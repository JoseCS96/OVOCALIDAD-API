/*
 OVOCALIDAD 2.0 - Workflow documental de Ficha Técnica.
 Alcance controlado:
 - Solo TipoDocumentoId = 3 (FICHA TÉCNICA).
 - No modifica ET, evaluaciones, certificados ni firmas.
 - Reutiliza ESTADOVERSION y VERSIONHISTORIALESTADO existentes.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

CREATE OR ALTER PROCEDURE dbo.SP_CAMBIAR_ESTADO_VERSION_FT
(
      @VersionId   INT
    , @Accion      VARCHAR(50)
    , @Comentario  VARCHAR(2000) = NULL
    , @Usuario     VARCHAR(100)
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
        BEGIN
            SELECT
                  1 AS CodigoResultado
                , 'La versión es obligatoria.' AS Mensaje
                , CAST(NULL AS INT) AS VersionId
                , CAST(NULL AS INT) AS EstVerOrigenId
                , CAST(NULL AS VARCHAR(100)) AS EstadoOrigen
                , CAST(NULL AS INT) AS EstVerDestinoId
                , CAST(NULL AS VARCHAR(100)) AS EstadoDestino
                , @AccionNormalizada AS Accion
                , @Comentario AS Comentario
                , CAST(NULL AS INT) AS VersionVigenteAnteriorId
                , CAST(NULL AS DATE) AS FechaVigencia;
            RETURN;
        END;

        IF @AccionNormalizada IS NULL
        BEGIN
            SELECT
                  2 AS CodigoResultado
                , 'La acción es obligatoria.' AS Mensaje
                , @VersionId AS VersionId
                , CAST(NULL AS INT) AS EstVerOrigenId
                , CAST(NULL AS VARCHAR(100)) AS EstadoOrigen
                , CAST(NULL AS INT) AS EstVerDestinoId
                , CAST(NULL AS VARCHAR(100)) AS EstadoDestino
                , CAST(NULL AS VARCHAR(50)) AS Accion
                , @Comentario AS Comentario
                , CAST(NULL AS INT) AS VersionVigenteAnteriorId
                , CAST(NULL AS DATE) AS FechaVigencia;
            RETURN;
        END;

        IF @Usuario IS NULL
        BEGIN
            SELECT
                  3 AS CodigoResultado
                , 'El usuario es obligatorio.' AS Mensaje
                , @VersionId AS VersionId
                , CAST(NULL AS INT) AS EstVerOrigenId
                , CAST(NULL AS VARCHAR(100)) AS EstadoOrigen
                , CAST(NULL AS INT) AS EstVerDestinoId
                , CAST(NULL AS VARCHAR(100)) AS EstadoDestino
                , @AccionNormalizada AS Accion
                , @Comentario AS Comentario
                , CAST(NULL AS INT) AS VersionVigenteAnteriorId
                , CAST(NULL AS DATE) AS FechaVigencia;
            RETURN;
        END;

        IF @AccionNormalizada NOT IN
        (
            'ENVIAR_REVISION',
            'OBSERVAR',
            'VERIFICAR',
            'PUBLICAR',
            'VIGENTAR',
            'RETORNAR_BORRADOR'
        )
        BEGIN
            SELECT
                  4 AS CodigoResultado
                , 'La acción indicada no es válida.' AS Mensaje
                , @VersionId AS VersionId
                , CAST(NULL AS INT) AS EstVerOrigenId
                , CAST(NULL AS VARCHAR(100)) AS EstadoOrigen
                , CAST(NULL AS INT) AS EstVerDestinoId
                , CAST(NULL AS VARCHAR(100)) AS EstadoDestino
                , @AccionNormalizada AS Accion
                , @Comentario AS Comentario
                , CAST(NULL AS INT) AS VersionVigenteAnteriorId
                , CAST(NULL AS DATE) AS FechaVigencia;
            RETURN;
        END;

        IF @AccionNormalizada = 'OBSERVAR'
           AND @Comentario IS NULL
        BEGIN
            SELECT
                  5 AS CodigoResultado
                , 'Debe registrar un comentario para observar la Ficha Técnica.' AS Mensaje
                , @VersionId AS VersionId
                , CAST(NULL AS INT) AS EstVerOrigenId
                , CAST(NULL AS VARCHAR(100)) AS EstadoOrigen
                , CAST(NULL AS INT) AS EstVerDestinoId
                , CAST(NULL AS VARCHAR(100)) AS EstadoDestino
                , @AccionNormalizada AS Accion
                , @Comentario AS Comentario
                , CAST(NULL AS INT) AS VersionVigenteAnteriorId
                , CAST(NULL AS DATE) AS FechaVigencia;
            RETURN;
        END;

        BEGIN TRANSACTION;

        SELECT
              @DocumentoId = V.DocumentoId
            , @EstVerActualId = V.EstVerId
            , @EstadoActual = EV.EstVerDescripcion
        FROM dbo.VERSION V WITH (UPDLOCK, HOLDLOCK)
        INNER JOIN dbo.ESTADOVERSION EV
            ON EV.EstVerId = V.EstVerId
        INNER JOIN dbo.DOCUMENTO D
            ON D.DocumentoId = V.DocumentoId
        WHERE V.VersionId = @VersionId
          AND V.Estado = 1
          AND D.Estado = 1
          AND D.TipoDocumentoId = 3;

        IF @EstVerActualId IS NULL
        BEGIN
            ROLLBACK TRANSACTION;

            SELECT
                  6 AS CodigoResultado
                , 'La versión indicada no existe, está inactiva o no pertenece a una Ficha Técnica.' AS Mensaje
                , @VersionId AS VersionId
                , CAST(NULL AS INT) AS EstVerOrigenId
                , CAST(NULL AS VARCHAR(100)) AS EstadoOrigen
                , CAST(NULL AS INT) AS EstVerDestinoId
                , CAST(NULL AS VARCHAR(100)) AS EstadoDestino
                , @AccionNormalizada AS Accion
                , @Comentario AS Comentario
                , CAST(NULL AS INT) AS VersionVigenteAnteriorId
                , CAST(NULL AS DATE) AS FechaVigencia;
            RETURN;
        END;

        SET @EstadoDestino =
            CASE
                WHEN @EstadoActual = 'BORRADOR'
                 AND @AccionNormalizada = 'ENVIAR_REVISION'
                    THEN 'PENDIENTE_REVISION'

                WHEN @EstadoActual = 'PENDIENTE_REVISION'
                 AND @AccionNormalizada = 'VERIFICAR'
                    THEN 'VERIFICADO'

                WHEN @EstadoActual = 'VERIFICADO'
                 AND @AccionNormalizada = 'PUBLICAR'
                    THEN 'PUBLICADO'

                WHEN @EstadoActual = 'PUBLICADO'
                 AND @AccionNormalizada = 'VIGENTAR'
                    THEN 'VIGENTE'

                WHEN @EstadoActual = 'PENDIENTE_REVISION'
                 AND @AccionNormalizada = 'OBSERVAR'
                    THEN 'BORRADOR'

                WHEN @EstadoActual = 'VERIFICADO'
                 AND @AccionNormalizada = 'OBSERVAR'
                    THEN 'PENDIENTE_REVISION'

                /* Solo para pruebas/control administrativo actual.
                   No forma parte del avance normal. */
                WHEN @EstadoActual = 'VIGENTE'
                 AND @AccionNormalizada = 'RETORNAR_BORRADOR'
                    THEN 'BORRADOR'

                ELSE NULL
            END;

        IF @EstadoDestino IS NULL
        BEGIN
            ROLLBACK TRANSACTION;

            SELECT
                  7 AS CodigoResultado
                , CONCAT(
                    'La acción ',
                    @AccionNormalizada,
                    ' no está permitida cuando la Ficha Técnica se encuentra en estado ',
                    @EstadoActual,
                    '.'
                  ) AS Mensaje
                , @VersionId AS VersionId
                , @EstVerActualId AS EstVerOrigenId
                , @EstadoActual AS EstadoOrigen
                , CAST(NULL AS INT) AS EstVerDestinoId
                , CAST(NULL AS VARCHAR(100)) AS EstadoDestino
                , @AccionNormalizada AS Accion
                , @Comentario AS Comentario
                , CAST(NULL AS INT) AS VersionVigenteAnteriorId
                , CAST(NULL AS DATE) AS FechaVigencia;
            RETURN;
        END;

        SELECT
            @EstVerDestinoId = EV.EstVerId
        FROM dbo.ESTADOVERSION EV
        WHERE EV.EstVerDescripcion = @EstadoDestino
          AND EV.Estado = 1;

        IF @EstVerDestinoId IS NULL
        BEGIN
            ROLLBACK TRANSACTION;

            SELECT
                  8 AS CodigoResultado
                , CONCAT(
                    'No se encuentra configurado el estado destino ',
                    @EstadoDestino,
                    '.'
                  ) AS Mensaje
                , @VersionId AS VersionId
                , @EstVerActualId AS EstVerOrigenId
                , @EstadoActual AS EstadoOrigen
                , CAST(NULL AS INT) AS EstVerDestinoId
                , @EstadoDestino AS EstadoDestino
                , @AccionNormalizada AS Accion
                , @Comentario AS Comentario
                , CAST(NULL AS INT) AS VersionVigenteAnteriorId
                , CAST(NULL AS DATE) AS FechaVigencia;
            RETURN;
        END;

        IF @AccionNormalizada = 'VIGENTAR'
        BEGIN
            SET @FechaVigencia = CAST(GETDATE() AS DATE);

            SELECT
                @VersionVigenteAnteriorId = MAX(V.VersionId)
            FROM dbo.VERSION V WITH (UPDLOCK, HOLDLOCK)
            INNER JOIN dbo.ESTADOVERSION EV
                ON EV.EstVerId = V.EstVerId
            WHERE V.DocumentoId = @DocumentoId
              AND V.VersionId <> @VersionId
              AND V.Estado = 1
              AND EV.EstVerDescripcion = 'VIGENTE'
              AND V.VersionInicioVigencia <= @FechaVigencia
              AND
              (
                  V.VersionFinVigencia IS NULL
                  OR V.VersionFinVigencia >= @FechaVigencia
              );

            UPDATE V
            SET
                  V.VersionFinVigencia = DATEADD(DAY, -1, @FechaVigencia)
                , V.AudUsuarioModificacion = @Usuario
                , V.AudFechaActualizacion = SYSDATETIME()
            FROM dbo.VERSION V
            INNER JOIN dbo.ESTADOVERSION EV
                ON EV.EstVerId = V.EstVerId
            WHERE V.DocumentoId = @DocumentoId
              AND V.VersionId <> @VersionId
              AND V.Estado = 1
              AND EV.EstVerDescripcion = 'VIGENTE'
              AND V.VersionInicioVigencia <= @FechaVigencia
              AND
              (
                  V.VersionFinVigencia IS NULL
                  OR V.VersionFinVigencia >= @FechaVigencia
              );
        END;

        UPDATE dbo.VERSION
        SET
              EstVerId = @EstVerDestinoId
            , VersionInicioVigencia =
                CASE
                    WHEN @AccionNormalizada = 'VIGENTAR'
                        THEN @FechaVigencia
                    ELSE VersionInicioVigencia
                END
            , VersionFinVigencia =
                CASE
                    WHEN @AccionNormalizada = 'VIGENTAR'
                        THEN NULL
                    ELSE VersionFinVigencia
                END
            , AudUsuarioModificacion = @Usuario
            , AudFechaActualizacion = SYSDATETIME()
        WHERE VersionId = @VersionId;

        INSERT INTO dbo.VERSIONHISTORIALESTADO
        (
              VersionId
            , EstVerOrigenId
            , EstVerDestinoId
            , Accion
            , Comentario
            , Usuario
            , Fecha
            , Estado
        )
        VALUES
        (
              @VersionId
            , @EstVerActualId
            , @EstVerDestinoId
            , @AccionNormalizada
            , @Comentario
            , @Usuario
            , SYSDATETIME()
            , 1
        );

        COMMIT TRANSACTION;

        SELECT
              0 AS CodigoResultado
            , CASE @AccionNormalizada
                WHEN 'ENVIAR_REVISION'
                    THEN 'La Ficha Técnica fue enviada a revisión correctamente.'
                WHEN 'VERIFICAR'
                    THEN 'La Ficha Técnica fue verificada correctamente.'
                WHEN 'PUBLICAR'
                    THEN 'La Ficha Técnica fue publicada correctamente.'
                WHEN 'VIGENTAR'
                    THEN 'La Ficha Técnica entró en vigencia correctamente.'
                WHEN 'OBSERVAR'
                    THEN 'La Ficha Técnica fue observada y devuelta a la etapa anterior correctamente.'
                WHEN 'RETORNAR_BORRADOR'
                    THEN 'La Ficha Técnica fue enviada a borrador correctamente.'
                ELSE 'Estado de la Ficha Técnica actualizado correctamente.'
              END AS Mensaje
            , @VersionId AS VersionId
            , @EstVerActualId AS EstVerOrigenId
            , @EstadoActual AS EstadoOrigen
            , @EstVerDestinoId AS EstVerDestinoId
            , @EstadoDestino AS EstadoDestino
            , @AccionNormalizada AS Accion
            , @Comentario AS Comentario
            , @VersionVigenteAnteriorId AS VersionVigenteAnteriorId
            , CASE
                WHEN @AccionNormalizada = 'VIGENTAR'
                    THEN @FechaVigencia
                ELSE NULL
              END AS FechaVigencia;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
              -1 AS CodigoResultado
            , ERROR_MESSAGE() AS Mensaje
            , @VersionId AS VersionId
            , @EstVerActualId AS EstVerOrigenId
            , @EstadoActual AS EstadoOrigen
            , @EstVerDestinoId AS EstVerDestinoId
            , @EstadoDestino AS EstadoDestino
            , @AccionNormalizada AS Accion
            , @Comentario AS Comentario
            , @VersionVigenteAnteriorId AS VersionVigenteAnteriorId
            , @FechaVigencia AS FechaVigencia;
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_HISTORIAL_ESTADO_FT
(
    @VersionId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.VERSION V
        INNER JOIN dbo.DOCUMENTO D
            ON D.DocumentoId = V.DocumentoId
        WHERE V.VersionId = @VersionId
          AND D.TipoDocumentoId = 3
    )
    BEGIN
        SELECT TOP (0)
              CAST(NULL AS INT) AS VersionHistorialEstadoId
            , CAST(NULL AS INT) AS VersionId
            , CAST(NULL AS INT) AS EstVerOrigenId
            , CAST(NULL AS VARCHAR(100)) AS EstadoOrigen
            , CAST(NULL AS INT) AS EstVerDestinoId
            , CAST(NULL AS VARCHAR(100)) AS EstadoDestino
            , CAST(NULL AS VARCHAR(50)) AS Accion
            , CAST(NULL AS VARCHAR(2000)) AS Comentario
            , CAST(NULL AS VARCHAR(100)) AS Usuario
            , CAST(NULL AS DATETIME2) AS Fecha;
        RETURN;
    END;

    SELECT
          H.VersionHistorialEstadoId
        , H.VersionId
        , H.EstVerOrigenId
        , EO.EstVerDescripcion AS EstadoOrigen
        , H.EstVerDestinoId
        , ED.EstVerDescripcion AS EstadoDestino
        , H.Accion
        , H.Comentario
        , H.Usuario
        , H.Fecha
    FROM dbo.VERSIONHISTORIALESTADO H
    LEFT JOIN dbo.ESTADOVERSION EO
        ON EO.EstVerId = H.EstVerOrigenId
    INNER JOIN dbo.ESTADOVERSION ED
        ON ED.EstVerId = H.EstVerDestinoId
    WHERE H.VersionId = @VersionId
      AND H.Estado = 1
    ORDER BY H.Fecha DESC, H.VersionHistorialEstadoId DESC;
END;
GO
