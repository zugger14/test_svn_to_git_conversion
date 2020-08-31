
/****** Object:  StoredProcedure [dbo].[spa_contract_group_detail]    Script Date: 03/31/2009 21:11:23 ******/
IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_contract_group_detail]')
  AND TYPE IN (N'P', N'PC'))
  DROP PROCEDURE [dbo].[spa_contract_group_detail]
/****** Object:  StoredProcedure [dbo].[spa_contract_group_detail]    Script Date: 03/31/2009 21:11:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_contract_group_detail] @flag char(1),
@contract_detail_id varchar(100) = NULL,
@contract_id int = NULL,
@invoice_line_item_id int = NULL,
@default_gl_id int = NULL,
@price float = NULL,
@formula_id int = NULL,
@manual char(1) = NULL,
@prod_type char(1) = NULL,
@after_seq int = NULL,
@inventory_item char(1) = NULL,
@volume_granularity int = NULL,
@class_name varchar(50) = NULL,
@increment_peaking_name varchar(50) = NULL,
@product_type_name varchar(50) = NULL,
@rate_description varchar(100) = NULL,
@units_for_rate varchar(50) = NULL,
@default_gl_id_estimates int = NULL,
@eqr_product_name int = NULL,
@group_by int = NULL,
@alias varchar(100) = NULL,
@hideInInvoice varchar(1) = NULL,
@int_begin_month varchar(10) = NULL,
@int_end_month varchar(10) = NULL,
@deal_type int = NULL,
@time_bucket_formula_id int = NULL,
@payment_calendar int = NULL,
@pnl_date int = NULL,
@pnl_calendar int = NULL,
@calc_aggregation varchar(100) = NULL,
@timeOfUse int = NULL,
@include_charges char(1) = NULL,
@contract_template int = NULL,
@contract_component_template int = NULL,
@automatic_manual char(2) = NULL,
@settlement_date datetime = NULL,
@settlement_calendar int = NULL,
@effective_date datetime = NULL,
@group1 int = NULL,
@group2 int = NULL,
@group3 int = NULL,
@group4 int = NULL,
@leg int = NULL,
@contract_type char(1) = 'c',
@uom int = NULL,
@default_gl_code_cash_applied int = NULL
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @sql varchar(8000),
          @sequence_order int
  DECLARE @factor int
  DECLARE @group_id int

  IF @flag = 's'
  BEGIN
    IF @contract_type = 'm'
    BEGIN
      SET @sql = '
    	SELECT cgd.[ID],
	       sd.description + ''('' + sd.code + '')'' [Model Components],
	       --ISNULL(sd.description, ''  '') + '' ('' +  sd.code + '')''  [Contract Components],
		   cgd.invoice_line_item_id [Contract Components],
	       sd1.code [GL Account],
	       cgd.price [Flat Fee],
	       CASE 
	            WHEN formula_type = ''n'' AND formula IS NULL THEN 
	                 ''Nested Formula''
	            ELSE dbo.FNAFormulaFormat(fr.formula, ''r'')
	       END Formula,
	       sdp.source_deal_type_name AS [Deal Type],
	       vg.code Granularity,
	       cct.contract_charge_desc [Model Template],
	       contract_template.code [Model Component Template]	       
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
		WHERE  contract_id = ' + CAST(@contract_id AS varchar(1000)) + '
			   AND cgd.prod_type = ''' + CAST(@prod_type AS varchar(1000)) + ''''

      IF @uom IS NOT NULL
        SET @sql = @sql + ' AND adgc.uom_id = ' + CAST(@uom AS varchar(1000))

      SET @sql = @sql + ' ORDER BY
			   cgd.sequence_order,
			   cgd.[ID] '
      --PRINT(@sql)
      EXEC (@sql)
    END
    ELSE
    BEGIN
      SET @sql = '
		SELECT cgd.[ID],
		--cgd.invoice_line_item_id [Contract Components],
	      sd.description [Contract Components],
		  cgd.volume_granularity,
		  cgd.calc_aggregation,
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
		   contract_type_alias.code [contract_charge_type_group],
		 --  cgd.radio_automatic_manual [Type]
		   CASE 
				WHEN cgd.radio_automatic_manual =''c'' THEN
				''Charge Map''
				WHEN cgd.radio_automatic_manual =''f'' THEN
				''Formula''
				WHEN cgd.radio_automatic_manual =''e'' THEN
				''Excel''
				ELSE
				''Template''
			END [radio_automatic_manual],
		   CASE cgd.true_up_applies_to
				WHEN ''c'' THEN ''Contract Start Month'' 
				WHEN ''y'' THEN ''Calendar Year''
				WHEN ''p'' THEN ''Prior Months''
				ELSE ''''
		   END [true_up_applies_to],
		   CASE ISNULL(cgd.is_true_up, ''n'')
				WHEN ''y'' THEN ''Yes''
				WHEN ''n'' THEN ''No''
				ELSE '''' 
		   END [is_true_up],
		   sdvc.code [charge_type]
		          
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
			   LEFT JOIN static_data_value contract_type_alias ON contract_type_alias.value_id = cgd.alias	
			   LEFT JOIN static_data_value sdvc ON sdvc.value_id = cgd.true_up_charge_type_id		
		WHERE  contract_id = ' + CAST(@contract_id AS varchar(1000)) + '
			   AND cgd.prod_type = ''' + CAST(@prod_type AS varchar(1000)) + ''''

      IF @uom IS NOT NULL
        SET @sql = @sql + ' AND adgc.uom_id = ' + CAST(@uom AS varchar(1000))

      SET @sql = @sql + ' ORDER BY
			   cgd.sequence_order,
			   cgd.[ID]'

      --PRINT(@sql)
      EXEC (@sql)
    END

  END

  ELSE IF @flag = 'r'
  BEGIN
	SELECT cctd.ID AS ID,
		   sdv.code AS [contract_components],
		  -- CASE 
			 --WHEN (cctd.price IS NOT NULL) THEN 'Flat Fee' 
			 --ELSE 'Formula' 
		  -- END AS [radio_automatic_manual],
		   CASE 
			 WHEN (cctd.price IS NOT NULL) THEN 'Flat Fee' 
				ELSE CASE WHEN cctd.contract_component_type = 'c' THEN 'Charge Map'
						  WHEN cctd.contract_component_type = 't' THEN 'Template'
			 ELSE 'Formula' 
					 END
		   END AS [radio_automatic_manual],
		   cctd.price AS flat_fee, 
		   sdva.code [contract_charge_type_group],
		   CASE cctd.true_up_applies_to
			 WHEN 'c' THEN 'Contract Start Month' 
			 WHEN 'y' THEN 'Calendar Year'
			 WHEN 'p' THEN 'Prior Months'
			 ELSE ''
		   END	[true_up_applies_to],
		   CASE  ISNULL(cctd.is_true_up,'n')
				WHEN 'y' THEN 'Yes'
				WHEN 'n' THEN 'No'
				ELSE '' 
		  END [is_true_up],
		  sdvc.code [charge_type]
	FROM contract_charge_type_detail cctd 
	LEFT JOIN static_data_value sdv ON sdv.value_id = cctd.invoice_line_item_id
	LEFT JOIN static_data_value sdva ON sdva.value_id = cctd.alias
	LEFT JOIN static_data_value sdvc ON sdvc.value_id = cctd.true_up_charge_type_id
	WHERE cctd.contract_charge_type_id=@contract_component_template
	ORDER BY [sequence_order] ASC
  END

  ELSE
  IF @flag = 'a'
  BEGIN
    SELECT
      cgd.[ID],
      sd.value_id [Invoice Line Item],
      cgd.default_gl_id [Adjustment GL],
      cgd.price Price,
      cgd.formula_id,
      cgd.[manual] [Manual Entry],
      CASE
        WHEN fr.formula_type = 'n' AND
          fr.formula IS NULL THEN 'Nested Formula'
        ELSE dbo.FNAFormulaFormat(fr.formula, 'r')
      END,
      cgd.prod_type,
      cgd.sequence_order,
      cgd.inventory_item,
      cgd.volume_granularity,
      ISNULL((SELECT
        COUNT(ii.sequence_order)
      FROM contract_group_detail ii
      WHERE ii.contract_id = cgd.contract_id
      AND ii.sequence_order < cgd.sequence_order),
      0
      ) psno,
      cgd.class_name,
      cgd.increment_peaking_name,
      cgd.product_type_name,
      cgd.rate_description,
      cgd.units_for_rate,
      cgd.default_gl_id_estimates,
      eqr_product_name,
      cgd.group_by,
      cgd.ALIAS,
      hideInInvoice,
      int_begin_month AS int_begin_month,
      int_end_month AS int_end_month,
      cgd.deal_type,
      ISNULL(fr.system_defined, 'n') AS system_defined,
      fr.formula_type,
      cgd.time_bucket_formula_id,
      dbo.FNAFormulaFormat(ISNULL(fe.formula, ''), 'r'),
      cgd.payment_calendar,
      cgd.pnl_date,
      cgd.pnl_calendar,
      cgd.calc_aggregation,
      cgd.timeofuse,
      cgd.include_charges,
      cgd.contract_template,
      cgd.contract_component_template,
      cgd.radio_automatic_manual,
      CONVERT(varchar(10), cgd.settlement_date, 120) settlement_date,
      cgd.settlement_calendar,
      CONVERT(varchar(10), cgd.effective_date, 120) effective_date,
      sdv1.code,
      cgd.group1,
      cgd.group2,
      cgd.group3,
      cgd.group4,
      cgd.leg,
      cgd.default_gl_code_cash_applied
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

  END
  ELSE
  IF @flag = 'p'
  BEGIN
    SELECT
      sequence_order,
      sd.description + '(' + sd.code + ')' [CONTRACT Components]
    FROM contract_group_detail cgd
    INNER JOIN static_data_value sd
      ON cgd.invoice_line_item_id = sd.value_id
    WHERE contract_id = @contract_id
    AND prod_type = @prod_type
    AND CAST([ID] AS varchar(100)) NOT IN (@contract_detail_id)
    ORDER BY sequence_order
  END
  ELSE
  IF @flag = 'i'
    OR @flag = 'u'
  BEGIN
    IF @flag = 'i'
    BEGIN
    BEGIN TRY
      SELECT
        @sequence_order = ISNULL(MAX(sequence_order), 0) + 1
      FROM contract_group_detail
      WHERE contract_id = @contract_id
      AND prod_type = @prod_type

      INSERT INTO contract_group_detail (contract_id,
      invoice_line_item_id,
      default_gl_id,
      price,
      formula_id,
      [manual],
      prod_type,
      sequence_order,
      inventory_item,
      volume_granularity,
      class_name,
      increment_peaking_name,
      product_type_name,
      rate_description,
      units_for_rate,
      default_gl_id_estimates,
      eqr_product_name,
      group_by,
      ALIAS,
      hideInInvoice,
      int_begin_month,
      int_end_month,
      deal_type,
      time_bucket_formula_id,
      payment_calendar,
      pnl_date,
      pnl_calendar,
      calc_aggregation,
      timeofuse,
      include_charges,
      contract_template,
      contract_component_template,
      radio_automatic_manual,
      settlement_date,
      settlement_calendar,
      effective_date,
      group1,
      group2,
      group3,
      group4,
      leg,
      default_gl_code_cash_applied)
        SELECT
          @contract_id,
          @invoice_line_item_id,
          @default_gl_id,
          @price,
          @formula_id,
          @manual,
          @prod_type,
          @sequence_order,
          @inventory_item,
          @volume_granularity,
          @class_name,
          @increment_peaking_name,
          @product_type_name,
          @rate_description,
          @units_for_rate,
          @default_gl_id_estimates,
          @eqr_product_name,
          @group_by,
          @alias,
          @hideInInvoice,
          @int_begin_month,
          @int_end_month,
          @deal_type,
          @time_bucket_formula_id,
          @payment_calendar,
          @pnl_date,
          @pnl_calendar,
          @calc_aggregation,
          @timeofuse,
          @include_charges,
          @contract_template,
          @contract_component_template,
          @automatic_manual,
          @settlement_date,
          @settlement_calendar,
          @effective_date,
          @group1,
          @group2,
          @group3,
          @group4,
          @leg,
          @default_gl_code_cash_applied

		SELECT @contract_id =  IDENT_CURRENT ('dbo.contract_group');

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
				SELECT contract_id, contract_name, contract_status, '''' as hyperlink FROM contract_group WHERE contract_id = ' + cast(@contract_id as varchar(5))
		
		EXEC(@sql_st)

		EXEC spa_register_event 20603, 20568, @process_table1, 0, @alert_process_id

      --EXEC spa_ErrorHANDler 0,
      --                      'contract Group',
      --                      'spa_contract_group',
      --                      'Success',
      --                      'Changes have been saved successfully',
      --                      ''
    END TRY
    BEGIN CATCH
      IF @@ERROR <> 0
        EXEC spa_ErrorHANDler -1,
                              'contract Group',
                              'spa_contract_group',
                              'Error',
                              'Duplicate data cannot be inserted',
                              ''
    END CATCH
    END
    ELSE
    IF @flag = 'u'
    BEGIN
    BEGIN TRY
      DECLARE @new_seq int,
              @update_id int,
              @old_prod_type char(1)

      SELECT
        @sequence_order = sequence_order,
        @old_prod_type = prod_type
      FROM contract_group_detail
      WHERE CAST([ID] AS varchar(100)) = @contract_detail_id
      AND contract_id = @contract_id

      IF EXISTS (SELECT
          *
        FROM contract_group_detail
        WHERE contract_id = @contract_id
        AND prod_type = @prod_type
        AND @after_seq < @sequence_order)
        SET @factor = 1
      ELSE
        SET @factor = -1

      IF @factor < 0
      BEGIN
        UPDATE contract_group_detail
        SET sequence_order = sequence_order - 1
        WHERE contract_id = @contract_id
        AND prod_type = @prod_type
        AND sequence_order BETWEEN @sequence_order + 1 AND @after_seq

        SET @new_seq = @after_seq
      END
      ELSE
      BEGIN
        UPDATE contract_group_detail
        SET sequence_order = sequence_order + 1
        WHERE contract_id = @contract_id
        AND prod_type = @prod_type
        AND sequence_order BETWEEN @after_seq + 1 AND @sequence_order
        SET @new_seq = @after_seq + 1
      END

      UPDATE contract_group_detail
      SET invoice_line_item_id = @invoice_line_item_id,
          default_gl_id = @default_gl_id,
          price = @price,
          formula_id = @formula_id,
          MANUAL = @manual,
          prod_type = @prod_type,
          sequence_order = @new_seq,
          inventory_item = @inventory_item,
          volume_granularity = @volume_granularity,
          class_name = @class_name,
          increment_peaking_name = @increment_peaking_name,
          product_type_name = @product_type_name,
          rate_description = @rate_description,
          units_for_rate = @units_for_rate,
          default_gl_id_estimates = @default_gl_id_estimates,
          eqr_product_name = @eqr_product_name,
          group_by = @group_by,
          ALIAS = @alias,
          hideInInvoice = @hideInInvoice,
          int_begin_month = @int_begin_month,
          int_end_month = @int_end_month,
          deal_type = @deal_type,
          time_bucket_formula_id = @time_bucket_formula_id,
          payment_calendar = @payment_calendar,
          pnl_date = @pnl_date,
          pnl_calendar = @pnl_calendar,
          calc_aggregation = @calc_aggregation,
          timeofuse = @timeofuse,
          include_charges = @include_charges,
          contract_template = @contract_template,
          contract_component_template = @contract_component_template,
          radio_automatic_manual = @automatic_manual,
          settlement_date = @settlement_date,
          settlement_calendar = @settlement_calendar,
          effective_date = @effective_date,
          group1 = @group1,
          group2 = @group2,
          group3 = @group3,
          group4 = @group4,
          leg = @leg,
          default_gl_code_cash_applied = @default_gl_code_cash_applied
      WHERE CAST([ID] AS varchar(100)) = @contract_detail_id

      EXEC spa_ErrorHANDler 0,
                            'contract Group',
                            'spa_contract_group',
                            'Success',
                            'contract Group successfully updated.',
                            ''
    END TRY
    BEGIN CATCH
      IF @@ERROR <> 0
        EXEC spa_ErrorHANDler -1,
                              'contract Group',
                              'spa_contract_group',
                              'Error',
                              'Duplicate data cannot be updated',
                              ''
    END CATCH
    END
  END
  ELSE
  IF @flag = 'd'
  BEGIN
  BEGIN TRY
    BEGIN TRAN

      CREATE TABLE #deleted_formula (
        formula_id int,
        formula_group_id int
      )

      DELETE f
      OUTPUT DELETED.formula_id, DELETED.formula_group_id
      INTO #deleted_formula
        FROM formula_nested f
        INNER JOIN contract_group_detail c
          ON f.formula_group_id = c.formula_id
          INNER JOIN dbo.SplitCommaSeperatedValues(@contract_detail_id) cdi
            ON cdi.item = CAST(c.id AS varchar(100))

      DECLARE @temp char(1)
      SELECT
        @temp = istemplate
      FROM formula_editor fe
      INNER JOIN #deleted_formula d
        ON fe.formula_id = d.formula_group_id

      IF @temp IS NULL
      BEGIN
        DELETE c
          FROM calc_formula_value c
          INNER JOIN #deleted_formula d
            ON c.formula_id = d.formula_group_id

        DELETE c
          FROM calc_formula_value_estimates c
          INNER JOIN #deleted_formula d
            ON c.formula_id = d.formula_group_id

        DELETE e
          FROM formula_editor_sql e
          INNER JOIN #deleted_formula d
            ON e.formula_id = d.formula_id

        DELETE e
          FROM formula_editor e
          INNER JOIN #deleted_formula d
            ON d.formula_id = e.formula_id
        WHERE e.istemplate IS NULL

        DELETE e
          FROM formula_editor e
          INNER JOIN contract_group_detail c
            ON e.formula_id = c.formula_id
            INNER JOIN dbo.SplitCommaSeperatedValues(@contract_detail_id) cdi
              ON cdi.item = CAST(c.id AS varchar(100))
      END

      DELETE c
        FROM contract_group_detail c
        INNER JOIN dbo.SplitCommaSeperatedValues(@contract_detail_id) cdi
          ON cdi.item = CAST(c.id AS varchar(100))

      EXEC spa_ErrorHANDler 0,
                            'contract Group',
                            'spa_contract_group',
                            'Success',
                            'Changes have been saved successfully.',
                            ''

    COMMIT TRAN
  END TRY
  BEGIN CATCH

    IF @@TRANCOUNT > 0
      ROLLBACK TRAN

    IF @@ERROR <> 0
      EXEC spa_ErrorHANDler -1,
                            'CONTRACT GROUP',
                            'spa_contract_group',
                            'DB ERROR',
                            'ERROR ON Deleting CONTRACT Group.',
                            ''
  END CATCH
  END
  ELSE
  IF @flag = 'v'
  BEGIN
    UPDATE contract_group_detail
    SET formula_id = @formula_id
    WHERE CAST([ID] AS varchar(100)) = @contract_detail_id
    EXEC spa_ErrorHANDler 0,
                          'contract Group',
                          'spa_contract_group',
                          'Success',
                          'Contract Group Updated Successfully.',
                          ''
  END
  ELSE
  IF @flag = 'c'  --copy charge type
  BEGIN
    SELECT
      @formula_id = formula_id
    FROM contract_group_detail
    WHERE id = @contract_id---here contract_id is the old contract_group_detail_id

    UPDATE contract_group_detail
    SET formula_id = @formula_id
    WHERE id = @contract_detail_id

    DECLARE @new_contract_id int
    SET @new_contract_id = @contract_detail_id

    DECLARE @formula varchar(8000),
            @formula_type varchar(1)
    DECLARE @new_formula_id int,
            @formula_nested_id INT
    DECLARE @istemplate varchar(1)
    DECLARE @formula_html varchar(8000)
    DECLARE formula_cursor CURSOR FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
    SELECT
      fe.formula_id,
      fe.formula,
      fe.formula_type,
      fe.formula_html,
      fe.istemplate
    FROM formula_editor fe
    INNER JOIN contract_group_detail cgd
      ON fe.formula_id = cgd.formula_id
    WHERE cgd.formula_id IS NOT NULL
    AND id = @new_contract_id

    OPEN formula_cursor
    FETCH NEXT FROM formula_Cursor INTO @formula_id, @formula, @formula_type, @formula_html, @istemplate
    WHILE @@fetch_status = 0
    BEGIN
      SET @formula = dbo.FNAFormulaFormat(@formula, 'd')
      INSERT formula_editor (formula, formula_type)
        VALUES (@formula, @formula_type)
      SET @new_formula_id = SCOPE_IDENTITY()
      --	exec spa_print @new_formula_id
      IF @formula_type = 'n'
      BEGIN
        DECLARE @formula_id_n int
        DECLARE @formula_id_n_new int
        DECLARE formula_cursor1 CURSOR FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
        SELECT
          formula_id,
          sequence_order
        FROM formula_nested
        WHERE formula_group_id = @formula_id
        OPEN formula_cursor1
        FETCH NEXT FROM formula_Cursor1 INTO @formula_id_n, @sequence_order
        WHILE @@fetch_status = 0
        BEGIN
          INSERT formula_editor (formula, formula_type, formula_html, istemplate)
            SELECT
              formula,
              formula_type,
              formula_html,
              istemplate
            FROM formula_editor
            WHERE formula_id = @formula_id_n
          SET @formula_id_n_new = SCOPE_IDENTITY()
          INSERT INTO formula_nested (sequence_order, description1, description2, formula_id, formula_group_id, granularity, include_item, show_value_id, uom_id, rate_id, total_id)
            SELECT
              sequence_order,
              description1,
              description2,
              @formula_id_n_new,
              @new_formula_id,
              granularity,
              include_item,
              show_value_id,
              uom_id,
              rate_id,
              total_id
            FROM formula_nested
            WHERE formula_group_id = @formula_id
            AND formula_id = @formula_id_n

          SET @formula_nested_id = SCOPE_IDENTITY()
          INSERT INTO formula_breakdown (formula_id, nested_id, formula_level, func_name, arg_no_for_next_func, parent_nested_id, level_func_sno, parent_level_func_sno, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, eval_value, formula_nested_id)
            SELECT
              @new_formula_id,
              nested_id,
              formula_level,
              func_name,
              arg_no_for_next_func,
              parent_nested_id,
              level_func_sno,
              parent_level_func_sno,
              arg1,
              arg2,
              arg3,
              arg4,
              arg5,
              arg6,
              arg7,
              arg8,
              arg9,
              arg10,
              arg11,
              arg12,
              eval_value,
              @formula_nested_id
            FROM formula_breakdown
            WHERE formula_id = @formula_id
            AND nested_id = @sequence_order
          FETCH NEXT FROM formula_Cursor1 INTO @formula_id_n, @sequence_order
        END --CURSOR1
        CLOSE formula_cursor1
        DEALLOCATE formula_cursor1
      END


      UPDATE [contract_group_detail]
      SET formula_id = @new_formula_id
      WHERE formula_id = @formula_id
      AND [id] = @new_contract_id
      FETCH NEXT FROM formula_Cursor INTO @formula_id, @formula, @formula_type, @formula_html, @istemplate
    END --CURSOR
    CLOSE formula_cursor
    DEALLOCATE formula_cursor

    IF @@ERROR <> 0
      EXEC spa_ErrorHandler -1,
                            'Maintain Contract Detail',
                            'spa_contract_group',
                            'DB Error',
                            'Error Copying Formula.',
                            ''
    ELSE
      EXEC spa_ErrorHandler 0,
                            'Contract Group',
                            'spa_contract_group',
                            'Success',
                            'Changes have been saved successfully.',
                            @new_contract_id

  END
  ELSE
  IF @flag = 'z'  -- call from settlement calc screen to populate charge type drop down
  BEGIN
    SELECT
      cgd.invoice_line_item_id,
      sd.[description] [CONTRACT Components]
    FROM contract_group_detail cgd
    INNER JOIN static_data_value sd
      ON cgd.invoice_line_item_id = sd.value_id
    WHERE contract_id = @contract_id
    AND prod_type = @prod_type
    ORDER BY sequence_order
  END
  --true up charge type dropdown option population
  ELSE
  IF @flag = 'q'
  BEGIN
    SELECT
      cgd.invoice_line_item_id [Contract Components],
      sd.description [Model Components]
    FROM contract_group_detail cgd
    INNER JOIN static_data_value sd
      ON cgd.invoice_line_item_id = sd.value_id
    LEFT JOIN adjustment_default_gl_codes adgc
      ON cgd.default_gl_id = adgc.default_gl_id
    LEFT JOIN static_data_value sd1
      ON adgc.adjustment_type_id = sd1.value_id
    LEFT JOIN source_currency sc
      ON sc.source_currency_id = cgd.currency
    LEFT JOIN formula_editor fr
      ON fr.formula_id = cgd.formula_id
    LEFT JOIN static_data_value vg
      ON cgd.volume_granularity = vg.value_id
    LEFT JOIN source_deal_type sdp
      ON sdp.source_deal_type_id = cgd.deal_type
    LEFT JOIN contract_charge_type cct
      ON cct.contract_charge_type_id = cgd.contract_template
    LEFT JOIN contract_charge_type_detail cctd
      ON cctd.ID = cgd.contract_component_template
    LEFT JOIN static_data_value contract_template
      ON contract_template.value_id = cctd.invoice_line_item_id
    WHERE contract_id = @contract_id
    AND cgd.prod_type = @prod_type
	order by sd.description
  END
END
IF @flag = 'y'
BEGIN
	SELECT  cgd.invoice_line_item_id,sdv.code FROM contract_group_detail cgd
	INNER JOIN static_data_value sdv ON cgd.invoice_line_item_id = sdv.value_id 
	WHERE cgd.contract_id IN ( @contract_id )
	AND ISNULL(cgd.is_true_up,'n') = 'n'
	--AND cgd.contract_id <> @contract_detail_id
	ORDER BY sdv.code
END
