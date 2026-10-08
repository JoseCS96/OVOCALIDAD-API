/*
 OVOCALIDAD 2.0 - Emisión de certificados
 Flujo:
   lote liberado + plantilla -> previsualización
   emitir -> snapshot CERTIFICADO + CERTIFICADODETALLE
   obtener emitido -> reimpresión histórica
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

CREATE OR ALTER PROCEDURE dbo.SP_PREVISUALIZAR_CERTIFICADO
(
      @LoteId INT
    , @CertificadoPlantillaId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
          @VersionFtId INT
        , @ProductoCodigo VARCHAR(50)
        , @VersionEtOrigenId INT;

    SELECT
          @VersionFtId = CP.VersionFtId
        , @ProductoCodigo = D.ProductoCodigo
        , @VersionEtOrigenId = V.VersionEtOrigenId
    FROM dbo.CERTIFICADOPLANTILLA CP
    INNER JOIN dbo.VERSION V
        ON V.VersionId = CP.VersionFtId
    INNER JOIN dbo.DOCUMENTO D
        ON D.DocumentoId = V.DocumentoId
    WHERE CP.CertificadoPlantillaId = @CertificadoPlantillaId
      AND CP.Estado = 1
      AND V.Estado = 1
      AND D.Estado = 1;

    IF @VersionFtId IS NULL
        THROW 50001,'La plantilla de certificado no existe o está inactiva.',1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.LOTE L
        INNER JOIN dbo.ESTADO_LOTE EL
            ON EL.EstadoLoteId = L.EstadoLoteId
        WHERE L.LoteId = @LoteId
          AND L.Estado = 'ACTIVO'
          AND EL.Codigo = 'LIBERADO'
    )
        THROW 50002,'El lote no está liberado para emisión de certificado.',1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.CERTIFICADO
        WHERE LoteId = @LoteId
          AND Estado = 'EMITIDO'
    )
        THROW 50003,'El lote ya tiene un certificado emitido.',1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.LOTE L
        INNER JOIN dbo.VERSION VE
            ON VE.VersionId = L.VersionId
        INNER JOIN dbo.DOCUMENTO DE
            ON DE.DocumentoId = VE.DocumentoId
        WHERE L.LoteId = @LoteId
          AND COALESCE(L.ProductoCodigo,DE.ProductoCodigo) = @ProductoCodigo
          AND (@VersionEtOrigenId IS NULL OR @VersionEtOrigenId = L.VersionId)
    )
        THROW 50004,'La plantilla seleccionada no corresponde al producto/ET del lote.',1;

    /* RS1 */
    SELECT
          CAST(NULL AS INT) AS CertificadoId
        , L.LoteId
        , L.CodigoLote
        , COALESCE(L.ProductoCodigo,DE.ProductoCodigo) AS ProductoCodigo
        , COALESCE(GI.NombreGenesis,DE.DocumentoDescripcionDocumento) AS ProductoDescripcion
        , L.FechaHoraProduccion
        , CP.CertificadoPlantillaId
        , CP.Nombre AS PlantillaNombre
        , CP.VersionFtId
        , DFT.DocumentoCodigo
        , VFT.VersionNumero
        , CAST(NULL AS VARCHAR(50)) AS NumeroCertificado
        , SYSDATETIME() AS FechaEmision
        , 'PREVISUALIZACION' AS Estado
    FROM dbo.LOTE L
    INNER JOIN dbo.VERSION VE
        ON VE.VersionId = L.VersionId
    INNER JOIN dbo.DOCUMENTO DE
        ON DE.DocumentoId = VE.DocumentoId
    LEFT JOIN dbo.GENESIS_ITEM GI
        ON GI.CodigoGenesis = L.CodigoGenesis
    INNER JOIN dbo.CERTIFICADOPLANTILLA CP
        ON CP.CertificadoPlantillaId = @CertificadoPlantillaId
    INNER JOIN dbo.VERSION VFT
        ON VFT.VersionId = CP.VersionFtId
    INNER JOIN dbo.DOCUMENTO DFT
        ON DFT.DocumentoId = VFT.DocumentoId
    WHERE L.LoteId = @LoteId;

    /* RS2: secciones visuales (RESULTADOS se devuelve también como marcador) */
    SELECT
          CS.Codigo AS TipoSeccion
        , CS.Descripcion AS TituloSeccion
        , CPS.Orden AS OrdenSeccion
        , CASE CS.Codigo
              WHEN 'DATOS_EMPRESA' THEN
                  (
                      SELECT TOP(1)
                            CE.RazonSocial AS razonSocial
                          , CE.NombreComercial AS nombreComercial
                          , CE.Direccion AS direccion
                          , CE.Telefono AS telefono
                          , CE.Fax AS fax
                          , CE.Correo AS correo
                          , CE.SitioWeb AS sitioWeb
                          , CE.Ruc AS ruc
                      FROM dbo.CERTIFICADOEMPRESA CE
                      WHERE CE.Estado = 1
                      ORDER BY CE.CertificadoEmpresaId DESC
                      FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                  )
              WHEN 'PRODUCTO' THEN
                  (
                      SELECT
                            COALESCE(L.ProductoCodigo,DE.ProductoCodigo) AS productoCodigo
                          , COALESCE(GI.NombreGenesis,DE.DocumentoDescripcionDocumento) AS productoDescripcion
                          , DFT.DocumentoCodigo AS fichaTecnica
                          , VFT.VersionNumero AS versionFt
                      FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                  )
              WHEN 'DATOS_LOTE' THEN
                  (
                      SELECT
                            L.CodigoLote AS lote
                          , L.FechaHoraProduccion AS fechaProduccion
                          , (
                                SELECT TOP(1) S.Contenido
                                FROM dbo.VERSIONFTSECCION S
                                WHERE S.VersionId = CP.VersionFtId
                                  AND S.Estado = 1
                                  AND S.Visible = 1
                                  AND (
                                        UPPER(S.Titulo) LIKE '%VIDA UTIL%'
                                     OR UPPER(S.Titulo) LIKE '%VIDA ÚTIL%'
                                  )
                                ORDER BY S.Orden
                            ) AS vidaUtil
                      FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                  )
              WHEN 'ALMACENAMIENTO' THEN
                  COALESCE
                  (
                      (
                          SELECT TOP(1) S.Contenido
                          FROM dbo.VERSIONFTSECCION S
                          WHERE S.VersionId = CP.VersionFtId
                            AND S.Estado = 1
                            AND S.Visible = 1
                            AND UPPER(S.Titulo) LIKE '%ALMACEN%'
                          ORDER BY S.Orden
                      ),
                      CONT.Contenido
                  )
              WHEN 'REFERENCIAS' THEN
                  (
                      SELECT STRING_AGG(X.MetodoEnsayo, CHAR(10))
                      FROM
                      (
                          SELECT DISTINCT ME.MetEnsayoDescripcion AS MetodoEnsayo
                          FROM dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA RC
                          INNER JOIN dbo.CERTIFICADOPLANTILLARESULTADO R
                              ON R.CertificadoPlantillaResultadoId = RC.CertificadoPlantillaResultadoId
                             AND R.Estado = 1
                             AND R.Visible = 1
                          INNER JOIN dbo.CERTIFICADOPLANTILLASECCION CPSR
                              ON CPSR.CertificadoPlantillaSeccionId = R.CertificadoPlantillaSeccionId
                             AND CPSR.CertificadoPlantillaId = CP.CertificadoPlantillaId
                             AND CPSR.Estado = 1
                          INNER JOIN dbo.VERSIONFTCARACTERISTICA VFC
                              ON VFC.VersionFtCaracteristicaId = RC.VersionFtCaracteristicaId
                          INNER JOIN dbo.CARACTERISTICA C
                              ON C.CaracteristicaId = VFC.CaracteristicaId
                          LEFT JOIN dbo.METODO_DE_ENSAYO ME
                              ON ME.MetEnsayoId = C.MetEnsayoId
                          WHERE RC.Estado = 1
                            AND ME.MetEnsayoDescripcion IS NOT NULL
                      ) X
                  )
              WHEN 'FIRMA' THEN
                  '{"responsable":"[Responsable]","cargo":"[Cargo]","fecha":"[Fecha]"}'
              ELSE CONT.Contenido
          END AS Contenido
    FROM dbo.CERTIFICADOPLANTILLASECCION CPS
    INNER JOIN dbo.CERTIFICADOSECCION CS
        ON CS.CertificadoSeccionId = CPS.CertificadoSeccionId
    INNER JOIN dbo.CERTIFICADOPLANTILLA CP
        ON CP.CertificadoPlantillaId = CPS.CertificadoPlantillaId
    INNER JOIN dbo.VERSION VFT
        ON VFT.VersionId = CP.VersionFtId
    INNER JOIN dbo.DOCUMENTO DFT
        ON DFT.DocumentoId = VFT.DocumentoId
    CROSS JOIN dbo.LOTE L
    INNER JOIN dbo.VERSION VE
        ON VE.VersionId = L.VersionId
    INNER JOIN dbo.DOCUMENTO DE
        ON DE.DocumentoId = VE.DocumentoId
    LEFT JOIN dbo.GENESIS_ITEM GI
        ON GI.CodigoGenesis = L.CodigoGenesis
    OUTER APPLY
    (
        SELECT TOP(1) C.Contenido
        FROM dbo.CERTIFICADOPLANTILLASECCIONCONTENIDO C
        WHERE C.CertificadoPlantillaSeccionId = CPS.CertificadoPlantillaSeccionId
          AND C.Estado = 1
        ORDER BY C.CertificadoPlantillaSeccionContenidoId DESC
    ) CONT
    WHERE CPS.CertificadoPlantillaId = @CertificadoPlantillaId
      AND CPS.Estado = 1
      AND CPS.Visible = 1
      AND L.LoteId = @LoteId
    ORDER BY CPS.Orden;

    /* RS3: resultados reales del lote contra especificación FT */
    SELECT
          R.Titulo AS TituloInforme
        , R.Orden AS OrdenInforme
        , RC.Orden AS OrdenDetalle
        , VFC.CaracteristicaId
        , C.CaracteristicaDescripcion AS Determinacion
        , COALESCE
          (
              ERX.ResultadoTexto,
              CASE
                  WHEN ERX.ResultadoNumerico IS NULL THEN NULL
                  ELSE CONVERT(VARCHAR(100),ERX.ResultadoNumerico)
              END
          ) AS Resultado
        , CASE
              WHEN VFC.ValorCualitativo IS NOT NULL
                  THEN VFC.ValorCualitativo
              WHEN VFC.ValorCuantitativoInicial IS NOT NULL
               AND VFC.ValorCuantitativoFinal IS NOT NULL
                  THEN CONCAT(VFC.ValorCuantitativoInicial,' - ',VFC.ValorCuantitativoFinal)
              WHEN VFC.ValorCuantitativoIgual IS NOT NULL
                  THEN CONVERT(VARCHAR(100),VFC.ValorCuantitativoIgual)
              WHEN VFC.ValorCuantitativoInicial IS NOT NULL
                  THEN CONCAT('>= ',VFC.ValorCuantitativoInicial)
              WHEN VFC.ValorCuantitativoFinal IS NOT NULL
                  THEN CONCAT('<= ',VFC.ValorCuantitativoFinal)
              WHEN VFC.TipoCriterioId = 5
                  THEN 'Ausencia'
              ELSE NULL
          END AS Especificacion
        , VFC.UnidadDeMedida
        , ME.MetEnsayoDescripcion AS MetodoEnsayo
    FROM dbo.CERTIFICADOPLANTILLARESULTADO R
    INNER JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
        ON CPS.CertificadoPlantillaSeccionId = R.CertificadoPlantillaSeccionId
       AND CPS.CertificadoPlantillaId = @CertificadoPlantillaId
       AND CPS.Estado = 1
       AND CPS.Visible = 1
    INNER JOIN dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA RC
        ON RC.CertificadoPlantillaResultadoId = R.CertificadoPlantillaResultadoId
       AND RC.Estado = 1
    INNER JOIN dbo.VERSIONFTCARACTERISTICA VFC
        ON VFC.VersionFtCaracteristicaId = RC.VersionFtCaracteristicaId
       AND VFC.Estado = 1
    INNER JOIN dbo.CARACTERISTICA C
        ON C.CaracteristicaId = VFC.CaracteristicaId
    LEFT JOIN dbo.METODO_DE_ENSAYO ME
        ON ME.MetEnsayoId = C.MetEnsayoId
    OUTER APPLY
    (
        SELECT TOP(1)
              ER.ResultadoTexto
            , ER.ResultadoNumerico
        FROM dbo.EVALUACION_RESULTADO ER
        INNER JOIN dbo.EVALUACION E
            ON E.EvaluacionId = ER.EvaluacionId
           AND E.LoteId = @LoteId
           AND E.Estado = 'ACTIVO'
        INNER JOIN dbo.ESTADO_EVALUACION EE
            ON EE.EstadoEvaluacionId = E.EstadoEvaluacionId
           AND EE.Codigo = 'TERMINADA'
        INNER JOIN dbo.VERSIONCARACTERISTICA VC
            ON VC.VersCaractId = ER.VersCaractId
           AND VC.VersionId = @VersionEtOrigenId
           AND VC.CaracteristicaId = VFC.CaracteristicaId
           AND VC.Estado = 1
        WHERE ER.Estado = 'ACTIVO'
          AND
          (
              VFC.VersionFaseId IS NULL
              OR VC.VersionFaseId = VFC.VersionFaseId
          )
        ORDER BY E.Intento DESC,E.EvaluacionId DESC,ER.EvaluacionResultadoId DESC
    ) ERX
    WHERE R.Estado = 1
      AND R.Visible = 1
    ORDER BY R.Orden,RC.Orden;
END;
GO


CREATE OR ALTER PROCEDURE dbo.SP_EMITIR_CERTIFICADO
(
      @LoteId INT
    , @CertificadoPlantillaId INT
    , @Usuario VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
          @VersionFtId INT
        , @VersionEtOrigenId INT
        , @ProductoCodigo VARCHAR(50)
        , @CertificadoId INT
        , @NumeroCertificado VARCHAR(50)
        , @FechaEmision DATETIME2 = SYSDATETIME()
        , @EstadoCertificadoId INT;

    SELECT
          @VersionFtId = CP.VersionFtId
        , @VersionEtOrigenId = V.VersionEtOrigenId
        , @ProductoCodigo = D.ProductoCodigo
    FROM dbo.CERTIFICADOPLANTILLA CP
    INNER JOIN dbo.VERSION V
        ON V.VersionId = CP.VersionFtId
    INNER JOIN dbo.DOCUMENTO D
        ON D.DocumentoId = V.DocumentoId
    WHERE CP.CertificadoPlantillaId = @CertificadoPlantillaId
      AND CP.Estado = 1
      AND V.Estado = 1
      AND D.Estado = 1;

    IF @VersionFtId IS NULL
        THROW 50001,'La plantilla de certificado no existe o está inactiva.',1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.LOTE L
        INNER JOIN dbo.ESTADO_LOTE EL
            ON EL.EstadoLoteId = L.EstadoLoteId
        INNER JOIN dbo.VERSION VE
            ON VE.VersionId = L.VersionId
        INNER JOIN dbo.DOCUMENTO DE
            ON DE.DocumentoId = VE.DocumentoId
        WHERE L.LoteId = @LoteId
          AND L.Estado = 'ACTIVO'
          AND EL.Codigo = 'LIBERADO'
          AND COALESCE(L.ProductoCodigo,DE.ProductoCodigo) = @ProductoCodigo
          AND (@VersionEtOrigenId IS NULL OR @VersionEtOrigenId = L.VersionId)
    )
        THROW 50002,'El lote no está liberado o la plantilla no corresponde al lote.',1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.CERTIFICADO
        WHERE LoteId = @LoteId
          AND Estado = 'EMITIDO'
    )
        THROW 50003,'El lote ya tiene un certificado emitido.',1;

    /* Toda característica configurada debe tener un resultado terminado */
    IF EXISTS
    (
        SELECT 1
        FROM dbo.CERTIFICADOPLANTILLARESULTADO R
        INNER JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
            ON CPS.CertificadoPlantillaSeccionId = R.CertificadoPlantillaSeccionId
           AND CPS.CertificadoPlantillaId = @CertificadoPlantillaId
           AND CPS.Estado = 1
           AND CPS.Visible = 1
        INNER JOIN dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA RC
            ON RC.CertificadoPlantillaResultadoId = R.CertificadoPlantillaResultadoId
           AND RC.Estado = 1
        INNER JOIN dbo.VERSIONFTCARACTERISTICA VFC
            ON VFC.VersionFtCaracteristicaId = RC.VersionFtCaracteristicaId
           AND VFC.Estado = 1
        WHERE R.Estado = 1
          AND R.Visible = 1
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.EVALUACION_RESULTADO ER
              INNER JOIN dbo.EVALUACION E
                  ON E.EvaluacionId = ER.EvaluacionId
                 AND E.LoteId = @LoteId
                 AND E.Estado = 'ACTIVO'
              INNER JOIN dbo.ESTADO_EVALUACION EE
                  ON EE.EstadoEvaluacionId = E.EstadoEvaluacionId
                 AND EE.Codigo = 'TERMINADA'
              INNER JOIN dbo.VERSIONCARACTERISTICA VC
                  ON VC.VersCaractId = ER.VersCaractId
                 AND VC.VersionId = @VersionEtOrigenId
                 AND VC.CaracteristicaId = VFC.CaracteristicaId
                 AND VC.Estado = 1
              WHERE ER.Estado = 'ACTIVO'
                AND
                (
                    VFC.VersionFaseId IS NULL
                    OR VC.VersionFaseId = VFC.VersionFaseId
                )
          )
    )
        THROW 50004,'Una o más características configuradas en el certificado no tienen resultado terminado para este lote.',1;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.CERTIFICADO
        (
              LoteId
            , CertificadoPlantillaId
            , VersionFtId
            , NumeroCertificado
            , FechaEmision
            , Estado
            , AudUsuarioCreacion
            , AudFechaCreacion
        )
        VALUES
        (
              @LoteId
            , @CertificadoPlantillaId
            , @VersionFtId
            , NULL
            , @FechaEmision
            , 'EMITIDO'
            , @Usuario
            , @FechaEmision
        );

        SET @CertificadoId = CONVERT(INT,SCOPE_IDENTITY());

        SET @NumeroCertificado =
              'CA-'
            + CONVERT(VARCHAR(4),YEAR(@FechaEmision))
            + '-'
            + RIGHT('000000' + CONVERT(VARCHAR(20),@CertificadoId),6);

        UPDATE dbo.CERTIFICADO
        SET NumeroCertificado = @NumeroCertificado
        WHERE CertificadoId = @CertificadoId;

        /* Snapshot de secciones */
        INSERT INTO dbo.CERTIFICADODETALLE
        (
              CertificadoId
            , TipoSeccion
            , TituloSeccion
            , OrdenSeccion
            , CaracteristicaId
            , Determinacion
            , Resultado
            , Especificacion
            , UnidadDeMedida
            , MetodoEnsayo
            , OrdenDetalle
            , Contenido
        )
        SELECT
              @CertificadoId
            , CS.Codigo
            , CS.Descripcion
            , CPS.Orden
            , NULL
            , NULL
            , NULL
            , NULL
            , NULL
            , NULL
            , NULL
            , CASE CS.Codigo
                  WHEN 'DATOS_EMPRESA' THEN
                      (
                          SELECT TOP(1)
                                CE.RazonSocial AS razonSocial
                              , CE.NombreComercial AS nombreComercial
                              , CE.Direccion AS direccion
                              , CE.Telefono AS telefono
                              , CE.Fax AS fax
                              , CE.Correo AS correo
                              , CE.SitioWeb AS sitioWeb
                              , CE.Ruc AS ruc
                          FROM dbo.CERTIFICADOEMPRESA CE
                          WHERE CE.Estado = 1
                          ORDER BY CE.CertificadoEmpresaId DESC
                          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                      )
                  WHEN 'PRODUCTO' THEN
                      (
                          SELECT
                                COALESCE(L.ProductoCodigo,DE.ProductoCodigo) AS productoCodigo
                              , COALESCE(GI.NombreGenesis,DE.DocumentoDescripcionDocumento) AS productoDescripcion
                              , DFT.DocumentoCodigo AS fichaTecnica
                              , VFT.VersionNumero AS versionFt
                          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                      )
                  WHEN 'DATOS_LOTE' THEN
                      (
                          SELECT
                                L.CodigoLote AS lote
                              , L.FechaHoraProduccion AS fechaProduccion
                              , (
                                    SELECT TOP(1) S.Contenido
                                    FROM dbo.VERSIONFTSECCION S
                                    WHERE S.VersionId = CP.VersionFtId
                                      AND S.Estado = 1
                                      AND S.Visible = 1
                                      AND (
                                            UPPER(S.Titulo) LIKE '%VIDA UTIL%'
                                         OR UPPER(S.Titulo) LIKE '%VIDA ÚTIL%'
                                      )
                                    ORDER BY S.Orden
                                ) AS vidaUtil
                          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                      )
                  WHEN 'ALMACENAMIENTO' THEN
                      COALESCE
                      (
                          (
                              SELECT TOP(1) S.Contenido
                              FROM dbo.VERSIONFTSECCION S
                              WHERE S.VersionId = CP.VersionFtId
                                AND S.Estado = 1
                                AND S.Visible = 1
                                AND UPPER(S.Titulo) LIKE '%ALMACEN%'
                              ORDER BY S.Orden
                          ),
                          CONT.Contenido
                      )
                  WHEN 'REFERENCIAS' THEN
                      (
                          SELECT STRING_AGG(X.MetodoEnsayo, CHAR(10))
                          FROM
                          (
                              SELECT DISTINCT ME.MetEnsayoDescripcion AS MetodoEnsayo
                              FROM dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA RC2
                              INNER JOIN dbo.CERTIFICADOPLANTILLARESULTADO R2
                                  ON R2.CertificadoPlantillaResultadoId = RC2.CertificadoPlantillaResultadoId
                                 AND R2.Estado = 1
                                 AND R2.Visible = 1
                              INNER JOIN dbo.CERTIFICADOPLANTILLASECCION CPS2
                                  ON CPS2.CertificadoPlantillaSeccionId = R2.CertificadoPlantillaSeccionId
                                 AND CPS2.CertificadoPlantillaId = CP.CertificadoPlantillaId
                                 AND CPS2.Estado = 1
                              INNER JOIN dbo.VERSIONFTCARACTERISTICA VFC2
                                  ON VFC2.VersionFtCaracteristicaId = RC2.VersionFtCaracteristicaId
                              INNER JOIN dbo.CARACTERISTICA C2
                                  ON C2.CaracteristicaId = VFC2.CaracteristicaId
                              LEFT JOIN dbo.METODO_DE_ENSAYO ME
                                  ON ME.MetEnsayoId = C2.MetEnsayoId
                              WHERE RC2.Estado = 1
                                AND ME.MetEnsayoDescripcion IS NOT NULL
                          ) X
                      )
                  WHEN 'FIRMA' THEN
                      (
                          SELECT
                                @Usuario AS responsable
                              , CAST(NULL AS VARCHAR(200)) AS cargo
                              , @FechaEmision AS fecha
                          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                      )
                  ELSE CONT.Contenido
              END
        FROM dbo.CERTIFICADOPLANTILLASECCION CPS
        INNER JOIN dbo.CERTIFICADOSECCION CS
            ON CS.CertificadoSeccionId = CPS.CertificadoSeccionId
        INNER JOIN dbo.CERTIFICADOPLANTILLA CP
            ON CP.CertificadoPlantillaId = CPS.CertificadoPlantillaId
        INNER JOIN dbo.VERSION VFT
            ON VFT.VersionId = CP.VersionFtId
        INNER JOIN dbo.DOCUMENTO DFT
            ON DFT.DocumentoId = VFT.DocumentoId
        CROSS JOIN dbo.LOTE L
        INNER JOIN dbo.VERSION VE
            ON VE.VersionId = L.VersionId
        INNER JOIN dbo.DOCUMENTO DE
            ON DE.DocumentoId = VE.DocumentoId
        LEFT JOIN dbo.GENESIS_ITEM GI
            ON GI.CodigoGenesis = L.CodigoGenesis
        OUTER APPLY
        (
            SELECT TOP(1) C.Contenido
            FROM dbo.CERTIFICADOPLANTILLASECCIONCONTENIDO C
            WHERE C.CertificadoPlantillaSeccionId = CPS.CertificadoPlantillaSeccionId
              AND C.Estado = 1
            ORDER BY C.CertificadoPlantillaSeccionContenidoId DESC
        ) CONT
        WHERE CPS.CertificadoPlantillaId = @CertificadoPlantillaId
          AND CPS.Estado = 1
          AND CPS.Visible = 1
          AND CS.Codigo <> 'RESULTADOS'
          AND L.LoteId = @LoteId;

        /* Snapshot de resultados */
        INSERT INTO dbo.CERTIFICADODETALLE
        (
              CertificadoId
            , TipoSeccion
            , TituloSeccion
            , OrdenSeccion
            , CaracteristicaId
            , Determinacion
            , Resultado
            , Especificacion
            , UnidadDeMedida
            , MetodoEnsayo
            , OrdenDetalle
            , Contenido
        )
        SELECT
              @CertificadoId
            , 'RESULTADOS'
            , R.Titulo
            , CPS.Orden
            , VFC.CaracteristicaId
            , C.CaracteristicaDescripcion
            , COALESCE
              (
                  ERX.ResultadoTexto,
                  CASE
                      WHEN ERX.ResultadoNumerico IS NULL THEN NULL
                      ELSE CONVERT(VARCHAR(100),ERX.ResultadoNumerico)
                  END
              )
            , CASE
                  WHEN VFC.ValorCualitativo IS NOT NULL
                      THEN VFC.ValorCualitativo
                  WHEN VFC.ValorCuantitativoInicial IS NOT NULL
                   AND VFC.ValorCuantitativoFinal IS NOT NULL
                      THEN CONCAT(VFC.ValorCuantitativoInicial,' - ',VFC.ValorCuantitativoFinal)
                  WHEN VFC.ValorCuantitativoIgual IS NOT NULL
                      THEN CONVERT(VARCHAR(100),VFC.ValorCuantitativoIgual)
                  WHEN VFC.ValorCuantitativoInicial IS NOT NULL
                      THEN CONCAT('>= ',VFC.ValorCuantitativoInicial)
                  WHEN VFC.ValorCuantitativoFinal IS NOT NULL
                      THEN CONCAT('<= ',VFC.ValorCuantitativoFinal)
                  WHEN VFC.TipoCriterioId = 5
                      THEN 'Ausencia'
                  ELSE NULL
              END
            , VFC.UnidadDeMedida
            , ME.MetEnsayoDescripcion
            , (R.Orden * 1000) + RC.Orden
            , CONCAT('{"ordenInforme":',R.Orden,'}')
        FROM dbo.CERTIFICADOPLANTILLARESULTADO R
        INNER JOIN dbo.CERTIFICADOPLANTILLASECCION CPS
            ON CPS.CertificadoPlantillaSeccionId = R.CertificadoPlantillaSeccionId
           AND CPS.CertificadoPlantillaId = @CertificadoPlantillaId
           AND CPS.Estado = 1
           AND CPS.Visible = 1
        INNER JOIN dbo.CERTIFICADOPLANTILLARESULTADOCARACTERISTICA RC
            ON RC.CertificadoPlantillaResultadoId = R.CertificadoPlantillaResultadoId
           AND RC.Estado = 1
        INNER JOIN dbo.VERSIONFTCARACTERISTICA VFC
            ON VFC.VersionFtCaracteristicaId = RC.VersionFtCaracteristicaId
           AND VFC.Estado = 1
        INNER JOIN dbo.CARACTERISTICA C
            ON C.CaracteristicaId = VFC.CaracteristicaId
        LEFT JOIN dbo.METODO_DE_ENSAYO ME
            ON ME.MetEnsayoId = C.MetEnsayoId
        OUTER APPLY
        (
            SELECT TOP(1)
                  ER.ResultadoTexto
                , ER.ResultadoNumerico
            FROM dbo.EVALUACION_RESULTADO ER
            INNER JOIN dbo.EVALUACION E
                ON E.EvaluacionId = ER.EvaluacionId
               AND E.LoteId = @LoteId
               AND E.Estado = 'ACTIVO'
            INNER JOIN dbo.ESTADO_EVALUACION EE
                ON EE.EstadoEvaluacionId = E.EstadoEvaluacionId
               AND EE.Codigo = 'TERMINADA'
            INNER JOIN dbo.VERSIONCARACTERISTICA VC
                ON VC.VersCaractId = ER.VersCaractId
               AND VC.VersionId = @VersionEtOrigenId
               AND VC.CaracteristicaId = VFC.CaracteristicaId
               AND VC.Estado = 1
            WHERE ER.Estado = 'ACTIVO'
              AND
              (
                  VFC.VersionFaseId IS NULL
                  OR VC.VersionFaseId = VFC.VersionFaseId
              )
            ORDER BY E.Intento DESC,E.EvaluacionId DESC,ER.EvaluacionResultadoId DESC
        ) ERX
        WHERE R.Estado = 1
          AND R.Visible = 1;

        SELECT @EstadoCertificadoId = EstadoLoteId
        FROM dbo.ESTADO_LOTE
        WHERE Codigo = 'CERTIFICADO';

        IF @EstadoCertificadoId IS NULL
            THROW 50005,'No existe el estado de lote CERTIFICADO.',1;

        UPDATE dbo.LOTE
        SET EstadoLoteId = @EstadoCertificadoId,
            AudUsuarioModificacion = @Usuario,
            AudFechaActualizacion = @FechaEmision
        WHERE LoteId = @LoteId;

        COMMIT TRANSACTION;

        SELECT
              0 AS CodigoResultado
            , 'Certificado emitido correctamente.' AS Mensaje
            , @CertificadoId AS CertificadoId
            , @NumeroCertificado AS NumeroCertificado
            , @FechaEmision AS FechaEmision;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE dbo.SP_OBTENER_CERTIFICADO_EMITIDO
(
    @CertificadoId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.CERTIFICADO
        WHERE CertificadoId = @CertificadoId
    )
        THROW 50001,'El certificado indicado no existe.',1;

    /* RS1 */
    SELECT
          C.CertificadoId
        , L.LoteId
        , L.CodigoLote
        , COALESCE(L.ProductoCodigo,DE.ProductoCodigo) AS ProductoCodigo
        , COALESCE(GI.NombreGenesis,DE.DocumentoDescripcionDocumento) AS ProductoDescripcion
        , L.FechaHoraProduccion
        , C.CertificadoPlantillaId
        , CP.Nombre AS PlantillaNombre
        , C.VersionFtId
        , DFT.DocumentoCodigo
        , VFT.VersionNumero
        , C.NumeroCertificado
        , C.FechaEmision
        , C.Estado
    FROM dbo.CERTIFICADO C
    INNER JOIN dbo.LOTE L
        ON L.LoteId = C.LoteId
    INNER JOIN dbo.VERSION VE
        ON VE.VersionId = L.VersionId
    INNER JOIN dbo.DOCUMENTO DE
        ON DE.DocumentoId = VE.DocumentoId
    LEFT JOIN dbo.GENESIS_ITEM GI
        ON GI.CodigoGenesis = L.CodigoGenesis
    LEFT JOIN dbo.CERTIFICADOPLANTILLA CP
        ON CP.CertificadoPlantillaId = C.CertificadoPlantillaId
    INNER JOIN dbo.VERSION VFT
        ON VFT.VersionId = C.VersionFtId
    INNER JOIN dbo.DOCUMENTO DFT
        ON DFT.DocumentoId = VFT.DocumentoId
    WHERE C.CertificadoId = @CertificadoId;

    /* RS2 */
    SELECT
          D.TipoSeccion
        , MAX(D.TituloSeccion) AS TituloSeccion
        , D.OrdenSeccion
        , MAX(D.Contenido) AS Contenido
    FROM dbo.CERTIFICADODETALLE D
    WHERE D.CertificadoId = @CertificadoId
      AND D.TipoSeccion <> 'RESULTADOS'
    GROUP BY D.TipoSeccion,D.OrdenSeccion
    ORDER BY D.OrdenSeccion;

    /* RS3 */
    SELECT
          D.TituloSeccion AS TituloInforme
        , ISNULL(TRY_CONVERT(INT,JSON_VALUE(D.Contenido,'$.ordenInforme')),1) AS OrdenInforme
        , D.OrdenDetalle
        , D.CaracteristicaId
        , D.Determinacion
        , D.Resultado
        , D.Especificacion
        , D.UnidadDeMedida
        , D.MetodoEnsayo
    FROM dbo.CERTIFICADODETALLE D
    WHERE D.CertificadoId = @CertificadoId
      AND D.TipoSeccion = 'RESULTADOS'
    ORDER BY
          ISNULL(TRY_CONVERT(INT,JSON_VALUE(D.Contenido,'$.ordenInforme')),1)
        , D.OrdenDetalle;
END;
GO
