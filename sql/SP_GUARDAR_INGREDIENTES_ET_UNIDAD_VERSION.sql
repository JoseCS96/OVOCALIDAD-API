/* OVOCALIDAD: ejecutar DESPUÉS de MIGRAR_UNIDAD_VERSIONINGREDIENTE.sql
   Reemplaza SP_GUARDAR_INGREDIENTES_ET conservando sus validaciones.
*/
CREATE OR ALTER PROCEDURE dbo.SP_GUARDAR_INGREDIENTES_ET
    @VersionId INT,
    @IngredientesJson VARCHAR(MAX),
    @Usuario VARCHAR(50)
AS
BEGIN
 SET NOCOUNT ON;
 SET XACT_ABORT ON;
 DECLARE @EstadoVersion VARCHAR(50), @Ahora DATETIME2 = SYSDATETIME();
 BEGIN TRY
  SET @Usuario = NULLIF(LTRIM(RTRIM(@Usuario)), '');
  IF @VersionId IS NULL BEGIN SELECT 1 CodigoResultado, 'VersionId es obligatorio.' Mensaje; RETURN; END;
  IF @Usuario IS NULL BEGIN SELECT 2 CodigoResultado, 'No se pudo identificar al usuario.' Mensaje; RETURN; END;
  IF ISJSON(@IngredientesJson) <> 1 BEGIN SELECT 3 CodigoResultado, 'El formato de ingredientes no es válido.' Mensaje; RETURN; END;
  SELECT @EstadoVersion=EV.EstVerDescripcion
  FROM dbo.VERSION V INNER JOIN dbo.ESTADOVERSION EV ON EV.EstVerId=V.EstVerId
  WHERE V.VersionId=@VersionId AND V.Estado=1;
  IF @EstadoVersion IS NULL BEGIN SELECT 4 CodigoResultado, 'La versión indicada no existe.' Mensaje; RETURN; END;
  IF @EstadoVersion <> 'BORRADOR' BEGIN SELECT 5 CodigoResultado, 'Solo se pueden modificar ingredientes en estado BORRADOR.' Mensaje; RETURN; END;

  DECLARE @Ingredientes TABLE
  (
   IngredienteId INT NOT NULL PRIMARY KEY,
   UnidadDeMedida VARCHAR(30) NULL,
   VersIngrValor DECIMAL(18,6) NULL,
   IdTipoContenido INT NULL,
   Orden INT NOT NULL
  );
  INSERT INTO @Ingredientes(IngredienteId,UnidadDeMedida,VersIngrValor,IdTipoContenido,Orden)
  SELECT IngredienteId,NULLIF(LTRIM(RTRIM(UnidadDeMedida)),''),Valor,IdTipoContenido,Orden
  FROM OPENJSON(@IngredientesJson,'$.ingredientes')
  WITH
  (
   IngredienteId INT '$.ingredienteId',
   UnidadDeMedida VARCHAR(30) '$.unidadDeMedida',
   Valor DECIMAL(18,6) '$.valor',
   IdTipoContenido INT '$.idTipoContenido',
   Orden INT '$.orden'
  );
  IF EXISTS(SELECT 1 FROM @Ingredientes WHERE IngredienteId IS NULL OR Orden IS NULL OR Orden<=0)
  BEGIN SELECT 6 CodigoResultado, 'Existen ingredientes con datos incompletos.' Mensaje; RETURN; END;
  IF EXISTS
  (
   SELECT 1 FROM @Ingredientes X
   LEFT JOIN dbo.INGREDIENTE I ON I.IngredienteId=X.IngredienteId AND I.Estado=1
   WHERE I.IngredienteId IS NULL
  )
  BEGIN SELECT 7 CodigoResultado, 'Uno o más ingredientes no existen o están inactivos.' Mensaje; RETURN; END;
  IF EXISTS
  (
   SELECT 1 FROM @Ingredientes X
   LEFT JOIN dbo.TIPOCONTENIDO TC ON TC.IdTipoContenido=X.IdTipoContenido AND TC.Estado=1
   WHERE X.IdTipoContenido IS NOT NULL AND TC.IdTipoContenido IS NULL
  )
  BEGIN SELECT 8 CodigoResultado, 'Uno o más tipos de contenido no son válidos.' Mensaje; RETURN; END;
  IF EXISTS(SELECT Orden FROM @Ingredientes GROUP BY Orden HAVING COUNT(*)>1)
  BEGIN SELECT 9 CodigoResultado, 'No puede existir más de un ingrediente con el mismo orden.' Mensaje; RETURN; END;

  BEGIN TRANSACTION;
  DELETE FROM dbo.VERSIONINGREDIENTE WHERE VersionId=@VersionId;
  INSERT INTO dbo.VERSIONINGREDIENTE
  (
   VersionId,IngredienteId,UnidadDeMedida,Estado,AudUsuarioCreacion,
   AudFechaCreacion,VersIngrValor,IdTipoContenido,VersIngOrden
  )
  SELECT @VersionId,X.IngredienteId,X.UnidadDeMedida,1,@Usuario,@Ahora,
         X.VersIngrValor,X.IdTipoContenido,X.Orden
  FROM @Ingredientes X;
  UPDATE dbo.VERSION SET AudUsuarioModificacion=@Usuario,AudFechaActualizacion=@Ahora
  WHERE VersionId=@VersionId;
  COMMIT TRANSACTION;
  SELECT 0 CodigoResultado,'Ingredientes guardados correctamente.' Mensaje,
         @VersionId VersionId,COUNT(*) CantidadIngredientes FROM @Ingredientes;
 END TRY
 BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
  SELECT -1 CodigoResultado,ERROR_MESSAGE() Mensaje,@VersionId VersionId;
 END CATCH;
END;
