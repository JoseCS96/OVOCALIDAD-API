CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_LOTES
(
      @CodigoLote          VARCHAR(20) = NULL
    , @ProductoCodigo      VARCHAR(50) = NULL
    , @CodigoGenesis       VARCHAR(30) = NULL
    , @EstadoLoteId        INT = NULL
    , @EstadoEvaluacionId  INT = NULL
    , @FechaDesde          DATE = NULL
    , @FechaHasta          DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
          L.LoteId
        , L.CodigoLote
        , COALESCE(L.ProductoCodigo, D.ProductoCodigo) AS ProductoCodigo
        , L.CodigoGenesis
        , CASE WHEN L.CodigoGenesis IS NOT NULL THEN GI.NombreGenesis ELSE P.ProductoDescripcion END AS ProductoDescripcion
        , L.Correlativo
        , L.FechaHoraProduccion
        , NC.NumeroCorrelativoId
        , N.NaturalezaId
        , N.Codigo AS NaturalezaCodigo
        , N.Descripcion AS NaturalezaDescripcion
        , F.FaseId
        , F.Codigo AS FaseCodigo
        , F.Descripcion AS FaseDescripcion
        , LO.LineaOrigenId
        , LO.Codigo AS LineaOrigenCodigo
        , LO.Descripcion AS LineaOrigenDescripcion
        , L.VersionId
        , V.VersionNumero
        , V.VersionInicioVigencia
        , V.VersionFinVigencia
        , D.DocumentoId
        , D.DocumentoCodigo
        , D.DocumentoDescripcionDocumento
        , L.EstadoLoteId
        , EL.Codigo AS EstadoLoteCodigo
        , EL.Descripcion AS EstadoLoteDescripcion
        , UE.EvaluacionId
        , UE.EvaluacionPadreId
        , UE.TipoEvaluacionId
        , UE.Intento AS IntentoEvaluacion
        , UE.EstadoEvaluacionId
        , EE.Codigo AS EstadoEvaluacionCodigo
        , EE.Descripcion AS EstadoEvaluacionDescripcion
        , UE.ResultadoGeneral
        , UE.FechaInicio AS FechaInicioEvaluacion
        , UE.FechaFin AS FechaFinEvaluacion
        , UE.UsuarioEvaluador
        , ISNULL(AV.TotalEvaluaciones, 0) AS TotalEvaluaciones
        , ISNULL(AV.EvaluacionesTerminadas, 0) AS EvaluacionesTerminadas
        , ISNULL(RUTA.TotalParametros, 0) AS TotalParametrosEvaluacion
        , ISNULL(AV.ResultadosRegistrados, 0) AS ResultadosRegistrados
        , CASE
              WHEN ISNULL(RUTA.TotalParametros, 0) - ISNULL(AV.ResultadosRegistrados, 0) < 0 THEN 0
              ELSE ISNULL(RUTA.TotalParametros, 0) - ISNULL(AV.ResultadosRegistrados, 0)
          END AS ParametrosPendientes
        , CAST(CASE
              WHEN ISNULL(RUTA.TotalParametros, 0) = 0 THEN 0.00
              ELSE ISNULL(AV.ResultadosRegistrados, 0) * 100.0 / RUTA.TotalParametros
          END AS DECIMAL(5,2)) AS PorcentajeAvance
        , CAST(CASE
              WHEN ISNULL(RUTA.TotalParametros, 0) = 0 THEN 100.00
              ELSE 100.00 - (ISNULL(AV.ResultadosRegistrados, 0) * 100.0 / RUTA.TotalParametros)
          END AS DECIMAL(5,2)) AS PorcentajeFaltante
        , L.Observacion
        , L.Estado
        , L.AudFechaCreacion
        , L.AudFechaActualizacion
    FROM dbo.LOTE AS L
    INNER JOIN dbo.VERSION AS V ON V.VersionId = L.VersionId
    INNER JOIN dbo.DOCUMENTO AS D ON D.DocumentoId = V.DocumentoId
    LEFT JOIN dbo.PRODUCTO AS P ON P.ProductoCodigo = L.ProductoCodigo
    LEFT JOIN dbo.GENESIS_ITEM AS GI ON GI.CodigoGenesis = L.CodigoGenesis
    INNER JOIN dbo.ESTADO_LOTE AS EL ON EL.EstadoLoteId = L.EstadoLoteId
    INNER JOIN dbo.NUMERO_CORRELATIVO AS NC ON NC.NumeroCorrelativoId = L.NumeroCorrelativoId
    INNER JOIN dbo.NATURALEZA AS N ON N.NaturalezaId = NC.NaturalezaId
    INNER JOIN dbo.FASE AS F ON F.FaseId = NC.FaseId
    INNER JOIN dbo.LINEA_ORIGEN AS LO ON LO.LineaOrigenId = NC.LineaOrigenId
    OUTER APPLY
    (
        SELECT TOP (1)
              E.EvaluacionId, E.EvaluacionPadreId, E.TipoEvaluacionId, E.EstadoEvaluacionId
            , E.Intento, E.ResultadoGeneral, E.FechaInicio, E.FechaFin, E.UsuarioEvaluador
        FROM dbo.EVALUACION AS E
        WHERE E.LoteId = L.LoteId AND E.Estado = 'ACTIVO'
        ORDER BY E.Intento DESC, E.EvaluacionId DESC
    ) AS UE
    LEFT JOIN dbo.ESTADO_EVALUACION AS EE ON EE.EstadoEvaluacionId = UE.EstadoEvaluacionId
    OUTER APPLY
    (
        SELECT COUNT(VC.VersCaractId) AS TotalParametros
        FROM dbo.VERSIONCARACTERISTICA AS VC
        INNER JOIN dbo.VERSIONFASE AS VF
            ON VF.VersionFaseId = VC.VersionFaseId
           AND VF.VersionId = L.VersionId
           AND VF.Estado = 1
        WHERE VC.VersionId = L.VersionId AND VC.Estado = 1
    ) AS RUTA
    OUTER APPLY
    (
        SELECT
              COUNT(DISTINCT E.EvaluacionId) AS TotalEvaluaciones
            , COUNT(DISTINCT CASE WHEN EE2.Codigo = 'TERMINADA' THEN E.EvaluacionId END) AS EvaluacionesTerminadas
            , COUNT(DISTINCT CASE
                  WHEN ER.EvaluacionResultadoId IS NOT NULL THEN ER.VersCaractId
              END) AS ResultadosRegistrados
        FROM dbo.EVALUACION AS E
        INNER JOIN dbo.ESTADO_EVALUACION AS EE2 ON EE2.EstadoEvaluacionId = E.EstadoEvaluacionId
        LEFT JOIN dbo.EVALUACION_RESULTADO AS ER
            ON ER.EvaluacionId = E.EvaluacionId
           AND ER.Estado = 'ACTIVO'
        LEFT JOIN dbo.VERSIONCARACTERISTICA AS VC
            ON VC.VersCaractId = ER.VersCaractId
           AND VC.VersionId = L.VersionId
           AND VC.Estado = 1
        LEFT JOIN dbo.VERSIONFASE AS VF
            ON VF.VersionFaseId = VC.VersionFaseId
           AND VF.VersionId = L.VersionId
           AND VF.Estado = 1
        WHERE E.LoteId = L.LoteId
          AND E.Estado = 'ACTIVO'
          AND EE2.Codigo <> 'ANULADA'
          AND (ER.EvaluacionResultadoId IS NULL OR VF.VersionFaseId IS NOT NULL)
    ) AS AV
    WHERE
        (@CodigoLote IS NULL OR LTRIM(RTRIM(@CodigoLote)) = '' OR L.CodigoLote LIKE '%' + LTRIM(RTRIM(@CodigoLote)) + '%')
        AND (@ProductoCodigo IS NULL OR LTRIM(RTRIM(@ProductoCodigo)) = '' OR COALESCE(L.ProductoCodigo, D.ProductoCodigo) = LTRIM(RTRIM(@ProductoCodigo)))
        AND (@CodigoGenesis IS NULL OR LTRIM(RTRIM(@CodigoGenesis)) = '' OR L.CodigoGenesis = LTRIM(RTRIM(@CodigoGenesis)))
        AND (@EstadoLoteId IS NULL OR L.EstadoLoteId = @EstadoLoteId)
        AND (@EstadoEvaluacionId IS NULL OR UE.EstadoEvaluacionId = @EstadoEvaluacionId)
        AND (@FechaDesde IS NULL OR L.FechaHoraProduccion >= @FechaDesde)
        AND (@FechaHasta IS NULL OR L.FechaHoraProduccion < DATEADD(DAY, 1, @FechaHasta))
    ORDER BY L.FechaHoraProduccion DESC, L.LoteId DESC;
END;
