CREATE OR ALTER PROCEDURE dbo.SP_VINCULAR_PDF_ET
(
      @VersionId INT
    , @ArchivoOriginalNombre VARCHAR(500)
    , @ArchivoOriginalRuta VARCHAR(2000)
    , @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @ArchivoOriginalNombre = NULLIF(LTRIM(RTRIM(@ArchivoOriginalNombre)), '');
    SET @ArchivoOriginalRuta = NULLIF(LTRIM(RTRIM(@ArchivoOriginalRuta)), '');
    SET @Usuario = NULLIF(LTRIM(RTRIM(@Usuario)), '');

    IF @VersionId IS NULL OR @VersionId <= 0 OR @ArchivoOriginalNombre IS NULL OR @ArchivoOriginalRuta IS NULL OR @Usuario IS NULL
    BEGIN
        SELECT 1 AS CodigoResultado, 'Los datos para vincular el PDF son obligatorios.' AS Mensaje;
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.VERSION V WITH (UPDLOCK, HOLDLOCK)
            INNER JOIN dbo.ESTADOVERSION EV ON EV.EstVerId = V.EstVerId
            INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId = V.DocumentoId
            INNER JOIN dbo.TIPO_DOCUMENTO TD ON TD.TipoDocumentoId = D.TipoDocumentoId
            WHERE V.VersionId = @VersionId
              AND V.Estado = 1
              AND D.Estado = 1
              AND TD.Estado = 1
              AND TD.TipoDocumentoDescripcion = 'ESPECIFICACIÓN TÉCNICA'
              AND EV.EstVerDescripcion = 'BORRADOR'
        )
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 2 AS CodigoResultado, 'Solo se puede vincular o reemplazar el PDF de una Especificación Técnica en BORRADOR.' AS Mensaje;
            RETURN;
        END;

        UPDATE dbo.VERSION
           SET ArchivoOriginalNombre = @ArchivoOriginalNombre,
               ArchivoOriginalRuta = @ArchivoOriginalRuta,
               AudUsuarioModificacion = @Usuario,
               AudFechaActualizacion = SYSDATETIME()
         WHERE VersionId = @VersionId;

        COMMIT TRANSACTION;

        SELECT 0 AS CodigoResultado,
               'PDF oficial vinculado correctamente.' AS Mensaje,
               @VersionId AS VersionId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT -1 AS CodigoResultado, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END;
GO
