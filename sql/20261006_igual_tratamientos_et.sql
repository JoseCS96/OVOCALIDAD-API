USE [OVOCALIDAD]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE dbo.SP_GUARDAR_TRATAMIENTOS_ET
(
      @VersionId        INT
    , @TratamientosJson VARCHAR(MAX)
    , @Usuario          VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
          @EstadoVersion VARCHAR(50)
        , @Ahora DATETIME2 = SYSDATETIME();

    BEGIN TRY
        SET @Usuario = NULLIF(LTRIM(RTRIM(@Usuario)), '');

        IF @VersionId IS NULL
        BEGIN
            SELECT 1 CodigoResultado, 'VersionId es obligatorio.' Mensaje;
            RETURN;
        END;

        IF @Usuario IS NULL
        BEGIN
            SELECT 2 CodigoResultado, 'No se pudo identificar al usuario.' Mensaje;
            RETURN;
        END;

        IF ISJSON(@TratamientosJson) <> 1
        BEGIN
            SELECT 3 CodigoResultado, 'El formato de tratamientos no es válido.' Mensaje;
            RETURN;
        END;

        SELECT @EstadoVersion = EV.EstVerDescripcion
        FROM dbo.VERSION V
        INNER JOIN dbo.ESTADOVERSION EV ON EV.EstVerId = V.EstVerId
        WHERE V.VersionId = @VersionId
          AND V.Estado = 1;

        IF @EstadoVersion IS NULL
        BEGIN
            SELECT 4 CodigoResultado, 'La versión indicada no existe.' Mensaje;
            RETURN;
        END;

        IF @EstadoVersion <> 'BORRADOR'
        BEGIN
            SELECT 5 CodigoResultado, 'Solo se pueden modificar tratamientos en estado BORRADOR.' Mensaje;
            RETURN;
        END;

        DECLARE @Tratamientos TABLE
        (
              FilaTratamientoId INT IDENTITY(1,1) PRIMARY KEY
            , TratConservId INT NULL
        );

        INSERT INTO @Tratamientos (TratConservId)
        SELECT TratConservId
        FROM OPENJSON(@TratamientosJson, '$.tratamientos')
        WITH (TratConservId INT '$.tratConservId');

        DECLARE @Parametros TABLE
        (
              FilaParametroId INT IDENTITY(1,1) PRIMARY KEY
            , TratConservId INT NULL
            , ParametroTratId INT NULL
            , TipoCriterioId INT NULL
            , ValorCuantitativoInicial DECIMAL(18,4) NULL
            , ValorCuantitativoFinal DECIMAL(18,4) NULL
            , ValorCuantitativoIgual DECIMAL(18,4) NULL
            , ValorCualitativo VARCHAR(1000) NULL
            , Orden INT NULL
        );

        INSERT INTO @Parametros
        (
              TratConservId, ParametroTratId, TipoCriterioId
            , ValorCuantitativoInicial, ValorCuantitativoFinal
            , ValorCuantitativoIgual, ValorCualitativo, Orden
        )
        SELECT
              T.TratConservId, P.ParametroTratId, P.TipoCriterioId
            , P.ValorCuantitativoInicial, P.ValorCuantitativoFinal
            , P.ValorCuantitativoIgual
            , NULLIF(LTRIM(RTRIM(P.ValorCualitativo)), '')
            , P.Orden
        FROM OPENJSON(@TratamientosJson, '$.tratamientos')
        WITH
        (
              TratConservId INT '$.tratConservId'
            , Parametros NVARCHAR(MAX) '$.parametros' AS JSON
        ) T
        CROSS APPLY OPENJSON(T.Parametros)
        WITH
        (
              ParametroTratId INT '$.parametroTratId'
            , TipoCriterioId INT '$.tipoCriterioId'
            , ValorCuantitativoInicial DECIMAL(18,4) '$.valorCuantitativoInicial'
            , ValorCuantitativoFinal DECIMAL(18,4) '$.valorCuantitativoFinal'
            , ValorCuantitativoIgual DECIMAL(18,4) '$.valorCuantitativoIgual'
            , ValorCualitativo VARCHAR(1000) '$.valorCualitativo'
            , Orden INT '$.orden'
        ) P;

        IF EXISTS
        (
            SELECT 1
            FROM @Tratamientos T
            LEFT JOIN dbo.TRATAMIENTODECONSERVACION TC
              ON TC.TratConservId = T.TratConservId AND TC.Estado = 1
            WHERE T.TratConservId IS NULL OR TC.TratConservId IS NULL
        )
        BEGIN
            SELECT 6 CodigoResultado, 'Uno o más tratamientos no son válidos.' Mensaje;
            RETURN;
        END;

        IF EXISTS
        (
            SELECT TratConservId FROM @Tratamientos
            GROUP BY TratConservId HAVING COUNT(*) > 1
        )
        BEGIN
            SELECT 7 CodigoResultado, 'No puede repetirse el mismo tratamiento.' Mensaje;
            RETURN;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM @Parametros P
            LEFT JOIN dbo.PARAMETROTRATAMIENTO PT
              ON PT.ParamTratId = P.ParametroTratId AND PT.Estado = 1
            WHERE P.ParametroTratId IS NULL OR PT.ParamTratId IS NULL
        )
        BEGIN
            SELECT 8 CodigoResultado, 'Uno o más parámetros de tratamiento no son válidos.' Mensaje;
            RETURN;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM @Parametros P
            LEFT JOIN dbo.TIPO_CRITERIO TC
              ON TC.TipoCriterioId = P.TipoCriterioId AND TC.Estado = 1
            WHERE P.TipoCriterioId IS NULL OR TC.TipoCriterioId IS NULL
        )
        BEGIN
            SELECT 9 CodigoResultado, 'Uno o más criterios no son válidos.' Mensaje;
            RETURN;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM @Parametros P
            LEFT JOIN @Tratamientos T ON T.TratConservId = P.TratConservId
            WHERE T.TratConservId IS NULL
        )
        BEGIN
            SELECT 10 CodigoResultado, 'Existen parámetros sin un tratamiento válido.' Mensaje;
            RETURN;
        END;

        IF EXISTS
        (
            SELECT TratConservId, ParametroTratId
            FROM @Parametros
            GROUP BY TratConservId, ParametroTratId
            HAVING COUNT(*) > 1
        )
        BEGIN
            SELECT 11 CodigoResultado, 'No puede repetirse un parámetro dentro del mismo tratamiento.' Mensaje;
            RETURN;
        END;

        IF EXISTS (SELECT 1 FROM @Parametros WHERE Orden IS NULL OR Orden <= 0)
        BEGIN
            SELECT 12 CodigoResultado, 'Existen parámetros con un orden no válido.' Mensaje;
            RETURN;
        END;

        IF EXISTS
        (
            SELECT TratConservId, Orden
            FROM @Parametros
            GROUP BY TratConservId, Orden
            HAVING COUNT(*) > 1
        )
        BEGIN
            SELECT 13 CodigoResultado, 'No puede repetirse el orden dentro de un mismo tratamiento.' Mensaje;
            RETURN;
        END;

        /* MINIMO (>=) y MAYOR_QUE (>) usan valor inicial. */
        IF EXISTS
        (
            SELECT 1 FROM @Parametros
            WHERE TipoCriterioId IN (1,9)
              AND ValorCuantitativoInicial IS NULL
        )
        BEGIN
            SELECT 14 CodigoResultado, 'El criterio MINIMO/MAYOR_QUE requiere un valor inicial.' Mensaje;
            RETURN;
        END;

        /* MAXIMO (<=) y MENOR_QUE (<) usan valor final. */
        IF EXISTS
        (
            SELECT 1 FROM @Parametros
            WHERE TipoCriterioId IN (2,10)
              AND ValorCuantitativoFinal IS NULL
        )
        BEGIN
            SELECT 15 CodigoResultado, 'El criterio MAXIMO/MENOR_QUE requiere un valor final.' Mensaje;
            RETURN;
        END;

        IF EXISTS
        (
            SELECT 1 FROM @Parametros
            WHERE TipoCriterioId = 3
              AND (ValorCuantitativoInicial IS NULL OR ValorCuantitativoFinal IS NULL)
        )
        BEGIN
            SELECT 16 CodigoResultado, 'El criterio RANGO requiere valor inicial y final.' Mensaje;
            RETURN;
        END;

        IF EXISTS
        (
            SELECT 1 FROM @Parametros
            WHERE TipoCriterioId = 3
              AND ValorCuantitativoInicial > ValorCuantitativoFinal
        )
        BEGIN
            SELECT 17 CodigoResultado, 'En un RANGO el valor inicial no puede ser mayor al valor final.' Mensaje;
            RETURN;
        END;

        IF EXISTS
        (
            SELECT 1 FROM @Parametros
            WHERE TipoCriterioId IN (4,5)
              AND ValorCualitativo IS NULL
        )
        BEGIN
            SELECT 18 CodigoResultado, 'Los criterios AUSENCIA y CUALITATIVO requieren un valor cualitativo.' Mensaje;
            RETURN;
        END;

        /* IGUAL (=) usa exclusivamente ValorCuantitativoIgual. */
        IF EXISTS
        (
            SELECT 1 FROM @Parametros
            WHERE TipoCriterioId = 11
              AND ValorCuantitativoIgual IS NULL
        )
        BEGIN
            SELECT 19 CodigoResultado, 'El criterio IGUAL requiere un valor.' Mensaje;
            RETURN;
        END;

        BEGIN TRANSACTION;

        DELETE VPT
        FROM dbo.VERSIONPARAMETROTRATAMIENTO VPT
        INNER JOIN dbo.VERSIONTRATAMIENTOCONS VTC
          ON VTC.VersTratConsId = VPT.VersTratConsId
        WHERE VTC.VersionId = @VersionId;

        DELETE FROM dbo.VERSIONTRATAMIENTOCONS
        WHERE VersionId = @VersionId;

        DECLARE @TratConservId INT, @VersTratConsId INT;

        DECLARE curTratamientos CURSOR LOCAL FAST_FORWARD FOR
        SELECT TratConservId
        FROM @Tratamientos
        ORDER BY FilaTratamientoId;

        OPEN curTratamientos;
        FETCH NEXT FROM curTratamientos INTO @TratConservId;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO dbo.VERSIONTRATAMIENTOCONS
            (
                VersionId, TratConservId, estado,
                AudUsuarioCreacion, AudFechaCreacion
            )
            VALUES
            (
                @VersionId, @TratConservId, 1,
                @Usuario, @Ahora
            );

            SET @VersTratConsId = SCOPE_IDENTITY();

            INSERT INTO dbo.VERSIONPARAMETROTRATAMIENTO
            (
                  VersTratConsId
                , ParametroTratId
                , TipoCriterioId
                , ValorCuantitativoInicial
                , ValorCuantitativoFinal
                , ValorCuantitativoIgual
                , ValorCualitativo
                , Estado
                , AudUsuarioCreacion
                , AudFechaCreacion
                , VersParamTratOrden
            )
            SELECT
                  @VersTratConsId
                , P.ParametroTratId
                , P.TipoCriterioId
                , CASE WHEN P.TipoCriterioId IN (1,3,9)
                       THEN P.ValorCuantitativoInicial ELSE NULL END
                , CASE WHEN P.TipoCriterioId IN (2,3,10)
                       THEN P.ValorCuantitativoFinal ELSE NULL END
                , CASE WHEN P.TipoCriterioId = 11
                       THEN P.ValorCuantitativoIgual ELSE NULL END
                , CASE WHEN P.TipoCriterioId IN (4,5)
                       THEN P.ValorCualitativo ELSE NULL END
                , 1
                , @Usuario
                , @Ahora
                , P.Orden
            FROM @Parametros P
            WHERE P.TratConservId = @TratConservId
            ORDER BY P.Orden;

            FETCH NEXT FROM curTratamientos INTO @TratConservId;
        END;

        CLOSE curTratamientos;
        DEALLOCATE curTratamientos;

        UPDATE dbo.VERSION
        SET AudUsuarioModificacion = @Usuario,
            AudFechaActualizacion = @Ahora
        WHERE VersionId = @VersionId;

        COMMIT TRANSACTION;

        SELECT
              0 CodigoResultado
            , 'Tratamientos guardados correctamente.' Mensaje
            , @VersionId VersionId
            , (SELECT COUNT(*) FROM @Tratamientos) CantidadTratamientos
            , (SELECT COUNT(*) FROM @Parametros) CantidadParametros;
    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('local', 'curTratamientos') >= 0
            CLOSE curTratamientos;

        IF CURSOR_STATUS('local', 'curTratamientos') > -3
            DEALLOCATE curTratamientos;

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
              -1 CodigoResultado
            , ERROR_MESSAGE() Mensaje
            , @VersionId VersionId;
    END CATCH;
END;
GO
