CREATE OR ALTER PROCEDURE dbo.SP_OBTENER_DETALLE_LOTE
(
    @LoteId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    /* RS1: cabecera + avance real de la ruta ET */
    SELECT
          L.LoteId, L.CodigoLote
        , COALESCE(L.ProductoCodigo, D.ProductoCodigo) AS ProductoCodigo
        , L.CodigoGenesis
        , CASE WHEN L.CodigoGenesis IS NOT NULL THEN GI.NombreGenesis ELSE P.ProductoDescripcion END AS ProductoDescripcion
        , GI.Kardex
        , L.Correlativo, L.FechaHoraProduccion
        , NC.NumeroCorrelativoId
        , N.NaturalezaId, N.Codigo AS NaturalezaCodigo, N.Descripcion AS NaturalezaDescripcion
        , F.FaseId, F.Codigo AS FaseCodigo, F.Descripcion AS FaseDescripcion
        , LO.LineaOrigenId, LO.Codigo AS LineaOrigenCodigo, LO.Descripcion AS LineaOrigenDescripcion
        , L.VersionId, V.VersionNumero, V.VersionInicioVigencia, V.VersionFinVigencia
        , D.DocumentoId, D.DocumentoCodigo, D.DocumentoDescripcionDocumento
        , L.EstadoLoteId, EL.Codigo AS EstadoLoteCodigo, EL.Descripcion AS EstadoLoteDescripcion
        , ISNULL(AV.TotalEvaluaciones, 0) AS TotalEvaluaciones
        , ISNULL(AV.EvaluacionesTerminadas, 0) AS EvaluacionesTerminadas
        , ISNULL(RUTA.TotalParametros, 0) AS TotalParametrosEvaluacion
        , ISNULL(AV.ResultadosRegistrados, 0) AS ResultadosRegistrados
        , CASE WHEN ISNULL(RUTA.TotalParametros,0)-ISNULL(AV.ResultadosRegistrados,0)<0 THEN 0
               ELSE ISNULL(RUTA.TotalParametros,0)-ISNULL(AV.ResultadosRegistrados,0) END AS ParametrosPendientes
        , CAST(CASE WHEN ISNULL(RUTA.TotalParametros,0)=0 THEN 0.00
                    ELSE ISNULL(AV.ResultadosRegistrados,0)*100.0/RUTA.TotalParametros END AS DECIMAL(5,2)) AS PorcentajeAvance
        , CAST(CASE WHEN ISNULL(RUTA.TotalParametros,0)=0 THEN 100.00
                    ELSE 100.00-(ISNULL(AV.ResultadosRegistrados,0)*100.0/RUTA.TotalParametros) END AS DECIMAL(5,2)) AS PorcentajeFaltante
        , L.Observacion, L.Estado, L.AudFechaCreacion, L.AudFechaActualizacion
    FROM dbo.LOTE AS L
    INNER JOIN dbo.VERSION AS V ON V.VersionId=L.VersionId
    INNER JOIN dbo.DOCUMENTO AS D ON D.DocumentoId=V.DocumentoId
    LEFT JOIN dbo.PRODUCTO AS P ON P.ProductoCodigo=L.ProductoCodigo
    LEFT JOIN dbo.GENESIS_ITEM AS GI ON GI.CodigoGenesis=L.CodigoGenesis
    INNER JOIN dbo.ESTADO_LOTE AS EL ON EL.EstadoLoteId=L.EstadoLoteId
    INNER JOIN dbo.NUMERO_CORRELATIVO AS NC ON NC.NumeroCorrelativoId=L.NumeroCorrelativoId
    INNER JOIN dbo.NATURALEZA AS N ON N.NaturalezaId=NC.NaturalezaId
    INNER JOIN dbo.FASE AS F ON F.FaseId=NC.FaseId
    INNER JOIN dbo.LINEA_ORIGEN AS LO ON LO.LineaOrigenId=NC.LineaOrigenId
    OUTER APPLY
    (
        SELECT COUNT(VC.VersCaractId) AS TotalParametros
        FROM dbo.VERSIONCARACTERISTICA VC
        INNER JOIN dbo.VERSIONFASE VF ON VF.VersionFaseId=VC.VersionFaseId AND VF.VersionId=L.VersionId AND VF.Estado=1
        WHERE VC.VersionId=L.VersionId AND VC.Estado=1
    ) RUTA
    OUTER APPLY
    (
        SELECT
              COUNT(DISTINCT E.EvaluacionId) AS TotalEvaluaciones
            , COUNT(DISTINCT CASE WHEN EE.Codigo='TERMINADA' THEN E.EvaluacionId END) AS EvaluacionesTerminadas
            , COUNT(DISTINCT CASE WHEN ER.EvaluacionResultadoId IS NOT NULL THEN ER.VersCaractId END) AS ResultadosRegistrados
        FROM dbo.EVALUACION E
        INNER JOIN dbo.ESTADO_EVALUACION EE ON EE.EstadoEvaluacionId=E.EstadoEvaluacionId
        LEFT JOIN dbo.EVALUACION_RESULTADO ER ON ER.EvaluacionId=E.EvaluacionId AND ER.Estado='ACTIVO'
        LEFT JOIN dbo.VERSIONCARACTERISTICA VC ON VC.VersCaractId=ER.VersCaractId AND VC.VersionId=L.VersionId AND VC.Estado=1
        LEFT JOIN dbo.VERSIONFASE VF ON VF.VersionFaseId=VC.VersionFaseId AND VF.VersionId=L.VersionId AND VF.Estado=1
        WHERE E.LoteId=L.LoteId AND E.Estado='ACTIVO' AND EE.Codigo<>'ANULADA'
          AND (ER.EvaluacionResultadoId IS NULL OR VF.VersionFaseId IS NOT NULL)
    ) AV
    WHERE L.LoteId=@LoteId;

    /* RS2: historial; cada intento usa solamente los parametros que realmente le corresponden.
       Para reevaluaciones, el denominador son los parametros registrados/requeridos en ese intento.
       Para una evaluacion normal, el denominador es la etapa concreta. */
    SELECT
          E.EvaluacionId, E.LoteId, E.EvaluacionPadreId
        , E.TipoEvaluacionId, TE.Codigo AS TipoEvaluacionCodigo, TE.Descripcion AS TipoEvaluacionDescripcion
        , E.EstadoEvaluacionId, EE.Codigo AS EstadoEvaluacionCodigo, EE.Descripcion AS EstadoEvaluacionDescripcion
        , E.Intento, E.ResultadoGeneral
        , CASE WHEN E.ResultadoGeneral=1 THEN 'CONFORME' WHEN E.ResultadoGeneral=0 THEN 'NO CONFORME' ELSE 'PENDIENTE' END AS ResultadoDescripcion
        , E.FechaInicio, E.FechaFin, E.MotivoReevaluacion, E.Observacion, E.UsuarioEvaluador
        , ISNULL(R.ResultadosRegistrados,0) AS ResultadosRegistrados
        , ISNULL(P.TotalParametros,0) AS TotalParametros
        , CASE WHEN ISNULL(P.TotalParametros,0)-ISNULL(R.ResultadosRegistrados,0)<0 THEN 0
               ELSE ISNULL(P.TotalParametros,0)-ISNULL(R.ResultadosRegistrados,0) END AS ParametrosPendientes
        , CAST(CASE WHEN ISNULL(P.TotalParametros,0)=0 THEN 0.00
                    ELSE ISNULL(R.ResultadosRegistrados,0)*100.0/P.TotalParametros END AS DECIMAL(5,2)) AS PorcentajeAvance
        , E.Estado, E.AudFechaCreacion, E.AudFechaActualizacion
    FROM dbo.EVALUACION E
    INNER JOIN dbo.LOTE L ON L.LoteId=E.LoteId
    INNER JOIN dbo.TIPO_EVALUACION TE ON TE.TipoEvaluacionId=E.TipoEvaluacionId
    INNER JOIN dbo.ESTADO_EVALUACION EE ON EE.EstadoEvaluacionId=E.EstadoEvaluacionId
    OUTER APPLY
    (
        SELECT COUNT(*) AS ResultadosRegistrados
        FROM dbo.EVALUACION_RESULTADO ER
        WHERE ER.EvaluacionId=E.EvaluacionId AND ER.Estado='ACTIVO'
    ) R
    OUTER APPLY
    (
        SELECT CASE
            WHEN E.EvaluacionPadreId IS NOT NULL
                THEN ISNULL((
                    SELECT COUNT(*)
                    FROM dbo.EVALUACION_RESULTADO ERX
                    WHERE ERX.EvaluacionId=E.EvaluacionId AND ERX.Estado='ACTIVO'
                ),0)
            WHEN E.VersionFaseId IS NOT NULL
                THEN ISNULL((
                    SELECT COUNT(*)
                    FROM dbo.VERSIONCARACTERISTICA VC
                    WHERE VC.VersionId=L.VersionId AND VC.VersionFaseId=E.VersionFaseId AND VC.Estado=1
                ),0)
            ELSE ISNULL((
                    SELECT COUNT(*) FROM dbo.VERSIONCARACTERISTICA VC
                    WHERE VC.VersionId=L.VersionId AND VC.Estado=1
                ),0)
        END AS TotalParametros
    ) P
    WHERE E.LoteId=@LoteId AND E.Estado='ACTIVO'
    ORDER BY E.Intento DESC,E.EvaluacionId DESC;

    /* RS3 */
    SELECT
          COUNT(*) AS TotalEvaluaciones
        , SUM(CASE WHEN EE.Codigo='PENDIENTE' THEN 1 ELSE 0 END) AS EvaluacionesPendientes
        , SUM(CASE WHEN EE.Codigo='EN_PROCESO' THEN 1 ELSE 0 END) AS EvaluacionesEnProceso
        , SUM(CASE WHEN EE.Codigo='TERMINADA' THEN 1 ELSE 0 END) AS EvaluacionesTerminadas
        , SUM(CASE WHEN EE.Codigo='TERMINADA' AND E.ResultadoGeneral=1 THEN 1 ELSE 0 END) AS EvaluacionesConformes
        , SUM(CASE WHEN EE.Codigo='TERMINADA' AND E.ResultadoGeneral=0 THEN 1 ELSE 0 END) AS EvaluacionesNoConformes
    FROM dbo.EVALUACION E
    INNER JOIN dbo.ESTADO_EVALUACION EE ON EE.EstadoEvaluacionId=E.EstadoEvaluacionId
    WHERE E.LoteId=@LoteId AND E.Estado='ACTIVO';
END;
