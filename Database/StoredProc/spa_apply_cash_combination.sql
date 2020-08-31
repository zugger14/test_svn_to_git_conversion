IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_apply_cash_combination]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_apply_cash_combination]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Description:	Find the combination of the invoice amount as inputed by the user in apply cash
	
	Parameters:
	@flag : Flag 'n' to find exact combiantion of line item. 					
					Flag 'm' for not exact combination, return the combination according to min invoice amount
	@counterparty_id		: counterparty id
	@invoice_number 		: invoice number
	@production_month 	: production month
	@save_invoice_detail_id	: save invoice detail
	@type_cash			: type cash
	@type_rp				: type rp
	@contract_id			: contract id
	@round_value			: round value
	@receive_pay_date	: receive pay date
	@production_month_to : production month to
	@invoice_due_date 	: invoice due date
	@amount				: Amount input of which combination need to be calculated
	@show_variance 		: show variance
	@charge_type 		: Charge type of the line item group
	@invoice 			: Invoice date of the line item group
	@production			: Invoice date of the line item group
	@comment				: comment
	@is_adjustment 		: is adjustment
	@show_prepay			: show prepay
	@show_option			: show option
	@commodity			: commodity
**/

CREATE procedure [dbo].[spa_apply_cash_combination] 
	@flag CHAR(1),
	@counterparty_id VARCHAR(MAX),
	@invoice_number VARCHAR(50) = null,
	@production_month VARCHAR(20) = null,
	@save_invoice_detail_id INT = null,
	@type_cash CHAR(1) = 'n',
	@type_rp CHAR(1)='r',
	@contract_id INT = NULL,
	@round_value CHAR(2) = '0',
	@receive_pay_date VARCHAR(20) = NULL,
	@production_month_to VARCHAR(20) = NULL,
	@invoice_due_date VARCHAR(20) = NULL,
	@amount VARCHAR(MAX) = NULL,
	@show_variance CHAR(2) = 'n',
	@charge_type VARCHAR(100) = NULL,
	@invoice DATETIME = NULL,
	@production DATETIME = NULL,
	@comment VARCHAR(200) = NULL,
	@is_adjustment CHAR(1) = NULL,
	@show_prepay CHAR(1) = NULL,
	@show_option CHAR(1) = NULL,
	@commodity INT = NULL
	
AS
SET NOCOUNT ON
DECLARE @sql VARCHAR(max)
DECLARE @join_type VARCHAR(10)
	
IF @type_cash = 'a'
	SET @join_type = 'INNER JOIN'
ELSE 
	SET @join_type = 'LEFT JOIN'

IF @type_rp = 'p' 
	SET @amount = CAST((CAST(@amount AS NUMERIC(32, 2)) * -1) AS VARCHAR(MAX))
	

IF @flag = 'm' -- For Combination of group
BEGIN
	DECLARE @prior_prod_month VARCHAR(20) = DATEADD (MM , -1, @production_month ) 
	DECLARE @prior_prod_month_to VARCHAR(20) = DATEADD (MM , -1, @production_month_to )

	SET @sql = '
			SELECT 
				civv.invoice_number,
				COALESCE(sdv1.description, sdv.description) [charge_type],
				COALESCE(dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE())), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days)),dbo.FNAGetContractMonth(civv.prod_date)) AS [invoice_due_date],		
				CASE 
					WHEN (MAX(sdv1.description) IS NULL) 
						THEN (MAX(dbo.FNARemoveTrailingZero(CONVERT(DECIMAL(18, 7), ROUND(civ.value, 2)))))
					ELSE SUM(ROUND(civ.value, 2)) 
				END  [sum_amount] 
			INTO #temp_min_grid		 
			   FROM
				source_counterparty sc
					OUTER APPLY(SELECT MAX(as_of_date) as_of_date,prod_date,counterparty_id,contract_id FROM calc_invoice_volume_variance 
					WHERE counterparty_id=sc.source_counterparty_id '
						+ CASE WHEN  @production_month IS NOT NULL THEN ' 
						AND prod_date BETWEEN  ''' + @production_month + ''' and ''' + ISNULL(@production_month_to, @production_month) + '''' ELSE '' END +' GROUP BY prod_date,counterparty_id,contract_id) a
				INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=a.counterparty_id AND civv.contract_id=a.contract_id AND civv.prod_date=a.prod_date AND civv.as_of_date=a.as_of_date
				INNER JOIN calc_invoice_volume civ ON civ.calc_id = civv.calc_id
				'+@join_type+' invoice_cash_received icr on icr.save_invoice_detail_id = civ.calc_detail_id
				LEFT JOIN static_data_value sdv ON sdv.value_id = civ.invoice_line_item_id
				OUTER APPLY(SELECT ngdc.source_contract_id contract_id FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
						INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_id WHERE ngd.netting_group_id=civv.netting_group_id
						AND civv.prod_date BETWEEN ISNULL(ng.effective_date,''1900-01-01'') AND ISNULL(ng.end_date,''9999-01-01'')
					) netting_group	
				LEFT JOIN contract_group cg ON cg.contract_id =  ISNULL(netting_group.contract_id,civv.contract_id)	
				INNER JOIN dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''') ci ON ci.item = CAST(civv.counterparty_id AS VARCHAR(100)) 
				INNER JOIN contract_group_detail cgd ON cg.contract_id = cgd.contract_id AND civ.invoice_line_item_id = cgd.invoice_line_item_id AND cgd.hideInInvoice = ''s'' 
				LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cgd.alias
			   WHERE 1=1 
			   AND civ.finalized = ''y'' AND civ.value <> 0
			   ' 
			   + CASE WHEN @type_rp = 'r' THEN ' AND civv.invoice_type = ''i''' ELSE ' AND civv.invoice_type = ''r''' END    
			   
			   + CASE 
				   WHEN (@type_cash = 'a') 
				   THEN ' AND icr.id IS NOT NULL AND (settle_status = ''s'' OR settle_status = ''o'') '
			          
				   WHEN (@type_cash = 'v') 
				   THEN ' AND icr.id IS NOT NULL AND settle_status = ''o'''
			          
				   ELSE 'AND icr.id IS NULL AND civ.apply_cash_calc_detail_id IS NULL '
				 END
			   
			  IF @invoice_number <> NULL OR @invoice_number <> ''
				  SET @sql = @sql + ' AND invoice_number = ''' + CAST(@invoice_number AS VARCHAR) + ''''
			  
			  IF @contract_id<>null or @contract_id<>''
			   SET @sql = @sql + ' AND cg.contract_id = ' + CAST(@contract_id AS VARCHAR) + ''

			   IF @commodity <> NULL OR @commodity <> ''
					  SET @sql = @sql + ' AND cg.commodity = ''' + CAST(@commodity AS VARCHAR) + ''''
			    
			  IF @invoice_due_date <> NULL OR @invoice_due_date <> ''
				  SET @sql = @sql + ' AND dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE())), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days)) = ''' + @invoice_due_date + ''''
			  
			  IF @production_month_to <> NULL OR @production_month_to <> ''
				  SET @sql = @sql + ' AND civv.prod_date <= ''' + @production_month_to + ''''
			  
			  SET @sql = @sql + 'GROUP BY civv.invoice_number,COALESCE(cgd.alias, civ.invoice_line_item_id), COALESCE(sdv1.description, sdv.description), dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE())), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days)),dbo.FNAGetContractMonth(civv.prod_date) '
			  --SET  @sql = @sql + 'ORDER BY dbo.FNAGetContractMonth(dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE()), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days)))), sum_amount '


	IF @show_option = 'p'
	BEGIN
	SET @sql = @sql + '
			UNION ALL
			SELECT 
				civv.invoice_number [invoice_number],
				''Variance '' + DATENAME(MONTH, civv.prod_date) + '' '' + DATENAME(YEAR, civv.prod_date) [charge_type],
				MAX(dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE()), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days)))) AS [invoice_due_date], 
				CASE 
						WHEN (MAX(sdv1.description) IS NULL) THEN (MAX(dbo.FNARemoveTrailingZero(CONVERT(DECIMAL(18, 7), ROUND(civ.value, 2)))))
						ELSE SUM(ROUND(civ.value, 2)) 
				END -
				CASE 
						WHEN (MAX(sdv1.description) IS NULL) THEN (MAX(dbo.FNARemoveTrailingZero(CONVERT(DECIMAL(18, 7), ROUND(cash_received, 2)))))
						ELSE SUM(ROUND(cash_received, 2)) 
				END - 
				ISNULL(MAX(write_off.value),0) [sum_amount]
					
			FROM
				source_counterparty sc
				OUTER APPLY(SELECT MAX(as_of_date) as_of_date,prod_date,counterparty_id,contract_id FROM calc_invoice_volume_variance 
					WHERE counterparty_id=sc.source_counterparty_id '
					+ CASE WHEN  @prior_prod_month IS NOT NULL THEN ' 
					AND prod_date BETWEEN  ''1900-01-01'' and ''' + ISNULL(@prior_prod_month_to, @prior_prod_month) + '''' ELSE '' END +' GROUP BY prod_date,counterparty_id,contract_id) a
				INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=a.counterparty_id AND civv.contract_id=a.contract_id AND civv.prod_date=a.prod_date AND civv.as_of_date=a.as_of_date
				INNER JOIN calc_invoice_volume civ ON civ.calc_id = civv.calc_id
				LEFT JOIN static_data_value sdv ON sdv.value_id = civ.invoice_line_item_id				
				OUTER APPLY(SELECT ngdc.source_contract_id contract_id FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
					INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_id WHERE ngd.netting_group_id=civv.netting_group_id
					AND civv.prod_date BETWEEN ISNULL(ng.effective_date,''1900-01-01'') AND ISNULL(ng.end_date,''9999-01-01'')
				) netting_group	
				LEFT JOIN contract_group cg ON cg.contract_id =  ISNULL(netting_group.contract_id,civv.contract_id)	
				INNER JOIN dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''') ci ON ci.item = CAST(civv.counterparty_id AS VARCHAR(100)) 
				INNER JOIN contract_group_detail cgd ON cg.contract_id = cgd.contract_id AND civ.invoice_line_item_id = cgd.invoice_line_item_id AND cgd.hideInInvoice = ''s'' 
				LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cgd.alias
				LEFT JOIN invoice_cash_received icr on icr.save_invoice_detail_id = civ.calc_detail_id
				CROSS APPLY (
					SELECT SUM(a_civ.value) [value] FROM calc_invoice_volume a_civ WHERE a_civ.apply_cash_calc_detail_id = civ.calc_detail_id
				) write_off
				WHERE 1=1 
				AND civ.value <> 0
				AND icr.id IS NOT NULL 
				'
				   
				+ CASE WHEN @show_prepay = 'y' THEN ' AND ISNULL(civ.finalized,''n'') = ''n''' ELSE ' AND ISNULL(civ.finalized,''n'') = ''y''' END    
				    
				+ CASE WHEN @type_rp = 'r' THEN ' AND civv.invoice_type = ''i''' ELSE ' AND civv.invoice_type = ''r''' END		
				  
				IF @invoice_number <> NULL OR @invoice_number <> ''
					SET @sql = @sql + ' AND invoice_number = ''' + CAST(@invoice_number AS VARCHAR) + ''''				 
				  
				IF @contract_id<>null or @contract_id<>''
				SET @sql = @sql + ' AND cg.contract_id = ' + CAST(@contract_id AS VARCHAR) + ''

				IF @commodity <> NULL OR @commodity <> ''
					  SET @sql = @sql + ' AND cg.commodity = ''' + CAST(@commodity AS VARCHAR) + ''''
				    
				IF @invoice_due_date <> NULL OR @invoice_due_date <> ''
					SET @sql = @sql + ' AND dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE())), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days)) = ''' + @invoice_due_date + ''''
				  
				IF @prior_prod_month_to <> NULL OR @prior_prod_month_to <> ''
					SET @sql = @sql + ' AND civv.prod_date <= ''' + @prior_prod_month_to + ''''
					  
				SET @sql = @sql + 'GROUP BY civv.prod_date, ISNULL(sdv1.description,sdv.description) 	,civ.calc_id,COALESCE(cgd.alias, civ.invoice_line_item_id), civv.prod_date, civv.settlement_date, civv.invoice_number '
	END
	
	SET @sql = @sql + ' 
	DELETE FROM #temp_min_grid WHERE sum_amount = 0

	DECLARE @row_count_for_min INT 
	SET @row_count_for_min  = (SELECT count(*) FROM #temp_min_grid)
	DECLARE @counter INT = 1
	DECLARE @cmp_amount NUMERIC(18,7) = ' + @amount + '
	DECLARE @min_combination Table(invoice_number VARCHAR(100),charge_type VARCHAR(500), invoice_due_date DATETIME, sum_amount FLOAT)
	
	;WITH CTE AS (
		SELECT *, ROW_NUMBER () OVER (ORDER BY sum_amount) row_id, -1 sign_order FROM #temp_min_grid WHERE sum_amount >= 0 
	), CTE2 AS (
		SELECT *, ROW_NUMBER () OVER (ORDER BY sum_amount DESC) row_id, 1 sign_order  FROM #temp_min_grid WHERE sum_amount < 0 
	)
	
	SELECT invoice_number,charge_type, invoice_due_date, sum_amount, sign_order, row_id 
	INTO #temp_grid_pay
	FROM 
	(SELECT * FROM CTE
	UNION 
	SELECT * FROM CTE2) a
	ORDER BY invoice_due_date, sign_order desc, row_id
	
	DECLARE @temp_sum_amount NUMERIC(18,7)
	
	WHILE @counter <= @row_count_for_min
	BEGIN
		IF (''r'' = ''' + @type_rp + ''')
		BEGIN
			SET @temp_sum_amount = (SELECT TOP(1) sum_amount FROM #temp_min_grid ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sum_amount) 
			IF (@temp_sum_amount < @cmp_amount)
			BEGIN

				INSERT INTO @min_combination (invoice_number,charge_type, invoice_due_date, sum_amount) 
					SELECT TOP(1) invoice_number,charge_type, invoice_due_date,
					 CASE WHEN  @counter = @row_count_for_min THEN @cmp_amount ELSE sum_amount END
						FROM  #temp_min_grid 
					ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sum_amount 
				SET @cmp_amount = @cmp_amount - @temp_sum_amount
				DELETE FROM #temp_min_grid WHERE charge_type = (SELECT top(1) charge_type FROM #temp_min_grid ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sum_amount)  AND invoice_due_date = (SELECT top(1) invoice_due_date FROM #temp_min_grid ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sum_amount)
						AND invoice_number = (SELECT top(1) invoice_number FROM #temp_min_grid ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sum_amount) 
			END
			ELSE
			BEGIN
				INSERT INTO @min_combination (invoice_number,charge_type, invoice_due_date, sum_amount) 
					SELECT TOP(1) invoice_number,charge_type, invoice_due_date, @cmp_amount 
						FROM  #temp_min_grid 
					ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sum_amount 
				SET @cmp_amount = 0
				DELETE FROM #temp_min_grid WHERE charge_type = (SELECT top(1) charge_type FROM #temp_min_grid ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sum_amount)  AND invoice_due_date = (SELECT top(1) invoice_due_date FROM #temp_min_grid ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sum_amount)
					AND invoice_number = (SELECT top(1) invoice_number FROM #temp_min_grid ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sum_amount)
				BREAK
			END
			SET @counter = @counter + 1
		END
		ELSE
		BEGIN
			SET @temp_sum_amount = (SELECT TOP(1) sum_amount FROM #temp_grid_pay ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sign_order, row_id)
			IF (@temp_sum_amount > @cmp_amount)
			BEGIN

				
				INSERT INTO @min_combination (invoice_number,charge_type, invoice_due_date, sum_amount) 
					SELECT TOP(1) invoice_number,charge_type, invoice_due_date, 
					 CASE WHEN  @counter = @row_count_for_min THEN @cmp_amount ELSE sum_amount END  
						FROM  #temp_grid_pay 
					ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sign_order, row_id
				SET @cmp_amount = @cmp_amount - @temp_sum_amount
				DELETE FROM #temp_grid_pay WHERE charge_type = (SELECT top(1) charge_type FROM #temp_grid_pay ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sign_order, row_id) AND invoice_due_date = (SELECT top(1) invoice_due_date FROM #temp_grid_pay ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sign_order, row_id)
					AND invoice_number = (SELECT top(1) invoice_number FROM #temp_grid_pay ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sign_order, row_id)
			END
			ELSE
			BEGIN
				INSERT INTO @min_combination (invoice_number,charge_type, invoice_due_date, sum_amount) 
					SELECT TOP(1) invoice_number,charge_type, invoice_due_date, @cmp_amount 
						FROM  #temp_grid_pay 
					ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sign_order, row_id
				SET @cmp_amount = 0
				DELETE FROM #temp_grid_pay WHERE charge_type = (SELECT TOP(1) charge_type FROM #temp_grid_pay ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sign_order, row_id) AND invoice_due_date = (SELECT top(1) invoice_due_date FROM #temp_grid_pay ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sign_order, row_id)
					AND invoice_number = (SELECT top(1) invoice_number FROM #temp_grid_pay ORDER BY year(invoice_due_date), month(invoice_due_date),day(invoice_due_date), sign_order, row_id)
				BREAK
			END
			SET @counter = @counter + 1		
		END
	END
	SELECT sum_amount, invoice_due_date [Invoice Due Date], charge_type [Id],invoice_number [Invoice_Number] FROM @min_combination ORDER BY invoice_due_date
	'
	--PRINT(@sql)
	EXEC(@sql)
END

IF @flag = 'n' -- For Combination of line item
BEGIN
	SET @sql = '
			SELECT 
				CAST(civ.calc_detail_id AS VARCHAR(MAX)) [Inv_id],
				COALESCE(sdv1.description, sdv.description) [charge_type],
				dbo.FNAGetContractMonth(civv.prod_date) [production_month],
				COALESCE(dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE()), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days))),dbo.FNAGetContractMonth(civv.prod_date)) AS [invoice_due_date],	
				CAST(dbo.FNARemoveTrailingZero(CONVERT(decimal(18,7),ROUND(civ.value, 2 ))) AS FLOAT) [sum_amount]	
			INTO #temp_line_grid
			FROM
				source_counterparty sc
					OUTER APPLY(SELECT MAX(as_of_date) as_of_date,prod_date,counterparty_id,contract_id FROM calc_invoice_volume_variance 
						WHERE counterparty_id=sc.source_counterparty_id '
						+ CASE WHEN  @production_month IS NOT NULL THEN ' 
						AND prod_date BETWEEN  ''' + @production_month + ''' and ''' + ISNULL(@production_month_to, @production_month) + '''' ELSE '' END +' GROUP BY prod_date,counterparty_id,contract_id) a
					INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=a.counterparty_id AND civv.contract_id=a.contract_id AND civv.prod_date=a.prod_date AND civv.as_of_date=a.as_of_date
					INNER JOIN calc_invoice_volume civ ON civ.calc_id = civv.calc_id
					'+@join_type+' invoice_cash_received icr on icr.save_invoice_detail_id = civ.calc_detail_id
					LEFT JOIN static_data_value sdv ON sdv.value_id = civ.invoice_line_item_id
					OUTER APPLY(SELECT ngdc.source_contract_id contract_id FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
						INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_id WHERE ngd.netting_group_id=civv.netting_group_id
						AND civv.prod_date BETWEEN ISNULL(ng.effective_date,''1900-01-01'') AND ISNULL(ng.end_date,''9999-01-01'')
					) netting_group	
				LEFT JOIN contract_group cg ON cg.contract_id =  ISNULL(netting_group.contract_id,civv.contract_id)	
					INNER JOIN dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''') ci ON ci.item = CAST(civv.counterparty_id AS VARCHAR(100)) 
					INNER JOIN contract_group_detail cgd ON cg.contract_id = cgd.contract_id AND civ.invoice_line_item_id = cgd.invoice_line_item_id AND cgd.hideInInvoice = ''s'' 
					LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cgd.alias
				   WHERE 1=1 
				   AND civ.finalized = ''y'' AND civ.value <> 0
				   '
		+ CASE WHEN @type_rp = 'r' THEN ' AND civv.invoice_type = ''i''' ELSE ' AND civv.invoice_type = ''r''' END	
		
		+ CASE 
			   WHEN (@type_cash = 'a') 
			   THEN ' AND icr.id IS NOT NULL AND (settle_status = ''s'' OR settle_status = ''o'') '
		       
			   WHEN (@type_cash = 'v') 
			   THEN ' AND icr.id IS NOT NULL AND settle_status = ''o'''
		       
			   ELSE 'AND icr.id IS NULL AND civ.apply_cash_calc_detail_id IS NULL '
		  END
		  		
		IF @invoice_number <> NULL OR @invoice_number <> ''
		    SET @sql = @sql + ' AND invoice_number = ''' + CAST(@invoice_number AS VARCHAR) + ''''
		
		IF @contract_id<>null or @contract_id<>''
			SET @sql = @sql + ' AND cg.contract_id = ' + CAST(@contract_id AS VARCHAR) + ''

			IF @commodity <> NULL OR @commodity <> ''
					  SET @sql = @sql + ' AND cg.commodity = ''' + CAST(@commodity AS VARCHAR) + ''''
				
		IF @invoice_due_date <> NULL OR @invoice_due_date <> ''
		    SET @sql = @sql + ' AND dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE())), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days)) = ''' + @invoice_due_date + ''''
		
		IF @production_month_to <> NULL OR @production_month_to <> ''
		    SET @sql = @sql + ' AND civv.prod_date <= ''' + @production_month_to + ''''
		    
	SET  @sql = @sql + 'ORDER BY dbo.FNAGetContractMonth(dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE()), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days)))),CAST(dbo.FNARemoveTrailingZero(CONVERT(decimal(18,7),ROUND(civ.value, 2 ))) AS FLOAT) '
	
	
	SET @sql = @sql + 'SELECT Inv_id, charge_type, invoice_due_date, sum_amount INTO #temp_grid_rec
						FROM #temp_line_grid 
						WHERE charge_type = ''' + @charge_type + ''''
	IF @invoice <> NULL OR @invoice <> ''
		SET @sql = @sql + ' AND invoice_due_date = ''' + CONVERT(VARCHAR(20), @invoice, 23)+ ''''
	IF @production <> NULL OR @production <> ''
		SET @sql = @sql + ' AND production_month = ''' + CONVERT(VARCHAR(20), @production, 23)+ ''''
		
		SET @sql = @sql + ' ORDER BY invoice_due_date, sum_amount'
	
	SET @sql = @sql + '
	DECLARE @row_count_for_line_item INT
	DECLARE @counter INT = 1
	DECLARE @cmp_amount NUMERIC(18,7) = ' + @amount + '
	SET @row_count_for_line_item  = (SELECT count(*) FROM #temp_grid_rec)
	DECLARE @line_item_combination Table( Inv_id VARCHAR(MAX), sum_amount FLOAT)
	
	;WITH CTE AS (
		SELECT *, ROW_NUMBER () OVER (ORDER BY sum_amount) row_id, -1 sign_order FROM #temp_grid_rec WHERE sum_amount >= 0 
	), CTE2 AS (
		SELECT *, ROW_NUMBER () OVER (ORDER BY sum_amount DESC) row_id, 1 sign_order  FROM #temp_grid_rec WHERE sum_amount < 0 
	)
	
	SELECT inv_id, invoice_due_date, sum_amount,sign_order, row_id 
	INTO #temp_grid_pay
	FROM 
	(SELECT * FROM CTE
	UNION 
	SELECT * FROM CTE2) a
	ORDER BY invoice_due_date, sign_order, row_id
	
	DECLARE @temp_sum_amount NUMERIC(18,7)
	
	WHILE @counter <= @row_count_for_line_item
	BEGIN
		IF (''r'' = ''' + @type_rp + ''')
		BEGIN
			SET @temp_sum_amount = (SELECT TOP(1) sum_amount FROM #temp_grid_rec ORDER BY invoice_due_date, sum_amount) 
			IF (@temp_sum_amount < @cmp_amount)
			BEGIN
				INSERT INTO invoice_cash_received (save_invoice_detail_id, received_date,cash_received,comments,invoice_type,settle_status,variance_amount)
				SELECT TOP(1) Inv_id, ''' + @receive_pay_date + ''', 
						CASE WHEN  @counter = @row_count_for_line_item THEN @cmp_amount ELSE sum_amount END
						, ''' + @comment + ''' , ''r'', ''s'', 0  
					FROM  #temp_grid_rec
					ORDER BY invoice_due_date, sum_amount
				SET @cmp_amount = @cmp_amount - (SELECT TOP(1) sum_amount FROM #temp_grid_rec ORDER BY invoice_due_date, sum_amount) 
				DELETE FROM #temp_grid_rec WHERE Inv_id = (SELECT top(1) Inv_id FROM #temp_grid_rec ORDER BY invoice_due_date, sum_amount)
			END
			ELSE
			BEGIN
				INSERT INTO invoice_cash_received (save_invoice_detail_id, received_date,cash_received,comments,invoice_type,settle_status,variance_amount)
				SELECT TOP(1) Inv_id, ''' + @receive_pay_date + ''', @cmp_amount, ''' + @comment + ''', ''r'', ''o'', sum_amount-@cmp_amount  
					FROM  #temp_grid_rec 
					ORDER BY invoice_due_date, sum_amount
				SET @cmp_amount = 0
				DELETE FROM #temp_grid_rec WHERE Inv_id = (SELECT TOP(1) Inv_id FROM #temp_grid_rec ORDER BY invoice_due_date, sum_amount)
				BREAK
			END
			SET @counter = @counter + 1
		END
		ELSE
		BEGIN
			SET @temp_sum_amount = (SELECT TOP(1) sum_amount FROM #temp_grid_pay ORDER BY invoice_due_date, sign_order, row_id)
			IF (@temp_sum_amount > @cmp_amount)
			BEGIN
				INSERT INTO invoice_cash_received (save_invoice_detail_id, received_date,cash_received,comments,invoice_type,settle_status,variance_amount)
				SELECT TOP(1) Inv_id, ''' + @receive_pay_date + ''', 
						CASE WHEN  @counter = @row_count_for_line_item THEN @cmp_amount ELSE sum_amount END
						, ''' + @comment + ''', ''p'', ''s'', 0  
					FROM  #temp_grid_pay 
					ORDER BY invoice_due_date, sign_order, row_id
				SET @cmp_amount = @cmp_amount - (SELECT TOP(1) sum_amount FROM #temp_grid_pay ORDER BY invoice_due_date, sign_order, row_id) 
				DELETE FROM #temp_grid_pay WHERE Inv_id = (SELECT top(1) Inv_id FROM #temp_grid_pay ORDER BY invoice_due_date, sign_order, row_id)
			END
			ELSE
			BEGIN
				INSERT INTO invoice_cash_received (save_invoice_detail_id, received_date,cash_received,comments,invoice_type,settle_status,variance_amount)
				SELECT TOP(1) Inv_id, ''' + @receive_pay_date + ''', @cmp_amount, ''' + @comment + ''', ''p'', ''o'', sum_amount-@cmp_amount  
					FROM  #temp_grid_pay 
					ORDER BY invoice_due_date, sign_order, row_id
				SET @cmp_amount = 0
				DELETE FROM #temp_grid_pay WHERE Inv_id = (SELECT TOP(1) Inv_id FROM #temp_grid_pay ORDER BY invoice_due_date, sign_order, row_id)
				BREAK
			END
			SET @counter = @counter + 1		
		END
	END	
	'
	--PRINT(@sql)
	EXEC(@sql)
END
