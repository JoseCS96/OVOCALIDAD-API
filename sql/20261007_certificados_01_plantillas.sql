/*
    OVOCALIDAD 2.0 - Certificación
    SPs del diseñador de plantillas de certificado.

    REGLA:
    - Solo una FICHA TÉCNICA (TipoDocumentoId = 3) puede ser origen de plantilla.
    - Solo VERSIONFTCARACTERISTICA activas con ImprimeCertificado = 1 pueden seleccionarse.
    - Las características con ObligatorioCertificado = 1 deben quedar incluidas
      al guardar el diseño.
*/
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

    IF NULLIF(LTRIM(RTRIM(@Nombre)), '') IS NULL
        THROW 50001, 'Debe indicar el nombre de la plantilla.', 1;

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
        THROW 50002, 'La versión indicada no corresponde a una Ficha Técnica activa.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.VERSIONFTCARACTERISTICA
        WHERE VersionId = @VersionFtId
          AND Estado = 1
          AND ImprimeCertificado = 1
    )
        THROW 50003, 'La Ficha Técnica no tiene parámetros habilitados para certificado.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.CERTIFICADOPLANTILLA
        WHERE VersionFtId = @VersionFtId
          AND Nombre = LTRIM(RTRIM(@Nombre))
          AND Estado = 1
    )
        THROW 50004, 'Ya existe una plantilla activa con ese nombre para la Ficha Técnica.', 1;

    INSERT dbo.CERTIFICADOPLANTILLA
    (
        VersionFtId, Nombre, Descripcion, Estado,
        AudUsuarioCreacion, AudFechaCreacion
    )
    VALUES
    (
        @VersionFtId, LTRIM(RTRIM(@Nombre)), NULLIF(LTRIM(RTRIM(@Descripcion)), ''),
        1, @Usuario, SYSDATETIME()
    );

    DECLARE @CertificadoPlantillaId INT = CONVERT(INT, SCOPE_IDENTITY());

    SELECT 0 CodigoResultado,
           'Plantilla de certificado creada correctamente.' Mensaje,
           @CertificadoPlantillaId CertificadoPlantillaId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_PLANTILLAS_CERTIFICADO
(
    @VersionFtId INT = NULL,
    @ProductoCodigo VARCHAR(50) = NULL
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
        , COUNT(DISTINCT CASE WHEN CPS.Estado = 1 THEN CPS.CertificadoPlantillaSeccionId END) CantidadSecciones
        , COUNT(CASE WHEN CPC.Estado = 1 THEN 1 END) CantidadCaracteristicas
    FROM dbo.CERTIFICADOPLANTILLA CP
    INNER JOIN dbo.VERSION V ON V.VersionId = CP.VersionFtId
    INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId = V.DocumentoId
    LEFT JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
        ON CPS.CertificadoPlantillaId = CP.CertificadoPlantillaId
    LEFT JOIN dbo.CERTIFICADOPLANTILLACARACTERISTICA CPC
        ON CPC.CertificadoPlantillaSeccionId = CPS.CertificadoPlantillaSeccionId
       AND CPC.Estado = 1
    WHERE CP.Estado = 1
      AND (@VersionFtId IS NULL OR CP.VersionFtId = @VersionFtId)
      AND (@ProductoCodigo IS NULL OR D.ProductoCodigo = @ProductoCodigo)
    GROUP BY
          CP.CertificadoPlantillaId, CP.VersionFtId, CP.Nombre, CP.Descripcion
        , D.DocumentoId, D.DocumentoCodigo, D.DocumentoDescripcionDocumento
        , D.ProductoCodigo, V.VersionNumero, V.EstVerId
        , CP.AudUsuarioCreacion, CP.AudFechaCreacion
    ORDER BY D.ProductoCodigo, CP.Nombre;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_OBTENER_PLANTILLA_CERTIFICADO
(
    @CertificadoPlantillaId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1 FROM dbo.CERTIFICADOPLANTILLA
        WHERE CertificadoPlantillaId = @CertificadoPlantillaId AND Estado = 1
    )
        THROW 50001, 'La plantilla de certificado no existe o está inactiva.', 1;

    -- Resultset 1: cabecera
    SELECT
          CP.CertificadoPlantillaId
        , CP.VersionFtId
        , CP.Nombre
        , CP.Descripcion
        , D.DocumentoCodigo
        , D.DocumentoDescripcionDocumento
        , D.ProductoCodigo
        , V.VersionNumero
    FROM dbo.CERTIFICADOPLANTILLA CP
    INNER JOIN dbo.VERSION V ON V.VersionId = CP.VersionFtId
    INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId = V.DocumentoId
    WHERE CP.CertificadoPlantillaId = @CertificadoPlantillaId
      AND CP.Estado = 1;

    -- Resultset 2: secciones
    SELECT
          CPS.CertificadoPlantillaSeccionId
        , CPS.CertificadoPlantillaId
        , CPS.TipoSeccion
        , CPS.Titulo
        , CPS.Orden
        , CPS.Visible
    FROM dbo.CERTIFICADOPLANTILLASECCION CPS
    WHERE CPS.CertificadoPlantillaId = @CertificadoPlantillaId
      AND CPS.Estado = 1
    ORDER BY CPS.Orden;

    -- Resultset 3: características elegidas
    SELECT
          CPC.CertificadoPlantillaCaracteristicaId
        , CPC.CertificadoPlantillaSeccionId
        , CPC.VersionFtCaracteristicaId
        , VFC.CaracteristicaId
        , C.CaracteristicaDescripcion Determinacion
        , TC.TipoCaractDescripcion
        , VFC.TipoCriterioId
        , VFC.ValorCuantitativoInicial
        , VFC.ValorCuantitativoFinal
        , VFC.ValorCuantitativoIgual
        , VFC.ValorCualitativo
        , VFC.UnidadDeMedida
        , ME.MetEnsayoDescripcion
        , VFC.ObligatorioCertificado
        , CPC.Orden
    FROM dbo.CERTIFICADOPLANTILLACARACTERISTICA CPC
    INNER JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
        ON CPS.CertificadoPlantillaSeccionId = CPC.CertificadoPlantillaSeccionId
    INNER JOIN dbo.VERSIONFTCARACTERISTICA VFC
        ON VFC.VersionFtCaracteristicaId = CPC.VersionFtCaracteristicaId
    INNER JOIN dbo.CARACTERISTICA C ON C.CaracteristicaId = VFC.CaracteristicaId
    LEFT JOIN dbo.TIPOCARACTERISTICA TC ON TC.TipoCaractId = C.TipoCaractId
    LEFT JOIN dbo.METODOENSAYO ME ON ME.MetEnsayoId = C.MetEnsayoId
    WHERE CPS.CertificadoPlantillaId = @CertificadoPlantillaId
      AND CPS.Estado = 1
      AND CPC.Estado = 1
    ORDER BY CPS.Orden, CPC.Orden;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_GUARDAR_DISENO_PLANTILLA_CERTIFICADO
(
    @CertificadoPlantillaId INT,
    @SeccionesJson NVARCHAR(MAX),
    @Usuario VARCHAR(100)
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
        Fila INT IDENTITY(1,1),
        TipoSeccion VARCHAR(40),
        Titulo VARCHAR(200),
        Orden INT,
        Visible BIT,
        CaracteristicasJson NVARCHAR(MAX)
    );

    INSERT @Secciones(TipoSeccion, Titulo, Orden, Visible, CaracteristicasJson)
    SELECT
          TipoSeccion
        , Titulo
        , Orden
        , ISNULL(Visible, 1)
        , Caracteristicas
    FROM OPENJSON(@SeccionesJson)
    WITH
    (
        TipoSeccion VARCHAR(40) '$.tipoSeccion',
        Titulo VARCHAR(200) '$.titulo',
        Orden INT '$.orden',
        Visible BIT '$.visible',
        Caracteristicas NVARCHAR(MAX) '$.caracteristicas' AS JSON
    );

    IF NOT EXISTS (SELECT 1 FROM @Secciones)
        THROW 50003, 'Debe configurar al menos una sección.', 1;

    IF EXISTS
    (
        SELECT 1 FROM @Secciones
        WHERE TipoSeccion NOT IN
        ('ENCABEZADO','DATOS_LOTE','RESULTADOS','ALMACENAMIENTO','REFERENCIAS','FIRMA','PIE')
           OR Orden IS NULL OR Orden <= 0
    )
        THROW 50004, 'Existe una sección con tipo u orden no válido.', 1;

    IF EXISTS
    (
        SELECT Orden FROM @Secciones GROUP BY Orden HAVING COUNT(*) > 1
    )
        THROW 50005, 'No pueden existir dos secciones con el mismo orden.', 1;

    DECLARE @Seleccion TABLE
    (
        VersionFtCaracteristicaId INT,
        Orden INT
    );

    INSERT @Seleccion(VersionFtCaracteristicaId, Orden)
    SELECT J.VersionFtCaracteristicaId, J.Orden
    FROM @Secciones S
    CROSS APPLY OPENJSON(S.CaracteristicasJson)
    WITH
    (
        VersionFtCaracteristicaId INT '$.versionFtCaracteristicaId',
        Orden INT '$.orden'
    ) J
    WHERE S.TipoSeccion = 'RESULTADOS'
      AND S.Visible = 1
      AND S.CaracteristicasJson IS NOT NULL;

    IF EXISTS
    (
        SELECT 1
        FROM @Seleccion S
        LEFT JOIN dbo.VERSIONFTCARACTERISTICA VFC
          ON VFC.VersionFtCaracteristicaId = S.VersionFtCaracteristicaId
         AND VFC.VersionId = @VersionFtId
         AND VFC.Estado = 1
         AND VFC.ImprimeCertificado = 1
        WHERE VFC.VersionFtCaracteristicaId IS NULL
    )
        THROW 50006, 'El diseño contiene una característica que no está habilitada para certificado en la Ficha Técnica.', 1;

    IF EXISTS
    (
        SELECT VersionFtCaracteristicaId
        FROM @Seleccion
        GROUP BY VersionFtCaracteristicaId
        HAVING COUNT(*) > 1
    )
        THROW 50007, 'Una característica de la Ficha Técnica no puede repetirse en el diseño.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.VERSIONFTCARACTERISTICA VFC
        WHERE VFC.VersionId = @VersionFtId
          AND VFC.Estado = 1
          AND VFC.ImprimeCertificado = 1
          AND VFC.ObligatorioCertificado = 1
          AND NOT EXISTS
          (
              SELECT 1 FROM @Seleccion S
              WHERE S.VersionFtCaracteristicaId = VFC.VersionFtCaracteristicaId
          )
    )
        THROW 50008, 'El diseño debe incluir todos los parámetros obligatorios definidos por la Ficha Técnica.', 1;

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

        DECLARE @Fila INT = 1, @MaxFila INT = (SELECT MAX(Fila) FROM @Secciones);
        WHILE @Fila <= @MaxFila
        BEGIN
            DECLARE @Tipo VARCHAR(40), @Titulo VARCHAR(200), @Orden INT,
                    @Visible BIT, @Caracteristicas NVARCHAR(MAX),
                    @SeccionId INT;

            SELECT @Tipo=TipoSeccion, @Titulo=Titulo, @Orden=Orden,
                   @Visible=Visible, @Caracteristicas=CaracteristicasJson
            FROM @Secciones WHERE Fila=@Fila;

            INSERT dbo.CERTIFICADOPLANTILLASECCION
            (
                CertificadoPlantillaId, TipoSeccion, Titulo, Orden, Visible,
                Estado, AudUsuarioCreacion, AudFechaCreacion
            )
            VALUES
            (
                @CertificadoPlantillaId, @Tipo, NULLIF(LTRIM(RTRIM(@Titulo)), ''),
                @Orden, @Visible, 1, @Usuario, SYSDATETIME()
            );

            SET @SeccionId = CONVERT(INT, SCOPE_IDENTITY());

            IF @Tipo = 'RESULTADOS' AND @Visible = 1 AND @Caracteristicas IS NOT NULL
            BEGIN
                INSERT dbo.CERTIFICADOPLANTILLACARACTERISTICA
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

    SELECT 0 CodigoResultado,
           'Diseño de plantilla guardado correctamente.' Mensaje,
           @CertificadoPlantillaId CertificadoPlantillaId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ELIMINAR_PLANTILLA_CERTIFICADO
(
    @CertificadoPlantillaId INT,
    @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1 FROM dbo.CERTIFICADOPLANTILLA
        WHERE CertificadoPlantillaId = @CertificadoPlantillaId AND Estado = 1
    )
        THROW 50001, 'La plantilla de certificado no existe o ya está inactiva.', 1;

    UPDATE dbo.CERTIFICADOPLANTILLA
    SET Estado = 0,
        AudUsuarioModificacion = @Usuario,
        AudFechaActualizacion = SYSDATETIME()
    WHERE CertificadoPlantillaId = @CertificadoPlantillaId;

    SELECT 0 CodigoResultado,
           'Plantilla de certificado desactivada correctamente.' Mensaje,
           @CertificadoPlantillaId CertificadoPlantillaId;
END;
GO
