IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_calc_mtm_job_wrapper]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_calc_mtm_job_wrapper]
GO
/****** 
Object:  StoredProcedure [dbo].[spa_calc_mtm_job_wrapper]   
Written By: SHUSHIL BOHARA
			sbohara@pioneersolutionsglobal.com 
Script Date: 20-Dec-2012 
deal ids: 55,62,88118,119,128
******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 /**
	Simulate calculation of Marked to Market and settlement of deals in portfolio.

	Parameters : 
	@sub_id : Subsidiary filter for deals to process
	@strategy_id : Strategy filter for deals to process
	@book_id : Book filter for deals to process
	@source_book_mapping_id : Sub-book filter for deals to process
	@source_deal_header_id : Deal filter to process
	@as_of_date : Date for processing
	@curve_source_value_id : Source of curves to use in calculation
	@pnl_source_value_id : Source of curves to use in calculation
	@hedge_or_item : Instrument deals filter  to process
						 - 'h' - Hedge deal 
						 - 'i' - Item deal  
	@job_name : Provide job name to create
	@user_id : User name of runner
	@assessment_curve_type_value_id : Curve assessment type filter for curve that used in deal
	@table_name : Provide table name to output the process result.
	@print_diagnostic : Run Mode - 'y' - With Debug 'n' - Without Debug
	@curve_as_of_date : Date to price of curve for processing
	@tenor_option : Term Option - 'f' - Forward term only 'c' - Forward with current term
	@summary_detail : Result output glanularity - 's' - Summary 'd' - Detail
	@options_only : Option Deal Filter to process - 'y' - Option only 'n' - All deals
	@trader_id : Trader filter to process
	@status_table_name : Table to export for process status
	@run_incremental : Incremental run option - 'y' - Process only deal's curve price changed in given term 'n' - All deals
	@term_start : Term Start filter to process
	@term_end : Term end filter to process
	@calc_type : Calculation Type - 'm' - MTM 's' - Settlement 'x' - Credit Exposure 'b' - Broker fee
	@curve_shift_val : Curve shift value for whatif calculation
	@curve_shift_per : Curve shift percentage for whatif calculation
	@deal_list_table : Input list deal table filter for process
	@criteria_id : WHATIF parameter changed criteria ID.
	@counterparty_id : Counterparty filter to process
	@ref_id : Deal reference filter to process
	@calc_explain_type : Type delta explain calculation
						 - 'd' - Delivered 
						 - 'f' - Forecast 
						 - 'p' - Price changed 
	@transaction_type_id : Instrument deal type filter to process
	@portfolio_group_id : Instrument deal type filter to process
	@purge : Delete before save process result
	@batch_process_id : process id when run through batch
	@batch_report_param : paramater to run through barch

  */



CREATE PROCEDURE [dbo].[spa_calc_mtm_job_wrapper]
	@sub_id VARCHAR(MAX)=NULL,
	@strategy_id VARCHAR(MAX)=NULL,
	@book_id VARCHAR(MAX)=NULL,
	@source_book_mapping_id VARCHAR (MAX)=NULL,
	@source_deal_header_id VARCHAR (5000) =NULL,
	@as_of_date VARCHAR(100),
	@curve_source_value_id INT ,
	@pnl_source_value_id INT ,
	@hedge_or_item CHAR(1) ='h',
	@process_id VARCHAR(150)=NULL,
	@job_name VARCHAR(100)=NULL,
	@user_id VARCHAR(100)=NULL,
	@assessment_curve_type_value_id INT= 77,
	@table_name VARCHAR(250) = NULL,
	@print_diagnostic INT = NULL,
	@curve_as_of_date VARCHAR(100) = NULL,
	@tenor_option VARCHAR(1) = NULL,
	@summary_detail VARCHAR(1) = 's',
	@options_only VARCHAR(1) = NULL,
	@trader_id INT = NULL,
	@status_table_name VARCHAR(100) = NULL,
	@run_incremental CHAR(1) = NULL,------------
	@term_start VARCHAR(100) =NULL,
	@term_end VARCHAR(100) =NULL,
	@calc_type VARCHAR(1) = NULL, --'m' for mtm, 'w' for what if AND 's' for settlement, 'y' revaluation
	@curve_shift_val FLOAT = 0,
	@curve_shift_per FLOAT = 0, 
	@deal_list_table VARCHAR(200)=NULL, -- contains list of deals to be processed
	@criteria_id INT = -1,--(-1 for monte carlo simulation
	@counterparty_id NVARCHAR(1000)=NULL,--
	@ref_id VARCHAR(MAX) = NULL,--
	@calc_explain_type CHAR(1) = NULL, -- 'm'-> modified--
	@transaction_type_id VARCHAR(5000),
	@portfolio_group_id INT = NULL,
	@purge CHAR(1) = 'n',
	@trigger_workflow NCHAR(1) = 'y',
	@batch_process_id	VARCHAR(120) = NULL,--
	@batch_report_param	VARCHAR(5000) = NULL--
AS
--SELECT @calc_type, @as_of_date, @deal_list_table, @curve_source_value_id, @pnl_source_value_id, @portfolio_group_id, @transaction_type_id, @criteria_id
/*	
	declare @sub_id VARCHAR(100)=NULL,
	@strategy_id VARCHAR(100)=NULL,
	@book_id VARCHAR(100)=NULL,
	@source_book_mapping_id VARCHAR (100)=NULL,
	@source_deal_header_id VARCHAR (5000) =NULL,
	@as_of_date VARCHAR(100),
	@curve_source_value_id INT ,
	@pnl_source_value_id INT ,
	@hedge_or_item CHAR(1) ='h',
	@process_id VARCHAR(150)=NULL,
	@job_name VARCHAR(100)=NULL,
	@user_id VARCHAR(100)=NULL,
	@assessment_curve_type_value_id INT= 77,
	@table_name VARCHAR(250) = NULL,
	@print_diagnostic INT = NULL,
	@curve_as_of_date VARCHAR(100) = NULL,
	@tenor_option VARCHAR(1) = NULL,
	@summary_detail VARCHAR(1) = 's',
	@options_only VARCHAR(1) = NULL,
	@trader_id INT = NULL,
	@status_table_name VARCHAR(100) = NULL,
	@run_incremental CHAR(1) = NULL,------------
	@term_start VARCHAR(100) =NULL,
	@term_end VARCHAR(100) =NULL,
	@calc_type VARCHAR(1) = NULL, --'m' for mtm, 'w' for what if AND 's' for settlement
	@curve_shift_val FLOAT = 0,
	@curve_shift_per FLOAT = 0, 
	@deal_list_table VARCHAR(200)=NULL, -- contains list of deals to be processed
	@criteria_id INT = -1,--(-1 for monte carlo simulation
	@counterparty_id NVARCHAR(1000)=NULL,--
	@ref_id VARCHAR(200) = NULL,--
	@calc_explain_type CHAR(1) = NULL, -- 'm'-> modified--
	@purge CHAR(1) = 'n',
	@trigger_workflow NCHAR(1) = 'y',
	@batch_process_id	VARCHAR(120) = NULL,--
	@batch_report_param	VARCHAR(5000) = NULL,--
	@transaction_type_id VARCHAR(5000),
	@portfolio_group_id INT
	
select	@sub_id =NULL, 
            @strategy_id =null, 
            @book_id =null,
            @source_book_mapping_id =NULL,
            @source_deal_header_id = '1018',
            @as_of_date='2019-04-30', -- '2011-07-31'
            @curve_source_value_id= 10639,
            @pnl_source_value_id =NULL,
            @hedge_or_item ='b',
            @process_id =null, --'F60E7B51_DAB6_4FFE_A2E1_99BBCDC4619C_t9',
            @job_name =NULL,
            @user_id =NULL,
            @assessment_curve_type_value_id = NULL,
            @table_name  = NULL,
            @print_diagnostic  = NULL,
            @curve_as_of_date  =null , ---'2013-05-02',
            @tenor_option = NULL,
            @summary_detail  = NULL,
            @options_only  = NULL,
            @trader_id  = NULL,
            @status_table_name= NULL,
            @run_incremental = 'n',
            @term_start = '2019-06-01',
            @term_end  = '2019-06-30',
            @calc_type = 'm', --'s'
            @curve_shift_val = NULL,
            @curve_shift_per = null,
            @criteria_id = null,
            @deal_list_table =NULL, 
            @batch_process_id = NULL,
            @batch_report_param     = NULL,
            @transaction_type_id = '400,401',
            @portfolio_group_id = NULL
 
drop table #book	
drop table 	#as_of_date_point
drop table 	#process_as_of_date_point
drop table 	#mv90_dst
drop table 	#deal_header
drop table #deal_detail
drop table #report_hourly_position_breakdown
drop table #report_hourly_position_breakdown_detail
drop table #source_deal_delta_value
drop table #curve_granularity
drop table #spsd
DROP TABLE #bok
--*/


DECLARE @default_time_zone INT, @dst_group_value_id INT
SELECT @default_time_zone = var_value FROM dbo.adiha_default_codes_values (nolock) WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1

SELECT @dst_group_value_id = tz.dst_group_value_id FROM dbo.adiha_default_codes_values (nolock) adcv INNER JOIN time_zones tz
		ON tz.TIMEZONE_ID = adcv.var_value WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1

BEGIN TRY
	
	DECLARE @mtm_job VARCHAR(100), @Monte_Carlo_Curve_Source INT, @MTMProcessTableName VARCHAR(200),
			@tbl_name VARCHAR(200), @portfolio_deals VARCHAR(200), @st_sql NVARCHAR(MAX), @hedge_value VARCHAR(100),@mtm_process VARCHAR(100), 
			@mtm_as_of_date VARCHAR(100), @as_of_date_start DATETIME, @as_of_date_end DATETIME, @curve_date DATETIME,
			@module VARCHAR(100), @source VARCHAR(100), @errorcode VARCHAR(1), @is_warning VARCHAR(1)='n', @desc VARCHAR(500), @url VARCHAR(500),
			@url_desc VARCHAR(500), @no_of_simulation INT, @call_to NCHAR(1), @DEALDeltaTableName VARCHAR(200) 
	,@tbl_name_pos varchar(250)
	
	SET @call_to = 'n' -- 'n' => new, 'o' => old
	
	SET @module = 'MTM simulation'
	SET @source = 'MTM simulation'			
	SET @errorcode = 'e'
	
	IF @hedge_or_item = 'h'
		SET @hedge_value = '400,407,409'
	ELSE IF @hedge_or_item = 'i'	
		SET @hedge_value = '401'
	ELSE
		SET @hedge_value = '402,404,405,406,408,411,410'
				
	IF @process_id IS NULL
		SET @process_id = REPLACE(NEWID(), '-', '_')
		
	IF @user_id IS NULL	
		SET @user_id = dbo.fnadbuser()	

	SET @mtm_job = 'mtm_'+ @process_id
	SET @Monte_Carlo_Curve_Source = ISNULL(@curve_source_value_id, 4505)--For monte carlo simulations

	--MTM process table for returning simulation
	SET @MTMProcessTableName = dbo.FNAProcessTableName('MTM_sim', @user_id, @process_id)
	
	IF @table_name IS NULL
		SET @table_name = @MTMProcessTableName
		
	--@tbl_name - table for storing deals
	IF ISNULL(@tbl_name, '') = ''
		SET @tbl_name = dbo.FNAProcessTableName('std_deals', @user_id, @process_id)
		
	IF ISNULL(@tbl_name_pos,'')=''
		SET @tbl_name_pos = dbo.FNAProcessTableName('tbl_name_pos', @user_id, @process_id)
		
	IF ISNULL(@portfolio_deals, '') = ''
		SET @portfolio_deals = dbo.FNAProcessTableName('tbl_portfolio_deals', @user_id, @process_id)
		
	IF OBJECT_ID(@MTMProcessTableName) IS NOT NULL
		EXEC('DROP TABLE ' + @MTMProcessTableName)
	
	IF OBJECT_ID(@portfolio_deals) IS NOT NULL
		EXEC('DROP TABLE ' + @portfolio_deals)
			
	IF OBJECT_ID(@tbl_name) IS NOT NULL
		EXEC('DROP TABLE ' + @tbl_name)
	
	--EXEC('CREATE TABLE ' + @portfolio_deals + '(source_deal_header_id INT, real_deal VARCHAR(1)')		
	EXEC('CREATE TABLE ' + @tbl_name + '(source_deal_header_id INT, real_deal VARCHAR(1))')
	
		
	SELECT clm1_value curve_id,
		clm2_value granularity_id 
	INTO #curve_granularity 
	FROM generic_mapping_values g 
	INNER JOIN generic_mapping_header h ON g.mapping_table_id = h.mapping_table_id
		AND h.mapping_name = 'curve granularity' --and clm1_value='y'
 	
	CREATE TABLE #book
	(
		book_id                 INT,
		book_deal_type_map_id   INT,
		source_system_book_id1  INT,
		source_system_book_id2  INT,
		source_system_book_id3  INT,
		source_system_book_id4  INT,
		func_cur_id             INT
	)
	
	IF @deal_list_table IS NULL
	BEGIN
		--#book storing mapping entities for abstracting deals.
		SET @st_sql='
			INSERT INTO #book (
				book_id,
				book_deal_type_map_id,
				source_system_book_id1,
				source_system_book_id2,
				source_system_book_id3,
				source_system_book_id4,
				func_cur_id 
				)		
			SELECT
				book.entity_id,
				book_deal_type_map_id,
				source_system_book_id1,
				source_system_book_id2,
				source_system_book_id3,
				source_system_book_id4,
				fs.func_cur_value_id
			FROM source_system_book_map sbm            
				INNER JOIN portfolio_hierarchy book (NOLOCK) ON book.entity_id = sbm.fas_book_id
				INNER JOIN Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
				INNER JOIN Portfolio_hierarchy sb (NOLOCK) ON stra.parent_entity_id = sb.entity_id 
				LEFT JOIN fas_subsidiaries fs ON  sb.entity_id = fs.fas_subsidiary_id
			WHERE 1=1  '
			+ CASE WHEN @sub_id IS NULL THEN '' ELSE ' AND sb.entity_id IN (' + @sub_id + ')' END
			+ CASE WHEN @strategy_id IS NULL THEN '' ELSE ' AND stra.entity_id IN (' + @strategy_id + ')' END
			+ CASE WHEN @book_id IS NULL THEN '' ELSE ' AND book.entity_id IN (' + @book_id + ')' END
			+ CASE WHEN @source_book_mapping_id IS NULL THEN '' ELSE ' AND sbm.book_deal_type_map_id IN (' + @source_book_mapping_id + ')' END
			
			+ CASE WHEN @transaction_type_id IS NOT NULL THEN ' AND sbm.fas_deal_type_value_id IN (' + @transaction_type_id + ')' 
													ELSE ' AND (sbm.fas_deal_type_value_id NOT IN (' + @hedge_value + '))'
												END	
					
		exec spa_print @st_sql	
		EXEC(@st_sql)
		
		--Collecting deals from Portfolio
		EXEC spa_collect_mapping_deals @as_of_date, 23202, @portfolio_group_id, @portfolio_deals
		
		DECLARE @book_structure CHAR(1) = 0
		
		SET @book_structure = CASE WHEN COALESCE(@sub_id,@strategy_id,@book_id,@source_book_mapping_id,@source_deal_header_id,@ref_id) IS NOT NULL THEN 1 ELSE 0 END
		
		--Collecting deal from Different Sources
		SET @st_sql = '
			INSERT INTO ' + @tbl_name + '(source_deal_header_id,real_deal)
			SELECT DISTINCT tpd.source_deal_header_id, 
				tpd.real_deal
			FROM ' + @portfolio_deals + ' tpd
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = tpd.source_deal_header_id'
			+ CASE WHEN  @source_deal_header_id IS NULL THEN '' ELSE ' AND sdh.source_deal_header_id IN (' + @source_deal_header_id + ')' END
			+ CASE WHEN  @ref_id IS NULL THEN '' ELSE ' AND sdh.deal_id IN (''' + REPLACE(@ref_id, ',', ''', ''') + ''')' END + '
			UNION
			SELECT 
				DISTINCT sdh.source_deal_header_id,
				''y''
			FROM source_deal_header sdh 
			INNER JOIN #book sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 
				AND sdh.source_system_book_id2 = sbm.source_system_book_id2 
				AND sdh.source_system_book_id3 = sbm.source_system_book_id3 
				AND sdh.source_system_book_id4 = sbm.source_system_book_id4
				AND 1 = ' + @book_structure + ' 
				AND sdh.deal_date <= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
				AND sdh.entire_term_end >= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''''
			+ CASE WHEN  @source_deal_header_id IS NULL THEN '' ELSE ' AND sdh.source_deal_header_id IN (' + @source_deal_header_id + ')' END
			+ CASE WHEN  @ref_id IS NULL THEN '' ELSE ' AND sdh.deal_id IN (''' + REPLACE(@ref_id, ',', ''', ''') + ''')' END 
				
		exec spa_print @st_sql
		EXEC(@st_sql)
	END
	ELSE
	BEGIN
		SET @tbl_name = @deal_list_table
	END	
		
	--check no of deals passed and if curve id is null for single passed deal raise error
	DECLARE @no_of_deals_passed INT
	SELECT @no_of_deals_passed = LEN(@source_deal_header_id) - LEN(REPLACE(@source_deal_header_id, ',', '')) + 1
	
	IF @no_of_deals_passed = 1 AND EXISTS(SELECT TOP 1 1 FROM source_deal_detail 
	                                      WHERE source_deal_header_id = @source_deal_header_id AND curve_id IS NULL)
	BEGIN
		INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
		SELECT  @process_id, 'Error', @module, @source, 'MTM simulation', ' Curve ID has not been set for deal: ', 'Please check data.'
		RAISERROR ('CatchError', 16, 1)
	END

	--Assigned value in @as_of_date_start and @as_of_date_end
	IF OBJECT_ID('tempdb..##tmp_curve_id') IS NOT NULL
	DROP TABLE ##tmp_curve_id
	IF OBJECT_ID('tempdb..##tmp_spcm') IS NOT NULL
	DROP TABLE ##tmp_spcm
	
	DECLARE @pt_sql1 VARCHAR(5000), @pt_sql2 VARCHAR(5000)
	SET @pt_sql1 = ' select distinct spcd.source_curve_def_id curve1,spcd1.source_curve_def_id curve2,spcd2.source_curve_def_id curve3,spcd3.source_curve_def_id curve4 
	    into ##tmp_curve_id
	    FROM dbo.source_deal_detail sdd
		INNER JOIN ' + @tbl_name + ' tn ON sdd.source_deal_header_id = tn.source_deal_header_id 
		LEFT JOIN dbo.source_price_curve_def spcd WITH(NOLOCK) ON spcd.source_curve_def_id = sdd.curve_id
		LEFT JOIN dbo.source_price_curve_def spcd1 WITH(NOLOCK) ON spcd.proxy_source_curve_def_id = spcd1.source_curve_def_id	
		LEFT JOIN dbo.source_price_curve_def spcd2 WITH(NOLOCK) ON spcd.monthly_index = spcd2.source_curve_def_id
		LEFT JOIN dbo.source_price_curve_def spcd3 WITH(NOLOCK) ON spcd.proxy_curve_id3 = spcd3.source_curve_def_id'
	EXEC spa_print @pt_sql1
	EXEC (@pt_sql1)
	
	CREATE INDEX ix_pt_tmp_spcd ON ##tmp_curve_id(curve1,curve2,curve3,curve4)	

	--    FROM dbo.source_deal_detail sdd
	--	INNER JOIN ' + @tbl_name + ' tn ON sdd.source_deal_header_id = tn.source_deal_header_id 
	--	LEFT JOIN dbo.source_price_curve_def spcd WITH(NOLOCK) ON spcd.source_curve_def_id = sdd.curve_id
	--	LEFT JOIN dbo.source_price_curve_def spcd1 WITH(NOLOCK) ON spcd.proxy_source_curve_def_id = spcd1.source_curve_def_id	
	--	LEFT JOIN dbo.source_price_curve_def spcd2 WITH(NOLOCK) ON spcd.monthly_index = spcd2.source_curve_def_id
	--	LEFT JOIN dbo.source_price_curve_def spcd3 WITH(NOLOCK) ON spcd.proxy_curve_id3 = spcd3.source_curve_def_id
	
	SET @as_of_date_start = '1900-01-01'
	
	SET @pt_sql2 = 'SELECT DISTINCT 
						as_of_date, source_curve_def_id INTO ##tmp_spcm 
	                FROM ' + CASE @call_to WHEN 'o' THEN 'dbo.source_price_curve_simulation ' ELSE CASE WHEN @calc_type = 'y' THEN 'dbo.source_price_simulation_delta_whatif' ELSE 'dbo.source_price_simulation_delta ' END END
		+ ' WHERE curve_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + ' and run_date = ''' + CAST(@as_of_date AS VARCHAR) + '''' +
		CASE WHEN @calc_type = 'y' THEN ' AND criteria_id = ' + CAST(@criteria_id AS VARCHAR) + '' ELSE '' END
			
	EXEC spa_print @pt_sql2
	EXEC (@pt_sql2)

	CREATE INDEX ix_pt_spc1 on ##tmp_spcm (as_of_date, source_curve_def_id)	
	
	SET @st_sql='SELECT @as_of_date_end = MIN(as_of_date) FROM (
		SELECT a.curve1, MAX(coalesce(spcm.as_of_date, spcm1.as_of_date, spcm2.as_of_date, spcm3.as_of_date)) as_of_date
		from ##tmp_curve_id a
		LEFT JOIN ##tmp_spcm spcm WITH(NOLOCK) ON a.curve1 = spcm.source_curve_def_id   
			--AND spcm.curve_source_value_id = ' + cast(@Monte_Carlo_Curve_Source as varchar) + '
			--AND spcm.run_date = ''' + CAST(@as_of_date AS VARCHAR) + '''
		LEFT JOIN ##tmp_spcm spcm1 WITH(NOLOCK) ON a.curve2 = spcm1.source_curve_def_id
			--AND spcm1.curve_source_value_id = ' + cast(@Monte_Carlo_Curve_Source as varchar) + '
			--AND spcm1.run_date = ''' + CAST(@as_of_date AS VARCHAR) + '''
		LEFT JOIN ##tmp_spcm spcm2 WITH(NOLOCK) ON a.curve3 = spcm2.source_curve_def_id
			--AND spcm2.curve_source_value_id = ' + cast(@Monte_Carlo_Curve_Source as varchar) + '
			--AND spcm2.run_date = ''' + CAST(@as_of_date AS VARCHAR) + '''
		LEFT JOIN ##tmp_spcm spcm3 WITH(NOLOCK) ON a.curve4 = spcm3.source_curve_def_id
			--AND spcm3.curve_source_value_id = ' + cast(@Monte_Carlo_Curve_Source as varchar) + '
			--AND spcm3.run_date = ''' + CAST(@as_of_date AS VARCHAR) + '''
		GROUP BY a.curve1) date_point
		option (hash join)'
	
	EXEC sp_executesql @st_sql, N'@as_of_date_end DATETIME OUT', @as_of_date_end OUT	
	
	--SET @as_of_date_end = '1900-1-10'
	--select dateadd(day, 1000, '1900-1-1')
	IF @as_of_date_end IS NULL
	BEGIN 
		INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
		SELECT  @process_id, 'Error', @module, @source, 'MTM simulation', ' Price curve simulation not found for as of date: ' 
		+ dbo.FNADateFormat(@as_of_date), 'Please check data.'
		RAISERROR ('CatchError', 16, 1)
	END
	
	--SET @as_of_date_end = '1902-09-28'
	--SELECT DATEADD(DAY, 1000, '1900-1-1')
	--Storing total no of simulation
	SELECT @no_of_simulation = DATEDIFF(DAY, @as_of_date_start, ISNULL(@as_of_date_end, @as_of_date_start)) +1
	--Collecting as_of_date_points
	CREATE TABLE #as_of_date_point (Row_id INT IDENTITY(1, 1), as_of_date DATETIME);
	
	WITH user_rec(as_of_date, cnt)AS
	(
		SELECT CAST(@as_of_date_start AS DATE) , 0 AS cnt
		UNION ALL 
		SELECT DATEADD(DAY, (cnt+1), CAST(@as_of_date_start AS DATE)), cnt + 1 FROM user_rec r 
		WHERE cnt + 1 < @no_of_simulation --no of simulations
	)
	INSERT INTO #as_of_date_point (as_of_date)
	SELECT as_of_date FROM user_rec
	OPTION (MAXRECURSION 0)
	-- old approach start
	IF @call_to = 'o'
	BEGIN
		-- MTM calculation started
		SET @mtm_as_of_date = CONVERT(VARCHAR(10), @as_of_date, 120)
		DECLARE b_cursor CURSOR FOR
			SELECT  as_of_date FROM #as_of_date_point	
		OPEN b_cursor
		FETCH NEXT FROM b_cursor INTO @curve_date
		WHILE @@FETCH_STATUS = 0   
		BEGIN 
			SET @mtm_process = @process_id
			SET @mtm_job = 'mtm_'+ @mtm_process
			
			SET @st_sql = '[dbo].[spa_calc_mtm_job] 
				@sub_id = NULL,
				@strategy_id = NULL,
				@book_id = NULL,
				@source_book_mapping_id = NULL,
				@source_deal_header_id  = NULL,
				@as_of_date = ''' + @mtm_as_of_date +''',
				@curve_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) +',
				@pnl_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) +',
				@hedge_or_item = ''h'',
				@process_id = ''' + @process_id + ''',
				@job_name = ''' + @mtm_job + ''',
				@user_id = ''' + ISNULL(@user_id, 'null') + ''',
				@assessment_curve_type_value_id = 77,
				@table_name = ''' +  @MTMProcessTableName + ''',
				@print_diagnostic = NULL,
				@curve_as_of_date = ''' + CAST(CONVERT(VARCHAR(10), @curve_date, 120) AS VARCHAR) + ''',
				@tenor_option = NULL,
				@summary_detail = ''s'',
				@options_only = NULL,
				@trader_id = NULL,
				@status_table_name = NULL,
				@term_start = ''' + @mtm_as_of_date + ''',
				@term_end = ''' + @mtm_as_of_date + ''',
				@calc_type = ''v'',
				@curve_shift_val = NULL,
				@curve_shift_per = NULL, 
				@trigger_workflow = ''' + @trigger_workflow + '''
				@deal_list_table = ''' + @tbl_name + ''',
				@criteria_id = ''-1'''-- @criteria_id=-1 for monte carlo vAR
				
			exec spa_print @st_sql
			EXEC(@st_sql)	
			EXEC spa_print 'END [spa_calc_mtm_job] '
			FETCH NEXT FROM b_cursor INTO @curve_date
		END
		CLOSE b_cursor
		DEALLOCATE  b_cursor

		IF @purge = 'y'
			DELETE FROM [dbo].[var_simulation_data] WHERE run_date <= CAST(@as_of_date AS VARCHAR)
		ELSE
		BEGIN
			SET @st_sql = '
			DELETE 
				[dbo].[var_simulation_data] 
			FROM 
				[dbo].[var_simulation_data] m
			INNER JOIN ' + @MTMProcessTableName + ' mtm on m.pnl_as_of_date = mtm.pnl_as_of_date
				AND m.source_deal_header_id = mtm.source_deal_header_id
				AND m.run_date = ''' + CAST(@as_of_date AS VARCHAR) + ''''
		
			exec spa_print @st_sql		
			EXEC(@st_sql)	
		END		
		
		SET @st_sql = 'INSERT INTO [dbo].[var_simulation_data] (
			run_date,
			source_deal_header_id,
			term_start,
			term_end,
			Leg,
			pnl_as_of_date,
			und_pnl,
			und_intrinsic_pnl,
			und_extrinsic_pnl,
			dis_pnl,
			dis_intrinsic_pnl,
			dis_extrinisic_pnl,
			pnl_source_value_id,
			pnl_currency_id,
			pnl_conversion_factor,
			pnl_adjustment_value,
			deal_volume,
			create_user,
			create_ts,
			update_user,
			update_ts,
			und_pnl_set,
			market_value,
			contract_value,
			dis_market_value,
			dis_contract_value
		)
		SELECT
			''' + CAST(@as_of_date AS VARCHAR) + ''',  
			source_deal_header_id,
			term_start,
			term_end,
			Leg,
			pnl_as_of_date,
			und_pnl,
			und_intrinsic_pnl,
			und_extrinsic_pnl,
			dis_pnl,
			dis_intrinsic_pnl,
			dis_extrinisic_pnl,
			pnl_source_value_id,
			pnl_currency_id,
			pnl_conversion_factor,
			pnl_adjustment_value,
			deal_volume,
			create_user,
			create_ts,
			update_user,
			update_ts,
			und_pnl_set,
			market_value,
			contract_value,
			dis_market_value,
			dis_contract_value
		FROM ' + @MTMProcessTableName
			
		exec spa_print @st_sql
		EXEC(@st_sql)
		
		IF EXISTS(SELECT TOP 1 1 FROM MTM_TEST_RUN_LOG WHERE code = 'Error' AND process_id = @process_id)
		BEGIN 
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
			SELECT  @process_id, 'Error', @module, @source, 'mtm_err', ' MTM Simulation(s) error found for : ' 
			+ dbo.FNADateFormat(@as_of_date), 'Please check data.'
			RAISERROR ('CatchError', 16, 1)
		END

	END
	ELSE -- @call_to = 'n'
	BEGIN --new approach block start
		SELECT source_commodity_id,
			   [year],
			   CASE WHEN (source_commodity_id = -1) THEN DATEADD(DAY, -1, [date])
					ELSE [date]
			   END [date],
			   CASE WHEN (source_commodity_id = -1) THEN 21
					ELSE [hour]
			   END [hour],
			   [date] [fin_date],
			   [hour] [fin_hour]
			   INTO #mv90_dst
		FROM   mv90_dst dst
			   CROSS JOIN source_commodity
		WHERE  insert_delete = 'i' 
			AND dst_group_value_id = @dst_group_value_id
		
		--new approach block start
		DECLARE @baseload_block_type       VARCHAR(10)
		DECLARE @baseload_block_define_id  VARCHAR(10)--,@orginal_summary_option CHAR(1)
		DECLARE @position_detail  VARCHAR(150)
		DECLARE @st1 VARCHAR(MAX), @st2 VARCHAR(MAX), @st3 VARCHAR(MAX)
		DECLARE @deal_level VARCHAR(1)
		
		SET  @position_detail = dbo.FNAProcessTableName('explain_position_detail', @user_id, @process_id)
		SET @deal_level = 'y' --report include deal id WHEN @run_mode=2
		SET @baseload_block_type = '12000'	-- Internal Static Data
		SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10)) FROM  static_data_value WHERE [TYPE_ID] = 10018 AND code LIKE 'Base Load' -- External Static Data

		IF @baseload_block_define_id IS NULL
			SET @baseload_block_define_id = 'NULL'

		CREATE TABLE #deal_header
		(
			book_id                 INT,
			source_deal_header_id   INT,
			create_ts               DATETIME,
			deal_id                 VARCHAR(150) COLLATE DATABASE_DEFAULT ,
			source_system_book_id1  INT,
			source_system_book_id2  INT,
			source_system_book_id3  INT,
			source_system_book_id4  INT,
			book_deal_type_map_id   INT,
			broker_id               INT,
			profile_id              INT,
			deal_type_id            INT,
			trader_id               INT,
			contract_id             INT,
			product_id              INT,
			template_id             INT,
			deal_status_id          INT,
			counterparty_id         INT
		)

		CREATE TABLE #deal_detail
		(
			source_deal_detail_id     INT,
			source_deal_header_id     INT,
			term_start                date,
			term_end                  date,
			curve_id                  INT,
			location_id               INT,
			fixed_price               FLOAT,
			leg                       INT,
			index_id                  INT,
			pvparty_id                INT,
			uom_id                    INT,
			physical_financial_flag   VARCHAR(1) COLLATE DATABASE_DEFAULT ,
			buy_sell_Flag             VARCHAR(1) COLLATE DATABASE_DEFAULT ,
			Category_id               INT,
			user_toublock_id          INT,
			toublock_id               INT,
			create_ts                 DATETIME,
			deal_volume               NUMERIC(38, 20),
			fixed_cost                FLOAT,
			contract_expiration_date  DATETIME,
			commodity_id              INT,
			price_multiplier          FLOAT,
			formula_curve_id          INT
		)

		SET @st_sql = '
		INSERT INTO #deal_header
		  (
			book_id,
			source_deal_header_id,
			create_ts,
			deal_id,
			source_system_book_id1,
			source_system_book_id2,
			source_system_book_id3,
			source_system_book_id4,
			book_deal_type_map_id,
			broker_id,
			profile_id,
			deal_type_id,
			trader_id,
			contract_id,
			product_id,
			template_id,
			deal_status_id,
			counterparty_id
		  )
		SELECT ssbm.fas_book_id,
			   s.source_deal_header_id,
			   s.create_ts,
			   deal_id,
			   s.source_system_book_id1,
			   s.source_system_book_id2,
			   s.source_system_book_id3,
			   s.source_system_book_id4,
			   ssbm.book_deal_type_map_id,
			   s.broker_id,
			   s.internal_desk_id profile_id,
			   s.source_deal_type_id deal_type_id,
			   s.trader_id,
			   s.contract_id,
			   s.product_id,
			   s.template_id,
			   s.deal_status deal_status_id,
			   s.counterparty_id
		FROM   source_deal_header s(NOLOCK)
			   INNER JOIN ' + @tbl_name + ' t
					ON  s.source_deal_header_id = t.source_deal_header_id
			   LEFT JOIN source_system_book_map ssbm
					ON  s.source_system_book_id1 = ssbm.source_system_book_id1
					AND s.source_system_book_id2 = ssbm.source_system_book_id2
					AND s.source_system_book_id3 = ssbm.source_system_book_id3
					AND s.source_system_book_id4 = ssbm.source_system_book_id4
		'
		
		EXEC(@st_sql)

		SET @st_sql = '
		INSERT INTO #deal_detail
		  (
			source_deal_detail_id,
			source_deal_header_id,
			term_start,
			term_end,
			curve_id,
			location_id,
			fixed_price,
			leg,
			index_id,
			pvparty_id,
			uom_id,
			physical_financial_flag,
			buy_sell_Flag,
			Category_id,
			user_toublock_id,
			toublock_id,
			create_ts,
			deal_volume,
			fixed_cost,
			contract_expiration_date,
			commodity_id,
			price_multiplier,
			formula_curve_id
		  )
		SELECT s.source_deal_detail_id,
			   s.source_deal_header_id,
			   s.term_start,
			   s.term_end,
			   s.curve_id,
			   ISNULL(s.location_id, -1) location_id,
			   s.fixed_price,
			   s.leg,
			   spcd.source_curve_def_id index_id,
			   s.pv_party pvparty_id,
			   ISNULL(spcd.display_uom_id, spcd.uom_id) uom_id,
			   s.physical_financial_flag,
			   s.buy_sell_flag,
			   s.Category Category_id,
			   ISNULL(spcd1.udf_block_group_id, spcd.udf_block_group_id) 
			   user_toublock_id,
			   ISNULL(spcd1.block_define_id, spcd.block_define_id) toublock_id,
			   s.create_ts,
			   s.deal_volume,
			   s.fixed_cost,
			   s.contract_expiration_date,
			   spcd.commodity_id commodity_id,
			   ISNULL(s.price_multiplier, 1) * ISNULL(dpbd.simple_for_multiplier, 1) 
			   price_multiplier,
			   s.formula_curve_id
		FROM   source_deal_detail s(NOLOCK)
			   INNER JOIN ' + @tbl_name + ' t
					ON  s.source_deal_header_id = t.source_deal_header_id
			'+case when @term_start is not null then ' and s.term_start>='''+@term_start+'''' else '' end
			+case when @term_end is not null then ' and s.term_end<='''+@term_end +'''' else '' end+'
			   INNER JOIN source_price_curve_def spcd(NOLOCK)
					ON  spcd.source_curve_def_id = s.curve_id
			   LEFT JOIN source_price_curve_def spcd1(NOLOCK)
					ON  spcd1.source_curve_def_id = spcd.proxy_curve_id
			   OUTER APPLY(
			SELECT TOP(1) simple_for_multiplier
			FROM   deal_position_break_down
			WHERE  source_deal_detail_id = s.source_deal_detail_id
		) dpbd
		'

		exec spa_print @st_sql
		EXEC(@st_sql)

		CREATE INDEX indx_deal_detail_aaa ON #deal_detail( source_deal_header_id,curve_id,location_id,term_start ,term_end)
		CREATE INDEX indx_deal_header_aaa ON #deal_header( source_deal_header_id)
		CREATE INDEX indx_deal_detail_aaaxx ON #deal_detail( source_deal_detail_id)


		SELECT rowid = IDENTITY(INT, 1, 1),
			   u.[curve_id],
			   u.[term_start],
			   u.expiration_date,
			   u.deal_volume_uom_id,
			   sdh.book_id,
			   MAX(ISNULL(spcd1.udf_block_group_id, spcd.udf_block_group_id)) 
			   [user_toublock_id],
			   MAX(ISNULL(spcd1.block_define_id, spcd.block_define_id)) [toublock_id],
			   MAX(u.formula) formula,
			   u.term_end,
			   SUM(u.calc_volume) calc_volume,
			   u.counterparty_id,
			   u.commodity_id,
			   u.physical_financial_flag,
			   sdh.book_deal_type_map_id,
			   CAST(CASE WHEN @deal_level = 'y' THEN sdh.[source_deal_header_id]
						 ELSE NULL
				   END AS INT
			   ) [source_deal_header_id]
			   INTO #report_hourly_position_breakdown
		FROM   report_hourly_position_breakdown u(NOLOCK)
			   INNER JOIN [deal_status_group] dsg
					ON  dsg.status_value_id = u.deal_status_id -- AND u.deal_date<=@as_of_date
			   INNER JOIN #deal_header sdh
					ON  u.source_deal_header_id = sdh.source_deal_header_id -- AND ISNULL(sdh.product_id,4101)<>4100 
			   LEFT JOIN source_price_curve_def spcd(NOLOCK)
					ON  spcd.source_curve_def_id = u.curve_id
			   LEFT JOIN source_price_curve_def spcd1(NOLOCK)
					ON  spcd1.source_curve_def_id = spcd.proxy_curve_id
		GROUP BY
			   u.[curve_id],
			   u.[term_start],
			   u.expiration_date,
			   u.deal_volume_uom_id,
			   sdh.book_id,
			   u.term_end,
			   u.counterparty_id,
			   u.commodity_id,
			   u.physical_financial_flag,
			   sdh.book_deal_type_map_id,
			   CAST(CASE WHEN @deal_level = 'y' THEN sdh.[source_deal_header_id]
						 ELSE NULL
				   END AS INT
			   )

		SELECT s.rowid,CAST(hb.term_date AS DATE) term_start
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr1,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr1
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr2,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr2
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr3,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr3
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr4,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr4
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr5,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr5
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr6,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr6
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr7,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr7
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr8,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr8
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr9,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr9
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr10,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr10
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr11,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr11
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr12,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr12
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr13,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr13
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr14,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr14
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr15,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr15
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr16,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr16
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr17,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr17
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr18,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr18
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr19,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr19
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr20,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr20
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr21,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr21
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr22,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr22
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr23,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr23
			,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr24,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr24
			,(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=0 THEN 0 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10))) /CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) AS Hr25 
			,CASE WHEN s.formula IN('dbo.FNACurveH','dbo.FNACurveD') THEN ISNULL(hg.exp_date,hb.term_date) 
				  WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date)
				  ELSE s.expiration_date 
			 END expiration_date
		INTO #report_hourly_position_breakdown_detail
		FROM #report_hourly_position_breakdown s  (NOLOCK) 
			LEFT JOIN source_price_curve_def spcd WITH (NOLOCK) ON spcd.source_curve_def_id=s.curve_id  
			LEFT JOIN source_price_curve_def spcd1 (NOLOCK) ON spcd1.source_curve_def_id=spcd.settlement_curve_id
			LEFT JOIN time_zones tz ON COALESCE(spcd.time_zone,spcd1.time_zone,@default_time_zone) = tz.TIMEZONE_ID
			OUTER APPLY 
			(
				SELECT SUM(volume_mult) term_no_hrs FROM hour_block_term hbt WHERE ISNULL(spcd.hourly_volume_allocation,17601) <17603 AND hbt.block_define_id=COALESCE(spcd.block_define_id,@baseload_block_define_id)	
				AND  hbt.block_type = COALESCE(spcd.block_type,12000) AND hbt.term_date BETWEEN s.term_start  AND s.term_END  
				AND hbt.dst_group_value_id = tz.dst_group_value_id
			) term_hrs
			OUTER APPLY 
			( 
				SELECT SUM(volume_mult) term_no_hrs FROM hour_block_term hbt INNER JOIN 
				(
					SELECT DISTINCT exp_date FROM holiday_group h WHERE  h.hol_group_value_id = ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) AND h.exp_date BETWEEN s.term_start  AND s.term_END 
				) ex ON ex.exp_date = hbt.term_date
				WHERE  ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) AND hbt.block_define_id = COALESCE(spcd.block_define_id,@baseload_block_define_id)	
				AND  hbt.block_type = COALESCE(spcd.block_type,12000) AND hbt.term_date BETWEEN s.term_start  AND s.term_END
				AND hbt.dst_group_value_id = tz.dst_group_value_id
			) term_hrs_exp
			LEFT JOIN hour_block_term hb (NOLOCK) ON hb.block_define_id = COALESCE(spcd.block_define_id,@baseload_block_define_id)
				AND  hb.block_type=COALESCE(spcd.block_type,12000) AND hb.term_date BETWEEN s.term_start  AND s.term_end  
				AND hb.dst_group_value_id = tz.dst_group_value_id
			OUTER APPLY 
			(
				SELECT MAX(exp_date) exp_date FROM holiday_group h WHERE h.hol_date = hb.term_date AND 
				h.hol_group_value_id = ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) AND h.hol_date BETWEEN s.term_start  AND s.term_END 
				AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 
			) hg   
			OUTER APPLY 
			(
				SELECT MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  FROM holiday_group h WHERE h.hol_group_value_id = ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) AND h.hol_date BETWEEN s.term_start  AND s.term_END AND s.formula NOT IN('REBD')
			) hg1   
			OUTER APPLY
			(
				SELECT count(exp_date) total_days,SUM(CASE WHEN h.exp_date > @as_of_date THEN 1 ELSE 0 END) remain_days FROM holiday_group h WHERE h.hol_group_value_id = ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
					AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
					AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN('REBD')
			) remain_month  
			WHERE 
			((ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,'9999-01-01') > @as_of_date ) OR COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800)
				AND (
					(ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) AND  hg.exp_date IS NOT NULL) 
					OR (ISNULL(spcd.hourly_volume_allocation,17601) < 17603 )
				)	 
				AND CASE  WHEN s.formula IN('dbo.FNACurveH','dbo.FNACurveD') THEN ISNULL(hg.exp_date,hb.term_date) 
						WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date)
						ELSE s.expiration_date 
				  END > @as_of_date
				AND   hb.term_date>@as_of_date


		DECLARE @hr_columns VARCHAR(MAX),@fin_columns VARCHAR(MAX),@phy_columns VARCHAR(MAX),@delta_hr_columns VARCHAR(MAX)

		SET @fin_columns = 'h.counterparty_id,h.[curve_id],h.expiration_date,h.deal_volume_uom_id,h.book_id,e.[term_start],h.commodity_id,h.[physical_financial_flag],h.book_deal_type_map_id,h.[source_deal_header_id]' 

		SET @phy_columns = 'sdd.source_deal_detail_id,sdh.counterparty_id,e.[curve_id],e.expiration_date,e.deal_volume_uom_id,sdh.book_id,e.[term_start],sdd.commodity_id,e.[physical_financial_flag],sdh.book_deal_type_map_id ,sdh.[source_deal_header_id]'

		SET @hr_columns = ',e.hr1,e.hr2,e.hr3,e.hr4,e.hr5,e.hr6,e.hr7,e.hr8,e.hr9,e.hr10,e.hr11,e.hr12,e.hr13,e.hr14,e.hr15,e.hr16,e.hr17,e.hr18,e.hr19,e.hr20,e.hr21 ,e.hr22 ,e.hr23,e.hr24,e.hr25,e.hr25 dst_hr'

		SET @st1 = '
			SELECT ROWID = IDENTITY(INT,1,1),u.source_deal_detail_id,u.counterparty_id,u.[curve_id],u.term_start,u.book_deal_type_map_id,[physical_financial_flag],u.deal_volume_uom_id,u.[book_id]
			,CASE WHEN CAST(SUBSTRING(hr,3,2) AS INT) =25 THEN CASE WHEN u.formula_breakdown=0 THEN dst.[hour] ELSE dst.fin_hour END
			ELSE 	
				CAST(SUBSTRING(u.hr,3,2) AS INT) 
			END Hr
			,SUM(CASE WHEN u.expiration_date > ''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''' AND u.[term_start] > '''+CONVERT(VARCHAR(10),@as_of_date,120) + ''' 
					THEN u.Volume ELSE 0 END- CASE WHEN dst.[hour]=CAST(SUBSTRING(u.hr,3,2) AS INT) THEN ISNULL(u.dst_hr,0) ELSE 0 END ) Position
			, DATEADD(HOUR,	CASE WHEN CAST(SUBSTRING(hr,3,2) AS INT) = 25 THEN dst.[hour] ELSE CAST(SUBSTRING(u.hr,3,2) AS INT) END -1,CAST(u.[term_start] AS DATETIME)) [Maturity_hr]
			,CAST(CONVERT(VARCHAR(8),u.[term_start],120)+''01'' AS DATE) [Maturity_mnth]
			,CAST(CONVERT(VARCHAR(5),u.[term_start],120)+ CAST(CASE DATEPART(q, u.term_start) WHEN 1 THEN 1 WHEN 2 THEN 4 WHEN 3 THEN 7 WHEN 4 THEN 10 END as VARCHAR)+''-01'' AS DATE) [Maturity_qtr] 
			,CAST(CONVERT(VARCHAR(5),u.[term_start],120)+ CAST(CASE WHEN month(u.term_start) < 7 THEN 1 ELSE 7 END as VARCHAR)+''-01'' AS DATE) [Maturity_semi] 
			,CAST(CONVERT(VARCHAR(5),u.[term_start],120)+ ''01-01'' AS DATE) [Maturity_yr],MAX(u.formula_breakdown) formula_breakdown,u.commodity_id
			,CASE WHEN CAST(SUBSTRING(u.hr,3,2) AS INT)=25 THEN 1 ELSE 0 END dst,u.[source_deal_header_id]
			INTO ' + @position_detail
			
		SET @st2 = '	FROM 
			(
				SELECT ' + @phy_columns + '
					,SUM(e.hr1) hr1,SUM(e.hr2) hr2 ,SUM(e.hr3) hr3 ,SUM(e.hr4) hr4 ,SUM(e.hr5) hr5 ,SUM(e.hr6) hr6 ,SUM(e.hr7) hr7 ,SUM(e.hr8) hr8
					,SUM(e.hr9) hr9 ,SUM(e.hr10) hr10 ,SUM(e.hr11) hr11 ,SUM(e.hr12) hr12 ,SUM(e.hr13) hr13 ,SUM(e.hr14) hr14 ,SUM(e.hr15) hr15 ,SUM(e.hr16) hr16
					,SUM(e.hr17) hr17 ,SUM(e.hr18) hr18 ,SUM(e.hr19) hr19 ,SUM(e.hr20) hr20 ,SUM(e.hr21 ) hr21 ,SUM(e.hr22 ) hr22 ,SUM(e.hr23) hr23 ,SUM(e.hr24) hr24,SUM(e.hr25) hr25,SUM(e.hr25) dst_hr
					,0 formula_breakdown
				FROM [dbo].[report_hourly_position_profile] e (NOLOCK) 
				INNER JOIN #deal_header sdh  ON e.source_deal_header_id=sdh.source_deal_header_id 
				INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = sdh.deal_status_id 
					AND e.expiration_date > ''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''' AND e.[term_start] > ''' + CONVERT(VARCHAR(10),@as_of_date,120) + '''
				inner JOIN  #deal_detail sdd  ON e.term_start BETWEEN sdd.term_start AND sdd.term_end 
					AND e.source_deal_detail_id=sdd.source_deal_detail_id
				GROUP BY ' + @phy_columns + ',CAST(CONVERT(VARCHAR(10),sdh.create_ts,120) AS DATE)
			UNION ALL
				SELECT '+ @phy_columns +'
					,SUM(e.hr1) hr1,SUM(e.hr2) hr2 ,SUM(e.hr3) hr3 ,SUM(e.hr4) hr4 ,SUM(e.hr5) hr5 ,SUM(e.hr6) hr6 ,SUM(e.hr7) hr7 ,SUM(e.hr8) hr8
						,SUM(e.hr9) hr9 ,SUM(e.hr10) hr10 ,SUM(e.hr11) hr11 ,SUM(e.hr12) hr12 ,SUM(e.hr13) hr13 ,SUM(e.hr14) hr14 ,SUM(e.hr15) hr15 ,SUM(e.hr16) hr16
						,SUM(e.hr17) hr17 ,SUM(e.hr18) hr18 ,SUM(e.hr19) hr19 ,SUM(e.hr20) hr20 ,SUM(e.hr21 ) hr21 ,SUM(e.hr22 ) hr22 ,SUM(e.hr23) hr23 ,SUM(e.hr24) hr24,SUM(e.hr25) hr25,SUM(e.hr25) dst_hr
					,0 formula_breakdown
				FROM [dbo].[report_hourly_position_deal] e (NOLOCK)  INNER JOIN ' + @tbl_name + ' t ON e.[source_deal_header_id]=t.source_deal_header_id 
					AND e.expiration_date > ''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''' AND e.[term_start] > ''' + CONVERT(VARCHAR(10),@as_of_date,120) + '''
				INNER JOIN #deal_header sdh  ON e.source_deal_header_id=sdh.source_deal_header_id -- AND ISNULL(sdh.product_id,4101)<>4100 
				INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = sdh.deal_status_id 
				inner JOIN #deal_detail sdd  ON e.term_start BETWEEN sdd.term_start AND sdd.term_end 
					AND e.source_deal_detail_id=sdd.source_deal_detail_id
				GROUP BY '+@phy_columns+',CAST(CONVERT(VARCHAR(10),sdh.create_ts,120) AS DATE)
			UNION ALL
				SELECT '+ @phy_columns +'
					,SUM(e.hr1) hr1,SUM(e.hr2) hr2 ,SUM(e.hr3) hr3 ,SUM(e.hr4) hr4 ,SUM(e.hr5) hr5 ,SUM(e.hr6) hr6 ,SUM(e.hr7) hr7 ,SUM(e.hr8) hr8
						,SUM(e.hr9) hr9 ,SUM(e.hr10) hr10 ,SUM(e.hr11) hr11 ,SUM(e.hr12) hr12 ,SUM(e.hr13) hr13 ,SUM(e.hr14) hr14 ,SUM(e.hr15) hr15 ,SUM(e.hr16) hr16
						,SUM(e.hr17) hr17 ,SUM(e.hr18) hr18 ,SUM(e.hr19) hr19 ,SUM(e.hr20) hr20 ,SUM(e.hr21 ) hr21 ,SUM(e.hr22 ) hr22 ,SUM(e.hr23) hr23 ,SUM(e.hr24) hr24,SUM(e.hr25) hr25,SUM(e.hr25) dst_hr
					,1 formula_breakdown
				FROM [dbo].[report_hourly_position_financial] e (NOLOCK)  INNER JOIN ' + @tbl_name + ' t ON e.[source_deal_header_id]=t.source_deal_header_id 
					AND e.expiration_date > ''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''' AND e.[term_start] > ''' + CONVERT(VARCHAR(10),@as_of_date,120) + '''
				INNER JOIN #deal_header sdh  ON e.source_deal_header_id=sdh.source_deal_header_id -- AND ISNULL(sdh.product_id,4101)<>4100 
				INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = sdh.deal_status_id 
				inner JOIN  #deal_detail sdd  ON e.term_start BETWEEN sdd.term_start AND sdd.term_end 
					AND e.source_deal_detail_id=sdd.source_deal_detail_id
				GROUP BY '+@phy_columns+',CAST(CONVERT(VARCHAR(10),sdh.create_ts,120) AS DATE)	
			UNION ALL
				SELECT db.source_deal_detail_id,'+ @fin_columns + @hr_columns + ',1 formula_breakdown FROM #report_hourly_position_breakdown_detail e
					LEFT JOIN #report_hourly_position_breakdown h ON h.rowid=e.rowid
				cross APPLY (
						SELECT DISTINCT dpbd.source_deal_detail_id
						FROM deal_position_break_down dpbd
						inner join #deal_detail sdd on sdd.source_deal_detail_id = dpbd.source_deal_detail_id                                     
						WHERE dpbd.source_deal_header_id=h.source_deal_header_id
						AND dpbd.curve_id=h.curve_id AND ((e.term_start BETWEEN dpbd.fin_term_start AND dpbd.fin_term_end AND dpbd.formula = ''dbo.FNALagCurve'') 
							OR (e.term_start between sdd.term_start and sdd.term_end AND  isnull(dpbd.formula,'''') <> ''dbo.FNALagCurve''))
				) db			
				'
			
		SET @st3 = '
			
			) p
				UNPIVOT
					(Volume for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25)
			)AS u 
			LEFT JOIN source_price_curve_def spcd ON u.curve_id = spcd.source_curve_def_id
			LEFT JOIN #mv90_dst dst ON dst.source_commodity_id = u.commodity_id 
				AND u.term_start=CASE WHEN u.formula_breakdown=0 THEN dst.date ELSE dst.fin_date END
			WHERE Volume <> 0 AND ( CASE WHEN CAST(SUBSTRING(hr,3,2) AS INT) = 25 THEN CASE WHEN u.formula_breakdown=0 THEN dst.[hour] ELSE dst.fin_hour END
										 ELSE CAST(SUBSTRING(u.hr,3,2) AS INT) 	
									END) IS NOT NULL
			GROUP BY u.source_deal_detail_id,u.[curve_id],u.term_start,u.book_deal_type_map_id,[physical_financial_flag] ,u.deal_volume_uom_id,u.[book_id],u.counterparty_id
			,CASE WHEN CAST(SUBSTRING(hr,3,2) AS INT) = 25 THEN CASE WHEN u.formula_breakdown = 0 THEN dst.[hour] ELSE dst.fin_hour END
				  ELSE CAST(SUBSTRING(u.hr,3,2) AS INT) 
			 END , DATEADD(hour, CASE WHEN CAST(SUBSTRING(hr,3,2) AS INT) = 25 THEN dst.[hour] ELSE CAST(SUBSTRING(u.hr,3,2) AS INT) END -1,CAST(u.[term_start] AS DATETIME))
			,u.commodity_id,CASE WHEN CAST(SUBSTRING(u.hr,3,2) AS INT)=25 THEN 1 ELSE 0 END,u.[source_deal_header_id]'
			
			
		EXEC spa_print @st1	
		EXEC spa_print @st2 
		EXEC spa_print @st3
		EXEC(@st1+ @st2 + @st3)		
			
		--SET @st1 = 'CREATE INDEX indx_11sss1_' + @process_id + ' ON ' + @position_detail + '(source_deal_detail_id)'
		--EXEC(@st1)

		--SET @st1 = 'CREATE INDEX indx_111_' + @process_id + ' ON ' + @position_detail + '(curve_id,term_start,hr)'
		--EXEC(@st1)

		--SET @st1 = 'CREATE INDEX indx_111aa_' + @process_id + ' ON ' + @position_detail + '(rowid)'
		--EXEC(@st1) 

		SET @st1 = 'CREATE INDEX indx_222_' + @process_id + ' ON ' + @position_detail + '(curve_id)'
		EXEC(@st1)
		SET @st1 = 'CREATE INDEX ix_pt_indddd_111_' + @process_id + '  ON ' + @position_detail + ' ([curve_id]) INCLUDE ([source_deal_detail_id], [counterparty_id], [term_start], [physical_financial_flag], [deal_volume_uom_id], [book_id], [Position], [Maturity_hr], [Maturity_mnth], [Maturity_qtr], [Maturity_semi], [Maturity_yr], [formula_breakdown], [dst], [source_deal_header_id])'
		EXEC(@st1)

		IF @purge = 'y'
			IF @calc_type = 'y'
			BEGIN
				DELETE FROM [dbo].[source_deal_delta_value_whatif] 
				WHERE run_date < CAST(@as_of_date AS VARCHAR)
				AND pnl_source_value_id = @Monte_Carlo_Curve_Source

				DELETE FROM [dbo].[source_deal_delta_value_whatif] 
				WHERE run_date = CAST(@as_of_date AS VARCHAR) 
				AND criteria_id = @criteria_id
				AND pnl_source_value_id = @Monte_Carlo_Curve_Source
			END
			ELSE
				DELETE FROM [dbo].[source_deal_delta_value] 
				WHERE run_date <= CAST(@as_of_date AS VARCHAR)
				AND pnl_source_value_id = @Monte_Carlo_Curve_Source
		ELSE
		BEGIN
			IF @calc_type = 'y'
				DELETE s FROM [source_deal_delta_value_whatif] s WHERE s.run_date = @as_of_date AND s.criteria_id = @criteria_id
			ELSE
				DELETE s 
				FROM [source_deal_delta_value] s 
				INNER JOIN #deal_header h ON s.source_deal_header_id = h.source_deal_header_id 
					AND run_date = @as_of_date
					AND pnl_source_value_id = @Monte_Carlo_Curve_Source	
		END	


		--Deal delta process table for storing final simulation
		CREATE TABLE #source_deal_delta_value(
			[run_date] [datetime] NULL,
			[as_of_date] [datetime] NULL,
			[source_deal_detail_id] [int] NULL,
			[source_deal_header_id] [int] NULL,
			[curve_id] [int] NULL,
			[term_start] [datetime] NULL,
			[term_end] [datetime] NULL,
			[physical_financial_flag] [varchar](20) COLLATE DATABASE_DEFAULT  NULL,
			[counterparty_id] [int] NULL,
			[Position] [float] NULL,
			[market_value_delta] [float] NULL,
			[contract_value_delta] [float] NULL,
			[avg_value] [float] NULL,
			[delta_value] [float] NULL,
			[avg_delta_value] [float] NULL,
			[dis_market_value_delta] [float] NULL,
			[dis_contract_value_delta] [float] NULL,
			[dis_avg_value] [float] NULL,
			[dis_delta_value] [float] NULL,
			[dis_avg_delta_value] [float] NULL,
			[currency_id] INT NULL,
			[pnl_source_value_id] INT NULL,
			[formula_curve_id] INT NULL,
			curve_value FLOAT,
			formula_curve_value FLOAT,
			leg INT
		)
CREATE TABLE #process_as_of_date_point(as_of_date DATETIME)
		 SELECT * INTO #spsd FROM source_price_simulation_delta WHERE 1 = 2
		 
	CREATE INDEX [IX_PT_spsd] ON  #spsd ([run_date], [curve_source_value_id]) INCLUDE ([source_curve_def_id], [as_of_date], [maturity_date])--, [rep_row_id])
	CREATE INDEX [IX_PT_spsd1] ON #spsd ([run_date], [source_curve_def_id], [as_of_date], [curve_source_value_id], [maturity_date]) INCLUDE ([is_dst], [curve_value_avg], [curve_value_delta], [curve_value_avg_delta])
	CREATE INDEX [IX_PT_spsd2] ON #spsd ([run_date], [curve_source_value_id]) INCLUDE ([source_curve_def_id], [as_of_date])
	CREATE INDEX [IX_PT_spsd3] ON #spsd ([run_date], [source_curve_def_id]) INCLUDE ([as_of_date], [Assessment_curve_type_value_id], [curve_source_value_id], [maturity_date], [is_dst], [curve_value_main], [curve_value_sim], [curve_value_avg], [curve_value_delta], [curve_value_avg_delta], [create_user], [create_ts])
	

	SET @st2='
		SELECT p.* INTO '+@tbl_name_pos+' FROM dbo.source_price_curve_Def spcd (NOLOCK)
			
			CROSS APPLY 
			( 
			select a.book_id,a.curve_id,a.source_deal_detail_id,a.counterparty_id,a.source_deal_header_id
				,max(a.deal_volume_uom_id) deal_volume_uom_id,
				CASE WHEN spcd.Granularity in( 982) then 
					case when g.granularity_id=993 then dateadd(hour,datepart(hour,a.maturity_hr),cast(a.maturity_yr as datetime) )
						when g.granularity_id=992 then dateadd(hour,datepart(hour,a.maturity_hr),cast(a.maturity_semi as datetime)) 
						when g.granularity_id=991 then dateadd(hour,datepart(hour,a.maturity_hr),cast(a.maturity_qtr as datetime)) 
						when g.granularity_id=980 then dateadd(hour,datepart(hour,a.maturity_hr),cast(a.maturity_mnth as datetime)) 
					else a.maturity_hr end else null end maturity_hr,
				CASE WHEN spcd.Granularity in(982, 981) then 
					case when g.granularity_id=993 then a.maturity_yr
						when g.granularity_id=992 then a.maturity_semi
						when g.granularity_id=991 then a.maturity_qtr 
						when g.granularity_id=980 then a.maturity_mnth
					else a.term_start end else a.maturity_mnth end term_start,
				CASE WHEN spcd.Granularity in(993,982,981,980 ) then a.maturity_mnth else null end maturity_mnth,
				CASE WHEN spcd.Granularity in(982,981,980, 991) then a.maturity_qtr else null end maturity_qtr,
				CASE WHEN spcd.Granularity in( 982,981,980,991, 992) then a.maturity_semi else null end maturity_semi,
				CASE WHEN spcd.Granularity in( 982,981,980,991, 992,993) then a.maturity_yr else null end maturity_yr,
				CASE WHEN spcd.Granularity = 982 THEN case when g.granularity_id in (993,992,991,980) THEN 0 ELSE dst END ELSE 0 END dst,
				physical_financial_flag,formula_breakdown ,sum(Position) Position
			  from '+@position_detail+' a left join #curve_granularity g on g.curve_id=a.curve_id
			  where a.curve_id=spcd.source_curve_def_id
			group by
				a.book_id,a.curve_id,a.source_deal_detail_id,a.counterparty_id,a.physical_financial_flag,a.formula_breakdown,a.source_deal_header_id,
				CASE WHEN spcd.Granularity in( 982) then 
					case when g.granularity_id=993 then dateadd(hour,datepart(hour,a.maturity_hr),cast(a.maturity_yr as datetime) )
						when g.granularity_id=992 then dateadd(hour,datepart(hour,a.maturity_hr),cast(a.maturity_semi as datetime)) 
						when g.granularity_id=991 then dateadd(hour,datepart(hour,a.maturity_hr),cast(a.maturity_qtr as datetime)) 
						when g.granularity_id=980 then dateadd(hour,datepart(hour,a.maturity_hr),cast(a.maturity_mnth as datetime)) 
					else a.maturity_hr end else null end,
				CASE WHEN spcd.Granularity in(982, 981) then 
					case when g.granularity_id=993 then a.maturity_yr
						when g.granularity_id=992 then a.maturity_semi
						when g.granularity_id=991 then a.maturity_qtr 
						when g.granularity_id=980 then a.maturity_mnth
					else a.term_start end else a.maturity_mnth end,
				CASE WHEN spcd.Granularity in(993,982,981,980) then maturity_mnth else null end ,
				CASE WHEN spcd.Granularity in(  982,981,980,991) then maturity_qtr else null end ,
				CASE WHEN spcd.Granularity in(  982,981,980,991, 992) then maturity_semi else null end ,
				CASE WHEN spcd.Granularity in( 982,981,980,991, 992,993) then maturity_yr else null end ,
				CASE WHEN spcd.Granularity = 982 THEN case when g.granularity_id in (993,992,991,980) THEN 0 ELSE dst END ELSE 0 END  
			) p
	'
	
	EXEC spa_print  @st2
	exec(@st2) 
	--exec( 'SELECT * FROM '+@tbl_name_pos +' order by curve_id,maturity_hr,term_start')
	--return
	SELECT distinct book_id, func_cur_id INTO #bok FROM  #book
	CREATE INDEX ix_pt_bok ON #bok(book_id, func_cur_id)

	SET @st1 = 'CREATE INDEX indx_333_' + @process_id + ' ON ' + @tbl_name_pos + '(curve_id)'
		EXEC(@st1)
		
		SET @st1 = 'CREATE INDEX indx_444_' + @process_id + ' ON ' + @tbl_name_pos + '(source_deal_detail_id)'
		EXEC(@st1)
		SET @st1 = 'CREATE INDEX indx_555_' + @process_id + ' ON ' + @tbl_name_pos + '(book_id)'
		EXEC(@st1)
		SET @st1 = 'CREATE INDEX indx_666_' + @process_id + ' ON ' + @tbl_name_pos + '(maturity_hr)'
		EXEC(@st1)
		SET @st1 = 'CREATE INDEX indx_777_' + @process_id + ' ON ' + @tbl_name_pos + '(term_start)'
		EXEC(@st1)
		SET @st1 = 'CREATE INDEX indx_888_' + @process_id + ' ON ' + @tbl_name_pos + '(maturity_mnth)'
		EXEC(@st1)
		SET @st1 = 'CREATE INDEX indx_999_' + @process_id + ' ON ' + @tbl_name_pos + '(maturity_qtr)'
		EXEC(@st1)

		SET @st1 = 'CREATE INDEX indx_11111_' + @process_id + ' ON ' + @tbl_name_pos + '(maturity_semi)'
		EXEC(@st1)
		SET @st1 = 'CREATE INDEX indx_22222_' + @process_id + ' ON ' + @tbl_name_pos + '(maturity_yr)'
		EXEC(@st1)		
	
		loop_process_as_of_date:

		TRUNCATE TABLE #process_as_of_date_point
		TRUNCATE TABLE #spsd
		DELETE TOP(100) #as_of_date_point OUTPUT DELETED.as_of_date INTO #process_as_of_date_point
		
		IF @calc_type = 'y'
			INSERT INTO #spsd 
			SELECT a.run_date, a.source_curve_def_id, a.as_of_date, a.Assessment_curve_type_value_id, a.curve_source_value_id, a.maturity_date, a.is_dst, a.curve_value_main, a.curve_value_sim, 
				a.curve_value_avg,
				a.curve_value_delta,
				a.curve_value_avg_delta,
				a.create_user,
				a.create_ts 
			FROM source_price_simulation_delta_whatif a 
			INNER JOIN #process_as_of_date_point b ON a.as_of_date = b.as_of_date
			WHERE a.criteria_id = @criteria_id
		ELSE
			INSERT INTO #spsd 
			SELECT a.* FROM source_price_simulation_delta a 
			INNER JOIN #process_as_of_date_point b ON a.as_of_date = b.as_of_date		
		
		SET @st1 = '
		INSERT INTO #source_deal_delta_value(run_date,
			as_of_date,
			source_deal_detail_id,
			source_deal_header_id,
			curve_id,
			term_start,
			term_end,
			physical_financial_flag,
			counterparty_id,
			Position,
			market_value_delta,
			contract_value_delta,
			avg_value,
			delta_value,
			avg_delta_value,
			currency_id,
			pnl_source_value_id,
			formula_curve_id,
			leg)
		SELECT ''' + @as_of_date + ''' run_date,COALESCE(spc.as_of_date,spc2.as_of_date,spc3.as_of_date,spc4.as_of_date) as_of_date
			,p.source_deal_detail_id,MAX(p.[source_deal_header_id]) source_deal_header_id,
			MAX(CASE WHEN p.formula_breakdown = 0 THEN COALESCE(spc.[source_curve_def_id],spc2.[source_curve_def_id],spc3.[source_curve_def_id],spc4.[source_curve_def_id]) else NULL END) curve_id
			,MIN(sdd.term_start) term_start,MAX(sdd.term_end) term_end ,MAX(p.[physical_financial_flag]) [physical_financial_flag]
			,MAX(p.counterparty_id) counterparty_id,SUM(p.Position ) Position 
			
			,SUM(CASE WHEN p.formula_breakdown = 0 THEN p.Position ELSE 0 END * COALESCE(spc.curve_value_delta,spc2.curve_value_delta,spc3.curve_value_delta,spc4.curve_value_delta)
			* ISNULL(sc_v.factor,1) * CASE WHEN p.formula_breakdown = 1 THEN ISNULL(sdd.price_multiplier,1) ELSE 1 END
			* CAST(ISNULL(conv_v.conversion_factor,1) AS NUMERIC(21,16)) 
			* COALESCE(fx_fnuc_v.curve_value,(1 / NULLIF(fx_fnuc_v1.curve_value,0)),1) / CAST(ISNULL(conv_price.conversion_factor,1) AS NUMERIC(21,16))
			* CASE WHEN sdd.leg = 1 THEN ISNULL(sogd.DELTA, 1) WHEN sdd.leg = 2 THEN ISNULL(sogd.DELTA2, 1) ELSE 1 END) market_value_delta

			,SUM(CASE WHEN p.formula_breakdown = 1 THEN p.Position ELSE 0 END  * COALESCE(spc.curve_value_delta,spc2.curve_value_delta,spc3.curve_value_delta,spc4.curve_value_delta) 
			* ISNULL(sc_v.factor,1) * CASE WHEN p.formula_breakdown = 1 THEN ISNULL(sdd.price_multiplier,1) ELSE 1 END
			* CAST(ISNULL(conv_v.conversion_factor,1) AS NUMERIC(21,16)) 
			* COALESCE(fx_fnuc_v.curve_value,(1 / NULLIF(fx_fnuc_v1.curve_value,0)),1) / CAST(ISNULL(conv_price.conversion_factor,1) AS NUMERIC(21,16))
			* CASE WHEN sdd.leg = 1 THEN ISNULL(sogd.DELTA, 1) WHEN sdd.leg = 2 THEN ISNULL(sogd.DELTA2, 1) ELSE 1 END) contract_value_delta
			
			
			,SUM(CASE WHEN p.physical_financial_flag = ''p'' AND p.formula_breakdown = 0 THEN 0 ELSE p.Position END * COALESCE(spc.curve_value_avg,spc2.curve_value_avg,spc3.curve_value_avg,spc4.curve_value_avg) 
			* ISNULL(sc_v.factor,1) * CASE WHEN p.formula_breakdown = 1 THEN ISNULL(sdd.price_multiplier,1) ELSE 1 END
			* CAST(ISNULL(conv_v.conversion_factor,1) AS NUMERIC(21,16)) 
			* COALESCE(fx_fnuc_v.curve_value,(1 / NULLIF(fx_fnuc_v1.curve_value,0)),1) / CAST(ISNULL(conv_price.conversion_factor,1) AS NUMERIC(21,16))) avg_value

			,SUM(p.Position * COALESCE(spc.curve_value_delta,spc2.curve_value_delta,spc3.curve_value_delta,spc4.curve_value_delta)
			* ISNULL(sc_v.factor,1) * CASE WHEN p.formula_breakdown = 1 THEN ISNULL(sdd.price_multiplier,1) ELSE 1 END
			* CAST(ISNULL(conv_v.conversion_factor,1) AS NUMERIC(21,16)) 
			* COALESCE(fx_fnuc_v.curve_value,(1 / NULLIF(fx_fnuc_v1.curve_value,0)),1) / CAST(ISNULL(conv_price.conversion_factor,1) AS NUMERIC(21,16))
			* CASE WHEN sdd.leg = 1 THEN ISNULL(sogd.DELTA, 1) WHEN sdd.leg = 2 THEN ISNULL(sogd.DELTA2, 1) ELSE 1 END) delta_value

			,SUM(
				CASE WHEN p.physical_financial_flag = ''p'' AND p.formula_breakdown = 0 THEN 0 ELSE p.Position END * COALESCE(spc.curve_value_avg_delta,spc2.curve_value_avg_delta,spc3.curve_value_avg_delta,spc4.curve_value_avg_delta)
			* ISNULL(sc_v.factor,1) * CASE WHEN p.formula_breakdown = 1 THEN ISNULL(sdd.price_multiplier,1) ELSE 1 END
			* CAST(ISNULL(conv_v.conversion_factor,1) AS NUMERIC(21,16)) 
			* COALESCE(fx_fnuc_v.curve_value,(1 / NULLIF(fx_fnuc_v1.curve_value,0)),1) / CAST(ISNULL(conv_price.conversion_factor,1) AS NUMERIC(21,16))
			* CASE WHEN sdd.leg = 1 THEN ISNULL(sogd.DELTA, 1) WHEN sdd.leg = 2 THEN ISNULL(sogd.DELTA2, 1) ELSE 1 END) avg_delta_value
			 
			,max(spcd.source_currency_id) currency_id
			,' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + ' pnl_source_value_id 
			,MAX(CASE WHEN p.formula_breakdown = 1 THEN COALESCE(spc.[source_curve_def_id],spc2.[source_curve_def_id],spc3.[source_curve_def_id],spc4.[source_curve_def_id]) else NULL END) formula_curve_id,
			MAX(sdd.leg) leg
			'

		SET @st2 = ' FROM #process_as_of_date_point a 
		cross join dbo.source_price_curve_Def spcd (NOLOCK)
			inner join '+@tbl_name_pos+' p on p.curve_id=spcd.source_curve_def_id
			--and CASE  spcd.Granularity WHEN 982 THEN p.maturity_hr WHEN 981 THEN p.term_start WHEN 980 THEN p.maturity_mnth
			--			WHEN 991 THEN p.maturity_qtr WHEN 992 THEN p.maturity_semi WHEN 993 THEN p.maturity_yr
			--	END>''' + CONVERT(VARCHAR(10),@as_of_date,120) + '''
			LEFT JOIN dbo.source_price_curve_def spcd2 (NOLOCK)  ON spcd.proxy_source_curve_def_id=spcd2.source_curve_def_id
			LEFT JOIN dbo.source_price_curve_def spcd3 (NOLOCK)  ON spcd.monthly_index=spcd3.source_curve_def_id
			LEFT JOIN dbo.source_price_curve_def spcd4 (NOLOCK)  ON spcd.proxy_curve_id3=spcd4.source_curve_def_id
			LEFT JOIN dbo.source_currency sc_v ON spcd.source_currency_id=sc_v.source_currency_id AND sc_v.currency_id_to IS NOT NULL
			LEFT JOIN #spsd [spc] (NOLOCK)  ON spcd.source_curve_def_id=[spc].source_curve_def_id
				AND [spc].curve_Source_value_id= ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '	
				AND ([spc].[run_date] = ''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''')
				AND spc.as_of_date = a.as_of_date
				AND [spc].maturity_date=
				CASE  spcd.Granularity WHEN 982 THEN p.maturity_hr WHEN 981 THEN p.term_start WHEN 980 THEN p.maturity_mnth
						WHEN 991 THEN p.maturity_qtr WHEN 992 THEN p.maturity_semi WHEN 993 THEN p.maturity_yr
				END AND p.dst=CASE WHEN spcd.Granularity = 982 THEN [spc].is_dst  ELSE p.dst END
				--AND spcd.settlement_curve_id IS NOT NULL
			LEFT JOIN #spsd [spc2] (NOLOCK)  ON spcd2.source_curve_def_id=[spc2].source_curve_def_id
				AND [spc2].curve_Source_value_id= ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '	
				AND ([spc2].[run_date] = ''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''')
				AND [spc2].maturity_date=
				CASE  spcd2.Granularity WHEN 982 THEN p.maturity_hr WHEN 981 THEN p.term_start WHEN 980 THEN p.maturity_mnth
					WHEN 991 THEN p.maturity_qtr WHEN 992 THEN p.maturity_semi WHEN 993 THEN p.maturity_yr
				END AND p.dst=CASE WHEN spcd2.Granularity = 982 THEN [spc2].is_dst  ELSE p.dst END
				AND spc2.as_of_date = a.as_of_date
			LEFT JOIN #spsd [spc3] (NOLOCK)  ON spcd3.source_curve_def_id=[spc3].source_curve_def_id
				AND [spc3].curve_Source_value_id= ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + ' 
				AND ([spc3].[run_date] = ''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''')
				AND [spc3].maturity_date=
				CASE  spcd3.Granularity WHEN 982 THEN p.maturity_hr WHEN 981 THEN p.term_start WHEN 980 THEN p.maturity_mnth
					WHEN 991 THEN p.maturity_qtr WHEN 992 THEN p.maturity_semi WHEN 993 THEN p.maturity_yr
				END AND p.dst=CASE WHEN spcd3.Granularity = 982 THEN [spc3].is_dst  ELSE p.dst END
				AND spc3.as_of_date = a.as_of_date
			LEFT JOIN #spsd [spc4] (NOLOCK)  ON spcd4.source_curve_def_id=[spc4].source_curve_def_id
				AND [spc4].curve_Source_value_id= ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + ' 
				AND ([spc4].[run_date] = ''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''')
				AND [spc4].maturity_date=
				CASE  spcd4.Granularity WHEN 982 THEN p.maturity_hr WHEN 981 THEN p.term_start WHEN 980 THEN p.maturity_mnth
					WHEN 991 THEN p.maturity_qtr WHEN 992 THEN p.maturity_semi WHEN 993 THEN p.maturity_yr
				END AND p.dst=CASE WHEN spcd4.Granularity = 982 THEN [spc4].is_dst  ELSE p.dst END
				AND spc4.as_of_date = a.as_of_date
			'
			
		SET @st3 = '
			LEFT JOIN #bok b ON p.book_id=b.book_id
			LEFT JOIN  dbo.source_price_curve_def fx_v (NOLOCK)  ON fx_v.source_curve_def_id = p.curve_id and fx_v.source_currency_id = ISNULL(sc_v.currency_id_to,spcd.source_currency_id) AND fx_v.source_currency_to_id=b.func_cur_id AND fx_v.Granularity=980
			LEFT JOIN source_price_curve fx_fnuc_v (NOLOCK)  ON fx_v.source_curve_def_id=fx_fnuc_v.source_curve_def_id
				AND fx_fnuc_v.curve_Source_value_id = ' + CAST(@curve_source_value_id as VARCHAR) + '	AND 
				(fx_fnuc_v.as_of_date = ''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''')
				AND fx_fnuc_v.maturity_date= p.maturity_mnth AND COALESCE(spc.as_of_date,spc2.as_of_date,spc3.as_of_date,spc4.as_of_date)=fx_fnuc_v.as_of_date
			LEFT JOIN dbo.source_price_curve_def fx_v1 (NOLOCK)  ON fx_v1.source_curve_def_id = p.curve_id AND fx_v1.source_currency_id =b.func_cur_id AND fx_v1.source_currency_to_id= ISNULL(sc_v.currency_id_to,spcd.source_currency_id) AND fx_v1.Granularity=980
			LEFT JOIN dbo.source_price_curve fx_fnuc_v1 (NOLOCK)  ON fx_v1.source_curve_def_id=fx_fnuc_v1.source_curve_def_id
				AND fx_fnuc_v1.curve_Source_value_id = ' + CAST(@curve_source_value_id as VARCHAR) + '	AND 
				(fx_fnuc_v1.as_of_date = ''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''')
				AND fx_fnuc_v1.maturity_date=p.maturity_mnth AND COALESCE(spc.as_of_date,spc2.as_of_date,spc3.as_of_date,spc4.as_of_date)=fx_fnuc_v1.as_of_date
			LEFT JOIN dbo.rec_volume_unit_conversion conv_v (NOLOCK) ON conv_v.from_source_uom_id=p.deal_volume_uom_id
				AND conv_v.to_source_uom_id=ISNULL(spcd.display_uom_id,spcd.uom_id)
			LEFT JOIN dbo.rec_volume_unit_conversion conv_price (NOLOCK) ON conv_price.from_source_uom_id=spcd.uom_id
				AND conv_price.to_source_uom_id=ISNULL(spcd.display_uom_id,spcd.uom_id)	
			LEFT JOIN #deal_detail sdd ON sdd.source_deal_detail_id=p.source_deal_detail_id
			LEFT JOIN source_option_greeks_detail sogd ON p.source_deal_header_id = sogd.source_deal_header_id
			AND sogd.hr = ISNULL((1+DATEPART(hh,p.maturity_hr)), 1) 
			AND sogd.is_dst= CASE WHEN spcd.Granularity = 982 THEN p.dst ELSE sogd.is_dst END
			AND sogd.term_start = 
				CASE spcd.Granularity WHEN 982 THEN p.term_start WHEN 981 THEN p.term_start WHEN 980 THEN p.maturity_mnth
					WHEN 991 THEN p.maturity_qtr WHEN 992 THEN p.maturity_semi WHEN 993 THEN p.maturity_yr
				END
			AND sogd.as_of_date = ''' + CONVERT(VARCHAR(10),@as_of_date,120) + '''
			AND sogd.pnl_source_value_id = ' + CAST(@curve_source_value_id as VARCHAR) + '
		--where p.curve_id is not null
			GROUP BY p.source_deal_detail_id,COALESCE(spc.as_of_date,spc2.as_of_date,spc3.as_of_date,spc4.as_of_date)
		   '
			
		exec spa_print @st1
		exec spa_print @st2 
		exec spa_print  @st3 
		EXEC(@st1 + @st2 + @st3)
		
		UPDATE sddv SET
			sddv.dis_market_value_delta =sddv.market_value_delta*ISNULL(sdpd.discount_factor, 1),
			sddv.dis_contract_value_delta = sddv.contract_value_delta*ISNULL(sdpd.discount_factor, 1),
			sddv.dis_avg_value = sddv.avg_value*ISNULL(sdpd.discount_factor, 1),
			sddv.dis_delta_value = sddv.delta_value*ISNULL(sdpd.discount_factor, 1),
			sddv.dis_avg_delta_value = sddv.avg_delta_value*ISNULL(sdpd.discount_factor, 1)
		FROM #source_deal_delta_value sddv
		INNER JOIN source_deal_pnl_detail sdpd ON sdpd.pnl_as_of_date = sddv.run_date
			AND sdpd.source_deal_header_id = sddv.source_deal_header_id
			AND sdpd.term_start = sddv.term_start
			AND sdpd.term_end = sddv.term_end	
		
		---jump for other remaining as_of_date
		IF EXISTS(SELECT 1 FROM #as_of_date_point)
			GOTO loop_process_as_of_date	


		DECLARE @totalCount INT = 0, @priceMissing INT = 0
		SELECT @totalCount = COUNT(*) FROM #source_deal_delta_value
		SELECT @priceMissing = COUNT(*) FROM #source_deal_delta_value WHERE as_of_date IS NULL
		
		IF (@totalCount = 0)
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
			SELECT  @process_id, 'Error', @module, @source, 'MTM simulation', ' No data found to process for MTM simulation for as of date: ' 
			+ dbo.FNADateFormat(@as_of_date), 'Please check data.'
			RAISERROR ('CatchError', 16, 1)
		END

		IF ((@totalCount > @priceMissing) AND @priceMissing > 0)
		BEGIN 
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
			SELECT DISTINCT @process_id, 'Warning', @module, @source, 'MTM simulation', ' Price curve simulation not found for as of date: ' + dbo.FNADateFormat(@as_of_date) + ' , curve:  ' + spcd.curve_name + ' and term: ' + dbo.FNADateFormat(sddv.term_start), 'Please check data.'
			FROM #source_deal_delta_value sddv
			INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sddv.curve_id
			WHERE sddv.as_of_date IS NULL

			SET @is_warning = 'y'
		END

		IF (@totalCount = @priceMissing)
		BEGIN 
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
			SELECT  @process_id, 'Error', @module, @source, 'MTM simulation', ' Price curve simulation not found for as of date: ' 
			+ dbo.FNADateFormat(@as_of_date), 'Please check data.'
			RAISERROR ('CatchError', 16, 1)
		END
		
		--Updating original curve and formula curve value price to calculate var(shift by value)
		UPDATE sddv SET sddv.curve_value = spc.curve_value, sddv.formula_curve_value = spc1.curve_value
		FROM #source_deal_delta_value sddv
		INNER JOIN source_price_curve spc ON spc.as_of_date = sddv.run_date
			AND spc.source_curve_def_id = sddv.curve_id
			AND spc.maturity_date = sddv.term_start
		LEFT JOIN source_price_curve spc1 ON spc1.as_of_date = sddv.run_date
			AND spc1.source_curve_def_id = sddv.formula_curve_id
			AND spc1.maturity_date = sddv.term_start
			AND spc1.curve_source_value_id = spc.curve_source_value_id	
		WHERE spc.curve_source_value_id = 4500

		IF @calc_type = 'y'
			INSERT INTO [dbo].[source_deal_delta_value_whatif](criteria_id,
				run_date ,
				as_of_date, 
				[source_deal_detail_id],
				[source_deal_header_id],
				[curve_id],
				[term_start],
				[term_end],
				physical_financial_flag,
				[counterparty_id],
				[Position],
				market_value_delta,
				contract_value_delta,
				[avg_value],
				[delta_value],
				[avg_delta_value],
				dis_market_value_delta,
				dis_contract_value_delta,
				dis_avg_value,
				dis_delta_value,
				dis_avg_delta_value,
				[currency_id],
				[pnl_source_value_id], 
				[formula_curve_id], 
				[curve_value], 
				[formula_curve_value],
				[leg]
			)
			SELECT @criteria_id,* FROM #source_deal_delta_value
		ELSE
			INSERT INTO [dbo].[source_deal_delta_value](run_date ,
				as_of_date, 
				[source_deal_detail_id],
				[source_deal_header_id],
				[curve_id],
				[term_start],
				[term_end],
				physical_financial_flag,
				[counterparty_id],
				[Position],
				market_value_delta,
				contract_value_delta,
				[avg_value],
				[delta_value],
				[avg_delta_value],
				dis_market_value_delta,
				dis_contract_value_delta,
				dis_avg_value,
				dis_delta_value,
				dis_avg_delta_value,
				[currency_id],
				[pnl_source_value_id], 
				[formula_curve_id], 
				[curve_value], 
				[formula_curve_value],
				[leg]
			)
			SELECT * FROM #source_deal_delta_value	
		END --new approach block end	
			
	SET @desc = 'MTM Simulation Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_id) + '.'	
	SET @errorcode = 's'
	IF @errorcode = 's'
	BEGIN
		INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
		SELECT  @process_id, 'Success', @module, @source, 'MTM simulation', CAST(ISNULL(@no_of_simulation, 0) AS VARCHAR) + ' MTM Simulation(s) Calculation done for as of date: ' 
		+ dbo.FNADateFormat(@as_of_date), 'Please check data.'
	END
	
END TRY	



BEGIN CATCH
	EXEC spa_print 'Catch Error'
	
	--INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
	--SELECT  @process_id, 'Error', @module, @source, 'MTM simulation', ERROR_MESSAGE(), 'Please check data.'
			
	--IF @@TRANCOUNT > 0
	--	ROLLBACK
	EXEC spa_print @process_id
	SET @errorcode = 'e'
	--EXEC spa_print  ERROR_LINE()
	SET @desc = 'MTM Simulation Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_id) + ' (ERRORS found).'
	EXEC spa_print @desc
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'',
		''MTM simulation'''
END CATCH


IF @errorcode = 'e'
BEGIN
	SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'

	SET @url_desc = '<a href="../../dev/spa_html.php?spa=spa_fas_eff_ass_test_run_log '''+@process_id+'''">Click here...</a>'

	SELECT 'Error' ErrorCode, 'Calculate MTM' MODULE, 
			'spa_calc_mtm_job_wrapper' Area, 'DB Error' Status, 'MTM Simulation Calculation process is completed with error. ' MESSAGE, '' Recommendation
END
ELSE
BEGIN
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'',
		''MTM simulation'''
	
	SET @desc = 'MTM Simulation Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_id) + CASE WHEN @is_warning = 'y' THEN ' with warning(s)' ELSE '' END + '.'	

	EXEC spa_ErrorHandler 0, 'Calculate MTM', 	'spa_calc_mtm_job_wrapper', 'Success', @desc, ''

	IF @is_warning = 'y'
	SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'
END



EXEC  spa_message_board 
		'i', 
		@user_id,
		NULL, 
		'MTM Simulation Calculation',
		@desc, 
		'', 
		'', 
		@errorcode, 
		'MTM Simulation Calculation',
		NULL,
		@process_id
