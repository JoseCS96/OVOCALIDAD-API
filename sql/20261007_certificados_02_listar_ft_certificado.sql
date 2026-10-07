CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_FICHAS_TECNICAS_CERTIFICADO
(
    @Busqueda VARCHAR(200) = NULL
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
        , COUNT(VFC.VersionFtCaracteristicaId) AS CantidadParametrosCertificables
    FROM dbo.VERSION V
    INNER JOIN dbo.DOCUMENTO D
        ON D.DocumentoId = V.DocumentoId
    INNER JOIN dbo.ESTADOVERSION EV
        ON EV.EstVerId = V.EstVerId
    INNER JOIN dbo.VERSIONFTCARACTERISTICA VFC
        ON VFC.VersionId = V.VersionId
       AND VFC.Estado = 1
       AND VFC.ImprimeCertificado = 1
    WHERE D.Estado = 1
      AND V.Estado = 1
      AND D.TipoDocumentoId = 3
      AND EV.EstVerDescripcion = 'VIGENTE'
      AND (
            @Busqueda IS NULL
            OR D.ProductoCodigo LIKE '%' + @Busqueda + '%'
            OR D.DocumentoCodigo LIKE '%' + @Busqueda + '%'
            OR D.DocumentoDescripcionDocumento LIKE '%' + @Busqueda + '%'
          )
    GROUP BY
          V.VersionId
        , D.DocumentoId
        , D.DocumentoCodigo
        , D.DocumentoDescripcionDocumento
        , D.ProductoCodigo
        , V.VersionNumero
        , V.VersionInicioVigencia
        , V.EstVerId
        , EV.EstVerDescripcion
    ORDER BY
          D.ProductoCodigo
        , D.DocumentoCodigo
        , V.VersionNumero DESC;
END;
GO
