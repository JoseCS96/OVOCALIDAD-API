CREATE OR ALTER PROCEDURE dbo.SP_OBTENER_CONFIGURACION_CERTIFICADO_FT
(
    @VersionId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
          VFC.VersionFtCaracteristicaId
        , VFC.VersionId
        , VFC.CaracteristicaId
        , C.CaracteristicaDescripcion AS Determinacion
        , C.TipoCaractId
        , TC.TipoCaractDescripcion
        , VFC.FaseId
        , VFC.VersionFaseId
        , VF.CodigoReferencia AS FaseCodigo
        , COALESCE(NULLIF(LTRIM(RTRIM(VF.Descripcion)), ''), VF.CodigoReferencia) AS FaseDescripcion
        , VFC.TipoCriterioId
        , VFC.ValorCuantitativoInicial
        , VFC.ValorCuantitativoFinal
        , VFC.ValorCuantitativoIgual
        , VFC.ValorCualitativo
        , VFC.UnidadDeMedida
        , C.MetEnsayoId
        , ME.MetEnsayoDescripcion
        , VFC.ObligatorioCertificado
        , VFC.OrdenCertificado
    FROM dbo.VERSIONFTCARACTERISTICA VFC
    INNER JOIN dbo.CARACTERISTICA C
        ON C.CaracteristicaId = VFC.CaracteristicaId
    LEFT JOIN dbo.TIPO_CARACTERISTICA TC
        ON TC.TipoCaractId = C.TipoCaractId
    LEFT JOIN dbo.VERSIONFASE VF
        ON VF.VersionFaseId = VFC.VersionFaseId
       AND VF.Estado = 1
    LEFT JOIN dbo.METODO_DE_ENSAYO ME
        ON ME.MetEnsayoId = C.MetEnsayoId
    WHERE VFC.VersionId = @VersionId
      AND VFC.Estado = 1
      AND VFC.ImprimeCertificado = 1
    ORDER BY
          ISNULL(VF.Orden, 999999)
        , ISNULL(VFC.OrdenCertificado, 999999)
        , C.CaracteristicaDescripcion;
END;
GO
