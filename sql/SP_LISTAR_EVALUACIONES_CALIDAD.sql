/* Ejecutar en OVOCALIDAD. El filtrado se realiza en SQL con la identidad de sesión enviada por la API. */
CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_EVALUACIONES_CALIDAD
    @Usuario VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SegUsuarioId INT, @EsSupervisor BIT = 0, @EsAuxiliar BIT = 0;
    SELECT @SegUsuarioId = U.SegUsuarioId
    FROM dbo.SEG_USUARIO U
    WHERE U.NombreUsuario = @Usuario AND U.Estado = 1;

    IF @SegUsuarioId IS NULL
        THROW 51000, 'Usuario no encontrado o inactivo.', 1;

    SELECT
        @EsSupervisor = CONVERT(BIT, MAX(CASE WHEN PF.PerfilCodigo IN ('ANALISTA_CALIDAD','JEFE_CALIDAD','ADMINISTRADOR') THEN 1 ELSE 0 END)),
        @EsAuxiliar = CONVERT(BIT, MAX(CASE WHEN PF.PerfilCodigo = 'AUXILIAR_CALIDAD' THEN 1 ELSE 0 END))
    FROM dbo.SEG_USUARIO_PERFIL UP
    JOIN dbo.SEG_PERFIL PF ON PF.PerfilId = UP.PerfilId AND PF.Estado = 1
    WHERE UP.SegUsuarioId = @SegUsuarioId AND UP.Estado = 1;

    IF ISNULL(@EsSupervisor, 0) = 0 AND ISNULL(@EsAuxiliar, 0) = 0
        THROW 51001, 'El usuario no posee un perfil autorizado para consultar evaluaciones de Calidad.', 1;

    SELECT
        E.EvaluacionId, L.LoteId, L.CodigoLote,
        COALESCE(L.CodigoGenesis, L.ProductoCodigo, D.ProductoCodigo) AS ProductoCodigo,
        COALESCE(GI.NombreGenesis, D.DocumentoDescripcionDocumento, '') AS ProductoDescripcion,
        TE.TipoEvaluacionId, TE.Codigo AS TipoEvaluacionCodigo,
        TE.Descripcion AS TipoEvaluacionDescripcion,
        E.EstadoEvaluacionId, EE.Codigo AS EstadoEvaluacionCodigo,
        EE.Descripcion AS EstadoEvaluacionDescripcion,
        L.EstadoLoteId, EL.Codigo AS EstadoLoteCodigo,
        EL.Descripcion AS EstadoLoteDescripcion,
        E.Intento, L.FechaHoraProduccion,
        E.AudFechaCreacion AS FechaCreacionEvaluacion,
        E.FechaInicio, E.FechaFin, E.ResultadoGeneral,
        E.UsuarioEvaluador, E.MotivoReevaluacion, E.Observacion,
        COALESCE(E.AudFechaActualizacion, E.AudFechaCreacion) AS FechaUltimaActualizacion
    FROM dbo.EVALUACION E
    JOIN dbo.LOTE L ON L.LoteId = E.LoteId
    JOIN dbo.VERSION V ON V.VersionId = L.VersionId
    JOIN dbo.DOCUMENTO D ON D.DocumentoId = V.DocumentoId
    LEFT JOIN dbo.GENESIS_ITEM GI ON GI.CodigoGenesis = L.CodigoGenesis
    JOIN dbo.TIPO_EVALUACION TE ON TE.TipoEvaluacionId = E.TipoEvaluacionId
    JOIN dbo.ESTADO_EVALUACION EE ON EE.EstadoEvaluacionId = E.EstadoEvaluacionId
    JOIN dbo.ESTADO_LOTE EL ON EL.EstadoLoteId = L.EstadoLoteId
    WHERE E.Estado = 'ACTIVO' AND L.Estado = 'ACTIVO'
      AND (
          @EsSupervisor = 1
          OR (
              @EsAuxiliar = 1 AND (
                  E.UsuarioEvaluador = @Usuario
                  OR (EE.Codigo = 'PENDIENTE' AND E.UsuarioEvaluador IS NULL)
              )
          )
      )
    ORDER BY
        CASE EE.Codigo WHEN 'PENDIENTE' THEN 1 WHEN 'EN_PROCESO' THEN 2 WHEN 'TERMINADA' THEN 3 ELSE 4 END,
        COALESCE(E.AudFechaActualizacion, E.AudFechaCreacion) DESC,
        E.EvaluacionId DESC;
END;
