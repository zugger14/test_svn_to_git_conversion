/****** Object:  StoredProcedure [dbo].[spa_contract_charge_type_detail]    Script Date: 07/23/2009 01:05:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_contract_charge_type_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_contract_charge_type_detail]
/****** Object:  StoredProcedure [dbo].[spa_contract_charge_type_detail]    Script Date: 07/23/2009 01:05:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spa_contract_charge_type_detail]
	@flag char(1),
	@contract_detail_id INT = NULL,
	@contract_charge_type_id INT = NULL,
	@invoice_line_item_id INT = NULL,
	@default_gl_id INT = NULL,
	@price FLOAT = NULL,
	@formula_id INT = NULL,
	@manual CHAR(1) = NULL,
	@prod_type CHAR(1)= NULL,
	@after_seq INT = NULL,
	@inventory_item char(1) = NULL,
	@volume_granularity INT = NULL,
	@default_gl_id_estimates INT = NULL,
	@group_by INT = NULL,
	@time_of_use INT = NULL,
	@payment_calendar INT = NULL,
	@pnl_date INT = NULL,
	@pnl_calendar INT = NULL,
	@settlement_date VARCHAR(100) = NULL,
	@settlement_calendar INT = NULL,
	@effective_date VARCHAR(100) = NULL,
	@aggregation_level INT = NULL,
	@group1 INT = NULL,
	@group2 INT = NULL,
	@group3 INT = NULL,
	@group4 INT = NULL,
	@leg INT = NULL,
	@default_gl_code_cash_applied INT = NULL,
	@alias INT  = NULL,
	@template_id INT = NULL,
	@contract_id INT = NULL ---here contract_id is the old contract_charge_type_detail_id
AS
BEGIN

SET NOCOUNT ON 
DECLARE @sql varchar(8000),@sequence_order int

IF @flag = 's'
BEGIN
	SELECT [ID],
			sd.description +'('+sd.code+')' [Contract Components],
			sd1.code [GL Account],
			price [Flat Fee],
			CASE WHEN formula_type ='n' and formula IS NULL
			THEN 'Nested Formula' 
			ELSE 
			dbo.FNAFormulaFormat(fr.formula, 'r') 
			end 
			Formula,
			vg.code Granularity
	FROM	contract_charge_type_detail cgd 
	INNER JOIN static_data_value sd on cgd.invoice_line_item_id=sd.value_id
	LEFT JOIN adjustment_default_gl_codes adgc on cgd.default_gl_id=adgc.default_gl_id
	LEFT JOIN static_data_value sd1 on adgc.adjustment_type_id=sd1.value_id 
	LEFT JOIN source_currency sc on sc.source_currency_id=cgd.currency
	LEFT JOIN formula_editor fr on fr.formula_id=cgd.formula_id
	LEFT JOIN static_data_value vg on cgd.volume_granularity =vg.value_id
	WHERE contract_charge_type_id=@contract_charge_type_id AND prod_type=ISNULL(@prod_type,'p')
	ORDER BY sequence_order,[ID]
END
else if @flag='p' 
BEGIN
	
	select sequence_order,sd.description +'('+sd.code+')' [Contract Components]
	from 	contract_charge_type_detail cgd inner join
	static_data_value sd on cgd.invoice_line_item_id=sd.value_id
	where contract_charge_type_id=@contract_charge_type_id and prod_type=ISNULL(@prod_type,'p') and
	[ID] not in (@contract_detail_id)
	order by sequence_order
	
END
ELSE IF @flag = 'a'
BEGIN
	SELECT [ID],
			sd.value_id [Invoice Line Item],
			cgd.default_gl_id [Adjustment GL],
			price Price,cgd.formula_id,
			manual [Manual Entry],
			CASE WHEN formula_type='n' and formula IS NULL THEN 'Nested Formula' 
			ELSE dbo.FNAFormulaFormat(fr.formula, 'r') 
			END ,
			prod_type,
			sequence_order,
			inventory_item,
			cgd.volume_granularity,
	isnull((select count(ii.sequence_order)			
	FROM contract_charge_type_detail ii 
	WHERE ii.contract_charge_type_id=cgd.contract_charge_type_id and ii.sequence_order<cgd.sequence_order),0) psno,default_gl_id_estimates,formula_type,isnull(fr.system_defined,'n') as system_defined,
	group_by,
	time_of_use,
	payment_calendar, 
	pnl_date, 
	pnl_calendar, 
	CONVERT(VARCHAR(10),settlement_date,120) settlement_date,
	settlement_calendar,
	CONVERT(VARCHAR(10),effective_date,120) effective_date,
	aggregation_level,
	cgd.group1,
	cgd.group2,
	cgd.group3,
	cgd.group4,
	cgd.leg,
	cgd.default_gl_code_cash_applied,
	sdv1.value_id
	FROM contract_charge_type_detail cgd 
	INNER JOIN static_data_value sd on cgd.invoice_line_item_id=sd.value_id
	--LEFT JOIN adjustment_default_gl_codes adgc on cgd.default_gl_id=adgc.default_gl_id
	--left join static_data_value sd1 on adgc.adjustment_type_id=sd1.value_id 
	LEFT JOIN formula_editor fr on fr.formula_id=cgd.formula_id
	LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cgd.alias
	where [ID]=@contract_detail_id 

END
ELSE IF @flag = 'i'
BEGIN
	SELECT @sequence_order=isNUll(max(sequence_order),0)+1 from contract_charge_type_detail where contract_charge_type_id=@contract_charge_type_id
	
	INSERT INTO contract_charge_type_detail (
		contract_charge_type_id,
		invoice_line_item_id,
		default_gl_id,
		price,
		formula_id,
		manual,
		prod_type,
		sequence_order,
		inventory_item,
		volume_granularity,
		default_gl_id_estimates,
		group_by,
		time_of_use,
		payment_calendar,
		pnl_date,
		pnl_calendar,
		settlement_date,
		settlement_calendar,
		effective_date,
		aggregation_level, 
		group1,
		group2,
		group3,
		group4,
		leg,
		default_gl_code_cash_applied,
		alias
	)
	SELECT 
		@contract_charge_type_id,
		@invoice_line_item_id,
		@default_gl_id,
		@price,
		@formula_id,
		@manual,
		isnull(@prod_type, 'p'),
		@sequence_order,
		@inventory_item,
		@volume_granularity,
		@default_gl_id_estimates,
		@group_by,
		@time_of_use,
		@payment_calendar,
		@pnl_date,
		@pnl_calendar,
		@settlement_date,
		@settlement_calendar,
		@effective_date,
		@aggregation_level,
		@group1,
		@group2,
		@group3,
		@group4,
		@leg,
		@default_gl_code_cash_applied,
		@alias

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'contract_charge_type_detail', 
		'spa_contract_charge_type_detail', 'DB Error', 
		'Error on Updating contract charge type detail.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'contract_charge_type_detail', 
		'spa_contract_charge_type_detail', 'Success', 
		'Changes have been saved successfully.',''
END
ELSE IF @flag='u'
BEGIN
	declare @new_seq int,@update_id int,@old_prod_type char(1)
	if not exists (select sequence_order  from contract_charge_type_detail where contract_charge_type_id=@contract_charge_type_id)
	begin
		select @sequence_order=isNUll(max(sequence_order),0)+1 from contract_charge_type_detail where contract_charge_type_id=@contract_charge_type_id
		set @after_seq=null
	end
	select @sequence_order=sequence_order,@old_prod_type=prod_type from contract_charge_type_detail where [ID]=@contract_detail_id
	
	if @after_seq is null
	begin
		set @new_seq=1
		select @update_id=[ID] from contract_charge_type_detail where sequence_order=@new_seq 
		and contract_charge_type_id=@contract_charge_type_id
	end
	if @after_seq is not null
	begin
		if(select max(sequence_order) from contract_charge_type_detail where contract_charge_type_id=@contract_charge_type_id)=@after_seq
			set @new_seq=@after_seq
		else
			set @new_seq=@after_seq+1
		select @update_id=[ID] from contract_charge_type_detail where sequence_order=@new_seq and contract_charge_type_id=@contract_charge_type_id
	end
-- 	else
-- 		set @new_seq=@sequence_order
	if @update_id is not null
		update contract_charge_type_detail 
			set sequence_order=@sequence_order 
			where [ID]=@update_id

	update contract_charge_type_detail
	set
		invoice_line_item_id=@invoice_line_item_id,
		default_gl_id=@default_gl_id,
		price=@price,
		formula_id=@formula_id,
		manual=@manual,
		prod_type=ISNULL(@prod_type, 'p'),
		sequence_order=@new_seq,
		inventory_item=@inventory_item ,
		volume_granularity=@volume_granularity,
		default_gl_id_estimates=@default_gl_id_estimates,
		group_by=@group_by,
		time_of_use = @time_of_use,
		payment_calendar = @payment_calendar,
		pnl_date = @pnl_date,
		pnl_calendar = @pnl_calendar, 
		settlement_date = @settlement_date,
		settlement_calendar = @settlement_calendar,
		effective_date = @effective_date,
		aggregation_level = @aggregation_level,
		group1 = @group1,
		group2 = @group2,
		group3 = @group3,
		group4 = @group4,
		leg = @leg,
		default_gl_code_cash_applied = @default_gl_code_cash_applied,
		alias = @alias
	where
		[ID]=@contract_detail_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'contract_charge_type_detail', 
		'contract_charge_type_detail', "DB Error", 
		'Error on Updating contract_charge_type_detail.', ''
	else
		Exec spa_ErrorHandler 0, 'contract_charge_type_detail', 
		'spa_contract_charge_type_detail', 'Success', 
		'Changes have been saved successfully.',''

END

ELSE IF @flag='d'
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
        INNER JOIN contract_charge_type_detail c
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
          INNER JOIN contract_charge_type_detail c
            ON e.formula_id = c.formula_id
            INNER JOIN dbo.SplitCommaSeperatedValues(@contract_detail_id) cdi
              ON cdi.item = CAST(c.id AS varchar(100))
      END

      DELETE c
        FROM contract_charge_type_detail c
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
			'ERROR ON Deleting Contract Charge Type.',
			''
	END CATCH
END
ELSE IF @flag = 'z' --DELETE contract_charge_type from only table contract_charge_type_detail
BEGIN
	IF EXISTS (SELECT 1 FROM contract_group_detail WHERE contract_component_template = @contract_detail_id)

	BEGIN
		EXEC spa_ErrorHandler -1, 'contract_charge_type', 
			'spa_contract_charge_type', 'DB Error', 
			'Data used in contract detail.', ''
	END

	ELSE
	BEGIN
		IF OBJECT_ID (N'#temp_formula_id', N'U') IS NOT NULL 
			DROP TABLE #temp_formula_id
			
		SELECT fn.formula_id INTO #temp_formula_id FROM formula_nested fn
		INNER JOIN contract_charge_type_detail s on
		fn.formula_group_id=s.formula_id and  s.ID=@contract_detail_id

		DELETE b FROM formula_breakdown b 
		INNER JOIN formula_nested f on f.formula_group_id=b.formula_id
		INNER JOIN contract_charge_type_detail s on 
		f.formula_group_id=s.formula_id and  s.ID=@contract_detail_id

		DELETE f FROM formula_nested f 
		INNER JOIN contract_charge_type_detail s on
		f.formula_group_id=s.formula_id and  s.ID=@contract_detail_id

		DELETE f FROM formula_editor f 
		INNER JOIN #temp_formula_id tmp ON f.formula_id = tmp.formula_id

		DELETE f FROM formula_editor f 
		INNER JOIN contract_charge_type_detail s on
		f.formula_id=s.formula_id and  s.ID=@contract_detail_id

		DELETE FROM contract_charge_type_detail WHERE ID = @contract_detail_id
	END
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler -1, 'Contract Group', 
				'spa_contract_charge_type_detail', 'DB Error', 
				'Failed to delete  charge type.', ''
	ELSE
	
		EXEC spa_ErrorHandler 0, 'Contract Group', 
				'spa_contract_charge_type_detail', 'Success', 
				'Changes have been saved successfully.', ''
	 
END
ELSE IF @flag = 'x' --populating the combobox Contract Component  Template by using the selected value pf Contract component
BEGIN
	SELECT cctd.[id] AS ID,
		   sdv.code AS Name
	FROM contract_charge_type_detail cctd
	LEFT JOIN static_data_value sdv ON cctd.invoice_line_item_id=sdv.value_id
	WHERE cctd.contract_charge_type_id=@contract_charge_type_id
	ORDER BY cctd.ID
END
ELSE IF @flag = 'g' --show table grid in maintain contract template new ui
BEGIN
	SELECT cctd.ID AS ID,
			sdv.code AS contract_components,
			cctd.volume_granularity,
			cctd.aggregation_level,
			CASE 
				WHEN (cctd.price IS NOT NULL) THEN 'Flat Fee' 
				ELSE CASE WHEN cctd.contract_component_type = 'c' THEN 'Charge Map'
						  WHEN cctd.contract_component_type = 't' THEN 'Template'
				ELSE 'Formula' 
					 END
			END AS [gl_account],
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
	WHERE cctd.contract_charge_type_id=@template_id
	ORDER BY CASE WHEN [sequence_order] IS NULL THEN '9999' ELSE [sequence_order] END ASC
END
ELSE IF @flag = 'l' --show dependent options of template contract component.
BEGIN
	SELECT [ID],
			sdv.code AS [contract_components]
	FROM contract_charge_type_detail cgd 
	INNER JOIN static_data_value sdv ON sdv.value_id = cgd.invoice_line_item_id
	WHERE cgd.contract_charge_type_id=@template_id
	ORDER BY [ID]
END

IF @flag = 'c'  --copy charge type
  BEGIN
    SELECT
      @formula_id = formula_id
    FROM contract_charge_type_detail
    WHERE ID = @contract_id---here contract_id is the old contract_charge_type_detail_id

    UPDATE contract_charge_type_detail
    SET formula_id = @formula_id
    WHERE ID = @contract_detail_id

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
    INNER JOIN contract_charge_type_detail cgd
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


      UPDATE [contract_charge_type_detail]
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
			@contract_detail_id
  END
END



