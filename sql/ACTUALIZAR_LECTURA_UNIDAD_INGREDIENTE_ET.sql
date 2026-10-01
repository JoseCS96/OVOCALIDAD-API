/*
 Actualiza únicamente el RS4 de dbo.SP_OBTENER_ESPECIFICACION_TECNICA,
 sin reescribir sus otros 14 conjuntos de resultados.
 Ejecutar después de la migración de columna.
 Revisar definición si se ha modificado el SP desde la versión compartida.
*/
SET NOCOUNT ON;
IF COL_LENGTH('dbo.VERSIONINGREDIENTE','UnidadDeMedida') IS NULL
 THROW 51000, 'Primero ejecutar MIGRAR_UNIDAD_VERSIONINGREDIENTE.sql', 1;
DECLARE @Sql NVARCHAR(MAX)=OBJECT_DEFINITION(OBJECT_ID(N'dbo.SP_OBTENER_ESPECIFICACION_TECNICA',N'P'));
IF @Sql IS NULL
 THROW 51001, 'No existe el procedimiento de lectura.', 1;
IF CHARINDEX(N'I.IngredienteDescripcion,',@Sql)=0
   OR CHARINDEX(N'I.UnidadDeMedida,',@Sql)=0
 THROW 51002, 'El RS4 ya cambió: revisar manualmente antes de aplicar.', 1;
-- Reemplazar exclusivamente la pareja de columnas de ingredientes.
SET @Sql=REPLACE(@Sql,
 N'I.IngredienteDescripcion,'+CHAR(13)+CHAR(10)+N'        I.UnidadDeMedida,',
 N'I.IngredienteDescripcion,'+CHAR(13)+CHAR(10)+N'        VI.UnidadDeMedida,');
-- Admitir también definiciones con finales de línea LF.
IF CHARINDEX(N'VI.UnidadDeMedida,',@Sql)=0
 SET @Sql=REPLACE(@Sql,
 N'I.IngredienteDescripcion,'+CHAR(10)+N'        I.UnidadDeMedida,',
 N'I.IngredienteDescripcion,'+CHAR(10)+N'        VI.UnidadDeMedida,');
IF CHARINDEX(N'VI.UnidadDeMedida,',@Sql)=0
 THROW 51003, 'No se reconoció el formato del RS4; realizar cambio manual.', 1;
-- El módulo original facilitado usa ALTER PROCEDURE.
IF UPPER(LEFT(LTRIM(@Sql),16)) NOT LIKE 'ALTER PROCEDURE%'
 THROW 51004, 'La definición no comienza con ALTER PROCEDURE; revisar manualmente.', 1;
EXEC sys.sp_executesql @Sql;
PRINT 'RS4 actualizado: la unidad se lee de VERSIONINGREDIENTE.';
