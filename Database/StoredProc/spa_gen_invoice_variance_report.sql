

/****** Object:  StoredProcedure [dbo].r[spa_gen_invoice_variance_report]    Script Date: 12/13/2010 19:04:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_gen_invoice_variance_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_gen_invoice_variance_report]
/****** Object:  StoredProcedure [dbo].[spa_gen_invoice_variance_report]    Script Date: 12/13/2010 19:04:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_gen_invoice_variance_report]   
	@counterparty_id  VARCHAR(500),  
	@prod_date VARCHAR(20),  
	@contract_id VARCHAR(500),  
	@item VARCHAR(500) = NULL,  
	@flag CHAR(1) = NULL, -- 's' form msummary , 'f' for formula, h for hourly volume ,'d' for detail formual_value drill  
	@as_of_date VARCHAR(20) = NULL,  
	@hour VARCHAR(10) = NULL,
	@actual_prod_date VARCHAR(20) = NULL,
	@deal_id VARCHAR(100) = NULL,
	@estimate_calculation CHAR(1) = 'n',
	@line_item_id INT = NULL,
	@drill_Counterparty VARCHAR(100) = NULL,
	@drill_Contract VARCHAR(100) = NULL,
	@deal_detail_id VARCHAR(100) = NULL,
	@deal_list_table VARCHAR(200) = NULL,
	@invoice_type CHAR(1) = NULL,
	@settlement_date VARCHAR(20) = NULL, 
	@is_dst INT = NULL,
	@invoice_number INT = NULL,
	@round_value CHAR(1) = '0',
	@show_recent_calculation CHAR(1) = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL

AS  
SET NOCOUNT ON 
--EXEC spa_gen_invoice_variance_report '3830',null,'1073',null,'h','2015-07-27',null,null,null,null,'-10019',null,null,null,null,null,null,null,null,'2'
--EXEC spa_gen_invoice_variance_report null,null,null,null,'h',null,null,null,null,'y',null,null,null,null,null,null,null,null,null,'2'
--declare @counterparty_id  VARCHAR(500) = null ,  
--	@prod_date VARCHAR(20) = null,  
--	@contract_id VARCHAR(500) = null,  
--	@item VARCHAR(500) = NULL,  
--	@flag CHAR(1) = 'h', -- 's' form msummary , 'f' for formula, h for hourly volume ,'d' for detail formual_value drill  
--	@as_of_date VARCHAR(20) = null,  
--	@hour VARCHAR(10) = NULL,
--	@actual_prod_date VARCHAR(20) = NULL,
--	@deal_id VARCHAR(100) = NULL,
--	@estimate_calculation CHAR(1) = 'N',
--	@line_item_id INT = null,
--	@drill_Counterparty VARCHAR(100) = NULL,
--	@drill_Contract VARCHAR(100) = NULL,
--	@deal_detail_id VARCHAR(100) = NULL,
--	@deal_list_table VARCHAR(200) = NULL,
--	@invoice_type CHAR(1) = NULL,
--	@settlement_date VARCHAR(20) = NULL, 
--	@is_dst INT = NULL,
--	@invoice_number INT = NULL,
--	@round_value CHAR(1) = '2',
--	@show_recent_calculation CHAR(1) = 'y',
--	@batch_process_id VARCHAR(250) = NULL,
--	@batch_report_param VARCHAR(500) = NULL, 
--	@enable_paging INT = 0,  --'1' = enable, '0' = disable
--	@page_size INT = NULL,
--	@page_no INT = NULL

	DECLARE @table_calc_invoice_volume_variance VARCHAR(50)
	DECLARE @table_calc_formula_value VARCHAR(50)
	DECLARE @table_calc_invoice_volume VARCHAR(50)
	DECLARE @sql VARCHAR(MAX)
	DECLARE @mins VARCHAR(10)

	IF NULLIF(@hour,'0') IS NOT NULL
	BEGIN
		SET @mins = REPLACE(RIGHT(@hour,2),':','')	
		SET @hour = SUBSTRING(@hour,0,CHARINDEX(':',@hour,0))
		
	END
			

	IF @prod_date IS NULL
		SET @prod_date=dbo.FNAGetContractMonth(@as_of_date)

	IF @deal_list_table = ''
		SET @deal_list_table = NULL
		
		
	IF @estimate_calculation='y'
		BEGIN
			SET @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance_estimates'
			SET @table_calc_invoice_volume = 'calc_invoice_volume_estimates'
			SET @table_calc_formula_value = 'calc_formula_value_estimates'
		END
	ELSE
		BEGIN
			SET @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance'
			SET @table_calc_invoice_volume = 'calc_invoice_volume'
			SET @table_calc_formula_value = 'calc_formula_value'
		END
		
	
	CREATE TABLE #temp_filter (deal_id VARCHAR(500) COLLATE DATABASE_DEFAULT )
	If OBJECT_ID(@deal_list_table) is not null
	BEGIN
		EXEC('INSERT INTO #temp_filter  SELECT DISTINCT source_deal_header_id FROM '+@deal_list_table)
	END

	--SELECT @frequency=volume_granularity FROM contract_group WHERE contract_id in(SELECT ppa_contract_id FROM rec_generator WHERE   
	-- ppa_counterparty_id=@counterparty_id)  

	--SELECT
	--	@billing_cycle = billing_cycle,
	--	@hourly_block=hourly_block 
	--FROM 
	--	contract_group 
	--WHERE 
	--	contract_id = @contract_id 


	--SET @prod_date = dbo.FNACoverttoStdDate(@prod_date)
	--SET @as_of_date = dbo.FNACoverttoStdDate(@as_of_date)
	--SET @actual_prod_date = dbo.FNACoverttoStdDate(@actual_prod_date)
  
	IF @drill_Counterparty IS NOT NULL
		SELECT @counterparty_id=source_counterparty_id FROM source_counterparty WHERE counterparty_name=@drill_Counterparty

		IF @drill_Contract IS NOT NULL
		SELECT @contract_id=contract_id FROM contract_group WHERE contract_name=@drill_Contract

	DECLARE @netting_group_id VARCHAR(100)
	IF @drill_Contract IS NOT NULL
		SELECT @netting_group_id=ng.netting_group_id FROM netting_group ng inner join netting_group_detail ngd ON ng.netting_group_id=ngd.netting_group_id WHERE netting_group_name=@drill_Contract
		AND ngd.source_counterparty_id = @counterparty_id

	IF @netting_group_id IS NOT NULL
		SET @contract_id = NULL


	IF @actual_prod_date IS NULL 
		set @actual_prod_date=@prod_date

	/*******************************************1st Paging Batch START**********************************************/
		DECLARE @str_batch_table VARCHAR(8000)
		DECLARE @user_login_id VARCHAR(50)
		DECLARE @sql_paging VARCHAR(8000)
		DECLARE @is_batch bit


		SET @str_batch_table = ''
		SET @user_login_id = dbo.FNADBUser() 
		SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 


		IF @is_batch = 1
			SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)


		IF @enable_paging = 1 --paging processing
		BEGIN
			IF @batch_process_id IS NULL
				SET @batch_process_id = dbo.FNAGetNewID()


			SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)


			--retrieve data from paging table instead of main table
			IF @page_no IS NOT NULL 
			BEGIN
				SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
				EXEC (@sql_paging) 
				RETURN 
			END
		END
				
	/*******************************************1st Paging Batch END**********************************************/

	IF @flag='f' OR @flag='d' OR @flag='h'
	BEGIN
		CREATE TABLE #calc_formula_value(invoice_line_item_id INT,seq_number INT,prod_date DATETIME,[value] FLOAT,volume FLOAT,contract_id INT,
				counterparty_id INT,formula_id INT,calc_id INT,hour INT,formula_stmt VARCHAR(2000) COLLATE DATABASE_DEFAULT ,qtr INT,half INT,deal_id INT,formula_str_eval VARCHAR(2000) COLLATE DATABASE_DEFAULT ,is_final_result CHAR(1) COLLATE DATABASE_DEFAULT ,granularity INT,source_deal_header_id INT,is_dst INT,formula_desc VARCHAR(500) COLLATE DATABASE_DEFAULT ,uom VARCHAR(100) COLLATE DATABASE_DEFAULT ,ref_id VARCHAR(100) COLLATE DATABASE_DEFAULT , formula_description VARCHAR(500) COLLATE DATABASE_DEFAULT )
		
		
		
		SET @sql='		
			INSERT INTO #calc_formula_value
			SELECT 
				cfv.invoice_line_item_id,
				cfv.seq_number,
				cfv.prod_date,
				cfv.[value],
				cfv.[volume],
				cfv.contract_id,
				cfv.counterparty_id,
				cfv.formula_id,
				cfv.calc_id,
				NULLIF(cfv.[hour],0),
				cfv.formula_str,
				cfv.qtr,
				cfv.half,
				cfv.deal_id,
				cfv.formula_str_eval,
				cfv.is_final_result,
				cfv.granularity,
				ISNULL(cfv.source_deal_header_id,sdd.source_deal_header_id) source_deal_header_id,
				cfv.is_dst,' +
				case  when @flag ='h' then 'ISNULL(fn.description1,''Amount'')' else 'ISNULL(fn.description1,''Formula'')' END + ' formula_desc,
				su.uom_name,
				sdh.deal_id ref_id, 
				fn.description1
			FROM source_counterparty sc
				 '+CASE WHEN @show_recent_calculation = 'y' THEN	
						'OUTER APPLY(SELECT MAX(as_of_date) as_of_date,prod_date,counterparty_id,contract_id,invoice_type FROM calc_invoice_volume_variance WHERE counterparty_id=sc.source_counterparty_id'+ CASE WHEN  @as_of_date IS NOT NULL THEN ' AND as_of_date = ''' + CAST(@as_of_date AS VARCHAR)+''''	ELSE '' END +' GROUP BY prod_date,counterparty_id,contract_id,invoice_type) a
						INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=a.counterparty_id AND civv.contract_id=a.contract_id AND civv.prod_date=a.prod_date AND civv.as_of_date=a.as_of_date AND civv.invoice_type=a.invoice_type' 
				ELSE '
				 INNER JOIN '+@table_calc_invoice_volume_variance+' civv ON civv.counterparty_id=sc.source_counterparty_id' END + '
				 INNER JOIN  '+@table_calc_formula_value+' cfv   ON civv.calc_id=cfv.calc_id 
				 INNER JOIN static_data_value sd ON sd.value_id=cfv.invoice_line_item_id
 				LEFT JOIN formula_nested fn ON fn.formula_group_id=cfv.formula_id
 					AND fn.sequence_order=cfv.seq_number	
 				LEFT JOIN contract_group cg ON cg.contract_id=cfv.contract_id
 			    LEFT JOIN source_uom su ON cg.volume_uom=su.source_uom_id
 			    LEFT JOIN source_uom su_fn ON fn.uom_id=su_fn.source_uom_id 		
 			    LEFT JOIN source_deal_detail sdd On sdd.source_deal_detail_id=cfv.deal_id 
 			    LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = ISNULL(cfv.source_deal_header_id,sdd.source_deal_header_id) 
 			    ' + CASE WHEN @deal_list_table IS NOT NULL THEN ' INNER JOIN #temp_filter t ON cfv.source_deal_header_id = t.deal_id ' ELSE '' END + '								
 			WHERE  1=1
				 '+CASE WHEN @counterparty_id IS NOT NULL THEN ' AND civv.counterparty_id IN('+CAST(ISNULL(@counterparty_id, '''''') AS VARCHAR)+')' ELSE ''  END +
				--AND dbo.FNAGETContractMONTH(ISNULL(pd.proxy_term_start,cfv.prod_date))=dbo.FNAGETContractMONTH('''+CAST(@prod_date AS VARCHAR)+''')
				+CASE WHEN @prod_date IS NOT NULL THEN ' AND YEAR(civv.prod_date)=YEAR('''+CAST(@prod_date AS VARCHAR)+''')' ELSE ''  END +
				+CASE WHEN @prod_date IS NOT NULL THEN ' AND MONTH(civv.prod_date)=MONTH('''+CAST(@prod_date AS VARCHAR)+''')' ELSE ''  END+
				+CASE WHEN @as_of_date IS NOT NULL THEN ' AND civv.as_of_date = ''' + CAST(@as_of_date AS VARCHAR)+'''' ELSE ''  END
				+CASE WHEN @item like '%Volume  (%'  THEN '' WHEN @item IS NOT NULL THEN  ' AND sd.description='''+CAST(@item  AS VARCHAR(500))+'''' ELSE '' END 
				+CASE WHEN @contract_id IS NOT NULL THEN ' AND ((civv.netting_group_id IS NULL AND civv.contract_id='+CAST(@contract_id AS VARCHAR) +') OR (civv.netting_group_id IS NOT NULL))' ELSE '' END
				+CASE WHEN @line_item_id IS NOT NULL THEN ' AND cfv.invoice_line_item_id='+CAST(@line_item_id AS VARCHAR) ELSE '' END
				+case when @invoice_type IS not null then ' AND civv.invoice_type='''+@invoice_type+'''' else '' end
				+CASE WHEN @settlement_date IS NOT NULL THEN ' AND civv.settlement_date =  ''' + CAST(@settlement_date AS VARCHAR)+'''' ELSE '' END
				+CASE WHEN @netting_group_id IS NOT NULL THEN ' AND civv.netting_group_id='+CAST(@netting_group_id AS VARCHAR) ELSE '' END
		
	--	exec spa_print isnull(@sql,'isnull')
		EXEC(@sql)	
	
		CREATE INDEX [IDX_CF1] ON #calc_formula_value(calc_id,invoice_line_item_id,seq_number,prod_date,[hour],[half],[qtr],[is_dst])
		CREATE INDEX [IDX_CF2] ON #calc_formula_value(source_deal_header_id,deal_id)
	
	 END


	IF @flag='s'
	BEGIN	
		DECLARE @show_invoice_variance CHAR(1)
		SET @show_invoice_variance = 'n'
		IF EXISTS(SELECT 'X' FROM invoice_header WHERE counterparty_id =@counterparty_id AND contract_id =@contract_id  AND dbo.FNAGetcontractMonth(production_month)=dbo.FNAGetcontractMonth(@prod_date))
			SET @show_invoice_variance = 'y'
		
		SET @sql='
			;WITH CTE(counterparty_id,contract_id,Item,Volume,prod_date,seq_number,invoicevolume,hourly_block)
			AS(	
			SELECT 
				counterparty_id,contract_id,
				CASE types WHEN ''allocationvolume'' THEN ''Volume  (''+uom_name+'')'' WHEN ''onpeak_volume'' THEN ''OnPeak Volume'' WHEN ''offpeak_volume'' THEN ''OffPeak Volume'' END AS Item,
				Volume,prod_date,
				CASE types WHEN ''allocationvolume'' THEN 1 WHEN ''onpeak_volume'' THEN 2 WHEN ''offpeak_volume'' THEN 3 END AS seq_number,
				invoicevolume,
				hourly_block
			FROM 
			   (SELECT civv.counterparty_id,civv.contract_id,civv.metervolume allocationvolume,civv.onpeak_volume,civv.offpeak_volume,civv.prod_date,isnull(ih.invoice_volume,0) inv_allocationvolume,isnull(ih.onpeak_volume,0) inv_onpeak_volume,isnull(ih.offpeak_volume,0) inv_offpeak_volume,su.uom_name,cg.hourly_block
					FROM 
						 '+@table_calc_invoice_volume_variance+' civv
						 LEFT JOIN invoice_header ih ON ih.counterparty_id=civv.counterparty_id
								AND ih.contract_id=civv.contract_id
								AND ih.Production_month=civv.prod_date
								AND civv.invoice_type = ''r''
						 LEFT JOIN source_uom su ON su.source_uom_id=civv.uom
						 LEFT JOIN contract_group cg ON cg.contract_id=civv.contract_id
									
					WHERE 
						 civv.counterparty_id IN('+CAST(@counterparty_id AS VARCHAR)+')   
						 AND dbo.FNAGetcontractMonth(civv.prod_date)=dbo.FNAGetcontractMonth('''+@prod_date+''')  
						 AND (civv.as_of_date)=('''+@as_of_date+''')  
						 AND civv.contract_id IN('+CAST(@contract_id AS VARCHAR)+') 
						 '+case when @invoice_type IS not null then ' AND civv.invoice_type='''+@invoice_type+'''' else '' end+'
				) p
				UNPIVOT
			   (Volume FOR types IN 
				  (allocationvolume,onpeak_volume,offpeak_volume)
				)AS unpvt
				UNPIVOT
				(invoicevolume FOR invoice_type IN
					(inv_allocationvolume,inv_onpeak_volume,inv_offpeak_volume)
				)AS inv_unpvt
			
			WHERE
				REPLACE(invoice_type,''inv_'','''')=types
			)
			

				
			SELECT Item,[Shadow Calc]'+CASE WHEN @show_invoice_variance='y' THEN ',[Invoice],[Variance] [Variance Amount],[Variance %]' ELSE '' END+'
			FROM(
				SELECT  
					 sd.description AS Item,  
					 SUM(ISNULL(a.value,0)) [Shadow Calc],  
					 SUM(ISNULL(ind.invoice_amount,0)) [Invoice],  
					 ROUND(abs((abs(SUM(ind.invoice_amount))-abs(SUM(ISNULL(a.value,0))))/ CASE WHEN (abs(SUM(ISNULL(a.value,0))))<=0 THEN (abs(SUM(ISNULL(ind.invoice_amount,0)))) ELSE (abs(SUM(ISNULL(a.value,0)))) end)*100,4) AS [Variance %],
					 ABS(ABS(SUM(ind.invoice_amount))-ABS(SUM(ISNULL(a.value,0)))) [Variance],
					 999 AS seq_number,
					 cgd.sequence_order	contract_sequence	
				FROM
					 '+@table_calc_invoice_volume_variance+' civ 
					 INNER JOIN '+@table_calc_invoice_volume+' a  ON civ.calc_id=a.calc_id   
					 LEFT JOIN invoice_header ih ON ih.counterparty_id=civ.counterparty_id 
						AND ih.contract_id=civ.contract_id
						AND ih.production_month=civ.prod_date
						AND ih.as_of_date>=civ.as_of_date
						AND civ.invoice_type=''r''
						AND ISNULL(a.manual_input,''n'')=''n''
					 OUTER APPLY(SELECT SUM(invoice_amount) invoice_amount FROM invoice_detail ind WHERE invoice_id = ih.invoice_id AND invoice_line_item_id=a.invoice_line_item_id ) ind  		
					 LEFT JOIN static_data_value sd ON sd.value_id=a.invoice_Line_Item_id  
					 LEFT JOIN contract_group_detail cgd ON cgd.contract_id=civ.contract_id	
						 AND cgd.invoice_line_item_id=a.invoice_line_item_id
						 AND ISNULL(cgd.deal_type,-1)=ISNULL(a.deal_type_id,-1)
					LEFT JOIN contract_group cg  ON cg.contract_id=civ.contract_id
					LEFT JOIN contract_charge_type cct ON cct.contract_charge_type_id=cg.contract_charge_type_id
					LEFT JOIN contract_charge_type_detail cctd ON cctd.contract_charge_type_id=cct.contract_charge_type_id
						AND cctd.invoice_line_item_id=a.invoice_line_item_id
						AND cctd.prod_type=
						CASE WHEN ISNULL(cg.term_start,'''')='''' THEN ''p''
							 when dbo.fnagetcontractmonth(cg.term_start)<=dbo.fnagetcontractmonth('''+@prod_date+''') THEN ''p''
							 ELSE ''t'' end
				 WHERE
					 civ.counterparty_id IN('+CAST(@counterparty_id AS VARCHAR)+')   
					 AND dbo.FNAGetcontractMonth(civ.prod_date)=dbo.FNAGetcontractMonth('''+ @prod_date +''')  
					 AND (civ.as_of_date)=('''+ @as_of_date +''')  
					 AND civ.contract_id IN('+ @contract_id +')  
					  '+case when @invoice_type IS not null then ' AND civ.invoice_type='''+@invoice_type+'''' else '' end+
					 CASE WHEN @settlement_date IS NOT NULL THEN ' AND civ.settlement_date =  ''' + CAST(@settlement_date AS VARCHAR)+'''' ELSE '' END+'
				GROUP BY  sd.description,cgd.sequence_order	
			)a
				ORDER BY seq_number,contract_sequence'					
			--PRINT(@sql)
			EXEC(@sql)
	END

	ELSE IF @flag='m'
	BEGIN
		IF @item like '%Volume  (%'  
		BEGIN  
			SET @sql='	
			  SELECT
				dbo.FNADateFormat(cinv.prod_date) [Production Date],  
				MAX(ROUND(meterVolume,2)) AS Volume,  
				MAX(su.uom_name) AS UOM  
			 FROM 
				'+@table_calc_invoice_volume_variance+' civv  
				INNER JOIN '+@table_calc_invoice_volume+' cinv ON civv.calc_id=cinv.calc_id  
				INNER JOIN static_data_value sd ON sd.value_id=cinv.invoice_line_item_id   
				LEFT JOIN contract_group cg ON civv.contract_id=cg.contract_id  
				LEFT JOIN source_uom su ON cg.volume_uom=su.source_uom_id  
			  WHERE
				civv.counterparty_id IN('+CAST(@counterparty_id AS VARCHAR)+')   
				AND civv.contract_id IN('+CAST(@contract_id AS VARCHAR)+')   
				AND dbo.FNAGetcontractMonth(civv.prod_date)=dbo.FNAGetcontractMonth('''+CAST(@prod_date AS VARCHAR)+''')  
				AND (civv.as_of_date)=('''+CAST(@as_of_date AS VARCHAR)+''')     
				AND civv.contract_id=ISNULL('+CAST(@contract_id AS VARCHAR)+',civv.contract_id)   
				'+case when @invoice_type IS not null then ' AND civv.invoice_type='''+@invoice_type+'''' else '' end+ 
				 CASE WHEN @settlement_date IS NOT NULL THEN ' AND civv.settlement_date =  ''' + CAST(@settlement_date AS VARCHAR)+'''' ELSE '' END+'
			  GROUP BY 
				dbo.FNADateFormat(cinv.prod_date)
			  ORDER BY 
				dbo.FNADateFormat(cinv.prod_date)'
			
			EXEC(@sql)	
			
		END  
		ELSE
		BEGIN
			SET @sql='
				SELECT  
					dbo.FNADateFormat(cinv.prod_date) [Production Date],  
					ROUND(Volume,2) AS Volume,  
					su.uom_name AS UOM,    
					ABS([Value]/(CASE WHEN ROUND(volume,2)=0 THEN 1 ELSE ROUND(volume,2) end))  AS Price,  
					[Value],
					''Formula'' Formula  
				 FROM 
					'+@table_calc_invoice_volume_variance+' civv INNER JOIN  
					'+@table_calc_invoice_volume+' cinv ON civv.calc_id=cinv.calc_id  
					INNER JOIN static_data_value sd ON sd.value_id=cinv.invoice_line_item_id   
					LEFT JOIN contract_group cg ON civv.contract_id=cg.contract_id  
					LEFT JOIN source_uom su ON cg.volume_uom=su.source_uom_id  
				 WHERE   
					counterparty_id IN('+CAST(@counterparty_id AS VARCHAR)+') 
					AND civv.contract_id IN('+CAST(@contract_id AS VARCHAR)+')   
					AND dbo.FNAGetcontractMonth(civv.prod_date)=dbo.FNAGetcontractMonth('''+CAST(@prod_date AS VARCHAR)+''')  
					AND (civv.as_of_date)=('''+CAST(@as_of_date AS VARCHAR)+''')   
					AND sd.description='''+CAST(@item AS VARCHAR(500))+'''
					 '+case when @invoice_type IS not null then ' AND civv.invoice_type='''+@invoice_type+'''' else '' end+	
					 CASE WHEN @settlement_date IS NOT NULL THEN ' AND civv.settlement_date =  ''' + CAST(@settlement_date AS VARCHAR)+'''' ELSE '' END+' 
				 ORDER BY 
					dbo.FNADateFormat(cinv.prod_date)'
				--PRINT(@sql)	
				EXEC(@sql)	
		END

	END

	ELSE if @flag='f'  
	BEGIN  
	
		SET @sql='
		 SELECT 
			 MAX(dbo.FNACONTRACTMONTHFORMAT(cfv.prod_date)) [Production Month],  
			 ISNULL(fn.sequence_order,1) [Row No],
			 ISNULL(description1,sd.description) [Desc1],  
			 ISNULL(description2,sd.description) [Desc2],  
			 dbo.fnaformulaformat(fe.formula,''r'') [Formula],sum(cfv.[value]) [Value]  
		 FROM   
			 #calc_formula_value cfv   
			 LEFT JOIN formula_nested fn  ON fn.formula_group_id=cfv.formula_id AND fn.sequence_order=cfv.seq_number  
			 LEFT JOIN formula_editor fe ON fe.formula_id=ISNULL(fn.formula_Id,cfv.formula_id)  
			 INNER JOIN '+@table_calc_invoice_volume+' civ ON civ.calc_id=cfv.calc_id 
			 INNER JOIN '+@table_calc_invoice_volume_variance+' civv ON civv.calc_id=cfv.calc_id 
					AND civ.invoice_line_item_id=cfv.invoice_Line_item_id  AND isnull(civ.manual_input,''n'')=''n''
			 INNER JOIN static_data_value sd ON sd.value_id=civ.invoice_line_item_id      
		WHERE  
			 civv.counterparty_id IN('+CAST(@counterparty_id AS VARCHAR)+')   
			 AND dbo.fnagetcontractmonth(civv.prod_date)='''+CAST(@actual_prod_date AS VARCHAR)+'''
			 AND civv.as_of_date=('''+CAST(@as_of_date    AS VARCHAR)+''')	
			 AND (dbo.fnagetcontractmonth(cfv.prod_date)='''+CAST(@prod_date AS VARCHAR)+''')
			 AND sd.description='''+@item+'''  
			 '+case when @invoice_type IS not null then ' AND civv.invoice_type='''+@invoice_type+'''' else '' end+
			 CASE WHEN @settlement_date IS NOT NULL THEN ' AND civv.settlement_date =  ''' + CAST(@settlement_date AS VARCHAR)+'''' ELSE '' END+'
		GROUP BY   
			 fn.sequence_order,ISNULL(description2,sd.description),cfv.seq_number,  
			 ISNULL(description1,sd.description),dbo.fnaformulaformat(fe.formula,''r'')  
		 ORDER BY   
		 cfv.seq_number  '
		 
		 EXEC(@sql)
	END

	ELSE IF @flag='h'  
	BEGIN  
		DECLARE @formula_column VARCHAR(5000),@formula_column_sum VARCHAR(5000)
		
		--SELECT * FROM #calc_formula_value

		IF EXISTS(SELECT 1 FROM #calc_formula_value)
		BEGIN
			SELECT DISTINCT formula_desc,MAX(seq_number) seq_number INTO #lst_formula FROM #calc_formula_value group by formula_desc
			SELECT @formula_column  = STUFF(( SELECT ',[' + formula_desc+']'
				 FROM    #lst_formula
				 ORDER BY seq_number
			 FOR XML PATH('')), 1, 1, '') 
				
			SELECT  @formula_column_sum = STUFF(( SELECT  ',SUM([' + formula_desc+'])['+formula_desc+']'
				 FROM    #lst_formula
				 ORDER BY seq_number
			 FOR XML PATH('')), 1, 1, '') 
			 DECLARE @formula_description VARCHAR(500)
			 SELECT  @formula_description = MAX(formula_description) FROM #calc_formula_value
			--SELECT * FROM #lst_formula
			
			SET @sql='
			SELECT
				dbo.FNATRMWinHyperlink(''a'', 10131010, source_deal_header_id, source_deal_header_id, ''n'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,0) [Deal ID],
				MAX(ref_id) [Ref ID],
				CAST(deal_id AS VARCHAR) [Detail ID], 
				dbo.FNADATEFORMAT(prod_date) [Production Date],
				is_dst [DST],
				(CASE WHEN hour = 0 THEN ''0'' ELSE CAST([Hour] AS VARCHAR) END
				+'':''+ 
				CASE WHEN qtr = 0 THEN ''00'' ELSE ISNULL(NULLIF(CAST(qtr-CASE WHEN granularity = 994 THEN 10 WHEN granularity = 995 THEN 5 ELSE 15 END AS VARCHAR), 0),''00'') END)  Hour,  
					'+ISNULL(@formula_column_sum,'src.value')+'' 
			
			SET @sql= 	@sql +	 CASE 
			          	      	      WHEN @formula_description IS NOT NULL THEN ''
			          	      	      ELSE ' , MAX(volume2) Volume,
											  ABS(SUM([final_value])/MAX(CASE WHEN ROUND(volume2,2)=0 THEN 1 ELSE ROUND(volume2,2) end)) Price '
			          	      	 END
					
			SET @sql=	@sql +	' ,uom [UOM] ' + @str_batch_table +  '
			FROM
					(		
						 SELECT 
							 cfv.counterparty_id,
							 cfv.seq_number,
							 cfv.prod_date,
							 cfv.[hour],
							 cfv.[qtr],
							 cfv.[half],
							 cfv.[value] [value],
							 cfv.source_deal_header_id,
							 cfv.deal_id,
							 cfv.formula_desc,
							 cfv.uom,
							 cfv.is_dst,
							 cfv.volume volume2,
							 CASE WHEN is_final_result = ''y'' THEN cfv.[value] else 0 END [final_value]	,
							 ref_id,
							 granularity						 
						 FROM #calc_formula_value cfv 
					 )src	 
					 PIVOT (SUM(value) FOR formula_desc IN('+ISNULL(@formula_column,'[NULL]')+')) AS pvt
				GROUP BY
				source_deal_header_id,deal_id,prod_date,[hour],[qtr],uom,is_dst,granularity
				ORDER BY source_deal_header_id,prod_date,CAST([hour] AS INT),is_dst,[qtr]
				'
		END
		ELSE
		BEGIN
			SET @sql = 'SELECT cfv.deal_id [Deal ID],
			                   cfv.source_deal_header_id [Detail ID],
			                   cfv.prod_date [Deliver Month],
			                   cfv.[hour] [Hour],
			                   cfv.[value] [Settlement Sum],
			                   cfv.uom [UOM] ' + @str_batch_table +  '
			            FROM  #calc_formula_value  cfv'
		END	
		--PRINT @sql 
		EXEC(@sql)
		
	END  

	ELSE IF @flag='d'
	BEGIN 
		DECLARE @granularity VARCHAR(100)
		SELECT @granularity =  max(granularity) FROM  #calc_formula_value 
		--*** resolve function parameter
		DECLARE @process_id	VARCHAR(200) = dbo.FNAGetNewId()
		DECLARE @user_name VARCHAR(50) = dbo.FNADBUser() 
		DECLARE @process_table	VARCHAR(300) = dbo.FNAProcessTableName('formula_editor', @user_name, @process_id)
		DECLARE @formula_group_id INT
		SELECT @formula_group_id = MAX(formula_id) FROM  #calc_formula_value
		EXEC spa_resolve_function_parameter @flag = 's',@process_id = @process_id, @formula_group_id = @formula_group_id

		--*** resolve function parameter

		SET @sql='
			SELECT 
				 ISNULL(fn.sequence_order,1) [Row No],
				 isnull(description1,sd.description) [Desc1],  
				 MAX(REPLACE(pt.formula_name,''<'',''&lt;''))+''<br>''+ MAX(cfv.formula_str_eval) Formula,
				 SUM(cfv.[value]) [Value]  
				' + @str_batch_table +  '
			 FROM   
				 #calc_formula_value cfv   
				 LEFT JOIN formula_nested fn  ON fn.formula_group_id=cfv.formula_id AND fn.sequence_order=cfv.seq_number  
				 LEFT JOIN formula_editor fe on fn.formula_id=fe.formula_id
				 INNER JOIN '+@table_calc_invoice_volume+' civ ON civ.calc_id=cfv.calc_id 
				 INNER JOIN '+@table_calc_invoice_volume_variance+' civv ON civv.calc_id=cfv.calc_id 
						AND civ.invoice_line_item_id=cfv.invoice_Line_item_id  AND ISNULL(civ.manual_input,''n'')=''n''
				 INNER JOIN static_data_value sd ON sd.value_id=civ.invoice_line_item_id 
				 ' + CASE WHEN @deal_list_table IS NOT NULL THEN ' INNER JOIN #temp_filter t ON cfv.source_deal_header_id = t.deal_id ' ELSE '' END + '								
				 LEFT JOIN '+@process_table+' pt ON pt.formula_id = fe.formula_id							
			WHERE  
				civv.counterparty_id IN('+CAST(@counterparty_id AS VARCHAR(100))+')   
				AND ((cfv.prod_date)='''+CAST(@prod_date AS VARCHAR)+''' OR (fn.granularity=980 AND dbo.FNAGETContractMonth(cfv.prod_date)='''+CAST(@prod_date AS VARCHAR)+''')) 
				AND YEAR(cfv.prod_date)=YEAR('''+CAST(@prod_date AS VARCHAR)+''')
				AND MONTH(cfv.prod_date)=MONTH('''+CAST(@prod_date AS VARCHAR)+''')
				'
				+ CASE WHEN ISNULL(@item, '') <> '' THEN 'AND sd.description = ''' + @item +'''' ELSE '' END
				+CASE WHEN ISNULL(@deal_id,'')<>'' THEN ' AND cfv.source_deal_header_id='+@deal_id ELSE '' END
				+CASE WHEN ISNULL(@deal_detail_id,'')<>'' THEN ' AND cfv.deal_id='+@deal_detail_id ELSE '' END
				+CASE WHEN ISNULL(NULLIF(@hour,''),-1)>=0 THEN ' AND cfv.[hour]='+CAST(CAST(@hour AS INT)+1 AS VARCHAR) ELSE '' END
				+CASE WHEN ISNULL(NULLIF(@mins,''),-1)>=0 AND @granularity IN(987,989,994,995) THEN 'AND cfv.[qtr]=
					CASE WHEN cfv.granularity=994 THEN '+CAST(CAST(@mins AS INT)+10 AS VARCHAR)+' WHEN cfv.granularity=995 THEN '+CAST(CAST(@mins AS INT)+5 AS VARCHAR)+' ELSE '++CAST(CAST(@mins AS INT)+15 AS VARCHAR)++' END)	
					OR fn.granularity NOT IN(987,989,994,995) )' ELSE '' END
				+case when @invoice_type IS not null then ' AND civv.invoice_type='''+@invoice_type+'''' else '' end+
				 CASE WHEN @settlement_date IS NOT NULL THEN ' AND civv.settlement_date =  ''' + CAST(@settlement_date AS VARCHAR)+'''' ELSE '' END+
				  CASE WHEN @is_dst IS NOT NULL THEN 'AND cfv.is_dst = ''' + CAST(@is_dst AS VARCHAR)+'''' ELSE '' END  + '
			 GROUP BY   
				 fn.sequence_order,description1,dbo.FNAcontractMonthFormat(cfv.prod_date), ISNULL(description1,sd.description)
			 ORDER BY   
				fn.sequence_order ' 
		--PRINT @sql
		--SELECT 1
		EXEC(@sql)

	END

	/*******************************************2nd Paging Batch START**********************************************/
			IF @is_batch = 1
			BEGIN
			   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
			   EXEC(@sql_paging)

			   --TODO: modify sp and report name
			   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_gen_invoice_variance_report', 'Invoice Reconciliation')
			   EXEC(@sql_paging)  

			   RETURN
			END

			--if it is first call from paging, return total no. of rows and process id instead of actual data
			IF @enable_paging = 1 AND @page_no IS NULL
			BEGIN
			   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
			   EXEC(@sql_paging)
			END


		/*******************************************2nd Paging Batch END**********************************************/
  

