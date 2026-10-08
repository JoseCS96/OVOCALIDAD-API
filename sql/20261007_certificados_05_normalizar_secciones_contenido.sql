/*
 OVOCALIDAD 2.0 - Certificados
 Normalización del diseñador siguiendo el patrón ET/FT:

 CERTIFICADOSECCION
      -> CERTIFICADOPLANTILLASECCION
          -> CERTIFICADOPLANTILLASECCIONCONTENIDO

 La sección RESULTADOS tiene estructura especializada:
 CERTIFICADOPLANTILLASECCION
      -> CERTIFICADOPLANTILLARESULTADO (1..N bloques)
          -> CERTIFICADOPLANTILLARESULTADOCARACTERISTICA
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/* ============================================================
   1. CATÁLOGO DE SECCIONES
   ============================================================ */
IF OBJECT_ID('dbo.CERTIFICADOSECCION','U') IS NULL
BEGIN
    CREATE TABLE dbo.CERTIFICADOSECCION
    (
        CertificadoSeccionId INT IDENTITY(1,1) NOT NULL,
        Codigo VARCHAR(40) NOT NULL,
        Descripcion VARCHAR(200) NOT NULL,
        TipoContenido VARCHAR(40) NOT NULL,
        PuedeEliminarse BIT NOT NULL CONSTRAINT DF_CERTIFICADOSECCION_PuedeEliminarse DEFAULT(0),
        PermiteReordenar BIT NOT NULL CONSTRAINT DF_CERTIFICADOSECCION_PermiteReordenar DEFAULT(1),
        EsBase BIT NOT NULL CONSTRAINT DF_CERTIFICADOSECCION_EsBase DEFAULT(1),
        OrdenBase INT NULL,
        Estado BIT NOT NULL CONSTRAINT DF_CERTIFICADOSECCION_Estado DEFAULT(1),
        AudUsuarioCreacion VARCHAR(100) NOT NULL,
        AudFechaCreacion DATETIME2 NOT NULL CONSTRAINT DF_CERTIFICADOSECCION_AudFechaCreacion DEFAULT(SYSDATETIME()),
        AudUsuarioModificacion VARCHAR(100) NULL,
        AudFechaActualizacion DATETIME2 NULL,
        CONSTRAINT PK_CERTIFICADOSECCION PRIMARY KEY(CertificadoSeccionId),
        CONSTRAINT UQ_CERTIFICADOSECCION_Codigo UNIQUE(Codigo)
    );
END;
GO

DECLARE @Usuario VARCHAR(100)='MIGRACION_CERTIFICADO_NORMALIZADO';

MERGE dbo.CERTIFICADOSECCION AS T
USING
(
    VALUES
      ('ENCABEZADO',     'Título y subtítulo',             'CONFIGURACION',       0,1,1,1)
    , ('DATOS_EMPRESA',  'Datos de empresa',               'DINAMICO_EMPRESA',    0,1,1,2)
    , ('PRODUCTO',       'Ovoproducto',                     'DINAMICO_PRODUCTO',   0,1,1,3)
    , ('DATOS_LOTE',     'Datos del lote',                  'DINAMICO_LOTE',       0,1,1,4)
    , ('RESULTADOS',     'Resultados y evaluaciones',       'RESULTADOS',          0,1,1,5)
    , ('ALMACENAMIENTO', 'Condición y almacenamiento',      'DINAMICO_FT',         0,1,1,6)
    , ('REFERENCIAS',    'Referencias',                     'DINAMICO_RESULTADOS', 0,1,1,7)
    , ('FIRMA',          'Firmas y fecha',                  'DINAMICO_EMISION',    0,1,1,8)
    , ('PIE',            'Pie de página',                   'TEXTO',               1,1,0,9)
) AS S(Codigo,Descripcion,TipoContenido,PuedeEliminarse,PermiteReordenar,EsBase,OrdenBase)
ON T.Codigo=S.Codigo
WHEN MATCHED THEN
    UPDATE SET
        T.Descripcion=S.Descripcion,
        T.TipoContenido=S.TipoContenido,
        T.PuedeEliminarse=S.PuedeEliminarse,
        T.PermiteReordenar=S.PermiteReordenar,
        T.EsBase=S.EsBase,
        T.OrdenBase=S.OrdenBase,
        T.Estado=1,
        T.AudUsuarioModificacion=@Usuario,
        T.AudFechaActualizacion=SYSDATETIME()
WHEN NOT MATCHED THEN
    INSERT(Codigo,Descripcion,TipoContenido,PuedeEliminarse,PermiteReordenar,EsBase,OrdenBase,Estado,AudUsuarioCreacion,AudFechaCreacion)
    VALUES(S.Codigo,S.Descripcion,S.TipoContenido,S.PuedeEliminarse,S.PermiteReordenar,S.EsBase,S.OrdenBase,1,@Usuario,SYSDATETIME());
GO

/* ============================================================
   2. RELACIÓN PLANTILLA - SECCIÓN
   Se conserva TipoSeccion/Titulo/etc. como columnas legacy,
   pero la fuente de verdad pasa a ser CertificadoSeccionId.
   ============================================================ */
IF COL_LENGTH('dbo.CERTIFICADOPLANTILLASECCION','CertificadoSeccionId') IS NULL
BEGIN
    ALTER TABLE dbo.CERTIFICADOPLANTILLASECCION
    ADD CertificadoSeccionId INT NULL;
END;
GO

UPDATE CPS
SET CPS.CertificadoSeccionId=CS.CertificadoSeccionId
FROM dbo.CERTIFICADOPLANTILLASECCION CPS
INNER JOIN dbo.CERTIFICADOSECCION CS
    ON CS.Codigo=CPS.TipoSeccion
WHERE CPS.CertificadoSeccionId IS NULL;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE name='FK_CERTIFICADOPLANTILLASECCION_CERTIFICADOSECCION'
)
BEGIN
    ALTER TABLE dbo.CERTIFICADOPLANTILLASECCION
    ADD CONSTRAINT FK_CERTIFICADOPLANTILLASECCION_CERTIFICADOSECCION
        FOREIGN KEY(CertificadoSeccionId)
        REFERENCES dbo.CERTIFICADOSECCION(CertificadoSeccionId);
END;
GO

/* ============================================================
   3. CONTENIDO / VALOR DE SECCIÓN
   ============================================================ */
IF OBJECT_ID('dbo.CERTIFICADOPLANTILLASECCIONCONTENIDO','U') IS NULL
BEGIN
    CREATE TABLE dbo.CERTIFICADOPLANTILLASECCIONCONTENIDO
    (
        CertificadoPlantillaSeccionContenidoId INT IDENTITY(1,1) NOT NULL,
        CertificadoPlantillaSeccionId INT NOT NULL,
        Contenido VARCHAR(MAX) NULL,
        Estado BIT NOT NULL CONSTRAINT DF_CPSC_Estado DEFAULT(1),
        AudUsuarioCreacion VARCHAR(100) NOT NULL,
        AudFechaCreacion DATETIME2 NOT NULL CONSTRAINT DF_CPSC_AudFechaCreacion DEFAULT(SYSDATETIME()),
        AudUsuarioModificacion VARCHAR(100) NULL,
        AudFechaActualizacion DATETIME2 NULL,
        CONSTRAINT PK_CERTIFICADOPLANTILLASECCIONCONTENIDO PRIMARY KEY(CertificadoPlantillaSeccionContenidoId),
        CONSTRAINT FK_CPSC_SECCION FOREIGN KEY(CertificadoPlantillaSeccionId)
            REFERENCES dbo.CERTIFICADOPLANTILLASECCION(CertificadoPlantillaSeccionId)
    );

    CREATE INDEX IX_CPSC_SECCION
        ON dbo.CERTIFICADOPLANTILLASECCIONCONTENIDO(CertificadoPlantillaSeccionId,Estado);
END;
GO

/* Migrar valores actuales de encabezado / pie */
INSERT INTO dbo.CERTIFICADOPLANTILLASECCIONCONTENIDO
(
    CertificadoPlantillaSeccionId,Contenido,Estado,
    AudUsuarioCreacion,AudFechaCreacion
)
SELECT
    CPS.CertificadoPlantillaSeccionId,
    CASE CS.Codigo
        WHEN 'ENCABEZADO' THEN
            (
                SELECT
                    COALESCE(NULLIF(LTRIM(RTRIM(CPS.Titulo)),''),'ASEGURAMIENTO DE LA CALIDAD') AS titulo,
                    COALESCE(NULLIF(LTRIM(RTRIM(CPS.Contenido)),''),'CERTIFICADO DE ANÁLISIS') AS subtitulo
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            )
        WHEN 'PIE' THEN
            (
                SELECT CPS.Contenido AS texto
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            )
    END,
    1,
    'MIGRACION_CERTIFICADO_NORMALIZADO',
    SYSDATETIME()
FROM dbo.CERTIFICADOPLANTILLASECCION CPS
INNER JOIN dbo.CERTIFICADOSECCION CS
    ON CS.CertificadoSeccionId=CPS.CertificadoSeccionId
WHERE CPS.Estado=1
  AND CS.Codigo IN('ENCABEZADO','PIE')
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.CERTIFICADOPLANTILLASECCIONCONTENIDO C
      WHERE C.CertificadoPlantillaSeccionId=CPS.CertificadoPlantillaSeccionId
        AND C.Estado=1
  );
GO

/* ============================================================
   4. BLOQUES DE RESULTADOS
   ============================================================ */
IF OBJECT_ID('dbo.CERTIFICADOPLANTILLARESULTADO','U') IS NULL
BEGIN
    CREATE TABLE dbo.CERTIFICADOPLANTILLARESULTADO
    (
        CertificadoPlantillaResultadoId INT IDENTITY(1,1) NOT NULL,
        CertificadoPlantillaSeccionId INT NOT NULL,
        Titulo VARCHAR(200) NOT NULL,
        Orden INT NOT NULL,
        Visible BIT NOT NULL CONSTRAINT DF_CPR_Visible DEFAULT(1),
        ModoSeleccion VARCHAR(20) NOT NULL CONSTRAINT DF_CPR_Modo DEFAULT('MANUAL'),
        VersionFaseId INT NULL,
        TipoCaractId INT NULL,
        Estado BIT NOT NULL CONSTRAINT DF_CPR_Estado DEFAULT(1),
        AudUsuarioCreacion VARCHAR(100) NOT NULL,
        AudFechaCreacion DATETIME2 NOT NULL CONSTRAINT DF_CPR_AudFechaCreacion DEFAULT(SYSDATETIME()),
        AudUsuarioModificacion VARCHAR(100) NULL,
        AudFechaActualizacion DATETIME2 NULL,
        CONSTRAINT PK_CERTIFICADOPLANTILLARESULTADO PRIMARY KEY(CertificadoPlantillaResultadoId),
        CONSTRAINT FK_CPR_SECCION FOREIGN KEY(CertificadoPlantillaSeccionId)
            REFERENCES dbo.CERTIFICADOPLANTILLASECCION(CertificadoPlantillaSeccionId),
        CONSTRAINT FK_CPR_VERSIONFASE FOREIGN KEY(VersionFaseId)
            REFERENCES dbo.VERSIONFASE(VersionFaseId),
        CONSTRAINT FK_CPR_TIPOCARACT FOREIGN KEY(TipoCaractId)
            REFERENCES dbo.TIPO_CARACTERISTICA(TipoCaractId),
        CONSTRAINT CK_CPR_ORDEN CHECK(Orden>0),
        CONSTRAINT CK_CPR_MODO CHECK(ModoSeleccion IN('MANUAL','TIPO','FASE','TIPO_FASE'))
    );

    CREATE UNIQUE INDEX UX_CPR_ORDEN
        ON dbo.CERTIFICADOPLANTILLARESULTADO(CertificadoPlantillaSeccionId,Orden)
        WHERE Estado=1;
END;
GO

IF OBJECT_ID('dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA','U') IS NULL
BEGIN
    CREATE TABLE dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA
    (
        CertificadoPlantillaResultadoCaracteristicaId INT IDENTITY(1,1) NOT NULL,
        CertificadoPlantillaResultadoId INT NOT NULL,
        VersionFtCaracteristicaId INT NOT NULL,
        Orden INT NOT NULL,
        Estado BIT NOT NULL CONSTRAINT DF_CPRC_Estado DEFAULT(1),
        AudUsuarioCreacion VARCHAR(100) NOT NULL,
        AudFechaCreacion DATETIME2 NOT NULL CONSTRAINT DF_CPRC_AudFechaCreacion DEFAULT(SYSDATETIME()),
        AudUsuarioModificacion VARCHAR(100) NULL,
        AudFechaActualizacion DATETIME2 NULL,
        CONSTRAINT PK_CERTIFICADOPLANTILLARESULTADOCARACTERISTICA PRIMARY KEY(CertificadoPlantillaResultadoCaracteristicaId),
        CONSTRAINT FK_CPRC_RESULTADO FOREIGN KEY(CertificadoPlantillaResultadoId)
            REFERENCES dbo.CERTIFICADOPLANTILLARESULTADO(CertificadoPlantillaResultadoId),
        CONSTRAINT FK_CPRC_FT FOREIGN KEY(VersionFtCaracteristicaId)
            REFERENCES dbo.VERSIONFTCARACTERISTICA(VersionFtCaracteristicaId),
        CONSTRAINT CK_CPRC_ORDEN CHECK(Orden>0)
    );

    CREATE UNIQUE INDEX UX_CPRC_CARACTERISTICA
        ON dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA
           (CertificadoPlantillaResultadoId,VersionFtCaracteristicaId)
        WHERE Estado=1;
END;
GO

/* ============================================================
   5. MIGRAR RESULTADOS LEGACY AL NUEVO MODELO
   ============================================================ */
IF OBJECT_ID('tempdb..#MapaResultado') IS NOT NULL DROP TABLE #MapaResultado;
CREATE TABLE #MapaResultado
(
    SeccionLegacyId INT NOT NULL PRIMARY KEY,
    ResultadoId INT NOT NULL
);

DECLARE
      @SeccionLegacyId INT
    , @PlantillaId INT
    , @SeccionResultadoId INT
    , @Titulo VARCHAR(200)
    , @Modo VARCHAR(20)
    , @VersionFaseId INT
    , @TipoCaractId INT
    , @OrdenResultado INT
    , @NuevoResultadoId INT;

DECLARE cur_resultados CURSOR LOCAL FAST_FORWARD FOR
SELECT
      CPS.CertificadoPlantillaSeccionId
    , CPS.CertificadoPlantillaId
    , COALESCE(NULLIF(LTRIM(RTRIM(CPS.Titulo)),''),'Informe de ensayo')
    , COALESCE(NULLIF(CPS.ModoSeleccion,''),'MANUAL')
    , CPS.VersionFaseId
    , CPS.TipoCaractId
FROM dbo.CERTIFICADOPLANTILLASECCION CPS
INNER JOIN dbo.CERTIFICADOSECCION CS
    ON CS.CertificadoSeccionId=CPS.CertificadoSeccionId
WHERE CPS.Estado=1
  AND CS.Codigo='RESULTADOS'
ORDER BY CPS.CertificadoPlantillaId,CPS.Orden,CPS.CertificadoPlantillaSeccionId;

OPEN cur_resultados;
FETCH NEXT FROM cur_resultados INTO
    @SeccionLegacyId,@PlantillaId,@Titulo,@Modo,@VersionFaseId,@TipoCaractId;

WHILE @@FETCH_STATUS=0
BEGIN
    SELECT TOP(1)
        @SeccionResultadoId=CPS.CertificadoPlantillaSeccionId
    FROM dbo.CERTIFICADOPLANTILLASECCION CPS
    INNER JOIN dbo.CERTIFICADOSECCION CS
        ON CS.CertificadoSeccionId=CPS.CertificadoSeccionId
    WHERE CPS.CertificadoPlantillaId=@PlantillaId
      AND CPS.Estado=1
      AND CS.Codigo='RESULTADOS'
    ORDER BY CPS.Orden,CPS.CertificadoPlantillaSeccionId;

    SELECT @OrdenResultado=ISNULL(MAX(Orden),0)+1
    FROM dbo.CERTIFICADOPLANTILLARESULTADO
    WHERE CertificadoPlantillaSeccionId=@SeccionResultadoId
      AND Estado=1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.CERTIFICADOPLANTILLARESULTADO
        WHERE CertificadoPlantillaSeccionId=@SeccionResultadoId
          AND Titulo=@Titulo
          AND Orden=@OrdenResultado
          AND Estado=1
    )
    BEGIN
        INSERT INTO dbo.CERTIFICADOPLANTILLARESULTADO
        (
            CertificadoPlantillaSeccionId,Titulo,Orden,Visible,
            ModoSeleccion,VersionFaseId,TipoCaractId,Estado,
            AudUsuarioCreacion,AudFechaCreacion
        )
        VALUES
        (
            @SeccionResultadoId,@Titulo,@OrdenResultado,1,
            @Modo,@VersionFaseId,@TipoCaractId,1,
            'MIGRACION_CERTIFICADO_NORMALIZADO',SYSDATETIME()
        );

        SET @NuevoResultadoId=CONVERT(INT,SCOPE_IDENTITY());

        INSERT INTO #MapaResultado(SeccionLegacyId,ResultadoId)
        VALUES(@SeccionLegacyId,@NuevoResultadoId);
    END;

    FETCH NEXT FROM cur_resultados INTO
        @SeccionLegacyId,@PlantillaId,@Titulo,@Modo,@VersionFaseId,@TipoCaractId;
END;

CLOSE cur_resultados;
DEALLOCATE cur_resultados;

INSERT INTO dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA
(
    CertificadoPlantillaResultadoId,VersionFtCaracteristicaId,Orden,Estado,
    AudUsuarioCreacion,AudFechaCreacion
)
SELECT
    M.ResultadoId,
    C.VersionFtCaracteristicaId,
    C.Orden,
    1,
    'MIGRACION_CERTIFICADO_NORMALIZADO',
    SYSDATETIME()
FROM dbo.CERTIFICADOPLANTILLACARACTERISTICA C
INNER JOIN #MapaResultado M
    ON M.SeccionLegacyId=C.CertificadoPlantillaSeccionId
WHERE C.Estado=1
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA N
      WHERE N.CertificadoPlantillaResultadoId=M.ResultadoId
        AND N.VersionFtCaracteristicaId=C.VersionFtCaracteristicaId
        AND N.Estado=1
  );
GO

/* Dejar una sola sección RESULTADOS activa por plantilla */
;WITH R AS
(
    SELECT
        CPS.CertificadoPlantillaSeccionId,
        ROW_NUMBER() OVER
        (
            PARTITION BY CPS.CertificadoPlantillaId
            ORDER BY CPS.Orden,CPS.CertificadoPlantillaSeccionId
        ) RN
    FROM dbo.CERTIFICADOPLANTILLASECCION CPS
    INNER JOIN dbo.CERTIFICADOSECCION CS
        ON CS.CertificadoSeccionId=CPS.CertificadoSeccionId
    WHERE CPS.Estado=1
      AND CS.Codigo='RESULTADOS'
)
UPDATE CPS
SET
    CPS.Estado=0,
    CPS.AudUsuarioModificacion='MIGRACION_CERTIFICADO_NORMALIZADO',
    CPS.AudFechaActualizacion=SYSDATETIME()
FROM dbo.CERTIFICADOPLANTILLASECCION CPS
INNER JOIN R
    ON R.CertificadoPlantillaSeccionId=CPS.CertificadoPlantillaSeccionId
WHERE R.RN>1;
GO

/* ============================================================
   6. CREAR PLANTILLA CON SECCIONES BASE
   ============================================================ */
CREATE OR ALTER PROCEDURE dbo.SP_CREAR_PLANTILLA_CERTIFICADO
(
      @VersionFtId INT
    , @Nombre VARCHAR(200)
    , @Descripcion VARCHAR(1000)=NULL
    , @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @Nombre=NULLIF(LTRIM(RTRIM(@Nombre)),'');
    SET @Descripcion=NULLIF(LTRIM(RTRIM(@Descripcion)),'');
    SET @Usuario=NULLIF(LTRIM(RTRIM(@Usuario)),'');

    IF @Nombre IS NULL
        THROW 50001,'Debe indicar el nombre de la plantilla.',1;

    IF @Usuario IS NULL
        THROW 50002,'El usuario es obligatorio.',1;

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
        THROW 50003,'La versión indicada no corresponde a una Ficha Técnica activa.',1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.VERSIONFTCARACTERISTICA
        WHERE VersionId=@VersionFtId
          AND Estado=1
          AND ImprimeCertificado=1
    )
        THROW 50004,'La Ficha Técnica no tiene parámetros habilitados para certificado.',1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.CERTIFICADOPLANTILLA
        WHERE VersionFtId=@VersionFtId
          AND Nombre=@Nombre
          AND Estado=1
    )
        THROW 50005,'Ya existe una plantilla activa con ese nombre para la Ficha Técnica.',1;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.CERTIFICADOPLANTILLA
        (
            VersionFtId,Nombre,Descripcion,Estado,
            AudUsuarioCreacion,AudFechaCreacion
        )
        VALUES
        (
            @VersionFtId,@Nombre,@Descripcion,1,
            @Usuario,SYSDATETIME()
        );

        DECLARE @CertificadoPlantillaId INT=CONVERT(INT,SCOPE_IDENTITY());

        INSERT INTO dbo.CERTIFICADOPLANTILLASECCION
        (
            CertificadoPlantillaId,CertificadoSeccionId,
            TipoSeccion,Titulo,Contenido,Orden,Visible,
            ModoSeleccion,VersionFaseId,TipoCaractId,
            Estado,AudUsuarioCreacion,AudFechaCreacion
        )
        SELECT
            @CertificadoPlantillaId,
            CS.CertificadoSeccionId,
            CS.Codigo,
            CS.Descripcion,
            NULL,
            CS.OrdenBase,
            1,
            'MANUAL',
            NULL,
            NULL,
            1,
            @Usuario,
            SYSDATETIME()
        FROM dbo.CERTIFICADOSECCION CS
        WHERE CS.Estado=1
          AND CS.EsBase=1
        ORDER BY CS.OrdenBase;

        DECLARE @SeccionEncabezadoId INT;

        SELECT @SeccionEncabezadoId=CPS.CertificadoPlantillaSeccionId
        FROM dbo.CERTIFICADOPLANTILLASECCION CPS
        INNER JOIN dbo.CERTIFICADOSECCION CS
            ON CS.CertificadoSeccionId=CPS.CertificadoSeccionId
        WHERE CPS.CertificadoPlantillaId=@CertificadoPlantillaId
          AND CPS.Estado=1
          AND CS.Codigo='ENCABEZADO';

        INSERT INTO dbo.CERTIFICADOPLANTILLASECCIONCONTENIDO
        (
            CertificadoPlantillaSeccionId,Contenido,Estado,
            AudUsuarioCreacion,AudFechaCreacion
        )
        VALUES
        (
            @SeccionEncabezadoId,
            '{"titulo":"ASEGURAMIENTO DE LA CALIDAD","subtitulo":"CERTIFICADO DE ANÁLISIS"}',
            1,@Usuario,SYSDATETIME()
        );

        COMMIT TRANSACTION;

        SELECT
            0 CodigoResultado,
            'Plantilla de certificado creada correctamente.' Mensaje,
            @CertificadoPlantillaId CertificadoPlantillaId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/* ============================================================
   7. OBTENER PLANTILLA NORMALIZADA
   RS1 cabecera
   RS2 secciones
   RS3 bloques de resultados
   RS4 características
   ============================================================ */
CREATE OR ALTER PROCEDURE dbo.SP_OBTENER_PLANTILLA_CERTIFICADO
(
    @CertificadoPlantillaId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.CERTIFICADOPLANTILLA
        WHERE CertificadoPlantillaId=@CertificadoPlantillaId
          AND Estado=1
    )
        THROW 50001,'La plantilla de certificado no existe o está inactiva.',1;

    SELECT
          CP.CertificadoPlantillaId
        , CP.VersionFtId
        , CP.Nombre
        , CP.Descripcion
        , D.DocumentoCodigo
        , D.DocumentoDescripcionDocumento
        , D.ProductoCodigo
        , V.VersionNumero
        , V.EstVerId
        , EV.EstVerDescripcion EstadoVersionFt
    FROM dbo.CERTIFICADOPLANTILLA CP
    INNER JOIN dbo.VERSION V ON V.VersionId=CP.VersionFtId
    INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId=V.DocumentoId
    INNER JOIN dbo.ESTADOVERSION EV ON EV.EstVerId=V.EstVerId
    WHERE CP.CertificadoPlantillaId=@CertificadoPlantillaId
      AND CP.Estado=1;

    SELECT
          CPS.CertificadoPlantillaSeccionId
        , CPS.CertificadoPlantillaId
        , CS.CertificadoSeccionId
        , CS.Codigo SeccionCodigo
        , CS.Descripcion SeccionDescripcion
        , CS.TipoContenido
        , CS.PuedeEliminarse
        , CS.PermiteReordenar
        , CPS.Orden
        , CPS.Visible
        , C.Contenido
    FROM dbo.CERTIFICADOPLANTILLASECCION CPS
    INNER JOIN dbo.CERTIFICADOSECCION CS
        ON CS.CertificadoSeccionId=CPS.CertificadoSeccionId
    OUTER APPLY
    (
        SELECT TOP(1) X.Contenido
        FROM dbo.CERTIFICADOPLANTILLASECCIONCONTENIDO X
        WHERE X.CertificadoPlantillaSeccionId=CPS.CertificadoPlantillaSeccionId
          AND X.Estado=1
        ORDER BY X.CertificadoPlantillaSeccionContenidoId DESC
    ) C
    WHERE CPS.CertificadoPlantillaId=@CertificadoPlantillaId
      AND CPS.Estado=1
      AND CS.Estado=1
    ORDER BY CPS.Orden;

    SELECT
          R.CertificadoPlantillaResultadoId
        , R.CertificadoPlantillaSeccionId
        , R.Titulo
        , R.Orden
        , R.Visible
        , R.ModoSeleccion
        , R.VersionFaseId
        , VF.FaseId
        , VF.CodigoReferencia FaseCodigo
        , COALESCE(NULLIF(LTRIM(RTRIM(VF.Descripcion)),''),VF.CodigoReferencia) FaseDescripcion
        , R.TipoCaractId
        , TC.TipoCaractDescripcion
    FROM dbo.CERTIFICADOPLANTILLARESULTADO R
    LEFT JOIN dbo.VERSIONFASE VF
        ON VF.VersionFaseId=R.VersionFaseId
       AND VF.Estado=1
    LEFT JOIN dbo.TIPO_CARACTERISTICA TC
        ON TC.TipoCaractId=R.TipoCaractId
    INNER JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
        ON CPS.CertificadoPlantillaSeccionId=R.CertificadoPlantillaSeccionId
    WHERE CPS.CertificadoPlantillaId=@CertificadoPlantillaId
      AND CPS.Estado=1
      AND R.Estado=1
    ORDER BY R.Orden;

    SELECT
          RC.CertificadoPlantillaResultadoCaracteristicaId
        , RC.CertificadoPlantillaResultadoId
        , RC.VersionFtCaracteristicaId
        , VFC.CaracteristicaId
        , C.CaracteristicaDescripcion Determinacion
        , C.TipoCaractId
        , TC.TipoCaractDescripcion
        , VFC.FaseId
        , VFC.VersionFaseId
        , VF.CodigoReferencia FaseCodigo
        , COALESCE(NULLIF(LTRIM(RTRIM(VF.Descripcion)),''),VF.CodigoReferencia) FaseDescripcion
        , VFC.TipoCriterioId
        , VFC.ValorCuantitativoInicial
        , VFC.ValorCuantitativoFinal
        , VFC.ValorCuantitativoIgual
        , VFC.ValorCualitativo
        , VFC.UnidadDeMedida
        , ME.MetEnsayoDescripcion
        , VFC.ObligatorioCertificado
        , RC.Orden
    FROM dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA RC
    INNER JOIN dbo.CERTIFICADOPLANTILLARESULTADO R
        ON R.CertificadoPlantillaResultadoId=RC.CertificadoPlantillaResultadoId
    INNER JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
        ON CPS.CertificadoPlantillaSeccionId=R.CertificadoPlantillaSeccionId
    INNER JOIN dbo.VERSIONFTCARACTERISTICA VFC
        ON VFC.VersionFtCaracteristicaId=RC.VersionFtCaracteristicaId
    INNER JOIN dbo.CARACTERISTICA C
        ON C.CaracteristicaId=VFC.CaracteristicaId
    LEFT JOIN dbo.TIPO_CARACTERISTICA TC
        ON TC.TipoCaractId=C.TipoCaractId
    LEFT JOIN dbo.VERSIONFASE VF
        ON VF.VersionFaseId=VFC.VersionFaseId
       AND VF.Estado=1
    LEFT JOIN dbo.METODO_DE_ENSAYO ME
        ON ME.MetEnsayoId=C.MetEnsayoId
    WHERE CPS.CertificadoPlantillaId=@CertificadoPlantillaId
      AND CPS.Estado=1
      AND R.Estado=1
      AND RC.Estado=1
    ORDER BY R.Orden,RC.Orden;
END;
GO

/* ============================================================
   8. LISTAR PLANTILLAS USANDO EL MODELO NORMALIZADO
   ============================================================ */
CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_PLANTILLAS_CERTIFICADO
(
    @VersionFtId INT=NULL,
    @ProductoCodigo VARCHAR(50)=NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
          CP.CertificadoPlantillaId
        , CP.VersionFtId
        , CP.Nombre
        , CP.Descripcion
        , D.DocumentoId
        , D.DocumentoCodigo
        , D.DocumentoDescripcionDocumento
        , D.ProductoCodigo
        , V.VersionNumero
        , V.EstVerId
        , CP.AudUsuarioCreacion
        , CP.AudFechaCreacion
        , COUNT(DISTINCT CASE WHEN CPS.Estado=1 THEN CPS.CertificadoPlantillaSeccionId END) CantidadSecciones
        , COUNT(DISTINCT CASE WHEN RC.Estado=1 THEN RC.CertificadoPlantillaResultadoCaracteristicaId END) CantidadCaracteristicas
    FROM dbo.CERTIFICADOPLANTILLA CP
    INNER JOIN dbo.VERSION V
        ON V.VersionId=CP.VersionFtId
    INNER JOIN dbo.DOCUMENTO D
        ON D.DocumentoId=V.DocumentoId
    LEFT JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
        ON CPS.CertificadoPlantillaId=CP.CertificadoPlantillaId
       AND CPS.Estado=1
    LEFT JOIN dbo.CERTIFICADOPLANTILLARESULTADO R
        ON R.CertificadoPlantillaSeccionId=CPS.CertificadoPlantillaSeccionId
       AND R.Estado=1
    LEFT JOIN dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA RC
        ON RC.CertificadoPlantillaResultadoId=R.CertificadoPlantillaResultadoId
       AND RC.Estado=1
    WHERE CP.Estado=1
      AND (@VersionFtId IS NULL OR CP.VersionFtId=@VersionFtId)
      AND (@ProductoCodigo IS NULL OR D.ProductoCodigo=@ProductoCodigo)
    GROUP BY
          CP.CertificadoPlantillaId
        , CP.VersionFtId
        , CP.Nombre
        , CP.Descripcion
        , D.DocumentoId
        , D.DocumentoCodigo
        , D.DocumentoDescripcionDocumento
        , D.ProductoCodigo
        , V.VersionNumero
        , V.EstVerId
        , CP.AudUsuarioCreacion
        , CP.AudFechaCreacion
    ORDER BY D.ProductoCodigo,CP.Nombre;
END;
GO

/* ============================================================
   9. GUARDAR DISEÑO NORMALIZADO
   ============================================================ */
CREATE OR ALTER PROCEDURE dbo.SP_GUARDAR_DISENO_PLANTILLA_CERTIFICADO
(
      @CertificadoPlantillaId INT
    , @SeccionesJson NVARCHAR(MAX)
    , @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF ISJSON(@SeccionesJson)<>1
        THROW 50001,'El diseño de secciones no tiene un formato JSON válido.',1;

    DECLARE @VersionFtId INT;

    SELECT @VersionFtId=VersionFtId
    FROM dbo.CERTIFICADOPLANTILLA
    WHERE CertificadoPlantillaId=@CertificadoPlantillaId
      AND Estado=1;

    IF @VersionFtId IS NULL
        THROW 50002,'La plantilla de certificado no existe o está inactiva.',1;

    DECLARE @Secciones TABLE
    (
        Fila INT IDENTITY(1,1) NOT NULL,
        CertificadoSeccionId INT NULL,
        Orden INT NULL,
        Visible BIT NULL,
        Contenido VARCHAR(MAX) NULL,
        ResultadosJson NVARCHAR(MAX) NULL
    );

    INSERT INTO @Secciones
    (
        CertificadoSeccionId,Orden,Visible,Contenido,ResultadosJson
    )
    SELECT
        CertificadoSeccionId,
        Orden,
        ISNULL(Visible,1),
        Contenido,
        Resultados
    FROM OPENJSON(@SeccionesJson)
    WITH
    (
        CertificadoSeccionId INT '$.certificadoSeccionId',
        Orden INT '$.orden',
        Visible BIT '$.visible',
        Contenido VARCHAR(MAX) '$.contenido',
        Resultados NVARCHAR(MAX) '$.resultados' AS JSON
    );

    IF NOT EXISTS(SELECT 1 FROM @Secciones)
        THROW 50003,'Debe configurar al menos una sección.',1;

    IF EXISTS
    (
        SELECT 1
        FROM @Secciones S
        LEFT JOIN dbo.CERTIFICADOSECCION CS
            ON CS.CertificadoSeccionId=S.CertificadoSeccionId
           AND CS.Estado=1
        WHERE CS.CertificadoSeccionId IS NULL
           OR S.Orden IS NULL
           OR S.Orden<=0
    )
        THROW 50004,'Existe una sección u orden no válido.',1;

    IF EXISTS
    (
        SELECT CertificadoSeccionId
        FROM @Secciones
        GROUP BY CertificadoSeccionId
        HAVING COUNT(*)>1
    )
        THROW 50005,'Una sección del certificado no puede repetirse.',1;

    IF EXISTS
    (
        SELECT Orden
        FROM @Secciones
        GROUP BY Orden
        HAVING COUNT(*)>1
    )
        THROW 50006,'No pueden existir dos secciones con el mismo orden.',1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.CERTIFICADOSECCION CS
        WHERE CS.Estado=1
          AND CS.PuedeEliminarse=0
          AND NOT EXISTS
          (
              SELECT 1
              FROM @Secciones S
              WHERE S.CertificadoSeccionId=CS.CertificadoSeccionId
          )
    )
        THROW 50007,'No se puede retirar una sección obligatoria de la plantilla.',1;

    DECLARE @Resultados TABLE
    (
        FilaSeccion INT NOT NULL,
        FilaResultado INT NOT NULL,
        Titulo VARCHAR(200) NULL,
        Orden INT NULL,
        Visible BIT NULL,
        ModoSeleccion VARCHAR(20) NULL,
        VersionFaseId INT NULL,
        TipoCaractId INT NULL,
        CaracteristicasJson NVARCHAR(MAX) NULL,
        PRIMARY KEY(FilaSeccion,FilaResultado)
    );

    INSERT INTO @Resultados
    (
        FilaSeccion,FilaResultado,Titulo,Orden,Visible,
        ModoSeleccion,VersionFaseId,TipoCaractId,CaracteristicasJson
    )
    SELECT
        S.Fila,
        TRY_CONVERT(INT,J.[key])+1,
        X.Titulo,
        X.Orden,
        ISNULL(X.Visible,1),
        ISNULL(NULLIF(UPPER(LTRIM(RTRIM(X.ModoSeleccion))),''),'MANUAL'),
        X.VersionFaseId,
        X.TipoCaractId,
        X.Caracteristicas
    FROM @Secciones S
    INNER JOIN dbo.CERTIFICADOSECCION CS
        ON CS.CertificadoSeccionId=S.CertificadoSeccionId
    CROSS APPLY OPENJSON(S.ResultadosJson) J
    CROSS APPLY OPENJSON(J.[value])
    WITH
    (
        Titulo VARCHAR(200) '$.titulo',
        Orden INT '$.orden',
        Visible BIT '$.visible',
        ModoSeleccion VARCHAR(20) '$.modoSeleccion',
        VersionFaseId INT '$.versionFaseId',
        TipoCaractId INT '$.tipoCaractId',
        Caracteristicas NVARCHAR(MAX) '$.caracteristicas' AS JSON
    ) X
    WHERE CS.Codigo='RESULTADOS'
      AND S.ResultadosJson IS NOT NULL;

    IF EXISTS
    (
        SELECT 1
        FROM @Resultados
        WHERE Orden IS NULL OR Orden<=0
           OR NULLIF(LTRIM(RTRIM(Titulo)),'') IS NULL
           OR ModoSeleccion NOT IN('MANUAL','TIPO','FASE','TIPO_FASE')
    )
        THROW 50008,'Existe un bloque de resultados con configuración inválida.',1;

    IF EXISTS
    (
        SELECT FilaSeccion,Orden
        FROM @Resultados
        GROUP BY FilaSeccion,Orden
        HAVING COUNT(*)>1
    )
        THROW 50009,'No pueden existir dos bloques de resultados con el mismo orden.',1;

    IF EXISTS
    (
        SELECT 1
        FROM @Resultados
        WHERE (ModoSeleccion='TIPO' AND TipoCaractId IS NULL)
           OR (ModoSeleccion='FASE' AND VersionFaseId IS NULL)
           OR (ModoSeleccion='TIPO_FASE' AND (TipoCaractId IS NULL OR VersionFaseId IS NULL))
    )
        THROW 50010,'La configuración del tipo o fase del bloque de resultados está incompleta.',1;

    IF EXISTS
    (
        SELECT 1
        FROM @Resultados R
        WHERE R.VersionFaseId IS NOT NULL
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.VERSIONFTCARACTERISTICA VFC
              WHERE VFC.VersionId=@VersionFtId
                AND VFC.VersionFaseId=R.VersionFaseId
                AND VFC.Estado=1
          )
    )
        THROW 50011,'Existe una fase configurada que no pertenece a esta Ficha Técnica.',1;

    DECLARE @Seleccion TABLE
    (
        FilaSeccion INT NOT NULL,
        FilaResultado INT NOT NULL,
        VersionFtCaracteristicaId INT NOT NULL,
        Orden INT NULL
    );

    INSERT INTO @Seleccion
    (
        FilaSeccion,FilaResultado,VersionFtCaracteristicaId,Orden
    )
    SELECT
        R.FilaSeccion,
        R.FilaResultado,
        C.VersionFtCaracteristicaId,
        C.Orden
    FROM @Resultados R
    CROSS APPLY OPENJSON(R.CaracteristicasJson)
    WITH
    (
        VersionFtCaracteristicaId INT '$.versionFtCaracteristicaId',
        Orden INT '$.orden'
    ) C
    WHERE R.CaracteristicasJson IS NOT NULL;

    IF EXISTS
    (
        SELECT 1
        FROM @Seleccion S
        LEFT JOIN dbo.VERSIONFTCARACTERISTICA VFC
            ON VFC.VersionFtCaracteristicaId=S.VersionFtCaracteristicaId
           AND VFC.VersionId=@VersionFtId
           AND VFC.Estado=1
           AND VFC.ImprimeCertificado=1
        WHERE VFC.VersionFtCaracteristicaId IS NULL
    )
        THROW 50012,'El diseño contiene una característica no habilitada para certificado.',1;

    IF EXISTS
    (
        SELECT VersionFtCaracteristicaId
        FROM @Seleccion
        GROUP BY VersionFtCaracteristicaId
        HAVING COUNT(*)>1
    )
        THROW 50013,'Una característica de la FT no puede repetirse en dos bloques del mismo certificado.',1;

    IF EXISTS
    (
        SELECT 1
        FROM @Seleccion
        WHERE Orden IS NULL OR Orden<=0
    )
        THROW 50014,'Existe una característica con orden inválido.',1;

    IF EXISTS
    (
        SELECT S.FilaSeccion,S.FilaResultado,S.Orden
        FROM @Seleccion S
        GROUP BY S.FilaSeccion,S.FilaResultado,S.Orden
        HAVING COUNT(*)>1
    )
        THROW 50015,'No pueden existir dos características con el mismo orden dentro de un bloque.',1;

    IF EXISTS
    (
        SELECT 1
        FROM @Seleccion S
        INNER JOIN @Resultados R
            ON R.FilaSeccion=S.FilaSeccion
           AND R.FilaResultado=S.FilaResultado
        INNER JOIN dbo.VERSIONFTCARACTERISTICA VFC
            ON VFC.VersionFtCaracteristicaId=S.VersionFtCaracteristicaId
        INNER JOIN dbo.CARACTERISTICA C
            ON C.CaracteristicaId=VFC.CaracteristicaId
        WHERE
            (R.ModoSeleccion IN('TIPO','TIPO_FASE') AND C.TipoCaractId<>R.TipoCaractId)
            OR
            (R.ModoSeleccion IN('FASE','TIPO_FASE') AND ISNULL(VFC.VersionFaseId,-1)<>R.VersionFaseId)
    )
        THROW 50016,'Existe una característica que no corresponde al tipo o fase configurados para su bloque.',1;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE RC
        SET RC.Estado=0,
            RC.AudUsuarioModificacion=@Usuario,
            RC.AudFechaActualizacion=SYSDATETIME()
        FROM dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA RC
        INNER JOIN dbo.CERTIFICADOPLANTILLARESULTADO R
            ON R.CertificadoPlantillaResultadoId=RC.CertificadoPlantillaResultadoId
        INNER JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
            ON CPS.CertificadoPlantillaSeccionId=R.CertificadoPlantillaSeccionId
        WHERE CPS.CertificadoPlantillaId=@CertificadoPlantillaId
          AND RC.Estado=1;

        UPDATE R
        SET R.Estado=0,
            R.AudUsuarioModificacion=@Usuario,
            R.AudFechaActualizacion=SYSDATETIME()
        FROM dbo.CERTIFICADOPLANTILLARESULTADO R
        INNER JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
            ON CPS.CertificadoPlantillaSeccionId=R.CertificadoPlantillaSeccionId
        WHERE CPS.CertificadoPlantillaId=@CertificadoPlantillaId
          AND R.Estado=1;

        UPDATE C
        SET C.Estado=0,
            C.AudUsuarioModificacion=@Usuario,
            C.AudFechaActualizacion=SYSDATETIME()
        FROM dbo.CERTIFICADOPLANTILLASECCIONCONTENIDO C
        INNER JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
            ON CPS.CertificadoPlantillaSeccionId=C.CertificadoPlantillaSeccionId
        WHERE CPS.CertificadoPlantillaId=@CertificadoPlantillaId
          AND C.Estado=1;

        UPDATE dbo.CERTIFICADOPLANTILLASECCION
        SET Estado=0,
            AudUsuarioModificacion=@Usuario,
            AudFechaActualizacion=SYSDATETIME()
        WHERE CertificadoPlantillaId=@CertificadoPlantillaId
          AND Estado=1;

        DECLARE @NuevaSeccion TABLE
        (
            FilaSeccion INT PRIMARY KEY,
            CertificadoPlantillaSeccionId INT NOT NULL
        );

        DECLARE
              @Fila INT
            , @MaxFila INT
            , @CertificadoSeccionId INT
            , @Codigo VARCHAR(40)
            , @Descripcion VARCHAR(200)
            , @Orden INT
            , @Visible BIT
            , @Contenido VARCHAR(MAX)
            , @NuevaSeccionId INT;

        SELECT @Fila=MIN(Fila),@MaxFila=MAX(Fila) FROM @Secciones;

        WHILE @Fila IS NOT NULL AND @Fila<=@MaxFila
        BEGIN
            SELECT
                  @CertificadoSeccionId=S.CertificadoSeccionId
                , @Orden=S.Orden
                , @Visible=S.Visible
                , @Contenido=S.Contenido
                , @Codigo=CS.Codigo
                , @Descripcion=CS.Descripcion
            FROM @Secciones S
            INNER JOIN dbo.CERTIFICADOSECCION CS
                ON CS.CertificadoSeccionId=S.CertificadoSeccionId
            WHERE S.Fila=@Fila;

            INSERT INTO dbo.CERTIFICADOPLANTILLASECCION
            (
                CertificadoPlantillaId,CertificadoSeccionId,
                TipoSeccion,Titulo,Contenido,Orden,Visible,
                ModoSeleccion,VersionFaseId,TipoCaractId,
                Estado,AudUsuarioCreacion,AudFechaCreacion
            )
            VALUES
            (
                @CertificadoPlantillaId,@CertificadoSeccionId,
                @Codigo,@Descripcion,NULL,@Orden,@Visible,
                'MANUAL',NULL,NULL,
                1,@Usuario,SYSDATETIME()
            );

            SET @NuevaSeccionId=CONVERT(INT,SCOPE_IDENTITY());

            INSERT INTO @NuevaSeccion(FilaSeccion,CertificadoPlantillaSeccionId)
            VALUES(@Fila,@NuevaSeccionId);

            IF @Contenido IS NOT NULL
            BEGIN
                INSERT INTO dbo.CERTIFICADOPLANTILLASECCIONCONTENIDO
                (
                    CertificadoPlantillaSeccionId,Contenido,Estado,
                    AudUsuarioCreacion,AudFechaCreacion
                )
                VALUES
                (
                    @NuevaSeccionId,@Contenido,1,
                    @Usuario,SYSDATETIME()
                );
            END;

            SET @Fila+=1;
        END;

        DECLARE @NuevaResultado TABLE
        (
            FilaSeccion INT NOT NULL,
            FilaResultado INT NOT NULL,
            CertificadoPlantillaResultadoId INT NOT NULL,
            PRIMARY KEY(FilaSeccion,FilaResultado)
        );

        DECLARE
              @RFilaSeccion INT
            , @RFilaResultado INT
            , @RTitulo VARCHAR(200)
            , @ROrden INT
            , @RVisible BIT
            , @RModo VARCHAR(20)
            , @RVersionFaseId INT
            , @RTipoCaractId INT
            , @RSeccionId INT
            , @NuevoResultadoId INT;

        DECLARE cur_guardar_resultados CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            FilaSeccion,FilaResultado,Titulo,Orden,Visible,
            ModoSeleccion,VersionFaseId,TipoCaractId
        FROM @Resultados
        ORDER BY FilaSeccion,Orden,FilaResultado;

        OPEN cur_guardar_resultados;
        FETCH NEXT FROM cur_guardar_resultados INTO
            @RFilaSeccion,@RFilaResultado,@RTitulo,@ROrden,@RVisible,
            @RModo,@RVersionFaseId,@RTipoCaractId;

        WHILE @@FETCH_STATUS=0
        BEGIN
            SELECT @RSeccionId=CertificadoPlantillaSeccionId
            FROM @NuevaSeccion
            WHERE FilaSeccion=@RFilaSeccion;

            INSERT INTO dbo.CERTIFICADOPLANTILLARESULTADO
            (
                CertificadoPlantillaSeccionId,Titulo,Orden,Visible,
                ModoSeleccion,VersionFaseId,TipoCaractId,
                Estado,AudUsuarioCreacion,AudFechaCreacion
            )
            VALUES
            (
                @RSeccionId,LTRIM(RTRIM(@RTitulo)),@ROrden,@RVisible,
                @RModo,@RVersionFaseId,@RTipoCaractId,
                1,@Usuario,SYSDATETIME()
            );

            SET @NuevoResultadoId=CONVERT(INT,SCOPE_IDENTITY());

            INSERT INTO @NuevaResultado
            (
                FilaSeccion,FilaResultado,CertificadoPlantillaResultadoId
            )
            VALUES
            (
                @RFilaSeccion,@RFilaResultado,@NuevoResultadoId
            );

            FETCH NEXT FROM cur_guardar_resultados INTO
                @RFilaSeccion,@RFilaResultado,@RTitulo,@ROrden,@RVisible,
                @RModo,@RVersionFaseId,@RTipoCaractId;
        END;

        CLOSE cur_guardar_resultados;
        DEALLOCATE cur_guardar_resultados;

        INSERT INTO dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA
        (
            CertificadoPlantillaResultadoId,
            VersionFtCaracteristicaId,
            Orden,
            Estado,
            AudUsuarioCreacion,
            AudFechaCreacion
        )
        SELECT
            NR.CertificadoPlantillaResultadoId,
            S.VersionFtCaracteristicaId,
            S.Orden,
            1,
            @Usuario,
            SYSDATETIME()
        FROM @Seleccion S
        INNER JOIN @NuevaResultado NR
            ON NR.FilaSeccion=S.FilaSeccion
           AND NR.FilaResultado=S.FilaResultado;

        UPDATE dbo.CERTIFICADOPLANTILLA
        SET AudUsuarioModificacion=@Usuario,
            AudFechaActualizacion=SYSDATETIME()
        WHERE CertificadoPlantillaId=@CertificadoPlantillaId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('local','cur_guardar_resultados')>=-1
        BEGIN
            IF CURSOR_STATUS('local','cur_guardar_resultados')>0
                CLOSE cur_guardar_resultados;
            DEALLOCATE cur_guardar_resultados;
        END;

        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT
        0 CodigoResultado,
        'Diseño de plantilla guardado correctamente.' Mensaje,
        @CertificadoPlantillaId CertificadoPlantillaId;
END;
GO

SELECT
    0 CodigoResultado,
    'Modelo normalizado de secciones de certificado configurado correctamente.' Mensaje;
GO
