/*
 OVOCALIDAD 2.0 - FT
 SPs ejecutados para administrar especificaciones de FT y su configuración de certificado.
*/
CREATE OR ALTER PROCEDURE dbo.SP_GUARDAR_CARACTERISTICA_FT
(
    @VersionFtCaracteristicaId INT = NULL,
    @VersionId INT,
    @CaracteristicaId INT,
    @TipoCriterioId INT,
    @ValorCuantitativoInicial DECIMAL(18,6) = NULL,
    @ValorCuantitativoFinal DECIMAL(18,6) = NULL,
    @ValorCuantitativoIgual DECIMAL(18,6) = NULL,
    @ValorCualitativo VARCHAR(1000) = NULL,
    @UnidadDeMedida VARCHAR(50) = NULL,
    @ImprimeCertificado BIT = 0,
    @ObligatorioCertificado BIT = 0,
    @OrdenCertificado INT = NULL,
    @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.VERSION WHERE VersionId = @VersionId)
        THROW 50001, 'La versión indicada no existe.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.CARACTERISTICA WHERE CaracteristicaId = @CaracteristicaId AND Estado = 1)
        THROW 50002, 'La característica indicada no existe o está inactiva.', 1;

    IF @ObligatorioCertificado = 1 AND @ImprimeCertificado = 0
        THROW 50003, 'Una característica obligatoria en certificado debe estar configurada para impresión.', 1;

    IF @ImprimeCertificado = 1 AND (@OrdenCertificado IS NULL OR @OrdenCertificado <= 0)
        THROW 50004, 'Debe indicar un orden válido para la característica que se imprimirá en el certificado.', 1;

    IF @ImprimeCertificado = 0
    BEGIN
        SET @ObligatorioCertificado = 0;
        SET @OrdenCertificado = NULL;
    END;

    IF ISNULL(@VersionFtCaracteristicaId, 0) = 0
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.VERSIONFTCARACTERISTICA WHERE VersionId = @VersionId AND CaracteristicaId = @CaracteristicaId)
            THROW 50005, 'La característica ya se encuentra registrada en esta versión de la FT.', 1;

        INSERT dbo.VERSIONFTCARACTERISTICA
        (
            VersionId, CaracteristicaId, TipoCriterioId,
            ValorCuantitativoInicial, ValorCuantitativoFinal, ValorCuantitativoIgual, ValorCualitativo,
            UnidadDeMedida, ImprimeCertificado, ObligatorioCertificado, OrdenCertificado,
            Estado, AudUsuarioCreacion, AudFechaCreacion
        )
        VALUES
        (
            @VersionId, @CaracteristicaId, @TipoCriterioId,
            @ValorCuantitativoInicial, @ValorCuantitativoFinal, @ValorCuantitativoIgual, @ValorCualitativo,
            @UnidadDeMedida, @ImprimeCertificado, @ObligatorioCertificado, @OrdenCertificado,
            1, @Usuario, SYSDATETIME()
        );

        SET @VersionFtCaracteristicaId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.VERSIONFTCARACTERISTICA WHERE VersionFtCaracteristicaId = @VersionFtCaracteristicaId)
            THROW 50006, 'La característica de FT indicada no existe.', 1;

        IF EXISTS
        (
            SELECT 1 FROM dbo.VERSIONFTCARACTERISTICA
            WHERE VersionId = @VersionId
              AND CaracteristicaId = @CaracteristicaId
              AND VersionFtCaracteristicaId <> @VersionFtCaracteristicaId
        )
            THROW 50007, 'La característica ya se encuentra registrada en esta versión de la FT.', 1;

        UPDATE dbo.VERSIONFTCARACTERISTICA
        SET CaracteristicaId = @CaracteristicaId,
            TipoCriterioId = @TipoCriterioId,
            ValorCuantitativoInicial = @ValorCuantitativoInicial,
            ValorCuantitativoFinal = @ValorCuantitativoFinal,
            ValorCuantitativoIgual = @ValorCuantitativoIgual,
            ValorCualitativo = @ValorCualitativo,
            UnidadDeMedida = @UnidadDeMedida,
            ImprimeCertificado = @ImprimeCertificado,
            ObligatorioCertificado = @ObligatorioCertificado,
            OrdenCertificado = @OrdenCertificado,
            AudUsuarioModificacion = @Usuario,
            AudFechaActualizacion = SYSDATETIME()
        WHERE VersionFtCaracteristicaId = @VersionFtCaracteristicaId;
    END;

    SELECT 0 CodigoResultado,
           'Característica de FT guardada correctamente.' Mensaje,
           @VersionFtCaracteristicaId VersionFtCaracteristicaId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_CARACTERISTICAS_FT @VersionId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT VFC.VersionFtCaracteristicaId, VFC.VersionId, VFC.CaracteristicaId,
           C.CaracteristicaDescripcion, TC.TipoCaractId, TC.TipoCaractDescripcion,
           VFC.TipoCriterioId, VFC.ValorCuantitativoInicial, VFC.ValorCuantitativoFinal,
           VFC.ValorCuantitativoIgual, VFC.ValorCualitativo, VFC.UnidadDeMedida,
           ME.MetEnsayoId, ME.MetEnsayoDescripcion, VFC.ImprimeCertificado,
           VFC.ObligatorioCertificado, VFC.OrdenCertificado, VFC.Estado
    FROM dbo.VERSIONFTCARACTERISTICA VFC
    INNER JOIN dbo.CARACTERISTICA C ON C.CaracteristicaId = VFC.CaracteristicaId
    LEFT JOIN dbo.TIPOCARACTERISTICA TC ON TC.TipoCaractId = C.TipoCaractId
    LEFT JOIN dbo.METODOENSAYO ME ON ME.MetEnsayoId = C.MetEnsayoId
    WHERE VFC.VersionId = @VersionId AND VFC.Estado = 1
    ORDER BY TC.TipoCaractDescripcion,
             CASE WHEN VFC.ImprimeCertificado = 1 THEN 0 ELSE 1 END,
             VFC.OrdenCertificado, C.CaracteristicaDescripcion;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ELIMINAR_CARACTERISTICA_FT
    @VersionFtCaracteristicaId INT,
    @Usuario VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS
    (
        SELECT 1 FROM dbo.VERSIONFTCARACTERISTICA
        WHERE VersionFtCaracteristicaId = @VersionFtCaracteristicaId AND Estado = 1
    )
        THROW 50001, 'La característica de FT no existe o ya se encuentra inactiva.', 1;

    UPDATE dbo.VERSIONFTCARACTERISTICA
    SET Estado = 0, ImprimeCertificado = 0, ObligatorioCertificado = 0, OrdenCertificado = NULL,
        AudUsuarioModificacion = @Usuario, AudFechaActualizacion = SYSDATETIME()
    WHERE VersionFtCaracteristicaId = @VersionFtCaracteristicaId;

    SELECT 0 CodigoResultado, 'Característica retirada de la FT correctamente.' Mensaje,
           @VersionFtCaracteristicaId VersionFtCaracteristicaId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_OBTENER_CONFIGURACION_CERTIFICADO_FT @VersionId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT VFC.VersionFtCaracteristicaId, VFC.VersionId, VFC.CaracteristicaId,
           C.CaracteristicaDescripcion Determinacion, TC.TipoCaractId, TC.TipoCaractDescripcion,
           VFC.TipoCriterioId, VFC.ValorCuantitativoInicial, VFC.ValorCuantitativoFinal,
           VFC.ValorCuantitativoIgual, VFC.ValorCualitativo, VFC.UnidadDeMedida,
           ME.MetEnsayoId, ME.MetEnsayoDescripcion, VFC.ObligatorioCertificado,
           VFC.OrdenCertificado
    FROM dbo.VERSIONFTCARACTERISTICA VFC
    INNER JOIN dbo.CARACTERISTICA C ON C.CaracteristicaId = VFC.CaracteristicaId
    LEFT JOIN dbo.TIPOCARACTERISTICA TC ON TC.TipoCaractId = C.TipoCaractId
    LEFT JOIN dbo.METODOENSAYO ME ON ME.MetEnsayoId = C.MetEnsayoId
    WHERE VFC.VersionId = @VersionId
      AND VFC.Estado = 1
      AND VFC.ImprimeCertificado = 1
    ORDER BY TC.TipoCaractDescripcion, VFC.OrdenCertificado, C.CaracteristicaDescripcion;
END;
GO
