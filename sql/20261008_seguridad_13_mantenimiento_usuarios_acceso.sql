SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_USUARIOS_ACCESO
(
      @Busqueda VARCHAR(200) = NULL
    , @Estado   BIT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @Busqueda = NULLIF(LTRIM(RTRIM(@Busqueda)), '');

    SELECT
          U.SegUsuarioId
        , U.NombreUsuario
        , U.NombresApellidos
        , U.Correo
        , U.Estado
        , U.UltimoAcceso
        , P.PerfilCodigo
        , P.PerfilDescripcion
        , RUA.UsuarioDni AS UsuarioDniResponsable
        , R.UsuarioNombresApellidos AS ResponsableNombre
    FROM dbo.SEG_USUARIO U
    OUTER APPLY
    (
        SELECT TOP (1)
              P2.PerfilCodigo
            , P2.PerfilDescripcion
        FROM dbo.SEG_USUARIO_PERFIL UP
        INNER JOIN dbo.SEG_PERFIL P2
            ON P2.PerfilId = UP.PerfilId
        WHERE UP.SegUsuarioId = U.SegUsuarioId
          AND UP.Estado = 1
          AND P2.Estado = 1
        ORDER BY UP.UsuarioPerfilId DESC
    ) P
    LEFT JOIN dbo.RESPONSABLE_USUARIO_ACCESO RUA
        ON RUA.SegUsuarioId = U.SegUsuarioId
       AND RUA.Estado = 1
    LEFT JOIN dbo.USUARIO R
        ON R.UsuarioDni = RUA.UsuarioDni
    WHERE (@Estado IS NULL OR U.Estado = @Estado)
      AND
      (
          @Busqueda IS NULL
          OR U.NombreUsuario LIKE '%' + @Busqueda + '%'
          OR U.NombresApellidos LIKE '%' + @Busqueda + '%'
          OR U.Correo LIKE '%' + @Busqueda + '%'
          OR R.UsuarioNombresApellidos LIKE '%' + @Busqueda + '%'
      )
    ORDER BY U.NombresApellidos, U.NombreUsuario;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_PERFILES_ACCESO
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
          PerfilId
        , PerfilCodigo
        , PerfilDescripcion
    FROM dbo.SEG_PERFIL
    WHERE Estado = 1
    ORDER BY PerfilDescripcion;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_CAMBIAR_ESTADO_USUARIO_ACCESO
(
      @SegUsuarioId INT
    , @Estado       BIT
    , @Usuario      VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @Usuario = NULLIF(LTRIM(RTRIM(@Usuario)), '');

    IF @Usuario IS NULL
    BEGIN
        SELECT
              -1 AS CodigoResultado
            , 'El usuario de auditoría es obligatorio.' AS Mensaje
            , @SegUsuarioId AS SegUsuarioId
            , @Estado AS Estado;
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.SEG_USUARIO
        WHERE SegUsuarioId = @SegUsuarioId
    )
    BEGIN
        SELECT
              -2 AS CodigoResultado
            , 'El usuario de acceso no existe.' AS Mensaje
            , @SegUsuarioId AS SegUsuarioId
            , @Estado AS Estado;
        RETURN;
    END;

    UPDATE dbo.SEG_USUARIO
    SET
          Estado = @Estado
        , AudUsuarioModificacion = @Usuario
        , AudFechaActualizacion = SYSDATETIME()
    WHERE SegUsuarioId = @SegUsuarioId;

    SELECT
          0 AS CodigoResultado
        , CASE WHEN @Estado = 1
               THEN 'Usuario activado correctamente.'
               ELSE 'Usuario inactivado correctamente.'
          END AS Mensaje
        , @SegUsuarioId AS SegUsuarioId
        , @Estado AS Estado;
END;
GO
