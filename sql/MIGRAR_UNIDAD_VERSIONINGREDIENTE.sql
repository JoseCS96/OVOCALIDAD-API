/*
 Migración no destructiva. Ejecutar en OVOCALIDAD antes de desplegar
 los cambios de la API. NO eliminar INGREDIENTE.UnidadDeMedida
 hasta adaptar y probar todos los procedimientos que la consultan.
*/
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRAN;
 IF OBJECT_ID('dbo.VERSIONINGREDIENTE','U') IS NULL
    THROW 50001, 'No existe dbo.VERSIONINGREDIENTE.', 1;
 IF COL_LENGTH('dbo.VERSIONINGREDIENTE','UnidadDeMedida') IS NULL
    ALTER TABLE dbo.VERSIONINGREDIENTE ADD UnidadDeMedida VARCHAR(30) NULL;
 IF COL_LENGTH('dbo.INGREDIENTE','UnidadDeMedida') IS NOT NULL
 BEGIN
    EXEC sp_executesql N'
       UPDATE vi
       SET vi.UnidadDeMedida = i.UnidadDeMedida
       FROM dbo.VERSIONINGREDIENTE AS vi
       INNER JOIN dbo.INGREDIENTE AS i ON i.IngredienteId = vi.IngredienteId
       WHERE vi.UnidadDeMedida IS NULL
         AND NULLIF(LTRIM(RTRIM(i.UnidadDeMedida)), '''') IS NOT NULL;';
 END;
 COMMIT;
 SELECT 'Migración de columna y datos completada. Falta adaptar SP de lectura y guardado.' AS Resultado;
END TRY
BEGIN CATCH
 IF @@TRANCOUNT > 0 ROLLBACK;
 THROW;
END CATCH;
