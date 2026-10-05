CREATE OR ALTER PROCEDURE dbo.SP_CAMBIAR_ESTADO_VERSION_ET
(
      @VersionId   INT
    , @Accion      VARCHAR(50)
    , @Comentario  VARCHAR(2000) = NULL
    , @Usuario     VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
          @DocumentoId INT
        , @EstVerActualId INT
        , @EstadoActual VARCHAR(100)
        , @EstVerDestinoId INT
        , @EstadoDestino VARCHAR(100)
        , @AccionNormalizada VARCHAR(50)
        , @FechaVigencia DATE
        , @VersionVigenteAnteriorId INT;

    BEGIN TRY
        SET @AccionNormalizada = UPPER(NULLIF(LTRIM(RTRIM(@Accion)), ''));
        SET @Comentario = NULLIF(LTRIM(RTRIM(@Comentario)), '');
        SET @Usuario = NULLIF(LTRIM(RTRIM(@Usuario)), '');

        IF @VersionId IS NULL OR @VersionId <= 0
        BEGIN SELECT 1 CodigoResultado, 'La versión es obligatoria.' Mensaje; RETURN; END;

        IF @AccionNormalizada IS NULL
        BEGIN SELECT 2 CodigoResultado, 'La acción es obligatoria.' Mensaje; RETURN; END;

        IF @Usuario IS NULL
        BEGIN SELECT 3 CodigoResultado, 'El usuario es obligatorio.' Mensaje; RETURN; END;

        IF @AccionNormalizada NOT IN
        ('ENVIAR_REVISION','OBSERVAR','VERIFICAR','PUBLICAR','VIGENTAR','RETORNAR_BORRADOR')
        BEGIN SELECT 4 CodigoResultado, 'La acción indicada no es válida.' Mensaje; RETURN; END;

        IF @AccionNormalizada = 'OBSERVAR' AND @Comentario IS NULL
        BEGIN SELECT 5 CodigoResultado, 'Debe registrar un comentario para observar la Especificación Técnica.' Mensaje; RETURN; END;

        BEGIN TRANSACTION;

        SELECT @DocumentoId=V.DocumentoId,@EstVerActualId=V.EstVerId,@EstadoActual=EV.EstVerDescripcion
        FROM dbo.VERSION V WITH (UPDLOCK,HOLDLOCK)
        INNER JOIN dbo.ESTADOVERSION EV ON EV.EstVerId=V.EstVerId
        INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId=V.DocumentoId
        INNER JOIN dbo.TIPO_DOCUMENTO TD ON TD.TipoDocumentoId=D.TipoDocumentoId
        WHERE V.VersionId=@VersionId AND V.Estado=1 AND D.Estado=1 AND TD.Estado=1
          AND TD.TipoDocumentoDescripcion='ESPECIFICACIÓN TÉCNICA';

        IF @EstVerActualId IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 6 CodigoResultado,'La versión indicada no existe, está inactiva o no pertenece a una Especificación Técnica.' Mensaje;
            RETURN;
        END;

        SET @EstadoDestino=CASE
            WHEN @EstadoActual='BORRADOR' AND @AccionNormalizada='ENVIAR_REVISION' THEN 'PENDIENTE_REVISION'
            WHEN @EstadoActual='PENDIENTE_REVISION' AND @AccionNormalizada='VERIFICAR' THEN 'VERIFICADO'
            WHEN @EstadoActual='VERIFICADO' AND @AccionNormalizada='PUBLICAR' THEN 'PUBLICADO'
            WHEN @EstadoActual='PUBLICADO' AND @AccionNormalizada='VIGENTAR' THEN 'VIGENTE'
            WHEN @EstadoActual='VERIFICADO' AND @AccionNormalizada='OBSERVAR' THEN 'PENDIENTE_REVISION'
            WHEN @EstadoActual='PENDIENTE_REVISION' AND @AccionNormalizada='OBSERVAR' THEN 'BORRADOR'
            WHEN @EstadoActual='VIGENTE' AND @AccionNormalizada='RETORNAR_BORRADOR' THEN 'BORRADOR'
            ELSE NULL END;

        IF @EstadoDestino IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 7 CodigoResultado,
                   CONCAT('La acción ',@AccionNormalizada,' no está permitida cuando la versión se encuentra en estado ',@EstadoActual,'.') Mensaje,
                   @VersionId VersionId,@EstVerActualId EstVerActualId,@EstadoActual EstadoActual,@AccionNormalizada Accion;
            RETURN;
        END;

        SELECT @EstVerDestinoId=EV.EstVerId
        FROM dbo.ESTADOVERSION EV
        WHERE EV.EstVerDescripcion=@EstadoDestino AND EV.Estado=1;

        IF @EstVerDestinoId IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 8 CodigoResultado,CONCAT('No se encuentra configurado el estado destino ',@EstadoDestino,'.') Mensaje;
            RETURN;
        END;

        IF @AccionNormalizada='VIGENTAR'
        BEGIN
            SET @FechaVigencia=CAST(GETDATE() AS DATE);
            SELECT @VersionVigenteAnteriorId=MAX(V.VersionId)
            FROM dbo.VERSION V WITH (UPDLOCK,HOLDLOCK)
            WHERE V.DocumentoId=@DocumentoId AND V.VersionId<>@VersionId AND V.EstVerId=1 AND V.Estado=1
              AND V.VersionInicioVigencia<=@FechaVigencia
              AND (V.VersionFinVigencia IS NULL OR V.VersionFinVigencia>=@FechaVigencia);

            UPDATE dbo.VERSION
               SET VersionFinVigencia=DATEADD(DAY,-1,@FechaVigencia),
                   AudUsuarioModificacion=@Usuario,AudFechaActualizacion=SYSDATETIME()
             WHERE DocumentoId=@DocumentoId AND VersionId<>@VersionId AND EstVerId=1 AND Estado=1
               AND VersionInicioVigencia<=@FechaVigencia
               AND (VersionFinVigencia IS NULL OR VersionFinVigencia>=@FechaVigencia);
        END;

        UPDATE dbo.VERSION
           SET EstVerId=@EstVerDestinoId,
               VersionInicioVigencia=CASE WHEN @AccionNormalizada='VIGENTAR' THEN @FechaVigencia ELSE VersionInicioVigencia END,
               VersionFinVigencia=CASE WHEN @AccionNormalizada='VIGENTAR' THEN NULL ELSE VersionFinVigencia END,
               AudUsuarioModificacion=@Usuario,
               AudFechaActualizacion=SYSDATETIME()
         WHERE VersionId=@VersionId;

        INSERT INTO dbo.VERSIONHISTORIALESTADO
        (VersionId,EstVerOrigenId,EstVerDestinoId,Accion,Comentario,Usuario,Fecha,Estado)
        VALUES
        (@VersionId,@EstVerActualId,@EstVerDestinoId,@AccionNormalizada,@Comentario,@Usuario,SYSDATETIME(),1);

        COMMIT TRANSACTION;

        SELECT 0 CodigoResultado,
               CASE @AccionNormalizada
                 WHEN 'ENVIAR_REVISION' THEN 'La Especificación Técnica fue enviada a revisión correctamente.'
                 WHEN 'VERIFICAR' THEN 'La Especificación Técnica fue verificada correctamente.'
                 WHEN 'PUBLICAR' THEN 'La Especificación Técnica fue publicada correctamente.'
                 WHEN 'VIGENTAR' THEN 'La Especificación Técnica entró en vigencia correctamente.'
                 WHEN 'OBSERVAR' THEN 'La Especificación Técnica fue observada y devuelta a la etapa anterior correctamente.'
                 WHEN 'RETORNAR_BORRADOR' THEN 'La Especificación Técnica vigente fue enviada a borrador correctamente.'
                 ELSE 'Estado de la Especificación Técnica actualizado correctamente.'
               END Mensaje,
               @VersionId VersionId,@EstVerActualId EstVerOrigenId,@EstadoActual EstadoOrigen,
               @EstVerDestinoId EstVerDestinoId,@EstadoDestino EstadoDestino,@AccionNormalizada Accion,
               @Comentario Comentario,@VersionVigenteAnteriorId VersionVigenteAnteriorId,
               CASE WHEN @AccionNormalizada='VIGENTAR' THEN @FechaVigencia ELSE NULL END FechaVigencia;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        SELECT -1 CodigoResultado,ERROR_MESSAGE() Mensaje;
    END CATCH
END;
