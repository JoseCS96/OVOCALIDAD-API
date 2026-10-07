/*
 OVOCALIDAD 2.0 - Eliminación física controlada de Ficha Técnica.

 TEMPORAL PARA LIMPIEZA DE DATA DE PRUEBA:
 - Permite eliminar FT en cualquier estado documental.
 - No permite eliminar si existen certificados emitidos.
 - Elimina trazabilidad, diseño, secciones y características.
 - Si el documento FT queda sin versiones, elimina también DOCUMENTO.
*/
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
          @DocumentoId INT
        , @VersionReemplazaAId INT
        , @EstVerId INT;

    BEGIN TRY
        SET @Usuario = NULLIF(LTRIM(RTRIM(@Usuario)), '');

        IF @Usuario IS NULL
        BEGIN
            SELECT -1 AS CodigoResultado,
                   'No se pudo identificar al usuario.' AS Mensaje,
                   @VersionId AS VersionId;
            RETURN;
        END;

        /*
          Importante: no filtramos por Estado.
          Esto permite limpiar físicamente una FT que haya sido
          desactivada por la versión anterior del SP.
        */
        SELECT
              @DocumentoId = V.DocumentoId
            , @VersionReemplazaAId = V.VersionReemplazaAId
            , @EstVerId = V.EstVerId
        FROM dbo.VERSION V
        INNER JOIN dbo.DOCUMENTO D
            ON D.DocumentoId = V.DocumentoId
        WHERE V.VersionId = @VersionId
          AND D.TipoDocumentoId = 3;

        IF @DocumentoId IS NULL
        BEGIN
            SELECT 0 AS CodigoResultado,
                   'La ficha técnica ya no existe en la base de datos.' AS Mensaje,
                   @VersionId AS VersionId;
            RETURN;
        END;

        /* Una FT utilizada en certificados es evidencia histórica. */
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

        /*
          Si alguna versión posterior apuntara a esta como reemplazada,
          la enlazamos con el reemplazo anterior antes de borrar.
        */
        UPDATE dbo.VERSION
        SET
              VersionReemplazaAId = @VersionReemplazaAId
            , AudUsuarioModificacion = @Usuario
            , AudFechaActualizacion = SYSDATETIME()
        WHERE VersionReemplazaAId = @VersionId;

        /* =====================================================
           1. DISEÑO DE CERTIFICADO
           ===================================================== */

        DELETE CPC
        FROM dbo.CERTIFICADOPLANTILLACARACTERISTICA CPC
        INNER JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
            ON CPS.CertificadoPlantillaSeccionId =
               CPC.CertificadoPlantillaSeccionId
        INNER JOIN dbo.CERTIFICADOPLANTILLA CP
            ON CP.CertificadoPlantillaId =
               CPS.CertificadoPlantillaId
        WHERE CP.VersionFtId = @VersionId;

        DELETE CPS
        FROM dbo.CERTIFICADOPLANTILLASECCION CPS
        INNER JOIN dbo.CERTIFICADOPLANTILLA CP
            ON CP.CertificadoPlantillaId =
               CPS.CertificadoPlantillaId
        WHERE CP.VersionFtId = @VersionId;

        DELETE FROM dbo.CERTIFICADOPLANTILLA
        WHERE VersionFtId = @VersionId;


        /* =====================================================
           2. DISEÑO PROPIO DE FT
           ===================================================== */

        IF OBJECT_ID('dbo.VERSIONFTSECCION', 'U') IS NOT NULL
        BEGIN
            DELETE FROM dbo.VERSIONFTSECCION
            WHERE VersionId = @VersionId;
        END;


        /* =====================================================
           3. ESTRUCTURA LEGACY DE SECCIONES FT
              Se conserva para limpiar datos creados antes del
              diseñador propio VERSIONFTSECCION.
           ===================================================== */

        IF OBJECT_ID('dbo.VERSIONSECCIONCONTENIDO', 'U') IS NOT NULL
           AND OBJECT_ID('dbo.VERSIONSECCION', 'U') IS NOT NULL
        BEGIN
            DELETE VSC
            FROM dbo.VERSIONSECCIONCONTENIDO VSC
            INNER JOIN dbo.VERSIONSECCION VS
                ON VS.VersSeccId = VSC.VersSeccId
            WHERE VS.VersionId = @VersionId;
        END;

        IF OBJECT_ID('dbo.VERSIONSECCION', 'U') IS NOT NULL
        BEGIN
            DELETE FROM dbo.VERSIONSECCION
            WHERE VersionId = @VersionId;
        END;


        /* =====================================================
           4. CARACTERÍSTICAS PROPIAS DE FT
           ===================================================== */

        DELETE FROM dbo.VERSIONFTCARACTERISTICA
        WHERE VersionId = @VersionId;


        /* =====================================================
           5. TRAZABILIDAD DE ESTADOS
           ===================================================== */

        DELETE FROM dbo.VERSIONHISTORIALESTADO
        WHERE VersionId = @VersionId;


        /* =====================================================
           6. VERSION FT
           ===================================================== */

        DELETE FROM dbo.VERSION
        WHERE VersionId = @VersionId;


        /* =====================================================
           7. DOCUMENTO FT
              Solo se elimina cuando ya no tiene ninguna versión.
           ===================================================== */

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.VERSION
            WHERE DocumentoId = @DocumentoId
        )
        BEGIN
            DELETE FROM dbo.DOCUMENTO
            WHERE DocumentoId = @DocumentoId;
        END;

        COMMIT TRANSACTION;

        SELECT
              0 AS CodigoResultado
            , 'Ficha técnica eliminada físicamente de la base de datos.' AS Mensaje
            , @VersionId AS VersionId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
              -1 AS CodigoResultado
            , ERROR_MESSAGE() AS Mensaje
            , @VersionId AS VersionId;
    END CATCH;
END;
GO
