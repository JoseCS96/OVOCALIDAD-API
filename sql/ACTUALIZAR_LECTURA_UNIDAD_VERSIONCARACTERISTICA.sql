/*
 Actualiza solo RS9 de SP_OBTENER_ESPECIFICACION_TECNICA.
 Preserva los otros 14 conjuntos de resultados.
 Ejecutar después de MIGRAR_UNIDAD_VERSIONCARACTERISTICA.sql.
*/
SET NOCOUNT ON;
IF COL_LENGTH('dbo.VERSIONCARACTERISTICA','UnidadDeMedida') IS NULL
 THROW 53001,'Primero agregar UnidadDeMedida a VERSIONCARACTERISTICA.',1;
DECLARE @Sql NVARCHAR(MAX)=OBJECT_DEFINITION(OBJECT_ID(N'dbo.SP_OBTENER_ESPECIFICACION_TECNICA',N'P'));
IF @Sql IS NULL THROW 53002,'No existe el procedimiento de lectura.',1;
IF CHARINDEX(N'VC.UnidadDeMedida AS Unidad',@Sql)>0
BEGIN PRINT 'RS9 ya lee la unidad de VERSIONCARACTERISTICA.'; RETURN; END;
IF CHARINDEX(N'C.CaracteristicaUnidadDeMedida AS Unidad',@Sql)=0
 THROW 53003,'RS9 no coincide con la definición revisada; no se modificó.',1;
SET @Sql=REPLACE(@Sql,N'C.CaracteristicaUnidadDeMedida AS Unidad',N'VC.UnidadDeMedida AS Unidad');
-- OBJECT_DEFINITION puede conservar CREATE aun si se alteró anteriormente.
DECLARE @Inicio NVARCHAR(100)=UPPER(LEFT(LTRIM(@Sql),100));
IF @Inicio LIKE N'CREATE%PROCEDURE%'
BEGIN
 DECLARE @Pos INT=PATINDEX('%CREATE%PROCEDURE%',UPPER(@Sql));
 DECLARE @Fin INT=CHARINDEX(N'PROCEDURE',UPPER(@Sql),@Pos)+LEN(N'PROCEDURE');
 SET @Sql=STUFF(@Sql,@Pos,@Fin-@Pos,N'CREATE OR ALTER PROCEDURE');
END
ELSE IF @Inicio LIKE N'ALTER%PROCEDURE%'
BEGIN
 DECLARE @Pos2 INT=PATINDEX('%ALTER%PROCEDURE%',UPPER(@Sql));
 DECLARE @Fin2 INT=CHARINDEX(N'PROCEDURE',UPPER(@Sql),@Pos2)+LEN(N'PROCEDURE');
 SET @Sql=STUFF(@Sql,@Pos2,@Fin2-@Pos2,N'CREATE OR ALTER PROCEDURE');
END
ELSE
 THROW 53004,'Encabezado del procedimiento no reconocido; revisar manualmente.',1;
EXEC sys.sp_executesql @Sql;
PRINT 'RS9 actualizado: VC.UnidadDeMedida AS Unidad.';
