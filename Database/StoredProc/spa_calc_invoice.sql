
/****** Object:  StoredProcedure [dbo].[spa_calc_invoice]    Script Date: 05/22/2012 15:18:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_calc_invoice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_calc_invoice]
GO

 /**
	Calculate Fees/chages of Settled invoice line items of contract

	Parameters : 
	@prod_date : From Product Date  to process
	@counterparty_id : Counterparty Id to process
	@as_of_date : As Of Date to process
	@process_id : Process Id to process
	@test_run : Test Run
	@settlement_adjustment : Settlement Adjustment
	@sub_entity_id : Subsidiary filter  to process
	@contract_id_param : Contract Id to process
	@estimate_calculation : Estimate Calculation
	@module_type : Module Type
						- 'stlmnt' - Settlement
						- 'trm' - TRM
	@invoice_line_item_id : Invoice Line Item Id
	@deal_id : Deal Id filter  to process
	@deal_ref_id : Deal Ref Id filter  to process
	@deal_set_calc : Calculate deal settlement
	@cpt_type : Counterparty Type filter  to process
	@deal_list_table : Input Deal List Table filter  to process
	@date_type : Date Type
						- 's' - Settlement
						- 't' - Term
	@calc_id : Calc Id  filter  to process
	@prod_date_to : Tp Product Date to process
	@call_from_true_up : Call From True Up


  */

CREATE PROCEDURE [dbo].[spa_calc_invoice]
	@prod_date DATETIME = NULL,
	@counterparty_id VARCHAR(MAX) = NULL,
	@as_of_date DATETIME = NULL,
	@process_id VARCHAR(100) = NULL,
	@test_run CHAR(1) = 'n',
	@settlement_adjustment CHAR(1) = 'n',
	@sub_entity_id INT = NULL,
	@contract_id_param VARCHAR(MAX) = NULL,
	@estimate_calculation CHAR(1) = 'n',
	@module_type VARCHAR(10) = NULL,
	@invoice_line_item_id VARCHAR(MAX) = NULL,
	@deal_id VARCHAR(MAX) = NULL,
	@deal_ref_id VARCHAR(100) = NULL,
	@deal_set_calc CHAR(1) = 'n',
	@cpt_type CHAR(1) = NULL,
	@deal_list_table VARCHAR(300) = NULL ,
	@date_type CHAR(1) = 's', -- 's' - Settlement, 't' Term
	@calc_id VARCHAR(MAX) = NULL,
	@prod_date_to DATETIME = NULL,
	@call_from_true_up CHAR(1) = 'n'

AS 

/*

DECLARE @prod_date DATETIME
DECLARE @counterparty_id VARCHAR(100)
DECLARE @as_of_date DATETIME
DECLARE @process_id VARCHAR(100)
DECLARE @test_run CHAR(1)
DECLARE @settlement_adjustment CHAR(1)
DECLARE @sub_entity_id INT
DECLARE @contract_id_param VARCHAR(1000)
DECLARE @estimate_calculation CHAR(1)
DECLARE @module_type VARCHAR(100)
DECLARE @prod_date_to DATETIME
DECLARE @invoice_line_item_id VARCHAR(100)
DECLARE @deal_id  VARCHAR(100)
DECLARE @deal_ref_id VARCHAR(100)
DECLARE @deal_set_calc CHAR(1)
DECLARE @cpt_type CHAR(1)
DECLARE @deal_filter_id VARCHAR(500)
DECLARE @deal_list_table VARCHAR(300)
DECLARE @date_type CHAR(1) 
DECLARE @calc_id VARCHAR(100)
DECLARE @call_from_true_up CHAR(1) = 'n'

SET @counterparty_id='8861'
SET @as_of_date='2018-01-31'
SET @prod_date='2018-01-01'
set @prod_date_to='2018-01-31'
SET @contract_id_param =10260
SET @process_id=NULL
SET @test_run='n'
SET @settlement_adjustment='n'
SET @sub_entity_id=NULL
SET @estimate_calculation='n'
SET @module_type='stlmnt'
SET @deal_set_calc = 'y'
SET @date_type = 't'
SET @cpt_type = 'e'
--SET @calc_id = 33686
--SET @invoice_line_item_id=302306

  
IF OBJECT_ID('tempdb..#tmp_block_def') IS NOT NULL DROP TABLE #tmp_block_def
IF OBJECT_ID('tempdb..#tmp_cache_curve') IS NOT NULL DROP TABLE #tmp_cache_curve
IF OBJECT_ID('tempdb..#table_temp_metervolume') IS NOT NULL DROP TABLE #table_temp_metervolume
IF OBJECT_ID('tempdb..#books') IS NOT NULL DROP TABLE #books
IF OBJECT_ID('tempdb..#temp_meter') IS NOT NULL DROP TABLE #temp_meter
IF OBJECT_ID('tempdb..#temp_calc') IS NOT NULL DROP TABLE #temp_calc
IF OBJECT_ID('tempdb..#missing_meter_data') IS NOT NULL DROP TABLE #missing_meter_data
IF OBJECT_ID('tempdb..#temp_variables') IS NOT NULL DROP TABLE #temp_variables
IF OBJECT_ID('tempdb..#temp_deals') IS NOT NULL DROP TABLE #temp_deals
IF OBJECT_ID('tempdb..#impact_deals') IS NOT NULL DROP TABLE #impact_deals
IF OBJECT_ID('tempdb..#impact_line_items') IS NOT NULL DROP TABLE #impact_line_items
IF OBJECT_ID('tempdb..#total_inv_volume') IS NOT NULL DROP TABLE #total_inv_volume
IF OBJECT_ID('tempdb..#temp_volumeper') IS NOT NULL DROP TABLE #temp_volumeper
IF OBJECT_ID('tempdb..#temp_hour') IS NOT NULL DROP TABLE #temp_hour
IF OBJECT_ID('tempdb..#temp_15mins') IS NOT NULL DROP TABLE #temp_15mins
IF OBJECT_ID('tempdb..#temp_30mins') IS NOT NULL DROP TABLE #temp_30mins
IF OBJECT_ID('tempdb..#temp_month') IS NOT NULL drop table #temp_month
IF OBJECT_ID('tempdb..#temp_daily') IS NOT NULL drop table #temp_daily
IF OBJECT_ID('tempdb..#temp_formula') IS NOT NULL drop table #temp_formula
IF OBJECT_ID('tempdb..#formula_cache') IS NOT NULL drop table #formula_cache
IF OBJECT_ID('tempdb..#function_lists') IS NOT NULL drop table #function_lists
IF OBJECT_ID('tempdb..#factor_formula_value') IS NOT NULL drop table #factor_formula_value
IF OBJECT_ID('tempdb..#pv') IS NOT NULL drop table #pv
IF OBJECT_ID('tempdb..#formula_value') IS NOT NULL drop table #formula_value
IF OBJECT_ID('tempdb..#formula_value1') IS NOT NULL drop table #formula_value1
IF OBJECT_ID('tempdb..#ContractBillingDate') IS NOT NULL drop table #ContractBillingDate
IF OBJECT_ID('tempdb..#prod_dt') IS NOT NULL DROP TABLE #prod_dt
IF OBJECT_ID('tempdb..#Proxy_term') IS NOT NULL DROP TABLE #Proxy_term
IF OBJECT_ID('tempdb..#temp_financial') IS NOT NULL DROP TABLE #temp_financial
IF OBJECT_ID('tempdb..#Onpeak_offpeak_block') IS NOT NULL DROP TABLE #Onpeak_offpeak_block
IF OBJECT_ID('tempdb..#pvt_table') IS NOT NULL DROP TABLE #pvt_table
IF OBJECT_ID('tempdb..#manual_line_item') IS NOT NULL DROP TABLE  #manual_line_item
IF OBJECT_ID('tempdb..#premium') IS NOT NULL DROP TABLE #premium
IF OBJECT_ID('tempdb..#temp_source_deal_header_id') IS NOT NULL DROP TABLE #temp_source_deal_header_id
IF OBJECT_ID('tempdb..#calc_summary') IS NOT NULL DROP TABLE #calc_summary
IF OBJECT_ID('tempdb..#cpty') IS NOT NULL DROP TABLE #cpty
IF OBJECT_ID('tempdb..#15minutes_temp') IS NOT NULL drop table #15minutes_temp
IF OBJECT_ID('tempdb..#CTE') IS NOT NULL drop table #CTE
IF OBJECT_ID('tempdb..#CTE1') IS NOT NULL drop table #CTE1
IF OBJECT_ID('tempdb..#CTE2') IS NOT NULL drop table #CTE2
IF OBJECT_ID('tempdb..#30minutes_temp') IS NOT NULL drop table #30minutes_temp
IF OBJECT_ID('tempdb..#calc_netting_summary') IS NOT NULL drop table #calc_netting_summary
IF OBJECT_ID('tempdb..#invoice_allocation') IS NOT NULL drop table #invoice_allocation
IF OBJECT_ID('tempdb..#invoice_seed') IS NOT NULL drop table #invoice_seed




--*/

BEGIN TRY
  
	DECLARE @total_Volume money
	DECLARE @rowcount INT   
	DECLARE @sqlstmt VARCHAR(MAX), @sqlstmt1 VARCHAR(MAX)   
	DECLARE @count INT   
	DECLARE @conv_uom_id INT   
	DECLARE @contract_id INT   
	DECLARE @counterparty_name NVARCHAR(1000)
	DECLARE @granularity INT
	DECLARE @sub_id INT
	DECLARE @xcel_sub_id INT
	DECLARE @meter_data_exists char(1)
	DECLARE @estimated char(1)
	DECLARE @UDF_FROM_date DATETIME 
	DECLARE @UDF_To_date DATETIME 
	DECLARE @sett_calc_id INT
	DECLARE @calc_time DATETIME 
	DECLARE @calc_start_time DATETIME 
	DECLARE @meter_not_required char(1)
	DECLARE @user_login_id VARCHAR(100)
	DECLARE @process_id1 VARCHAR(100)
	DECLARE @tempTable VARCHAR(1000)
	DECLARE @uses_meter char(1)
	DECLARE @meter_found CHAR(1)   
	DECLARE @MAX_term_start DATETIME 
	DECLARE @MAXid INT   
	DECLARE @totalvolume money   
	DECLARE @leftvolume money  
	DECLARE @url VARCHAR(500)
	DECLARE @user_name VARCHAR(100)
	DECLARE @new_process_id VARCHAR(100)		
	DECLARE @billing_cycle INT   
	DECLARE @prod_month INT
	DECLARE @table_calc_invoice_volume_variance VARCHAR(128)
	DECLARE @table_calc_invoice_volume_recorder VARCHAR(128)
	DECLARE @table_calc_invoice_volume VARCHAR(128)
	DECLARE @table_calc_invoice_volume_detail VARCHAR(128)
	DECLARE @table_calc_formula_value VARCHAR(128)
	DECLARE @stmt VARCHAR(MAX)
	DECLARE @stmt1 VARCHAR(MAX)
	DECLARE @table_temp_metervolume VARCHAR(128)
	DECLARE @test_process_id VARCHAR(100)		
	DECLARE @transportation_deal_type INT
	DECLARE @formula_id INT
	DECLARE @15_mins_calculation CHAR(1)
	DECLARE @total_time VARCHAR(100)
	DECLARE @desc VARCHAR(500)
	DECLARE  @job_name VARCHAR(100)
	DECLARE @calc_result_table VARCHAR(100),@calc_result_detail_table VARCHAR(100)
	DECLARE @formula_table VARCHAR(100)
	DECLARE @hourly_calculation CHAR(1)
	DECLARE @Pivot_table VARCHAR(MAX),@Pivot_table1 VARCHAR(MAX)
	DECLARE @model_name VARCHAR(100)
	
	IF @cpt_type ='m'
		SET @model_name = 'Financial Model Calculation'
	ELSE
		SET @model_name = 'Settlement Reconciliation'

	IF @contract_id_param = 'NULL'
		SET @contract_id_param = NULL

	IF @counterparty_id = 'NULL'
		SET @counterparty_id = NULL
	
	IF @calc_id = '' OR @calc_id = 'NULL'
		SET @calc_id = NULL
										
	DECLARE @premium_id INT

	SET @premium_id = 2
	-------##################
	
	SET @hourly_calculation='n'
	-------##################
	
	IF @prod_date_to IS NULL  
		SET @prod_date_to=@prod_date

	DECLARE @prod_date_to_str VARCHAR(10)
	SET @prod_date_to_str = CONVERT(VARCHAR(10),@prod_date_to,120)
	SET @job_name = 'batch_' + @process_id
	SET @15_mins_calculation='n'
	SET @transportation_deal_type=981
	SET @user_login_id = dbo.fnadbuser()

	SET @meter_data_exists='n'
	SET @meter_not_required='n'
	SET @estimated='n'
	SET @xcel_sub_id=-1
	IF @settlement_adjustment IS NULL
	   SET @settlement_adjustment='n'

	IF @module_type IS NULL
		SET @module_type='trm'

	--SET @prod_date = dbo.FNAGetContractMonth(@prod_date)
	
	SET @granularity = 980
	--Print 'start calculation:'+convert(VARCHAR(100),getdate(),113)
	SET @calc_time=getdate() -- Note down the calculation Start Time
	

		create table #table_temp_metervolume(
			volume FLOAT	
		)

IF @sub_entity_id IS NULL
   SET @sub_entity_id=-1	

-- ########### SELECT book FROM 
CREATE TABLE #books (fas_book_id INT) 
CREATE TABLE #temp_source_deal_header_id (source_deal_header_id INT)


/*---#### Determins the invoice or Remitance based on configurations defined in default code values. 
If var_value =1 -> +Ve is Invoice and -Ve is Remittance

*/
DECLARE @ir_sign CHAR(1),@ir_sign_rev CHAR(1),@inv_remit_logic INT

SELECT  @inv_remit_logic =  var_value
FROM         adiha_default_codes_values
WHERE     (instance_no = 1) AND (default_code_id = 87) AND (seq_no = 1)

IF @inv_remit_logic = 2
BEGIN
	SET @ir_sign = 'i'
	SET @ir_sign_rev = 'r'
END
ELSE
BEGIN
	SET @ir_sign = 'r'
	SET @ir_sign_rev = 'i'
END

IF OBJECT_ID(@deal_list_table) IS NOT NULL
BEGIN
    EXEC ('INSERT INTO #temp_source_deal_header_id  SELECT DISTINCT source_deal_header_id FROM ' + @deal_list_table)
END


IF NOT EXISTS(SELECT 'X' FROM #temp_source_deal_header_id) 
	SET @deal_list_table = NULL

	SET @sqlstmt=        

	'INSERT INTO  #books(fas_book_id)
		SELECT 
			distinct book.entity_id fas_book_id 
		FROM 
			portfolio_hierarchy book (nolock) 
			INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id 
			LEFT OUTER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
		WHERE 1=1 '                 

	IF @sub_entity_id <>-1
	  SET @sqlstmt = @sqlstmt + ' AND stra.parent_entity_id IN  ( ' + CAST(@sub_entity_id AS VARCHAR) + ') '         
	EXEC(@sqlstmt)


--#################################
-- Section: Process TestRun
-- SELECT Contract variables FROM the Contract
-- Create a report to show the variance between the calculated value AND the new value.
--#################################
	IF @process_id is null or @process_id = ''
		SET @test_process_id=REPLACE(newid(),'-','_')
	ELSE
		SET @test_process_id = @process_id

	DECLARE @calc_type CHAR(1)
	IF @deal_set_calc = 'y'
	BEGIN
		SET @calc_type = CASE WHEN @cpt_type = 'b' THEN 'b' ELSE 's' END
		SET @stmt = 'EXEC  spa_calc_mtm_job '+ISNULL(NULLIF(CAST(@sub_entity_id AS VARCHAR),-1),'NULL')+',NULL,NULL,NULL,' + ISNULL(@deal_id, 'NULL') + ',''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''',4500,NULL,''b'',NULL,''' + @job_name + ''',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,''n'',''' + CONVERT(VARCHAR(10),@prod_date,120) +''',''' + CONVERT(VARCHAR(10),@prod_date_to,120) +''','''+@calc_type+''',NULL,NULL,'+ISNULL(''''+@deal_list_table+'''', 'NULL')+',NULL,'''+@counterparty_id+''','+ISNULL(''''+@deal_ref_id+'''','NULL')+',NULL,NULL,0,0,0,''' + @process_id + ''''
		--PRINT(ISNULL(@stmt, 'isnull'))
		EXEC(@stmt)
	END

IF @test_run='y'
BEGIN 

	SET @table_calc_invoice_volume_variance=dbo.FNAProcessTableName('calc_invoice_volume_variance', @user_login_id,@test_process_id)
	SET @table_calc_invoice_volume_recorder =dbo.FNAProcessTableName('calc_invoice_volume_recorder', @user_login_id,@test_process_id)
	SET @table_calc_invoice_volume=dbo.FNAProcessTableName('calc_invoice_volume', @user_login_id,@test_process_id)

	SET @table_temp_metervolume=dbo.FNAProcessTableName('temp_metervolume', @user_login_id,@test_process_id)

	DECLARE @create_calc_invoice_volume_variance VARCHAR(MAX)

	
		SET @create_calc_invoice_volume_variance = '
		CREATE TABLE ' + @table_calc_invoice_volume_variance + '(
			[calc_id] [INT] IDENTITY(1,1) NOT NULL,
			[as_of_date] [DATETIME ] NULL,
			[recorderid] [VARCHAR](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[counterparty_id] [INT] NULL,
			[generator_id] [INT] NULL,
			[contract_id] [INT] NULL,
			[prod_date] [DATETIME ] NULL,
			[metervolume] [FLOAT] NULL,
			[invoicevolume] [FLOAT] NULL,
			[allocationvolume] [FLOAT] NULL,
			[variance] [FLOAT] NULL,
			[onpeak_volume] [FLOAT] NULL,
			[offpeak_volume] [FLOAT] NULL,
			[UOM] [INT] NULL,
			[ActualVolume] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[book_entries] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[finalized] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[invoice_id] [INT] NULL,
			[deal_id] [INT] NULL,
			[create_user] [VARCHAR](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[create_ts] [DATETIME ] NULL,
			[update_user] [VARCHAR](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[update_ts] [DATETIME ] NULL,
			[estimated] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[calculation_time] [FLOAT] NULL,
			sub_id INT,
			invoice_lock CHAR(1),
			invoice_number VARCHAR(50),
			invoice_type CHAR(1),
			netting_group_id	int,
			prod_date_to	datetime,
			settlement_date		datetime,
			invoice_template_id		INT,
			netting_calc_id INT
		 CONSTRAINT [PK_' + @table_calc_invoice_volume_variance + '] PRIMARY KEY CLUSTERED 
		(
			[calc_id] ASC
		)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	'

	IF @process_id is not null
		EXEC(@create_calc_invoice_volume_variance)


	DECLARE @create_calc_invoice_volume_recorder VARCHAR(MAX)
	SET @create_calc_invoice_volume_recorder = '
		create table ' + @table_calc_invoice_volume_recorder + '(
			calc_id	INT identity,
			as_of_date	DATETIME ,
			recorderid	VARCHAR(100),
			counterparty_id	INT,
			generator_id	INT,
			contract_id	INT,
			prod_date	DATETIME ,
			metervolume	FLOAT,
			invoicevolume	FLOAT,
			allocationvolume	FLOAT,
			variance	FLOAT,
			onpeak_volume	FLOAT,
			offpeak_volume	FLOAT,
			UOM	INT,
			ActualVolume	char(1),
			book_entries	char(1),
			finalized	char(1),
			invoice_id	INT,
			deal_id	INT,
			create_user	VARCHAR(50),
			create_ts	DATETIME ,
			update_user	VARCHAR(50),
			update_ts	DATETIME ,
			original_volume	FLOAT
		)
	'
	IF @process_id is not null
		EXEC(@create_calc_invoice_volume_recorder)

	DECLARE @create_calc_invoice_volume VARCHAR(MAX)
	SET @create_calc_invoice_volume = '
		create table '+@table_calc_invoice_volume+'(
			calc_detail_id	INT identity,
			calc_id	INT,
			invoice_line_item_id	INT,
			prod_date	DATETIME ,
			Value	FLOAT,
			Volume	FLOAT,
			manual_input	char(1),
			default_gl_id	INT,
			uom_id	INT,
			price_or_formula	char(1),
			onpeak_offpeak	char(1),
			remarks	VARCHAR(100),
			finalized	char(1),
			finalized_id	INT,
			inv_prod_date	DATETIME ,
			include_volume	char(1),
			create_user	VARCHAR(50),
			create_td	DATETIME ,
			update_user	VARCHAR(50),
			update_ts	DATETIME ,
			default_gl_id_estimate	INT,
			deal_type_id INT,
			status	char(1),
			inventory	char(1)
		
		)
	'
	IF @process_id is not null 
		EXEC(@create_calc_invoice_volume)

END

ELSE IF @test_run='n'
BEGIN 
	IF @estimate_calculation='y'
		BEGIN
			SET @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance_estimates'
			SET @table_calc_invoice_volume_recorder = 'calc_invoice_volume_recorder_estimates'
			SET @table_calc_invoice_volume = 'calc_invoice_volume_estimates'
			SET @table_calc_formula_value ='calc_formula_value_estimates'

		END
	ELSE
		BEGIN
			SET @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance'
			SET @table_calc_invoice_volume_recorder = 'calc_invoice_volume_recorder'
			SET @table_calc_invoice_volume = 'calc_invoice_volume'
			SET @table_calc_formula_value ='calc_formula_value'
		END
END



--*************************************
--Create Temporary tables
--*************************************

	CREATE TABLE #temp_meter(recorderid VARCHAR(100) COLLATE DATABASE_DEFAULT,prod_date DATETIME )

	CREATE TABLE #temp_calc(   
		[id] INT identity,   
		meter_id INT,   
		counterparty_id INT,   
		generator_id INT,   
		contract_id INT,   
		prod_date DATETIME ,   
		metervolume FLOAT,   
		invoicevolume FLOAT,   
		allocationvolume FLOAT,   
		variance FLOAT,   
		onpeak_volume FLOAT,   
		offpeak_volume FLOAT,   
		UOM INT,   
		ActualVolume VARCHAR(1) COLLATE DATABASE_DEFAULT,   
		book_entries VARCHAR(1) COLLATE DATABASE_DEFAULT,   
		Finalized VARCHAR(1) COLLATE DATABASE_DEFAULT,   
		invoice_id INT ,
		deal_id INT,
		original_volume FLOAT,
		conversion_factor FLOAT 
	)   
	  
	---------------------------------
	CREATE TABLE #missing_meter_data(
		meter_id INT,
		channel INT,
		prod_date DATETIME ,
		missing char(1) COLLATE DATABASE_DEFAULT,
		last_day INT,	
		current_month_last_day INT
	)

	---------------------------------
	create table #temp_variables(
		v_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		v_value VARCHAR(100) COLLATE DATABASE_DEFAULT
	)

	
	
	CREATE TABLE #temp_formula(
		counterparty_id INT,
		contract_id INT,
		invoice_Line_item_id INT,
		invoice_template_id INT,
		price FLOAT,
		formula_id INT,
		formula_sequence_number INT,
		[ID] INT,
		granularity INT,
		invoice_line_item_sequence_number INT,	
		deal_type_id INT,
		calc_id INT,
		calc_aggregation INT,
		timeofuse INT,
		uom_id INT,
		formula VARCHAR(8000) COLLATE DATABASE_DEFAULT,
		contract_calc_type CHAR(1) COLLATE DATABASE_DEFAULT,
		group1 INT,
		group2 INT,
		group3 INT,
		group4 INT,
		neting_rule CHAR(1) COLLATE DATABASE_DEFAULT,
		leg INT,
		is_true_up CHAR(1) COLLATE DATABASE_DEFAULT,
		document_type CHAR(1) COLLATE DATABASE_DEFAULT,
		buy_sell CHAR(1) COLLATE DATABASE_DEFAULT,
		location_id INT,
		dst_group_value_id INT
	)


	CREATE TABLE #ContractBillingDate(
			contract_id INT,
			udf_from_date DATETIME,
			udf_to_date DATETIME,
			udf_from_date_hour DATETIME,
			udf_to_date_hour DATETIME,
		)


	CREATE TABLE #temp_financial(counterparty_id INT,contract_id INT, prod_date DATETIME,[Hour] INT, [volume] FLOAT,location_id INT)
	
	SET @formula_table=dbo.FNAProcessTableName('formula_table', @user_login_id,@test_process_id)
	
	EXEC('if OBJECT_ID(''' + @formula_table + ''') IS NOT NULL
			 DROP TABLE ' + @formula_table
		)
		
	SET @sqlstmt='
		CREATE TABLE '+@formula_table+'(
			rowid int ,
			counterparty_id INT,
			contract_id INT,
			curve_id INT,
			prod_date DATETIME,
			as_of_date DATETIME,
			volume FLOAT,
			onPeakVolume FLOAT,
			source_deal_detail_id INT,
			formula_id INT,
			invoice_Line_item_id INT,			
			invoice_line_item_seq_id INT,
			price FLOAT,			
			granularity INT,
			volume_uom_id INT,
			generator_id INT,
			[Hour] INT,
			commodity_id INT,
			meter_id INT,
			curve_source_value_id INT,
			[mins] INT,
			is_dst INT,
			source_deal_header_id INT,
			calc_aggregation INT,
			fin_volume FLOAT,
			offPeakVolume FLOAT,
			curve_tou INT,
			allocation_volume FLOAT,
			deal_settlement_amount FLOAT,
			deal_settlement_volume FLOAT,
			deal_settlement_price FLOAT,
			deal_type INT,
			netting_group_id INT,
			invoice_granularity INT,
			is_true_up CHAR(1),
			onpeakperiod_hour	INT,
			offpeakperiod_hour	INT,
			totalperiod_hour	INT,
			onpeakmax_value		FLOAT,
			offpeakmax_value	FLOAT			
		)	'
		
	EXEC(@sqlstmt)	
	

	CREATE TABLE #pvt_table
	(
		counterparty_id         INT,
		contract_id             INT,
		prod_date               DATETIME,
		[Hour]                  INT,
		volume                  FLOAT,
		data_missing            CHAR(1) COLLATE DATABASE_DEFAULT,
		source_deal_detail_id   INT,
		deal_term_start         DATETIME,
		deal_formula_id         INT,
		location_id             INT,
		generator_id            INT,
		commodity_id            INT,
		is_dst                  INT,
		source_deal_header_id   INT,
		curve_tou               INT,
		onpeak_offpeak_factor   INT,
		allocation_vol          INT,
		deal_settlement_amount  FLOAT,
		deal_settlement_volume  FLOAT,
		deal_settlement_price   FLOAT,
		deal_type               INT,
		meter_id                INT,
		source_system_book_id1 INT,
		source_system_book_id2 INT,
		source_system_book_id3 INT,
		source_system_book_id4 INT,
		netting_group_id INT,
		invoice_granularity INT,
		leg					INT,
		is_true_up			CHAR(1) COLLATE DATABASE_DEFAULT,
		contract_allocation FLOAT,
		period INT,
		buy_sell CHAR(1) COLLATE DATABASE_DEFAULT,
		onpeak_volume		FLOAT,
		offpeak_volume		FLOAT,
		onpeakperiod_hour	INT,
		offpeakperiod_hour	INT,
		totalperiod_hour	INT,
		onpeakmax_value		FLOAT,
		offpeakmax_value	FLOAT

	)

--##################################
-- Section 1
-- Check FOR exceptions
--##################################

CREATE TABLE #cpty(counterparty_id INT)
IF @counterparty_id IS NOT NULL
	INSERT INTO #cpty SELECT DISTINCT [item] FROM dbo.SplitCommaSeperatedValues(@counterparty_id)
ELSE 
	INSERT INTO #cpty SELECT source_counterparty_id FROM source_counterparty

--### if netting contract is used select all applicable contracts

	--IF EXISTS(SELECT 'X' FROM calc_invoice_volume_variance WHERE calc_id = @calc_id AND netting_calc_id IS NOT NULL)
	--	SET @calc_id = NULL

	--IF EXISTS(SELECT 'X' FROM calc_invoice_volume_variance WHERE calc_id = @calc_id AND netting_group_id IS NOT NULL)
	--BEGIN

	--	SELECT @contract_id_param = MAX(ngdc.source_contract_id)
	--	FROM 
	--		calc_invoice_volume_variance civv
	--		INNER JOIN netting_group ng ON ng.netting_group_id = civv.netting_group_id
	--		INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id 
	--		INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_detail_id 
	--	WHERE
	--		civv.calc_id = @calc_id

	--	SET @calc_id = NULL
	--END



	DECLARE @netting_contract VARCHAR(1000),@cpt_contract VARCHAR(1000),@contract_ids VARCHAR(1000)
	
	SELECT 
		@netting_contract = ISNULL(@netting_contract,'') + ','+  CAST(ngdc.source_contract_id AS VARCHAR)
	FROM	
		netting_group ng 
		INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id AND ng.netting_parent_group_id = -1 
		INNER JOIN #cpty cpt ON cpt.counterparty_id = ngd.source_counterparty_id
		INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_detail_id 
		CROSS APPLY(SELECT MAX(effective_date) effective_date FROM netting_group ng1 INNER JOIN netting_group_detail ngd1 ON ng1.netting_group_id = ngd1.netting_group_id AND ng1.netting_parent_group_id = -1 
			WHERE ng1.effective_date <=  @prod_date  AND  ngd1.source_counterparty_id=cpt.counterparty_id AND ngd1.netting_group_id=ng.netting_group_id) ng2

	WHERE EXISTS (SELECT source_contract_id FROM netting_group_detail_contract ngdc1 WHERE ngdc1.netting_group_detail_id = ngdc.netting_group_detail_id 
		AND (ngdc1.source_contract_id IN(SELECT item FROM dbo.SplitCommaSeperatedValues(@contract_id_param)) OR @contract_id_param IS NULL))
		AND ng.effective_date = ng2.effective_date

	IF @netting_contract IS NOT NULL AND (@contract_id_param IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@netting_contract)) OR @contract_id_param IS NULL) 	
	BEGIN

		SET @contract_ids = SUBSTRING(@netting_contract,2,LEN(@netting_contract)) 
	END
	
	IF (@contract_id_param IS NULL) 	
	BEGIN

			SELECT 
			@cpt_contract =  ISNULL(@cpt_contract,'') + ','+  CAST(cc.contract_id AS VARCHAR)
		FROM 
			counterparty_contract_address cc
			INNER JOIN #cpty cpt ON cc.counterparty_id = cpt.counterparty_id
			OUTER APPLY(SELECT MAX(effective_date) effective_date FROM netting_group ng1 INNER JOIN netting_group_detail ngd1 ON ng1.netting_group_id = ngd1.netting_group_id AND ng1.netting_parent_group_id = -1 
				WHERE ng1.effective_date <=  @prod_date  AND  ngd1.source_counterparty_id=cpt.counterparty_id) ng2
			LEFT JOIN netting_group_detail ngd ON cc.counterparty_id = ngd.source_counterparty_id 
			LEFT JOIN netting_group ng ON ng.netting_group_id = ngd.netting_group_id AND ng.netting_parent_group_id = -1 AND ng.effective_date = ng2.effective_date
			LEFT JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_detail_id AND ngdc.source_contract_id = cc.contract_id
		WHERE
			ngdc.source_contract_id IS NULL
		SET @contract_ids =  ISNULL(@contract_ids+',','') + SUBSTRING(@cpt_contract,2,LEN(@cpt_contract))
	END



	IF @contract_ids IS NOT NULL
		SET @contract_id_param = ISNULL(@contract_id_param+',','') + @contract_ids
	




--*************************************
-- Section 1.1
--Check to see, Accounting Book is closed FOR that Accounting Period - AS of Date. IF the Accounting book os already closed, 
--do not process AND give an error message
--*************************************
	IF EXISTS(SELECT * FROM close_measurement_books 
			  WHERE (as_of_date)=(@as_of_date) AND (sub_id=@sub_entity_id))
		BEGIN 
			SELECT 'Error' ErrorCode,'Calc Invoice' Module,
					'spa_calc_invoice' Area, 'Error' Status, 
					'Accounting Book already Closed FOR Accounting Period: '+(@as_of_date)+'.Please Unlock the Accounting Period to Continue.'RecommENDation
				FROM   
					source_counterparty WHERE source_counterparty_id IN(SELECT counterparty_id FROM #cpty)   
		
			RETURN 			
		END




---*************************************
--Section 3.1
--Fincd out IF the data is missing AND the volume needs to be estimated
---*************************************

	SET @user_login_id=dbo.FNADBUser()
	SET @process_id1=REPLACE(newid(),'-','_')
	SET @tempTable=dbo.FNAProcessTableName('settlement_process', @user_login_id,@process_id1)

	;WITH cte AS
	(
		--SELECT @prod_date  dt_from,DATEADD(MONTH,1,@prod_date)-1 dt_to
		--UNION all
		--SELECT  DATEADD(MONTH,1,dt_from) dt_from,DATEADD(MONTH,2,dt_from)-1 dt_to FROM cte WHERE dt_from<@prod_date_to
		SELECT DATEADD(MONTH,n-1,@prod_date) dt_from ,DATEADD(DAY, -1, DATEADD(MONTH,n,@prod_date)) dt_to FROM seq s
		WHERE s.n <= DATEDIFF(MONTH,@prod_date,@prod_date_to) + 1 

	)
	SELECT dt_from,dt_to INTO #prod_dt FROM cte
	
	--SELECT * FROM #prod_dt

--####### Create a temporary table to populate the summary information of meter, generators AND deals

	CREATE TABLE #temp_deals(
		dst_group_value_id INT,
		meter_id INT,
		counterparty_id INT,
		contract_id INT,
		generator_id INT,
		location_id INT,
		allocation_per FLOAT,
		from_vol FLOAT,
		to_vol FLOAT,
		source_deal_detail_id INT,
		uom_id INT,
		deal_term_start DATETIME,
		contract_allocation FLOAT,
		deal_formula_id INT,
		source_deal_header_id INT,
		deal_term_end DATETIME,
		commodity_id INT,
		deal_volume FLOAT,
		physical_financial_flag CHAR(1) COLLATE DATABASE_DEFAULT,
		curve_id INT,
		curve_tou INT,
		block_defintion_id INT,
		deal_settlement_amount FLOAT,
		deal_settlement_volume FLOAT,
		deal_settlement_price FLOAT,
		deal_type INT,
		set_volume_uom INT,
		alloc_volume FLOAT,
		leg INT,
		source_system_book_id1 INT,
		source_system_book_id2 INT,
		source_system_book_id3 INT,
		source_system_book_id4 INT,
		netting_group_id INT,
		settlement_date DATETIME,
		sds_deal_id INT,
		invoice_granularity INT,
		contract_time_zone INT,
		deal_time_zone INT,
		save_mtm_at_calculation_granularity CHAR(1) COLLATE DATABASE_DEFAULT,
        is_true_up  CHAR(1) COLLATE DATABASE_DEFAULT,
		document_type CHAR(1) COLLATE DATABASE_DEFAULT,
        buy_sell CHAR(1) COLLATE DATABASE_DEFAULT
	)	
	
	

	
	SET @stmt = '
		INSERT INTO #temp_deals
		SELECT DISTINCT
			tz.dst_group_value_id,
			map.meter_id,
			rg.ppa_counterparty_id,
			rg.ppa_contract_id,			
			rg.generator_id,
			NULL,
			MAX(map.allocation_per),
			MAX(map.from_vol),
			MAX(map.to_vol),
			NULL,
			MAX(cg.volume_uom),
			ISNULL(mv.from_date,'''+CAST(@prod_date AS VARCHAR)+'''),
			MAX(COALESCE(map.allocation_per,rg.contract_allocation,1)),
			NULL,
			NULL,
			ISNULL(mv.from_date,'''+CAST(@prod_date_to AS VARCHAR)+'''),
			NULL,
			NULL,
			NULL,
			18900,
			NULL,
			MAX(cg.hourly_block),
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			CASE WHEN netting_group.create_individual_invoice=0 THEN netting_group_id ELSE NULL END netting_group_id,
			MAX(COALESCE(cg_set_date.term_start,hgp.exp_date,'''+CAST(@prod_date AS VARCHAR)+''')) settlement_date,
			NULL,
			MAX(cg.volume_granularity) invoice_granularity,
			NULL,
			NULL,
			NULL,
            ''n'',
			MAX(NULLIF(cg.[type],''a'')),
            NULL 
		FROM
			rec_generator rg 
			LEFT JOIN recorder_generator_map map ON rg.generator_id=map.generator_id
			LEFT JOIN contract_group cg ON cg.contract_id=rg.ppa_contract_id	
			LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = rg.ppa_counterparty_id		
			LEFT JOIN holiday_group hgp ON hgp.hol_group_value_id = cg.settlement_calendar and
					 convert(varchar(7), hgp.hol_date, 120) = convert(varchar(7), '''+CAST(@prod_date AS VARCHAR)+''', 120)
			OUTER APPLY(SELECT MAX(effective_date) effective_date FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id AND ng.netting_parent_group_id = -1 WHERE ng.effective_date <= '''+CAST(@prod_date AS VARCHAR)+''' AND  ngd.source_counterparty_id=rg.ppa_counterparty_id) ng1
			OUTER APPLY(SELECT ngd.netting_group_id,ng.create_individual_invoice FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id AND ng.netting_parent_group_id = -1 AND ng1.effective_date = ng.effective_date
						INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_detail_id WHERE ngd.source_counterparty_id = rg.ppa_counterparty_id
						AND ngdc.source_contract_id = cg.contract_id) netting_group		 
			OUTER APPLY(SELECT 	CASE WHEN settlement_date IS NOT NULL THEN dbo.FNAInvoiceDueDate('''+CAST(@prod_date AS VARCHAR)+''',cg.settlement_date,cg.holiday_calendar_id,cg.settlement_days) ELSE NULL END term_start FROM contract_group 
					WHERE contract_id = cg.contract_id ) cg_set_date
			LEFT JOIN counterparty_contract_address cca ON cca.counterparty_id = sc.source_counterparty_id AND cca.contract_id = cg.contract_id
			LEFT JOIN mv90_data mv ON mv.meter_id=map.meter_id AND mv.from_date>='''+CAST(@prod_date AS VARCHAR)+''' AND mv.from_date<='''+CAST(@prod_date_to AS VARCHAR)+'''
			OUTER APPLY(SELECT MAX(prod_date) prod_date FROM mv90_data_hour WHERE meter_data_id=mv.meter_data_id) mvd
			cross join 
			(
				select var_value default_timezone_id from dbo.adiha_default_codes_values (nolock) WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
			) df  
			INNER JOIN dbo.time_zones tz (nolock) on tz.timezone_id = coalesce(cg.time_zone,df.default_timezone_id)

		WHERE
			map.meter_id IS NOT NULL
			AND rg.ppa_counterparty_id IN(SELECT counterparty_id FROM #cpty)'
			+ CASE WHEN @contract_id_param IS NOT NULL THEN ' AND cg.contract_id IN(' +@contract_id_param+')' ELSE '' END +'
			AND ''' + CAST(@prod_date as VARCHAR) + '''  BETWEEN CAST(CONVERT(VARCHAR(7),COALESCE(cca.contract_start_date,cg.term_start,''1990-01-01''),120)+''-01'' AS DATETIME) AND DATEADD(m,1,CAST(CONVERT(VARCHAR(7),COALESCE(cca.contract_end_date,cg.term_end, ''9999-01-01''),120)+''-01'' AS DATETIME))-1
		GROUP BY map.meter_id,rg.ppa_counterparty_id,rg.ppa_contract_id,rg.generator_id,CASE WHEN netting_group.create_individual_invoice=0 THEN netting_group_id ELSE NULL END,mv.from_date,mvd.prod_date,tz.dst_group_value_id
		'		
	EXEC(@stmt)

	
	
	CREATE TABLE #premium(source_deal_header_id VARCHAR(500) COLLATE DATABASE_DEFAULT,leg INT,term_start DATETIME,premium FLOAT,fs_type CHAR(1) COLLATE DATABASE_DEFAULT)
		SET @stmt= '
				INSERT INTO #premium
				SELECT ifb.source_deal_header_id, ifb.leg, ifb.term_start, SUM(value) premium,''f''					
				FROM 
					index_fees_breakdown ifb 			
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id=ifb.source_deal_header_id	
					INNER JOIN static_data_value s ON s.value_id = ifb.field_id AND s.category_id = '+CAST(@premium_id AS VARCHAR)+'
					' + CASE WHEN @deal_list_table IS NOT NULL THEN ' INNER JOIN #temp_source_deal_header_id t ON sdh.source_deal_header_id = t.source_deal_header_id ' ELSE '' END + '								
					WHERE
					sdh.counterparty_id IN(SELECT counterparty_id FROM #cpty)
					AND ifb.as_of_date='''+CONVERT(VARCHAR(10),@as_of_date,120)+''''+
					+ CASE WHEN @contract_id_param IS NOT NULL THEN ' AND sdh.contract_id IN(' +@contract_id_param+')' ELSE '' END 
					+ CASE WHEN @deal_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN (''' +@deal_id + ''')'  ELSE '' END 
					+ CASE WHEN @deal_ref_id IS NOT NULL THEN ' AND sdh.deal_id = ' + @deal_ref_id ELSE '' END
					--+ CASE WHEN @deal_filter_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN (SELECT source_deal_header_id FROM ' +@deal_filter_id + ')'  ELSE '' END
				 +' GROUP BY ifb.source_deal_header_id,ifb.leg,ifb.term_start'		 
		--PRINT(@stmt)	 
		--RETURN 0
		EXEC(@stmt)

	
	
    ----------------------------------------------------------------------						
	SET @stmt = '
		INSERT INTO #temp_deals
		SELECT 
			tz.dst_group_value_id,
			MAX(smlm.meter_id) meter_id,'
			+ CASE WHEN @cpt_type='m' THEN 'sdht.model_id' ELSE ' CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.broker_id WHEN sc.int_ext_flag = ''c'' THEN uddf.udf_value ELSE sdh.counterparty_id END' END+',
			cg.contract_id,
			rg.generator_id,
			sdd.location_id,
			1,
			NULL,
			NULL,
			sdd.source_deal_detail_id,
			MAX(cg.volume_uom),
			CASE WHEN sc.int_ext_flag = ''b'' THEN CAST(CONVERT(VARCHAR(7),sdh.deal_date,120)+''-01'' AS DATETIME) ELSE sdd.term_start END term_start,
			MAX(ISNULL(rg.contract_allocation,1)),
			MAX(sdd.formula_id),
			MAX(sdh.source_deal_header_id),
			MAX(CASE WHEN sc.int_ext_flag = ''b'' THEN DATEADD(m,1,CAST(CONVERT(VARCHAR(7),sdh.deal_date,120)+''-01'' AS DATETIME))-1 ELSE sdd.term_end END) term_end,
			MAX(spcd.commodity_id),
			SUM(ISNULL(sdsb.volume,sdd.total_volume)),
			MAX(sdd.physical_financial_flag),
			MAX(sdd.curve_id),
			MAX(spcd.curve_tou),
			MAX(spcd.block_define_id),
			SUM(COALESCE(sdsb.leg_set,sds.settlement_amount,0)+ISNULL(sdp.und_pnl_set,0)+ CASE WHEN '''+CONVERT(VARCHAR(10),@as_of_date,120)+'''<sds.term_end THEN ISNULL(premium,0) ELSE 0 END),
			SUM(CASE WHEN sds.volume IS NULL THEN  ISNULL(sdsb.volume,sdd.settlement_volume) ELSE ISNULL(CASE WHEN sdd.physical_financial_flag=''f'' THEN sds.fin_volume ELSE sds.volume END,0)+ISNULL(CASE WHEN sdp.buy_sell_flag = ''s'' THEN -1 ELSE 1 END * sdp.deal_volume,0) END ),
			MAX(ISNULL(sds.deal_price,sdp.price)),
			MAX(sdh.source_deal_type_id),
			MAX(ISNULL(sds.volume_uom,sdd.settlement_uom)),
			SUM(sds.allocation_volume),
			ISNULL(sdd.leg,1),
			MAX(sdh.source_system_book_id1),MAX(sdh.source_system_book_id2),MAX(sdh.source_system_book_id3),MAX(sdh.source_system_book_id4),CASE WHEN netting_group.create_individual_invoice=0 THEN netting_group_id ELSE NULL END netting_group_id,
			COALESCE(NULLIF(sdd.settlement_date,''1900-01-01''),cg_set_date.term_start,hgp.exp_date,CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.deal_date ELSE sdd.term_start END) settlement_date,MAX(sds.source_deal_header_id),MAX(cg.volume_granularity) invoice_granularity,ISNULL(MAX(cca.time_zone), MAX(cg.time_zone)) contract_time_zone,MAX(Coalesce(sdh.timezone_id, sml.time_zone, spcd.time_zone, sub.timezone_id)) deal_time_zone,
			MAX(CASE WHEN sdht.save_mtm_at_calculation_granularity IN(20151,20152) THEN ''y'' ELSE ''n'' END),
            ''n'' is_true_up,
			MAX(NULLIF(cg.[type],''a'')),
            MAX(sdd.buy_sell_flag)
		FROM
			source_deal_header sdh
			INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1=ssbm.source_system_book_id1
			  AND  sdh.source_system_book_id2=ssbm.source_system_book_id2
			  AND  sdh.source_system_book_id3=ssbm.source_system_book_id3
			  AND  sdh.source_system_book_id4=ssbm.source_system_book_id4
			INNER JOIN portfolio_hierarchy  b ON ssbm.fas_book_id=b.entity_id
			INNER JOIN portfolio_hierarchy st ON st.entity_id=b.parent_entity_id
			INNER JOIN fas_subsidiaries sub ON sub.fas_subsidiary_id=st.parent_entity_id	  
			INNER JOIN source_counterparty sc ON sc.source_counterparty_id =' + CASE WHEN @cpt_type='m' THEN ' sdht.model_id ' ELSE 'CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.broker_id ELSE sdh.counterparty_id END ' END +'
			INNER JOIN #cpty cpt ON sc.source_counterparty_id = cpt.counterparty_id
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id AND 1=CASE WHEN sc.int_ext_flag = ''b'' THEN 2 ELSE 1 END 
			LEFT JOIN  vwDealTimezone tz on tz.source_deal_header_id=sdd.source_deal_header_id
			AND ISNULL(tz.curve_id,-1)=ISNULL(sdd.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(sdd.location_id,-1)
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = ISNULL(sdh.deal_status,5604)
			LEFT JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
			LEFT JOIN user_defined_deal_fields_template uddft ON uddft.template_id  = sdht.template_id
				 AND uddft.field_id = -5586 AND sc.int_ext_flag = ''c''
			LEFT JOIN user_defined_deal_fields	uddf ON uddf.source_deal_header_id  = sdh.source_deal_header_id AND uddf.udf_template_id = uddft.udf_template_id
			LEFT JOIN user_defined_deal_fields_template uddft1 ON uddft1.template_id  = sdht.template_id
				 AND uddft1.field_id = -5604 AND sc.int_ext_flag = ''b''
			LEFT JOIN user_defined_deal_fields	uddf1 ON uddf1.source_deal_header_id  = sdh.source_deal_header_id AND uddf1.udf_template_id = uddft1.udf_template_id				 
			OUTER APPLY(SELECT MAX(smlm.meter_id) meter_id FROM source_minor_location_meter smlm WHERE source_minor_location_id=sdd.location_id) smlm
			OUTER APPLY(SELECT MAX(contract_id) contract_id, MAX(time_zone) time_zone FROM counterparty_contract_address WHERE counterparty_id = sc.source_counterparty_id AND CASE WHEN sc.int_ext_flag = ''b'' THEN CAST(CONVERT(VARCHAR(7),sdh.deal_date,120)+''-01'' AS DATETIME) ELSE sdd.term_start END BETWEEN COALESCE(contract_start_date,''1900-01-01'') AND COALESCE(contract_end_date,''9999-01-01'')) cca
			LEFT JOIN rec_generator rg ON rg.ppa_counterparty_id='+ CASE WHEN @cpt_type='m' THEN 'sdht.model_id' ELSE ' CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.broker_id  WHEN sc.int_ext_flag = ''c'' THEN uddf.udf_value ELSE  sdh.counterparty_id END' END
			
		SET @stmt1 = 	' INNER JOIN contract_group cg ON cg.contract_id='+ CASE WHEN @cpt_type='m' THEN 'rg.ppa_contract_id ' ELSE 'CASE WHEN sc.int_ext_flag = ''b'' THEN ISNULL(uddf1.udf_value,cca.contract_id) ELSE ISNULL(rg.ppa_contract_id,sdh.contract_id) END' END +'
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id
			LEFT JOIN source_deal_settlement sds ON sds.source_deal_header_id=sdh.source_deal_header_id
				AND sds.leg=sdd.leg
				AND sds.term_start=sdd.term_start
				AND (sds.set_type = ''f'' AND sds.as_of_date = '''+CONVERT(VARCHAR(10),@as_of_date,120)+''' OR ( sds.set_type = ''s'' AND '''+CONVERT(VARCHAR(10),@as_of_date,120)+'''>=sds.term_end))
			 LEFT JOIN source_deal_pnl_detail sdp ON sdd.source_deal_header_id=sdp.source_deal_header_id
				AND sdp.term_start=sdd.term_start AND sdp.leg=sdd.leg AND sdp.pnl_as_of_date='''+CONVERT(VARCHAR(10),@as_of_date,120)+'''
				AND convert(varchar(8),'''+CONVERT(VARCHAR(10),@as_of_date,120)+''', 120)+''01'' = convert(varchar(8),'''+CONVERt(VARCHAR(10),@as_of_date,120)+''', 120)+''01''
			 LEFT JOIN #premium ifb  ON ifb.source_deal_header_id =  sdh.source_deal_header_id 
				AND ifb.term_start = sdd.term_start	AND ifb.leg = sdd.leg
			 LEFT JOIN holiday_group hgp ON hgp.hol_group_value_id = cg.settlement_calendar and
					 convert(varchar(7), hgp.hol_date, 120) = convert(varchar(7), sdd.term_start, 120)
					 ' + CASE WHEN @deal_list_table IS NOT NULL THEN ' INNER JOIN #temp_source_deal_header_id t ON sdh.source_deal_header_id = t.source_deal_header_id ' ELSE '' END + '
			OUTER APPLY(SELECT MAX(effective_date) effective_date FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id AND ng.netting_parent_group_id = -1 WHERE ng.effective_date <= CASE WHEN sc.int_ext_flag = ''b'' THEN CAST(CONVERT(VARCHAR(7),sdh.deal_date,120)+''-01'' AS DATETIME) ELSE sdd.term_start END AND  ngd.source_counterparty_id='+ CASE WHEN @cpt_type='m' THEN 'sdht.model_id' ELSE ' CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.broker_id  WHEN sc.int_ext_flag = ''c'' THEN uddf.udf_value ELSE  sdh.counterparty_id END' END+') ng1
			OUTER APPLY(SELECT ngd.netting_group_id,ng.create_individual_invoice FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id AND ng.netting_parent_group_id = -1 AND ng.effective_date = ng1.effective_date
						INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id = ngd.netting_group_detail_id WHERE ngd.source_counterparty_id='+ CASE WHEN @cpt_type='m' THEN 'sdht.model_id' ELSE ' CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.broker_id  WHEN sc.int_ext_flag = ''c'' THEN uddf.udf_value ELSE  sdh.counterparty_id END' END+'
						AND ngdc.source_contract_id = cg.contract_id) netting_group		 
			OUTER APPLY(SELECT 	CASE WHEN settlement_date IS NOT NULL THEN dbo.FNAInvoiceDueDate(CASE WHEN cg.settlement_date = ''20023''  OR cg.settlement_date = ''20024'' THEN '''+CONVERt(VARCHAR(10),@as_of_date,120)+''' ELSE CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.deal_date ELSE sdd.term_start END END ,cg.settlement_date,cg.holiday_calendar_id,cg.settlement_days) ELSE NULL END term_start FROM contract_group 
					WHERE contract_id = cg.contract_id ) cg_set_date
			LEFT JOIN counterparty_contract_address cca1 ON cca1.counterparty_id = sc.source_counterparty_id
				AND cca1.contract_id = cg.contract_id 
			LEFT JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id	
			OUTER APPLY(SELECT MAX(contract_id) contract_id  FROM #temp_deals WHERE counterparty_id =' + CASE WHEN @cpt_type='m' THEN 'sdht.model_id' ELSE ' CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.broker_id WHEN sc.int_ext_flag = ''c'' THEN uddf.udf_value ELSE sdh.counterparty_id END' END+'
					AND contract_id = cg.contract_id	AND deal_term_start= CASE WHEN sc.int_ext_flag = ''b'' THEN CAST(CONVERT(VARCHAR(7),sdh.deal_date,120)+''-01'' AS DATETIME) ELSE sdd.term_start END ) td_temp			
			OUTER APPLY(SELECT SUM(leg_set) leg_set,SUM(volume) volume FROM source_deal_settlement_breakdown WHERE source_deal_header_id = sdh.source_deal_header_id AND as_of_date = sds.as_of_date AND CONVERT(VARCHAR(7),term_date,120) = CONVERT(VARCHAR(7),term_start,120) ) sdsb				
			WHERE 1=1 '
			+ ' AND td_temp.contract_id IS NULL'
			+ CASE WHEN @cpt_type='m' THEN '' ELSE ' AND sc.int_ext_flag='''+@cpt_type+'''' END
			+ CASE WHEN @date_type = 's' THEN 
				' AND COALESCE(sdd.settlement_date,cg_set_date.term_start,hgp.exp_date,sdd.term_start) BETWEEN '''+CAST(@prod_date AS VARCHAR)+''' AND '''+CAST(@prod_date_to AS VARCHAR)+''''				
			  ELSE
				 'AND ((sdh.deal_date BETWEEN '''+CAST(@prod_date AS VARCHAR)+''' AND '''+CAST(@prod_date_to AS VARCHAR)+''' AND sc.int_ext_flag = ''b'') OR (sdd.term_start BETWEEN '''+CAST(@prod_date AS VARCHAR)+''' AND '''+CAST(@prod_date_to AS VARCHAR)+''' AND sc.int_ext_flag <> ''b''))' 
				  
			END				  	
			+ CASE WHEN @contract_id_param IS NOT NULL THEN CASE WHEN @cpt_type = 'm' THEN ' AND rg.ppa_contract_id IN(' +@contract_id_param+')' ELSE ' AND (cg.contract_id IN(' +@contract_id_param +') OR rg.ppa_contract_id IN(' +@contract_id_param+'))' END ELSE '' END 
			+ CASE WHEN @deal_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN ('+ @deal_id + ')' ELSE '' END 
			+ CASE WHEN @deal_ref_id IS NOT NULL THEN ' AND sdh.deal_id = ' + @deal_ref_id ELSE '' END
			+ ' AND ''' + CAST(@prod_date as VARCHAR) + '''  BETWEEN CAST(CONVERT(VARCHAR(7),COALESCE(cca1.contract_start_date,cg.term_start,''1990-01-01''),120)+''-01'' AS DATETIME) AND DATEADD(m,1,CAST(CONVERT(VARCHAR(7),COALESCE(cca1.contract_end_date,cg.term_end, ''9999-01-01''),120)+''-01'' AS DATETIME))-1'
			--+ ' AND ((ISNULL(cg.contract_type_def_id,38400) = 38400 AND ISNULL(sds.source_deal_header_id,sdp.source_deal_header_id) IS NOT NULL) OR ISNULL(cg.contract_type_def_id,38400) <> 38400 )'
		+' GROUP BY '+
			+ CASE WHEN @cpt_type='m' THEN 'sdht.model_id' ELSE ' CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.broker_id WHEN sc.int_ext_flag = ''c'' THEN uddf.udf_value ELSE sdh.counterparty_id END' END+',
			cg.contract_id,rg.generator_id,sdd.location_id,sdd.source_deal_detail_id,tz.dst_group_value_id,
			CASE WHEN sc.int_ext_flag = ''b'' THEN CAST(CONVERT(VARCHAR(7),sdh.deal_date,120)+''-01'' AS DATETIME) ELSE sdd.term_start END,sdh.source_deal_header_id,ISNULL(sdd.leg,1),CASE WHEN netting_group.create_individual_invoice=0 THEN netting_group_id ELSE NULL END,COALESCE(NULLIF(sdd.settlement_date,''1900-01-01''),cg_set_date.term_start,hgp.exp_date,CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.deal_date ELSE sdd.term_start END)'
	EXEC spa_print  @stmt
	EXEC spa_print  @stmt1
	EXEC(@stmt+@stmt1)



	SET @stmt = '
		INSERT INTO #temp_deals
		SELECT 
			tz.dst_group_value_id,
			MAX(smlm.meter_id) meter_id,'
			+ CASE WHEN @cpt_type='m' THEN 'sdht.model_id' ELSE ' CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.broker_id WHEN sc.int_ext_flag = ''c'' THEN uddf.udf_value ELSE sdh.counterparty_id END' END+',
			cg.contract_id,
			rg.generator_id,
			sdd.location_id,
			1,
			NULL,
			NULL,
			sdd.source_deal_detail_id,
			MAX(cg.volume_uom),
			sdsb.term_date term_start,
			MAX(ISNULL(rg.contract_allocation,1)),
			MAX(sdd.formula_id),
			MAX(sdh.source_deal_header_id),
			sdsb.term_date term_end,
			MAX(spcd.commodity_id),
			SUM(ISNULL(sdsb.volume,sdd.total_volume)),
			MAX(sdd.physical_financial_flag),
			MAX(sdd.curve_id),
			MAX(spcd.curve_tou),
			MAX(spcd.block_define_id),
			SUM(sdsb.leg_set),
			SUM(sdsb.volume),
			MAX(sdsb.price),
			MAX(sdh.source_deal_type_id),
			MAX(sds.volume_uom),
			SUM(sds.allocation_volume),
			ISNULL(sdd.leg,1),
			MAX(sdh.source_system_book_id1),
			MAX(sdh.source_system_book_id2),
			MAX(sdh.source_system_book_id3),
			MAX(sdh.source_system_book_id4),
			netting_group_id,
			COALESCE(NULLIF(sdd.settlement_date,''1900-01-01''),cg_set_date.term_start,hgp.exp_date,CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.deal_date ELSE sdd.term_start END) settlement_date,
			MAX(sds.source_deal_header_id),
			MAX(cg.volume_granularity) invoice_granularity,
			ISNULL(MAX(cca.time_zone), MAX(cg.time_zone)) contract_time_zone,
			MAX(Coalesce(sdh.timezone_id, sml.time_zone, spcd.time_zone, sub.timezone_id)) deal_time_zone,
			MAX(CASE WHEN sdht.save_mtm_at_calculation_granularity IN(20151,20152) THEN ''y'' ELSE ''n'' END),
			  ''n'' is_true_up,
			MAX(NULLIF(cg.[type],''a'')),
            MAX(sdd.buy_sell_flag)
		FROM
			source_deal_header sdh
			INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1=ssbm.source_system_book_id1
			  AND  sdh.source_system_book_id2=ssbm.source_system_book_id2
			  AND  sdh.source_system_book_id3=ssbm.source_system_book_id3
			  AND  sdh.source_system_book_id4=ssbm.source_system_book_id4 '

	SET @sqlstmt1 ='		INNER JOIN portfolio_hierarchy  b ON ssbm.fas_book_id=b.entity_id
			INNER JOIN portfolio_hierarchy st ON st.entity_id=b.parent_entity_id
			INNER JOIN fas_subsidiaries sub ON sub.fas_subsidiary_id=st.parent_entity_id	  
			INNER JOIN source_counterparty sc ON sc.source_counterparty_id =' + CASE WHEN @cpt_type='m' THEN ' sdht.model_id ' ELSE 'CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.broker_id ELSE sdh.counterparty_id END ' END +'
			INNER JOIN #cpty cpt ON sc.source_counterparty_id = cpt.counterparty_id
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id AND 1=CASE WHEN sc.int_ext_flag = ''b'' THEN 2 ELSE 1 END 
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = ISNULL(sdh.deal_status,5604)
			LEFT JOIN  vwDealTimezone tz on tz.source_deal_header_id=sdd.source_deal_header_id
			LEFT JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
			LEFT JOIN user_defined_deal_fields_template uddft ON uddft.template_id  = sdht.template_id
				 AND uddft.field_id = -5586 AND sc.int_ext_flag = ''c''
			LEFT JOIN user_defined_deal_fields	uddf ON uddf.source_deal_header_id  = sdh.source_deal_header_id AND uddf.udf_template_id = uddft.udf_template_id
			LEFT JOIN user_defined_deal_fields_template uddft1 ON uddft1.template_id  = sdht.template_id
				 AND uddft1.field_id = -5604 AND sc.int_ext_flag = ''b''
			LEFT JOIN user_defined_deal_fields	uddf1 ON uddf1.source_deal_header_id  = sdh.source_deal_header_id AND uddf1.udf_template_id = uddft1.udf_template_id				 
			OUTER APPLY(SELECT MAX(smlm.meter_id) meter_id FROM source_minor_location_meter smlm WHERE source_minor_location_id=sdd.location_id) smlm
			OUTER APPLY(SELECT MAX(contract_id) contract_id, MAX(time_zone) time_zone FROM counterparty_contract_address WHERE counterparty_id = sc.source_counterparty_id AND CASE WHEN sc.int_ext_flag = ''b'' THEN CAST(CONVERT(VARCHAR(7),sdh.deal_date,120)+''-01'' AS DATETIME) ELSE sdd.term_start END BETWEEN COALESCE(contract_start_date,''1900-01-01'') AND COALESCE(contract_end_date,''9999-01-01'')) cca
			LEFT JOIN rec_generator rg ON rg.ppa_counterparty_id='+ CASE WHEN @cpt_type='m' THEN 'sdht.model_id' ELSE ' CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.broker_id  WHEN sc.int_ext_flag = ''c'' THEN uddf.udf_value ELSE  sdh.counterparty_id END' END+
			' INNER JOIN contract_group cg ON cg.contract_id='+ CASE WHEN @cpt_type='m' THEN 'rg.ppa_contract_id ' ELSE 'CASE WHEN sc.int_ext_flag = ''b'' THEN ISNULL(uddf1.udf_value,cca.contract_id) ELSE ISNULL(rg.ppa_contract_id,sdh.contract_id) END' END +'
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id
			INNER JOIN source_deal_settlement sds ON sds.source_deal_header_id=sdh.source_deal_header_id
				AND sds.leg=sdd.leg
				AND sds.term_start = sdd.term_start
				AND (sds.set_type = ''f'' AND sds.as_of_date = '''+CONVERT(VARCHAR(10),@as_of_date,120)+''' OR ( sds.set_type = ''s'' AND '''+CONVERT(VARCHAR(10),@as_of_date,120)+'''>=sds.term_end))
			 LEFT JOIN holiday_group hgp ON hgp.hol_group_value_id = cg.settlement_calendar and
					 convert(varchar(7), hgp.hol_date, 120) = convert(varchar(7), sdd.term_start, 120)
					 ' + CASE WHEN @deal_list_table IS NOT NULL THEN ' INNER JOIN #temp_source_deal_header_id t ON sdh.source_deal_header_id = t.source_deal_header_id ' ELSE '' END + '
			OUTER APPLY(SELECT ngd.netting_group_id FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
						INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_id WHERE ngd.source_counterparty_id='+ CASE WHEN @cpt_type='m' THEN 'sdht.model_id' ELSE ' CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.broker_id  WHEN sc.int_ext_flag = ''c'' THEN uddf.udf_value ELSE  sdh.counterparty_id END' END+'
						AND ngdc.source_contract_id = cg.contract_id) netting_group		 
			LEFT JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id	
			CROSS APPLY(SELECT SUM(leg_set) leg_set,SUM(volume) volume, MAX(Price) price,MAX(term_date) term_date FROM source_deal_settlement_breakdown WHERE
				source_deal_header_id = sds.source_deal_header_id
				AND as_of_date = sds.as_of_date
				AND ((term_start BETWEEN sds.term_start AND sds.term_end AND CONVERT(VARCHAR(7),term_date,120) <> CONVERT(VARCHAR(7),term_start,120)) OR (term_start>sds.term_end AND CONVERT(VARCHAR(7),term_date,120) = CONVERT(VARCHAR(7),term_start,120))) ) sdsb
			OUTER APPLY(SELECT 	CASE WHEN settlement_date IS NOT NULL THEN dbo.FNAInvoiceDueDate(CASE WHEN cg.settlement_date = ''20023''  OR cg.settlement_date = ''20024'' THEN '''+CONVERt(VARCHAR(10),@as_of_date,120)+''' ELSE CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.deal_date ELSE sdsb.term_date END END ,cg.settlement_date,cg.holiday_calendar_id,cg.settlement_days) ELSE NULL END term_start FROM contract_group 
					WHERE contract_id = cg.contract_id ) cg_set_date
			OUTER APPLY(SELECT MAX(source_deal_header_id) source_deal_header_id FROM #temp_deals where source_deal_header_id = sdh.source_deal_header_id) t_deal				
		WHERE 1=1 AND t_deal.source_deal_header_id IS NULL'
			+ CASE WHEN @cpt_type='m' THEN '' ELSE ' AND sc.int_ext_flag='''+@cpt_type+'''' END +
			' AND sdsb.term_date BETWEEN '''+CAST(@prod_date AS VARCHAR)+''' AND '''+CAST(@prod_date_to AS VARCHAR)+''''				
			  	  	
			+ CASE WHEN @contract_id_param IS NOT NULL THEN CASE WHEN @cpt_type = 'm' THEN ' AND rg.ppa_contract_id IN(' +@contract_id_param+')' ELSE ' AND (cg.contract_id IN(' +@contract_id_param +') OR rg.ppa_contract_id IN(' +@contract_id_param+'))' END ELSE '' END 
			+ CASE WHEN @deal_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN ('+ @deal_id + ')' ELSE '' END 
			+ CASE WHEN @deal_ref_id IS NOT NULL THEN ' AND sdh.deal_id = ' + @deal_ref_id ELSE '' END
			--+ ' AND ((ISNULL(cg.standard_contract,''n'') = ''y'' AND sds.source_deal_header_id IS NOT NULL) OR ISNULL(cg.standard_contract,''n'') = ''n'' )'
		+' GROUP BY '+
			+ CASE WHEN @cpt_type='m' THEN 'sdht.model_id' ELSE ' CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.broker_id WHEN sc.int_ext_flag = ''c'' THEN uddf.udf_value ELSE sdh.counterparty_id END' END+',
			cg.contract_id,rg.generator_id,sdd.location_id,sdd.source_deal_detail_id,
			sdsb.term_date,tz.dst_group_value_id,
			sdh.source_deal_header_id,ISNULL(sdd.leg,1),netting_group_id,COALESCE(NULLIF(sdd.settlement_date,''1900-01-01''),cg_set_date.term_start,hgp.exp_date,CASE WHEN sc.int_ext_flag = ''b'' THEN sdh.deal_date ELSE sdd.term_start END)'
	--print(@stmt)
	EXEC(@stmt+@sqlstmt1)




	CREATE  INDEX [IX_temp_deals1] ON  [#temp_deals]([source_deal_detail_id],[counterparty_id],[meter_id],source_deal_header_id)                    

	--print '#temp_deals table populated'+': '+cast(datediff(ss,@calc_time,getdate()) as varchar) +'*************************************'
	SET @calc_time=GETDATE()


		SET @stmt = '
		INSERT INTO #temp_deals
		SELECT DISTINCT
			tz.dst_group_value_id,
			NULL,
			cca.counterparty_id,
			cca.contract_id,			
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			MAX(cg.volume_uom),
			pd.dt_from,
			1,
			NULL,
			NULL,
			pd.dt_to,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			CASE WHEN netting_group.create_individual_invoice=0 THEN netting_group_id ELSE NULL END netting_group_id,
			MAX(COALESCE(cg_set_date.term_start,hgp.exp_date,'''+CAST(@prod_date AS VARCHAR)+''')) settlement_date,
			NULL,
			MAX(cg.volume_granularity) invoice_granularity,
			NULL,
			NULL,
			''n'',
            ''n'',
			MAX(NULLIF(cg.[type],''a'')),
            NULL 
		FROM
			counterparty_contract_address cca 
			INNER JOIN contract_group cg ON cg.contract_id=cca.contract_id	
			LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = cca.counterparty_id		
			LEFT JOIN holiday_group hgp ON hgp.hol_group_value_id = cg.settlement_calendar and
					 convert(varchar(7), hgp.hol_date, 120) = convert(varchar(7), '''+CAST(@prod_date AS VARCHAR)+''', 120)
			OUTER APPLY(SELECT MAX(effective_date) effective_date FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id AND ng.netting_parent_group_id = -1 WHERE ng.effective_date <= '''+CAST(@prod_date AS VARCHAR)+''' AND  ngd.source_counterparty_id=cca.counterparty_id) ng1
			OUTER APPLY(SELECT ngd.netting_group_id, ng.create_individual_invoice FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id  AND ng.netting_parent_group_id = -1 AND ng1.effective_date = ng.effective_date
						INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_detail_id WHERE ngd.source_counterparty_id = cca.counterparty_id
						AND ngdc.source_contract_id = cg.contract_id) netting_group		 
			OUTER APPLY(SELECT 	CASE WHEN settlement_date IS NOT NULL THEN dbo.FNAInvoiceDueDate('''+CAST(@prod_date AS VARCHAR)+''',cg.settlement_date,cg.holiday_calendar_id,cg.settlement_days) ELSE NULL END term_start FROM contract_group 
					WHERE contract_id = cg.contract_id ) cg_set_date
			OUTER APPLY(SELECT counterparty_id,contract_id FROM #temp_deals WHERE counterparty_id = cca.counterparty_id AND contract_id = cca.contract_id) td
			OUTER APPLY (select dt_from,dt_to from #prod_dt) pd
			cross join 
			(	
				select var_value default_timezone_id from dbo.adiha_default_codes_values (nolock) WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
			) df  
			inner join dbo.time_zones tz (nolock) on tz.timezone_id = coalesce(cg.time_zone,df.default_timezone_id)
		WHERE
			+ ''' + CAST(@prod_date as VARCHAR) + ''' BETWEEN CAST(CONVERT(VARCHAR(7),COALESCE(cca.contract_start_date,cg.term_start,''1990-01-01''),120)+''-01'' AS DATETIME) AND DATEADD(m,1,CAST(CONVERT(VARCHAR(7),COALESCE(cca.contract_end_date,cg.term_end, ''9999-01-01''),120)+''-01'' AS DATETIME))-1
			AND cca.counterparty_id IN(SELECT counterparty_id FROM #cpty)
			AND td.counterparty_id IS NULL'
			+ CASE WHEN @contract_id_param IS NOT NULL THEN ' AND cca.contract_id IN(' +@contract_id_param+')' ELSE '' END +'
		GROUP BY pd.dt_from,pd.dt_to, cca.counterparty_id,tz.dst_group_value_id,cca.contract_id,CASE WHEN netting_group.create_individual_invoice=0 THEN netting_group_id ELSE NULL END
		'		
	EXEC spa_print @stmt
	EXEC(@stmt)

	-- Do not change this process id this will be used for entire excel based settlement calc
	DECLARE @excel_calc_process_id VARCHAR(500) = dbo.FNAGetNewID()
	-- Collect temp deals , this deals will be used for calculation through excel add-in package, if any contract charge type has data component with DEAL definition this process table will be used
	IF EXISTS(
		       SELECT TOP 1 dcd.data_component_detail_id
		       FROM   contract_group AS cg
		              INNER JOIN contract_group_detail AS cgd
		                   ON  cg.contract_id = cgd.contract_id
		              INNER JOIN dbo.FNASplit(@contract_id_param, ',') AS f
		                   ON  cg.contract_id = f.item
		              INNER JOIN data_component_detail AS dcd
		                   ON  cgd.ID = dcd.contract_group_detail_id
	)
	BEGIN
		EXEC ('SELECT * INTO adiha_process.dbo.excel_add_in_temp_deal_' + @excel_calc_process_id + ' FROM #temp_deals')
	END



-------------#############################	

--*************************************
-- Section 1.2
--Check to see, If the calculation has already been finalized for that production month. IF it's been finalized then 
--do not process AND give an error message
--*************************************

	IF @test_run = 'n'
	BEGIN
			SET @stmt='
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
					'''+@test_process_id+''',
					''Warning'',
					''Process Settlement'',
					sc.source_counterparty_id,
					dbo.FNAGetcontractMonth('''+CAST(@prod_date AS VARCHAR)+'''),
					CASE WHEN ISNULL(civv.invoice_lock,''n'')=''y'' THEN ''Settlement Invoice locked for counterparty:'' ELSE ''Settlement already finalized for counterparty:'' END +sc.counterparty_name+'' and contract:'' + cg.contract_name + '' for the '+CASE WHEN @date_type='s' THEN 'settlement' ELSE 'production' END+' month:'+dbo.FNAGetcontractMonth(@prod_date)+'.'',
					CASE WHEN ISNULL(civv.invoice_lock,''n'')=''y'' THEN ''Please unlock the invoice'' ELSE ''Please un-finalize the settlement'' END
				FROM   
					#temp_deals td
					INNER JOIN source_counterparty sc ON sc.source_counterparty_id = td.counterparty_id
					INNER JOIN contract_group cg ON cg.contract_id = td.contract_id
					INNER JOIN '+@table_calc_invoice_volume_variance+' civv ON sc.source_counterparty_id=civv.counterparty_id 
							AND ((td.contract_id=civv.contract_id AND civv.netting_group_id IS NULL) OR (civv.netting_group_id = td.netting_group_id))
						AND '+CASE WHEN @date_type='s' THEN 'dbo.FNAGetcontractMonth(civv.settlement_date)' ELSE 'civv.prod_date' END +'=dbo.FNAGetcontractMonth('''+CAST(@prod_date AS VARCHAR)+''')
						'+CASE WHEN @calc_id IS NOT NULL THEN ' AND civv.calc_id IN ('+@calc_id+ ')' ELSE '' END +'
					CROSS APPLY(SELECT MAX(as_of_date) as_of_date FROM '+@table_calc_invoice_volume_variance+'  WHERE
							counterparty_id = civv.counterparty_id AND contract_id = civv.contract_id
							AND prod_date = civv.prod_date AND invoice_type = civv.invoice_type 
							) civv1
				WHERE 1=1 AND civv.as_of_date = civv1.as_of_date AND  (ISNULL(civv.finalized,'''') = ''y'' OR (ISNULL(civv.invoice_lock,''n'')=''y'' AND civv.as_of_date='''+CAST(@as_of_date AS VARCHAR)+'''))'
				
				--print(@stmt)
				EXEC(@stmt)

		SET @stmt=' DELETE td FROM 
						#temp_deals td
						INNER JOIN source_counterparty sc ON sc.source_counterparty_id = td.counterparty_id
						INNER JOIN contract_group cg ON cg.contract_id = td.contract_id
						INNER JOIN '+@table_calc_invoice_volume_variance+' civv ON sc.source_counterparty_id=civv.counterparty_id 
							AND ((td.contract_id=civv.contract_id AND civv.netting_group_id IS NULL) OR (civv.netting_group_id = td.netting_group_id))
							AND '+CASE WHEN @date_type='s' THEN 'dbo.FNAGetcontractMonth(civv.settlement_date)' ELSE 'civv.prod_date' END +'=dbo.FNAGetcontractMonth('''+CAST(@prod_date AS VARCHAR)+''')
							'+CASE WHEN @calc_id IS NOT NULL THEN ' AND civv.calc_id IN ('+@calc_id+ ')' ELSE '' END +'
						CROSS APPLY(SELECT MAX(as_of_date) as_of_date FROM '+@table_calc_invoice_volume_variance+'  WHERE
							counterparty_id = civv.counterparty_id AND contract_id = civv.contract_id
							AND prod_date = civv.prod_date AND invoice_type = civv.invoice_type 
							) civv1
					WHERE 1=1 AND civv.as_of_date = civv1.as_of_date AND td.is_true_up =''n'' AND (ISNULL(civv.finalized,'''') = ''y'' OR (ISNULL(civv.invoice_lock,''n'') = ''y'' AND civv.as_of_date='''+CAST(@as_of_date AS VARCHAR)+'''))'
		--PRINT @stmt
		EXEC(@stmt)			
			
	END	

			
--############ END of Finalized Production Month Check

	--;WITH cte AS
	--(
	--	SELECT @prod_date  dt_from,DATEADD(MONTH,1,@prod_date)-1 dt_to
	--	--UNION all
	--	--SELECT  DATEADD(MONTH,1,dt_from) dt_from,DATEADD(MONTH,2,dt_from)-1 dt_to FROM cte WHERE dt_from<@prod_date_to
	--)
	--SELECT dt_from,dt_to INTO #prod_dt FROM cte


	INSERT INTO #ContractBillingDate
		SELECT DISTINCT cg.contract_id,
			   udf_from_date,
			   CAST(CONVERT(VARCHAR(10),udf_to_date,120)+' '+'23:59:00:000' AS DATETIME),
			   CONVERT(VARCHAR(10),udf_from_date,120)+' '+ISNULL(b.billing_from_hour,'00')+':00:00:000',
			   CONVERT(VARCHAR(10),udf_to_date,120)+' '+ISNULL(b.billing_to_hour,'00')+':00:00:000'
		FROM
			contract_group cg
			INNER JOIN #temp_deals td ON cg.contract_id=td.contract_id
			cross join #prod_dt d 
			CROSS APPLY  dbo.FNAContractBillingDate(cg.contract_id,d.dt_from) b

	UPDATE #ContractBillingDate
		SET udf_from_date=CAST(CONVERT(VARCHAR(10),udf_from_date,120)+' '+'23:59:00:000' AS DATETIME)
	WHERE
		udf_from_date>(select MIN(udf_from_date) FROM #ContractBillingDate)
		AND udf_from_date<>udf_from_date_hour
		
	
	CREATE TABLE #Proxy_term(contract_id INT,commodity_id INT,term_start DATETIME,[hour] INT,proxy_term_start DATETIME,proxy_hour INT)
	INSERT INTO #Proxy_term
	SELECT 
		td.contract_id,
		pd.commodity_id,
		pd.term_start,
		pd.[hour],
		pd.proxy_term_start,
		pd.proxy_hour
	FROM
		(SELECT DISTINCT contract_id FROM #temp_deals)	td
		CROSS APPLY [dbo].[FNAGetProxy_term](td.contract_id,982,@prod_date ,DATEADD(MONTH,1,ISNULL(@prod_date_to,@prod_date))) pd 

----**********************************
--Section 5.11
--Insert the formulaS FOR each charge type to calculate
----**********************************
-- FInd Onpeak,offpeak based on curve
	DECLARE @baseload_block_definition INT
	SELECT @baseload_block_definition= value_id FROM static_data_value WHERE type_id=10018 AND code LIKE '%Base Load%'
	

	SET @sqlstmt = '
	INSERT INTO 
		#temp_formula
	SELECT	
			a.counterparty_id,
			a.contract_id,
			a.invoice_Line_item_id,
			MAX(a.invoice_template_id) invoice_template_id,
			MAX(a.price),
			a.formula_id,
			MAX(a.sequence_number),
			a.[ID],
			--MAX(a.volume_granularity) volume_granularity,
			a.volume_granularity volume_granularity,
			a.sequence_order,
			MAX(a.deal_type),
			MAX(civv.calc_id)calc_id,
			MAX(calc_aggregation),
			MAX(timeofuse),
			MAX(a.uom_id),
			MAX(a.formula),
			MAX(a.contract_calc_type),
			MAX(a.group1),
			MAX(a.group2),
			MAX(a.group3),
			MAX(a.group4),
			MAX(a.neting_rule) neting_rule,
			MAX(a.leg),
			a.is_true_up,
			MAX(a.document_type),
			MAX(a.buy_sell),
			MAX(a.location_id),
			MAX(a.dst_group_value_id) dst_group_value_id
	 FROM 
			(
			SELECT DISTINCT
				td.counterparty_id counterparty_id,
				td.contract_id,
				ISNULL(cgd.invoice_Line_item_id,cctd.invoice_Line_item_id) AS invoice_Line_item_id,
				cgd.invoice_template_id invoice_template_id,
				ISNULL(cgd.price,cctd.price) AS price ,
				COALESCE(cctd1.formula_id,cgd.formula_id,cctd.formula_id) formula_id,
				replace(ISNULL(fe1.formula,fe.formula),'' '','''') formula,
				ISNULL(fn.sequence_order,0) sequence_number,
				ISNULL(cgd.[ID],cctd.[ID]) [ID],
				COALESCE(fn.granularity,cgd.volume_granularity,cctd.volume_granularity,cg.volume_granularity,'+ISNULL(CAST(@granularity AS VARCHAR),'NULL')+') volume_granularity,
				cgd.sequence_order,
				COALESCE(cctd1.deal_type,cctd.deal_type, cgd.deal_type)  deal_type,
				COALESCE(cctd1.aggregation_level,cctd.aggregation_level,cgd.calc_aggregation,19001) calc_aggregation,
				COALESCE(cctd1.time_of_use,cctd.time_of_use,cgd.timeofuse)timeofuse,
				COALESCE(fn.uom_id,cg.volume_uom) uom_id,
				COALESCE(cctd1.contract_component_type, cctd.contract_component_type, radio_automatic_manual,''f'') contract_calc_type,
				COALESCE(cctd1.group1,cctd.group1, cgd.group1) group1,
				COALESCE(cctd1.group2,cctd.group2, cgd.group2) group2,
				COALESCE(cctd1.group3,cctd.group3, cgd.group3) group3,
				COALESCE(cctd1.group4,cctd.group4, cgd.group4) group4,
				--CASE WHEN COALESCE(cctd1.aggregation_level,cctd.aggregation_level,cgd.calc_aggregation,19001) = 19001 THEN ''y'' ELSE COALESCE(cca.apply_netting_rule,cg.neting_rule,''n'') END neting_rule,
				COALESCE(cca.apply_netting_rule,cg.neting_rule,''n'')  neting_rule,
				COALESCE(cctd1.leg, cgd.leg) leg,
				COALESCE(cgd.is_true_up,cctd.is_true_up) is_true_up,
				NULLIF(cg.[type],''a'') document_type,
				COALESCE(cctd1.buy_sell, cgd.buy_sell_flag) buy_sell,
				COALESCE(cctd1.location, cgd.location_id) location_id,
				td.dst_group_value_id
			FROM
				#temp_deals td
				LEFT JOIN contract_group cg ON cg.contract_id=td.contract_id
				LEFT JOIN contract_group_detail cgd ON  cgd.contract_id=cg.contract_id
					AND '''+CAST(@as_of_date AS VARCHAR)+''' >= ISNULL(cgd.effective_date,''1900-01-01'')
				LEFT JOIN contract_charge_type cct ON  cct.contract_charge_type_id=cg.contract_charge_type_id
				LEFT JOIN contract_charge_type_detail cctd ON  cctd.contract_charge_type_id=cct.contract_charge_type_id
				LEFT JOIN contract_charge_type_detail cctd1 ON cctd1.[ID] = cgd.contract_component_template
				LEFT JOIN formula_editor fe ON  COALESCE(cctd1.formula_id,cgd.formula_id,cctd.formula_id)=fe.formula_id
				LEFT JOIN formula_nested fn ON  fe.formula_id=fn.formula_group_id
				LEFT JOIN formula_editor fe1 ON  fe1.formula_id=fn.formula_id
				LEFT JOIN counterparty_contract_address cca ON cca.contract_id = td.contract_id
					AND cca.counterparty_id = td.counterparty_id
			WHERE
				td.counterparty_id IN(SELECT counterparty_id FROM #cpty)
				'+CASE WHEN @invoice_line_item_id IS NOT NULL THEN ' AND ISNULL(cgd.invoice_line_item_id,cctd.invoice_line_item_id) IN ('+@invoice_line_item_id +')' ELSE '' END+'
				AND '''+CAST(@prod_date AS VARCHAR)+''' BETWEEN CAST(CONVERT(VARCHAR(7),COALESCE(cca.contract_start_date,cg.term_start,''1990-01-01''),120)+''-01'' AS DATETIME) AND DATEADD(m,1,CAST(CONVERT(VARCHAR(7),COALESCE(cca.contract_end_date,cg.term_end, ''9999-01-01''),120)+''-01'' AS DATETIME))-1
				--AND ((COALESCE(cctd1.contract_component_type, cctd.contract_component_type, radio_automatic_manual,''f'')=''f'' AND COALESCE(cctd1.formula_id,cgd.formula_id,cctd.formula_id) IS NOT NULL) OR (COALESCE(cctd1.contract_component_type, cctd.contract_component_type, radio_automatic_manual,''f'')<>''f''))
					
			) a 		
		OUTER APPLY(
			
			SELECT civv2.calc_id,civ.finalized,civ.manual_input, civ.status
			FROM
				(SELECT MAX(as_of_date) as_of_date,prod_date,counterparty_id,contract_id FROM calc_invoice_volume_variance WHERE
					 '+CASE WHEN @date_type='s' THEN 'dbo.fnagetcontractmonth(settlement_date)' ELSE 'prod_date' END +'=dbo.fnagetcontractmonth('''+CAST(@prod_date AS VARCHAR)+''')
					AND counterparty_id=a.counterparty_id AND contract_id=a.contract_id GROUP BY prod_date,counterparty_id,contract_id ) civv1
				INNER JOIN calc_invoice_volume_variance civv2 ON civv2.as_of_date = civv1.as_of_date
					AND civv2.prod_date = civv1.prod_date
					AND civv2.counterparty_id = civv1.counterparty_id
					AND civv2.contract_id = civv1.contract_id 	
				INNER JOIN calc_invoice_volume civ ON civv2.calc_id=civ.calc_id 
					AND ISNULL(a.deal_type,-1)=ISNULL(deal_type_id,-1) 
			) civv				
			WHERE 1=1 
		GROUP BY a.counterparty_id,a.contract_id,a.invoice_Line_item_id,a.formula_id,a.[ID],a.sequence_order,a.volume_granularity,a.is_true_up
		ORDER BY a.sequence_order '
	
	EXEC spa_print @sqlstmt
	EXEC(@sqlstmt)




	IF EXISTS (SELECT fe.formula_id, MAX(fe.formula) formula
		FROM formula_editor fe 
		inner join formula_nested fn on fn.formula_id = fe.formula_id --and fn.formula_group_id in (699)
		inner join #temp_formula tf on tf.formula_id = fn.formula_group_id
		left join formula_breakdown fb on fn.formula_group_id = fb.formula_id AND fb.nested_id = fn.sequence_order
		 WHERE fb.formula_breakdown_id IS NULL
		 GROUP BY fe.formula_id)
	BEGIN
		-- code here to check formula breakdown and formula parse for insertion

		SELECT fe.formula_id, MAX(fe.formula) formula, fe.formula_type, fn.formula_group_id , fn.formula_id formula_nested_id, fn.sequence_order
			into #temp_formula_cur
		FROM formula_editor fe 
		inner join formula_nested fn on fn.formula_id = fe.formula_id --and fn.formula_group_id in (699)
		inner join #temp_formula tf on tf.formula_id = fn.formula_group_id
		left join formula_breakdown fb on fn.formula_group_id = fb.formula_id AND fb.nested_id = fn.sequence_order
		 WHERE fb.formula_breakdown_id IS NULL
		 GROUP BY fe.formula_id,fe.formula_type, fn.formula_group_id , fn.formula_id, fn.sequence_order
		 
	
		DECLARE @formula_cur_val VARCHAR(MAX)
		DECLARE @formula_cur_type VARCHAR(2)
		DECLARE @formula_id_cur INT
		DECLARE @formula_xmlValue_cur VARCHAR(MAX)
		DECLARE @formula_group_id_cur INT
		DECLARE @formula_nested_id_cur INT
		DECLARE @sequence_order_cur INT


		DECLARE formula_breakdown_cur CURSOR FOR
		SELECT formula_id, formula, formula_type, formula_group_id, formula_nested_id, sequence_order FROM #temp_formula_cur
		
		OPEN formula_breakdown_cur
		FETCH NEXT FROM formula_breakdown_cur
		INTO @formula_id_cur, @formula_cur_val, @formula_cur_type,  @formula_group_id_cur, @formula_nested_id_cur, @sequence_order_cur
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @formula_cur_type = 'd'			
				SELECT @formula_xmlValue_cur = dbo.FNAParseFormula(dbo.FNAFormulaFormatMaxString(@formula_cur_val, 'c'))
			ELSE
				SELECT @formula_xmlValue_cur = dbo.FNAParseFormula(@formula_cur_val)
			SET @formula_xmlValue_cur += '>'
			EXEC spa_formula_breakdown 'u',@formula_id_cur,@sequence_order_cur,@formula_xmlValue_cur,@formula_group_id_cur,@formula_nested_id_cur
			
			FETCH NEXT FROM formula_breakdown_cur
				INTO @formula_id_cur, @formula_cur_val, @formula_cur_type,  @formula_group_id_cur, @formula_nested_id_cur, @sequence_order_cur
		END
		CLOSE formula_breakdown_cur
		DEALLOCATE formula_breakdown_cur

		drop table #temp_formula_cur
		
	
	END


	--##########call true up calc
	--IF EXISTS (SELECT 'X' FROM #temp_formula WHERE is_true_up ='y')
	--BEGIN
	--		SELECT @process_id
	--		SET @stmt = ' spa_calc_true_up '''+CONVERT(VARCHAR(10),@prod_date,120)+''',''' +@counterparty_id+''',''' +CONVERT(VARCHAR(10),@as_of_date,120)+''',''' +ISNULL(@contract_id_param,'NULL')+''',''' +ISNULL(@estimate_calculation,'NULL')+''',''' +ISNULL(@module_type,'NULL')+''',''' +ISNULL(@invoice_line_item_id,'NULL')+''',''' +ISNULL(@deal_set_calc,'NULL')+''',''' +ISNULL(@cpt_type,'NULL')+''',''' +ISNULL(@date_type,'NULL')+''',''' +ISNULL(@calc_id,'NULL')+''',''' +CONVERT(VARCHAR(10),@prod_date_to,120)+''',''' +ISNULL(@user_login_id,'NULL')+''''
	--		SELECT @stmt			
	--		SET @job_name = 'TrueUPCalc_' + dbo.FNAGetNewID()
	--		EXEC spa_run_sp_as_job @job_name,  @stmt, 'True UP Calc', @user_name
	--END

	IF @call_from_true_up = 'n'
	BEGIN
		DELETE FROM #temp_formula WHERE is_true_up ='y'
	END

	--##########call true up calc


	IF (SELECT MAX('X') FROM #temp_formula WHERE granularity IN(982,994,995))='X' 
		SET @hourly_calculation='y'


	--print 'formula table populated'+': '+cast(datediff(ss,@calc_time,getdate()) as varchar) +'*************************************'
	set @calc_time=getdate()


	---*************************************
	--Section 3.5
	--Insert hourly data in process table, that needs to be processed
	---*************************************
	--(
	 SELECT a.meter_id,a.source_deal_detail_id,a.location_id,a.curve_id,a.curve_tou,a.term_date,
		REPLACE(a.[Hour],'hr','')[Hour],a.[volume] factor, 
		CASE WHEN dst_hour=1 AND a.[Hour]='Hr25' THEN 1 ELSE 0 END dst_hour
		INTO #Onpeak_offpeak_block
	FROM
			#temp_deals td
		CROSS APPLY	
		(SELECT hb.block_define_id,hb.term_date,
				hb.Hr1, hb.Hr2, hb.Hr3, hb.Hr4, hb.Hr5, hb.Hr6, hb.Hr7, hb.Hr8, hb.Hr9, hb.Hr10, hb.Hr11, hb.Hr12, 
				hb.Hr13, hb.Hr14, hb.Hr15, hb.Hr16, hb.Hr17, hb.Hr18, hb.Hr19, hb.Hr20, hb.Hr21,hb.Hr22, hb.Hr23, hb.Hr24,
				CAST(CASE WHEN hb.add_dst_hour<=0 THEN 0 ELSE hb.Hr3 END AS tinyint) Hr25,CASE WHEN hb.add_dst_hour<=0 THEN 0 ELSE 1 END dst_hour
			FROM 
				hour_block_term hb
			WHERE
				hb.block_type=12000
				AND hb.block_define_id=ISNULL(td.block_defintion_id,@baseload_block_definition)
				AND hb.term_date BETWEEN td.deal_term_start AND td.deal_term_end
				AND hb.dst_group_value_id = td.dst_group_value_id
		) hb

	UNPIVOT
	([Volume] FOR [Hour] IN(HR1 ,HR2 ,HR3 ,HR4 ,HR5 ,HR6 ,HR7 ,HR8 ,HR9 ,HR10 ,HR11 ,HR12 ,HR13 ,HR14 ,HR15 ,HR16 ,HR17 ,HR18 ,HR19 ,HR20 ,HR21 ,HR22 ,HR23 ,HR24,Hr25)
	)a 

	CREATE INDEX [IX_op1] ON [dbo].[#Onpeak_offpeak_block]([source_deal_detail_id],[curve_id] ,[location_id])
	CREATE INDEX [IX_op2] ON [dbo].[#Onpeak_offpeak_block]([term_date])
	
	CREATE TABLE #temp_hour(
			meter_data_id INT,
			counterparty_id INT,
			contract_id INT,
			prod_date datetime,
			HR1 FLOAT,HR2 FLOAT,HR3 FLOAT,HR4 FLOAT,HR5 FLOAT,HR6 FLOAT,HR7 FLOAT,HR8 FLOAT,HR9 FLOAT,HR10 FLOAT,HR11 FLOAT,HR12 FLOAT,HR13 FLOAT,HR14 FLOAT,HR15 FLOAT,HR16 FLOAT,HR17 FLOAT,HR18 FLOAT,HR19 FLOAT,HR20 FLOAT,HR21 FLOAT,HR22 FLOAT,HR23 FLOAT,HR24 FLOAT,HR25 FLOAT,
			data_missing CHAR(1) COLLATE DATABASE_DEFAULT,
			source_deal_detail_id INT,
			deal_term_start DATETIME,
			deal_formula_id INT,
			location_id INT,
			generator_id INT,
			commodity_id INT,
			source_deal_header_id INT,
			allocation_vol INT,
			meter_id INT,
			period INT,
			conversion_factor FLOAT
		)


	--- Get the meter id FOR deals location

	IF EXISTS(SELECT 'x' FROM #temp_deals where meter_id IS NOT NULL)
	BEGIN
				SET @sqlstmt='
				INSERT INTO #temp_hour(meter_data_id,counterparty_id,contract_id,prod_date,HR1 ,HR2 ,HR3 ,HR4 ,HR5 ,HR6 ,HR7 ,HR8 ,HR9 ,HR10 ,HR11 ,HR12 ,HR13 ,HR14 ,HR15 ,HR16 ,HR17 ,HR18 ,HR19 ,HR20 ,HR21 ,HR22 ,HR23 ,HR24 ,HR25, data_missing,source_deal_detail_id,deal_term_start,deal_formula_id,location_id,generator_id,commodity_id,source_deal_header_id,allocation_vol,meter_id,period,conversion_factor)
				SELECT
					mv.meter_data_id,
					td.counterparty_id,
					td.contract_id,
					mvh.prod_date AS prod_date,
					SUM(mvh.HR1 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)) HR1,
					SUM(mvh.HR2 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR3 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR4 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR5 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR6 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR7 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR8 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR9 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR10 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR11 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR12 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR13 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR14 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR15 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR16 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR17 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR18 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR19 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR20 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR21 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR22 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR23 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR24 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					SUM(mvh.HR25 *ISNULL(rp.mult_factor,1)*ISNULL(conv.conversion_factor,1)),
					''n'' AS data_missing,				
					td.source_deal_detail_id AS source_deal_detail_id,
					td.deal_term_start AS deal_term_start,
					MAX(td.deal_formula_id),
					MAX(td.location_id),
					td.generator_id,
					MAX(td.commodity_id),
					td.source_deal_header_id,
					1 allocation_vol,	
					td.meter_id,
					mvh.period,
					MAX(ISNULL(conv.conversion_factor,1))	
			FROM
				#temp_deals td
				INNER JOIN mv90_data mv ON mv.meter_id=td.meter_id AND mv.from_date=td.deal_term_start 
				INNER JOIN  '+dbo.FNAGetProcessTableName(@prod_date,'mv90_data_hour')+' mvh ON mv.meter_data_id=mvh.meter_data_id
				INNER JOIN #ContractBillingDate cb ON cb.contract_id=td.contract_id AND mvh.prod_date between cb.udf_from_date AND cb.udf_to_date
				INNER JOIN recorder_properties rp ON rp.meter_id=mv.meter_id and rp.channel=mv.channel
				LEFT JOIN rec_volume_unit_conversion conv ON rp.uom_id=conv.FROM_source_uom_id AND conv.to_source_uom_id=td.uom_id  
						AND conv.state_value_id is null AND conv.assignment_type_value_id is null AND conv.curve_id is null   	
			WHERE
				mvh.prod_date between cb.udf_from_date AND cb.udf_to_date
				GROUP BY mv.meter_data_id,td.counterparty_id,td.contract_id,mvh.prod_date,td.source_deal_detail_id,td.generator_id,td.source_deal_header_id,td.source_deal_detail_id,td.meter_id,mvh.period,td.deal_term_start

				'
		--print @sqlstmt
		EXEC(@sqlstmt)
	END

	--IF @hourly_calculation='y' OR EXISTS(SELECT 'X' FROM #temp_formula WHERE granularity=981) -- only populate hourly tables for hourly calculations
	IF EXISTS(SELECT 'x' FROM #temp_deals where source_deal_header_id IS NOT NULL)
	BEGIN

		INSERT INTO #temp_hour
				(meter_data_id,counterparty_id,contract_id,prod_date,HR1 ,HR2 ,HR3 ,HR4 ,HR5 ,HR6 ,HR7 ,HR8 ,HR9 ,HR10 ,HR11 ,HR12 ,HR13 ,HR14 ,HR15 ,HR16 ,HR17 ,HR18 ,HR19 ,HR20 ,HR21 ,HR22 ,HR23 ,HR24 , HR25 ,data_missing,source_deal_detail_id,deal_term_start,deal_formula_id,location_id,generator_id,commodity_id,source_deal_header_id,meter_id,period,conversion_factor)
		SELECT
			NULL as meter_data_id,
			td.counterparty_id,
			td.contract_id,
			rhpd.term_start,
			rhpd.HR1 ,rhpd.HR2 ,rhpd.HR3 ,rhpd.HR4 ,rhpd.HR5 ,rhpd.HR6 ,rhpd.HR7 ,rhpd.HR8 ,rhpd.HR9 ,rhpd.HR10 ,rhpd.HR11 ,rhpd.HR12 ,rhpd.HR13 ,rhpd.HR14 ,rhpd.HR15 ,
				rhpd.HR16 ,rhpd.HR17 ,rhpd.HR18 ,rhpd.HR19 ,rhpd.HR20 ,rhpd.HR21 ,rhpd.HR22 ,rhpd.HR23 ,rhpd.HR24 ,rhpd.hr25 ,
			NULL data_missing,
			td.source_deal_detail_id,
			td.deal_term_start,
			td.deal_formula_id,
			td.location_id,
			td.generator_id,
			td.commodity_id,
			td.source_deal_header_id,
			td.meter_id,
			th.period,
			1 conversion_factor
		FROM
			#temp_deals td
			INNER JOIN report_hourly_position_deal rhpd ON rhpd.term_start BETWEEN td.term_start AND td.term_end
				AND rhpd.source_deal_detail_id=td.source_deal_detail_id
			INNER JOIN #ContractBillingDate cb ON cb.contract_id=td.contract_id AND rhpd.term_start between cb.udf_from_date AND cb.udf_to_date
			LEFT JOIN #temp_hour th ON ISNULL(th.location_id,-1)=ISNULL(td.location_id,-1)
				AND th.source_deal_detail_id=td.source_deal_detail_id
				AND rhpd.term_start=th.prod_date
		WHERE
			th.location_id IS NULL			

		--UNION
		INSERT INTO #temp_hour
				(meter_data_id,counterparty_id,contract_id,prod_date,HR1 ,HR2 ,HR3 ,HR4 ,HR5 ,HR6 ,HR7 ,HR8 ,HR9 ,HR10 ,HR11 ,HR12 ,HR13 ,HR14 ,HR15 ,HR16 ,HR17 ,HR18 ,HR19 ,HR20 ,HR21 ,HR22 ,HR23 ,HR24 , HR25 ,data_missing,source_deal_detail_id,deal_term_start,deal_formula_id,location_id,generator_id,commodity_id,source_deal_header_id,meter_id,period,conversion_factor)

		SELECT
			NULL as meter_data_id,
			td.counterparty_id,
			td.contract_id,
			rhpd.term_start,
			rhpd.HR1 ,rhpd.HR2 ,rhpd.HR3 ,rhpd.HR4 ,rhpd.HR5 ,rhpd.HR6 ,rhpd.HR7 ,rhpd.HR8 ,rhpd.HR9 ,rhpd.HR10 ,rhpd.HR11 ,rhpd.HR12 ,rhpd.HR13 ,rhpd.HR14 ,rhpd.HR15 ,
				rhpd.HR16 ,rhpd.HR17 ,rhpd.HR18 ,rhpd.HR19 ,rhpd.HR20 ,rhpd.HR21 ,rhpd.HR22 ,rhpd.HR23 ,rhpd.HR24 ,rhpd.hr25 ,
			NULL data_missing,
			td.source_deal_detail_id,
			td.deal_term_start,
			td.deal_formula_id,
			td.location_id,
			td.generator_id,
			td.commodity_id,
			td.source_deal_header_id,
			td.meter_id,
			th.period,
			1 conversion_factor
		FROM
			#temp_deals td
			INNER JOIN report_hourly_position_profile rhpd ON td.source_deal_header_id=rhpd.source_deal_header_id
				--AND rhpd.term_start BETWEEN td.deal_term_start AND deal_term_end				
				AND ISNULL(td.location_id,-1)=ISNULL(rhpd.location_id,-1)
			INNER JOIN #ContractBillingDate cb ON cb.contract_id=td.contract_id AND rhpd.term_start between cb.udf_from_date AND cb.udf_to_date
			LEFT JOIN #temp_hour th ON ISNULL(th.location_id,-1)=ISNULL(td.location_id,-1)
				AND th.source_deal_detail_id=td.source_deal_detail_id
				AND rhpd.term_start=th.prod_date
		WHERE
			th.location_id IS NULL		

-- insert the fixation deals allocation volume
	INSERT INTO #temp_hour(meter_data_id,counterparty_id,contract_id,prod_date,HR1 ,HR2 ,HR3 ,HR4 ,HR5 ,HR6 ,HR7 ,HR8 ,HR9 ,HR10 ,HR11 ,HR12 ,HR13 ,HR14 ,HR15 ,HR16 ,HR17 ,HR18 ,HR19 ,HR20 ,HR21 ,HR22 ,HR23 ,HR24 ,HR25, data_missing,source_deal_detail_id,deal_term_start,deal_formula_id,location_id,generator_id,commodity_id,source_deal_header_id,meter_id,period,conversion_factor)
	SELECT
		meter_data_id,th.counterparty_id,th.contract_id,prod_date,
		SUM(HR1) ,SUM(HR2) ,SUM(HR3) ,SUM(HR4) ,SUM(HR5) ,SUM(HR6) ,SUM(HR7) ,SUM(HR8) ,SUM(HR9) ,
		SUM(HR10) ,SUM(HR11) ,SUM(HR12) ,SUM(HR13) ,SUM(HR14) ,SUM(HR15) ,
		SUM(HR16) ,SUM(HR17) ,SUM(HR18) ,SUM(HR19) ,SUM(HR20) ,SUM(HR21) ,SUM(HR22) ,SUM(HR23) ,SUM(HR24) ,SUM(HR25), 
		MAX(data_missing),sdd.source_deal_detail_id,MAX(sdd.term_start),MAX(deal_formula_id),
		th.location_id,th.generator_id,th.commodity_id,sdh.source_deal_header_id,th.meter_id, th.period,1 conversion_factor	
	FROM
		#temp_hour th
		INNER JOIN source_deal_detail sdd1 ON sdd1.source_deal_detail_id=th.source_deal_detail_id
		INNER JOIN source_deal_header sdh ON sdh.close_reference_id=th.source_deal_header_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=sdh.source_deal_header_id
			AND th.deal_term_start=sdd.term_start
			AND sdd.leg=sdd1.leg
	GROUP BY 			
		th.meter_id, meter_data_id,th.counterparty_id,th.contract_id,prod_date,th.location_id,th.generator_id,th.commodity_id,sdh.source_deal_header_id,sdd.source_deal_detail_id,th.period			

-- populate the hourly data for financial positions

	INSERT INTO #temp_financial
		(counterparty_id,contract_id,prod_date,Hour ,volume)
	SELECT 
			a.counterparty_id,
			a.contract_id,
			a.term_start prod_date,
			CAST(REPLACE(a.[Hour],'hr','') AS INT) Hour,
			SUM(a.[volume]) volume
	 FROM
			(SELECT td.counterparty_id,td.contract_id,term_start,td.location_id,
				HR1 ,HR2 ,HR3 ,HR4 ,HR5 ,HR6 ,HR7 ,HR8 ,HR9 ,HR10 ,HR11 ,HR12 ,HR13 ,HR14 ,HR15 ,HR16 ,HR17 ,HR18 ,HR19 ,HR20 ,HR21 ,HR22 ,HR23 ,HR24 ,HR25 
				FROM #temp_deals td
					INNER JOIN report_hourly_position_deal rhpd ON td.source_deal_detail_id=rhpd.source_deal_detail_id
					INNER JOIN #ContractBillingDate cb ON cb.contract_id=td.contract_id AND rhpd.term_start between cb.udf_from_date AND cb.udf_to_date
				WHERE
					td.physical_financial_flag = 'f'	
				) P
			UNPIVOT
				([Volume] FOR [Hour] IN(HR1 ,HR2 ,HR3 ,HR4 ,HR5 ,HR6 ,HR7 ,HR8 ,HR9 ,HR10 ,HR11 ,HR12 ,HR13 ,HR14 ,HR15 ,HR16 ,HR17 ,HR18 ,HR19 ,HR20 ,HR21 ,HR22 ,HR23 ,HR24 ,HR25)
			)a	
		GROUP BY
			a.counterparty_id,a.contract_id,a.term_start ,CAST(REPLACE(a.[Hour],'hr','') AS INT)
			
------- create index on the table
			CREATE CLUSTERED INDEX [IX_tmp1] ON [dbo].[#temp_hour] 
		(
			[source_deal_detail_id] ASC,
			[meter_data_id] ASC,
			[prod_date] ASC,
			[contract_id] ASC
		)
              
	--print 'Meter Data populated'+': '+cast(datediff(ss,@calc_time,getdate()) as varchar) +'*************************************'
	SET @calc_time=GETDATE()
--Find out allocated percentage FOR each counterparty based on the contracts AND meter id association
---*************************************
	
END

--**********************************
--	Populate PIVOT temporary table
----**********************************
	DECLARE @min_granularity INT
IF EXISTS (SELECT top 1 'X' FROM #temp_formula WHERE granularity = 995)
	SET @min_granularity = 995
ELSE IF EXISTS (SELECT top 1 'X' FROM #temp_formula WHERE granularity = 994)
	SET @min_granularity = 994
ELSE IF EXISTS (SELECT top 1 'X' FROM #temp_formula WHERE granularity = 987)
	SET @min_granularity = 987
ELSE IF EXISTS (SELECT top 1 'X' FROM #temp_formula WHERE granularity = 989)
	SET @min_granularity = 989
ELSE IF EXISTS (SELECT top 1 'X' FROM #temp_formula WHERE granularity = 982)
	SET @min_granularity = 982
ELSE IF EXISTS (SELECT top 1 'X' FROM #temp_formula WHERE granularity = 981)
	SET @min_granularity = 981
ELSE IF EXISTS (SELECT top 1 'X' FROM #temp_formula WHERE granularity = 980)
	SET @min_granularity = 980

SET @min_granularity = ISNULL(@min_granularity,980)

	
	-- Allocate Volume based on Invoice

	CREATE TABLE #invoice_allocation(counterparty_id INT, contract_id INT,meter_id INT,alloc_per FLOAT,prod_month DATETIME)

	INSERT INTO #invoice_allocation(counterparty_id,contract_id,meter_id,alloc_per,prod_month)
	SELECT 
		rg.ppa_counterparty_id,rg.ppa_contract_id,rgm.meter_id,ISNULL(ISNULL(ih.invoice_volume,1)/NULLIF((SUM(ISNULL(ih.invoice_volume,1)) OVER (partition BY td.meter_id,td.deal_term_start)),0),10) alloc_per,td.deal_term_start
	FROM 
		#temp_deals td
		INNER JOIN recorder_generator_map rgm ON td.meter_id = rgm.meter_id --and ISNULL(rgm.allocation_per,1) = 1
		INNER JOIN rec_generator rg ON rgm.generator_id = rg.generator_id
		LEFT JOIN invoice_header ih ON ih.counterparty_id = rg.ppa_counterparty_id --AND ih.contract_id = rg.ppa_contract_id 
			AND ih.production_month = td.deal_term_start



	SET @Pivot_table=
		'
		INSERT INTO #pvt_table
		SELECT 
			td.counterparty_id,
			td.contract_id,
			'+CASE WHEN @min_granularity = 980 THEN 'CONVERT(VARCHAR(7),ISNULL(a.prod_date,td.deal_term_start),120)+''-01''' ELSE 'ISNULL(a.prod_date,td.deal_term_start)' END+' prod_date,
			'+CASE WHEN @min_granularity IN(982,995,994,987,989) THEN 'CAST(REPLACE(REPLACE(a.[Hour],''25'',''''+ISNULL(mvdst.[hour],2)+''''),''hr'','''') AS INT)' ELSE 'NULL' END+' Hour,
			(SUM((ISNULL(a.[volume],td.deal_volume)-CASE WHEN a.[Hour]=''HR''+CAST(mvdst.[hour] AS VARCHAR) AND a.[volume]<>0 THEN ISNULL(dst_volume,0) ELSE 0 END))-MAX(ISNULL(mia.gre_volume*ISNULL(a.conversion_factor,1),0))) * MAX(ISNULL(ial.alloc_per,1)) volume,
			MAX(a.data_missing),
			td.source_deal_detail_id,
			MAX(td.deal_term_start),
			MAX(td.deal_formula_id),
			MAX(td.location_id),
			td.generator_id,
			MAX(td.commodity_id),
			'+CASE WHEN @min_granularity IN(982,995,994,987,989) THEN 'CASE WHEN a.[Hour]=''HR25'' AND a.[volume]<>0 THEN 1 ELSE 0 END' ELSE '0' END +' is_dst,
			td.source_deal_header_id,
			td.curve_tou,
			MAX(ISNULL(on_b.factor,0)),
			SUM(a.allocation_vol),
			MAX(td.deal_settlement_amount),
			MAX(td.deal_settlement_volume),
			MAX(td.deal_settlement_price),
			MAX(td.deal_type),
			MAX(td.meter_id),
			MAX(td.source_system_book_id1),
			MAX(td.source_system_book_id2),
			MAX(td.source_system_book_id3),
			MAX(td.source_system_book_id4),
			MAX(td.netting_group_id),
			MAX(td.invoice_granularity),
			MAX(td.leg),
			MAX(td.is_true_up),
			MAX(td.contract_allocation),
			'+CASE WHEN @min_granularity IN(995,994,987,989) THEN 'a.period' ELSE '0' END+',
			MAX(td.buy_sell),
			SUM((ISNULL(a.[volume],td.deal_volume)-CASE WHEN a.[Hour]=''HR3'' AND a.[volume]<>0 THEN ISNULL(dst_volume,0) ELSE 0 END)*on_b.factor) onpeak_volume,
			SUM((ISNULL(a.[volume],td.deal_volume)-CASE WHEN a.[Hour]=''HR3'' AND a.[volume]<>0 THEN ISNULL(dst_volume,0) ELSE 0 END)* CASE WHEN on_b.factor = 0  THEN 1 ELSE 0 END ) offpeak_volume,
			SUM(on_b.factor) as onpeakperiod_hour,
			SUM(CASE WHEN on_b.factor = 0  THEN 1 ELSE 0 END) as offpeakperiod_hour,
			SUM(CASE WHEN on_b.factor = 0  THEN 1 ELSE 1 END) as totalperiod_hour,
			MAX(CASE WHEN on_b.factor = 0 THEN 0 ELSE ISNULL(a.[volume],td.deal_volume)-CASE WHEN a.[Hour]=''HR3'' AND a.[volume]<>0 THEN ISNULL(dst_volume,0) ELSE 0 END END) onpeakmax_value,
			MAX(CASE WHEN on_b.factor = 1 THEN 0 ELSE ISNULL(a.[volume],td.deal_volume)-CASE WHEN a.[Hour]=''HR3'' AND a.[volume]<>0 THEN ISNULL(dst_volume,0) ELSE 0 END END ) onpeakmax_value
		FROM
			#temp_deals td
			LEFT JOIN
			(SELECT counterparty_id,contract_id,prod_date,data_missing,source_deal_detail_id,deal_term_start,deal_formula_id,location_id,generator_id,commodity_id,HR25 dst_volume,allocation_vol,meter_id,period,conversion_factor,
				HR1 ,HR2 ,HR3 ,HR4 ,HR5 ,HR6 ,HR7 ,HR8 ,HR9 ,HR10 ,HR11 ,HR12 ,HR13 ,HR14 ,HR15 ,HR16 ,HR17 ,HR18 ,HR19 ,HR20 ,HR21 ,HR22 ,HR23 ,HR24,HR25
				FROM #temp_hour) P
			UNPIVOT
				([Volume] FOR [Hour] IN(HR1 ,HR2 ,HR3 ,HR4 ,HR5 ,HR6 ,HR7 ,HR8 ,HR9 ,HR10 ,HR11 ,HR12 ,HR13 ,HR14 ,HR15 ,HR16 ,HR17 ,HR18 ,HR19 ,HR20 ,HR21 ,HR22 ,HR23 ,HR24,HR25)
			)a		
			ON ISNULL(td.source_deal_detail_id,-1)=ISNULL(a.source_deal_detail_id,-1)
				AND ISNULL(td.meter_id,-1)=ISNULL(a.meter_id,-1)
				AND td.contract_id = a.contract_id
				AND td.counterparty_id = a.counterparty_id
				AND ISNULL(td.generator_id,-1) = ISNULL(a.generator_id,-1)
				AND a.deal_term_start = td.deal_term_start
			INNER JOIN #ContractBillingDate cb ON cb.contract_id=td.contract_id 
				AND CAST(CONVERT(VARCHAR(10),ISNULL(prod_date,td.deal_term_start),120)+'' ''+ISNULL(CAST(CAST(REPLACE(REPLACE(a.[Hour],''25'',''3''),''hr'','''') AS INT)-1 AS VARCHAR),''00'')+'':00:00:000'' AS DATETIME) between cb.udf_from_date_hour AND cb.udf_to_date_hour
			LEFT JOIN #Onpeak_offpeak_block on_b ON ISNULL(on_b.meter_id,-1)=ISNULL(a.meter_id,-1)
				AND ISNULL(on_b.source_deal_detail_id,-1)=ISNULL(a.source_deal_detail_id,-1)
				AND ISNULL(on_b.curve_id,-1)=ISNULL(td.curve_id,-1)
				AND ISNULL(on_b.location_id,-1)=ISNULL(td.location_id,-1)
				AND on_b.term_date=ISNULL(a.prod_date,td.deal_term_start)
				AND on_b.[hour]= CAST(REPLACE(a.[Hour],''hr'','''') AS INT)
				AND on_b.dst_hour=CASE WHEN a.[Hour]=''HR25'' AND a.[volume]<>0 THEN 1 ELSE 0 END
			LEFT JOIN #invoice_allocation ial ON ial.counterparty_id = td.counterparty_id AND ial.contract_id=td.contract_id AND ial.meter_id=td.meter_id AND ial.prod_month = td.deal_term_start
			LEFT JOIN meter_id_allocation mia ON mia.meter_id = td.meter_id AND mia.production_month = a.prod_date
			LEFT JOIN mv90_dst mvdst ON mvdst.[date] = a.prod_date AND mvdst.insert_delete=''i''
				AND mvdst.dst_group_value_id = td.dst_group_value_id
			WHERE (( a.[Hour]=''HR25'' AND a.[volume]<>0) OR a.[Hour]<>''HR25'')
		GROUP BY td.counterparty_id,td.contract_id,td.source_deal_detail_id,td.generator_id,td.source_deal_header_id,td.curve_tou
		'+CASE WHEN @min_granularity = 980 THEN ',CONVERT(VARCHAR(7),ISNULL(a.prod_date,td.deal_term_start),120)' ELSE ',ISNULL(a.prod_date,td.deal_term_start)' END
		 +CASE WHEN @min_granularity IN(982,995,994,987,989) THEN ',CAST(REPLACE(REPLACE(a.[Hour],''25'',''''+ISNULL(mvdst.[hour],2)+''''),''hr'','''') AS INT)' ELSE '' END
		 +CASE WHEN @min_granularity IN(982,995,994,987,989) THEN ',CASE WHEN a.[Hour]=''HR25'' AND a.[volume]<>0 THEN 1 ELSE 0 END' ELSE '' END 
		 +CASE WHEN @min_granularity IN(995,994,987,989) THEN ',a.period' ELSE '' END
		
		EXEC(@Pivot_table)



		IF NOT EXISTS(SELECT 'X' FROM #pvt_table) -- if there is no meter data then populate the table for calculations
		BEGIN
			SET @Pivot_table=
			'
			INSERT INTO #pvt_table
			SELECT 
				td.counterparty_id,
				td.contract_id,
				'+CASE WHEN @min_granularity = 980 THEN 'CONVERT(VARCHAR(7),ISNULL(on_b.term_date,td.deal_term_start),120)+''-01''' ELSE 'ISNULL(on_b.term_date,td.deal_term_start)' END +' prod_date,
				'+CASE WHEN @min_granularity = 982 THEN 'CASE WHEN on_b.[dst_hour] = 1 AND on_b.[Hour] = 25 THEN mvdst.[hour] ELSE on_b.[Hour] END' ELSE 'NULL' END+' Hour,
				SUM(td.deal_settlement_volume*ISNULL(conv.conversion_factor,1)) volume,
				NULL data_missing,
				td.source_deal_detail_id,
				MAX(td.deal_term_start),
				MAX(td.deal_formula_id),
				MAX(td.location_id),
				MAX(td.generator_id),
				MAX(td.commodity_id),
				'+CASE WHEN @min_granularity = 982 THEN 'on_b.[dst_hour]' ELSE '0' END+' is_dst,
				MAX(td.source_deal_header_id),
				MAX(td.curve_tou),
				MAX(ISNULL(on_b.factor,0)),
				0 AS allocation_vol,
				SUM(td.deal_settlement_amount),
				SUM(td.deal_settlement_volume*ISNULL(conv.conversion_factor,1)),
				MAX(td.deal_settlement_price),
				MAX(td.deal_type),
				MAX(td.meter_id),
				MAX(td.source_system_book_id1),
				MAX(td.source_system_book_id2),
				MAX(td.source_system_book_id3),
				MAX(td.source_system_book_id4),
				MAX(td.netting_group_id),
				MAX(td.invoice_granularity),
				MAX(td.leg),
				MAX(td.is_true_up),
				MAX(td.contract_allocation),
				0 as period,
				MAX(td.buy_sell),
				0 onpeak_volume,
				0 offpeak_volume,			
				SUM(on_b.factor) as onpeakperiod_hour,
				SUM(CASE WHEN on_b.factor = 0  THEN 1 ELSE 0 END) as offpeakperiod_hour,
				SUM(CASE WHEN on_b.factor = 0  THEN 1 ELSE 1 END) as totalperiod_hour,
				0 onpeakmax_value,
				0 onpeakmax_value
		FROM
				#temp_deals td	
				LEFT JOIN #Onpeak_offpeak_block on_b ON ISNULL(on_b.source_deal_detail_id,-1)=ISNULL(td.source_deal_detail_id,-1)
					AND ISNULL(on_b.curve_id,-1)=ISNULL(td.curve_id,-1)
					AND ISNULL(on_b.location_id,-1)=ISNULL(td.location_id,-1)
					AND YEAR(on_b.term_date)=YEAR(td.deal_term_start)
					AND MONTH(on_b.term_date)=MONTH(td.deal_term_start)'
					+CASE WHEN @min_granularity = 980 THEN 'AND 1=2' ELSE '' END+ '			
				INNER JOIN #ContractBillingDate cb ON cb.contract_id=td.contract_id 
					AND CAST(CONVERT(VARCHAR(10),ISNULL(term_date,td.deal_term_start),120)+'' ''+ISNULL(CAST(ISNULL(on_b.[Hour]-1,0) AS VARCHAR),''00'')+'':00:00:000'' AS DATETIME) between cb.udf_from_date_hour AND cb.udf_to_date_hour
					AND ISNULL(on_b.[Hour],0) <> 25
				LEFT JOIN rec_volume_unit_conversion conv ON conv.FROM_source_uom_id = td.set_volume_uom AND conv.to_source_uom_id=td.uom_id  
						AND conv.state_value_id is null AND conv.assignment_type_value_id is null AND conv.curve_id is null   	
				LEFT JOIN mv90_dst mvdst ON mvdst.[date] = ISNULL(on_b.term_date,td.deal_term_start) AND mvdst.insert_delete=''i''
					AND mvdst.dst_group_value_id = td.dst_group_value_id
				GROUP BY 
					td.counterparty_id,	td.contract_id,td.source_deal_detail_id,td.generator_id
					'+CASE WHEN @min_granularity = 980 THEN ',CONVERT(VARCHAR(7),ISNULL(on_b.term_date,td.deal_term_start),120)+''-01''' ELSE ',ISNULL(on_b.term_date,td.deal_term_start)' END
					 +CASE WHEN @min_granularity = 982 THEN ',CASE WHEN on_b.[dst_hour] = 1 AND on_b.[Hour] = 25 THEN mvdst.[hour] ELSE on_b.[Hour] END' ELSE '' END
					 +CASE WHEN @min_granularity = 982 THEN ',on_b.[dst_hour]' ELSE '' END

		EXEC(@Pivot_table)
	END

	CREATE INDEX [IX_pv1] ON [dbo].#pvt_table(counterparty_id,contract_id,commodity_id)
	CREATE INDEX [IX_pv2] ON [dbo].#pvt_table(prod_date,[Hour])

--- temporay table for Average Hourly Function
	DECLARE @baseload_block INT
	SELECT @baseload_block = value_id  FROM static_data_value WHERE [type_id] = 10018 AND code LIKE 'Base Load'



IF exists(select 1 from #temp_formula tmp inner join formula_nested fn On fn.formula_group_id = tmp.formula_id INNER JOIN formula_editor fe ON fe.formula_id = fn.formula_id  where fe.formula LIKE '%AverageHourly%' OR fe.formula LIKE '%AverageMnthly%')
BEGIN

	--select distinct f.curve_id,f.deal_term_start maturity_date,ISNULL(block_define_id,@baseload_block) block_define_id 
	--into #tmp_cache_curve from #temp_deals f left join source_price_curve_def spcd on f.curve_id=spcd.source_curve_def_id WHERE f.curve_id IS NOT NULL

	SELECT 
		DISTINCT  tf.dst_group_value_id,fd.arg1 curve_id,@prod_date maturity_date,COALESCE(NULLIF(CASE WHEN fd.func_name = 'AverageMnthlyPrice' then NULL ELSE fd.arg2 END ,'NULL'),@baseload_block) block_define_id 
	INTO #tmp_cache_curve		
	FROM
		#temp_formula tf
		INNER JOIN formula_breakdown fd On tf.formula_id = fd.formula_id AND (fd.func_name = 'AverageHourlyPrice' OR fd.func_name = 'AverageMnthlyPrice')
	--WHERE fd.arg2 IS NOT NULL


	select  dst_group_value_id,block_define_id ,MIN(maturity_date) term_start,Max(maturity_date) term_end into #tmp_block_def 
	from #tmp_cache_curve
	group by block_define_id


SET @sqlstmt='
	;WITH CTE AS (
		SELECT unpvt.block_define_id,unpvt.term_date,CAST(REPLACE(unpvt.[hour],''hr'','''') AS INT) [Hour],unpvt.hr_mult FROM 
		(SELECT
				hb.term_date,
				hb.block_type,
				hb.block_define_id,
				hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
			FROM #tmp_block_def c  
				inner join hour_block_term hb on block_type=12000
				AND hb.block_define_id=c.block_define_id
				AND YEAR(term_date) = YEAR(c.term_start)
				AND MONTH(term_date) = MONTH(c.term_start)
				AND hb.dst_group_value_id = c.dst_group_value_id
		)p
		
			UNPIVOT
			(hr_mult FOR [hour] IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
			) AS unpvt 
		WHERE
		unpvt.[hr_mult]<>0
	)
	
	Insert into dbo.source_price_curve_cache(as_of_date, maturity_date,curve_id,curve_value, process_id,block_define_id)
	SELECT
			'''+CONVERT(VARCHAR(10),@as_of_date,120)+''',a.maturity_date ,a.curve_id,AVG(curve_value) curve_value,'''+@test_process_id+''',block_define_id
	FROM		
	(		
		SELECT 
			tcc.curve_id,tcc.maturity_date,spc.curve_value*ISNULL(hr_mult,0) curve_value,tcc.block_define_id		
		FROM
			source_price_curve spc inner join source_price_curve_def spcd on spc.source_curve_def_id=spcd.source_curve_def_id
			inner join #tmp_cache_curve tcc on tcc.curve_id=spcd.source_curve_def_id
			AND YEAR(spc.maturity_date) = YEAR(tcc.maturity_date)
			AND MONTH(spc.maturity_date) = MONTH(tcc.maturity_date)
			INNER JOIN CTE td on CONVERT(VARCHAR(10),td.term_date,120) = CONVERT(VARCHAR(10),spc.maturity_date,120)
			AND td.[Hour]-1  = DATEPART(hh,spc.maturity_date)
			AND tcc.block_define_id= td.block_define_id 
			AND spc.maturity_date<='''+CONVERT(VARCHAR(10),@as_of_date,120)+'''+'' 23:59:59.000'''
			
	+CASE WHEN day(@as_of_date)<>dbo.FNALastDayInMonth(@as_of_date) THEN
		' UNION ALL
		SELECT 
			tcc.curve_id,tcc.maturity_date,spc.curve_value curve_value,tcc.block_define_id			
		FROM 
		source_price_curve_def spcd  
		inner join #tmp_cache_curve tcc on tcc.curve_id=spcd.source_curve_def_id
		INNER JOIN source_price_curve_def spcd1 ON spcd1.source_curve_def_id = spcd.proxy_source_curve_def_id
		inner join	source_price_curve spc  on spc.source_curve_def_id=spcd1.source_curve_def_id
				AND YEAR(spc.maturity_date) = YEAR(tcc.maturity_date)
			AND MONTH(spc.maturity_date) = MONTH(tcc.maturity_date)
			AND spc.as_of_date  = '''+CONVERT(VARCHAR(10),@as_of_date,120)+'''
			AND spc.maturity_date > '''+CONVERT(VARCHAR(10),@as_of_date,120)+'''+'' 23:59:59.000''' ELSE '' END+'	
	) a group by a.curve_id,a.maturity_date,a.block_define_id'

EXEC(@sqlstmt)
	
END

-- delete from source_price_curve_cache
--DELETE FROM dbo.source_price_curve_cache



IF (SELECT MAX('X') FROM #temp_formula WHERE granularity=980)='X'
	BEGIN	
		SET @sqlstmt='
		INSERT INTO '+@formula_table+'(rowid,counterparty_id,contract_id,prod_date,as_of_date,volume,onPeakVolume,source_deal_detail_id,formula_id,invoice_Line_item_id,invoice_line_item_seq_id,price,granularity,volume_uom_id,generator_id,[Hour],commodity_id,[mins],is_dst,source_deal_header_id,calc_aggregation,fin_volume,offPeakVolume,curve_tou,allocation_volume,deal_settlement_amount,deal_settlement_volume,deal_settlement_price,deal_type,meter_id,netting_group_id,invoice_granularity,is_true_up,onpeakperiod_hour,offpeakperiod_hour,totalperiod_hour,onpeakmax_value,offpeakmax_value)
			SELECT 
				DENSE_RANK() OVER(ORDER BY mv.counterparty_id,mv.contract_id,tf.invoice_line_item_id,tf.formula_id,YEAR(ISNULL(pd.term_start,mv.[deal_term_start])),MONTH(ISNULL(pd.term_start,mv.[deal_term_start]))),				
				MAX(mv.counterparty_id) counterparty_id,
				MAX(cg.contract_id) contract_id,			
				CAST(CAST(YEAR(ISNULL(pd.term_start,mv.[deal_term_start])) AS VARCHAR)+''-''+CAST(MONTH(ISNULL(pd.term_start,mv.[deal_term_start])) AS VARCHAR)+''-01'' AS DATETIME) prod_date,
				'''+CAST(@as_of_date AS VARCHAR)+''',
				SUM(ISNULL(mv.deal_volume,av.volume) * CASE WHEN mv.meter_id IS NOT NULL THEN mv.contract_allocation ELSE 1 END)  Volume,
				SUM(av.onpeak_volume  * CASE WHEN mv.meter_id IS NOT NULL THEN mv.contract_allocation ELSE 1 END) AS onPeakVolume,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19002 THEN mv.source_deal_detail_id ELSE NULL END AS source_deal_detail_id,
				(tf.formula_id),
				MAX(tf.invoice_line_item_id)invoice_line_item_id,
				MAX(tf.formula_sequence_number),
				MAX(tf.invoice_line_item_sequence_number),
				980 granularity,
				MAX(cg.volume_uom),
				MAX(generator_id),
				0 AS [Hour],
				MAX(mv.commodity_id),
				0 AS [mins],
				0 AS is_dst,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19000 THEN mv.source_deal_header_id ELSE NULL END AS source_deal_header_id,
				tf.calc_aggregation,
				SUM(fin_volume) AS fin_volume,
				SUM(av.offpeak_volume  * CASE WHEN mv.meter_id IS NOT NULL THEN mv.contract_allocation ELSE 1 END) AS offPeakVolume,
				MAX(mv.curve_tou) curve_tou,
				--SUM(CASE WHEN av.alloc_vol IS NOT NULL THEN mv.deal_volume ELSE 0 END) allocation_volume,
				--SUM(av.alloc_vol) allocation_volume,
				SUM(mv.alloc_volume  * CASE WHEN mv.meter_id IS NOT NULL THEN mv.contract_allocation ELSE 1 END) allocation_volume,
				SUM(mv.deal_settlement_amount) deal_settlement_amount,
				SUM(mv.deal_settlement_volume* ISNULL(conv.conversion_factor,1)) deal_settlement_volume,
				AVG(mv.deal_settlement_price/ISNULL(conv.conversion_factor,1)) deal_settlement_price,
				MAX(deal_type),
				MAX(mv.meter_id)meter_id,
				MAX(mv.netting_group_id),
				MAX(mv.invoice_granularity),
				MAX(mv.is_true_up),
				MAX(av.onpeakperiod_hour),MAX(av.offpeakperiod_hour),MAX(av.totalperiod_hour),MAX(av.onpeakmax_value),MAX(av.offpeakmax_value)			
			FROM
				#temp_deals mv 
				left JOIN contract_group cg ON  mv.contract_id=cg.contract_id 
 				INNER JOIN #temp_formula tf ON tf.counterparty_id=mv.counterparty_id
 					AND tf.contract_id=mv.contract_id
 					AND COALESCE(tf.deal_type_id,mv.deal_type,-1)=COALESCE(mv.deal_type,-1)
 					AND tf.granularity=980	
 					AND COALESCE(tf.timeofuse,mv.curve_tou,-1) = ISNULL(mv.curve_tou,-1) 
 					AND tf.contract_calc_type IN(''f'',''t'')	
 					AND ISNULL(mv.source_system_book_id1,-1) = COALESCE(tf.group1,mv.source_system_book_id1,-1)
 					AND ISNULL(mv.source_system_book_id2,-2) = COALESCE(tf.group2,mv.source_system_book_id2,-2)
 					AND ISNULL(mv.source_system_book_id3,-3) = COALESCE(tf.group3,mv.source_system_book_id3,-3)
 					AND ISNULL(mv.source_system_book_id4,-4) = COALESCE(tf.group4,mv.source_system_book_id4,-4)
 					AND tf.contract_calc_type <> ''c''
					AND ISNULL(mv.buy_sell, '''') = COALESCE(tf.buy_sell, mv.buy_sell,'''')
 					AND ISNULL(mv.location_id, 1) = COALESCE(tf.location_id, mv.location_id, 1)
 					AND ISNULL(mv.leg, 2) = COALESCE(tf.leg, mv.leg, 2)
 				LEFT JOIN #Proxy_term pd 
 				    ON pd.contract_id=mv.contract_id
 				    AND pd.commodity_id=mv.commodity_id
 					AND pd.proxy_term_start=mv.deal_term_start
 					AND pd.[proxy_hour]=0	
 				LEFT JOIN (SELECT counterparty_id,contract_id,YEAR(prod_date) yr_Prod_date,MONTH(prod_date) mt_Prod_date,SUM(volume) fin_volume FROM #temp_financial  GROUP BY counterparty_id,contract_id,YEAR(prod_date),MONTH(prod_date))fin
 					ON fin.counterparty_id=mv.counterparty_id
 						AND fin.contract_id=cg.contract_id
 						AND (fin.mt_Prod_date) = MONTH(ISNULL(pd.term_start,mv.[deal_term_start]))
 						AND (fin.yr_Prod_date) = YEAR(ISNULL(pd.term_start,mv.[deal_term_start]))	
 					OUTER APPLY(
						SELECT SUM(volume) volume,SUM(onpeak_volume) onpeak_volume,SUM(offpeak_volume)offpeak_volume,SUM(onpeakperiod_hour) onpeakperiod_hour,
						SUM(offpeakperiod_hour)offpeakperiod_hour,SUM(totalperiod_hour) totalperiod_hour,MAX(onpeakmax_value) onpeakmax_value,MAX(offpeakmax_value) offpeakmax_value
						FROM
							#pvt_table
						WHERE
							ISNULL(meter_id,-1)=ISNULL(mv.meter_id,-1)	
							AND CONVERT(VARCHAR(7),prod_date,120)=CONVERT(VARCHAR(7),mv.deal_term_start,120)
							AND counterparty_id = mv.counterparty_id AND contract_id=mv.contract_id AND ISNULL(source_deal_detail_id,-1)=ISNULL(mv.source_deal_detail_id,-1)
					) av	
				 LEFT JOIN rec_volume_unit_conversion conv ON conv.from_source_uom_id = mv.set_volume_uom						
						AND conv.to_source_uom_id = tf.uom_id
 			WHERE 1=1
  			GROUP BY 
				mv.counterparty_id, mv.contract_id,CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19002 THEN mv.source_deal_detail_id ELSE NULL END,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19000 THEN mv.source_deal_header_id ELSE NULL END,
				tf.invoice_line_item_id,tf.formula_id,
				YEAR(ISNULL(pd.term_start,mv.[deal_term_start])),MONTH(ISNULL(pd.term_start,mv.[deal_term_start])),tf.calc_aggregation	
		
		
		CREATE  INDEX [IX_temp_month1] ON  '+@formula_table+'([contract_id])                    
		CREATE  INDEX [IX_temp_month2] ON  '+@formula_table+'(counterparty_id)                    
		CREATE  INDEX [IX_temp_month3] ON  '+@formula_table+'(prod_date)  '                  
		
	 --PRINT @sqlstmt 	
	 EXEC(@sqlstmt)
		
	END


-- select * from #temp_deals where source_deal_header_id=158163


	--print 'Monthly table populated'+': '+cast(datediff(ss,@calc_time,getdate()) as varchar) +'*************************************'
	set @calc_time=getdate()
----**********************************
--Populate the Daily temporary table
----**********************************
	IF (SELECT MAX('X') FROM #temp_formula WHERE granularity=981)='X'
	BEGIN	
			SET @sqlstmt='
				INSERT INTO '+@formula_table+'(rowid,counterparty_id,contract_id,prod_date,as_of_date,volume,onPeakVolume,source_deal_detail_id,formula_id,invoice_Line_item_id,invoice_line_item_seq_id,price,granularity,volume_uom_id,generator_id,[Hour],commodity_id,[mins],is_dst,source_deal_header_id,calc_aggregation,fin_volume,offPeakVolume,curve_tou,allocation_volume,deal_settlement_amount,deal_settlement_volume,deal_settlement_price,deal_type,meter_id,netting_group_id,invoice_granularity,is_true_up,onpeakperiod_hour,offpeakperiod_hour,totalperiod_hour,onpeakmax_value,offpeakmax_value)
				SELECT
				DENSE_RANK() OVER(ORDER BY mv.counterparty_id,mv.contract_id,tf.invoice_line_item_id,tf.formula_id,dbo.FNAGetContractMonth(ISNULL(pd.term_start,mv.[prod_date]))), 
				MAX(mv.counterparty_id) counterparty_id,
				MAX(cg.contract_id) contract_id,
				ISNULL(pd.term_start,mv.[prod_date]) prod_date,
				'''+CAST(@as_of_date AS VARCHAR)+''',
				SUM(mv.Volume  * CASE WHEN mv.meter_id IS NOT NULL THEN mv.contract_allocation ELSE 1 END)  Volume,
				SUM(av.onpeak_volume * CASE WHEN mv.meter_id IS NOT NULL THEN mv.contract_allocation ELSE 1 END) AS onPeakVolume,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19002 THEN mv.source_deal_detail_id ELSE NULL END  AS source_deal_detail_id,
				(tf.formula_id),
				MAX(tf.invoice_line_item_id),
				MAX(tf.formula_sequence_number),
				MAX(tf.invoice_line_item_sequence_number),
				981 granularity,
				MAX(cg.volume_uom),
				MAX(generator_id),
				0 AS [Hour],
				MAX(mv.commodity_id),
				0 AS [mins],
				0 AS is_dst,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19000 THEN mv.source_deal_header_id ELSE NULL END source_deal_header_id,
				tf.calc_aggregation,
				0 AS fin_volume,
				SUM(av.offpeak_volume * CASE WHEN mv.meter_id IS NOT NULL THEN mv.contract_allocation ELSE 1 END) AS offPeakVolume,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19002 THEN mv.curve_tou ELSE NULL END,
				SUM(CASE WHEN mv.allocation_vol=1 THEN 	mv.Volume ELSE 0 END * CASE WHEN mv.meter_id IS NOT NULL THEN mv.contract_allocation ELSE 1 END) allocation_volume,
				SUM(mv.deal_settlement_amount) deal_settlement_amount,
				SUM(mv.deal_settlement_volume) deal_settlement_volume,
				MAX(mv.deal_settlement_price) deal_settlement_price,
				MAX(deal_type),			
				MAX(mv.meter_id)meter_id,
				MAX(mv.netting_group_id),
				MAX(mv.invoice_granularity),
				MAX(mv.is_true_up),
				SUM(av.onpeakperiod_hour),SUM(av.offpeakperiod_hour),SUM(av.totalperiod_hour),MAX(av.onpeakmax_value),MAX(av.offpeakmax_value)		
			FROM
				#pvt_table mv 
				left JOIN contract_group cg ON  mv.contract_id=cg.contract_id 
 				INNER JOIN #temp_formula tf ON tf.counterparty_id=mv.counterparty_id
 					AND tf.contract_id=mv.contract_id
 					AND COALESCE(tf.deal_type_id,mv.deal_type,-1)=ISNULL(mv.deal_type,-1)
 					AND tf.granularity=981
 					AND COALESCE(tf.timeofuse,mv.curve_tou,-1) = ISNULL(mv.curve_tou,-1) 
 					AND ISNULL(mv.source_system_book_id1,-1) = COALESCE(tf.group1,mv.source_system_book_id1,-1)
 					AND ISNULL(mv.source_system_book_id2,-2) = COALESCE(tf.group2,mv.source_system_book_id2,-2)
 					AND ISNULL(mv.source_system_book_id3,-3) = COALESCE(tf.group3,mv.source_system_book_id3,-3)
 					AND ISNULL(mv.source_system_book_id4,-4) = COALESCE(tf.group4,mv.source_system_book_id4,-4) 	
 					AND tf.contract_calc_type <> ''c''
 					AND ISNULL(mv.buy_sell, '''') = COALESCE(tf.buy_sell, mv.buy_sell,'''')
 					AND ISNULL(mv.location_id, 1) = COALESCE(tf.location_id, mv.location_id, 1)
 					AND ISNULL(mv.leg, 2) = COALESCE(tf.leg, mv.leg, 2)
				LEFT JOIN hour_block_term hb ON ISNULL(cg.hourly_block,291890)=hb.block_define_id AND ISNULL(cg.block_type,12000)=hb.block_type AND mv.[prod_date]=hb.term_date
					AND hb.dst_group_value_id = tf.dst_group_value_id
 				LEFT JOIN #Proxy_term pd 
 				    ON pd.contract_id=mv.contract_id
 				    AND pd.commodity_id=mv.commodity_id
 					AND pd.proxy_term_start=mv.prod_date
 					AND pd.[proxy_hour]=mv.[hour]
				OUTER APPLY(SELECT SUM(volume) volume,SUM(onpeak_volume) onpeak_volume,sum(offpeak_volume) offpeak_volume,SUM(onpeakperiod_hour) onpeakperiod_hour,
						SUM(offpeakperiod_hour) offpeakperiod_hour,SUM(totalperiod_hour) totalperiod_hour,SUM(onpeakmax_value) onpeakmax_value,SUM(offpeakmax_value) offpeakmax_value
						FROM
							#pvt_table
						WHERE
							ISNULL(meter_id,-1)=ISNULL(mv.meter_id,-1)	
							AND CONVERT(VARCHAR(7),prod_date,120)=CONVERT(VARCHAR(7),mv.deal_term_start,120)
							AND counterparty_id = mv.counterparty_id AND contract_id=mv.contract_id 
							AND ISNULL(source_deal_detail_id,-1)=ISNULL(mv.source_deal_detail_id,-1)	
					) av		
 			WHERE 1=1
 				  AND mv.is_dst=0	
		GROUP BY 
				mv.counterparty_id, mv.contract_id,CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19002 THEN mv.source_deal_detail_id ELSE NULL END,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19000 THEN mv.source_deal_header_id ELSE NULL END,
				ISNULL(pd.term_start,mv.[prod_date]),tf.formula_id,dbo.FNAGetContractMonth(ISNULL(pd.term_start,mv.[prod_date])),tf.invoice_line_item_id,tf.calc_aggregation,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19002 THEN mv.curve_tou ELSE NULL END	'
		
		--PRINT @sqlstmt
		EXEC(@sqlstmt)		
		
	END
	--print 'Daily table populated'+': '+cast(datediff(ss,@calc_time,getdate()) as varchar) +'*************************************'
	

IF (SELECT MAX('X') FROM #temp_formula WHERE granularity IN(982,994,995))='X'
	BEGIN	
		
		
		SELECT meter_id,CONVERT(VARCHAR(7),prod_date,120) prod_date,counterparty_id,contract_id,source_deal_detail_id,SUM(volume) volume,SUM(onpeak_volume) onpeak_volume,
						sum(offpeak_volume) offpeak_volume,SUM(onpeakperiod_hour) onpeakperiod_hour,
						SUM(offpeakperiod_hour) offpeakperiod_hour,SUM(totalperiod_hour) totalperiod_hour,MAX(onpeakmax_value) onpeakmax_value,
						MAX(offpeakmax_value) offpeakmax_value 
		INTO #pvt_hour_sum
		FROM #pvt_table
		GROUP BY 
				meter_id,CONVERT(VARCHAR(7),prod_date,120),counterparty_id,contract_id,source_deal_detail_id


			SET @sqlstmt='
				INSERT INTO '+@formula_table+'(rowid,counterparty_id,contract_id,prod_date,as_of_date,volume,onPeakVolume,source_deal_detail_id,formula_id,invoice_Line_item_id,invoice_line_item_seq_id,price,granularity,volume_uom_id,generator_id,[Hour],commodity_id,[mins],is_dst,source_deal_header_id,calc_aggregation,fin_volume,offPeakVolume,curve_tou,allocation_volume,deal_settlement_amount,deal_settlement_volume,deal_settlement_price,deal_type,meter_id,netting_group_id,invoice_granularity,is_true_up,onpeakperiod_hour,offpeakperiod_hour,totalperiod_hour,onpeakmax_value,offpeakmax_value)
				SELECT
				DENSE_RANK() OVER(ORDER BY mv.counterparty_id,mv.contract_id,tf.invoice_line_item_id,tf.formula_id,dbo.FNAGetContractMonth(ISNULL(pd.term_start,mv.[prod_date]))), 
				MAX(mv.counterparty_id) counterparty_id,
				MAX(cg.contract_id) contract_id,
				ISNULL(pd.term_start,mv.[prod_date]) prod_date,
				'''+CAST(@as_of_date AS VARCHAR)+''',
				SUM(mv.Volume * CASE WHEN mv.meter_id IS NOT NULL THEN mv.contract_allocation ELSE 1 END)  Volume,
				SUM(mv.onpeak_volume) AS onPeakVolume,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19002 THEN mv.source_deal_detail_id ELSE NULL END  AS source_deal_detail_id,
				(tf.formula_id),
				MAX(tf.invoice_line_item_id),
				MAX(tf.formula_sequence_number),
				MAX(tf.invoice_line_item_sequence_number),
				MAX(ISNULL(tf.granularity,982)) granularity,
				MAX(cg.volume_uom),
				MAX(generator_id),
				ISNULL(pd.hour,mv.hour) AS [Hour],
				MAX(mv.commodity_id),
				ISNULL(mv.period,0) AS [mins],
				mv.is_dst,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19000 THEN mv.source_deal_header_id ELSE NULL END source_deal_header_id,
				tf.calc_aggregation,
				MAX(fin.Volume) AS fin_volume,
				SUM(mv.offpeak_volume * CASE WHEN mv.meter_id IS NOT NULL THEN mv.contract_allocation ELSE 1 END) AS offPeakVolume,
				MAX(mv.onpeakperiod_hour) onpeakperiod_hour,
				SUM(CASE WHEN mv.allocation_vol=1 THEN 	mv.Volume ELSE 0 END * CASE WHEN mv.meter_id IS NOT NULL THEN mv.contract_allocation ELSE 1 END) allocation_volume,
				MAX(mv.deal_settlement_amount) deal_settlement_amount,
				MAX(mv.deal_settlement_volume) deal_settlement_volume,
				MAX(mv.deal_settlement_price) deal_settlement_price,
				MAX(deal_type),
				MAX(mv.meter_id)meter_id,
				MAX(netting_group_id),
				MAX(mv.invoice_granularity),
				MAX(mv.is_true_up),
				SUM(av.onpeakperiod_hour),SUM(av.offpeakperiod_hour),SUM(av.totalperiod_hour),SUM(av.onpeakmax_value),SUM(av.offpeakmax_value)				
			FROM
				#pvt_table mv 
				INNER JOIN contract_group cg ON  mv.contract_id=cg.contract_id 
 				INNER JOIN #temp_formula tf ON tf.counterparty_id=mv.counterparty_id
 					AND tf.contract_id=mv.contract_id
 					AND COALESCE(tf.deal_type_id,mv.deal_type,-1)=COALESCE(mv.deal_type,-1)
 					AND COALESCE(tf.timeofuse,mv.curve_tou,-1) = ISNULL(mv.curve_tou,-1) 
 					AND ISNULL(mv.source_system_book_id1,-1) = COALESCE(tf.group1,mv.source_system_book_id1,-1)
 					AND ISNULL(mv.source_system_book_id2,-2) = COALESCE(tf.group2,mv.source_system_book_id2,-2)
 					AND ISNULL(mv.source_system_book_id3,-3) = COALESCE(tf.group3,mv.source_system_book_id3,-3)
 					AND ISNULL(mv.source_system_book_id4,-4) = COALESCE(tf.group4,mv.source_system_book_id4,-4)
 					AND COALESCE(tf.leg,mv.leg,-1)=COALESCE(mv.leg,-1)	 	
 					AND tf.contract_calc_type <> ''c''
 					AND ISNULL(mv.buy_sell, '''') = COALESCE(tf.buy_sell, mv.buy_sell,'''')
 					AND ISNULL(mv.location_id, 1) = COALESCE(tf.location_id, mv.location_id, 1)
 					AND ISNULL(mv.leg, 2) = COALESCE(tf.leg, mv.leg, 2)
				LEFT JOIN hour_block_term hb ON ISNULL(cg.hourly_block,291890)=hb.block_define_id AND ISNULL(cg.block_type,12000)=hb.block_type AND mv.[prod_date]=hb.term_date
					AND hb.dst_group_value_id = tf.dst_group_value_id 
 				LEFT JOIN #Proxy_term pd 
 				    ON pd.contract_id=mv.contract_id
 				    AND pd.commodity_id=mv.commodity_id
 					AND pd.proxy_term_start=mv.prod_date
 					AND pd.[proxy_hour]=mv.[hour]
 				LEFT JOIN #temp_financial fin
 					ON fin.counterparty_id=mv.counterparty_id
 						AND fin.contract_id=cg.contract_id
 						AND fin.prod_date = ISNULL(pd.term_start,mv.[prod_date])
 							AND fin.[hour] = ISNULL(pd.hour,mv.hour)
				LEFT JOIN #pvt_hour_sum av
							ON ISNULL(av.meter_id,-1)=ISNULL(mv.meter_id,-1)	
							AND CONVERT(VARCHAR(7),av.prod_date,120)=CONVERT(VARCHAR(7),mv.deal_term_start,120)
							AND av.counterparty_id = mv.counterparty_id AND av.contract_id=mv.contract_id 
							AND ISNULL(av.source_deal_detail_id,-1)=ISNULL(mv.source_deal_detail_id,-1)			
 			WHERE
 				tf.granularity IN(982,994,995)
		GROUP BY 
				mv.period,mv.counterparty_id, mv.contract_id,CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19002 THEN mv.source_deal_detail_id ELSE NULL END,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19000 THEN mv.source_deal_header_id ELSE NULL END,
				ISNULL(pd.term_start,mv.[prod_date]),ISNULL(pd.hour,mv.hour),
				tf.formula_id,dbo.FNAGetContractMonth(ISNULL(pd.term_start,mv.[prod_date])),tf.invoice_line_item_id,mv.is_dst,tf.calc_aggregation,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19002 THEN mv.curve_tou ELSE NULL END	'
		--PRINT @sqlstmt
		EXEC(@sqlstmt)	

	END
	
	--print 'Hourly table populated'+': '+cast(datediff(ss,@calc_time,getdate()) as varchar) +'*************************************'
	set @calc_time=getdate()

	IF (SELECT MAX('X') FROM #temp_formula WHERE granularity=987)='X' -- 15 minutes
		BEGIN	

	CREATE TABLE #15minutes_temp(counterparty_id INT,contract_id INT,prod_date DATETIME,[Hour] INT,[org_Hour] INT,volume FLOAT, data_missing CHAR(1) COLLATE DATABASE_DEFAULT,source_deal_detail_id INT,
		deal_term_start DATETIME,deal_formula_id INT, location_id INT,generator_id INT,commodity_id INT, [mins] INT, is_dst INT, source_deal_header_id INT, deal_type INT,meter_id INT, netting_group_id INT, invoice_granularity INT,is_true_up CHAR(1) COLLATE DATABASE_DEFAULT)  
		
	SET @Pivot_table=
		'
		INSERT INTO #15minutes_temp
		SELECT 
			td.counterparty_id,
			td.contract_id,
			ISNULL(a.prod_date,td.deal_term_start) prod_date,
			substring(REPLACE(REPLACE(a.[Hour],''25'',''3''),''hr'',''''),0,charindex(''_'',REPLACE(REPLACE(a.[Hour],''25'',''3''),''hr'',''''))) [Hour],
			substring(REPLACE(a.[Hour],''hr'',''''),0,charindex(''_'',REPLACE(a.[Hour],''hr'',''''))) [org_Hour],
			COALESCE(a.[volume],td.deal_volume,0)-CASE WHEN a.[Hour]=''HR3_15'' THEN ISNULL(dst_volume15,0) WHEN a.[Hour]=''HR3_30'' THEN ISNULL(dst_volume30,0) WHEN a.[Hour]=''HR3_45'' THEN ISNULL(dst_volume45,0) WHEN a.[Hour]=''HR3_60'' THEN ISNULL(dst_volume60,0) ELSE 0 END volume,
			a.data_missing,
			td.source_deal_detail_id,
			td.deal_term_start,
			td.deal_formula_id,
			td.location_id,
			td.generator_id,
			td.commodity_id,
			RIGHT(a.[Hour],2) [mins],
			CASE WHEN a.[Hour] LIKE ''%HR25%'' AND mv_dst.[id] IS NOT NULL THEN 1 ELSE 0 END is_dst,
			td.source_deal_header_id,
			td.deal_type,
			td.meter_id,
			td.netting_group_id,
			td.invoice_granularity,
			td.is_true_up
		 FROM
			#temp_deals td
			INNER JOIN
			(SELECT td.counterparty_id,td.contract_id,mvh.prod_date,''n'' AS data_missing,td.source_deal_detail_id,
				td.deal_term_start,td.deal_formula_id,td.location_id,td.generator_id,td.commodity_id,
						HR25_15*ISNULL(conv.conversion_factor,1)*contract_allocation dst_volume15,
						HR25_30*ISNULL(conv.conversion_factor,1)*contract_allocation dst_volume30,
						HR25_45*ISNULL(conv.conversion_factor,1)*contract_allocation dst_volume45,
						HR25_60*ISNULL(conv.conversion_factor,1)*contract_allocation dst_volume60,
						mvh.HR1_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR1_15,mvh.HR1_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR1_30,mvh.HR1_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR1_45,mvh.HR1_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR1_60,
						mvh.HR2_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR2_15,mvh.HR2_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR2_30,mvh.HR2_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR2_45,mvh.HR2_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR2_60,
						mvh.HR3_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR3_15,mvh.HR3_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR3_30,mvh.HR3_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR3_45,mvh.HR3_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR3_60,
						mvh.HR4_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR4_15,mvh.HR4_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR4_30,mvh.HR4_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR4_45,mvh.HR4_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR4_60,
						mvh.HR5_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR5_15,mvh.HR5_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR5_30,mvh.HR5_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR5_45,mvh.HR5_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR5_60,
						mvh.HR6_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR6_15,mvh.HR6_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR6_30,mvh.HR6_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR6_45,mvh.HR6_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR6_60,
						mvh.HR7_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR7_15,mvh.HR7_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR7_30,mvh.HR7_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR7_45,mvh.HR7_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR7_60,
						mvh.HR8_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR8_15,mvh.HR8_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR8_30,mvh.HR8_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR8_45,mvh.HR8_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR8_60,
						mvh.HR9_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR9_15,mvh.HR9_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR9_30,mvh.HR9_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR9_45,mvh.HR9_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR9_60,
						mvh.HR10_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR10_15,mvh.HR10_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR10_30,mvh.HR10_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR10_45,mvh.HR10_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR10_60,
						mvh.HR11_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR11_15,mvh.HR11_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR11_30,mvh.HR11_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR11_45,mvh.HR11_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR11_60,
						mvh.HR12_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR12_15,mvh.HR12_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR12_30,mvh.HR12_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR12_45,mvh.HR12_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR12_60,
						mvh.HR13_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR13_15,mvh.HR13_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR13_30,mvh.HR13_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR13_45,mvh.HR13_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR13_60,
						mvh.HR14_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR14_15,mvh.HR14_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR14_30,mvh.HR14_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR14_45,mvh.HR14_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR14_60,
						mvh.HR15_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR15_15,mvh.HR15_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR15_30,mvh.HR15_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR15_45,mvh.HR15_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR15_60,
						mvh.HR16_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR16_15,mvh.HR16_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR16_30,mvh.HR16_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR16_45,mvh.HR16_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR16_60,
						mvh.HR17_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR17_15,mvh.HR17_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR17_30,mvh.HR17_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR17_45,mvh.HR17_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR17_60,
						mvh.HR18_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR18_15,mvh.HR18_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR18_30,mvh.HR18_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR18_45,mvh.HR18_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR18_60,
						mvh.HR19_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR19_15,mvh.HR19_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR19_30,mvh.HR19_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR19_45,mvh.HR19_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR19_60,
						mvh.HR20_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR20_15,mvh.HR20_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR20_30,mvh.HR20_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR20_45,mvh.HR20_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR20_60,
						mvh.HR21_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR21_15,mvh.HR21_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR21_30,mvh.HR21_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR21_45,mvh.HR21_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR21_60,
						mvh.HR22_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR22_15,mvh.HR22_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR22_30,mvh.HR22_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR22_45,mvh.HR22_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR22_60,
						mvh.HR23_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR23_15,mvh.HR23_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR23_30,mvh.HR23_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR23_45,mvh.HR23_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR23_60,
						mvh.HR24_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR24_15,mvh.HR24_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR24_30,mvh.HR24_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR24_45,mvh.HR24_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR24_60,
						mvh.HR25_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR25_15,mvh.HR25_30 *ISNULL(conv.conversion_factor,1)*contract_allocation HR25_30,mvh.HR25_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR25_45,mvh.HR25_60 *ISNULL(conv.conversion_factor,1)*contract_allocation HR25_60
				FROM
					#temp_deals td
					INNER JOIN mv90_data mv ON mv.meter_id=td.meter_id --AND mv.from_date=td.deal_term_start 
					INNER JOIN  mv90_data_mins mvh ON mv.meter_data_id=mvh.meter_data_id
					INNER JOIN #ContractBillingDate cb ON cb.contract_id=td.contract_id AND mvh.prod_date between cb.udf_from_date AND cb.udf_to_date
					INNER JOIN recorder_properties rp ON rp.meter_id=mv.meter_id and rp.channel=mv.channel
					LEFT JOIN rec_volume_unit_conversion conv ON rp.uom_id=conv.FROM_source_uom_id AND conv.to_source_uom_id=td.uom_id  
							AND conv.state_value_id is null AND conv.assignment_type_value_id is null AND conv.curve_id is null   
				WHERE
					mvh.prod_date between cb.udf_from_date AND cb.udf_to_date		
			) P
			UNPIVOT
				([Volume] FOR [Hour] IN(Hr1_15, Hr1_30, Hr1_45, Hr1_60,Hr2_15, Hr2_30, Hr2_45, Hr2_60,Hr3_15, Hr3_30, Hr3_45, Hr3_60,Hr4_15, Hr4_30, Hr4_45, Hr4_60,
							Hr5_15, Hr5_30, Hr5_45, Hr5_60,Hr6_15, Hr6_30, Hr6_45, Hr6_60,Hr7_15, Hr7_30, Hr7_45, Hr7_60,Hr8_15, Hr8_30, Hr8_45, Hr8_60,Hr9_15, Hr9_30, Hr9_45, Hr9_60,
							Hr10_15, Hr10_30, Hr10_45, Hr10_60,	Hr11_15, Hr11_30, Hr11_45, Hr11_60,Hr12_15, Hr12_30, Hr12_45, Hr12_60,Hr13_15, Hr13_30, Hr13_45, Hr13_60,Hr14_15, Hr14_30, Hr14_45, Hr14_60,
							Hr15_15, Hr15_30, Hr15_45, Hr15_60,Hr16_15, Hr16_30, Hr16_45, Hr16_60,Hr17_15, Hr17_30, Hr17_45, Hr17_60,Hr18_15, Hr18_30, Hr18_45, Hr18_60,Hr19_15, Hr19_30, Hr19_45, Hr19_60,
							Hr20_15, Hr20_30, Hr20_45, Hr20_60,Hr21_15, Hr21_30, Hr21_45, Hr21_60,Hr22_15, Hr22_30, Hr22_45, Hr22_60,Hr23_15, Hr23_30, Hr23_45, Hr23_60,Hr24_15, Hr24_30, Hr24_45, Hr24_60,Hr25_15, Hr25_30, Hr25_45, Hr25_60))a		
			ON ISNULL(td.source_deal_detail_id,-1)=ISNULL(a.source_deal_detail_id,-1)
			INNER JOIN #ContractBillingDate cb ON cb.contract_id=td.contract_id 
				AND CAST(CONVERT(VARCHAR(10),ISNULL(prod_date,td.deal_term_start),120)+'' ''+ISNULL(CAST(CAST(substring(REPLACE(REPLACE(a.[Hour],''25'',''3''),''hr'',''''),0,charindex(''_'',REPLACE(REPLACE(a.[Hour],''25'',''3''),''hr'',''''))) AS INT)-1 AS VARCHAR),''00'')+'':00:00:000'' AS DATETIME) between cb.udf_from_date_hour AND cb.udf_to_date_hour 
			LEFT JOIN mv90_dst mv_dst ON mv_dst.[Date]=	ISNULL(a.prod_date,td.deal_term_start)
					AND mv_dst.insert_delete=''i''
					AND mv_dst.dst_group_value_id = td.dst_group_value_id
					AND substring(REPLACE(a.[Hour],''hr'',''''),0,charindex(''_'',REPLACE(a.[Hour],''hr'','''')))=25		
				'			
			EXEC(@Pivot_table)
			
			IF NOT EXISTS(SELECT 'X' FROM #15minutes_temp)
			BEGIN
				
				;With mycte
				AS ( SELECT 1 as Time_ID, CAST(CONVERT(VARCHAR(10),udf_from_date,120)+' '+RIGHT(CONVERT(VARCHAR(16),DATEADD(day, DATEDIFF(day,0,udf_from_date),0),120),5)+':00.000' AS DATETIME)  as term_date,udf_to_date,0 is_dst FROM #ContractBillingDate
					UNION ALL
					SELECT Time_ID+1 ,CAST(CONVERT(VARCHAR(16),DATEADD(minute, 15,term_date) ,120) AS DATETIME),udf_to_date,0 is_dst
					FROM mycte
					WHERE CAST(term_date AS DATETIME) < CAST(CONVERT(VARCHAR(10),udf_to_date,120)+' '+'23:45:00.000' AS DATETIME)
				)
				SELECT * INTO #CTE1 FROM mycte OPTION (MAXRECURSION 5000)	
				
				INSERT INTO #CTE1(term_date,udf_to_date,is_dst)
				SELECT cte.term_date,udf_to_date,1 FROM #CTE1 cte CROSS JOIN 
				(
					select var_value default_timezone_id from dbo.adiha_default_codes_values (nolock) WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
				) df  
				INNER join dbo.time_zones tz (nolock) ON tz.timezone_id = df.default_timezone_id
				INNER JOIN mv90_DST mv_dst ON CONVERT(VARCHAR(10),cte.term_date,120) = mv_dst.date 
					AND datepart(hh,term_date)= mv_dst.hour-1
					AND tz.dst_group_value_id = mv_dst.dst_group_value_id
				
				
			
			SET @Pivot_table=
				'INSERT INTO #15minutes_temp
				 SELECT 
					td.counterparty_id,
					td.contract_id,
					ISNULL(CONVERT(VARCHAR(10),cte.term_date,120),td.deal_term_start) prod_date,
					DATEPART(hour,cte.term_date)+1 [Hour],
					CASE WHEN cte.is_dst =1 THEN 25 ELSE DATEPART(hour,cte.term_date)+1 END [org_Hour],
					0 volume,
					''n'' data_missing,
					td.source_deal_detail_id,
					td.deal_term_start,
					td.deal_formula_id,
					td.location_id,
					td.generator_id,
					td.commodity_id,
					DATEPART(Mi,cte.term_date)+15 [mins],
					cte.is_dst is_dst,
					td.source_deal_header_id,
					td.deal_type,
					td.meter_id,
					td.netting_group_id,
					td.invoice_granularity,
					td.is_true_up
				 FROM
					#temp_deals td
					INNER JOIN #ContractBillingDate cb ON cb.contract_id=td.contract_id 
					INNER JOIN #CTE1 cte ON CONVERT(VARCHAR(10),cte.term_date,120) between cb.udf_from_date AND cb.udf_to_date '	
									
				EXEC(@Pivot_table)			
			END

			SET @sqlstmt='
				INSERT INTO '+@formula_table+'(rowid,counterparty_id,contract_id,prod_date,as_of_date,volume,onPeakVolume,source_deal_detail_id,formula_id,invoice_Line_item_id,invoice_line_item_seq_id,price,granularity,volume_uom_id,generator_id,[Hour],commodity_id,[mins],is_dst,source_deal_header_id,calc_aggregation,meter_id,netting_group_id,invoice_granularity,is_true_up)
				SELECT
				DENSE_RANK() OVER(ORDER BY mv.counterparty_id,mv.contract_id,tf.invoice_line_item_id,tf.formula_id,dbo.FNAGetContractMonth(ISNULL(pd.term_start,mv.[prod_date]))), 
				MAX(mv.counterparty_id) counterparty_id,
				MAX(cg.contract_id) contract_id,
				ISNULL(pd.term_start,mv.[prod_date]) prod_date,
				'''+CAST(@as_of_date AS VARCHAR)+''',
				MAX(mv.Volume)  Volume,
				0 AS onPeakVolume,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19002 THEN mv.source_deal_detail_id ELSE NULL END  AS source_deal_detail_id,
				(tf.formula_id),
				MAX(tf.invoice_line_item_id),
				MAX(tf.formula_sequence_number),
				MAX(tf.invoice_line_item_sequence_number),
				987 granularity,
				MAX(cg.volume_uom),
				MAX(generator_id),
				ISNULL(pd.hour,mv.[Hour])  AS [Hour],
				MAX(mv.commodity_id),
				mv.[mins] AS [mins],
				mv.is_dst,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19000 THEN mv.source_deal_header_id ELSE NULL END source_deal_header_id,
				tf.calc_aggregation,
				mv.meter_id,
				MAX(mv.netting_group_id),
				MAX(mv.invoice_granularity),
				MAX(mv.is_true_up)
			FROM
				'
			SET @sqlstmt1 = ' #15minutes_temp  mv
				left JOIN contract_group cg ON  mv.contract_id=cg.contract_id 
 				INNER JOIN #temp_formula tf ON tf.counterparty_id=mv.counterparty_id
 					AND tf.contract_id=mv.contract_id
 					AND COALESCE(tf.deal_type_id,mv.deal_type,-1)=ISNULL(mv.deal_type,-1)
 					AND tf.granularity=987
 					AND tf.contract_calc_type <> ''c''
				LEFT JOIN hour_block_term hb ON ISNULL(cg.hourly_block,291890)=hb.block_define_id AND ISNULL(cg.block_type,12000)=hb.block_type AND mv.[prod_date]=hb.term_date
 					AND hb.dst_group_value_id = tf.dst_group_value_id
				LEFT JOIN #Proxy_term pd 
 				    ON pd.contract_id=mv.contract_id
 				    AND pd.commodity_id=mv.commodity_id
 					AND pd.proxy_term_start=mv.prod_date
 					AND pd.[proxy_hour]=mv.[Hour]
		WHERE
			((mv.[org_Hour]=25 AND mv.is_dst=1) OR (mv.is_dst=0 AND mv.[org_Hour]<>25))
								
		GROUP BY 
				meter_id,mv.counterparty_id, mv.contract_id,CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19002 THEN mv.source_deal_detail_id ELSE NULL END,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19000 THEN mv.source_deal_header_id ELSE NULL END,
				ISNULL(pd.term_start,mv.[prod_date]),ISNULL(pd.hour,mv.hour),
					tf.formula_id,dbo.FNAGetContractMonth(ISNULL(pd.term_start,mv.[prod_date])),tf.invoice_line_item_id,mv.[mins],mv.is_dst,tf.calc_aggregation'
		
		--PRINT @sqlstmt
		--PRINT @sqlstmt1
		EXEC(@sqlstmt+@sqlstmt1)		
		
	END

	set @calc_time=getdate()

	IF (SELECT MAX('X') FROM #temp_formula WHERE granularity=989)='X' -- 30 minutes
		BEGIN	

	CREATE TABLE #30minutes_temp(counterparty_id INT,contract_id INT,prod_date DATETIME,[Hour] INT,[org_Hour] INT,volume FLOAT, data_missing CHAR(1) COLLATE DATABASE_DEFAULT,source_deal_detail_id INT,
		deal_term_start DATETIME,deal_formula_id INT, location_id INT,generator_id INT,commodity_id INT, [mins] INT, is_dst INT, source_deal_header_id INT, deal_type INT,meter_id INT, netting_group_id INT, invoice_granularity INT,is_true_up CHAR(1) COLLATE DATABASE_DEFAULT)  
		
	SET @Pivot_table=
		'
		INSERT INTO #30minutes_temp
		SELECT 
			td.counterparty_id,
			td.contract_id,
			ISNULL(a.prod_date,td.deal_term_start) prod_date,
			substring(REPLACE(REPLACE(a.[Hour],''25'',''3''),''hr'',''''),0,charindex(''_'',REPLACE(REPLACE(a.[Hour],''25'',''3''),''hr'',''''))) [Hour],
			substring(REPLACE(a.[Hour],''hr'',''''),0,charindex(''_'',REPLACE(a.[Hour],''hr'',''''))) [org_Hour],
			COALESCE(a.[volume],td.deal_volume,0)-CASE WHEN a.[Hour]=''HR3_15'' THEN ISNULL(dst_volume15,0) WHEN a.[Hour]=''HR3_45'' THEN ISNULL(dst_volume45,0) ELSE 0 END volume,
			a.data_missing,
			td.source_deal_detail_id,
			td.deal_term_start,
			td.deal_formula_id,
			td.location_id,
			td.generator_id,
			td.commodity_id,
			RIGHT(a.[Hour],2) [mins],
			CASE WHEN a.[Hour] LIKE ''%HR25%'' AND mv_dst.[id] IS NOT NULL THEN 1 ELSE 0 END is_dst,
			td.source_deal_header_id,
			td.deal_type,
			td.meter_id,
			td.netting_group_id,
			td.invoice_granularity,
			td.is_true_up
		 FROM
			#temp_deals td
			INNER JOIN
			(SELECT td.counterparty_id,td.contract_id,mvh.prod_date,''n'' AS data_missing,td.source_deal_detail_id,
				td.deal_term_start,td.deal_formula_id,td.location_id,td.generator_id,td.commodity_id,
						HR25_15*ISNULL(conv.conversion_factor,1)*contract_allocation dst_volume15,
						HR25_45*ISNULL(conv.conversion_factor,1)*contract_allocation dst_volume45,
						mvh.HR1_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR1_15,mvh.HR1_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR1_45,
						mvh.HR2_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR2_15,mvh.HR2_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR2_45,
						mvh.HR3_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR3_15,mvh.HR3_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR3_45,
						mvh.HR4_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR4_15,mvh.HR4_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR4_45,
						mvh.HR5_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR5_15,mvh.HR5_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR5_45,
						mvh.HR6_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR6_15,mvh.HR6_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR6_45,
						mvh.HR7_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR7_15,mvh.HR7_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR7_45,
						mvh.HR8_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR8_15,mvh.HR8_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR8_45,
						mvh.HR9_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR9_15,mvh.HR9_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR9_45,
						mvh.HR10_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR10_15,mvh.HR10_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR10_45,
						mvh.HR11_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR11_15,mvh.HR11_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR11_45,
						mvh.HR12_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR12_15,mvh.HR12_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR12_45,
						mvh.HR13_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR13_15,mvh.HR13_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR13_45,
						mvh.HR14_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR14_15,mvh.HR14_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR14_45,
						mvh.HR15_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR15_15,mvh.HR15_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR15_45,
						mvh.HR16_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR16_15,mvh.HR16_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR16_45,
						mvh.HR17_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR17_15,mvh.HR17_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR17_45,
						mvh.HR18_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR18_15,mvh.HR18_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR18_45,
						mvh.HR19_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR19_15,mvh.HR19_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR19_45,
						mvh.HR20_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR20_15,mvh.HR20_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR20_45,
						mvh.HR21_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR21_15,mvh.HR21_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR21_45,
						mvh.HR22_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR22_15,mvh.HR22_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR22_45,
						mvh.HR23_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR23_15,mvh.HR23_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR23_45,
						mvh.HR24_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR24_15,mvh.HR24_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR24_45,
						mvh.HR25_15 *ISNULL(conv.conversion_factor,1)*contract_allocation HR25_15,mvh.HR25_45 *ISNULL(conv.conversion_factor,1)*contract_allocation HR25_45
				FROM
					#temp_deals td
					INNER JOIN mv90_data mv ON mv.meter_id=td.meter_id --AND mv.from_date=td.deal_term_start 
					INNER JOIN  mv90_data_mins mvh ON mv.meter_data_id=mvh.meter_data_id
					INNER JOIN #ContractBillingDate cb ON cb.contract_id=td.contract_id AND mvh.prod_date between cb.udf_from_date AND cb.udf_to_date
					INNER JOIN recorder_properties rp ON rp.meter_id=mv.meter_id and rp.channel=mv.channel
					LEFT JOIN rec_volume_unit_conversion conv ON rp.uom_id=conv.FROM_source_uom_id AND conv.to_source_uom_id=td.uom_id  
							AND conv.state_value_id is null AND conv.assignment_type_value_id is null AND conv.curve_id is null   
				WHERE
					mvh.prod_date between cb.udf_from_date AND cb.udf_to_date		
			) P
			UNPIVOT
				([Volume] FOR [Hour] IN(Hr1_15,  Hr1_45, Hr2_15,  Hr2_45, Hr3_15, Hr3_45, Hr4_15, Hr4_45, 
							Hr5_15,  Hr5_45, Hr6_15,  Hr6_45, Hr7_15,  Hr7_45, Hr8_15,  Hr8_45, Hr9_15,  Hr9_45, 
							Hr10_15,  Hr10_45, 	Hr11_15,  Hr11_45, Hr12_15,  Hr12_45, Hr13_15,  Hr13_45, Hr14_15,  Hr14_45, 
							Hr15_15,  Hr15_45,Hr16_15,  Hr16_45, Hr17_15,  Hr17_45, Hr18_15,  Hr18_45, Hr19_15,  Hr19_45, 
							Hr20_15,  Hr20_45, Hr21_15,  Hr21_45, Hr22_15,  Hr22_45, Hr23_15,  Hr23_45, Hr24_15,  Hr24_45, Hr25_15,  Hr25_45))a		
			ON ISNULL(td.source_deal_detail_id,-1)=ISNULL(a.source_deal_detail_id,-1)
			INNER JOIN #ContractBillingDate cb ON cb.contract_id=td.contract_id 
				AND CAST(CONVERT(VARCHAR(10),ISNULL(prod_date,td.deal_term_start),120)+'' ''+ISNULL(CAST(CAST(substring(REPLACE(REPLACE(a.[Hour],''25'',''3''),''hr'',''''),0,charindex(''_'',REPLACE(REPLACE(a.[Hour],''25'',''3''),''hr'',''''))) AS INT)-1 AS VARCHAR),''00'')+'':00:00:000'' AS DATETIME) between cb.udf_from_date_hour AND cb.udf_to_date_hour 
			LEFT JOIN mv90_dst mv_dst ON mv_dst.[Date]=	ISNULL(a.prod_date,td.deal_term_start)
					AND mv_dst.insert_delete=''i''
					AND mv_dst.dst_group_value_id = td.dst_group_value_id
					AND substring(REPLACE(a.[Hour],''hr'',''''),0,charindex(''_'',REPLACE(a.[Hour],''hr'','''')))=25		
				'			
			
			EXEC(@Pivot_table)
			
			IF NOT EXISTS(SELECT 'X' FROM #30minutes_temp)
			BEGIN
				
				;With mycte
				AS ( SELECT 1 as Time_ID, CAST(CONVERT(VARCHAR(10),udf_from_date,120)+' '+RIGHT(CONVERT(VARCHAR(16),DATEADD(day, DATEDIFF(day,0,udf_from_date),0),120),5)+':00.000' AS DATETIME)  as term_date,udf_to_date,0 is_dst FROM #ContractBillingDate
					UNION ALL
					SELECT Time_ID+1 ,CAST(CONVERT(VARCHAR(16),DATEADD(minute, 30,term_date) ,120) AS DATETIME),udf_to_date,0 is_dst
					FROM mycte
					WHERE CAST(term_date AS DATETIME) < CAST(CONVERT(VARCHAR(10),udf_to_date,120)+' '+'23:45:00.000' AS DATETIME)
				)
				SELECT * INTO #CTE2 FROM mycte OPTION (MAXRECURSION 5000)	
				
				INSERT INTO #CTE2(term_date)
				SELECT cte.term_date FROM #CTE2 cte CROSS JOIN
				(
					select var_value default_timezone_id from dbo.adiha_default_codes_values (nolock) WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
				) df  
				INNER join dbo.time_zones tz (nolock) ON tz.timezone_id = df.default_timezone_id
				INNER JOIN mv90_DST mv_dst ON CONVERT(VARCHAR(10),cte.term_date,120) = mv_dst.date
				AND mv_dst.dst_group_value_id = tz.dst_group_value_id
				
				
			
			SET @Pivot_table=
				'INSERT INTO #30minutes_temp
				 SELECT 
					td.counterparty_id,
					td.contract_id,
					ISNULL(CONVERT(VARCHAR(10),cte.term_date,120),td.deal_term_start) prod_date,
					DATEPART(hour,cte.term_date)+1 [Hour],
					DATEPART(hour,cte.term_date)+1 [org_Hour],
					0 volume,
					''n'' data_missing,
					td.source_deal_detail_id,
					td.deal_term_start,
					td.deal_formula_id,
					td.location_id,
					td.generator_id,
					td.commodity_id,
					DATEPART(Mi,cte.term_date)+15 [mins],
					cte.is_dst is_dst,
					td.source_deal_header_id,
					td.deal_type,
					td.meter_id,
					td.netting_group_id,
					td.invoice_granularity,
					td.is_true_up
				 FROM
					#temp_deals td
					INNER JOIN #ContractBillingDate cb ON cb.contract_id=td.contract_id 
					INNER JOIN #CTE2 cte ON CONVERT(VARCHAR(10),cte.term_date,120) between cb.udf_from_date AND cb.udf_to_date '	
									
				EXEC(@Pivot_table)			
			END

			SET @sqlstmt='
				INSERT INTO '+@formula_table+'(rowid,counterparty_id,contract_id,prod_date,as_of_date,volume,onPeakVolume,source_deal_detail_id,formula_id,invoice_Line_item_id,invoice_line_item_seq_id,price,granularity,volume_uom_id,generator_id,[Hour],commodity_id,[mins],is_dst,source_deal_header_id,calc_aggregation,meter_id,netting_group_id,invoice_granularity,is_true_up)
				SELECT
				DENSE_RANK() OVER(ORDER BY mv.counterparty_id,mv.contract_id,tf.invoice_line_item_id,tf.formula_id,dbo.FNAGetContractMonth(ISNULL(pd.term_start,mv.[prod_date]))), 
				MAX(mv.counterparty_id) counterparty_id,
				MAX(cg.contract_id) contract_id,
				ISNULL(pd.term_start,mv.[prod_date]) prod_date,
				'''+CAST(@as_of_date AS VARCHAR)+''',
				MAX(mv.Volume)  Volume,
				0 AS onPeakVolume,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19002 THEN mv.source_deal_detail_id ELSE NULL END  AS source_deal_detail_id,
				(tf.formula_id),
				MAX(tf.invoice_line_item_id),
				MAX(tf.formula_sequence_number),
				MAX(tf.invoice_line_item_sequence_number),
				989 granularity,
				MAX(cg.volume_uom),
				MAX(generator_id),
				ISNULL(pd.hour,mv.[Hour])  AS [Hour],
				MAX(mv.commodity_id),
				mv.[mins] AS [mins],
				mv.is_dst,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19000 THEN mv.source_deal_header_id ELSE NULL END source_deal_header_id,
				tf.calc_aggregation,
				mv.meter_id,
				MAX(mv.netting_group_id),
				MAX(mv.invoice_granularity),
				MAX(mv.is_true_up)
			FROM
				'
			SET @sqlstmt1 = ' #30minutes_temp  mv
				left JOIN contract_group cg ON  mv.contract_id=cg.contract_id 
 				INNER JOIN #temp_formula tf ON tf.counterparty_id=mv.counterparty_id
 					AND tf.contract_id=mv.contract_id
 					AND COALESCE(tf.deal_type_id,mv.deal_type,-1)=ISNULL(mv.deal_type,-1)
 					AND tf.granularity=989
 					AND tf.contract_calc_type <> ''c''
				LEFT JOIN hour_block_term hb ON ISNULL(cg.hourly_block,291890)=hb.block_define_id AND ISNULL(cg.block_type,12000)=hb.block_type AND mv.[prod_date]=hb.term_date
					AND hb.dst_group_value_id = tf.dst_group_value_id
 				LEFT JOIN #Proxy_term pd 
 				    ON pd.contract_id=mv.contract_id
 				    AND pd.commodity_id=mv.commodity_id
 					AND pd.proxy_term_start=mv.prod_date
 					AND pd.[proxy_hour]=mv.[Hour]
		WHERE
			((mv.[org_Hour]=25 AND mv.is_dst=1) OR (mv.is_dst=0 AND mv.[org_Hour]<>25))
								
		GROUP BY 
				meter_id,mv.counterparty_id, mv.contract_id,CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19002 THEN mv.source_deal_detail_id ELSE NULL END,
				CASE WHEN ISNULL(tf.calc_aggregation,19001) = 19000 THEN mv.source_deal_header_id ELSE NULL END,
				ISNULL(pd.term_start,mv.[prod_date]),ISNULL(pd.hour,mv.hour),
					tf.formula_id,dbo.FNAGetContractMonth(ISNULL(pd.term_start,mv.[prod_date])),tf.invoice_line_item_id,mv.[mins],mv.is_dst,tf.calc_aggregation'
		
		--PRINT @sqlstmt
		--PRINT @sqlstmt1
		EXEC(@sqlstmt+@sqlstmt1)		
		
	END

	--print '30 Minutes table populated'+': '+cast(datediff(ss,@calc_time,getdate()) as varchar) +'*************************************'
		set @calc_time=getdate()	






        EXEC spa_calculate_formula	@as_of_date,@formula_table,@test_process_id,@calc_result_table=@calc_result_table OUTPUT,@calc_result_detail_table = @calc_result_detail_table OUTPUT,@estimate_calculation = 'n',@formula_audit = 'n',@call_from= NULL,@simulation_curve_criteria = 0,@cpt_model_type = @cpt_type, @prod_date_to=@prod_date_to_str




	DELETE source_price_curve_cache where process_id=@test_process_id
	--EXEC('select * from '+@calc_result_table + ' ORDER BY FORMULA_ID,INVOICE_LINE_ITEM_ID,PROD_DATE')
	--EXEC('select * from '+@calc_result_detail_table + ' order by source_id,seq_number')



----**********************************
--Ths last line of the formula will be an answer
----**********************************

	exec('create index indx_calc_result_table_111 on '+@calc_result_table+' (counterparty_id,contract_id);
			create index indx_calc_result_table_222 on '+@calc_result_table+' (prod_date,[hour],mins,is_dst);
			create index indx_calc_result_table_333 on '+@calc_result_table+' (invoice_Line_item_id);
			create index indx_calc_result_table_444 on '+@calc_result_table+' (source_deal_header_id,source_deal_detail_id)')


 ---### Evaluate the formula multiplier defined in the mapping	
   SET @process_id = REPLACE(newid(),'-','_')
   SET @formula_table=dbo.FNAProcessTableName('curve_formula_table', @user_login_id, @process_id)
   	
	
	SET @stmt='
		CREATE TABLE '+@formula_table+'(
			rowid int ,
			counterparty_id INT,
			contract_id INT,
			curve_id INT,
			prod_date DATETIME,
			as_of_date DATETIME,
			volume FLOAT,
			onPeakVolume FLOAT,
			source_deal_header_id INT,
			source_deal_detail_id INT,
			formula_id INT,
			invoice_Line_item_id INT,			
			invoice_line_item_seq_id INT,
			price FLOAT,			
			granularity INT,
			volume_uom_id INT,
			generator_id INT,
			[Hour] INT,
			commodity_id INT,
			meter_id INT,
			curve_source_value_id INT,
			[mins] INT,
			calc_aggregation INT
		)	'
		
	EXEC(@stmt)	



	SET @stmt=' INSERT INTO '+@formula_table+'(rowid,formula_id,prod_date, as_of_date,granularity,contract_id,counterparty_id,source_deal_header_id,source_deal_detail_id,calc_aggregation,invoice_Line_item_id)
				SELECT 	[ID], ccm.formula_id,'''+CAST(@prod_date AS VARCHAR)+''', '''+CAST(@as_of_date AS VARCHAR)+''', 980,td.contract_id,td.counterparty_id,td.source_deal_header_id,td.source_deal_detail_id,19002,invoice_Line_item_id
				FROM #temp_deals td	
				INNER JOIN #temp_formula tf ON tf.counterparty_id=td.counterparty_id
					AND tf.contract_id=td.contract_id
					AND tf.contract_calc_type = ''c''
				INNER JOIN contract_component_mapping ccm ON ccm.contract_component_id = tf.invoice_Line_item_id
					AND ISNULL(ccm.deal_type_id,td.deal_type) = td.deal_type
					AND ISNULL(ccm.leg,td.leg) = td.leg
					AND td.source_system_book_id1 = ISNULL(ccm.book_identifier1,td.source_system_book_id1)
					AND td.source_system_book_id2 = ISNULL(ccm.book_identifier2,td.source_system_book_id2)
					AND td.source_system_book_id3 = ISNULL(ccm.book_identifier3,td.source_system_book_id3)
					AND td.source_system_book_id4 = ISNULL(ccm.book_identifier4,td.source_system_book_id4)
				WHERE
					ccm.formula_id IS NOT NULL	
			'

	--print @stmt 
	EXEC(@stmt)


	DECLARE @calc_result_table_formula_line VARCHAR(100),@calc_result_detail_table_formula_line VARCHAR(100)
	EXEC spa_calculate_formula	@as_of_date, @formula_table,@process_id,@calc_result_table_formula_line output, @calc_result_detail_table_formula_line output,@estimate_calculation = 'n',@formula_audit = 'n',@call_from= NULL,@simulation_curve_criteria = 0,@cpt_model_type = @cpt_type, @prod_date_to=@prod_date_to

	-- Insert the deal items calculated for the contract components
	-- Insert commodyt charge type
	CREATE TABLE #impact_line_items(calc_id INT,invoice_Line_item_id INT,prod_date DATETIME,term_Date DATETIME, [hour] INT,[mins] INT,is_dst INT,value FLOAT, volume FLOAT,price_or_formula CHAR(1) COLLATE DATABASE_DEFAULT,source_deal_header_id INT,source_deal_detail_id INT,prod_date_summary DATETIME)




-- Insert the summary for netting group
	SET @stmt=' 
		INSERT INTO '+@table_calc_invoice_volume_variance+'(
					as_of_date,
					counterparty_id,
					generator_id,   
					contract_id,
					prod_date,
					metervolume,
					invoicevolume,
					allocationvolume,   
					variance,
					onpeak_volume,
					offpeak_volume,
					UOM,
					actualvolume,
					book_entries,   
					invoice_id,
					deal_id,
					estimated,
					sub_id,
					invoice_type,
					netting_group_id,
					prod_date_to,
					settlement_date,
					invoice_template_id '
					
		IF @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance'	  --Added to save Workflow Status as 'Initial' for newly processed Invoice
			SET @stmt = @stmt + ',invoice_status)'		
		ELSE
			 SET @stmt = @stmt +')'			
				 			
		SET @stmt = @stmt + '
		SELECT
				'''+CAST(@as_of_date AS VARCHAR)+''',
				a.counterparty_id,
				MAX(a.generator_id),
				MAX(a.contract_id),
				MIN(CASE a.invoice_granularity WHEN 980 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(Month(a.deal_term_start) as varchar) + ''-01'' 
						WHEN 981 THEN a.deal_term_start
						WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', a.deal_term_start), ''19050101'')
						WHEN 991 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,a.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
						WHEN 992 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, a.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
						WHEN 993 THEN cast(Year(a.deal_term_start) as varchar) + ''-01-01'' END) ,
				0,
				0,
				0,
				0 variance,   
				0,
				0,
				MAX(uom_id),
				0,
				''m'',
				NULL,
				NULL,
				''n'',
				'+CAST(@sub_entity_id as VARCHAR)+', 
				''i'',
				a.netting_group_id,
				NULL,
				a.settlement_date,
				NULL '
				
		IF @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance'	
			SET @stmt = @stmt + ',20701'
		 				
		SET @stmt = @stmt  + 
		'FROM
			#temp_deals a 
			LEFT JOIN '+@table_calc_invoice_volume_variance+' civv ON civv.counterparty_id = a.counterparty_id
				AND civv.netting_group_id = a.netting_group_id
				AND civv.settlement_date = a.settlement_date
				AND civv.as_of_date = '''+CAST(@as_of_date AS VARCHAR)+'''
				AND civv.prod_date = CASE a.invoice_granularity WHEN 980 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(Month(a.deal_term_start) as varchar) + ''-01'' 
					WHEN 981 THEN a.deal_term_start
					WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', a.deal_term_start), ''19050101'')
					WHEN 991 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,a.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
					WHEN 992 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, a.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
					WHEN 993 THEN cast(Year(a.deal_term_start) as varchar) + ''-01-01'' END
		WHERE
			civv.calc_id IS NULL	
			AND a.netting_group_id IS NOT NULL
			AND ISNULL(a.is_true_up,''n'') = ''n''
			AND ISNULL(a.document_type,''a'') IN (''i'',''a'')
		GROUP BY a.counterparty_id,a.netting_group_id,a.settlement_date'
	EXEC(@stmt)


	SET @stmt=' 
		INSERT INTO '+@table_calc_invoice_volume_variance+'(
					as_of_date,
					counterparty_id,
					generator_id,   
					contract_id,
					prod_date,
					metervolume,
					invoicevolume,
					allocationvolume,   
					variance,
					onpeak_volume,
					offpeak_volume,
					UOM,
					actualvolume,
					book_entries,   
					invoice_id,
					deal_id,
					estimated,
					sub_id,
					invoice_type,
					prod_date_to,
					settlement_date,
					invoice_template_id'
					
		IF @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance'	--Added to save Workflow Status as 'Initial' for newly processed Invoice
			SET @stmt = @stmt + ',invoice_status)'		
		ELSE
			 SET @stmt = @stmt +')'			
				 			
		SET @stmt = @stmt + '
		SELECT
				'''+CAST(@as_of_date AS VARCHAR)+''',
				a.counterparty_id,
				MAX(a.generator_id),
				a.contract_id,
				MIN(CASE a.invoice_granularity WHEN 980 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(Month(a.deal_term_start) as varchar) + ''-01'' 
						WHEN 981 THEN a.deal_term_start
						WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', a.deal_term_start), ''19050101'')
						WHEN 991 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,a.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
						WHEN 992 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, a.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
						WHEN 993 THEN cast(Year(a.deal_term_start) as varchar) + ''-01-01'' END) ,
				0,
				0,
				0,
				0 variance,   
				0,
				0,
				MAX(uom_id),
				0,
				''m'',
				NULL,
				NULL,
				''n'',
				'+CAST(@sub_entity_id as VARCHAR)+', 
				''i'',
				NULL,
				a.settlement_date,
				tf.invoice_template_id'
				
		IF @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance'	
			SET @stmt = @stmt + ',20701'
		 				
		SET @stmt = @stmt  + 
		' FROM	#temp_deals a 
			CROSS APPLY(SELECT  MAX(neting_rule) neting_rule, invoice_template_id FROM #temp_formula 
			            WHERE contract_id=a.contract_id AND counterparty_id = a.counterparty_id GROUP BY invoice_template_id) tf	
			LEFT JOIN '+@table_calc_invoice_volume_variance+' civv ON civv.counterparty_id = a.counterparty_id
				AND civv.contract_id = a.contract_id
				AND civv.settlement_date = a.settlement_date
				AND civv.as_of_date = '''+CAST(@as_of_date AS VARCHAR)+''' 
				AND ISNULL(civv.invoice_template_id,-1) = ISNULL(tf.invoice_template_id,-1)
				AND civv.invoice_type = ''i''
				AND civv.prod_date = CASE a.invoice_granularity WHEN 980 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(Month(a.deal_term_start) as varchar) + ''-01'' 
					WHEN 981 THEN a.deal_term_start
					WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', a.deal_term_start), ''19050101'')
					WHEN 991 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,a.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
					WHEN 992 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, a.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
					WHEN 993 THEN cast(Year(a.deal_term_start) as varchar) + ''-01-01'' END
		WHERE
			civv.calc_id IS NULL	
			AND neting_rule = ''n''	
			AND a.netting_group_id IS NULL
			AND ISNULL(a.is_true_up,''n'') = ''n''
			AND ISNULL(a.document_type,''a'') IN (''i'',''a'')
		GROUP BY a.counterparty_id,a.contract_id,a.settlement_date, tf.invoice_template_id'
	EXEC(@stmt)




	-- if Invoice netting is 'n' create another record for remittance
	SET @stmt=' 
		INSERT INTO '+@table_calc_invoice_volume_variance+'(
					as_of_date,
					counterparty_id,
					generator_id,   
					contract_id,
					prod_date,
					metervolume,
					invoicevolume,
					allocationvolume,   
					variance,
					onpeak_volume,
					offpeak_volume,
					UOM,
					actualvolume,
					book_entries,   
					invoice_id,
					deal_id,
					estimated,
					sub_id,
					invoice_type,
					prod_date_to,
					settlement_date,
					tf.invoice_template_id'
					
		IF @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance'	--Added to save Workflow Status as 'Initial' for newly processed Invoice
			SET @stmt = @stmt + ',invoice_status)'		
		ELSE
			 SET @stmt = @stmt +')'			
				 			
		SET @stmt = @stmt + '
		SELECT
				'''+CAST(@as_of_date AS VARCHAR)+''',
				a.counterparty_id,
				MAX(a.generator_id),
				a.contract_id,
				MIN(CASE a.invoice_granularity WHEN 980 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(Month(a.deal_term_start) as varchar) + ''-01'' 
						WHEN 981 THEN a.deal_term_start
						WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', a.deal_term_start), ''19050101'')
						WHEN 991 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,a.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
						WHEN 992 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, a.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
						WHEN 993 THEN cast(Year(a.deal_term_start) as varchar) + ''-01-01'' END) ,
				0,
				0,
				0,
				0 variance,   
				0,
				0,
				MAX(uom_id),
				0,
				''m'',
				NULL,
				NULL,
				''n'',
				'+CAST(@sub_entity_id as VARCHAR)+', 
				''r'',
				NULL,
				a.settlement_date,
				tf.invoice_template_id'
				
		IF @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance'	
			SET @stmt = @stmt + ',20701'
		 				
		SET @stmt = @stmt  + 
		'
		FROM
			#temp_deals a 
			CROSS APPLY(SELECT MAX(neting_rule) neting_rule, invoice_template_id FROM #temp_formula WHERE contract_id=a.contract_id AND counterparty_id = a.counterparty_id GROUP BY invoice_template_id) tf	
			LEFT JOIN '+@table_calc_invoice_volume_variance+' civv ON civv.counterparty_id = a.counterparty_id
				AND civv.contract_id = a.contract_id
				AND civv.settlement_date = a.settlement_date
				AND civv.as_of_date = '''+CAST(@as_of_date AS VARCHAR)+''' 
				AND ISNULL(civv.invoice_template_id,-1) = ISNULL(tf.invoice_template_id,-1)
				AND ((civv.invoice_type = ''r'' AND tf.neting_rule =''n'') OR tf.neting_rule =''y'')
				AND civv.prod_date = CASE a.invoice_granularity WHEN 980 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(Month(a.deal_term_start) as varchar) + ''-01'' 
					WHEN 981 THEN a.deal_term_start
					WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', a.deal_term_start), ''19050101'')
					WHEN 991 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,a.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
					WHEN 992 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, a.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
					WHEN 993 THEN cast(Year(a.deal_term_start) as varchar) + ''-01-01'' END
		WHERE
			civv.calc_id IS NULL				
			AND a.netting_group_id IS NULL
			AND ISNULL(a.is_true_up,''n'') = ''n''
		GROUP BY a.counterparty_id,a.contract_id,a.settlement_date, tf.invoice_template_id'
	EXEC(@stmt)


	
	SET @stmt = '
	INSERT INTO #impact_line_items (
				calc_id,
				invoice_Line_item_id,
				prod_date,
				[Value],
				Volume,
				price_or_formula,
				source_deal_header_id,
				source_deal_detail_id,
				prod_date_summary					
			)
		select 
	 		civv.calc_id,
			tf.invoice_Line_item_id,
			CASE td.invoice_granularity WHEN 980 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(Month(td.deal_term_start) as varchar) + ''-01'' 
						WHEN 981 THEN td.deal_term_start
						WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', td.deal_term_start), ''19050101'')
						WHEN 991 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,td.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
						WHEN 992 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
						WHEN 993 THEN cast(Year(td.deal_term_start) as varchar) + ''-01-01'' END,
			ROUND(SUM(td.deal_settlement_amount)*MAX(ISNULL(multiplier,1))*MAX(ISNULL(crt.formula_eval_value,1)),MAX(ISNULL(rounding,7))) [value],
			ROUND(SUM(ISNULL(NULLIF(td.deal_settlement_volume,0),td.deal_volume)),MAX(ISNULL(rounding,7))) [volume],
			''f'',
			td.source_deal_header_id,
			CASE WHEN ISNULL(tf.calc_aggregation,19001)=19002 THEN td.source_deal_detail_id ELSE NULL END source_deal_detail_id,
			civv.prod_date
		FROM
			#temp_deals td	
			INNER JOIN #temp_formula tf ON tf.counterparty_id=td.counterparty_id
				AND tf.contract_id=td.contract_id
				AND tf.contract_calc_type = ''c''
				AND COALESCE(tf.buy_sell, td.buy_sell,'''') = COALESCE(td.buy_sell, tf.buy_sell,'''')
				AND COALESCE(tf.location_id, td.location_id, 1) = COALESCE(td.location_id, tf.location_id, 1)
			INNER JOIN contract_component_mapping ccm ON ccm.contract_component_id = tf.invoice_Line_item_id
				AND ISNULL(ccm.deal_type_id,td.deal_type) = td.deal_type
				AND ISNULL(ccm.leg,td.leg) = td.leg
				AND ccm.charge_type_id =-5500
				AND td.source_system_book_id1 = ISNULL(ccm.book_identifier1,td.source_system_book_id1)
				AND td.source_system_book_id2 = ISNULL(ccm.book_identifier2,td.source_system_book_id2)
				AND td.source_system_book_id3 = ISNULL(ccm.book_identifier3,td.source_system_book_id3)
				AND td.source_system_book_id4 = ISNULL(ccm.book_identifier4,td.source_system_book_id4)
			INNER JOIN '+@table_calc_invoice_volume_variance+' civv (nolock) ON td.counterparty_id=civv.counterparty_id
					AND ((td.contract_id = civv.contract_id AND td.netting_group_id IS NULL) OR (td.netting_group_id = civv.netting_group_id))
					AND ((civv.invoice_type = ISNULL(td.document_type,CASE WHEN td.deal_settlement_amount<0 THEN '''+@ir_sign+''' ELSE '''+@ir_sign_rev+''' END) AND tf.neting_rule =''n'') OR tf.neting_rule =''y'' OR td.netting_group_id IS NOT NULL)
					'+CASE WHEN @date_type='s' THEN ' AND civv.settlement_date = td.settlement_date' ELSE ' AND civv.prod_date = CASE td.invoice_granularity WHEN 980 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(Month(td.deal_term_start) as varchar) + ''-01'' 
						WHEN 981 THEN td.deal_term_start
						WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', td.deal_term_start), ''19050101'')
						WHEN 991 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,td.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
						WHEN 992 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
						WHEN 993 THEN cast(Year(td.deal_term_start) as varchar) + ''-01-01'' END' END +'
					'+CASE WHEN @calc_id IS NOT NULL THEN ' AND civv.calc_id IN ('+@calc_id+ ')' ELSE '' END +'
			LEFT JOIN '+@calc_result_table_formula_line+' crt ON ISNULL(crt.source_deal_detail_id,-1) = ISNULL(td.source_deal_detail_id,-1)		
				AND  ISNULL(crt.source_deal_header_id,-1) = ISNULL(td.source_deal_header_id,-1)
				AND crt.invoice_Line_item_id=tf.invoice_Line_item_id
			WHERE
				td.save_mtm_at_calculation_granularity = ''n''
				AND civv.as_of_date='''+CAST(@as_of_date AS VARCHAR)+'''
				AND td.sds_deal_id IS NOT NULL
				AND CONVERT(VARCHAR(7),'+CASE WHEN @date_type='s' THEN 'civv.settlement_date' ELSE 'civv.prod_date' END +',120) = '''+CONVERT(VARCHAR(7),@prod_date,120)+'''
		GROUP BY
			civv.calc_id,tf.invoice_Line_item_id,td.source_deal_header_id,
			CASE WHEN ISNULL(tf.calc_aggregation,19001)=19002 THEN td.source_deal_detail_id ELSE NULL END,civv.prod_date,CASE td.invoice_granularity WHEN 980 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(Month(td.deal_term_start) as varchar) + ''-01'' 
						WHEN 981 THEN td.deal_term_start
						WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', td.deal_term_start), ''19050101'')
						WHEN 991 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,td.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
						WHEN 992 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
						WHEN 993 THEN cast(Year(td.deal_term_start) as varchar) + ''-01-01'' END
		 '
		--PRINT(@stmt)		
		EXEC(@stmt)

	-- Time Zone Shift Logic
	IF EXISTS(SELECT 'X' FROM #temp_deals td INNER JOIN #temp_formula tf ON tf.counterparty_id=td.counterparty_id AND tf.contract_id=td.contract_id AND tf.contract_calc_type = 'c' WHERE td.save_mtm_at_calculation_granularity = 'y')
	BEGIN
	
		
					
		SET @stmt = '
		INSERT INTO #impact_line_items (
					calc_id,
					invoice_Line_item_id,
					prod_date,
					term_date,
					[hour],
					[mins],
					[is_dst],
					[Value],
					Volume,
					price_or_formula,
					source_deal_header_id,
					source_deal_detail_id,
					prod_date_summary					
				)
			select 
	 			civv.calc_id,
				tf.invoice_Line_item_id,
				CASE td.invoice_granularity WHEN 980 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(Month(td.deal_term_start) as varchar) + ''-01'' 
							WHEN 981 THEN td.deal_term_start
							WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', td.deal_term_start), ''19050101'')
							WHEN 991 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,td.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
							WHEN 992 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
							WHEN 993 THEN cast(Year(td.deal_term_start) as varchar) + ''-01-01'' END,
				sdsb.term_date,
				sdsb.Hours,
				sdsb.[period],
				sdsb.is_dst,
				ROUND(SUM(sdsb.leg_set)*MAX(ISNULL(multiplier,1)),MAX(ISNULL(rounding,7))) [value],
				ROUND(SUM(sdsb.volume),MAX(ISNULL(rounding,7))) [volume],
				''f'',
				td.source_deal_header_id,
				CASE WHEN ISNULL(tf.calc_aggregation,19001)=19002 THEN td.source_deal_detail_id ELSE NULL END source_deal_detail_id,
				civv.prod_date
			FROM
				#temp_deals td	
				INNER JOIN #temp_formula tf ON tf.counterparty_id=td.counterparty_id
					AND tf.contract_id=td.contract_id
					AND tf.contract_calc_type = ''c''
					AND COALESCE(tf.buy_sell, td.buy_sell,'''') = COALESCE(td.buy_sell, tf.buy_sell,'''')
					AND COALESCE(tf.location_id, td.location_id, 1) = COALESCE(td.location_id, td.location_id, 1)
				INNER JOIN contract_component_mapping ccm ON ccm.contract_component_id = tf.invoice_Line_item_id
					AND ISNULL(ccm.deal_type_id,td.deal_type) = td.deal_type
					AND ISNULL(ccm.leg,td.leg) = td.leg
					AND ccm.charge_type_id =-5500
					AND td.source_system_book_id1 = ISNULL(ccm.book_identifier1,td.source_system_book_id1)
					AND td.source_system_book_id2 = ISNULL(ccm.book_identifier2,td.source_system_book_id2)
					AND td.source_system_book_id3 = ISNULL(ccm.book_identifier3,td.source_system_book_id3)
					AND td.source_system_book_id4 = ISNULL(ccm.book_identifier4,td.source_system_book_id4)
				INNER JOIN '+@table_calc_invoice_volume_variance+' civv (nolock) ON td.counterparty_id=civv.counterparty_id
						AND ((td.contract_id = civv.contract_id AND td.netting_group_id IS NULL) OR (td.netting_group_id = civv.netting_group_id))
						AND ((civv.invoice_type = ISNULL(td.document_type,CASE WHEN td.deal_settlement_amount<0 THEN '''+@ir_sign+''' ELSE '''+@ir_sign_rev+''' END) AND tf.neting_rule =''n'') OR tf.neting_rule =''y'' OR td.netting_group_id IS NOT NULL)
						'+CASE WHEN @date_type='s' THEN ' AND civv.settlement_date = td.settlement_date' ELSE ' AND civv.prod_date = CASE td.invoice_granularity WHEN 980 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(Month(td.deal_term_start) as varchar) + ''-01'' 
							WHEN 981 THEN td.deal_term_start
							WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', td.deal_term_start), ''19050101'')
							WHEN 991 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,td.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
							WHEN 992 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
							WHEN 993 THEN cast(Year(td.deal_term_start) as varchar) + ''-01-01'' END' END +'
						'+CASE WHEN @calc_id IS NOT NULL THEN ' AND civv.calc_id IN ('+@calc_id+ ')' ELSE '' END +'
				INNER JOIN source_deal_settlement_breakdown sdsb ON sdsb.source_deal_detail_id = td.source_deal_detail_id
					AND sdsb.leg=td.leg
					--AND '''+CONVERT(VARCHAR(10),@as_of_date,120)+'''>=sdsb.term_end
					AND  '''+CONVERT(VARCHAR(10),@as_of_date,120)+''' = sdsb.as_of_date
				WHERE
					td.save_mtm_at_calculation_granularity = ''y''
					AND civv.as_of_date='''+CAST(@as_of_date AS VARCHAR)+'''
					AND CONVERT(VARCHAR(7),'+CASE WHEN @date_type='s' THEN 'civv.settlement_date' ELSE 'civv.prod_date' END +',120) = '''+CONVERT(VARCHAR(7),@prod_date,120)+'''
			GROUP BY
				sdsb.term_date,sdsb.Hours,sdsb.[period],sdsb.is_dst,civv.calc_id,tf.invoice_Line_item_id,td.source_deal_header_id,
				CASE WHEN ISNULL(tf.calc_aggregation,19001)=19002 THEN td.source_deal_detail_id ELSE NULL END,civv.prod_date,CASE td.invoice_granularity WHEN 980 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(Month(td.deal_term_start) as varchar) + ''-01'' 
							WHEN 981 THEN td.deal_term_start
							WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', td.deal_term_start), ''19050101'')
							WHEN 991 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,td.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
							WHEN 992 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
							WHEN 993 THEN cast(Year(td.deal_term_start) as varchar) + ''-01-01'' END
			 '
			--PRINT(@stmt)		
			EXEC(@stmt)
	END



	SET @stmt = '
	INSERT INTO #impact_line_items (
				calc_id,
				invoice_Line_item_id,
				prod_date,
				[Value],
				Volume,
				price_or_formula,
				source_deal_header_id,
				source_deal_detail_id,
				prod_date_summary					
			)
		select 
	 		civv.calc_id,
			tf.invoice_Line_item_id,
			CASE td.invoice_granularity WHEN 980 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(Month(td.deal_term_start) as varchar) + ''-01'' 
						WHEN 981 THEN td.deal_term_start
						WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', td.deal_term_start), ''19050101'')
						WHEN 991 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,td.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
						WHEN 992 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
						WHEN 993 THEN cast(Year(td.deal_term_start) as varchar) + ''-01-01'' END,
			ROUND(SUM(ISNULL(sdp.value,sdp1.value))*MAX(ISNULL(multiplier,1)),MAX(ISNULL(rounding,7))) [value],
			ROUND(SUM(COALESCE(sdp.volume,sdp1.volume,td.deal_volume)),MAX(ISNULL(rounding,7))) [volume],
			''f'',
			td.source_deal_header_id,
			td.source_deal_detail_id,
			civv.prod_date
		FROM
			#temp_deals td
			INNER JOIN #temp_formula tf ON tf.counterparty_id=td.counterparty_id
				AND tf.contract_id=td.contract_id
				AND tf.contract_calc_type = ''c''
				AND COALESCE(tf.buy_sell, td.buy_sell,'''') = COALESCE(td.buy_sell, tf.buy_sell,'''')
				AND COALESCE(tf.location_id, td.location_id, 1) = COALESCE(td.location_id, tf.location_id, 1)
			INNER JOIN contract_component_mapping ccm ON ccm.contract_component_id = tf.invoice_Line_item_id
				AND ISNULL(ccm.deal_type_id,td.deal_type) = td.deal_type
				AND ISNULL(ccm.leg,td.leg) = td.leg
				AND ccm.charge_type_id <> -5500 
				AND td.source_system_book_id1 = ISNULL(ccm.book_identifier1,td.source_system_book_id1)
				AND td.source_system_book_id2 = ISNULL(ccm.book_identifier2,td.source_system_book_id2)
				AND td.source_system_book_id3 = ISNULL(ccm.book_identifier3,td.source_system_book_id3)
				AND td.source_system_book_id4 = ISNULL(ccm.book_identifier4,td.source_system_book_id4)			
			LEFT JOIN index_fees_breakdown_settlement sdp
					ON td.source_deal_header_id=sdp.source_deal_header_id 
					AND sdp.term_start=td.deal_term_start 
					AND sdp.leg=td.Leg
					AND sdp.field_id = ccm.charge_type_id
					--AND ccm.charge_type_id <> -5500
					AND ((sdp.set_type = ''f'' AND sdp.as_of_date = '''+CONVERT(VARCHAR(10),@as_of_date,120)+''') OR (sdp.set_type = ''s''  AND '''+CONVERT(VARCHAR(10),@as_of_date,120)+'''>=sdp.term_end))
			LEFT JOIN index_fees_breakdown sdp1
					ON td.source_deal_header_id=sdp1.source_deal_header_id 
					AND sdp1.term_start=td.deal_term_start 
					AND sdp1.leg=td.Leg
					AND sdp1.field_id = ccm.charge_type_id
					AND sdp1.as_of_date = '''+CONVERT(VARCHAR(10),@as_of_date,120)+'''			
			LEFT JOIN '+@calc_result_table_formula_line+' crt ON ISNULL(crt.source_deal_detail_id,-1) = ISNULL(td.source_deal_detail_id,-1)
				AND ISNULL(crt.source_deal_header_id,-1) = ISNULL(td.source_deal_header_id,-1)
				AND crt.invoice_Line_item_id=tf.invoice_Line_item_id	
				AND td.contract_id=crt.contract_id
			INNER JOIN '+@table_calc_invoice_volume_variance+' civv (nolock) ON td.counterparty_id=civv.counterparty_id
				AND ((civv.invoice_type = ISNULL(td.document_type,CASE WHEN ISNULL(sdp.value,sdp1.value)*ISNULL(multiplier,1)*ISNULL(crt.formula_eval_value,1)<0 THEN '''+@ir_sign+''' ELSE '''+@ir_sign_rev+''' END) AND tf.neting_rule =''n'') OR tf.neting_rule =''y''  OR td.netting_group_id IS NOT NULL)
				AND ((td.contract_id=civv.contract_id AND td.netting_group_id IS NULL) OR (td.netting_group_id = civv.netting_group_id))
				'+CASE WHEN @date_type='s' THEN ' AND civv.settlement_date = td.settlement_date' ELSE ' AND civv.prod_date = CASE td.invoice_granularity WHEN 980 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(Month(td.deal_term_start) as varchar) + ''-01'' 
						WHEN 981 THEN td.deal_term_start
						WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', td.deal_term_start), ''19050101'')
						WHEN 991 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,td.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
						WHEN 992 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
						WHEN 993 THEN cast(Year(td.deal_term_start) as varchar) + ''-01-01'' END' END +'
				'+CASE WHEN @calc_id IS NOT NULL THEN ' AND civv.calc_id IN ('+@calc_id+ ')' ELSE '' END +'

		WHERE
				ISNULL(sdp.value,sdp1.value) IS NOT NULL
				AND civv.as_of_date='''+CAST(@as_of_date AS VARCHAR)+'''
				AND CONVERT(VARCHAR(7),'+CASE WHEN @date_type='s' THEN 'civv.settlement_date' ELSE 'civv.prod_date' END +',120) = '''+CONVERT(VARCHAR(7),@prod_date,120)+'''
		GROUP BY
			civv.calc_id,tf.invoice_Line_item_id,td.source_deal_header_id,td.source_deal_detail_id,civv.prod_date,CASE td.invoice_granularity WHEN 980 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(Month(td.deal_term_start) as varchar) + ''-01'' 
						WHEN 981 THEN td.deal_term_start
						WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', td.deal_term_start), ''19050101'')
						WHEN 991 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,td.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
						WHEN 992 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
						WHEN 993 THEN cast(Year(td.deal_term_start) as varchar) + ''-01-01'' END'

	    --print @stmt 
		EXEC(@stmt)



 SET @stmt = '
	 INSERT INTO #impact_line_items (
		calc_id,
		invoice_Line_item_id,
		prod_date,
		[Value],
		Volume,
		price_or_formula,
		source_deal_header_id,
		source_deal_detail_id,
		prod_date_summary     
	 )
	 
	  SELECT civv.calc_id,
	         tf.invoice_Line_item_id,
			 CASE td.invoice_granularity WHEN 980 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(Month(td.deal_term_start) as varchar) + ''-01'' 
				  WHEN 981 THEN td.deal_term_start
				  WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', td.deal_term_start), ''19050101'')
				  WHEN 991 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,td.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
				  WHEN 992 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
				  WHEN 993 THEN cast(Year(td.deal_term_start) as varchar) + ''-01-01'' END,
			tf.price [value],
			0 [volume],
			''p'',
			MAX(td.source_deal_header_id),
			MAX(td.source_deal_detail_id),
			civv.prod_date
	  FROM
	   #temp_deals td
	   INNER JOIN #temp_formula tf ON tf.counterparty_id = td.counterparty_id
			AND tf.contract_id = td.contract_id
			AND tf.price IS NOT NULL
	   INNER JOIN '+@table_calc_invoice_volume_variance+' civv (nolock) ON td.counterparty_id=civv.counterparty_id
			AND ((civv.invoice_type = ISNULL(td.document_type,CASE WHEN tf.price<0 THEN '''+@ir_sign+''' ELSE '''+@ir_sign_rev+''' END) AND tf.neting_rule =''n'') OR tf.neting_rule =''y''  OR td.netting_group_id IS NOT NULL)
			AND ((td.contract_id=civv.contract_id AND td.netting_group_id IS NULL) OR (td.netting_group_id = civv.netting_group_id))
		'+CASE WHEN @date_type='s' THEN ' AND civv.settlement_date = td.settlement_date' ELSE ' AND civv.prod_date = CASE td.invoice_granularity WHEN 980 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(Month(td.deal_term_start) as varchar) + ''-01'' 
			  WHEN 981 THEN td.deal_term_start
			  WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', td.deal_term_start), ''19050101'')
			  WHEN 991 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,td.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
			  WHEN 992 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
			  WHEN 993 THEN cast(Year(td.deal_term_start) as varchar) + ''-01-01'' END' END +'
		'+CASE WHEN @calc_id IS NOT NULL THEN ' AND civv.calc_id IN ('+@calc_id+ ')' ELSE '' END +'  
	  WHERE 1=1			
			AND civv.as_of_date='''+CAST(@as_of_date AS VARCHAR)+'''
			AND CONVERT(VARCHAR(7),'+CASE WHEN @date_type='s' THEN 'civv.settlement_date' ELSE 'civv.prod_date' END +',120) = '''+CONVERT(VARCHAR(7),@prod_date,120)+'''
	  GROUP BY
		CASE ISNULL(tf.calc_aggregation,19001) WHEN 19002 THEN td.source_deal_detail_id  WHEN 19000 THEN td.source_deal_detail_id ELSE NULL END,
		 civv.calc_id,tf.invoice_Line_item_id,civv.prod_date,tf.price,CASE td.invoice_granularity WHEN 980 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(Month(td.deal_term_start) as varchar) + ''-01'' 
			  WHEN 981 THEN td.deal_term_start
			  WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', td.deal_term_start), ''19050101'')
			  WHEN 991 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,td.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
			  WHEN 992 THEN cast(Year(td.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
			  WHEN 993 THEN cast(Year(td.deal_term_start) as varchar) + ''-01-01'' END'

	  --PRINT @stmt 
	  EXEC(@stmt)
 


		SET @stmt = ' DELETE civ
		FROM
				#impact_line_items ili
				INNER JOIN '+cast(@table_calc_invoice_volume AS VARCHAR(max))+' civ  (nolock) ON civ.calc_id=ili.calc_id
					AND civ.invoice_Line_item_id=ili.invoice_Line_item_id			
			WHERE 1=1
				'+CASE WHEN @invoice_line_item_id IS NOT NULL THEN +' AND ili.invoice_Line_item_id IN ('+@invoice_line_item_id +')' ELSE '' END
		EXEC(@stmt)
		
	


		SET @stmt = '
		INSERT INTO '+cast(@table_calc_invoice_volume AS VARCHAR(max))+'(
				calc_id,
				invoice_Line_item_id,
				prod_date,
				[Value],
				Volume,
				price_or_formula					
			)
		SELECT
			calc_id,
			invoice_Line_item_id,
			prod_date_summary,
			SUM([Value]),
			SUM(Volume),
			price_or_formula
		FROM
			#impact_line_items
		GROUP BY calc_id,invoice_Line_item_id,prod_date_summary,price_or_formula '
							
		EXEC(@stmt)


		DELETE cfv FROM 			
		calc_formula_value cfv INNER JOIN #impact_line_items ili ON cfv.calc_id = ili.calc_id
			AND cfv.invoice_line_item_id = ili.invoice_Line_item_id
		
		INSERT INTO calc_formula_value(invoice_line_item_id,seq_number,prod_date,value,contract_id,counterparty_id,formula_id,calc_id,hour,formula_str,qtr,half,deal_type_id,generator_id,ems_generator_id,
		deal_id,volume,formula_str_eval,commodity_id,granularity,is_final_result,is_dst,source_deal_header_id,allocation_volume)
		SELECT 
			ili.invoice_Line_item_id,1,ISNULL(ili.term_date,ili.prod_date),ili.value,civv.contract_id,civv.counterparty_id,NULL,ili.calc_id,ili.hour,NULL,ili.mins,NULL,NULL,NULL,NULL,source_deal_detail_id,ili.volume,NULL,NULL,NULL,'y',ili.is_dst,ili.source_deal_header_id,NULL
		FROM #impact_line_items ili
			 INNER JOIN Calc_invoice_Volume_variance civv ON civv.calc_id = ili.calc_id
		WHERE
			ili.value IS NOT NULL
	


		-- Add calc_id in the @calc_result_table table
	EXEC(' ALTER TABLE '+@calc_result_table+' ADD calc_id INT, civv_prod_date DATETIME,invoice_template_id INT')
	EXEC( 'CREATE INDEX indx_11sanpt333_' + @process_id + ' ON ' + @calc_result_table + '([calc_id])')
	EXEC('CREATE INDEX indx_11sanpt444_' + @process_id + ' ON ' + @calc_result_table + '([is_final_result]) INCLUDE ([invoice_line_item_id], [formula_eval_value], [calc_id])')
	EXEC('CREATE INDEX indx_11sanpt555_' + @process_id + ' ON ' + @calc_result_table + '([formula_id], [formula_sequence_number]) INCLUDE ([contract_id], [invoice_line_item_id], [prod_date], [formula_eval_value], [calc_id])')	

	-----			
	SET @stmt = ' UPDATE a SET a.calc_id = civv.calc_id, a.civv_prod_date = civv.prod_date, a.invoice_template_id = tf.invoice_template_id 
		FROM
		'+@calc_result_table+' a
		INNER JOIN #temp_formula tf ON tf.counterparty_id = a.counterparty_id
			AND tf.contract_id = a.contract_id
			AND tf.invoice_Line_item_id = a.invoice_Line_item_id
			AND tf.granularity = a.granularity
		OUTER APPLY(SELECT SUM(formula_eval_value) formula_eval_value, CASE invoice_granularity WHEN 980 THEN cast(Year(prod_date) as varchar) + ''-'' + cast(Month(prod_date) as varchar) + ''-01'' 
					WHEN 981 THEN prod_date
					WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', prod_date), ''19050101'')
					WHEN 991 THEN cast(Year(prod_date) as varchar) + ''-'' + cast(CASE datepart(q,prod_date) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
					WHEN 992 THEN cast(Year(prod_date) as varchar) + ''-'' + cast(CASE datepart(q, prod_date) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
					WHEN 993 THEN cast(Year(prod_date) as varchar) + ''-01-01'' END prod_date
				FROM 
				'+@calc_result_table+' 			
				 WHERE 
					is_final_result = ''y''
					AND counterparty_id = a.counterparty_id
					AND contract_id = a.contract_id
					AND invoice_Line_item_id = a.invoice_Line_item_id
					AND ISNULL([source_deal_detail_id],-1)=ISNULL(a.[source_deal_detail_id],-1)
					AND ISNULL([source_deal_header_id],-1)=ISNULL(a.[source_deal_header_id],-1)	
				GROUP BY CASE invoice_granularity WHEN 980 THEN cast(Year(prod_date) as varchar) + ''-'' + cast(Month(prod_date) as varchar) + ''-01'' 
						WHEN 981 THEN prod_date
						WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', prod_date), ''19050101'')
						WHEN 991 THEN cast(Year(prod_date) as varchar) + ''-'' + cast(CASE datepart(q,prod_date) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
						WHEN 992 THEN cast(Year(prod_date) as varchar) + ''-'' + cast(CASE datepart(q, prod_date) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
						WHEN 993 THEN cast(Year(prod_date) as varchar) + ''-01-01'' END						 			
				)	b	
			INNER JOIN '+@table_calc_invoice_volume_variance+' civv ON a.counterparty_id=civv.counterparty_id
				AND ((a.contract_id=civv.contract_id AND civv.netting_group_id IS NULL) OR (civv.netting_group_id = a.netting_group_id))
				AND a.counterparty_id=civv.counterparty_id
				AND civv.prod_date = b.prod_date
				AND ((tf.neting_rule=''n'' AND civv.invoice_type=ISNULL(tf.document_type,CASE WHEN b.formula_eval_value<0 THEN '''+@ir_sign+''' ELSE '''+@ir_sign_rev+''' END)) OR tf.neting_rule=''y'')	
				AND ISNULL(tf.invoice_template_id,-1) = ISNULL(civv.invoice_template_id,-1)

		WHERE 1=1 
				AND civv.as_of_date='''+CAST(@as_of_date AS VARCHAR)+'''
				AND CONVERT(VARCHAR(7),'+CASE WHEN @date_type='s' THEN 'civv.settlement_date' ELSE 'civv.prod_date' END +',120) BETWEEN  '''+CONVERT(VARCHAR(7),@prod_date,120)+''' AND '''+CONVERT(VARCHAR(7),@prod_date_to,120)+'''
				'+CASE WHEN @invoice_line_item_id IS NOT NULL THEN +' AND a.invoice_Line_item_id IN ('+@invoice_line_item_id +')' ELSE '' END
				 +CASE WHEN @calc_id IS NOT NULL THEN ' AND civv.calc_id IN ('+@calc_id+ ')' ELSE '' END 		    
	
	EXEC(@stmt)
	

	EXEC('DELETE FROM '+@calc_result_table+' WHERE calc_id IS NULL ')
	
	SET @stmt = ' DELETE civ
		FROM
				'+@calc_result_table+' a (nolock)
				INNER JOIN calc_invoice_volume civ  (nolock) ON civ.calc_id=a.calc_id
					AND civ.invoice_Line_item_id=a.invoice_Line_item_id			
			WHERE
				a.is_final_result=''y''
				AND ISNULL(civ.manual_input,''n'') = ''n'' '
	EXEC(@stmt)


	SET @stmt = ' DELETE cfv
		FROM
				'+@calc_result_table+' a 
				INNER JOIN calc_formula_value cfv (nolock) ON cfv.calc_id=a.calc_id
					AND cfv.invoice_line_item_id = a.invoice_Line_item_id
					AND cfv.prod_date = a.prod_date
			WHERE 1=1 
				'+CASE WHEN @invoice_line_item_id IS NOT NULL THEN +' AND a.invoice_Line_item_id IN ('+@invoice_line_item_id +')' ELSE '' END
	EXEC(@stmt)					


	SET @stmt = '
		INSERT INTO '+cast(@table_calc_invoice_volume AS VARCHAR(max))+'(
					calc_id,
					invoice_Line_item_id,
					prod_date,
					[Value],
					Volume,
					price_or_formula					
				)
		SELECT
			a.calc_id,
			a.invoice_Line_item_id,
			civv.prod_date,
			SUM(a.formula_eval_value),
			0,
			''f''
		FROM
			'+@calc_result_table+' a
			LEFT JOIN calc_invoice_volume_variance civv ON 	civv.calc_id = a.calc_id		
		WHERE
			a.is_final_result=''y''
		GROUP BY a.invoice_line_item_id,a.calc_id,civv.prod_date'

		EXEC(@stmt)




---############ update calc_invoice_volume with volume whose value_id=12000


		SET @stmt = '
		UPDATE civ
			SET civ.volume = a.volume
		FROM
		(
		SELECT 
			a.calc_id,a.invoice_line_item_id,SUM(CAST(a.formula_eval_value AS FLOAT)) volume
		FROM
				'+@calc_result_table+' a
				INNER JOIN formula_nested fn ON fn.formula_group_id = a.formula_id
					AND fn.sequence_order = a.formula_sequence_number
					AND fn.show_value_id=1200
			GROUP BY a.invoice_line_item_id,a.calc_id,dbo.FNAGETContractMonth(a.prod_date),a.invoice_line_item_id
		) a
		INNER JOIN '+@table_calc_invoice_volume+' civ ON civ.calc_id=a.calc_id	
			AND civ.invoice_line_item_id = a.invoice_line_item_id		
		
		'

		EXEC(@stmt)
		



		SET @stmt = '
		INSERT INTO '+cast(@table_calc_formula_value AS VARCHAR(max))+'(
				calc_id,
				counterparty_id,
				contract_id,
				formula_id,
				deal_id,
				invoice_line_item_id,
				seq_number,
				prod_date,
				[hour],
				[qtr],
				[half],
				[value],
				[volume],
				formula_str_eval,
				commodity_id,
				granularity,
				is_final_result,
				is_dst,
				source_deal_header_id,
				allocation_volume
			)
			SELECT 	
				a.calc_id,
				a.counterparty_id,
				a.contract_id,
				a.formula_id,
				a.source_deal_detail_id,
				a.invoice_line_item_id,
				a.formula_sequence_number,
				a.prod_date,
				[hour],
				a.mins,
				NULL,
				a.formula_eval_value,
				a.volume,
				ISNULL(a.eval_string,''''),
				a.commodity_id,
				a.granularity,
				a.is_final_result,
				a.is_dst,
				a.source_deal_header_id,
				a.allocation_volume
			FROM
			'+@calc_result_table+' a '	
	
	--print @stmt
	EXEC(@stmt)

	
		    		
	SET @stmt = '
			
		UPDATE cfv
			SET cfv.volume = a.formula_eval_value
		FROM
				'+@calc_result_table+' a
				INNER JOIN formula_nested fn ON fn.formula_group_id = a.formula_id
					AND fn.sequence_order = a.formula_sequence_number
					AND fn.show_value_id=1200
				INNER JOIN calc_formula_value cfv  (nolock) ON
					cfv.calc_id = a.calc_id
					AND cfv.invoice_line_item_id = a.invoice_Line_item_id
					AND cfv.prod_date = a.prod_date
					--AND cfv.seq_number = fn.sequence_order
					AND ISNULL(cfv.hour,0) = ISNULL(a.hour,0)
					AND ISNULL(cfv.qtr,0) = ISNULL(a.mins,0)
					AND ISNULL(cfv.source_deal_header_id,-1)= ISNULL(a.source_deal_header_id,-1)
					AND ISNULL(cfv.deal_id,-1)= ISNULL(a.source_deal_detail_id,-1)
					AND ISNULL(cfv.is_dst,0) = ISNULL(a.is_dst,0) '
				
	EXEC(@stmt)
	
	-- Delete from calc_invoice if value is 0 for standard contracts
	SET @stmt = ' DELETE civ 
		FROM (SELECT DISTINCT contract_id,counterparty_id,settlement_date,deal_term_start,invoice_granularity FROM #temp_deals) a 
		INNER JOIN '+@table_calc_invoice_volume_variance+' civv ON civv.counterparty_id = a.counterparty_id
			AND civv.contract_id = a.contract_id
			AND civv.as_of_date='''+CAST(@as_of_date AS VARCHAR)+'''
			'+CASE WHEN @date_type='s' THEN ' AND civv.settlement_date = a.settlement_date' ELSE ' AND civv.prod_date = CASE a.invoice_granularity WHEN 980 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(Month(a.deal_term_start) as varchar) + ''-01'' 
				WHEN 981 THEN a.deal_term_start
				WHEN 990 THEN DATEADD(WEEK, DATEDIFF(WEEK, ''19050101'', a.deal_term_start), ''19050101'')
				WHEN 991 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q,a.deal_term_start) WHEN 1 THEN ''01'' WHEN 2 THEN ''04'' WHEN 3 THEN ''07'' ELSE ''10'' END as varchar) + ''-01'' 
				WHEN 992 THEN cast(Year(a.deal_term_start) as varchar) + ''-'' + cast(CASE datepart(q, a.deal_term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
				WHEN 993 THEN cast(Year(a.deal_term_start) as varchar) + ''-01-01'' END' END +'
			'+CASE WHEN @calc_id IS NOT NULL THEN ' AND civv.calc_id IN ('+@calc_id+ ')' ELSE '' END +'
		INNER JOIN '+@table_calc_invoice_volume+' civ ON civ.calc_id = civv.calc_id
		INNER JOIN contract_group cg ON cg.contract_id = a.contract_id
		WHERE civ.Value = 0 AND ISNULL(cg.contract_type_def_id,38400) = 38400 '
	EXEC(@stmt)		
	
	

	
	-- Delete from summary if detail is no calculated
	SET @stmt = ' DELETE civv 
		FROM #temp_deals a 
		INNER JOIN '+@table_calc_invoice_volume_variance+' civv ON civv.counterparty_id = a.counterparty_id
		LEFT JOIN '+@table_calc_invoice_volume+' civ ON civ.calc_id = civv.calc_id
		WHERE civ.calc_id IS NULL '
	EXEC(@stmt)		

	


	-- Update the invoice type of the invoice
	CREATE TABLE #calc_summary(calc_id INT,counterparty_id INT,contract_id INT, netting_group_id INT)
	SET @stmt = ' 
	UPDATE civv WITH(UPDLOCK) SET civv.invoice_type = a.inv_type,
				civv.prod_date_to =  CASE a.invoice_granularity WHEN 980 THEN DATEADD(m,1,CAST(CONVERT(VARCHAR(7),civv.prod_date,120)+''-01'' AS DATETIME))-1
						WHEN 981 THEN cfv.mx_prod_date
						WHEN 990 THEN DATEADD(d,6,civv.prod_date)
						WHEN 991 THEN cast(Year(civv.prod_date) as varchar) + ''-'' + cast(CASE datepart(q,civv.prod_date) WHEN 1 THEN ''03-31'' WHEN 2 THEN ''06-30'' WHEN 3 THEN ''10-31'' ELSE ''12-31'' END  as varchar) 
						WHEN 992 THEN cast(Year(civv.prod_date) as varchar) + ''-'' + cast(CASE datepart(q,civv.prod_date) WHEN 1 THEN ''-06-30'' WHEN 2 THEN ''-06-30'' ELSE ''-12-31'' END as varchar)
						WHEN 993 THEN cast(Year(civv.prod_date) as varchar) + ''-12-31'' END							
		output inserted.calc_id,inserted.counterparty_id,inserted.contract_id,inserted.netting_group_id into #calc_summary	
		FROM(
			SELECT ISNULL(a.document_type,inv_type) inv_type,civv.calc_id,invoice_granularity 
			FROM (SELECT DISTINCT counterparty_id,contract_id,netting_group_id,invoice_granularity,document_type FROM #temp_deals) a 
				INNER JOIN '+@table_calc_invoice_volume_variance+' civv  ON civv.counterparty_id = a.counterparty_id
						AND ((a.contract_id=civv.contract_id AND a.netting_group_id IS NULL)  OR (civv.netting_group_id = a.netting_group_id))
						AND CONVERT(VARCHAR(7),'+CASE WHEN @date_type='s' THEN 'civv.settlement_date' ELSE 'civv.prod_date' END +',120) = '''+CONVERT(VARCHAR(7),@prod_date,120)+'''
						AND civv.as_of_date = '''+CAST(@as_of_date AS VARCHAR)+'''
						'+CASE WHEN @calc_id IS NOT NULL THEN ' AND civv.calc_id IN ('+@calc_id+ ')' ELSE '' END +'
				CROSS APPLY(SELECT CASE WHEN SUM(value)<0 THEN '''+@ir_sign+''' ELSE '''+@ir_sign_rev+''' END inv_type FROM '+(@table_calc_invoice_volume)+' WHERE calc_id=civv.calc_id) civ
		) a INNER JOIN '+@table_calc_invoice_volume_variance+' civv ON a.calc_id = civv.calc_id
		OUTER APPLY(SELECT MAX(prod_date) mx_prod_date FROM calc_formula_value WHERE calc_id=civv.calc_id) cfv
		'
	EXEC(@stmt)


	

	--EXEC('UPDATE invoice_seed WITH(UPDLOCK) SET last_invoice_number = (SELECT ISNULL(MAX(CAST(invoice_number AS INT)),0) FROM   '+@table_calc_invoice_volume_variance+')')



	
	--#################### Netting logic if individual invoice is to be created
	CREATE TABLE #calc_netting_summary(calc_id INT,counterparty_id INT,contract_id INT,netting_group_id INT)

	SET @stmt = ' 
	UPDATE civv set civv.netting_group_id  = civv2.netting_group_id
		OUTPUT inserted.calc_id,inserted.counterparty_id,inserted.contract_id,inserted.netting_group_id into #calc_netting_summary	
	FROM 
	'+@table_calc_invoice_volume_variance+'  civv
	CROSS APPLY(
		select 
			cs.counterparty_id,ng.netting_group_id,civv.prod_date,civv.as_of_date
		FROM 
			#calc_summary cs 
			INNER JOIN netting_group_detail ngd ON ngd.source_counterparty_id = cs.counterparty_id
			INNER JOIN netting_group ng ON ng.netting_group_id = ngd.netting_group_id AND ng.netting_parent_group_id = -1 AND ng.create_individual_invoice = 1
			INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id = ngd.netting_group_detail_id AND ngdc.source_contract_id = cs.contract_id
			INNER JOIN '+@table_calc_invoice_volume_variance+'  civv1 ON civv1.calc_id = cs.calc_id
			CROSS APPLY(SELECT MAX(effective_date) effective_date FROM netting_group ng1 INNER JOIN netting_group_detail ngd1 ON ng1.netting_group_id = ngd1.netting_group_id AND ng1.netting_parent_group_id = -1 
				WHERE ng1.effective_date <=  civv.prod_date  AND  ngd1.source_counterparty_id = civv.counterparty_id AND ngd1.netting_group_id=ng.netting_group_id) ng2
		WHERE
			cs.counterparty_id = civv.counterparty_id
			AND ng.netting_group_id = civv.netting_group_id
			AND civv1.prod_date = civv.prod_date
			AND civv1.as_of_date = civv.as_of_date
			AND ng.effective_date = ng2.effective_date
		GROUP BY 	
			cs.counterparty_id,ng.netting_group_id,civv1.prod_date,civv1.as_of_date	
	)civv2
	WHERE
		civv.netting_group_id IS NOT NULL '

	EXEC(@stmt)
	
	

	
	SET @stmt = ' 	
		INSERT INTO '+@table_calc_invoice_volume_variance+'(as_of_date,counterparty_id,generator_id,contract_id,prod_date,metervolume,invoicevolume,allocationvolume,uom,invoice_type,netting_group_id,prod_date_to,settlement_date,invoice_template_id)
			OUTPUT inserted.calc_id,inserted.counterparty_id,inserted.contract_id,inserted.netting_group_id into #calc_netting_summary	
		SELECT 
			MAX(civv.as_of_date),
			civv.counterparty_id,
			MAX(civv.generator_id),
			MAX(civv.contract_id),
			MAX(civv.prod_date),
			SUM(civv.metervolume),
			SUM(civv.invoicevolume),
			SUM(civv.allocationvolume),
			MAX(civv.uom),
			MAX(civv.invoice_type),
			ng.netting_group_id,
			MAX(civv.prod_date_to),
			MAX(civv.settlement_date),
			MAX(ng.invoice_template)
		FROM
			#calc_summary cs 
			INNER JOIN netting_group_detail ngd ON ngd.source_counterparty_id = cs.counterparty_id
			INNER JOIN netting_group ng ON ng.netting_group_id = ngd.netting_group_id AND ng.netting_parent_group_id = -1 AND ng.create_individual_invoice = 1
			INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id = ngd.netting_group_detail_id AND ngdc.source_contract_id = cs.contract_id
			INNER JOIN calc_invoice_volume_variance civv ON civv.calc_id = cs.calc_id
			CROSS APPLY(SELECT MAX(effective_date) effective_date FROM netting_group ng1 INNER JOIN netting_group_detail ngd1 ON ng1.netting_group_id = ngd1.netting_group_id AND ng1.netting_parent_group_id = -1 
				WHERE ng1.effective_date <=  civv.prod_date  AND  ngd1.source_counterparty_id = civv.counterparty_id AND ngd1.netting_group_id=ng.netting_group_id) ng2
			LEFT JOIN '+@table_calc_invoice_volume_variance+' civv1 ON civv.counterparty_id= civv1.counterparty_id
				AND  ng.netting_group_id = civv1.netting_group_id
				AND civv.prod_date= civv1.prod_date
				AND civv.as_of_date= civv1.as_of_date
		WHERE
			civv1.calc_id IS NULL AND ng.effective_date = ng2.effective_date
		GROUP BY 
			ng.netting_group_id,civv.counterparty_id '
	
	EXEC(@stmt)

	SET @stmt = ' 	DELETE civ FROM '+@table_calc_invoice_volume+' civ INNER JOIN #calc_netting_summary cns ON civ.calc_id = cns.calc_id '
	EXEC(@stmt)

	UPDATE cs
		SET	cs.netting_group_id =  ng.netting_group_id
	FROM 
		#calc_summary cs
		INNER JOIN netting_group_detail ngd ON ngd.source_counterparty_id = cs.counterparty_id
		INNER JOIN netting_group ng ON ng.netting_group_id = ngd.netting_group_id AND ng.netting_parent_group_id = -1 AND ng.create_individual_invoice = 1
		INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id = ngd.netting_group_detail_id AND ngdc.source_contract_id = cs.contract_id
		


	SET @stmt = ' 	
		INSERT INTO '+@table_calc_invoice_volume+'(calc_id,invoice_line_item_id,prod_date,	Value, Volume, uom_id)
		SELECT 
			cns.calc_id,
			civ.invoice_line_item_id,
			civ.prod_date,	
			SUM(civ.Value), 
			SUM(civ.Volume), 
			SUM(civ.uom_id)
		FROM
			#calc_netting_summary cns
			INNER JOIN #calc_summary cs ON cns.counterparty_id = cs.counterparty_id AND  cs.netting_group_id = cns.netting_group_id
			INNER JOIN calc_invoice_volume civ ON civ.calc_id = cs.calc_id		
		GROUP BY 
			cns.calc_id, civ.invoice_line_item_id,civ.prod_date '

	EXEC(@stmt)


	
	SET @stmt = ' 
		UPDATE civv	
			SET civv.netting_calc_id = cns.calc_id
		FROM 
			'+@table_calc_invoice_volume_variance+' civv
			INNER JOIN #calc_summary cs ON civv.calc_id = cs.calc_id
			INNER JOIN #calc_netting_summary cns ON cns.counterparty_id = cs.counterparty_id AND  cs.netting_group_id = cns.netting_group_id
		WHERE
			civv.netting_group_id IS NULL
		'
	EXEC(@stmt)

	
	--#################### Netting logic END


		--EXEC spa_calc_true_up @prod_date, @prod_date_to, @as_of_date,@contract_id_param, @counterparty_id
		--##########call true up calc


	IF (@call_from_true_up = 'n')
	BEGIN
			--SELECT * FROM #temp_formula WHERE is_true_up ='y'
			SET @stmt = ' spa_calc_true_up '''+CONVERT(VARCHAR(10),@prod_date,120)+''',''' +CONVERT(VARCHAR(10),@prod_date_to,120)+''',''' +CONVERT(VARCHAR(10),@as_of_date,120)+''',''' +ISNULL(@contract_id_param,'NULL')+''',''' +ISNULL(@counterparty_id,'NULL')+''''
			--SELECT @stmt			
			SET @job_name = 'TrueUPCalc_' + dbo.FNAGetNewID()
			EXEC spa_run_sp_as_job @job_name,  @stmt, 'True UP Calc', @user_name
			--EXEC spa_calc_true_up @prod_date, @prod_date_to, @as_of_date, @contract_id_param, @counterparty_id, @process_id, @settlement_adjustment, @estimate_calculation, @module_type, @deal_set_calc, @cpt_type, @date_type
	END


	--INSERT INTO calc_formula_value(calc_id,invoice_line_item_id,seq_number,	

	-- Update invoice number 
     SET @stmt = '
	    UPDATE calc WITH(UPDLOCK) SET calc.invoice_number = calc.calc_id
	    FROM   (
				SELECT ROW_NUMBER() OVER(ORDER BY civv.calc_id) invoice_index,
						civv.calc_id,
					  civv.invoice_number,
					  is1.last_invoice_number
				FROM   ' + @table_calc_invoice_volume_variance + ' civv
					  CROSS APPLY invoice_seed is1
				WHERE  civv.invoice_number IS NULL
			 ) calc'
	EXEC (@stmt)	




SET @stmt = '
		INSERT INTO '+@calc_result_table+'(source_id,counterparty_id,contract_id,formula_id,formula_sequence_number,invoice_line_item_id,invoice_line_item_seq_id,prod_date,as_of_date,formula_eval_value,volume,is_final_result,granularity,source_deal_header_id,source_deal_detail_id,calc_id)
		SELECT 
			ili.calc_id,civv.counterparty_id,civv.contract_id,tf.formula_id,tf.formula_sequence_number,tf.invoice_line_item_id,tf.invoice_line_item_sequence_number,ili.prod_date,civv.as_of_date,ili.value,ili.volume,''y'',tf.granularity,ili.source_deal_header_id,ili.source_deal_detail_id,ili.calc_id
		FROM 
			#impact_line_items ili
			INNER JOIN '+@table_calc_invoice_volume_variance+' civv ON civv.calc_id = ili.calc_id
			INNER JOIN '+@table_calc_invoice_volume+' civ On civ.calc_id = ili.calc_id
			INNER JOIN #temp_formula tf oN tf.contract_id = civv.contract_id AND tf.invoice_line_item_id = civ.invoice_line_item_id
		WHERE
			tf.contract_calc_type = ''c'' '

EXEC(@stmt)
		-- Excel add-in calculation
		-- Run Excel base calculation if any charge type of contract is defined as excel data component
		IF EXISTS(
		       SELECT TOP 1 dcd.data_component_detail_id
		       FROM   contract_group AS cg
		              INNER JOIN contract_group_detail AS cgd
		                   ON  cg.contract_id = cgd.contract_id
		              INNER JOIN dbo.FNASplit(@contract_id_param, ',') AS f
		                   ON  cg.contract_id = f.item
		              INNER JOIN data_component_detail AS dcd
		                   ON  cgd.ID = dcd.contract_group_detail_id
		   )
		BEGIN
		    IF OBJECT_ID('tempdb..#excel_addin_calc_status') IS NOT NULL
		        DROP TABLE #excel_addin_calc_status
		    
		    CREATE TABLE #excel_addin_calc_status
		    (
		    	result VARCHAR(200)
		    )
		    
		    INSERT INTO #excel_addin_calc_status
		    EXEC spa_excel_addin_settlement_process @flag = 'r',
		         @counterparty_id = @counterparty_id,
		         @contract_id = @contract_id_param,
		         @prod_date = @prod_date,
		         @prod_date_to = @prod_date_to,
		         @as_of_date = @as_of_date,
		         @unique_process_id = @excel_calc_process_id
		    
		    
		    UPDATE civv
		    SET    civv.calculated_excel_file = @excel_calc_process_id + '.xlsx'
		    FROM   Calc_invoice_Volume_variance AS civv
		          
		    WHERE  civv.prod_date = @prod_date
		           AND civv.prod_date_to = @prod_date_to
		           AND civv.as_of_date = @as_of_date
		           AND civv.counterparty_id = @counterparty_id
		           AND civv.contract_id = @contract_id_param
		END
		
		
	--IF EXISTS(SELECT 'X' FROM #invoice_seed)
	--	EXEC('UPDATE invoice_seed WITH(UPDLOCK) SET last_invoice_number = (SELECT MAX(invoice_id) FROM   #invoice_seed)')		

----**********************************

	--print 'calculation Completed'+': '+cast(datediff(ss,@calc_time,getdate()) as varchar) +'*************************************'
	set @calc_time=getdate()
	 DECLARE @error_count VARCHAR(50) 
	 SET  @error_count = ''
	--SELECT  *  FROM process_settlement_invoice_log 
	 SELECT @error_count =  code  FROM process_settlement_invoice_log WHERE	process_id = @test_process_id
	-- PRINT 	@error_count +'www'
	--IF (@error_count = '')
	BEGIN
		 --if data not found for counterparty generate error
	-- Suppress data not found error if excel based calculation is run
	IF NOT EXISTS(
		       SELECT TOP 1 dcd.data_component_detail_id
		       FROM   contract_group AS cg
		              INNER JOIN contract_group_detail AS cgd
		                   ON  cg.contract_id = cgd.contract_id
		              INNER JOIN dbo.FNASplit(@contract_id_param, ',') AS f
		                   ON  cg.contract_id = f.item
		              INNER JOIN data_component_detail AS dcd
		                   ON  cgd.ID = dcd.contract_group_detail_id
	)
	BEGIN
	SET @stmt='
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
			'''+@test_process_id+''',
			''Warning'',
			'''+@model_name+''',
			sc.source_counterparty_id,
			dbo.FNAGetcontractMonth('''+CAST(@prod_date AS VARCHAR)+'''),
			''Data not found for '+CASE WHEN @cpt_type = 'm' THEN 'Model Group' ELSE 'counterparty' END +':''+sc.counterparty_name+'' and '+CASE WHEN @cpt_type = 'm' THEN 'Model' ELSE 'contract' END +': '' + ISNULL(cg.contract_name,'''') + '' for the '+CASE WHEN @date_type='s' THEN 'settlement' ELSE 'production' END+' month:'+dbo.FNAGetcontractMonth(@prod_date)+'.'',
			''Please Check Data''
		FROM counterparty_contract_address AS cca
			INNER JOIN #cpty cpt ON cca.counterparty_id = cpt.counterparty_id AND dbo.FNAGetcontractMonth('''+CAST(@prod_date AS VARCHAR)+''') BETWEEN cca.contract_start_date AND cca.contract_end_date 
			LEFT JOIN '+@table_calc_invoice_volume_variance+' civv ON civv.counterparty_id = cpt.counterparty_id AND civv.contract_id = cca.contract_id AND '+CASE WHEN @date_type='s' THEN 'dbo.FNAGetcontractMonth(civv.settlement_date)' ELSE 'civv.prod_date' END +'=dbo.FNAGetcontractMonth('''+CAST(@prod_date AS VARCHAR)+''')
			LEFT JOIN source_counterparty AS sc ON cpt.counterparty_id = sc.source_counterparty_id
			LEFT JOIN contract_group AS cg ON cca.contract_id = cg.contract_id
		WHERE cca.contract_id IN (' + @contract_id_param + ')
			AND civv.contract_id IS NULL AND civv.counterparty_id IS NULL'
		
		EXEC(@stmt)
	END
	
		
		SET @stmt='
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
			'''+@test_process_id+''',
			''Success'',
			'''+@model_name+''',
			sc.source_counterparty_id,
			dbo.FNAGetcontractMonth('''+CAST(@prod_date AS VARCHAR)+'''),
			'''+@model_name+' completed for '+CASE WHEN @cpt_type = 'm' THEN 'Model Group' ELSE 'counterparty' END +':''+sc.counterparty_name+'' and '+CASE WHEN @cpt_type = 'm' THEN 'Model' ELSE 'contract' END +':'' + ISNULL(cg.contract_name,'''') + '' for the '+CASE WHEN @date_type='s' THEN 'settlement' ELSE 'production' END+' month:'+dbo.FNAGetcontractMonth(@prod_date)+'.'',
			''Please Check Data''
		FROM   
			#calc_summary civv
			INNER JOIN source_counterparty sc ON sc.source_counterparty_id = civv.counterparty_id
			INNER JOIN contract_group cg on cg.contract_id =civv.contract_id
			INNER JOIN ' + @table_calc_invoice_volume + ' civ ON civv.calc_id = civ.calc_id ' +
			CASE WHEN @invoice_line_item_id IS NOT NULL THEN 'INNER JOIN dbo.FNASplit(''' + @invoice_line_item_id + ''', '','') f ON civ.invoice_line_item_id = f.item ' ELSE '' END + '
		WHERE 1=1 ' 
		EXEC(@stmt)
		
		
		-- If any uprocessed charge types are found  Case 1 : processed selecting contract , Case 2 : processed selecting chargetypes
		IF OBJECT_ID('tempdb..#unprocessed_chargetypes') IS NOT NULL
			DROP TABLE #unprocessed_chargetypes
			
		CREATE TABLE #unprocessed_chargetypes(contract_id INT, chargetypes VARCHAR(1024))

		IF OBJECT_ID('tempdb..#calc_summary_lineitem') IS NOT NULL
			DROP TABLE #calc_summary_lineitem
		CREATE TABLE #calc_summary_lineitem (counterparty_id INT,contract_id INT,invoice_line_item_id INT)
		SET @stmt1 = ' INSERT INTO #calc_summary_lineitem  SELECT DISTINCT civv.counterparty_id,civv.contract_id,civ.invoice_line_item_id
		from 
		#calc_summary cs
		INNER JOIN calc_invoice_volume_variance civv ON civv.calc_id = cs.calc_id 
		INNER JOIN ' + @table_calc_invoice_volume + ' civ ON civ.calc_id = civv.calc_id	'

		EXEC(@stmt1)

		SET @stmt1 = '
		INSERT INTO #unprocessed_chargetypes
		SELECT cct.contract_id, CAST(code AS VARCHAR(1024))
         FROM (
		SELECT DISTINCT  cs.counterparty_id,cs.contract_id, cctd.invoice_line_item_id,
		       sdv.code
		FROM   #calc_summary cs
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
		       INNER JOIN #calc_summary cs
		            ON  cs.contract_id = cg.contract_id
				--INNER JOIN calc_invoice_volume civ ON civ.calc_id = cs.calc_id AND civ.invoice_line_item_id = cgd.invoice_line_item_id
		) cct ' +
		CASE WHEN @invoice_line_item_id IS NOT NULL THEN 'INNER JOIN dbo.FNASplit(''' + @invoice_line_item_id + ''', '','') f ON cct.invoice_line_item_id = f.item ' ELSE '' END + '
		LEFT JOIN #calc_summary_lineitem csl ON csl.counterparty_id = cct.counterparty_id AND csl.contract_id = cct.contract_id AND csl.invoice_line_item_id = cct.invoice_line_item_id 
		WHERE csl.invoice_line_item_id IS NULL 
	
		'
		--PRINT @stmt1
		EXEC (@stmt1)
		
		SET @stmt1 = '
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
		SELECT ''' + @test_process_id + ''', ''Warning'', ''' + @model_name + ''', cs.counterparty_id,dbo.FNAGetContractMonth('''+CAST(@prod_date AS VARCHAR)+'''),
		CASE WHEN CHARINDEX('','', uc.chargetypes, 0) <> 0 THEN
		''Some charge types were not processed for counterparty:'' + sc.counterparty_name + '' and contract:'' + cg.[contract_name] COLLATE DATABASE_DEFAULT + ''.('' + uc.chargetypes + '')''
		ELSE uc.chargetypes + '' could not be processed for counterparty:'' + sc.counterparty_name + '' and contract:'' + cg.[contract_name] COLLATE DATABASE_DEFAULT  END + '' for the production month:'' +  dbo.FNAGetcontractMonth('''+CAST(@prod_date AS VARCHAR)+''')
		, ''Please Check Data'' 
		  FROM #calc_summary cs
		INNER JOIN #unprocessed_chargetypes uc ON cs.contract_id = uc.contract_id
		INNER JOIN contract_group cg ON cs.contract_id = cg.contract_id
		INNER JOIN source_counterparty sc on cs.counterparty_id = sc.source_counterparty_id  
		WHERE uc.chargetypes IS NOT NULL '
		--PRINT @stmt1
		EXEC (@stmt1)
		
	--if formula is not evaluated, generate an error
		SET @stmt='
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
                    '''+@test_process_id+''',
                    ''Warning'',
                    '''+@model_name+''',
                    sc.source_counterparty_id,
                    dbo.FNAGetcontractMonth('''+CAST(@prod_date AS VARCHAR)+'''),
                    ''Function evaluation failed for Contract: '' + cg.contract_name + '', Charge Type: '' + sdv.code + '', Row number: '' + CAST(crt.nested_id AS NVARCHAR) + '', Function: '' + crt.func_name + ''.'',
                    ''Please Check formula and Data''
             FROM   
                    '+@calc_result_detail_table+' crt
                    INNER JOIN source_counterparty sc ON crt.counterparty_id = sc.source_counterparty_id
                    INNER JOIN contract_group cg ON crt.contract_id = cg.contract_id 
                    INNER JOIN static_data_value sdv ON sdv.value_id = crt.invoice_line_item_id
             WHERE 
                    eval_value IS NULL'
        --PRINT @stmt
        EXEC(@stmt)
	
	END	
		  
								
END TRY
BEGIN CATCH
	--DEALLOCATE cursor2
	--DEALLOCATE cursor1

	IF CURSOR_STATUS('global','cursor2')>=-1
	BEGIN
	 DEALLOCATE cursor2
	END
	IF CURSOR_STATUS('global','cursor1')>=-1
	BEGIN
	 DEALLOCATE cursor1
	END

	SET @desc =   ERROR_MESSAGE()
	--PRINT @desc
	
	SELECT @stmt='
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
			'''+@test_process_id+''',
			''Error'',
			''Process Settlement'',
			-1,
			dbo.FNAGetcontractMonth('''+CAST(@prod_date AS VARCHAR)+'''),
			'''+@model_name+' Failed.'+REPLACE(@desc,'''','')+''',
			''Please Check Data'''	
	EXEC(@stmt) 
	
	

END CATCH

