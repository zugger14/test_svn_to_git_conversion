IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_invoice_cash_received]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_invoice_cash_received]
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Description: Received invoice cash
	
	Parameters:
	@flag : Flag 
			'i' insert
			'y'
	@xmltext			 :	xmltext
	@counterparty_id 	 :	counterparty id
	@contract_id 		 :	contract id
	@production_month	 :	production month
	@production_month_to :	production month_to
	@invoice_due_date	 :	invoice due date
	@round_value		 :	round value
	@invoice_number 	 :	invoice number
	@type_rp 			 :	type rp
	@type_cash 			 :	type cash
	@show_prepay 		 :	show prepay
	@show_option		 :	show option
	@commodity			 :	commodity
**/

CREATE procedure [dbo].[spa_invoice_cash_received]
	@flag CHAR(1),
	@xmltext TEXT,
	@counterparty_id VARCHAR(MAX) = NULL,
	@contract_id INT = NULL,
	@production_month VARCHAR(20) = NULL,
	@production_month_to VARCHAR(20) = NULL,
	@invoice_due_date VARCHAR(20) = NULL,
	@round_value CHAR(1) = '0',
	@invoice_number VARCHAR(100) = NULL,
	@type_rp CHAR(1) = 'r', --radio recieve/pay
	@type_cash CHAR(1) = 'n', --radio type/cash
	@show_prepay CHAR(1) = NULL,
	@show_option CHAR(1) = NULL,
	@commodity INT = NULL
AS

SET NOCOUNT ON 

DECLARE @idoc INT
DECLARE @doc VARCHAR(1000)
DECLARE @sqlStmt1 VARCHAR(5000)
DECLARE @sqlStmt2 VARCHAR(5000)
DECLARE @sql VARCHAR(8000)
DECLARE @sqlStmt3 VARCHAR(5000)
DECLARE @receive_pay_date DATETIME

/* --this logic is to collect the individual data using the contract charge type */
BEGIN
	IF (@type_cash = 'n')
	BEGIN
		IF OBJECT_ID('tempdb..#charge_type_individual_table') IS NOT NULL
		DROP TABLE #charge_type_individual_table
    
		CREATE TABLE #charge_type_individual_table
		(
    		invoice_number          VARCHAR(100) COLLATE DATABASE_DEFAULT ,
    		production_month        DATETIME ,
    		charge_type             VARCHAR(200) COLLATE DATABASE_DEFAULT ,
    		amount                  FLOAT,
    		cash_received           FLOAT,
    		receive_pay_date        DATETIME ,
    		comments                VARCHAR(500) COLLATE DATABASE_DEFAULT ,
    		save_invoice_detail_id  INT,
    		invoice_due_date        DATETIME ,
    		invoice_date            DATETIME ,
    		calc_id                 INT,
    		as_of_date              DATETIME ,
    		contract_id             INT,
    		[status]                VARCHAR(5) COLLATE DATABASE_DEFAULT ,
    		invoice_type            CHAR(2) COLLATE DATABASE_DEFAULT ,
    		alias                   VARCHAR(200) COLLATE DATABASE_DEFAULT 
		)
	    
		SET @sql = 'INSERT INTO #charge_type_individual_table (invoice_number, production_month, charge_type, amount, cash_received, receive_pay_date, comments, save_invoice_detail_id, invoice_due_date, invoice_date, calc_id, as_of_date, contract_id, [status], invoice_type, alias)
					SELECT 
						civv.invoice_number,
						dbo.FNAGetContractMonth(civv.prod_date) [Production Month],
						sdv.description [Charge Type],
						dbo.FNARemoveTrailingZero(convert(decimal(18,7),ROUND(civ.value, ' + @round_value + '))) [Amount],
						dbo.FNARemoveTrailingZero(convert(decimal(18,7),ROUND(cash_received, ' + @round_value + '))) [Receive/Pay Amount],
						received_date [Receive/Pay Date],
						comments [Comments], 
						civ.calc_detail_id [save_invoice_detail_id],
						dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE()), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days))) AS [Invoice Due Date],	
						civv.settlement_date [Invoice Date],
						civ.calc_id [Calc_id],
						civv.as_of_date [As Of Date],
						civv.contract_id,
						civv.invoice_type,
						civ.status,
						sdv1.description [Alias]	 
					FROM
						source_counterparty sc
						OUTER APPLY(SELECT MAX(as_of_date) as_of_date,prod_date,counterparty_id,contract_id FROM calc_invoice_volume_variance 
							WHERE counterparty_id=sc.source_counterparty_id '
							 + CASE WHEN  @production_month IS NOT NULL THEN ' 
							AND prod_date BETWEEN  ''' + @production_month + ''' and ''' + ISNULL(@production_month_to, @production_month) + '''' ELSE '' END +' GROUP BY prod_date,counterparty_id,contract_id) a
						INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=a.counterparty_id AND civv.contract_id=a.contract_id AND civv.prod_date=a.prod_date AND civv.as_of_date=a.as_of_date
						INNER JOIN calc_invoice_volume civ ON civ.calc_id = civv.calc_id
						LEFT JOIN invoice_cash_received icr on icr.save_invoice_detail_id = civ.calc_detail_id
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
			  
			--SET @sql = @sql +  'select * from #charge_type_individual_table'
			
			--PRINT(@sql)
			EXEC(@sql)	
	END
END

/* till here*/
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmltext
	
	SELECT * INTO #ztbl_xmlvalue
	FROM   OPENXML(@idoc, '/Root/PSRecordset', 2)
	       WITH (
	           invoice_number VARCHAR(100) '@invoice_number',
	           production_month DATETIME '@production_month',
	           charge_type VARCHAR(250) '@charge_type',
	           settlement_value FLOAT '@settlement_value',
	           cash_received FLOAT '@cash_received',
	           comments VARCHAR(100) '@comments',
	           save_invoice_detail_id INT '@save_invoice_detail_id',
	           variance FLOAT '@variance',
	           received_date DATETIME '@received_date',
	           invoice_due_date DATETIME '@invoice_due_date',
	           invoice_date DATETIME '@invoice_date',
			   is_adjustment CHAR(1) '@is_adjustment',
			   calc_id INT '@calc_id',
			   invoice_line_item_id INT '@invoice_line_item_id'
	       )

	IF (@type_cash = 'n')
	BEGIN
		 SET @sqlStmt3 = '
			 INSERT INTO invoice_cash_received
			  (
				save_invoice_detail_id,
				cash_received,
				comments,
				invoice_type,
				settle_status,
				received_date,
				variance_amount
			  )
			SELECT t.save_invoice_detail_id,
				   t.amount,
				   b.comments,
				   CASE WHEN settlement_value < 0 THEN ''p'' else ''r'' END,
				   CASE WHEN variance=0 THEN ''s'' else ''o'' END,
				   b.received_date,
				   0 
			FROM #ztbl_xmlvalue b 
			INNER JOIN #charge_type_individual_table t ON LTRIM(COALESCE(t.alias, t.charge_type)) = LTRIM(b.charge_type) AND b.invoice_number = t.invoice_number
			WHERE b.settlement_value = b.cash_received AND t.save_invoice_detail_id not in (select save_invoice_detail_id from invoice_cash_received)
			AND ISNULL(b.production_month, '''') = ISNULL(t.production_month, '''')	
			AND b.invoice_due_date = ISNULL(t.invoice_due_date, '''') 
			AND ISNULL(b.invoice_date, '''') = ISNULL(t.invoice_date, '''')	
		'
		--PRINT (@sqlStmt3)	
		EXEC(@sqlStmt3)
	    
		DECLARE @charge_type1 VARCHAR(100), @invoice_due_date_from_combination DATETIME, @production_date_from_combination DATETIME, @cash_received_from_combination NUMERIC(32,2), @comments VARCHAR(200)
		DECLARE @is_adjustment CHAR(1), @save_invoice_detail_id INT, @calc_id INT, @invoice_line_item_id INT, @org_prod_month DATETIME
		DECLARE @inv_prod_month DATETIME, @uom_id INT
		--SET @charge_type1 = (SELECT charge_type FROM  #ztbl_xmlvalue WHERE variance <> 0)
		--SET @invoice_due_date_from_combination = (SELECT invoice_due_date FROM  #ztbl_xmlvalue WHERE variance <> 0)
		--SET @production_date_from_combination = (SELECT production_month FROM #ztbl_xmlvalue WHERE variance <> 0 )
		--SET @cash_received_from_combination = (SELECT cash_received FROM #ztbl_xmlvalue WHERE variance != 0)
		--SET @comments = (SELECT comments FROM #ztbl_xmlvalue WHERE variance <> 0)
		
		IF (@type_rp = 'p')
		BEGIN
			SET	 @cash_received_from_combination = CAST((CAST(@cash_received_from_combination AS NUMERIC(32, 2)) * -1) AS VARCHAR(MAX))
		END
		ELSE
		BEGIN
			SET	 @cash_received_from_combination = CAST(CAST(@cash_received_from_combination AS NUMERIC(32, 2)) AS VARCHAR(MAX))
		END

		
	
		/*insert logic on variance != 0 */   
		--IF EXISTS(SELECT 1 FROM #ztbl_xmlvalue WHERE variance != 0)
		--SELECT * FROM #ztbl_xmlvalue
		DECLARE cursor_tbl CURSOR FOR
		
		SELECT invoice_number, charge_type,invoice_due_date,production_month,
			 CASE WHEN @type_rp = 'p' THEN CAST((CAST(cash_received AS NUMERIC(32, 2)) * -1) AS VARCHAR(MAX)) ELSE CAST(CAST(cash_received AS NUMERIC(32, 2)) AS VARCHAR(MAX)) END
			, comments
			, is_adjustment
			, save_invoice_detail_id
			, calc_id
			, invoice_line_item_id
			, production_month
			, received_date
			FROM #ztbl_xmlvalue WHERE variance <> 0 OR is_adjustment = 'y'
		
		OPEN cursor_tbl
		FETCH NEXT FROM cursor_tbl INTO @invoice_number, @charge_type1,@invoice_due_date_from_combination,@production_date_from_combination,@cash_received_from_combination, @comments, @is_adjustment, @save_invoice_detail_id, @calc_id, @invoice_line_item_id, @org_prod_month, @receive_pay_date
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @is_adjustment = 'y'
			BEGIN
				SELECT @inv_prod_month = ISNULL(prod_date,@org_prod_month)  FROM Calc_invoice_Volume_variance

				SELECT @uom_id = volume_uom FROM contract_group
				WHERE contract_id = (SELECT contract_id FROM Calc_invoice_Volume_variance WHERE calc_id = @calc_id)

				EXEC spa_calc_invoice_volume_input  @flag='i',
													@calc_id=@calc_id, 
													@invoice_line_item_id=@invoice_line_item_id, 
													@value= @cash_received_from_combination,
													@volume='', 
													@finalized='y', 
													@include_volume='n', 
													@remarks='', 
													@apply_cash_calc_detail_id=@save_invoice_detail_id, 
													@inventory='n', 
													@prod_date= @org_prod_month, 
													@as_of_date= @production_month_to,
													@inv_prod_date= @inv_prod_month,
													@default_gl_id='', 
													@uom_id=@uom_id, 
													@sub_id=@calc_id, 
													@default_gl_id_estimate='',
													@is_adjustment_entry = 'y'

				UPDATE invoice_cash_received
				SET settle_status = 's'
				WHERE save_invoice_detail_id = @save_invoice_detail_id
			END
			ELSE 
			BEGIN
				EXEC spa_apply_cash_combination 'n',
					 @counterparty_id,
					 @invoice_number,
					 @production_month,
					 NULL, --save_invoice_calc_id
					 @type_cash,
					 @type_rp,
					 @contract_id, 
					 @round_value,
					 @receive_pay_date, --for recieve/Pay date  
					 @production_month_to,
					 @invoice_due_date,
					 @cash_received_from_combination, --@amount	
					 'n',
					 @charge_type1,
					 @invoice_due_date_from_combination,
					 @production_date_from_combination,
					 @comments,
					 @is_adjustment,
					 @show_prepay,
					 @show_option
			END
		
			FETCH NEXT FROM cursor_tbl INTO @invoice_number, @charge_type1,@invoice_due_date_from_combination,@production_date_from_combination,@cash_received_from_combination, @comments, @is_adjustment, @save_invoice_detail_id, @calc_id, @invoice_line_item_id, @org_prod_month, @receive_pay_date
		END
		CLOSE cursor_tbl
		DEALLOCATE cursor_tbl
		
	END	
	IF (@type_cash = 'v')
	BEGIN
		SET @sqlStmt1 = ' UPDATE  invoice_cash_received
						  SET  
							invoice_cash_received.cash_received= NULLIF(B.cash_received, NULL),
							invoice_cash_received.comments = NULLIF(B.comments,''NULL''),
							invoice_cash_received.variance_amount = A.variance_amount,
							invoice_type=CASE WHEN settlement_value<0 THEN ''p'' else ''r'' END, ' +
							CASE WHEN @flag = 'y' THEN 'settle_status=CASE WHEN B.variance=0 THEN ''s'' else ''o'' END,'
							ELSE
							'settle_status=CASE WHEN B.variance=0 THEN ''s'' else ''o'' END,' END 
							
						  SET @sqlStmt1 = @sqlStmt1	+ 'received_date = B.received_date		
						  FROM invoice_cash_received A
						  INNER JOIN #ztbl_xmlvalue B ON A.save_invoice_detail_id = B.save_invoice_detail_id
				 	    '	
	END
		
	--PRINT (@sqlStmt1)	
	EXEC(@sqlStmt1)

	EXEC spa_ErrorHandler 0,
	     "Invoice Entries",
	     "spa_invoice_cash_received",
	     "Status",
	     "Changes have been saved successfully.",
	     "Recommendation"
