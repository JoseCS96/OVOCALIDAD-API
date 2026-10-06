CREATE OR ALTER PROCEDURE dbo.SP_OBTENER_RUTA_EVALUACION_LOTE
(
    @LoteId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @VersionId INT;

    SELECT @VersionId = L.VersionId
    FROM dbo.LOTE L
    WHERE L.LoteId = @LoteId
      AND L.Estado = 'ACTIVO';

    IF @VersionId IS NULL
    BEGIN
        RAISERROR('El lote no existe o no está activo.', 16, 1);
        RETURN;
    END;

    /* RS1: ruta configurada de la ET y resumen operativo por etapa */
    SELECT
          VF.VersionFaseId
        , VF.Orden
        , VF.CodigoReferencia
        , VF.Descripcion AS VersionFaseDescripcion
        , VF.FaseId
        , F.Codigo AS FaseCodigo
        , F.Descripcion AS FaseDescripcion
        , VF.EsFinal
        , VF.EsObligatoria
        , COUNT(DISTINCT CASE WHEN VC.Estado = 1 THEN VC.VersCaractId END) AS CantidadCaracteristicas
        , COUNT(DISTINCT CASE WHEN E.Estado = 'ACTIVO' THEN E.EvaluacionId END) AS CantidadIntentos
        , MAX(CASE WHEN E.Estado = 'ACTIVO' THEN E.EvaluacionId END) AS UltimaEvaluacionId
        , CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM dbo.EVALUACION EX
                INNER JOIN dbo.ESTADO_EVALUACION EEX
                    ON EEX.EstadoEvaluacionId = EX.EstadoEvaluacionId
                WHERE EX.LoteId = @LoteId
                  AND EX.VersionFaseId = VF.VersionFaseId
                  AND EX.Estado = 'ACTIVO'
                  AND EEX.Codigo IN ('EN_PROCESO','PENDIENTE','PENDIENTE_REAPERTURA')
            ) THEN 'EN_PROCESO'
            WHEN EXISTS
            (
                SELECT 1
                FROM dbo.EVALUACION EX
                WHERE EX.LoteId = @LoteId
                  AND EX.VersionFaseId = VF.VersionFaseId
                  AND EX.Estado = 'ACTIVO'
                  AND EX.ResultadoGeneral = 0
            ) AND NOT EXISTS
            (
                SELECT 1
                FROM dbo.EVALUACION EX
                WHERE EX.LoteId = @LoteId
                  AND EX.VersionFaseId = VF.VersionFaseId
                  AND EX.Estado = 'ACTIVO'
                  AND EX.ResultadoGeneral = 1
            ) THEN 'NO_CONFORME'
            WHEN EXISTS
            (
                SELECT 1
                FROM dbo.EVALUACION EX
                WHERE EX.LoteId = @LoteId
                  AND EX.VersionFaseId = VF.VersionFaseId
                  AND EX.Estado = 'ACTIVO'
                  AND EX.ResultadoGeneral = 1
            ) THEN 'CONFORME'
            ELSE 'PENDIENTE'
          END AS EstadoEtapa
    FROM dbo.VERSIONFASE VF
    INNER JOIN dbo.FASE F
        ON F.FaseId = VF.FaseId
    LEFT JOIN dbo.VERSIONCARACTERISTICA VC
        ON VC.VersionFaseId = VF.VersionFaseId
       AND VC.VersionId = VF.VersionId
       AND VC.Estado = 1
    LEFT JOIN dbo.EVALUACION E
        ON E.LoteId = @LoteId
       AND E.VersionFaseId = VF.VersionFaseId
       AND E.Estado = 'ACTIVO'
    WHERE VF.VersionId = @VersionId
      AND VF.Estado = 1
    GROUP BY
          VF.VersionFaseId
        , VF.Orden
        , VF.CodigoReferencia
        , VF.Descripcion
        , VF.FaseId
        , F.Codigo
        , F.Descripcion
        , VF.EsFinal
        , VF.EsObligatoria
    ORDER BY VF.Orden, VF.VersionFaseId;

    /* RS2: todos los intentos históricos del lote */
    SELECT
          E.EvaluacionId
        , E.VersionFaseId
        , VF.Orden AS VersionFaseOrden
        , VF.CodigoReferencia
        , E.EvaluacionPadreId
        , E.Intento
        , E.TipoEvaluacionId
        , TE.Codigo AS TipoEvaluacion
        , E.EstadoEvaluacionId
        , EE.Codigo AS EstadoEvaluacion
        , E.ResultadoGeneral
        , E.UsuarioEvaluador
        , E.FechaInicio
        , E.FechaFin
        , E.MotivoReevaluacion
        , E.Observacion
        , CAST(CASE WHEN E.EvaluacionPadreId IS NULL THEN 0 ELSE 1 END AS BIT) AS EsReevaluacion
        , COUNT(ER.EvaluacionResultadoId) AS ResultadosRegistrados
        , SUM(CASE WHEN ER.Cumple = 1 THEN 1 ELSE 0 END) AS ResultadosConformes
        , SUM(CASE WHEN ER.Cumple = 0 THEN 1 ELSE 0 END) AS ResultadosNoConformes
    FROM dbo.EVALUACION E
    LEFT JOIN dbo.VERSIONFASE VF
        ON VF.VersionFaseId = E.VersionFaseId
    INNER JOIN dbo.TIPO_EVALUACION TE
        ON TE.TipoEvaluacionId = E.TipoEvaluacionId
    INNER JOIN dbo.ESTADO_EVALUACION EE
        ON EE.EstadoEvaluacionId = E.EstadoEvaluacionId
    LEFT JOIN dbo.EVALUACION_RESULTADO ER
        ON ER.EvaluacionId = E.EvaluacionId
       AND ER.Estado = 'ACTIVO'
    WHERE E.LoteId = @LoteId
      AND E.Estado = 'ACTIVO'
    GROUP BY
          E.EvaluacionId
        , E.VersionFaseId
        , VF.Orden
        , VF.CodigoReferencia
        , E.EvaluacionPadreId
        , E.Intento
        , E.TipoEvaluacionId
        , TE.Codigo
        , E.EstadoEvaluacionId
        , EE.Codigo
        , E.ResultadoGeneral
        , E.UsuarioEvaluador
        , E.FechaInicio
        , E.FechaFin
        , E.MotivoReevaluacion
        , E.Observacion
    ORDER BY E.Intento, E.EvaluacionId;
END;
GO
