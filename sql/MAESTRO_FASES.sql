/* Maestro compartido FASE: no altera registros existentes.
   Ejecutar en OVOCALIDAD, revisar en desarrollo antes de producción. */
CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_FASES
 @Buscar VARCHAR(150)=NULL,
 @IncluirInactivos BIT=1
AS
BEGIN
 SET NOCOUNT ON;
 SELECT FaseId,Codigo,Descripcion,Estado,FechaCreacion,UsuarioCreacion,
        FechaModificacion,UsuarioModificacion
 FROM dbo.FASE
 WHERE (@IncluirInactivos=1 OR Estado='ACTIVO')
   AND (NULLIF(LTRIM(RTRIM(@Buscar)),'') IS NULL
        OR Codigo LIKE '%'+LTRIM(RTRIM(@Buscar))+'%'
        OR Descripcion LIKE '%'+LTRIM(RTRIM(@Buscar))+'%')
 ORDER BY Descripcion,FaseId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_GUARDAR_FASE
 @FaseId INT=NULL,
 @Codigo VARCHAR(20),
 @Descripcion VARCHAR(150),
 @Usuario INT=NULL
AS
BEGIN
 SET NOCOUNT ON;
 SET XACT_ABORT ON;
 SET @Codigo=UPPER(LTRIM(RTRIM(@Codigo)));
 SET @Descripcion=LTRIM(RTRIM(@Descripcion));
 IF NULLIF(@Codigo,'') IS NULL OR NULLIF(@Descripcion,'') IS NULL
     THROW 51001,'Codigo y descripcion son obligatorios.',1;
 IF @FaseId IS NOT NULL AND @FaseId<=0
     THROW 51002,'FaseId no valido.',1;
 BEGIN TRY
  BEGIN TRANSACTION;
  IF EXISTS(SELECT 1 FROM dbo.FASE WITH(UPDLOCK,HOLDLOCK)
            WHERE Codigo=@Codigo AND (@FaseId IS NULL OR FaseId<>@FaseId))
     THROW 51003,'El codigo de fase ya existe.',1;
  IF @FaseId IS NULL
  BEGIN
   /* FaseId no es IDENTITY: serializar altas para proteger MAX+1. */
   DECLARE @LockResult INT;
   EXEC @LockResult=sys.sp_getapplock
       @Resource='OVOCALIDAD_DBO_FASE_NUEVO_ID',
       @LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=10000;
   IF @LockResult<0 THROW 51004,'No se pudo reservar el identificador de fase.',1;
   SELECT @FaseId=ISNULL(MAX(FaseId),0)+1 FROM dbo.FASE WITH(UPDLOCK,HOLDLOCK);
   INSERT dbo.FASE(FaseId,Codigo,Descripcion,Estado,FechaCreacion,UsuarioCreacion)
   VALUES(@FaseId,@Codigo,@Descripcion,'ACTIVO',SYSDATETIME(),@Usuario);
  END
  ELSE
  BEGIN
   IF NOT EXISTS(SELECT 1 FROM dbo.FASE WITH(UPDLOCK,HOLDLOCK) WHERE FaseId=@FaseId)
      THROW 51005,'La fase no existe.',1;
   UPDATE dbo.FASE
   SET Codigo=@Codigo,Descripcion=@Descripcion,
       FechaModificacion=SYSDATETIME(),UsuarioModificacion=@Usuario
   WHERE FaseId=@FaseId;
  END
  COMMIT TRANSACTION;
  SELECT FaseId,Codigo,Descripcion,Estado FROM dbo.FASE WHERE FaseId=@FaseId;
 END TRY
 BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
  THROW;
 END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_CAMBIAR_ESTADO_FASE
 @FaseId INT,
 @Estado VARCHAR(20),
 @Usuario INT=NULL
AS
BEGIN
 SET NOCOUNT ON;
 SET XACT_ABORT ON;
 SET @Estado=UPPER(LTRIM(RTRIM(@Estado)));
 IF @Estado NOT IN('ACTIVO','INACTIVO')
    THROW 51006,'Estado no valido: ACTIVO o INACTIVO.',1;
 BEGIN TRY
  BEGIN TRANSACTION;
  IF NOT EXISTS(SELECT 1 FROM dbo.FASE WITH(UPDLOCK,HOLDLOCK) WHERE FaseId=@FaseId)
     THROW 51007,'La fase no existe.',1;
  /* Los registros historicos y las FK permanecen intactos. */
  UPDATE dbo.FASE SET Estado=@Estado,
       FechaModificacion=SYSDATETIME(),UsuarioModificacion=@Usuario
  WHERE FaseId=@FaseId;
  COMMIT TRANSACTION;
  SELECT FaseId,Codigo,Descripcion,Estado FROM dbo.FASE WHERE FaseId=@FaseId;
 END TRY
 BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
  THROW;
 END CATCH
END;
GO
