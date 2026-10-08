/*
 OVOCALIDAD 2.0
 Mantenedor de asignación de plantilla predeterminada de certificado.

 Regla:
 - Una sola plantilla activa predeterminada por versión FT.
 - El cambio no afecta certificados ya emitidos.
 - La emisión futura resuelve automáticamente la plantilla predeterminada.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ESTABLECER_PLANTILLA_PREDETERMINADA_CERTIFICADO
(
      @CertificadoPlantillaId INT
    , @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @Usuario=NULLIF(LTRIM(RTRIM(@Usuario)),'');

    IF @Usuario IS NULL
        THROW 50001,'El usuario es obligatorio.',1;

    DECLARE
          @VersionFtId INT
        , @Nombre VARCHAR(200);

    SELECT
          @VersionFtId=CP.VersionFtId
        , @Nombre=CP.Nombre
    FROM dbo.CERTIFICADOPLANTILLA CP
    WHERE CP.CertificadoPlantillaId=@CertificadoPlantillaId
      AND CP.Estado=1;

    IF @VersionFtId IS NULL
        THROW 50002,'La plantilla indicada no existe o está inactiva.',1;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.CERTIFICADOPLANTILLA
        SET
              EsPredeterminada=0
            , AudUsuarioModificacion=@Usuario
            , AudFechaActualizacion=SYSDATETIME()
        WHERE VersionFtId=@VersionFtId
          AND Estado=1
          AND EsPredeterminada=1
          AND CertificadoPlantillaId<>@CertificadoPlantillaId;

        UPDATE dbo.CERTIFICADOPLANTILLA
        SET
              EsPredeterminada=1
            , AudUsuarioModificacion=@Usuario
            , AudFechaActualizacion=SYSDATETIME()
        WHERE CertificadoPlantillaId=@CertificadoPlantillaId
          AND Estado=1;

        COMMIT TRANSACTION;

        SELECT
              0 CodigoResultado
            , CONCAT('La plantilla "',@Nombre,'" quedó establecida como predeterminada.') Mensaje
            , @CertificadoPlantillaId CertificadoPlantillaId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

SELECT
      0 CodigoResultado
    , 'Mantenedor de plantilla predeterminada configurado correctamente.' Mensaje;
GO
