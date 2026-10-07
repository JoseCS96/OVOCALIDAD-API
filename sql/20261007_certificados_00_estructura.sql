/*
    OVOCALIDAD 2.0 - Certificación
    Estructura base del diseñador de plantillas y snapshot de emisión.

    Regla funcional:
    - La FT determina qué parámetros pueden/deben certificarse.
    - La plantilla determina cómo se presentan.
    - El resultado proviene de la evaluación del lote.
    - El certificado emitido conserva snapshot para reimpresión histórica.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('dbo.CERTIFICADOPLANTILLA', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.CERTIFICADOPLANTILLA
        (
            CertificadoPlantillaId INT IDENTITY(1,1) NOT NULL,
            VersionFtId INT NOT NULL,
            Nombre VARCHAR(200) NOT NULL,
            Descripcion VARCHAR(1000) NULL,
            Estado BIT NOT NULL CONSTRAINT DF_CERTIFICADOPLANTILLA_Estado DEFAULT (1),
            AudUsuarioCreacion VARCHAR(100) NOT NULL,
            AudFechaCreacion DATETIME2 NOT NULL CONSTRAINT DF_CERTIFICADOPLANTILLA_AudFechaCreacion DEFAULT (SYSDATETIME()),
            AudUsuarioModificacion VARCHAR(100) NULL,
            AudFechaActualizacion DATETIME2 NULL,
            CONSTRAINT PK_CERTIFICADOPLANTILLA PRIMARY KEY (CertificadoPlantillaId),
            CONSTRAINT FK_CERTIFICADOPLANTILLA_VERSION FOREIGN KEY (VersionFtId) REFERENCES dbo.VERSION(VersionId)
        );

        CREATE INDEX IX_CERTIFICADOPLANTILLA_VERSIONFT
            ON dbo.CERTIFICADOPLANTILLA(VersionFtId, Estado);
    END;

    IF OBJECT_ID('dbo.CERTIFICADOPLANTILLASECCION', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.CERTIFICADOPLANTILLASECCION
        (
            CertificadoPlantillaSeccionId INT IDENTITY(1,1) NOT NULL,
            CertificadoPlantillaId INT NOT NULL,
            TipoSeccion VARCHAR(40) NOT NULL,
            Titulo VARCHAR(200) NULL,
            Orden INT NOT NULL,
            Visible BIT NOT NULL CONSTRAINT DF_CERTIFICADOPLANTILLASECCION_Visible DEFAULT (1),
            Estado BIT NOT NULL CONSTRAINT DF_CERTIFICADOPLANTILLASECCION_Estado DEFAULT (1),
            AudUsuarioCreacion VARCHAR(100) NOT NULL,
            AudFechaCreacion DATETIME2 NOT NULL CONSTRAINT DF_CERTIFICADOPLANTILLASECCION_AudFechaCreacion DEFAULT (SYSDATETIME()),
            AudUsuarioModificacion VARCHAR(100) NULL,
            AudFechaActualizacion DATETIME2 NULL,
            CONSTRAINT PK_CERTIFICADOPLANTILLASECCION PRIMARY KEY (CertificadoPlantillaSeccionId),
            CONSTRAINT FK_CERTIFICADOPLANTILLASECCION_PLANTILLA FOREIGN KEY (CertificadoPlantillaId)
                REFERENCES dbo.CERTIFICADOPLANTILLA(CertificadoPlantillaId),
            CONSTRAINT CK_CERTIFICADOPLANTILLASECCION_ORDEN CHECK (Orden > 0),
            CONSTRAINT CK_CERTIFICADOPLANTILLASECCION_TIPO CHECK
            (
                TipoSeccion IN
                ('ENCABEZADO','DATOS_LOTE','RESULTADOS','ALMACENAMIENTO','REFERENCIAS','FIRMA','PIE')
            )
        );

        CREATE UNIQUE INDEX UX_CERTIFICADOPLANTILLASECCION_ORDEN
            ON dbo.CERTIFICADOPLANTILLASECCION(CertificadoPlantillaId, Orden)
            WHERE Estado = 1;
    END;

    IF OBJECT_ID('dbo.CERTIFICADOPLANTILLACARACTERISTICA', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.CERTIFICADOPLANTILLACARACTERISTICA
        (
            CertificadoPlantillaCaracteristicaId INT IDENTITY(1,1) NOT NULL,
            CertificadoPlantillaSeccionId INT NOT NULL,
            VersionFtCaracteristicaId INT NOT NULL,
            Orden INT NOT NULL,
            Estado BIT NOT NULL CONSTRAINT DF_CERTIFICADOPLANTILLACARACTERISTICA_Estado DEFAULT (1),
            AudUsuarioCreacion VARCHAR(100) NOT NULL,
            AudFechaCreacion DATETIME2 NOT NULL CONSTRAINT DF_CERTIFICADOPLANTILLACARACTERISTICA_AudFechaCreacion DEFAULT (SYSDATETIME()),
            AudUsuarioModificacion VARCHAR(100) NULL,
            AudFechaActualizacion DATETIME2 NULL,
            CONSTRAINT PK_CERTIFICADOPLANTILLACARACTERISTICA PRIMARY KEY (CertificadoPlantillaCaracteristicaId),
            CONSTRAINT FK_CERTIFICADOPLANTILLACARACTERISTICA_SECCION FOREIGN KEY (CertificadoPlantillaSeccionId)
                REFERENCES dbo.CERTIFICADOPLANTILLASECCION(CertificadoPlantillaSeccionId),
            CONSTRAINT FK_CERTIFICADOPLANTILLACARACTERISTICA_FT FOREIGN KEY (VersionFtCaracteristicaId)
                REFERENCES dbo.VERSIONFTCARACTERISTICA(VersionFtCaracteristicaId),
            CONSTRAINT CK_CERTIFICADOPLANTILLACARACTERISTICA_ORDEN CHECK (Orden > 0)
        );

        CREATE UNIQUE INDEX UX_CERTIFICADOPLANTILLACARACTERISTICA
            ON dbo.CERTIFICADOPLANTILLACARACTERISTICA(CertificadoPlantillaSeccionId, VersionFtCaracteristicaId)
            WHERE Estado = 1;
    END;

    IF OBJECT_ID('dbo.CERTIFICADO', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.CERTIFICADO
        (
            CertificadoId INT IDENTITY(1,1) NOT NULL,
            LoteId INT NOT NULL,
            CertificadoPlantillaId INT NULL,
            VersionFtId INT NOT NULL,
            NumeroCertificado VARCHAR(50) NULL,
            FechaEmision DATETIME2 NOT NULL CONSTRAINT DF_CERTIFICADO_FechaEmision DEFAULT (SYSDATETIME()),
            Estado VARCHAR(20) NOT NULL CONSTRAINT DF_CERTIFICADO_Estado DEFAULT ('EMITIDO'),
            AudUsuarioCreacion VARCHAR(100) NOT NULL,
            AudFechaCreacion DATETIME2 NOT NULL CONSTRAINT DF_CERTIFICADO_AudFechaCreacion DEFAULT (SYSDATETIME()),
            AudUsuarioModificacion VARCHAR(100) NULL,
            AudFechaActualizacion DATETIME2 NULL,
            CONSTRAINT PK_CERTIFICADO PRIMARY KEY (CertificadoId),
            CONSTRAINT FK_CERTIFICADO_LOTE FOREIGN KEY (LoteId) REFERENCES dbo.LOTE(LoteId),
            CONSTRAINT FK_CERTIFICADO_PLANTILLA FOREIGN KEY (CertificadoPlantillaId)
                REFERENCES dbo.CERTIFICADOPLANTILLA(CertificadoPlantillaId),
            CONSTRAINT FK_CERTIFICADO_VERSIONFT FOREIGN KEY (VersionFtId) REFERENCES dbo.VERSION(VersionId),
            CONSTRAINT CK_CERTIFICADO_ESTADO CHECK (Estado IN ('EMITIDO','ANULADO'))
        );

        CREATE INDEX IX_CERTIFICADO_LOTE ON dbo.CERTIFICADO(LoteId, Estado, FechaEmision);
    END;

    IF OBJECT_ID('dbo.CERTIFICADODETALLE', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.CERTIFICADODETALLE
        (
            CertificadoDetalleId INT IDENTITY(1,1) NOT NULL,
            CertificadoId INT NOT NULL,
            TipoSeccion VARCHAR(40) NOT NULL,
            TituloSeccion VARCHAR(200) NULL,
            OrdenSeccion INT NOT NULL,
            CaracteristicaId INT NULL,
            Determinacion VARCHAR(500) NULL,
            Resultado VARCHAR(1000) NULL,
            Especificacion VARCHAR(1000) NULL,
            UnidadDeMedida VARCHAR(50) NULL,
            MetodoEnsayo VARCHAR(1000) NULL,
            OrdenDetalle INT NULL,
            Contenido VARCHAR(MAX) NULL,
            CONSTRAINT PK_CERTIFICADODETALLE PRIMARY KEY (CertificadoDetalleId),
            CONSTRAINT FK_CERTIFICADODETALLE_CERTIFICADO FOREIGN KEY (CertificadoId)
                REFERENCES dbo.CERTIFICADO(CertificadoId),
            CONSTRAINT FK_CERTIFICADODETALLE_CARACTERISTICA FOREIGN KEY (CaracteristicaId)
                REFERENCES dbo.CARACTERISTICA(CaracteristicaId)
        );

        CREATE INDEX IX_CERTIFICADODETALLE_CERTIFICADO
            ON dbo.CERTIFICADODETALLE(CertificadoId, OrdenSeccion, OrdenDetalle);
    END;

    COMMIT TRANSACTION;

    SELECT 0 CodigoResultado,
           'Estructura base de plantillas y certificados creada correctamente.' Mensaje;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
