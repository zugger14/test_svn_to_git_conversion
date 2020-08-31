IF OBJECT_ID(N'[dbo].[spa_contract_charge_type]', N'P') IS NOT NULL
	DROP PROC [dbo].[spa_contract_charge_type]
GO

CREATE PROCEDURE [dbo].[spa_contract_charge_type]	
	@flag AS CHAR(1),	
	@contract_id INT = NULL,
	@contract_charge_type_id VARCHAR(1000) = NULL,
	@contract_charge_desc VARCHAR(100) = NULL,
	@sub_id INT = NULL,
	@deal_type INT = NULL
AS

/*---------------Debug Section-----------------
DECLARE @flag AS CHAR(1),	
		@contract_id INT = NULL,
		@contract_charge_type_id VARCHAR(1000) = NULL,
		@contract_charge_desc VARCHAR(100) = NULL,
		@sub_id INT = NULL,
		@deal_type INT = NULL

SELECT @flag='c',@contract_id='14'
---------------------------------------------*/

DECLARE @error INT

SET NOCOUNT ON

IF @flag='i'
BEGIN
	INSERT INTO contract_charge_type (contract_charge_desc, sub_id, deal_type)
	VALUES (@contract_charge_desc, @sub_id, @deal_type)
	
	SET @contract_charge_type_id = SCOPE_IDENTITY()
	SET @error = ERROR_NUMBER()

	IF @error <> 0
		EXEC spa_ErrorHandler @error, 'contract_charge_type', 'spa_contract_charge_type', 'DB Error', 'Failed to insert contract charge type.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'contract_charge_type', 'spa_contract_charge_type', 'Success', 'Successfully Inserted Values', @contract_charge_type_id
END
ELSE IF @flag = 'a'
BEGIN
	SELECT contract_charge_type_id [ID],
		   contract_charge_desc [Contract Charge Type],
		   sub_id,
		   deal_type
	FROM contract_charge_type
	WHERE contract_charge_type_id = @contract_charge_type_id
END
ELSE IF @flag = 's'
BEGIN
	IF @sub_id IS NULL
		SELECT contract_charge_type_id [ID],
			   contract_charge_desc [Contract Charge Type]
		FROM contract_charge_type
		WHERE contract_charge_desc LIKE '%' + ISNULL(@contract_charge_desc, '') + '%'
	ELSE 
		SELECT contract_charge_type_id [ID],
			   contract_charge_desc [Contract Charge Type] 
		FROM contract_charge_type 
		WHERE sub_id = @sub_id
			OR sub_id IS NULL
			AND contract_charge_desc LIKE '%' + ISNULL(@contract_charge_desc, '') + '%'
END
ELSE IF @flag = 'u'
BEGIN
	UPDATE contract_charge_type
	SET contract_charge_desc = @contract_charge_desc,
		sub_id = @sub_id,
		deal_type = @deal_type		
	WHERE contract_charge_type_id = @contract_charge_type_id

	SET @error = ERROR_NUMBER()

	IF @error <> 0
		EXEC spa_ErrorHandler @error, 'contract_charge_type', 'spa_contract_charge_type', 'DB Error', 'Failed to update Contract Charge Type.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'contract_charge_type', 'spa_contract_charge_type', 'Success', 'Contract Charge Type updated.', ''
END
ElSE IF @flag = 'd'
BEGIN
	SELECT s.item contract_charge_type_id
	INTO #temp_contract_charge_type 
	FROM dbo.SplitCommaSeperatedValues(@contract_charge_type_id) s

	IF EXISTS (
		SELECT 1 
		FROM contract_group cg
		INNER JOIN #temp_contract_charge_type tcct
			ON tcct.contract_charge_type_id = cg.contract_charge_type_id
	)
	BEGIN
		EXEC spa_ErrorHandler -1, 'contract_charge_type', 'spa_contract_charge_type', 'DB Error', 'Contract component template used in contract.', ''
	END

	IF EXISTS (
		SELECT contract_component_template
		FROM contract_group_detail cgd
		INNER JOIN #temp_contract_charge_type tcct
			ON tcct.contract_charge_type_id = cgd.contract_template
	)
	BEGIN
		EXEC spa_ErrorHandler -1, 'contract_charge_type', 'spa_contract_charge_type', 'DB Error', 'Data used in contract detail.', ''
	END
	ELSE
	BEGIN
		IF OBJECT_ID (N'#temp_formula_id', N'U') IS NOT NULL 
			DROP TABLE #temp_formula_id
			
		SELECT fn.formula_id
		INTO #temp_formula_id
		FROM formula_nested fn
		INNER JOIN contract_charge_type_detail s
			ON fn.formula_group_id=s.formula_id 
		INNER JOIN #temp_contract_charge_type tcct
			ON tcct.contract_charge_type_id = s.contract_charge_type_id

		DELETE b 
		FROM formula_breakdown b 
		INNER JOIN formula_nested f
			ON f.formula_group_id=b.formula_id
		INNER JOIN contract_charge_type_detail s
			ON f.formula_group_id=s.formula_id
		INNER JOIN #temp_contract_charge_type tcct
			ON tcct.contract_charge_type_id = s.contract_charge_type_id

		DELETE f
		FROM formula_nested f 
		INNER JOIN contract_charge_type_detail s
			ON f.formula_group_id=s.formula_id
		INNER JOIN #temp_contract_charge_type tcct
			ON tcct.contract_charge_type_id = s.contract_charge_type_id

		DELETE f
		FROM formula_editor f 
		INNER JOIN #temp_formula_id tmp
			ON f.formula_id = tmp.formula_id

		DELETE f
		FROM formula_editor f 
		INNER JOIN contract_charge_type_detail s
			ON f.formula_id=s.formula_id
		INNER JOIN #temp_contract_charge_type tcct
			ON tcct.contract_charge_type_id = s.contract_charge_type_id

		DELETE cct
		FROM contract_charge_type cct
		INNER JOIN #temp_contract_charge_type tcct
			ON tcct.contract_charge_type_id = cct.contract_charge_type_id

		SET @error = ERROR_NUMBER()

		IF @error <> 0
			EXEC spa_ErrorHandler @error, 'contract_charge_type', 'spa_contract_charge_type', 'DB Error', 'Failed to delete contract charge type.', ''
		ELSE
			EXEC spa_ErrorHandler 0, 'contract_charge_type', 'spa_contract_charge_type', 'Success', 'Changes have been saved successfully', ''
	END
END
ELSE IF @flag = 'x' --for retrieving the data from the table contract charge type for the contract template combobox
BEGIN
	SELECT contract_charge_type_id [ID],
	       contract_charge_desc [Contract Charge Type]
	FROM contract_charge_type 
END
ELSE IF @flag = 'g' --for retrieving grid data new UI framework
BEGIN
	SELECT contract_charge_type_id  AS [contract_id],
		   contract_charge_desc AS [contract_name],
		   ph.[entity_name] AS [entity_name]
	FROM contract_charge_type cct
	LEFT JOIN portfolio_hierarchy ph
		ON ph.[entity_id] = cct.sub_id	
	ORDER BY [contract_name]
END
/******************* Added by: Laxmihari Nepal  Date: 24/08/2016******************************/
ELSE IF @flag='c' --for copying contract template
	BEGIN
		BEGIN TRAN
		DECLARE @new_contract_id INT, 
				@copy_contract VARCHAR(500),
				@new_contract VARCHAR(300), 
				@new_source_contract_id VARCHAR(500),
				@invoice_line_item_id VARCHAR(300)
			
		SELECT @copy_contract = contract_charge_desc
		FROM contract_charge_type
		WHERE contract_charge_type_id = @contract_id

		EXEC [spa_GetUniqueCopyName] @copy_contract, 'contract_charge_desc', 'contract_charge_type', NULL, @new_contract OUTPUT

		INSERT INTO contract_charge_type (contract_charge_desc, sub_id, deal_type)
		SELECT @new_contract, sub_id, deal_type
		FROM contract_charge_type
		WHERE contract_charge_type_id = @contract_id
		
		SET @new_contract_id = SCOPE_IDENTITY()
		SET @error = ERROR_NUMBER()

		IF @error <> 0
		BEGIN
			EXEC spa_ErrorHandler -1, 'Maintain Contract Group', 'spa_contract_group', 'DB Error', 'Copying of Maintain Contract Group data failed.', ''
			ROLLBACK TRAN
		END
		ELSE
		BEGIN
			INSERT INTO contract_charge_type_detail (
				contract_charge_type_id, invoice_line_item_id, default_gl_id, price, formula_id, [manual], currency, volume_granularity, Prod_type,
				sequence_order, inventory_item, default_gl_id_estimates, group_by, time_of_use, payment_calendar, pnl_date, pnl_calendar, settlement_date,
				settlement_calendar, effective_date, aggregation_level, group1, group2, group3, group4, leg, default_gl_code_cash_applied, alias, template_id,
				location, buy_sell, true_up_charge_type_id, true_up_no_month, true_up_applies_to, is_true_up, end_date
			)
			SELECT @new_contract_id, invoice_line_item_id, default_gl_id, price, formula_id, [manual], currency, volume_granularity, Prod_type,
				   sequence_order, inventory_item, default_gl_id_estimates, group_by, time_of_use, payment_calendar, pnl_date, pnl_calendar, settlement_date,
				   settlement_calendar, effective_date, aggregation_level, group1, group2, group3, group4, leg, default_gl_code_cash_applied, alias, template_id,
				   location, buy_sell, true_up_charge_type_id, true_up_no_month, true_up_applies_to, is_true_up, end_date
			FROM contract_charge_type_detail
			WHERE contract_charge_type_id = @contract_id

			SET @error = ERROR_NUMBER()
			
			IF @error <> 0
			BEGIN
				EXEC spa_ErrorHandler -1, 'Maintain Contract Detail', 'spa_contract_group', 'DB Error', 'Error Copying Contract Group Detail Data.', ''
				ROLLBACK TRAN
			END						
		ELSE
		BEGIN
			DECLARE @formula_id INT,
					@formula VARCHAR(8000),
					@formula_type VARCHAR(1),
					@formula_html VARCHAR(MAX),
					@new_formula_id INT,
					@sequence_order INT,
					@formula_nested_id INT
			
			DECLARE formula_cursor CURSOR FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
				
				SELECT fe.formula_id,
					   fe.formula,
					   fe.formula_type
				FROM formula_editor fe 
				INNER JOIN contract_charge_type_detail cctd
					ON fe.formula_id = cctd.formula_id 
				WHERE cctd.formula_id IS NOT NULL 
					AND contract_charge_type_id = @new_contract_id

			OPEN formula_cursor			
			FETCH NEXT FROM formula_Cursor 
			INTO @formula_id, @formula, @formula_type
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @formula = dbo.FNAFormulaFormat(@formula, 'd')
				
				INSERT formula_editor (formula, formula_type, formula_html)
				VALUES (@formula, @formula_type, @formula_html)
				
				SET @new_formula_id = SCOPE_IDENTITY()
				
				IF @formula_type = 'n'
				BEGIN
					DECLARE @formula_id_n INT,
							@formula_id_n_new INT

					DECLARE formula_cursor1 CURSOR FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
						
						SELECT formula_id,
							   sequence_order
						FROM formula_nested
						WHERE formula_group_id = @formula_id

					OPEN formula_cursor1
					FETCH NEXT FROM formula_Cursor1
					INTO @formula_id_n, @sequence_order
					WHILE @@FETCH_STATUS = 0
					BEGIN
						INSERT formula_editor (formula, formula_type, formula_name, system_defined, static_value_id, istemplate, formula_source_type, formula_html)
						SELECT formula, formula_type, formula_name, system_defined, static_value_id, istemplate, formula_source_type, formula_html
						FROM formula_editor WHERE formula_id=@formula_id_n
						SET @formula_id_n_new = SCOPE_IDENTITY()

						INSERT INTO formula_nested (
							sequence_order, description1, description2, formula_id, formula_group_id, granularity,
							include_item, show_value_id, uom_id, rate_id, total_id
						)
						SELECT sequence_order, description1, description2, @formula_id_n_new, @new_formula_id, granularity,
							   include_item, show_value_id, uom_id, rate_id, total_id
						FROM formula_nested
						WHERE formula_group_id = @formula_id 
							AND formula_id = @formula_id_n
									
						SET @formula_nested_id = SCOPE_IDENTITY()	
										
						INSERT INTO formula_breakdown(
							formula_id, nested_id, formula_level, func_name, arg_no_for_next_func, parent_nested_id, level_func_sno, parent_level_func_sno,
							arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, eval_value, formula_nested_id
						)
						SELECT @new_formula_id, nested_id, formula_level, func_name, arg_no_for_next_func, parent_nested_id, level_func_sno, parent_level_func_sno,
							   arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, eval_value, @formula_nested_id
						FROM formula_breakdown 
						WHERE formula_id = @formula_id
							AND nested_id = @sequence_order

					FETCH NEXT FROM formula_Cursor1 INTO @formula_id_n, @sequence_order
					END --CURSOR1
					CLOSE formula_cursor1
					DEALLOCATE formula_cursor1
				END				
					UPDATE contract_charge_type_detail 
					SET formula_id = @new_formula_id 
					WHERE formula_id = @formula_id 
						AND contract_charge_type_id = @new_contract_id
				FETCH NEXT FROM formula_Cursor INTO @formula_id, @formula, @formula_type
			END --CURSOR
			CLOSE formula_cursor
			DEALLOCATE formula_cursor
			
			SET @error = ERROR_NUMBER()
								
			IF @error <> 0
				EXEC spa_ErrorHandler -1, 'Maintain Contract Detail', 'spa_contract_charge_type_detail', 'DB Error', 'Error Copying Formula.', ''
			ELSE
				EXEC spa_ErrorHandler 0, 'Contract Group', 'spa_contract_charge_type', 'Success', 'Changes have been saved successfully.', @new_contract_id					
			COMMIT TRAN
		END
	END
END
GO