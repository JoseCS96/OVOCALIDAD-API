/* Restaurar la unidad del maestro en RS9; conserva las otras secciones. */
SET NOCOUNT ON;
DECLARE @Sql NVARCHAR(MAX)=OBJECT_DEFINITION(OBJECT_ID(N'dbo.SP_OBTENER_ESPECIFICACION_TECNICA',N'P'));
IF @Sql IS NULL THROW 53101,'No se encontró el SP de lectura.',1;
IF CHARINDEX(N'C.CaracteristicaUnidadDeMedida AS Unidad',@Sql)>0
BEGIN PRINT 'RS9 ya utiliza la unidad del maestro.'; RETURN; END;
IF CHARINDEX(N'VC.UnidadDeMedida AS Unidad',@Sql)=0
 THROW 53102,'RS9 no coincide con la definición esperada. No se modificó.',1;
SET @Sql=REPLACE(@Sql,N'VC.UnidadDeMedida AS Unidad',N'C.CaracteristicaUnidadDeMedida AS Unidad');
DECLARE @P INT=PATINDEX('%PROCEDURE%',UPPER(@Sql));
IF @P=0 THROW 53103,'No se encontró encabezado PROCEDURE.',1;
DECLARE @Prefix NVARCHAR(MAX)=LEFT(@Sql,@P-1);
IF UPPER(@Prefix) NOT LIKE '%CREATE%' AND UPPER(@Prefix) NOT LIKE '%ALTER%'
 THROW 53104,'Encabezado no reconocido.',1;
DECLARE @VerbStart INT=CASE WHEN CHARINDEX('CREATE',UPPER(@Prefix))>0 THEN CHARINDEX('CREATE',UPPER(@Prefix)) ELSE CHARINDEX('ALTER',UPPER(@Prefix)) END;
SET @Sql=STUFF(@Sql,@VerbStart,@P+LEN('PROCEDURE')-@VerbStart,N'CREATE OR ALTER PROCEDURE');
EXEC sys.sp_executesql @Sql;
PRINT 'RS9 vuelve a leer C.CaracteristicaUnidadDeMedida AS Unidad.';
