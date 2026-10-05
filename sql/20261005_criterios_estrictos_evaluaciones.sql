/*
OVOCALIDAD 2.0
Migración: criterios estrictos en Evaluaciones
Requiere TIPO_CRITERIO:
  9  MAYOR_QUE
  10 MENOR_QUE

Este script actualiza las definiciones existentes de los SP sin alterar sus contratos.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @sql nvarchar(max);

    /* ============================================================
       SP_GUARDAR_RESULTADO
       ============================================================ */
    SET @sql = OBJECT_DEFINITION(OBJECT_ID(N'dbo.SP_GUARDAR_RESULTADO'));

    IF @sql IS NULL
        THROW 50001, 'No existe dbo.SP_GUARDAR_RESULTADO.', 1;

    SET @sql = STUFF(@sql, CHARINDEX('CREATE', UPPER(@sql)), 6, 'ALTER');

    SET @sql = REPLACE(
        @sql,
        'IF @TipoCriterio IN (''MINIMO'', ''MAXIMO'', ''RANGO'')',
        'IF @TipoCriterio IN (''MINIMO'', ''MAXIMO'', ''RANGO'', ''MAYOR_QUE'', ''MENOR_QUE'')'
    );

    SET @sql = REPLACE(
        @sql,
        '        --------------------------------------------------------' + CHAR(13) + CHAR(10) +
        '        -- AUSENCIA',
        '        --------------------------------------------------------' + CHAR(13) + CHAR(10) +
        '        -- MAYOR_QUE' + CHAR(13) + CHAR(10) +
        '        --------------------------------------------------------' + CHAR(13) + CHAR(10) +
        '        ELSE IF @TipoCriterio = ''MAYOR_QUE''' + CHAR(13) + CHAR(10) +
        '        BEGIN' + CHAR(13) + CHAR(10) +
        '            IF @ValorCuantitativoInicial IS NULL' + CHAR(13) + CHAR(10) +
        '                RAISERROR(''La especificación MAYOR_QUE no tiene límite configurado.'',16,1);' + CHAR(13) + CHAR(10) +
        '            SET @CumpleCalculado = CASE WHEN @ResultadoNumerico > @ValorCuantitativoInicial THEN 1 ELSE 0 END;' + CHAR(13) + CHAR(10) +
        '        END;' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
        '        --------------------------------------------------------' + CHAR(13) + CHAR(10) +
        '        -- MENOR_QUE' + CHAR(13) + CHAR(10) +
        '        --------------------------------------------------------' + CHAR(13) + CHAR(10) +
        '        ELSE IF @TipoCriterio = ''MENOR_QUE''' + CHAR(13) + CHAR(10) +
        '        BEGIN' + CHAR(13) + CHAR(10) +
        '            IF @ValorCuantitativoFinal IS NULL' + CHAR(13) + CHAR(10) +
        '                RAISERROR(''La especificación MENOR_QUE no tiene límite configurado.'',16,1);' + CHAR(13) + CHAR(10) +
        '            SET @CumpleCalculado = CASE WHEN @ResultadoNumerico < @ValorCuantitativoFinal THEN 1 ELSE 0 END;' + CHAR(13) + CHAR(10) +
        '        END;' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
        '        --------------------------------------------------------' + CHAR(13) + CHAR(10) +
        '        -- AUSENCIA'
    );

    EXEC sys.sp_executesql @sql;

    /* ============================================================
       SP_CERRAR_EVALUACION
       Agrega 9 (> inicial) y 10 (< final) al CASE de recálculo.
       ============================================================ */
    SET @sql = OBJECT_DEFINITION(OBJECT_ID(N'dbo.SP_CERRAR_EVALUACION'));

    IF @sql IS NULL
        THROW 50002, 'No existe dbo.SP_CERRAR_EVALUACION.', 1;

    SET @sql = STUFF(@sql, CHARINDEX('CREATE', UPPER(@sql)), 6, 'ALTER');

    SET @sql = REPLACE(
        @sql,
        '                    ELSE NULL',
        '                    /* MAYOR_QUE */' + CHAR(13) + CHAR(10) +
        '                    WHEN 9 THEN' + CHAR(13) + CHAR(10) +
        '                        CASE WHEN ER.ResultadoNumerico IS NOT NULL' + CHAR(13) + CHAR(10) +
        '                                   AND VC.ValorCuantitativoInicial IS NOT NULL' + CHAR(13) + CHAR(10) +
        '                                   AND ER.ResultadoNumerico > VC.ValorCuantitativoInicial' + CHAR(13) + CHAR(10) +
        '                             THEN 1 ELSE 0 END' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
        '                    /* MENOR_QUE */' + CHAR(13) + CHAR(10) +
        '                    WHEN 10 THEN' + CHAR(13) + CHAR(10) +
        '                        CASE WHEN ER.ResultadoNumerico IS NOT NULL' + CHAR(13) + CHAR(10) +
        '                                   AND VC.ValorCuantitativoFinal IS NOT NULL' + CHAR(13) + CHAR(10) +
        '                                   AND ER.ResultadoNumerico < VC.ValorCuantitativoFinal' + CHAR(13) + CHAR(10) +
        '                             THEN 1 ELSE 0 END' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
        '                    ELSE NULL'
    );

    EXEC sys.sp_executesql @sql;

    /* ============================================================
       SP_PRECALCULAR_DISPOSICION_EVALUACIONES
       - Unidad propia de VERSIONCARACTERISTICA.
       - Especificación para criterios 9 y 10.
       ============================================================ */
    SET @sql = OBJECT_DEFINITION(OBJECT_ID(N'dbo.SP_PRECALCULAR_DISPOSICION_EVALUACIONES'));

    IF @sql IS NULL
        THROW 50003, 'No existe dbo.SP_PRECALCULAR_DISPOSICION_EVALUACIONES.', 1;

    SET @sql = STUFF(@sql, CHARINDEX('CREATE', UPPER(@sql)), 6, 'ALTER');

    SET @sql = REPLACE(
        @sql,
        'C.CaracteristicaUnidadDeMedida AS Unidad',
        'VC.UnidadDeMedida AS Unidad'
    );

    SET @sql = REPLACE(
        @sql,
        '            ELSE NULL',
        '            WHEN 9 THEN CONCAT(''> '', CONVERT(VARCHAR(50), VC.ValorCuantitativoInicial))' + CHAR(13) + CHAR(10) +
        '            WHEN 10 THEN CONCAT(''< '', CONVERT(VARCHAR(50), VC.ValorCuantitativoFinal))' + CHAR(13) + CHAR(10) +
        '            ELSE NULL'
    );

    EXEC sys.sp_executesql @sql;

    COMMIT TRANSACTION;

    SELECT
        'OK' AS Resultado,
        'Criterios MAYOR_QUE y MENOR_QUE incorporados en Evaluaciones.' AS Mensaje;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
