CREATE OR ALTER PROCEDURE dbo.SP_ELIMINAR_FICHA_TECNICA_BORRADOR
(
    @VersionId INT,
    @Usuario   VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @DocumentoId INT,
        @EstVerId INT,
        @EstadoVersion VARCHAR(100);

    BEGIN TRY
        SET @Usuario = NULLIF(LTRIM(RTRIM(@Usuario)), '');

        IF @Usuario IS NULL
        BEGIN
            SELECT -1 AS CodigoResultado,
                   'No se pudo identificar al usuario.' AS Mensaje,
                   @VersionId AS VersionId;
            RETURN;
        END;

        SELECT
            @DocumentoId = V.DocumentoId,
            @EstVerId = V.EstVerId,
            @EstadoVersion = EV.EstVerDescripcion
        FROM dbo.VERSION V
        INNER JOIN dbo.DOCUMENTO D
            ON D.DocumentoId = V.DocumentoId
        INNER JOIN dbo.ESTADOVERSION EV
            ON EV.EstVerId = V.EstVerId
        WHERE V.VersionId = @VersionId
          AND V.Estado = 1
          AND D.Estado = 1
          AND D.TipoDocumentoId = 3;

        IF @DocumentoId IS NULL
        BEGIN
            SELECT -1 AS CodigoResultado,
                   'La versión de ficha técnica no existe o se encuentra inactiva.' AS Mensaje,
                   @VersionId AS VersionId;
            RETURN;
        END;

        IF @EstVerId <> 2 OR UPPER(ISNULL(@EstadoVersion, '')) <> 'BORRADOR'
        BEGIN
            SELECT -1 AS CodigoResultado,
                   'Solo se puede eliminar una versión de ficha técnica en estado BORRADOR.' AS Mensaje,
                   @VersionId AS VersionId;
            RETURN;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.CERTIFICADOPLANTILLA
            WHERE VersionFtId = @VersionId
              AND Estado = 1
        )
        BEGIN
            SELECT -1 AS CodigoResultado,
                   'No se puede eliminar la FT porque tiene plantillas de certificado activas.' AS Mensaje,
                   @VersionId AS VersionId;
            RETURN;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.CERTIFICADO
            WHERE VersionFtId = @VersionId
        )
        BEGIN
            SELECT -1 AS CodigoResultado,
                   'No se puede eliminar la FT porque ya fue utilizada en certificados.' AS Mensaje,
                   @VersionId AS VersionId;
            RETURN;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.VERSION
            WHERE VersionReemplazaAId = @VersionId
              AND Estado = 1
        )
        BEGIN
            SELECT -1 AS CodigoResultado,
                   'No se puede eliminar la FT porque otra versión activa la referencia como versión reemplazada.' AS Mensaje,
                   @VersionId AS VersionId;
            RETURN;
        END;

        BEGIN TRANSACTION;

        UPDATE dbo.VERSIONFTCARACTERISTICA
        SET
            Estado = 0,
            AudUsuarioModificacion = @Usuario,
            AudFechaActualizacion = SYSDATETIME()
        WHERE VersionId = @VersionId
          AND Estado = 1;

        UPDATE dbo.VERSION
        SET
            Estado = 0,
            AudUsuarioModificacion = @Usuario,
            AudFechaActualizacion = SYSDATETIME()
        WHERE VersionId = @VersionId
          AND Estado = 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.VERSION
            WHERE DocumentoId = @DocumentoId
              AND Estado = 1
        )
        BEGIN
            UPDATE dbo.DOCUMENTO
            SET
                Estado = 0,
                AudUsuarioModificacion = @Usuario,
                AudFechaActualizacion = SYSDATETIME()
            WHERE DocumentoId = @DocumentoId
              AND Estado = 1;
        END;

        COMMIT TRANSACTION;

        SELECT
            0 AS CodigoResultado,
            'Ficha técnica en borrador eliminada correctamente.' AS Mensaje,
            @VersionId AS VersionId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            -1 AS CodigoResultado,
            ERROR_MESSAGE() AS Mensaje,
            @VersionId AS VersionId;
    END CATCH;
END;
GO
