/*
 OVOCALIDAD 2.0
 Plantilla predeterminada de certificado por versión FT.
 La plantilla predeterminada se resolverá automáticamente al emitir.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF COL_LENGTH('dbo.CERTIFICADOPLANTILLA','EsPredeterminada') IS NULL
BEGIN
    ALTER TABLE dbo.CERTIFICADOPLANTILLA
    ADD EsPredeterminada BIT NOT NULL
        CONSTRAINT DF_CERTIFICADOPLANTILLA_EsPredeterminada DEFAULT(0);
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id=OBJECT_ID('dbo.CERTIFICADOPLANTILLA')
      AND name='UX_CERTIFICADOPLANTILLA_PREDETERMINADA_VERSIONFT'
)
BEGIN
    CREATE UNIQUE INDEX UX_CERTIFICADOPLANTILLA_PREDETERMINADA_VERSIONFT
        ON dbo.CERTIFICADOPLANTILLA(VersionFtId)
        WHERE Estado=1 AND EsPredeterminada=1;
END;
GO

/* Si una FT tiene plantillas pero ninguna predeterminada,
   se marca automáticamente la primera activa.
   Esto permite usar el flujo inmediatamente hasta tener mantenedor. */
;WITH P AS
(
    SELECT
          CP.CertificadoPlantillaId
        , CP.VersionFtId
        , ROW_NUMBER() OVER
          (
              PARTITION BY CP.VersionFtId
              ORDER BY CP.CertificadoPlantillaId
          ) RN
    FROM dbo.CERTIFICADOPLANTILLA CP
    WHERE CP.Estado=1
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.CERTIFICADOPLANTILLA X
          WHERE X.VersionFtId=CP.VersionFtId
            AND X.Estado=1
            AND X.EsPredeterminada=1
      )
)
UPDATE CP
SET
      CP.EsPredeterminada=1
    , CP.AudUsuarioModificacion='MIGRACION_CERTIFICADO_DEFAULT'
    , CP.AudFechaActualizacion=SYSDATETIME()
FROM dbo.CERTIFICADOPLANTILLA CP
INNER JOIN P
    ON P.CertificadoPlantillaId=CP.CertificadoPlantillaId
WHERE P.RN=1;
GO

CREATE OR ALTER PROCEDURE dbo.SP_OBTENER_PLANTILLA_PREDETERMINADA_CERTIFICADO
(
    @LoteId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
          @VersionEtId INT
        , @ProductoCodigo VARCHAR(50);

    SELECT
          @VersionEtId=L.VersionId
        , @ProductoCodigo=COALESCE(L.ProductoCodigo,D.ProductoCodigo)
    FROM dbo.LOTE L
    INNER JOIN dbo.VERSION V
        ON V.VersionId=L.VersionId
    INNER JOIN dbo.DOCUMENTO D
        ON D.DocumentoId=V.DocumentoId
    WHERE L.LoteId=@LoteId
      AND L.Estado='ACTIVO';

    IF @VersionEtId IS NULL
        THROW 50001,'El lote indicado no existe o está inactivo.',1;

    SELECT TOP(1)
          CP.CertificadoPlantillaId
        , CP.VersionFtId
        , CP.Nombre
        , CP.Descripcion
        , CP.EsPredeterminada
        , D.DocumentoId
        , D.DocumentoCodigo
        , D.DocumentoDescripcionDocumento
        , D.ProductoCodigo
        , V.VersionNumero
        , V.EstVerId
        , CP.AudUsuarioCreacion
        , CP.AudFechaCreacion
        , (
            SELECT COUNT(*)
            FROM dbo.CERTIFICADOPLANTILLASECCION S
            WHERE S.CertificadoPlantillaId=CP.CertificadoPlantillaId
              AND S.Estado=1
          ) AS CantidadSecciones
        , (
            SELECT COUNT(*)
            FROM dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA RC
            INNER JOIN dbo.CERTIFICADOPLANTILLARESULTADO R
                ON R.CertificadoPlantillaResultadoId=RC.CertificadoPlantillaResultadoId
               AND R.Estado=1
            INNER JOIN dbo.CERTIFICADOPLANTILLASECCION S
                ON S.CertificadoPlantillaSeccionId=R.CertificadoPlantillaSeccionId
               AND S.Estado=1
            WHERE S.CertificadoPlantillaId=CP.CertificadoPlantillaId
              AND RC.Estado=1
          ) AS CantidadCaracteristicas
    FROM dbo.CERTIFICADOPLANTILLA CP
    INNER JOIN dbo.VERSION V
        ON V.VersionId=CP.VersionFtId
    INNER JOIN dbo.DOCUMENTO D
        ON D.DocumentoId=V.DocumentoId
    WHERE CP.Estado=1
      AND CP.EsPredeterminada=1
      AND D.TipoDocumentoId=3
      AND D.Estado=1
      AND V.Estado=1
      AND D.ProductoCodigo=@ProductoCodigo
      AND
      (
          V.VersionEtOrigenId IS NULL
          OR V.VersionEtOrigenId=@VersionEtId
      )
    ORDER BY
          CASE WHEN V.VersionEtOrigenId=@VersionEtId THEN 0 ELSE 1 END
        , V.VersionNumero DESC
        , CP.CertificadoPlantillaId DESC;
END;
GO

/* Listado normalizado: ahora expone EsPredeterminada */
CREATE OR ALTER PROCEDURE dbo.SP_LISTAR_PLANTILLAS_CERTIFICADO
(
    @VersionFtId INT=NULL,
    @ProductoCodigo VARCHAR(50)=NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
          CP.CertificadoPlantillaId
        , CP.VersionFtId
        , CP.Nombre
        , CP.Descripcion
        , CP.EsPredeterminada
        , D.DocumentoId
        , D.DocumentoCodigo
        , D.DocumentoDescripcionDocumento
        , D.ProductoCodigo
        , V.VersionNumero
        , V.EstVerId
        , CP.AudUsuarioCreacion
        , CP.AudFechaCreacion
        , COUNT(DISTINCT CASE WHEN CPS.Estado=1 THEN CPS.CertificadoPlantillaSeccionId END) CantidadSecciones
        , COUNT(DISTINCT CASE WHEN RC.Estado=1 THEN RC.CertificadoPlantillaResultadoCaracteristicaId END) CantidadCaracteristicas
    FROM dbo.CERTIFICADOPLANTILLA CP
    INNER JOIN dbo.VERSION V
        ON V.VersionId=CP.VersionFtId
    INNER JOIN dbo.DOCUMENTO D
        ON D.DocumentoId=V.DocumentoId
    LEFT JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
        ON CPS.CertificadoPlantillaId=CP.CertificadoPlantillaId
       AND CPS.Estado=1
    LEFT JOIN dbo.CERTIFICADOPLANTILLARESULTADO R
        ON R.CertificadoPlantillaSeccionId=CPS.CertificadoPlantillaSeccionId
       AND R.Estado=1
    LEFT JOIN dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA RC
        ON RC.CertificadoPlantillaResultadoId=R.CertificadoPlantillaResultadoId
       AND RC.Estado=1
    WHERE CP.Estado=1
      AND (@VersionFtId IS NULL OR CP.VersionFtId=@VersionFtId)
      AND (@ProductoCodigo IS NULL OR D.ProductoCodigo=@ProductoCodigo)
    GROUP BY
          CP.CertificadoPlantillaId
        , CP.VersionFtId
        , CP.Nombre
        , CP.Descripcion
        , CP.EsPredeterminada
        , D.DocumentoId
        , D.DocumentoCodigo
        , D.DocumentoDescripcionDocumento
        , D.ProductoCodigo
        , V.VersionNumero
        , V.EstVerId
        , CP.AudUsuarioCreacion
        , CP.AudFechaCreacion
    ORDER BY
          D.ProductoCodigo
        , CP.EsPredeterminada DESC
        , CP.Nombre;
END;
GO

/* Obtener plantilla también devuelve el flag */
CREATE OR ALTER PROCEDURE dbo.SP_OBTENER_PLANTILLA_CERTIFICADO
(
    @CertificadoPlantillaId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.CERTIFICADOPLANTILLA
        WHERE CertificadoPlantillaId=@CertificadoPlantillaId
          AND Estado=1
    )
        THROW 50001,'La plantilla de certificado no existe o está inactiva.',1;

    SELECT
          CP.CertificadoPlantillaId
        , CP.VersionFtId
        , CP.Nombre
        , CP.Descripcion
        , CP.EsPredeterminada
        , D.DocumentoCodigo
        , D.DocumentoDescripcionDocumento
        , D.ProductoCodigo
        , V.VersionNumero
        , V.EstVerId
        , EV.EstVerDescripcion EstadoVersionFt
    FROM dbo.CERTIFICADOPLANTILLA CP
    INNER JOIN dbo.VERSION V ON V.VersionId=CP.VersionFtId
    INNER JOIN dbo.DOCUMENTO D ON D.DocumentoId=V.DocumentoId
    INNER JOIN dbo.ESTADOVERSION EV ON EV.EstVerId=V.EstVerId
    WHERE CP.CertificadoPlantillaId=@CertificadoPlantillaId
      AND CP.Estado=1;

    SELECT
          CPS.CertificadoPlantillaSeccionId
        , CPS.CertificadoPlantillaId
        , CS.CertificadoSeccionId
        , CS.Codigo SeccionCodigo
        , CS.Descripcion SeccionDescripcion
        , CS.TipoContenido
        , CS.PuedeEliminarse
        , CS.PermiteReordenar
        , CPS.Orden
        , CPS.Visible
        , CONT.Contenido
    FROM dbo.CERTIFICADOPLANTILLASECCION CPS
    INNER JOIN dbo.CERTIFICADOSECCION CS
        ON CS.CertificadoSeccionId=CPS.CertificadoSeccionId
    OUTER APPLY
    (
        SELECT TOP(1) C.Contenido
        FROM dbo.CERTIFICADOPLANTILLASECCIONCONTENIDO C
        WHERE C.CertificadoPlantillaSeccionId=CPS.CertificadoPlantillaSeccionId
          AND C.Estado=1
        ORDER BY C.CertificadoPlantillaSeccionContenidoId DESC
    ) CONT
    WHERE CPS.CertificadoPlantillaId=@CertificadoPlantillaId
      AND CPS.Estado=1
    ORDER BY CPS.Orden;

    SELECT
          R.CertificadoPlantillaResultadoId
        , R.CertificadoPlantillaSeccionId
        , R.Titulo
        , R.Orden
        , R.Visible
        , R.ModoSeleccion
        , R.VersionFaseId
        , VF.FaseId
        , VF.CodigoReferencia FaseCodigo
        , COALESCE(NULLIF(LTRIM(RTRIM(VF.Descripcion)),''),VF.CodigoReferencia) FaseDescripcion
        , R.TipoCaractId
        , TC.TipoCaractDescripcion
    FROM dbo.CERTIFICADOPLANTILLARESULTADO R
    INNER JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
        ON CPS.CertificadoPlantillaSeccionId=R.CertificadoPlantillaSeccionId
    LEFT JOIN dbo.VERSIONFASE VF
        ON VF.VersionFaseId=R.VersionFaseId
       AND VF.Estado=1
    LEFT JOIN dbo.TIPO_CARACTERISTICA TC
        ON TC.TipoCaractId=R.TipoCaractId
    WHERE CPS.CertificadoPlantillaId=@CertificadoPlantillaId
      AND CPS.Estado=1
      AND R.Estado=1
    ORDER BY R.Orden;

    SELECT
          RC.CertificadoPlantillaResultadoCaracteristicaId
        , RC.CertificadoPlantillaResultadoId
        , RC.VersionFtCaracteristicaId
        , VFC.CaracteristicaId
        , C.CaracteristicaDescripcion Determinacion
        , C.TipoCaractId
        , TC.TipoCaractDescripcion
        , VFC.FaseId
        , VFC.VersionFaseId
        , VF.CodigoReferencia FaseCodigo
        , COALESCE(NULLIF(LTRIM(RTRIM(VF.Descripcion)),''),VF.CodigoReferencia) FaseDescripcion
        , VFC.TipoCriterioId
        , VFC.ValorCuantitativoInicial
        , VFC.ValorCuantitativoFinal
        , VFC.ValorCuantitativoIgual
        , VFC.ValorCualitativo
        , VFC.UnidadDeMedida
        , ME.MetEnsayoDescripcion
        , VFC.ObligatorioCertificado
        , RC.Orden
    FROM dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA RC
    INNER JOIN dbo.CERTIFICADOPLANTILLARESULTADO R
        ON R.CertificadoPlantillaResultadoId=RC.CertificadoPlantillaResultadoId
    INNER JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
        ON CPS.CertificadoPlantillaSeccionId=R.CertificadoPlantillaSeccionId
    INNER JOIN dbo.VERSIONFTCARACTERISTICA VFC
        ON VFC.VersionFtCaracteristicaId=RC.VersionFtCaracteristicaId
    INNER JOIN dbo.CARACTERISTICA C
        ON C.CaracteristicaId=VFC.CaracteristicaId
    LEFT JOIN dbo.TIPO_CARACTERISTICA TC
        ON TC.TipoCaractId=C.TipoCaractId
    LEFT JOIN dbo.VERSIONFASE VF
        ON VF.VersionFaseId=VFC.VersionFaseId
       AND VF.Estado=1
    LEFT JOIN dbo.METODO_DE_ENSAYO ME
        ON ME.MetEnsayoId=C.MetEnsayoId
    WHERE CPS.CertificadoPlantillaId=@CertificadoPlantillaId
      AND CPS.Estado=1
      AND R.Estado=1
      AND RC.Estado=1
    ORDER BY R.Orden,RC.Orden;
END;
GO
