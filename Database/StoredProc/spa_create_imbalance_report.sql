
IF OBJECT_ID('spa_create_imbalance_report') IS NOT NULL
DROP PROC dbo.spa_create_imbalance_report

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/**
	Generate imbalance report and also create imbalance deals.
	Parameters
	@summary_option			: Summary Option
	@sub_entity_id			: Subsidiary Entity Id
	@stra_entity_id			: Strategy Entity Id
	@book_entity_id			: Book Entity Id
	@term_start				: Term Start
	@term_end				: Term End
	@location				: Location ID
	@location_type			: Location Type ID
	@meter					: Meter id comma separated
	@show_imbalance_amount	: Show Imbalance Amount flag
	@counterparty_id		: Counterparty Id
	@drill_location			: Location id of Drill downed imbalance report
	@drill_meter			: Meter id of Drill downed imbalance report
	@drill_term				: Term date of dril downed imbalance report
	@process_table			: Process Table to dump imbalance report result (unused)
	@source_system_book_id1 : Source System Book Id1
	@source_system_book_id2 : Source System Book Id2
	@source_system_book_id3 : Source System Book Id3
	@source_system_book_id4 : Source System Book Id4
	@major_location			: Major Location ID comma separated
	@minor_location			: Location ID comma separated
	@pipeline_counterparty	: Pipeline Counterparty ID comma separated
	@delivery_path			: Delivery Path ID comma separated
	@group_by				: Group By mode (unused)
	@daily_rolling			: Daily Rolling (unused)
	@contract_ids			: Contract Ids comma separated
	@round_by				: Rounding by values (unused)
	@calc_flag				: Calculation logic Flag (1=Receipt volm-Fuel loss; 2=Delivery Volm(LEG 2))
	@run_mode				: Logic code run mode (0=calc only; 1=adhoc run report only AND NOT calc; 2=calc AND report)
	@drill_pipeline			: Pipeline counterparty id of dril downed imbalance report
	@drill_contract			: contract name of dril downed imbalance report
	@drill_type				: Drilldown report Type
	@drill_date				: Drill Date
	@call_from				: Call From flag
	@batch_process_id		: Batch Process Id
	@batch_report_param		: Batch Report Param
	@enable_paging			: Enable Paging
	@page_size				: Page Size
	@page_no				: Page No
*/
CREATE PROC [dbo].[spa_create_imbalance_report]
	@summary_option CHAR(1) = 's',
	@sub_entity_id VARCHAR(MAX) = NULL,
	@stra_entity_id VARCHAR(MAX) = NULL,
	@book_entity_id VARCHAR(MAX) = NULL,
	@term_start VARCHAR(20) = NULL,
	@term_end VARCHAR(20) = NULL,
	@location INT = NULL,
	@location_type INT = NULL,
	@meter VARCHAR(1000) = NULL,
	@show_imbalance_amount CHAR(1) = NULL,
	@counterparty_id VARCHAR(1000) = NULL,
	@drill_location VARCHAR(1000) = NULL,
	@drill_meter VARCHAR(100) = NULL,
	@drill_term VARCHAR(100) = NULL,
	@process_table VARCHAR(100) = NULL,
	@source_system_book_id1 INT = NULL, 
	@source_system_book_id2 INT = NULL, 
	@source_system_book_id3 INT = NULL, 
	@source_system_book_id4 INT = NULL,	
	@major_location VARCHAR(250) = NULL,
	@minor_location VARCHAR(250) = NULL,
	@pipeline_counterparty VARCHAR(250) = NULL,
	@delivery_path VARCHAR(500) = NULL,
	@group_by VARCHAR(100) = NULL,
	@daily_rolling VARCHAR(100) = NULL,	--d: daily, m: monthly, dr: daily rolling SUM, mr: monthly rolling SUM
	@contract_ids VARCHAR(1000) = NULL,
	@round_by VARCHAR(2) = 2,
	@calc_flag INT = 1,	---1=Receipt volm-Fuel loss; 2=Delivery Volm(LEG 2)
	@run_mode INT = 2, --0=calc only; 1=adhoc run report only AND NOT calc; 2=calc AND report
	@drill_pipeline VARCHAR(250) = NULL,
	@drill_contract VARCHAR(250) = NULL,
	@drill_type VARCHAR(250) = NULL,
	@drill_date VARCHAR(10) = NULL,
	@call_from VARCHAR(50) = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,		--'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS

SET NOCOUNT ON


/*
DECLARE
	@summary_option CHAR(1) = 'd',
	@sub_entity_id VARCHAR(MAX) = NULL,
	@stra_entity_id VARCHAR(MAX) = NULL,
	@book_entity_id VARCHAR(MAX) = NULL,
	@term_start VARCHAR(20),-- = '2017-10-01',
	@term_end VARCHAR(20), --= '2017-12-31',
	@location INT = NULL,
	@location_type INT = NULL,
	@meter VARCHAR(1000) = NULL,
	@show_imbalance_amount CHAR(1) = NULL,
	@counterparty_id VARCHAR(1000) = NULL,
	@drill_location VARCHAR(100), --= '1358',
	@drill_meter VARCHAR(100) = NULL,
	@drill_term VARCHAR(100) = NULL,
	@process_table VARCHAR(100) = NULL,
	@source_system_book_id1 INT = NULL, 
	@source_system_book_id2 INT = NULL, 
	@source_system_book_id3 INT = NULL, 
	@source_system_book_id4 INT = NULL,	
	@major_location VARCHAR(250) = NULL,
	@minor_location VARCHAR(250) = NULL,
	@pipeline_counterparty VARCHAR(250),-- = '4224',
	@delivery_path VARCHAR(500) = NULL,
	@group_by VARCHAR(100) = NULL,
	@daily_rolling VARCHAR(100) = NULL,	--d: daily, m: monthly, dr: daily rolling SUM, mr: monthly rolling SUM
	@contract_ids VARCHAR(1000) = NULL,
	@round_by VARCHAR(2) = 2,
	@calc_flag INT = 1,	---1=Receipt volm-Fuel loss; 2=Delivery Volm(LEG 2)
	@run_mode INT = 2, --0=calc only; 1=adhoc run report only AND NOT calc; 2=calc AND report
	@drill_pipeline VARCHAR(250) --= 'Williams Co. '
	,@drill_contract VARCHAR(250) --= 'W123456'
	,@drill_type VARCHAR(250) --= 'MD'
	,@drill_date VARCHAR(10) --= '2017-11-14'
	,@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,		--'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL

EXEC sys.sp_set_session_context @key = N'DB_USER', @value = 'adangol'
--Drops all temp tables created in this scope.
EXEC [spa_drop_all_temp_table] 

--report run
select @summary_option='d'
,@sub_entity_id='18,8,2,15,11,5'
,@stra_entity_id='19,9,3,16,12,6'
,@book_entity_id='20,10,4,17,13,14,7'
,@term_start='2021-05-01'
,@term_end='2021-05-31'
,@pipeline_counterparty='7988'
,@round_by='2'

--*/



BEGIN TRY


	DECLARE @str_batch_table VARCHAR(8000)
	DECLARE @is_batch BIT
	DECLARE @sql_paging VARCHAR(8000)
	DECLARE @user_login_id VARCHAR(50)
	DECLARE @job_name VARCHAR(250)
	declare @process_id varchar(100)
	DECLARE @desc VARCHAR(5000)

	SET @str_batch_table = ''
	SET @user_login_id = dbo.FNADBUser() 
	set @process_id= dbo.FNAGetNewID()

	SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END		

	IF @is_batch = 1
		SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

	IF @enable_paging = 1 --paging processing
	BEGIN
		IF @batch_process_id IS NULL
			SET @batch_process_id = dbo.FNAGetNewID()

		SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)

		--retrieve data FROM paging table instead of main table
		IF @page_no IS NOT NULL  
		BEGIN
			SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no)    
			EXEC (@sql_paging)  
			RETURN  
		END
	END

	CREATE TABLE #meg_trapp(
		errcode VARCHAR(50) COLLATE DATABASE_DEFAULT  ,
		module VARCHAR(50) COLLATE DATABASE_DEFAULT  ,
		area VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
		statu VARCHAR(100) COLLATE DATABASE_DEFAULT  ,
		msg VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
		rec VARCHAR(200) COLLATE DATABASE_DEFAULT  
	)


	DECLARE @sub_type_ids VARCHAR(100),
			@org_summary_option VARCHAR(1)

	SET @org_summary_option = @summary_option
	SET @run_mode = 2
	SET @calc_flag = 1

	DECLARE @sql_str VARCHAR(MAX),
			@sql_str1 VARCHAR(MAX)

	IF @process_table IS NOT NULL
		SET @process_table = ' INTO ' + @process_table
	ELSE
		SET @process_table = ''

	--******************************************************            
	--CREATE source book map table AND build index            
	--*********************************************************   
	SET @sql_str = ''   
      
	CREATE TABLE #imbalance_template_ids(template_id INT,group_ID INT ,group_name VARCHAR(250) COLLATE DATABASE_DEFAULT  ,group_order_id INT)
	CREATE TABLE #imbalance_deals(counterparty_id INT,contract_id INT ,location_id INT,meter_id INT,template_id INT,off_template_id INT,closeout_template_id INT,reporting_contract_id INT, sub_book_id INT, formula_id int)

	INSERT INTO #imbalance_template_ids (group_ID,group_name,template_id ,group_order_id)
	SELECT clm1_value,clm2_value,clm3_value ,clm4_value FROM generic_mapping_values g 
	INNER JOIN generic_mapping_header h ON g.mapping_table_id=h.mapping_table_id
		 AND h.mapping_name= 'Imbalance Report' --AND clm1_value = 'y'
		 AND ISNUMERIC(ISNULL(clm1_value,1))=1 AND ISNUMERIC(ISNULL(clm3_value,1))=1 AND ISNUMERIC(ISNULL(clm4_value,1))=1

	INSERT INTO #imbalance_deals (contract_id  ,counterparty_id ,location_id ,meter_id,template_id ,off_template_id,closeout_template_id,reporting_contract_id, sub_book_id, formula_id)
	SELECT clm1_value,clm2_value,clm3_value ,clm4_value,clm5_value,clm6_value,clm7_value,clm9_value,clm10_value,clm11_value FROM generic_mapping_values g 
	INNER JOIN generic_mapping_header h ON g.mapping_table_id=h.mapping_table_id
	 AND h.mapping_name= 'Imbalance Deal' --AND clm1_value = 'y'
	 WHERE ISNUMERIC(ISNULL(clm1_value,1))=1 AND ISNUMERIC(ISNULL(clm2_value,1))=1 AND ISNUMERIC(ISNULL(clm3_value,1))= 1 
	 AND ISNUMERIC(ISNULL(clm4_value,1))=1 AND ISNUMERIC(ISNULL(clm5_value,1))=1
	AND ISNUMERIC(ISNULL(clm6_value,1))=1 AND ISNUMERIC(ISNULL(clm7_value,1))=1 AND ISNUMERIC(ISNULL(clm9_value,1))=1

	IF @drill_pipeline IS NOT NULL
	BEGIN
		IF LEN(@drill_date)=7
		BEGIN
			SET @term_start =@drill_date+'-01'
			SET @term_end=CONVERT(VARCHAR(10),DATEADD(MONTH,1,CAST(@drill_date+'-01' AS DATETIME))-1,120)
		END
		ELSE
		BEGIN
			SET @term_start =@drill_date
			SET @term_end=@drill_date
		END
	
		SET @summary_option='d'
		SELECT @pipeline_counterparty=source_counterparty_id  FROM source_counterparty WHERE counterparty_name= @drill_pipeline
		SELECT @contract_ids=contract_id  FROM contract_group WHERE contract_name= @drill_contract

	END

	DECLARE @spa VARCHAR(5000)

	SET @spa = 'EXEC spa_create_imbalance_report ''''' +ISNULL(@summary_option,'d') +''''','+
		+ CASE WHEN @sub_entity_id IS NULL THEN 'NULL' ELSE '''''' + @sub_entity_id + '''''' END + ','
		+ CASE WHEN @stra_entity_id IS NULL THEN 'NULL' ELSE '''''' + @stra_entity_id + '''''' END + ','
		+ CASE WHEN @book_entity_id IS NULL THEN 'NULL' ELSE '''''' + @book_entity_id + '''''' END + ','
		+ CASE WHEN @term_start IS NULL THEN 'NULL'  ELSE '''''' + @term_start + '''''' END + ','
		+ CASE WHEN @term_end IS NULL THEN 'NULL'  ELSE  '''''' +@term_end  + '''''' END + ','
		+ CASE WHEN @location IS NULL THEN 'NULL'  ELSE CAST( @location AS VARCHAR) END + ',NULL,'
		+ CASE WHEN @meter IS NULL THEN 'NULL'  ELSE '''''' + @meter + '''''' END + ','
		+ CASE WHEN @show_imbalance_amount IS NULL THEN 'NULL'  ELSE '''''' + @show_imbalance_amount + '''''' END + ',NULL,<#drill_location_id#>,NULL,NULL,NULL,'
		+ CASE WHEN @source_system_book_id1 IS NULL THEN 'NULL'  ELSE  CAST(@source_system_book_id1 AS VARCHAR)  END + ','
		+ CASE WHEN @source_system_book_id1 IS NULL THEN 'NULL'  ELSE CAST(@source_system_book_id2 AS VARCHAR) END + ','
		+ CASE WHEN @source_system_book_id1 IS NULL THEN 'NULL'  ELSE CAST(@source_system_book_id3 AS VARCHAR) END + ','
		+ CASE WHEN @source_system_book_id1 IS NULL THEN 'NULL'  ELSE CAST(@source_system_book_id4 AS VARCHAR) END + ',NULL,NULL,'
		+ CASE WHEN @pipeline_counterparty IS NULL THEN 'NULL'  ELSE '''''' + @pipeline_counterparty + '''''' END + ','
		+ CASE WHEN @delivery_path IS NULL THEN 'NULL'  ELSE '''''' + @delivery_path + '''''' END + ','
		+ CASE WHEN @group_by IS NULL THEN 'NULL'  ELSE '''''' + @group_by + '''''' END + ',NULL,'
		+ CASE WHEN @contract_ids IS NULL THEN 'NULL'  ELSE '''''' + @contract_ids + '''''' END + ','
		+ CASE WHEN @round_by IS NULL THEN 'NULL'  ELSE CAST(@round_by AS VARCHAR) END
		+ ', 1, ' +
		+ CASE WHEN @run_mode IS NULL THEN 'NULL'  ELSE CAST(@run_mode AS VARCHAR) END 
    
	--PRINT @spa  
   
	CREATE TABLE #books ( fas_book_id INT,source_system_book_id1 INT,source_system_book_id2 INT,source_system_book_id3 INT ,source_system_book_id4 INT ) 

	SET @sql_str = '
		INSERT INTO  #books
		SELECT DISTINCT book.entity_id fas_book_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3  ,source_system_book_id4
		FROM portfolio_hierarchy book (nolock) INNER JOIN
				Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id INNER  JOIN            
				source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
		WHERE --(fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) 
		1=1  '
		+CASE WHEN @source_system_book_id1 IS  NULL THEN '' ELSE ' AND ssbm.source_system_book_id1='+CAST(@source_system_book_id1 AS VARCHAR) END
		+CASE WHEN @source_system_book_id2 IS  NULL THEN '' ELSE ' AND ssbm.source_system_book_id2='+CAST(@source_system_book_id2 AS VARCHAR) END
		+CASE WHEN @source_system_book_id3 IS  NULL THEN '' ELSE ' AND ssbm.source_system_book_id3='+CAST(@source_system_book_id3 AS VARCHAR) END
		+CASE WHEN @source_system_book_id4 IS  NULL THEN '' ELSE ' AND ssbm.source_system_book_id4='+CAST(@source_system_book_id4 AS VARCHAR) END
            
	IF @sub_entity_id IS NOT NULL 
		SET @sql_str = @sql_str + ' AND stra.parent_entity_id IN  ( '
			+ @sub_entity_id + ') '         
	IF @stra_entity_id IS NOT NULL 
		SET @sql_str = @sql_str + ' AND (stra.entity_id IN('
			+ @stra_entity_id + ' ))'        
	IF @book_entity_id IS NOT NULL 
		SET @sql_str = @sql_str + ' AND (book.entity_id IN('
			+ @book_entity_id + ')) '        
  
	EXEC ( @sql_str)
	--PRINT( @sql_str)

	CREATE TABLE #tmp_delivery_path
	(
		[ID] [INT] IDENTITY(1,1) NOT NULL,
		[path_id] INT NULL,
		[meter_id] INT NULL,
		[location_id] INT NULL,
		[formula_id] INT NULL,
		[leg] INT NULL,
		[pipeline_counterparty] INT NULL,
		[contract] INT NULL,
		loss_factor FLOAT,
		fuel_factor FLOAT					
	)                
		
	SET @sql_str = '
		INSERT INTO #tmp_delivery_path 
		SELECT path_id,
			CASE imbalance_from
				WHEN ''y'' THEN meter_from
				WHEN ''n'' THEN meter_to
			END AS MeterID,
			CASE imbalance_from
				WHEN ''y'' THEN from_location
				WHEN ''n'' THEN to_location
			END AS LocationID,
			CASE imbalance_from
				WHEN ''y'' THEN formula_from
				WHEN ''n'' THEN formula_to
			END AS FormulaID,

			 CASE imbalance_from
				WHEN ''y'' THEN 1
				WHEN ''n'' THEN 2
			END AS  Leg, counterparty,[contract],loss_factor,fuel_factor
		FROM delivery_path WHERE 1=1 '
		+ CASE WHEN @location IS NULL THEN '' ELSE ' AND CASE imbalance_from
				WHEN ''y'' THEN from_location
				WHEN ''n'' THEN to_location
			END = ('+CAST(@location AS VARCHAR)+')' END 
		+ CASE WHEN @meter IS NULL THEN '' ELSE ' AND CASE imbalance_from
				WHEN ''y'' THEN meter_from
				WHEN ''n'' THEN meter_to
			END in ( '+@meter+')' END 
		+ CASE WHEN nullif(@pipeline_counterparty, '') IS NULL THEN '' ELSE ' AND counterparty in ('+@pipeline_counterparty+')' END
		+ CASE WHEN nullif(@contract_ids , '')IS NULL THEN '' ELSE ' AND [contract] in ('+ @contract_ids + ')' END
		+ CASE WHEN nullif(@delivery_path, '') IS NULL THEN '' ELSE ' AND path_id in ('+ @delivery_path +')' END
	
	EXEC(@sql_str)
	
	CREATE TABLE #temp_deals(
		counterparty_id INT,
		contract_id INT,
		deal_sub_type_type_id INT,
		Term DATETIME,
		deal_volume_uom_id INT,
		receipt_volume FLOAT,
		fuel_loss FLOAT,
		net_receipt_volume  NUMERIC(26,8),
		allocated_delivery  NUMERIC(26,8),
		daily_imbalance NUMERIC(26,8),
		id INT IDENTITY(1,1),
		price FLOAT,currency_id INT,
		source_deal_header_id INT,
		template_id INT,
		group_order_id INT,
		group_name VARCHAR(250) COLLATE DATABASE_DEFAULT ,
		group_id INT,
		id1 INT,
		location_id INT,
		meter_id INT,
		deal_volume NUMERIC(26,8)
	)


	CREATE TABLE #deal_list (source_deal_header_id INT,source_deal_detail_id INT,total_volume FLOAT)

	--SELECT * FROM #temp_deals
	IF ISNULL(@show_imbalance_amount,'n') = 'n'
	BEGIN
		SET @sql_str1='
			INSERT INTO #temp_deals (meter_id,location_id,counterparty_id ,contract_id ,group_id,group_order_id ,Term ,deal_volume_uom_id ,group_name, receipt_volume ,fuel_loss ,net_receipt_volume ,allocated_delivery ,daily_imbalance'+CASE WHEN @org_summary_option='d' THEN ',source_deal_header_id,template_id' ELSE ''  END +',deal_volume)
			SELECT 
				leg_2.meter_id,sdd.location_id,sdh.counterparty_id,ISNULL(id1.reporting_contract_id,sdh.contract_id),idi.group_id,idi.group_order_id,CAST(ISNULL(uddf.udf_value,sdd.term_start) AS DATETIME) Term,
					MAX(sdd.deal_volume_uom_id) deal_volume_uom_id,MAX(idi.group_name) group_name,
					[Receip Volume]=SUM(CASE WHEN idi.group_ID <>1 THEN 0 ELSE 1 * ISNULL(sdd.schedule_volume,sdd.deal_volume)  END),
					[Shrinkage]=ISNULL( SUM(ISNULL(uddf_fac.udf_value, 0) *
							CASE WHEN idi.group_ID <>1 THEN 0 ELSE CASE WHEN sdd.leg=1 THEN 1 ELSE 0 END* CASE WHEN sdd.buy_sell_flag=''b'' THEN 1 ELSE 1 END*  ISNULL(sdd.schedule_volume,sdd.deal_volume)  END), 0),
					[Net Receipt Volume]=ABS('
					+CASE WHEN @calc_flag=1 THEN 
						'SUM(CASE WHEN idi.group_ID <>1 THEN 0 ELSE sdd.deal_volume end
						*(1-(ISNULL(uddf_fac.udf_value, 0))))'
					ELSE
						'SUM(CASE WHEN idi.group_ID <>1 THEN 0 ELSE CASE WHEN sdd.leg=2 THEN 1 ELSE 0 END* isnull(sdd.schedule_volume,sdd.deal_volume) )'	
					END +')
					--,[Allocated Delivery]=CASE WHEN MAX(sdd.leg) = 2 THEN MIN(coalesce(leg_2.vol,sdd.actual_volume,0)) ELSE 0 END,
				,[Allocated Delivery]=sum(
					case when idi.group_ID <>1 THEN 0 
						ELSE coalesce(sdd.actual_volume,sdd.schedule_volume,leg_2.vol,sdd.deal_volume,0) 
					end),
					null [Daily Imbalance]'
					+CASE WHEN @org_summary_option='d'  THEN ',sdh.source_deal_header_id,sdh.template_id' ELSE ''  END +'
					,sum(sdd.deal_volume * CASE WHEN sdd.buy_sell_flag=''b'' THEN 1 ELSE -1 END)
			FROM source_deal_header sdh	
			INNER JOIN #imbalance_template_ids idi ON sdh.template_id=idi.template_id
			INNER JOIN  #books b ON sdh.source_system_book_id1=b.source_system_book_id1     		                        
				AND sdh.source_system_book_id2=b.source_system_book_id2                             
				AND sdh.source_system_book_id3=b.source_system_book_id3                             
				AND sdh.source_system_book_id4=b.source_system_book_id4   
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=sdh.source_deal_header_id 
			LEFT JOIN (SELECT DISTINCT counterparty_id ,location_id,contract_id,meter_id  FROM #imbalance_deals) imb 
				ON sdh.contract_id=imb.contract_id
				AND sdh.counterparty_id=imb.counterparty_id 
				AND sdd.location_id=imb.location_id
			OUTER APPLY (
				SELECT top(1) * 
				FROM #tmp_delivery_path  
				WHERE sdd.location_id=location_id 
					AND sdh.counterparty_id=[pipeline_counterparty] 
					AND sdh.contract_id=[contract] 
					AND sdd.leg=CASE WHEN idi.group_ID =1 THEN leg ELSE sdd.leg END   
					AND meter_id=CASE WHEN idi.group_ID =1 THEN  sdd.meter_id ELSE meter_id END
			) dp
			OUTER APPLY(
				SELECT f.udf_value FROM  user_defined_deal_fields f
				INNER JOIN  user_defined_deal_fields_template uddft 
					ON f.udf_template_id=uddft.udf_template_id  
					AND uddft.field_name=-5613
					AND f.source_deal_header_id=sdh.source_deal_header_id  
					AND ISDATE(f.udf_value)=1 
					AND idi.group_ID in (4,5,6,7)
			) uddf
			OUTER APPLY(
				SELECT CAST(f.udf_value AS FLOAT) udf_value FROM  user_defined_deal_fields f
				INNER JOIN  user_defined_deal_fields_template uddft ON f.udf_template_id=uddft.udf_template_id  AND uddft.field_name=-5614
					AND f.source_deal_header_id=sdh.source_deal_header_id  AND ISNUMERIC(f.udf_value)=1
			) uddf_fac
			OUTER APPLY(
				SELECT top(1)  s1.delivered_volume FROM delivery_status s 
				INNER JOIN source_deal_detail d ON s.source_deal_detail_id=d.source_deal_detail_id AND s.source_deal_detail_id=sdd.source_deal_detail_id
				INNER JOIN source_deal_detail d1 ON d.source_deal_header_id=d1.source_deal_header_id AND d1.leg=2
				INNER JOIN  delivery_status s1 ON  s1.source_deal_detail_id=d1.source_deal_detail_id
				ORDER BY s1.status_timestamp desc
			) ds
			OUTER APPLY(
				SELECT id.meter_id, SUM(ISNULL(mvh.hr1,0)+ISNULL(mvh.hr2,0)+ISNULL(mvh.hr3,0)+ISNULL(mvh.hr4,0)+ISNULL(mvh.hr5,0)+ISNULL(mvh.hr6,0)
						+ISNULL(mvh.hr7,0)+ISNULL(mvh.hr8,0)+ISNULL(mvh.hr9,0)+ISNULL(mvh.hr10,0)+ISNULL(mvh.hr11,0)+ISNULL(mvh.hr12,0)
						+ISNULL(mvh.hr13,0)+ISNULL(mvh.hr14,0)+ISNULL(mvh.hr15,0)+ISNULL(mvh.hr16,0)+ISNULL(mvh.hr17,0)+ISNULL(mvh.hr18,0)
						+ISNULL(mvh.hr19,0)+ISNULL(mvh.hr20,0)+ISNULL(mvh.hr21,0)+ISNULL(mvh.hr22,0)+ISNULL(mvh.hr23,0)+ISNULL(mvh.hr24,0)) vol
				FROM #imbalance_deals id
				INNER JOIN mv90_data mv 
					ON mv.meter_id = id.meter_id 
					AND id.counterparty_id = sdh.counterparty_id 
					AND id.contract_id= sdh.contract_id
					AND mv.from_date = CONVERT(VARCHAR(8),sdd.term_start,120)+''01'' 
					AND idi.group_ID =1 
					AND sdd.location_id=id.location_id
				INNER JOIN mv90_data_hour mvh 
					ON mv.meter_data_id = mvh.meter_data_id
					AND mvh.prod_date= sdd.term_start   
				GROUP BY id.meter_id               
			)  leg_2  
			OUTER APPLY ( 
				SELECT top(1) reporting_contract_id 
				FROM #imbalance_deals 
				WHERE counterparty_id = sdh.counterparty_id 
					AND contract_id= sdh.contract_id 
					AND location_id=sdd.location_id
			) id1        
			WHERE CAST(ISNULL(uddf.udf_value,sdd.term_start) AS DATETIME) BETWEEN '''+@term_start+''' AND '''+@term_end+''''
				+ CASE WHEN ISNULL(@run_mode,0)=0 THEN ' AND idi.group_ID <>1 ' ELSE '' END +' 
				AND ISNULL(id1.reporting_contract_id,sdh.contract_id) IS NOT NULL
				AND sdd.location_id IN (SELECT DISTINCT id2.location_id FROM #imbalance_deals id2)
				'
				+ ISNULL(' and sdh.counterparty_id IN (' + NULLIF(@pipeline_counterparty,'') + ')', '') +
				+ ISNULL(' and sdd.location_id IN (' + NULLIF(@drill_location,'') + ')', '') +
				'

			GROUP BY leg_2.meter_id,sdh.counterparty_id,ISNULL(id1.reporting_contract_id,sdh.contract_id),idi.group_id,idi.group_order_id
			'+CASE WHEN  @org_summary_option='d' THEN ',sdh.template_id' ELSE '' END +',ISNULL(uddf.udf_value,sdd.term_start)
			,sdh.source_deal_header_id
			,sdd.location_id
			--ORDER BY 1,2,5,4

		
			update #temp_deals set daily_imbalance = receipt_volume - allocated_delivery
				'
		EXEC(@sql_str1)	
		
		IF @summary_option in ('d','m')
		BEGIN 
			IF ISNULL(@run_mode,0)<>0
			BEGIN 

				SELECT rowid=ROW_NUMBER() OVER (ORDER BY a.counterparty_id,a.reporting_contract_id ,a.term,a.group_id,MAX(group_order_id)) ,
					counterparty_id,
					MAX(contract_id) contract_id,
					MAX(deal_sub_type_type_id) deal_sub_type_type_id,
					Term,
					MAX(deal_volume_uom_id) deal_volume_uom_id,
					SUM(receipt_volume)receipt_volume,
					SUM(fuel_loss) fuel_loss,
					SUM(net_receipt_volume) net_receipt_volume,
					SUM(allocated_delivery) allocated_delivery,
					SUM(daily_imbalance) daily_imbalance,
					MAX(id) id,
					MAX(price) price,
					MAX(currency_id) currency_id,
					source_deal_header_id,
					MAX(template_id) template_id,
					MAX(group_order_id) group_order_id,
					MAX(group_name) group_name,
					group_id,
					MAX(id1) id1,a.reporting_contract_id,
					sum(deal_volume) deal_volume
				INTO #temp_deals3 --  select * from #temp_deals3
				FROM (
					SELECT td.meter_id,td.source_deal_header_id,td.counterparty_id
						,ISNULL(b.reporting_contract_id,td.contract_id) reporting_contract_id,
						MAX(td.contract_id) contract_id,td.term,group_id,MAX(td.group_order_id) group_order_id ,
						MAX(deal_sub_type_type_id) deal_sub_type_type_id,				
						MAX(deal_volume_uom_id) deal_volume_uom_id,
						SUM(receipt_volume) receipt_volume,
						SUM(fuel_loss) fuel_loss,
						SUM(net_receipt_volume) net_receipt_volume,
						MAX(allocated_delivery) allocated_delivery,
						CASE WHEN td.meter_id IS NULL THEN SUM(daily_imbalance) ELSE MAX(daily_imbalance) END daily_imbalance,
						MAX(id) id,
						MAX(price) price,
						MAX(currency_id) currency_id,
						MAX(template_id) template_id,
						MAX(group_name) group_name,
						MAX(td.id1) id1,
						sum(deal_volume) deal_volume
					FROM #temp_deals td
					 OUTER APPLY
					  (
						  SELECT DISTINCT reporting_contract_id  FROM #imbalance_deals
							--WHERE td.contract_id =CASE WHEN  ISNULL(1,0)=0  THEN ISNULL(reporting_contract_id,contract_id)  ELSE contract_id END
								WHERE  contract_id=td.contract_id AND counterparty_id=td.counterparty_id
									AND ISNULL(location_id,-1)=ISNULL(td.location_id,-1)
					  ) b 

						GROUP BY td.source_deal_header_id,td.counterparty_id,ISNULL(b.reporting_contract_id,td.contract_id),td.term,group_id,td.meter_id
				  ) a
			
				GROUP BY counterparty_id,reporting_contract_id,a.Term ,a.group_id,source_deal_header_id
				ORDER BY counterparty_id,reporting_contract_id,a.Term,a.group_id ,MAX(group_order_id)
						
				EXEC spa_print '5609'

				UPDATE user_defined_deal_detail_fields SET udf_value =ISNULL(imb_v.imb_vol ,0) 
				FROM source_deal_header sdh
				INNER JOIN  (SELECT DISTINCT source_deal_header_id FROM #deal_list) dl 
					ON dl.source_deal_header_id=sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id
				INNER JOIN #imbalance_deals imb ON sdh.contract_id=imb.reporting_contract_id
					AND sdh.counterparty_id=imb.counterparty_id AND sdh.template_id=imb.template_id  -- ,off_template_id
					and imb.location_id = sdd.location_id
				INNER JOIN user_defined_deal_detail_fields f ON f.source_deal_detail_id=sdd.source_deal_detail_id 
				INNER JOIN  user_defined_deal_fields_template uddft ON f.udf_template_id=uddft.udf_template_id  
					AND uddft.udf_type = 'd' AND uddft.field_name=-5609 AND uddft.leg=sdd.Leg
				left JOIN #temp_deals3 td ON td.term=sdd.term_start AND td.contract_id=imb.reporting_contract_id
					 AND td.counterparty_id=sdh.counterparty_id
				OUTER APPLY (
					SELECT	SUM(ABS(d.receipt_volume)) imb_vol FROM #temp_deals3 d 
						--INNER JOIN (SELECT DISTINCT reporting_contract_id,contract_id,counterparty_id  FROM #imbalance_deals) b ON d.contract_id=b.contract_id
						--	--AND b.location_id=d.location_id 
						--	AND b.counterparty_id=d.counterparty_id
					 WHERE d.term=sdd.term_start AND d.reporting_contract_id=sdh.contract_id
						 AND d.counterparty_id=sdh.counterparty_id --AND d.template_id=sdh.template_id
						 AND d.group_id=1
				) imb_v
				WHERE sdd.term_start BETWEEN COALESCE(@term_start,@term_end,'1900-01-01') AND COALESCE(@term_end,@term_start,'9999-01-01')

				EXEC spa_print '5610'
				UPDATE user_defined_deal_detail_fields SET udf_value = ISNULL(imb_v.imb_vol ,0) 
				 FROM source_deal_header sdh
				INNER JOIN  (SELECT DISTINCT source_deal_header_id FROM #deal_list) dl 
				ON dl.source_deal_header_id=sdh.source_deal_header_id
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id
					INNER JOIN #imbalance_deals imb ON sdh.contract_id=imb.reporting_contract_id
						AND sdh.counterparty_id=imb.counterparty_id AND sdh.template_id=imb.template_id  -- ,off_template_id
						and imb.location_id = sdd.location_id
					INNER JOIN user_defined_deal_detail_fields f ON f.source_deal_detail_id=sdd.source_deal_detail_id 
					INNER JOIN  user_defined_deal_fields_template uddft ON f.udf_template_id=uddft.udf_template_id  
						AND uddft.udf_type = 'd' AND uddft.field_name=-5610 AND uddft.leg=sdd.Leg
					left JOIN #temp_deals3 td ON td.term=sdd.term_start AND td.contract_id=imb.reporting_contract_id
					 AND td.counterparty_id=sdh.counterparty_id
				OUTER APPLY (
					SELECT	SUM(ABS(d.fuel_loss)) imb_vol 
					FROM #temp_deals3 d 
						--INNER JOIN (SELECT DISTINCT reporting_contract_id,contract_id,location_id,counterparty_id  FROM #imbalance_deals) b ON d.contract_id=b.contract_id
						--	AND b.location_id=d.location_id AND b.counterparty_id=d.counterparty_id
					 WHERE d.term=sdd.term_start AND d.reporting_contract_id=sdh.contract_id
					 AND d.counterparty_id=sdh.counterparty_id --AND d.template_id=sdh.template_id
					  AND d.group_id=1
				) imb_v
				WHERE sdd.term_start BETWEEN COALESCE(@term_start,@term_end,'1900-01-01') AND COALESCE(@term_end,@term_start,'9999-01-01')

				EXEC spa_print '5611'

				UPDATE user_defined_deal_detail_fields SET udf_value =ISNULL(imb_v.imb_vol ,0) 
				FROM source_deal_header sdh
				INNER JOIN  (SELECT DISTINCT source_deal_header_id FROM #deal_list) dl 
				ON dl.source_deal_header_id=sdh.source_deal_header_id
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id
					INNER JOIN #imbalance_deals imb ON sdh.contract_id=imb.reporting_contract_id
						AND sdh.counterparty_id=imb.counterparty_id AND sdh.template_id=imb.template_id  -- ,off_template_id
						and imb.location_id = sdd.location_id
					INNER JOIN user_defined_deal_detail_fields f ON f.source_deal_detail_id=sdd.source_deal_detail_id 
					INNER JOIN  user_defined_deal_fields_template uddft ON f.udf_template_id=uddft.udf_template_id  
					AND uddft.udf_type = 'd' AND uddft.field_name=-5611 AND uddft.leg=sdd.Leg
					left JOIN #temp_deals3 td ON td.term=sdd.term_start AND td.contract_id=imb.reporting_contract_id
					 AND td.counterparty_id=sdh.counterparty_id
				OUTER APPLY (
					SELECT	SUM(ABS(d.net_receipt_volume)) imb_vol 
					FROM #temp_deals3 d 
						--INNER JOIN (SELECT DISTINCT reporting_contract_id,contract_id,location_id,counterparty_id  FROM #imbalance_deals) b ON d.contract_id=b.contract_id
						--	AND b.location_id=d.location_id AND b.counterparty_id=d.counterparty_id
					 WHERE d.term=sdd.term_start AND d.reporting_contract_id=sdh.contract_id
					 AND d.counterparty_id=sdh.counterparty_id --AND d.template_id=sdh.template_id
					  AND d.group_id=1
				) imb_v
				WHERE sdd.term_start BETWEEN COALESCE(@term_start,@term_end,'1900-01-01') AND COALESCE(@term_end,@term_start,'9999-01-01')

				EXEC spa_print '5612'
				UPDATE user_defined_deal_detail_fields SET udf_value =ISNULL(imb_v.imb_vol ,0) 
				FROM source_deal_header sdh
				INNER JOIN  (SELECT DISTINCT source_deal_header_id FROM #deal_list) dl 
				ON dl.source_deal_header_id=sdh.source_deal_header_id
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id
					INNER JOIN #imbalance_deals imb ON sdh.contract_id=imb.reporting_contract_id
						AND sdh.counterparty_id=imb.counterparty_id AND sdh.template_id=imb.template_id  -- ,off_template_id
						and imb.location_id = sdd.location_id
					INNER JOIN user_defined_deal_detail_fields f ON f.source_deal_detail_id=sdd.source_deal_detail_id 
					INNER JOIN  user_defined_deal_fields_template uddft ON f.udf_template_id=uddft.udf_template_id  
					AND uddft.udf_type = 'd' AND uddft.field_name=-5612 AND uddft.leg=sdd.Leg
					left JOIN #temp_deals3 td ON td.term=sdd.term_start AND td.contract_id=imb.reporting_contract_id
					 AND td.counterparty_id=sdh.counterparty_id
				OUTER APPLY (
					SELECT	SUM(ABS(d.allocated_delivery)) imb_vol 
					FROM #temp_deals3 d 
						INNER JOIN (SELECT DISTINCT ISNULL(reporting_contract_id,contract_id) contract_id  FROM #imbalance_deals) b ON d.reporting_contract_id=b.contract_id
					 WHERE d.term=sdd.term_start AND b.contract_id=sdh.contract_id
					 AND d.counterparty_id=sdh.counterparty_id --AND d.template_id=sdh.template_id
					  AND d.group_id=1
				) imb_v
				WHERE sdd.term_start BETWEEN COALESCE(@term_start,@term_end,'1900-01-01') AND COALESCE(@term_end,@term_start,'9999-01-01')

				--SELECT * FROM user_defined_deal_fields_template
				DECLARE @deal_ids VARCHAR(MAX)

				SET @deal_ids=NULL

				SELECT @deal_ids=ISNULL(@deal_ids+',','')+CAST(source_deal_header_id AS VARCHAR) 
				 FROM #deal_list GROUP BY source_deal_header_id

				EXEC spa_print @deal_ids
				--IF ISNULL(@deal_ids,'')<>''
				--INSERT INTO #meg_trapp	EXEC dbo.spa_calc_deal_position_breakdown @deal_ids
				
				IF ISNULL(@run_mode,0)=2 ---requery the deals
				BEGIN
				
					TRUNCATE TABLE #temp_deals
					EXEC spa_print @sql_str1;
					EXEC(@sql_str1)		
			
				END 
			
			END 
		
			IF ISNULL(@run_mode,0)<>1
			BEGIN 
				IF @org_summary_option='d' AND ISNULL(@run_mode,0)=0
				BEGIN 		
			
				
					SET @sql_str1='
						INSERT INTO #temp_deals (counterparty_id ,contract_id ,group_id,group_order_id ,Term ,deal_volume_uom_id ,group_name,
							receipt_volume ,fuel_loss ,net_receipt_volume ,allocated_delivery ,daily_imbalance,source_deal_header_id,template_id)
						SELECT sdh.counterparty_id,ISNULL(imb.reporting_contract_id,sdh.contract_id) contract_id ,1 group_id,1 group_order_id,CAST(ISNULL(uddf.udf_value,sdd.term_start) AS DATETIME) Term,
									MAX(sdd.deal_volume_uom_id) deal_volume_uom_id,MAX(CASE WHEN idi.group_id=1 THEN idi.group_name ELSE NULL END) group_name,
									[Receip Volume]=0,
									[Shrinkage]=0,
									[Net Receipt Volume]=0
									,[Allocated Delivery]=0,
									[Daily Imbalance]=MAX(sdd.deal_volume),sdh.source_deal_header_id,sdh.template_id		
							FROM source_deal_header sdh
							INNER JOIN (SELECT DISTINCT counterparty_id,template_id ,location_id, reporting_contract_id  FROM #imbalance_deals) imb ON sdh.contract_id=imb.reporting_contract_id
								AND sdh.counterparty_id=imb.counterparty_id AND sdh.template_id=imb.template_id 
							CROSS APPLY (
								SELECT top(1) 1 aa FROM source_deal_detail WHERE sdh.source_deal_header_id=source_deal_header_id AND location_id=imb.location_id
								) ex
							INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id
								AND sdd.location_id= CASE WHEN sdd.leg=2 THEN  imb.location_id ELSE sdd.location_id END
							INNER JOIN  #books b ON sdh.source_system_book_id1=b.source_system_book_id1     		                        
								AND sdh.source_system_book_id2=b.source_system_book_id2                             
								AND sdh.source_system_book_id3=b.source_system_book_id3                             
								AND sdh.source_system_book_id4=b.source_system_book_id4   
							OUTER APPLY(
								SELECT a.udf_value FROM  user_defined_deal_fields a
								INNER JOIN  user_defined_deal_fields_template uddft ON a.udf_template_id=uddft.udf_template_id  AND uddft.field_name=-5613
								AND a.source_deal_header_id=sdh.source_deal_header_id  AND ISDATE(a.udf_value)=1
							) uddf
							CROSS JOIN ( SELECT MAX(group_id) group_id,MAX(group_name) group_name,MAX(group_order_id) group_order_id
								FROM #imbalance_template_ids  WHERE group_id=1 
							) idi
							WHERE  CAST(ISNULL(uddf.udf_value,sdd.term_start) AS DATETIME) BETWEEN '''+@term_start+''' AND '''+@term_end+''' 
							GROUP BY sdh.counterparty_id,ISNULL(imb.reporting_contract_id,sdh.contract_id),idi.group_id,idi.group_order_id
							,sdh.template_id,sdh.source_deal_header_id,ISNULL(uddf.udf_value,sdd.term_start)
							--ORDER BY 1,2,5,4	
							'		

					EXEC(@sql_str1)								
				END

				SELECT rowid=ROW_NUMBER() OVER (ORDER BY a.counterparty_id,a.reporting_contract_id ,a.term,MAX(group_order_id),a.group_id) ,
					counterparty_id,a.location_id,
					MAX(contract_id) contract_id,
					MAX(deal_sub_type_type_id) deal_sub_type_type_id,
					Term,
					convert(varchar(8),Term,120)+'01' first_dom,
					MAX(deal_volume_uom_id) deal_volume_uom_id,
					ROUND(sum(receipt_volume),0)receipt_volume,
					ROUND(sum(fuel_loss),0) fuel_loss,
					ROUND(sum(net_receipt_volume),0) net_receipt_volume,
					ROUND(sum(allocated_delivery),0) allocated_delivery,
					ROUND(sum(daily_imbalance),0) daily_imbalance,
					MAX(id) id,
					MAX(price) price,
					MAX(currency_id) currency_id,
					source_deal_header_id,
					MAX(template_id) template_id,
					MAX(group_order_id) group_order_id,
					MAX(group_name) group_name,
					group_id,
					MAX(id1) id1,a.reporting_contract_id,
					sum(deal_volume) deal_volume,
					max(a.meter_id) meter_id
				INTO  #temp_deals2 -- select * from #temp_deals2
				FROM (
					SELECT td.meter_id,td.source_deal_header_id,td.location_id,td.counterparty_id,ISNULL(b.reporting_contract_id,td.contract_id) reporting_contract_id,
					MAX(td.contract_id) contract_id,td.term,group_id,MAX(td.group_order_id) group_order_id ,
						MAX(deal_sub_type_type_id) deal_sub_type_type_id,				
						MAX(deal_volume_uom_id) deal_volume_uom_id,
						SUM(receipt_volume) receipt_volume,
						SUM(fuel_loss) fuel_loss,
						SUM(net_receipt_volume) net_receipt_volume,
						MAX(allocated_delivery) allocated_delivery,
						CASE WHEN td.meter_id IS NULL THEN SUM(daily_imbalance) ELSE MAX(daily_imbalance) END daily_imbalance,
						MAX(id) id,
						MAX(price) price,
						MAX(currency_id) currency_id,
						MAX(template_id) template_id,
						MAX(group_name) group_name,
						MAX(td.id1) id1,
						sum(deal_volume) deal_volume
					 FROM #temp_deals td
					 OUTER APPLY
					  (
					  SELECT DISTINCT reporting_contract_id  FROM #imbalance_deals
							WHERE td.contract_id =CASE WHEN  ISNULL(1,0)=0  THEN ISNULL(reporting_contract_id,contract_id)  ELSE contract_id END AND ISNULL(location_id,-1)=ISNULL(td.location_id,-1)
					  ) b 
					GROUP BY td.source_deal_header_id,td.counterparty_id,ISNULL(b.reporting_contract_id,td.contract_id),td.term,group_id,td.meter_id,td.location_id
				  ) a
				GROUP BY counterparty_id,reporting_contract_id,a.Term ,a.group_id,source_deal_header_id,a.location_id
				ORDER BY counterparty_id,reporting_contract_id,a.Term ,MAX(group_order_id),a.group_id
			

				--select '#temp_deals2',* from #temp_deals2 order by location_id

				IF ISNULL(@drill_type,'')<>''
				BEGIN
					SET @sql_str='delete  #temp_deals2 FROM  #temp_deals2 sdh WHERE NOT ( 1=1 '+CASE WHEN @drill_pipeline IS NULL THEN '' ELSE 
						CASE WHEN @drill_type IS NULL THEN '' ELSE  ' AND sdh.group_name = '''+@drill_type+''''  END  END 
			
					IF NULLIF(@pipeline_counterparty, '') IS NOT NULL 
						SET @sql_str = @sql_str + ' AND sdh.counterparty_id IN (' + CAST(@pipeline_counterparty AS VARCHAR(4000)) + ')'
				
					IF nullif(@contract_ids , '') IS NOT NULL 
						SET @sql_str = @sql_str + ' AND ISNULL(sdh.reporting_contract_id,sdh.contract_id) IN (' + CAST(@contract_ids AS VARCHAR(4000)) + ')'

					SET @sql_str=@sql_str+')'

					EXEC spa_print @sql_str;
					EXEC(@sql_str)

				END

				IF ISNULL(@drill_type, '') <> 'calc'
				BEGIN
				SET @sql_str='
					SELECT	
						row_number() over(order by (select null)) [rid],
						' + IIF(@summary_option = 'm'
							,'case when max(imb_deal_info.imb_deal_id) is not null 
								then dbo.FNATRMWinHyperlink(''a'',10131010, sc.counterparty_name ,cast(max(imb_deal_info.imb_deal_id) as varchar(30)),''n'',null,null,null,null,null,null,null,null,null,null,0)
								else sc.counterparty_name
							  end'
							,'sc.counterparty_name') + ' [Pipeline]
						,lname.location_name [Location]
						,coalesce(cg1.contract_name,cg.contract_name,'''') [Contract]
						' + IIF(@summary_option = 'd',',sdh.group_name  [Type]','') + '
					'+CASE WHEN @org_summary_option='d' 
					then ',dbo.FNATRMWinHyperlink(''a'',10131010,cast(max(sdh.source_deal_header_id) as varchar(30)),ABS(max(sdh.source_deal_header_id)),''n'',null,null,null,null,null,null,null,null,null,null,0) [Deal ID]'  
					ELSE '' END 
					+ ','+CASE WHEN  @org_summary_option='d' 
					--added spaces as time part on label parameter as deal creation logic broke when time part is excluded
					THEN 'dbo.FNADateFormat(' + IIF(@summary_option = 'd','sdh.term','dbo.FNAGetFirstLastDayOfMonth(sdh.term,''f'')') + ') ' 
					--ELSE '[dbo].[FNAHyperHTML]('+replace(@spa,'<#drill_location_id#>',''''''' + cast(max(sdh.location_id) as varchar(10)) + ''''''')+',''''''+sc.counterparty_name+'''''',''''''+coalesce(cg1.contract_name,cg.contract_name,'''')+'''''',''''''+ISNULL(sdh.group_name,'''')+'''''',''''''+CONVERT(VARCHAR(10),' + IIF(@summary_option = 'd','sdh.term','dbo.FNAGetFirstLastDayOfMonth(sdh.term,''f'')') + ',120)+'''''''', dbo.fnadateformat(' + IIF(@summary_option = 'd','sdh.term','dbo.FNAGetFirstLastDayOfMonth(sdh.term,''f'')') + ') + ''     '')'  END +
				
					--' [Term]

					when @summary_option = 'd'
						then '''<span style="color: #0000ff; text-decoration: underline;" onclick="parent.parent.open_spa_html_window(&quot;Pipeline Imbalance Detail Report&quot;,&quot;' 
						+ replace(@spa,'<#drill_location_id#>',''''''' + cast(max(sdh.location_id) as varchar(10)) + ''''''')+',''''''+sc.counterparty_name+'''''',''''''+coalesce(cg1.contract_name,cg.contract_name,'''')+'''''',''''''+ISNULL(sdh.group_name,'''')+'''''',''''''+CONVERT(VARCHAR(10),sdh.term,120) + ''''''' 
						+ '&quot;,600, 1200)">' + ' ''+dbo.fnadateformat(sdh.term) + ''</span>'' ' 
					when @summary_option = 'm' 
						then '''<span style="color: #0000ff; text-decoration: underline;" onclick="parent.parent.open_spa_html_window(&quot;Pipeline Imbalance Daily Report&quot;,&quot;' 
						+ 'EXEC spa_create_imbalance_report @summary_option=''''d'''', @term_start='''''' + CONVERT(VARCHAR(10),dbo.FNAGetFirstLastDayOfMonth(sdh.term,''f''),120) + '''''',@term_end='''''' + CONVERT(VARCHAR(10),dbo.FNAGetFirstLastDayOfMonth(dbo.FNAGetFirstLastDayOfMonth(sdh.term,''f''),''l''),120) + '''''',@pipeline_counterparty='''''' + cast(max(sdh.counterparty_id) as varchar(100)) + '''''', @drill_location='''''' + cast(max(sdh.location_id) as varchar(100)) + '''''', @drill_contract='''''' + cast(coalesce(cg1.contract_name,cg.contract_name,'''') as varchar(100)) + '''''''
						+ '&quot;,600, 1200)">' + ' ''+dbo.fnadateformat(dbo.FNAGetFirstLastDayOfMonth(sdh.term,''f'')) + ''</span>'' ' 
					else 'dbo.FNADateFormat(sdh.term) '
					END + 

					' AS [Term]
				
					,dbo.FNARemoveTrailingZero(SUM(ABS(sdh.receipt_volume))) [Nominated Volume]
					,dbo.FNARemoveTrailingZero(case when max(sdh.meter_id) is null then SUM(sdh.allocated_delivery) else ' + IIF(@summary_option = 'd','max(sdh.allocated_delivery)','sum(sdh.allocated_delivery)') + ' end) [Actual Volume]
					--,dbo.FNARemoveTrailingZero(SUM(sdh.daily_imbalance)) [Daily Imbalance],
				--,dbo.FNARemoveTrailingZero(SUM(ABS(sdh.receipt_volume))-SUM(sdh.allocated_delivery)) [Daily Imbalance],
				,[Daily Imbalance] =  
					CAST(SUM(
								CASE WHEN sdh.group_id in (9, 10, 12, 13) 
									THEN IIF(sdh.group_id IN (10, 13), -1, 1) * (sdh.deal_volume) 
									ELSE dbo.FNARemoveTrailingZero((ABS(sdh.receipt_volume))-(sdh.allocated_delivery))  
								END
								) AS NUMERIC(20,2)
						),
				[Adjustment]        = CAST(SUM(CASE WHEN sdh.group_id in(6,7) THEN -1 * sdh.deal_volume ELSE 0 END) AS NUMERIC(20,2)),
				--[Cash Out]          = CAST(SUM(CASE WHEN sdh.group_id =8 THEN (ABS(sdh.receipt_volume)-sdh.allocated_delivery) ELSE 0 END) AS NUMERIC(20,2)),
				[Cash Out]          = CAST(SUM(CASE WHEN sdh.group_id =8 THEN sdh.deal_volume ELSE 0 END) AS NUMERIC(20,2)),
				[Pay Back]          =  CAST(SUM(CASE WHEN sdh.group_id in(4,5) THEN -1 * sdh.deal_volume ELSE 0 END) AS NUMERIC(20,2)),
					[CloseOut/Xfer]     =  CAST(SUM(CASE WHEN sdh.group_id in(3,11) THEN (sdh.deal_volume) ELSE 0 END) AS NUMERIC(20,2))
					,MAX(su.uom_name) UOM,
					dbo.FNAAddThousandSeparator(dbo.FNARemoveTrailingZero(
						isnull(
							--[Daily Imbalance]
							SUM( CAST(SUM(
									CASE WHEN sdh.group_id in (9, 10, 12, 13) 
										THEN IIF(sdh.group_id IN (10, 13), -1, 1) * (sdh.deal_volume) 
										ELSE dbo.FNARemoveTrailingZero((ABS(sdh.receipt_volume))-(sdh.allocated_delivery))  
									END
									) AS NUMERIC(20,2)
							)

							--[Adjustment]
							+SUM(CASE WHEN sdh.group_id in(6,7) THEN	-1 * sdh.deal_volume ELSE 0 END)

							--[Cash Out]
							+SUM(CASE WHEN sdh.group_id =8 THEN sdh.deal_volume ELSE 0 END)

							--[Pay Back]
							+SUM(CASE WHEN sdh.group_id in(4,5) THEN	-1 * sdh.deal_volume ELSE 0 END)

							--[CloseOut/Xfer]
							+SUM(CASE WHEN sdh.group_id in(3,11) THEN	sdh.deal_volume ELSE 0 END)
							) 
							OVER(
								PARTITION BY sc.counterparty_name,lname.location_name,coalesce(cg1.contract_name,cg.contract_name,'''') 
								ORDER BY ' + IIF(@summary_option = 'd','sdh.term','dbo.FNAGetFirstLastDayOfMonth(sdh.term,''f'')') + '
								ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
							)
						,0) 
					)) [Cummulative Imbalance]
					--null [Cummulative Imbalance]
					' + IIF(@summary_option = 'd', '', ',[Action]=dbo.FNATRMWinHyperlink(''a'',10131800,''Transfer'',MAX(sdh.contract_id),convert(varchar(10),dateadd(month,1,cast(CONVERT(varchar(8),max(sdh.term),120)+''01'' as datetime))-1,120),
						max(case when sdh.group_id in(1,2,3,4,5,6,7,8,9,10,11,12,13) then ''<#CUMMULATIVE_IMBALANCE#>'' else ''0'' end),MAX(sdh.counterparty_id),''<#NOMINATED_VOLUME#>'',''<#ACTUAL_VOLUME#>'',''<#CASHOUT_PERCENT#>'',max(lname.source_minor_location_id),null,null,null,null,0)') + '

					into #final_result
					FROM #temp_deals2 sdh 
					INNER JOIN (
						SELECT DISTINCT reporting_contract_id,counterparty_id FROM #imbalance_deals
					) imb ON sdh.reporting_contract_id=imb.reporting_contract_id
						AND sdh.counterparty_id=imb.counterparty_id
					LEFT JOIN source_uom su ON su.source_uom_id=sdh.deal_volume_uom_id
					LEFT JOIN source_counterparty sc ON sc.source_counterparty_id=sdh.counterparty_id
					LEFT JOIN contract_group cg ON sdh.contract_id=cg.contract_id
					LEFT JOIN contract_group cg1 ON sdh.reporting_contract_id=cg1.contract_id
					LEFT JOIN source_minor_location lname ON lname.source_minor_location_id = sdh.location_id
					outer apply (
						select top 1 sdh1.source_deal_header_id [imb_deal_id]
						from source_deal_detail sdd1
						inner join source_deal_header sdh1 on sdh1.source_deal_header_id = sdd1.source_deal_header_id
						inner join source_deal_header_template sdht1 on sdht1.template_id = sdh1.template_id
						where sdd1.location_id = sdh.location_id
							and sdh1.counterparty_id = sdh.counterparty_id
							and sdh1.contract_id = isnull(cg1.contract_id, cg.contract_id)
							and sdd1.term_start between dbo.FNAGetFirstLastDayOfMonth(sdh.term,''f'') and dbo.FNAGetFirstLastDayOfMonth(sdh.term,''l'')
							and sdht1.template_name = ''Imb Actualization'' --imb deals template
					) imb_deal_info
				
					WHERE 1=1 		
					'
				 
				IF @drill_contract IS NOT NULL
					SET @sql_str = @sql_str + ' AND ISNULL(cg1.contract_name,cg.contract_name) IN (''' + @drill_contract + ''')'

				IF @drill_pipeline IS NOT NULL
					SET @sql_str = @sql_str + ' AND sc.counterparty_name IN (''' + @drill_pipeline + ''')'

				IF @drill_location IS NOT NULL
					SET @sql_str = @sql_str + ' AND sdh.location_id = ''' + @drill_location + ''''

				SET @sql_str=@sql_str+ '
				GROUP BY sc.counterparty_name
					,lname.location_name
					,coalesce(cg1.contract_name,cg.contract_name,'''')
				
					,' + IIF(@summary_option = 'd','sdh.group_name,sdh.term','dbo.FNAGetFirstLastDayOfMonth(sdh.term,''f'')') + '
					--,sdh.source_deal_header_id
				'
			
				SET @sql_str = @sql_str + '
				ORDER BY MAX(sdh.counterparty_id)
					,lname.location_name
					,MAX(sdh.reporting_contract_id) 
					,' + IIF(@summary_option = 'd','sdh.term','dbo.FNAGetFirstLastDayOfMonth(sdh.term,''f'')') + '
					,MAX(ISNULL(sdh.group_order_id,9999))
					
				--UPDATE #final_result SET [Cummulative Imbalance] = dbo.FNAAddThousandSeparator(dbo.FNARemoveTrailingZero(
				--	[Daily Imbalance] + [Adjustment] + [Cash Out] + [Pay Back] + [CloseOut/Xfer]
				--))

				' + iif(@summary_option = 'd', '', '
				UPDATE #final_result 
				SET [Action]=REPLACE(REPLACE(REPLACE(REPLACE([Action],''<#CUMMULATIVE_IMBALANCE#>'',REPLACE([Cummulative Imbalance],'','','''')),''<#NOMINATED_VOLUME#>'', [Nominated Volume]),''<#ACTUAL_VOLUME#>'', [Actual Volume]),''<#CASHOUT_PERCENT#>'',case [rid] when 1 then ''0.05'' when 2 then ''0.03'' else ''0'' end)
				, [Cummulative Imbalance] = dbo.FNARemoveTrailingZero(
					[Daily Imbalance] + [Adjustment] + [Cash Out] + [Pay Back] + [CloseOut/Xfer]
					)
				') + '

				alter table #final_result 
				drop column rid

				select *
				' + @str_batch_table + '
				from #final_result	
				'
			
				--PRINT @sql_str;
				EXEC(@sql_str)
					RETURN
				--raiserror('forced_debug',16,1)
				END

	----

	-------------------------------------Deal creation-------------------------------------------
	--------------------------------------------------------------------------------------------


		SELECT [source_system_id],
			   CAST([deal_id] AS VARCHAR(250)) [deal_id],
			   [deal_date],
			   [ext_deal_id],
			   [physical_financial_flag],
			   [structured_deal_id],
			   [counterparty_id],
			   [entire_term_start],
			   [entire_term_end],
			   [source_deal_type_id],
			   [deal_sub_type_type_id],
			   [option_flag],
			   [option_type],
			   [option_excercise_type],
			   [source_system_book_id1],
			   [source_system_book_id2],
			   [source_system_book_id3],
			   [source_system_book_id4],
			   [description1],
			   [description2],
			   [description3],
			   [deal_category_value_id],
			   [trader_id],
			   [internal_deal_type_value_id],
			   [internal_deal_subtype_value_id],
			   [template_id],
			   [header_buy_sell_flag],
			   [broker_id],
			   [generator_id],
			   [status_value_id],
			   [status_date],
			   [assignment_type_value_id],
			   [compliance_year],
			   [state_value_id],
			   [assigned_date],
			   [assigned_by],
			   [generation_source],
			   [aggregate_environment],
			   [aggregate_envrionment_comment],
			   [rec_price],
			   [rec_formula_id],
			   [rolling_avg],
			   [contract_id],
			   [create_user],
			   [create_ts],
			   [update_user],
			   [update_ts],
			   [legal_entity],
			   [internal_desk_id],
			   [product_id],
			   [internal_portfolio_id],
			   [commodity_id],
			   [reference],
			   [deal_locked],
			   [close_reference_id],
			   [block_type],
			   [block_define_id],
			   [granularity_id],
			   [Pricing],
			   [deal_reference_type_id],
			   [unit_fixed_flag],
			   [broker_unit_fees],
			   [broker_fixed_cost],
			   [broker_currency_id],
			   [deal_status],
			   [term_frequency],
			   [option_settlement_date],
			   [verified_by],
			   [verified_date],
			   [risk_sign_off_by],
			   [risk_sign_off_date],
			   [back_office_sign_off_by],
			   [back_office_sign_off_date],
			   [book_transfer_id],
			   [confirm_status_type],
			   [sub_book],
			   [deal_rules],
			   [confirm_rule],
			   [description4],
			   [timezone_id],
			   CAST(0 AS INT) source_deal_header_id,
			   cast(0 as int) location_id
		INTO   #tmp_header
		FROM   [dbo].[source_deal_header]
		WHERE  1 = 2


		CREATE TABLE #detail_inserted
		(
			id                        INT IDENTITY(1, 1),
			source_deal_header_id     INT,
			source_deal_detail_id     INT,
			leg                       INT,
			term_start                DATETIME,
			inj_volume                FLOAT,
			wth_volume                FLOAT
		)


		SELECT 
			rowid=identity(int,1,1),
			sdh.counterparty_id ,
			MAX(sdh.term) max_term,
			sdh.first_dom,
			ISNULL(sdh.reporting_contract_id,sdh.contract_id) [contract_id],  
			SUM(sdh.daily_imbalance) daily_imbalance,
			SUM(sdh.allocated_delivery) allocated_delivery, 
			SUM(sdh.net_receipt_volume)  net_receipt_volume,
			SUM(sdh.fuel_loss) fuel_loss,
			SUM(sdh.receipt_volume) receipt_volume,
			imb.location_id location_id,
			MAX(ISNULL(sml.term_pricing_index, sddt.curve_id))  curve_id,
			MAX(imb.meter_id) meter_id,
			MAX(imb.sub_book_id) sub_book_id,
			MAX(imb.template_id) template_id,
			MAX(sdht.source_system_id) [source_system_id],
			MAX(imb.reporting_contract_id) [reporting_contract_id],
			MAX(sdht.option_flag) [option_flag],
			MAX(sdh.group_id) [group_id],
			MAX(imb.formula_id) [formula_id],

			SUM(CASE WHEN sdh.group_id = 8 THEN sdh.daily_imbalance ELSE 0 END) [cashout_vol],
			SUM(CASE WHEN sdh.group_id in(4,5) THEN sdh.daily_imbalance ELSE 0 END) [payback_vol],
			SUM(CASE WHEN sdh.group_id in(3,11) THEN sdh.daily_imbalance ELSE 0 END) [closeout_vol]

		into #tmp_data_for_deal
		FROM #temp_deals2 sdh 
		INNER JOIN #imbalance_deals imb ON imb.reporting_contract_id=isnull(sdh.reporting_contract_id,sdh.contract_id) 
			AND sdh.counterparty_id=imb.counterparty_id
			and imb.location_id = sdh.location_id
		inner join dbo.source_deal_header_template sdht on sdht.template_id=imb.template_id
		inner join source_deal_detail_template sddt on sddt.template_id = sdht.template_id
		inner join source_system_book_map ssbm on imb.sub_book_id=ssbm.book_deal_type_map_id
		inner join source_minor_location sml on sml.source_minor_location_id = imb.location_id
		WHERE NOT (ISNULL(sdh.daily_imbalance,0)=0 AND ISNULL(sdh.allocated_delivery,0)=0 
			AND ISNULL(sdh.net_receipt_volume,0)=0
			AND ISNULL(sdh.fuel_loss,0)=0 AND ISNULL(sdh.receipt_volume,0) =0)			
		GROUP BY sdh.counterparty_id,isnull(sdh.reporting_contract_id,sdh.contract_id), sdh.first_dom, imb.location_id
	
		if object_id('tempdb..#tmp_data_for_deal_detail') is not null 
			drop table #tmp_data_for_deal_detail
	
		SELECT 
			rowid=identity(int,1,1),
			sdh.counterparty_id ,
			sdh.term term_start,
			min(sdh.first_dom) first_dom,
			ISNULL(sdh.reporting_contract_id,sdh.contract_id) [contract_id],  
			SUM(sdh.receipt_volume)-SUM(sdh.allocated_delivery) daily_imbalance,
			sum(SUM(sdh.receipt_volume)-SUM(sdh.allocated_delivery)) over(
				partition by sdh.counterparty_id,isnull(sdh.reporting_contract_id,sdh.contract_id), imb.location_id
				order by sdh.term
			) [daily_balance_cummulative],
			SUM(sdh.allocated_delivery) allocated_delivery, 
			SUM(sdh.net_receipt_volume)  net_receipt_volume,
			SUM(sdh.fuel_loss) fuel_loss,
			SUM(sdh.receipt_volume) receipt_volume,
			imb.location_id location_id,
			MAX(ISNULL(sml.term_pricing_index, sddt.curve_id))  curve_id,
			MAX(imb.meter_id) meter_id,
			MAX(imb.sub_book_id) sub_book_id,
			MAX(imb.template_id) template_id,
			MAX(sdht.source_system_id) [source_system_id],
			MAX(imb.reporting_contract_id) [reporting_contract_id],
			MAX(sdht.option_flag) [option_flag],
			MAX(sdh.group_id) [group_id],
			MAX(imb.formula_id) [formula_id],

			SUM(CASE WHEN sdh.group_id = 8 THEN sdh.deal_volume ELSE 0 END) [cashout_vol],
			SUM(CASE WHEN sdh.group_id in(4,5) THEN sdh.daily_imbalance ELSE 0 END) [payback_vol],
			SUM(CASE WHEN sdh.group_id in(3,11) THEN sdh.daily_imbalance ELSE 0 END) [closeout_vol]

		into #tmp_data_for_deal_detail
		FROM #temp_deals2 sdh 
		INNER JOIN #imbalance_deals imb ON imb.reporting_contract_id=isnull(sdh.reporting_contract_id,sdh.contract_id) 
			AND sdh.counterparty_id=imb.counterparty_id
			and imb.location_id = sdh.location_id
		INNER JOIN dbo.source_deal_header_template sdht on sdht.template_id=imb.template_id
		INNER JOIN source_deal_detail_template sddt on sddt.template_id = sdht.template_id
		INNER JOIN source_system_book_map ssbm on imb.sub_book_id=ssbm.book_deal_type_map_id
		INNER JOIN source_minor_location sml on sml.source_minor_location_id = imb.location_id
		WHERE 1=1 and NOT (
			ISNULL(sdh.daily_imbalance,0)=0 AND ISNULL(sdh.allocated_delivery,0)=0 
			AND ISNULL(sdh.net_receipt_volume,0)=0
			AND ISNULL(sdh.fuel_loss,0)=0 AND ISNULL(sdh.receipt_volume,0) =0
			and sdh.group_id = 1 --exclude 0 values for daily imbalance group only
		)			
		GROUP BY sdh.counterparty_id,isnull(sdh.reporting_contract_id,sdh.contract_id), sdh.term, imb.location_id

		--select counterparty_id,contract_id,location_id,* from #temp_deals2 where counterparty_id=8896 and contract_id=8223
		--order by 1,2,3,term asc
		--select * from #imbalance_deals
		--select * from #temp_deals2
		--select * from #tmp_data_for_deal
		--select * from #tmp_data_for_deal_detail
		--select * from #affected_deal_details
		--return

		/** UPDATE EXISTING DEAL DETAIL INFO -START **/
		--store deal detail info of affected deals (details which are needed to update when imbalance is run on update mode)
		if object_id('tempdb..#affected_deal_details') is not null drop table #affected_deal_details
		select sdd.source_deal_header_id,sdh.counterparty_id,sdh.contract_id,sdd.location_id,sdh.template_id,sdd.term_start,sdd.source_deal_detail_id
			,td.receipt_volume, td.fuel_loss,td.net_receipt_volume,td.allocated_delivery,(td.receipt_volume-td.allocated_delivery) [daily_imbalance],tdfd.cashout_vol,tdfd.payback_vol,tdfd.closeout_vol
			,sum(tdfd.daily_imbalance) over(partition by sdd.source_deal_header_id order by sdd.term_start) [daily_imbalance_cummulative]
		into #affected_deal_details --select *
		from source_deal_detail sdd
		inner join source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id
		inner join  #imbalance_deals id on id.counterparty_id = sdh.counterparty_id
			and isnull(id.reporting_contract_id, id.contract_id) = sdh.contract_id
			and id.template_id = sdh.template_id
			and id.location_id = sdd.location_id
		inner join #temp_deals2 td on td.counterparty_id = sdh.counterparty_id
			and isnull(td.reporting_contract_id, td.contract_id) = sdh.contract_id
			and td.location_id = sdd.location_id
			and td.Term = sdd.term_start
		left join #tmp_data_for_deal_detail tdfd on tdfd.counterparty_id = sdh.counterparty_id
			and tdfd.contract_id = sdh.contract_id
			and tdfd.location_id = sdd.location_id
			and tdfd.term_start = sdd.term_start

		--order by 1,2

		--select * from #affected_deal_details
		--return

		--begin tran
		------update deal detail volume
		update sdd set sdd.deal_volume = aff.daily_imbalance_cummulative
		from source_deal_detail sdd
		inner join #affected_deal_details aff on aff.source_deal_detail_id = sdd.source_deal_detail_id
				
		declare @concerned_deal_detail_update table (source_deal_detail_id int,source_deal_header_id int,term_start datetime,deal_volume numeric(20,10))
		
		insert into @concerned_deal_detail_update
		select sdd.source_deal_detail_id,sdd.source_deal_header_id,sdd.term_start,sdd.deal_volume
		from source_deal_detail sdd
		inner join #affected_deal_details aff on aff.source_deal_detail_id = sdd.source_deal_detail_id
		
		--COPY CUMULATIVE DEAL VOLUME FOR OTHER REMAINING NON IMBALANCE TERMS
		
		update sdd set sdd.deal_volume = last_val.deal_volume
		from source_deal_detail sdd
		inner join (select distinct a1.source_deal_header_id from #affected_deal_details a1) th on th.source_deal_header_id = sdd.source_deal_header_id
		cross apply (
			select top 1 cdd.deal_volume, cdd.term_start
			from @concerned_deal_detail_update cdd
			where cdd.source_deal_header_id = th.source_deal_header_id
			order by cdd.term_start desc 
		) last_val
		where sdd.source_deal_detail_id not in (select c.source_deal_detail_id from @concerned_deal_detail_update c) 
			and sdd.term_start = last_val.term_start + 1
	
		--select sdd.deal_volume,sdd.term_start,sdd.*
		--from source_deal_detail sdd
		--inner join source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id
		--inner join  #imbalance_deals id on id.counterparty_id = sdh.counterparty_id
		--	and isnull(id.reporting_contract_id, id.contract_id) = sdh.contract_id
		--	and id.template_id = sdh.template_id
		--	and id.location_id = sdd.location_id

		--rollback
		--return

		--update deal detail udf volumes
		update udddf set udddf.udf_value = 
			case uddft.field_name 
				when -10000141 then aff.receipt_volume --Nominated Volume
				when -5617 then aff.allocated_delivery --Actual Volume
				when -10000130 then aff.daily_imbalance --Daily Imbalance Volume
				when -10000142 then aff.cashout_vol --Cashout Volume
				when -10000143 then aff.payback_vol --Payback Volume
				when -10000144 then aff.closeout_vol --Closeout Volume
				else udddf.udf_value
			end
		from user_defined_deal_detail_fields udddf
		inner join user_defined_deal_fields_template uddft on uddft.udf_template_id = udddf.udf_template_id
		inner join #affected_deal_details aff on aff.source_deal_detail_id = udddf.source_deal_detail_id 
			and aff.template_id = uddft.template_id

		/** UPDATE EXISTING DEAL DETAIL INFO -END **/

		BEGIN TRAN
		INSERT INTO [dbo].[source_deal_header]
			(
				[source_system_id],
				[deal_id],
				[deal_date],
				[ext_deal_id],
				[physical_financial_flag],
				[structured_deal_id],
				[counterparty_id],
				[entire_term_start],
				[entire_term_end],
				[source_deal_type_id],
				[deal_sub_type_type_id],
				[option_flag],
				[option_type],
				[option_excercise_type],
				[source_system_book_id1],
				[source_system_book_id2],
				[source_system_book_id3],
				[source_system_book_id4],
				[description1],
				[description2],
				[description3],
				[deal_category_value_id],
				[trader_id],
				[internal_deal_type_value_id],
				[internal_deal_subtype_value_id],
				[template_id],
				[header_buy_sell_flag],
				[broker_id],
				[generator_id],
				[status_value_id],
				[status_date],
				[assignment_type_value_id],
				[compliance_year],
				[state_value_id],
				[assigned_date],
				[assigned_by],
				[generation_source],
				[aggregate_environment],
				[aggregate_envrionment_comment],
				[rec_price],
				[rec_formula_id],
				[rolling_avg],
				[contract_id],
				[create_user],
				[create_ts],
				[update_user],
				[update_ts],
				[legal_entity],
				[internal_desk_id],
				[product_id],
				[internal_portfolio_id],
				[commodity_id],
				[reference],
				[deal_locked],
				[close_reference_id],
				[block_type],
				[block_define_id],
				[granularity_id],
				[Pricing],
				[deal_reference_type_id],
				[unit_fixed_flag],
				[broker_unit_fees],
				[broker_fixed_cost],
				[broker_currency_id],
				[deal_status],
				[term_frequency],
				[option_settlement_date],
				[verified_by],
				[verified_date],
				[risk_sign_off_by],
				[risk_sign_off_date],
				[back_office_sign_off_by],
				[back_office_sign_off_date],
				[book_transfer_id],
				[confirm_status_type],
				[sub_book],
				[deal_rules],
				[confirm_rule],
				[description4],
				[timezone_id]
			) 
			OUTPUT 
				INSERTED.[source_system_id], INSERTED.[deal_id], INSERTED.[deal_date], INSERTED.[ext_deal_id], 
				INSERTED.[physical_financial_flag], INSERTED.[structured_deal_id], INSERTED.[counterparty_id], 
				INSERTED.[entire_term_start], INSERTED.[entire_term_end], INSERTED.[source_deal_type_id], 
				INSERTED.[deal_sub_type_type_id], INSERTED.[option_flag], INSERTED.[option_type], 
				INSERTED.[option_excercise_type], INSERTED.[source_system_book_id1], INSERTED.[source_system_book_id2], 
				INSERTED.[source_system_book_id3], INSERTED.[source_system_book_id4], INSERTED.[description1], 
				INSERTED.[description2], INSERTED.[description3], INSERTED.[deal_category_value_id], INSERTED.[trader_id],
				INSERTED.[internal_deal_type_value_id], INSERTED.[internal_deal_subtype_value_id], INSERTED.[template_id],
				INSERTED.[header_buy_sell_flag], INSERTED.[broker_id], INSERTED.[generator_id], INSERTED.[status_value_id], 
				INSERTED.[status_date], INSERTED.[assignment_type_value_id], INSERTED.[compliance_year], 
				INSERTED.[state_value_id], INSERTED.[assigned_date], INSERTED.[assigned_by], INSERTED.[generation_source],
				INSERTED.[aggregate_environment], INSERTED.[aggregate_envrionment_comment], INSERTED.[rec_price], 
				INSERTED.[rec_formula_id], INSERTED.[rolling_avg], INSERTED.[contract_id], INSERTED.[create_user], 
				INSERTED.[create_ts], INSERTED.[update_user], INSERTED.[update_ts], INSERTED.[legal_entity], 
				INSERTED.[internal_desk_id], INSERTED.[product_id], INSERTED.[internal_portfolio_id], 
				INSERTED.[commodity_id], INSERTED.[reference], 
				INSERTED.[deal_locked], INSERTED.[close_reference_id], INSERTED.[block_type], INSERTED.[block_define_id], 
				INSERTED.[granularity_id], INSERTED.[Pricing], INSERTED.[deal_reference_type_id], 
				INSERTED.[unit_fixed_flag], INSERTED.[broker_unit_fees], INSERTED.[broker_fixed_cost], 
				INSERTED.[broker_currency_id], INSERTED.[deal_status], INSERTED.[term_frequency], 
				INSERTED.[option_settlement_date], INSERTED.[verified_by], INSERTED.[verified_date], 
				INSERTED.[risk_sign_off_by], INSERTED.[risk_sign_off_date], INSERTED.[back_office_sign_off_by], 
				INSERTED.[back_office_sign_off_date], INSERTED.[book_transfer_id], INSERTED.[confirm_status_type], 
				INSERTED.[sub_book], INSERTED.[deal_rules], INSERTED.[confirm_rule], INSERTED.[description4], 
				INSERTED.[timezone_id], INSERTED.[source_deal_header_id], INSERTED.[description4]
			INTO #tmp_header--select * from #tmp_header
			SELECT sdh.[source_system_id],
					@process_id + '_' + RIGHT('00000000' + CAST(sdh.rowid AS VARCHAR(20)), 8),
					cast(sdh.first_dom as datetime)-1 -- ti.term_start-1,
					,null [ext_deal_id],
					sdht.[physical_financial_flag],
					null [structured_deal_id],
					sdh.counterparty_id [counterparty_id],
					sdh.first_dom term_start,
					DATEADD(MONTH, 1, sdh.first_dom) -1 term_end,
					sdht.[source_deal_type_id],
					null [deal_sub_type_type_id],
					sdh.option_flag [option_flag],
					null [option_type],
					null [option_excercise_type],
					ssbm.source_system_book_id1,
					ssbm.source_system_book_id2,
					ssbm.source_system_book_id3,
					ssbm.source_system_book_id4,
					null [description1],
					null [description2],
					null [description3],
					sdht.[deal_category_value_id],
					sdht.[trader_id], --?
					null [internal_deal_type_value_id],
					null [internal_deal_subtype_value_id],
					sdht.[template_id],
					sdht.[header_buy_sell_flag],
					null [broker_id],
					null [generator_id],
					null [status_value_id],
					null [status_date],
					null [assignment_type_value_id],
					null [compliance_year],
					null [state_value_id],
					null [assigned_date],
					null [assigned_by],
					null [generation_source],
					null [aggregate_environment],
					null [aggregate_envrionment_comment],
					null [rec_price],
					null [rec_formula_id],
					null [rolling_avg],
					isnull(sdh.reporting_contract_id,sdh.contract_id) [contract_id],
					@user_login_id [create_user],
					GETDATE(),
					@user_login_id [update_user],
					GETDATE(),
					null [legal_entity],
					sdht.[internal_desk_id],
					null [product_id],
					null [internal_portfolio_id],
					sdht.[commodity_id],
					null [reference],
					'n' [deal_locked],
					null [close_reference_id],
					null [block_type],
					null [block_define_id],
					null [granularity_id],
					null [Pricing],
					null [deal_reference_type_id],
					null [unit_fixed_flag],
					null [broker_unit_fees],
					null [broker_fixed_cost],
					null [broker_currency_id],
					sdht.[deal_status],
					'd' [term_frequency],
					null [option_settlement_date],
					null [verified_by],
					null [verified_date],
					null [risk_sign_off_by],
					null [risk_sign_off_date],
					null [back_office_sign_off_by],
					null [back_office_sign_off_date],
					null [book_transfer_id],
					sdht.[confirm_status_type],
					sdh.sub_book_id,
					null [deal_rules],
					null [confirm_rule],
					sdh.location_id [description4],
					null [timezone_id]

					--select *
		FROM #tmp_data_for_deal sdh 
			--INNER JOIN #imbalance_deals imb ON sdh.contract_id=imb.reporting_contract_id 
			--	AND sdh.counterparty_id=imb.counterparty_id
			INNER JOIN dbo.source_deal_header_template sdht ON sdht.template_id=sdh.template_id
			INNER JOIN source_system_book_map ssbm ON sdh.sub_book_id=ssbm.book_deal_type_map_id
			LEFT JOIN dbo.source_deal_header h ON h.entire_term_start=sdh.first_dom and h.contract_id=sdh.contract_id
				AND h.counterparty_id=sdh.counterparty_id
				AND h.template_id = sdh.template_id
		where h.source_deal_header_id is null

		
		UPDATE sdh
		SET sdh.deal_id = 'IMB_' + cast(sdh.source_deal_header_id AS VARCHAR(10))
		FROM source_deal_header sdh
		INNER JOIN #tmp_header th ON th.source_deal_header_id = sdh.source_deal_header_id

		select th.source_deal_header_id into #tmp_new_deals from #tmp_header th

		INSERT INTO [dbo].[source_deal_detail]
			(
			[source_deal_header_id],
			[term_start],
			[term_end],
			[Leg],
			[contract_expiration_date],
			[fixed_float_leg],
			[buy_sell_flag],
			[curve_id],
			[fixed_price],
			[fixed_price_currency_id],
			[option_strike_price],
			[deal_volume],
			[deal_volume_frequency],
			[deal_volume_uom_id],
			[block_description],
			[deal_detail_description],
			[formula_id],
			[volume_left],
			[settlement_volume],
			[settlement_uom],
			[create_user],
			[create_ts],
			[update_user],
			[update_ts],
			[price_adder],
			[price_multiplier],
			[settlement_date],
			[day_count_id],
			[location_id],
			[meter_id],
			[physical_financial_flag],
			[Booked],
			[process_deal_status],
			[fixed_cost],
			[multiplier],
			[adder_currency_id],
			[fixed_cost_currency_id],
			[formula_currency_id],
			[price_adder2],
			[price_adder_currency2],
			[volume_multiplier2],
			[pay_opposite],
			[capacity],
			[settlement_currency],
			[standard_yearly_volume],
			[formula_curve_id],
			[price_uom_id],
			[category],
			[profile_code],
			[pv_party],
			[status],
			[lock_deal_detail],
			schedule_volume,
			actual_volume,
			lot,
			product_description,
			batch_id,
			crop_year,
			position_uom
			) 
		OUTPUT INSERTED.source_deal_header_id,INSERTED.source_deal_detail_id, INSERTED.leg, INSERTED.term_start, 
			INSERTED.schedule_volume, INSERTED.actual_volume
		INTO #detail_inserted
		SELECT 
				th.[source_deal_header_id],
				tm.term_start,
				tm.term_end,
				1 [Leg],
				tm.term_end [contract_expiration_date],
				't' [fixed_float_leg],
				MAX(sddt.[buy_sell_flag]) [buy_sell_flag],
				MAX(sdh.[curve_id]) [curve_id],
				null [fixed_price],
				max(sddt.currency_id) [fixed_price_currency_id],
				null [option_strike_price],
				--case when td.term = tm.term_start then sdh.daily_imbalance else null end [deal_volume],
				--SUM(isnull(td.daily_imbalance,0)) [deal_volume],
				null [deal_volume], --will be calculated later
				MAX(sddt.[deal_volume_frequency]) [deal_volume_frequency],
				MAX(sddt.[deal_volume_uom_id]) [deal_volume_uom_id],
				null [block_description],
				null [deal_detail_description],
				MAX(sdh.[formula_id]) [formula_id],
				--case when td.term = tm.term_start then sdh.daily_imbalance else null end [daily_imbalance],
				MAX(isnull(td.daily_imbalance,0)) [daily_imbalance],
				null [settlement_volume],
				null [settlement_uom],
				@user_login_id  [create_user],
				GETDATE() [create_ts],
				@user_login_id [update_user],
				GETDATE() [update_ts],
				null [price_adder],
				1 [price_multiplier],
				tm.term_start [settlement_date],
				null [day_count_id],
				sdh.location_id location_id,
				null [meter_id],
				MAX(sddt.[physical_financial_flag]) [physical_financial_flag],
				null [Booked],
				null [process_deal_status],
				null [fixed_cost],
				null [multiplier],
				null [adder_currency_id],
				null [fixed_cost_currency_id],
				null [formula_currency_id],
				null [price_adder2],
				null [price_adder_currency2],
				null [volume_multiplier2],
				null [pay_opposite],
				null [capacity],
				null [settlement_currency],
				null [standard_yearly_volume],
				null [formula_curve_id],
				null [price_uom_id],
				null [category],
				null [profile_code],
				null [pv_party],
				null [status],
				null [lock_deal_detail],
				null schedule_volume,
				null actual_volume,
				null lot,
				null product_description,
				null batch_id,
				null crop_year,
				MAX(isnull(spcd.display_uom_id,spcd.uom_id)) [position_uom]
		FROM   #tmp_header th
		INNER JOIN [dbo].[source_deal_detail_template] sddt
			ON  sddt.template_id = th.[template_id]
 		INNER JOIN #tmp_data_for_deal sdh ON sdh.first_dom=th.entire_term_start
			AND sdh.counterparty_id = th.counterparty_id
			AND sdh.contract_id = th.contract_id
			AND sdh.template_id = th.template_id
			and sdh.location_id = th.location_id
		OUTER APPLY (
			SELECT DATEADD(day, sq.n - 1 , th.entire_term_start) term_start, DATEADD(day, sq.n - 1 , th.entire_term_start) term_end  
			FROM seq sq
			WHERE th.entire_term_end >= DATEADD(day, sq.n - 1, th.entire_term_start) 
		) tm
		--CROSS APPLY [dbo].[FNATermBreakdown]('d', th.entire_term_start, th.entire_term_end) tm
		OUTER APPLY (
			SELECT td1.daily_imbalance, td1.allocated_delivery, td1.net_receipt_volume, td1.fuel_loss, td1.receipt_volume
			FROM #temp_deals2 td1
			WHERE td1.counterparty_id = th.counterparty_id
				AND ISNULL(td1.reporting_contract_id,td1.contract_id) = th.contract_id
				AND td1.Term = tm.term_start
		) td
		--inner join #temp_deals2 td on isnull(td.reporting_contract_id,td.contract_id)=sdh.contract_id
		--	and td.counterparty_id=sdh.counterparty_id and td.first_dom=sdh.first_dom
		--	and td.group_id = sdh.group_id
		--	--and td.term=tm.term_start
		left join source_price_curve_def spcd on spcd.source_curve_def_id = sdh.curve_id
		--WHERE NOT (ISNULL(td.daily_imbalance,0)=0 AND ISNULL(td.allocated_delivery,0)=0 
		--	AND ISNULL(td.net_receipt_volume,0)=0
		--	AND ISNULL(td.fuel_loss,0)=0 AND ISNULL(td.receipt_volume,0) =0)
		GROUP BY th.source_deal_header_id, tm.term_start,tm.term_end,sdh.location_id
		ORDER BY --th.counterparty_id,th.contract_id,
				 th.source_deal_header_id,	tm.term_start

		--UPDATE DEAL VOLUME TO SET EQUALS TO DAILY IMBALANCE FOR IMBALANCE TERMS
		
		update sdd set sdd.deal_volume = tsdd.daily_balance_cummulative
		from source_deal_detail sdd
		inner join #tmp_header th on th.source_deal_header_id = sdd.source_deal_header_id
		inner join #tmp_data_for_deal_detail tsdd on tsdd.term_start=sdd.term_start
			and tsdd.counterparty_id = th.counterparty_id
			and tsdd.location_id= sdd.location_id
			and tsdd.contract_id = th.contract_id
			and tsdd.template_id = th.template_id
		
		declare @concerned_deal_detail table (source_deal_detail_id int,source_deal_header_id int,term_start datetime,deal_volume numeric(20,10))
		
		insert into @concerned_deal_detail
		select sdd.source_deal_detail_id,sdd.source_deal_header_id,sdd.term_start,sdd.deal_volume
		from source_deal_detail sdd
		inner join #tmp_header th on th.source_deal_header_id = sdd.source_deal_header_id
		inner join #tmp_data_for_deal_detail tsdd on tsdd.term_start=sdd.term_start
			and tsdd.counterparty_id = th.counterparty_id
			and tsdd.location_id= sdd.location_id
			and tsdd.contract_id = th.contract_id
			and tsdd.template_id = th.template_id
		

		--COPY CUMULATIVE DEAL VOLUME FOR OTHER REMAINING NON IMBALANCE TERMS
		
		update sdd set sdd.deal_volume = last_val.deal_volume
		from source_deal_detail sdd
		inner join #tmp_header th on th.source_deal_header_id = sdd.source_deal_header_id
		cross apply (
			select top 1 cdd.deal_volume, cdd.term_start
			from @concerned_deal_detail cdd
			where cdd.source_deal_header_id = th.source_deal_header_id
			order by cdd.term_start desc 
		) last_val
		where sdd.source_deal_detail_id not in (select c.source_deal_detail_id from @concerned_deal_detail c) 
			and sdd.term_start = last_val.term_start + 1

		--select sdd.deal_volume,sdd.term_start,sdd.*
		--from source_deal_detail sdd
		--inner join #tmp_header th on th.source_deal_header_id = sdd.source_deal_header_id
		
		--rollback
		--return
	
		UPDATE udddf 
		SET 
			udf_value = td.daily_imbalance
			--, volume_left=td.daily_imbalance
		OUTPUT inserted.source_deal_detail_id  INTO #tmp_new_deals
		FROM  source_deal_detail sdd
			INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id=sdh.source_deal_header_id
			INNER JOIN user_defined_deal_fields_template uddft
				ON uddft.template_id = sdh.template_id 
			INNER JOIN user_defined_deal_detail_fields udddf
				ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
			INNER JOIN #temp_deals2 td ON ISNULL(td.reporting_contract_id,td.contract_id)=sdh.contract_id
				AND td.counterparty_id=sdh.counterparty_id AND td.first_dom=sdh.entire_term_start
				AND td.term=sdd.term_start
			LEFT JOIN #tmp_header th ON sdh.entire_term_start=th.entire_term_start
				AND th.contract_id=sdh.contract_id and th.counterparty_id=sdh.counterparty_id
		WHERE td.rowid IS NULL
			AND ISNULL(td.daily_imbalance,0)<>0 
			AND uddft.field_name = -10000130 --Daily Imbalance Volume (UDF)

		DECLARE @new_deal_ids VARCHAR(MAX)

		SELECT @new_deal_ids = ISNULL( @new_deal_ids + ',', '') + CAST(sdd.source_deal_header_id AS VARCHAR(10))
		FROM #tmp_new_deals tnd
		INNER JOIN source_deal_detail sdd
			ON tnd.source_deal_header_id = sdd.source_deal_detail_id
	
		SELECT  @new_deal_ids = ISNULL( @new_deal_ids + ',', '') + CAST(source_deal_header_id AS VARCHAR(10))
		FROM #tmp_new_deals
	
		INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id, udf_template_id, udf_value)
		SELECT 
			sdd.source_deal_detail_id, 
			uddft.udf_template_id, 
			CAST (round(sddt.daily_imbalance , 0) AS INT) deal_volume
		FROM #tmp_header sdh
		INNER JOIN source_deal_detail sdd
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
			AND uddft.field_name = -10000130
		left join #tmp_data_for_deal_detail sddt on sddt.term_start=sdd.term_start
				and sddt.counterparty_id = sdh.counterparty_id
				and sddt.location_id= sdd.location_id
				and sddt.contract_id = sdh.contract_id
				and sddt.template_id = sdh.template_id
		 --Daily Imbalance Volume (UDF)
	
		--insert udf value for 'Nominated Volume', 'Actual Volume'
		INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id, udf_template_id, udf_value)
		SELECT 
			sdd.source_deal_detail_id, 
			uddft.udf_template_id, 
			CAST (round(sdh.receipt_volume,0) as int) net_receipt_volume
			--sdh.net_receipt_volume
		FROM #tmp_header th
		INNER JOIN source_deal_detail sdd
			ON sdd.source_deal_header_id = th.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template uddft
			ON uddft.template_id = th.template_id
			AND uddft.field_name = -10000141 --Nominated Volume (UDF)
		left join #tmp_data_for_deal_detail sdh on sdh.term_start=sdd.term_start
				and sdh.counterparty_id = th.counterparty_id
				and sdh.location_id= sdd.location_id
				and sdh.contract_id = th.contract_id
				and sdh.template_id = th.template_id
		
	
		--insert udf value for 'Actual Volume', 'Actual Volume'
		INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id, udf_template_id, udf_value)
		SELECT 
			sdd.source_deal_detail_id, 
			uddft.udf_template_id, 
			sdh.allocated_delivery  
		FROM #tmp_header th
		INNER JOIN source_deal_detail sdd
			ON sdd.source_deal_header_id = th.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template uddft
			ON uddft.template_id = th.template_id
			AND uddft.field_name = -5617 --Actual Volume (UDF)
		left join #tmp_data_for_deal_detail sdh on sdh.term_start=sdd.term_start
				and sdh.counterparty_id = th.counterparty_id
				and sdh.location_id= sdd.location_id
				and sdh.contract_id = th.contract_id
				and sdh.template_id = th.template_id
		

		--insert udf value for 'Cashout Volume', 'Actual Volume'
		INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id, udf_template_id, udf_value)
		SELECT 
			sdd.source_deal_detail_id, 
			uddft.udf_template_id, 
			CAST (ROUND(sdh.cashout_vol, 0) AS INT ) cashout_vol
		FROM #tmp_header th
		INNER JOIN source_deal_detail sdd
			ON sdd.source_deal_header_id = th.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template uddft
			ON uddft.template_id = th.template_id
			AND uddft.field_name = -10000142 --Cashout Volume (UDF)
		left join #tmp_data_for_deal_detail sdh on sdh.term_start=sdd.term_start
				and sdh.counterparty_id = th.counterparty_id
				and sdh.location_id= sdd.location_id
				and sdh.contract_id = th.contract_id
				and sdh.template_id = th.template_id
		

		--insert udf value for 'Payback Volume', 'Actual Volume'
		INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id, udf_template_id, udf_value)
		SELECT 
			sdd.source_deal_detail_id, 
			uddft.udf_template_id, 
			CAST(ROUND(sdh.payback_vol, 0) AS INT) payback_vol
		FROM #tmp_header th
		INNER JOIN source_deal_detail sdd
			ON sdd.source_deal_header_id = th.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template uddft
			ON uddft.template_id = th.template_id
			AND uddft.field_name = -10000143 --Payback Volume (UDF)
		left join #tmp_data_for_deal_detail sdh on sdh.term_start=sdd.term_start
				and sdh.counterparty_id = th.counterparty_id
				and sdh.location_id= sdd.location_id
				and sdh.contract_id = th.contract_id
				and sdh.template_id = th.template_id
		
	
		--insert udf value for 'Closeout Volume', 'Actual Volume'
		INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id, udf_template_id, udf_value)
		SELECT 
			sdd.source_deal_detail_id, 
			uddft.udf_template_id, 
			CAST(ROUND(sdh.closeout_vol,0) As INT)  closeout_vol
		FROM #tmp_header th
		INNER JOIN source_deal_detail sdd
			ON sdd.source_deal_header_id = th.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template uddft
			ON uddft.template_id = th.template_id
			AND uddft.field_name = -10000144 --Closeout Volume (UDF)
		left join #tmp_data_for_deal_detail sdh on sdh.term_start=sdd.term_start
				and sdh.counterparty_id = th.counterparty_id
				and sdh.location_id= sdd.location_id
				and sdh.contract_id = th.contract_id
				and sdh.template_id = th.template_id
		
	
		/*
		--update deal_volume which is cummulative imbalance of report
		UPDATE sdd
			SET deal_volume = (sddt.daily_imbalance+sddt.cashout_vol+sddt.payback_vol+sddt.closeout_vol)
		FROM source_deal_detail sdd
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN #tmp_header sdht ON sdht.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN #tmp_data_for_deal_detail sddt ON sddt.counterparty_id = sdh.counterparty_id
			AND sddt.location_id = sdd.location_id
			AND sddt.contract_id = sdh.contract_id
			AND sddt.term_start = sdd.term_start
		*/

			if ISNULL(@new_deal_ids, @deal_ids) is not null
			begin
				SET @job_name =  'calc_position_breakdown_' + @process_id
				SET @sql_str = 'spa_calc_deal_position_breakdown @deal_header_ids=''' + ISNULL(@new_deal_ids, @deal_ids) + ''''
				EXEC spa_run_sp_as_job @job_name,  @sql_str, 'Position Calculation', @user_login_id 

				--print @sql_str
				--EXEC spa_calc_deal_position_breakdown  @deal_header_ids=@new_deal_ids
			end

			END 	
		END 		
	END

	IF  ISNULL(@run_mode,0)=1
	BEGIN

		SET @desc = 'Imbalance calculation completed successfully.' 
		SET @batch_process_id =ISNULL(@batch_process_id, dbo.FNAGetNewID())
	
		SET @job_name = 'Imbalance_'+@batch_process_id 
		EXEC  spa_message_board 'u', @user_login_id, NULL, 'Imbalance Calculation', @desc, '', '', 's', @job_name,NULL, @batch_process_id,NULL,'n',NULL,'y'
	END
	

	------------------------------------------------------------------
 
	IF ISNULL(@run_mode, 0) <> 1
	BEGIN
		/*******************************************2nd Paging Batch START**********************************************/
		--UPDATE time spent AND batch completion message in message board

		IF @is_batch = 1
		BEGIN
			SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
			EXEC (@str_batch_table)
	 
			SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
						   GETDATE(), 'spa_create_imbalance_report', 'Imbalance Report') --TODO: modify sp AND report name
			--EXEC (@str_batch_table) --commented since issue on batch for csv export, since no file saving is needed for imbalance deal create on batch mode.
		END
 
		--IF it IS first call FROM paging, return total no. of rows AND process id instead of actual data
		IF @enable_paging = 1 AND @page_no IS NULL
		BEGIN
			SET @sql_paging = dbo.FNAPagingProcess ('t', @batch_process_id, @page_size, @page_no)
			EXEC (@sql_paging)
		END
	
		/*******************************************2nd Paging Batch END**********************************************/
	END
	---- success
	EXEC spa_ErrorHandler 0,
			 'Create Imbalance Report.',
			  'spa_create_imbalance_report',
			  'Success',
			  'Changes have been saved successfully.',
			  ''
	COMMIT TRAN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
	DECLARE @err_msg VARCHAR(5000) = error_message()
	--print @err_msg
	EXEC spa_ErrorHandler -1,
				'Create Imbalance Report.',
				'spa_create_imbalance_report',
				'Error',
				@err_msg,
				''
END CATCH
