/* Ejecutar primero. Migración no destructiva; conserva el maestro. */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRAN;
 IF COL_LENGTH('dbo.VERSIONCARACTERISTICA','UnidadDeMedida') IS NULL
    ALTER TABLE dbo.VERSIONCARACTERISTICA ADD UnidadDeMedida VARCHAR(50) NULL;
 IF COL_LENGTH('dbo.CARACTERISTICA','CaracteristicaUnidadDeMedida') IS NOT NULL
 BEGIN
   EXEC sys.sp_executesql N'
     UPDATE VC SET UnidadDeMedida = NULLIF(LTRIM(RTRIM(C.CaracteristicaUnidadDeMedida)),'''')
     FROM dbo.VERSIONCARACTERISTICA VC
     INNER JOIN dbo.CARACTERISTICA C ON C.CaracteristicaId=VC.CaracteristicaId
     WHERE VC.UnidadDeMedida IS NULL;';
 END;
 COMMIT;
END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK;
 THROW;
END CATCH;
GO
/* Adaptación conservadora de SP_GUARDAR_CARACTERISTICA_ET.
   Preserva todas las validaciones actuales y modifica solo firma, INSERT,
   UPDATE y respuesta. Aborta si no reconoce la definición actual. */
DECLARE @Sql NVARCHAR(MAX)=OBJECT_DEFINITION(OBJECT_ID(N'dbo.SP_GUARDAR_CARACTERISTICA_ET',N'P'));
IF @Sql IS NULL THROW 52001,'No existe SP_GUARDAR_CARACTERISTICA_ET.',1;
IF CHARINDEX('@UnidadDeMedida',@Sql)>0
BEGIN PRINT 'SP de guardado ya contiene @UnidadDeMedida'; RETURN; END;
IF CHARINDEX('@FaseId                     INT = NULL,',@Sql)=0
 THROW 52002,'Firma diferente a la proporcionada; revisar manualmente.',1;
SET @Sql=REPLACE(@Sql,
 N'@FaseId                     INT = NULL,',
 N'@FaseId                     INT = NULL,'+CHAR(13)+CHAR(10)+N'    @UnidadDeMedida              VARCHAR(50) = NULL,');
-- Conservar valores antiguos en ediciones si cliente no envía unidad: el frontend actualizado la envía explícitamente.
IF CHARINDEX(N'                FaseId,'+CHAR(13)+CHAR(10)+N'                EsObligatorio',@Sql)=0
 THROW 52003,'Bloque INSERT distinto al esperado; revisar manualmente.',1;
SET @Sql=REPLACE(@Sql,
 N'                FaseId,'+CHAR(13)+CHAR(10)+N'                EsObligatorio',
 N'                FaseId,'+CHAR(13)+CHAR(10)+N'                UnidadDeMedida,'+CHAR(13)+CHAR(10)+N'                EsObligatorio');
SET @Sql=REPLACE(@Sql,
 N'                @FaseId,'+CHAR(13)+CHAR(10)+N'                @EsObligatorio',
 N'                @FaseId,'+CHAR(13)+CHAR(10)+N'                NULLIF(LTRIM(RTRIM(@UnidadDeMedida)), ''''),'+CHAR(13)+CHAR(10)+N'                @EsObligatorio');
SET @Sql=REPLACE(@Sql,
 N'                 FaseId ='+CHAR(13)+CHAR(10)+N'                     @FaseId,',
 N'                 FaseId ='+CHAR(13)+CHAR(10)+N'                     @FaseId,'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+N'                 UnidadDeMedida ='+CHAR(13)+CHAR(10)+N'                     NULLIF(LTRIM(RTRIM(@UnidadDeMedida)), ''''),');
IF CHARINDEX(N'UnidadDeMedida =',@Sql)=0 OR CHARINDEX(N'                UnidadDeMedida,',@Sql)=0
 THROW 52004,'No se pudieron adaptar INSERT y UPDATE; no se aplicaron cambios.',1;
-- SQL Server conserva CREATE/ALTER en OBJECT_DEFINITION.
DECLARE @Start INT=PATINDEX('%CREATE%PROCEDURE%',UPPER(LEFT(LTRIM(@Sql),100)));
IF UPPER(LEFT(LTRIM(@Sql),16)) LIKE N'ALTER PROCEDURE%'
 SET @Sql=STUFF(@Sql,PATINDEX('%ALTER PROCEDURE%',UPPER(@Sql)),LEN('ALTER PROCEDURE'),N'CREATE OR ALTER PROCEDURE');
ELSE IF UPPER(LEFT(LTRIM(@Sql),17)) LIKE N'CREATE PROCEDURE%'
 SET @Sql=STUFF(@Sql,PATINDEX('%CREATE PROCEDURE%',UPPER(@Sql)),LEN('CREATE PROCEDURE'),N'CREATE OR ALTER PROCEDURE');
ELSE IF UPPER(LEFT(LTRIM(@Sql),25)) NOT LIKE N'CREATE OR ALTER PROCEDURE%'
 THROW 52005,'Encabezado del SP no reconocido.',1;
EXEC sys.sp_executesql @Sql;
PRINT 'Guardado de unidad por versión habilitado.';
