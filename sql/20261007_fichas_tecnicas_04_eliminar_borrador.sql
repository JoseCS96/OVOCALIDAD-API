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
        @VersionReemplazaAId INT;

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
            @VersionReemplazaAId = V.VersionReemplazaAId
        FROM dbo.VERSION V
        INNER JOIN dbo.DOCUMENTO D
            ON D.DocumentoId = V.DocumentoId
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

        /* Una FT utilizada en certificados emitidos ya es evidencia histórica. */
        IF EXISTS
        (
            SELECT 1
            FROM dbo.CERTIFICADO
            WHERE VersionFtId = @VersionId
        )
        BEGIN
            SELECT -1 AS CodigoResultado,
                   'No se puede eliminar la FT porque ya fue utilizada en certificados emitidos.' AS Mensaje,
                   @VersionId AS VersionId;
            RETURN;
        END;

        BEGIN TRANSACTION;

        /* Si una versión posterior reemplaza a la versión eliminada,
           la enlazamos con el reemplazo anterior para no dejar referencias
           activas apuntando a una versión inactiva. */
        UPDATE dbo.VERSION
        SET
            VersionReemplazaAId = @VersionReemplazaAId,
            AudUsuarioModificacion = @Usuario,
            AudFechaActualizacion = SYSDATETIME()
        WHERE VersionReemplazaAId = @VersionId
          AND Estado = 1;

        /* Desactivar diseño de certificado asociado a esta FT. */
        UPDATE CPC
        SET
            CPC.Estado = 0,
            CPC.AudUsuarioModificacion = @Usuario,
            CPC.AudFechaActualizacion = SYSDATETIME()
        FROM dbo.CERTIFICADOPLANTILLACARACTERISTICA CPC
        INNER JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
            ON CPS.CertificadoPlantillaSeccionId = CPC.CertificadoPlantillaSeccionId
        INNER JOIN dbo.CERTIFICADOPLANTILLA CP
            ON CP.CertificadoPlantillaId = CPS.CertificadoPlantillaId
        WHERE CP.VersionFtId = @VersionId
          AND CPC.Estado = 1;

        UPDATE CPS
        SET
            CPS.Estado = 0,
            CPS.AudUsuarioModificacion = @Usuario,
            CPS.AudFechaActualizacion = SYSDATETIME()
        FROM dbo.CERTIFICADOPLANTILLASECCION CPS
        INNER JOIN dbo.CERTIFICADOPLANTILLA CP
            ON CP.CertificadoPlantillaId = CPS.CertificadoPlantillaId
        WHERE CP.VersionFtId = @VersionId
          AND CPS.Estado = 1;

        UPDATE dbo.CERTIFICADOPLANTILLA
        SET
            Estado = 0,
            AudUsuarioModificacion = @Usuario,
            AudFechaActualizacion = SYSDATETIME()
        WHERE VersionFtId = @VersionId
          AND Estado = 1;

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
            'Ficha técnica eliminada correctamente.' AS Mensaje,
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
