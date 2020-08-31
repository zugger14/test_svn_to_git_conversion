IF OBJECT_ID('spa_calc_explain_position') IS NOT NULL
	DROP PROC dbo.spa_calc_explain_position
GO

/*
EXEC [dbo].[spa_calc_explain_position] 
     @as_of_date_from = '2013-04-04' --?????
     ,
     @as_of_date_to = '2013-04-05' --?????
     ,
     @term_start = NULL,
     @term_end = NULL,
     @sub = NULL,
     @str = NULL,
     @book = NULL,
     @source_deal_header_ids = '166419' --?????
     ,
     @deal_ids = NULL,
     @run_mode = 2 --@run_mode = 0: Calculation only .
                   --@run_mode = 1: Calculation and return data.
                   --@run_mode = 2: Return data without calculating.
                   --@run_mode = 3: Return data from Explain Position Table.
     ,
     @calc_type = 'm' --p = position; m = mtm; b=both calculation only(@run_mode=0)
     ,
     @commodity = NULL,
     @index = NULL,
     @round = 4,
     @discounted_mtm = 'n',
     @purge = 'n',
     @deal_level  = 'n'  
	

	
EXEC [dbo].[spa_calc_explain_position] 
     @as_of_date_from = '2012-01-16' --?????
     ,
     @as_of_date_to = '2012-01-17' --?????
     ,
     @term_start = NULL,
     @term_end = NULL,
     @sub = NULL,
     @str = NULL,
     @book = NULL,
     @source_deal_header_ids = '166419' --?????
     ,
     @deal_ids = NULL,
     @run_mode = 2 --@run_mode = 0: Calculation only .
                   --@run_mode = 1: Calculation and return data.
                   --@run_mode = 2: Return data without calculating.
                   --@run_mode = 3: Return data from Explain Position Table.
     ,
     @calc_type = 'm' --p = position; m = mtm; b=both calculation only(@run_mode=0)
     ,
     @commodity = NULL,
     @index = NULL,
     @round = 4,
     @discounted_mtm = 'n',
     @purge = 'n',
     @deal_level VARCHAR(1) = 'y'	
	
	
*/
create PROC [dbo].[spa_calc_explain_position] 
	@as_of_date_from  DATETIME= NULL
	,@as_of_date_to DATETIME 
	,@term_start DATETIME = NULL
	,@term_end DATETIME = NULL
	,@sub VARCHAR(200) = NULL
	,@str VARCHAR(200) = NULL
	,@book VARCHAR(200) = NULL
	,@source_deal_header_ids VARCHAR(500) = NULL
	,@deal_ids VARCHAR(1000) = NULL
	,@run_mode  INT = 2 --@run_mode = 0: Calculation only (this option is used scheduled job).
	                    --@run_mode = 1: Calculation and return data.
	                    --@run_mode = 2: Return data without calculating. (adhoc query=y)
	                    --@run_mode = 3: Return data from Explain Position Table.(adhoc query=n)
	,@calc_type  VARCHAR(1) = 'm' --p = position; m = mtm; b=both calculation only(@run_mode=0)
	,@commodity VARCHAR(200) = NULL
	,@index VARCHAR(MAX) = NULL
	,@round VARCHAR(1) = NULL
	,@discounted_mtm VARCHAR(1)='n'
	,@purge VARCHAR(1)='n' --option for delete existing record: y: delete with criteria as_of_date; n:delete  with criteria as_of_date n book
	,@deal_level VARCHAR(1)='y'  ---report include deal id when @run_mode=2
	,@batch_process_id VARCHAR(100) = NULL
	,@batch_report_param VARCHAR(1000) = NULL
	,@enable_paging INT = 0 --'1' = enable, '0' = disable
	,@page_size INT = NULL
	,@page_no INT = NULL
AS



/*



DECLARE @as_of_date_from         DATETIME = '2013-08-21',	-- '2012-01-16', --'2012-01-16'
        @as_of_date_to           DATETIME = '2013-08-22',	--'2012-01-17',
        @sub                     VARCHAR(200) = NULL,	--'148',
        @str                     VARCHAR(200) = NULL,	--'150',
        @term_start              DATETIME = NULL,
        @term_end                DATETIME = NULL,
        @book                    VARCHAR(200) = null,	--'158' ,--'206',
        @source_deal_header_ids  VARCHAR(500) ='582' ---'125593'--'121158'-- 
        /*
        '104249'= fees  ; '125069'=new;122638= new/fee as_of_date='2012-01-15' - '2012-01-16'
        ;125599=pricechange/contract side only; 3856=pricechange/contract side only/financial
        ;25467=cancel deal;  48541=deleted; 121158=deliver 
        ;125593=reforecast /need to comment update modify statement
        
        */,
        @deal_ids                VARCHAR(1000) = NULL,
        @process_tbl             VARCHAR(200),
        @run_mode                INT = 2,
        @calc_type               VARCHAR(1) = 'm',
        @commodity               VARCHAR(200) = null,
        @index                   VARCHAR(200) = null,
        @round                   VARCHAR(1) = '8',
        @discounted_mtm          VARCHAR(1) = 'n',
        @purge VARCHAR(1)='n', --option for delete existing record: y: delete with criteria as_of_date; n:delete  with criteria as_of_date n book
	@deal_level VARCHAR(1)='y',  ---report include deal id when @run_mode=2

        @batch_process_id        VARCHAR(50) = NULL,
        @batch_report_param      VARCHAR(1000) = NULL,
        @enable_paging           INT = 0,	--'1' = enable, '0' = disable
        @page_size               INT = NULL,
        @page_no                 INT = NULL

DROP TABLE #book


----value_id	type_id	code
----17401	17400	New Deal
----17402	17400	Deleted Deal
----17403	17400	Forecast Volume Change
----17404	17400	Deal Change
----17405	17400	Volume delivered

--update delete_source_deal_header set create_ts=GETDATE()-1 where source_deal_header_id=4099


--select * from explain_mtm



--*/

/*







DECLARE @sub                 VARCHAR(200) = NULL,	--'148',
        @str                 VARCHAR(200) = NULL,	--'150',
        @term_start          DATETIME = NULL,
        @term_end            DATETIME = NULL,
        @book                VARCHAR(200) = NULL --'158' ,--'206',
        
        
        /*'104249'= fees  ; '125069'=new;122638= new/fee as_of_date='2012-01-15' - '2012-01-16'
        ;125599=pricechange/contract side only; 3856=pricechange/contract side only/financial
        ;25467=cancel deal;  48541=deleted; 121158=deliver 
        ;125593=reforecast /need to comment update modify statement
        
        */,
        @deal_ids            VARCHAR(1000) = NULL,
        @run_mode            INT = 2,
        @commodity           VARCHAR(200) = NULL,
        @index               VARCHAR(200) = NULL,
        @round               VARCHAR(1) = '4',
        @discounted_mtm      VARCHAR(1) = 'n',
        @purge               VARCHAR(1) = 'n',
        @batch_process_id    VARCHAR(50) = NULL,
        @batch_report_param  VARCHAR(1000) = NULL,
        @enable_paging       INT = 0,	--'1' = enable, '0' = disable
        @page_size           INT = NULL,
        @page_no             INT = NULL
        

*/

---For Debug in deal level mtm explain---
declare @filter_counterparty_id int =null
	,@filter_book_deal_type_map_id int =Null
	,@orginal_run_mode int=null

if @run_mode=9
begin
	set @orginal_run_mode=@run_mode
	set @run_mode =2
	set @deal_level ='y'
end
else
begin
	set @filter_counterparty_id  =null
	set @filter_book_deal_type_map_id=null
end

       
DECLARE @status_type	VARCHAR(1)
DECLARE @desc			VARCHAR(5000)
DECLARE @error_count	INT 
DECLARE @saved_records	INT
DECLARE @stmt			VARCHAR(8000)
-----------------------------------------


DECLARE @baseload_block_type                                VARCHAR(10)
DECLARE @baseload_block_define_id                           VARCHAR(10)--,@orginal_summary_option CHAR(1)
DECLARE @st1                                                VARCHAR(MAX),
        @st2                                                VARCHAR(MAX),
        @st2_0                                              VARCHAR(MAX),
        @st2a                                               VARCHAR(MAX),
        @st2b                                               VARCHAR(MAX),
        @st3                                                VARCHAR(MAX),
        @st4                                                VARCHAR(MAX),
        @st5                                                VARCHAR(MAX),
        @st_fields                                          VARCHAR(MAX),
        @st_group_by                                        VARCHAR(MAX),
        @st_from                                            VARCHAR(MAX),
        @st_term                                            VARCHAR(1000),
        @st_criteria                                        VARCHAR(MAX),
        @source_deal_header                                 VARCHAR(200),
        @source_deal_detail                                 VARCHAR(200),
        @report_hourly_position_breakdown                   VARCHAR(200),
        @delta_report_hourly_position_breakdown             VARCHAR(200),
        @report_hourly_position_breakdown_detail            VARCHAR(200),
        @delta_report_hourly_position_breakdown_detail      VARCHAR(200),
        @report_hourly_position_breakdown_detail_delivered  VARCHAR(300),
        @report_hourly_position_breakdown_detail_ending     VARCHAR(300),
        @modify_status										VARCHAR(300),
        @price_change_value									VARCHAR(300),

        @index_fee_breakdown_reforecast                     VARCHAR(300),
        @temp_discounted_mtm_factor                         VARCHAR(200),
        @delivered_position                                 VARCHAR(200),
        @deferral_temp_explain_mtm                          VARCHAR(200),
        @tmp_price_changed_phy                              VARCHAR(200),
        @tmp_price_changed_formula                          VARCHAR(200),
        @fin_term_ratio                                     VARCHAR(200),
        @temp_explain_mtm_formula                           VARCHAR(200),
        @temp_explain_mtm                                   VARCHAR(200),
        @final_explain_mtm                                  VARCHAR(200),
        @forecast_position                                  VARCHAR(200),
        @explain_reforecast_deals                           VARCHAR(300),
        @explain_delivered_mtm                              VARCHAR(200),
        @explain_modified_mtm                               VARCHAR(200),
        @sum_left_side_term                                 VARCHAR(200),
        @left_side_term                                     VARCHAR(200),
        @process_id                                         VARCHAR(150),
        @tmp_price_diff                                     VARCHAR(200),
        @udf_modify											VARCHAR(200),
		@delta_price_changed_t0								VARCHAR(200),
		@delta_price_changed_t1								VARCHAR(200),
        @deal_filters										VARCHAR(200),
		@udf_status											VARCHAR(200),
        --@tmp_price_diff_distinct   VARCHAR(200),
        @tmp_price_diff_distinct_t0                         VARCHAR(200),
        @tmp_price_diff_distinct_t1                         VARCHAR(200),
        @str_batch_table                                    VARCHAR(MAX),
        @begin_time                                         DATETIME,
        @user_login_id                                      VARCHAR(50),
        @position_detail                                    VARCHAR(150),
        @select_fix                                         VARCHAR(MAX),
        @hr_columns                                         VARCHAR(MAX),
        @fin_columns                                        VARCHAR(MAX),
        @phy_columns                                        VARCHAR(MAX),
        @curve_source_id                                    INT = 4500,
        @dst                                                VARCHAR(MAX)


DECLARE @sp_name         VARCHAR(100)
DECLARE @report_name     VARCHAR(100)
DECLARE @is_batch        BIT
DECLARE @sql_paging      VARCHAR(8000)
DECLARE @tmp_date        VARCHAR(10)
DECLARE @delivered_date  DATE,
        @job_name        VARCHAR(500),
        @spa             VARCHAR(MAX)

declare @added_term varchar(250),@deleted_term varchar(250)

DECLARE @default_holiday_id INT,@start_time datetime
SET @default_holiday_id = 291898

IF @run_mode <> 2
    SET @deal_level = 'n' 

set @start_time=GETDATE()

SET @process_id = ISNULL(@batch_process_id, REPLACE(NEWID(), '-', '_'))
SET @user_login_id = dbo.FNADBUser() 
SET @begin_time = GETDATE()

SELECT @as_of_date_from = ISNULL(@as_of_date_from, dbo.FNAGetBusinessDay('p', @as_of_date_to, @default_holiday_id))

IF @calc_type = 'b'
    SET @run_mode = 0

SET @as_of_date_to = ISNULL(@as_of_date_to, GETDATE())

IF @as_of_date_from > @as_of_date_to
    SET @as_of_date_from = @as_of_date_to
	
SET @baseload_block_type = '12000'	-- Internal Static Data
SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10)) FROM static_data_value WHERE [TYPE_ID] = 10018 AND code LIKE 'Base Load' -- External Static Data

IF @baseload_block_define_id IS NULL
    SET @baseload_block_define_id = 'NULL'

DECLARE @process_id_reforecast VARCHAR(150)
SET @process_id_reforecast=@process_id +'_1'

SET @added_term = dbo.FNAProcessTableName('added_term', @user_login_id, @process_id)
SET @deleted_term = dbo.FNAProcessTableName('deleted_term', @user_login_id, @process_id)

SET @position_detail = dbo.FNAProcessTableName('explain_position_detail', @user_login_id, @process_id)
SET @source_deal_header = dbo.FNAProcessTableName('source_deal_header', @user_login_id, @process_id)
SET @source_deal_detail = dbo.FNAProcessTableName('source_deal_detail', @user_login_id, @process_id)

SET @report_hourly_position_breakdown = dbo.FNAProcessTableName('report_hourly_position_breakdown', @user_login_id, @process_id)
SET @delta_report_hourly_position_breakdown = dbo.FNAProcessTableName('delta_report_hourly_position_breakdown', @user_login_id, @process_id)
SET @report_hourly_position_breakdown_detail = dbo.FNAProcessTableName('report_hourly_position_breakdown_detail', @user_login_id, @process_id)
SET @delta_report_hourly_position_breakdown_detail = dbo.FNAProcessTableName('delta_report_hourly_position_breakdown_detail', @user_login_id, @process_id)
SET @report_hourly_position_breakdown_detail_delivered = dbo.FNAProcessTableName('report_hourly_position_breakdown_detail_delivered', @user_login_id, @process_id)
SET @report_hourly_position_breakdown_detail_ending = dbo.FNAProcessTableName('report_hourly_position_breakdown_detail_ending', @user_login_id, @process_id)
SET @forecast_position=dbo.FNAProcessTableName('forecast_position', @user_login_id, @process_id_reforecast)
SET @explain_reforecast_deals=dbo.FNAProcessTableName('explain_reforecast_deals', @user_login_id, @process_id_reforecast)
SET @index_fee_breakdown_reforecast=dbo.FNAProcessTableName('index_fees_breakdown_forecast', @user_login_id, @process_id_reforecast)
SET @explain_delivered_mtm=dbo.FNAProcessTableName('explain_delivered_mtm', @user_login_id, @process_id)
SET @explain_modified_mtm =dbo.FNAProcessTableName('explain_modified_mtm', @user_login_id, @process_id)
SET @tmp_price_changed_phy=dbo.FNAProcessTableName('tmp_price_changed_phy', @user_login_id, @process_id)
SET @tmp_price_changed_formula =dbo.FNAProcessTableName('tmp_price_changed_formula', @user_login_id, @process_id)
SET @sum_left_side_term  =dbo.FNAProcessTableName('sum_left_side_term', @user_login_id, @process_id)
SET @left_side_term  =dbo.FNAProcessTableName('left_side_term', @user_login_id, @process_id)
SET @tmp_price_diff =dbo.FNAProcessTableName('tmp_price_diff', @user_login_id, @process_id)
SET @fin_term_ratio =dbo.FNAProcessTableName('fin_term_ratio', @user_login_id, @process_id)
SET @deal_filters =dbo.FNAProcessTableName('deal_filters', @user_login_id, @process_id)
SET @price_change_value =dbo.FNAProcessTableName('price_change_value', @user_login_id, @process_id)
SET @udf_status =dbo.FNAProcessTableName('udf_status', @user_login_id, @process_id)

SET @udf_modify =dbo.FNAProcessTableName('udf_modify', @user_login_id, @process_id)

SET @modify_status =dbo.FNAProcessTableName('modify_status', @user_login_id, @process_id)

SET @tmp_price_diff_distinct_t0 =dbo.FNAProcessTableName('tmp_price_diff_distinct_t0', @user_login_id, @process_id)
SET @tmp_price_diff_distinct_t1 =dbo.FNAProcessTableName('tmp_price_diff_distinct_t1', @user_login_id, @process_id)

SET @final_explain_mtm=dbo.FNAProcessTableName('final_explain_mtm', @user_login_id, @process_id)
SET @delivered_position=dbo.FNAProcessTableName('delivered_position', @user_login_id, @process_id)

--BEGIN TRY

---START Batch initilization--------------------------------------------------------
--------------------------------------------------------------------------------------
SET @str_batch_table = ''
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END		

IF @is_batch = 1
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

IF @batch_process_id IS NULL
	SET @batch_process_id = dbo.FNAGetNewID()	
	
IF @enable_paging = 1 --paging processing
BEGIN
	SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)

	--retrieve data from paging table instead of main table
	IF @page_no IS NOT NULL  
	BEGIN
		SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no)    
		EXEC (@sql_paging)  
		RETURN  
	END
END
---END Batch initilization--------------------------------------------------------
--------------------------------------------------------------------------------------

SET @st_criteria =
	CASE WHEN @commodity IS NULL THEN '' ELSE ' AND spcd.commodity_id IN (' +@commodity +')' END
	+ CASE WHEN @index IS NULL THEN '' ELSE ' AND delta.curve_id IN (' +@index +')' END
			
				
SET @st_term = CASE WHEN @term_start IS NULL THEN '' ELSE ' AND delta.term_start >= ''' +CONVERT(VARCHAR(10),@term_start,120) +'''' END
				+ CASE WHEN @term_end IS NULL THEN '' ELSE ' AND delta.term_start <= ''' +CONVERT(VARCHAR(10),@term_end,120) +'''' END

--SET @st_hr = CASE WHEN @hr_from IS NULL THEN '' ELSE ' AND delta.hr>=' +CAST(@hr_from  AS VARCHAR) END
--			+ CASE WHEN @hr_to IS NULL THEN '' ELSE ' AND delta.hr<=' +CAST(@hr_to  AS VARCHAR) END
	
----collect books for filtering		
CREATE TABLE #book (book_deal_type_map_id INT,source_system_book_id1 INT,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)		
	
SET @st1='INSERT INTO #book (
				book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 
			)		
			SELECT book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 
			FROM source_system_book_map sbm            
				INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=sbm.fas_book_id
				INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
				INNER JOIN  Portfolio_hierarchy sb (NOLOCK) ON stra.parent_entity_id = sb.entity_id 
			WHERE 1=1  '
			+CASE WHEN  @sub IS NULL THEN '' ELSE ' and sb.entity_id in ('+@sub+')' END
			+CASE WHEN  @str IS NULL THEN '' ELSE ' and stra.entity_id in ('+@str+')' END
			+CASE WHEN  @book IS NULL THEN '' ELSE ' and book.entity_id in ('+@book+')' END	
			+case when @filter_book_deal_type_map_id is null then '' else ' and book_deal_type_map_id='+CAST(@filter_book_deal_type_map_id as varchar) end 	
exec spa_print @st1	
EXEC(@st1)


IF @run_mode IN (3)	
	GOTO reporting

----collect deals for filtering		
		
SET @st1='
SELECT    --top(10) 
	dsdh.source_deal_header_id,dsdh.source_system_id,dsdh.deal_id,dsdh.deal_date,dsdh.ext_deal_id,dsdh.physical_financial_flag,dsdh.structured_deal_id,dsdh.counterparty_id
	,dsdh.entire_term_start,dsdh.entire_term_end,dsdh.source_deal_type_id deal_type_id,dsdh.deal_sub_type_type_id,dsdh.option_flag,dsdh.option_type,dsdh.option_excercise_type
	,dsdh.source_system_book_id1,dsdh.source_system_book_id2,dsdh.source_system_book_id3,dsdh.source_system_book_id4,dsdh.description1,dsdh.description2,dsdh.description3
	,dsdh.deal_category_value_id,dsdh.trader_id,dsdh.internal_deal_type_value_id,dsdh.internal_deal_subtype_value_id,dsdh.template_id,dsdh.header_buy_sell_flag,dsdh.broker_id
	,dsdh.generator_id,dsdh.status_value_id,dsdh.status_date,dsdh.assignment_type_value_id,dsdh.compliance_year,dsdh.state_value_id,dsdh.assigned_date,dsdh.assigned_by,dsdh.generation_source
	,dsdh.aggregate_environment,dsdh.aggregate_envrionment_comment,dsdh.rec_price,dsdh.rec_formula_id,dsdh.rolling_avg,dsdh.contract_id,dsdh.create_user,convert(varchar(10),dsdh.create_ts,120) create_ts
	,dsdh.update_user,dsdh.update_ts,dsdh.legal_entity,dsdh.internal_desk_id profile_id,dsdh.product_id product_id,dsdh.commodity_id,dsdh.reference,dsdh.deal_locked,dsdh.close_reference_id
	,dsdh.block_type,dsdh.block_define_id,dsdh.granularity_id,dsdh.Pricing,dsdh.deal_reference_type_id,dsdh.unit_fixed_flag,dsdh.broker_unit_fees,dsdh.broker_fixed_cost,dsdh.broker_currency_id
	,-5607 deal_status_id,dsdh.term_frequency,dsdh.option_settlement_date,dsdh.verified_by,dsdh.verified_date,dsdh.risk_sign_off_by,dsdh.risk_sign_off_date,dsdh.back_office_sign_off_by
	,dsdh.back_office_sign_off_date,dsdh.book_transfer_id,dsdh.confirm_status_type,sbm.book_deal_type_map_id,dsdh.product_id  fixation
	,case when dsdh.deal_status=5607 then case when convert(varchar(10),dsdh.update_ts,120)=convert(varchar(10),dsdh.delete_ts,120)  then 0 else 1 end else 0 end cancel_delete
INTO ' +@source_deal_header +' 
FROM delete_source_deal_header dsdh 
INNER JOIN #book sbm ON dsdh.source_system_book_id1 = sbm.source_system_book_id1 AND 
		   dsdh.source_system_book_id2 = sbm.source_system_book_id2 AND dsdh.source_system_book_id3 = sbm.source_system_book_id3 AND 
		   dsdh.source_system_book_id4 = sbm.source_system_book_id4 where dsdh.deal_date<= '''+CONVERT(VARCHAR(10),@as_of_date_to,120)  + ''''
	+CASE WHEN  @source_deal_header_ids IS NULL THEN '' ELSE ' and dsdh.source_deal_header_id in ('+@source_deal_header_ids+')' END
	+CASE WHEN  @deal_ids IS NULL THEN '' ELSE ' and dsdh.deal_id in ('''+REPLACE(@deal_ids,',',''',''') +''')' END 
	+case when @filter_counterparty_id is null then '' else ' and dsdh.counterparty_id='+CAST(@filter_counterparty_id as varchar) end 	+'
	and case when dsdh.deal_status=5607 then case when convert(varchar(10),dsdh.update_ts,120)=convert(varchar(10),dsdh.delete_ts,120)  then 0 else 1 end else 0 end=0  --exclude deal that cancel first and then next day delete
UNION all
SELECT distinct sdh.source_deal_header_id,sdh.source_system_id,sdh.deal_id,sdh.deal_date,sdh.ext_deal_id,sdh.physical_financial_flag,sdh.structured_deal_id,sdh.counterparty_id
	,sdh.entire_term_start,sdh.entire_term_end,sdh.source_deal_type_id,sdh.deal_sub_type_type_id deal_type_id, sdh.option_flag,sdh.option_type,sdh.option_excercise_type
	,sdh.source_system_book_id1,sdh.source_system_book_id2,sdh.source_system_book_id3,sdh.source_system_book_id4,sdh.description1,sdh.description2,sdh.description3
	,sdh.deal_category_value_id,sdh.trader_id,sdh.internal_deal_type_value_id,sdh.internal_deal_subtype_value_id,sdh.template_id,sdh.header_buy_sell_flag,sdh.broker_id
	,sdh.generator_id,sdh.status_value_id,sdh.status_date,sdh.assignment_type_value_id,sdh.compliance_year,sdh.state_value_id,sdh.assigned_date,sdh.assigned_by,sdh.generation_source
	,sdh.aggregate_environment,sdh.aggregate_envrionment_comment,sdh.rec_price,sdh.rec_formula_id,sdh.rolling_avg,sdh.contract_id,sdh.create_user,convert(varchar(10),sdh.create_ts,120) create_ts
	,sdh.update_user,sdh.update_ts,sdh.legal_entity,sdh.internal_desk_id profile_id,sdh.product_id product_id,sdh.commodity_id,sdh.reference,sdh.deal_locked,sdh.close_reference_id
	,sdh.block_type,sdh.block_define_id,sdh.granularity_id,sdh.Pricing,sdh.deal_reference_type_id,sdh.unit_fixed_flag,sdh.broker_unit_fees,sdh.broker_fixed_cost,sdh.broker_currency_id
	,sdh.deal_status deal_status_id,sdh.term_frequency,sdh.option_settlement_date,sdh.verified_by,sdh.verified_date,sdh.risk_sign_off_by,sdh.risk_sign_off_date,sdh.back_office_sign_off_by
	,sdh.back_office_sign_off_date,sdh.book_transfer_id,sdh.confirm_status_type,sbm.book_deal_type_map_id,sdh.product_id  fixation,0 cancel_delete
FROM source_deal_header sdh 
INNER JOIN [deal_status_group] dsg ON (dsg.status_value_id = sdh.deal_status or  
	(sdh.deal_status= 5607 and convert(varchar(10),sdh.update_ts,120)>'''+CONVERT(VARCHAR(10),@as_of_date_from,120) 
	 + ''' and convert(varchar(10),sdh.update_ts,120)<='''+CONVERT(VARCHAR(10),@as_of_date_to,120)  + ''')) and sdh.deal_date<= '''+CONVERT(VARCHAR(10),@as_of_date_to,120) + '''
	 '+case when @filter_counterparty_id is null then '' else ' and sdh.counterparty_id='+CAST(@filter_counterparty_id as varchar) end 	+ '
INNER JOIN #book sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND 
		   sdh.source_system_book_id2 = sbm.source_system_book_id2 AND sdh.source_system_book_id3 = sbm.source_system_book_id3 AND 
		   sdh.source_system_book_id4 = sbm.source_system_book_id4 where 1=1 '
+CASE WHEN  @source_deal_header_ids IS NULL THEN '' ELSE ' and sdh.source_deal_header_id in ('+@source_deal_header_ids+')' END
+CASE WHEN  @deal_ids IS NULL THEN '' ELSE ' and sdh.deal_id in ('''+REPLACE(@deal_ids,',',''',''') +''')' END 
	
exec spa_print @st1
EXEC(@st1)

EXEC('create index indx_header_id_'+@process_id +' on  '+@source_deal_header +' (source_deal_header_id)')
	
SET @st1='	
	SELECT dsdd.source_deal_detail_id,dsdd.source_deal_header_id,dsdd.term_start,dsdd.term_end,dsdd.Leg,dsdd.contract_expiration_date,dsdd.fixed_float_leg,dsdd.buy_sell_flag,dsdd.curve_id,dsdd.fixed_price,
		dsdd.fixed_price_currency_id,dsdd.option_strike_price,dsdd.deal_volume,dsdd.deal_volume_frequency,dsdd.deal_volume_uom_id,dsdd.block_description,dsdd.deal_detail_description,
		dsdd.formula_id,dsdd.volume_left,dsdd.settlement_volume,dsdd.settlement_uom,dsdd.create_user,dsdd.create_ts,dsdd.update_user,dsdd.update_ts,dsdd.price_adder,dsdd.price_multiplier,
		dsdd.settlement_date,dsdd.day_count_id,ISNULL(dsdd.location_id,-1) location_id,dsdd.meter_id,dsdd.physical_financial_flag,dsdd.Booked,dsdd.process_deal_status,dsdd.fixed_cost,dsdd.multiplier,
		dsdd.adder_currency_id,dsdd.fixed_cost_currency_id,dsdd.formula_currency_id,dsdd.price_adder2,dsdd.price_adder_currency2,dsdd.volume_multiplier2,dsdd.total_volume,
		dsdd.pay_opposite,dsdd.capacity,dsdd.settlement_currency,dsdd.standard_yearly_volume,dsdd.formula_curve_id,dsdd.price_uom_id,dsdd.category Category_id,dsdd.profile_code,dsdd.pv_party pvparty_id
		,ISNULL(spcd1.source_curve_def_id,spcd.source_curve_def_id) index_id,ISNULL(spcd.display_uom_id,spcd.uom_id) uom_id
		, COALESCE(spcd1.block_define_id,spcd.block_define_id) user_toublock_id,COALESCE(spcd1.udf_block_group_id,spcd.udf_block_group_id,grp.block_type_group_id) toublock_id
	INTO '+ @source_deal_detail+'
	FROM dbo.delete_source_deal_detail dsdd  INNER JOIN  '+@source_deal_header +' sdh ON dsdd.source_deal_header_id=sdh.source_deal_header_id'
--	+ CASE WHEN @index IS NULL THEN '' ELSE ' AND dsdd.curve_id IN (' +@index +')' END 
+'	INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=dsdd.curve_id  '
	--+CASE WHEN @commodity IS NULL THEN '' ELSE ' AND spcd.commodity_id IN (' +@commodity +')' END
	+' left JOIN  source_price_curve_def spcd1 ON  spcd1.source_curve_def_id=spcd.proxy_curve_id
		left join block_type_group grp ON ISNULL(spcd1.block_define_id,spcd.block_define_id)=grp.hourly_block_id 
			AND ISNULL(spcd.block_type,spcd.block_type)=grp.block_type_id  
	UNION all
	SELECT sdd.source_deal_detail_id,sdd.source_deal_header_id,sdd.term_start,sdd.term_end,sdd.Leg,sdd.contract_expiration_date,sdd.fixed_float_leg
		,sdd.buy_sell_flag,sdd.curve_id,sdd.fixed_price,sdd.fixed_price_currency_id,sdd.option_strike_price,sdd.deal_volume,sdd.deal_volume_frequency
		,sdd.deal_volume_uom_id,sdd.block_description,sdd.deal_detail_description,sdd.formula_id,sdd.volume_left,sdd.settlement_volume,sdd.settlement_uom
		,sdd.create_user,sdd.create_ts,sdd.update_user,sdd.update_ts,sdd.price_adder,sdd.price_multiplier,sdd.settlement_date,sdd.day_count_id
		,isnull(sdd.location_id,-1) location_id,sdd.meter_id,sdd.physical_financial_flag,sdd.Booked,sdd.process_deal_status,sdd.fixed_cost,sdd.multiplier,
		sdd.adder_currency_id,sdd.fixed_cost_currency_id,sdd.formula_currency_id,sdd.price_adder2,sdd.price_adder_currency2,sdd.volume_multiplier2
		,sdd.total_volume,sdd.pay_opposite,sdd.capacity,sdd.settlement_currency,sdd.standard_yearly_volume,sdd.formula_curve_id,sdd.price_uom_id,sdd.category Category_id
		,sdd.profile_code,sdd.pv_party pvparty_id,ISNULL(spcd1.source_curve_def_id,spcd.source_curve_def_id) index_id,ISNULL(spcd.display_uom_id,spcd.uom_id) uom_id
		,COALESCE(spcd1.block_define_id,spcd.block_define_id) user_toublock_id,COALESCE(spcd1.udf_block_group_id,spcd.udf_block_group_id,grp.block_type_group_id) toublock_id
	FROM dbo.source_deal_detail sdd  INNER JOIN  '+@source_deal_header +' sdh ON sdd.source_deal_header_id=sdh.source_deal_header_id'
	--+ CASE WHEN @index IS NULL THEN '' ELSE ' AND sdd.curve_id IN (' +@index +')' END 
	+' INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id  '
	--+CASE WHEN @commodity IS NULL THEN '' ELSE ' AND spcd.commodity_id IN (' +@commodity +')' END
+'	left JOIN  source_price_curve_def spcd1 ON  spcd1.source_curve_def_id=spcd.proxy_curve_id
	left join block_type_group grp ON ISNULL(spcd1.block_define_id,spcd.block_define_id)=grp.hourly_block_id 
		AND ISNULL(spcd.block_type,spcd.block_type)=grp.block_type_id  
	'	
exec spa_print @st1	
EXEC(@st1)

EXEC('create index indx_detail_id_'+@process_id +' on '+@source_deal_detail +' (source_deal_header_id,curve_id,term_start)')

declare @call_from int
set @call_from=0

IF   @calc_type IN ('b', 'm')
begin
	set @call_from=1
	set @deal_level='y'
end	

--Explain position calculation
IF   @calc_type IN ('b', 'p')
	EXEC [dbo].[spa_core_explain_position] 	@as_of_date_from  ,@as_of_date_to ,@deal_level,@index,@commodity,@process_id,@call_from


EXEC spa_print '****************************************end [spa_core_explain_position]'
--return

SET  @st_group_by =' GROUP BY delta.physical_financial_flag,delta.[curve_id],delta.[term_start] ' 

IF   @calc_type IN ('b', 'p')
BEGIN
	SET  @st_from ='	
		 FROM ' +@position_detail+' delta  
		LEFT JOIN source_uom su ON su.source_uom_id=delta.deal_volume_uom_id
		LEFT JOIN source_price_curve_def idx ON delta.curve_id = idx.source_curve_def_id
	 ' 
	CREATE TABLE #udt(udf_block_group_id  INT,block_id INT, term_start DATE, Hr TINYINT)
		
	SET @st1='
			insert into #udt(udf_block_group_id,block_id,term_start,Hr)
			select distinct upv.udf_block_group_id ,upv.block_id, upv.term_start,cast(substring(upv.hr,3,2) AS INT) Hr
			from (
			select p.udf_block_group_id,p.block_id ,p.term_start ,
				hb.hr1,hb.hr2,hb.hr3,hb.hr4,hb.hr5,hb.hr6,hb.hr7,hb.hr8,hb.hr9,hb.hr10,hb.hr11,hb.hr12,hb.hr13,hb.hr14,hb.hr15,hb.hr16
				,hb.hr17,hb.hr18,hb.hr19,hb.hr20,hb.hr21,hb.hr22,hb.hr23,hb.hr24
			 from (
					select distinct grp.id udf_block_group_id,spcd.udf_block_group_id block_id, a.term_start,hourly_block_id
					 from ' +@position_detail+' a  
					 left join source_price_curve_def spcd on spcd.source_curve_def_id=a.curve_id
					inner join block_type_group grp ON spcd.udf_block_group_id=grp.block_type_group_id 
					and spcd.udf_block_group_id is not null
						
				) p
				inner join  hour_block_term hb  ON hb.block_define_id=p.hourly_block_id and isnull(hb.block_type,12000)=12000
					and p.term_start=hb.term_date
			) s
				UNPIVOT
				(on_off for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)	
			) upv	
			where on_off=1'


	 exec spa_print @st1
	 EXEC(@st1)
		

	IF  @run_mode IN (0,1)
	BEGIN
			
		IF ISNULL(@purge,'n')='n' 
			DELETE explain_position FROM explain_position e INNER JOIN #book b ON b.book_deal_type_map_id=e.book_deal_type_map_id
				WHERE as_of_date_from=@as_of_date_from AND as_of_date_to=@as_of_date_to
		ELSE
			DELETE explain_position  WHERE as_of_date_from=@as_of_date_from AND as_of_date_to=@as_of_date_to
		
		
		SET @st1='INSERT INTO [dbo].[explain_position]
			(
				[as_of_date_from],[as_of_date_to],[curve_id],[term_start],hr,[book_deal_type_map_id],[counterparty_id],[proxy_curve_id],[uom_id],[physical_financial_flag]
				,[tou_id],[ob_value],[new_deal],[modify_deal],[forecast_changed],[deleted],[delivered],[cb_value],[create_ts],[create_user],un_explain
			)
			select '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +''' as_of_date_from,'''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' as_of_date_to,
				 delta.[curve_id],delta.[term_start],delta.hr,delta.[book_deal_type_map_id]
				,delta.[counterparty_id],idx.[proxy_curve_id],delta.[deal_volume_uom_id],delta.[physical_financial_flag]
				,t.[udf_block_group_id],sum(delta.OB_Volume) OB_value,sum(delta.new_delta)  new_deal
				,sum(delta.modify_delta) modify_deal,sum(delta.forecast_delta) forecast_changed,sum(delta.deleted_delta) deleted,sum(delta.delivered_delta) delivered,sum(delta.CB_Volume)  CB_value 
				,getdate() create_ts,'''+dbo.FNADBUser()+''' create_user,sum(delta.CB_Volume -(delta.OB_Volume+delta.new_delta+delta.modify_delta+delta.forecast_delta+delta.deleted_delta+delta.delivered_delta))
			 FROM ' +@position_detail+' delta  
				left join source_uom su on su.source_uom_id=delta.deal_volume_uom_id
				LEFT JOIN source_price_curve_def idx ON delta.curve_id = idx.source_curve_def_id
				left join  #udt t on  delta.term_start=t.term_start and delta.hr=t.hr  and idx.udf_block_group_id =t.block_id 
			Group by
				 delta.[curve_id],delta.[term_start],delta.hr,delta.[book_deal_type_map_id],delta.[counterparty_id],idx.[proxy_curve_id]
				,delta.[deal_volume_uom_id],delta.[physical_financial_flag],t.[udf_block_group_id]
			--having 
			--	abs(sum(delta.modify_delta))+ abs(sum(delta.forecast_delta))+abs(sum(delta.deleted_delta))+abs(sum(delta.delivered_delta))<>0
				'
			
		EXEC spa_print @st1
		EXEC( @st1)	
	END

	ELSE IF @run_mode =2
	BEGIN 
		SET @st1='SELECT subs.entity_name + '' / ''+ stra.entity_name+ '' / '' + book.entity_name [Book],'
		+CASE WHEN @deal_level='y' THEN ' delta.[source_deal_header_id] [Deal ID],' ELSE '' END +' spcd.[curve_name] [Index],spcd1.[curve_name] [ProxyIndex],
			CASE WHEN delta.physical_financial_flag=''p'' THEN ''Physical'' ELSE ''Financial'' END [Physical/Financial], cpty.counterparty_name Counterparty,
			max(grp.block_name) TOU,
			dbo.FNADateFormat(delta.[term_start]) [Term],delta.Hr,
			CAST(sum(delta.OB_Volume) as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + '))  [Beginning Position],
			CAST(sum(delta.new_delta) as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + '))  [New Business Position],
			--CAST(sum(case when not (CONVERT(VARCHAR(10),sdh.create_ts,120) > '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  and CONVERT(VARCHAR(10),sdh.create_ts,120)<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''') then delta.CB_Volume -(delta.modify_delta+delta.forecast_delta+delta.deleted_delta+delta.delivered_delta) else 0 end) as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + '))  [Beginning Position],
			--CAST(sum(case when CONVERT(VARCHAR(10),sdh.create_ts,120) > '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  and CONVERT(VARCHAR(10),sdh.create_ts,120)<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' then delta.CB_Volume -(delta.modify_delta+delta.forecast_delta+delta.deleted_delta+delta.delivered_delta) else 0 end) as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + '))  [New Business Position],
			CAST(sum(delta.modify_delta) as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [Modified Deals Position],
			CAST(sum(delta.deleted_delta) as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [Deleted Deals Position] ,
			CAST(sum(delta.forecast_delta) as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [Re-forecast Position],
			CAST(sum(delta.delivered_delta) as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [Delivery Position],
			CAST(sum(delta.CB_Volume -(delta.OB_Volume+delta.new_delta+delta.modify_delta+delta.forecast_delta+delta.deleted_delta+delta.delivered_delta)) as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [Unexplain Position],
			CAST(sum(delta.CB_volume) as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [Ending Position] ,
			max(su.uom_name) [UOM]
		'+ @str_batch_table  +'
		FROM '+@position_detail+' delta		
			--left join '+@source_deal_header +' sdh on sdh.source_deal_header_id=delta.source_deal_header_id
			LEFT JOIN  source_price_curve_def spcd 
				ON spcd.source_curve_def_id = delta.curve_id 
			LEFT JOIN  source_price_curve_def spcd1 
				ON spcd1.source_curve_def_id = spcd.proxy_curve_id 
			left join source_uom su on su.source_uom_id=delta.deal_volume_uom_id
			left join source_counterparty cpty on cpty.source_counterparty_id=delta.counterparty_id
			left join source_system_book_map sbm on sbm.book_deal_type_map_id=delta.book_deal_type_map_id
			left join portfolio_hierarchy book on book.entity_id=sbm.fas_book_id
			left join portfolio_hierarchy stra on stra.entity_id=book.parent_entity_id
			left join portfolio_hierarchy subs on subs.entity_id=stra.parent_entity_id	
			left join  #udt t on  delta.term_start=t.term_start and delta.hr=t.hr  and spcd.udf_block_group_id =t.block_id
			left join block_type_group grp ON t.udf_block_group_id=grp.id  	
		WHERE 1=1'
			+ CASE WHEN @term_start IS NULL THEN '' ELSE ' AND delta.term_start >= ''' + CONVERT(VARCHAR(10),@term_start,120) + '''' END
			+ CASE WHEN @term_end IS NULL THEN '' ELSE ' AND delta.term_start <= ''' + CONVERT(VARCHAR(10),@term_end,120) + '''' END
			+ CASE WHEN @st_criteria IS NULL THEN '' ELSE  @st_criteria END + 
		' Group by 
			 subs.entity_name,  stra.entity_name, book.entity_name ,'
			+CASE WHEN @deal_level='y' THEN ' delta.[source_deal_header_id],' ELSE '' END +' spcd.[curve_name],spcd1.[curve_name],
				 delta.physical_financial_flag, cpty.counterparty_name,delta.[term_start],delta.Hr
		ORDER BY delta.physical_financial_flag,1'+CASE WHEN @deal_level='y' THEN ' ,[Deal ID]' ELSE '' END +', [index],delta.term_start,delta.Hr'	 

			
		EXEC spa_print @st1
		EXEC( @st1)
		GOTO batch_process
	END		
END	
ELSE IF @calc_type IN ('b','m')
BEGIN

	SET @deferral_temp_explain_mtm =dbo.FNAProcessTableName('deferral_temp_explain_mtm', @user_login_id, @process_id)
	SET @temp_explain_mtm =dbo.FNAProcessTableName('temp_explain_mtm', @user_login_id, @process_id)
	SET @temp_explain_mtm_formula =dbo.FNAProcessTableName('temp_explain_mtm_formula', @user_login_id, @process_id)
	SET @temp_discounted_mtm_factor =dbo.FNAProcessTableName('temp_discounted_mtm_factor', @user_login_id, @process_id)

	EXEC('create table '+ @temp_discounted_mtm_factor+ ' ( as_of_date date,source_deal_header_id int, term_start date,discount_factor float)')
	
	IF ISNULL(@discounted_mtm ,'n')='y'
	BEGIN
		SET @st1='insert into '+ @temp_discounted_mtm_factor +' ( as_of_date,source_deal_header_id , term_start ,discount_factor )
			select sdp.pnl_as_of_date, sdp.source_deal_header_id , sdp.term_start ,max(sdp.discount_factor) from source_deal_pnl_detail sdp 
			inner join '+ @source_deal_header +' sdh on sdp.source_deal_header_id=sdh.source_deal_header_id
			and sdp.pnl_as_of_date in ('''+CONVERT(VARCHAR(10),@as_of_date_from,120)+''','''+CONVERT(VARCHAR(10),@as_of_date_to,120)+''')
			group by sdp.pnl_as_of_date,sdp.source_deal_header_id , sdp.term_start
		'
		EXEC spa_print @st1
		EXEC(@st1)
	END 
		
	EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Data prepararion^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
	--EXEC spa_print 'Time taken(second):' +cast(datediff(ss,@start_time, GETDATE()) as varchar)
	set @start_time=GETDATE()	

	EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'



--=============================================================================================================================
	EXEC spa_print '*************************Explain mtm (new/delete/end/begin/delivered delta mtm).********************************'
--==============================================================================================================================



	SET @st1='
		select source_deal_header_id,cast(term_start as datetime) term_start,term_end, curve_id,leg,cast(null as int) tou_id
				,cast(sum(begin_mtm) as float) begin_mtm,cast(sum(new_mtm) as float) new_mtm,cast(0.00  as float) modify_MTM
				,cast(0.00  as float) reforecast_mtm, cast(sum(deleted_mtm) as float) deleted_mtm,
				cast(sum(delivered_mtm) as float) delivered_mtm,cast(0.00 as float) price_changed_mtm,cast(sum(end_mtm) as float) end_mtm
				,max(pnl_currency_id) pnl_currency_id ,charge_type,cast(0.00 as float) unexplain_mtm,max(create_ts) create_ts,max(deal_status_id) deal_status_id
		into ' +@temp_explain_mtm + ' 
		from (
			select sdp.source_deal_header_id,sdp.term_start,sdp.term_end, sdp.curve_id,sdp.leg,abs(max(sdh.deal_status_id)) deal_status_id,
				sum(case when sdp.pnl_as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_from,120)+''' then ' + CASE WHEN ISNULL(@discounted_mtm ,'n')='y'   THEN 'sdp.dis_pnl' ELSE 'sdp.und_pnl' END+ ' else 0 end ) begin_mtm,
				 sum(case when sdh.create_ts='''+CONVERT(VARCHAR(10),@as_of_date_to,120)+''' and sdp.pnl_as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_to,120)+''' then ' + CASE WHEN ISNULL(@discounted_mtm ,'n')='y'   THEN 'sdp.dis_pnl' ELSE 'sdp.und_pnl' END+ ' else 0 end ) new_mtm,
				 0.00 modify_MTM,0.00  reforecast_mtm,
				 sum(-1*case when abs(sdh.deal_status_id)=5607 and sdp.pnl_as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_from,120)+''' then ' + CASE WHEN ISNULL(@discounted_mtm ,'n')='y'   THEN 'sdp.dis_pnl' ELSE 'sdp.und_pnl' END+ ' else 0 end ) deleted_mtm,
				0.00 delivered_mtm,0.00 price_changed_mtm,
				sum(case when abs(sdh.deal_status_id)<>5607 and sdp.pnl_as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_to,120)+''' then ' + CASE WHEN ISNULL(@discounted_mtm ,'n')='y'   THEN 'sdp.dis_pnl' ELSE 'sdp.und_pnl' END+ ' else 0 end ) end_mtm
				,max(sdp.pnl_currency_id) pnl_currency_id,291905 charge_type,max(sdh.create_ts) create_ts
			 from source_deal_pnl_detail sdp 
				inner join '+ @source_deal_header +' sdh on sdp.source_deal_header_id=sdh.source_deal_header_id
					and (sdp.pnl_as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_from,120)+''' or sdp.pnl_as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_to,120)+''')
			GROUP BY sdp.source_deal_header_id,sdp.term_start,sdp.term_end, sdp.curve_id,sdp.leg
			having sum(case when sdp.pnl_as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_from,120)+''' then sdp.und_pnl else 0 end )<>0
				or sum(case when abs(sdh.deal_status_id)<>5607 and sdp.pnl_as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_to,120)+''' then sdp.und_pnl else 0 end ) <>0
			union all 
			select sdp.source_deal_header_id,sdp.term_start,sdp.term_end,sdp.curve_id,sdp.leg,abs(max(sdh.deal_status_id)) deal_status_id,
				0.00 begin_mtm,0.00 new_mtm,0.00 modify_MTM,0.00  reforecast_mtm, 0.00 deleted_mtm,
				sum(-1*case when abs(sdh.deal_status_id)=5607 then 0.00 else ' + CASE WHEN ISNULL(@discounted_mtm ,'n')='y'   THEN 'sdp.dis_pnl' ELSE 'sdp.und_pnl' END+ ' end ) delivered_mtm,0.00 price_changed_mtm,0.00 end_mtm
				,max(sdp.pnl_currency_id) pnl_currency_id ,291905 charge_type,max(sdh.create_ts) create_ts
			from explain_delivered_mtm sdp 
				inner join '+ @source_deal_header +' sdh on sdp.source_deal_header_id=sdh.source_deal_header_id
					and sdp.pnl_as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_from,120)+''' 
			GROUP BY sdp.source_deal_header_id,sdp.term_start,sdp.term_end, sdp.curve_id,sdp.leg
			union all
			select sdp.source_deal_header_id,sdp.term_start,sdp.term_end,sdd.curve_id curve_id,sdp.leg,abs(max(sdh.deal_status_id)) deal_status_id,
				sum(case when sdp.as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_from,120)+''' then sdp.value*isnull(fac.discount_factor,1) else 0 end ) begin_mtm,
				 sum(case when sdh.create_ts='''+CONVERT(VARCHAR(10),@as_of_date_to,120)+''' and sdp.as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_to,120)+''' then sdp.value*isnull(fac.discount_factor,1) else 0 end ) new_mtm,
				 0.00 modify_MTM,0.00  reforecast_mtm,
				 sum(-1*case when abs(sdh.deal_status_id)=5607 and sdp.as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_from,120)+''' then sdp.value*isnull(fac.discount_factor,1) else 0 end ) deleted_mtm,
				0.00 delivered_mtm,0.00 price_changed_mtm,
				sum(case when abs(sdh.deal_status_id)<>5607 and sdp.as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_to,120)+''' then sdp.value*isnull(fac.discount_factor,1) else 0 end ) end_mtm
				,max(sdp.fee_currency_id) pnl_currency_id,field_id charge_type,max(sdh.create_ts) create_ts
			 from index_fees_breakdown sdp 
				inner join '+ @source_deal_header +' sdh on sdp.source_deal_header_id=sdh.source_deal_header_id and  sdp.internal_type<>-1
					and (sdp.as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_from,120)+''' or sdp.as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_to,120)+''')
				left join '+ @source_deal_detail +' sdd on sdd.source_deal_header_id=sdp.source_deal_header_id
					and sdp.term_start=sdd.term_start and sdp.leg=sdd.leg
				left join '+@temp_discounted_mtm_factor+' fac on fac.source_deal_header_id=sdp.source_deal_header_id and fac.term_start=sdp.term_start
					and fac.as_of_date=sdp.as_of_date
			GROUP BY sdp.source_deal_header_id,sdp.term_start,sdp.term_end, sdd.curve_id,sdp.leg,sdp.field_id
			having sum(case when sdp.as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_from,120)+''' then sdp.value else 0 end )<>0
				or sum(case when abs(sdh.deal_status_id)<>5607 and sdp.as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_to,120)+''' then sdp.value else 0 end )<>0
			union all 
			select sdp.source_deal_header_id,sdp.term_start,sdp.term_end,sdd.curve_id,sdp.leg,abs(max(sdh.deal_status_id)) deal_status_id,
				0.00 begin_mtm,0.00 new_mtm,0.00 modify_MTM,0.00  reforecast_mtm, 0.00 deleted_mtm,
				sum(-1*case when abs(sdh.deal_status_id)=5607 then 0.00 else sdp.value*isnull(fac.discount_factor,1) end ) delivered_mtm,0.00 price_changed_mtm,0.00 end_mtm
				,max(sdp.fee_currency_id) pnl_currency_id ,sdp.field_id charge_type,max(sdh.create_ts) create_ts
			from index_fees_breakdown_delivered sdp 
				inner join '+ @source_deal_header +' sdh on sdp.source_deal_header_id=sdh.source_deal_header_id and  sdp.internal_type<>-1
					and sdp.as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_from,120)+'''
				left join '+ @source_deal_detail +' sdd on sdd.source_deal_header_id=sdp.source_deal_header_id
					and sdp.term_start=sdd.term_start and sdp.leg=sdd.leg
				left join '+@temp_discounted_mtm_factor+' fac on fac.source_deal_header_id=sdp.source_deal_header_id and fac.term_start=sdp.term_start
					and fac.as_of_date=sdp.as_of_date
			GROUP BY sdp.source_deal_header_id,sdp.term_start,sdp.term_end, sdd.curve_id,sdp.leg,sdp.field_id
		) a group by source_deal_header_id,term_start,term_end, curve_id,a.leg,charge_type'
			
	EXEC spa_print @st1
	EXEC(@st1)

	EXEC('create index indx_'+@process_id+'__123 on '+@temp_explain_mtm+' (source_deal_header_id,term_start,term_end,curve_id) include (new_mtm,deleted_mtm)')

	-- '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Delta Collecting^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
	--print 'Time taken(second):' +cast(datediff(ss,@start_time, GETDATE()) as varchar)
	set @start_time=GETDATE()	
	EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'


	set @st1='
		select source_deal_header_id,term_start,term_end,curve_id,leg, max(deal_modify) deal_modify,max(market_modify) market_modify,max(contract_modify) contract_modify
		into '+@modify_status+' 
		from (
			select s.source_deal_header_id,s.term_start,s.term_end,s.curve_id,s.leg, 1 deal_modify,0 market_modify,0 contract_modify
			from  (select distinct source_deal_header_id,term_start,term_end,curve_id,leg from ' +@temp_explain_mtm + ' mtm where  mtm.deleted_mtm=0 and mtm.new_mtm=0) s left join source_deal_detail sdd on s.source_deal_header_id=sdd.source_deal_header_id
			and s.term_start=sdd.term_start and s.term_end=sdd.term_end and s.curve_id=sdd.curve_id and s.leg=sdd.leg
			--left join  source_deal_header sdh on s.source_deal_header_id=sdh.source_deal_header_id
			cross apply (
				select top(1) * from source_deal_detail_audit where 
				source_deal_header_id=SDD.source_deal_header_id and term_start=sdd.term_start and leg=sdd.leg
				--source_deal_detail_id=sdd.source_deal_detail_id --and user_action=''Update'' 
					and convert(varchar(10),update_ts,120)<='''+CONVERT(VARCHAR(10),@as_of_date_from,120)+'''
				order by audit_id desc 
			) a
			where sdd.deal_volume<>a.deal_volume or sdd.price_adder<>a.price_adder
				or sdd.price_multiplier<>a.price_multiplier or sdd.fixed_cost<>a.fixed_cost
				or sdd.multiplier<>a.multiplier or sdd.price_adder2<>a.price_adder2
				or sdd.price_adder_currency2<>a.price_adder_currency2
				or sdd.volume_multiplier2<>a.volume_multiplier2 or a.adder_currency_id<>sdd.adder_currency_id
				or a.fixed_cost_currency_id<>sdd.fixed_cost_currency_id or sdd.formula_currency_id<>a.formula_currency_id
				or a.fixed_price_currency_id<>sdd.fixed_price_currency_id or a.settlement_currency<>sdd.settlement_currency
				or a.formula_curve_id<>sdd.formula_curve_id or a.fixed_price<>sdd.fixed_price
				or a.standard_yearly_volume<>sdd.standard_yearly_volume
				--or (ISNULL(sdh.internal_desk_id,17300)=17302  and a.total_volume<>sdd.total_volume)
				or (sdd.fixed_float_leg=''f'')
			union all
			select s.source_deal_header_id,s.term_start,s.term_end,s.curve_id,s.leg, 0 deal_modify
				,0 market_modify
				,1  contract_modify
				from  (select distinct source_deal_header_id,term_start,term_end,curve_id,leg from ' +@temp_explain_mtm + ' mtm where  mtm.deleted_mtm=0 and mtm.new_mtm=0) s 
				inner join source_deal_detail sdd on s.source_deal_header_id=sdd.source_deal_header_id
					and s.term_start=sdd.term_start and s.term_end=sdd.term_end and s.curve_id=sdd.curve_id and s.leg=sdd.leg
				cross apply (
					select top(1) * from source_deal_detail_audit where 
					source_deal_header_id=SDD.source_deal_header_id
					and term_start=sdd.term_start and leg=sdd.leg
				--source_deal_detail_id=sdd.source_deal_detail_id --and user_action=''Update'' 
						and convert(varchar(10),update_ts,120)<='''+CONVERT(VARCHAR(10),@as_of_date_from,120)+'''
					order by audit_id desc
					) a
				LEFT JOIN formula_editor fe ON fe.formula_id = sdd.formula_id
				where isnull(a.formula_id,-1)<>isnull(sdd.formula_id,-1) 
				or replace(isnull(fe.formula,''''), '' '','''')<>replace(isnull(a.formula_text,''''), '' '','''')	
			union all
			select s.source_deal_header_id,s.term_start,s.term_end,s.curve_id,s.leg, 0 deal_modify
				,1 market_modify
				,0  contract_modify
				from  (select distinct source_deal_header_id,term_start,term_end,curve_id,leg from ' +@temp_explain_mtm + ' mtm where  mtm.deleted_mtm=0 and mtm.new_mtm=0) s inner join source_deal_detail sdd on s.source_deal_header_id=sdd.source_deal_header_id
				and s.term_start=sdd.term_start and s.term_end=sdd.term_end and s.curve_id=sdd.curve_id and s.leg=sdd.leg
				cross apply (
					select top(1) * from source_deal_detail_audit where 
					source_deal_header_id=SDD.source_deal_header_id and term_start=sdd.term_start and leg=sdd.leg
					--source_deal_detail_id=sdd.source_deal_detail_id
					 and convert(varchar(10),update_ts,120)<='''+CONVERT(VARCHAR(10),@as_of_date_from,120)+'''
					order by audit_id desc
					) a
				where a.curve_id<>s.curve_id		
		) m group by m.source_deal_header_id,m.term_start,m.term_end,m.curve_id,m.leg
	'
	exec spa_print @st1
	exec(@st1)

	set @st1='
		select s.source_deal_header_id into '+@udf_status+'
			from  (select distinct source_deal_header_id from ' +@temp_explain_mtm + ' mtm where  mtm.deleted_mtm=0 and mtm.new_mtm=0) s 
			inner join user_defined_deal_fields uddf on uddf.source_deal_header_id=s.source_deal_header_id
			inner join  user_defined_deal_fields_template uddft on uddf.udf_template_id=uddft.udf_template_id  and uddft.internal_field_type=18718
			cross apply (
				select top(1) udf_value from user_defined_deal_fields_audit 
				where source_deal_header_id=uddf.source_deal_header_id
					and udf_template_id=uddf.udf_template_id	and convert(varchar(10),update_ts,120)<='''+ convert(varchar(10),@as_of_date_from,120)+'''
				order by udf_audit_id desc
			) a
			where uddf.udf_value<>a.udf_value
		group by s.source_deal_header_id
		--having count(1)>0'

	exec spa_print @st1
	exec(@st1)


	SET @st1='
	select  distinct m.source_deal_header_id ,m.term_start, m.leg --,m.charge_type  
	 into  '+@added_term +' from '+@temp_explain_mtm+ ' m
	left join source_deal_pnl_detail mtm on
	 mtm.source_deal_header_id=m.source_deal_header_id and mtm.term_start=m.term_start and
			mtm.leg=m.leg and mtm.pnl_as_of_date='''+convert(varchar(10),@as_of_date_from,120)+'''
	where mtm.source_deal_header_id is null and m.create_ts<'''+convert(varchar(10),@as_of_date_to,120)+'''  and m.deal_status_id<>5607'

	EXEC spa_print @st1
	EXEC(@st1)

	SET @st1='
		select distinct m.source_deal_header_id ,m.term_start, m.leg--,m.charge_type
		  into  '+@deleted_term +' from '+@temp_explain_mtm+ ' m
		left join source_deal_pnl_detail mtm on
		 mtm.source_deal_header_id=m.source_deal_header_id and mtm.term_start=m.term_start and
				mtm.leg=m.leg and mtm.pnl_as_of_date='''+convert(varchar(10),@as_of_date_to,120)+'''
		where mtm.source_deal_header_id is null  and m.create_ts<'''+convert(varchar(10),@as_of_date_to,120)+''' and m.deal_status_id<>5607'

	EXEC spa_print @st1
	EXEC(@st1)

	set @st1='
	select distinct sdh.source_deal_header_id  into '+@deal_filters+' from ' +@source_deal_header +' sdh 
	inner join  (select distinct source_deal_header_id from ' +@temp_explain_mtm + ' mtm where  mtm.deleted_mtm=0 and mtm.new_mtm=0) s
		on sdh.source_deal_header_id=s.source_deal_header_id
	left join
	( select source_deal_header_id, max(market_modify) market_modify, max(contract_modify) contract_modify from 
		( 
			select source_deal_header_id ,1 market_modify, 0 contract_modify from '+@modify_status+' m group by source_deal_header_id having min(market_modify)<>0
			union all
			 select source_deal_header_id ,0 market_modify, 1 contract_modify from '+@modify_status+' m group by source_deal_header_id having min(contract_modify)<>0
			union 
			 select  source_deal_header_id ,0 market_modify, 1 contract_modify from '+@udf_status+' m 
		) a group by source_deal_header_id
	) b on sdh.source_deal_header_id=b.source_deal_header_id and (contract_modify=1 or market_modify=1)
	where b.source_deal_header_id is null and  abs(deal_status_id)<>5607'


	exec spa_print @st1
	exec(@st1)
	

	if @@rowcount >0
	begin
		--calc t0 position for mtm
		EXEC spa_print '---------------calc postion------------------'
		EXEC [dbo].[spa_core_explain_position] 	@as_of_date_from  ,@as_of_date_to ,@deal_level,@index,@commodity,@process_id,@call_from
		
		exec('select top(1) 1 aa into #data_exist_check from '+@position_detail)
		if @@rowcount >0
		begin
			EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Price change preparation^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
			--EXEC spa_print 'Time taken(second):' +cast(datediff(ss,@start_time, GETDATE()) as varchar)
			set @start_time=GETDATE()	
			EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'

			EXEC spa_print '*************************************************************'
			EXEC spa_print 'Calc contract and market value for @as_of_date_from'
			EXEC spa_print '*************************************************************'

			declare @dt_to varchar(10),@dt_from varchar(10)
			set @dt_to =CONVERT(varchar(10),@as_of_date_to,120)
			set @dt_from =CONVERT(varchar(10),@as_of_date_from,120)

			set @process_id_reforecast=@process_id+'_t0'

			set @delta_price_changed_t0=dbo.FNAProcessTableName('delta_price_changed', @user_login_id, @process_id_reforecast)

			EXEC [dbo].[spa_calc_mtm_job]
				@sub_id =@sub,
				@strategy_id =@str,
				@book_id =@book,
				@source_book_mapping_id=NULL,
				@source_deal_header_id =NULL,
				@as_of_date=@dt_to,
				@curve_source_value_id =4500 ,
				@pnl_source_value_id =775 ,
				@hedge_or_item  =NULL,
				@process_id =@process_id_reforecast,
				@job_name =NULL,
				@user_id =@user_login_id,
				@assessment_curve_type_value_id = 77,
				@table_name  = NULL,
				@print_diagnostic  = NULL,
				@curve_as_of_date  = @dt_from,
				@tenor_option = NULL,
				@summary_detail  = 'd',
				@options_only = NULL,
				@trader_id  = NULL,
				@status_table_name  = NULL,
				@run_incremental = 'n',
				@term_start  ='2000-01-01',
				@term_end  ='2099-12-31',
				@calc_type  = NULL, --'m' for mtm, 'w' for what if and 's' for settlement
				@curve_shift_val  = NULL,
				@curve_shift_per  = NULL, 
				@deal_list_table =@deal_filters, -- contains list of deals to be processed
				@criteria_id =NULL,
				@counterparty_id =NULL,
				@ref_id = NULL,
				@calc_explain_type  =  'p',---> forecast change
				@batch_process_id	 = NULL,
				@batch_report_param	 = NULL

			EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Calc contract and market value for @as_of_date_from^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
			--EXEC spa_print 'Time taken(second):' +cast(datediff(ss,@start_time, GETDATE()) as varchar)
			set @start_time=GETDATE()	
			EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'

			EXEC spa_print '*************************************************************'
			EXEC spa_print 'Calc contract and market value for @as_of_date_to'
			EXEC spa_print '*************************************************************'

			set @process_id_reforecast=@process_id+'_t1'

			set @delta_price_changed_t1=dbo.FNAProcessTableName('delta_price_changed', @user_login_id, @process_id_reforecast)

			EXEC [dbo].[spa_calc_mtm_job]
				@sub_id =@sub,
				@strategy_id =@str,
				@book_id =@book,
				@source_book_mapping_id=NULL,
				@source_deal_header_id =NULL,
				@as_of_date=@dt_to,
				@curve_source_value_id =4500 ,
				@pnl_source_value_id =775 ,
				@hedge_or_item  =NULL,
				@process_id =@process_id_reforecast,
				@job_name =NULL,
				@user_id =@user_login_id,
				@assessment_curve_type_value_id = 77,
				@table_name  = NULL,
				@print_diagnostic  = NULL,
				@curve_as_of_date  = @dt_to,
				@tenor_option = NULL,
				@summary_detail  = 'd',
				@options_only = NULL,
				@trader_id  = NULL,
				@status_table_name  = NULL,
				@run_incremental = 'n',
				@term_start  ='2000-01-01',
				@term_end  ='2099-12-31',
				@calc_type  = NULL, --'m' for mtm, 'w' for what if and 's' for settlement
				@curve_shift_val  = NULL,
				@curve_shift_per  = NULL, 
				@deal_list_table =@deal_filters, -- contains list of deals to be processed
				@criteria_id =NULL,
				@counterparty_id =NULL,
				@ref_id = NULL,
				@calc_explain_type  =  'p',---> forecast change
				@batch_process_id	 = NULL,
				@batch_report_param	 = NULL

			EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Calc contract and market value for @as_of_date_to^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
			--EXEC spa_print 'Time taken(second):' +cast(datediff(ss,@start_time, GETDATE()) as varchar)
			set @start_time=GETDATE()	
			EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'

			EXEC('create index indx_price_changed_t0_'+@process_id+'__123 on '+@delta_price_changed_t0+' (source_deal_header_id ,curve_id,term_start ,term_end ,leg ,tou_id )')
			EXEC('create index indx_price_changed_t1_'+@process_id+'__123 on '+@delta_price_changed_t1+' (source_deal_header_id ,curve_id,term_start ,term_end ,leg ,tou_id )')


			set @st1='
				select t1.source_deal_header_id ,t1.curve_id,t1.term_start ,t1.term_end,t1.leg,t1.tou_id,
					case when isnull(market_modify,0)=1 then 0 else t1.market_value -t0.market_value end market_value 
					,--case when udf.source_deal_header_id is null then 
					case when isnull(contract_modify,0)=1 then 0 else t1.contract_value -t0.contract_value end --else 0 end 
					contract_value
					, isnull(t0.func_cur_id,t1.func_cur_id) func_cur_id into '+@price_change_value+' 
				from '+@delta_price_changed_t0 +' t0 
				inner join '+@delta_price_changed_t1+' t1 on
					t0.source_deal_header_id=t1.source_deal_header_id and t0.term_start=t1.term_start and t0.term_end=t1.term_end and
					t0.leg=t1.leg and isnull(t0.tou_id,-1)=isnull(t1.tou_id ,-1) and t1.curve_id=t0.curve_id
				left join '+@udf_status+' udf on udf.source_deal_header_id=t1.source_deal_header_id
				left join '+@modify_status+' m on m.source_deal_header_id=t1.source_deal_header_id and
					m.term_start=t1.term_start and m.term_end=t1.term_end and m.leg=t1.leg and m.curve_id=t1.curve_id
				where (t1.market_value -t0.market_value +t1.contract_value -t0.contract_value)<>0	'

			exec spa_print @st1
			exec(@st1)
			SET @st1='	delete m 
			from '+ @deleted_term +' mtm inner join '+@price_change_value+'  m on
			 mtm.source_deal_header_id=m.source_deal_header_id and mtm.term_start=m.term_start and		mtm.leg=m.leg '

			EXEC spa_print @st1
			EXEC(@st1)
			
			EXEC('create index indx_price_change_value_'+@process_id+'__123 on '+@price_change_value+' (source_deal_header_id,term_start ,leg )')
		

			SET @st1='
			delete m 
			from '+ @added_term +' mtm inner join '+@price_change_value+'  m on
			 mtm.source_deal_header_id=m.source_deal_header_id and mtm.term_start=m.term_start and
					mtm.leg=m.leg '

			EXEC spa_print @st1
			EXEC(@st1)

			SET @st1=' update mtm set  mtm.price_changed_mtm=isnull(t1.price_changed_mtm,0) from '+ @temp_explain_mtm +' mtm 
				inner join 
				( select source_deal_header_id,curve_id ,term_start ,term_end,leg,sum(market_value+contract_value) price_changed_mtm from  '+@price_change_value+' p 
					group by source_deal_header_id,curve_id  ,term_start ,term_end,leg having sum(market_value+contract_value)<>0 
				) t1 on mtm.source_deal_header_id=t1.source_deal_header_id and mtm.term_start=t1.term_start and mtm.term_end=t1.term_end and
					mtm.leg=t1.leg  and mtm.curve_id=t1.curve_id and mtm.charge_type=291905'

			EXEC spa_print @st1
			EXEC(@st1)

			EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Finishing price_chage calculation^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
			--EXEC spa_print 'Time taken(second):' +cast(datediff(ss,@start_time, GETDATE()) as varchar)
			set @start_time=GETDATE()	
			EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
		end
	end
	--==========================================================================================================
		---calculate modify-----------------------------------
	--==========================================================================================================


	SET @st1='
	update mtm set  price_changed_mtm=0
	from '+ @temp_explain_mtm +' mtm inner join '+@added_term+'  m on
	 mtm.source_deal_header_id=m.source_deal_header_id and mtm.term_start=m.term_start  and
			mtm.leg=m.leg  -- and charge_type=291905  '

	EXEC spa_print @st1
	EXEC(@st1)
	
	
	SET @st1='
	update mtm set  price_changed_mtm=0
	from '+ @temp_explain_mtm +' mtm inner join '+@deleted_term+'  m on
	 mtm.source_deal_header_id=m.source_deal_header_id and mtm.term_start=m.term_start  and
			mtm.leg=m.leg --and charge_type=291905  '
	EXEC spa_print @st1
	EXEC(@st1)


	SET @st1='
	update mtm set modify_MTM=round(end_mtm-begin_mtm-delivered_mtm- price_changed_mtm,4)
	from '+ @temp_explain_mtm +' mtm inner join '+@modify_status+'  m on
	 mtm.source_deal_header_id=m.source_deal_header_id and mtm.term_start=m.term_start and mtm.term_end=m.term_end and
			mtm.leg=m.leg and (m.deal_modify=1 or m.market_modify=1 or m.contract_modify=1  ) and mtm.curve_id =m.curve_id 
	 where deleted_mtm=0 and new_mtm=0 and (end_mtm-begin_mtm-delivered_mtm- price_changed_mtm)<>0 '

	EXEC spa_print @st1
	EXEC(@st1)

	SET @st1='
		update mtm set modify_MTM=round(end_mtm-begin_mtm-delivered_mtm- price_changed_mtm,4)
		from '+ @temp_explain_mtm +' mtm inner join '+@udf_status+'  m on
		 mtm.source_deal_header_id=m.source_deal_header_id 
		 where deleted_mtm=0 and new_mtm=0 and (end_mtm-begin_mtm-delivered_mtm-price_changed_mtm)<>0 '

	EXEC spa_print @st1
	EXEC(@st1)

	SET @st1='
		update mtm set modify_MTM=round(end_mtm,4)
		from '+ @temp_explain_mtm +' mtm inner join '+@added_term+'  m on
		mtm.source_deal_header_id=m.source_deal_header_id and mtm.term_start=m.term_start and	mtm.leg=m.leg  --and charge_type=291905  '

	EXEC spa_print @st1
	EXEC(@st1)
	
	SET @st1='
		update mtm set modify_MTM=round(-1*(begin_mtm+delivered_mtm),4)
		from '+ @temp_explain_mtm +' mtm inner join '+@deleted_term+'  m on
		mtm.source_deal_header_id=m.source_deal_header_id and mtm.term_start=m.term_start and	mtm.leg=m.leg  ---and charge_type=291905  '

	EXEC spa_print @st1
	EXEC(@st1)




		


	--=======================================================================================================================

	--========================================================================================================================
		-----------------Reforecast-------------------------------------------------------------------------------------
	--=========================================================================================================================
	set @process_id_reforecast=@process_id+'_1'

	SET @st1='select e.source_deal_header_id,e.curve_id,e.location_id,e.term_start,e.commodity_id,e.expiration_date,e.period,e.granularity
			,sum(hr1) hr1,sum(hr2) hr2,sum(hr3) hr3,sum(hr4) hr4,sum(hr5) hr5 ,sum(hr6) hr6
			,sum(hr7) hr7 ,sum(hr8) hr8 ,sum(hr9) hr9 ,sum(hr10) hr10 ,sum(hr11) hr11 
			,sum(hr12) hr12 ,sum(hr13) hr13 ,sum(hr14) hr14 ,sum(hr15) hr15 
			,sum(hr16) hr16 ,sum(hr17) hr17 ,sum(hr18) hr18 ,sum(hr19) hr19
			,sum(hr20) hr20,sum(hr21) hr21,sum(hr22) hr22,sum(hr23) hr23,sum(hr24) hr24,sum(hr25) hr25
			 into '+@forecast_position+'
		FROM [dbo].[delta_report_hourly_position] e 
		inner JOIN '+ @source_deal_header +' sdh  ON e.source_deal_header_id=sdh.source_deal_header_id  
		inner join '+ @source_deal_detail +' sdd on sdd.source_deal_header_id=e.source_deal_header_id 
		and e.curve_id= sdd.curve_id and isnull(e.location_id,-1)=isnull(sdd.location_id,-1)
		and e.term_start between  sdd.term_start and  sdd.term_end	 --  and sdh.product_id=4101
			and  [expiration_date]>'''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' and 
				(CONVERT(VARCHAR(10),e.as_of_date,120)> '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''
				 and CONVERT(VARCHAR(10),e.as_of_date,120)<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''')
				  AND e.[term_start]>'''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' and e.delta_type=17403
		left join (
			select source_deal_header_id from ' +@modify_status +' where deal_modify=1 or market_modify=1 or contract_modify=1 
			union
			select source_deal_header_id from ' +@udf_status +'
		) m on m.source_deal_header_id=sdh.source_deal_header_id
		where m.source_deal_header_id is null
	group by e.source_deal_header_id,e.curve_id,e.location_id,e.term_start,e.commodity_id,e.expiration_date,e.period,e.granularity
  		'
	EXEC spa_print @st1
	EXEC(@st1)	

	IF @@ROWCOUNT>0
	BEGIN
		EXEC spa_print 'Calculate MTM for reforecast position'
		SET @tmp_date=CONVERT(VARCHAR(10),@as_of_date_to,120)

		EXEC [dbo].[spa_calc_mtm_job]
			@sub_id =@sub,
			@strategy_id =@str,
			@book_id =@book,
			@source_book_mapping_id=NULL,
			@source_deal_header_id =NULL,
			@as_of_date=@tmp_date,
			@curve_source_value_id =4500 ,
			@pnl_source_value_id =775 ,
			@hedge_or_item  =NULL,
			@process_id =@process_id_reforecast,
			@job_name =NULL,
			@user_id =@user_login_id,
			@assessment_curve_type_value_id = 77,
			@table_name  = NULL,
			@print_diagnostic  = NULL,
			@curve_as_of_date  = NULL,
			@tenor_option = NULL,
			@summary_detail  = 'd',
			@options_only = NULL,
			@trader_id  = NULL,
			@status_table_name  = NULL,
			@run_incremental = 'n',
			@term_start  ='2000-01-01',
			@term_end  ='2099-12-31',
			@calc_type  = NULL, --'m' for mtm, 'w' for what if and 's' for settlement
			@curve_shift_val  = NULL,
			@curve_shift_per  = NULL, 
			@deal_list_table =@process_id_reforecast, -- contains list of deals to be processed
			@criteria_id =NULL,
			@counterparty_id =NULL,
			@ref_id = NULL,
			@calc_explain_type  =  'f',---> forecast change
			@batch_process_id	 = NULL,
			@batch_report_param	 = NULL
			
		EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Calc reforecast mtm^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
		--EXEC spa_print 'Time taken(second):' +cast(datediff(ss,@start_time, GETDATE()) as varchar)
		set @start_time=GETDATE()	
		EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
			

		EXEC spa_print '*************************Explain mtm (reforecast_mtm).********************************'

		SET @st1=' update mtm set  mtm.reforecast_mtm=sdp.und_pnl from  '+ @temp_explain_mtm +'  mtm
			 inner join  '+@explain_reforecast_deals+' sdp 	on sdp.term_start = mtm.term_start
			  and sdp.term_end=mtm.term_end and sdp.curve_id=mtm.curve_id  and mtm.begin_mtm<>0 and mtm.deleted_mtm=0 and mtm.new_mtm=0
				and sdp.source_deal_header_id=mtm.source_deal_header_id	 and sdp.und_pnl<>0 and mtm.charge_type=291905
			'

		EXEC spa_print @st1
		EXEC(@st1)	
		
		SET @st1=' update mtm set  mtm.modify_MTM=0 from  '+ @temp_explain_mtm +'  mtm
				where  round(mtm.modify_MTM,4)=round(mtm.reforecast_mtm,4) and  mtm.charge_type=291905
			'

		EXEC spa_print @st1
		EXEC(@st1)	
		
		SET @st1=' update mtm set  mtm.reforecast_mtm=0 from  '+ @temp_explain_mtm +'  mtm
				where  round(mtm.modify_MTM,4)<>round(mtm.reforecast_mtm,4) and  mtm.modify_MTM<>0 and mtm.charge_type=291905
			'

		EXEC spa_print @st1
		EXEC(@st1)	
		
		EXEC spa_print '*************************Explain mtm (reforecast_mtm fee breakdown).********************************'

		SET @st1=' update mtm set  mtm.reforecast_mtm=sdp.value*isnull(fac.discount_factor,1) from  '+ @temp_explain_mtm +'  mtm
		inner join '+@source_deal_detail +' sdd on sdd.source_deal_header_id=mtm.source_deal_header_id
			and sdd.term_start=mtm.term_start and sdd.curve_id=mtm.curve_id  and mtm.charge_type<>291905
			 inner join  '+@index_fee_breakdown_reforecast+' sdp on sdp.term_start = sdd.term_start
			  and sdp.leg=sdd.leg 	and sdp.source_deal_header_id=mtm.source_deal_header_id
			  and mtm.charge_type=sdp.field_id	and  mtm.modify_MTM=0 and mtm.begin_mtm<>0 and sdp.value<>0 and mtm.deleted_mtm=0 and mtm.new_mtm=0
			left join '+@temp_discounted_mtm_factor+' fac on fac.source_deal_header_id=sdp.source_deal_header_id and fac.term_start=sdp.term_start
				and fac.as_of_date=sdp.as_of_date			'

		EXEC spa_print @st1
		EXEC(@st1)							
			
	END 
		
	--=================================End reforecast mtm==============================================================================	

	----==============================================================================================================================
	--PRINT 'calc unexplain mtm'
	----==============================================================================================================================
		
	--PRINT('update '+@temp_explain_mtm+ ' set unexplain_mtm =round(end_mtm-(begin_mtm+new_mtm+modify_MTM+delivered_mtm+deleted_mtm+ reforecast_mtm+price_changed_mtm),2)  where deleted_mtm=0 and new_mtm=0')

	--EXEC('update '+@temp_explain_mtm+ ' set unexplain_mtm =round(end_mtm-(begin_mtm+new_mtm+modify_MTM+delivered_mtm+deleted_mtm+ reforecast_mtm+price_changed_mtm),2)  where deleted_mtm=0 and new_mtm=0')

	----==================================================================================================================
	-------------------end calc unexplain mtm-------------------------------------------------------------------------------------
	----=========================================================================================================================
		
	--	Added unexplained  into modified mtm if any 

	SET @st1='
		update mtm set modify_MTM=modify_MTM+unexplain_mtm,unexplain_mtm=0
		from '+ @temp_explain_mtm +' mtm inner join '+@modify_status+'  m on
		 mtm.source_deal_header_id=m.source_deal_header_id and convert(varchar(7),mtm.term_start,120)=convert(varchar(7),m.term_start,120)
		   and mtm.leg=m.leg and (m.deal_modify=1 or m.market_modify=1 or m.contract_modify=1) and mtm.curve_id =m.curve_id 
		 where unexplain_mtm<>0  '

	EXEC spa_print @st1
	EXEC(@st1)

	SET @st1='
		update mtm set modify_MTM=modify_MTM+unexplain_mtm,unexplain_mtm=0
		from '+ @temp_explain_mtm +' mtm inner join '+@udf_status+'  m on
		 mtm.source_deal_header_id=m.source_deal_header_id 
		 where unexplain_mtm<>0 '

	EXEC spa_print @st1
	EXEC(@st1)


	---insert price change by tou
	EXEC('update '+@temp_explain_mtm+ ' set price_changed_mtm =0  where price_changed_mtm<>0')


	if OBJECT_ID(@price_change_value) is not null
	begin
	
		SET @st1=' insert into '+ @temp_explain_mtm +' (
			source_deal_header_id,term_start,term_end, curve_id,leg,tou_id,begin_mtm,new_mtm, modify_MTM
			,reforecast_mtm, deleted_mtm,delivered_mtm, price_changed_mtm, end_mtm	,pnl_currency_id ,charge_type
		) 
		select source_deal_header_id ,term_start ,term_end,curve_id,leg,tou_id 
			, 0 begin_mtm,0 new_mtm, 0 modify_MTM	,0 reforecast_mtm,0 deleted_mtm,
			0 delivered_mtm, market_value+contract_value price_changed_mtm,0 end_mtm	,func_cur_id pnl_currency_id ,291905 charge_type
		from  '+@price_change_value+'  where (market_value+contract_value)<>0 
		'

		EXEC spa_print @st1
		EXEC(@st1)

	end 
	
	--==============================================================================================================================
	EXEC spa_print 'update null curve id that are deleted term'
	--==============================================================================================================================
		
	set @st1='update t  set curve_id =a.curve_id
	from  '+@temp_explain_mtm+ ' t cross apply
	(select top(1) curve_id from source_deal_detail_audit where source_deal_header_id= t.source_deal_header_id and leg=t.leg and term_start=t.term_start
		and t.curve_id is null and update_ts<'''+convert(varchar(10),@as_of_date_to,120 )+''' order by update_ts desc) a  where t.curve_id is null'

	EXEC spa_print @st1
	exec(@st1)

	--==================================================================================================================
	-----------------end 'update null curve id that are deleted term'-------------------------------------------------------------------------------------
	--======================================================================================================================

	--========================================================================================================
		EXEC spa_print 'Deferral Term'
	--========================================================================================================
	SET @phy_columns='sdp.source_deal_header_id, sdh.physical_financial_flag,sdp.[curve_id]
			,sdh.book_deal_type_map_id,sdh.[broker_id],sdp.charge_type,sdh.[counterparty_id],sdp.tou_id,isnull(hdv.pnl_term,sdp.term_start) '

	SET @st1='
	select source_deal_header_id,[curve_id],charge_type,tou_id,term_start, max(physical_financial_flag) physical_financial_flag
	,max(book_deal_type_map_id) book_deal_type_map_id,max([broker_id]) broker_id,max([counterparty_id]) counterparty_id
	,max(pnl_currency_id) pnl_currency_id,sum(begin_mtm)  begin_mtm,sum(new_mtm) new_mtm,sum(modify_MTM) modify_MTM,sum(reforecast_mtm) reforecast_mtm
	,sum(deleted_mtm) deleted_mtm,sum(delivered_mtm) delivered_mtm,sum(price_changed_mtm) price_changed_mtm
	,sum(end_mtm) end_mtm,sum(unexplain_mtm) unexplain_mtm into '+@deferral_temp_explain_mtm+ '
	from (
	select '+@phy_columns+' term_start ,max(sdp.pnl_currency_id) pnl_currency_id,
		sum(case when sdh.create_ts='''+CONVERT(VARCHAR(10),@as_of_date_to,120)+''' then 0 else isnull(hdvp.und_pnl,sdp.begin_mtm) end)  begin_mtm,sum(case when sdh.create_ts='''+CONVERT(VARCHAR(10),@as_of_date_to,120)+''' then isnull(hdv.und_pnl,sdp.new_mtm) else 0 end) new_mtm
		,sum(sdp.modify_MTM)*isnull(avg(hdv.per_alloc),1) modify_MTM,sum(sdp.reforecast_mtm)*isnull(avg(hdv.per_alloc),1) reforecast_mtm
		,sum(deleted_mtm)*isnull(avg(hdv.per_alloc),1) deleted_mtm,sum(sdp.delivered_mtm)*isnull(avg(hdv.per_alloc),1) delivered_mtm
		,sum(sdp.price_changed_mtm)*isnull(avg(hdv.per_alloc),1) price_changed_mtm,sum(isnull(hdv.und_pnl,sdp.end_mtm)) end_mtm
		,sum(sdp.unexplain_mtm) unexplain_mtm

	from (select source_deal_header_id, [curve_id],
		charge_type,max(pnl_currency_id) pnl_currency_id,tou_id,term_start,term_end,sum(begin_mtm)  begin_mtm,sum(new_mtm) new_mtm
		,sum(modify_MTM) modify_MTM,sum(reforecast_mtm) reforecast_mtm,sum(deleted_mtm) deleted_mtm,sum(delivered_mtm) delivered_mtm
		,sum(price_changed_mtm) price_changed_mtm,sum(end_mtm) end_mtm,sum(unexplain_mtm) unexplain_mtm
	from '+@temp_explain_mtm +'
	group by source_deal_header_id, [curve_id]
		,charge_type,tou_id,term_start,term_end ) sdp		
	inner join '+ @source_deal_header +' sdh on sdp.source_deal_header_id=sdh.source_deal_header_id
	left JOIN hedge_deferral_values hdv ON sdp.source_deal_header_id=hdv.source_deal_header_id 
		AND sdp.term_start=hdv.cash_flow_term AND hdv.as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_to,120)+'''
	left JOIN hedge_deferral_values hdvp ON sdp.source_deal_header_id=hdvp.source_deal_header_id 
		AND sdp.term_start=hdvp.cash_flow_term AND hdvp.as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_from,120)+'''
		and isnull(hdvp.pnl_term,sdp.term_start)=isnull(hdv.pnl_term,sdp.term_start)
	GROUP BY '+@phy_columns
+' union all
		select hdv.source_deal_header_id,sdh.physical_financial_flag,isnull(sdd.curve_id,sdp.[curve_id])
		,sdh.book_deal_type_map_id,sdh.[broker_id],291905,sdh.[counterparty_id],sdp.tou_id,isnull(hdv.pnl_term,sdp.term_start) term_start,max(sdp.pnl_currency_id) pnl_currency_id ,
		sum(case when sdh.create_ts='''+CONVERT(VARCHAR(10),@as_of_date_to,120)+''' then 0 else hdv.und_pnl end) begin_mtm
		,sum(case when sdh.create_ts='''+CONVERT(VARCHAR(10),@as_of_date_to,120)+''' then hdv.und_pnl else 0 end) new_mtm
		,0 modify_MTM,0 reforecast_mtm
		,0 deleted_mtm,0 delivered_mtm
		,0 price_changed_mtm,sum(hdv.und_pnl) end_mtm
		,0 unexplain_mtm
	from  hedge_deferral_values hdv 
	inner join '+ @source_deal_header +' sdh on hdv.source_deal_header_id=sdh.source_deal_header_id and hdv.as_of_date='''+CONVERT(VARCHAR(10),@as_of_date_to,120)+'''
	left join '+ @source_deal_detail +' sdd on hdv.source_deal_header_id=sdd.source_deal_header_id
		and hdv.cash_flow_term =sdd.term_start
	left join '+@temp_explain_mtm +' sdp ON sdp.source_deal_header_id=hdv.source_deal_header_id 
		AND sdp.term_start=hdv.cash_flow_term 
		where sdp.term_start is null and (set_type = ''s''  and pnl_term >='''+CONVERT(VARCHAR(8),@as_of_date_from,120)+'01'')  --these have 0 deltas and picked up only for begin/end mtm
	GROUP BY hdv.source_deal_header_id, sdh.physical_financial_flag,isnull(sdd.curve_id,sdp.[curve_id])
		,sdh.book_deal_type_map_id,sdh.[broker_id],sdh.[counterparty_id],sdp.tou_id,isnull(hdv.pnl_term,sdp.term_start)
	) a
	group by  source_deal_header_id,[curve_id],charge_type,tou_id,term_start'

	EXEC spa_print @st1
	EXEC(@st1)


	--==============================================================================================================================		
	---End Deferral Term-----------------------------------

	--==============================================================================================================================		

		--delete unchanged mtm record

	--PRINT('delete '+@deferral_temp_explain_mtm+ ' where end_mtm=begin_mtm and charge_type=291905 and curve_id is not null and isnull(price_changed_mtm,0)=0')	
	--EXEC('delete '+@deferral_temp_explain_mtm+ ' where end_mtm=begin_mtm and charge_type=291905 and curve_id is not null and isnull(price_changed_mtm,0)=0')

	--	====================================================================================================================
			
--==============================================================================================================================
	EXEC spa_print 'calc unexplain mtm'
	--==============================================================================================================================
		

	SET @st1='update '+@deferral_temp_explain_mtm+ ' set unexplain_mtm =round(sdp.end_mtm-(sdp.begin_mtm+sdp.new_mtm+sdp.modify_MTM+sdp.delivered_mtm+sdp.deleted_mtm+ sdp.reforecast_mtm+sdp.price_changed_mtm),4)
		from (
		select source_deal_header_id,[curve_id],
			charge_type,max(pnl_currency_id) pnl_currency_id,term_start,sum(begin_mtm)  begin_mtm,sum(new_mtm) new_mtm
			,sum(modify_MTM) modify_MTM,sum(reforecast_mtm) reforecast_mtm,sum(deleted_mtm) deleted_mtm,sum(delivered_mtm) delivered_mtm
			,sum(price_changed_mtm) price_changed_mtm,sum(end_mtm) end_mtm,sum(unexplain_mtm) unexplain_mtm
		from '+@deferral_temp_explain_mtm +'
		group by source_deal_header_id,[curve_id],charge_type,term_start 
		) sdp inner join '+@deferral_temp_explain_mtm +' d on d.source_deal_header_id=sdp.source_deal_header_id 
		and  d.[curve_id]=sdp.[curve_id] and d.charge_type=sdp.charge_type and d.term_start=sdp.term_start and d.[curve_id] is not null
		   where d.deleted_mtm=0 and d.new_mtm=0 and d.tou_id is null 
	 and round(sdp.end_mtm-(sdp.begin_mtm+sdp.new_mtm+sdp.modify_MTM+sdp.delivered_mtm+sdp.deleted_mtm+ sdp.reforecast_mtm+sdp.price_changed_mtm),2)<>0'
	
	EXEC spa_print @st1
	exec(@st1)
	
	
	--==================================================================================================================
	-----------------end calc unexplain mtm-------------------------------------------------------------------------------------
	--=========================================================================================================================
	
			
--==============================================================================================================================
	EXEC spa_print 'calc modify (unexplain)  mtm for cuve_id is null'
--==============================================================================================================================
		
	SET @st1='update '+@deferral_temp_explain_mtm+ ' set modify_MTM =round(sdp.end_mtm-(sdp.begin_mtm+sdp.new_mtm+sdp.modify_MTM+sdp.delivered_mtm+sdp.deleted_mtm+ sdp.reforecast_mtm+sdp.price_changed_mtm),4)
		from (
		select source_deal_header_id, [curve_id],
			charge_type,pnl_currency_id,term_start,sum(begin_mtm)  begin_mtm,sum(new_mtm) new_mtm
			,sum(modify_MTM) modify_MTM,sum(reforecast_mtm) reforecast_mtm,sum(deleted_mtm) deleted_mtm,sum(delivered_mtm) delivered_mtm
			,sum(price_changed_mtm) price_changed_mtm,sum(end_mtm) end_mtm,sum(unexplain_mtm) unexplain_mtm
		from '+@deferral_temp_explain_mtm +'  where [curve_id] is null
		group by source_deal_header_id,[curve_id],charge_type,pnl_currency_id,term_start 
		) sdp inner join '+@deferral_temp_explain_mtm +' d on d.source_deal_header_id=sdp.source_deal_header_id 
		and   d.charge_type=sdp.charge_type and d.term_start=sdp.term_start and d.[curve_id] is null and  isnull(d.modify_MTM,0)=0
		   where d.deleted_mtm=0 and d.new_mtm=0 and d.tou_id is null 
	 and round(sdp.end_mtm-(sdp.begin_mtm+sdp.new_mtm+sdp.modify_MTM+sdp.delivered_mtm+sdp.deleted_mtm+ sdp.reforecast_mtm+sdp.price_changed_mtm),2)<>0'
	
	EXEC spa_print @st1
	exec(@st1)
	
	
	
	--==================================================================================================================
	-----------------calc modify (unexplain)  mtm for cuve_id is null----------------------------------------------------------
	--=========================================================================================================================	
	
	
	--Hedge Defferal unxplain moved to deliver
	SET @st1='
		update '+@deferral_temp_explain_mtm+' set delivered_mtm=delivered_mtm+unexplain_mtm,unexplain_mtm=0
		from '+@deferral_temp_explain_mtm+' a inner join hedge_deferral_values b on a.source_deal_header_id=b.source_deal_header_id
				 where a.unexplain_mtm<>0 and a.delivered_mtm<>0  '

	EXEC spa_print @st1
	EXEC(@st1)
	
	
	
				
	EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Finalize explain mtm^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
	--EXEC spa_print 'Time taken(second):' +cast(datediff(ss,@start_time, GETDATE()) as varchar)
	set @start_time=GETDATE()	
	EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
			
	--===============================================================================
	-- Calculate MTM for delivered position 
	--===========================================================================

	--set @adhoc='n'
	IF @run_mode=0
	BEGIN

		SELECT @delivered_date=dbo.FNAGetBusinessDay('n',@as_of_date_to,@default_holiday_id)

		SET @st2='
			select e.[source_deal_header_id],e.[curve_id],isnull(e.[location_id],-1) location_id,e.[term_start],e.[commodity_id],e.[physical_financial_flag],e.period,e.granularity
				,e.[hr1],e.[hr2],e.[hr3],e.[hr4],e.[hr5],e.[hr6],e.[hr7],e.[hr8],e.[hr9],e.[hr10],e.[hr11],e.[hr12],e.[hr13]
				,e.[hr14],e.[hr15],e.[hr16],e.[hr17],e.[hr18],e.[hr19],e.[hr20],e.[hr21],e.[hr22],e.[hr23],e.[hr24],e.[hr25],e.[expiration_date]
			into '+@delivered_position+ '
			FROM [dbo].[report_hourly_position_profile] e 
			inner JOIN '+ @source_deal_header +' sdh  ON e.source_deal_header_id=sdh.source_deal_header_id  
				and e.expiration_date>'''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' AND e.[term_start]>'''+CONVERT(VARCHAR(10),@as_of_date_to,120) +'''
				and ( e.expiration_date<='''+CONVERT(VARCHAR(10),@delivered_date,120) +''' or e.[term_start]<='''+CONVERT(VARCHAR(10),@delivered_date,120) +''')
			UNION ALL
				select e.[source_deal_header_id],e.[curve_id],isnull(e.[location_id],-1) location_id,e.[term_start],e.[commodity_id],e.[physical_financial_flag],e.period,e.granularity
					,e.[hr1],e.[hr2],e.[hr3],e.[hr4],e.[hr5],e.[hr6],e.[hr7],e.[hr8],e.[hr9],e.[hr10],e.[hr11],e.[hr12],e.[hr13]
					,e.[hr14],e.[hr15],e.[hr16],e.[hr17],e.[hr18],e.[hr19],e.[hr20],e.[hr21],e.[hr22],e.[hr23],e.[hr24],e.[hr25],e.[expiration_date]
				FROM [dbo].[report_hourly_position_deal] e 
				inner JOIN '+ @source_deal_header +' sdh  ON e.source_deal_header_id=sdh.source_deal_header_id  
					and e.expiration_date>'''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' AND e.[term_start]>'''+CONVERT(VARCHAR(10),@as_of_date_to,120) +'''
					and ( e.expiration_date<='''+CONVERT(VARCHAR(10),@delivered_date,120) +''' or e.[term_start]<='''+CONVERT(VARCHAR(10),@delivered_date,120) +''')
			UNION ALL
				select e.[source_deal_header_id],e.[curve_id],isnull(e.[location_id],-1) location_id,e.[term_start],e.[commodity_id],e.[physical_financial_flag],e.period,e.granularity
						,e.[hr1],e.[hr2],e.[hr3],e.[hr4],e.[hr5],e.[hr6],e.[hr7],e.[hr8],e.[hr9],e.[hr10],e.[hr11],e.[hr12],e.[hr13]
						,e.[hr14],e.[hr15],e.[hr16],e.[hr17],e.[hr18],e.[hr19],e.[hr20],e.[hr21],e.[hr22],e.[hr23],e.[hr24],e.[hr25],e.[expiration_date]
				FROM [dbo].[report_hourly_position_fixed] e 
				inner JOIN '+ @source_deal_header +' sdh  ON e.source_deal_header_id=sdh.source_deal_header_id   and sdh.fixation=4100
					and e.expiration_date>'''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' AND e.[term_start]>'''+CONVERT(VARCHAR(10),@as_of_date_to,120) +'''
					and ( e.expiration_date<='''+CONVERT(VARCHAR(10),@delivered_date,120) +''' or e.[term_start]<='''+CONVERT(VARCHAR(10),@delivered_date,120) +''')
				'
		EXEC spa_print @st2
		EXEC( @st2)

		SET @job_name = 'calc_mtm_for_delivered_position' + @process_id

		SET @tmp_date=CONVERT(VARCHAR(10),@as_of_date_to,120)

		SET @spa = '[spa_calc_mtm_job] '
		
		if @sub is null
			SET @spa = @spa+'null'
		else
			SET @spa = @spa+'''' + @sub +''''

		if @str is null
			SET @spa = @spa+',null'
		else
			SET @spa = @spa+',''' + @str +''''
			
		if @book is null
			SET @spa = @spa+',null'
		else
			SET @spa = @spa+',''' + @book +''''
		
		SET @spa = @spa+',NULL,NULL,''' + @tmp_date +''',4500 ,775 ,
						NULL,''' +@process_id +''' ,NULL,''' +@user_login_id +''' ,77,NULL,NULL,NULL,NULL,''d'',
						NULL,NULL,NULL,''n'',''2000-01-01'',''2012-12-31'',NULL,NULL,NULL, ''' +@process_id +''',
						null,NULL,NULL,''d'',NULL,NULL'
		exec spa_print 'exec ', @spa				
		exec('exec '+@spa)
		--EXEC spa_run_sp_as_job @job_name,  @spa, 'calc_mtm_for_delivered_position', @user_login_id

		EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Calc delivered mtm^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
		--EXEC spa_print 'Time taken(second):' +cast(datediff(ss,@start_time, GETDATE()) as varchar)
		set @start_time=GETDATE()	
		EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'

	END 
		
	IF @run_mode IN (0,1)
	BEGIN	

		SET @st1='
			DELETE explain_mtm '+ CASE WHEN ISNULL(@purge,'n')='n'  THEN ' from explain_mtm e inner join #book b on b.book_deal_type_map_id=e.book_deal_type_map_id ' ELSE + '' END+ ' WHERE [as_of_date_from]='''+ CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  AND [as_of_date_to]='''+ CONVERT(VARCHAR(10),@as_of_date_to,120) +''' 
			INSERT INTO  explain_mtm([as_of_date_from],[as_of_date_to],[curve_id] ,counterparty_id,[charge_type] ,[term_start],
					[book_deal_type_map_id] ,[physical_financial_flag],[ob_mtm],[new_deal],[deal_modify],[forecast_changed],[deleted],[delivered],
					[price_changed],un_explain,[cb_mtm],[currency_id] ,[create_ts] ,[create_user],tou_id
				)
			SELECT '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +''' [as_of_date_from],'''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' [as_of_date_to]
				,delta.[curve_id],delta.[counterparty_id],delta.[charge_type],delta.[term_start],delta.book_deal_type_map_id,delta.physical_financial_flag
				,sum(delta.begin_mtm), sum(delta.new_mtm), sum(delta.modify_MTM), sum(delta.reforecast_mtm),sum(delta.deleted_mtm), sum(delta.delivered_mtm)
			, sum(delta.price_changed_mtm),sum(delta.unexplain_mtm), sum(delta.end_mtm),delta.pnl_currency_id	,getdate(),'''+@user_login_id+''',delta.tou_id
				FROM '+ @deferral_temp_explain_mtm +' delta 
				group by  physical_financial_flag,[curve_id],book_deal_type_map_id,charge_type,[counterparty_id],pnl_currency_id,tou_id,term_start '


		EXEC spa_print @st1
		EXEC( @st1)
		
		IF @run_mode IN (0)
			goto exeit_proc

			--RETURN
	END 	
	
	IF @run_mode IN (2)	
	BEGIN 
		SET @st1='SELECT subs.entity_name + '' / ''+ stra.entity_name+ '' / '' + book.entity_name [Book],'
			+CASE WHEN @deal_level='y' THEN ' dbo.FNAHyperLink(10131024,cast(delta.source_deal_header_id as varchar) ,delta.source_deal_header_id,''-1'') [Deal ID],' ELSE '' END +' 
				spcd.[curve_name] [Index],
				 CASE WHEN delta.physical_financial_flag=''p'' THEN ''Physical'' ELSE ''Financial'' END [Physical/Financial],
				 sdv.description ChargeType, cpty.counterparty_name Counterparty,
				 isnull(max(grp.block_name),''Base Load'')  TOU
				 ,dbo.FNADateFormat(delta.[term_start]) [Term]
				,round(sum(delta.[begin_mtm]),'+ISNULL(@round,'9')+') [BeginningMTM] 
				,round(sum(delta.new_mtm),'+ISNULL(@round,'9')+') [NewBusinessMTM]
				,round(sum(delta.modify_MTM) ,'+ISNULL(@round,'9')+') [DealModifiedMTM]
				,round(sum(delta.[deleted_mtm]),'+ISNULL(@round,'9')+') [DeletedMTM]
				,round(sum(delta.reforecast_mtm),'+ISNULL(@round,'9')+') [Re-forecastMTM]
				,round(sum(delta.[delivered_mtm]),'+ISNULL(@round,'9')+') [DeliveryMTM]
				,round(sum(delta.[price_changed_mtm]),'+ISNULL(@round,'9')+') [PriceChangedMTM]
				,round(sum(delta.[unexplain_mtm]),'+ISNULL(@round,'9')+') [UnexplainMTM]
				,round(sum(delta.[end_mtm]),'+ISNULL(@round,'9')+') [EndingMTM]
				,max(sc.currency_name) Currency
				'+ ISNULL(@str_batch_table,'') +'
			FROM '+@deferral_temp_explain_mtm+' delta
				LEFT JOIN  source_price_curve_def spcd ON spcd.source_curve_def_id = delta.curve_id 
				LEFT JOIN source_currency sc ON sc.source_currency_id=delta.pnl_currency_id
				LEFT JOIN static_data_value sdv ON sdv.value_id=delta.charge_type
				LEFT JOIN source_counterparty cpty ON cpty.source_counterparty_id=delta.counterparty_id
				LEFT JOIN source_system_book_map sbm ON sbm.book_deal_type_map_id=delta.book_deal_type_map_id
				LEFT JOIN portfolio_hierarchy book ON book.entity_id=sbm.fas_book_id
				LEFT JOIN portfolio_hierarchy stra ON stra.entity_id=book.parent_entity_id
				LEFT JOIN portfolio_hierarchy subs ON subs.entity_id=stra.parent_entity_id
				left join block_type_group grp ON grp.id=delta.tou_id 
			WHERE 1=1'
				+ CASE WHEN @term_start IS NULL THEN '' ELSE ' AND delta.term_start >= ''' + CONVERT(VARCHAR(10),@term_start,120) + '''' END
				+ CASE WHEN @term_end IS NULL THEN '' ELSE ' AND delta.term_start <= ''' + CONVERT(VARCHAR(10),@term_end,120) + '''' END
				+CASE WHEN @st_criteria IS NULL THEN '' ELSE  @st_criteria END + 
			' GROUP BY subs.entity_name, stra.entity_name, book.entity_name ,'+CASE WHEN @deal_level='y' THEN ' delta.[source_deal_header_id],' ELSE '' END +' 
				spcd.[curve_name], delta.physical_financial_flag, sdv.description,cpty.counterparty_name ,delta.[term_start]	,delta.tou_id		
			ORDER BY delta.physical_financial_flag'+CASE WHEN @deal_level='y' THEN ',[Deal ID]' ELSE '' END +', [index],delta.term_start'	        
	   
		exec spa_print @st1
		EXEC(@st1)
		GOTO batch_process
	END 	
END 

reporting:
IF @run_mode IN (1,3)	
BEGIN 
	if   @calc_type in ('p')
	BEGIN
		SET @st1='SELECT subs.entity_name + '' / ''+ stra.entity_name+ '' / '' + book.entity_name [Book],
						 spcd.[curve_name] [Index],
						 spcd1.[curve_name] [ProxyIndex],
						 CASE WHEN delta.physical_financial_flag=''p'' THEN ''Physical'' ELSE ''Financial'' END [Physical/Financial], 
						 cpty.counterparty_name Counterparty, max(grp.block_name) TOU,
						 dbo.FNADateFormat(delta.[term_start]) [Term],
						 CAST(SUM(delta.OB_value) AS NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [Beginning Position],
						 CAST(SUM(delta.new_deal) AS NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [New Business Position],
						 CAST(SUM(delta.modify_deal) AS NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [Modified Deals Position],
						 CAST(SUM(delta.deleted) AS NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [Deleted Deals Position] ,
						 CAST(SUM(delta.forecast_changed) AS NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [Re-forecast Position],
						 CAST(SUM(delta.delivered) AS NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [Delivery Position],
						 CAST(SUM(delta.un_explain) AS NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [Unexplain Position],
						 CAST(SUM(delta.CB_value) AS NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [Ending Position],
						 MAX(su.uom_name) [UOM]
						'+ @str_batch_table +'
						FROM dbo.explain_position delta  inner join #book b on delta.book_deal_type_map_id=b.book_deal_type_map_id
							LEFT JOIN  source_price_curve_def spcd ON spcd.source_curve_def_id = delta.curve_id 
							LEFT JOIN  source_price_curve_def spcd1 ON spcd1.source_curve_def_id = delta.proxy_curve_id 
							LEFT JOIN source_uom su ON su.source_uom_id=delta.uom_id
							LEFT JOIN source_counterparty cpty ON cpty.source_counterparty_id=delta.counterparty_id
							LEFT JOIN source_system_book_map sbm ON sbm.book_deal_type_map_id=delta.book_deal_type_map_id
							LEFT JOIN portfolio_hierarchy book ON book.entity_id=sbm.fas_book_id
							LEFT JOIN portfolio_hierarchy stra ON stra.entity_id=book.parent_entity_id
							LEFT JOIN portfolio_hierarchy subs ON subs.entity_id=stra.parent_entity_id	
							left join block_type_group grp ON delta.tou_id=grp.id 		
						WHERE 1=1'
			+ CASE WHEN @term_start IS NULL THEN '' ELSE ' AND delta.term_start >= ''' + CONVERT(VARCHAR(10),@term_start,120) + '''' END
			+ CASE WHEN @term_end IS NULL THEN '' ELSE ' AND delta.term_start <= ''' + CONVERT(VARCHAR(10),@term_end,120) + '''' END
			+ CASE WHEN @as_of_date_from IS NULL THEN '' ELSE ' AND delta.as_of_date_from = ''' + CONVERT(VARCHAR(10),@as_of_date_from,120) + '''' END
			+ CASE WHEN @as_of_date_to IS NULL THEN '' ELSE ' AND delta.as_of_date_to = ''' + CONVERT(VARCHAR(10),@as_of_date_to,120) + '''' END
			+ CASE WHEN @st_criteria IS NULL THEN '' ELSE  @st_criteria END + 
			' GROUP BY subs.entity_name,  stra.entity_name, book.entity_name ,'
			+ CASE WHEN @deal_level='y' THEN ' delta.[source_deal_header_id],' ELSE '' END + ' spcd.[curve_name],spcd1.[curve_name],
				 delta.physical_financial_flag, cpty.counterparty_name,delta.[term_start],delta.Hr
			ORDER BY delta.physical_financial_flag,1, [index],delta.term_start,delta.Hr'	 

		EXEC spa_print @st1
		EXEC( @st1)
	END
	if   @calc_type in ( 'm')
	BEGIN

		SET @st1='SELECT subs.entity_name + '' / ''+ stra.entity_name+ '' / '' + book.entity_name [Book],
						spcd.[curve_name] [INDEX],
						CASE WHEN delta.physical_financial_flag=''p'' THEN ''Physical'' ELSE ''Financial'' END [Physical/Financial],
				 sdv.description ChargeType, cpty.counterparty_name Counterparty, isnull(grp.block_name,''Base Load'') TOU
					,	dbo.FNADateFormat(delta.[term_start]) [Term]
				,cast(delta.ob_mtm  as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [BeginningMTM] 
				,cast(delta.new_deal as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [NewBusinessMTM]
				,cast(delta.deal_modify as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [DealModifiedMTM]
				,cast(delta.deleted as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [DeletedMTM]
				,cast(delta.forecast_changed as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [Re-forecastMTM]
				,cast(delta.delivered as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [DeliveryMTM]
				,cast(delta.price_changed as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [PriceChangedMTM]
				,cast(delta.un_explain as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [UnexplainMTM]
				,cast(delta.cb_mtm as NUMERIC(30,' + CAST(ISNULL(@round, '10') AS VARCHAR(2)) + ')) [EndingMTM]
				,sc.currency_name Currency	'+ ISNULL(@str_batch_table,'') +'
				FROM dbo.explain_mtm delta  inner join #book b on delta.book_deal_type_map_id=b.book_deal_type_map_id
				LEFT JOIN  source_price_curve_def spcd 
					ON spcd.source_curve_def_id = delta.curve_id 
						LEFT JOIN source_currency sc ON sc.source_currency_id=delta.currency_id
						LEFT JOIN static_data_value sdv ON sdv.value_id=delta.charge_type
						LEFT JOIN source_counterparty cpty ON cpty.source_counterparty_id=delta.counterparty_id
						LEFT JOIN source_system_book_map sbm ON sbm.book_deal_type_map_id=delta.book_deal_type_map_id
						LEFT JOIN portfolio_hierarchy book ON book.entity_id=sbm.fas_book_id
						LEFT JOIN portfolio_hierarchy stra ON stra.entity_id=book.parent_entity_id
						LEFT JOIN portfolio_hierarchy subs ON subs.entity_id=stra.parent_entity_id	
						left join block_type_group grp ON delta.tou_id=grp.id		
			WHERE delta.as_of_date_from='''+convert(varchar(10),@as_of_date_from,120) +''' AND delta.as_of_date_to='''+convert(varchar(10),@as_of_date_to,120) +''''
			+ CASE WHEN @term_start IS NULL THEN '' ELSE ' AND delta.term_start >= ''' + CONVERT(VARCHAR(12), @term_start, 120) + '''' END
			+ CASE WHEN @term_end IS NULL THEN '' ELSE ' AND delta.term_start <= ''' + CONVERT(VARCHAR(12), @term_end, 120) + '''' END
			 + ISNULL(@st_criteria,'') +  
			' ORDER BY delta.physical_financial_flag, [INDEX],delta.term_start'	        
		    
		EXEC spa_print @str_batch_table
		exec spa_print @st1
		EXEC(@st1)
	END
END 		


batch_process:
/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
IF @is_batch = 1  AND @run_mode <> 0
BEGIN
	IF @sp_name IS NULL AND @report_name IS NULL
	BEGIN
	    SET @sp_name = 'spa_calc_explain_position'
	    IF @calc_type = 'm'
			SET @report_name = 'MTM Explain Report'
		ELSE 
			SET @report_name = 'Position Explain Report'
	END
	
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)   
	EXEC(@str_batch_table)
	
	SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(),@sp_name, @report_name)		
	EXEC(@str_batch_table)  
	      
	goto exeit_proc
	--RETURN
END
ELSE IF @run_mode = 1 OR @run_mode = 0
BEGIN
	SET @user_login_id = dbo.FNADBUser()
	IF @calc_type = 'm'
		SET @report_name = 'MTM Explain Report'
	ELSE 
		SET @report_name = 'Position Explain Report'
		
	EXEC spa_message_board 'i', @user_login_id,NULL,@report_name,'Calculation is done successfully',NULL,NULL, 's'
		
END


--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
	SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	EXEC(@sql_paging)
END
/*******************************************2nd Paging Batch END*****************************/

DECLARE @e_time_s INT 
DECLARE @e_time_text_s VARCHAR(100)
SET @e_time_s = DATEDIFF(ss,@begin_time,GETDATE())
SET @e_time_text_s = CAST(CAST(@e_time_s/60 AS INT) AS VARCHAR) + ' Mins ' + CAST(@e_time_s - CAST(@e_time_s/60 AS INT) * 60 AS VARCHAR) + ' Secs'
IF @calc_type = 'p'
BEGIN
	SET @job_name = 'Position Explain Calculation' + @process_id
	SET @desc = 'Position Explain Calculation completed Successfully ' + 
			' [Elapse time: ' + @e_time_text_s + ']' 
	EXEC  spa_message_board 'i', @user_login_id, NULL, 'Position Explain Calculation ', @desc, '', '', 's', @job_name,@as_of_date_to, @process_id,NULL,'n',NULL,'y'

END
IF @calc_type = 'm'
BEGIN
	SET @job_name = 'MTM Explain Calculation' + @process_id	
	SET @desc = 'MTM Explain Calculation completed Successfully ' + 
			' [Elapse time: ' + @e_time_text_s + ']' 
	EXEC  spa_message_board 'i', @user_login_id, NULL, 'MTM Explain Calculation ', @desc, '', '', 's', @job_name,@as_of_date_to, @process_id,NULL,'n',NULL,'y'


END

exeit_proc:
exec  dbo.spa_clear_all_temp_table 0,@process_id