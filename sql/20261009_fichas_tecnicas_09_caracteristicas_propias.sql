/*
 OVOCALIDAD 2.0
 FT - Características propias de Ficha Técnica.

 Permite:
 - conservar las características heredadas desde ET;
 - agregar características exclusivas de FT (ej. PROXIMAL);
 - guardar tolerancia cuando el criterio la utilice;
 - mantener configuración de certificado independiente.

 No modifica VERSIONCARACTERISTICA.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/* Asegurar columnas de trazabilidad FT utilizadas por la aplicación. */
IF COL_LENGTH('dbo.VERSIONFTCARACTERISTICA','VersCaractOrigenId') IS NULL
    ALTER TABLE dbo.VERSIONFTCARACTERISTICA ADD VersCaractOrigenId INT NULL;
GO
IF COL_LENGTH('dbo.VERSIONFTCARACTERISTICA','OrdenTecnico') IS NULL
    ALTER TABLE dbo.VERSIONFTCARACTERISTICA ADD OrdenTecnico INT NULL;
GO
IF COL_LENGTH('dbo.VERSIONFTCARACTERISTICA','FaseId') IS NULL
    ALTER TABLE dbo.VERSIONFTCARACTERISTICA ADD FaseId INT NULL;
GO
IF COL_LENGTH('dbo.VERSIONFTCARACTERISTICA','VersionFaseId') IS NULL
    ALTER TABLE dbo.VERSIONFTCARACTERISTICA ADD VersionFaseId INT NULL;
GO
IF COL_LENGTH('dbo.VERSIONFTCARACTERISTICA','EsPropiaFt') IS NULL
BEGIN
    ALTER TABLE dbo.VERSIONFTCARACTERISTICA
    ADD EsPropiaFt BIT NOT NULL
        CONSTRAINT DF_VERSIONFTCARACTERISTICA_EsPropiaFt DEFAULT(0);
END;
GO
IF COL_LENGTH('dbo.VERSIONFTCARACTERISTICA','ValorTolerancia') IS NULL
    ALTER TABLE dbo.VERSIONFTCARACTERISTICA ADD ValorTolerancia DECIMAL(18,6) NULL;
GO

CREATE OR ALTER PROCEDURE dbo.SP_GUARDAR_CARACTERISTICA_FT
(
      @VersionFtId INT
    , @VersionFtCaracteristicaId INT = NULL
    , @CaracteristicaId INT
    , @TipoCriterioId INT
    , @ValorCuantitativoInicial DECIMAL(18,6) = NULL
    , @ValorCuantitativoFinal DECIMAL(18,6) = NULL
    , @ValorCuantitativoIgual DECIMAL(18,6) = NULL
    , @ValorTolerancia DECIMAL(18,6) = NULL
    , @ValorCualitativo VARCHAR(1000) = NULL
    , @UnidadDeMedida VARCHAR(50) = NULL
    , @ImprimeCertificado BIT = 0
    , @ObligatorioCertificado BIT = 0
    , @OrdenCertificado INT = NULL
    , @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
          @EsNueva BIT = 0
        , @UnidadCatalogo VARCHAR(50)
        , @OrdenTecnico INT;

    BEGIN TRY
        SET @Usuario=NULLIF(LTRIM(RTRIM(@Usuario)),'');
        SET @UnidadDeMedida=NULLIF(LTRIM(RTRIM(@UnidadDeMedida)),'');
        SET @ValorCualitativo=NULLIF(LTRIM(RTRIM(@ValorCualitativo)),'');

        IF @Usuario IS NULL
            THROW 50001,'No se pudo identificar al usuario.',1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.VERSION V
            INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId=V.DocumentoId
            WHERE V.VersionId=@VersionFtId
              AND V.Estado=1
              AND D.Estado=1
              AND D.TipoDocumentoId=3
        )
            THROW 50002,'La versión indicada no corresponde a una Ficha Técnica activa.',1;

        SELECT @UnidadCatalogo=C.CaracteristicaUnidadDeMedida
        FROM dbo.CARACTERISTICA C
        WHERE C.CaracteristicaId=@CaracteristicaId
          AND C.Estado=1;

        IF @@ROWCOUNT=0
            THROW 50003,'La característica indicada no existe o está inactiva.',1;

        IF @ObligatorioCertificado=1 AND @ImprimeCertificado=0
            THROW 50004,'Una característica obligatoria en certificado debe configurarse para impresión.',1;

        IF @ImprimeCertificado=1 AND (@OrdenCertificado IS NULL OR @OrdenCertificado<=0)
            THROW 50005,'Debe indicar un orden válido para una característica que se imprimirá en certificado.',1;

        IF @ImprimeCertificado=0
        BEGIN
            SET @ObligatorioCertificado=0;
            SET @OrdenCertificado=NULL;
        END;

        SET @UnidadDeMedida=COALESCE(@UnidadDeMedida,@UnidadCatalogo);

        IF ISNULL(@VersionFtCaracteristicaId,0)<=0
        BEGIN
            SET @EsNueva=1;

            IF EXISTS
            (
                SELECT 1
                FROM dbo.VERSIONFTCARACTERISTICA
                WHERE VersionId=@VersionFtId
                  AND CaracteristicaId=@CaracteristicaId
                  AND Estado=1
            )
                THROW 50006,'La característica ya se encuentra incluida en esta Ficha Técnica.',1;

            SELECT @OrdenTecnico=ISNULL(MAX(OrdenTecnico),0)+1
            FROM dbo.VERSIONFTCARACTERISTICA
            WHERE VersionId=@VersionFtId
              AND Estado=1;

            SELECT TOP (1)
                @VersionFtCaracteristicaId=VersionFtCaracteristicaId
            FROM dbo.VERSIONFTCARACTERISTICA
            WHERE VersionId=@VersionFtId
              AND CaracteristicaId=@CaracteristicaId
              AND Estado=0
            ORDER BY VersionFtCaracteristicaId DESC;

            IF @VersionFtCaracteristicaId IS NOT NULL
            BEGIN
                UPDATE dbo.VERSIONFTCARACTERISTICA
                SET
                      TipoCriterioId=@TipoCriterioId
                    , ValorCuantitativoInicial=@ValorCuantitativoInicial
                    , ValorCuantitativoFinal=@ValorCuantitativoFinal
                    , ValorCuantitativoIgual=@ValorCuantitativoIgual
                    , ValorTolerancia=@ValorTolerancia
                    , ValorCualitativo=@ValorCualitativo
                    , UnidadDeMedida=@UnidadDeMedida
                    , ImprimeCertificado=@ImprimeCertificado
                    , ObligatorioCertificado=@ObligatorioCertificado
                    , OrdenCertificado=@OrdenCertificado
                    , VersCaractOrigenId=NULL
                    , OrdenTecnico=@OrdenTecnico
                    , FaseId=NULL
                    , VersionFaseId=NULL
                    , EsPropiaFt=1
                    , Estado=1
                    , AudUsuarioModificacion=@Usuario
                    , AudFechaActualizacion=SYSDATETIME()
                WHERE VersionFtCaracteristicaId=@VersionFtCaracteristicaId;
            END
            ELSE
            BEGIN
                INSERT INTO dbo.VERSIONFTCARACTERISTICA
                (
                      VersionId
                    , CaracteristicaId
                    , TipoCriterioId
                    , ValorCuantitativoInicial
                    , ValorCuantitativoFinal
                    , ValorCuantitativoIgual
                    , ValorTolerancia
                    , ValorCualitativo
                    , UnidadDeMedida
                    , ImprimeCertificado
                    , ObligatorioCertificado
                    , OrdenCertificado
                    , VersCaractOrigenId
                    , OrdenTecnico
                    , FaseId
                    , VersionFaseId
                    , EsPropiaFt
                    , Estado
                    , AudUsuarioCreacion
                    , AudFechaCreacion
                )
                VALUES
                (
                      @VersionFtId
                    , @CaracteristicaId
                    , @TipoCriterioId
                    , @ValorCuantitativoInicial
                    , @ValorCuantitativoFinal
                    , @ValorCuantitativoIgual
                    , @ValorTolerancia
                    , @ValorCualitativo
                    , @UnidadDeMedida
                    , @ImprimeCertificado
                    , @ObligatorioCertificado
                    , @OrdenCertificado
                    , NULL
                    , @OrdenTecnico
                    , NULL
                    , NULL
                    , 1
                    , 1
                    , @Usuario
                    , SYSDATETIME()
                );

                SET @VersionFtCaracteristicaId=CONVERT(INT,SCOPE_IDENTITY());
            END;
        END
        ELSE
        BEGIN
            IF NOT EXISTS
            (
                SELECT 1
                FROM dbo.VERSIONFTCARACTERISTICA
                WHERE VersionFtCaracteristicaId=@VersionFtCaracteristicaId
                  AND VersionId=@VersionFtId
                  AND Estado=1
            )
                THROW 50007,'La característica FT indicada no existe o no pertenece a esta versión.',1;

            IF EXISTS
            (
                SELECT 1
                FROM dbo.VERSIONFTCARACTERISTICA
                WHERE VersionId=@VersionFtId
                  AND CaracteristicaId=@CaracteristicaId
                  AND VersionFtCaracteristicaId<>@VersionFtCaracteristicaId
                  AND Estado=1
            )
                THROW 50008,'La característica ya se encuentra incluida en esta Ficha Técnica.',1;

            UPDATE dbo.VERSIONFTCARACTERISTICA
            SET
                  CaracteristicaId=@CaracteristicaId
                , TipoCriterioId=@TipoCriterioId
                , ValorCuantitativoInicial=@ValorCuantitativoInicial
                , ValorCuantitativoFinal=@ValorCuantitativoFinal
                , ValorCuantitativoIgual=@ValorCuantitativoIgual
                , ValorTolerancia=@ValorTolerancia
                , ValorCualitativo=@ValorCualitativo
                , UnidadDeMedida=@UnidadDeMedida
                , ImprimeCertificado=@ImprimeCertificado
                , ObligatorioCertificado=@ObligatorioCertificado
                , OrdenCertificado=@OrdenCertificado
                , AudUsuarioModificacion=@Usuario
                , AudFechaActualizacion=SYSDATETIME()
            WHERE VersionFtCaracteristicaId=@VersionFtCaracteristicaId
              AND VersionId=@VersionFtId;
        END;

        SELECT
              0 CodigoResultado
            , CASE WHEN @EsNueva=1
                   THEN 'Característica propia de FT agregada correctamente.'
                   ELSE 'Característica de FT guardada correctamente.'
              END Mensaje
            , @VersionFtCaracteristicaId VersionFtCaracteristicaId;
    END TRY
    BEGIN CATCH
        SELECT
              -1 CodigoResultado
            , ERROR_MESSAGE() Mensaje
            , ISNULL(@VersionFtCaracteristicaId,0) VersionFtCaracteristicaId;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_CARACTERISTICAS_FT
(
    @VersionFtId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
          VFC.VersionFtCaracteristicaId
        , VFC.VersionId
        , VFC.VersCaractOrigenId
        , VFC.OrdenTecnico
        , VFC.FaseId
        , VFC.VersionFaseId
        , VF.CodigoReferencia AS FaseCodigo
        , COALESCE(NULLIF(LTRIM(RTRIM(VF.Descripcion)),''),VF.CodigoReferencia) AS FaseDescripcion
        , VF.Orden AS VersionFaseOrden
        , VFC.CaracteristicaId
        , C.CaracteristicaDescripcion
        , C.TipoCaractId
        , TC.TipoCaractDescripcion
        , VFC.TipoCriterioId
        , VFC.ValorCuantitativoInicial
        , VFC.ValorCuantitativoFinal
        , VFC.ValorCuantitativoIgual
        , VFC.ValorTolerancia
        , VFC.ValorCualitativo
        , VFC.UnidadDeMedida
        , C.MetEnsayoId
        , ME.MetEnsayoDescripcion
        , VFC.EsPropiaFt
        , VFC.ImprimeCertificado
        , VFC.ObligatorioCertificado
        , VFC.OrdenCertificado
        , VFC.Estado
    FROM dbo.VERSIONFTCARACTERISTICA VFC
    INNER JOIN dbo.CARACTERISTICA C
      ON C.CaracteristicaId=VFC.CaracteristicaId
    LEFT JOIN dbo.TIPO_CARACTERISTICA TC
      ON TC.TipoCaractId=C.TipoCaractId
    LEFT JOIN dbo.METODO_DE_ENSAYO ME
      ON ME.MetEnsayoId=C.MetEnsayoId
    LEFT JOIN dbo.VERSIONFASE VF
      ON VF.VersionFaseId=VFC.VersionFaseId
     AND VF.Estado=1
    WHERE VFC.VersionId=@VersionFtId
      AND VFC.Estado=1
    ORDER BY
          ISNULL(VF.Orden,999999)
        , ISNULL(VFC.OrdenTecnico,999999)
        , TC.TipoCaractDescripcion
        , C.CaracteristicaDescripcion;
END;
GO
