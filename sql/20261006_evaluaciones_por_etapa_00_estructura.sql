/*
OVOCALIDAD 2.0
Fecha   : 2026-10-06
Modulo  : ET / Evaluaciones por etapas
Objetivo: versionar la estructura validada en la prueba integral del lote H260002L2.

Este script es idempotente y NO carga datos de prueba.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/* =========================================================
   1. VERSIONFASE
   Ruta concreta de evaluacion de una version de ET.
   ========================================================= */
IF OBJECT_ID('dbo.VERSIONFASE', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.VERSIONFASE
    (
          VersionFaseId          INT IDENTITY(1,1) NOT NULL
        , VersionId              INT NOT NULL
        , FaseId                 INT NOT NULL
        , CodigoReferencia       VARCHAR(30) NOT NULL
        , Descripcion            VARCHAR(200) NULL
        , Orden                  INT NOT NULL
        , EsFinal                BIT NOT NULL CONSTRAINT DF_VERSIONFASE_EsFinal DEFAULT (0)
        , EsObligatoria          BIT NOT NULL CONSTRAINT DF_VERSIONFASE_EsObligatoria DEFAULT (1)
        , Estado                 BIT NOT NULL CONSTRAINT DF_VERSIONFASE_Estado DEFAULT (1)
        , AudUsuarioCreacion     VARCHAR(50) NOT NULL
        , AudFechaCreacion       DATETIME2 NOT NULL CONSTRAINT DF_VERSIONFASE_AudFechaCreacion DEFAULT (SYSDATETIME())
        , AudUsuarioModificacion VARCHAR(50) NULL
        , AudFechaActualizacion  DATETIME2 NULL
        , CONSTRAINT PK_VERSIONFASE PRIMARY KEY (VersionFaseId)
        , CONSTRAINT FK_VERSIONFASE_VERSION FOREIGN KEY (VersionId)
            REFERENCES dbo.VERSION (VersionId)
        , CONSTRAINT FK_VERSIONFASE_FASE FOREIGN KEY (FaseId)
            REFERENCES dbo.FASE (FaseId)
        , CONSTRAINT CK_VERSIONFASE_Orden CHECK (Orden > 0)
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.VERSIONFASE')
      AND name = 'UX_VERSIONFASE_Version_Orden_Activo'
)
BEGIN
    CREATE UNIQUE INDEX UX_VERSIONFASE_Version_Orden_Activo
        ON dbo.VERSIONFASE (VersionId, Orden)
        WHERE Estado = 1;
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.VERSIONFASE')
      AND name = 'UX_VERSIONFASE_Version_CodigoReferencia_Activo'
)
BEGIN
    CREATE UNIQUE INDEX UX_VERSIONFASE_Version_CodigoReferencia_Activo
        ON dbo.VERSIONFASE (VersionId, CodigoReferencia)
        WHERE Estado = 1;
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.VERSIONFASE')
      AND name = 'UX_VERSIONFASE_Version_Final_Activo'
)
BEGIN
    CREATE UNIQUE INDEX UX_VERSIONFASE_Version_Final_Activo
        ON dbo.VERSIONFASE (VersionId)
        WHERE EsFinal = 1 AND Estado = 1;
END;
GO

/* =========================================================
   2. VERSIONCARACTERISTICA -> VERSIONFASE
   FaseId se conserva temporalmente por compatibilidad.
   ========================================================= */
IF COL_LENGTH('dbo.VERSIONCARACTERISTICA', 'VersionFaseId') IS NULL
BEGIN
    ALTER TABLE dbo.VERSIONCARACTERISTICA
        ADD VersionFaseId INT NULL;
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE parent_object_id = OBJECT_ID('dbo.VERSIONCARACTERISTICA')
      AND name = 'FK_VERSIONCARACTERISTICA_VERSIONFASE'
)
BEGIN
    ALTER TABLE dbo.VERSIONCARACTERISTICA WITH CHECK
        ADD CONSTRAINT FK_VERSIONCARACTERISTICA_VERSIONFASE
        FOREIGN KEY (VersionFaseId)
        REFERENCES dbo.VERSIONFASE (VersionFaseId);

    ALTER TABLE dbo.VERSIONCARACTERISTICA
        CHECK CONSTRAINT FK_VERSIONCARACTERISTICA_VERSIONFASE;
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.VERSIONCARACTERISTICA')
      AND name = 'IX_VERSIONCARACTERISTICA_VERSIONFASE'
)
BEGIN
    CREATE INDEX IX_VERSIONCARACTERISTICA_VERSIONFASE
        ON dbo.VERSIONCARACTERISTICA (VersionFaseId);
END;
GO

/* =========================================================
   3. EVALUACION -> VERSIONFASE
   Una evaluacion representa un intento de una etapa.
   EvaluacionPadreId mantiene la cadena de reevaluaciones.
   ========================================================= */
IF COL_LENGTH('dbo.EVALUACION', 'VersionFaseId') IS NULL
BEGIN
    ALTER TABLE dbo.EVALUACION
        ADD VersionFaseId INT NULL;
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE parent_object_id = OBJECT_ID('dbo.EVALUACION')
      AND name = 'FK_EVALUACION_VERSIONFASE'
)
BEGIN
    ALTER TABLE dbo.EVALUACION WITH CHECK
        ADD CONSTRAINT FK_EVALUACION_VERSIONFASE
        FOREIGN KEY (VersionFaseId)
        REFERENCES dbo.VERSIONFASE (VersionFaseId);

    ALTER TABLE dbo.EVALUACION
        CHECK CONSTRAINT FK_EVALUACION_VERSIONFASE;
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.EVALUACION')
      AND name = 'IX_EVALUACION_VERSIONFASE'
)
BEGIN
    CREATE INDEX IX_EVALUACION_VERSIONFASE
        ON dbo.EVALUACION (VersionFaseId);
END;
GO

SELECT
      0 AS CodigoResultado
    , 'Estructura de evaluaciones por etapas verificada correctamente.' AS Mensaje;
GO
