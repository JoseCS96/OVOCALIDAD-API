/*
OVOCALIDAD 2.0
Utilidades de limpieza para pruebas.
NO usar como funcionalidad productiva.
Los procedimientos se ejecutan únicamente desde endpoints protegidos para JEFE_CALIDAD.
*/

CREATE OR ALTER PROCEDURE dbo.SP_ELIMINAR_EVALUACION_PRUEBA
(
      @EvaluacionId INT
    , @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.EVALUACION WHERE EvaluacionId=@EvaluacionId)
        THROW 50001,'La evaluación indicada no existe.',1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @EvaluacionesEliminar TABLE(EvaluacionId INT PRIMARY KEY);

        ;WITH EvaluacionesCTE AS
        (
            SELECT EvaluacionId
            FROM dbo.EVALUACION
            WHERE EvaluacionId=@EvaluacionId

            UNION ALL

            SELECT H.EvaluacionId
            FROM dbo.EVALUACION H
            INNER JOIN EvaluacionesCTE P
                ON H.EvaluacionPadreId=P.EvaluacionId
        )
        INSERT INTO @EvaluacionesEliminar(EvaluacionId)
        SELECT DISTINCT EvaluacionId
        FROM EvaluacionesCTE
        OPTION(MAXRECURSION 100);

        DELETE ESRL
        FROM dbo.EVALUACION_SOLICITUD_REAPERTURA_LECTURA ESRL
        INNER JOIN dbo.EVALUACION_SOLICITUD_REAPERTURA ESR
            ON ESR.SolicitudReaperturaId=ESRL.SolicitudReaperturaId
        INNER JOIN @EvaluacionesEliminar X
            ON X.EvaluacionId=ESR.EvaluacionId;

        DELETE ESR
        FROM dbo.EVALUACION_SOLICITUD_REAPERTURA ESR
        INNER JOIN @EvaluacionesEliminar X ON X.EvaluacionId=ESR.EvaluacionId;

        DELETE EC
        FROM dbo.EVALUACION_CONSOLIDACION EC
        INNER JOIN @EvaluacionesEliminar X ON X.EvaluacionId=EC.EvaluacionId;

        DELETE ER
        FROM dbo.EVALUACION_RESULTADO ER
        INNER JOIN @EvaluacionesEliminar X ON X.EvaluacionId=ER.EvaluacionId;

        WHILE EXISTS
        (
            SELECT 1
            FROM dbo.EVALUACION E
            INNER JOIN @EvaluacionesEliminar X ON X.EvaluacionId=E.EvaluacionId
        )
        BEGIN
            DELETE E
            FROM dbo.EVALUACION E
            INNER JOIN @EvaluacionesEliminar X ON X.EvaluacionId=E.EvaluacionId
            WHERE NOT EXISTS
            (
                SELECT 1
                FROM dbo.EVALUACION H
                INNER JOIN @EvaluacionesEliminar XH ON XH.EvaluacionId=H.EvaluacionId
                WHERE H.EvaluacionPadreId=E.EvaluacionId
            );

            IF @@ROWCOUNT=0
                THROW 50002,'No se pudo resolver la jerarquía de reevaluaciones.',1;
        END;

        COMMIT TRANSACTION;

        SELECT
              0 CodigoResultado
            , 'Evaluación y dependencias de prueba eliminadas correctamente.' Mensaje
            , @EvaluacionId EvaluacionId
            , @Usuario Usuario;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ELIMINAR_LOTE_PRUEBA
(
      @LoteId INT
    , @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.LOTE WHERE LoteId=@LoteId)
        THROW 50001,'El lote indicado no existe.',1;

    DECLARE @CodigoLote VARCHAR(100);
    SELECT @CodigoLote=CodigoLote FROM dbo.LOTE WHERE LoteId=@LoteId;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @EvaluacionesEliminar TABLE(EvaluacionId INT PRIMARY KEY);

        INSERT INTO @EvaluacionesEliminar(EvaluacionId)
        SELECT EvaluacionId
        FROM dbo.EVALUACION
        WHERE LoteId=@LoteId;

        DELETE CD
        FROM dbo.CERTIFICADODETALLE CD
        INNER JOIN dbo.CERTIFICADO C ON C.CertificadoId=CD.CertificadoId
        WHERE C.LoteId=@LoteId;

        DELETE FROM dbo.CERTIFICADO WHERE LoteId=@LoteId;

        DELETE ESR
        FROM dbo.EVALUACION_SOLICITUD_REAPERTURA ESR
        INNER JOIN @EvaluacionesEliminar X ON X.EvaluacionId=ESR.EvaluacionId;

        DELETE EC
        FROM dbo.EVALUACION_CONSOLIDACION EC
        INNER JOIN @EvaluacionesEliminar X ON X.EvaluacionId=EC.EvaluacionId;

        DELETE ER
        FROM dbo.EVALUACION_RESULTADO ER
        INNER JOIN @EvaluacionesEliminar X ON X.EvaluacionId=ER.EvaluacionId;

        WHILE EXISTS(SELECT 1 FROM dbo.EVALUACION WHERE LoteId=@LoteId)
        BEGIN
            DELETE E
            FROM dbo.EVALUACION E
            WHERE E.LoteId=@LoteId
              AND NOT EXISTS
              (
                  SELECT 1
                  FROM dbo.EVALUACION H
                  WHERE H.EvaluacionPadreId=E.EvaluacionId
                    AND H.LoteId=@LoteId
              );

            IF @@ROWCOUNT=0
                THROW 50002,'No se pudo resolver la jerarquía de evaluaciones del lote.',1;
        END;

        DELETE FROM dbo.LOTEHISTORIALESTADO WHERE LoteId=@LoteId;
        DELETE FROM dbo.LOTE WHERE LoteId=@LoteId;

        COMMIT TRANSACTION;

        SELECT
              0 CodigoResultado
            , 'Lote y toda su data de prueba eliminados correctamente.' Mensaje
            , @LoteId LoteId
            , @CodigoLote CodigoLote
            , @Usuario Usuario;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
