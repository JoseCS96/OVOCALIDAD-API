/*
 OVOCALIDAD 2.0
 FT - Estructura complementaria propia:
 - Declaraciones
 - Alérgenos
 - Metadatos por grupo de características
 - Características propias FT / tolerancia
 - Secciones de sistema DECLARACIONES, ALERGENOS y PROXIMAL

 IMPORTANTE:
 - Migración aditiva e idempotente.
 - No modifica VERSIONCARACTERISTICA (ET/evaluación).
 - No altera certificados existentes.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/* =========================================================
   1. CATÁLOGO DE ALÉRGENOS
   ========================================================= */
IF OBJECT_ID('dbo.ALERGENO','U') IS NULL
BEGIN
    CREATE TABLE dbo.ALERGENO
    (
        AlergenoId              INT IDENTITY(1,1) NOT NULL,
        AlergenoCodigo          VARCHAR(60) NOT NULL,
        AlergenoDescripcion     VARCHAR(300) NOT NULL,
        Orden                   INT NOT NULL,
        Estado                  BIT NOT NULL CONSTRAINT DF_ALERGENO_Estado DEFAULT(1),
        AudUsuarioCreacion      VARCHAR(100) NULL,
        AudFechaCreacion        DATETIME2 NOT NULL CONSTRAINT DF_ALERGENO_AudFechaCreacion DEFAULT(SYSDATETIME()),
        AudUsuarioModificacion  VARCHAR(100) NULL,
        AudFechaActualizacion   DATETIME2 NULL,
        CONSTRAINT PK_ALERGENO PRIMARY KEY(AlergenoId)
    );

    CREATE UNIQUE INDEX UX_ALERGENO_CODIGO
        ON dbo.ALERGENO(AlergenoCodigo);
END;
GO

DECLARE @Alergenos TABLE
(
    Codigo VARCHAR(60) NOT NULL,
    Descripcion VARCHAR(300) NOT NULL,
    Orden INT NOT NULL
);

INSERT INTO @Alergenos(Codigo,Descripcion,Orden)
VALUES
('GLUTEN','Cereales que contengan gluten',1),
('CRUSTACEOS','Crustáceos',2),
('HUEVOS','Huevos',3),
('PESCADO','Pescado',4),
('CACAHUATES','Cacahuates',5),
('SOJA','Soja',6),
('LECHE','Leche (incluida lactosa)',7),
('FRUTOS_CASCARA','Frutos de cáscara',8),
('SULFITOS','Dióxido de azufre y sulfitos',9),
('APIO','Apio',10),
('MOSTAZA','Mostaza',11),
('SESAMO','Granos de sésamo',12),
('ALTRAMUCES','Altramuces',13),
('MOLUSCOS','Moluscos',14);

MERGE dbo.ALERGENO AS T
USING @Alergenos AS S
ON T.AlergenoCodigo=S.Codigo
WHEN MATCHED THEN
    UPDATE SET
        T.AlergenoDescripcion=S.Descripcion,
        T.Orden=S.Orden
WHEN NOT MATCHED BY TARGET THEN
    INSERT(AlergenoCodigo,AlergenoDescripcion,Orden,Estado,AudUsuarioCreacion,AudFechaCreacion)
    VALUES(S.Codigo,S.Descripcion,S.Orden,1,'MIGRACION_FT',SYSDATETIME());
GO

/* =========================================================
   2. ALÉRGENOS POR VERSIÓN FT
   ========================================================= */
IF OBJECT_ID('dbo.VERSIONFTALERGENO','U') IS NULL
BEGIN
    CREATE TABLE dbo.VERSIONFTALERGENO
    (
        VersionFtAlergenoId     INT IDENTITY(1,1) NOT NULL,
        VersionId               INT NOT NULL,
        AlergenoId              INT NOT NULL,
        EnProducto              BIT NOT NULL CONSTRAINT DF_VERSIONFTALERGENO_EnProducto DEFAULT(0),
        EnLinea                 BIT NOT NULL CONSTRAINT DF_VERSIONFTALERGENO_EnLinea DEFAULT(0),
        EnPlanta                BIT NOT NULL CONSTRAINT DF_VERSIONFTALERGENO_EnPlanta DEFAULT(0),
        Descripcion             VARCHAR(500) NULL,
        Orden                   INT NOT NULL,
        Estado                  BIT NOT NULL CONSTRAINT DF_VERSIONFTALERGENO_Estado DEFAULT(1),
        AudUsuarioCreacion      VARCHAR(100) NULL,
        AudFechaCreacion        DATETIME2 NOT NULL CONSTRAINT DF_VERSIONFTALERGENO_AudFechaCreacion DEFAULT(SYSDATETIME()),
        AudUsuarioModificacion  VARCHAR(100) NULL,
        AudFechaActualizacion   DATETIME2 NULL,

        CONSTRAINT PK_VERSIONFTALERGENO PRIMARY KEY(VersionFtAlergenoId),
        CONSTRAINT FK_VERSIONFTALERGENO_VERSION
            FOREIGN KEY(VersionId) REFERENCES dbo.VERSION(VersionId),
        CONSTRAINT FK_VERSIONFTALERGENO_ALERGENO
            FOREIGN KEY(AlergenoId) REFERENCES dbo.ALERGENO(AlergenoId)
    );

    CREATE UNIQUE INDEX UX_VERSIONFTALERGENO_VERSION_ALERGENO
        ON dbo.VERSIONFTALERGENO(VersionId,AlergenoId)
        WHERE Estado=1;

    CREATE INDEX IX_VERSIONFTALERGENO_VERSION_ORDEN
        ON dbo.VERSIONFTALERGENO(VersionId,Estado,Orden);
END;
GO

/* =========================================================
   3. DECLARACIONES POR VERSIÓN FT
   ========================================================= */
IF OBJECT_ID('dbo.VERSIONFTDECLARACION','U') IS NULL
BEGIN
    CREATE TABLE dbo.VERSIONFTDECLARACION
    (
        VersionFtDeclaracionId  INT IDENTITY(1,1) NOT NULL,
        VersionId               INT NOT NULL,
        Codigo                  VARCHAR(60) NOT NULL,
        Titulo                  VARCHAR(250) NOT NULL,
        Descripcion             VARCHAR(2000) NULL,
        Orden                   INT NOT NULL,
        Estado                  BIT NOT NULL CONSTRAINT DF_VERSIONFTDECLARACION_Estado DEFAULT(1),
        AudUsuarioCreacion      VARCHAR(100) NULL,
        AudFechaCreacion        DATETIME2 NOT NULL CONSTRAINT DF_VERSIONFTDECLARACION_AudFechaCreacion DEFAULT(SYSDATETIME()),
        AudUsuarioModificacion  VARCHAR(100) NULL,
        AudFechaActualizacion   DATETIME2 NULL,

        CONSTRAINT PK_VERSIONFTDECLARACION PRIMARY KEY(VersionFtDeclaracionId),
        CONSTRAINT FK_VERSIONFTDECLARACION_VERSION
            FOREIGN KEY(VersionId) REFERENCES dbo.VERSION(VersionId)
    );

    CREATE UNIQUE INDEX UX_VERSIONFTDECLARACION_VERSION_CODIGO
        ON dbo.VERSIONFTDECLARACION(VersionId,Codigo)
        WHERE Estado=1;

    CREATE INDEX IX_VERSIONFTDECLARACION_VERSION_ORDEN
        ON dbo.VERSIONFTDECLARACION(VersionId,Estado,Orden);
END;
GO

/* =========================================================
   4. REFERENCIAS / NOTAS POR GRUPO DE CARACTERÍSTICAS FT
   ========================================================= */
IF OBJECT_ID('dbo.VERSIONFTCARACTERISTICAGRUPO','U') IS NULL
BEGIN
    CREATE TABLE dbo.VERSIONFTCARACTERISTICAGRUPO
    (
        VersionFtCaracteristicaGrupoId INT IDENTITY(1,1) NOT NULL,
        VersionId               INT NOT NULL,
        TipoCaractId            INT NOT NULL,
        Titulo                  VARCHAR(250) NULL,
        Referencia              VARCHAR(2000) NULL,
        Nota                    VARCHAR(2000) NULL,
        Orden                   INT NULL,
        Estado                  BIT NOT NULL CONSTRAINT DF_VERSIONFTCARACTERISTICAGRUPO_Estado DEFAULT(1),
        AudUsuarioCreacion      VARCHAR(100) NULL,
        AudFechaCreacion        DATETIME2 NOT NULL CONSTRAINT DF_VERSIONFTCARACTERISTICAGRUPO_AudFechaCreacion DEFAULT(SYSDATETIME()),
        AudUsuarioModificacion  VARCHAR(100) NULL,
        AudFechaActualizacion   DATETIME2 NULL,

        CONSTRAINT PK_VERSIONFTCARACTERISTICAGRUPO PRIMARY KEY(VersionFtCaracteristicaGrupoId),
        CONSTRAINT FK_VERSIONFTCARACTERISTICAGRUPO_VERSION
            FOREIGN KEY(VersionId) REFERENCES dbo.VERSION(VersionId),
        CONSTRAINT FK_VERSIONFTCARACTERISTICAGRUPO_TIPO
            FOREIGN KEY(TipoCaractId) REFERENCES dbo.TIPO_CARACTERISTICA(TipoCaractId)
    );

    CREATE UNIQUE INDEX UX_VERSIONFTCARACTERISTICAGRUPO_VERSION_TIPO
        ON dbo.VERSIONFTCARACTERISTICAGRUPO(VersionId,TipoCaractId)
        WHERE Estado=1;
END;
GO

/* =========================================================
   5. EXTENDER CARACTERÍSTICA FT DE FORMA ADITIVA
   ========================================================= */
IF COL_LENGTH('dbo.VERSIONFTCARACTERISTICA','EsPropiaFt') IS NULL
BEGIN
    ALTER TABLE dbo.VERSIONFTCARACTERISTICA
    ADD EsPropiaFt BIT NOT NULL
        CONSTRAINT DF_VERSIONFTCARACTERISTICA_EsPropiaFt DEFAULT(0);
END;
GO

IF COL_LENGTH('dbo.VERSIONFTCARACTERISTICA','ValorTolerancia') IS NULL
BEGIN
    ALTER TABLE dbo.VERSIONFTCARACTERISTICA
    ADD ValorTolerancia DECIMAL(18,6) NULL;
END;
GO

/* =========================================================
   6. ASEGURAR SECCIONES COMPLEMENTARIAS EN FTs EXISTENTES
   ========================================================= */
;WITH FTs AS
(
    SELECT V.VersionId
    FROM dbo.VERSION V
    INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId=V.DocumentoId
    WHERE V.Estado=1
      AND D.Estado=1
      AND D.TipoDocumentoId=3
),
BaseOrden AS
(
    SELECT
        F.VersionId,
        ISNULL(MAX(S.Orden),0) AS MaxOrden
    FROM FTs F
    LEFT JOIN dbo.VERSIONFTSECCION S
      ON S.VersionId=F.VersionId
     AND S.Estado=1
    GROUP BY F.VersionId
)
INSERT INTO dbo.VERSIONFTSECCION
(
    VersionId,Codigo,Titulo,TipoContenido,Orden,Visible,EsSistema,Contenido,Estado,
    AudUsuarioCreacion,AudFechaCreacion
)
SELECT B.VersionId,'DECLARACIONES','Declaraciones','LISTA',B.MaxOrden+1,1,1,NULL,1,'MIGRACION_FT',SYSDATETIME()
FROM BaseOrden B
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.VERSIONFTSECCION S
    WHERE S.VersionId=B.VersionId
      AND S.Codigo='DECLARACIONES'
      AND S.Estado=1
);

;WITH FTs AS
(
    SELECT V.VersionId
    FROM dbo.VERSION V
    INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId=V.DocumentoId
    WHERE V.Estado=1
      AND D.Estado=1
      AND D.TipoDocumentoId=3
),
BaseOrden AS
(
    SELECT
        F.VersionId,
        ISNULL(MAX(S.Orden),0) AS MaxOrden
    FROM FTs F
    LEFT JOIN dbo.VERSIONFTSECCION S
      ON S.VersionId=F.VersionId
     AND S.Estado=1
    GROUP BY F.VersionId
)
INSERT INTO dbo.VERSIONFTSECCION
(
    VersionId,Codigo,Titulo,TipoContenido,Orden,Visible,EsSistema,Contenido,Estado,
    AudUsuarioCreacion,AudFechaCreacion
)
SELECT B.VersionId,'ALERGENOS','Alérgenos','TABLA',B.MaxOrden+1,1,1,NULL,1,'MIGRACION_FT',SYSDATETIME()
FROM BaseOrden B
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.VERSIONFTSECCION S
    WHERE S.VersionId=B.VersionId
      AND S.Codigo='ALERGENOS'
      AND S.Estado=1
);

;WITH FTs AS
(
    SELECT V.VersionId
    FROM dbo.VERSION V
    INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId=V.DocumentoId
    WHERE V.Estado=1
      AND D.Estado=1
      AND D.TipoDocumentoId=3
),
BaseOrden AS
(
    SELECT
        F.VersionId,
        ISNULL(MAX(S.Orden),0) AS MaxOrden
    FROM FTs F
    LEFT JOIN dbo.VERSIONFTSECCION S
      ON S.VersionId=F.VersionId
     AND S.Estado=1
    GROUP BY F.VersionId
)
INSERT INTO dbo.VERSIONFTSECCION
(
    VersionId,Codigo,Titulo,TipoContenido,Orden,Visible,EsSistema,Contenido,Estado,
    AudUsuarioCreacion,AudFechaCreacion
)
SELECT B.VersionId,'PROXIMAL','Proximal','CARACTERISTICAS',B.MaxOrden+1,1,1,NULL,1,'MIGRACION_FT',SYSDATETIME()
FROM BaseOrden B
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.VERSIONFTSECCION S
    WHERE S.VersionId=B.VersionId
      AND S.Codigo='PROXIMAL'
      AND S.Estado=1
);
GO

/* =========================================================
   7. INICIALIZAR SECCIONES FT PARA NUEVAS VERSIONES
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.SP_INICIALIZAR_SECCIONES_FT
(
    @VersionId INT,
    @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @VersionEtOrigenId INT;

    BEGIN TRY
        SELECT @VersionEtOrigenId=V.VersionEtOrigenId
        FROM dbo.VERSION V
        INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId=V.DocumentoId
        WHERE V.VersionId=@VersionId
          AND V.Estado=1
          AND D.Estado=1
          AND D.TipoDocumentoId=3;

        IF @VersionEtOrigenId IS NULL
            THROW 50001,'La versión indicada no corresponde a una FT activa o no tiene ET origen.',1;

        INSERT INTO dbo.VERSIONFTSECCION
        (
            VersionId,Codigo,Titulo,TipoContenido,Orden,Visible,EsSistema,Contenido,
            Estado,AudUsuarioCreacion,AudFechaCreacion
        )
        SELECT
              @VersionId
            , 'ET_SECCION_' + CONVERT(VARCHAR(20),VS.SeccionId)
            , S.SeccionDescripcion
            , CASE
                WHEN UPPER(LTRIM(RTRIM(S.SeccionDescripcion))) LIKE '%CARACTER%'
                    THEN 'CARACTERISTICAS'
                WHEN UPPER(ISNULL(TS.Descripcion,'')) LIKE '%LIST%'
                    THEN 'LISTA'
                WHEN UPPER(ISNULL(TS.Descripcion,'')) LIKE '%TABLA%'
                    THEN 'TABLA'
                WHEN UPPER(LTRIM(RTRIM(S.SeccionDescripcion))) LIKE '%ROTUL%'
                    THEN 'LISTA'
                ELSE 'TEXTO'
              END
            , ROW_NUMBER() OVER
              (
                  ORDER BY ISNULL(VS.Orden,2147483647),VS.VersSeccId
              )
            , 1
            , 1
            , VSC.Contenido
            , 1
            , @Usuario
            , SYSDATETIME()
        FROM dbo.VERSIONSECCION VS
        INNER JOIN dbo.SECCION S
          ON S.SeccionId=VS.SeccionId
         AND S.Estado=1
        LEFT JOIN dbo.TIPO_SECCION TS
          ON TS.IdTipoSeccion=S.IdTipoSeccion
        OUTER APPLY
        (
            SELECT TOP (1) C.Contenido
            FROM dbo.VERSIONSECCIONCONTENIDO C
            WHERE C.VersSeccId=VS.VersSeccId
              AND C.Estado=1
            ORDER BY C.VersionSeccionContenidoId DESC
        ) VSC
        WHERE VS.VersionId=@VersionEtOrigenId
          AND VS.Estado=1
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.VERSIONFTSECCION FTS
              WHERE FTS.VersionId=@VersionId
                AND FTS.Codigo='ET_SECCION_' + CONVERT(VARCHAR(20),VS.SeccionId)
                AND FTS.Estado=1
          );

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.VERSIONFTSECCION
            WHERE VersionId=@VersionId
              AND Estado=1
              AND TipoContenido='CARACTERISTICAS'
              AND Codigo<>'PROXIMAL'
        )
        BEGIN
            INSERT INTO dbo.VERSIONFTSECCION
            (
                VersionId,Codigo,Titulo,TipoContenido,Orden,Visible,EsSistema,Contenido,
                Estado,AudUsuarioCreacion,AudFechaCreacion
            )
            VALUES
            (
                @VersionId,'CARACTERISTICAS','Características','CARACTERISTICAS',
                (
                    SELECT ISNULL(MAX(Orden),0)+1
                    FROM dbo.VERSIONFTSECCION
                    WHERE VersionId=@VersionId AND Estado=1
                ),
                1,1,NULL,1,@Usuario,SYSDATETIME()
            );
        END;

        IF NOT EXISTS
        (
            SELECT 1 FROM dbo.VERSIONFTSECCION
            WHERE VersionId=@VersionId AND Codigo='DECLARACIONES' AND Estado=1
        )
        BEGIN
            INSERT INTO dbo.VERSIONFTSECCION
            (
                VersionId,Codigo,Titulo,TipoContenido,Orden,Visible,EsSistema,Contenido,
                Estado,AudUsuarioCreacion,AudFechaCreacion
            )
            VALUES
            (
                @VersionId,'DECLARACIONES','Declaraciones','LISTA',
                (SELECT ISNULL(MAX(Orden),0)+1 FROM dbo.VERSIONFTSECCION WHERE VersionId=@VersionId AND Estado=1),
                1,1,NULL,1,@Usuario,SYSDATETIME()
            );
        END;

        IF NOT EXISTS
        (
            SELECT 1 FROM dbo.VERSIONFTSECCION
            WHERE VersionId=@VersionId AND Codigo='ALERGENOS' AND Estado=1
        )
        BEGIN
            INSERT INTO dbo.VERSIONFTSECCION
            (
                VersionId,Codigo,Titulo,TipoContenido,Orden,Visible,EsSistema,Contenido,
                Estado,AudUsuarioCreacion,AudFechaCreacion
            )
            VALUES
            (
                @VersionId,'ALERGENOS','Alérgenos','TABLA',
                (SELECT ISNULL(MAX(Orden),0)+1 FROM dbo.VERSIONFTSECCION WHERE VersionId=@VersionId AND Estado=1),
                1,1,NULL,1,@Usuario,SYSDATETIME()
            );
        END;

        IF NOT EXISTS
        (
            SELECT 1 FROM dbo.VERSIONFTSECCION
            WHERE VersionId=@VersionId AND Codigo='PROXIMAL' AND Estado=1
        )
        BEGIN
            INSERT INTO dbo.VERSIONFTSECCION
            (
                VersionId,Codigo,Titulo,TipoContenido,Orden,Visible,EsSistema,Contenido,
                Estado,AudUsuarioCreacion,AudFechaCreacion
            )
            VALUES
            (
                @VersionId,'PROXIMAL','Proximal','CARACTERISTICAS',
                (SELECT ISNULL(MAX(Orden),0)+1 FROM dbo.VERSIONFTSECCION WHERE VersionId=@VersionId AND Estado=1),
                1,1,NULL,1,@Usuario,SYSDATETIME()
            );
        END;

        SELECT
              0 AS CodigoResultado
            , 'Secciones de la ET y complementos FT inicializados correctamente.' AS Mensaje
            , @VersionId AS VersionId
            , @VersionEtOrigenId AS VersionEtOrigenId
            , (
                SELECT COUNT(*)
                FROM dbo.VERSIONFTSECCION
                WHERE VersionId=@VersionId
                  AND Estado=1
              ) AS CantidadSecciones;
    END TRY
    BEGIN CATCH
        SELECT
              -1 AS CodigoResultado
            , ERROR_MESSAGE() AS Mensaje
            , @VersionId AS VersionId
            , @VersionEtOrigenId AS VersionEtOrigenId
            , 0 AS CantidadSecciones;
    END CATCH;
END;
GO

/* =========================================================
   8. DECLARACIONES
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_DECLARACIONES_FT
(
    @VersionId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
          VersionFtDeclaracionId
        , VersionId
        , Codigo
        , Titulo
        , Descripcion
        , Orden
        , Estado
    FROM dbo.VERSIONFTDECLARACION
    WHERE VersionId=@VersionId
      AND Estado=1
    ORDER BY Orden,VersionFtDeclaracionId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_GUARDAR_DECLARACIONES_FT
(
    @VersionId INT,
    @DeclaracionesJson VARCHAR(MAX),
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
            THROW 50001,'La versión indicada no corresponde a una Ficha Técnica activa.',1;

        IF ISJSON(@DeclaracionesJson)<>1
            THROW 50002,'Las declaraciones no tienen un formato válido.',1;

        DECLARE @Items TABLE
        (
            Codigo VARCHAR(60) NOT NULL,
            Titulo VARCHAR(250) NOT NULL,
            Descripcion VARCHAR(2000) NULL,
            Orden INT NOT NULL
        );

        INSERT INTO @Items(Codigo,Titulo,Descripcion,Orden)
        SELECT
              UPPER(NULLIF(LTRIM(RTRIM(Codigo)),''))
            , NULLIF(LTRIM(RTRIM(Titulo)),'')
            , NULLIF(LTRIM(RTRIM(Descripcion)),'')
            , Orden
        FROM OPENJSON(@DeclaracionesJson)
        WITH
        (
            Codigo VARCHAR(60) '$.codigo',
            Titulo VARCHAR(250) '$.titulo',
            Descripcion VARCHAR(2000) '$.descripcion',
            Orden INT '$.orden'
        )
        WHERE NULLIF(LTRIM(RTRIM(Codigo)),'') IS NOT NULL
          AND NULLIF(LTRIM(RTRIM(Titulo)),'') IS NOT NULL;

        IF EXISTS
        (
            SELECT Codigo
            FROM @Items
            GROUP BY Codigo
            HAVING COUNT(*)>1
        )
            THROW 50003,'No se puede repetir el código de una declaración dentro de la misma FT.',1;

        BEGIN TRANSACTION;

        UPDATE D
        SET
              Estado=0
            , AudUsuarioModificacion=@Usuario
            , AudFechaActualizacion=SYSDATETIME()
        FROM dbo.VERSIONFTDECLARACION D
        WHERE D.VersionId=@VersionId
          AND D.Estado=1
          AND NOT EXISTS(SELECT 1 FROM @Items I WHERE I.Codigo=D.Codigo);

        UPDATE D
        SET
              Titulo=I.Titulo
            , Descripcion=I.Descripcion
            , Orden=I.Orden
            , Estado=1
            , AudUsuarioModificacion=@Usuario
            , AudFechaActualizacion=SYSDATETIME()
        FROM dbo.VERSIONFTDECLARACION D
        INNER JOIN @Items I ON I.Codigo=D.Codigo
        WHERE D.VersionId=@VersionId;

        INSERT INTO dbo.VERSIONFTDECLARACION
        (
            VersionId,Codigo,Titulo,Descripcion,Orden,Estado,
            AudUsuarioCreacion,AudFechaCreacion
        )
        SELECT
              @VersionId,I.Codigo,I.Titulo,I.Descripcion,I.Orden,1,@Usuario,SYSDATETIME()
        FROM @Items I
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.VERSIONFTDECLARACION D
            WHERE D.VersionId=@VersionId
              AND D.Codigo=I.Codigo
        );

        COMMIT TRANSACTION;

        SELECT
              0 CodigoResultado
            , 'Declaraciones de la Ficha Técnica guardadas correctamente.' Mensaje
            , @VersionId VersionId
            , (SELECT COUNT(*) FROM @Items) Cantidad;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        SELECT -1 CodigoResultado,ERROR_MESSAGE() Mensaje,@VersionId VersionId,0 Cantidad;
    END CATCH;
END;
GO

/* =========================================================
   9. ALÉRGENOS
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_ALERGENOS_FT
(
    @VersionId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
          A.AlergenoId
        , A.AlergenoCodigo
        , A.AlergenoDescripcion
        , A.Orden
        , CONVERT(BIT,ISNULL(V.EnProducto,0)) AS EnProducto
        , CONVERT(BIT,ISNULL(V.EnLinea,0)) AS EnLinea
        , CONVERT(BIT,ISNULL(V.EnPlanta,0)) AS EnPlanta
        , V.Descripcion
    FROM dbo.ALERGENO A
    LEFT JOIN dbo.VERSIONFTALERGENO V
      ON V.AlergenoId=A.AlergenoId
     AND V.VersionId=@VersionId
     AND V.Estado=1
    WHERE A.Estado=1
    ORDER BY A.Orden,A.AlergenoId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_GUARDAR_ALERGENOS_FT
(
    @VersionId INT,
    @AlergenosJson VARCHAR(MAX),
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
            THROW 50001,'La versión indicada no corresponde a una Ficha Técnica activa.',1;

        IF ISJSON(@AlergenosJson)<>1
            THROW 50002,'Los alérgenos no tienen un formato válido.',1;

        DECLARE @Items TABLE
        (
            AlergenoId INT PRIMARY KEY,
            EnProducto BIT NOT NULL,
            EnLinea BIT NOT NULL,
            EnPlanta BIT NOT NULL,
            Descripcion VARCHAR(500) NULL,
            Orden INT NOT NULL
        );

        INSERT INTO @Items(AlergenoId,EnProducto,EnLinea,EnPlanta,Descripcion,Orden)
        SELECT
              AlergenoId
            , ISNULL(EnProducto,0)
            , ISNULL(EnLinea,0)
            , ISNULL(EnPlanta,0)
            , NULLIF(LTRIM(RTRIM(Descripcion)),'')
            , Orden
        FROM OPENJSON(@AlergenosJson)
        WITH
        (
            AlergenoId INT '$.alergenoId',
            EnProducto BIT '$.enProducto',
            EnLinea BIT '$.enLinea',
            EnPlanta BIT '$.enPlanta',
            Descripcion VARCHAR(500) '$.descripcion',
            Orden INT '$.orden'
        );

        IF EXISTS
        (
            SELECT 1
            FROM @Items I
            LEFT JOIN dbo.ALERGENO A
              ON A.AlergenoId=I.AlergenoId
             AND A.Estado=1
            WHERE A.AlergenoId IS NULL
        )
            THROW 50003,'Uno o más alérgenos no existen o están inactivos.',1;

        BEGIN TRANSACTION;

        UPDATE V
        SET
              EnProducto=I.EnProducto
            , EnLinea=I.EnLinea
            , EnPlanta=I.EnPlanta
            , Descripcion=I.Descripcion
            , Orden=I.Orden
            , Estado=1
            , AudUsuarioModificacion=@Usuario
            , AudFechaActualizacion=SYSDATETIME()
        FROM dbo.VERSIONFTALERGENO V
        INNER JOIN @Items I ON I.AlergenoId=V.AlergenoId
        WHERE V.VersionId=@VersionId;

        INSERT INTO dbo.VERSIONFTALERGENO
        (
            VersionId,AlergenoId,EnProducto,EnLinea,EnPlanta,Descripcion,Orden,Estado,
            AudUsuarioCreacion,AudFechaCreacion
        )
        SELECT
              @VersionId,I.AlergenoId,I.EnProducto,I.EnLinea,I.EnPlanta,I.Descripcion,I.Orden,1,
              @Usuario,SYSDATETIME()
        FROM @Items I
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.VERSIONFTALERGENO V
            WHERE V.VersionId=@VersionId
              AND V.AlergenoId=I.AlergenoId
        );

        COMMIT TRANSACTION;

        SELECT
              0 CodigoResultado
            , 'Alérgenos de la Ficha Técnica guardados correctamente.' Mensaje
            , @VersionId VersionId
            , (SELECT COUNT(*) FROM @Items) Cantidad;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        SELECT -1 CodigoResultado,ERROR_MESSAGE() Mensaje,@VersionId VersionId,0 Cantidad;
    END CATCH;
END;
GO

/* =========================================================
   10. GRUPOS DE CARACTERÍSTICAS: REFERENCIA / NOTA
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_GRUPOS_CARACTERISTICA_FT
(
    @VersionId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
          TC.TipoCaractId
        , TC.TipoCaractDescripcion
        , G.VersionFtCaracteristicaGrupoId
        , COALESCE(NULLIF(G.Titulo,''),TC.TipoCaractDescripcion) AS Titulo
        , G.Referencia
        , G.Nota
        , G.Orden
    FROM
    (
        SELECT DISTINCT C.TipoCaractId
        FROM dbo.VERSIONFTCARACTERISTICA VFC
        INNER JOIN dbo.CARACTERISTICA C ON C.CaracteristicaId=VFC.CaracteristicaId
        WHERE VFC.VersionId=@VersionId
          AND VFC.Estado=1
    ) X
    INNER JOIN dbo.TIPO_CARACTERISTICA TC
      ON TC.TipoCaractId=X.TipoCaractId
    LEFT JOIN dbo.VERSIONFTCARACTERISTICAGRUPO G
      ON G.VersionId=@VersionId
     AND G.TipoCaractId=TC.TipoCaractId
     AND G.Estado=1
    ORDER BY ISNULL(G.Orden,999999),TC.TipoCaractDescripcion;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_GUARDAR_GRUPO_CARACTERISTICA_FT
(
    @VersionId INT,
    @TipoCaractId INT,
    @Titulo VARCHAR(250)=NULL,
    @Referencia VARCHAR(2000)=NULL,
    @Nota VARCHAR(2000)=NULL,
    @Orden INT=NULL,
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
            THROW 50001,'La versión indicada no corresponde a una Ficha Técnica activa.',1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.TIPO_CARACTERISTICA
            WHERE TipoCaractId=@TipoCaractId
              AND Estado=1
        )
            THROW 50002,'El tipo de característica no existe o está inactivo.',1;

        SET @Titulo=NULLIF(LTRIM(RTRIM(@Titulo)),'');
        SET @Referencia=NULLIF(LTRIM(RTRIM(@Referencia)),'');
        SET @Nota=NULLIF(LTRIM(RTRIM(@Nota)),'');

        IF EXISTS
        (
            SELECT 1
            FROM dbo.VERSIONFTCARACTERISTICAGRUPO
            WHERE VersionId=@VersionId
              AND TipoCaractId=@TipoCaractId
        )
        BEGIN
            UPDATE dbo.VERSIONFTCARACTERISTICAGRUPO
            SET
                  Titulo=@Titulo
                , Referencia=@Referencia
                , Nota=@Nota
                , Orden=@Orden
                , Estado=1
                , AudUsuarioModificacion=@Usuario
                , AudFechaActualizacion=SYSDATETIME()
            WHERE VersionId=@VersionId
              AND TipoCaractId=@TipoCaractId;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.VERSIONFTCARACTERISTICAGRUPO
            (
                VersionId,TipoCaractId,Titulo,Referencia,Nota,Orden,Estado,
                AudUsuarioCreacion,AudFechaCreacion
            )
            VALUES
            (
                @VersionId,@TipoCaractId,@Titulo,@Referencia,@Nota,@Orden,1,
                @Usuario,SYSDATETIME()
            );
        END;

        SELECT
              0 CodigoResultado
            , 'Información del grupo FT guardada correctamente.' Mensaje
            , @VersionId VersionId
            , @TipoCaractId TipoCaractId;
    END TRY
    BEGIN CATCH
        SELECT -1 CodigoResultado,ERROR_MESSAGE() Mensaje,@VersionId VersionId,@TipoCaractId TipoCaractId;
    END CATCH;
END;
GO
