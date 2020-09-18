/****** Object:  StoredProcedure [dbo].[spa_calculate_formula]    Script Date: 12/27/2013 12:30:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_calculate_formula]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_calculate_formula]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Evaluate formula used in the system .
	
	Parameters : 
	@as_of_date : As Of Date for formula evaluation
	@calc_process_table : List items of Process Table to evaluate formula
	@process_id : Process Id that used in formula evaluation
	@calc_result_table : Evaluated summary output result table
	@calc_result_detail_table : Evaluated detail output result table
	@estimate_calculation : Externally pass parameter estimate calculation to the function in formula
	@formula_audit : Maintain formula changed audit
	@call_from : Evaluation Type
							- 'm' - MTM 
							- 's' - Settlement 
							- 'd' - Derive Curve
							- 'w' - Whatif
	@simulation_curve_criteria : Externally pass parameter Simulation Curve Criteria to the function in formula
	@cpt_model_type : Externally pass parameter Cpt Model Type to the function in formula
	@calc_type :  Source caller
							- 'm' - MTM 
							- 's' - Settlement 
	@single_row_return_formula : Single Row Return Formula
	@asofdate_to : To as of date for rqm of Mocoh to evaluate UDSQL

*/	

CREATE PROC [dbo].[spa_calculate_formula]
	@as_of_date VARCHAR(MAX),
	@calc_process_table VARCHAR(MAX),
	@process_id VARCHAR(100),
	@calc_result_table VARCHAR(100) OUTPUT,
	@calc_result_detail_table VARCHAR(100)  = NULL OUTPUT,
	@estimate_calculation CHAR(1) = 'n',
	@formula_audit CHAR(1) = 'n', --this option will be used by SP calc explain mtm for opening balance mtm calculation
	@call_from CHAR(1) = NULL, -- 'd' - derive curve
	@simulation_curve_criteria INT = 0,
	@cpt_model_type CHAR(1) = NULL, -- indicates if this is the financial model calculations
	@calc_type varchar(1)=NULL --s=when call from settlement calculation, in this case curve value will be taken from settlement curve id while evaluating curve functions.
	,@single_row_return_formula VARCHAR(1)=NULL
	,@asofdate_to VARCHAR(100) = NULL -- Added after rqm of Mocoh necessary to evaluate UDSQL. 
	,@prod_date_to VARCHAR(10) = NULL
AS
	
BEGIN
/*
	

BEGIN

IF OBJECT_ID('tempdb..#temp_formula_calculations_value') IS NOT NULL DROP TABLE #temp_formula_calculations_value
IF OBJECT_ID('tempdb..#formula_breakdown') IS NOT NULL DROP TABLE #formula_breakdown
IF OBJECT_ID('tempdb..#whatif_shift') IS NOT NULL DROP TABLE #whatif_shift
IF OBJECT_ID('tempdb..#temp_cfv') IS NOT NULL DROP TABLE #temp_cfv
IF OBJECT_ID('tempdb..#temp_UD_sql') IS NOT NULL DROP TABLE #temp_UD_sql
IF OBJECT_ID('tempdb..#formula_breakdown_pt') IS NOT NULL DROP TABLE #formula_breakdown_pt
IF OBJECT_ID('tempdb..#temp_formula_calculations_value') IS NOT NULL  DROP TABLE #temp_formula_calculations_value
IF OBJECT_ID('tempdb..#formula_nested_audit') IS NOT NULL DROP TABLE  #formula_nested_audit
IF OBJECT_ID('tempdb..#formula_nested_audit') IS NOT NULL DROP TABLE  #formula_nested_audit
IF OBJECT_ID('tempdb..#tmp_next_level_func_args') IS NOT NULL DROP TABLE #tmp_next_level_func_args
IF OBJECT_ID('tempdb..#formula_breakdown_audit') IS NOT NULL DROP TABLE #formula_breakdown_audit
IF OBJECT_ID('tempdb..#tmp_formula_ids') IS NOT NULL DROP TABLE #tmp_formula_ids
IF OBJECT_ID('tempdb..#list_replace_variable') IS NOT NULL DROP TABLE #list_replace_variable
IF OBJECT_ID('tempdb..#formula_function_mapping') IS NOT NULL DROP TABLE #formula_function_mapping
IF OBJECT_ID('tempdb..#UD_function_name') IS NOT NULL DROP TABLE #UD_function_name
IF OBJECT_ID('tempdb..#ud_function_param_value') IS NOT NULL DROP TABLE #ud_function_param_value
IF OBJECT_ID('tempdb..#ud_function_param') IS NOT NULL DROP TABLE #ud_function_param
IF OBJECT_ID('tempdb..#ud_function_evaluation') IS NOT NULL DROP TABLE #ud_function_evaluation


SET nocount off	
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo

--UPDATE adiha_process.dbo.curve_formula_table_farrms_admin_F711CE0E_6D23_4AE3_A780_26A84F478D6A SET hour=NULL

DECLARE @as_of_date VARCHAR(MAX)='2018-01-31',
	@calc_process_table VARCHAR(MAX)='adiha_process.dbo.curve_formula_table_dev_admin_688A3ED0_571B_49F6_A21B_D1FEBEE32773',
	@process_id VARCHAR(100)=NULL,
	@calc_result_table VARCHAR(100) ,
	@calc_result_detail_table VARCHAR(100)  = NULL ,
	@estimate_calculation CHAR(1) = 'n'
	,@formula_audit CHAR(1) = 'n'
	,@call_from CHAR(1) = 'm', -- 'd' - derive curve
	 @simulation_curve_criteria INT = null,
	 @cpt_model_type CHAR(1) = NULL -- indicates if this is the financial model calculations
	,@calc_type varchar(1)=NULL
	,@single_row_return_formula VARCHAR(1)='n'
	,@asofdate_to VARCHAR(100) = NULL
	,@prod_date_to VARCHAR(10) = NULL
SELECT @process_id = dbo.FNAGetNewID()


	--*/
	
	
/*
-- DROP TABLE adiha_process.dbo.curve_formula_table_farrms_admin_F711CE0E_6D23_4AE3_A780_26A84F478D6
SELECT  *
FROM   adiha_process.dbo.curve_formula_table_ashrestha_6C1C2614_C98F_4BE5_AFE2_9CE77A7BAD23

where --nested_id=3 and 
prod_date='2016-01-01' and 00:15:00.000
DELETE FROM adiha_process.dbo.curve_formula_table_farrms_admin_F711CE0E_6D23_4AE3_A780_26A84F478D6

SELECT  *
FROM    #formula_breakdown 
where prod_date='2016-01-01' and nested_id=3 and
 final_date='2016-01-01 00:30:00.000'

select * from source_deal_detail where source_deal_header_id=219929

CREATE TABLE adiha_process.dbo.curve_formula_table_farrms_admin_F711CE0E_6D23_4AE3_A780_26A84F478D6(
			rowid int IDENTITY(1,1),
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
			source_deal_header_id INT,
			term_start DATETIME,
			term_end DATETIME
		)

INSERT INTO adiha_process.dbo.curve_formula_table_farrms_admin_F711CE0E_6D23_4AE3_A780_26A84F478D6
SELECT 	sdh.counterparty_id, sdh.contract_id, sdd.curve_id, cast(sdd.term_start as date), sdh.deal_date, sdd.deal_volume, NULL onPeakVolume, sdd.source_deal_detail_id,
		sdd.position_formula_id, NULL invoice_Line_item_id, NULL invoice_line_item_seq_id, NULL price, sdht.hourly_position_breakdown granularity, NULL volume_uom_id,
		NULL generator_id, NULL [hour],sdh.commodity_id, NULL meter_id, 4500 curve_source_value_id, NULL [mins], sdh.source_deal_header_id, sdd.term_start, sdd.term_end		
		FROM  source_deal_header sdh
		INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id	
	WHERE sdh.source_deal_header_id=219929

*/	


EXEC spa_print '@as_of_date:', @as_of_date
EXEC spa_print '@calc_process_table:', @calc_process_table
EXEC spa_print '@calc_type:', @calc_type


 DECLARE @max_source_level INT, @invoice_line_item_seq INT

DECLARE @user_login_id       VARCHAR(50),@whatif_shift varchar(250)
DECLARE @i                   INT,
		@max_formula_level   INT,
		@max_nested_level    INT,
		@j                   INT

DECLARE @calc_start_time     DATETIME,
		@sqlstmt             VARCHAR(MAX),
		@sqlstmt1             VARCHAR(MAX),
		@sql1                VARCHAR(MAX),
		@sql2                VARCHAR(MAX),
		@sql3                VARCHAR(MAX),
		@sql4                VARCHAR(MAX),
		@sql5                VARCHAR(MAX),
		@sql6                VARCHAR(MAX),
		@sql7                VARCHAR(MAX),			
		@sql8                VARCHAR(MAX),			
		@process_id_avg_curve VARCHAR(200)

DECLARE @granularity         VARCHAR(10),
		@parent_granularity  VARCHAR(10),
		@date_filter         VARCHAR(500)

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET @calc_start_time=GETDATE()
SET @user_login_id=dbo.FNADBUser()

create table #whatif_shift(curve_id int,curve_shift_val float ,curve_shift_per float)
SET @whatif_shift= dbo.FNAProcessTableName('whatif_shift', @user_login_id,@process_id)
EXEC spa_print @whatif_shift
if OBJECT_ID(@whatif_shift) is not null
	exec('insert into #whatif_shift(curve_id,curve_shift_val ,curve_shift_per) select curve_id,curve_shift_val ,curve_shift_per from '+@whatif_shift)

IF @process_id IS NULL
SET @process_id=REPLACE(newid(),'-','_')

IF ISNULL(@call_from, '') <> 'd'
	SET @process_id_avg_curve= @process_id
 
	declare @formula_nested  VARCHAR(100),@formula_breakdown  VARCHAR(100),@curve_shift_val float ,@curve_shift_per float
	
	--select @curve_shift_val=isnull(@curve_shift_val,0)  ,@curve_shift_per=isnull(@curve_shift_per,1)
	
	select @formula_nested='formula_nested',@formula_breakdown='formula_breakdown'
	
	if isnull(@formula_audit,'n')='y'
	begin
		select @formula_nested='#formula_nested_audit',@formula_breakdown='#formula_breakdown_audit'
		select formula_breakdown_id,formula_id,nested_id,formula_level,func_name,arg_no_for_next_func,parent_nested_id,level_func_sno,parent_level_func_sno,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,eval_value,create_user,create_ts,update_user,update_ts,formula_nested_id
		 into  #formula_breakdown_audit from formula_breakdown_audit where 1=2

		select id,sequence_order,description1,description2,formula_id,formula_group_id,granularity,include_item,show_value_id,uom_id,rate_id,total_id,create_user,create_ts,update_user,update_ts,time_bucket_formula_id
		 into  #formula_nested_audit from formula_nested_audit where 1=2

		create table #tmp_formula_ids (formula_id int)
		
		exec('insert into #tmp_formula_ids (formula_id) select distinct formula_id from '+@calc_process_table) 

		set @sql1='insert into #formula_breakdown_audit 
				select a.formula_breakdown_id,a.formula_id,a.nested_id,a.formula_level,a.func_name,a.arg_no_for_next_func,a.parent_nested_id,a.level_func_sno,a.parent_level_func_sno,a.arg1,a.arg2,a.arg3,a.arg4,a.arg5,a.arg6,a.arg7,a.arg8,a.arg9,a.arg10,a.arg11,a.arg12,a.eval_value,a.create_user,a.create_ts,a.update_user,a.update_ts,a.formula_nested_id
			FROM #tmp_formula_ids t 
				cross apply (
				select top 1 *	from formula_breakdown_audit f (nolock) where t.formula_id = f.formula_id 
					AND f.formula_id iS NOT NULL and create_ts<'''+convert(varchar(10),CAST(@as_of_date as datetime)+1,120)+'''
				order by create_ts desc ) a
				
					'
	--	exec spa_print @sql1
		exec(@sql1)
		
		--taking firmula that not exist in audit table
		set @sql1='insert into #formula_breakdown_audit 
				select a.formula_breakdown_id,a.formula_id,a.nested_id,a.formula_level,a.func_name,a.arg_no_for_next_func,a.parent_nested_id,a.level_func_sno,a.parent_level_func_sno,a.arg1,a.arg2,a.arg3,a.arg4,a.arg5,a.arg6,a.arg7,a.arg8,a.arg9,a.arg10,a.arg11,a.arg12,a.eval_value,a.create_user,a.create_ts,a.update_user,a.update_ts,a.formula_nested_id
			FROM #tmp_formula_ids t 
			inner join formula_breakdown a on t.formula_id = a.formula_id 
			left join #formula_breakdown_audit f on t.formula_id=f.formula_id
			where f.formula_id is null
					'
	--	exec spa_print @sql1
		exec(@sql1)
		
		create index indx_formula_breakdown_audit11 on  #formula_breakdown_audit (formula_id) 

		set @sql1='insert into #formula_nested_audit
			select fn.id,fn.sequence_order,fn.description1,fn.description2,fn.formula_id,fn.formula_group_id,fn.granularity,fn.include_item
			,fn.show_value_id,fn.uom_id,fn.rate_id,fn.total_id,fn.create_user,fn.create_ts,fn.update_user,fn.update_ts,fn.time_bucket_formula_id
			FROM #formula_breakdown_audit f 
				cross apply
				(select sequence_order,max(create_ts) create_ts from  formula_nested_audit a  where a.formula_group_id = f.formula_id  
					and create_ts<'''+convert(varchar(10),CAST(@as_of_date as datetime)+1,120)+'''
					group by sequence_order	
				) mx
				inner join formula_nested_audit fn (nolock) ON fn.formula_group_id = f.formula_id AND fn.sequence_order = mx.sequence_order
					and fn.create_ts=mx.create_ts
				'
	--	exec spa_print @sql1		
		exec(@sql1)
		
		set @sql1='insert into #formula_nested_audit
			select fn.id,fn.sequence_order,fn.description1,fn.description2,fn.formula_id,fn.formula_group_id,fn.granularity,fn.include_item,fn.show_value_id,fn.uom_id,fn.rate_id,fn.total_id,fn.create_user,fn.create_ts,fn.update_user,fn.update_ts,fn.time_bucket_formula_id
			FROM #formula_breakdown_audit f 
			inner join formula_nested fn (nolock) ON fn.formula_group_id = f.formula_id 
			left join #formula_nested_audit a (nolock) ON fn.formula_group_id = a.formula_id AND fn.sequence_order = a.sequence_order
			where a.formula_id is null
				'
		--print(@sql1)		
		exec(@sql1)
		
		create index indx_formula_nested_auditt11 on  #formula_nested_audit (formula_group_id,sequence_order) 
	end

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''is_dst'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD is_dst INT
			END'
	EXEC(@sql1)		

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''source_deal_header_id'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD source_deal_header_id INT
			END'
	EXEC(@sql1)	

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''calc_aggregation'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD calc_aggregation INT
			END'
	EXEC(@sql1)	

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''fin_volume'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD fin_volume FLOAT
			END'
	EXEC(@sql1)	
	
	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''offPeakVolume'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD offPeakVolume FLOAT
			END'
	EXEC(@sql1)	

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''curve_tou'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD curve_tou INT
			END'
	EXEC(@sql1)			

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''allocation_volume'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD allocation_volume FLOAT
			END'
	EXEC(@sql1)	

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''deal_settlement_amount'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD deal_settlement_amount FLOAT
			END'
	EXEC(@sql1)	

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''deal_settlement_volume'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD deal_settlement_volume FLOAT
			END'
	EXEC(@sql1)		

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''deal_settlement_price'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD deal_settlement_price FLOAT
			END'
	EXEC(@sql1)	
	
	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''deal_type'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD deal_type FLOAT
			END'
	EXEC(@sql1)	

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''netting_group_id'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD netting_group_id INT
			END'
	EXEC(@sql1)	

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''invoice_granularity'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD invoice_granularity INT
			END'
	EXEC(@sql1)
	
	SET @sql1 = 'IF COL_LENGTH(''' + @calc_process_table + ''', ''as_of_date'') IS NULL
				BEGIN
					ALTER TABLE ' + @calc_process_table + ' ADD as_of_date DATETIME
				END'
	EXEC(@sql1)		
	
	SET @sql1 = 'IF COL_LENGTH(''' + @calc_process_table + ''', ''source_input_id'') IS NULL
				BEGIN
					ALTER TABLE ' + @calc_process_table + ' ADD source_input_id INT
				END'
	EXEC(@sql1)	

	SET @sql1 = 'IF COL_LENGTH(''' + @calc_process_table + ''', ''input_char1'') IS NULL
				BEGIN
					ALTER TABLE ' + @calc_process_table + ' ADD input_char1 INT
				END'
	EXEC(@sql1)	

	SET @sql1 = 'IF COL_LENGTH(''' + @calc_process_table + ''', ''input_char2'') IS NULL
				BEGIN
					ALTER TABLE ' + @calc_process_table + ' ADD input_char2 INT
				END'
	EXEC(@sql1)	

	SET @sql1 = 'IF COL_LENGTH(''' + @calc_process_table + ''', ''input_char3'') IS NULL
				BEGIN
					ALTER TABLE ' + @calc_process_table + ' ADD input_char3 INT
				END'
	EXEC(@sql1)	

	SET @sql1 = 'IF COL_LENGTH(''' + @calc_process_table + ''', ''input_char4'') IS NULL
				BEGIN
					ALTER TABLE ' + @calc_process_table + ' ADD input_char4 INT
				END'
	EXEC(@sql1)	
				
	SET @sql1 = 'IF COL_LENGTH(''' + @calc_process_table + ''', ''input_char5'') IS NULL
				BEGIN
					ALTER TABLE ' + @calc_process_table + ' ADD input_char5 INT
				END'
	EXEC(@sql1)	

	SET @sql1 = 'IF COL_LENGTH(''' + @calc_process_table + ''', ''input_char6'') IS NULL
				BEGIN
					ALTER TABLE ' + @calc_process_table + ' ADD input_char6 INT
				END'
	EXEC(@sql1)	

	SET @sql1 = 'IF COL_LENGTH(''' + @calc_process_table + ''', ''input_char7'') IS NULL
				BEGIN
					ALTER TABLE ' + @calc_process_table + ' ADD input_char7 INT
				END'
	EXEC(@sql1)	
	
	SET @sql1 = 'IF COL_LENGTH(''' + @calc_process_table + ''', ''input_char8'') IS NULL
				BEGIN
					ALTER TABLE ' + @calc_process_table + ' ADD input_char8 INT
				END'
	EXEC(@sql1)	
	
	SET @sql1 = 'IF COL_LENGTH(''' + @calc_process_table + ''', ''input_char9'') IS NULL
				BEGIN
					ALTER TABLE ' + @calc_process_table + ' ADD input_char9 INT
				END'
	EXEC(@sql1)	
	
	SET @sql1 = 'IF COL_LENGTH(''' + @calc_process_table + ''', ''input_char10'') IS NULL
				BEGIN
					ALTER TABLE ' + @calc_process_table + ' ADD input_char10 INT
				END'
	EXEC(@sql1)	
	SET @sql1 = 'IF COL_LENGTH(''' + @calc_process_table + ''', ''invoice_line_item_seq'') IS NULL
				BEGIN
					ALTER TABLE ' + @calc_process_table + ' ADD invoice_line_item_seq INT
				END'
	EXEC(@sql1)	

	SET @sql1 = 'IF COL_LENGTH(''' + @calc_process_table + ''', ''is_true_up'') IS NULL
				BEGIN
					ALTER TABLE ' + @calc_process_table + ' ADD is_true_up CHAR(1)
				END'
	EXEC(@sql1)	

	SET @sql1 = 'IF COL_LENGTH(''' + @calc_process_table + ''', ''ticket_detail_id'') IS NULL
				BEGIN
					ALTER TABLE ' + @calc_process_table + ' ADD ticket_detail_id INT
				END'
	EXEC(@sql1)	

	SET @sql1 = 'IF COL_LENGTH(''' + @calc_process_table + ''', ''shipment_id'') IS NULL
				BEGIN
					ALTER TABLE ' + @calc_process_table + ' ADD shipment_id INT
				END'
	EXEC(@sql1)	



		
	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''curve_id'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD curve_id INT
			END'
	EXEC(@sql1)	
	
	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''source_deal_detail_id'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD source_deal_detail_id INT
			END'
	EXEC(@sql1)	


	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''onPeakVolume'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD onPeakVolume FLOAT
			END'
	EXEC(@sql1)	

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''generator_id'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD generator_id INT
			END'
	EXEC(@sql1)	

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''ticket_detail_id'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD ticket_detail_id INT
			END'
	EXEC(@sql1)	

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''shipment_id'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD shipment_id INT
			END'
	EXEC(@sql1)	

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''commodity_id'') IS NULL
			BEGIN
				ALTER TABLE '+@calc_process_table+' ADD commodity_id INT
			END'
	EXEC(@sql1)	

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''deal_price_type_id'') IS NULL
			BEGIN
				ALTER TABLE ' + @calc_process_table + ' ADD deal_price_type_id INT
			END'
	EXEC(@sql1)	

	SET @sql1='IF COL_LENGTH('''+@calc_process_table+''', ''sequence_order'') IS NULL
			BEGIN
				ALTER TABLE ' + @calc_process_table + ' ADD sequence_order INT
			END'
	EXEC(@sql1)	


	CREATE TABLE  #formula_breakdown (
		[rowid] [INT] IDENTITY(1,1) NOT NULL,
		source_id int,
		[formula_id] [INT] NULL,
		[nested_id] [INT] NULL,
		[formula_level] [INT] NULL,
		[func_name] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
		[arg_no_for_next_func] [INT] NULL,
		[parent_nested_id] [INT] NULL,
		[level_func_sno] [INT] NULL,
		[parent_level_func_sno] [INT] NULL,
		[arg1] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg2] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg3] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg4] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg5] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg6] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg7] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg8] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg9] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg10] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg11] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg12] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg13] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg14] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg15] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg16] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg17] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[arg18] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[eval_value] [VARCHAR](500) COLLATE DATABASE_DEFAULT NULL,
		[granularity] INT,
		[prod_date] DATETIME,
		[Hour] INT,
		source_deal_detail_id INT,
		source_deal_header_id INT,
		[mins] INT,
		fin_volume FLOAT,
		is_dst INT,
		onPeakVolume FLOAT,
		offPeakVolume FLOAT,
		curve_tou INT,
		allocation_volume FLOAT,
		deal_settlement_amount FLOAT,
		deal_settlement_volume FLOAT,
		deal_settlement_price FLOAT,
		deal_type INT,
		final_date DATETIME,
		counterparty_id INT,
		contract_id INT,
		invoice_line_item_id INT,
		final_offset_date DATETIME,
		calc_aggregation INT,
		netting_group_id INT,
		invoice_granularity INT,
		as_of_date DATETIME,
		generator_id INT,
		source_input_id INT,
		input_char1 INT,
		input_char2 INT,
		input_char3 INT,
		input_char4 INT,
		input_char5 INT,
		input_char6 INT,
		input_char7 INT,
		input_char8 INT,
		input_char9 INT,
		input_char10 INT,
		invoice_line_item_seq int,
		is_true_up CHAR(1) COLLATE DATABASE_DEFAULT,
		data_source_id INT,
		curve_id int --unique record when deriving multiple curves value.
	)
	
create table #list_replace_variable(variable_name varchar(50) COLLATE DATABASE_DEFAULT)

INSERT INTO #list_replace_variable(variable_name)
VALUES
	('@as_of_date')
	,('@simulation_curve_criteria')
	,('@process_id_avg_curve')
	,('@curve_shift_val')
	,('@curve_shift_per')
	,('@cpt_model_type')
	,('@process_id')
	,('@calc_type')
	,('@estimate_calculation')
	,('@formula_audit')
 	,('@invoice_line_item_seq')
	,('''''')


declare	@arg1 [VARCHAR](max),
		@arg2 VARCHAR(max),
		@arg3 VARCHAR(max),
		@arg4 VARCHAR(max),
		@arg5 VARCHAR(max),
		@arg6 VARCHAR(max),
		@arg7 VARCHAR(max),
		@arg8 VARCHAR(max),
		@arg9 VARCHAR(max),
		@arg10 VARCHAR(max),
		@arg11 VARCHAR(max),
		@arg12 VARCHAR(max),
		@arg13 VARCHAR(max),
		@arg14 VARCHAR(max),
		@arg15 VARCHAR(max),
		@arg16 VARCHAR(max),
		@arg17 VARCHAR(max),
		@arg18 VARCHAR(max),
		@eval_value VARCHAR(max)

 CREATE TABLE #formula_function_mapping
    (
		[function_name]						VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[eval_string]						VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg1]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg2]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg3]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg4]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg5]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg6]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg7]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg8]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg9]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg10]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg11]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg12]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,	
		[arg13]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg14]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg15]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg16]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg17]								VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[arg18]								VARCHAR(5000) COLLATE DATABASE_DEFAULT 

    ) 
	
set @sql1='
	insert into #formula_function_mapping
	(
	[function_name],
	[eval_string],
	[arg1]	,[arg2]	,[arg3]	,[arg4]	,[arg5]	,[arg6]	,[arg7]	,[arg8]	,[arg9]	,[arg10]	,[arg11]	,
	[arg12]	,[arg13]	,[arg14]	,[arg15]	,[arg16]	,[arg17],[arg18]	
	) 			
	select  --top(50) percent --
	 distinct 
	m.[function_name],
		m.[eval_string],
		m.[arg1]	,m.[arg2]	,m.[arg3]	,m.[arg4]	,m.[arg5]	,m.[arg6]	,m.[arg7]	,m.[arg8]	,m.[arg9]	,m.[arg10]	,m.[arg11]	,
		m.[arg12]	,m.[arg13]	,m.[arg14]	,m.[arg15]	,m.[arg16]	,m.[arg17],m.[arg18]	
	from  '+@calc_process_table+' t (nolock)
	inner join '+@formula_breakdown+' f (nolock) ON t.formula_id = f.formula_id
	 inner join dbo.formula_function_mapping m 
		ON m.function_name = f.func_name		
	where isnull(m.comment_function,''n'')=''n''
	--order by 1 
	'

EXEC spa_print @sql1
exec(@sql1)


select 
	 @arg1=CASE WHEN isnull(arg1,'')<>'' THEN isnull(@arg1+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg1 ELSE @arg1 END,
	 @arg2=CASE WHEN isnull(arg2,'')<>'' THEN isnull(@arg2+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg2 ELSE @arg2 END,
	 @arg3=CASE WHEN isnull(arg3,'')<>'' THEN isnull(@arg3+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg3 ELSE @arg3 END,
	 @arg4=CASE WHEN isnull(arg4,'')<>'' THEN isnull(@arg4+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg4 ELSE @arg4 END,
	 @arg5=CASE WHEN isnull(arg5,'')<>'' THEN isnull(@arg5+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg5 ELSE @arg5 END,
	 @arg6=CASE WHEN isnull(arg6,'')<>'' THEN isnull(@arg6+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg6 ELSE @arg6 END,
	 @arg7=CASE WHEN isnull(arg7,'')<>'' THEN isnull(@arg7+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg7 ELSE @arg7 END,
	 @arg8=CASE WHEN isnull(arg8,'')<>'' THEN isnull(@arg8+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg8 ELSE @arg8 END,
	 @arg9=CASE WHEN isnull(arg9,'')<>'' THEN isnull(@arg9+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg9 ELSE @arg9 END,
	 @arg10=CASE WHEN isnull(arg10,'')<>'' THEN isnull(@arg10+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg10 ELSE @arg10 END,
	 @arg11=CASE WHEN isnull(arg11,'')<>'' THEN isnull(@arg11+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg11 ELSE @arg11 END,
	 @arg12=CASE WHEN isnull(arg12,'')<>'' THEN isnull(@arg12+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg12 ELSE @arg12 END,
	 @arg13=CASE WHEN isnull(arg13,'')<>'' THEN isnull(@arg13+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg13 ELSE @arg13 END,
	 @arg14=CASE WHEN isnull(arg14,'')<>'' THEN isnull(@arg14+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg14 ELSE @arg14 END,
	 @arg15=CASE WHEN isnull(arg15,'')<>'' THEN isnull(@arg15+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg15 ELSE @arg15 END,
	 @arg16=CASE WHEN isnull(arg16,'')<>'' THEN isnull(@arg16+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg16 ELSE @arg16 END,
	 @arg17=CASE WHEN isnull(arg17,'')<>'' THEN isnull(@arg17+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg17 ELSE @arg17 END,
	 @arg18=CASE WHEN isnull(arg18,'')<>'' THEN isnull(@arg18+' WHEN '''+ function_name +''' THEN ',' CASE f.func_name  WHEN '''+ function_name +''' THEN ')+ arg18 ELSE @arg18	END,
	 @eval_value=CASE WHEN isnull(eval_string,'')<>'' THEN isnull(@eval_value+' WHEN '''+ function_name +''' THEN rtrim(ltrim(str(',' CASE f.func_name  WHEN '''+ function_name +''' THEN rtrim(ltrim(str(')+ eval_string+',38,10)))' ELSE @eval_value+',38,10)))' END
 from #formula_function_mapping
--(select top(20) * from formula_function_mapping	) a

--select @eval_value,@arg1,@arg2,@arg3,@arg4,@arg5,@arg6,@arg7,@arg8,@arg9,@arg10,@arg11,@arg12,@arg13,@arg14,@arg15,@arg16,@arg17,@arg18

SELECT 
   	 @arg1=REPLACE(@arg1,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END
		)
   	, @arg2=REPLACE(@arg2,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END		)

   	, @arg3=REPLACE(@arg3,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END		)
   	, @arg4=REPLACE(@arg4,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END		)
   	, @arg5=REPLACE(@arg5,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END			)
   	, @arg6=REPLACE(@arg6,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END			)
   	, @arg7=REPLACE(@arg7,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END			)
   	, @arg8=REPLACE(@arg8,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END			)
   	, @arg9=REPLACE(@arg9,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END			)
   	, @arg10=REPLACE(@arg10,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END			)
   	, @arg11=REPLACE(@arg11,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END			)
	    , @arg12=REPLACE(@arg12,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END			)
   	, @arg13=REPLACE(@arg13,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END			)
   	, @arg14=REPLACE(@arg14,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END			)
	, @arg15=REPLACE(@arg15,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END			)
   	, @arg16=REPLACE(@arg16,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END			)
   	, @arg17=REPLACE(@arg17,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END			)
   	, @arg18=REPLACE(@arg18,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END			)
   	, @eval_value=REPLACE(@eval_value,variable_name
		,CASE variable_name 
			WHEN '@as_of_date' THEN	CONVERT(varchar(10),@as_of_date,120)
			WHEN '@simulation_curve_criteria' THEN	 CAST(ISNULL(@simulation_curve_criteria	,0) AS VARCHAR)
			WHEN '@process_id_avg_curve' THEN	isnull(@process_id_avg_curve,'null')
			WHEN '@curve_shift_val' THEN   STR(ISNULL(@curve_shift_val,0) ,20,4)
			WHEN '@curve_shift_per' THEN  STR(ISNULL(@curve_shift_per,1) ,20,4)
			WHEN '@cpt_model_type' THEN	 isnull(@cpt_model_type,'null')
			WHEN '@process_id' THEN	isnull(@process_id,'null')
			WHEN '@calc_type' THEN 	 isnull(@calc_type,'m')
			WHEN '@estimate_calculation' THEN isnull(@estimate_calculation,'n')
			WHEN '@formula_audit' THEN isnull(@formula_audit,'n')
			WHEN '@invoice_line_item_seq'  THEN	 CAST(ISNULL(@invoice_line_item_seq	,0) AS VARCHAR)
			WHEN '''''' THEN ''''
		END			)
 FROM  #list_replace_variable
--select @eval_value,@arg1,@arg2,@arg3,@arg4,@arg5,@arg6,@arg7,@arg8,@arg9,@arg10,@arg11,@arg12,@arg13,@arg14,@arg15,@arg16,@arg17,@arg18

set @arg1 =CASE WHEN ISNULL(@arg1,'')<>'' THEN 	@arg1+' ELSE f.arg1	 END ' ELSE	' f.arg1' END +',' --+char(10)
set @arg2 =CASE WHEN ISNULL(@arg2,'')<>'' THEN 	@arg2+' ELSE f.arg2	 END ' ELSE	' f.arg2' END  +','--+char(10)
set @arg3 =CASE WHEN ISNULL(@arg3,'')<>'' THEN 	@arg3+' ELSE f.arg3	 END ' ELSE	' f.arg3' END  +','--+char(10)
set @arg4 =CASE WHEN ISNULL(@arg4,'')<>'' THEN 	@arg4+' ELSE f.arg4	 END ' ELSE	' f.arg4' END  +','--+char(10)
set @arg5 =CASE WHEN ISNULL(@arg5,'')<>'' THEN 	@arg5+' ELSE f.arg5	 END ' ELSE	' f.arg5' END  +','--+char(10)
set @arg6 =CASE WHEN ISNULL(@arg6,'')<>'' THEN 	@arg6+' ELSE f.arg6	 END ' ELSE	' f.arg6' END  +','--+char(10)
set @arg7 =CASE WHEN ISNULL(@arg7,'')<>'' THEN 	@arg7+' ELSE f.arg7	 END ' ELSE	' f.arg7' END  +','--+char(10)
set @arg8 =CASE WHEN ISNULL(@arg8,'')<>'' THEN 	@arg8+' ELSE f.arg8	 END ' ELSE	' f.arg8' END  +','--+char(10)
set @arg9 =CASE WHEN ISNULL(@arg9,'')<>'' THEN 	@arg9+' ELSE f.arg9	 END ' ELSE	' f.arg9' END  +','--+char(10)
set @arg10 =CASE WHEN ISNULL(@arg10,'')<>'' THEN 	@arg10+' ELSE f.arg10	 END ' ELSE	' f.arg10' END  +','--+char(10)
set @arg11 =CASE WHEN ISNULL(@arg11,'')<>'' THEN 	@arg11+' ELSE f.arg11	 END ' ELSE	' f.arg11' END  +','--+char(10)
set @arg12 =CASE WHEN ISNULL(@arg12,'')<>'' THEN 	@arg12+' ELSE f.arg12	 END ' ELSE	' f.arg12' END	 +','--+char(10)
set @arg13 =CASE WHEN ISNULL(@arg13,'')<>'' THEN 	@arg13+' ELSE f.arg13	 END ' ELSE	' f.arg13' END  +','--+char(10)
set @arg14 =CASE WHEN ISNULL(@arg14,'')<>'' THEN 	@arg14+' ELSE f.arg14	 END ' ELSE	' f.arg14' END  +','--+char(10)
set @arg15 =CASE WHEN ISNULL(@arg15,'')<>'' THEN 	@arg15+' ELSE f.arg15	 END ' ELSE	' f.arg15' END  +','--+char(10)
set @arg16 =CASE WHEN ISNULL(@arg16,'')<>'' THEN 	@arg16+' ELSE f.arg16	 END ' ELSE	' f.arg16' END  +','--+char(10)
set @arg17 =CASE WHEN ISNULL(@arg17,'')<>'' THEN 	@arg17+' ELSE f.arg17	 END ' ELSE	' f.arg17' END +','--+char(10)
set @arg18 =CASE WHEN ISNULL(@arg18,'')<>'' THEN 	@arg18+' ELSE f.arg18	 END ' ELSE	' f.arg18' END  +','--+char(10)
set @eval_value =@eval_value+' END '

--select @eval_value,@arg1,@arg2,@arg3,@arg4,@arg5,@arg6,@arg7,@arg8,@arg9,@arg10,@arg11,@arg12,@arg13,@arg14,@arg15,@arg16,@arg17,@arg18




SET @sql1='
	INSERT INTO #formula_breakdown (
		source_id,formula_id,nested_id,formula_level,func_name,arg_no_for_next_func,parent_nested_id,level_func_sno,parent_level_func_sno,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,granularity,prod_date,[Hour],source_deal_detail_id,source_deal_header_id,[mins],fin_volume,is_dst,onPeakVolume,offPeakVolume,curve_tou,allocation_volume,deal_settlement_amount,deal_settlement_volume,deal_settlement_price,deal_type,final_date,counterparty_id,contract_id,invoice_line_item_id,calc_aggregation,netting_group_id,invoice_granularity, as_of_date,
			generator_id,source_input_id,input_char1,input_char2,input_char3,input_char4,input_char5,input_char6,input_char7,input_char8,input_char9,input_char10,invoice_line_item_seq,is_true_up,data_source_id,curve_id)
	SELECT DISTINCT
		t.rowid, 
		f.formula_id,
			ISNULL(f.nested_id,1) nested_id,
		f.formula_level,
		f.func_name,
		f.arg_no_for_next_func,
		f.parent_nested_id,
		f.level_func_sno,
		f.parent_level_func_sno, '
			
SET @sql2='
		t.granularity,
		t.[prod_date],
		t.[Hour],
		t.source_deal_detail_id,
		t.source_deal_header_id source_deal_header_id,
		t.[mins],
		t.fin_volume,
		ISNULL(t.is_dst,0),
		t.onPeakVolume,
		t.offPeakVolume,
		CASE WHEN ISNULL(t.curve_tou,18900)=18900 THEN 1 ELSE 0 END curve_tou,
		t.allocation_volume,
		t.deal_settlement_amount,
		t.deal_settlement_volume,
		t.deal_settlement_price,
		t.deal_type,
		CONVERT(VARCHAR(10),t.prod_date,120)+'' ''+RIGHT(CAST(''00''+CASE WHEN t.granularity IN(987,989,982,994,995) THEN t.[Hour]-1 ELSE t.[Hour] END AS VARCHAR),2)+'':''+RIGHT(''00''+CAST(CASE WHEN t.[mins] <> 0 THEN CASE WHEN t.granularity IN(987) THEN t.[mins]-15 WHEN t.granularity IN(989) THEN t.[mins]-15 WHEN t.granularity IN(994) THEN t.[mins]-10 WHEN t.granularity IN(995) THEN t.[mins]-5 ELSE t.[mins] END ELSE t.[mins] END AS VARCHAR),2)+'':00.000'',
		t.counterparty_id, 
		t.contract_id,
		t.invoice_line_item_id,
		t.calc_aggregation,
		t.netting_group_id,
		t.invoice_granularity,
		ISNULL(t.as_of_date, t.prod_date),
		t.generator_id,
		t.source_input_id,
		t.input_char1,
		t.input_char2,
		t.input_char3,
		t.input_char4,
		t.input_char5,
		t.input_char6,
		t.input_char7,
		t.input_char8,
		t.input_char9,
			t.input_char10,
		COALESCE(cgd.sequence_order,cctd1.sequence_order,cctd.sequence_order,t.sequence_order,1) invoice_line_item_seq,
		t.is_true_up,
		f.data_source_id,t.curve_id
	FROM 
	'+@calc_process_table+' t (nolock)
	LEFT JOIN '+@formula_breakdown+' f (nolock) ON t.formula_id = f.formula_id
	LEFT JOIN contract_group_detail cgd (nolock) ON t.contract_id = cgd.contract_id AND cgd.invoice_line_item_id = t.invoice_line_item_id
	LEFT JOIN contract_group cg (nolock) ON cg.contract_id = t.contract_id	
	LEFT JOIN source_price_curve_def spcd (nolock) ON spcd.source_curve_def_id = t.curve_id
	LEFT JOIN '+@formula_nested+' fn (nolock) ON fn.formula_group_id = f.formula_id AND fn.sequence_order = f.nested_id
	LEFT JOIN source_deal_detail sdd (nolock) ON sdd.source_deal_detail_id = t.source_deal_detail_id
	LEFT JOIN source_deal_header sdh (nolock) ON sdd.source_deal_header_id = sdh.source_deal_header_id
	LEFT JOIN source_price_curve_def spcd_s (nolock) ON spcd_s.source_curve_def_id = case when f.func_name in (''CurveM'', ''CurveY'' ,''CurveD'' ,''CurveH'' ,''Curve15'',''Curve30'',''Curve'',''GetCurveValue'') then f.arg1 else null end 
	'+CASE WHEN @calc_type='s' THEN '' ELSE ' and 1=2 ' END +'
	left join user_defined_deal_fields_template uddft ON uddft.template_id=sdh.template_id	and isnull(uddft.leg,sdd.leg)=sdd.leg	
		and uddft.udf_type=''d'' and f.func_name IN (''UDFValue'',''FieldValue'') and uddft.field_id =case when f.func_name IN (''UDFValue'',''FieldValue'') then f.arg1 else null end
		--LEFT JOIN deal_actual_quality daq ON t.source_deal_detail_id = daq.source_deal_detail_id
		LEFT JOIN contract_charge_type cct ON  cct.contract_charge_type_id=cg.contract_charge_type_id
		LEFT JOIN contract_charge_type_detail cctd ON  cctd.contract_charge_type_id=cct.contract_charge_type_id AND cctd.invoice_line_item_id = t.invoice_line_item_id
		LEFT JOIN contract_charge_type_detail cctd1 ON cctd1.[ID] = cgd.contract_component_template
	WHERE 
		' + case when @call_from in ('m','s','d','w') then '' else ' t.granularity=COALESCE(fn.granularity,cgd.volume_granularity,cctd1.volume_granularity,cctd.volume_granularity,spcd.Granularity,t.granularity,980) and ' END 
	+' isnull(f.formula_id,0)<>0 --f.formula_id iS NOT NULL 
	AND ((t.granularity IN(982,987,989,994,995) AND isnull(t.[hour],0) >=0) OR (isnull(t.[hour],0)<=0 AND t.granularity NOT IN(982,987,989,994,995)))
	'
		
EXEC spa_print @sql1
EXEC spa_print @arg1 
EXEC spa_print @arg2
EXEC spa_print @arg3 
EXEC spa_print @arg4 
EXEC spa_print @arg5 
EXEC spa_print @arg6 
EXEC spa_print @arg7 
EXEC spa_print @arg8 
EXEC spa_print @arg9 
EXEC spa_print @arg10 
EXEC spa_print @arg11 
EXEC spa_print @arg12 
EXEC spa_print @arg13 
EXEC spa_print @arg14 
EXEC spa_print @arg15 
EXEC spa_print @arg16 
EXEC spa_print @arg17 
EXEC spa_print @arg18 
EXEC spa_print @sql2


	







 /*


set @sql1='UPDATE #formula_breakdown 
 			SET eval_value=	'

set @sql2=' from #formula_breakdown f left join #whatif_shift wif on wif.curve_id= CASE f.func_name 
					WHEN ''LagCurve'' THEN f.arg5
					WHEN ''CurveD'' THEN f.arg3
					WHEN ''CurveM'' THEN f.arg3
					WHEN ''CurveY'' THEN f.arg3
					WHEN ''CurveH'' THEN f.arg3
					WHEN ''Curve15'' THEN f.arg3
					WHEN ''Curve30'' THEN f.arg3
					WHEN ''Curve'' THEN f.arg3
 		else null end
		outer apply (
			select max(udf_value) curve_id
			FROM
					user_defined_deal_detail_fields udddf INNER JOIN user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
					and  udddf.source_deal_detail_id = f.source_deal_detail_id and (uddft.field_label =''Pricing Index'' or uddft.field_id=''-5647'') -- -5647 provisional index
		) pc
		left join #whatif_shift wif1 on wif1.curve_id=pc.curve_id
		WHERE 
			formula_level='+cast(@i as varchar)+'  AND isnull(nested_id,0)='+cast(@j as varchar)+'  AND parent_nested_id is NULL AND eval_value IS null 
			AND func_name <> ''UDSql'' -- do not select the user defined SQL functions '


EXEC spa_print @sql1
EXEC spa_print	@eval_value
EXEC spa_print @sql2

 -- */



EXEC(@sql1+@arg1+@arg2+@arg3+@arg4+@arg5+@arg6+@arg7+@arg8+@arg9+@arg10+@arg11+@arg12+@arg13+@arg14+@arg15+@arg16+@arg17+@arg18+@sql2)	
	


CREATE INDEX [IX_PT_formula_breakdown_func_name] ON [#formula_breakdown] ([func_name]) INCLUDE ([formula_id], [nested_id], [prod_date], [source_deal_detail_id], [source_deal_header_id], [deal_type], [counterparty_id], [contract_id], [invoice_line_item_id], [calc_aggregation], [generator_id])

CREATE INDEX indx_formula_breakdown_1 ON #formula_breakdown(source_id)
CREATE INDEX indx_formula_breakdown_2 ON #formula_breakdown(formula_id)
CREATE INDEX indx_formula_breakdown_5 ON #formula_breakdown(nested_id)
CREATE INDEX indx_formula_breakdown_4 ON #formula_breakdown(formula_level)
CREATE INDEX indx_formula_breakdown_3 ON #formula_breakdown(level_func_sno)
CREATE INDEX indx_formula_breakdown_6 ON #formula_breakdown(parent_nested_id)
CREATE INDEX indx_formula_breakdown_formula_next_arg ON #formula_breakdown([arg_no_for_next_func])
CREATE INDEX indx_formula_breakdown_formula_rowid ON #formula_breakdown([rowid])
CREATE INDEX indx_formula_breakdown_7 ON #formula_breakdown(prod_date,[Hour],[mins])
CREATE INDEX indx_formula_breakdown_8 ON #formula_breakdown(source_deal_detail_id)
CREATE INDEX indx_formula_breakdown_9 ON #formula_breakdown(final_date)
CREATE INDEX indx_formula_breakdown_10 ON #formula_breakdown(granularity)
	
	--New Indices
CREATE INDEX [IX_PT_#formula_breakdown_func_name_11] ON #formula_breakdown ([func_name]) INCLUDE ([rowid], [source_id], [formula_id], [parent_nested_id], [arg2], [arg3], [granularity], [prod_date], [Hour], [source_deal_detail_id], [source_deal_header_id], [mins], [is_dst], [final_date], [final_offset_date])	
CREATE INDEX [IX_PT_#formula_breakdown_nested_id_arg_no_for_next_func_12] ON #formula_breakdown ([nested_id], [arg_no_for_next_func]) INCLUDE ([source_id], [formula_id], [eval_value], [prod_date], [Hour], [source_deal_detail_id], [source_deal_header_id], [mins], [is_dst], [final_date], [counterparty_id], [contract_id], [invoice_line_item_id], [generator_id])	
	
--EXEC spa_print 'log10.1 Retrive formula elapse time' + ': ' 
--		+ CONVERT(VARCHAR(8),DATEADD(ss, DATEDIFF(ss, @calc_start_time, GETDATE()), '00:00:00'),108      )  + '*************************************'


UPDATE p set final_offset_date=CASE WHEN NULLIF(p.arg2,'NULL') IS NULL THEN p.final_date ELSE	
					CASE WHEN granularity = 982 THEN DATEADD(HH,CAST(NULLIF(p.arg2,'NULL') AS INT),p.final_date)
							WHEN granularity = 987 THEN DATEADD(MI,CAST(NULLIF(p.arg2,'NULL') AS INT)*15,p.final_date)
							WHEN granularity = 989 THEN DATEADD(MI,CAST(NULLIF(p.arg2,'NULL') AS INT)*30,p.final_date)
							WHEN granularity = 994 THEN DATEADD(MI,CAST(NULLIF(p.arg2,'NULL') AS INT)*10,p.final_date)
							WHEN granularity = 995 THEN DATEADD(MI,CAST(NULLIF(p.arg2,'NULL') AS INT)*5,p.final_date)
							WHEN granularity = 981 THEN DATEADD(D,CAST(NULLIF(p.arg2,'NULL') AS INT),p.final_date)
					ELSE p.final_date END END
from #formula_breakdown p where parent_nested_id is not null AND func_name <> 'UDSql'

CREATE INDEX indx_formula_breakdown_11 ON #formula_breakdown(final_offset_date)

--DELETE FROM #formula_breakdown  where nested_id=10


---		 left join '+@whatif_shift+' wif on sdd.curve_id=wif.curve_id



-- populate the temporary tables if the row function is used
	CREATE TABLE #temp_cfv(formula_id INT,prod_date DATETIME,[hour] INT,[mins] INT,value FLOAT,seq_number INT,invoice_line_item_id INT,granularity INT,final_date DATETIME,source_deal_header_id INT,source_deal_detail_id INT, is_dst INT)

	INSERT INTO #temp_cfv
	select 
		cf.formula_id,
		cf.prod_date,
		cf.hour,
		cf.qtr,
		cf.value,
		cf.seq_number,
		cf.invoice_line_item_id,
		cf.granularity,
		CONVERT(VARCHAR(10),cf.prod_date,120)+' '+RIGHT(CAST('00'+CASE WHEN cf.granularity IN(987,982,989,994,995) THEN cf.[Hour]-1 ELSE cf.[Hour] END AS VARCHAR),2)+':'+RIGHT('00'+CAST(CASE WHEN cf.qtr<>0 THEN  CASE WHEN cf.granularity IN(987) THEN cf.qtr-15 WHEN cf.granularity IN(989) THEN cf.qtr-30 WHEN cf.granularity IN(994) THEN cf.qtr-10 WHEN cf.granularity IN(995) THEN cf.qtr-5 ELSE cf.qtr END ELSE cf.qtr END AS VARCHAR),2)+':00.000',
		source_deal_header_id ,
		source_deal_detail_id,
		is_dst 
	FROM
		(SELECT DISTINCT counterparty_id,contract_id,parent_nested_id,invoice_line_item_id FROM #formula_breakdown WHERE parent_nested_id>0 ) fb
		OUTER APPLY(
			SELECT 
				cfv.formula_id,
				cfv.prod_date,
				cfv.hour,
				cfv.qtr,
				cfv.value,
				cfv.seq_number,
				cfv.invoice_line_item_id,
				cfv.granularity,
				cfv.source_deal_header_id source_deal_header_id,
				cfv.deal_id source_deal_detail_id,
				cfv.is_dst
			FROM	
			(SELECT MAX(as_of_date) as_of_date,prod_date,counterparty_id,contract_id,netting_group_id FROM Calc_invoice_Volume_variance  GROUP BY prod_date,counterparty_id,contract_id,netting_group_id) civv
			INNER JOIN calc_invoice_Volume_variance civv1 ON civv1.counterparty_id = civv.counterparty_id
					AND civv1.contract_id = civv.contract_id
					AND civv1.prod_date = civv.prod_date
					AND civv1.counterparty_id= fb.counterparty_id 
					AND civv1.contract_id=fb.contract_id
					AND civv1.as_of_date=civv.as_of_date
					AND ISNULL(civv1.netting_group_id,1)=ISNULL(civv.netting_group_id,-1)
			INNER JOIN calc_formula_value cfv ON cfv.calc_id = civv1.calc_id	
				AND seq_number = fb.parent_nested_id
				AND invoice_line_item_id = fb.invoice_line_item_id	

		) cf
	WHERE cf.formula_id IS NOT NULL
			


--############### Evaluate the user defined SQL
   CREATE TABLE #temp_UD_sql(contract_id INT,
			[counterparty_id] INT,
			[formula_id] INT,
			[nested_id] INT,
			[invoice_line_item_id] INT,
			[deal_type] INT,
			[source_deal_header_id] INT,
			[source_deal_detail_id] INT,
			[prod_date] DATETIME,
		    [hour] INT,
		    [mins] INT,
		    [ud_sql_value] FLOAT,is_dst int,
		    [generator_id] INT
		)
			

   DECLARE @contract_id VARCHAR(100),@counterparty_id VARCHAR(100),@generator_id VARCHAR(100),@formula_id VARCHAR(100),@nested_id VARCHAR(100),@invoice_line_item_id VARCHAR(100),@deal_type VARCHAR(100),@formula_sql VARCHAR(MAX),@calc_aggregation VARCHAR(100),@source_deal_header_id VARCHAR(100),@source_deal_detail_id VARCHAR(100),@prod_date VARCHAR(30),@batch_identifier VARCHAR(100)
   SET @batch_identifier = '--[__final_output__]'	

	SET @sql8=' DECLARE cur_ud_sql CURSOR FOR	
	SELECT  fd.contract_id,fd.counterparty_id,fd.generator_id,fd.formula_id,fd.nested_id,fd.invoice_line_item_id, ISNULL(fd.deal_type,''''),formula_sql,fd.calc_aggregation 
		,ISNULL(fd.source_deal_header_id,''''),ISNULL(fd.source_deal_detail_id,'''')'+CASE WHEN ISNULL(@single_row_return_formula,'n')='y' THEN ',convert(varchar(30),fd.prod_date,120)' ELSE ',max(convert(varchar(30),fd.prod_date,120))' END 
		+' FROM #formula_breakdown fd 
			 LEFT JOIN formula_nested fn ON fn.formula_group_id = 	fd.formula_id
				AND fn.sequence_order = fd.nested_id
			 LEFT JOIN formula_editor_sql fes on fes.formula_id = ISNULL(fn.formula_id,fd.formula_id)
		WHERE func_name = ''UDSql''
			-- AND CHARINDEX('''+@batch_identifier+''', formula_sql) > 0 
		GROUP BY fd.contract_id,fd.counterparty_id,fd.generator_id,fd.formula_id,fd.nested_id,fd.invoice_line_item_id, ISNULL(fd.deal_type,''''),formula_sql,fd.calc_aggregation 
		,ISNULL(fd.source_deal_header_id,''''),ISNULL(fd.source_deal_detail_id,'''')'
		+CASE WHEN ISNULL(@single_row_return_formula,'n')='y' THEN ',convert(varchar(30),fd.prod_date,120)' ELSE '' END 
	
	exec spa_print @sql8
	EXEC(@sql8)
	
	
	OPEN cur_ud_sql
	FETCH NEXT FROM cur_ud_sql INTO @contract_id,@counterparty_id,@generator_id,@formula_id,@nested_id,@invoice_line_item_id,@deal_type,@formula_sql,@calc_aggregation,@source_deal_header_id,@source_deal_detail_id,@prod_date
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @sqlstmt = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@formula_sql,'@prod_date',isnull(CONVERT(VARCHAR(30),CAST(@prod_date AS DATETIME),120),'')),'@as_of_date',isnull(CONVERT(VARCHAR(10),CAST(@as_of_date AS DATETIME),120),'')),'@counterparty_id',isnull(@counterparty_id,'')),'@contract_id',isnull(@contract_id,'')),'@deal_type',isnull(@deal_type,'')),'adiha_add','+'),@batch_identifier,' INTO #final_output'),'@generator_id',isnull(@generator_id,'0')),'@source_deal_header_id',isnull(@source_deal_header_id,'')),'@source_deal_detail_id',isnull(@source_deal_detail_id,'')), '@asofdate_to',isnull(CONVERT(VARCHAR(10),CAST(@asofdate_to AS DATETIME),120),''))

		SET @sqlstmt = '
					'+@sqlstmt+';
					IF COL_LENGTH(''tempdb..#final_output'', ''is_dst'') IS NULL
					BEGIN
						ALTER TABLE #final_output ADD is_dst int
						update #final_output set is_dst=0
					END;
					INSERT INTO #temp_UD_sql(contract_id,[counterparty_id],[formula_id],[nested_id],[invoice_line_item_id],[deal_type],source_deal_header_id,source_deal_detail_id,[generator_id],[prod_date],[hour],[mins],[ud_sql_value],is_dst) 
					 SELECT NULLIF('+isnull(@contract_id,'''''')+',''''),NULLIF('+isnull(@counterparty_id,'''''')+',''''),NULLIF('+isnull(@formula_id,'''''')+',''''),NULLIF('+isnull(@nested_id,'''''')+',''''),NULLIF('+isnull(@invoice_line_item_id,'''''')+',''''),NULLIF('+isnull(@deal_type,'''''')+',''''),NULLIF('+isnull(@source_deal_header_id,'''''')+',''''),NULLIF('+isnull(@source_deal_detail_id,'''''')+',''''),NULLIF('+isnull(@generator_id,'''''')+','''')'
					+',* FROM #final_output s_qery'
		
		EXEC spa_print @sqlstmt
		EXEC(@sqlstmt)
	--SELECT * FROM #temp_UD_sql
		--SELECT @contract_id,@counterparty_id,@formula_id,@nested_id,@invoice_line_item_id,@deal_type,
	FETCH NEXT FROM cur_ud_sql INTO @contract_id,@counterparty_id,@generator_id,@formula_id,@nested_id,@invoice_line_item_id,@deal_type,@formula_sql,@calc_aggregation,@source_deal_header_id,@source_deal_detail_id,@prod_date
	END
	CLOSE cur_ud_sql
	DEALLOCATE cur_ud_sql	

	-----################################
--delete from #formula_breakdown where source_deal_header_id<>60328
-----################################

--###########################Update UDFValue function and update the argument
	UPDATE #formula_breakdown SET eval_value=dbo.FNARUDFValue(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12) WHERE func_name='UDFValue'


	UPDATE  s 
		SET s .arg1 = NULLIF(t.eval_value,'NULL')
	FROM
					#formula_breakdown s 
					INNER JOIN #formula_breakdown t ON  
					s.source_id=t.source_id 
					AND s.formula_id=t.formula_id 
					AND s.nested_id=t.nested_id 
					AND s.invoice_line_item_seq = t.invoice_line_item_seq
					AND s.level_func_sno=t.parent_level_func_sno
					AND s.prod_date=t.prod_date
					AND ISNULL(s.[hour],0)=ISNULL(t.[Hour],0)
					AND ISNULL(s.[mins],0)=ISNULL(t.[mins],0)
					AND ISNULL(s.source_deal_detail_id,-1)=ISNULL(t.source_deal_detail_id,-1)
					AND ISNULL(s.source_deal_header_id,-1)=ISNULL(t.source_deal_header_id,-1)
					AND s.is_dst=t.is_dst
					AND s.as_of_date = t.as_of_date
	WHERE
		t.func_name='UDFValue' and s.data_source_id IS NOT NULL

--################### Evaluate user Defined Functions
	DECLARE @formula_input_table VARCHAR(200)
 /* 
	###--This Process table will be used in UDF functions
	###--UDF query should return the at the requried aggregation(counterparty, deal, ticket, shipment etc) and granularity(hourly, 15 minutes, 5 minutes, Daily etc) 
 */

	SET @formula_input_table= dbo.FNAProcessTableName('formula_input_table', @user_login_id,@process_id)


	if object_id(@formula_input_table) is not null 
		exec('drop table '+@formula_input_table)

	SET @sqlstmt = 'CREATE TABLE '+@formula_input_table+'(
					as_of_date DATETIME,
					prod_date DATETIME,
					prod_date_to DATETIME,
					counterparty_id INT,	
					contract_id INT,
					source_deal_header_id INT,
					source_deal_detail_id INT,
					ticket_id INT,
					shipment_id INT,
					calc_aggregation INT,
					granularity INT
				);
				'
	SET @sqlstmt = @sqlstmt + 'INSERT INTO '+@formula_input_table+'(as_of_date,prod_date,prod_date_to,counterparty_id,contract_id,source_deal_header_id,source_deal_detail_id,calc_aggregation,granularity)
				SELECT 
					as_of_date,MIN(prod_date) prod_date,MAX(prod_date) prod_date_to,counterparty_id,contract_id,source_deal_header_id,source_deal_detail_id,calc_aggregation,MIN(granularity) granularity
				FROM 
					#formula_breakdown
				GROUP BY as_of_date,counterparty_id,contract_id,source_deal_header_id,source_deal_detail_id,calc_aggregation '

	EXEC(@sqlstmt)	


	DECLARE @tsql VARCHAR(MAX),@data_source_table VARCHAR(200),@alias VARCHAR(100),@ds_process_id VARCHAR(100),@data_source_id INT,@criteria VARCHAR(5000),@global_filters VARCHAR(5000),@formula_level INT,@argument VARCHAR(5000),@param_name VARCHAR(5000),@level_func_sno INT, @source_id INT
	CREATE TABLE #ud_function_evaluation(
			source_id INT, 
			counterparty_id INT,
			contract_id INT,
			source_deal_header_id INT,
			source_deal_detail_id INT,
			data_source_id INT,
			formula_id INT,
			nested_id INT,
			level_func_sno INT,
			prod_date DATETIME,
			hour INT,
			mins INT,
			value NUMERIC(28,10)
		)

	SELECT MIN(Prod_date) prod_date,MAX(Prod_date) prod_date_to,func_name,alias,ds.data_source_id,fb.formula_id,fb.nested_id,fb.level_func_sno, fb.source_deal_header_id, MAX(source_id) source_id,MAX(invoice_line_item_seq) seq
	INTO #UD_function_name 
	FROM #formula_breakdown fb 
		INNER JOIN data_source ds ON ds.data_source_id = fb.data_source_id AND ds.category = 106501
	GROUP BY func_name,alias,ds.data_source_id,fb.formula_id,fb.nested_id,fb.level_func_sno, fb.source_deal_header_id


	SELECT data_source_id,CAST(REPLACE(seqence,'arg','') AS INT) seqence,argument,formula_id,nested_id,level_func_sno
		INTO #ud_function_param_value
	FROM
	(
		SELECT DISTINCT fb.data_source_id,fb.formula_id,fb.nested_id,fb.level_func_sno,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18 
			FROM #formula_breakdown fb INNER JOIN #UD_function_name ufm ON ufm.data_source_id = fb.data_source_id
	) PVT
	UNPIVOT(argument FOR seqence IN (arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18))UNPT

	SELECT 
		DENSE_RANK() OVER(PARTITION BY ds.data_source_id ORDER BY ds.data_source_id,dsc.data_source_column_id) row_id,
		dsc.name param_name,ds.data_source_id
	INTO
		#ud_function_param
	FROM 
		data_source_column dsc
		INNER JOIN data_source ds On ds.data_source_id = dsc.source_id
		INNER JOIN #UD_function_name ufn ON ufn.data_source_id = ds.data_source_id AND ds.category = 106501
	WHERE
		dsc.required_filter =1
	GROUP BY dsc.name,ds.data_source_id,dsc.data_source_column_id


	DECLARE @seq INT
	IF EXISTS(SELECT 'X' FROM  #UD_function_name)
	BEGIN

		DECLARE cur_func CURSOR FOR 
			SELECT  DISTINCT ufm.data_source_id,ufm.alias,CONVERT(VARCHAR(10),ufm.prod_date,120),convert(varchar(10),ufm.prod_date_to,120),ufm.formula_id,ufm.nested_id,ufm.level_func_sno,ufm.source_deal_header_id, ufm.source_id,ufm.seq
			FROM	
				#UD_function_name ufm 
				LEFT JOIN #ud_function_param_value ufpv ON ufpv.data_source_id =  ufm.data_source_id
					AND ufpv.formula_id = ufm.formula_id
					AND ufpv.nested_id =  ufm.nested_id
			ORDER BY seq

		OPEN cur_func
		FETCH NEXT FROM cur_func INTO @data_source_id,@alias,@prod_date,@prod_date_to,@formula_id,@nested_id,@level_func_sno,@source_deal_header_id, @source_id,@seq
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @criteria =  ''
			SET @criteria = 'source_deal_header_id='+@source_deal_header_id+',as_of_date='+@as_of_date+',prod_date='+@prod_date+',prod_date_to='+ISNULL(@prod_date_to,@prod_date)+',formula_input_table='+@formula_input_table+',calc_process_table='+@calc_process_table
			SET @ds_process_id = dbo.FNAGetNewID()
			SET @data_source_table = dbo.FNAProcessTableName('report_dataset_' + @alias, dbo.FNADBUser(), @ds_process_id)

			SELECT @tsql =[tsql] FROM data_source WHERE data_source_id = @data_source_id
			SELECT @criteria = ufp.param_name + '=' + ISNULL(a.argument,'NULL') + ','+@criteria
			FROM 
				#ud_function_param ufp
				OUTER APPLY(SELECT MAX(ufpv.argument) argument FROM  #ud_function_param_value ufpv WHERE ufpv.data_source_id=ufp.data_source_id AND ufpv.seqence = ufp.row_id
					AND ufpv.data_source_id = @data_source_id
					AND ufpv.formula_id = @formula_id
					AND ufpv.nested_id = @nested_id
					AND ufpv.level_func_sno = @level_func_sno
				) a
			-- WHERE a.argument IS NOT NULL
				
			EXEC [spa_rfx_handle_data_source] @data_source_tsql = @tsql,@data_source_alias=@alias,@criteria=@criteria,@data_source_process_id=@ds_process_id
			print @tsql

		--exec('select * from '+@data_source_table)
		SET @sqlstmt = 'INSERT INTO #ud_function_evaluation (data_source_id,formula_id,nested_id,level_func_sno,source_id,counterparty_id,contract_id,source_deal_header_id,source_deal_detail_id,prod_date,hour,mins,value)
		SELECT '+CAST(@data_source_id AS VARCHAR)+','+CAST(@formula_id AS VARCHAR)+','+CAST(@nested_id AS VARCHAR)+','+CAST(ISNULL(@level_func_sno,1) AS VARCHAR) +','+CAST(@source_id AS VARCHAR)+',counterparty_id,contract_id,source_deal_header_id,source_deal_detail_id,prod_date,hour,mins,value FROM '+@data_source_table
		EXEC(@sqlstmt)
		
		FETCH NEXT FROM cur_func INTO @data_source_id,@alias,@prod_date,@prod_date_to,@formula_id,@nested_id,@level_func_sno,@source_deal_header_id,@source_id,@seq
		END
		CLOSE cur_func
		DEALLOCATE cur_func



	END


	UPDATE fb
		SET fb.eval_value = ISNULL(ufe.value,0)
	FROM 
		#formula_breakdown fb
		INNER JOIN #UD_function_name ufm ON 
			--CONVERT(VARCHAR(7),ufm.prod_date,120) =  CONVERT(VARCHAR(7),fb.prod_date,120)
			ufm.func_name = fb.func_name
			AND ufm.data_source_id = fb.data_source_id
			AND ufm.formula_id = fb.formula_id
			AND ufm.nested_id = fb.nested_id
		INNER JOIN #ud_function_evaluation ufe ON ISNULL(fb.counterparty_id,-1) = COALESCE(ufe.counterparty_id, fb.counterparty_id,-1)
			AND COALESCE(fb.contract_id,-1) = COALESCE(ufe.contract_id,fb.contract_id,-1)
			AND fb.prod_date = ufe.prod_date
			AND ISNULL(fb.Hour,0) = ISNULL(ufe.hour,0)
			AND ISNULL(fb.mins,0) = ISNULL(ufe.mins,0)
			AND fb.data_source_id = ufe.data_source_id
			AND fb.formula_id = ufe.formula_id
			AND fb.nested_id = ufe.nested_id
			AND fb.level_func_sno = ufe.level_func_sno
			AND COALESCE(ufe.source_deal_header_id,fb.source_deal_header_id,-1) = ISNULL(fb.source_deal_header_id,-1)
			AND COALESCE(ufe.source_deal_detail_id,fb.source_deal_detail_id,-1) = ISNULL(fb.source_deal_detail_id,-1)





--########****      END of UD Function Foormula Evaluations###############


  	SELECT @max_source_level=   MAX(invoice_line_item_seq) FROM #formula_breakdown 
	SELECT @invoice_line_item_seq = MIN(invoice_line_item_seq) FROM #formula_breakdown 
  
	WHILE @invoice_line_item_seq <= @max_source_level
	BEGIN
		SELECT @max_nested_level=   MAX(nested_id) FROM #formula_breakdown WHERE invoice_line_item_seq = @invoice_line_item_seq
 		SET @j=0

	 WHILE @j<=@max_nested_level
	 BEGIN
		EXEC spa_print '*********************************@j:', @j
		
			 SELECT @max_formula_level=MAX(formula_level),@parent_granularity=MAX(granularity) FROM #formula_breakdown WHERE  nested_id=@j AND invoice_line_item_seq = @invoice_line_item_seq
			 SELECT @granularity=MAX(granularity) FROM #formula_breakdown WHERE  parent_nested_id=@j AND invoice_line_item_seq = @invoice_line_item_seq
		 
		 SET @i=@max_formula_level

		 WHILE @i>=1
		 BEGIN
 			EXEC spa_print '@i:', @i

 		--select * from #formula_breakdown
 		--			WHERE 
 		--	formula_level= @i AND isnull(nested_id,0)=@j AND parent_nested_id is NULL AND eval_value IS null -- AND func_name<>'FNALagCurve'
		
 		----	 Update the value of contract value 
 			UPDATE fb 
 			SET eval_value = cv.contract_value
	 		FROM #formula_breakdown fb
 					OUTER APPLY(
 					SELECT SUM(cast(eval_value as numeric(28,10))) contract_value FROM #formula_breakdown WHERE fb.func_name = 'ContractValue'  
 						--AND CONVERT(VARCHAR(10),NULLIF(fb.arg1,'NULL'),120) = CONVERT(VARCHAR(10),final_date,120)						
 						AND CAST(CONVERT(VARCHAR(10),fb.arg1,120)+' '+RIGHT(CAST('00'+CASE WHEN fb.granularity IN(987,989,982,994,995) THEN fb.[Hour]-1 ELSE fb.[Hour] END AS VARCHAR),2)+':'+RIGHT('00'+CAST(CASE WHEN fb.[mins] <> 0 THEN CASE WHEN fb.granularity IN(987) THEN fb.[mins]-15 WHEN fb.granularity IN(989) THEN fb.[mins]-30  WHEN fb.granularity IN(994) THEN fb.[mins]-10  WHEN fb.granularity IN(995) THEN fb.[mins]-5 ELSE fb.[mins] END ELSE fb.[mins] END AS VARCHAR),2)+':00.000' AS DATETIME)
 							= CAST(CASE WHEN fb.granularity IN(987,989,982,994,995) THEN final_date WHEN fb.granularity IN(981) THEN CONVERT(VARCHAR(10),final_date,120)+ ' '+'00:00.000' ELSE CONVERT(VARCHAR(7),final_date,120)+'-01' + ' '+'00:00.000' END AS DATETIME)	
						AND CAST(counterparty_id AS VARCHAR) = (NULLIF(fb.arg2,'NULL'))
						AND CAST(contract_id AS VARCHAR) = (NULLIF(fb.arg3,'NULL'))
						AND CAST(invoice_line_item_id AS VARCHAR) = (NULLIF(fb.arg4,'NULL'))
						AND CAST(nested_id AS VARCHAR) = (NULLIF(fb.arg5,'NULL'))
						--AND CAST(NULLIF(fb.arg6,'NULL') AS INT) = 0
						AND arg_no_for_next_func IS NULL
 					) cv
 			WHERE 
 				formula_level= @i AND isnull(nested_id,0)=@j AND parent_nested_id is NULL --AND eval_value IS null 
				AND invoice_line_item_seq = @invoice_line_item_seq
				AND func_name <> 'UDSql'
				AND fb.func_name = 'ContractValue' 
				AND ISNULL(arg9,1) in(1, 0)

		set @sql1='UPDATE #formula_breakdown 
 				--SET eval_value=case when isnumeric(eva.eval_value1)=1 then convert(numeric(38,10),eva.eval_value1) else eva.eval_value1 end
				SET eval_value = eva.eval_value1
				from #formula_breakdown f left join #whatif_shift wif on wif.curve_id= CASE f.func_name 
						WHEN ''LagCurve'' THEN f.arg5
						WHEN ''CurveD'' THEN f.arg3
						WHEN ''CurveM'' THEN f.arg3
						WHEN ''CurveY'' THEN f.arg3
						WHEN ''CurveH'' THEN f.arg3
						WHEN ''Curve15'' THEN f.arg3
						WHEN ''Curve30'' THEN f.arg3
						WHEN ''Curve'' THEN f.arg3
 				else null end
			outer apply (
				select max(udf_value) curve_id
				FROM
					 user_defined_deal_detail_fields udddf INNER JOIN user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
					 and  udddf.source_deal_detail_id = f.source_deal_detail_id and (uddft.field_label =''Pricing Index'' or uddft.field_id=''-5647'') -- -5647 provisional index
			) pc
			left join #whatif_shift wif1 on wif1.curve_id=pc.curve_id 
			outer apply 
			( select  '

		 set @sql2='  eval_value1 ) eva
			WHERE 1=1 AND data_source_id IS NULL
				AND formula_level='+ cast(@i as varchar)+' AND isnull(nested_id,0)='+cast(@j as varchar)+' AND parent_nested_id is NULL AND NULLIF(eval_value, 0) IS null 
				AND func_name <> ''UDSql'' -- do not select the user defined SQL functions 
				AND invoice_line_item_seq ='+cast(@invoice_line_item_seq as varchar) +
				' AND eval_value IS NULL '
		
		SET @eval_value = ISNULL(NULLIF(@eval_value, ''), '''''')
		
		EXEC spa_print @sql1
		exec spa_print '---------------------------------------'
		EXEC spa_print @eval_value
		exec spa_print '---------------------------------------'
		EXEC spa_print @sql2
	
		exec(@sql1 +@eval_value+@sql2)


--SELECT @j j,@i i
--SELECT 'after updating eval_value'
--SELECT * FROM #formula_breakdown
--WHERE formula_level= @i AND isnull(nested_id,0)=@j 
--		AND parent_nested_id is NULL AND eval_value IS null
--		AND func_name <> 'UDSql' 
	 	

			SELECT 
				f.source_id,
				f.formula_id,
				f.nested_id,
				f.formula_level-1 formula_level,
				f.arg_no_for_next_func +
				CASE f1.func_name 
					WHEN 'LagCurve' THEN 4
					WHEN 'CurveD' THEN 2
					WHEN 'AverageHourlyPrice' THEN 4
					WHEN 'AverageMnthlyPrice' THEN 4
					WHEN 'AverageYrlyPrice' THEN 4
					WHEN 'MeterVol' THEN 4
					WHEN 'GetMeteredVolm' THEN 4
					WHEN 'SUMPRODUCT' THEN 0
					WHEN 'Curve30' THEN 3
					WHEN 'Curve15' THEN 2
					WHEN 'CurveH' THEN 2
					WHEN 'CurveM' THEN 2
					WHEN 'CurveY' THEN 2
					--WHEN 'GetCurveValue' THEN 2
					WHEN 'ContractPriceValue' THEN 3
					WHEN 'AverageQtrDailyPrice' THEN 1
					WHEN 'AverageDailyPrice' THEN 3
					WHEN 'AverageQVol' THEN 0
					WHEN 'CurveH' THEN 2
					WHEN 'Curve15' THEN 2
					WHEN 'Curve30' THEN 2
					WHEN 'Curve' THEN 2
					WHEN 'PriorCurve' THEN 4
                    WHEN 'RollingSum' THEN 9
					WHEN 'MeterVolmUK' THEN 6
					WHEN 'AveragePrice' THEN 2
					else  0
				END arg_no_for_next_func,
				f.parent_level_func_sno,
				f.eval_value,
				f.prod_date,
				f.[hour],
				f.[mins],
				f.[is_dst],
				f.source_deal_detail_id,
				f.source_deal_header_id
				, f.as_of_date
				INTO #tmp_eval_val
			FROM 
			#formula_breakdown f 
			INNER JOIN #formula_breakdown f1 ON f.source_id=f1.source_id 
				AND f.formula_id=f1.formula_id 
				AND isnull(f.nested_id,0)=@j 
				AND isnull(f.nested_id,0)=isnull(f1.nested_id,0) 
				AND f.formula_level=@i
				AND f.invoice_line_item_seq = @invoice_line_item_seq
				AND f1.level_func_sno=f.parent_level_func_sno
				AND f1.prod_date=f.prod_date
				AND isnull(f1.[hour],0)=isnull(f.[hour],0)
				AND isnull(f1.[mins],0)=isnull(f.[mins],0)
				AND f1.is_dst=f.is_dst
			--WHERE 
				AND f.arg_no_for_next_func IS NOT NULL 	 		
	 			AND isnull(f1.[source_deal_detail_Id],-1)=isnull(f.[source_deal_detail_Id],-1)
				AND isnull(f1.[source_deal_header_Id],-1)=isnull(f.[source_deal_header_Id],-1)
	 		
	 		--CREATE INDEX indx_tmp_eval_val_11 ON #tmp_eval_val
	 		
	 	--	SELECT '#tmp_eval_val'
			--SELECT * FROM #tmp_eval_val

			
			 SELECT source_id, formula_id,nested_id,formula_level, parent_level_func_sno,
					[1], [2], [3], [4],[5],[6],[7],[8],[9],[10],[11],[12],prod_date,[hour],[mins],[is_dst],source_deal_detail_id,source_deal_header_id, as_of_date
			 INTO #tmp_next_level_func_args 
			 FROM 
					( 
						SELECT * FROM #tmp_eval_val
						
						) AS SourceTable
					PIVOT
					(
					max(eval_value)
					FOR arg_no_for_next_func IN ([1], [2], [3], [4],[5],[6],[7],[8],[9],[10],[11],[12])
					) AS PivotTable; 	
			
			
			--SELECT '#tmp_next_level_func_args'
			--SELECT * FROM #tmp_next_level_func_args	

			IF object_id('tempdb..#tmp_eval_val') IS NOT null
				DROP TABLE  #tmp_eval_val
				
--SELECT * FROM #tmp_next_level_func_args				
		    CREATE INDEX indx_formula_breakdown_formula_level ON #tmp_next_level_func_args(source_id,formula_id,nested_id,parent_level_func_sno,prod_date,[Hour],[mins],source_deal_detail_id)
	 		
			--EXEC spa_print 'log10a evaluate func elapse time'+': '+convert(VARCHAR(8),dateadd(ss,DATEDIFF(ss,@calc_start_time,GETDATE()),'00:00:00'),108)  +'*************************************'
		----UPDATE arguments of next level function
			UPDATE  s 
			SET arg1 = CASE WHEN func_name IN ('AverageQVol','SUMPRODUCT') THEN ISNULL(NULLIF(arg1,'NULL'),CONVERT(VARCHAR,CAST(CAST([1] AS FLOAT) AS INT),2)) ELSE ISNULL(NULLIF(arg1,'NULL'),CONVERT(VARCHAR,[1],2)) END,
				arg2 = CASE WHEN func_name IN ('AverageQtrDailyPrice','SUMPRODUCT') THEN ISNULL(NULLIF(arg2,'NULL'),CONVERT(VARCHAR,CAST(CAST([2] AS FLOAT) AS INT),2)) ELSE ISNULL(NULLIF(arg2,'NULL'),CONVERT(VARCHAR,[2],2)) END,
				arg3 = CASE WHEN func_name IN ('Curve15', 'CurveH', 'CurveM', 'CurveY', 'CurveD', 'GetCurveValue','SUMPRODUCT') THEN ISNULL(NULLIF(arg3, 'NULL'), CONVERT(VARCHAR, CAST(CAST([3] AS FLOAT) AS INT), 2)) ELSE ISNULL(NULLIF(arg3,'NULL'), CONVERT(VARCHAR, [3], 2))  END, 
				arg4 = CASE WHEN func_name IN ('Curve30', 'AverageDailyPrice','ContractPriceValue') THEN ISNULL(NULLIF(arg4, 'NULL'), CONVERT(VARCHAR, CAST(CAST([4] AS FLOAT) AS INT), 2)) ELSE ISNULL(NULLIF(arg4, 'NULL'), CONVERT(VARCHAR, [4], 2)) END,
				arg5 = CASE WHEN func_name ='AverageMnthlyPrice' OR func_name ='AverageYrlyPrice' OR func_name ='Metervol' OR  func_name = 'GetMeteredVolm' OR func_name ='AverageHourlyPrice' THEN ISNULL(NULLIF(arg5,'NULL'),CONVERT(VARCHAR,CAST(CAST([5] AS FLOAT) AS INT),2)) ELSE ISNULL(NULLIF(arg5,'NULL'),CONVERT(VARCHAR,[5],2)) END,
				arg6=CASE WHEN func_name ='PriorCurve' THEN ISNULL(NULLIF(arg6,'NULL'),CONVERT(VARCHAR,([6]),2)) ELSE ISNULL(NULLIF(arg6,'NULL'),CONVERT(VARCHAR,[6],2)) END,
				arg7=CASE WHEN func_name ='PriorCurve' OR func_name ='MeterVolmUK' THEN ISNULL(NULLIF(arg7,'NULL'),CONVERT(VARCHAR,CAST(CAST([7] AS FLOAT) AS INT),2)) ELSE ISNULL(NULLIF(arg7,'NULL'),CONVERT(VARCHAR,[7],2)) END,
				arg8 =ISNULL(NULLIF(arg8,'NULL'),CONVERT(VARCHAR,[8],2)) ,
				arg9=ISNULL(NULLIF(arg9,'NULL'),CONVERT(VARCHAR,[9],2) ),
				arg10=ISNULL(NULLIF(arg10,'NULL'),CONVERT(VARCHAR,[10],2)) ,
				arg11=ISNULL(NULLIF(arg11,'NULL'),CONVERT(VARCHAR,CAST(CAST([11] AS FLOAT) AS INT),2)),
				arg12=ISNULL(NULLIF(arg12,'NULL'),CONVERT(VARCHAR,[12],2)) 
			 FROM
				#formula_breakdown s INNER JOIN #tmp_next_level_func_args t ON  
				s.source_id=t.source_id 
				AND s.formula_id=t.formula_id 
				AND s.nested_id=t.nested_id 
				AND isnull(s.nested_id,0)=@j 
				AND s.invoice_line_item_seq = @invoice_line_item_seq
			--	AND s.formula_level=t.formula_level
				AND s.level_func_sno=t.parent_level_func_sno
				AND s.prod_date=t.prod_date
				AND ISNULL(s.[hour],0)=ISNULL(t.[Hour],0)
				AND ISNULL(s.[mins],0)=ISNULL(t.[mins],0)
				AND ISNULL(s.source_deal_detail_id,-1)=ISNULL(t.source_deal_detail_id,-1)
				AND ISNULL(s.source_deal_header_id,-1)=ISNULL(t.source_deal_header_id,-1)
				AND s.is_dst=t.is_dst
				AND s.as_of_date = t.as_of_date
				
			--s.rowid = t.rowid
--SELECT 'after updating args'
--SELECT * FROM #formula_breakdown
--select * from #formula_breakdown
--WHERE 
--formula_level= @i AND isnull(nested_id,0)=@j AND parent_nested_id is NULL AND eval_value IS null -- AND func_name<>'FNALagCurve'
 								
			--EXEC spa_print 'log10a UPDATE next func argument elapse time'+': '+convert(VARCHAR(8),dateadd(ss,DATEDIFF(ss,@calc_start_time,GETDATE()),'00:00:00'),108)  +'*************************************'
			

			--EXEC spa_print 'log10.2 UPDATE cache functiON FNARLagCurve elapse time'+': '+convert(VARCHAR(8),dateadd(ss,DATEDIFF(ss,@calc_start_time,GETDATE()),'00:00:00'),108)  +'*************************************'		

			SET @i=@i-1	  
			DROP TABLE #tmp_next_level_func_args
			
				
				
		END --@i
--select * from #formula_breakdown


/*
		SET @date_filter=
			CASE WHEN @parent_granularity=980 THEN
					' AND (dbo.FNAGetContractMonth(c.prod_date)=dbo.FNAGetContractMonth(p.prod_date))'
				 WHEN @parent_granularity=981 THEN
				 	' AND (c.prod_date=p.prod_date)'
				 WHEN @parent_granularity=982 THEN
				 	' AND ((c.prod_date=p.prod_date  AND '+@granularity+'=981)
						OR (c.prod_date=p.prod_date AND ISNULL(c.[hour],0)=ISNULL(p.[Hour],0) AND '+@granularity+'=982)
						OR (c.prod_date=p.prod_date AND ISNULL(c.[hour],0)=ISNULL(p.[Hour],0) AND ISNULL(c.[mins],0)=ISNULL(p.[mins],0) AND'+@granularity+'=987)
						OR (dbo.FNAGetContractMonth(c.prod_date)=dbo.FNAGetContractMonth(p.prod_date)  AND '+@granularity+'=980)
					)'
				 ELSE ''	
			END

*/

		SET @date_filter=
			CASE WHEN @parent_granularity=980 THEN
					' AND convert(varchar(7),c.prod_date,120)=convert(varchar(7),p.prod_date,120)'
				 WHEN @parent_granularity=981 THEN
				 	' AND c.prod_date=p.prod_date'
				 WHEN @parent_granularity=982 THEN
				 	' AND ' + CASE  @granularity WHEN 981 THEN 'c.prod_date=p.prod_date '
				 				WHEN 982 THEN 'c.prod_date=p.prod_date AND ISNULL(c.[hour],0)=ISNULL(p.[Hour],0) AND c.is_dst=p.is_dst'
				 				WHEN 987 THEN 'c.prod_date=p.prod_date AND ISNULL(c.[hour],0)=ISNULL(p.[Hour],0) AND ISNULL(c.[mins],0)=ISNULL(p.[mins],0) AND c.is_dst=p.is_dst '
								WHEN 989 THEN 'c.prod_date=p.prod_date AND ISNULL(c.[hour],0)=ISNULL(p.[Hour],0) AND ISNULL(c.[mins],0)=ISNULL(p.[mins],0) AND c.is_dst=p.is_dst '
								WHEN 994 THEN 'c.prod_date=p.prod_date AND ISNULL(c.[hour],0)=ISNULL(p.[Hour],0) AND ISNULL(c.[mins],0)=ISNULL(p.[mins],0) AND c.is_dst=p.is_dst '
								WHEN 995 THEN 'c.prod_date=p.prod_date AND ISNULL(c.[hour],0)=ISNULL(p.[Hour],0) AND ISNULL(c.[mins],0)=ISNULL(p.[mins],0) AND c.is_dst=p.is_dst '
								WHEN 980 THEN 'convert(varchar(7),c.prod_date,120)=convert(varchar(7),p.prod_date,120)'
								ELSE ' c.prod_date=p.prod_date  '
							END 
				 WHEN @parent_granularity IN(987,989,994,995) THEN ' AND c.prod_date=p.prod_date AND ISNULL(c.[hour],0)=ISNULL(p.[Hour],0) AND ISNULL(c.[mins],0)=ISNULL(p.[mins],0) AND c.is_dst=p.is_dst '
				 ELSE ''	
			END

	--SELECT p.rowid,SUM(ISNULL(r.eval_value,cfv.eval_value))eval_value,p.prod_date,p.[Hour],p.[mins],p.is_dst,source_deal_detail_id,source_deal_header_id 

	
	--select * into adiha_process.dbo.temp_UD_sql from #temp_UD_sql
	--select * into adiha_process.dbo.temp_cfv from 4

	UPDATE fb
		SET fb.eval_value = CAST(CAST(tus.[ud_sql_value] as FLOAT) AS NUMERIC(38,6))
		FROM
			#temp_UD_sql tus
			INNER JOIN #formula_breakdown fb ON fb.formula_id = tus.formula_id
				AND isnull(fb.nested_id,0) = isnull(tus.nested_id,0)
				AND isnull(fb.invoice_line_item_id,-1) = isnull(tus.invoice_line_item_id,-1)
				AND fb.prod_date = tus.prod_date
				AND isnull(fb.[Hour],tus.[hour]) = tus.[hour]
				AND isnull(fb.[mins],tus.[mins]) = tus.[mins]	
				AND isnull(fb.source_deal_header_id,-1) = isnull(tus.source_deal_header_id,-1)	
				AND isnull(fb.source_deal_detail_id,-1) = isnull(tus.source_deal_detail_id,-1)		
				AND isnull(fb.contract_id,-1) = isnull(tus.contract_id,-1)		
				AND isnull(fb.counterparty_id	,-1) = isnull(tus.counterparty_id,-1)

	select * into #formula_breakdown_pt from #formula_breakdown where func_name = 'ROW'
			
	SET @sqlstmt=' 
--
		SELECT p.rowid,CASE WHEN r.arg3=1  THEN AVG(r.eval_value) ELSE SUM(r.eval_value) END eval_value,p.prod_date,p.[Hour],p.[mins],p.is_dst,source_deal_detail_id,source_deal_header_id 
--SELECT p.rowid,CASE WHEN r.arg3=1  THEN AVG(COALESCE(r.eval_value,cfv.eval_value)) ELSE SUM(COALESCE(r.eval_value,cfv.eval_value)) END eval_value,p.prod_date,p.[Hour],p.[mins],p.is_dst,source_deal_detail_id,source_deal_header_id 
			INTO #tmp_nested_eval
		FROM #formula_breakdown_pt p with(nolock) CROSS APPLY
			( SELECT COALESCE(tus.[ud_sql_value],c.eval_value,0) eval_value,CAST(NULLIF(p.arg3,''NULL'') AS INT) arg3 
			FROM #formula_breakdown c  with(nolock)
				LEFT JOIN #temp_UD_sql tus with(nolock) ON tus.contract_id =	c.contract_id
					AND tus.counterparty_id =	c.counterparty_id
					AND ISNULL(tus.generator_id,-1) = ISNULL(c.generator_id,-1)
					AND tus.invoice_line_item_id =	c.invoice_line_item_id
					AND tus.formula_id =	c.formula_id
					AND ISNULL(tus.nested_id,0)=isnull(c.nested_id,0) 
 					AND ISNULL(tus.source_deal_detail_id,-1)=ISNULL(c.source_deal_detail_id,-1)
					AND ISNULL(tus.source_deal_header_id,-1)=ISNULL(c.source_deal_header_id,-1)				
					AND tus.prod_date =	c.prod_date  
					AND tus.[Hour] = c.[Hour]  		
				AND tus.[mins] = c.[mins]	
				AND tus.[is_dst] = c.[is_dst]	
			WHERE p.formula_id=c.formula_id 
			AND isnull(p.parent_nested_id,0)=isnull(c.nested_id,0) 
				 --AND p.source_id=c.source_id 
				 AND c.nested_id='+CAST(@j AS VARCHAR)+'
				 AND c.invoice_line_item_seq = '+CAST(@invoice_line_item_seq AS VARCHAR)+'
				 AND c.arg_no_for_next_func IS NULL
				 AND  ISNULL(p.source_deal_detail_id,-1)=ISNULL(c.source_deal_detail_id,-1)
				 AND  ISNULL(p.source_deal_header_id,-1)=ISNULL(c.source_deal_header_id,-1) 
				 AND p.counterparty_id=c.counterparty_id 
				 AND p.contract_id = c.contract_id 
				 AND p.invoice_line_item_id = c.invoice_line_item_id 
				 AND c.nested_id>0
				 AND p.final_offset_date = CASE WHEN p.granularity IN(982,987,989,994,995) THEN c.final_date WHEN p.granularity IN(981) THEN c.prod_date ELSE CAST(CONVERT(VARCHAR(7),c.final_date,120)+''-01'' AS DATETIME) END
				 AND c.is_dst=p.is_dst 
				 and  isnumeric(c.eval_value)=1 
				) r	
			OUTER APPLY(
				SELECT ISNULL(value,0) eval_value FROM #temp_cfv
				WHERE  seq_number = ISNULL(p.parent_nested_id,0)
				AND seq_number = ISNULL(p.parent_nested_id,0) 
				AND  ISNULL(source_deal_detail_id,-1)=ISNULL(p.source_deal_detail_id,-1)
				AND  ISNULL(source_deal_header_id,-1)=ISNULL(p.source_deal_header_id,-1)
				AND formula_id = p.formula_id
				AND p.arg2 IS NOT NULL
				AND final_date = CASE WHEN p.arg2 IS NULL THEN p.final_date ELSE	
						CASE WHEN granularity = 982 THEN DATEADD(HH,CAST(NULLIF(p.arg2,''NULL'') AS INT),p.final_date)
							 WHEN granularity = 987 THEN DATEADD(MI,CAST(NULLIF(p.arg2,''NULL'') AS INT)*15,p.final_date)
							 WHEN granularity = 989 THEN DATEADD(MI,CAST(NULLIF(p.arg2,''NULL'') AS INT)*30,p.final_date)
							 WHEN granularity = 994 THEN DATEADD(MI,CAST(NULLIF(p.arg2,''NULL'') AS INT)*10,p.final_date)
							 WHEN granularity = 995 THEN DATEADD(MI,CAST(NULLIF(p.arg2,''NULL'') AS INT)*5,p.final_date)
							 WHEN granularity = 981 THEN DATEADD(D,CAST(NULLIF(p.arg2,''NULL'') AS INT),p.final_date)
							 WHEN granularity = 980 THEN DATEADD(m,CAST(NULLIF(p.arg2,''NULL'') AS INT),p.final_date)
						ELSE p.final_date END END
				AND is_dst = p.is_dst						
				)cfv 
		WHERE p.func_name = ''ROW''		
		GROUP BY r.arg3,p.rowid,p.prod_date,p.[Hour],p.[mins],p.is_dst,source_deal_detail_id,source_deal_header_id 		
		if @@ROWCOUNT>0
			UPDATE  #formula_breakdown with (rowlock) set eval_value=rtrim(ltrim(str(c.eval_value,38,10))) 
				FROM #formula_breakdown p 
				INNER JOIN #tmp_nested_eval c ON p.rowid=c.rowid 
				'+@date_filter+' 
				AND  ISNULL(p.source_deal_detail_id,-1)=ISNULL(c.source_deal_detail_id,-1)
				AND  ISNULL(p.source_deal_header_id,-1)=ISNULL(c.source_deal_header_id,-1) 
			WHERE c.eval_value is not null	and isnumeric(c.eval_value)=1
			drop table #formula_breakdown_pt			
			DROP TABLE #tmp_nested_eval	
		 	
			'
		exec spa_print @sqlstmt
		EXEC(@sqlstmt)	
	
		/*RowSum related logic was removed*/
		
		--EXEC spa_print 'log10a UPDATE nested  elapse time'+': '+convert(VARCHAR(8),dateadd(ss,DATEDIFF(ss,@calc_start_time,GETDATE()),'00:00:00'),108)  +'*************************************'
		
			
		SET @j=@j+1	  

		--	Save only answers, These intermediate results are used for GetVatAmount function
	   INSERT INTO calc_line_item_formula_value(counterparty_id,contract_id,prod_date,as_of_date,invoice_line_item_id,formula_id,source_id,nested_id,contract_value,process_id)
		SELECT fb_max.counterparty_id,
			   fb_max.contract_id,
			   MAX(dbo.FNAGetContractMonth(fb_max.prod_date)) prod_date,
			   fb_max.as_of_date,
			   fb_max.invoice_line_item_id,
			   fb_max.formula_id,
			   fb_max.source_id,
			   MAX(fb_max.nested_id)     nested_id,
			   SUM(CAST(fb_max.eval_value AS FLOAT))		 contract_value,
			   @process_id
		FROM   #formula_breakdown        fb_max
		CROSS APPLY (
						SELECT TOP 1 
							   SUM(CAST(fb.eval_value AS FLOAT)) contract_value,
							    MAX(fb.nested_id) nested_id 
						FROM   #formula_breakdown fb
						WHERE  fb.arg_no_for_next_func IS NULL
							   AND fb.invoice_line_item_id = fb_max.invoice_line_item_id
							   --AND fb.prod_date = fb_max.prod_date
						GROUP BY fb.invoice_line_item_id, fb.invoice_line_item_seq, fb.formula_id, fb.arg_no_for_next_func, fb.counterparty_id,fb.contract_id
						ORDER BY fb.invoice_line_item_id
					) ans
		WHERE  fb_max.arg_no_for_next_func IS NULL		
		AND fb_max.invoice_line_item_seq = @invoice_line_item_seq
		AND ans.contract_value IS NOT NULL
		AND fb_max.nested_id = ans.nested_id
		GROUP BY fb_max.counterparty_id, fb_max.contract_id,fb_max.as_of_date, fb_max.invoice_line_item_id, fb_max.formula_id, fb_max.source_id, fb_max.arg_no_for_next_func
		    		    
	END --@j
	    -- Delete saved intermediate results when getvatamount function is found.		    
	    IF EXISTS(SELECT 1 FROM #formula_breakdown WHERE invoice_line_item_seq = @invoice_line_item_seq AND func_name LIKE '%GetVatAmount%')
		BEGIN
			-- Delete calculated invoice line item answer (GetVatAmount)
			DELETE clifv FROM calc_line_item_formula_value clifv
			INNER JOIN #formula_breakdown fb ON clifv.invoice_line_item_id = fb.invoice_line_item_id
			WHERE fb.invoice_line_item_seq = @invoice_line_item_seq
			
			DELETE FROM  calc_line_item_formula_value WHERE process_id = @process_id
		END	    
		SET @invoice_line_item_seq = @invoice_line_item_seq +1	 
	END --@source_id
	
	
--select * from #formula_breakdown
--SELECT * FROM #formula_breakdown ORDER BY arg3, arg4, arg2, arg1
	--##### update the formula evaluatio value from UD SQl
				
				
	DECLARE @calc_process_id VARCHAR(100)
	SET @calc_process_id = REPLACE(newid(),'-','_')

	IF @calc_result_table IS NULL 
	BEGIN
		SET @calc_result_table = dbo.FNAProcessTableName('formula_calc_result', @user_login_id,@process_id)
	END
	
	IF @calc_result_detail_table IS NULL 
	BEGIN
		SET @calc_result_detail_table = dbo.FNAProcessTableName('formula_calc_result_detail', @user_login_id,@process_id)
	END

	if OBJECT_ID(@calc_result_detail_table) is not null
	exec('drop table '+@calc_result_detail_table)
	
	if OBJECT_ID(@calc_result_table) is not null
	exec('drop table '+@calc_result_table)

	SET @sqlstmt='
			SELECT
					source_id,
					nested_id,
					row_number()OVER(ORDER BY nested_id,level_func_sno) seq_number,
					CASE WHEN func_name LIKE ''%LagCurve%'' THEN arg5
						 WHEN func_name LIKE ''%CurveM%'' THEN arg3	
						 WHEN func_name LIKE ''%CurveD%'' THEN arg3	
						 WHEN func_name LIKE ''%CurveH%'' THEN arg3	
						 WHEN func_name LIKE ''%Curve15%'' THEN arg3	
					--	 WHEN func_name LIKE ''%GetCurveValue%'' THEN arg3	
					ELSE NULL END curve_id, 
					cast(eval_value as numeric(28,10)) eval_value,
					prod_date,
					[hour],
					[mins],source_deal_detail_id,
					is_dst,
					source_deal_header_id,
					func_name,
					counterparty_id,
					invoice_line_item_id,
					contract_id					
			INTO '+@calc_result_detail_table+'		
			FROM
				#formula_breakdown WHERE func_name NOT IN(''+'',''-'',''*'',''/'')	
				--and  isnumeric(eval_value)=1 '	
				
	exec spa_print @sqlstmt		
	EXEC(@sqlstmt)				
	exec ('create index ix_pt_cc_fv on  '+@calc_result_detail_table+' (source_id,nested_id,prod_date,[hour],[mins],[is_dst],source_deal_detail_id,source_deal_header_id)')
	exec ('create index indx_formula_calc_result_detail_111 on  '+@calc_result_detail_table+' ([source_id],[nested_id],[prod_date],[hour],[mins],[is_dst])
		INCLUDE ([eval_value],[source_deal_detail_id],[source_deal_header_id])')

	SET @sqlstmt='
	SELECT 
		 source_id,nested_id,prod_date,[hour],[mins],is_dst,source_deal_detail_id,source_deal_header_id
		, REPLACE(RTRIM((SELECT CONVERT(varchar(100), CAST(eval_value AS decimal(38,4)))  + '' '' FROM '+@calc_result_detail_table+' with(nolock)
			 WHERE (source_id = Results.source_id AND nested_id = Results.nested_id AND prod_date = Results.prod_date AND [hour] = Results.[hour] AND [mins] = Results.[mins] AND [is_dst] = Results.[is_dst] AND ISNULL(source_deal_detail_id,'''') = ISNULL(Results.source_deal_detail_id,'''') AND ISNULL(source_deal_header_id,'''') = ISNULL(Results.source_deal_header_id,'''')) FOR XML PATH (''''))),'' '','', '')
		AS NameValues 
	INTO #formula_detail	
	FROM '+@calc_result_detail_table+' Results with(nolock)  
	--where isnumeric(eval_value)=1 
	GROUP BY source_id,nested_id,prod_date,[hour],[mins],[is_dst],source_deal_detail_id,source_deal_header_id
	
	create index idx_formula_detail1111 on #formula_detail (source_id ,source_deal_detail_id,source_deal_header_id,nested_id ,prod_date,[hour],[mins]	,[is_dst]);

	SELECT ISNULL(fn.formula_group_id,fe.formula_id) formula_group_id,MAX(ISNULL(sequence_order,1)) sequence_order  into #tmp_func
		FROM formula_editor fe LEFT JOIN formula_nested fn ON fe.formula_id=fn.formula_id CROSS APPLY(SELECT formula_id FROM #formula_breakdown WHERE formula_id = ISNULL(fn.formula_group_id,fe.formula_id)) fb
		 GROUP BY ISNULL(fn.formula_group_id,fe.formula_id);
		
	create index idx_tmp_func_111 on #tmp_func (formula_group_id,sequence_order);
	SELECT b.source_id,m.counterparty_id,m.contract_id,b.formula_id,m.source_deal_detail_id,m.curve_id,m.generator_id,
	m.formula_id formula_group_id,b.nested_id formula_sequence_number,m.invoice_line_item_id,m.invoice_line_item_seq_id,
	m.prod_date,m.as_of_date,m.[hour],cast(ISNULL(b.[eval_value], 0) as numeric(28,10)) AS [formula_eval_value],m.volume,
	m.volume_uom_id,fd.NameValues AS eval_string,CASE WHEN fn.formula_group_id IS NOT NULL THEN ''y'' ELSE ''n'' END is_final_result,
	m.commodity_id,m.granularity,m.[mins],m.is_dst,b.source_deal_header_id,b.allocation_volume,b.netting_group_id,b.invoice_granularity,b.is_true_up
	,m.ticket_detail_id,m.shipment_id
	INTO '+@calc_result_table+'		
	FROM '+@calc_process_table+' m
		inner join #formula_breakdown b
		 	ON m.rowid=b.source_id   
			AND m.[granularity]=b.granularity
			AND m.[prod_date]=b.[prod_date]
			AND ISNULL(m.[hour],0)=ISNULL(b.[hour],0)
			AND ISNULL(m.[mins],0)=ISNULL(b.[mins],0)
			AND ISNULL(m.[source_deal_detail_id],-1)=ISNULL(b.[source_deal_detail_id],-1)
			AND ISNULL(m.[source_deal_header_id],-1)=ISNULL(b.[source_deal_header_id],-1)
			AND ISNULL(m.is_dst,0)=b.is_dst
			AND arg_no_for_next_func IS NULL
			AND m.as_of_date = b.as_of_date
			AND ISNULL(m.[curve_id],-1)=ISNULL(b.[curve_id],-1)
		LEFT JOIN #tmp_func fn 
				ON fn.formula_group_id=m.formula_id AND fn.sequence_order=ISNULL(b.nested_id,0)
		LEFT JOIN #formula_detail fd ON 
			fd.source_id = 	b.source_id
			--AND fd.source_id = 	b.source_id
			AND ISNULL(fd.source_deal_detail_id,'''') =	ISNULL(b.source_deal_detail_id,'''')
			AND ISNULL(fd.source_deal_header_id,'''') =	ISNULL(b.source_deal_header_id,'''')
			AND fd.nested_id = 	b.nested_id
			AND fd.prod_date = 	b.prod_date
			AND fd.[hour] = 	b.[hour]
			AND fd.[mins] = 	b.[mins]
			AND fd.[is_dst] = 	b.[is_dst]
		where 1=1 
		--AND isnumeric(b.eval_value)=1
	order by b.nested_id'
	
	exec spa_print @sqlstmt	
	EXEC(@sqlstmt)
	--EXEC('select ''@calc_process_table'',* from ' + @calc_process_table)
end 	
DELETE FROM calc_line_item_formula_value WHERE process_id = @process_id
exec('	CREATE INDEX [IX_PT_formula_calc_result_1111111111] ON '+ @calc_result_table +' ([counterparty_id], [contract_id], [invoice_line_item_id], [is_final_result]) INCLUDE ([source_deal_detail_id], [prod_date], [formula_eval_value], [source_deal_header_id], [invoice_granularity])')



--select * from #formula_breakdown
-- select * from formula_breakdown where formula_id= 777
--select * from formula_editor where formula_id= 777
--select * from adiha_process.dbo.curve_formula_table2_farrms_admin_CC7E1C60_1B2A_48E1_AC34_E6FA79004342
-- select dbo.FNARECCurve('2014-10-10','2012-03-06',10,1)
--arg1	arg2	arg3	arg4
--2014-10-10 00:00:00	2012-03-07 00:00:00	10	1.000000000000000e+000
--update adiha_process.dbo.curve_formula_table2_farrms_admin_CC7E1C60_1B2A_48E1_AC34_E6FA79004342 set as_of_date='2012-03-06'

--select dbo.FNARUDFValue(44494 ,980,'2014-07-01','2012-03-06',null,null,null,null,13,'2012-03-06',-5556)

--select * from adiha_process.dbo.curve_formula_table2_farrms_admin_CC7E1C60_1B2A_48E1_AC34_E6FA79004342
-- select * from #formula_breakdown		


