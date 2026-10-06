/*
OVOCALIDAD 2.0
Evaluaciones por etapa - Bloque 1
SP_CREAR_EVALUACION

Reglas:
- Si es una reevaluación, conserva la misma VersionFaseId de la evaluación padre.
- Si es una evaluación inicial y la versión tiene ruta VERSIONFASE, toma la primera etapa activa por Orden.
- Si la versión aún no tiene VERSIONFASE, conserva compatibilidad legacy con VersionFaseId = NULL.
*/
CREATE OR ALTER PROCEDURE dbo.SP_CREAR_EVALUACION
(
      @LoteId             INT
    , @TipoEvaluacionId   INT
    , @Usuario            VARCHAR(100)
    , @UsuarioEvaluador   VARCHAR(100) = NULL
    , @EvaluacionPadreId  INT = NULL
    , @MotivoReevaluacion VARCHAR(500) = NULL
    , @Observacion        VARCHAR(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
          @Intento             SMALLINT
        , @EvaluacionId        INT
        , @EstadoPendienteId   INT
        , @CodigoLote          VARCHAR(20)
        , @ProductoCodigo      VARCHAR(50)
        , @VersionId           INT
        , @VersionFaseId       INT
        , @VersionFaseOrden    INT
        , @CodigoReferencia    VARCHAR(30)
        , @FaseCodigo          VARCHAR(20)
        , @EsFinal             BIT;

    BEGIN TRY
        BEGIN TRANSACTION;

        /* 1. ESTADO PENDIENTE */
        SELECT @EstadoPendienteId = EstadoEvaluacionId
        FROM dbo.ESTADO_EVALUACION
        WHERE Codigo = 'PENDIENTE';

        IF @EstadoPendienteId IS NULL
            RAISERROR('No existe el estado PENDIENTE.',16,1);

        /* 2. VALIDAR LOTE Y OBTENER VERSION */
        SELECT
              @CodigoLote = L.CodigoLote
            , @ProductoCodigo = L.ProductoCodigo
            , @VersionId = L.VersionId
        FROM dbo.LOTE L WITH (UPDLOCK, HOLDLOCK)
        WHERE L.LoteId = @LoteId
          AND L.Estado = 'ACTIVO';

        IF @CodigoLote IS NULL
            RAISERROR('El lote no existe o se encuentra inactivo.',16,1);

        /* 3. VALIDAR TIPO */
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.TIPO_EVALUACION
            WHERE TipoEvaluacionId = @TipoEvaluacionId
              AND Estado = 'ACTIVO'
        )
            RAISERROR('El tipo de evaluación no existe o se encuentra inactivo.',16,1);

        /* 4. VALIDAR EVALUACION ABIERTA */
        IF EXISTS
        (
            SELECT 1
            FROM dbo.EVALUACION E
            INNER JOIN dbo.ESTADO_EVALUACION EE
                ON EE.EstadoEvaluacionId = E.EstadoEvaluacionId
            WHERE E.LoteId = @LoteId
              AND EE.Codigo IN ('PENDIENTE','EN_PROCESO')
              AND E.Estado = 'ACTIVO'
        )
            RAISERROR('El lote ya posee una evaluación abierta.',16,1);

        /* 5. RESOLVER ETAPA */
        IF @EvaluacionPadreId IS NOT NULL
        BEGIN
            SELECT @VersionFaseId = E.VersionFaseId
            FROM dbo.EVALUACION E
            WHERE E.EvaluacionId = @EvaluacionPadreId
              AND E.LoteId = @LoteId
              AND E.Estado = 'ACTIVO';

            IF @@ROWCOUNT = 0
                RAISERROR('La evaluación padre no existe, está inactiva o pertenece a otro lote.',16,1);

            IF @VersionFaseId IS NOT NULL
               AND NOT EXISTS
               (
                   SELECT 1
                   FROM dbo.VERSIONFASE VF
                   WHERE VF.VersionFaseId = @VersionFaseId
                     AND VF.VersionId = @VersionId
                     AND VF.Estado = 1
               )
                RAISERROR('La etapa de la evaluación padre no pertenece a la versión vigente del lote.',16,1);
        END
        ELSE
        BEGIN
            SELECT TOP (1)
                  @VersionFaseId = VF.VersionFaseId
            FROM dbo.VERSIONFASE VF
            WHERE VF.VersionId = @VersionId
              AND VF.Estado = 1
            ORDER BY VF.Orden, VF.VersionFaseId;
        END;

        /* 6. DATOS DE ETAPA */
        IF @VersionFaseId IS NOT NULL
        BEGIN
            SELECT
                  @VersionFaseOrden = VF.Orden
                , @CodigoReferencia = VF.CodigoReferencia
                , @FaseCodigo = F.Codigo
                , @EsFinal = VF.EsFinal
            FROM dbo.VERSIONFASE VF
            INNER JOIN dbo.FASE F ON F.FaseId = VF.FaseId
            WHERE VF.VersionFaseId = @VersionFaseId
              AND VF.VersionId = @VersionId
              AND VF.Estado = 1;

            IF @VersionFaseOrden IS NULL
                RAISERROR('No fue posible resolver la etapa de evaluación.',16,1);

            IF NOT EXISTS
            (
                SELECT 1
                FROM dbo.VERSIONCARACTERISTICA VC
                WHERE VC.VersionId = @VersionId
                  AND VC.VersionFaseId = @VersionFaseId
                  AND VC.Estado = 1
            )
                RAISERROR('La etapa seleccionada no contiene características activas para evaluar.',16,1);
        END;

        /* 7. CALCULAR INTENTO
           Se conserva la semántica histórica: correlativo por lote. */
        SELECT @Intento = ISNULL(MAX(Intento),0) + 1
        FROM dbo.EVALUACION
        WHERE LoteId = @LoteId;

        /* 8. CREAR */
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
            , @EvaluacionPadreId
            , @TipoEvaluacionId
            , @EstadoPendienteId
            , @Intento
            , NULL
            , NULL
            , @MotivoReevaluacion
            , @Observacion
            , 'ACTIVO'
            , @Usuario
            , SYSDATETIME()
            , @UsuarioEvaluador
            , NULL
            , @VersionFaseId
        );

        SET @EvaluacionId = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        /* 9. RESPUESTA */
        SELECT
              0 AS CodigoResultado
            , CASE
                WHEN @VersionFaseId IS NULL
                    THEN 'Evaluación creada correctamente en modo legacy.'
                ELSE 'Evaluación creada correctamente para la etapa configurada.'
              END AS Mensaje
            , @EvaluacionId AS EvaluacionId
            , @LoteId AS LoteId
            , @CodigoLote AS CodigoLote
            , @ProductoCodigo AS ProductoCodigo
            , @VersionId AS VersionId
            , @VersionFaseId AS VersionFaseId
            , @VersionFaseOrden AS VersionFaseOrden
            , @CodigoReferencia AS CodigoReferencia
            , @FaseCodigo AS FaseCodigo
            , @EsFinal AS EsFinal
            , @Intento AS Intento
            , @UsuarioEvaluador AS UsuarioEvaluador
            , 'PENDIENTE' AS EstadoEvaluacion;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
              -1 AS CodigoResultado
            , ERROR_NUMBER() AS ErrorNumero
            , ERROR_LINE() AS ErrorLinea
            , ERROR_PROCEDURE() AS ErrorProcedimiento
            , ERROR_MESSAGE() AS Mensaje;
    END CATCH
END;
