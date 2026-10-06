CREATE OR ALTER PROCEDURE dbo.SP_REPORTE_TRAZABILIDAD_LOTE
(
    @LoteId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.LOTE WHERE LoteId=@LoteId)
    BEGIN
        RAISERROR('El lote indicado no existe.',16,1);
        RETURN;
    END;

    /* RS1: identificación del lote y documento aplicado */
    SELECT
          L.LoteId, L.CodigoLote, L.CodigoGenesis
        , COALESCE(L.ProductoCodigo,D.ProductoCodigo) AS ProductoCodigo
        , GI.NombreGenesis AS ProductoDescripcion
        , L.FechaHoraProduccion
        , L.VersionId, V.VersionNumero
        , D.DocumentoId, D.DocumentoCodigo, D.DocumentoDescripcionDocumento
        , L.EstadoLoteId, EL.Codigo AS EstadoLoteCodigo, EL.Descripcion AS EstadoLoteDescripcion
        , L.Observacion
        , L.AudUsuarioCreacion, L.AudFechaCreacion
        , L.AudUsuarioModificacion, L.AudFechaActualizacion
    FROM dbo.LOTE L
    INNER JOIN dbo.VERSION V ON V.VersionId=L.VersionId
    INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId=V.DocumentoId
    INNER JOIN dbo.ESTADO_LOTE EL ON EL.EstadoLoteId=L.EstadoLoteId
    LEFT JOIN dbo.GENESIS_ITEM GI ON GI.CodigoGenesis=L.CodigoGenesis
    WHERE L.LoteId=@LoteId;

    /* RS2: ruta configurada */
    SELECT
          VF.VersionFaseId, VF.Orden, VF.CodigoReferencia
        , F.FaseId, F.Codigo AS FaseCodigo, F.Descripcion AS FaseDescripcion
        , VF.EsFinal, VF.EsObligatoria
        , COUNT(VC.VersCaractId) AS CantidadCaracteristicas
    FROM dbo.LOTE L
    INNER JOIN dbo.VERSIONFASE VF ON VF.VersionId=L.VersionId AND VF.Estado=1
    INNER JOIN dbo.FASE F ON F.FaseId=VF.FaseId
    LEFT JOIN dbo.VERSIONCARACTERISTICA VC
        ON VC.VersionId=VF.VersionId AND VC.VersionFaseId=VF.VersionFaseId AND VC.Estado=1
    WHERE L.LoteId=@LoteId
    GROUP BY VF.VersionFaseId,VF.Orden,VF.CodigoReferencia,F.FaseId,F.Codigo,F.Descripcion,VF.EsFinal,VF.EsObligatoria
    ORDER BY VF.Orden,VF.VersionFaseId;

    /* RS3: evaluaciones e intentos */
    SELECT
          E.EvaluacionId, E.EvaluacionPadreId, E.Intento
        , E.VersionFaseId, VF.Orden AS EtapaOrden, VF.CodigoReferencia
        , F.Codigo AS FaseCodigo, F.Descripcion AS FaseDescripcion, VF.EsFinal
        , E.TipoEvaluacionId, TE.Codigo AS TipoEvaluacionCodigo, TE.Descripcion AS TipoEvaluacionDescripcion
        , E.EstadoEvaluacionId, EE.Codigo AS EstadoEvaluacionCodigo, EE.Descripcion AS EstadoEvaluacionDescripcion
        , E.ResultadoGeneral
        , CASE WHEN E.ResultadoGeneral=1 THEN 'CONFORME'
               WHEN E.ResultadoGeneral=0 THEN 'NO CONFORME'
               ELSE 'PENDIENTE' END AS ResultadoDescripcion
        , E.UsuarioEvaluador, E.FechaInicio, E.FechaFin
        , E.MotivoReevaluacion, E.Observacion
        , E.AudUsuarioCreacion, E.AudFechaCreacion
        , E.AudUsuarioModificacion, E.AudFechaActualizacion
    FROM dbo.EVALUACION E
    INNER JOIN dbo.TIPO_EVALUACION TE ON TE.TipoEvaluacionId=E.TipoEvaluacionId
    INNER JOIN dbo.ESTADO_EVALUACION EE ON EE.EstadoEvaluacionId=E.EstadoEvaluacionId
    LEFT JOIN dbo.VERSIONFASE VF ON VF.VersionFaseId=E.VersionFaseId
    LEFT JOIN dbo.FASE F ON F.FaseId=VF.FaseId
    WHERE E.LoteId=@LoteId
    ORDER BY E.Intento,E.EvaluacionId;

    /* RS4: resultados completos y auditoría */
    SELECT
          ER.EvaluacionResultadoId, ER.EvaluacionId, E.Intento
        , E.VersionFaseId, VF.Orden AS EtapaOrden, VF.CodigoReferencia
        , ER.VersCaractId, C.CaracteristicaId, C.CaracteristicaDescripcion AS Caracteristica
        , TC.Codigo AS TipoCriterio
        , VC.ValorCuantitativoInicial, VC.ValorCuantitativoFinal, VC.ValorCuantitativoIgual
        , VC.ValorCualitativo, VC.UnidadDeMedida
        , ER.ResultadoNumerico, ER.ResultadoTexto, ER.Cumple
        , ER.FechaResultado, ER.Observacion
        , ER.AudUsuarioCreacion, ER.AudFechaCreacion
        , ER.AudUsuarioModificacion, ER.AudFechaActualizacion
    FROM dbo.EVALUACION_RESULTADO ER
    INNER JOIN dbo.EVALUACION E ON E.EvaluacionId=ER.EvaluacionId
    INNER JOIN dbo.VERSIONCARACTERISTICA VC ON VC.VersCaractId=ER.VersCaractId
    INNER JOIN dbo.CARACTERISTICA C ON C.CaracteristicaId=VC.CaracteristicaId
    INNER JOIN dbo.TIPO_CRITERIO TC ON TC.TipoCriterioId=VC.TipoCriterioId
    LEFT JOIN dbo.VERSIONFASE VF ON VF.VersionFaseId=E.VersionFaseId
    WHERE E.LoteId=@LoteId
    ORDER BY E.Intento,VC.Orden,ER.EvaluacionResultadoId;

    /* RS5: cambios reales de estado capturados desde la instalación de la auditoría */
    SELECT
          H.LoteHistorialEstadoId, H.LoteId
        , H.EstadoLoteOrigenId, EO.Codigo AS EstadoOrigen
        , H.EstadoLoteDestinoId, ED.Codigo AS EstadoDestino
        , H.Accion, H.Comentario, H.Usuario, H.Fecha
    FROM dbo.LOTEHISTORIALESTADO H
    LEFT JOIN dbo.ESTADO_LOTE EO ON EO.EstadoLoteId=H.EstadoLoteOrigenId
    INNER JOIN dbo.ESTADO_LOTE ED ON ED.EstadoLoteId=H.EstadoLoteDestinoId
    WHERE H.LoteId=@LoteId AND H.Estado=1
    ORDER BY H.Fecha,H.LoteHistorialEstadoId;
END;
GO
