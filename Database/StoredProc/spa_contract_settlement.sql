
IF OBJECT_ID(N'[dbo].[spa_contract_settlement]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_contract_settlement]
GO

-- ===========================================================================================================
-- Author: bmaharjan@pioneersolutionsglobal.com
-- Create date: 2015-03-20
-- Description: CRUD operation for Run COntract Settlement
 
-- Params:
-- @flag     CHAR - Operation flag

-- ===========================================================================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[spa_contract_settlement]
	@flag CHAR(1),
	@counterparty_id VARCHAR(MAX) = NULL,
	@contract_id VARCHAR(MAX) = NULL,
	@show_processed CHAR(1) = NULL,
	@deal_id VARCHAR(100) = '',
	@deal_id_filter VARCHAR(100) = '',
	@ref_id VARCHAR(100) = '',
	@counterparty_type CHAR(1) = 'e',
	@subsidiary_id INT = NULL ,
	@date_from VARCHAR(10) = '',
	@date_to VARCHAR(10) = '',
	@as_of_date VARCHAR(10) = '',
	@meter_id VARCHAR(100) = '',
	@commodity VARCHAR(100) = NULL,
	@cpt_type CHAR(1) = 'e',
	@date_type CHAR(1) = 't', -- 's' settlement date, 't' term
	@process_adjustment CHAR(1) = NULL
	
AS

SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)

--******************************************************            
-- Create source book map table 
--*********************************************************            
	SET @sql = ''            
		CREATE TABLE #ssbm(            
			 source_system_book_id1 INT,            
			 source_system_book_id2 INT,            
			 source_system_book_id3 INT,            
			 source_system_book_id4 INT,            
			 fas_deal_type_value_id INT,            
			 book_deal_type_map_id INT,            
			 fas_book_id INT,            
			 stra_book_id INT,            
			 sub_entity_id INT            
		)            

	BEGIN         
			SET @sql=            
			'INSERT INTO #ssbm            
			SELECT            
			  source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,fas_deal_type_value_id,            
			  book_deal_type_map_id,book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id             
			FROM            
			 source_system_book_map ssbm             
			 INNER JOIN portfolio_hierarchy book (nolock) ON ssbm.fas_book_id = book.entity_id             
			 INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id	            
			WHERE 1=1'             
			+ CASE WHEN @subsidiary_id IS NOT NULL THEN ' AND stra.parent_entity_id IN  ( ' + cast (@subsidiary_id as varchar)+ ') '  ELSE '' END
				   
			EXEC (@sql)         
            
	 END
 
  --******************************************************            
-- Collect Counterparty
--********************************************************* 
 
 CREATE TABLE #temp_counterparty
	(
		counterparty_id INT,
		counterparty_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		generator_id INT,
		legal_entity_value_id INT,
		contract_id INT,
		is_active NCHAR(1) COLLATE DATABASE_DEFAULT
	)

	SET @sql= '          
		INSERT INTO #temp_counterparty (counterparty_id, counterparty_name, generator_id, legal_entity_value_id, contract_id, is_active)
		SELECT 
			source_counterparty_id, 
			counterparty_name, 
			MAX(generator_id), 
			MAX(legal_entity_value_id), 
			contract_id, 
			MAX(is_active)
		FROM
		('

		SET @sql= @sql + '
			
			SELECT source_counterparty_id, counterparty_name, rg.generator_id, rg.legal_entity_value_id, cg.contract_id, sc.is_active,rgm.meter_id,NULL [source_deal_header_id]
			from 
				source_counterparty sc 
				inner join rec_generator rg on sc.source_counterparty_id=isnull(rg.ppa_Counterparty_id,'''')
				inner join contract_group cg on cg.contract_id=rg.ppa_Contract_id
				LEFT JOIN counterparty_contract_address cca ON cca.counterparty_id = sc.source_counterparty_id AND cca.contract_id = cg.contract_id
				INNER JOIN recorder_generator_map rgm ON rgm.generator_id = rg.generator_id
			WHERE 1=1 
				AND  ((
						COALESCE(cca.contract_start_date, cg.term_start) BETWEEN''' + CAST(@date_from AS VARCHAR(50)) + ''' AND ''' + CAST(@date_to AS VARCHAR(50)) + '''
						OR COALESCE(cca.contract_end_date, cg.term_end) BETWEEN''' + CAST(@date_from AS VARCHAR(50)) + ''' AND ''' + CAST(@date_to AS VARCHAR(50)) + '''
				) OR (
						''' + CAST(@date_from AS VARCHAR(50)) + ''' BETWEEN COALESCE(cca.contract_start_date, cg.term_start,''1900-01-01'') AND COALESCE(cca.contract_end_date, cg.term_end,''9999-01-01'')
						OR ''' + CAST(@date_to AS VARCHAR(50)) + ''' BETWEEN COALESCE(cca.contract_start_date, cg.term_start,''1900-01-01'') AND COALESCE(cca.contract_end_date, cg.term_end,''9999-01-01'')
				))
				
				AND ISNULL(sc.int_ext_flag,''e'') = ISNULL('''+@counterparty_type+''',''e'')  
				AND COALESCE(cca.contract_active, cg.is_active,''n'') = ''y'' AND COALESCE(sc.is_active,''n'') = ''y''
		
				'+ CASE WHEN @counterparty_id <> '' THEN ' AND sc.source_counterparty_id IN('+@counterparty_id+')' ELSE '' END +'
				'+ CASE WHEN @contract_id <> '' THEN ' AND cg.contract_id IN('+@contract_id+')' ELSE '' END +'
				'+ CASE WHEN @meter_id <> '' THEN ' AND rgm.meter_id IN('+@meter_id+')' ELSE '' END +'
				'+ CASE WHEN @commodity <> '' THEN ' AND cg.commodity = '+ @commodity ELSE '' END 
		
		SET @sql= @sql + '     
			UNION ALL

			SELECT 
				source_counterparty_id,counterparty_name,sdh.generator_id as generator_id,'+CAST(ISNULL(@subsidiary_id,-1) AS VARCHAR)+' as legal_entity_value_id,cg.contract_id, sc.is_active, NULL, sdh.source_deal_header_id
			FROM 
				source_counterparty sc 
				INNER JOIN source_deal_header sdh on sc.source_counterparty_id = '+CASE WHEN @counterparty_type = 'b' THEN ' sdh.broker_id' ELSE ' sdh.counterparty_id' END+'
				INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
				LEFT JOIN user_defined_deal_fields_template uddft1 ON uddft1.template_id  = sdht.template_id
						 AND uddft1.field_id = -5604 AND sc.int_ext_flag = ''b''
				LEFT JOIN user_defined_deal_fields	uddf1 ON uddf1.source_deal_header_id  = sdh.source_deal_header_id AND uddf1.udf_template_id = uddft1.udf_template_id				 
				INNER JOIN contract_group cg on CAST(cg.contract_id AS VARCHAR)='+CASE WHEN @counterparty_type = 'b' THEN ' uddf1.udf_value' ELSE 'CAST(sdh.Contract_id AS VARCHAR)' END +'
				LEFT JOIN #ssbm ssbm ON sdh.source_system_book_id1=ssbm.source_system_book_id1
					AND sdh.source_system_book_id2=ssbm.source_system_book_id2
					AND sdh.source_system_book_id3=ssbm.source_system_book_id3
					AND sdh.source_system_book_id4=ssbm.source_system_book_id4   
				LEFT JOIN counterparty_contract_address cca 
					ON cca.counterparty_id = sc.source_counterparty_id AND cca.contract_id = cg.contract_id   
				WHERE 1=1  AND COALESCE(sc.is_active,''n'') = ''y'' AND COALESCE(cca.contract_active,cg.is_active,''n'') = ''y''
					AND  ((
						COALESCE(cca.contract_start_date, cg.term_start, '+CASE WHEN @counterparty_type = 'b' THEN 'sdh.deal_date' ELSE 'sdh.entire_term_start' END + ') BETWEEN''' + CAST(@date_from AS VARCHAR(50)) + ''' AND ''' + CAST(@date_to AS VARCHAR(50)) + '''
						OR COALESCE(cca.contract_end_date, cg.term_end, '+CASE WHEN @counterparty_type = 'b' THEN 'sdh.deal_date' ELSE 'sdh.entire_term_start' END + ') BETWEEN''' + CAST(@date_from AS VARCHAR(50)) + ''' AND ''' + CAST(@date_to AS VARCHAR(50)) + '''
					) OR (
							''' + CAST(@date_from AS VARCHAR(50)) + ''' BETWEEN COALESCE(cca.contract_start_date, cg.term_start, '+CASE WHEN @counterparty_type = 'b' THEN 'sdh.deal_date' ELSE 'sdh.entire_term_start' END + ') AND COALESCE(cca.contract_end_date, cg.term_end, '+CASE WHEN @counterparty_type = 'b' THEN 'sdh.deal_date' ELSE 'sdh.entire_term_end' END + ')
							OR ''' + CAST(@date_to AS VARCHAR(50)) + ''' BETWEEN COALESCE(cca.contract_start_date, cg.term_start, '+CASE WHEN @counterparty_type = 'b' THEN 'sdh.deal_date' ELSE 'sdh.entire_term_start' END + ') AND COALESCE(cca.contract_end_date, cg.term_end, '+CASE WHEN @counterparty_type = 'b' THEN 'sdh.deal_date' ELSE 'sdh.entire_term_end' END + ')
					))
					'+ CASE WHEN @counterparty_id <> '' THEN ' AND sc.source_counterparty_id IN('+@counterparty_id+')' ELSE '' END +'
					'+ CASE WHEN @contract_id <> '' THEN ' AND cg.contract_id IN('+@contract_id+')' ELSE '' END +'
					'+ CASE WHEN @deal_id <> '' THEN ' AND sdh.source_deal_header_id IN('+@deal_id+')' ELSE '' END +'
					'+ CASE WHEN @commodity <> '' THEN ' AND cg.commodity = '+ @commodity ELSE '' END 
		
		IF @meter_id = '' AND @deal_id = ''
		BEGIN
		SET @sql= @sql + '      		
			UNION ALL
	
			SELECT source_counterparty_id, counterparty_name, NULL, cg.sub_id, cg.contract_id, sc.is_active , NULL , NULL
			FROM 
				counterparty_contract_address cca
				INNER JOIN source_counterparty sc on sc.source_counterparty_id = cca.counterparty_id
				INNER JOIN contract_group cg on cg.contract_id = cca.contract_id
			WHERE 1=1
				AND  ((
						COALESCE(cca.contract_start_date, cg.term_start) BETWEEN''' + CAST(@date_from AS VARCHAR(50)) + ''' AND ''' + CAST(@date_to AS VARCHAR(50)) + '''
						OR COALESCE(cca.contract_end_date, cg.term_end) BETWEEN''' + CAST(@date_from AS VARCHAR(50)) + ''' AND ''' + CAST(@date_to AS VARCHAR(50)) + '''
				) OR (
						''' + CAST(@date_from AS VARCHAR(50)) + ''' BETWEEN COALESCE(cca.contract_start_date, cg.term_start) AND COALESCE(cca.contract_end_date, cg.term_end)
						OR ''' + CAST(@date_to AS VARCHAR(50)) + ''' BETWEEN COALESCE(cca.contract_start_date, cg.term_start) AND COALESCE(cca.contract_end_date, cg.term_end)
				))
				AND ISNULL(sc.int_ext_flag,''e'') = ISNULL('''+@counterparty_type+''',''e'')  
				AND COALESCE(cca.contract_active, cg.is_active,''n'') = ''y'' AND COALESCE(sc.is_active,''n'') = ''y''
				'+ CASE WHEN @counterparty_id <> '' THEN ' AND sc.source_counterparty_id IN('+@counterparty_id+')' ELSE '' END +'
				'+ CASE WHEN @contract_id <> '' THEN ' AND cg.contract_id IN('+@contract_id+')' ELSE '' END +'
				'+ CASE WHEN @commodity <> '' THEN ' AND cg.commodity = '+ @commodity ELSE '' END 
		END

		SET @sql= @sql + '
		) a
		WHERE 1 = 1
		'+ CASE WHEN @meter_id <> '' THEN ' AND a.meter_id IN('+@meter_id+')' ELSE '' END +'
		'+ CASE WHEN @deal_id <> '' THEN ' AND a.source_deal_header_id IN('+@deal_id+')' ELSE '' END +'
		GROUP BY source_counterparty_id,counterparty_name,contract_id '
	 EXEC(@sql)

--******************************************************            
--END of source book map table and build index            
--*********************************************************        

IF @flag = 'g'
BEGIN
	SET @sql = 'SELECT	sc.counterparty_name [counterparty], 
						cg.[contract_name] [contract], 
						cca.contract_id [contract_id] , 
						cca.counterparty_id [counterparty_id]  
				FROM counterparty_contract_address cca
				INNER JOIN source_counterparty sc ON cca.counterparty_id = sc.source_counterparty_id
				INNER JOIN contract_group cg ON cca.contract_id = cg.contract_id
				WHERE 1=1 '

	IF @counterparty_type <> ''
		SET @sql = @sql + ' AND sc.int_ext_flag = ''' + @counterparty_type + ''''

	IF @subsidiary_id <> ''
		SET @sql = @sql + ' AND cg.sub_id = ' + CAST(@subsidiary_id AS VARCHAR) 
		
	EXEC(@sql)
END

ELSE IF @flag = 'c' OR @flag = 'd'
	BEGIN

		SET @sql = ' SELECT 
				MAX(civv.calc_id) calc_id,
				civv.invoice_number invoice_number,
				civv.counterparty_id,
				civv.contract_id,
				civv.Prod_date,
				civ.invoice_line_item_id,
				MAX(settlement_date) settlement_date,
				MAX(civv.Prod_date_to) Prod_date_to,
				civv.invoice_type
			INTO 
				#temp_calc_invoice
			FROM
				#temp_counterparty tc
				INNER JOIN calc_invoice_volume_variance civv ON civv.counterparty_id = tc.counterparty_id AND civv.contract_id = tc.contract_id
				CROSS APPLY (SELECT MAX(as_of_date) as_of_date,counterparty_id,contract_id,prod_date,Max(invoice_type) invoice_type,MAX(ISNULL(invoice_template_id,-1)) invoice_template_id 
					FROM calc_invoice_volume_variance WHERE counterparty_id = tc.counterparty_id AND contract_id = tc.contract_id '
					+ CASE WHEN @date_from IS NOT NULL AND @date_to IS NOT NULL THEN 
											CASE WHEN @date_type = 't' THEN ' AND prod_date BETWEEN '''+CONVERT(VARCHAR(10),@date_from,120)+''' AND '''+CONVERT(VARCHAR(10),@date_to,120)+'''' 
											ELSE ' AND settlement_date BETWEEN '''+CONVERT(VARCHAR(10),@date_from,120)+''' AND '''+CONVERT(VARCHAR(10),@date_to,120)+'''' END 
									  ELSE '' END
					+ ' GROUP BY counterparty_id,contract_id,prod_date
				) civv1
				INNER JOIN calc_invoice_volume civ on civ.calc_id = civv.calc_id
				LEFT JOIN calc_invoice_true_up citu ON citu.calc_id = civv.calc_id
			WHERE 1 = 1'

			IF @process_adjustment = 'y'
				SET @sql = @sql + ' AND civv.finalized = ''y'' AND citu.calc_id IS NULL AND citu.counterparty_id IS NULL'

			SET @sql = @sql +' AND civv.as_of_date = civv1.as_of_date
			GROUP BY civv.counterparty_id,civv.contract_id,civv.Prod_date,civ.invoice_line_item_id,civv.invoice_number,civv.invoice_type
		'
	

		SET @sql = @sql+ '
			;WITH CTE(term_start,term_end) AS (SELECT * FROM [FNATermBreakdown] (''m'','''+CONVERT(VARCHAR(10),@date_from,120)+''','''+CONVERT(VARCHAR(10),@date_to,120)+''')) '
		+ ' SELECT
						sc.counterparty_name [Counterparty], 
						cg.[contract_name] [Contract], '
						+ CASE WHEN @show_processed = 'n' THEN ' ISNULL(sdv.code, sdv_t.code) [Charge Type], ' ELSE ' tcv.invoice_number [Charge Type], ' END
						+ ' sc.source_counterparty_id [counterparty_id],
						cg.contract_id [contract_id], '
						+ CASE WHEN @show_processed = 'n' THEN ' MAX(ISNULL(cctd.invoice_line_item_id,cgd.invoice_line_item_id)) ' ELSE '''''' END +' [charge_type_id],'
						+ ' CONVERT(VARCHAR(10),'''+@as_of_date+''',120) AS [as_of_date],'
						+ CASE WHEN @show_processed = 'y' THEN 'dbo.FNAdateformat(CONVERT(VARCHAR(10),MIN(tcv.prod_date),120))' WHEN @flag = 'd' THEN '' ELSE 'dbo.FNAdateformat(MIN(CTE.term_start))' END + ' AS [Date From], '
						+ CASE WHEN @show_processed = 'y' THEN 'dbo.FNAdateformat(CONVERT(VARCHAR(10),MAX(tcv.prod_date_to),120))' WHEN @flag = 'd' THEN '' ELSE 'dbo.FNAdateformat(MAX(CTE.term_end))' END + ' AS [Date To], '+
						+ 'MAX(' + 'dbo.FNAdateformat('+ CASE WHEN @show_processed = 'y' THEN 'tcv.settlement_date' ELSE 'COALESCE(NULLIF(sdd.settlement_date,''1900-01-01''),cg_set_date.term_start,CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.deal_date ELSE sdd.term_start END)' END+ ')) settlement_date,
						tcv.invoice_number [Invoice Number],
						MAX(tcv.calc_id) calc_id,
						MAX(ih.invoice_id) inv_rec_id, tcv.invoice_type
					FROM	
						#temp_counterparty tc
						INNER JOIN source_counterparty sc ON tc.counterparty_id = sc.source_counterparty_id
						INNER JOIN contract_group cg ON tc.contract_id = cg.contract_id
						LEFT JOIN contract_group_detail cgd ON tc.contract_id = cgd.contract_id
						LEFT JOIN static_data_value sdv ON cgd.invoice_line_item_id = sdv.value_id
						LEFT JOIN contract_charge_type cct ON  cct.contract_charge_type_id=cg.contract_charge_type_id
						LEFT JOIN contract_charge_type_detail cctd ON  cctd.contract_charge_type_id=cct.contract_charge_type_id
						LEFT JOIN contract_charge_type_detail cctd1 ON cctd1.[ID] = cgd.contract_component_template
						LEFT JOIN static_data_value sdv_t on sdv_t.value_id = ISNULL(cctd1.invoice_line_item_id,cctd.invoice_line_item_id)						 
						LEFT JOIN source_deal_header sdh ON sdh.counterparty_id = tc.counterparty_id ' +CASE WHEN  @flag <> 'd' THEN ' AND 1=2 ' ELSE '' END +'
						LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
						LEFT JOIN CTE ON 1=1
								OUTER APPLY(SELECT 	CASE WHEN cg.settlement_date IS NOT NULL THEN dbo.FNAInvoiceDueDate(ISNULL(CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.deal_date ELSE sdd.term_start END,CTE.term_start),cg.settlement_date,cg.holiday_calendar_id,cg.settlement_days) ELSE NULL END term_start FROM contract_group 
								WHERE contract_id = cg.contract_id ) cg_set_date 
						LEFT JOIN #temp_calc_invoice tcv ON tcv.counterparty_id = tc.counterparty_id AND tcv.contract_id = tc.contract_id
							AND tcv.prod_date = CTE.term_start
							AND tcv.invoice_line_item_id = COALESCE(cgd.invoice_line_item_id,cctd1.invoice_line_item_id,cctd.invoice_line_item_id)
						LEFT JOIN invoice_header ih ON ih.counterparty_id = tc.counterparty_id
							AND ih.contract_id = tc.contract_id
							AND ih.production_month = ' + CASE WHEN @show_processed = 'y' THEN 'CONVERT(VARCHAR(10),tcv.prod_date,120)' WHEN @flag = 'd' THEN '' ELSE 'CONVERT(VARCHAR(10),'''+@date_from+''',120)' END + '
					WHERE 1=1 '
					IF @counterparty_type <> ''
						SET @sql = @sql + ' AND sc.int_ext_flag = ''' + @counterparty_type + ''''
					+ CASE WHEN @show_processed = 'y' THEN ' AND tcv.calc_id IS NOT NULL ' ELSE ' AND tcv.calc_id IS NULL' END
					+ CASE WHEN @date_from IS NOT NULL THEN CASE WHEN @show_processed = 'y' THEN ' AND CONVERT(VARCHAR(10),tcv.prod_date,120)' WHEN @flag = 'd' THEN '' ELSE ' AND CONVERT(VARCHAR(10),'''+@date_from+''',120)' END + ' >= '''+@date_from+'''' ELSE '' END
					+ CASE WHEN @date_to IS NOT NULL THEN CASE WHEN @show_processed = 'y' THEN ' AND CONVERT(VARCHAR(10),tcv.prod_date_to,120)' WHEN @flag = 'd' THEN '' ELSE ' AND CONVERT(VARCHAR(10),'''+@date_to+''',120)' END + ' <= '''+@date_to+'''' ELSE '' END
					+ ' GROUP BY sc.counterparty_name ,cg.[contract_name],'+ CASE WHEN @show_processed = 'n' THEN ' ISNULL(sdv.code, sdv_t.code) ' ELSE ' tcv.invoice_number' END	
					+ ',sc.source_counterparty_id,cg.contract_id,tcv.invoice_number,tcv.invoice_type order by sc.counterparty_name asc'

		EXEC(@sql)
	
	END

