/*
 OVOCALIDAD 2.0 - Gestión de secciones de Ficha Técnica.
*/
CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_SECCIONES_FT
(
    @VersionId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.VERSION V
        INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId = V.DocumentoId
        WHERE V.VersionId = @VersionId
          AND V.Estado = 1
          AND D.Estado = 1
          AND D.TipoDocumentoId = 3
    )
    BEGIN
        SELECT TOP (0)
              CAST(NULL AS INT) AS VersSeccId
            , CAST(NULL AS INT) AS VersionId
            , CAST(NULL AS INT) AS SeccionId
            , CAST(NULL AS VARCHAR(200)) AS SeccionDescripcion
            , CAST(NULL AS INT) AS IdTipoSeccion
            , CAST(NULL AS VARCHAR(150)) AS TipoSeccionDescripcion
            , CAST(NULL AS INT) AS Orden
            , CAST(NULL AS BIT) AS PuedeEliminarse
            , CAST(NULL AS BIT) AS PermiteReordenar
            , CAST(NULL AS VARCHAR(MAX)) AS Contenido;
        RETURN;
    END;

    SELECT
          VS.VersSeccId
        , VS.VersionId
        , VS.SeccionId
        , S.SeccionDescripcion
        , S.IdTipoSeccion
        , TS.Descripcion AS TipoSeccionDescripcion
        , VS.Orden
        , S.PuedeEliminarse
        , S.PermiteReordenar
        , VSC.Contenido
    FROM dbo.VERSIONSECCION VS
    INNER JOIN dbo.SECCION S
        ON S.SeccionId = VS.SeccionId
    LEFT JOIN dbo.TIPO_SECCION TS
        ON TS.IdTipoSeccion = S.IdTipoSeccion
    OUTER APPLY
    (
        SELECT TOP (1) C.Contenido
        FROM dbo.VERSIONSECCIONCONTENIDO C
        WHERE C.VersSeccId = VS.VersSeccId
          AND C.Estado = 1
        ORDER BY C.VersionSeccionContenidoId DESC
    ) VSC
    WHERE VS.VersionId = @VersionId
      AND VS.Estado = 1
      AND S.Estado = 1
    ORDER BY ISNULL(VS.Orden, 2147483647), VS.VersSeccId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_GUARDAR_CONTENIDO_SECCION_FT
(
    @VersionId INT,
    @VersSeccId INT,
    @Contenido VARCHAR(MAX) = NULL,
    @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @VersionSeccionContenidoId INT;

    BEGIN TRY
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.VERSIONSECCION VS
            INNER JOIN dbo.VERSION V ON V.VersionId = VS.VersionId
            INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId = V.DocumentoId
            WHERE VS.VersSeccId = @VersSeccId
              AND VS.VersionId = @VersionId
              AND VS.Estado = 1
              AND V.Estado = 1
              AND D.Estado = 1
              AND D.TipoDocumentoId = 3
        )
            THROW 50001, 'La sección indicada no pertenece a la versión FT.', 1;

        SELECT TOP (1)
            @VersionSeccionContenidoId = VersionSeccionContenidoId
        FROM dbo.VERSIONSECCIONCONTENIDO
        WHERE VersSeccId = @VersSeccId
          AND Estado = 1
        ORDER BY VersionSeccionContenidoId DESC;

        IF @VersionSeccionContenidoId IS NULL
        BEGIN
            INSERT INTO dbo.VERSIONSECCIONCONTENIDO
            (
                VersSeccId, Contenido, Estado,
                AudUsuarioCreacion, AudFechaCreacion
            )
            VALUES
            (
                @VersSeccId, @Contenido, 1,
                @Usuario, SYSDATETIME()
            );

            SET @VersionSeccionContenidoId = CONVERT(INT, SCOPE_IDENTITY());
        END
        ELSE
        BEGIN
            UPDATE dbo.VERSIONSECCIONCONTENIDO
            SET
                Contenido = @Contenido,
                AudUsuarioModificacion = @Usuario,
                AudFechaActualizacion = SYSDATETIME()
            WHERE VersionSeccionContenidoId = @VersionSeccionContenidoId;
        END;

        SELECT
            0 AS CodigoResultado,
            'Contenido de sección FT guardado correctamente.' AS Mensaje,
            @VersionSeccionContenidoId AS VersionSeccionContenidoId,
            @VersSeccId AS VersSeccId;
    END TRY
    BEGIN CATCH
        SELECT -1 AS CodigoResultado, ERROR_MESSAGE() AS Mensaje,
               CAST(NULL AS INT) AS VersionSeccionContenidoId,
               @VersSeccId AS VersSeccId;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_AGREGAR_SECCION_FT
(
    @VersionId INT,
    @SeccionId INT,
    @Orden INT = NULL,
    @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @VersSeccId INT;

    BEGIN TRY
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.VERSION V
            INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId = V.DocumentoId
            WHERE V.VersionId = @VersionId
              AND V.Estado = 1
              AND D.Estado = 1
              AND D.TipoDocumentoId = 3
        )
            THROW 50001, 'La versión FT no existe o está inactiva.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.SECCION WHERE SeccionId=@SeccionId AND Estado=1)
            THROW 50002, 'La sección seleccionada no existe o está inactiva.', 1;

        IF EXISTS
        (
            SELECT 1 FROM dbo.VERSIONSECCION
            WHERE VersionId=@VersionId AND SeccionId=@SeccionId AND Estado=1
        )
            THROW 50003, 'La sección ya está incluida en la ficha técnica.', 1;

        IF @Orden IS NULL
            SELECT @Orden = ISNULL(MAX(Orden),0)+1
            FROM dbo.VERSIONSECCION
            WHERE VersionId=@VersionId AND Estado=1;

        IF EXISTS
        (
            SELECT 1 FROM dbo.VERSIONSECCION
            WHERE VersionId=@VersionId AND SeccionId=@SeccionId
        )
        BEGIN
            UPDATE dbo.VERSIONSECCION
            SET Estado=1, Orden=@Orden,
                AudUsuarioModificacion=@Usuario,
                AudFechaActualizacion=SYSDATETIME()
            WHERE VersionId=@VersionId AND SeccionId=@SeccionId;

            SELECT @VersSeccId=VersSeccId
            FROM dbo.VERSIONSECCION
            WHERE VersionId=@VersionId AND SeccionId=@SeccionId;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.VERSIONSECCION
            (
                VersionId, SeccionId, Orden, Estado,
                AudUsuarioCreacion, AudFechaCreacion
            )
            VALUES
            (
                @VersionId, @SeccionId, @Orden, 1,
                @Usuario, SYSDATETIME()
            );
            SET @VersSeccId=CONVERT(INT,SCOPE_IDENTITY());
        END;

        SELECT 0 CodigoResultado, 'Sección agregada a la FT correctamente.' Mensaje,
               @VersSeccId VersSeccId, @VersionId VersionId, @SeccionId SeccionId, @Orden Orden;
    END TRY
    BEGIN CATCH
        SELECT -1 CodigoResultado, ERROR_MESSAGE() Mensaje,
               CAST(NULL AS INT) VersSeccId, @VersionId VersionId, @SeccionId SeccionId, @Orden Orden;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_QUITAR_SECCION_FT
(
    @VersionId INT,
    @VersSeccId INT,
    @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.VERSIONSECCION VS
            INNER JOIN dbo.VERSION V ON V.VersionId=VS.VersionId
            INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId=V.DocumentoId
            WHERE VS.VersSeccId=@VersSeccId
              AND VS.VersionId=@VersionId
              AND VS.Estado=1
              AND D.TipoDocumentoId=3
        )
            THROW 50001, 'La sección indicada no pertenece a la versión FT.', 1;

        UPDATE dbo.VERSIONSECCIONCONTENIDO
        SET Estado=0,
            AudUsuarioModificacion=@Usuario,
            AudFechaActualizacion=SYSDATETIME()
        WHERE VersSeccId=@VersSeccId AND Estado=1;

        UPDATE dbo.VERSIONSECCION
        SET Estado=0,
            AudUsuarioModificacion=@Usuario,
            AudFechaActualizacion=SYSDATETIME()
        WHERE VersSeccId=@VersSeccId AND VersionId=@VersionId;

        SELECT 0 CodigoResultado, 'Sección retirada de la FT correctamente.' Mensaje,
               @VersSeccId VersSeccId;
    END TRY
    BEGIN CATCH
        SELECT -1 CodigoResultado, ERROR_MESSAGE() Mensaje, @VersSeccId VersSeccId;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_REORDENAR_SECCIONES_FT
(
    @VersionId INT,
    @SeccionesJson VARCHAR(MAX),
    @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF ISJSON(@SeccionesJson) <> 1
            THROW 50001, 'El orden de secciones no tiene un formato válido.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.VERSION V
            INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId=V.DocumentoId
            WHERE V.VersionId=@VersionId
              AND V.Estado=1
              AND D.Estado=1
              AND D.TipoDocumentoId=3
        )
            THROW 50002, 'La versión FT no existe o está inactiva.', 1;

        DECLARE @Orden TABLE (VersSeccId INT PRIMARY KEY, Orden INT NOT NULL);

        INSERT INTO @Orden(VersSeccId,Orden)
        SELECT VersSeccId, Orden
        FROM OPENJSON(@SeccionesJson)
        WITH
        (
            VersSeccId INT '$.versSeccId',
            Orden INT '$.orden'
        );

        IF EXISTS
        (
            SELECT 1
            FROM @Orden O
            LEFT JOIN dbo.VERSIONSECCION VS
              ON VS.VersSeccId=O.VersSeccId
             AND VS.VersionId=@VersionId
             AND VS.Estado=1
            WHERE VS.VersSeccId IS NULL
        )
            THROW 50003, 'Una o más secciones no pertenecen a la versión FT.', 1;

        UPDATE VS
        SET VS.Orden=O.Orden,
            VS.AudUsuarioModificacion=@Usuario,
            VS.AudFechaActualizacion=SYSDATETIME()
        FROM dbo.VERSIONSECCION VS
        INNER JOIN @Orden O ON O.VersSeccId=VS.VersSeccId
        WHERE VS.VersionId=@VersionId AND VS.Estado=1;

        SELECT 0 CodigoResultado, 'Orden de secciones FT actualizado correctamente.' Mensaje;
    END TRY
    BEGIN CATCH
        SELECT -1 CodigoResultado, ERROR_MESSAGE() Mensaje;
    END CATCH;
END;
GO
