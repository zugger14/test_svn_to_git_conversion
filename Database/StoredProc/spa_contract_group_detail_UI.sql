
/****** Object:  StoredProcedure [dbo].[spa_contract_group_detail_UI]    Script Date: 12/19/2014 21:11:23 ******/
--vsshrestha@pioneersolutionsglobal.com
IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_contract_group_detail_UI]')
  AND TYPE IN (N'P', N'PC'))
  DROP PROCEDURE [dbo].[spa_contract_group_detail_UI]
/****** Object:  StoredProcedure [dbo].[spa_contract_group_detail_UI]    Script Date: 12/19/2014  21:11:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_contract_group_detail_UI] @flag char(1),
@xml nvarchar(max) = NULL,
@contract_name AS varchar(8000) = NULL,
@contract_id AS INT = NULL,
@module_id INT = NULL,
@event_id INT = NULL

AS
  SET NOCOUNT ON
  DECLARE @sql varchar(8000),
          @idoc int

  DECLARE @a varchar(100) = ''
  DECLARE @b varchar(100)
  DECLARE @formula_nested_id int


  IF @flag = 's'
  BEGIN
    SET @sql = 'SELECT cgd.[ID],
           sd.description + ''('' + sd.code + '')'' [Contract Components],
         --ISNULL(sd.description, ''  '') + '' ('' +  sd.code + '')''  [Contract Components],
         sd1.code [GL Account],
         cgd.price [Flat Fee],
           CASE 
                WHEN formula_type = ''n'' AND formula IS NULL THEN 
	                 ''Nested Formula''
	            ELSE dbo.FNAFormulaFormat(fr.formula, ''r'')
	       END Formula,
	       sdp.source_deal_type_name AS [Deal Type],
	       dbo.FNADateformat(cgd.effective_date) AS [EffectiveDate],
	       vg.code Granularity,
	       cct.contract_charge_desc [Contract Template],
		   contract_template.code [Contract Component Template],
		   contract_type_alias.code [Alias]
		          
		FROM   contract_group_detail cgd
			   INNER JOIN static_data_value sd ON  cgd.invoice_line_item_id = sd.value_id
			   LEFT JOIN adjustment_default_gl_codes adgc ON  cgd.default_gl_id = adgc.default_gl_id
			   LEFT JOIN static_data_value sd1 ON  adgc.adjustment_type_id = sd1.value_id
			   LEFT JOIN source_currency sc ON  sc.source_currency_id = cgd.currency
			   LEFT JOIN formula_editor fr ON  fr.formula_id = cgd.formula_id
			   LEFT JOIN static_data_value vg ON  cgd.volume_granularity = vg.value_id
			   LEFT JOIN source_deal_type sdp ON  sdp.source_deal_type_id = cgd.deal_type
			   LEFT JOIN contract_charge_type cct ON cct.contract_charge_type_id = cgd.contract_template
			   LEFT JOIN contract_charge_type_detail cctd ON cctd.ID = cgd.contract_component_template
			   LEFT JOIN static_data_value contract_template ON contract_template.value_id = cctd.invoice_line_item_id
			   LEFT JOIN static_data_value contract_type_alias ON contract_type_alias.value_id = cgd.alias 	WHERE  contract_id = 55000	UNION ALL
			   SELECT NULL AS [ID],
	    NULL AS [Contract Components],
	     NULL AS [GL Account],
	      NULL AS [Flat Fee],
	      NULL AS Formula,
	      NULL AS [Deal Type],
	      NULL AS [EffectiveDate],
	      NULL AS [Granularity],
	      NULL AS [Contract Template],
		  NULL AS [Contract Component Template],
		  NULL AS [Alias]'
    exec spa_print @sql
    EXEC (@sql)
  END
  ELSE
  IF @flag = 'f'--formula data for contract screen
  BEGIN
    (SELECT
      ID AS [Nested ID],
      sequence_order [Row],
      Description1 AS [Description 1],
      Description2 AS [Description 2],
      REPLACE(dbo.FNAFormulaFormat(fe.formula, 'r'), '<', '&lt;') Formula,
      sd.code [Granularity],
      include_item [Include in Invoice],
      sd1.code AS [Fuel Type],
      --REPLACE(dbo.FNAFormulaFormat(fe1.formula, 'r'),'<','&lt;')  Formula
      n.formula_id AS [Formula ID]
    FROM formula_nested n
    JOIN formula_editor fe
      ON n.formula_id = fe.formula_id
    LEFT JOIN static_data_value sd
      ON sd.value_id = n.granularity
    LEFT JOIN static_data_value sd1
      ON sd1.value_id = fe.static_value_id
    LEFT JOIN formula_editor fe1
      ON fe1.formula_id = n.time_bucket_formula_id)
    UNION ALL
    SELECT
      NULL AS [Nested ID],
      NULL AS [Row],
      NULL AS [Description 1],
      NULL AS [Description2],
      NULL AS Formula,
      NULL AS [Granularity],
      NULL AS [Include in Invoice],
      NULL AS [Fuel Type],
      NULL AS [Formula ID]

  END
  ELSE
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

    DECLARE @RowNum int
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
    --  ON fn.id = t.nested_id
    EXEC spa_ErrorHandler 0,
                          'Formula Sequence update.',
                          'spa_contract_group_detail_UI',
                          'Success',
                          'Changes have been saved successfully.',
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
  ELSE
  IF @flag = 't'--tree data for contract screen.
  BEGIN
    SELECT
      (ISNULL(ph.entity_name, 'General')) AS [Parent],
      contract_id,
      contract_name
    FROM contract_group cg
    LEFT JOIN portfolio_hierarchy ph
      ON cg.sub_id = ph.entity_id
  END
  ELSE
  IF @flag = 'g'
  BEGIN
  BEGIN TRY
    EXEC sp_xml_preparedocument @idoc OUTPUT,
                                @xml
    IF OBJECT_ID('tempdb..#temp_create_new_contract_gl') IS NOT NULL
      DROP TABLE temp_create_new_contract_gl

    SELECT
      default_gl_id [default_gl_id],
      adj_type_estimates [adj_type_estimates],
      default_gl_code_cash_applied [default_gl_code_cash_applied],
      manual_entry [manual_entry],
      contract_detail_id [contract_detail_id] INTO #temp_create_new_contract_gl
    FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
    WITH (
    default_gl_id int,
    adj_type_estimates int,
    default_gl_code_cash_applied int,
    manual_entry char(1),
    contract_detail_id int
    )


    UPDATE cgd
    SET cgd.default_gl_id = t.default_gl_id,
        cgd.default_gl_id_estimates = t.adj_type_estimates,
        cgd.default_gl_code_cash_applied = t.default_gl_code_cash_applied,
        cgd.manual = t.manual_entry
    FROM contract_group_detail cgd
    INNER JOIN #temp_create_new_contract_gl t
      ON cgd.ID = t.contract_detail_id
    EXEC spa_ErrorHandler 0,
                          'GL Code Mapping update.',
                          'spa_contract_group_detail_UI',
                          'Success',
                          'Changes have been saved successfully.',
                          ''
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK

    EXEC spa_ErrorHandler -1,
                          'GL Code Mapping update.',
                          'spa_contract_group_detail_UI',
                          'DB Error',
                          'Fail to update GL Code Mapping.',
                          ''
  END CATCH
  END
  IF @flag = 'c'
  BEGIN

    SELECT
      value_id [Value ID],
      CASE value_id
        WHEN 50 THEN code + ' (Group 1)'
        WHEN 51 THEN code + ' (Group 2)'
        WHEN 52 THEN code + ' (Group 3)'
        WHEN 53 THEN code + ' (Group 4)'
        ELSE code
      END AS Code
    FROM static_data_value s
    LEFT OUTER JOIN static_data_category c
      ON c.category_id = s.category_id
    WHERE s.type_id = 10019
    AND entity_id IS NULL
    ORDER BY c.category_name, code
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
    UPDATE contract_group_detail
    SET contract_group_detail.sequence_order = ticd.sequence_order

    FROM #temp_update_contract_detail ticd
    WHERE contract_group_detail.ID = ticd.contract_detail_id

    EXEC spa_ErrorHandler 0,
                          'Contract Group detail update.',
                          'spa_contract_group_detail_UI',
                          'Success',
                          'Changes have been saved successfully.',
                          ''
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK

    EXEC spa_ErrorHandler -1,
                          'Contract Group detail update.',
                          'spa_contract_group_detail_UI',
                          'DB Error',
                          'Fail to update Contract details.',
                          ''
  END CATCH
  END

  IF @flag = 'w'--EXEC spa_contract_group_detail_UI 'w','<Root contract_detail_id="3138"><FormulaUpdate nested_id="6" formula_description="Amount" nested_formula_id="10" row_seq="1"></FormulaUpdate><FormulaUpdate nested_id="5" formula_description="Quantity" nested_formula_id="56" row_seq="2"></FormulaUpdate><FormulaUpdate nested_id="47" formula_description="zxcv" nested_formula_id="17" row_seq="3"></FormulaUpdate><FormulaUpdate nested_id="53" formula_description="sdfasdf" nested_formula_id="118" row_seq="4"></FormulaUpdate><FormulaUpdate nested_id="42" formula_description="test_varun" nested_formula_id="17" row_seq="5"></FormulaUpdate></Root>'

  BEGIN
  BEGIN TRY
  BEGIN TRAN
    DECLARE @contract_detail_id varchar(100)
    DECLARE @group_id varchar(100)
    DECLARE @formula_description nvarchar(500)

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
    FROM contract_group_detail cgd
    INNER JOIN static_data_value sd
      ON cgd.invoice_line_item_id = sd.value_id
    LEFT JOIN adjustment_default_gl_codes adgc
      ON cgd.default_gl_id = adgc.default_gl_id
    LEFT JOIN formula_editor fr
      ON fr.formula_id = cgd.formula_id
    LEFT JOIN formula_editor fe
      ON fe.formula_id = cgd.time_bucket_formula_id
    LEFT JOIN contract_charge_type_detail cctd
      ON cctd.ID = cgd.contract_component_template
    LEFT JOIN static_data_value sdv1
      ON sdv1.value_id = cctd.invoice_line_item_id
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
    -- SELECT
    --  @formula_description = formula_description
    --FROM OPENXML(@idoc, '/Root/FormulaInsert', 1)
    --WITH (
    --formula_description varchar(50)
    --)
    IF EXISTS (SELECT
        1
      FROM #temp_insert_formula
      WHERE formula_description = 'price')
    BEGIN
      EXEC spa_ErrorHandler -1,
                            'formula_editor',
                            'spa_contract_group_detail_ui',
                            'Error',
                            'Description ''Price'' is not accepted. Please enter another description.',
                            ''
      RETURN
    END
    IF EXISTS (SELECT
        1
      FROM #temp_insert_formula
      WHERE formula_description = 'volume')
    BEGIN
      EXEC spa_ErrorHandler -1,
                            'formula_editor',
                            'spa_contract_group_detail_ui',
                            'Error',
                            'Description ''Volume'' is not accepted. Please enter another description.',
                            ''
      RETURN
    END
	IF EXISTS (SELECT
        1
      FROM #temp_insert_formula
      WHERE formula_description = 'value')
    BEGIN
      EXEC spa_ErrorHandler -1,
                            'formula_editor',
                            'spa_contract_group_detail_ui',
                            'Error',
                            'Description ''Value'' is not accepted. Please enter another description.',
                            ''
      RETURN
    END
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

    UPDATE contract_group_detail
    SET formula_id = @group_id
    WHERE CAST([ID] AS varchar(100)) = @contract_detail_id
    --/*END*/

    --UPDATE FORMULA
    --/*START*/
    -- SELECT
    --   @formula_description = formula_description
    -- FROM OPENXML(@idoc, '/Root/FormulaUpdate', 1)
    -- WITH (
    -- formula_description varchar(50)
    -- )
    IF EXISTS (SELECT
        1
      FROM #temp_update_formula
      WHERE formula_description = 'price')
    BEGIN
      EXEC spa_ErrorHandler -1,
                            'formula_editor',
                            'spa_contract_group_detail_ui',
                            'Error',
                            'Description ''Price'' is not accepted. Please enter another description.',
                            ''
      RETURN
    END
    IF EXISTS (SELECT
        1
      FROM #temp_update_formula
      WHERE formula_description = 'volume')
    BEGIN
      EXEC spa_ErrorHandler -1,
                            'formula_editor',
                            'spa_contract_group_detail_ui',
                            'Error',
                            'Description ''Volume'' is not accepted. Please enter another description.',
                            ''
      RETURN
    END
	IF EXISTS (SELECT
        1
      FROM #temp_insert_formula
      WHERE formula_description = 'value')
    BEGIN
      EXEC spa_ErrorHandler -1,
                            'formula_editor',
                            'spa_contract_group_detail_ui',
                            'Error',
                            'Description ''Value'' is not accepted. Please enter another description.',
                            ''
      RETURN
    END
    IF EXISTS (SELECT
        1
      FROM #temp_insert_formula)
    BEGIN
      --Making update in formula_breakdown
      DECLARE @temp_formula_description varchar(8000)
      DECLARE @temp_nested_formula_id int
      DECLARE @temp_row_seq int
      DECLARE insertList CURSOR FOR
      SELECT
        formula_description,
        nested_formula_id,
        row_seq
      FROM #temp_insert_formula
      OPEN insertList
      FETCH NEXT FROM insertList
      INTO @temp_formula_description, @temp_nested_formula_id, @temp_row_seq
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
        WHERE a.formula_id = @temp_nested_formula_id
        -- EXEC spa_print @temp_nested_formula_id
        --	END
        FETCH NEXT FROM insertList
        INTO @temp_formula_description, @temp_nested_formula_id, @temp_row_seq
      END
      CLOSE insertList
      DEALLOCATE insertList
    END
    --UPDATE formula_nested
    --SET sequence_order = row_seq,
    --    description1 = formula_description,
    --    formula_id = nested_formula_id
    --FROM #temp_update_formula
    --WHERE id = nested_id
    --  UPDATE a
    --   SET a.nested_id = b.sequence_order,
    --a.formula_id=@group_id,
    --a.formula_nested_id=b.id
    --   FROM dbo.formula_breakdown a
    --   INNER JOIN formula_nested b
    --     ON a.formula_id = b.formula_id
    --   WHERE b.formula_group_id = @group_id
    --  END
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




      DELETE fb
        FROM formula_breakdown fb
        INNER JOIN #deleted_formula d
          ON fb.formula_id = d.formula_group_id
        INNER JOIN formula_editor fe
          ON fe.formula_id = d.formula_id
        INNER JOIN #temp_delete_formula tdf
          ON tdf.nested_id = d.nested_id
      WHERE fb.nested_id = d.sequence_order
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
        ON a.formula_nested_id = b.formula_id
      WHERE b.formula_group_id = @group_id
    END
    --/*END*/
    EXEC spa_ErrorHandler 0,
                          'Formula update.',
                          'spa_contract_group_detail_UI',
                          'Success',
                          'Changes have been saved successfully.',
                          ''
  COMMIT TRAN
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK

    EXEC spa_ErrorHandler -1,
                          'Formula update.',
                          'spa_contract_group_detail_UI',
                          'DB Error',
                          'Fail to update Formula.',
                          ''
  END CATCH
  END
  IF @flag = 'l'
  BEGIN
  BEGIN TRY
    EXEC sp_xml_preparedocument @idoc OUTPUT,
                                @xml
    IF OBJECT_ID('tempdb..#temp_delete_contract_detail') IS NOT NULL
      DROP TABLE #temp_delete_contract_detail

    SELECT
      contract_detail_id [contract_detail_id] INTO #temp_delete_contract_detail
    FROM OPENXML(@idoc, '/Root/GridDelete', 1)
    WITH (
    contract_detail_id varchar(10)
    )
	DECLARE @temp_contract_id INT,@temp_contract_detail_id INT
	SELECT @temp_contract_id=contract_id
	 FROM #temp_delete_contract_detail ticd
    INNER JOIN contract_group_detail ON contract_group_detail.ID = ticd.contract_detail_id

	--Delete formula
	IF OBJECT_ID (N'#temp_formula_id', N'U') IS NOT NULL 
		DROP TABLE #temp_formula_id
			
	SELECT fn.formula_id INTO #temp_formula_id FROM formula_nested fn
	INNER JOIN contract_group_detail s on fn.formula_group_id=s.formula_id 
	INNER JOIN #temp_delete_contract_detail tdcd ON tdcd.contract_detail_id=s.ID

	DELETE b FROM formula_breakdown b 
	INNER JOIN formula_nested f on f.formula_group_id=b.formula_id
	INNER JOIN contract_group_detail s on f.formula_group_id=s.formula_id 
	INNER JOIN #temp_delete_contract_detail tdcd ON tdcd.contract_detail_id=s.ID

	DELETE f FROM formula_nested f 
	INNER JOIN contract_group_detail s on f.formula_group_id=s.formula_id 
	INNER JOIN #temp_delete_contract_detail tdcd ON tdcd.contract_detail_id=s.ID

	DELETE f FROM formula_editor f 
	INNER JOIN #temp_formula_id tmp ON f.formula_id = tmp.formula_id

	DELETE f FROM formula_editor f 
	INNER JOIN contract_group_detail s on f.formula_id=s.formula_id 
	INNER JOIN #temp_delete_contract_detail tdcd ON tdcd.contract_detail_id=s.ID

	--Deleting the charge type from contract_group_detail
	DELETE contract_group_detail
    FROM #temp_delete_contract_detail ticd
    WHERE contract_group_detail.ID = ticd.contract_detail_id
	--Updating sequence_order of other charge types in contract_group_detail
	DECLARE contractDetailList CURSOR FOR
	SELECT ID FROM contract_group_detail WHERE contract_id=@temp_contract_id ORDER BY sequence_order 
	OPEN contractDetailList
	FETCH NEXT FROM contractDetailList
	INTO @temp_contract_detail_id
		SET @RowNum = 0
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @RowNum = @RowNum + 1
			 
			UPDATE contract_group_detail
			SET sequence_order=@RowNum
			WHERE ID=@temp_contract_detail_id
			FETCH NEXT FROM contractDetailList
			INTO @temp_contract_detail_id
		END
	CLOSE contractDetailList
	DEALLOCATE contractDetailList
	


    EXEC spa_ErrorHandler 0,
                          'Contract Group detail delete.',
                          'spa_contract_group_detail_UI',
                          'Success',
                          'Changes have been saved successfully.',
                          ''
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK

    EXEC spa_ErrorHandler -1,
                          'Contract Group detail delete.',
                          'spa_contract_group_detail_UI',
                          'DB Error',
                          'Fail to delete Contract details.',
                          ''
  END CATCH
  END

  -- FOR Contract approval alert
  ELSE IF @flag = 'a'
  BEGIN
	DECLARE @process_table1 VARCHAR(500)
	DECLARE @sql_st VARCHAR(MAX)
	DECLARE @alert_process_id VARCHAR(200)
	SET @alert_process_id = dbo.FNAGetNewID()  
	SET @process_table1 = 'adiha_process.dbo.alert_contract_' + @alert_process_id + '_ac'
		
	SET @sql_st = 'CREATE TABLE ' + @process_table1 + ' (
         	contract_id    INT,
         	contract_name  VARCHAR(200),
         	contract_status INT,
         	hyperlink1 VARCHAR(5000), 
         	hyperlink2 VARCHAR(5000), 
         	hyperlink3 VARCHAR(5000), 
         	hyperlink4 VARCHAR(5000), 
         	hyperlink5 VARCHAR(5000)
			)
		INSERT INTO ' + @process_table1 + '(
			contract_id,
			contract_name,
			contract_status,
			hyperlink1
			)
		SELECT x.contract_id,
				x.contract_name,
				x.contract_status, 
				dbo.FNATrmHyperlink(''i'', CASE WHEN x.contract_type_def_id = 38400 THEN 10211200 WHEN x.contract_type_def_id = 38401 THEN 10211300 ELSE 10211400 END,''Review Contract - '' + CAST(x.contract_id AS VARCHAR) + '','' + CAST(x.contract_name AS VARCHAR) ,x.contract_id,x.contract_name,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
				FROM contract_group x WHERE x.contract_id = ' + CAST(@contract_id AS VARCHAR)

		EXEC(@sql_st)

		EXEC spa_register_event @module_id, @event_id, @process_table1, 0, @alert_process_id
  END
