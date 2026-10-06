SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('dbo.LOTEHISTORIALESTADO','U') IS NULL
    BEGIN
        CREATE TABLE dbo.LOTEHISTORIALESTADO
        (
            LoteHistorialEstadoId INT IDENTITY(1,1) NOT NULL
                CONSTRAINT PK_LOTEHISTORIALESTADO PRIMARY KEY,
            LoteId INT NOT NULL,
            EstadoLoteOrigenId INT NULL,
            EstadoLoteDestinoId INT NOT NULL,
            Accion VARCHAR(50) NOT NULL,
            Comentario VARCHAR(1000) NULL,
            Usuario VARCHAR(100) NOT NULL,
            Fecha DATETIME2 NOT NULL
                CONSTRAINT DF_LOTEHISTORIALESTADO_Fecha DEFAULT SYSDATETIME(),
            Estado BIT NOT NULL
                CONSTRAINT DF_LOTEHISTORIALESTADO_Estado DEFAULT 1,
            CONSTRAINT FK_LOTEHISTORIALESTADO_LOTE
                FOREIGN KEY (LoteId) REFERENCES dbo.LOTE(LoteId),
            CONSTRAINT FK_LOTEHISTORIALESTADO_ESTADO_ORIGEN
                FOREIGN KEY (EstadoLoteOrigenId) REFERENCES dbo.ESTADO_LOTE(EstadoLoteId),
            CONSTRAINT FK_LOTEHISTORIALESTADO_ESTADO_DESTINO
                FOREIGN KEY (EstadoLoteDestinoId) REFERENCES dbo.ESTADO_LOTE(EstadoLoteId)
        );

        CREATE INDEX IX_LOTEHISTORIALESTADO_Lote_Fecha
            ON dbo.LOTEHISTORIALESTADO(LoteId, Fecha, LoteHistorialEstadoId);
    END;

    COMMIT TRANSACTION;

    SELECT 0 AS CodigoResultado,
           'Estructura de historial de estados del lote creada correctamente.' AS Mensaje;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

CREATE OR ALTER TRIGGER dbo.TR_LOTE_HISTORIAL_ESTADO
ON dbo.LOTE
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.LOTEHISTORIALESTADO
    (
          LoteId
        , EstadoLoteOrigenId
        , EstadoLoteDestinoId
        , Accion
        , Comentario
        , Usuario
        , Fecha
        , Estado
    )
    SELECT
          I.LoteId
        , D.EstadoLoteId
        , I.EstadoLoteId
        , CASE
              WHEN D.LoteId IS NULL THEN 'CREAR_LOTE'
              WHEN EO.Codigo = 'PENDIENTE' AND ED.Codigo = 'EVALUACION' THEN 'INICIAR_EVALUACION'
              WHEN ED.Codigo = 'LIBERADO' THEN 'LIBERAR_LOTE'
              WHEN ED.Codigo = 'NO_CONFORME' THEN 'MARCAR_NO_CONFORME'
              WHEN ED.Codigo = 'ANULADO' THEN 'ANULAR_LOTE'
              WHEN ED.Codigo = 'CERTIFICADO' THEN 'CERTIFICAR_LOTE'
              ELSE 'CAMBIAR_ESTADO'
          END
        , CASE
              WHEN D.LoteId IS NULL THEN 'Registro automático por creación del lote.'
              ELSE CONCAT('Cambio automático de estado: ', ISNULL(EO.Codigo,'SIN_ESTADO'), ' -> ', ED.Codigo, '.')
          END
        , COALESCE(
              NULLIF(LTRIM(RTRIM(I.AudUsuarioModificacion)), ''),
              NULLIF(LTRIM(RTRIM(I.AudUsuarioCreacion)), ''),
              SUSER_SNAME()
          )
        , SYSDATETIME()
        , 1
    FROM inserted I
    LEFT JOIN deleted D
        ON D.LoteId = I.LoteId
    LEFT JOIN dbo.ESTADO_LOTE EO
        ON EO.EstadoLoteId = D.EstadoLoteId
    INNER JOIN dbo.ESTADO_LOTE ED
        ON ED.EstadoLoteId = I.EstadoLoteId
    WHERE D.LoteId IS NULL
       OR ISNULL(D.EstadoLoteId,-1) <> ISNULL(I.EstadoLoteId,-1);
END;
GO
