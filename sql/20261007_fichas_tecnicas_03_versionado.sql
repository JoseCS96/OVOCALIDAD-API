/* OVOCALIDAD - FT: documento unico por producto + version ET origen */
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF COL_LENGTH('dbo.VERSION', 'VersionEtOrigenId') IS NULL
BEGIN
    ALTER TABLE dbo.VERSION
    ADD VersionEtOrigenId INT NULL;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_VERSION_VERSION_ET_ORIGEN'
      AND parent_object_id = OBJECT_ID('dbo.VERSION')
)
BEGIN
    ALTER TABLE dbo.VERSION WITH CHECK
    ADD CONSTRAINT FK_VERSION_VERSION_ET_ORIGEN
        FOREIGN KEY (VersionEtOrigenId)
        REFERENCES dbo.VERSION(VersionId);

    ALTER TABLE dbo.VERSION
        CHECK CONSTRAINT FK_VERSION_VERSION_ET_ORIGEN;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.VERSION')
      AND name = 'IX_VERSION_VERSION_ET_ORIGEN'
)
BEGIN
    CREATE INDEX IX_VERSION_VERSION_ET_ORIGEN
        ON dbo.VERSION(VersionEtOrigenId)
        WHERE VersionEtOrigenId IS NOT NULL;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_CREAR_FICHA_TECNICA
(
    @DocumentoCodigo               VARCHAR(50),
    @DocumentoDescripcionDocumento VARCHAR(500),
    @ProductoCodigo                VARCHAR(50) = NULL,
    @VersionNumero                 DECIMAL(18,4) = NULL,
    @VersionInicioVigencia         DATE = NULL,
    @VersionReemplazaAId           INT = NULL,
    @VersionNroPaginas             INT = NULL,
    @VersionDescripcion            VARCHAR(2000) = NULL,
    @VersionEtOrigenId             INT = NULL,
    @Usuario                       VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @DocumentoId INT,
        @VersionId INT,
        @DocumentoExistente BIT = 0;

    BEGIN TRY
        SET @DocumentoCodigo = NULLIF(LTRIM(RTRIM(@DocumentoCodigo)), '');
        SET @DocumentoDescripcionDocumento = NULLIF(LTRIM(RTRIM(@DocumentoDescripcionDocumento)), '');
        SET @ProductoCodigo = NULLIF(LTRIM(RTRIM(@ProductoCodigo)), '');
        SET @VersionDescripcion = NULLIF(LTRIM(RTRIM(@VersionDescripcion)), '');
        SET @Usuario = NULLIF(LTRIM(RTRIM(@Usuario)), '');

        IF @ProductoCodigo IS NULL
        BEGIN
            SELECT -1 CodigoResultado, 'Debe seleccionar el producto de la ficha técnica.' Mensaje,
                   CAST(NULL AS INT) DocumentoId, CAST(NULL AS INT) VersionId;
            RETURN;
        END;

        IF @DocumentoCodigo IS NULL
        BEGIN
            SELECT -1 CodigoResultado, 'Debe ingresar el código de la ficha técnica.' Mensaje,
                   CAST(NULL AS INT) DocumentoId, CAST(NULL AS INT) VersionId;
            RETURN;
        END;

        IF @DocumentoDescripcionDocumento IS NULL
        BEGIN
            SELECT -1 CodigoResultado, 'Debe ingresar la descripción de la ficha técnica.' Mensaje,
                   CAST(NULL AS INT) DocumentoId, CAST(NULL AS INT) VersionId;
            RETURN;
        END;

        IF @Usuario IS NULL
        BEGIN
            SELECT -1 CodigoResultado, 'No se pudo identificar al usuario.' Mensaje,
                   CAST(NULL AS INT) DocumentoId, CAST(NULL AS INT) VersionId;
            RETURN;
        END;

        IF NOT EXISTS (
            SELECT 1 FROM dbo.TIPO_DOCUMENTO
            WHERE TipoDocumentoId = 3
              AND TipoDocumentoDescripcion = 'FICHA TÉCNICA'
              AND Estado = 1
        )
        BEGIN
            SELECT -1 CodigoResultado, 'El tipo documental FICHA TÉCNICA no está configurado.' Mensaje,
                   CAST(NULL AS INT) DocumentoId, CAST(NULL AS INT) VersionId;
            RETURN;
        END;

        IF NOT EXISTS (
            SELECT 1 FROM dbo.ESTADOVERSION
            WHERE EstVerId = 2
              AND EstVerDescripcion = 'BORRADOR'
              AND Estado = 1
        )
        BEGIN
            SELECT -1 CodigoResultado, 'El estado BORRADOR no está configurado.' Mensaje,
                   CAST(NULL AS INT) DocumentoId, CAST(NULL AS INT) VersionId;
            RETURN;
        END;

        IF @VersionEtOrigenId IS NOT NULL
           AND NOT EXISTS (
               SELECT 1
               FROM dbo.VERSION VE
               INNER JOIN dbo.DOCUMENTO DE ON DE.DocumentoId = VE.DocumentoId
               WHERE VE.VersionId = @VersionEtOrigenId
                 AND VE.Estado = 1
                 AND DE.Estado = 1
                 AND DE.TipoDocumentoId = 1
                 AND DE.ProductoCodigo = @ProductoCodigo
           )
        BEGIN
            SELECT -1 CodigoResultado,
                   'La versión ET origen no existe, está inactiva o no corresponde al producto seleccionado.' Mensaje,
                   CAST(NULL AS INT) DocumentoId, CAST(NULL AS INT) VersionId;
            RETURN;
        END;

        IF (
            SELECT COUNT(*)
            FROM dbo.DOCUMENTO D
            WHERE D.TipoDocumentoId = 3
              AND D.ProductoCodigo = @ProductoCodigo
              AND D.Estado = 1
        ) > 1
        BEGIN
            SELECT -1 CodigoResultado,
                   'El producto tiene más de un documento FT activo. Debe regularizarse antes de crear una nueva versión.' Mensaje,
                   CAST(NULL AS INT) DocumentoId, CAST(NULL AS INT) VersionId;
            RETURN;
        END;

        SELECT @DocumentoId = MIN(D.DocumentoId)
        FROM dbo.DOCUMENTO D
        WHERE D.TipoDocumentoId = 3
          AND D.ProductoCodigo = @ProductoCodigo
          AND D.Estado = 1;

        IF @DocumentoId IS NOT NULL
            SET @DocumentoExistente = 1;

        IF EXISTS (
            SELECT 1
            FROM dbo.DOCUMENTO D
            WHERE D.DocumentoCodigo = @DocumentoCodigo
              AND (@DocumentoId IS NULL OR D.DocumentoId <> @DocumentoId)
        )
        BEGIN
            SELECT -1 CodigoResultado, 'Ya existe un documento con ese código.' Mensaje,
                   CAST(NULL AS INT) DocumentoId, CAST(NULL AS INT) VersionId;
            RETURN;
        END;

        IF @DocumentoExistente = 1
        BEGIN
            SELECT
                @DocumentoCodigo = D.DocumentoCodigo,
                @DocumentoDescripcionDocumento = D.DocumentoDescripcionDocumento
            FROM dbo.DOCUMENTO D
            WHERE D.DocumentoId = @DocumentoId;

            IF @VersionNumero IS NULL
            BEGIN
                SELECT @VersionNumero = ISNULL(MAX(V.VersionNumero), 0) + 1
                FROM dbo.VERSION V
                WHERE V.DocumentoId = @DocumentoId;
            END;

            IF @VersionReemplazaAId IS NULL
            BEGIN
                SELECT TOP (1) @VersionReemplazaAId = V.VersionId
                FROM dbo.VERSION V
                WHERE V.DocumentoId = @DocumentoId
                  AND V.Estado = 1
                ORDER BY V.VersionNumero DESC, V.VersionId DESC;
            END;
        END
        ELSE IF @VersionNumero IS NULL
            SET @VersionNumero = 1;

        IF @DocumentoId IS NOT NULL
           AND EXISTS (
               SELECT 1
               FROM dbo.VERSION V
               WHERE V.DocumentoId = @DocumentoId
                 AND V.VersionNumero = @VersionNumero
                 AND V.Estado = 1
           )
        BEGIN
            SELECT -1 CodigoResultado, 'Ya existe esa versión para la ficha técnica del producto.' Mensaje,
                   @DocumentoId DocumentoId, CAST(NULL AS INT) VersionId;
            RETURN;
        END;

        IF @VersionReemplazaAId IS NOT NULL
           AND (
               @DocumentoId IS NULL
               OR NOT EXISTS (
                   SELECT 1
                   FROM dbo.VERSION V
                   WHERE V.VersionId = @VersionReemplazaAId
                     AND V.DocumentoId = @DocumentoId
               )
           )
        BEGIN
            SELECT -1 CodigoResultado,
                   'La versión indicada como reemplazada no pertenece a la ficha técnica del producto.' Mensaje,
                   @DocumentoId DocumentoId, CAST(NULL AS INT) VersionId;
            RETURN;
        END;

        BEGIN TRANSACTION;

        IF @DocumentoExistente = 0
        BEGIN
            INSERT INTO dbo.DOCUMENTO
            (
                DocumentoCodigo, DocumentoDescripcionDocumento, TipoDocumentoId,
                ProductoCodigo, Estado, AudUsuarioCreacion, AudFechaCreacion
            )
            VALUES
            (
                @DocumentoCodigo, @DocumentoDescripcionDocumento, 3,
                @ProductoCodigo, 1, @Usuario, SYSDATETIME()
            );

            SET @DocumentoId = CONVERT(INT, SCOPE_IDENTITY());
        END;

        INSERT INTO dbo.VERSION
        (
            DocumentoId, EstVerId, VersionInicioVigencia, VersionFinVigencia,
            VersionReemplazaAId, VersionNroPaginas, VersionFechaFirmado,
            VersionNumero, Estado, AudUsuarioCreacion, AudFechaCreacion,
            VersionDescripcion, VersionEtOrigenId
        )
        VALUES
        (
            @DocumentoId, 2, @VersionInicioVigencia, NULL,
            @VersionReemplazaAId, @VersionNroPaginas, NULL,
            @VersionNumero, 1, @Usuario, SYSDATETIME(),
            @VersionDescripcion, @VersionEtOrigenId
        );

        SET @VersionId = CONVERT(INT, SCOPE_IDENTITY());

        /* =====================================================
           INICIALIZAR CARACTERÍSTICAS PROPIAS DE FT
           Se copian desde la ET manteniendo trazabilidad exacta
           VersCaractOrigenId + fase + orden técnico.
           ===================================================== */
        IF @VersionEtOrigenId IS NOT NULL
        BEGIN
            EXEC dbo.SP_INICIALIZAR_CARACTERISTICAS_FT
                 @VersionFtId = @VersionId,
                 @Usuario = @Usuario;
        END;


        /* =====================================================
           INICIALIZAR SECCIONES PROPIAS DE FT
           Se toma una COPIA de la estructura activa de la ET origen.
           A partir de aquí la FT queda independiente.
           ===================================================== */
        IF @VersionEtOrigenId IS NOT NULL
        BEGIN
            EXEC dbo.SP_INICIALIZAR_SECCIONES_FT
                 @VersionId = @VersionId,
                 @Usuario = @Usuario;
        END;

        COMMIT TRANSACTION;

        SELECT
            0 CodigoResultado,
            CASE WHEN @DocumentoExistente = 1
                 THEN 'Nueva versión de ficha técnica creada correctamente.'
                 ELSE 'Ficha técnica creada correctamente.'
            END Mensaje,
            D.DocumentoId,
            D.DocumentoCodigo,
            D.DocumentoDescripcionDocumento,
            D.TipoDocumentoId,
            TD.TipoDocumentoDescripcion,
            D.ProductoCodigo,
            V.VersionId,
            V.VersionNumero,
            V.EstVerId,
            EV.EstVerDescripcion EstadoVersion,
            V.VersionInicioVigencia,
            V.VersionReemplazaAId,
            V.VersionNroPaginas,
            V.VersionDescripcion,
            V.VersionEtOrigenId
        FROM dbo.DOCUMENTO D
        INNER JOIN dbo.TIPO_DOCUMENTO TD ON TD.TipoDocumentoId = D.TipoDocumentoId
        INNER JOIN dbo.VERSION V ON V.DocumentoId = D.DocumentoId
        INNER JOIN dbo.ESTADOVERSION EV ON EV.EstVerId = V.EstVerId
        WHERE D.DocumentoId = @DocumentoId
          AND V.VersionId = @VersionId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT -1 CodigoResultado, ERROR_MESSAGE() Mensaje,
               CAST(NULL AS INT) DocumentoId, CAST(NULL AS INT) VersionId;
    END CATCH;
END;
GO
