CREATE OR ALTER PROCEDURE dbo.SP_GENERAR_LOTE_GENESIS
(
      @CodigoGenesis  VARCHAR(30)
    , @NaturalezaId   INT
    , @FaseId         INT
    , @LineaOrigenId  INT
    , @Observacion    VARCHAR(MAX) = NULL
    , @Usuario        VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
          @DocumentoId                 INT
        , @DocumentoCodigo             VARCHAR(50)
        , @VersionId                   INT
        , @VersionNumero               DECIMAL(10,2)
        , @NumeroCorrelativoId         INT
        , @Correlativo                 INT
        , @CodigoLote                  VARCHAR(20)
        , @EstadoLoteId                INT
        , @LoteId                      INT
        , @NombreGenesis               VARCHAR(500)
        , @Kardex                      INT
        , @TipoEvaluacionRutinaId      INT
        , @EstadoEvaluacionPendienteId INT
        , @EvaluacionId                INT
        , @VersionFaseId               INT;

    DECLARE @ResultadoLote TABLE
    (
          LoteId                        INT
        , CodigoLote                    VARCHAR(20)
        , CodigoGenesis                 VARCHAR(30)
        , Kardex                        INT
        , ProductoDescripcion           VARCHAR(500)
        , DocumentoId                   INT
        , DocumentoCodigo               VARCHAR(50)
        , DocumentoDescripcionDocumento VARCHAR(300)
        , VersionId                     INT
        , VersionNumero                 DECIMAL(10,2)
        , Naturaleza                    VARCHAR(20)
        , NaturalezaDescripcion         VARCHAR(200)
        , Fase                          VARCHAR(20)
        , FaseDescripcion               VARCHAR(200)
        , LineaOrigen                   VARCHAR(20)
        , LineaOrigenDescripcion        VARCHAR(200)
        , EstadoLote                    VARCHAR(20)
        , EstadoLoteDescripcion         VARCHAR(200)
        , FechaHoraProduccion           DATETIME2
        , Observacion                   VARCHAR(MAX)
        , AudUsuarioCreacion            VARCHAR(100)
        , AudFechaCreacion              DATETIME2
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        SET @CodigoGenesis = NULLIF(LTRIM(RTRIM(@CodigoGenesis)), '');

        IF @CodigoGenesis IS NULL
        BEGIN
            RAISERROR('Debe indicar el Código Génesis.', 16, 1);
        END;

        IF @CodigoGenesis = 'Por Definir'
        BEGIN
            RAISERROR('El Código Génesis no es válido.', 16, 1);
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.GENESIS_ITEM GI
            WHERE LTRIM(RTRIM(GI.CodigoGenesis)) = @CodigoGenesis
        )
        BEGIN
            RAISERROR('El Código Génesis no existe.', 16, 1);
        END;

        SELECT TOP (1)
              @NombreGenesis = GI.NombreGenesis
            , @Kardex        = GI.Kardex
        FROM dbo.GENESIS_ITEM GI
        WHERE LTRIM(RTRIM(GI.CodigoGenesis)) = @CodigoGenesis
        ORDER BY GI.GenesisItemId;

        EXEC dbo.SP_OBTENER_VERSION_VIGENTE_GENESIS
              @CodigoGenesis   = @CodigoGenesis
            , @DocumentoId     = @DocumentoId OUTPUT
            , @DocumentoCodigo = @DocumentoCodigo OUTPUT
            , @VersionId       = @VersionId OUTPUT
            , @VersionNumero   = @VersionNumero OUTPUT;

        IF @VersionId IS NULL
        BEGIN
            RAISERROR(
                'No se encontró una Especificación Técnica vigente para el Código Génesis.',
                16,
                1
            );
        END;

        /*
            Si la versión tiene una ruta de evaluación configurada,
            la evaluación inicial debe nacer asociada a su primera etapa.
            Para versiones legacy sin VERSIONFASE se conserva VersionFaseId = NULL.
        */
        SELECT TOP (1)
            @VersionFaseId = VF.VersionFaseId
        FROM dbo.VERSIONFASE VF
        WHERE VF.VersionId = @VersionId
          AND VF.Estado = 1
        ORDER BY VF.Orden, VF.VersionFaseId;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.VERSIONFASE VF
            WHERE VF.VersionId = @VersionId
              AND VF.Estado = 1
        )
        AND @VersionFaseId IS NULL
        BEGIN
            RAISERROR(
                'La Especificación Técnica tiene una ruta de evaluación inválida: no fue posible determinar la primera etapa.',
                16,
                1
            );
        END;

        IF @VersionFaseId IS NOT NULL
           AND NOT EXISTS
           (
               SELECT 1
               FROM dbo.VERSIONCARACTERISTICA VC
               WHERE VC.VersionId = @VersionId
                 AND VC.VersionFaseId = @VersionFaseId
                 AND VC.Estado = 1
           )
        BEGIN
            RAISERROR(
                'La primera etapa de evaluación no tiene características activas configuradas.',
                16,
                1
            );
        END;

        SELECT
            @EstadoLoteId = EstadoLoteId
        FROM dbo.ESTADO_LOTE
        WHERE Codigo = 'PENDIENTE';

        IF @EstadoLoteId IS NULL
        BEGIN
            RAISERROR('No existe el estado PENDIENTE para el lote.', 16, 1);
        END;

        EXEC dbo.SP_OBTENER_SIGUIENTE_CORRELATIVO
              @NaturalezaId        = @NaturalezaId
            , @FaseId              = @FaseId
            , @LineaOrigenId        = @LineaOrigenId
            , @NumeroCorrelativoId = @NumeroCorrelativoId OUTPUT
            , @Correlativo         = @Correlativo OUTPUT
            , @CodigoLote          = @CodigoLote OUTPUT;

        IF @NumeroCorrelativoId IS NULL
           OR @CodigoLote IS NULL
        BEGIN
            RAISERROR('No fue posible obtener el correlativo del lote.', 16, 1);
        END;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.LOTE
            WHERE CodigoLote = @CodigoLote
        )
        BEGIN
            RAISERROR('El código de lote ya existe.', 16, 1);
        END;

        DECLARE @TMP TABLE
        (
            LoteId INT
        );

        INSERT INTO dbo.LOTE
        (
              CodigoLote
            , ProductoCodigo
            , CodigoGenesis
            , VersionId
            , NumeroCorrelativoId
            , Correlativo
            , FechaHoraProduccion
            , EstadoLoteId
            , Observacion
            , Estado
            , AudUsuarioCreacion
        )
        OUTPUT INSERTED.LoteId
        INTO @TMP
        VALUES
        (
              @CodigoLote
            , NULL
            , @CodigoGenesis
            , @VersionId
            , @NumeroCorrelativoId
            , @Correlativo
            , GETDATE()
            , @EstadoLoteId
            , @Observacion
            , 'ACTIVO'
            , @Usuario
        );

        SELECT
            @LoteId = LoteId
        FROM @TMP;

        INSERT INTO @ResultadoLote
        (
              LoteId
            , CodigoLote
            , CodigoGenesis
            , Kardex
            , ProductoDescripcion
            , DocumentoId
            , DocumentoCodigo
            , DocumentoDescripcionDocumento
            , VersionId
            , VersionNumero
            , Naturaleza
            , NaturalezaDescripcion
            , Fase
            , FaseDescripcion
            , LineaOrigen
            , LineaOrigenDescripcion
            , EstadoLote
            , EstadoLoteDescripcion
            , FechaHoraProduccion
            , Observacion
            , AudUsuarioCreacion
            , AudFechaCreacion
        )
        SELECT
              L.LoteId
            , L.CodigoLote
            , L.CodigoGenesis
            , @Kardex
            , @NombreGenesis
            , D.DocumentoId
            , D.DocumentoCodigo
            , D.DocumentoDescripcionDocumento
            , V.VersionId
            , V.VersionNumero
            , N.Codigo
            , N.Descripcion
            , F.Codigo
            , F.Descripcion
            , LO.Codigo
            , LO.Descripcion
            , EL.Codigo
            , EL.Descripcion
            , L.FechaHoraProduccion
            , L.Observacion
            , L.AudUsuarioCreacion
            , L.AudFechaCreacion
        FROM dbo.LOTE L
        INNER JOIN dbo.VERSION V
            ON V.VersionId = L.VersionId
        INNER JOIN dbo.DOCUMENTO D
            ON D.DocumentoId = V.DocumentoId
        INNER JOIN dbo.NUMERO_CORRELATIVO NC
            ON NC.NumeroCorrelativoId = L.NumeroCorrelativoId
        INNER JOIN dbo.NATURALEZA N
            ON N.NaturalezaId = NC.NaturalezaId
        INNER JOIN dbo.FASE F
            ON F.FaseId = NC.FaseId
        INNER JOIN dbo.LINEA_ORIGEN LO
            ON LO.LineaOrigenId = NC.LineaOrigenId
        INNER JOIN dbo.ESTADO_LOTE EL
            ON EL.EstadoLoteId = L.EstadoLoteId
        WHERE L.LoteId = @LoteId;

        SELECT
            @TipoEvaluacionRutinaId = TipoEvaluacionId
        FROM dbo.TIPO_EVALUACION
        WHERE Codigo = 'RUTINA'
          AND Estado = 'ACTIVO';

        IF @TipoEvaluacionRutinaId IS NULL
        BEGIN
            RAISERROR('No existe el tipo de evaluación RUTINA activo.', 16, 1);
        END;

        SELECT
            @EstadoEvaluacionPendienteId = EstadoEvaluacionId
        FROM dbo.ESTADO_EVALUACION
        WHERE Codigo = 'PENDIENTE';

        IF @EstadoEvaluacionPendienteId IS NULL
        BEGIN
            RAISERROR('No existe el estado de evaluación PENDIENTE.', 16, 1);
        END;

        INSERT INTO dbo.EVALUACION
        (
              LoteId
            , EvaluacionPadreId
            , TipoEvaluacionId
            , EstadoEvaluacionId
            , Intento
            , FechaInicio
            , FechaFin
            , MotivoReevaluacion
            , Observacion
            , Estado
            , AudUsuarioCreacion
            , AudFechaCreacion
            , UsuarioEvaluador
            , ResultadoGeneral
            , VersionFaseId
        )
        VALUES
        (
              @LoteId
            , NULL
            , @TipoEvaluacionRutinaId
            , @EstadoEvaluacionPendienteId
            , 1
            , NULL
            , NULL
            , NULL
            , NULL
            , 'ACTIVO'
            , @Usuario
            , SYSDATETIME()
            , NULL
            , NULL
            , @VersionFaseId
        );

        SET @EvaluacionId = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SELECT
              0 AS CodigoResultado
            , 'Lote generado correctamente.' AS Mensaje;

        SELECT
              RL.*
            , @EvaluacionId AS EvaluacionId
            , 'RUTINA' AS TipoEvaluacion
            , 'PENDIENTE' AS EstadoEvaluacion
            , @VersionFaseId AS VersionFaseId
        FROM @ResultadoLote RL;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
              -1 AS CodigoResultado
            , ERROR_MESSAGE() AS Mensaje;

        SELECT TOP (0)
            *
        FROM @ResultadoLote;
    END CATCH;
END;
GO
