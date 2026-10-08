/*
 OVOCALIDAD 2.0
 Flujo transversal de firma documental - Fase 1: Especificaciones Técnicas.

 Flujo:
 PUBLICAR / VIGENTAR ET
 -> generar solicitudes a responsables
 -> responsable autenticado visualiza solicitud
 -> revalida contraseña en API
 -> SP_FIRMAR_DOCUMENTO registra evidencia y snapshot de firma
 -> la firma solo se muestra en esa versión documental.

 La tabla y SPs quedan preparados para reutilizarse en FT y CERTIFICADO.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/* ============================================================
   1. VINCULO RESPONSABLE DOCUMENTAL <-> USUARIO DE ACCESO
   ============================================================ */

IF OBJECT_ID('dbo.RESPONSABLE_USUARIO_ACCESO','U') IS NULL
BEGIN
    CREATE TABLE dbo.RESPONSABLE_USUARIO_ACCESO
    (
          UsuarioDni              VARCHAR(20) NOT NULL
        , SegUsuarioId            INT NULL
        , NombreUsuario           VARCHAR(100) NOT NULL
        , Estado                  BIT NOT NULL
            CONSTRAINT DF_RESP_USR_ACCESO_Estado DEFAULT(1)
        , AudUsuarioCreacion      VARCHAR(100) NOT NULL
        , AudFechaCreacion        DATETIME2(0) NOT NULL
            CONSTRAINT DF_RESP_USR_ACCESO_FechaCreacion DEFAULT(SYSDATETIME())
        , AudUsuarioModificacion  VARCHAR(100) NULL
        , AudFechaActualizacion   DATETIME2(0) NULL

        , CONSTRAINT PK_RESPONSABLE_USUARIO_ACCESO
            PRIMARY KEY (UsuarioDni)
    );
END;
GO

IF EXISTS
(
    SELECT 1
    FROM sys.key_constraints
    WHERE [name] = 'UQ_RESPONSABLE_USUARIO_ACCESO_NombreUsuario'
      AND parent_object_id = OBJECT_ID('dbo.RESPONSABLE_USUARIO_ACCESO')
)
BEGIN
    ALTER TABLE dbo.RESPONSABLE_USUARIO_ACCESO
    DROP CONSTRAINT UQ_RESPONSABLE_USUARIO_ACCESO_NombreUsuario;
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE [name] = 'UX_RESPONSABLE_USUARIO_ACCESO_NombreUsuario_Activo'
      AND object_id = OBJECT_ID('dbo.RESPONSABLE_USUARIO_ACCESO')
)
BEGIN
    CREATE UNIQUE INDEX UX_RESPONSABLE_USUARIO_ACCESO_NombreUsuario_Activo
        ON dbo.RESPONSABLE_USUARIO_ACCESO (NombreUsuario)
        WHERE Estado = 1;
END;
GO


/* ============================================================
   2. SOLICITUD / EVIDENCIA DE FIRMA DOCUMENTAL
   ============================================================ */

IF OBJECT_ID('dbo.DOCUMENTO_FIRMA_SOLICITUD','U') IS NULL
BEGIN
    CREATE TABLE dbo.DOCUMENTO_FIRMA_SOLICITUD
    (
          DocumentoFirmaSolicitudId BIGINT IDENTITY(1,1) NOT NULL
        , TipoDocumento             VARCHAR(20) NOT NULL
        , EntidadId                 INT NOT NULL
        , DocumentoCodigo           VARCHAR(100) NOT NULL
        , DocumentoDescripcion      VARCHAR(500) NOT NULL
        , VersionNumero             DECIMAL(10,2) NULL

        , TipoResponsabilidad       VARCHAR(50) NOT NULL
        , UsuarioDni                VARCHAR(20) NOT NULL
        , ResponsableNombre         VARCHAR(200) NOT NULL
        , UsuarioCargoHistorialId   INT NULL
        , CargoId                   INT NULL
        , CargoDescripcion          VARCHAR(200) NULL

        , SegUsuarioId              INT NULL
        , NombreUsuarioDestino      VARCHAR(100) NULL

        , EstadoSolicitud           VARCHAR(20) NOT NULL
            CONSTRAINT DF_DOC_FIRMA_SOL_Estado DEFAULT('PENDIENTE')

        , FechaSolicitud            DATETIME2(0) NOT NULL
            CONSTRAINT DF_DOC_FIRMA_SOL_Fecha DEFAULT(SYSDATETIME())

        , FechaFirma                DATETIME2(0) NULL
        , NombreUsuarioFirma        VARCHAR(100) NULL

        , FirmaMimeTypeSnapshot     VARCHAR(50) NULL
        , FirmaImagenSnapshot       VARBINARY(MAX) NULL
        , FirmaNombreArchivoSnapshot VARCHAR(255) NULL

        , AudUsuarioCreacion        VARCHAR(100) NOT NULL
        , AudFechaCreacion          DATETIME2(0) NOT NULL
            CONSTRAINT DF_DOC_FIRMA_SOL_AudFecha DEFAULT(SYSDATETIME())
        , AudUsuarioModificacion    VARCHAR(100) NULL
        , AudFechaActualizacion     DATETIME2(0) NULL

        , CONSTRAINT PK_DOCUMENTO_FIRMA_SOLICITUD
            PRIMARY KEY (DocumentoFirmaSolicitudId)

        , CONSTRAINT CK_DOCUMENTO_FIRMA_SOLICITUD_Estado
            CHECK (EstadoSolicitud IN ('PENDIENTE','FIRMADO','SIN_USUARIO','ANULADO'))

        , CONSTRAINT UQ_DOCUMENTO_FIRMA_SOLICITUD
            UNIQUE (TipoDocumento, EntidadId, UsuarioDni, TipoResponsabilidad)
    );

    CREATE INDEX IX_DOCUMENTO_FIRMA_SOLICITUD_Destino
        ON dbo.DOCUMENTO_FIRMA_SOLICITUD
        (
              NombreUsuarioDestino
            , EstadoSolicitud
            , FechaSolicitud DESC
        );
END;
GO


/* ============================================================
   3. GENERAR SOLICITUDES DE FIRMA PARA ET
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_GENERAR_SOLICITUDES_FIRMA_ET
(
      @VersionId        INT
    , @ResponsablesJson NVARCHAR(MAX)
    , @Usuario          VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
          @DocumentoCodigo      VARCHAR(100)
        , @DocumentoDescripcion VARCHAR(500)
        , @VersionNumero        DECIMAL(10,2);

    SELECT
          @DocumentoCodigo = D.DocumentoCodigo
        , @DocumentoDescripcion = D.DocumentoDescripcionDocumento
        , @VersionNumero = V.VersionNumero
    FROM dbo.VERSION V
    INNER JOIN dbo.DOCUMENTO D
        ON D.DocumentoId = V.DocumentoId
    WHERE V.VersionId = @VersionId;

    IF @DocumentoCodigo IS NULL
    BEGIN
        SELECT
              -1 CodigoResultado
            , 'No se encontró la versión de ET.' Mensaje
            , 0 CantidadGenerada
            , 0 CantidadSinUsuario;
        RETURN;
    END;

    IF ISJSON(@ResponsablesJson) <> 1
    BEGIN
        SELECT
              -2 CodigoResultado
            , 'La lista de responsables de la ET no es válida.' Mensaje
            , 0 CantidadGenerada
            , 0 CantidadSinUsuario;
        RETURN;
    END;

    CREATE TABLE #Responsables
    (
          TipoResponsabilidad     VARCHAR(100) NULL
        , IdRelacion              INT NULL
        , UsuarioDni              VARCHAR(20) NULL
        , UsuarioNombresApellidos VARCHAR(200) NULL
        , UsuarioCargoHistorialId INT NULL
        , CargoId                 INT NULL
        , CargoDescripcion        VARCHAR(200) NULL
    );

    INSERT INTO #Responsables
    (
          TipoResponsabilidad
        , IdRelacion
        , UsuarioDni
        , UsuarioNombresApellidos
        , UsuarioCargoHistorialId
        , CargoId
        , CargoDescripcion
    )
    SELECT
          J.TipoResponsabilidad
        , J.IdRelacion
        , J.UsuarioDni
        , J.UsuarioNombresApellidos
        , J.UsuarioCargoHistorialId
        , J.CargoId
        , J.CargoDescripcion
    FROM OPENJSON(@ResponsablesJson)
    WITH
    (
          TipoResponsabilidad     VARCHAR(100) '$.tipoResponsabilidad'
        , IdRelacion              INT          '$.idRelacion'
        , UsuarioDni              VARCHAR(20)  '$.usuarioDni'
        , UsuarioNombresApellidos VARCHAR(200) '$.usuarioNombresApellidos'
        , UsuarioCargoHistorialId INT          '$.usuarioCargoHistorialId'
        , CargoId                 INT          '$.cargoId'
        , CargoDescripcion        VARCHAR(200) '$.cargoDescripcion'
    ) J
    WHERE NULLIF(LTRIM(RTRIM(J.UsuarioDni)), '') IS NOT NULL;

    IF NOT EXISTS (SELECT 1 FROM #Responsables)
    BEGIN
        SELECT
              0 CodigoResultado
            , 'La ET no tiene responsables asignados; no se generaron solicitudes de firma.' Mensaje
            , 0 CantidadGenerada
            , 0 CantidadSinUsuario;
        RETURN;
    END;

    /* Vinculación automática únicamente si nombres/apellidos
       coinciden de manera única con una cuenta de acceso. */
    IF OBJECT_ID('dbo.SEG_USUARIO','U') IS NOT NULL
    BEGIN
        INSERT INTO dbo.RESPONSABLE_USUARIO_ACCESO
        (
              UsuarioDni
            , SegUsuarioId
            , NombreUsuario
            , Estado
            , AudUsuarioCreacion
            , AudFechaCreacion
        )
        SELECT
              R.UsuarioDni
            , MAX(SU.SegUsuarioId)
            , MAX(SU.NombreUsuario)
            , 1
            , @Usuario
            , SYSDATETIME()
        FROM #Responsables R
        INNER JOIN dbo.SEG_USUARIO SU
            ON LTRIM(RTRIM(SU.NombresApellidos))
             = LTRIM(RTRIM(R.UsuarioNombresApellidos))
        LEFT JOIN dbo.RESPONSABLE_USUARIO_ACCESO RA
            ON RA.UsuarioDni = R.UsuarioDni
        WHERE RA.UsuarioDni IS NULL
        GROUP BY
              R.UsuarioDni
            , R.UsuarioNombresApellidos
        HAVING COUNT(DISTINCT SU.SegUsuarioId) = 1;
    END;

    DECLARE @Antes INT =
    (
        SELECT COUNT(*)
        FROM dbo.DOCUMENTO_FIRMA_SOLICITUD
        WHERE TipoDocumento = 'ET'
          AND EntidadId = @VersionId
    );

    INSERT INTO dbo.DOCUMENTO_FIRMA_SOLICITUD
    (
          TipoDocumento
        , EntidadId
        , DocumentoCodigo
        , DocumentoDescripcion
        , VersionNumero
        , TipoResponsabilidad
        , UsuarioDni
        , ResponsableNombre
        , UsuarioCargoHistorialId
        , CargoId
        , CargoDescripcion
        , SegUsuarioId
        , NombreUsuarioDestino
        , EstadoSolicitud
        , FechaSolicitud
        , AudUsuarioCreacion
        , AudFechaCreacion
    )
    SELECT
          'ET'
        , @VersionId
        , @DocumentoCodigo
        , @DocumentoDescripcion
        , @VersionNumero
        , UPPER(LTRIM(RTRIM(R.TipoResponsabilidad)))
        , R.UsuarioDni
        , R.UsuarioNombresApellidos
        , R.UsuarioCargoHistorialId
        , R.CargoId
        , R.CargoDescripcion
        , RA.SegUsuarioId
        , RA.NombreUsuario
        , CASE
              WHEN RA.NombreUsuario IS NULL THEN 'SIN_USUARIO'
              ELSE 'PENDIENTE'
          END
        , SYSDATETIME()
        , @Usuario
        , SYSDATETIME()
    FROM #Responsables R
    LEFT JOIN dbo.RESPONSABLE_USUARIO_ACCESO RA
        ON RA.UsuarioDni = R.UsuarioDni
       AND RA.Estado = 1
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.DOCUMENTO_FIRMA_SOLICITUD DFS
        WHERE DFS.TipoDocumento = 'ET'
          AND DFS.EntidadId = @VersionId
          AND DFS.UsuarioDni = R.UsuarioDni
          AND DFS.TipoResponsabilidad = UPPER(LTRIM(RTRIM(R.TipoResponsabilidad)))
    );

    DECLARE
          @Despues INT =
          (
              SELECT COUNT(*)
              FROM dbo.DOCUMENTO_FIRMA_SOLICITUD
              WHERE TipoDocumento = 'ET'
                AND EntidadId = @VersionId
          )
        , @SinUsuario INT =
          (
              SELECT COUNT(*)
              FROM dbo.DOCUMENTO_FIRMA_SOLICITUD
              WHERE TipoDocumento = 'ET'
                AND EntidadId = @VersionId
                AND EstadoSolicitud = 'SIN_USUARIO'
          );

    SELECT
          0 CodigoResultado
        , CASE
              WHEN @SinUsuario > 0
              THEN CONCAT(
                    'Solicitudes de firma generadas. ',
                    @SinUsuario,
                    ' responsable(s) todavía no tienen usuario de acceso vinculado.'
                   )
              ELSE 'Solicitudes de firma generadas correctamente.'
          END Mensaje
        , (@Despues - @Antes) CantidadGenerada
        , @SinUsuario CantidadSinUsuario;
END;
GO


/* ============================================================
   4. LISTAR MIS SOLICITUDES
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_MIS_SOLICITUDES_FIRMA
(
      @NombreUsuario VARCHAR(100)
    , @Estado        VARCHAR(20) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @Estado = NULLIF(UPPER(LTRIM(RTRIM(@Estado))), '');

    /* Si existe una solicitud sin vínculo pero el nombre del
       responsable coincide de forma única con la cuenta actual,
       se termina de vincular automáticamente. */
    DECLARE
          @SegUsuarioId INT
        , @NombresApellidos VARCHAR(200);

    SELECT TOP(1)
          @SegUsuarioId = SegUsuarioId
        , @NombresApellidos = NombresApellidos
    FROM dbo.SEG_USUARIO
    WHERE NombreUsuario = @NombreUsuario;

    IF @SegUsuarioId IS NOT NULL
       AND @NombresApellidos IS NOT NULL
    BEGIN
        UPDATE DFS
        SET
              DFS.SegUsuarioId = @SegUsuarioId
            , DFS.NombreUsuarioDestino = @NombreUsuario
            , DFS.EstadoSolicitud = 'PENDIENTE'
            , DFS.AudUsuarioModificacion = @NombreUsuario
            , DFS.AudFechaActualizacion = SYSDATETIME()
        FROM dbo.DOCUMENTO_FIRMA_SOLICITUD DFS
        WHERE DFS.EstadoSolicitud = 'SIN_USUARIO'
          AND LTRIM(RTRIM(DFS.ResponsableNombre))
            = LTRIM(RTRIM(@NombresApellidos));

        INSERT INTO dbo.RESPONSABLE_USUARIO_ACCESO
        (
              UsuarioDni
            , SegUsuarioId
            , NombreUsuario
            , Estado
            , AudUsuarioCreacion
            , AudFechaCreacion
        )
        SELECT DISTINCT
              DFS.UsuarioDni
            , @SegUsuarioId
            , @NombreUsuario
            , 1
            , @NombreUsuario
            , SYSDATETIME()
        FROM dbo.DOCUMENTO_FIRMA_SOLICITUD DFS
        LEFT JOIN dbo.RESPONSABLE_USUARIO_ACCESO RA
            ON RA.UsuarioDni = DFS.UsuarioDni
        WHERE DFS.NombreUsuarioDestino = @NombreUsuario
          AND RA.UsuarioDni IS NULL;
    END;

    SELECT
          DFS.DocumentoFirmaSolicitudId
        , DFS.TipoDocumento
        , DFS.EntidadId
        , DFS.DocumentoCodigo
        , DFS.DocumentoDescripcion
        , DFS.VersionNumero
        , DFS.TipoResponsabilidad
        , DFS.UsuarioDni
        , DFS.ResponsableNombre
        , DFS.CargoDescripcion
        , DFS.EstadoSolicitud
        , DFS.FechaSolicitud
        , DFS.FechaFirma
        , CASE DFS.TipoDocumento
              WHEN 'ET'
              THEN CONCAT('/documentos/especificaciones/', DFS.EntidadId)
              WHEN 'FT'
              THEN CONCAT('/documentos/fichas-tecnicas/', DFS.EntidadId)
              ELSE NULL
          END UrlDocumento
    FROM dbo.DOCUMENTO_FIRMA_SOLICITUD DFS
    WHERE DFS.NombreUsuarioDestino = @NombreUsuario
      AND
      (
          @Estado IS NULL
          OR DFS.EstadoSolicitud = @Estado
      )
    ORDER BY
          CASE DFS.EstadoSolicitud
              WHEN 'PENDIENTE' THEN 0
              WHEN 'FIRMADO' THEN 1
              ELSE 2
          END
        , DFS.FechaSolicitud DESC;
END;
GO


/* ============================================================
   5. OBTENER MI SOLICITUD PARA UN DOCUMENTO
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_OBTENER_MI_SOLICITUD_FIRMA_DOCUMENTO
(
      @NombreUsuario VARCHAR(100)
    , @TipoDocumento VARCHAR(20)
    , @EntidadId     INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP(1)
          DFS.DocumentoFirmaSolicitudId
        , DFS.TipoDocumento
        , DFS.EntidadId
        , DFS.DocumentoCodigo
        , DFS.DocumentoDescripcion
        , DFS.VersionNumero
        , DFS.TipoResponsabilidad
        , DFS.UsuarioDni
        , DFS.ResponsableNombre
        , DFS.CargoDescripcion
        , DFS.EstadoSolicitud
        , DFS.FechaSolicitud
        , DFS.FechaFirma
        , CASE DFS.TipoDocumento
              WHEN 'ET'
              THEN CONCAT('/documentos/especificaciones/', DFS.EntidadId)
              WHEN 'FT'
              THEN CONCAT('/documentos/fichas-tecnicas/', DFS.EntidadId)
              ELSE NULL
          END UrlDocumento
    FROM dbo.DOCUMENTO_FIRMA_SOLICITUD DFS
    WHERE DFS.NombreUsuarioDestino = @NombreUsuario
      AND DFS.TipoDocumento = UPPER(@TipoDocumento)
      AND DFS.EntidadId = @EntidadId
      AND DFS.EstadoSolicitud IN ('PENDIENTE','FIRMADO')
    ORDER BY
          CASE WHEN DFS.EstadoSolicitud = 'PENDIENTE' THEN 0 ELSE 1 END
        , DFS.DocumentoFirmaSolicitudId DESC;
END;
GO


/* ============================================================
   6. FIRMAR DOCUMENTO
   La contraseña ya fue revalidada por IAuthService en API.
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_FIRMAR_DOCUMENTO
(
      @DocumentoFirmaSolicitudId BIGINT
    , @NombreUsuario             VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
          @UsuarioDni VARCHAR(20)
        , @EstadoSolicitud VARCHAR(20);

    SELECT
          @UsuarioDni = DFS.UsuarioDni
        , @EstadoSolicitud = DFS.EstadoSolicitud
    FROM dbo.DOCUMENTO_FIRMA_SOLICITUD DFS
    WHERE DFS.DocumentoFirmaSolicitudId = @DocumentoFirmaSolicitudId
      AND DFS.NombreUsuarioDestino = @NombreUsuario;

    IF @UsuarioDni IS NULL
    BEGIN
        SELECT
              -1 CodigoResultado
            , 'La solicitud no existe o no pertenece al usuario autenticado.' Mensaje
            , @DocumentoFirmaSolicitudId DocumentoFirmaSolicitudId
            , CAST(NULL AS VARCHAR(20)) EstadoSolicitud
            , CAST(NULL AS DATETIME2) FechaFirma;
        RETURN;
    END;

    IF @EstadoSolicitud = 'FIRMADO'
    BEGIN
        SELECT
              1 CodigoResultado
            , 'El documento ya fue firmado por este responsable.' Mensaje
            , @DocumentoFirmaSolicitudId DocumentoFirmaSolicitudId
            , 'FIRMADO' EstadoSolicitud
            , (
                SELECT FechaFirma
                FROM dbo.DOCUMENTO_FIRMA_SOLICITUD
                WHERE DocumentoFirmaSolicitudId = @DocumentoFirmaSolicitudId
              ) FechaFirma;
        RETURN;
    END;

    IF @EstadoSolicitud <> 'PENDIENTE'
    BEGIN
        SELECT
              -2 CodigoResultado
            , 'La solicitud no se encuentra pendiente de firma.' Mensaje
            , @DocumentoFirmaSolicitudId DocumentoFirmaSolicitudId
            , @EstadoSolicitud EstadoSolicitud
            , CAST(NULL AS DATETIME2) FechaFirma;
        RETURN;
    END;

    DECLARE
          @FirmaImagen VARBINARY(MAX)
        , @FirmaMimeType VARCHAR(50)
        , @FirmaNombreArchivo VARCHAR(255);

    SELECT TOP(1)
          @FirmaImagen = RF.FirmaImagen
        , @FirmaMimeType = RF.FirmaMimeType
        , @FirmaNombreArchivo = RF.FirmaNombreArchivo
    FROM dbo.RESPONSABLE_FIRMA RF
    WHERE RF.UsuarioDni = @UsuarioDni
      AND RF.Estado = 1;

    IF @FirmaImagen IS NULL
    BEGIN
        SELECT
              -3 CodigoResultado
            , 'No tienes una firma registrada. Registra tu firma antes de firmar el documento.' Mensaje
            , @DocumentoFirmaSolicitudId DocumentoFirmaSolicitudId
            , 'PENDIENTE' EstadoSolicitud
            , CAST(NULL AS DATETIME2) FechaFirma;
        RETURN;
    END;

    DECLARE @FechaFirma DATETIME2(0) = SYSDATETIME();

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.DOCUMENTO_FIRMA_SOLICITUD
        SET
              EstadoSolicitud = 'FIRMADO'
            , FechaFirma = @FechaFirma
            , NombreUsuarioFirma = @NombreUsuario
            , FirmaMimeTypeSnapshot = @FirmaMimeType
            , FirmaImagenSnapshot = @FirmaImagen
            , FirmaNombreArchivoSnapshot = @FirmaNombreArchivo
            , AudUsuarioModificacion = @NombreUsuario
            , AudFechaActualizacion = @FechaFirma
        WHERE DocumentoFirmaSolicitudId = @DocumentoFirmaSolicitudId
          AND EstadoSolicitud = 'PENDIENTE';

        COMMIT TRANSACTION;

        SELECT
              0 CodigoResultado
            , 'Documento firmado correctamente.' Mensaje
            , @DocumentoFirmaSolicitudId DocumentoFirmaSolicitudId
            , 'FIRMADO' EstadoSolicitud
            , @FechaFirma FechaFirma;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


/* ============================================================
   7. OBTENER FIRMA YA APLICADA A UN DOCUMENTO
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_OBTENER_FIRMA_DOCUMENTO_APLICADA
(
      @TipoDocumento VARCHAR(20)
    , @EntidadId     INT
    , @UsuarioDni    VARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP(1)
          DFS.DocumentoFirmaSolicitudId
        , DFS.TipoDocumento
        , DFS.EntidadId
        , DFS.UsuarioDni
        , DFS.TipoResponsabilidad
        , DFS.ResponsableNombre
        , DFS.CargoDescripcion
        , DFS.FirmaMimeTypeSnapshot FirmaMimeType
        , DFS.FirmaImagenSnapshot FirmaImagen
        , DFS.FechaFirma
    FROM dbo.DOCUMENTO_FIRMA_SOLICITUD DFS
    WHERE DFS.TipoDocumento = UPPER(@TipoDocumento)
      AND DFS.EntidadId = @EntidadId
      AND DFS.UsuarioDni = @UsuarioDni
      AND DFS.EstadoSolicitud = 'FIRMADO'
      AND DFS.FirmaImagenSnapshot IS NOT NULL
    ORDER BY DFS.FechaFirma DESC;
END;
GO


/* ============================================================
   8. OBTENER VÍNCULO RESPONSABLE <-> USUARIO DE ACCESO
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_OBTENER_VINCULO_RESPONSABLE_USUARIO
(
    @UsuarioDni VARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP(1)
          RA.UsuarioDni
        , RA.SegUsuarioId
        , RA.NombreUsuario
        , SU.NombresApellidos
    FROM dbo.RESPONSABLE_USUARIO_ACCESO RA
    LEFT JOIN dbo.SEG_USUARIO SU
        ON SU.SegUsuarioId = RA.SegUsuarioId
    WHERE RA.UsuarioDni = @UsuarioDni
      AND RA.Estado = 1;
END;
GO


/* ============================================================
   9. VINCULAR RESPONSABLE <-> USUARIO DE ACCESO
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_VINCULAR_RESPONSABLE_USUARIO_ACCESO
(
      @UsuarioDni    VARCHAR(20)
    , @NombreUsuario VARCHAR(100)
    , @Usuario       VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @UsuarioDni = NULLIF(LTRIM(RTRIM(@UsuarioDni)), '');
    SET @NombreUsuario = NULLIF(LTRIM(RTRIM(@NombreUsuario)), '');
    SET @Usuario = NULLIF(LTRIM(RTRIM(@Usuario)), '');

    IF @UsuarioDni IS NULL OR @NombreUsuario IS NULL OR @Usuario IS NULL
    BEGIN
        SELECT
              -1 CodigoResultado
            , 'Responsable, usuario de acceso y usuario de auditoría son obligatorios.' Mensaje
            , @UsuarioDni UsuarioDni
            , CAST(NULL AS INT) SegUsuarioId
            , @NombreUsuario NombreUsuario;
        RETURN;
    END;

    DECLARE @SegUsuarioId INT;

    SELECT TOP(1)
        @SegUsuarioId = SegUsuarioId
    FROM dbo.SEG_USUARIO
    WHERE NombreUsuario = @NombreUsuario;

    IF @SegUsuarioId IS NULL
    BEGIN
        SELECT
              -2 CodigoResultado
            , 'El usuario de acceso indicado no existe.' Mensaje
            , @UsuarioDni UsuarioDni
            , CAST(NULL AS INT) SegUsuarioId
            , @NombreUsuario NombreUsuario;
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        /* Una cuenta de acceso no puede quedar vinculada
           simultáneamente a responsables distintos. */
        UPDATE dbo.RESPONSABLE_USUARIO_ACCESO
        SET
              Estado = 0
            , AudUsuarioModificacion = @Usuario
            , AudFechaActualizacion = SYSDATETIME()
        WHERE NombreUsuario = @NombreUsuario
          AND UsuarioDni <> @UsuarioDni
          AND Estado = 1;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.RESPONSABLE_USUARIO_ACCESO
            WHERE UsuarioDni = @UsuarioDni
        )
        BEGIN
            UPDATE dbo.RESPONSABLE_USUARIO_ACCESO
            SET
                  SegUsuarioId = @SegUsuarioId
                , NombreUsuario = @NombreUsuario
                , Estado = 1
                , AudUsuarioModificacion = @Usuario
                , AudFechaActualizacion = SYSDATETIME()
            WHERE UsuarioDni = @UsuarioDni;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.RESPONSABLE_USUARIO_ACCESO
            (
                  UsuarioDni
                , SegUsuarioId
                , NombreUsuario
                , Estado
                , AudUsuarioCreacion
                , AudFechaCreacion
            )
            VALUES
            (
                  @UsuarioDni
                , @SegUsuarioId
                , @NombreUsuario
                , 1
                , @Usuario
                , SYSDATETIME()
            );
        END;

        /* Actualizar solicitudes que todavía estaban sin usuario. */
        UPDATE dbo.DOCUMENTO_FIRMA_SOLICITUD
        SET
              SegUsuarioId = @SegUsuarioId
            , NombreUsuarioDestino = @NombreUsuario
            , EstadoSolicitud =
                CASE
                    WHEN EstadoSolicitud = 'SIN_USUARIO' THEN 'PENDIENTE'
                    ELSE EstadoSolicitud
                END
            , AudUsuarioModificacion = @Usuario
            , AudFechaActualizacion = SYSDATETIME()
        WHERE UsuarioDni = @UsuarioDni
          AND EstadoSolicitud IN ('SIN_USUARIO','PENDIENTE');

        COMMIT TRANSACTION;

        SELECT
              0 CodigoResultado
            , 'Usuario de acceso vinculado correctamente.' Mensaje
            , @UsuarioDni UsuarioDni
            , @SegUsuarioId SegUsuarioId
            , @NombreUsuario NombreUsuario;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
