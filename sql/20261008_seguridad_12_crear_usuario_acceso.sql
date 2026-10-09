SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

CREATE OR ALTER PROCEDURE dbo.SP_CREAR_USUARIO_ACCESO
(
      @NombreUsuario    VARCHAR(100)
    , @NombresApellidos VARCHAR(200)
    , @Correo           VARCHAR(200) = NULL
    , @PasswordHash     VARCHAR(500)
    , @PerfilId         INT
    , @Usuario          VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @NombreUsuario = NULLIF(LTRIM(RTRIM(@NombreUsuario)), '');
    SET @NombresApellidos = NULLIF(LTRIM(RTRIM(@NombresApellidos)), '');
    SET @Correo = NULLIF(LTRIM(RTRIM(@Correo)), '');
    SET @PasswordHash = NULLIF(LTRIM(RTRIM(@PasswordHash)), '');
    SET @Usuario = NULLIF(LTRIM(RTRIM(@Usuario)), '');

    IF @NombreUsuario IS NULL
       OR @NombresApellidos IS NULL
       OR @PasswordHash IS NULL
       OR @PerfilId IS NULL
       OR @PerfilId <= 0
       OR @Usuario IS NULL
    BEGIN
        SELECT
              -1 AS CodigoResultado
            , 'Nombre de usuario, nombres, contraseña, perfil y usuario de auditoría son obligatorios.' AS Mensaje
            , CAST(NULL AS INT) AS SegUsuarioId
            , @NombreUsuario AS NombreUsuario
            , @PerfilId AS PerfilId;
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.SEG_USUARIO
        WHERE NombreUsuario = @NombreUsuario
    )
    BEGIN
        SELECT
              -2 AS CodigoResultado
            , 'El nombre de usuario ya existe.' AS Mensaje
            , SegUsuarioId
            , NombreUsuario
            , @PerfilId AS PerfilId
        FROM dbo.SEG_USUARIO
        WHERE NombreUsuario = @NombreUsuario;
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.SEG_PERFIL
        WHERE PerfilId = @PerfilId
          AND Estado = 1
    )
    BEGIN
        SELECT
              -3 AS CodigoResultado
            , 'El perfil indicado no existe o está inactivo.' AS Mensaje
            , CAST(NULL AS INT) AS SegUsuarioId
            , @NombreUsuario AS NombreUsuario
            , @PerfilId AS PerfilId;
        RETURN;
    END;

    DECLARE @SegUsuarioId INT;
    DECLARE @UsuarioPerfilId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF COLUMNPROPERTY(OBJECT_ID('dbo.SEG_USUARIO'), 'SegUsuarioId', 'IsIdentity') = 1
        BEGIN
            INSERT INTO dbo.SEG_USUARIO
            (
                  NombreUsuario
                , NombresApellidos
                , Correo
                , PasswordHash
                , Estado
                , AudUsuarioCreacion
                , AudFechaCreacion
            )
            VALUES
            (
                  @NombreUsuario
                , @NombresApellidos
                , @Correo
                , @PasswordHash
                , 1
                , @Usuario
                , SYSDATETIME()
            );

            SET @SegUsuarioId = CONVERT(INT, SCOPE_IDENTITY());
        END
        ELSE
        BEGIN
            SELECT @SegUsuarioId = ISNULL(MAX(SegUsuarioId), 0) + 1
            FROM dbo.SEG_USUARIO WITH (UPDLOCK, HOLDLOCK);

            INSERT INTO dbo.SEG_USUARIO
            (
                  SegUsuarioId
                , NombreUsuario
                , NombresApellidos
                , Correo
                , PasswordHash
                , Estado
                , AudUsuarioCreacion
                , AudFechaCreacion
            )
            VALUES
            (
                  @SegUsuarioId
                , @NombreUsuario
                , @NombresApellidos
                , @Correo
                , @PasswordHash
                , 1
                , @Usuario
                , SYSDATETIME()
            );
        END;

        IF COLUMNPROPERTY(OBJECT_ID('dbo.SEG_USUARIO_PERFIL'), 'UsuarioPerfilId', 'IsIdentity') = 1
        BEGIN
            INSERT INTO dbo.SEG_USUARIO_PERFIL
            (
                  SegUsuarioId
                , PerfilId
                , Estado
                , AudUsuarioCreacion
                , AudFechaCreacion
            )
            VALUES
            (
                  @SegUsuarioId
                , @PerfilId
                , 1
                , @Usuario
                , SYSDATETIME()
            );

            SET @UsuarioPerfilId = CONVERT(INT, SCOPE_IDENTITY());
        END
        ELSE
        BEGIN
            SELECT @UsuarioPerfilId = ISNULL(MAX(UsuarioPerfilId), 0) + 1
            FROM dbo.SEG_USUARIO_PERFIL WITH (UPDLOCK, HOLDLOCK);

            INSERT INTO dbo.SEG_USUARIO_PERFIL
            (
                  UsuarioPerfilId
                , SegUsuarioId
                , PerfilId
                , Estado
                , AudUsuarioCreacion
                , AudFechaCreacion
            )
            VALUES
            (
                  @UsuarioPerfilId
                , @SegUsuarioId
                , @PerfilId
                , 1
                , @Usuario
                , SYSDATETIME()
            );
        END;

        COMMIT TRANSACTION;

        SELECT
              0 AS CodigoResultado
            , 'Usuario de acceso creado correctamente.' AS Mensaje
            , @SegUsuarioId AS SegUsuarioId
            , @NombreUsuario AS NombreUsuario
            , @PerfilId AS PerfilId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
