/*
 OVOCALIDAD 2.0
 Firma gráfica opcional por responsable.

 IMPORTANTE:
 Esta tabla almacena la imagen de firma disponible del responsable.
 NO representa todavía el acto de firma de una ET/FT/Certificado.
 El acto de firma documental tendrá su propio historial/evidencia.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID('dbo.RESPONSABLE_FIRMA','U') IS NULL
BEGIN
    CREATE TABLE dbo.RESPONSABLE_FIRMA
    (
          ResponsableFirmaId      INT IDENTITY(1,1) NOT NULL
        , UsuarioDni              VARCHAR(20) NOT NULL
        , FirmaImagen             VARBINARY(MAX) NOT NULL
        , FirmaMimeType           VARCHAR(50) NOT NULL
        , FirmaNombreArchivo      VARCHAR(255) NULL
        , Estado                  BIT NOT NULL
            CONSTRAINT DF_RESPONSABLE_FIRMA_Estado DEFAULT(1)
        , AudUsuarioCreacion      VARCHAR(100) NOT NULL
        , AudFechaCreacion        DATETIME2(0) NOT NULL
            CONSTRAINT DF_RESPONSABLE_FIRMA_FechaCreacion DEFAULT(SYSDATETIME())
        , AudUsuarioModificacion  VARCHAR(100) NULL
        , AudFechaActualizacion   DATETIME2(0) NULL

        , CONSTRAINT PK_RESPONSABLE_FIRMA
            PRIMARY KEY (ResponsableFirmaId)

        , CONSTRAINT UQ_RESPONSABLE_FIRMA_UsuarioDni
            UNIQUE (UsuarioDni)
    );
END;
GO


CREATE OR ALTER PROCEDURE dbo.SP_GUARDAR_FIRMA_RESPONSABLE
(
      @UsuarioDni          VARCHAR(20)
    , @FirmaImagen         VARBINARY(MAX)
    , @FirmaMimeType       VARCHAR(50)
    , @FirmaNombreArchivo  VARCHAR(255) = NULL
    , @Usuario             VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @UsuarioDni = NULLIF(LTRIM(RTRIM(@UsuarioDni)), '');
    SET @FirmaMimeType = NULLIF(LTRIM(RTRIM(@FirmaMimeType)), '');
    SET @Usuario = NULLIF(LTRIM(RTRIM(@Usuario)), '');

    IF @UsuarioDni IS NULL
    BEGIN
        SELECT -1 CodigoResultado,
               'El responsable es obligatorio.' Mensaje,
               @UsuarioDni UsuarioDni;
        RETURN;
    END;

    IF @Usuario IS NULL
    BEGIN
        SELECT -2 CodigoResultado,
               'El usuario de auditoría es obligatorio.' Mensaje,
               @UsuarioDni UsuarioDni;
        RETURN;
    END;

    IF @FirmaImagen IS NULL OR DATALENGTH(@FirmaImagen) = 0
    BEGIN
        SELECT -3 CodigoResultado,
               'La imagen de firma es obligatoria.' Mensaje,
               @UsuarioDni UsuarioDni;
        RETURN;
    END;

    IF DATALENGTH(@FirmaImagen) > 2000000
    BEGIN
        SELECT -4 CodigoResultado,
               'La imagen de firma no debe superar 2 MB.' Mensaje,
               @UsuarioDni UsuarioDni;
        RETURN;
    END;

    IF @FirmaMimeType NOT IN ('image/png','image/jpeg','image/webp')
    BEGIN
        SELECT -5 CodigoResultado,
               'Formato de firma no permitido. Usa PNG, JPG/JPEG o WEBP.' Mensaje,
               @UsuarioDni UsuarioDni;
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.USUARIO
        WHERE UsuarioDni = @UsuarioDni
    )
    BEGIN
        SELECT -6 CodigoResultado,
               'El responsable indicado no existe.' Mensaje,
               @UsuarioDni UsuarioDni;
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.RESPONSABLE_FIRMA
            WHERE UsuarioDni = @UsuarioDni
        )
        BEGIN
            UPDATE dbo.RESPONSABLE_FIRMA
            SET
                  FirmaImagen = @FirmaImagen
                , FirmaMimeType = @FirmaMimeType
                , FirmaNombreArchivo = @FirmaNombreArchivo
                , Estado = 1
                , AudUsuarioModificacion = @Usuario
                , AudFechaActualizacion = SYSDATETIME()
            WHERE UsuarioDni = @UsuarioDni;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.RESPONSABLE_FIRMA
            (
                  UsuarioDni
                , FirmaImagen
                , FirmaMimeType
                , FirmaNombreArchivo
                , Estado
                , AudUsuarioCreacion
                , AudFechaCreacion
            )
            VALUES
            (
                  @UsuarioDni
                , @FirmaImagen
                , @FirmaMimeType
                , @FirmaNombreArchivo
                , 1
                , @Usuario
                , SYSDATETIME()
            );
        END;

        COMMIT TRANSACTION;

        SELECT
              0 CodigoResultado
            , 'Firma registrada correctamente.' Mensaje
            , @UsuarioDni UsuarioDni;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE dbo.SP_OBTENER_FIRMA_RESPONSABLE
(
    @UsuarioDni VARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP(1)
          0 CodigoResultado
        , 'OK' Mensaje
        , RF.UsuarioDni
        , RF.FirmaMimeType
        , RF.FirmaNombreArchivo
        , RF.FirmaImagen
        , COALESCE(RF.AudFechaActualizacion, RF.AudFechaCreacion)
            AS FechaActualizacion
    FROM dbo.RESPONSABLE_FIRMA RF
    WHERE RF.UsuarioDni = @UsuarioDni
      AND RF.Estado = 1;
END;
GO


CREATE OR ALTER PROCEDURE dbo.SP_ELIMINAR_FIRMA_RESPONSABLE
(
      @UsuarioDni VARCHAR(20)
    , @Usuario    VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.RESPONSABLE_FIRMA
        WHERE UsuarioDni = @UsuarioDni
          AND Estado = 1
    )
    BEGIN
        SELECT
              1 CodigoResultado
            , 'El responsable no tiene una firma registrada.' Mensaje
            , @UsuarioDni UsuarioDni;
        RETURN;
    END;

    DELETE FROM dbo.RESPONSABLE_FIRMA
    WHERE UsuarioDni = @UsuarioDni;

    SELECT
          0 CodigoResultado
        , 'Firma eliminada correctamente.' Mensaje
        , @UsuarioDni UsuarioDni;
END;
GO
