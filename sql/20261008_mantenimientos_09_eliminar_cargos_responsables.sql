/*
 OVOCALIDAD 2.0
 Eliminación segura de Cargos y Responsables.

 Regla:
 - Solo eliminar físicamente registros sin uso histórico.
 - Si existen relaciones documentales o de seguridad, no eliminar.
 - Nunca dejar relaciones huérfanas.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ELIMINAR_CARGO
(
      @CargoId INT
    , @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @CargoId IS NULL OR @CargoId <= 0
    BEGIN
        SELECT -1 CodigoResultado, 'El cargo indicado no es válido.' Mensaje, @CargoId CargoId;
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.CARGO WHERE CargoId=@CargoId)
    BEGIN
        SELECT -2 CodigoResultado, 'El cargo no existe.' Mensaje, @CargoId CargoId;
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        /* El historial de cargos es uso real del maestro. */
        IF OBJECT_ID('dbo.USUARIOCARGOHISTORIAL','U') IS NOT NULL
        BEGIN
            DECLARE @SqlUsoCargo NVARCHAR(MAX)=
                N'IF EXISTS(SELECT 1 FROM dbo.USUARIOCARGOHISTORIAL WHERE CargoId=@Id)
                  THROW 51001, ''No se puede eliminar el cargo porque tiene responsables o historial asociado. Inactívalo si ya no debe utilizarse.'', 1;';
            EXEC sys.sp_executesql @SqlUsoCargo,N'@Id INT',@Id=@CargoId;
        END
        ELSE IF OBJECT_ID('dbo.USUARIO_CARGO_HISTORIAL','U') IS NOT NULL
        BEGIN
            DECLARE @SqlUsoCargo2 NVARCHAR(MAX)=
                N'IF EXISTS(SELECT 1 FROM dbo.USUARIO_CARGO_HISTORIAL WHERE CargoId=@Id)
                  THROW 51001, ''No se puede eliminar el cargo porque tiene responsables o historial asociado. Inactívalo si ya no debe utilizarse.'', 1;';
            EXEC sys.sp_executesql @SqlUsoCargo2,N'@Id INT',@Id=@CargoId;
        END;

        DELETE FROM dbo.CARGO
        WHERE CargoId=@CargoId;

        COMMIT TRANSACTION;

        SELECT
              0 CodigoResultado
            , 'Cargo eliminado correctamente.' Mensaje
            , @CargoId CargoId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;

        IF ERROR_NUMBER()=51001
        BEGIN
            SELECT
                  2 CodigoResultado
                , ERROR_MESSAGE() Mensaje
                , @CargoId CargoId;
            RETURN;
        END;

        IF ERROR_NUMBER()=547
        BEGIN
            SELECT
                  3 CodigoResultado
                , 'No se puede eliminar el cargo porque posee relaciones históricas o activas. Inactívalo si ya no debe utilizarse.' Mensaje
                , @CargoId CargoId;
            RETURN;
        END;

        THROW;
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE dbo.SP_ELIMINAR_RESPONSABLE
(
      @UsuarioDni VARCHAR(20)
    , @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @UsuarioDni=NULLIF(LTRIM(RTRIM(@UsuarioDni)),'');

    IF @UsuarioDni IS NULL
    BEGIN
        SELECT -1 CodigoResultado, 'El responsable indicado no es válido.' Mensaje, @UsuarioDni UsuarioDni;
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.USUARIO WHERE UsuarioDni=@UsuarioDni)
    BEGIN
        SELECT -2 CodigoResultado, 'El responsable no existe.' Mensaje, @UsuarioDni UsuarioDni;
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        /* =====================================================
           VALIDAR USO DOCUMENTAL POR HISTORIAL DE CARGO
           ===================================================== */

        IF OBJECT_ID('dbo.USUARIOCARGOHISTORIAL','U') IS NOT NULL
           AND OBJECT_ID('dbo.VERSIONRESPONSABLE','U') IS NOT NULL
        BEGIN
            DECLARE @SqlUsoResponsable NVARCHAR(MAX)=
            N'
              IF EXISTS
              (
                  SELECT 1
                  FROM dbo.VERSIONRESPONSABLE VR
                  INNER JOIN dbo.USUARIOCARGOHISTORIAL UCH
                      ON UCH.UsuarioCargoHistorialId=VR.UsuarioCargoHistorialId
                  WHERE UCH.UsuarioDni=@Dni
              )
              THROW 51002, ''No se puede eliminar el responsable porque ya tiene uso documental histórico. Inactívalo si ya no debe utilizarse.'', 1;
            ';
            EXEC sys.sp_executesql @SqlUsoResponsable,N'@Dni VARCHAR(20)',@Dni=@UsuarioDni;
        END;

        IF OBJECT_ID('dbo.USUARIO_CARGO_HISTORIAL','U') IS NOT NULL
           AND OBJECT_ID('dbo.VERSION_RESPONSABLE','U') IS NOT NULL
        BEGIN
            DECLARE @SqlUsoResponsable2 NVARCHAR(MAX)=
            N'
              IF EXISTS
              (
                  SELECT 1
                  FROM dbo.VERSION_RESPONSABLE VR
                  INNER JOIN dbo.USUARIO_CARGO_HISTORIAL UCH
                      ON UCH.UsuarioCargoHistorialId=VR.UsuarioCargoHistorialId
                  WHERE UCH.UsuarioDni=@Dni
              )
              THROW 51002, ''No se puede eliminar el responsable porque ya tiene uso documental histórico. Inactívalo si ya no debe utilizarse.'', 1;
            ';
            EXEC sys.sp_executesql @SqlUsoResponsable2,N'@Dni VARCHAR(20)',@Dni=@UsuarioDni;
        END;

        /* Algunas instalaciones pueden guardar el DNI directamente
           en la relación de responsables. */
        IF OBJECT_ID('dbo.VERSIONRESPONSABLE','U') IS NOT NULL
           AND COL_LENGTH('dbo.VERSIONRESPONSABLE','UsuarioDni') IS NOT NULL
        BEGIN
            DECLARE @SqlUsoResponsable3 NVARCHAR(MAX)=
            N'
              IF EXISTS(SELECT 1 FROM dbo.VERSIONRESPONSABLE WHERE UsuarioDni=@Dni)
              THROW 51002, ''No se puede eliminar el responsable porque ya tiene uso documental histórico. Inactívalo si ya no debe utilizarse.'', 1;
            ';
            EXEC sys.sp_executesql @SqlUsoResponsable3,N'@Dni VARCHAR(20)',@Dni=@UsuarioDni;
        END;

        /* =====================================================
           ELIMINAR HISTORIAL DE CARGO SIN USO
           ===================================================== */

        IF OBJECT_ID('dbo.USUARIOCARGOHISTORIAL','U') IS NOT NULL
        BEGIN
            DECLARE @SqlDeleteHist NVARCHAR(MAX)=
                N'DELETE FROM dbo.USUARIOCARGOHISTORIAL WHERE UsuarioDni=@Dni;';
            EXEC sys.sp_executesql @SqlDeleteHist,N'@Dni VARCHAR(20)',@Dni=@UsuarioDni;
        END
        ELSE IF OBJECT_ID('dbo.USUARIO_CARGO_HISTORIAL','U') IS NOT NULL
        BEGIN
            DECLARE @SqlDeleteHist2 NVARCHAR(MAX)=
                N'DELETE FROM dbo.USUARIO_CARGO_HISTORIAL WHERE UsuarioDni=@Dni;';
            EXEC sys.sp_executesql @SqlDeleteHist2,N'@Dni VARCHAR(20)',@Dni=@UsuarioDni;
        END;

        DELETE FROM dbo.USUARIO
        WHERE UsuarioDni=@UsuarioDni;

        COMMIT TRANSACTION;

        SELECT
              0 CodigoResultado
            , 'Responsable eliminado correctamente.' Mensaje
            , @UsuarioDni UsuarioDni;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;

        IF ERROR_NUMBER()=51002
        BEGIN
            SELECT
                  2 CodigoResultado
                , ERROR_MESSAGE() Mensaje
                , @UsuarioDni UsuarioDni;
            RETURN;
        END;

        IF ERROR_NUMBER()=547
        BEGIN
            SELECT
                  3 CodigoResultado
                , 'No se puede eliminar el responsable porque posee relaciones históricas, documentales o de seguridad. Inactívalo si ya no debe utilizarse.' Mensaje
                , @UsuarioDni UsuarioDni;
            RETURN;
        END;

        THROW;
    END CATCH;
END;
GO
