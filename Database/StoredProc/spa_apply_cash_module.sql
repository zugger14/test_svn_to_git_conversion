/****** Object:  StoredProcedure [dbo].[spa_apply_cash_module]    Script Date: 12/21/2012 14:39:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_apply_cash_module]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_apply_cash_module]
GO
/****** Object:  StoredProcedure [dbo].[spa_apply_cash_module]    Script Date: 6/20/2017 10:54:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_apply_cash_module]
	@flag CHAR(1),
	@counterparty_id VARCHAR(MAX),
	@invoice_number VARCHAR(50) = NULL,
	@production_month VARCHAR(20) = NULL,
	@save_invoice_detail_id VARCHAR(MAX) = NULL,
	@type_cash CHAR(1) = 'n', -- 'n' for cash not applied. 'a' for cash applied and 'v' for variance only 
	@type CHAR(1) = 'r',
	@contract_id INT = NULL,
	@round_value CHAR(2) = '0',
	@receive_pay_date VARCHAR(20) = NULL,
	@production_month_to VARCHAR(20) = NULL,
	@invoice_due_date VARCHAR(20) = NULL,
	@show_variance CHAR(2) = 'n', 
	@is_pivot CHAR(1) = NULL,
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


	IF @flag = 's' -- to show on the grid
	BEGIN
		SET @sql = '
			select 
				dbo.FNAHyperLinkText(400,civv.invoice_number,civv.invoice_number) [Invoice Number],
				dbo.FNAGetContractMonth(civv.prod_date) [Production Month],
				sdv.description [Charge Type],
				civ.value [Amount],
				cash_received [Amount Received], 
				dbo.FNAGetContractMonth(received_date) [Received Date], 
				comments [Comments],
				civ.calc_detail_id [save_invoice_detail_id],
				civ.calc_id [Calc_id]
			FROM
				source_counterparty sc
				OUTER APPLY(SELECT MAX(as_of_date) as_of_date,prod_date,counterparty_id,contract_id FROM calc_invoice_volume_variance 
					WHERE counterparty_id=sc.source_counterparty_id '
					+ CASE WHEN  @production_month IS NOT NULL THEN ' 
					AND prod_date = '''+@production_month+'''' ELSE '' END +' GROUP BY prod_date,counterparty_id,contract_id) a
				INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=a.counterparty_id AND civv.contract_id=a.contract_id AND civv.prod_date=a.prod_date AND civv.as_of_date=a.as_of_date
				INNER JOIN dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''') ci ON ci.item = CAST(civv.counterparty_id AS VARCHAR(100)) 
				INNER JOIN calc_invoice_volume civ ON civ.calc_id = civv.calc_id
				'+@join_type+' invoice_cash_received icr on icr.save_invoice_detail_id = civ.calc_detail_id
				LEFT JOIN static_data_value sdv ON sdv.value_id = civ.invoice_line_item_id
			WHERE 1=1 '+
			+ CASE WHEN @type = 'r' THEN ' AND civv.invoice_type = ''i''' ELSE ' AND civv.invoice_type = ''r''' END	
		

			if @invoice_number<>null or @invoice_number<>''
				set @sql = @sql + '
					and invoice_number = '+cast(@invoice_number as varchar)+'
			'
		EXEC(@sql)

	END

	IF @flag = 'u' -- to show in the grid
	 BEGIN
	 	IF (@type_cash = 'n')
 		BEGIN
			DECLARE @prior_prod_month VARCHAR(20) = DATEADD (MM , -1, @production_month )   --'2017-06-01'
			DECLARE @prior_prod_month_to VARCHAR(20) = DATEADD (MM , -1, @production_month_to )

			SET @sql = 'SELECT * FROM ('

			IF @show_option = 'p'
			BEGIN

			SET @sql = @sql + '
				
				SELECT 
					''Total'' [Total],
					civv.invoice_number [SubTotal],
					civv.invoice_number [Invoice Number],
					MAX(sc.counterparty_name) [Counterparty],
					dbo.FNADateformat(dbo.FNAGetContractMonth(civv.prod_date)) [Production Month],
					MAX(dbo.FNADateformat(dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE())), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days)))) AS [Invoice Due Date], 
					dbo.FNADateformat(convert(varchar(10), civv.settlement_date, 120)) [Invoice Date],
					MAX(dbo.FNADateformat(received_date)) [Payment Date],
					''Variance '' + DATENAME(MONTH, civv.prod_date) + '' '' + DATENAME(YEAR, civv.prod_date) [ChargeType],
					CASE 
						 WHEN (MAX(sdv1.description) IS NULL) THEN (MAX(dbo.FNARemoveTrailingZero(CONVERT(DECIMAL(18, 7), ROUND(civ.value, 2)))))
						 ELSE SUM(ROUND(civ.value, 2)) 
					END -
					CASE 
						 WHEN (MAX(sdv1.description) IS NULL) THEN (MAX(dbo.FNARemoveTrailingZero(CONVERT(DECIMAL(18, 7), ROUND(cash_received, 2)))))
						 ELSE SUM(ROUND(cash_received, 2)) 
					END - 
					ISNULL(MAX(write_off.value),0) [Invoice Amount],
					'''' [Amount],
					0 [Variance],
					MAX(comments) [Comments],					 
					MAX(civ.calc_detail_id) [save_invoice_detail_id],
					MAX(civv.contract_id) contract_id,
					MAX(sc.source_counterparty_id) counterparty_id,
					ISNULL(a_calc_id.calc_id,civ.calc_id) [Calc_id],
					MAX(dbo.FNADateformat(civv.as_of_date)) [As Of Date],
					MAX(sdv.value_id) invoice_line_item_id,
					MAX(sc.int_ext_flag) int_ext_flag,
					MAX(civv.invoice_type) invoice_type,
					MAX(icr.settle_status) status,
					''y'' [is_adjustment]					
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
						AND ngdc.source_contract_id =civv.contract_id AND civv.prod_date BETWEEN ISNULL(ng.effective_date,''1900-01-01'') AND ISNULL(ng.end_date,''9999-01-01'')
					) netting_group	
					LEFT JOIN contract_group cg ON cg.contract_id =  ISNULL(netting_group.contract_id,civv.contract_id)	
					INNER JOIN dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''') ci ON ci.item = CAST(civv.counterparty_id AS VARCHAR(100)) 
					INNER JOIN contract_group_detail cgd ON cg.contract_id = cgd.contract_id AND civ.invoice_line_item_id = cgd.invoice_line_item_id AND cgd.hideInInvoice = ''s'' 
					LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cgd.alias
					LEFT JOIN invoice_cash_received icr on icr.save_invoice_detail_id = civ.calc_detail_id
					CROSS APPLY (
						SELECT SUM(a_civ.value) [value] FROM calc_invoice_volume a_civ WHERE a_civ.apply_cash_calc_detail_id = civ.calc_detail_id
					) write_off
					CROSS APPLY (
						SELECT MAX(calc_id) calc_id FROM calc_invoice_volume_variance m_cciv WHERE m_cciv.prod_date = ''' + @production_month + ''' AND m_cciv.counterparty_id = sc.source_counterparty_id AND m_cciv.contract_id = cg.contract_id '
						+ CASE WHEN @type = 'r' THEN ' AND m_cciv.invoice_type = ''i''' ELSE ' AND m_cciv.invoice_type = ''r''' END	+'
					) a_calc_id
				  WHERE 1=1 
				   AND civ.value <> 0
				   AND icr.id IS NOT NULL 
				   '
				   
				   + CASE WHEN @show_prepay = 'y' THEN ' AND ISNULL(civ.finalized,''n'') = ''n''' ELSE ' AND ISNULL(civ.finalized,''n'') = ''y''' END    
				    
				   + CASE WHEN @type = 'r' THEN ' AND civv.invoice_type = ''i''' ELSE ' AND civv.invoice_type = ''r''' END		
				  
				  IF @invoice_number <> NULL OR @invoice_number <> ''
					  SET @sql = @sql + ' AND invoice_number = ''' + CAST(@invoice_number AS VARCHAR) + ''''				 
				  
				  IF @commodity <> NULL OR @commodity <> ''
					  SET @sql = @sql + ' AND cg.commodity = ''' + CAST(@commodity AS VARCHAR) + ''''				 
				  
				  IF @contract_id<>null or @contract_id<>''
				   SET @sql = @sql + ' AND cg.contract_id = ' + CAST(@contract_id AS VARCHAR) + ''
				    
				  IF @invoice_due_date <> NULL OR @invoice_due_date <> ''
					  SET @sql = @sql + ' AND dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE())), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days)) = ''' + @invoice_due_date + ''''
				  
				  IF @prior_prod_month_to <> NULL OR @prior_prod_month_to <> ''
					  SET @sql = @sql + ' AND civv.prod_date <= ''' + @prior_prod_month_to + ''''
					  
				  SET @sql = @sql + 'GROUP BY a_calc_id.calc_id, ISNULL(sdv1.description,sdv.description) 	,civ.calc_id,COALESCE(cgd.alias, civ.invoice_line_item_id), civv.prod_date, civv.settlement_date, civv.invoice_number 
				  
				  UNION ALL
				  '
				END  

			
	 		SET @sql = @sql + '
				SELECT'+CASE WHEN @is_pivot = 'y' THEN '' ELSE '
					''Total'' [Total],
					civv.invoice_number [SubTotal],' END  + '
				    civv.invoice_number [Invoice Number],
					MAX(sc.counterparty_name) [Counterparty],
					dbo.FNADateformat(dbo.FNAGetContractMonth(civv.prod_date)) [Production Month],
					MAX(dbo.FNADateformat(dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE())), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days)))) AS [Invoice Due Date],
					dbo.FNADateformat(convert(varchar(10), civv.settlement_date, 120)) [Invoice Date],
					NULL [Payment Date],
					CASE WHEN (MAX(sdv1.description) IS NULL) THEN (MAX(sdv.description)) ELSE  MAX(sdv1.description) END [ChargeType],
					CASE 
						 WHEN (MAX(sdv1.description) IS NULL) THEN MAX(dbo.FNARemoveTrailingZero(CONVERT(DECIMAL(18, 7), ROUND(ISNULL(ind.invoice_amount, civ.value), 2))))
						 ELSE  SUM(ROUND(ISNULL(ind.invoice_amount,civ.value), 2))
					END [Invoice Amount],
					NULL [Amount],
					MAX(civv.variance) [Variance],
					NULL [Comments],					
					--NULL [Receive/Pay Amount],
					MAX(civ.calc_detail_id) [save_invoice_detail_id],
					MAX(civv.contract_id) [Contract Id],
					MAX(sc.source_counterparty_id) [Counterparty Id],
					MAX(civ.calc_id) [Calc_id],
					MAX(dbo.FNADateformat(civv.as_of_date)) [As Of Date],
					MAX(sdv.value_id) [Invoice Line Item Id],
					MAX(sc.int_ext_flag) [Int Ext Flag],
					MAX(civv.invoice_type) [Invoice Type],
					MAX(civ.status) [Status],
					''n'' [is_adjustment]
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
						AND ngdc.source_contract_id =civv.contract_id AND civv.prod_date BETWEEN ISNULL(ng.effective_date,''1900-01-01'') AND ISNULL(ng.end_date,''9999-01-01'')
					) netting_group			
					LEFT JOIN contract_group cg ON cg.contract_id =  ISNULL(netting_group.contract_id,civv.contract_id)	
					INNER JOIN contract_group_detail cgd ON cg.contract_id = cgd.contract_id AND civ.invoice_line_item_id = cgd.invoice_line_item_id AND cgd.hideInInvoice = ''s'' 
					INNER JOIN dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''') ci ON ci.item = CAST(civv.counterparty_id AS VARCHAR(100)) 
					LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cgd.alias
					LEFT JOIN invoice_header ih ON ih.counterparty_id=civv.counterparty_id
								AND ih.contract_id=civv.contract_id
								AND ih.Production_month=civv.prod_date
								AND civv.invoice_type = ''r''
					OUTER APPLY(SELECT SUM(ind.invoice_amount) invoice_amount, MAX(ind.invoice_due_date) invoice_due_date FROM invoice_detail ind WHERE ind.invoice_id = ih.invoice_id AND ind.invoice_line_item_id=civ.invoice_line_item_id ) ind
					 WHERE 1=1 
				   AND civ.value <> 0
				   ' 
				   + CASE WHEN @show_prepay = 'y' THEN ' AND ISNULL(civ.finalized,''n'') = ''n''' ELSE ' AND ISNULL(civ.finalized,''n'') = ''y''' END    

				   + CASE WHEN @type = 'r' THEN ' AND civv.invoice_type = ''i''' ELSE ' AND civv.invoice_type = ''r''' END    
				   
				   + CASE 
					   WHEN (@type_cash = 'a') 
					   THEN ' AND icr.id IS NOT NULL AND (settle_status = ''s'' OR settle_status = ''o'') '
				          
					   WHEN (@type_cash = 'v') 
					   THEN ' AND icr.id IS NOT NULL AND settle_status = ''o'''
				          
					   ELSE 'AND icr.id IS NULL AND civ.apply_cash_calc_detail_id IS NULL '
					 END
				
				  IF @invoice_number <> NULL OR @invoice_number <> ''
					  SET @sql = @sql + ' AND invoice_number = ''' + CAST(@invoice_number AS VARCHAR) + ''''

				  IF @commodity <> NULL OR @commodity <> ''
					  SET @sql = @sql + ' AND cg.commodity = ''' + CAST(@commodity AS VARCHAR) + ''''
				  
				  IF @contract_id<>null or @contract_id<>''
				   SET @sql = @sql + ' AND cg.contract_id = ' + CAST(@contract_id AS VARCHAR) + ''
				    
				  IF @invoice_due_date <> NULL OR @invoice_due_date <> ''
					  SET @sql = @sql + ' AND dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE())), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days)) = ''' + @invoice_due_date + ''''
				  
				  IF @production_month_to <> NULL OR @production_month_to <> ''
					  SET @sql = @sql + ' AND civv.prod_date <= ''' + @production_month_to + ''''
				  
				  BEGIN
					SET @sql = @sql + ' GROUP BY COALESCE(cgd.alias, civ.invoice_line_item_id), civv.prod_date, civv.settlement_date, civv.invoice_number '			  	
					SET @sql = @sql + '
					) a WHERE a.[Invoice Amount] <> 0
					ORDER BY a.[Invoice Amount]'					
				  END
			  --PRINT(@sql)
			  EXEC(@sql) 
 		END
 		IF (@type_cash <> 'n')
 		BEGIN
 			SET @sql = '
				SELECT 
					''Total'' [Total],
					civv.invoice_number [SubTotal],
					civv.invoice_number [Invoice Number],
					MAX(sc.counterparty_name) [Counterparty],
					dbo.FNADateformat(dbo.FNAGetContractMonth(civv.prod_date)) [Production Month],
					MAX(dbo.FNADateformat(dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE())), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days)))) AS [Invoice Due Date], 
					dbo.FNADateformat(convert(varchar(10), civv.settlement_date, 120)) [Invoice Date],
					MAX(dbo.FNADateformat(received_date)) [Payment Date],
					ISNULL(sdv1.description,sdv.description) [ChargeType],
					CASE 
						 WHEN (MAX(sdv1.description) IS NULL) THEN MAX(dbo.FNARemoveTrailingZero(CONVERT(DECIMAL(18, 7), ROUND(ISNULL(ind.invoice_amount, civ.value), 2))))
						 ELSE  SUM(ROUND(ISNULL(ind.invoice_amount,civ.value), 2))
					END [Invoice Amount],
					CASE 
						 WHEN (MAX(sdv1.description) IS NULL) THEN (MAX(dbo.FNARemoveTrailingZero(CONVERT(DECIMAL(18, 7), ROUND(cash_received, 2)))))
						 ELSE SUM(ROUND(cash_received, 2)) 
					END [Amount],
					0 [Variance],
					MAX(comments) [Comments],					 
					MAX(civ.calc_detail_id) [save_invoice_detail_id],
					MAX(civv.contract_id) contract_id,
					MAX(sc.source_counterparty_id) counterparty_id,
					civ.calc_id [Calc_id],
					MAX(dbo.FNADateformat(civv.as_of_date)) [As Of Date],
					MAX(sdv.value_id) invoice_line_item_id,
					MAX(sc.int_ext_flag) int_ext_flag,
					MAX(civv.invoice_type) invoice_type,
					MIN(icr.settle_status) status,
					MAX(civv.netting_group_id) netting_group_id,
					MAX(cgd.alias) group_id,
					MAX(civv.prod_date) prod_date
				INTO 
					#temp_items	
			   FROM
					source_counterparty sc
					OUTER APPLY(SELECT MAX(as_of_date) as_of_date,prod_date,counterparty_id,contract_id FROM calc_invoice_volume_variance 
					 WHERE counterparty_id=sc.source_counterparty_id '
					 + CASE WHEN  @production_month IS NOT NULL THEN ' 
					 AND prod_date BETWEEN  ''' + @production_month + ''' and ''' + ISNULL(@production_month_to, @production_month) + '''' ELSE '' END +' GROUP BY prod_date,counterparty_id,contract_id) a
					INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=a.counterparty_id AND civv.contract_id=a.contract_id AND civv.prod_date=a.prod_date AND civv.as_of_date=a.as_of_date
					INNER JOIN calc_invoice_volume civ ON civ.calc_id = civv.calc_id
					LEFT JOIN static_data_value sdv ON sdv.value_id = civ.invoice_line_item_id				
					OUTER APPLY(SELECT ngdc.source_contract_id contract_id FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
						INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_id WHERE ngd.netting_group_id=civv.netting_group_id
						AND ngdc.source_contract_id =civv.contract_id AND civv.prod_date BETWEEN ISNULL(ng.effective_date,''1900-01-01'') AND ISNULL(ng.end_date,''9999-01-01'')
					) netting_group	
					LEFT JOIN contract_group cg ON cg.contract_id =  ISNULL(netting_group.contract_id,civv.contract_id)	
					INNER JOIN dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''') ci ON ci.item = CAST(civv.counterparty_id AS VARCHAR(100)) 
					INNER JOIN contract_group_detail cgd ON cg.contract_id = cgd.contract_id AND civ.invoice_line_item_id = cgd.invoice_line_item_id AND cgd.hideInInvoice = ''s'' 
					LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cgd.alias
					LEFT JOIN invoice_cash_received icr on icr.save_invoice_detail_id = civ.calc_detail_id
					LEFT JOIN invoice_header ih ON ih.counterparty_id=civv.counterparty_id
								AND ih.contract_id=civv.contract_id
								AND ih.Production_month=civv.prod_date
								AND civv.invoice_type = ''r''
					OUTER APPLY(SELECT SUM(ind.invoice_amount) invoice_amount, MAX(ind.invoice_due_date) invoice_due_date FROM invoice_detail ind WHERE ind.invoice_id = ih.invoice_id AND ind.invoice_line_item_id=civ.invoice_line_item_id ) ind
				  WHERE 1=1 
				   AND civ.value <> 0
				   AND icr.id IS NOT NULL 
				   '
				   
				   + CASE WHEN @show_prepay = 'y' THEN ' AND ISNULL(civ.finalized,''n'') = ''n''' ELSE ' AND ISNULL(civ.finalized,''n'') = ''y''' END    
				    
				   + CASE WHEN @type = 'r' THEN ' AND civv.invoice_type = ''i''' ELSE ' AND civv.invoice_type = ''r''' END		
				  
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
					  
				  SET @sql = @sql + 'GROUP BY ISNULL(sdv1.description,sdv.description) 	,civ.calc_id,COALESCE(cgd.alias, civ.invoice_line_item_id), civv.prod_date, civv.settlement_date, civv.invoice_number '
				  
				  SET @sql =  @sql +  ' 
					SELECT '+CASE WHEN @is_pivot = 'y' THEN '' ELSE '
							[Total],
							[SubTotal],' END  + '
	                       [Invoice Number],
	                       [Counterparty],
                           [Production Month],
                           [Invoice Due Date],
                           [Invoice Date],
                           [Payment Date],
                           [ChargeType],
                           [Invoice Amount],
                           CASE 
                                WHEN ti.[ChargeType] = ''Write Off'' THEN ''0''
                                ELSE ti.amount
                           END [Amount],
                           [Variance],
                           [Comments],
                           [save_invoice_detail_id],
                           contract_id,
                           counterparty_id,
                           [Calc_id],
                           [As Of Date],
                           invoice_line_item_id,
                           int_ext_flag,
                           invoice_type,
                           STATUS,
						   NULL [is_adjustment_entry]
                           --netting_group_id,
                           --group_id
						 INTO #temp_items_and_writeoff FROM  #temp_items ti 
					CROSS APPLY(
						SELECT SUM(ROUND(civ.value, ' + @round_value + ')) value 
						FROM calc_invoice_volume civ 
						OUTER APPLY(SELECT ngdc.source_contract_id contract_id FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
							INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_id WHERE ngd.netting_group_id=ti.netting_group_id						
							AND ti.prod_date BETWEEN ISNULL(ng.effective_date,''1900-01-01'') AND ISNULL(ng.end_date,''9999-01-01'')
						) netting_group	
						INNER JOIN contract_group_detail cgd ON 
							cgd.contract_id = ISNULL(netting_group.contract_id,ti.contract_id)
							AND ISNULL(cgd.alias, '''') = ISNULL(ti.group_id, '''')
							AND cgd.invoice_line_item_id = civ.invoice_line_item_id AND cgd.hideInInvoice = ''s'' 
							AND ti.[ChargeType] <> ''Write Off''
							AND civ.apply_cash_calc_detail_id IS NULL
						WHERE civ.calc_id =ti.calc_id
							AND civ.invoice_line_item_id = ti.invoice_line_item_id	
					) civ'
					
				-- Writer OFF
				  SET @sql =  @sql +  ' UNION ALL SELECT '+CASE WHEN @is_pivot = 'y' THEN '' ELSE '
														''Total'' [Total],
														[SubTotal],' END  + '
														[Invoice Number],
														[Counterparty],
														dbo.fnadateformat(civ.prod_date) [prod_date],
														NULL [Invoice Due Date],
														NULL [Invoice Date],
														NULL [Receive/Pay Date],
														civ.[ChargeType] [ChargeType],
														civ.invoice_value [Invoice Amount],
														civ.value [Amount],
														NULL [Variance],
														NULL [Comments],
														civ.calc_detail_id [save_invoice_detail_id],
														NULL contract_id,														
														counterparty_id     counterparty_id,
														[Calc_id],
														[As Of Date],
														NULL                invoice_line_item_id,
														NULL                int_ext_flag,
														NULL                invoice_type,
														''s''                STATUS,
														civ.is_adjustment_entry
														--NULL                netting_group_id,
														--NULL                group_id
						 FROM  
					(SELECT  MAX([SubTotal])[SubTotal],
							 MAX([Counterparty])[Counterparty],
							 [Invoice Number],
							 calc_id,
							 [Production Month],
							 [As Of Date],
							 MAX(save_invoice_detail_id) save_invoice_detail_id,
							 MAX(counterparty_id) counterparty_id,
							 [invoice_line_item_id]
                   FROM #temp_items GROUP BY [Invoice Number],calc_id,[Production Month],[As Of Date],[invoice_line_item_id] ) ti 
					CROSS APPLY(
						SELECT ROUND(civ.value*1, ' + @round_value + ') value, civ.calc_detail_id, civ.prod_date,
						CASE WHEN ISNULL(civ.is_adjustment_entry,''n'') = ''y'' THEN ROUND(civ.value*1, ' + @round_value + ') ELSE '''' END [invoice_value],
						CASE WHEN ISNULL(civ.is_adjustment_entry,''n'') = ''y'' THEN ''Variance '' + DATENAME(MONTH, civ.prod_date) + '' '' + DATENAME(YEAR, civ.prod_date) ELSE ''Write Off'' END [ChargeType],
						civ.is_adjustment_entry 
						FROM calc_invoice_volume civ
						WHERE civ.calc_id =ti.calc_id AND civ.invoice_line_item_id = ti.invoice_line_item_id AND apply_cash_calc_detail_id IS NOT NULL	
					) civ WHERE civ.value IS NOT NULL '
							  
				 SET @sql = @sql + '				 
				 
				 SELECT * FROM #temp_items_and_writeoff WHERE 1 =1 ' 
				 
				 + CASE 
					   WHEN (@show_option = 'v') 
					   THEN ' AND [Invoice Amount] - [Amount] <> 0 AND [ChargeType] <> ''Write Off'''
				          
					   WHEN (@show_option = 'w') 
					   THEN ' AND [ChargeType] = ''Write Off'''
				       
					   ELSE ' '
					 END + ' order by [Invoice Number], Amount '
				 
				  
				 
				 IF @type = 'r'
				 BEGIN
					 SET @sql = @sql + ' desc'				 	
				 END
			--PRINT(@sql)
			EXEC(@sql)
 		END
	 END

	ELSE IF @flag = 'r' -- for reports
	BEGIN
	 	IF (@type_cash = 'n')
 		BEGIN
	 		SET @sql = '
				SELECT 
					civv.invoice_number,
					dbo.FNADateformat(dbo.FNAGetContractMonth(civv.prod_date)) [Production Month],
					dbo.FNADateformat(dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE())), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days))) AS [Invoice Due Date], 
					dbo.FNADateformat(convert(varchar(10), civv.settlement_date, 120)) [Invoice Date],
					CASE WHEN (MAX(sdv1.description) IS NULL) THEN (MAX(sdv.description)) ELSE  MAX(sdv1.description) END [ChargeType],
					CASE 
						 WHEN (MAX(sdv1.description) IS NULL) THEN (MAX(dbo.FNARemoveTrailingZero(CONVERT(DECIMAL(18, 7), ROUND(civ.value, 2)))))
						 ELSE SUM(ROUND(civ.value, 2)) 
					END [Amount],
					MAX(dbo.FNARemoveTrailingZero(convert(decimal(18,7),ROUND(cash_received, ' + @round_value + ')))) [Receive/Pay Amount],
					MAX(comments) [Comments],
					MAX(sc.source_counterparty_id)
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
					LEFT JOIN contract_group cg ON cg.contract_id = civv.contract_id 
					INNER JOIN dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''') ci ON ci.item = CAST(civv.counterparty_id AS VARCHAR(100)) 
					INNER JOIN contract_group_detail cgd ON cg.contract_id = cgd.contract_id AND civ.invoice_line_item_id = cgd.invoice_line_item_id AND cgd.hideInInvoice = ''s'' 
					LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cgd.alias
				   WHERE 1=1 
				   AND civ.finalized = ''y'' AND civ.value <> 0
				   ' 
				   + CASE WHEN @type = 'r' THEN ' AND civv.invoice_type = ''i''' ELSE ' AND civv.invoice_type = ''r''' END    
				   
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
				  
				  IF (@type_cash = 'n')
				  BEGIN
					SET @sql = @sql + 'GROUP BY COALESCE(cgd.alias, civ.invoice_line_item_id), civv.prod_date, civv.settlement_date, civv.invoice_number, cg.invoice_due_date, cg.holiday_calendar_id, cg.payment_days '			  	
					SET @sql = @sql + 'ORDER BY COALESCE(dbo.FNADateformat(dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE())), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days))),civv.prod_date)'					
				  END
			  --PRINT(@sql)
			  EXEC(@sql) 
 		END
 		IF (@type_cash <> 'n')
 		BEGIN
 			SET @sql = '
				SELECT 
					civv.invoice_number,
					dbo.FNADateformat(dbo.FNAGetContractMonth(civv.prod_date)) [Production Month],
					dbo.FNADateformat(dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE())), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days))) AS [Invoice Due Date], 
					dbo.FNADateformat(convert(varchar(10), civv.settlement_date, 120)) [Invoice Date],
					ISNULL(sdv1.description,sdv.description) [ChargeType],
					dbo.FNARemoveTrailingZero(CONVERT(DECIMAL(18, 7), ROUND(SUM(civ.value), 2))) [Amount],
					dbo.FNARemoveTrailingZero(convert(decimal(18,7),ROUND(SUM(cash_received), ' + @round_value + '))) [Receive/Pay Amount],
					MAX(comments) [Comments],
					MAX(sc.source_counterparty_id)
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
					LEFT JOIN contract_group cg ON cg.contract_id = civv.contract_id 
					INNER JOIN dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''') ci ON ci.item = CAST(civv.counterparty_id AS VARCHAR(100)) 
					INNER JOIN contract_group_detail cgd ON cg.contract_id = cgd.contract_id AND civ.invoice_line_item_id = cgd.invoice_line_item_id AND cgd.hideInInvoice = ''s'' 
					LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cgd.alias
				   WHERE 1=1 
				   AND civ.finalized = ''y'' AND civ.value <> 0
				   ' 
				   + CASE WHEN @type = 'r' THEN ' AND civv.invoice_type = ''i''' ELSE ' AND civv.invoice_type = ''r''' END    
				   
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
				  SET @sql = @sql + ' GROUP BY civv.invoice_number,civv.prod_date,ISNULL(sdv1.description,sdv.description),dbo.FNADateformat(dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE())), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days))),dbo.FNADateformat(convert(varchar(10), civv.settlement_date, 120)) '
				  SET @sql = @sql + 'ORDER BY COALESCE(dbo.FNADateformat(dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE())), (cg.invoice_due_date), (cg.holiday_calendar_id), (cg.payment_days))),civv.prod_date)'
			--PRINT(@sql)
			EXEC(@sql)
 		END
	 END

	ELSE IF @flag = 'd'
    BEGIN
         IF OBJECT_ID('tempdb..#save_invoice_detail_ids') IS NOT NULL
             DROP TABLE #save_invoice_detail_ids
         
         SELECT * INTO #save_invoice_detail_ids
         FROM   dbo.SplitCommaSeperatedValues(@save_invoice_detail_id)
         
		 -- FInd out all the charge type in that group
         SELECT DISTINCT  civ.calc_id, civ1.calc_detail_id,civ1.apply_cash_calc_detail_id
         INTO #line_items
         FROM
			#save_invoice_detail_ids sidi
			INNER JOIN calc_invoice_volume civ ON civ.calc_detail_id = sidi.item
			INNER JOIN calc_invoice_volume_variance civv ON civv.calc_id = civ.calc_id
			OUTER APPLY(SELECT ngdc.source_contract_id contract_id FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
						INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_id WHERE ngd.netting_group_id=civv.netting_group_id
						AND civv.prod_date BETWEEN ISNULL(ng.effective_date,'1900-01-01') AND ISNULL(ng.end_date,'9999-01-01')
			) netting_group	
			INNER JOIN contract_group_detail cg ON cg.contract_id =  ISNULL(netting_group.contract_id,civv.contract_id) --AND cg.invoice_line_Item_id = civ.invoice_line_Item_id
			LEFT JOIN contract_group_detail cg1 ON cg1.contract_id =  ISNULL(netting_group.contract_id,civv.contract_id) AND cg1.alias = cg.alias
			INNER JOIN calc_invoice_volume civ1 ON civ1.calc_id = civ.calc_id AND civ1.invoice_line_Item_id = ISNULL(cg1.invoice_line_item_id,cg.invoice_line_item_id)
		
		DELETE icr
		FROM  
		invoice_cash_received icr 
		INNER JOIN #line_items cl ON icr.save_invoice_detail_id = cl.calc_detail_id  
        WHERE save_invoice_detail_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@save_invoice_detail_id))  
         
         IF @@ERROR <> 0
             EXEC spa_ErrorHandler @@ERROR,
                  'Reconcile Cash ',
                  'spa_apply_cash_module',
                  'DB Error',
                  'Failed to delete data.',
                  ''
         
         EXEC spa_ErrorHandler 0,
              'Reconcile Cash ',
              'spa_apply_cash_module',
              'Success',
              'Changes have been saved successfully.',
              ''
    END

	ELSE IF @flag = 'e' --delete the variance item 
    BEGIN
         IF OBJECT_ID('tempdb..#save_invoice_detail_ids_variance') IS NOT NULL
             DROP TABLE #save_invoice_detail_ids_variance
         
         SELECT * INTO #save_invoice_detail_ids_variance
         FROM   dbo.SplitCommaSeperatedValues(@save_invoice_detail_id)
         
         SELECT DISTINCT  civ.calc_id, civ1.calc_detail_id,civ1.apply_cash_calc_detail_id,civ1.is_adjustment_entry
         INTO #line_items_variance
         FROM
			#save_invoice_detail_ids_variance sidi
			INNER JOIN calc_invoice_volume civ ON civ.calc_detail_id = sidi.item
			INNER JOIN calc_invoice_volume_variance civv ON civv.calc_id = civ.calc_id
			OUTER APPLY(SELECT ngdc.source_contract_id contract_id FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
						INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_id WHERE ngd.netting_group_id=civv.netting_group_id
						AND civv.prod_date BETWEEN ISNULL(ng.effective_date,'1900-01-01') AND ISNULL(ng.end_date,'9999-01-01')
			) netting_group	
			INNER JOIN contract_group_detail cg ON cg.contract_id =  ISNULL(netting_group.contract_id,civv.contract_id) --AND cg.invoice_line_Item_id = civ.invoice_line_Item_id
			LEFT JOIN contract_group_detail cg1 ON cg1.contract_id =  ISNULL(netting_group.contract_id,civv.contract_id) AND cg1.alias = cg.alias
			INNER JOIN calc_invoice_volume civ1 ON civ1.calc_id = civ.calc_id AND civ1.invoice_line_Item_id = ISNULL(cg1.invoice_line_item_id,cg.invoice_line_item_id)
		
		SELECT calc_detail_id
		INTO #calc
		FROM #line_items_variance 
		WHERE apply_cash_calc_detail_id IS NOT NULL
		AND calc_detail_id = CASE WHEN ISNULL(is_adjustment_entry,'n') = 'y' THEN @save_invoice_detail_id ELSE calc_detail_id END

		DELETE civ
		FROM calc_invoice_volume civ
		INNER JOIN #calc c ON civ.calc_detail_id = c.calc_detail_id 
		
		UPDATE icr 
	    SET    settle_status = 'o'
	    FROM invoice_cash_received icr 
	    INNER JOIN #line_items_variance li ON icr.save_invoice_detail_id = li.apply_cash_calc_detail_id
		WHERE icr.variance_amount <> 0
		             
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR,
			  'Reconcile Cash ',
			  'spa_apply_cash_module',
			  'DB Error',
			  'Failed to delete data.',
			  ''

			EXEC spa_ErrorHandler 0,
			  'Reconcile Cash ',
			  'spa_apply_cash_module',
			  'Success',
			  'Changes have been saved successfully.',
			  ''
    END
	
	ELSE IF @flag = 'x'
    BEGIN
		 SELECT * INTO #save_invoice_detail_ids1
         FROM   dbo.SplitCommaSeperatedValues(@save_invoice_detail_id)
         
		 SELECT DISTINCT  civ.calc_id, civ1.calc_detail_id,civ1.apply_cash_calc_detail_id
         INTO #line_items1
         FROM
			#save_invoice_detail_ids1 sidi
			INNER JOIN calc_invoice_volume civ ON civ.calc_detail_id = sidi.item
			INNER JOIN calc_invoice_volume_variance civv ON civv.calc_id = civ.calc_id
			OUTER APPLY(SELECT ngdc.source_contract_id contract_id FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
						INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_id WHERE ngd.netting_group_id=civv.netting_group_id
						AND civv.prod_date BETWEEN ISNULL(ng.effective_date,'1900-01-01') AND ISNULL(ng.end_date,'9999-01-01')
					) netting_group	
			INNER JOIN contract_group_detail cg ON cg.contract_id = ISNULL(netting_group.contract_id,civv.contract_id)	 AND cg.invoice_line_Item_id = civ.invoice_line_Item_id
			LEFT JOIN contract_group_detail cg1 ON cg1.contract_id = ISNULL(netting_group.contract_id,civv.contract_id)	 AND cg1.alias = cg.alias
			INNER JOIN calc_invoice_volume civ1 ON civ1.calc_id = civ.calc_id --AND civ1.invoice_line_Item_id = ISNULL(cg1.invoice_line_item_id,cg.invoice_line_item_id)
			
         UPDATE icr 
         SET    settle_status = 's'
         FROM 
			invoice_cash_received icr INNER JOIN #line_items1 li ON icr.save_invoice_detail_id = li.calc_detail_id
         

         
         IF @@ERROR <> 0
             EXEC spa_ErrorHandler @@ERROR,
                  'Reconcile Cash ',
                  'spa_apply_cash_module',
                  'DB Error',
                  'Failed to update data.',
                  ''
         
         EXEC spa_ErrorHandler 0,
              'Reconcile Cash ',
              'spa_apply_cash_module',
              'Success',
              'Changes have been saved successfully.',
              ''
     END