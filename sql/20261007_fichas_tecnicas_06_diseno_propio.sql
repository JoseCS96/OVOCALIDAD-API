/*
 OVOCALIDAD 2.0 - Diseño propio de Ficha Técnica.
 La FT no reutiliza el diseñador de secciones de la ET.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID('dbo.VERSIONFTSECCION','U') IS NULL
BEGIN
    CREATE TABLE dbo.VERSIONFTSECCION
    (
        VersionFtSeccionId       INT IDENTITY(1,1) NOT NULL,
        VersionId                INT NOT NULL,
        Codigo                   VARCHAR(60) NOT NULL,
        Titulo                   VARCHAR(200) NOT NULL,
        TipoContenido            VARCHAR(30) NOT NULL,
        Orden                    INT NOT NULL,
        Visible                  BIT NOT NULL CONSTRAINT DF_VERSIONFTSECCION_Visible DEFAULT(1),
        EsSistema                BIT NOT NULL CONSTRAINT DF_VERSIONFTSECCION_EsSistema DEFAULT(0),
        Contenido                VARCHAR(MAX) NULL,
        Estado                   BIT NOT NULL CONSTRAINT DF_VERSIONFTSECCION_Estado DEFAULT(1),
        AudUsuarioCreacion       VARCHAR(100) NOT NULL,
        AudFechaCreacion         DATETIME2 NOT NULL CONSTRAINT DF_VERSIONFTSECCION_AudFechaCreacion DEFAULT(SYSDATETIME()),
        AudUsuarioModificacion   VARCHAR(100) NULL,
        AudFechaActualizacion    DATETIME2 NULL,

        CONSTRAINT PK_VERSIONFTSECCION PRIMARY KEY(VersionFtSeccionId),
        CONSTRAINT FK_VERSIONFTSECCION_VERSION
            FOREIGN KEY(VersionId) REFERENCES dbo.VERSION(VersionId),
        CONSTRAINT CK_VERSIONFTSECCION_TIPO
            CHECK(TipoContenido IN ('TEXTO','LISTA','TABLA','CARACTERISTICAS'))
    );

    CREATE UNIQUE INDEX UX_VERSIONFTSECCION_VERSION_CODIGO
        ON dbo.VERSIONFTSECCION(VersionId,Codigo)
        WHERE Estado=1;

    CREATE INDEX IX_VERSIONFTSECCION_VERSION_ORDEN
        ON dbo.VERSIONFTSECCION(VersionId,Estado,Orden);
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_INICIALIZAR_SECCIONES_FT
(
    @VersionId INT,
    @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.VERSION V
            INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId=V.DocumentoId
            WHERE V.VersionId=@VersionId
              AND V.Estado=1
              AND D.Estado=1
              AND D.TipoDocumentoId=3
        )
            THROW 50001, 'La versión indicada no corresponde a una FT activa.', 1;

        DECLARE @Base TABLE
        (
            Codigo VARCHAR(60),
            Titulo VARCHAR(200),
            TipoContenido VARCHAR(30),
            Orden INT,
            EsSistema BIT
        );

        INSERT INTO @Base(Codigo,Titulo,TipoContenido,Orden,EsSistema)
        VALUES
          ('DESCRIPCION','Descripción del producto','TEXTO',1,1),
          ('INGREDIENTES','Ingredientes','TEXTO',2,1),
          ('ALMACENAMIENTO_DISTRIBUCION','Condiciones de almacenamiento y distribución','TEXTO',3,1),
          ('VIDA_UTIL','Vida útil','TEXTO',4,1),
          ('CONTENIDO_ROTULADO','Contenido rotulado','LISTA',5,1),
          ('ENVASADO','Envasado','TEXTO',6,1),
          ('CARACTERISTICAS','Características','CARACTERISTICAS',7,1),
          ('PROXIMAL','Proximal','TABLA',8,0),
          ('DECLARACIONES','Declaraciones','LISTA',9,0),
          ('ALERGENOS','Alérgenos','TABLA',10,0);

        INSERT INTO dbo.VERSIONFTSECCION
        (
            VersionId,Codigo,Titulo,TipoContenido,Orden,Visible,EsSistema,
            Contenido,Estado,AudUsuarioCreacion,AudFechaCreacion
        )
        SELECT
            @VersionId,B.Codigo,B.Titulo,B.TipoContenido,B.Orden,1,B.EsSistema,
            NULL,1,@Usuario,SYSDATETIME()
        FROM @Base B
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.VERSIONFTSECCION S
            WHERE S.VersionId=@VersionId
              AND S.Codigo=B.Codigo
              AND S.Estado=1
        );

        SELECT 0 CodigoResultado,
               'Secciones estándar de FT inicializadas correctamente.' Mensaje,
               @VersionId VersionId;
    END TRY
    BEGIN CATCH
        SELECT -1 CodigoResultado,ERROR_MESSAGE() Mensaje,@VersionId VersionId;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_SECCIONES_FT
(
    @VersionId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        VersionFtSeccionId,
        VersionId,
        Codigo,
        Titulo,
        TipoContenido,
        Orden,
        Visible,
        EsSistema,
        Contenido
    FROM dbo.VERSIONFTSECCION
    WHERE VersionId=@VersionId
      AND Estado=1
    ORDER BY Orden,VersionFtSeccionId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_GUARDAR_CONTENIDO_SECCION_FT
(
    @VersionId INT,
    @VersionFtSeccionId INT,
    @Titulo VARCHAR(200),
    @Contenido VARCHAR(MAX)=NULL,
    @Visible BIT=1,
    @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.VERSIONFTSECCION S
            INNER JOIN dbo.VERSION V ON V.VersionId=S.VersionId
            INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId=V.DocumentoId
            WHERE S.VersionFtSeccionId=@VersionFtSeccionId
              AND S.VersionId=@VersionId
              AND S.Estado=1
              AND V.Estado=1
              AND D.Estado=1
              AND D.TipoDocumentoId=3
        )
            THROW 50001, 'La sección indicada no pertenece a la versión FT.', 1;

        SET @Titulo=NULLIF(LTRIM(RTRIM(@Titulo)),'');
        IF @Titulo IS NULL
            THROW 50002, 'Debe indicar el título de la sección.', 1;

        UPDATE dbo.VERSIONFTSECCION
        SET Titulo=@Titulo,
            Contenido=@Contenido,
            Visible=@Visible,
            AudUsuarioModificacion=@Usuario,
            AudFechaActualizacion=SYSDATETIME()
        WHERE VersionFtSeccionId=@VersionFtSeccionId
          AND VersionId=@VersionId
          AND Estado=1;

        SELECT 0 CodigoResultado,
               'Sección FT guardada correctamente.' Mensaje,
               @VersionFtSeccionId VersionFtSeccionId,
               @VersionId VersionId;
    END TRY
    BEGIN CATCH
        SELECT -1 CodigoResultado,ERROR_MESSAGE() Mensaje,
               @VersionFtSeccionId VersionFtSeccionId,@VersionId VersionId;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_AGREGAR_SECCION_FT
(
    @VersionId INT,
    @Titulo VARCHAR(200),
    @TipoContenido VARCHAR(30)='TEXTO',
    @Orden INT=NULL,
    @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @VersionFtSeccionId INT,
            @Codigo VARCHAR(60);

    BEGIN TRY
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.VERSION V
            INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId=V.DocumentoId
            WHERE V.VersionId=@VersionId
              AND V.Estado=1
              AND D.Estado=1
              AND D.TipoDocumentoId=3
        )
            THROW 50001, 'La versión FT no existe o está inactiva.', 1;

        SET @Titulo=NULLIF(LTRIM(RTRIM(@Titulo)),'');
        SET @TipoContenido=UPPER(NULLIF(LTRIM(RTRIM(@TipoContenido)),''));

        IF @Titulo IS NULL
            THROW 50002, 'Debe indicar el título de la sección.', 1;

        IF @TipoContenido NOT IN ('TEXTO','LISTA','TABLA')
            THROW 50003, 'El tipo de contenido de la sección no es válido.', 1;

        IF @Orden IS NULL
            SELECT @Orden=ISNULL(MAX(Orden),0)+1
            FROM dbo.VERSIONFTSECCION
            WHERE VersionId=@VersionId AND Estado=1;

        SET @Codigo='CUSTOM_' + REPLACE(CONVERT(VARCHAR(36),NEWID()),'-','');

        INSERT INTO dbo.VERSIONFTSECCION
        (
            VersionId,Codigo,Titulo,TipoContenido,Orden,Visible,EsSistema,
            Estado,AudUsuarioCreacion,AudFechaCreacion
        )
        VALUES
        (
            @VersionId,@Codigo,@Titulo,@TipoContenido,@Orden,1,0,
            1,@Usuario,SYSDATETIME()
        );

        SET @VersionFtSeccionId=CONVERT(INT,SCOPE_IDENTITY());

        SELECT 0 CodigoResultado,'Sección FT agregada correctamente.' Mensaje,
               @VersionFtSeccionId VersionFtSeccionId,@VersionId VersionId,@Orden Orden;
    END TRY
    BEGIN CATCH
        SELECT -1 CodigoResultado,ERROR_MESSAGE() Mensaje,
               CAST(NULL AS INT) VersionFtSeccionId,@VersionId VersionId,@Orden Orden;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_QUITAR_SECCION_FT
(
    @VersionId INT,
    @VersionFtSeccionId INT,
    @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.VERSIONFTSECCION
            WHERE VersionFtSeccionId=@VersionFtSeccionId
              AND VersionId=@VersionId
              AND Estado=1
        )
            THROW 50001, 'La sección indicada no pertenece a la versión FT.', 1;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.VERSIONFTSECCION
            WHERE VersionFtSeccionId=@VersionFtSeccionId
              AND VersionId=@VersionId
              AND EsSistema=1
        )
            THROW 50002, 'La sección es parte de la estructura base de la FT. Puede ocultarla, pero no eliminarla.', 1;

        UPDATE dbo.VERSIONFTSECCION
        SET Estado=0,
            AudUsuarioModificacion=@Usuario,
            AudFechaActualizacion=SYSDATETIME()
        WHERE VersionFtSeccionId=@VersionFtSeccionId
          AND VersionId=@VersionId;

        SELECT 0 CodigoResultado,'Sección FT retirada correctamente.' Mensaje,
               @VersionFtSeccionId VersionFtSeccionId;
    END TRY
    BEGIN CATCH
        SELECT -1 CodigoResultado,ERROR_MESSAGE() Mensaje,
               @VersionFtSeccionId VersionFtSeccionId;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_REORDENAR_SECCIONES_FT
(
    @VersionId INT,
    @SeccionesJson VARCHAR(MAX),
    @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF ISJSON(@SeccionesJson)<>1
            THROW 50001,'El orden de secciones no tiene un formato válido.',1;

        DECLARE @Orden TABLE
        (
            VersionFtSeccionId INT PRIMARY KEY,
            Orden INT NOT NULL
        );

        INSERT INTO @Orden(VersionFtSeccionId,Orden)
        SELECT VersionFtSeccionId,Orden
        FROM OPENJSON(@SeccionesJson)
        WITH
        (
            VersionFtSeccionId INT '$.versionFtSeccionId',
            Orden INT '$.orden'
        );

        IF EXISTS
        (
            SELECT 1
            FROM @Orden O
            LEFT JOIN dbo.VERSIONFTSECCION S
              ON S.VersionFtSeccionId=O.VersionFtSeccionId
             AND S.VersionId=@VersionId
             AND S.Estado=1
            WHERE S.VersionFtSeccionId IS NULL
        )
            THROW 50002,'Una o más secciones no pertenecen a la versión FT.',1;

        UPDATE S
        SET S.Orden=O.Orden,
            S.AudUsuarioModificacion=@Usuario,
            S.AudFechaActualizacion=SYSDATETIME()
        FROM dbo.VERSIONFTSECCION S
        INNER JOIN @Orden O ON O.VersionFtSeccionId=S.VersionFtSeccionId
        WHERE S.VersionId=@VersionId AND S.Estado=1;

        SELECT 0 CodigoResultado,'Orden de secciones FT actualizado correctamente.' Mensaje;
    END TRY
    BEGIN CATCH
        SELECT -1 CodigoResultado,ERROR_MESSAGE() Mensaje;
    END CATCH;
END;
GO

/* Inicializa versiones FT activas ya existentes para que el nuevo diseñador
   pueda utilizarse también con datos creados antes de esta migración. */
DECLARE @VersionIdSeed INT;
DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
SELECT V.VersionId
FROM dbo.VERSION V
INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId=V.DocumentoId
WHERE V.Estado=1 AND D.Estado=1 AND D.TipoDocumentoId=3;

OPEN cur;
FETCH NEXT FROM cur INTO @VersionIdSeed;
WHILE @@FETCH_STATUS=0
BEGIN
    EXEC dbo.SP_INICIALIZAR_SECCIONES_FT @VersionId=@VersionIdSeed,@Usuario='MIGRACION_FT';
    FETCH NEXT FROM cur INTO @VersionIdSeed;
END;
CLOSE cur;
DEALLOCATE cur;
GO
