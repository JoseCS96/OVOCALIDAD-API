/* ============================================================
   OVOCALIDAD 2.0
   CERTIFICADOS - ESTRUCTURA BASE DE DISEÑO

   Secciones base:
   1. Título y subtítulo
   2. Datos de empresa
   3. Ovoproducto
   4. Datos del lote
   5. Resultados y evaluaciones (1..N)
   6. Condición y almacenamiento
   7. Referencias
   8. Firmas y fecha
   ============================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/* 1. Contenido auxiliar para título/subtítulo y pie */
IF COL_LENGTH('dbo.CERTIFICADOPLANTILLASECCION','Contenido') IS NULL
BEGIN
    ALTER TABLE dbo.CERTIFICADOPLANTILLASECCION
    ADD Contenido VARCHAR(MAX) NULL;
END;
GO

/* 2. Ampliar tipos de sección */
IF EXISTS
(
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_CERTIFICADOPLANTILLASECCION_TIPO'
      AND parent_object_id = OBJECT_ID('dbo.CERTIFICADOPLANTILLASECCION')
)
BEGIN
    ALTER TABLE dbo.CERTIFICADOPLANTILLASECCION
    DROP CONSTRAINT CK_CERTIFICADOPLANTILLASECCION_TIPO;
END;
GO

ALTER TABLE dbo.CERTIFICADOPLANTILLASECCION
WITH CHECK
ADD CONSTRAINT CK_CERTIFICADOPLANTILLASECCION_TIPO
CHECK
(
    TipoSeccion IN
    (
        'ENCABEZADO',
        'DATOS_EMPRESA',
        'PRODUCTO',
        'DATOS_LOTE',
        'RESULTADOS',
        'ALMACENAMIENTO',
        'REFERENCIAS',
        'FIRMA',
        'PIE'
    )
);
GO

/* 3. Inicializar estructura base en plantillas activas que aún no tienen diseño */
DECLARE @UsuarioMigracion VARCHAR(100) = 'MIGRACION_CERTIFICADO_BASE';

INSERT INTO dbo.CERTIFICADOPLANTILLASECCION
(
    CertificadoPlantillaId,
    TipoSeccion,
    Titulo,
    Contenido,
    Orden,
    Visible,
    ModoSeleccion,
    VersionFaseId,
    TipoCaractId,
    Estado,
    AudUsuarioCreacion,
    AudFechaCreacion
)
SELECT
    CP.CertificadoPlantillaId,
    X.TipoSeccion,
    X.Titulo,
    X.Contenido,
    X.Orden,
    1,
    'MANUAL',
    NULL,
    NULL,
    1,
    @UsuarioMigracion,
    SYSDATETIME()
FROM dbo.CERTIFICADOPLANTILLA CP
CROSS APPLY
(
    VALUES
      ('ENCABEZADO',     'SEGURAMIENTO DE LA CALIDAD', 'CERTIFICADO DE ANÁLISIS', 1),
      ('DATOS_EMPRESA',  'Datos de empresa',            NULL,                      2),
      ('PRODUCTO',       'Ovoproducto',                  NULL,                      3),
      ('DATOS_LOTE',     'Datos del lote',               NULL,                      4),
      ('RESULTADOS',     'Informe de ensayo',            NULL,                      5),
      ('ALMACENAMIENTO', 'Condición de almacenamiento',  NULL,                      6),
      ('REFERENCIAS',    'Referencias',                  NULL,                      7),
      ('FIRMA',          'Firmas y fecha',               NULL,                      8)
) X(TipoSeccion,Titulo,Contenido,Orden)
WHERE CP.Estado = 1
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.CERTIFICADOPLANTILLASECCION CPS
      WHERE CPS.CertificadoPlantillaId = CP.CertificadoPlantillaId
        AND CPS.Estado = 1
  );
GO

/* 4. Crear plantilla con estructura base */
CREATE OR ALTER PROCEDURE dbo.SP_CREAR_PLANTILLA_CERTIFICADO
(
    @VersionFtId INT,
    @Nombre VARCHAR(200),
    @Descripcion VARCHAR(1000) = NULL,
    @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @Nombre = NULLIF(LTRIM(RTRIM(@Nombre)), '');
    SET @Descripcion = NULLIF(LTRIM(RTRIM(@Descripcion)), '');
    SET @Usuario = NULLIF(LTRIM(RTRIM(@Usuario)), '');

    IF @Nombre IS NULL
        THROW 50001, 'Debe indicar el nombre de la plantilla.', 1;

    IF @Usuario IS NULL
        THROW 50002, 'El usuario es obligatorio.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.VERSION V
        INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId = V.DocumentoId
        WHERE V.VersionId = @VersionFtId
          AND V.Estado = 1
          AND D.Estado = 1
          AND D.TipoDocumentoId = 3
    )
        THROW 50003, 'La versión indicada no corresponde a una Ficha Técnica activa.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.VERSIONFTCARACTERISTICA
        WHERE VersionId = @VersionFtId
          AND Estado = 1
          AND ImprimeCertificado = 1
    )
        THROW 50004, 'La Ficha Técnica no tiene parámetros habilitados para certificado.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.CERTIFICADOPLANTILLA
        WHERE VersionFtId = @VersionFtId
          AND Nombre = @Nombre
          AND Estado = 1
    )
        THROW 50005, 'Ya existe una plantilla activa con ese nombre para la Ficha Técnica.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.CERTIFICADOPLANTILLA
        (
            VersionFtId, Nombre, Descripcion, Estado,
            AudUsuarioCreacion, AudFechaCreacion
        )
        VALUES
        (
            @VersionFtId, @Nombre, @Descripcion, 1,
            @Usuario, SYSDATETIME()
        );

        DECLARE @CertificadoPlantillaId INT = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO dbo.CERTIFICADOPLANTILLASECCION
        (
            CertificadoPlantillaId,
            TipoSeccion,
            Titulo,
            Contenido,
            Orden,
            Visible,
            ModoSeleccion,
            VersionFaseId,
            TipoCaractId,
            Estado,
            AudUsuarioCreacion,
            AudFechaCreacion
        )
        VALUES
          (@CertificadoPlantillaId,'ENCABEZADO',    'SEGURAMIENTO DE LA CALIDAD','CERTIFICADO DE ANÁLISIS',1,1,'MANUAL',NULL,NULL,1,@Usuario,SYSDATETIME()),
          (@CertificadoPlantillaId,'DATOS_EMPRESA', 'Datos de empresa',           NULL,                     2,1,'MANUAL',NULL,NULL,1,@Usuario,SYSDATETIME()),
          (@CertificadoPlantillaId,'PRODUCTO',      'Ovoproducto',                NULL,                     3,1,'MANUAL',NULL,NULL,1,@Usuario,SYSDATETIME()),
          (@CertificadoPlantillaId,'DATOS_LOTE',    'Datos del lote',             NULL,                     4,1,'MANUAL',NULL,NULL,1,@Usuario,SYSDATETIME()),
          (@CertificadoPlantillaId,'RESULTADOS',    'Informe de ensayo',          NULL,                     5,1,'MANUAL',NULL,NULL,1,@Usuario,SYSDATETIME()),
          (@CertificadoPlantillaId,'ALMACENAMIENTO','Condición de almacenamiento',NULL,                     6,1,'MANUAL',NULL,NULL,1,@Usuario,SYSDATETIME()),
          (@CertificadoPlantillaId,'REFERENCIAS',   'Referencias',                NULL,                     7,1,'MANUAL',NULL,NULL,1,@Usuario,SYSDATETIME()),
          (@CertificadoPlantillaId,'FIRMA',         'Firmas y fecha',             NULL,                     8,1,'MANUAL',NULL,NULL,1,@Usuario,SYSDATETIME());

        COMMIT TRANSACTION;

        SELECT
            0 AS CodigoResultado,
            'Plantilla de certificado creada correctamente.' AS Mensaje,
            @CertificadoPlantillaId AS CertificadoPlantillaId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/* 5. Obtener plantilla */
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
        WHERE CertificadoPlantillaId = @CertificadoPlantillaId
          AND Estado = 1
    )
        THROW 50001, 'La plantilla de certificado no existe o está inactiva.', 1;

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
        , EV.EstVerDescripcion AS EstadoVersionFt
    FROM dbo.CERTIFICADOPLANTILLA CP
    INNER JOIN dbo.VERSION V ON V.VersionId = CP.VersionFtId
    INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId = V.DocumentoId
    INNER JOIN dbo.ESTADOVERSION EV ON EV.EstVerId = V.EstVerId
    WHERE CP.CertificadoPlantillaId = @CertificadoPlantillaId
      AND CP.Estado = 1;

    SELECT
          CPS.CertificadoPlantillaSeccionId
        , CPS.CertificadoPlantillaId
        , CPS.TipoSeccion
        , CPS.Titulo
        , CPS.Contenido
        , CPS.Orden
        , CPS.Visible
        , CPS.ModoSeleccion
        , CPS.VersionFaseId
        , VF.FaseId
        , VF.CodigoReferencia AS FaseCodigo
        , COALESCE(NULLIF(LTRIM(RTRIM(VF.Descripcion)), ''), VF.CodigoReferencia) AS FaseDescripcion
        , CPS.TipoCaractId
        , TC.TipoCaractDescripcion
    FROM dbo.CERTIFICADOPLANTILLASECCION CPS
    LEFT JOIN dbo.VERSIONFASE VF
        ON VF.VersionFaseId = CPS.VersionFaseId
       AND VF.Estado = 1
    LEFT JOIN dbo.TIPO_CARACTERISTICA TC
        ON TC.TipoCaractId = CPS.TipoCaractId
    WHERE CPS.CertificadoPlantillaId = @CertificadoPlantillaId
      AND CPS.Estado = 1
    ORDER BY CPS.Orden;

    SELECT
          CPC.CertificadoPlantillaCaracteristicaId
        , CPC.CertificadoPlantillaSeccionId
        , CPC.VersionFtCaracteristicaId
        , VFC.CaracteristicaId
        , C.CaracteristicaDescripcion AS Determinacion
        , C.TipoCaractId
        , TC.TipoCaractDescripcion
        , VFC.FaseId
        , VFC.VersionFaseId
        , VF.CodigoReferencia AS FaseCodigo
        , COALESCE(NULLIF(LTRIM(RTRIM(VF.Descripcion)), ''), VF.CodigoReferencia) AS FaseDescripcion
        , VFC.TipoCriterioId
        , TCR.TipCritDescripcion AS TipoCriterioCodigo
        , TCR.TipCritDescripcionUsuario AS TipoCriterioDescripcionUsuario
        , VFC.ValorCuantitativoInicial
        , VFC.ValorCuantitativoFinal
        , VFC.ValorCuantitativoIgual
        , VFC.ValorCualitativo
        , VFC.UnidadDeMedida
        , C.MetEnsayoId
        , ME.MetEnsayoDescripcion
        , VFC.ObligatorioCertificado
        , CPC.Orden
    FROM dbo.CERTIFICADOPLANTILLACARACTERISTICA CPC
    INNER JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
        ON CPS.CertificadoPlantillaSeccionId = CPC.CertificadoPlantillaSeccionId
    INNER JOIN dbo.VERSIONFTCARACTERISTICA VFC
        ON VFC.VersionFtCaracteristicaId = CPC.VersionFtCaracteristicaId
    INNER JOIN dbo.CARACTERISTICA C
        ON C.CaracteristicaId = VFC.CaracteristicaId
    LEFT JOIN dbo.TIPO_CARACTERISTICA TC
        ON TC.TipoCaractId = C.TipoCaractId
    LEFT JOIN dbo.TIPO_CRITERIO TCR
        ON TCR.TipoCriterioId = VFC.TipoCriterioId
    LEFT JOIN dbo.VERSIONFASE VF
        ON VF.VersionFaseId = VFC.VersionFaseId
       AND VF.Estado = 1
    LEFT JOIN dbo.METODO_DE_ENSAYO ME
        ON ME.MetEnsayoId = C.MetEnsayoId
    WHERE CPS.CertificadoPlantillaId = @CertificadoPlantillaId
      AND CPS.Estado = 1
      AND CPC.Estado = 1
    ORDER BY CPS.Orden, CPC.Orden;
END;
GO

/* 6. Guardar diseño multi-bloque */
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

    IF ISJSON(@SeccionesJson) <> 1
        THROW 50001, 'El diseño de secciones no tiene un formato JSON válido.', 1;

    DECLARE @VersionFtId INT;

    SELECT @VersionFtId = VersionFtId
    FROM dbo.CERTIFICADOPLANTILLA
    WHERE CertificadoPlantillaId = @CertificadoPlantillaId
      AND Estado = 1;

    IF @VersionFtId IS NULL
        THROW 50002, 'La plantilla de certificado no existe o está inactiva.', 1;

    DECLARE @Secciones TABLE
    (
          Fila INT IDENTITY(1,1)
        , TipoSeccion VARCHAR(40)
        , Titulo VARCHAR(200)
        , Contenido VARCHAR(MAX)
        , Orden INT
        , Visible BIT
        , ModoSeleccion VARCHAR(20)
        , VersionFaseId INT NULL
        , TipoCaractId INT NULL
        , CaracteristicasJson NVARCHAR(MAX)
    );

    INSERT INTO @Secciones
    (
        TipoSeccion,Titulo,Contenido,Orden,Visible,ModoSeleccion,
        VersionFaseId,TipoCaractId,CaracteristicasJson
    )
    SELECT
          TipoSeccion
        , Titulo
        , Contenido
        , Orden
        , ISNULL(Visible,1)
        , ISNULL(NULLIF(UPPER(LTRIM(RTRIM(ModoSeleccion))),''),'MANUAL')
        , VersionFaseId
        , TipoCaractId
        , Caracteristicas
    FROM OPENJSON(@SeccionesJson)
    WITH
    (
          TipoSeccion VARCHAR(40) '$.tipoSeccion'
        , Titulo VARCHAR(200) '$.titulo'
        , Contenido VARCHAR(MAX) '$.contenido'
        , Orden INT '$.orden'
        , Visible BIT '$.visible'
        , ModoSeleccion VARCHAR(20) '$.modoSeleccion'
        , VersionFaseId INT '$.versionFaseId'
        , TipoCaractId INT '$.tipoCaractId'
        , Caracteristicas NVARCHAR(MAX) '$.caracteristicas' AS JSON
    );

    IF NOT EXISTS (SELECT 1 FROM @Secciones)
        THROW 50003, 'Debe configurar al menos una sección.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM @Secciones
        WHERE TipoSeccion NOT IN
        (
            'ENCABEZADO','DATOS_EMPRESA','PRODUCTO','DATOS_LOTE',
            'RESULTADOS','ALMACENAMIENTO','REFERENCIAS','FIRMA','PIE'
        )
        OR Orden IS NULL OR Orden <= 0
    )
        THROW 50004, 'Existe una sección con tipo u orden no válido.', 1;

    IF EXISTS
    (
        SELECT Orden
        FROM @Secciones
        GROUP BY Orden
        HAVING COUNT(*) > 1
    )
        THROW 50005, 'No pueden existir dos secciones con el mismo orden.', 1;

    IF EXISTS
    (
        SELECT TipoSeccion
        FROM @Secciones
        WHERE TipoSeccion <> 'RESULTADOS'
        GROUP BY TipoSeccion
        HAVING COUNT(*) > 1
    )
        THROW 50006, 'Las secciones base no pueden repetirse. Solo Resultados y evaluaciones admite múltiples bloques.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM @Secciones
        WHERE TipoSeccion = 'RESULTADOS'
          AND ModoSeleccion NOT IN ('MANUAL','TIPO','FASE','TIPO_FASE')
    )
        THROW 50007, 'Existe un bloque de resultados con modo de selección inválido.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM @Secciones
        WHERE TipoSeccion = 'RESULTADOS'
          AND
          (
              (ModoSeleccion = 'TIPO' AND TipoCaractId IS NULL)
              OR (ModoSeleccion = 'FASE' AND VersionFaseId IS NULL)
              OR (ModoSeleccion = 'TIPO_FASE' AND (TipoCaractId IS NULL OR VersionFaseId IS NULL))
          )
    )
        THROW 50008, 'La configuración del tipo o fase del bloque de resultados está incompleta.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM @Secciones S
        WHERE S.VersionFaseId IS NOT NULL
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.VERSIONFTCARACTERISTICA VFC
              WHERE VFC.VersionId = @VersionFtId
                AND VFC.VersionFaseId = S.VersionFaseId
                AND VFC.Estado = 1
          )
    )
        THROW 50009, 'Existe una fase configurada que no pertenece a esta Ficha Técnica.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM @Secciones S
        WHERE S.TipoCaractId IS NOT NULL
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.TIPO_CARACTERISTICA TC
              WHERE TC.TipoCaractId = S.TipoCaractId
                AND TC.Estado = 1
          )
    )
        THROW 50010, 'Existe un tipo de característica inválido en el diseño.', 1;

    DECLARE @Seleccion TABLE
    (
          FilaSeccion INT
        , VersionFtCaracteristicaId INT
        , Orden INT
    );

    INSERT INTO @Seleccion(FilaSeccion,VersionFtCaracteristicaId,Orden)
    SELECT
          S.Fila
        , J.VersionFtCaracteristicaId
        , J.Orden
    FROM @Secciones S
    CROSS APPLY OPENJSON(S.CaracteristicasJson)
    WITH
    (
          VersionFtCaracteristicaId INT '$.versionFtCaracteristicaId'
        , Orden INT '$.orden'
    ) J
    WHERE S.TipoSeccion = 'RESULTADOS'
      AND S.Visible = 1
      AND S.CaracteristicasJson IS NOT NULL;

    IF NOT EXISTS
    (
        SELECT 1
        FROM @Secciones
        WHERE TipoSeccion = 'RESULTADOS'
          AND Visible = 1
    )
        THROW 50011, 'La plantilla debe contener al menos un bloque de resultados visible.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM @Secciones S
        WHERE S.TipoSeccion = 'RESULTADOS'
          AND S.Visible = 1
          AND NOT EXISTS
          (
              SELECT 1
              FROM @Seleccion SEL
              WHERE SEL.FilaSeccion = S.Fila
          )
    )
        THROW 50012, 'Cada bloque de resultados visible debe contener al menos una característica.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM @Seleccion SEL
        LEFT JOIN dbo.VERSIONFTCARACTERISTICA VFC
          ON VFC.VersionFtCaracteristicaId = SEL.VersionFtCaracteristicaId
         AND VFC.VersionId = @VersionFtId
         AND VFC.Estado = 1
         AND VFC.ImprimeCertificado = 1
        WHERE VFC.VersionFtCaracteristicaId IS NULL
    )
        THROW 50013, 'El diseño contiene una característica que no está habilitada para certificado en la Ficha Técnica.', 1;

    IF EXISTS
    (
        SELECT VersionFtCaracteristicaId
        FROM @Seleccion
        GROUP BY VersionFtCaracteristicaId
        HAVING COUNT(*) > 1
    )
        THROW 50014, 'Una misma característica de la Ficha Técnica no puede repetirse dos veces en la misma plantilla.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM @Seleccion
        WHERE Orden IS NULL OR Orden <= 0
    )
        THROW 50015, 'Existe una característica con orden inválido dentro de un bloque.', 1;

    IF EXISTS
    (
        SELECT FilaSeccion,Orden
        FROM @Seleccion
        GROUP BY FilaSeccion,Orden
        HAVING COUNT(*) > 1
    )
        THROW 50016, 'No pueden existir dos características con el mismo orden dentro del mismo bloque.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM @Seleccion SEL
        INNER JOIN @Secciones S ON S.Fila = SEL.FilaSeccion
        INNER JOIN dbo.VERSIONFTCARACTERISTICA VFC
            ON VFC.VersionFtCaracteristicaId = SEL.VersionFtCaracteristicaId
        INNER JOIN dbo.CARACTERISTICA C
            ON C.CaracteristicaId = VFC.CaracteristicaId
        WHERE
            (S.ModoSeleccion IN ('TIPO','TIPO_FASE') AND C.TipoCaractId <> S.TipoCaractId)
            OR
            (S.ModoSeleccion IN ('FASE','TIPO_FASE') AND ISNULL(VFC.VersionFaseId,-1) <> S.VersionFaseId)
    )
        THROW 50017, 'Existe una característica que no corresponde al tipo o fase configurados para su bloque.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.CERTIFICADOPLANTILLACARACTERISTICA
        SET Estado = 0,
            AudUsuarioModificacion = @Usuario,
            AudFechaActualizacion = SYSDATETIME()
        WHERE CertificadoPlantillaSeccionId IN
        (
            SELECT CertificadoPlantillaSeccionId
            FROM dbo.CERTIFICADOPLANTILLASECCION
            WHERE CertificadoPlantillaId = @CertificadoPlantillaId
              AND Estado = 1
        )
          AND Estado = 1;

        UPDATE dbo.CERTIFICADOPLANTILLASECCION
        SET Estado = 0,
            AudUsuarioModificacion = @Usuario,
            AudFechaActualizacion = SYSDATETIME()
        WHERE CertificadoPlantillaId = @CertificadoPlantillaId
          AND Estado = 1;

        DECLARE @Fila INT = 1,
                @MaxFila INT = (SELECT MAX(Fila) FROM @Secciones);

        WHILE @Fila <= @MaxFila
        BEGIN
            DECLARE
                  @Tipo VARCHAR(40)
                , @Titulo VARCHAR(200)
                , @Contenido VARCHAR(MAX)
                , @Orden INT
                , @Visible BIT
                , @ModoSeleccion VARCHAR(20)
                , @VersionFaseId INT
                , @TipoCaractId INT
                , @Caracteristicas NVARCHAR(MAX)
                , @SeccionId INT;

            SELECT
                  @Tipo = TipoSeccion
                , @Titulo = Titulo
                , @Contenido = Contenido
                , @Orden = Orden
                , @Visible = Visible
                , @ModoSeleccion = ModoSeleccion
                , @VersionFaseId = VersionFaseId
                , @TipoCaractId = TipoCaractId
                , @Caracteristicas = CaracteristicasJson
            FROM @Secciones
            WHERE Fila = @Fila;

            INSERT INTO dbo.CERTIFICADOPLANTILLASECCION
            (
                  CertificadoPlantillaId
                , TipoSeccion
                , Titulo
                , Contenido
                , Orden
                , Visible
                , ModoSeleccion
                , VersionFaseId
                , TipoCaractId
                , Estado
                , AudUsuarioCreacion
                , AudFechaCreacion
            )
            VALUES
            (
                  @CertificadoPlantillaId
                , @Tipo
                , NULLIF(LTRIM(RTRIM(@Titulo)),'')
                , NULLIF(LTRIM(RTRIM(@Contenido)),'')
                , @Orden
                , @Visible
                , CASE WHEN @Tipo='RESULTADOS' THEN @ModoSeleccion ELSE 'MANUAL' END
                , CASE WHEN @Tipo='RESULTADOS' THEN @VersionFaseId ELSE NULL END
                , CASE WHEN @Tipo='RESULTADOS' THEN @TipoCaractId ELSE NULL END
                , 1
                , @Usuario
                , SYSDATETIME()
            );

            SET @SeccionId = CONVERT(INT,SCOPE_IDENTITY());

            IF @Tipo='RESULTADOS'
               AND @Visible=1
               AND @Caracteristicas IS NOT NULL
            BEGIN
                INSERT INTO dbo.CERTIFICADOPLANTILLACARACTERISTICA
                (
                    CertificadoPlantillaSeccionId,
                    VersionFtCaracteristicaId,
                    Orden,
                    Estado,
                    AudUsuarioCreacion,
                    AudFechaCreacion
                )
                SELECT
                    @SeccionId,
                    J.VersionFtCaracteristicaId,
                    J.Orden,
                    1,
                    @Usuario,
                    SYSDATETIME()
                FROM OPENJSON(@Caracteristicas)
                WITH
                (
                    VersionFtCaracteristicaId INT '$.versionFtCaracteristicaId',
                    Orden INT '$.orden'
                ) J;
            END;

            SET @Fila += 1;
        END;

        UPDATE dbo.CERTIFICADOPLANTILLA
        SET AudUsuarioModificacion = @Usuario,
            AudFechaActualizacion = SYSDATETIME()
        WHERE CertificadoPlantillaId = @CertificadoPlantillaId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT
          0 AS CodigoResultado
        , 'Diseño de plantilla guardado correctamente.' AS Mensaje
        , @CertificadoPlantillaId AS CertificadoPlantillaId;
END;
GO
