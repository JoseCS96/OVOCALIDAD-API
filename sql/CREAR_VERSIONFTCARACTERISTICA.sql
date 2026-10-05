/*
    OVOCALIDAD 2.0
    Modelo base para Ficha Técnica (FT) y configuración de certificado.

    OBJETIVO
    - ET y FT se versionan de forma independiente usando DOCUMENTO + VERSION.
    - VERSIONCARACTERISTICA continúa siendo exclusiva de la ET/evaluación.
    - VERSIONFTCARACTERISTICA guarda la especificación comunicada por la FT.
    - La selección de lo que puede/debe imprimirse vive en la versión FT.
    - No se modifica CARACTERISTICA ni EVALUACION_RESULTADO.

    IMPORTANTE
    Este script crea únicamente la estructura FT. No crea CERTIFICADO todavía.
    Antes de ejecutarlo en producción, validar en el ambiente destino los nombres
    de PK/FK de VERSION, CARACTERISTICA y TIPOCRITERIO.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('dbo.VERSIONFTCARACTERISTICA', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.VERSIONFTCARACTERISTICA
        (
            VersionFtCaracteristicaId INT IDENTITY(1,1) NOT NULL,
            VersionId                 INT NOT NULL,
            CaracteristicaId          INT NOT NULL,
            TipoCriterioId            INT NOT NULL,

            ValorCuantitativoInicial  DECIMAL(18,6) NULL,
            ValorCuantitativoFinal    DECIMAL(18,6) NULL,
            ValorCuantitativoIgual    DECIMAL(18,6) NULL,
            ValorCualitativo          VARCHAR(1000) NULL,
            UnidadDeMedida            VARCHAR(50) NULL,

            ImprimeCertificado        BIT NOT NULL
                CONSTRAINT DF_VERSIONFTCARACTERISTICA_ImprimeCertificado DEFAULT (0),

            ObligatorioCertificado    BIT NOT NULL
                CONSTRAINT DF_VERSIONFTCARACTERISTICA_ObligatorioCertificado DEFAULT (0),

            OrdenCertificado          INT NULL,

            Estado                    BIT NOT NULL
                CONSTRAINT DF_VERSIONFTCARACTERISTICA_Estado DEFAULT (1),

            AudUsuarioCreacion        VARCHAR(100) NULL,
            AudFechaCreacion          DATETIME2 NOT NULL
                CONSTRAINT DF_VERSIONFTCARACTERISTICA_AudFechaCreacion DEFAULT (SYSDATETIME()),
            AudUsuarioModificacion    VARCHAR(100) NULL,
            AudFechaActualizacion     DATETIME2 NULL,

            CONSTRAINT PK_VERSIONFTCARACTERISTICA
                PRIMARY KEY (VersionFtCaracteristicaId),

            CONSTRAINT FK_VERSIONFTCARACTERISTICA_VERSION
                FOREIGN KEY (VersionId)
                REFERENCES dbo.VERSION (VersionId),

            CONSTRAINT FK_VERSIONFTCARACTERISTICA_CARACTERISTICA
                FOREIGN KEY (CaracteristicaId)
                REFERENCES dbo.CARACTERISTICA (CaracteristicaId),

            CONSTRAINT FK_VERSIONFTCARACTERISTICA_TIPOCRITERIO
                FOREIGN KEY (TipoCriterioId)
                REFERENCES dbo.TIPOCRITERIO (TipoCriterioId),

            CONSTRAINT CK_VERSIONFTCARACTERISTICA_OBLIGATORIO
                CHECK (ObligatorioCertificado = 0 OR ImprimeCertificado = 1),

            CONSTRAINT CK_VERSIONFTCARACTERISTICA_ORDEN
                CHECK (
                    (ImprimeCertificado = 0 AND OrdenCertificado IS NULL)
                    OR
                    (ImprimeCertificado = 1 AND OrdenCertificado IS NOT NULL AND OrdenCertificado > 0)
                )
        );

        /*
          Una característica se define una sola vez dentro de una versión FT.
          Si en el futuro una FT necesita repetir la misma característica por
          sección/presentación, esta restricción deberá evolucionar junto con
          esa necesidad real.
        */
        CREATE UNIQUE INDEX UX_VERSIONFTCARACTERISTICA_VERSION_CARACTERISTICA
            ON dbo.VERSIONFTCARACTERISTICA (VersionId, CaracteristicaId);

        CREATE INDEX IX_VERSIONFTCARACTERISTICA_CERTIFICADO
            ON dbo.VERSIONFTCARACTERISTICA
            (
                VersionId,
                ImprimeCertificado,
                OrdenCertificado
            )
            INCLUDE
            (
                CaracteristicaId,
                TipoCriterioId,
                ObligatorioCertificado,
                Estado
            );
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
