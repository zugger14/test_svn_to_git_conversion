IF OBJECT_ID(N'[dbo].[spa_stmt_contract_calculation]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_stmt_contract_calculation]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 /**
	Calculation of formula setup in the contract

	Parameters :
	@as_of_date : Calculation As Of Date
	@term_start : Term Start Filter
	@term_end : Term End Filter
	@sub_id : Sub Id Filter
	@strategy_id : Strategy Id Filter
	@book_id : Book Id Filter
	@source_book_mapping_id : Source Book Mapping Id Filter
	@counterparty_id : Counterparty Id Filter
	@contract_id : Contract Id Filter
	@charge_type_id : Charge Type Id Filter
	@log_error : 0 -Error not logged in log table,1-Error logged in log table
	@batch_process_id : Batch Process Id
	@batch_report_param : Batch Report Param
 */

CREATE PROCEDURE [dbo].[spa_stmt_contract_calculation]
	@as_of_date DATETIME = NULL,
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@sub_id varchar(1000)=NULL,
	@strategy_id varchar(1000)=NULL,
	@book_id varchar(1000)=NULl,
	@source_book_mapping_id varchar (1000)=NULL,
	@counterparty_id VARCHAR(MAX) = NULL,
	@contract_id VARCHAR(MAX) = NULL,
	@charge_type_id VARCHAR(MAX) = NULL,
	@log_error BIT = 0,
	@batch_process_id VARCHAR(120) = NULL,
	@batch_report_param	varchar(5000) = NULL
AS 

/*
	SET nocount off	
	DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
	SET CONTEXT_INFO @contextinfo


	DECLARE
	@as_of_date VARCHAR(10) = NULL,
	@term_start VARCHAR(10) = NULL,
	@term_end VARCHAR(10) = NULL,
	@sub_id varchar(1000)=NULL,
	@strategy_id varchar(1000)=NULL,
	@book_id varchar(1000)=NULl,
	@source_book_mapping_id varchar (1000)=NULL,
	@counterparty_id VARCHAR(MAX) = NULL,
	@contract_id VARCHAR(MAX) = NULL,
	@charge_type_id VARCHAR(MAX) = NULL,
	@log_error BIT = 0,
	@batch_process_id	VARCHAR(120) = NULL,
	@batch_report_param	varchar(5000) = NULL

	SET @as_of_date='2020-06-30'
	SET @term_start='2020-06-01'
	SET @term_end='2020-06-30'
	SET @sub_id=NULl
	SET @strategy_id =NULL
	SET @book_id = NULL
	SET @counterparty_id = 10879
	SET @contract_id = NULL
	SET @charge_type_id = NULL
	SET @log_error =1
 
	IF OBJECT_ID('tempdb..#books') IS NOT NULL DROP TABLE #books
	IF OBJECT_ID('tempdb..#temp_formula') IS NOT NULL DROP TABLE #temp_formula
	IF OBJECT_ID('tempdb..#contract_detail') IS NOT NULL DROP TABLE #contract_detail
	IF OBJECT_ID('tempdb..#term_breakdown') IS NOT NULL DROP TABLE #term_breakdown
	IF OBJECT_ID('tempdb..#final_insert_output') IS NOT NULL DROP TABLE #final_insert_output
	IF OBJECT_ID('tempdb..#unprocessed_chargetypes') IS NOT NULL DROP TABLE #unprocessed_chargetypes


	
	
--*/

BEGIN TRY
  DECLARE @sqlstmt VARCHAR(MAX)
  DECLARE @formula_table VARCHAR(250)
  DECLARE @calc_result_table VARCHAR(250)
  DECLARE @calc_result_detail_table VARCHAR(250)
  DECLARE @user_login_id VARCHAR(100)
  DECLARE @desc VARCHAR(5000)
  DECLARE @total_time VARCHAR(100)
  DECLARE @calc_start_time  DATETIME 
  DECLARE @model_name VARCHAR(100)
  DECLARE @url VARCHAR(5000)
  DECLARE @error_warning VARCHAR(100)
  DECLARE @error_success CHAR(1)


	
	IF @batch_process_id IS NULL
		SET @batch_process_id = REPLACE(NEWID(), '-', '_')
	SET @calc_start_time = GETDATE()
	SET @user_login_id = dbo.FNADBUser()


--### Create temporary tables
	CREATE TABLE #books ( 
		sub_id INT,
		stra_id INT,
		book_id INT,
		book_deal_type_map_id INT,
		source_system_book_id1 INT,
		source_system_book_id2 INT,
		source_system_book_id3 INT,
		source_system_book_id4  INT
	) 


	CREATE TABLE #contract_detail(
		counterparty_id INT,
		contract_id INT
	)

	CREATE TABLE #temp_formula(
		counterparty_id INT,
		contract_id INT,
		charge_type_id INT,
		charge_type_sequence_number INT,	
		granularity INT,
		formula_id INT,
		formula_sequence_number INT,
		price FLOAT,		
		uom_id INT,
		currency_id INT,
		calc_aggregation INT
	)

	
	SET @sqlstmt = '
	INSERT INTO  #books(sub_id,stra_id,book_id,book_deal_type_map_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4)
	SELECT 
		 stra.parent_entity_id,stra.entity_id,sbm.fas_book_id,sbm.book_deal_type_map_id fas_book_id,sbm.source_system_book_id1,	sbm.source_system_book_id2,sbm.source_system_book_id3,sbm.source_system_book_id4
	FROM 
		portfolio_hierarchy book (nolock) 
		INNER JOIN	Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id 
		INNER JOIN	source_system_book_map sbm ON sbm.fas_book_id = book.entity_id  ' 
	
		+CASE WHEN @sub_id IS NOT NULL THEN  ' AND stra.parent_entity_id in ('+@sub_id + ')' ELSE '' END
		+CASE WHEN @strategy_id IS NOT NULL THEN  ' AND stra.entity_id in ('+@strategy_id + ')' ELSE '' END
		+CASE WHEN @book_id IS NOT NULL THEN  ' AND book.parent_entity_id in ('+@book_id + ')' ELSE '' END
		+CASE WHEN @source_book_mapping_id IS NOT NULL THEN  ' AND sbm.book_deal_type_map_id in ('+@source_book_mapping_id + ')' ELSE '' END

	EXEC spa_print @sqlstmt
	EXEC(@sqlstmt)

	SET @sqlstmt = ' INSERT INTO #contract_detail(counterparty_id,contract_id)
		SELECT 
			DISTINCT cca.counterparty_id,cca.contract_id
		FROM 
			counterparty_contract_address cca '
			+ CASE WHEN @counterparty_id IS NOT NULL THEN ' INNER JOIN dbo.SplitCommaSeperatedValues('+@counterparty_id+') a ON a.[item] = cca.counterparty_id' ELSE '' END
			+ CASE WHEN @contract_id IS NOT NULL THEN ' INNER JOIN dbo.SplitCommaSeperatedValues('+@contract_id+') b ON b.[item] = cca.contract_id' ELSE '' END

	EXEC spa_print @sqlstmt
	EXEC(@sqlstmt)




  	SET @sqlstmt = '
	INSERT INTO #temp_formula(counterparty_id,contract_id,charge_type_id,charge_type_sequence_number,granularity,formula_id,formula_sequence_number,price,uom_id,currency_id,calc_aggregation)
		SELECT 
			cd.counterparty_id counterparty_id,
			cd.contract_id,
			ISNULL(cgd.invoice_Line_item_id,cctd.invoice_Line_item_id) AS charge_type_id,
			cgd.sequence_order,
			COALESCE(fn.granularity,cgd.volume_granularity,cctd.volume_granularity,cg.volume_granularity,980) granularity,			
			COALESCE(cctd1.formula_id,cgd.formula_id,cctd.formula_id) formula_id,
			ISNULL(fn.sequence_order,0) sequence_number,
			ISNULL(cgd.price,cctd.price) AS price ,
			COALESCE(fn.uom_id,cg.volume_uom) uom_id,
			cg.currency currency_id,
			cgd.calc_aggregation
		FROM
			#contract_detail cd
			INNER JOIN contract_group cg ON cg.contract_id=cd.contract_id
			LEFT JOIN contract_group_detail cgd ON  cgd.contract_id=cg.contract_id
				AND '''+CAST(@as_of_date AS VARCHAR)+''' >= ISNULL(cgd.effective_date,''1900-01-01'')
			LEFT JOIN contract_charge_type cct ON  cct.contract_charge_type_id=cg.contract_charge_type_id
			LEFT JOIN contract_charge_type_detail cctd ON  cctd.contract_charge_type_id=cct.contract_charge_type_id
			LEFT JOIN contract_charge_type_detail cctd1 ON cctd1.[ID] = cgd.contract_component_template
			LEFT JOIN formula_editor fe ON  COALESCE(cctd1.formula_id,cgd.formula_id,cctd.formula_id)=fe.formula_id
			LEFT JOIN formula_nested fn ON  fe.formula_id=fn.formula_group_id
			LEFT JOIN formula_editor fe1 ON  fe1.formula_id=fn.formula_id
		WHERE 1=1 AND ISNULL(cgd.invoice_Line_item_id,cctd.invoice_Line_item_id)  IS NOT NULL 
			AND (COALESCE(cctd1.formula_id,cgd.formula_id,cctd.formula_id) IS NOT NULL OR ISNULL(cgd.price,cctd.price)  IS NOT NULL)
			'+CASE WHEN @charge_type_id IS NOT NULL THEN ' AND ISNULL(cgd.invoice_line_item_id,cctd.invoice_line_item_id) IN ('+@charge_type_id +')' ELSE '' END

	EXEC spa_print @sqlstmt
	EXEC(@sqlstmt)



	IF OBJECT_ID('tempdb..#tmp_calc_agg_details') IS NOT NULL
		DROP TABLE #tmp_calc_agg_details
	CREATE TABLE #tmp_calc_agg_details (
		counterparty_id			INT,
		contract_id				INT,
		charge_type_id			INT,
		source_deal_header_id	INT,
		source_deal_detail_id	INT
	)


	--SET @sqlstmt = '
	--	INSERT INTO #tmp_calc_agg_details (counterparty_id, contract_id, charge_type_id, source_deal_header_id, source_deal_detail_id)
	--	SELECT tmp.counterparty_id, tmp.contract_id, tmp.charge_type_id, sdh.source_deal_header_id, NULL source_deal_detail_id  
	--	FROM #temp_formula tmp
	--	INNER JOIN source_deal_header sdh ON sdh.counterparty_id = tmp.counterparty_id AND sdh.contract_id = tmp.contract_id 
	--			AND sdh.entire_term_start >= ''' + CAST(@term_start AS NVARCHAR) + ''' AND sdh.entire_term_end <= ''' + CAST(@term_end AS NVARCHAR) + '''
	--	WHERE tmp.calc_aggregation = 19000'
	--EXEC(@sqlstmt)

	SET @sqlstmt = '
		INSERT INTO #tmp_calc_agg_details (counterparty_id, contract_id, charge_type_id, source_deal_header_id, source_deal_detail_id)
		SELECT tmp.counterparty_id, tmp.contract_id, tmp.charge_type_id, sdh.source_deal_header_id, sdd.source_deal_detail_id  
		FROM #temp_formula tmp
		INNER JOIN source_deal_header sdh ON sdh.counterparty_id = tmp.counterparty_id AND sdh.contract_id = tmp.contract_id 
				AND sdh.entire_term_start >= ''' + CAST(@term_start AS NVARCHAR) + ''' AND sdh.entire_term_end <= ''' + CAST(@term_end AS NVARCHAR) + '''
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		WHERE tmp.calc_aggregation = 19002 OR tmp.calc_aggregation = 19000'
	EXEC(@sqlstmt)
	 


--########## Breadkdown data by granularity and populate formula input table
	SET @formula_table=dbo.FNAProcessTableName('contract_settlement', @user_login_id, @batch_process_id)

	SET @sqlstmt='
		CREATE TABLE '+@formula_table+'(
			rowid int identity(1,1),
			counterparty_id INT,
			contract_id INT,
			formula_id INT,
			prod_date DATETIME,
			as_of_date DATETIME,
			volume FLOAT,			
			invoice_Line_item_id INT,			
			invoice_line_item_seq_id INT,
			granularity INT,
			volume_uom_id INT,
			[Hour] INT,
			[mins] INT,
			source_deal_header_id INT,
			source_deal_detail_id INT
		)	'
		

	EXEC spa_print @sqlstmt
	EXEC(@sqlstmt)	



--######### Create Table #term_breakdown

		CREATE TABLE #term_breakdown(
			granularity INT,
			term_date DATETIME,
			[hour] INT,
			[period] INT,
			is_dst BIT
		)



		INSERT INTO #term_breakdown(granularity,term_date,[hour],[period],is_dst)
		SELECT a.granularity,term_start,DATEPART(HH,term_start) [hour],DATEPART(mi,term_start),is_dst period 
		FROM
		(SELECT DISTINCT granularity FROM  #temp_formula) a
		CROSS APPLY	dbo.FNATermBreakdownDST(
			CASE a.granularity WHEN 980 THEN 'm'
				 WHEN 981 THEN 'd'
				 WHEN 982 THEN 'h'
				 WHEN 989 THEN 't'
				 WHEN 987 THEN 'f'
				 WHEN 994 THEN 'r'
				 WHEN 995 THEN 'z'
				 ELSE 'm' END,@term_start,@term_end,NULL)

---################


		SET @sqlstmt='
			INSERT INTO '+@formula_table+'(counterparty_id,contract_id,formula_id,prod_date, as_of_date,volume,invoice_Line_item_id,invoice_line_item_seq_id,granularity,volume_uom_id,[Hour],[mins],source_deal_header_id,source_deal_detail_id)
			SELECT 	 
				tf.counterparty_id,
				tf.contract_id,
				tf.formula_id,
				tb.term_date,
				'''+CAST(@as_of_date AS VARCHAR)+''' as_of_date,
				NULL volume,
				tf.charge_type_id,
				tf.charge_type_sequence_number,
				tf.granularity,
				tf.uom_id,
				tb.hour [Hour],
				tb.period [mins],
				tmp.source_deal_header_id,
				tmp.source_deal_detail_id
			from  #temp_formula tf
			INNER JOIN #term_breakdown tb ON tb.granularity = tf.granularity
			LEFT JOIN #tmp_calc_agg_details tmp ON tmp.counterparty_id = tf.counterparty_id
					AND tmp.contract_id = tf.contract_id
					AND tmp.charge_type_id = tf.charge_type_id	
		'
		EXEC(@sqlstmt)

	    EXEC spa_calculate_formula	@as_of_date,@formula_table,@batch_process_id,@calc_result_table=@calc_result_table OUTPUT,@calc_result_detail_table = @calc_result_detail_table OUTPUT,@estimate_calculation = 'n',@formula_audit = 'n',@call_from= NULL,@simulation_curve_criteria = 0
--###### insert in final table

		CREATE TABLE #final_insert_output (
			stmt_contract_settlement_id INT,
			as_of_date DATETIME,
			counterparty_id INT,
			contract_id INT,
			charge_type_id INT,
			term_date DATETIME
		)
			
			

		SET @sqlstmt=' 
		INSERT INTO stmt_contract_settlement(as_of_date,counterparty_id,contract_id,charge_type_id,term_start,term_end,volume,value,volume_uom_id,currency_id)
		OUTPUT inserted.stmt_contract_settlement_id,inserted.as_of_date,inserted.counterparty_id,inserted.contract_id,inserted.charge_type_id,inserted.term_start INTO #final_insert_output
		SELECT
			calc.as_of_date,
			calc.counterparty_id,
			calc.contract_id,
			calc.invoice_line_item_id [contract_charge_type_id],
			CONVERT(VARCHAR(7),calc.prod_date,120)+''-01'' [term_start],
			CONVERT(VARCHAR(7),calc.prod_date,120)+''-01'' [term_End],
			SUM(calc.volume) volume,
			SUM(calc.formula_eval_value) value,
			MAX(tf.uom_id) uom_id,
			MAX(tf.currency_id) currency_id
		FROM 
			'+@calc_result_table+' calc
			INNER JOIN #temp_formula tf ON calc.counterparty_id = tf.counterparty_id 
				AND calc.contract_id = tf.contract_id 
				AND calc.invoice_line_item_id = tf.charge_type_id 
				AND calc.formula_id = tf.formula_id 
			LEFT JOIN stmt_contract_settlement cs ON cs.counterparty_id = calc.counterparty_id 
				AND cs.contract_id = calc.contract_id 
				AND cs.charge_type_id = calc.invoice_line_item_id 
				AND cs.term_start = CONVERT(VARCHAR(7),calc.prod_date,120)+''-01''
				AND cs.as_of_date = calc.as_of_date
		WHERE 
			calc.is_final_result = ''y''
			AND cs.stmt_contract_settlement_id IS NULL
		GROUP BY 
			calc.as_of_date,
			calc.counterparty_id,
			calc.contract_id,
			calc.invoice_line_item_id,
			CONVERT(VARCHAR(7),calc.prod_date,120)+''-01''
		'

		EXEC spa_print @sqlstmt
		EXEC(@sqlstmt)	

		--SET @sqlstmt=' 
		--	UPDATE cs
		--	SET
		--		cs.volume = calc.volume,
		--		cs.value= calc.formula_eval_value
		--	OUTPUT inserted.contract_settlement_id,inserted.as_of_date,inserted.counterparty_id,inserted.contract_id,inserted.charge_type_id,inserted.term_date INTO #final_insert_output
		--	FROM 
		--		#temp_formula tf 
		--		INNER JOIN index_fees_breakdown_settlement cs ON cs.counterparty_id = tf.counterparty_id 
		--			AND cs.contract_id = tf.contract_id 
		--			AND cs.contract_charge_type_id = tf.contract_charge_type_id 			
		--		CROSS APPLY(SELECT SUM(volume) volume,SUM(formula_eval_value) formula_eval_value FROM '+@calc_result_table+' calc WHERE
		--			calc.counterparty_id = cs.counterparty_id
		--			AND calc.contract_id = cs.contract_id 
		--			AND calc.invoice_line_item_id = cs.contract_charge_type_id 
		--			AND cs.as_of_date = calc.as_of_date
		--			AND CONVERT(VARCHAR(7),calc.prod_date,120)+''-01'' = cs.term_start
		--			AND calc.is_final_result = ''y'' 
		--		)calc '
				
		

		--EXEC spa_print @sqlstmt
		--EXEC(@sqlstmt)	
	
		
		SET @sqlstmt=' 
			INSERT INTO stmt_contract_settlement_detail(stmt_contract_settlement_id,term_date,hour,period,is_dst,formula_id,formula_squence,volume,value, source_deal_header_id, source_deal_detail_id)
			SELECT
				cs.stmt_contract_settlement_id,
				calc.prod_date,
				calc.[hour],
				calc.[mins],
				calc.is_dst,
				calc.formula_id,
				calc.formula_sequence_number,
				calc.volume,
				calc.formula_eval_value,
				calc.source_deal_header_id,
				calc.source_deal_detail_id
			FROM 
				'+@calc_result_table+' calc
				INNER JOIN  #final_insert_output cs ON cs.counterparty_id = calc.counterparty_id 
					AND cs.contract_id = calc.contract_id 
					AND cs.charge_type_id = calc.invoice_line_item_id 
					AND cs.term_date = CONVERT(VARCHAR(7),calc.prod_date,120)+''-01''
			WHERE 1=1
		'

		EXEC spa_print @sqlstmt
		EXEC(@sqlstmt)	
		

		IF @log_error = 1
		BEGIN
			SET @sqlstmt='
			INSERT INTO process_settlement_invoice_log
			(   
				process_id,
				code,
				module,
				counterparty_id,
				prod_date,
				[description],
				nextsteps	   
			)   
			SELECT DISTINCT
				'''+@batch_process_id+''',
				''Success'',
				''Contract Settlement'',
				sc.source_counterparty_id,
				fi.term_date,
				''Contract Calculation completed for Counterparty' +':''+sc.counterparty_name+'' And Contract'+':'' + ISNULL(cg.contract_name,'''') + '' for the Month:''+dbo.FNAGetcontractMonth(fi.term_date)+''.'',
				''N/A''
			FROM   
				#final_insert_output fi
				INNER JOIN source_counterparty sc ON sc.source_counterparty_id = fi.counterparty_id
				INNER JOIN contract_group cg on cg.contract_id =fi.contract_id
				INNER JOIN stmt_contract_settlement cs ON cs.stmt_contract_settlement_id = fi.contract_settlement_id ' +
				CASE WHEN @charge_type_id IS NOT NULL THEN 'INNER JOIN dbo.FNASplit(''' + @charge_type_id + ''', '','') f ON cs.charge_type_id = f.item ' ELSE '' END + '
			WHERE 1=1 ' 
			EXEC(@sqlstmt)
		
		
			-- If any uprocessed charge types are found  Case 1 : processed selecting contract , Case 2 : processed selecting chargetypes
		
			CREATE TABLE #unprocessed_chargetypes(contract_id INT, chargetypes VARCHAR(1024) COLLATE DATABASE_DEFAULT)

			SET @sqlstmt = '
				INSERT INTO #unprocessed_chargetypes
					SELECT cct.contract_id, CAST(code AS VARCHAR(1024))
					 FROM (
					SELECT DISTINCT  cs.counterparty_id,cs.contract_id, cctd.invoice_line_item_id,
						   sdv.code
					FROM   #final_insert_output cs
						   INNER JOIN contract_group cg
								ON  cs.contract_id = cg.contract_id
						   LEFT JOIN contract_charge_type cct
								ON  cct.contract_charge_type_id = cg.contract_charge_type_id
						   LEFT JOIN contract_charge_type_detail cctd
								ON  cctd.contract_charge_type_id = cct.contract_charge_type_id
						   INNER JOIN static_data_value sdv
								ON  cctd.invoice_line_item_id = sdv.value_id
					WHERE  1 = 1
						   AND cctd.invoice_line_item_id IS NOT NULL
					UNION ALL    
					SELECT cs.counterparty_id,cs.contract_id, cgd.invoice_line_item_id,
						   sdv.code
					FROM   contract_group cg
						   INNER JOIN contract_group_detail cgd
								ON  cg.contract_id = cgd.contract_id AND ISNULL(cgd.is_true_up,''n'') = ''n''
						   INNER JOIN static_data_value sdv
								ON  cgd.invoice_line_item_id = sdv.value_id
						   INNER JOIN #final_insert_output cs
								ON  cs.contract_id = cg.contract_id
							--INNER JOIN calc_invoice_volume civ ON civ.calc_id = cs.calc_id AND civ.invoice_line_item_id = cgd.invoice_line_item_id
					) cct ' +
					CASE WHEN @charge_type_id IS NOT NULL THEN 'INNER JOIN dbo.FNASplit(''' + @charge_type_id + ''', '','') f ON cct.invoice_line_item_id = f.item ' ELSE '' END + '
					LEFT JOIN #final_insert_output csl ON csl.counterparty_id = cct.counterparty_id AND csl.contract_id = cct.contract_id AND csl.charge_type_id = cct.invoice_line_item_id 
				WHERE 
					csl.charge_type_id IS NULL 
	
			'
			EXEC (@sqlstmt)
		
			SET @sqlstmt = '
				INSERT INTO process_settlement_invoice_log
				(   
					process_id,
					code,
					module,
					counterparty_id,
					prod_date,
					[description],
					nextsteps	   
				)
				SELECT ''' + @batch_process_id + ''', ''Warning'', ''Contract Settlement'', cs.counterparty_id,dbo.FNAGetContractMonth(cs.term_date),
				CASE WHEN CHARINDEX('','', uc.chargetypes, 0) <> 0 THEN
				''Some charge types were not processed for counterparty:'' + sc.counterparty_name + '' and contract:'' + cg.[contract_name]  + ''.('' + uc.chargetypes + '')''
				ELSE uc.chargetypes + '' could not be processed for counterparty:'' + sc.counterparty_name + '' and contract:'' + cg.[contract_name]   END + '' for the production month:'' +  dbo.FNAGetcontractMonth(cs.term_date)
				, ''Please Check Data'' 
				FROM 
					#final_insert_output cs
					INNER JOIN #unprocessed_chargetypes uc ON cs.contract_id = uc.contract_id
					INNER JOIN contract_group cg ON cs.contract_id = cg.contract_id
					INNER JOIN source_counterparty sc on cs.counterparty_id = sc.source_counterparty_id  
				WHERE 
					uc.chargetypes IS NOT NULL '

			EXEC (@sqlstmt)
			



			SET @total_time=CAST(DATEPART(mi,getdate()-@calc_start_time) AS VARCHAR)+ ' min '+ CAST(DATEPART(s,getdate()-@calc_start_time) AS VARCHAR)+' sec'

			SET @error_warning = ''
			SET @error_success = 's'
			IF EXISTS(
				   SELECT 'X'
				   FROM   process_settlement_invoice_log
				   WHERE  process_id = @batch_process_id AND code IN ('Error', 'Warning')
			   )
			BEGIN
				SET @error_warning = ' <font color="red">(Warnings Found)</font>'
				SET @error_success = 'e'
			END
	
			SET @url = './dev/spa_html.php?__user_name__=''' + @user_login_id + '''&spa=exec spa_get_settlement_invoice_log ''' + @batch_process_id + ''''

			SET @desc = '<a target="_blank" href="' + @url + '">' +'Contract Settlement Processed:  As of Date  ' + dbo.FNAContractmonthFormat(@as_of_date)+ @error_warning+'.</a> (Elapsed Time: '+@total_time+')'	 

			EXEC spa_message_board 'u',
					 @user_login_id,
					 NULL,
					 'Contract Settlement ',
					 @desc,
					 '',
					 '',
					 @error_success,
					 @batch_process_id
		
		END


END TRY
BEGIN CATCH
		SET @desc =  'Error Found in Catch: ' + ERROR_MESSAGE()
		EXEC spa_print  @desc	


		IF @log_error = 1
		BEGIN
			SELECT @sqlstmt='
				INSERT INTO process_settlement_invoice_log
				(   
					process_id,
					code,
					module,
					counterparty_id,
					prod_date,
					[description],
					nextsteps	   
				)   
				SELECT
					'''+@batch_process_id+''',
					''Error'',
					''Process Settlement'',
					-1,
					dbo.FNAGetcontractMonth('''+CAST(@as_of_date AS VARCHAR)+'''),
					''Contract Settlement Procss Failed.'+REPLACE(@desc,'''','')+''',
					''Please Check data'''	
			EXEC(@sqlstmt) 

			EXEC spa_message_board 'u',
					 @user_login_id,
					 NULL,
					 'Contract Settlement ',
					 @desc,
					 '',
					 '',
					  'e',
					 @batch_process_id

		END
END CATCH