/****** Object:  StoredProcedure [dbo].[spa_contract_charge_type_detail_UI]    Script Date: 23/06/2015 ******/
--lhnepal@pioneersolutionsglobal.com
IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_contract_charge_type_detail_UI]')
  AND TYPE IN (N'P', N'PC'))
  DROP PROCEDURE [dbo].[spa_contract_charge_type_detail_UI]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_contract_charge_type_detail_UI] 
	@flag char(1),
	@xml nvarchar(max) = NULL,
	@contract_name AS varchar(8000) = NULL
AS
SET NOCOUNT ON
	DECLARE @sql varchar(8000),
		    @idoc int
	DECLARE @RowNum int
	DECLARE @a varchar(100) = ''
	DECLARE @b varchar(100)
	DECLARE @formula_nested_id int
IF @flag = 'w'--EXEC spa_contract_charge_type_detail_UI 'w','<Root contract_detail_id="3138"><FormulaUpdate nested_id="6" formula_description="Amount" nested_formula_id="10" row_seq="1"></FormulaUpdate><FormulaUpdate nested_id="5" formula_description="Quantity" nested_formula_id="56" row_seq="2"></FormulaUpdate><FormulaUpdate nested_id="47" formula_description="zxcv" nested_formula_id="17" row_seq="3"></FormulaUpdate><FormulaUpdate nested_id="53" formula_description="sdfasdf" nested_formula_id="118" row_seq="4"></FormulaUpdate><FormulaUpdate nested_id="42" formula_description="test_varun" nested_formula_id="17" row_seq="5"></FormulaUpdate></Root>'

BEGIN
BEGIN TRY

	DECLARE @contract_detail_id varchar(100)
	DECLARE @group_id varchar(100)

	EXEC sp_xml_preparedocument @idoc OUTPUT,
								@xml
	IF OBJECT_ID('tempdb..#temp_update_formula') IS NOT NULL
		DROP TABLE #temp_update_formula

	IF OBJECT_ID('tempdb..#temp_delete_formula') IS NOT NULL
		DROP TABLE #temp_delete_formula
	IF OBJECT_ID('tempdb..#temp_insert_formula') IS NOT NULL
		DROP TABLE #temp_insert_formula

	-- parse the contract_detail_id
	SELECT
		@contract_detail_id = contract_detail_id
	FROM OPENXML(@idoc, '/Root', 1)
	WITH (
	contract_detail_id varchar(10)
	)
	SELECT
		@group_id = cgd.formula_id
	FROM contract_charge_type_detail cgd
	INNER JOIN static_data_value sd
		ON cgd.invoice_line_item_id = sd.value_id
	LEFT JOIN adjustment_default_gl_codes adgc
		ON cgd.default_gl_id = adgc.default_gl_id
	LEFT JOIN formula_editor fr
		ON fr.formula_id = cgd.formula_id
	LEFT JOIN static_data_value sdv1
		ON sdv1.value_id = cgd.invoice_line_item_id
	WHERE CAST(cgd.[ID] AS varchar(100)) = @contract_detail_id

	IF @group_id IS NULL
	BEGIN
		INSERT formula_editor (formula_type)
		VALUES ('n')
		SET @group_id = SCOPE_IDENTITY()
	END

	SELECT
		formula_description [formula_description],
		nested_formula_id [nested_formula_id],
		row_seq [row_seq] INTO #temp_insert_formula
	FROM OPENXML(@idoc, '/Root/FormulaInsert', 1)
	WITH (
	formula_description nvarchar(1000),
	nested_formula_id varchar(10),
	row_seq varchar(10)
	)

	SELECT
		nested_id [nested_id],
		formula_description [formula_description],
		nested_formula_id [nested_formula_id],
		row_seq [row_seq] INTO #temp_update_formula
	FROM OPENXML(@idoc, '/Root/FormulaUpdate', 1)
	WITH (
	nested_id varchar(1000),
	formula_description nvarchar(1000),
	nested_formula_id varchar(1000),
	row_seq varchar(1000)
	)

	SELECT
		nested_id [nested_id] INTO #temp_delete_formula
	FROM OPENXML(@idoc, '/Root/FormulaDelete', 1)
	WITH (
	nested_id varchar(10)
	)
	--INSERT SCRIPT
	--/*START*/
	INSERT INTO formula_nested (sequence_order,
	description1,
	formula_id,
	formula_group_id)
		SELECT
		row_seq,
		formula_description,
		nested_formula_id,
		@group_id
		FROM #temp_insert_formula
	SET @formula_nested_id = SCOPE_IDENTITY()
	UPDATE fb
	SET fb.formula_id = @group_id,
		fb.nested_id = row_seq,
		fb.formula_nested_id = @formula_nested_id
	FROM formula_breakdown fb
	INNER JOIN #temp_insert_formula tif
		ON tif.nested_formula_id = fb.formula_id
	--INNER JOIN formula_nested fn ON fn.formula_id=fb.formula_id
	WHERE (fb.formula_id = @group_id
	OR fb.formula_id = tif.nested_formula_id)
	AND ISNULL(NULLIF(fb.nested_id, 0), -1) = -1
	--SELECT
 --     *
 --     FROM #temp_insert_formula
	--  SELECT
 --       formula_description,
 --       fn.id,
 --       row_seq
 --     FROM #temp_insert_formula tis
	--  INNER JOIN formula_nested fn ON fn.formula_id=tis.nested_formula_id
	--  return
	UPDATE contract_charge_type_detail
	SET formula_id = @group_id
	WHERE CAST([ID] AS varchar(100)) = @contract_detail_id
	--/*END*/
	   IF EXISTS (SELECT
        1
      FROM #temp_insert_formula)
    BEGIN
      --Making update in formula_breakdown
      DECLARE @temp_formula_description varchar(8000)
      DECLARE @temp_nested_formula_id int
	  DECLARE @temp_formula_id int
      DECLARE @temp_row_seq int
      DECLARE insertList CURSOR FOR
      SELECT
        formula_description,
        fn.id,
        row_seq,
		tis.nested_formula_id
      FROM #temp_insert_formula tis
	  INNER JOIN formula_nested fn ON fn.formula_id=tis.nested_formula_id
      OPEN insertList
      FETCH NEXT FROM insertList
      INTO @temp_formula_description, @temp_nested_formula_id, @temp_row_seq,@temp_formula_id
      SET @RowNum = 0
      WHILE @@FETCH_STATUS = 0
      BEGIN
        SET @RowNum = @RowNum + 1
        UPDATE a
        SET a.nested_id = @temp_row_seq,
            a.formula_id = @group_id,
            a.formula_nested_id = @temp_nested_formula_id
        FROM dbo.formula_breakdown a
        INNER JOIN formula_nested b
          ON a.formula_id = b.formula_id
        WHERE a.formula_id = @temp_formula_id
        -- EXEC spa_print @temp_nested_formula_id
        --	END
        FETCH NEXT FROM insertList
        INTO @temp_formula_description, @temp_nested_formula_id, @temp_row_seq,@temp_formula_id
      END
      CLOSE insertList
      DEALLOCATE insertList
    END
	--UPDATE FORMULA
	--/*START*/
	IF EXISTS (SELECT
		1
		FROM #temp_update_formula)
	BEGIN
		UPDATE formula_nested
		SET sequence_order = row_seq,
			description1 = formula_description,
			formula_id = nested_formula_id
		FROM #temp_update_formula
		WHERE id = nested_id


		UPDATE a
		SET a.nested_id = b.sequence_order
		FROM dbo.formula_breakdown a
		INNER JOIN formula_nested b
		ON a.formula_nested_id = b.[id]
		WHERE b.formula_group_id = @group_id
	END
	--/*END*/
	--DELETE FORMULA
	--/*START*/
	IF EXISTS (SELECT
		1
		FROM #temp_delete_formula)
	BEGIN
		 CREATE TABLE #deleted_formula (
        nested_id int,
        formula_id int,
        formula_group_id int,
        sequence_order int
      )
	
	  DELETE fn
      OUTPUT DELETED.id,
      DELETED.formula_id,
      DELETED.formula_group_id,
      DELETED.sequence_order
      INTO #deleted_formula
        FROM formula_nested fn
        INNER JOIN #temp_delete_formula tdf
          ON tdf.nested_id = fn.id
      WHERE fn.id = tdf.nested_id

     delete fb
        FROM formula_breakdown fb
        INNER JOIN #deleted_formula d
          ON fb.formula_id = d.formula_group_id
        INNER JOIN formula_editor fe
          ON fe.formula_id = d.formula_id
        INNER JOIN #temp_delete_formula tdf
          ON tdf.nested_id = d.nested_id
      WHERE fb.formula_nested_id = tdf.nested_id
        AND ISNULL(fe.istemplate, '') <> 'y'
		
      DELETE fes
        FROM formula_editor_sql fes
        INNER JOIN formula_editor fe
          ON fes.formula_id = fe.formula_id
        INNER JOIN #deleted_formula d
          ON fe.formula_id = d.formula_id
      WHERE ISNULL(fe.istemplate, '') <> 'y'

      DELETE fe
        FROM formula_editor fe
        INNER JOIN #deleted_formula d
          ON fe.formula_id = d.formula_id
      WHERE ISNULL(fe.istemplate, '') <> 'y'

      UPDATE a
      SET a.nested_id = b.sequence_order,
          a.formula_id = @group_id
      FROM dbo.formula_breakdown a
      INNER JOIN formula_nested b
        ON a.formula_id = b.[id]
      WHERE b.formula_group_id = @group_id
	END
	--/*END*/
	EXEC spa_ErrorHandler 0,
		'Formula update.',
		'spa_contract_charge_type_detail_UI',
		'Success',
		'Changes have been saved successfully.',
		''
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK

	EXEC spa_ErrorHandler -1,
		'Formula update.',
		'spa_contract_charge_type_detail_UI',
		'DB Error',
		'Fail to update Formula.',
		''
END CATCH
END
IF @flag = 'v'
--EXEC spa_contract_group_detail_UI @flag='v',@xml='<Root><GridUpdate contract_id="1080" contract_detail_id="3142" sequence_order="1"></GridUpdate><GridUpdate contract_id="1080" contract_detail_id="3158" sequence_order="2"></GridUpdate><GridUpdate contract_id="1080" contract_detail_id="3208" sequence_order="3"></GridUpdate><GridUpdate contract_id="1080" contract_detail_id="3212" sequence_order="4"></GridUpdate></Root>'
--To sort contract group detail grid rows in new framework
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT,
		@xml
		IF OBJECT_ID('tempdb..#temp_update_contract_detail') IS NOT NULL
			DROP TABLE #temp_update_contract_detail
		SELECT
			contract_detail_id [contract_detail_id],
			contract_id [contract_id],
			sequence_order [sequence_order] INTO #temp_update_contract_detail
		FROM OPENXML(@idoc, '/Root/GridUpdate', 1)
			WITH (
			contract_detail_id varchar(10),
			contract_id varchar(10),
			sequence_order varchar(10)
			)
		UPDATE contract_charge_type_detail
			SET contract_charge_type_detail.sequence_order = ticd.sequence_order
			FROM #temp_update_contract_detail ticd
		WHERE contract_charge_type_detail.ID = ticd.contract_detail_id
    
		--EXEC spa_ErrorHandler 0,
		--	'Contract Charge Type detail update.',
		--	'spa_contract_charge_type_detail_UI',
		--	'Success',
		--	'Changes have been saved successfully.',
		--	''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		EXEC spa_ErrorHandler -1,
			'Contract Charge Type detail update.',
			'spa_contract_charge_type_detail_UI',
			'DB Error',
			'Fail to update Contract details.',
			''
	END CATCH
END

IF @flag = 'x'--formula sequence ordering 
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT,
									@xml
		IF OBJECT_ID('tempdb..#temp_create_new_formulas_seq') IS NOT NULL
			DROP TABLE #temp_create_new_formulas_seq

		IF OBJECT_ID('tempdb..#newly_inserted_value') IS NOT NULL
			DROP TABLE #newly_inserted_value
		CREATE TABLE #newly_inserted_value (
			nested_id int,
			seq_order int
		)
		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT
			nested_id [nested_id],
			seq_order [seq_order] INTO #temp_create_new_formulas_seq
		FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
		WITH (
		nested_id varchar(10),
		seq_order varchar(10)
		)
		
    DECLARE @nested_id int
    DECLARE @old_seq int
    DECLARE @formula_group_id int
    DECLARE @after_seq int,
            @seq_no int,
            @formula_id int
    DECLARE @new_formula varchar(8000)
    DECLARE FormulaList CURSOR FOR
    SELECT
      fn.id,
      fn.sequence_order,
      fn.formula_group_id,
      (t.seq_order)
    FROM formula_nested fn
    INNER JOIN #temp_create_new_formulas_seq t
      ON fn.id = t.nested_id
    WHERE fn.sequence_order <> t.seq_order
    OPEN FormulaList
    FETCH NEXT FROM FormulaList
    INTO @nested_id, @old_seq, @formula_group_id, @seq_no
    SET @RowNum = 0
    WHILE @@FETCH_STATUS = 0
    BEGIN
      SET @RowNum = @RowNum + 1
      SELECT
        @formula_id = fe.formula_id
      FROM formula_editor fe
      INNER JOIN formula_nested fn
        ON fe.formula_id = fn.formula_id
      WHERE formula_group_id = @formula_group_id
      AND fn.id = @nested_id

      --remove extra space between <NO> and )	
      --remove extra space between dbo.FNARow and (	
      --remove extra space between dbo.FNARow( and <NO>
      SELECT
        @new_formula = REPLACE(
        REPLACE(
        REPLACE(formula, 'dbo.FNARow (', 'dbo.FNARow(')
        , 'dbo.FNARow( ', 'dbo.FNARow(')
        , ' )', ')')
      FROM formula_editor fe
      WHERE fe.formula_id = @formula_id

      --replacing formula with new sequence
      SELECT
        @new_formula = REPLACE(@new_formula, 'dbo.FNARow(' + CAST(@old_seq AS varchar(10)) + ')'
        , 'dbo.FNARow(' + CAST(@seq_no AS varchar(10)) + ')')

      --Updating formula_editor 
      UPDATE formula_editor
      SET formula = @new_formula
      FROM formula_editor fe
      WHERE fe.formula_id = @formula_id

      --Updating formula_nested with the new sequence 
      UPDATE fn
      SET fn.sequence_order = @seq_no
      FROM formula_nested fn
      WHERE fn.id = @nested_id

      --Updating formula breakdown as well.
      UPDATE fb
      SET fb.nested_id = @seq_no
      FROM formula_breakdown fb
      WHERE fb.formula_nested_id = @nested_id

      FETCH NEXT FROM FormulaList
      INTO @nested_id, @old_seq, @formula_group_id, @seq_no
    END
    CLOSE FormulaList
    DEALLOCATE FormulaList
		--UPDATE fn
		--SET fn.sequence_order = t.seq_order
		--FROM formula_nested fn
		--INNER JOIN #temp_create_new_formulas_seq t
		--	ON fn.id = t.nested_id
		EXEC spa_ErrorHandler 0,
			'Formula Sequence update.',
			'spa_contract_group_detail_UI',
			'Success',
			'Changes have been saved successfully..',
			''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		EXEC spa_ErrorHandler -1,
			'Formula Sequence update.',
			'spa_contract_group_detail_UI',
			'DB Error',
			'Fail to update formula sequence..',
			''
	END CATCH
END