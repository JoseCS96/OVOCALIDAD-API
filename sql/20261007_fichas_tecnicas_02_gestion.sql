/*
 OVOCALIDAD 2.0 - Gestión de Fichas Técnicas.
*/
CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_FICHAS_TECNICAS
(
    @Busqueda VARCHAR(200) = NULL,
    @EstVerId INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @Busqueda = NULLIF(LTRIM(RTRIM(@Busqueda)), '');

    SELECT
          V.VersionId
        , D.DocumentoId
        , D.DocumentoCodigo
        , D.DocumentoDescripcionDocumento
        , D.ProductoCodigo
        , V.VersionNumero
        , V.VersionInicioVigencia
        , V.EstVerId
        , EV.EstVerDescripcion AS EstadoVersion
        , COUNT(CASE WHEN VFC.Estado = 1 THEN 1 END) AS CantidadCaracteristicas
        , COUNT(CASE WHEN VFC.Estado = 1 AND VFC.ImprimeCertificado = 1 THEN 1 END) AS CantidadParametrosCertificables
    FROM dbo.VERSION V
    INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId = V.DocumentoId
    INNER JOIN dbo.ESTADOVERSION EV ON EV.EstVerId = V.EstVerId
    LEFT JOIN dbo.VERSIONFTCARACTERISTICA VFC ON VFC.VersionId = V.VersionId
    WHERE D.Estado = 1
      AND D.TipoDocumentoId = 3
      AND (@EstVerId IS NULL OR V.EstVerId = @EstVerId)
      AND (@Busqueda IS NULL
           OR D.ProductoCodigo LIKE '%' + @Busqueda + '%'
           OR D.DocumentoCodigo LIKE '%' + @Busqueda + '%'
           OR D.DocumentoDescripcionDocumento LIKE '%' + @Busqueda + '%')
    GROUP BY V.VersionId,D.DocumentoId,D.DocumentoCodigo,D.DocumentoDescripcionDocumento,
             D.ProductoCodigo,V.VersionNumero,V.VersionInicioVigencia,V.EstVerId,EV.EstVerDescripcion
    ORDER BY D.ProductoCodigo,D.DocumentoCodigo,V.VersionNumero DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_OBTENER_FICHA_TECNICA
(
    @VersionId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
          V.VersionId
        , D.DocumentoId
        , D.DocumentoCodigo
        , D.DocumentoDescripcionDocumento
        , D.ProductoCodigo
        , V.VersionNumero
        , V.VersionInicioVigencia
        , V.EstVerId
        , EV.EstVerDescripcion AS EstadoVersion
        , V.VersionNroPaginas
        , V.VersionDescripcion
    FROM dbo.VERSION V
    INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId = V.DocumentoId
    INNER JOIN dbo.ESTADOVERSION EV ON EV.EstVerId = V.EstVerId
    WHERE V.VersionId = @VersionId
      AND D.TipoDocumentoId = 3
      AND D.Estado = 1;
END;
GO
