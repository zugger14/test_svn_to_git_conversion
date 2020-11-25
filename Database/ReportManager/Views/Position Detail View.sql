BEGIN TRY
		BEGIN TRAN
	
	declare @new_ds_alias varchar(10) = 'SPDV019'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'SPDV019' and name <> 'Position Detail View')
	begin
		select top 1 @new_ds_alias = 'SPDV019' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'SPDV019' + cast(s.n as varchar(5))
		where ds.data_source_id is null
			and s.n < 10

		--RAISERROR ('Datasource alias already exists on system.', 16, 1);
	end

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL
	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Position Detail View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'Position Detail View' AND '106500' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], 'Position Detail View' AS [name], @new_ds_alias AS ALIAS, 'Position Detail View' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'1' AS [system_defined]
			,'106500' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = 'Position Detail View'
	, [tsql] = CAST('' AS VARCHAR(MAX)) + '--DECLARE @_contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), ''DEBUG_MODE_ON'')
--SET CONTEXT_INFO @_contextinfo
--SET NOCOUNT off


SET NOCOUNT on
DECLARE @_summary_option CHAR(6) =null --''h'' --''m'' --''x'' --''y'' -- ''m'' --''d'' -------  ''d'' Detail, ''h'' =hourly,''x''/''y'' = 15/30 minute, q=quatar, a=annual
	,@_sub_id VARCHAR(MAX) = NULL
	,@_stra_id VARCHAR(MAX) = NULL
	,@_book_id VARCHAR(MAX) = null
	,@_subbook_id VARCHAR(MAX) = NULL
	,@_as_of_date VARCHAR(20) =null --''2018-01-01'' --''2020-09-07'' --''2020-06-30''
	,@_source_deal_header_id VARCHAR(1000) = null --80150 -- 45871 --540 -- --223683,
	,@_period_from VARCHAR(6) = NULL
	,@_period_to VARCHAR(6) = NULL
	,@_tenor_option VARCHAR(6) = NULL
	,@_location_id VARCHAR(1000) = NULL
	,@_curve_id VARCHAR(1000) = NULL
	,@_commodity_id VARCHAR(MAX) = NULL
	,@_deal_id VARCHAR(1000) = NULL
	,@_location_group_id VARCHAR(1000) = NULL
	,@_grid VARCHAR(1000) = NULL
	,@_country VARCHAR(1000) = NULL
	,@_region VARCHAR(MAX) = NULL
	,@_province VARCHAR(1000) = NULL
	,@_deal_status VARCHAR(8) = NULL
	,@_confirm_status VARCHAR(8) = NULL
	,@_profile VARCHAR(8) = NULL
	,@_term_start VARCHAR(20) =null --''2018-10-27'' -- ''2021-10-30''
	,@_term_end VARCHAR(20) =null --''2018-10-28'' -- ''2021-12-01''
	,@_deal_type VARCHAR(MAX) = NULL
	,@_deal_sub_type VARCHAR(MAX) = NULL
	,@_buy_sell_flag VARCHAR(6)
	,@_counterparty VARCHAR(MAX) = NULL
	,@_hour_from VARCHAR(6) = NULL
	,@_hour_to VARCHAR(6) = NULL
	,@_block_group VARCHAR(10) = NULL
	,@_parent_counterparty VARCHAR(10) = NULL
	,@_deal_date_from VARCHAR(20) = NULL
	,@_deal_date_to VARCHAR(20) = NULL
	,@_block_type_group_id VARCHAR(20) = NULL
	,@_trader_id VARCHAR(20) = NULL
	,@_convert_to_uom_id VARCHAR(20) =null -- 1159
	,@_physical_financial_flag VARCHAR(6)
	,@_include_actuals_from_shape VARCHAR(6)
	,@_leg VARCHAR(6)
	,@_deal_status_group VARCHAR(4) = NULL
	,@_show_delta_volume CHAR(1) = null
	,@_include_storage CHAR(1) = ''y''
	,@_storage_deals VARCHAR(MAX)=NULL
	,@_proxy_curve_view CHAR(1)
    ,@_pricing_type VARCHAR(1000)
	,@_product_group VARCHAR(1000)
DECLARE @_reporting_group1 VARCHAR(1000)
DECLARE @_reporting_group2 VARCHAR(1000)
DECLARE @_reporting_group3 VARCHAR(1000)
DECLARE @_reporting_group4 VARCHAR(1000)
DECLARE @_reporting_group5 VARCHAR(1000)
DECLARE @_dst_group_value_id INT
SELECT @_dst_group_value_id = tz.dst_group_value_id FROM dbo.adiha_default_codes_values adcv
		INNER JOIN time_zones tz ON tz.timezone_id = adcv.var_value
	WHERE adcv.instance_no = 1
		AND adcv.default_code_id = 36
		AND adcv.seq_no = 1
SET @_summary_option = nullif(isnull(@_summary_option, nullif(''@summary_option'', replace(''@_summary_option'', ''@_'', ''@''))), ''null'')
SET @_proxy_curve_view = nullif(isnull(@_proxy_curve_view,nullif(''@proxy_curve_view'', replace(''@_proxy_curve_view'',''@_'',''@''))),''null'')
SET @_sub_id = nullif(isnull(@_sub_id, nullif(''@sub_id'', replace(''@_sub_id'', ''@_'', ''@''))), ''null'')
SET @_stra_id = nullif(isnull(@_stra_id, nullif(''@stra_id'', replace(''@_stra_id'', ''@_'', ''@''))), ''null'')
SET @_book_id = nullif(isnull(@_book_id, nullif(''@book_id'', replace(''@_book_id'', ''@_'', ''@''))), ''null'')
SET @_subbook_id = nullif(isnull(@_subbook_id, nullif(''@sub_book_id'', replace(''@_sub_book_id'', ''@_'', ''@''))), ''null'')
SET @_as_of_date = nullif(isnull(@_as_of_date, nullif(''@as_of_date'', replace(''@_as_of_date'', ''@_'', ''@''))), ''null'')
SET @_source_deal_header_id = nullif(isnull(@_source_deal_header_id, nullif(''@source_deal_header_id'', replace(''@_source_deal_header_id'', ''@_'', ''@''))), ''null'')
SET @_period_from = nullif(isnull(@_period_from, nullif(''@period_from'', replace(''@_period_from'', ''@_'', ''@''))), ''null'')
SET @_period_to = nullif(isnull(@_period_to, nullif(''@period_to'', replace(''@_period_to'', ''@_'', ''@''))), ''null'')
SET @_tenor_option = nullif(isnull(@_tenor_option, nullif(''@tenor_option'', replace(''@_tenor_option'', ''@_'', ''@''))), ''null'')
SET @_location_id = nullif(isnull(@_location_id, nullif(''@location_id'', replace(''@_location_id'', ''@_'', ''@''))), ''null'')
SET @_curve_id = nullif(isnull(@_curve_id, nullif(''@index_id'', replace(''@_index_id'', ''@_'', ''@''))), ''null'')
SET @_commodity_id = nullif(isnull(@_commodity_id, nullif(''@commodity_id'', replace(''@_commodity_id'', ''@_'', ''@''))), ''null'')
SET @_location_group_id = nullif(isnull(@_location_group_id, nullif(''@location_group_id'', replace(''@_location_group_id'', ''@_'', ''@''))), ''null'')
SET @_grid = nullif(isnull(@_grid, nullif(''@grid_id'', replace(''@_grid_id'', ''@_'', ''@''))), ''null'')
SET @_country = nullif(isnull(@_country, nullif(''@country_id'', replace(''@_country_id'', ''@_'', ''@''))), ''null'')
SET @_region = nullif(isnull(@_region, nullif(''@region_id'', replace(''@_region_id'', ''@_'', ''@''))), ''null'')
SET @_province = nullif(isnull(@_province, nullif(''@province_id'', replace(''@_province_id'', ''@_'', ''@''))), ''null'')
SET @_deal_status = nullif(isnull(@_deal_status, nullif(''@deal_status_id'', replace(''@_deal_status_id'', ''@_'', ''@''))), ''null'')
SET @_confirm_status = nullif(isnull(@_confirm_status, nullif(''@confirm_status_id'', replace(''@_confirm_status_id'', ''@_'', ''@''))), ''null'')
SET @_profile = nullif(isnull(@_profile, nullif(''@profile_id'', replace(''@_profile_id'', ''@_'', ''@''))), ''null'')
SET @_term_start = nullif(isnull(@_term_start, nullif(''@term_start'', replace(''@_term_start'', ''@_'', ''@''))), ''null'')
SET @_term_end = nullif(isnull(@_term_end, nullif(''@term_end'', replace(''@_term_end'', ''@_'', ''@''))), ''null'')
SET @_deal_type = nullif(isnull(@_deal_type, nullif(''@deal_type_id'', replace(''@_deal_type_id'', ''@_'', ''@''))), ''null'')
SET @_deal_sub_type = nullif(isnull(@_deal_sub_type, nullif(''@deal_sub_type_id'', replace(''@_deal_sub_type_id'', ''@_'', ''@''))), ''null'')
SET @_buy_sell_flag = nullif(isnull(@_buy_sell_flag, nullif(''@buy_sell_flag'', replace(''@_buy_sell_flag'', ''@_'', ''@''))), ''null'')
SET @_counterparty = nullif(isnull(@_counterparty, nullif(''@counterparty_id'', replace(''@_counterparty_id'', ''@_'', ''@''))), ''null'')
SET @_hour_from = nullif(isnull(@_hour_from, nullif(''@hour_from'', replace(''@_hour_from'', ''@_'', ''@''))), ''null'')
SET @_hour_to = nullif(isnull(@_hour_to, nullif(''@hour_to'', replace(''@_hour_to'', ''@_'', ''@''))), ''null'')
SET @_block_group = nullif(isnull(@_block_group, nullif(''@block_group'', replace(''@_block_group'', ''@_'', ''@''))), ''null'')
SET @_parent_counterparty = nullif(isnull(@_parent_counterparty, nullif(''@parent_counterparty'', replace(''@_parent_counterparty'', ''@_'', ''@''))), ''null'')
SET @_deal_date_from = nullif(isnull(@_deal_date_from, nullif(''@deal_date_from'', replace(''@_deal_date_from'', ''@_'', ''@''))), ''null'')
SET @_deal_date_to = nullif(isnull(@_deal_date_to, nullif(''@deal_date_to'', replace(''@_deal_date_to'', ''@_'', ''@''))), ''null'')
SET @_block_type_group_id = nullif(isnull(@_block_type_group_id, nullif(''@block_type_group_id'', replace(''@_block_type_group_id'', ''@_'', ''@''))), ''null'')
SET @_deal_id = nullif(isnull(@_deal_id, nullif(''@deal_id'', replace(''@_deal_id'', ''@_'', ''@''))), ''null'')
SET @_trader_id = nullif(isnull(@_trader_id, nullif(''@trader_id'', replace(''@_trader_id'', ''@_'', ''@''))), ''null'')
SET @_convert_to_uom_id = nullif(isnull(@_convert_to_uom_id, nullif(''@convert_to_uom_id'', replace(''@_convert_to_uom_id'', ''@_'', ''@''))), ''null'')
SET @_physical_financial_flag = nullif(isnull(@_physical_financial_flag, nullif(''@physical_financial_flag'', replace(''@_physical_financial_flag'', ''@_'', ''@''))), ''null'')
SET @_include_actuals_from_shape = nullif(isnull(@_include_actuals_from_shape, nullif(''@include_actuals_from_shape'', replace(''@_include_actuals_from_shape'', ''@_'', ''@''))), ''null'')
SET @_leg = nullif(isnull(@_leg, nullif(''@leg'', replace(''@_leg'', ''@_'', ''@''))), ''null'')
SET @_deal_status_group = nullif(isnull(@_deal_status_group, nullif(''@deal_status_group'', replace(''@_deal_status_group'', ''@_'', ''@''))), ''null'')
SET @_show_delta_volume = nullif(isnull(@_show_delta_volume, nullif(''@show_delta_volume'', replace(''@_show_delta_volume'', ''@_'', ''@''))), ''null'')
--IF ''@physical_financial_flag'' <> ''NULL''
--	SET @_physical_financial_flag =''@physical_financial_flag''
--IF ''@include_actuals_from_shape'' <> ''NULL''
--	SET @_include_actuals_from_shape = ''@include_actuals_from_shape''
SET @_deal_status_group = isnull(@_deal_status_group, ''a'') 
SET @_physical_financial_flag = isnull(@_physical_financial_flag, ''b'')
SET @_show_delta_volume = isnull(@_show_delta_volume, ''n'')
SET @_include_storage = NULLIF(  ISNULL(@_include_storage,NULLIF(''@include_storage'', replace(''@_include_storage'',''@_'',''@''))),''n'')
SET @_pricing_type = NULLIF(ISNULL(@_pricing_type, NULLIF(''@pricing_type'', REPLACE(''@_pricing_type'', ''@_'', ''@''))), ''NULL'')
SET @_product_group = NULLIF(ISNULL(@_product_group, NULLIF(''@product_group'', REPLACE(''@_product_group'', ''@_'', ''@''))), ''NULL'')
SET @_reporting_group1 = NULLIF(ISNULL(@_reporting_group1, NULLIF(''@reporting_group1'', REPLACE(''@_reporting_group1'', ''@_'', ''@''))), ''NULL'')
SET @_reporting_group2 = NULLIF(ISNULL(@_reporting_group2, NULLIF(''@reporting_group2'', REPLACE(''@_reporting_group2'', ''@_'', ''@''))), ''NULL'')
SET @_reporting_group3 = NULLIF(ISNULL(@_reporting_group3, NULLIF(''@reporting_group3'', REPLACE(''@_reporting_group3'', ''@_'', ''@''))), ''NULL'')
SET @_reporting_group4 = NULLIF(ISNULL(@_reporting_group4, NULLIF(''@reporting_group4'', REPLACE(''@_reporting_group4'', ''@_'', ''@''))), ''NULL'')
SET @_reporting_group5 = NULLIF(ISNULL(@_reporting_group5, NULLIF(''@reporting_group5'', REPLACE(''@_reporting_group5'', ''@_'', ''@''))), ''NULL'')
DECLARE @_format_option CHAR(1) = ''r''
	,@_group_by CHAR(1) = ''i''
	,-- ''i''- Index, ''l'' - Location   
	@_round_value CHAR(1) = ''8''
	--,@_convert_uom INT = NULL
	,@_col_7_to_6 VARCHAR(1) = ''n''
	,@_include_no_breakdown VARCHAR(1) = ''n''
	,@_sql_select VARCHAR(MAX)
	,@_report_type INT
	,@_storage_inventory_sub_type_id INT
	,@_sel_sql VARCHAR(1000)
	,@_group_sql VARCHAR(200)
	,@_block_sql VARCHAR(100)
	,@_col_name VARCHAR(20)
	,@_frequency VARCHAR(20)
	,@_term_END_parameter VARCHAR(100)
	,@_term_start_parameter VARCHAR(100)
	,@_actual_summary_option CHAR(1)
	,@_hour_pivot_table VARCHAR(100)
	,@_position_deal VARCHAR(250)
	,@_position_no_breakdown VARCHAR(250)
	,@_remain_month VARCHAR(1000)
	,@_column_level VARCHAR(100)
	,@_temp_process_id VARCHAR(100)
	,@_sql_final VARCHAR(MAX)



IF object_id(''tempdb..#temp_deals'') IS NOT NULL
	DROP TABLE #temp_deals
IF object_id(''tempdb..#source_deal_header_id'') IS NOT NULL
	DROP TABLE #source_deal_header_id
IF object_id(''tempdb..#term_date'') IS NOT NULL
	DROP TABLE #term_date
IF object_id(''tempdb..#minute_break'') IS NOT NULL
	DROP TABLE #minute_break
IF object_id(''tempdb..#books'') IS NOT NULL
	DROP TABLE #books
IF object_id(''tempdb..#unit_conversion'') IS NOT NULL
	DROP TABLE #unit_conversion
IF object_id(''tempdb..#deal_summary'') IS NOT NULL
	DROP TABLE #deal_summary
IF object_id(''tempdb..#proxy_term'') IS NOT NULL
	DROP TABLE #proxy_term
IF object_id(''tempdb..#proxy_term_summary'') IS NOT NULL
	DROP TABLE #proxy_term_summary
IF object_id(''tempdb..#tmp_pos_detail_gas'') IS NOT NULL
	DROP TABLE #tmp_pos_detail_gas
IF object_id(''tempdb..#tmp_pos_detail_power'') IS NOT NULL
	DROP TABLE #tmp_pos_detail_power
IF object_id(''tempdb..#unit_conversion'') IS NOT NULL
	DROP TABLE #unit_conversion
IF object_id(''tempdb..#unpvt'') IS NOT NULL
	DROP TABLE #unpvt
IF OBJECT_ID(''tempdb..#injection_withdrawal_deals'') IS NOT NULL 
	DROP TABLE #injection_withdrawal_deals
IF OBJECT_ID(''tempdb..#tmp_pos_detail_torage'') IS NOT NULL 
	DROP TABLE #tmp_pos_detail_torage
IF OBJECT_ID(''tempdb..#density_multiplier'') IS NOT NULL 
	DROP TABLE #density_multiplier
IF OBJECT_ID(''tempdb..#period_display_format'') IS NOT NULL
	DROP TABLE #period_display_format
IF OBJECT_ID(''tempdb..#tmp_delta_0'') IS NOT NULL
	DROP TABLE #tmp_delta_0
--SELECT * FROM REPORT_hourly_position_deal where source_deal_header_id=46750
--SELECT * FROM REPORT_hourly_position_financial where source_deal_header_id=46750
---START Batch initilization--------------------------------------------------------
--------------------------------------------------------------------------------------
DECLARE @_forward_storage_inventory_template_id VARCHAR(10) , @_actual_storage_inventory_template_id VARCHAR(10) , @_storage_inj_wthd_template_id VARCHAR(100) 
select @_forward_storage_inventory_template_id=template_id
from source_deal_header_template where template_name in (''Forward Storage Inventory'')
select @_actual_storage_inventory_template_id=template_id
from source_deal_header_template where template_name in (''Actual Storage Inventory'')
select @_storage_inj_wthd_template_id=isnull(@_storage_inj_wthd_template_id+'','','''')+cast(template_id as varchar)
from source_deal_header_template where template_name in (''Storage Injection'',''Storage Withdrawal'')
set @_forward_storage_inventory_template_id=isnull(nullif(@_forward_storage_inventory_template_id,''''),''-99999'')
set @_actual_storage_inventory_template_id=isnull(nullif(@_actual_storage_inventory_template_id,''''),''-99999'')
set @_storage_inj_wthd_template_id=isnull(nullif(@_storage_inj_wthd_template_id,''''),''-99999'')
DECLARE @_sqry2 VARCHAR(MAX)
DECLARE @_user_login_id VARCHAR(50)
	,@_hypo_breakdown VARCHAR(MAX)
	,@_hypo_breakdown1 VARCHAR(MAX)
	,@_hypo_breakdown2 VARCHAR(MAX)
	,@_hypo_breakdown3 VARCHAR(MAX)
DECLARE @_baseload_block_type VARCHAR(10)
DECLARE @_baseload_block_define_id VARCHAR(10)
CREATE TABLE #source_deal_header_id (source_deal_header_id VARCHAR(200) COLLATE DATABASE_DEFAULT)
DECLARE @_view_nameq VARCHAR(100)
	,@_volume_clm VARCHAR(MAX)
	,@_view_name1 VARCHAR(100)
DECLARE @_dst_column VARCHAR(2000)
	,@_vol_multiplier VARCHAR(2000)
	,@_rhpb VARCHAR(MAX)
	,@_rhpb1 VARCHAR(MAX)
	,@_rhpb2 VARCHAR(MAX)
	,@_rhpb3 VARCHAR(MAX)
	,@_rhpb4 VARCHAR(MAX)
	,@_rhpba1 VARCHAR(MAX)
	,@_rhpb5 VARCHAR(MAX) = ''''
	,@_sqry VARCHAR(MAX)
	,@_scrt VARCHAR(max)
	,@_sqry1 VARCHAR(MAX)
	,@_rpn VARCHAR(MAX)
	,@_rpn1 VARCHAR(MAX)
	,@_rpn2 VARCHAR(MAX)
	,@_rpn3 VARCHAR(MAX)
DECLARE @_commodity_str VARCHAR(max)
	,@_rhpb_0 VARCHAR(max)
	,@_commodity_str1 VARCHAR(max)
DECLARE @_std_whatif_deals VARCHAR(250)
	,@_hypo_deal_header VARCHAR(250)
	,@_hypo_deal_detail VARCHAR(250)
	,@_position_hypo VARCHAR(250) --, @_position_breakdown varchar(250)
CREATE TABLE #unit_conversion (
	convert_from_uom_id INT
	,convert_to_uom_id INT
	,conversion_factor NUMERIC(38, 20)
	)
INSERT INTO #unit_conversion (
	convert_from_uom_id
	,convert_to_uom_id
	,conversion_factor
	)
SELECT from_source_uom_id
	,to_source_uom_id
	,conversion_factor
FROM rec_volume_unit_conversion
WHERE state_value_id IS NULL
	AND curve_id IS NULL
	AND assignment_type_value_id IS NULL
	AND to_curve_id IS NULL
SET @_temp_process_id = dbo.FNAGetNewID()
SET @_user_login_id = dbo.FNADBUser()
-- If group by proxy curvem set group by =''l'' and assign another variable
--SET @_proxy_curve_view = ''n''
IF @_group_by = ''p''
BEGIN
	SET @_group_by = ''i''
	SET @_proxy_curve_view = ''y''
END
SET @_hour_pivot_table = dbo.FNAProcessTableName(''hour_pivot'', @_user_login_id, @_temp_process_id)
SET @_position_deal = dbo.FNAProcessTableName(''position_deal'', @_user_login_id, @_temp_process_id)
SET @_position_no_breakdown = dbo.FNAProcessTableName(''position_no_breakdown'', @_user_login_id, @_temp_process_id)
--SET @_position_breakdown=dbo.FNAProcessTableName(''position_breakdown'', @_user_login_id,@_temp_process_id)  
IF @_summary_option IN ( ''y'' ,''x'' )
SET @_round_value = ''8''
SET @_baseload_block_type = ''12000'' -- Internal Static Data
SELECT @_baseload_block_define_id = CAST(value_id AS VARCHAR(10))
FROM static_data_value
WHERE [TYPE_ID] = 10018
	AND code LIKE ''Base Load'' -- External Static Data
IF @_baseload_block_define_id IS NULL
	SET @_baseload_block_define_id = ''NULL''
IF @_hour_from IS NOT NULL
BEGIN
	IF @_hour_to IS NULL
		SET @_hour_to = @_hour_from
END
ELSE
BEGIN
	IF @_hour_to IS NOT NULL
		SET @_hour_from = @_hour_to
END
IF NULLIF(@_format_option, '''') IS NULL
	SET @_format_option = ''c''
DECLARE @_term_start_temp DATETIME
	,@_term_END_temp DATETIME
CREATE TABLE #temp_deals (term_start date,term_end date, source_deal_detail_id int,source_deal_header_id int,physical_financial CHAR(1) COLLATE DATABASE_DEFAULT, pricing_type INT, internal_portfolio_id INT,template_id int, internal_deal_type_value_id int, internal_deal_subtype_value_id int
)
--print @_term_start
--print @_as_of_date
IF @_period_from IS NOT NULL
	AND @_period_to IS NULL
	SET @_period_to = @_period_from
IF @_period_from IS NULL
	AND @_period_to IS NOT NULL
	SET @_period_from = @_period_to
IF nullif(@_period_from, ''1900'') IS NOT NULL
BEGIN
	--	select  dbo.FNAGetTermStartDate(''m'', convert(varchar(8),isnull(@_term_start,@_as_of_date),120)+''01'', cast(@_period_from as int))
	SET @_term_start_temp = dbo.FNAGetTermStartDate(''m'', convert(VARCHAR(8), isnull(@_term_start, @_as_of_date), 120) + ''01'', cast(@_period_from AS INT))
END
IF nullif(@_period_to, ''1900'') IS NOT NULL
BEGIN
	--print convert(varchar(8),isnull(@_term_start,@_as_of_date),120)+''01''
	---select dbo.FNAGetTermStartDate(''m'',convert(varchar(8),isnull(@_term_start,@_as_of_date),120)+''01'', cast(@_period_to as int)+1)
	SET @_term_END_temp = dbo.FNAGetTermStartDate(''m'', convert(VARCHAR(8), isnull(@_term_start, @_as_of_date), 120) + ''01'', cast(@_period_to AS INT) + 1)
	SET @_term_END_temp = dateadd(DAY, - 1, @_term_END_temp)
END
SET @_term_start = convert(VARCHAR(20), isnull(@_term_start_temp, @_term_start), 120)
SET @_term_end = convert(VARCHAR(20), isnull(@_term_END_temp, @_term_end), 120)
--select @_term_start,@_term_end
IF @_term_start IS NOT NULL
	AND @_term_END IS NULL
	SET @_term_END = @_term_start
IF @_term_start IS NULL
	AND @_term_END IS NOT NULL
	SET @_term_start = @_term_END
IF @_deal_date_from IS NOT NULL
	AND @_deal_date_to IS NULL
	SET @_deal_date_to = @_deal_date_from
IF @_deal_date_from IS NULL
	AND @_deal_date_to IS NOT NULL
	SET @_deal_date_from = @_deal_date_to
SELECT rowid,clm_name, is_dst, alias_name, RIGHT(''0'' + CAST(LEFT(clm_name, 2) + 1 AS VARCHAR(10)), 2) + ''_'' + RIGHT(clm_name, 2) [process_clm_name]
INTO #period_display_format
FROM dbo.FNAGetPivotGranularityColumn(@_term_start,@_term_end,case @_summary_option when ''h'' then 982 when ''x'' then 987 when ''y'' then 989 else null end,@_dst_group_value_id) 
where 1= case when @_summary_option in ( ''h'',''x'',''y'') then 1 else 0 end
--select * from static_data_value where type_id= 978
----print ''CREATE TABLE #books ( fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)    ''
CREATE TABLE #books (
	fas_book_id INT
	,source_system_book_id1 INT
	,source_system_book_id2 INT
	,source_system_book_id3 INT
	,source_system_book_id4 INT
	)  
SET @_Sql_Select = 
''  INSERT INTO #books
SELECT DISTINCT book.entity_id
	,ssbm.source_system_book_id1
	,ssbm.source_system_book_id2
	,ssbm.source_system_book_id3
	,ssbm.source_system_book_id4 fas_book_id
FROM portfolio_hierarchy book(NOLOCK)
INNER JOIN Portfolio_hierarchy stra(NOLOCK) ON book.parent_entity_id = stra.entity_id
INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id
WHERE ( fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401 )  '' 
+case when @_as_of_date is null then '' and 1=2'' else '''' end
IF @_sub_id IS NOT NULL
	SET @_Sql_Select = @_Sql_Select + '' AND stra.parent_entity_id IN  ( '' + @_sub_id + '') ''
IF @_stra_id IS NOT NULL
	SET @_Sql_Select = @_Sql_Select + '' AND (stra.entity_id IN('' + @_stra_id + '' ))''
IF @_book_id IS NOT NULL
	SET @_Sql_Select = @_Sql_Select + '' AND (book.entity_id IN('' + @_book_id + '')) ''
IF @_subbook_id IS NOT NULL
	SET @_Sql_Select = @_Sql_Select + '' AND ssbm.book_deal_type_map_id IN ('' + @_subbook_id + '' ) ''
EXEC spa_print @_Sql_Select   
EXEC (@_Sql_Select)
CREATE INDEX [IX_Book] ON [#books] ([fas_book_id])     
set @_as_of_date=isnull(@_as_of_date,''9999-01-01'')
SET @_Sql_Select = ''
	INSERT INTO #temp_deals (term_start,term_end, source_deal_detail_id,source_deal_header_id,physical_financial, pricing_type, internal_portfolio_id,template_id,internal_deal_type_value_id,internal_deal_subtype_value_id)
SELECT 
sdd.term_start,sdd.term_end, sdd.source_deal_detail_id,
sdh.source_deal_header_id,sdh.physical_financial_flag, sdh.pricing_type, sdh.internal_portfolio_id,sdh.template_id
,sdh.internal_deal_type_value_id,sdh.internal_deal_subtype_value_id
FROM dbo.source_deal_header sdh
INNER JOIN #books b ON sdh.source_system_book_id1 = b.source_system_book_id1
	AND sdh.source_system_book_id2 = b.source_system_book_id2
	AND sdh.source_system_book_id3 = b.source_system_book_id3
	AND sdh.source_system_book_id4 = b.source_system_book_id4
	and sdh.template_id<>''+@_forward_storage_inventory_template_id+''
inner join dbo.source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
WHERE 1=1  '' --sdh.source_deal_type_id <> 1177
	+ CASE 
	WHEN @_source_deal_header_id IS NOT NULL
		THEN '' and sdh.source_deal_header_id in ('' + @_source_deal_header_id + '')''
	ELSE ''''
	END + CASE 
	WHEN @_deal_id IS NOT NULL
		THEN '' and sdh.deal_id LIKE ''''%'' + @_deal_id + ''%''''''
	ELSE ''''
	END + CASE 
	WHEN @_confirm_status IS NOT NULL
		THEN '' and sdh.confirm_status_type in ('' + @_confirm_status + '')''
	ELSE ''''
	END + CASE 
	WHEN @_profile IS NOT NULL
		THEN '' and sdh.internal_desk_id in ('' + @_profile + '')''
	ELSE ''''
	END + CASE 
	WHEN @_deal_type IS NOT NULL
		THEN '' and sdh.source_deal_type_id IN ('' + @_deal_type + '')'' 
	ELSE ''''
	END + CASE 
	WHEN @_deal_sub_type IS NOT NULL
		THEN '' and sdh.deal_sub_type_type_id in ('' + @_deal_sub_type + '')''
	ELSE ''''
	END + CASE 
	WHEN @_counterparty IS NOT NULL
		THEN '' AND sdh.counterparty_id IN ('' + @_counterparty + '')''
	ELSE ''''
	END + CASE 
	WHEN @_trader_id IS NOT NULL
		THEN '' AND sdh.trader_id IN ('' + @_trader_id + '')''
	ELSE ''''
	END + CASE 
	WHEN @_deal_status IS NOT NULL
		THEN '' AND sdh.deal_status IN('' + @_deal_status + '')''
	ELSE ''''
	END + CASE 
	WHEN @_deal_date_from IS NOT NULL
		THEN '' AND sdh.deal_date>='''''' + @_deal_date_from + '''''' AND sdh.deal_date<='''''' + @_deal_date_to + ''''''''
	ELSE ''''
	END + CASE 
	WHEN @_as_of_date IS NOT NULL 
		THEN '' AND ((sdh.deal_date<=''''''+convert(varchar(10),@_as_of_date,120) +'''''' AND ISNULL(sdh.internal_deal_type_value_id,-1) NOT IN(15)) OR ISNULL(sdh.internal_deal_type_value_id,-1) IN(15))'' 
	ELSE '''' 
	END + CASE 
	WHEN @_pricing_type IS NOT NULL
		THEN '' AND sdh.pricing_type IN ('' + @_pricing_type + '')''
	ELSE ''''
	END + CASE 
	WHEN @_product_group IS NOT NULL
		THEN '' AND sdh.internal_portfolio_id IN ('' + @_product_group + '')''
	ELSE ''''
	END
	+ CASE WHEN @_reporting_group1 IS NULL THEN '''' ELSE '' AND sdh.reporting_group1 = '''''' + @_reporting_group1 + '''''''' END
	+ CASE WHEN @_reporting_group2 IS NULL THEN '''' ELSE '' AND sdh.reporting_group2 = '''''' + @_reporting_group2 + '''''''' END
	+ CASE WHEN @_reporting_group3 IS NULL THEN '''' ELSE '' AND sdh.reporting_group3 = '''''' + @_reporting_group3 + '''''''' END
	+ CASE WHEN @_reporting_group4 IS NULL THEN '''' ELSE '' AND sdh.reporting_group4 = '''''' + @_reporting_group4 + '''''''' END
	+ CASE WHEN @_reporting_group5 IS NULL THEN '''' ELSE '' AND sdh.reporting_group5 = '''''' + @_reporting_group5 + '''''''' END
EXEC spa_print @_Sql_Select   
EXEC ( @_Sql_Select)  
IF OBJECT_ID(N''tempdb..#temp_block_type_group_table'') IS NOT NULL
	DROP TABLE #temp_block_type_group_table
CREATE TABLE #temp_block_type_group_table (
	block_type_group_id INT
	,block_type_id INT
	,block_name VARCHAR(200) COLLATE DATABASE_DEFAULT
	,hourly_block_id INT
	)
IF (@_block_type_group_id IS NOT NULL)	
	SET @_Sql_Select = ''INSERT INTO #temp_block_type_group_table (
		block_type_group_id
		,block_type_id
		,block_name
		,hourly_block_id
	)
	SELECT block_type_group_id
		,block_type_id
		,block_name
		,hourly_block_id
	FROM block_type_group
	WHERE block_type_group_id = '' + CAST(@_block_type_group_id AS VARCHAR(100))
ELSE 
	SET @_Sql_Select =''INSERT INTO #temp_block_type_group_table (
		block_type_group_id
		,block_type_id
		,block_name
		,hourly_block_id
	)
	SELECT NULL block_type_group_id
		,NULL block_type_id
		,NULL block_name
		,''+@_baseload_block_define_id+'' hourly_block_id''
EXEC spa_print @_Sql_Select
EXEC (@_Sql_Select)
CREATE TABLE #term_date (
	block_define_id INT
	,term_date DATE
	,term_start DATE
	,term_end DATE
	,hr1 TINYINT
	,hr2 TINYINT
	,hr3 TINYINT
	,hr4 TINYINT
	,hr5 TINYINT
	,hr6 TINYINT
	,hr7 TINYINT
	,hr8 TINYINT
	,hr9 TINYINT
	,hr10 TINYINT
	,hr11 TINYINT
	,hr12 TINYINT
	,hr13 TINYINT
	,hr14 TINYINT
	,hr15 TINYINT
	,hr16 TINYINT
	,hr17 TINYINT
	,hr18 TINYINT
	,hr19 TINYINT
	,hr20 TINYINT
	,hr21 TINYINT
	,hr22 TINYINT
	,hr23 TINYINT
	,hr24 TINYINT
	,add_dst_hour INT
)


INSERT INTO #term_date (
	block_define_id
	,term_date
	,term_start
	,term_end
	,hr1
	,hr2
	,hr3
	,hr4
	,hr5
	,hr6
	,hr7
	,hr8
	,hr9
	,hr10
	,hr11
	,hr12
	,hr13
	,hr14
	,hr15
	,hr16
	,hr17
	,hr18
	,hr19
	,hr20
	,hr21
	,hr22
	,hr23
	,hr24
	,add_dst_hour
	)
SELECT DISTINCT a.block_define_id
	,hb.term_date
	,a.term_start
	,a.term_end
	,hb.hr1
	,hb.hr2
	,hb.hr3
	,hb.hr4
	,hb.hr5
	,hb.hr6
	,hb.hr7
	,hb.hr8
	,hb.hr9
	,hb.hr10
	,hb.hr11
	,hb.hr12
	,hb.hr13
	,hb.hr14
	,hb.hr15
	,hb.hr16
	,hb.hr17
	,hb.hr18
	,hb.hr19
	,hb.hr20
	,hb.hr21
	,hb.hr22
	,hb.hr23
	,hb.hr24
	,hb.add_dst_hour
FROM (
	select DISTINCT tz.dst_group_value_id, isnull(spcd.block_define_id, nullif(-10000298, NULL)) block_define_id  
			,s.term_start
			,s.term_end
	FROM report_hourly_position_breakdown s (NOLOCK)
			INNER JOIN #temp_deals td on --s.term_start between td.term_start and td.term_end and
			  td.source_deal_detail_id=s.source_deal_detail_id
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id
			LEFT JOIN source_price_curve_def spcd WITH (NOLOCK) ON spcd.source_curve_def_id = s.curve_id
			LEFT JOIN vwDealTimezone tz ON tz.source_deal_header_id = s.source_deal_header_id
				AND ISNULL(tz.formula_curve_id, - 1) = ISNULL(s.curve_id, - 1)
				--AND ISNULL(tz.location_id, - 1) = ISNULL(s.location_id, - 1)

	) a
OUTER APPLY (
	SELECT h.*
	FROM hour_block_term h WITH (NOLOCK)
	WHERE block_define_id = a.block_define_id
		AND h.block_type = 12000
		AND term_date BETWEEN a.term_start
			AND a.term_end --and term_date>@_as_of_date
		AND h.dst_group_value_id = a.dst_group_value_id
	) hb
CREATE INDEX indxterm_dat ON #term_date (
	block_define_id
	,term_start
	,term_end
	)
----print ''CREATE TABLE #minute_break ( granularity int,period tinyint, factor numeric(2,1))    ''
CREATE TABLE #minute_break (
	granularity INT
	,period TINYINT
	,factor NUMERIC(6, 2)
	)
SET @_summary_option = isnull(nullif(@_summary_option, ''1900''), ''m'')
IF @_summary_option = ''y'' --30 minutes
BEGIN
	--insert into #minute_break ( granularity ,period , factor )   --daily
	--values (981,0,48),(981,30,2)
	INSERT INTO #minute_break (
		granularity
		,period
		,factor
		) --hourly
	VALUES (
		982
		,0
		,2
		)
		,(
		982
		,30
		,2
		)
END
ELSE IF @_summary_option = ''x'' --15 minutes
BEGIN
	--insert into #minute_break ( granularity ,period , factor )   --daily
	--values (981,0,96),(981,15,96),(981,30,96),(981,45,4)
	INSERT INTO #minute_break (
		granularity
		,period
		,factor
		) --hourly
	VALUES (
		982
		,0
		,4
		)
		,(
		982
		,15
		,4
		)
		,(
		982
		,30
		,4
		)
		,(
		982
		,45
		,4
		)
	INSERT INTO #minute_break (
		granularity
		,period
		,factor
		) --30 minute
	VALUES (
		989
		,15
		,2
		)
		,(
		989
		,45
		,2
		)
END
--***************************              
--END of source book map table and build index              
--*****************************     
-- Collect Required Deals  
SET @_view_nameq = ''report_hourly_position_deal''
SET @_view_name1 = ''report_hourly_position''
----print ''-----------------------@_scrt''
SET @_scrt = ''''
SET @_scrt = CASE WHEN @_source_deal_header_id IS NOT NULL
			THEN '' AND s.source_deal_header_id IN ('' + CAST(@_source_deal_header_id AS VARCHAR) + '')''
		ELSE '''' END 
		+ CASE WHEN @_term_start IS NOT NULL
			THEN '' AND s.term_start>='''''' + @_term_start + '''''' AND s.term_start<='''''' + @_term_end + ''''''''
		ELSE '''' END 
		+ CASE WHEN @_commodity_id IS NOT NULL
			THEN '' AND s.commodity_id IN ('' + @_commodity_id + '')''
		ELSE '''' END 
		+ CASE WHEN @_curve_id IS NOT NULL
			THEN '' AND s.curve_id IN ('' + @_curve_id + '')''
		ELSE '''' END 
		+ CASE WHEN @_location_id IS NOT NULL
			THEN '' AND s.location_id IN ('' + @_location_id + '')''
		ELSE '''' END 
		+ CASE WHEN @_tenor_option <> ''a''
			THEN '' AND s.expiration_date>'''''' + @_as_of_date + '''''' AND s.term_start>'''''' + @_as_of_date + ''''''''
		ELSE ''
			 AND ((td.template_id=''+ @_actual_storage_inventory_template_id+'' AND s.expiration_date>'''''' + @_as_of_date + '''''' AND s.term_start>'''''' + @_as_of_date + '''''')
				OR (td.template_id in (''+ @_storage_inj_wthd_template_id+'') AND s.expiration_date>='''''' + @_as_of_date + '''''' AND s.term_start>='''''' + @_as_of_date + '''''')
				or ( not td.template_id in (''+ @_storage_inj_wthd_template_id+'',''+@_actual_storage_inventory_template_id+'') ))''
		END 
		+ CASE WHEN @_physical_financial_flag <> ''b''
			THEN '' AND s.physical_financial_flag='''''' + @_physical_financial_flag + ''''''''
		ELSE '''' END
----print @_scrt
----print ''--------------------------------------------''
---------------------------Start hourly_position_breakdown=null------------------------------------------------------------
if isnull(@_include_no_breakdown,''n'')=''y''
begin
	create table #term_date_no_break( block_define_id int ,term_date date,term_start date,term_end date,
		hr1 tinyint,hr2 tinyint,hr3 tinyint,hr4 tinyint,hr5 tinyint,hr6 tinyint,hr7 tinyint,hr8 tinyint,hr9 tinyint,hr10 tinyint,hr11 tinyint,hr12 tinyint,hr13 tinyint
		,hr14 tinyint,hr15 tinyint,hr16 tinyint,hr17 tinyint,hr18 tinyint,hr19 tinyint,hr20 tinyint,hr21 tinyint,hr22 tinyint,hr23 tinyint,hr24 tinyint,add_dst_hour int,volume_mult int
	)
	set @_rpn=''
		select sdh.source_deal_header_id,sdh.source_system_book_id1,sdh.source_system_book_id2,sdh.source_system_book_id3,sdh.source_system_book_id4
		,sdh.deal_date,sdh.counterparty_id,sdh.deal_status deal_status_id,sdd.curve_id,sdd.location_id,sdd.term_start,sdd.term_end,sdd.total_volume
		,spcd.commodity_id,sdd.physical_financial_flag,sdd.deal_volume_uom_id,bk.fas_book_id,sdd.contract_expiration_date expiration_date,
		isnull(spcd.block_define_id,''+@_baseload_block_define_id+'') block_define_id
		  into ''+ @_position_no_breakdown+''
		from source_deal_header sdh inner join source_deal_header_template sdht on sdh.template_id=sdht.template_id and sdht.hourly_position_breakdown is null
		inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
		inner join #temp_deals td on td.source_deal_detail_id=sdh.source_deal_detail_id
		INNER JOIN [deal_status_group] dsg ON dsg.deal_status_group_id = sdh.deal_status 
		'' +CASE WHEN isnull(@_source_deal_header_id ,-1) <>-1 THEN '' and sdh.source_deal_header_id IN ('' +CAST(@_source_deal_header_id AS VARCHAR) + '')'' ELSE '''' END 
		+''	INNER JOIN #books bk ON bk.source_system_book_id1=sdh.source_system_book_id1 AND bk.source_system_book_id2=sdh.source_system_book_id2 
		AND bk.source_system_book_id3=sdh.source_system_book_id3 AND bk.source_system_book_id4=sdh.source_system_book_id4
		left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=sdd.curve_id 
	''
	----print @_rpn
	exec(@_rpn)
	set @_rpn=''
		insert into #term_date_no_break(block_define_id,term_date,term_start,term_end,
			hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16 ,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,add_dst_hour,volume_mult
		)
		select distinct a.block_define_id,hb.term_date,a.term_start ,a.term_end,
			hb.hr1 ,hb.hr2 ,hb.hr3 ,hb.hr4 ,hb.hr5 ,hb.hr6 ,hb.hr7 ,hb.hr8 
			,hb.hr9 ,hb.hr10 ,hb.hr11 ,hb.hr12 ,hb.hr13 ,hb.hr14 ,hb.hr15 ,hb.hr16 
			,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour,hb.volume_mult
		from ''+@_position_no_breakdown+'' a
		left JOIN  vwDealTimezone tz on tz.source_deal_header_id=a.source_deal_header_id
			AND ISNULL(tz.curve_id,-1)=ISNULL(a.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(a.location_id,-1)
				outer apply	(select h.* from hour_block_term h with (nolock) where block_define_id=a.block_define_id and h.block_type=12000 
				and term_date between a.term_start  and a.term_end --and term_date>''''''+convert(varchar(10),@_as_of_date,120) +''''''
				 and h.dst_group_value_id=tz.dst_group_value_id 
		) hb
		''
	EXEC spa_print @_rpn
	exec(@_rpn)
	create index indxterm_dat_no_break on #term_date_no_break(block_define_id,term_start,term_end)
	SET @_dst_column = ''cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0))''  
	SET @_vol_multiplier=''*cast(cast(s.total_volume as numeric(26,12))/nullif(term_hrs.term_hrs,0) as numeric(28,16))''+case when @_summary_option in (''x'',''y'')  then '' /hrs.factor ''	else '''' end
	SET @_rpn=''Union all
	select s.curve_id,ISNULL(s.location_id,-1) location_id,hb.term_date term_start,''+case when @_summary_option in (''x'',''y'')  then '' hrs.period '' else ''0'' end +'' period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
		,cast(isnull(hb.hr1,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END ''+ @_vol_multiplier +''  AS Hr1
		,cast(isnull(hb.hr2,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr2
		,cast(isnull(hb.hr3,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr3
		,cast(isnull(hb.hr4,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr4
		,cast(isnull(hb.hr5,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr5
		,cast(isnull(hb.hr6,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr6
		,cast(isnull(hb.hr7,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr7
		,cast(isnull(hb.hr8,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr8
		,cast(isnull(hb.hr9,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr9
		,cast(isnull(hb.hr10,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr10
		,cast(isnull(hb.hr11,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr11
		,cast(isnull(hb.hr12,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr12
		,cast(isnull(hb.hr13,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr13''
	SET @_rpn1= '',cast(isnull(hb.hr14,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr14
		,cast(isnull(hb.hr15,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr15
		,cast(isnull(hb.hr16,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr16
		,cast(isnull(hb.hr17,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr17
		,cast(isnull(hb.hr18,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr18
		,cast(isnull(hb.hr19,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr19
		,cast(isnull(hb.hr20,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr20
		,cast(isnull(hb.hr21,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr21
		,cast(isnull(hb.hr22,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr22
		,cast(isnull(hb.hr23,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr23
		,cast(isnull(hb.hr24,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END''+ @_vol_multiplier+''  AS Hr24
		,''+@_dst_column+ @_vol_multiplier+'' AS Hr25 '' 
	SET @_rpn2=
		'',s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date ,''''y'''' AS is_fixedvolume ,deal_status_id 
	from ''+@_position_no_breakdown + '' s inner join #temp_deals td on
		 s.term_start between td.term_start and td.term_end
			 and td.source_deal_detail_id=s.source_deal_detail_id
		 left join #term_date_no_break hb on hb.term_start = s.term_start and hb.term_end=s.term_end  and hb.block_define_id=s.block_define_id''
		+case when @_summary_option in (''x'',''y'')  then 
			'' left join #minute_break hrs on hrs.granularity=982 ''
		else '''' end+''
		outer apply ( select sum(volume_mult) term_hrs from #term_date_no_break h where h.term_start = s.term_start and h.term_end=s.term_end  and h.term_date>'''''' + @_as_of_date +'''''') term_hrs
	    where 1=1'' +@_scrt
		--from demo4
		--+CASE WHEN @_tenor_option <> ''a'' THEN '' AND s.expiration_date>''''''+@_as_of_date+'''''' AND s.term_start>''''''+@_as_of_date+'''''''' ELSE '''' END 
end
	---------------------------end hourly_position_breakdown=null------------------------------------------------------------
if @_physical_financial_flag<>''p'' 
BEGIN 
	SET @_dst_column = ''cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0))''  
	--SET @_remain_month =''*(CASE WHEN YEAR(hb.term_date)=YEAR(DATEADD(m,1,''''''+@_as_of_date+'''''')) AND MONTH(hb.term_date)=MONTH(DATEADD(m,1,''''''+@_as_of_date+'''''')) THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)''            	
	SET @_remain_month =''*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''''+@_as_of_date+'''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''''+@_as_of_date+'''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)''+case when @_summary_option in (''x'',''y'')  then '' /hrs.factor ''	else '''' end    
	--SET @_dst_column=''CASE WHEN (dst.insert_delete)=''''i'''' THEN isnull(CASE dst.hour WHEN 1 THEN hb.hr1 WHEN 2 THEN hb.hr2 WHEN 3 THEN hb.hr3 WHEN 4 THEN hb.hr4 WHEN 5 THEN hb.hr5 WHEN 6 THEN hb.hr6 WHEN 7 THEN hb.hr7 WHEN 8 THEN hb.hr8 WHEN 9 THEN hb.hr9 WHEN 10 THEN hb.hr10 WHEN 11 THEN hb.hr11 WHEN 12 THEN hb.hr12 WHEN 13 THEN hb.hr13 WHEN 14 THEN hb.hr14 WHEN 15 THEN hb.hr15 WHEN 16 THEN hb.hr16 WHEN 17 THEN hb.hr17 WHEN 18 THEN hb.hr18 WHEN 19 THEN hb.hr19 WHEN 20 THEN hb.hr20 WHEN 21 THEN hb.hr21 WHEN 22 THEN hb.hr22 WHEN 23 THEN hb.hr23 WHEN 24 THEN hb.hr24 END,0) END''              	
	SET @_vol_multiplier=''/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))''
	SET @_rhpb=''select s.source_deal_detail_id,s.curve_id,''+ CASE WHEN @_view_name1=''vwHourly_position_AllFilter'' THEN ''-1'' ELSE ''ISNULL(s.location_id,-1)'' END +'' location_id,hb.term_date term_start,''+case when @_summary_option in (''x'',''y'')  then '' hrs.period ''	else ''0'' end +'' period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr1
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr2
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr3
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr4
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr5
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr6
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr7
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr8
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr9
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr10
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr11
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr12
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr13''
	SET @_rhpb1= '',(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr14
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr15
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr16
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr17
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr18
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr19
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr20
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr21
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr22
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr23
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr24
		,(cast(cast(s.calc_volume as numeric(22,10))* ''+@_dst_column+'' as numeric(22,10))) ''+ @_vol_multiplier +@_remain_month+'' AS Hr25 '' 
	SET @_rhpb2=
	'',s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,CASE WHEN s.formula IN(''''dbo.FNACurveH'''',''''dbo.FNACurveD'''') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END expiration_date,''''y'''' AS is_fixedvolume ,deal_status_id,1 breakdown, spcd.block_define_id
			from ''+@_view_name1+''_breakdown s ''+CASE WHEN @_view_nameq=''vwHourly_position_AllFilter'' THEN '' WITH(NOEXPAND) '' ELSE '' (nolock) '' END +'' 
			 inner join #temp_deals td on --s.term_start between td.term_start and td.term_end and 
			 td.source_deal_detail_id=s.source_deal_detail_id
			INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
			'' +CASE WHEN @_source_deal_header_id IS NOT NULL THEN '' and s.source_deal_header_id IN ('' +CAST(@_source_deal_header_id AS VARCHAR) + '')'' ELSE '''' END 
			+''	AND bk.source_system_book_id1=s.source_system_book_id1 AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4 '' 
		+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
		''	INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id '' ELSE '''' END 
		+'' left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
		LEFT JOIN source_price_curve_def spcd1 (nolock) On spcd1.source_curve_def_id=spcd.settlement_curve_id
		left JOIN  vwDealTimezone tz on tz.source_deal_header_id=s.source_deal_header_id
			AND ISNULL(tz.formula_curve_id,-1)=ISNULL(s.curve_id,-1) --AND ISNULL(tz.location_id,-1)=ISNULL(s.location_id,-1)
		outer apply (select sum(volume_mult) term_no_hrs from hour_block_term hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,''+@_baseload_block_define_id+'')	and  hbt.block_type=COALESCE(spcd.block_type,''+@_baseload_block_type+'') and hbt.term_date between s.term_start  and s.term_END and hbt.dst_group_value_id=tz.dst_group_value_id ) term_hrs
		outer apply ( select sum(volume_mult) term_no_hrs from hour_block_term hbt inner join 
		(select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END  ) ex on ex.exp_date=hbt.term_date
		 	and  hbt.dst_group_value_id=tz.dst_group_value_id
		where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,''+@_baseload_block_define_id+'')	and  hbt.block_type=COALESCE(spcd.block_type,''+@_baseload_block_type+'') and hbt.term_date between s.term_start  and s.term_END and hbt.dst_group_value_id=tz.dst_group_value_id) term_hrs_exp
		left join #term_date hb on hb.block_define_id=isnull(spcd.block_define_id,''+@_baseload_block_define_id+'') and hb.term_start = s.term_start
		and hb.term_end=s.term_end  --and hb.term_date>'''''' + @_as_of_date +''''''
		outer apply  (select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
			h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 ) hg   
			outer apply  (select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h where 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''''REBD'''')) hg1   
			outer apply  (select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>''''''+@_as_of_date+'''''' THEN 1 else 0 END) remain_days from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
					AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
					AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''''REBD'''')) remain_month  ''
		+case when @_summary_option in (''x'',''y'')  then 
			'' left join #minute_break hrs on hrs.granularity=982 ''
		else '''' end+''
		    where ((ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''''9999-01-01'''')>''''''+@_as_of_date+'''''') OR COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800)
		    AND ((isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (isnull(spcd.hourly_volume_allocation,17601)<17603 ))		           
		    '' +CASE WHEN @_tenor_option <> ''a'' THEN '' and CASE WHEN s.formula IN(''''dbo.FNACurveH'''',''''dbo.FNACurveD'''') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END>''''''+@_as_of_date+'''''''' ELSE '''' END + 
			@_scrt
END




	--select @_group_by, @_summary_option,@_format_option		
IF  @_summary_option IN (''d'' ,''m'',''q'',''a'')	
--IF  @_summary_option IN (''q'',''a'')
BEGIN
	SET @_volume_clm=''''
	SET @_volume_clm=CASE WHEN @_summary_option = ''m'' THEN ''(''ELSE ''SUM('' END
	IF @_volume_clm IN (''('',''SUM('')
	BEGIN
		SET @_volume_clm=@_volume_clm + ''ROUND(''+ CASE WHEN  @_summary_option = ''m'' THEN ''SUM('' ELSE '''' END +
				''CAST((cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr7 else hb.hr1 end *'' else '''' end +''vw.hr1 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr8 else hb.hr2 end *'' else '''' end +''vw.hr2 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr9 else hb.hr3 end *'' else '''' end +''vw.hr3 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr10 else hb.hr4 end *'' else '''' end +''vw.hr4 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr11 else hb.hr5 end *'' else '''' end +''vw.hr5 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr12 else hb.hr6 end *'' else '''' end +''vw.hr6 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr13 else hb.hr7 end *'' else '''' end +''vw.hr7 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr14 else hb.hr8 end *'' else '''' end +''vw.hr8 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr15 else hb.hr9 end *'' else '''' end +''vw.hr9 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr16 else hb.hr10 end *'' else '''' end +''vw.hr10 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr17 else hb.hr11 end *'' else '''' end +''vw.hr11 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr18 else hb.hr12 end *'' else '''' end +''vw.hr12 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr19 else hb.hr13 end *'' else '''' end +''vw.hr13 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr20 else hb.hr14 end *'' else '''' end +''vw.hr14 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr21 else hb.hr15 end *'' else '''' end +''vw.hr15 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr22 else hb.hr16 end *'' else '''' end +''vw.hr16 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr23 else hb.hr17 end *'' else '''' end +''vw.hr17 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr24 else hb.hr18 end *'' else '''' end +''vw.hr18 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb1.hr1 else hb.hr19 end *'' else '''' end +''vw.hr19 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb1.hr2 else hb.hr20 end *'' else '''' end +''vw.hr20 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb1.hr3 else hb.hr21 end *'' else '''' end +''vw.hr21 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb1.hr4 else hb.hr22 end *'' else '''' end +''vw.hr22 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb1.hr5 else hb.hr23 end *'' else '''' end +''vw.hr23 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				+(cast(''+case when @_group_by=''b'' then '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb1.hr6 else hb.hr24 end *'' else '''' end +''vw.hr24 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' else '''' end +'')
				AS NUMERIC(38, 10))  '' + CASE WHEN @_summary_option = ''m'' THEN '')'' ELSE '''' END +'', '' + @_round_value + '' )) Volume ,'' 
			+ CASE @_summary_option WHEN ''d'' THEN ''''''Daily'''' AS Frequency,''
				WHEN ''m'' THEN ''''''Monthly'''' AS Frequency,''
				WHEN ''q'' THEN ''''''Quarterly'''' AS Frequency,''
				WHEN ''a'' THEN ''''''Annually'''' AS Frequency,''
				ELSE ''''						 
			END 
	END
END--@_summary_option IN (''d'' ,''m'',''q'',''a'')
ELSE 
	SET @_volume_clm=
		CASE WHEN @_summary_option=''m'' THEN ''''''Monthly'''' AS Frequency,'' WHEN @_summary_option=''d'' THEN ''''''Daily'''' AS Frequency,'' WHEN @_summary_option=''a'' THEN ''''''Annually'''' AS Frequency,'' WHEN @_summary_option=''q'' THEN ''''''Quarterly'''' AS Frequency,'' ELSE '''' END +
			''ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr7 else hb.hr1 end *'' else '''' end +''vw.hr1 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''7'' ELSE ''1'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr8 else hb.hr2 end *'' else '''' end +''vw.hr2 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''8'' ELSE ''2'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr9 else hb.hr3 end *'' else '''' end +''vw.hr3 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''9'' ELSE ''3'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr10 else hb.hr4 end *'' else '''' end +''vw.hr4 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''10'' ELSE ''4'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr11 else hb.hr5 end *'' else '''' end +''vw.hr5 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''11'' ELSE ''5'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr12 else hb.hr6 end *'' else '''' end +''vw.hr6 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''12'' ELSE ''6'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr13 else hb.hr7 end *'' else '''' end +''vw.hr7 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''13'' ELSE ''7'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr14 else hb.hr8 end *'' else '''' end +''vw.hr8 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''14'' ELSE ''8'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr15 else hb.hr9 end *'' else '''' end +''vw.hr9 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''15'' ELSE ''9'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr16 else hb.hr10 end *'' else '''' end +''vw.hr10 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''16'' ELSE ''10'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr17 else hb.hr11 end *'' else '''' end +''vw.hr11 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''17'' ELSE ''11'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr18 else hb.hr12 end *'' else '''' end +''vw.hr12 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''18'' ELSE ''12'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr19 else hb.hr13 end *'' else '''' end +''vw.hr13 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''19'' ELSE ''13'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr20 else hb.hr14 end *'' else '''' end +''vw.hr14 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''20'' ELSE ''14'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr21 else hb.hr15 end *'' else '''' end +''vw.hr15 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''21'' ELSE ''15'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr22 else hb.hr16 end *'' else '''' end +''vw.hr16 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''22'' ELSE ''16'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr23 else hb.hr17 end *'' else '''' end +''vw.hr17 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''23'' ELSE ''17'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr24 else hb.hr18 end *'' else '''' end +''vw.hr18 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''24'' ELSE ''18'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb1.hr1 else hb.hr19 end *'' else '''' end +''vw.hr19 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''1'' ELSE ''19'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb1.hr2 else hb.hr20 end *'' else '''' end +''vw.hr20 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''2'' ELSE ''20'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb1.hr3 else hb.hr21 end *'' else '''' end +''vw.hr21 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''3'' ELSE ''21'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb1.hr4 else hb.hr22 end *'' else '''' end +''vw.hr22 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''4'' ELSE ''22'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb1.hr5 else hb.hr23 end *'' else '''' end +''vw.hr23 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''5'' ELSE ''23'' END  +'',
			ROUND((cast(SUM(cast(''+ case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb1.hr6 else hb.hr24 end *'' else '''' end +''vw.hr24 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr''+ CASE WHEN ISNULL(@_col_7_to_6,''n'')=''y'' AND @_format_option<>''r'' THEN ''6'' ELSE ''24'' END  +'',
		''+CASE WHEN @_format_option =''r'' THEN +''ROUND((cast(SUM(cast(''+case WHEN @_group_by=''b'' THEN '' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''''n'''' then hb.hr9 else hb.hr3 end *'' else '''' end +''vw.hr25 as numeric(20,8))''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ''*cast(uc.conversion_factor as numeric(21,16))'' ELSE '''' END+'') as numeric(38,20))), '' + @_round_value + '') Hr25,'' ELSE '''' END
SET @_sqry=''select s.source_deal_detail_id,s.curve_id,s.location_id,s.term_start,''+
		+case  @_summary_option when ''y'' then  ''case when s.granularity=987 then case s.period when 15 then 0 when 45 then 30 else COALESCE(hrs.period,s.period) END else  COALESCE(hrs.period,s.period) end''
				when ''x'' then  ''COALESCE(hrs.period,m30.period,s.period)''
				else ''0''
		end+'' Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,'' 
		+case  @_summary_option when ''y'' then  
				'' s.hr1/COALESCE(hrs.factor,1) hr1, s.hr2/COALESCE(hrs.factor,1) hr2
				,s.hr3/COALESCE(hrs.factor,1) hr3, s.hr4/COALESCE(hrs.factor,1) hr4
				, s.hr5/COALESCE(hrs.factor,1) hr5, s.hr6/COALESCE(hrs.factor,1) hr6
				, s.hr7/COALESCE(hrs.factor,1) hr7, s.hr8/COALESCE(hrs.factor,1) hr8
				, s.hr9/COALESCE(hrs.factor,1) hr9, s.hr10/COALESCE(hrs.factor,1) hr10
				, s.hr11/COALESCE(hrs.factor,1) hr11, s.hr12/COALESCE(hrs.factor,1) hr12
				, s.hr13/COALESCE(hrs.factor,1) hr13, s.hr14/COALESCE(hrs.factor,1) hr14
				, s.hr15/COALESCE(hrs.factor,1) hr15, s.hr16/COALESCE(hrs.factor,1) hr16
				, s.hr17/COALESCE(hrs.factor,1) hr17, s.hr18/COALESCE(hrs.factor,1) hr18
				, s.hr19/COALESCE(hrs.factor,1) hr19, s.hr20/COALESCE(hrs.factor,1) hr20
				, s.hr21/COALESCE(hrs.factor,1) hr21, s.hr22/COALESCE(hrs.factor,1) hr22
				,s.hr23/COALESCE(hrs.factor,1) hr23, s.hr24/COALESCE(hrs.factor,1) hr24
				, s.hr25/COALESCE(hrs.factor,1) hr25''				
			when ''x'' then  
				'' s.hr1 /COALESCE(hrs.factor,m30.factor,1) hr1, s.hr2 /COALESCE(hrs.factor,m30.factor,1) hr2
				,s.hr3 /COALESCE(hrs.factor,m30.factor,1) hr3, s.hr4 /COALESCE(hrs.factor,m30.factor,1) hr4
				, s.hr5 /COALESCE(hrs.factor,m30.factor,1) hr5, s.hr6 /COALESCE(hrs.factor,m30.factor,1) hr6
				, s.hr7 /COALESCE(hrs.factor,m30.factor,1) hr7, s.hr8 /COALESCE(hrs.factor,m30.factor,1) hr8
				, s.hr9 /COALESCE(hrs.factor,m30.factor,1) hr9, s.hr10 /COALESCE(hrs.factor,m30.factor,1) hr10
				, s.hr11 /COALESCE(hrs.factor,m30.factor,1) hr11, s.hr12 /COALESCE(hrs.factor,m30.factor,1) hr12
				, s.hr13 /COALESCE(hrs.factor,m30.factor,1) hr13, s.hr14 /COALESCE(hrs.factor,m30.factor,1) hr14
				, s.hr15 /COALESCE(hrs.factor,m30.factor,1) hr15, s.hr16 /COALESCE(hrs.factor,m30.factor,1) hr16
				, s.hr17 /COALESCE(hrs.factor,m30.factor,1) hr17, s.hr18 /COALESCE(hrs.factor,m30.factor,1) hr18
				, s.hr19 /COALESCE(hrs.factor,m30.factor,1) hr19, s.hr20 /COALESCE(hrs.factor,m30.factor,1) hr20
				, s.hr21 /COALESCE(hrs.factor,m30.factor,1) hr21, s.hr22 /COALESCE(hrs.factor,m30.factor,1) hr22
				, s.hr23 /COALESCE(hrs.factor,m30.factor,1) hr23, s.hr24 /COALESCE(hrs.factor,m30.factor,1) hr24
				, s.hr25/COALESCE(hrs.factor,m30.factor,1) hr25''				
			else ''s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25''
		end
	+'',s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2
		,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date,''''n'''' AS is_fixedvolume,deal_status_id,0 breakdown, spcd.block_define_id
	INTO ''+ @_position_deal +''  
	from ''+@_view_nameq+'' s  (nolock) inner join #temp_deals td on s.term_start between td.term_start and td.term_end
			and td.source_deal_detail_id=s.source_deal_detail_id 
		INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
			AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3
			AND bk.source_system_book_id4=s.source_system_book_id4 
		left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id ''	
	+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
	'' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id'' ELSE '''' END
	+case  @_summary_option	when ''y'' then  '' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982 ''
							when ''x'' then  '' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982
											left join #minute_break m30 on s.granularity=m30.granularity and m30.granularity=989 ''
							else ''''
	end
	+'' WHERE  1=1 '' +CASE WHEN @_tenor_option <> ''a'' THEN '' AND s.expiration_date>''''''+@_as_of_date+'''''' AND s.term_start>''''''+@_as_of_date+'''''''' ELSE '''' END
	+ @_scrt 
SET @_sqry1=''
	union all
	select s.source_deal_detail_id,s.curve_id,s.location_id,s.term_start,''
		+case  @_summary_option when ''y'' then  ''case when s.granularity=987 then case s.period when 15 then 0 when 45 then 30 else COALESCE(hrs.period,s.period) end else  COALESCE(hrs.period,s.period) end''
				when ''x'' then  ''COALESCE(hrs.period,m30.period,s.period)''
				else ''0''
		end+'' Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,'' 
		+case  @_summary_option	when ''y'' then  
				'' s.hr1/COALESCE(hrs.factor,1)  hr1, s.hr2/COALESCE(hrs.factor,1) hr2
				,s.hr3/COALESCE(hrs.factor,1)  hr3, s.hr4/COALESCE(hrs.factor,1) hr4
				,s.hr5/COALESCE(hrs.factor,1)  hr5, s.hr6/COALESCE(hrs.factor,1) hr6
				, s.hr7/COALESCE(hrs.factor,1)  hr7, s.hr8/COALESCE(hrs.factor,1) hr8
				, s.hr9/COALESCE(hrs.factor,1) hr9, s.hr10/COALESCE(hrs.factor,1) hr10
				, s.hr11/COALESCE(hrs.factor,1)  hr11, s.hr12/COALESCE(hrs.factor,1) hr12
				, s.hr13/COALESCE(hrs.factor,1)  hr13, s.hr14/COALESCE(hrs.factor,1) hr14
				, s.hr15/COALESCE(hrs.factor,1)  hr15, s.hr16/COALESCE(hrs.factor,1) hr16
				, s.hr17/COALESCE(hrs.factor,1) hr17, s.hr18/COALESCE(hrs.factor,1) hr18
				, s.hr19/COALESCE(hrs.factor,1)  hr19, s.hr20/COALESCE(hrs.factor,1) hr20
				, s.hr21/COALESCE(hrs.factor,1)  hr21,s.hr22/COALESCE(hrs.factor,1) hr22
				, s.hr23/COALESCE(hrs.factor,1)  hr23, s.hr24/COALESCE(hrs.factor,1) hr24
				, s.hr25/COALESCE(hrs.factor,1)  hr25''				
			when ''x'' then  
				'' s.hr1 /COALESCE(hrs.factor,m30.factor,1) hr1, s.hr2 /COALESCE(hrs.factor,m30.factor,1)  hr2,
				s.hr3 /COALESCE(hrs.factor,m30.factor,1)  hr3, s.hr4 /COALESCE(hrs.factor,m30.factor,1)  hr4
				, s.hr5 /COALESCE(hrs.factor,m30.factor,1) hr5, s.hr6 /COALESCE(hrs.factor,m30.factor,1)  hr6
				, s.hr7 /COALESCE(hrs.factor,m30.factor,1) hr7, s.hr8 /COALESCE(hrs.factor,m30.factor,1)  hr8
				, s.hr9 /COALESCE(hrs.factor,m30.factor,1) hr9, s.hr10 /COALESCE(hrs.factor,m30.factor,1) hr10
				, s.hr11 /COALESCE(hrs.factor,m30.factor,1)  hr11, s.hr12 /COALESCE(hrs.factor,m30.factor,1)  hr12
				, s.hr13 /COALESCE(hrs.factor,m30.factor,1)  hr13, s.hr14 /COALESCE(hrs.factor,m30.factor,1)  hr14
				, s.hr15 /COALESCE(hrs.factor,m30.factor,1)  hr15, s.hr16 /COALESCE(hrs.factor,m30.factor,1)  hr16
				, s.hr17 /COALESCE(hrs.factor,m30.factor,1)  hr17, s.hr18 /COALESCE(hrs.factor,m30.factor,1)  hr18
				, s.hr19 /COALESCE(hrs.factor,m30.factor,1)  hr19, s.hr20 /COALESCE(hrs.factor,m30.factor,1)  hr20
				, s.hr21 /COALESCE(hrs.factor,m30.factor,1)  hr21,s.hr22 /COALESCE(hrs.factor,m30.factor,1)  hr22
				, s.hr23 /COALESCE(hrs.factor,m30.factor,1)  hr23, s.hr24 /COALESCE(hrs.factor,m30.factor,1)  hr24
				, s.hr25 /COALESCE(hrs.factor,m30.factor,1)  hr25''				
			else ''s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25''
		end
	+'',s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4 
	,s.expiration_date,''''n'''' AS is_fixedvolume,deal_status_id,0 breakdown, spcd.block_define_id
	from ''+@_view_name1+''_profile s  (nolock) inner join #temp_deals td on s.term_start between td.term_start and td.term_end
			 and td.source_deal_detail_id=s.source_deal_detail_id
	 INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
		AND bk.source_system_book_id2=s.source_system_book_id2	AND bk.source_system_book_id3=s.source_system_book_id3
		AND bk.source_system_book_id4=s.source_system_book_id4 
		left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id ''	
	+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
	'' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id'' ELSE '''' END
	+case  @_summary_option	when ''y'' then  '' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982 and 1=2 ''
							when ''x'' then  '' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982 and 1=2
											left join #minute_break m30 on s.granularity=m30.granularity and m30.granularity=989  and 1=2''
							else ''''
	end
	+'' WHERE  1=1 '' +CASE WHEN @_tenor_option <> ''a'' THEN '' AND s.expiration_date>''''''+@_as_of_date+'''''' AND s.term_start>''''''+@_as_of_date+'''''''' ELSE '''' END
	+ @_scrt 
	SET @_sqry2=''
	union all
	select s.source_deal_detail_id,s.curve_id,s.location_id,s.term_start,''
		+case  @_summary_option when ''y'' then  ''case when s.granularity=987 then case s.period when 15 then 0 when 45 then 30 else COALESCE(hrs.period,s.period) end else  COALESCE(hrs.period,s.period) end''
				when ''x'' then  ''COALESCE(hrs.period,m30.period,s.period)''
				else ''0''
		end+'' Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,'' 
		+case  @_summary_option	when ''y'' then  
				'' s.hr1/COALESCE(hrs.factor,1)  hr1, s.hr2/COALESCE(hrs.factor,1) hr2
				,s.hr3/COALESCE(hrs.factor,1)  hr3, s.hr4/COALESCE(hrs.factor,1) hr4
				,s.hr5/COALESCE(hrs.factor,1)  hr5, s.hr6/COALESCE(hrs.factor,1) hr6
				, s.hr7/COALESCE(hrs.factor,1)  hr7, s.hr8/COALESCE(hrs.factor,1) hr8
				, s.hr9/COALESCE(hrs.factor,1) hr9, s.hr10/COALESCE(hrs.factor,1) hr10
				, s.hr11/COALESCE(hrs.factor,1)  hr11, s.hr12/COALESCE(hrs.factor,1) hr12
				, s.hr13/COALESCE(hrs.factor,1)  hr13, s.hr14/COALESCE(hrs.factor,1) hr14
				, s.hr15/COALESCE(hrs.factor,1)  hr15, s.hr16/COALESCE(hrs.factor,1) hr16
				, s.hr17/COALESCE(hrs.factor,1) hr17, s.hr18/COALESCE(hrs.factor,1) hr18
				, s.hr19/COALESCE(hrs.factor,1)  hr19, s.hr20/COALESCE(hrs.factor,1) hr20
				, s.hr21/COALESCE(hrs.factor,1)  hr21,s.hr22/COALESCE(hrs.factor,1) hr22
				, s.hr23/COALESCE(hrs.factor,1)  hr23, s.hr24/COALESCE(hrs.factor,1) hr24
				, s.hr25/COALESCE(hrs.factor,1)  hr25''				
			when ''x'' then  
				'' s.hr1 /COALESCE(hrs.factor,m30.factor,1) hr1, s.hr2 /COALESCE(hrs.factor,m30.factor,1)  hr2,
				s.hr3 /COALESCE(hrs.factor,m30.factor,1)  hr3, s.hr4 /COALESCE(hrs.factor,m30.factor,1)  hr4
				, s.hr5 /COALESCE(hrs.factor,m30.factor,1) hr5, s.hr6 /COALESCE(hrs.factor,m30.factor,1)  hr6
				, s.hr7 /COALESCE(hrs.factor,m30.factor,1) hr7, s.hr8 /COALESCE(hrs.factor,m30.factor,1)  hr8
				, s.hr9 /COALESCE(hrs.factor,m30.factor,1) hr9, s.hr10 /COALESCE(hrs.factor,m30.factor,1) hr10
				, s.hr11 /COALESCE(hrs.factor,m30.factor,1)  hr11, s.hr12 /COALESCE(hrs.factor,m30.factor,1)  hr12
				, s.hr13 /COALESCE(hrs.factor,m30.factor,1)  hr13, s.hr14 /COALESCE(hrs.factor,m30.factor,1)  hr14
				, s.hr15 /COALESCE(hrs.factor,m30.factor,1)  hr15, s.hr16 /COALESCE(hrs.factor,m30.factor,1)  hr16
				, s.hr17 /COALESCE(hrs.factor,m30.factor,1)  hr17, s.hr18 /COALESCE(hrs.factor,m30.factor,1)  hr18
				, s.hr19 /COALESCE(hrs.factor,m30.factor,1)  hr19, s.hr20 /COALESCE(hrs.factor,m30.factor,1)  hr20
				, s.hr21 /COALESCE(hrs.factor,m30.factor,1)  hr21,s.hr22 /COALESCE(hrs.factor,m30.factor,1)  hr22
				, s.hr23 /COALESCE(hrs.factor,m30.factor,1)  hr23, s.hr24 /COALESCE(hrs.factor,m30.factor,1)  hr24
				, s.hr25 /COALESCE(hrs.factor,m30.factor,1)  hr25''				
			else ''s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25''
		end
	+'',s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4 
			,s.expiration_date,''''n'''' AS is_fixedvolume,deal_status_id,1 breakdown, spcd.block_define_id
	from ''+replace(@_view_nameq,''_deal'','''')+''_financial s  (nolock) inner join #temp_deals td on s.term_start between td.term_start and td.term_end
		and td.source_deal_detail_id=s.source_deal_detail_id 
	INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
		AND bk.source_system_book_id2=s.source_system_book_id2	AND bk.source_system_book_id3=s.source_system_book_id3
		AND bk.source_system_book_id4=s.source_system_book_id4 
	left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id ''	
	+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
	'' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id'' ELSE '''' END
	+case  @_summary_option	when ''y'' then  '' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982 ''
							when ''x'' then  '' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982
											left join #minute_break m30 on s.granularity=m30.granularity and m30.granularity=989 ''
							else ''''
	end
	+'' WHERE  1=1 '' +CASE WHEN @_tenor_option <> ''a'' THEN '' AND s.expiration_date>''''''+@_as_of_date+'''''' AND s.term_start>''''''+@_as_of_date+'''''''' ELSE '''' END
	+ @_scrt 			
IF @_physical_financial_flag<>''x''
	SET @_rhpb	=''	union all '' + @_rhpb	
ELSE
BEGIN
	SET @_rhpb	=''''
	SET @_rhpb1	=''''
	SET @_rhpb2	=''''
	SET @_rhpb3	=''''
END	
set @_rpn=isnull(@_rpn,'''')
set @_rpn1= isnull(@_rpn1,'''')
set @_rpn2=isnull(@_rpn2,'''')
EXEC spa_print  @_sqry
EXEC spa_print  @_sqry1
EXEC spa_print  @_sqry2
EXEC spa_print  @_rhpb
EXEC spa_print  @_rhpb1
EXEC spa_print  @_rhpb2
EXEC spa_print  @_rpn
EXEC spa_print  @_rpn1
EXEC spa_print  @_rpn2
exec(
	@_sqry +@_sqry1+@_sqry2+ @_rhpb+ @_rhpb1+ @_rhpb2
	+ @_rpn+@_rpn1+@_rpn2
)
exec(''CREATE INDEX indx_tmp_subqry1''+@_temp_process_id+'' ON ''+@_position_deal +''(curve_id);
	CREATE INDEX indx_tmp_subqry2''+@_temp_process_id+'' ON ''+@_position_deal +''(location_id);
	CREATE INDEX indx_tmp_subqry3''+@_temp_process_id+'' ON ''+@_position_deal +''(counterparty_id)''
)
select distinct sdd.source_deal_header_id,s.term_date, 
case when is_dst=1 then 25 else s.hours end [hours], isnull(s.period,0) period, 1 non_money
into #tmp_delta_0 -- select * from  #tmp_delta_0
 from source_deal_pnl_breakdown s
inner join #temp_deals td on td.source_deal_header_id=s.source_deal_header_id
	and  td.internal_deal_type_value_id=103 and td.internal_deal_subtype_value_id=102
 inner JOIN source_deal_detail sdd WITH (NOLOCK) ON sdd.source_deal_header_id = s.source_deal_header_id
	and sdd.leg =s.leg and s.term_date between sdd.term_start and sdd.term_end
where leg_mtm_deal<0  and as_of_date=@_as_of_date 
	and @_summary_option IN (''h'',''x'',''y'') 
create index indx_90909 on #tmp_delta_0 (source_deal_header_id,term_date,[hours], [period])
if object_id(''tempdb..#tmp_delta_pvt'') is not null drop table #tmp_delta_pvt
select * 
into #tmp_delta_pvt -- select * from #tmp_delta_pvt
from #tmp_delta_0  SourceTable
Pivot 
(
max(non_money) for [hours]
	in ( [1], [2], [3], [4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25])
) pr
if @@rowcount>0
begin
	set @_sqry=''update t set
		[hr1]=[hr1]*isnull([1],0.0000),
		[hr2]=[hr2]*isnull([2],0.0000),
		[hr3]=[hr3]*isnull([3],0.0000),
		[hr4]=[hr4]*isnull([4],0.0000),
		[hr5]=[hr5]*isnull([5],0.0000),
		[hr6]=[hr6]*isnull([6],0.0000),
		[hr7]=[hr7]*isnull([7],0.0000),
		[hr8]=[hr8]*isnull([8],0.0000),
		[hr9]=[hr9]*isnull([9],0.0000),
		[hr10]=[hr10]*isnull([10],0.0000),
		[hr11]=[hr11]*isnull([11],0.0000),
		[hr12]=[hr12]*isnull([12],0.0000),
		[hr13]=[hr13]*isnull([13],0.0000),
		[hr14]=[hr14]*isnull([14],0.0000),
		[hr15]=[hr15]*isnull([15],0.0000),
		[hr16]=[hr16]*isnull([16],0.0000),
		[hr17]=[hr17]*isnull([17],0.0000),
		[hr18]=[hr18]*isnull([18],0.0000),
		[hr19]=[hr19]*isnull([19],0.0000),
		[hr20]=[hr20]*isnull([20],0.0000),
		[hr21]=[hr21]*isnull([21],0.0000),
		[hr22]=[hr22]*isnull([22],0.0000),
		[hr23]=[hr23]*isnull([23],0.0000),
		[hr24]=[hr24]*isnull([24],0.0000),
		[hr25]=[hr25]*isnull([25],0.0000)
	from ''+@_position_deal+ '' t 
		inner join #tmp_delta_pvt d on d.source_deal_header_id=t.source_deal_header_id
			and d.term_date=t.term_start and d.period=t.period
	''
	EXEC spa_print  @_sqry
	exec(@_sqry)
end
set @_sqry=CASE WHEN @_convert_to_uom_id IS NULL then '''' else ''
	select distinct sdd.source_deal_detail_id,vw.term_start,cf_p.factor physical_density_mult,cf_f.factor financial_density_mult
	into #density_multiplier
	from ''+@_position_deal+'' vw 
		inner join dbo.source_deal_detail sdd on sdd.source_deal_header_id=vw.source_deal_header_id 
				and vw.is_fixedvolume=''''n'''' and sdd.curve_id=vw.curve_id 
				and vw.term_start between sdd.term_start and sdd.term_end
				and isnull(sdd.location_id,-1)=vw.location_id
		left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id --and spcd.conversion_value_id
		left join source_minor_location sml on sml.source_minor_location_id=sdd.location_id and sml.conversion_value_id is not null
		left join forecast_profile fp on fp.profile_id=COALESCE(sdd.profile_id,sml.profile_id,sml.proxy_profile_id)
		left join [dbo].[conversion_factor] h_p on h_p.conversion_value_id=sml.conversion_value_id	
			and h_p.from_uom=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id) and h_p.to_uom=''+@_convert_to_uom_id+''
		left join [dbo].[conversion_factor] h_f on h_f.conversion_value_id=spcd.conversion_value_id
			and h_f.from_uom=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id) and h_f.to_uom=''+@_convert_to_uom_id+''
		outer apply
		(
			select max(d.effective_date) effective_date from  [conversion_factor_detail] d where d.conversion_factor_id=h_p.conversion_factor_id
				and d.effective_date<=vw.term_start
		) cf_p_date
		outer apply
		(
			select max(d.effective_date) effective_date from [dbo].[conversion_factor_detail] d where d.conversion_factor_id=h_f.conversion_factor_id
				and d.effective_date<=vw.term_start
		) cf_f_date
		left join [dbo].[conversion_factor_detail] cf_p on cf_p.conversion_factor_id=h_p.conversion_factor_id
			and cf_p.effective_date=cf_p_date.effective_date
		left join dbo.[conversion_factor_detail] cf_f on cf_f.conversion_factor_id=h_f.conversion_factor_id
			and cf_f.effective_date=cf_f_date.effective_date
	where not (cf_p.factor is null and cf_f.factor is null);
''
end
SET @_Sql_Select=  
	'' SELECT sdd.source_deal_detail_id,vw.physical_financial_flag,su.source_uom_id
		,isnull(spcd1.source_curve_def_id,spcd.source_curve_def_id) source_curve_def_id,vw.location_id,vw.counterparty_id,vw.fas_book_id,''
		+CASE WHEN  @_summary_option IN (''d'',''h'',''x'',''y'')  THEN ''vw.term_start'' ELSE CASE WHEN @_summary_option=''m'' THEN ''convert(varchar(7),vw.term_start,120)'' WHEN @_summary_option=''a'' THEN ''year(vw.term_start)'' WHEN @_summary_option=''q'' THEN ''dbo.FNATermGrouping(vw.term_start,''''q'''')''  ELSE ''vw.term_start'' END END+'' [Term], ''
		+CASE WHEN  @_summary_option IN (''x'',''y'')  THEN ''vw.period'' ELSE ''0'' END+'' [Period], ''
			+ @_volume_clm+'' max(su.uom_name) [UOM],MAX(vw.commodity_id) commodity_id,MAX(vw.is_fixedvolume) is_fixedvolume,spcd.proxy_curve_id proxy_curve_id,breakdown breakdown
		INTO ''+@_hour_pivot_table 
	+'' FROM  ''
SET @_rhpb3=
		''  vw ''
	+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
			'' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = vw.deal_status_id'' 
		ELSE '''' END +''
		INNER JOIN source_price_curve_def spcd (nolock) ON spcd.source_curve_def_id=vw.curve_id 
		LEFT JOIN dbo.location_price_index lpi ON lpi.location_id = vw.location_id AND lpi.commodity_id = vw.commodity_id	
		left join dbo.source_deal_detail sdd on sdd.source_deal_detail_id=vw.source_deal_detail_id 
		LEFT JOIN  source_price_curve_def spcd1 (nolock) ON  spcd1.source_curve_def_id=''
		+CASE WHEN @_proxy_curve_view = ''y'' THEN  ''spcd.proxy_curve_id'' ELSE ''spcd.source_curve_def_id'' END
	+'' LEFT JOIN source_minor_location sml (nolock) ON sml.source_minor_location_id=vw.location_id
		left join static_data_value sdv1 (nolock) on sdv1.value_id=sml.grid_value_id
		left join static_data_value sdv (nolock)  on sdv.value_id=sml.country
		left join static_data_value sdv2 (nolock) on sdv2.value_id=sml.region
		left join static_data_value sdv_prov (nolock) on sdv_prov.value_id=sml.province
		left join source_major_location mjr (nolock) on  sml.source_major_location_ID=mjr.source_major_location_ID
		left join source_counterparty scp (nolock) on vw.counterparty_id = scp.source_counterparty_id	
		LEFT JOIN source_uom su (nolock) on su.source_uom_id=ISNULL(spcd.display_uom_id,spcd.uom_id)
	''+ CASE WHEN @_convert_to_uom_id IS NOT NULL THEN 
	'' 
		left join #density_multiplier den_mul on den_mul.source_deal_detail_id=sdd.source_deal_detail_id and vw.[term_start]=den_mul.term_start
		LEFT JOIN #unit_conversion unt ON unt.convert_from_uom_id=ISNULL(spcd.display_uom_id,spcd.uom_id) AND unt.convert_to_uom_id=''+CAST(@_convert_to_uom_id AS VARCHAR) +''
		outer apply (select coalesce(case when sdd.physical_financial_flag=''''p'''' then den_mul.physical_density_mult else den_mul.financial_density_mult end,unt.conversion_factor,1) conversion_factor) uc ''
	ELSE  '''' END +''
	WHERE 1=1 '' +
	CASE WHEN @_term_start IS NOT NULL THEN '' AND vw.term_start>=''''''+CAST(@_term_start AS VARCHAR)+'''''' AND vw.term_start<=''''''+CAST(@_term_END AS VARCHAR)+'''''''' ELSE '''' END  
	+CASE WHEN @_parent_counterparty IS NOT NULL THEN '' AND  scp.parent_counterparty_id = '' + CAST(@_parent_counterparty AS VARCHAR) ELSE  '''' END
	+CASE WHEN @_counterparty IS NOT NULL THEN '' AND vw.counterparty_id IN ('' + @_counterparty + '')'' ELSE '''' END
	+CASE WHEN @_commodity_id IS NOT NULL THEN '' AND vw.commodity_id IN(''+@_commodity_id+'')'' ELSE '''' END
	+CASE WHEN @_curve_id IS NOT NULL THEN '' AND vw.curve_id IN(''+@_curve_id+'')'' ELSE '''' END
	+CASE WHEN @_location_id IS NOT NULL THEN '' AND vw.location_id IN(''+@_location_id+'')'' ELSE '''' END
	+CASE WHEN @_tenor_option <> ''a'' THEN '' AND vw.expiration_date>''''''+@_as_of_date+'''''' AND vw.term_start>''''''+@_as_of_date+'''''''' ELSE '''' END  
	+CASE WHEN @_physical_financial_flag <>''b'' THEN '' AND vw.physical_financial_flag=''''''+@_physical_financial_flag+'''''''' ELSE '''' END
	+CASE WHEN @_country IS NOT NULL THEN '' AND sdv.value_id IN(''+ CAST(@_country AS VARCHAR) +'')''  ELSE '''' END
	+CASE WHEN @_region IS NOT NULL THEN '' AND sdv2.value_id IN(''+ CAST(@_region AS VARCHAR) +'')'' ELSE '''' END
	+CASE WHEN @_location_group_id IS NOT NULL THEN '' AND mjr.source_major_location_id=''+ @_location_group_id ELSE '''' END
	+CASE WHEN @_grid IS NOT NULL THEN '' AND sdv1.value_id=''+ @_grid ELSE '''' END
	+CASE WHEN @_province IS NOT NULL THEN '' AND sdv_prov.value_id=''+ @_province ELSE '''' END
 	+CASE WHEN @_deal_status IS NOT NULL THEN '' AND deal_status_id IN(''+@_deal_status+'')'' ELSE '''' END
	+CASE WHEN @_buy_sell_flag is not null THEN '' AND  sdd.buy_sell_flag=''''''+@_buy_sell_flag+'''''''' ELSE '''' END
	+'' GROUP BY sdd.source_deal_detail_id,isnull(spcd1.source_curve_def_id ,spcd.source_curve_def_id),vw.location_id,''
	+CASE WHEN  @_summary_option IN (''d'',''h'',''x'',''y'')  THEN ''vw.term_start'' ELSE CASE WHEN @_summary_option=''m'' THEN ''convert(varchar(7),vw.term_start,120)'' WHEN @_summary_option=''a'' THEN ''year(vw.term_start)'' WHEN @_summary_option=''q'' THEN ''dbo.FNATermGrouping(vw.term_start,''''q'''')''  ELSE ''vw.term_start'' END END
	+CASE WHEN  @_summary_option IN (''x'',''y'')  THEN '',vw.period'' ELSE '''' END+'',su.source_uom_id,vw.physical_financial_flag,vw.counterparty_id,vw.fas_book_id,spcd.proxy_curve_id,breakdown''  --,vw.commodity_id
EXEC spa_print @_sqry
EXEC spa_print @_Sql_Select
EXEC spa_print @_position_deal
EXEC spa_print @_rhpb3						
exec(@_sqry+@_Sql_Select+@_position_deal+@_rhpb3)
--select @_hour_pivot_table RETURN
--select * from adiha_process.dbo.hour_pivot_sbohara_2AF8B8FE_0565_4137_97EE_6C200291EF6E
SET @_rhpb=''SELECT s.source_deal_detail_id,s.source_curve_def_id,s.commodity_id,s.[Term],s.Period,s.is_fixedvolume,s.physical_financial_flag,s.source_uom_id,[UOM],counterparty_id,s.location_id,s.fas_book_id,s.proxy_curve_id,s.breakdown, spcd.block_define_id,''
if  @_summary_option IN (''h'',''x'',''y'') -- (''h'',''x'',''y'',''d'',''m'') 
begin
	set @_volume_clm=''
		CAST(hb1.hr1*s.hr1 AS NUMERIC(38,20)) [1],
		CAST(case when s.commodity_id=-1 then case when abs(isnull(hb1.add_dst_hour,0))=2 then 1.00 else isnull(hb1.hr2,0) end else isnull(hb.hr2,0) end*(s.hr2 - CASE WHEN hb1.add_dst_hour=2 THEN isnull(s.hr25,0) ELSE 0 END) AS NUMERIC(38,20)) [2],
		CAST(case when s.commodity_id=-1 then case when abs(isnull(hb1.add_dst_hour,0))=3 then 1.00 else isnull(hb1.hr3,0) end else isnull(hb.hr3,0) end*(s.hr3 - CASE WHEN hb1.add_dst_hour=3 THEN isnull(s.hr25,0) ELSE 0 END) AS NUMERIC(38,20)) [3],
		CAST(hb1.hr4*s.hr4 AS NUMERIC(38,20)) [4],
		CAST(hb1.hr5*s.hr5 AS NUMERIC(38,20)) [5],
		CAST(hb1.hr6*s.hr6 AS NUMERIC(38,20)) [6],
		CAST(hb1.hr7*s.hr7 AS NUMERIC(38,20)) [7],
		CAST(hb1.hr8*s.hr8 AS NUMERIC(38,20)) [8],
		CAST(hb1.hr9*s.hr9 AS NUMERIC(38,20)) [9],
		CAST(hb1.hr10*s.hr10 AS NUMERIC(38,20)) [10],
		CAST(hb1.hr11*s.hr11 AS NUMERIC(38,20)) [11],
		CAST(hb1.hr12*s.hr12 AS NUMERIC(38,20)) [12],
		CAST(hb1.hr13*s.hr13 AS NUMERIC(38,20)) [13],
		CAST(hb1.hr14*s.hr14 AS NUMERIC(38,20)) [14],
		CAST(hb1.hr15*s.hr15 AS NUMERIC(38,20)) [15],
		CAST(hb1.hr16*s.hr16 AS NUMERIC(38,20)) [16],
		CAST(hb1.hr17*s.hr17 AS NUMERIC(38,20)) [17],
		CAST(hb1.hr18*s.hr18 AS NUMERIC(38,20)) [18],
		CAST(hb1.hr19*s.hr19 AS NUMERIC(38,20)) [19],
		CAST(hb1.hr20*(s.hr20 - CASE WHEN abs(hb.add_dst_hour)+18=20 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [20],
		CAST(hb1.hr21*(s.hr21- CASE WHEN abs(hb.add_dst_hour)+18=21 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [21],
		CAST(hb1.hr22*s.hr22 AS NUMERIC(38,20)) [22],
		CAST(hb1.hr23*s.hr23 AS NUMERIC(38,20)) [23],
		CAST(hb1.hr24*s.hr24 AS NUMERIC(38,20)) [24],
		CAST(hb1.hr3*(s.hr25) AS NUMERIC(38,20)) [25],cast(hb1.hr3*(s.hr25) AS NUMERIC(38,20)) dst_hr,(hb.add_dst_hour) add_dst_hour
		,ISNULL(hb1.block_type_id, spcd.source_curve_def_id)  block_type_id,hb1.block_name
		,sdv_block_group.code [user_defined_block] ,sdv_block_group.value_id [user_defined_block_id],hb1.block_type_group_id '' --,no_hrs.no_hrs hr_nos
	
	SET @_rhpb_0= '' 
		select source_deal_detail_id,source_curve_def_id,commodity_id,[Term],Period,is_fixedvolume,physical_financial_flag,source_uom_id,[UOM],counterparty_id,location_id,fas_book_id,proxy_curve_id,breakdown,block_define_id,dst_hr,add_dst_hour,block_type_id
		,block_name,[user_defined_block] ,[user_defined_block_id],block_type_group_id
		,convert(varchar(10),CASE WHEN commodity_id=-1 AND is_fixedvolume =''''n'''' AND [hours]>18 THEN dateadd(DAY,1,[term]) ELSE [term] END,120) [term_date] 
		,CASE WHEN commodity_id=-1 AND is_fixedvolume =''''n'''' then case when [hours]<19 then [Hours]+6 when [hours] between 19 and 24 then [Hours]-18 else [Hours] end else [Hours] end [Hours] ,1  tot_hours,Volume
		into #unpvt 
		from (
			SELECT * FROM #tmp_pos_detail_power
			union all 
			SELECT * FROM #tmp_pos_detail_gas
		) p
		UNPIVOT
			(Volume for Hours IN
				([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25])
			) AS unpvt
		WHERE NOT ([hours]=abs(isnull(add_dst_hour,0))+18 AND add_dst_hour<0) ''
		+CASE WHEN @_block_type_group_id is not null  THEN '' and Volume<>0'' else '''' end+'';''
end
else 
begin
	set @_volume_clm=''Volume 
		,null block_type_id,null block_name, null [user_defined_block] ,null [user_defined_block_id],null block_type_group_id
		''
	set @_rhpb_0=''''
end
set @_commodity_str='' INTO #tmp_pos_detail_power FROM ''+@_hour_pivot_table+'' s 
		inner JOIN source_price_curve_def spcd (nolock) on spcd.source_curve_def_id = s.source_curve_def_id  AND not (s.commodity_id=-1 AND s.is_fixedvolume =''''n'''') 
	''
	+case when  @_summary_option IN (''h'',''x'',''y'') then
	''
	inner JOIN source_deal_detail sdd WITH (NOLOCK) ON sdd.source_deal_detail_id = s.source_deal_detail_id
	left JOIN  vwDealTimezone tz on tz.source_deal_header_id=sdd.source_deal_header_id
			AND ISNULL(tz.curve_id,-1)=ISNULL(sdd.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(sdd.location_id,-1)
		inner JOIN hour_block_term hb ON hb.term_date =s.[term]
			and hb.block_define_id = COALESCE(spcd.block_define_id,''+@_baseload_block_define_id+'') and  hb.block_type=12000
			and  hb.dst_group_value_id=tz.dst_group_value_id
		outer apply
		(
		 select g.*,h.* from  #temp_block_type_group_table g
			inner JOIN  hour_block_term h WITH (NOLOCK) ON h.block_define_id=COALESCE(g.hourly_block_id,''+@_baseload_block_define_id+'')  
			and s.term=h.term_date and  h.dst_group_value_id=tz.dst_group_value_id
		) hb1
		LEFT JOIN static_data_value sdv_block_group WITH (NOLOCK) ON sdv_block_group.value_id = hb1.block_type_group_id
	'' else '''' end


set @_commodity_str1='' INTO #tmp_pos_detail_gas FROM ''+@_hour_pivot_table+'' s  
	inner JOIN source_price_curve_def spcd (nolock) on spcd.source_curve_def_id = s.source_curve_def_id and s.commodity_id=-1 AND s.is_fixedvolume =''''n''''
	''
+case when  @_summary_option IN (''h'',''x'',''y'') then
''
	inner JOIN source_deal_detail sdd WITH (NOLOCK) ON sdd.source_deal_detail_id = s.source_deal_detail_id
	inner JOIN  vwDealTimezone tz on tz.source_deal_header_id=sdd.source_deal_header_id
	AND ISNULL(tz.curve_id,-1)=ISNULL(sdd.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(sdd.location_id,-1)
	inner JOIN hour_block_term hb ON  hb.term_date-1=s.[term]  
	AND hb.block_define_id =COALESCE(spcd.block_define_id,''+@_baseload_block_define_id+'') 
	and  hb.block_type=12000 
	and  hb.dst_group_value_id=tz.dst_group_value_id
	outer apply
	(
		select g.*,h.*
		from  #temp_block_type_group_table g
	inner JOIN  hour_block_term h WITH (NOLOCK)  ON h.block_define_id=COALESCE(g.hourly_block_id,''+@_baseload_block_define_id+'')  and s.term=h.term_date
	and  h.dst_group_value_id=tz.dst_group_value_id
	) hb1
	LEFT JOIN static_data_value sdv_block_group WITH (NOLOCK) ON sdv_block_group.value_id = hb1.block_type_group_id
''
else '''' end




SET @_rhpb1= ''
SELECT 
	id = IDENTITY(INT, 1, 1),
	''''''+isnull(@_as_of_date,'''')+'''''' as_of_date,
	sub.entity_id sub_id,
	stra.entity_id stra_id,
	book.entity_id book_id,
	sub.entity_name sub,
	stra.entity_name strategy,
	book.entity_name book,
	sdh.source_deal_header_id,
	sdh.deal_id deal_id,
	CASE WHEN vw.physical_financial_flag = ''''p'''' THEN ''''Physical'''' ELSE ''''Financial'''' END physical_financial_flag,
	sdh.deal_date deal_date,
	CASE WHEN vw.physical_financial_flag = ''''f'''' THEN coalesce(sml.Location_Name, spcd.curve_name) ELSE sml.Location_Name END location,
	spcd.source_curve_def_id [index_id],
	spcd.curve_name [index],
	spcd_proxy.curve_name proxy_index,
	spcd_proxy.source_curve_def_id proxy_index_id,
	sdv2.code region,
	sdv2.value_id region_id,
	sdv.code country,
	sdv.value_id country_id,
	sdv1.code grid,
	sdv1.value_id grid_id,
	sdv_prov.code Province,
	sdv_prov.value_id Province_id,
	mjr.location_name location_group,
	com.commodity_name commodity,
	sc.counterparty_name counterparty_name,
	sc.counterparty_name parent_counterparty,
	sb1.source_book_name book_identifier1,
	sb2.source_book_name book_identifier2,
	sb3.source_book_name book_identifier3,
	sb4.source_book_name book_identifier4,
	sb1.source_book_id book_identifier1_id,
	sb2.source_book_id book_identifier2_id,
	sb3.source_book_id book_identifier3_id,
	sb4.source_book_id book_identifier4_id,
	ssbm.logical_name AS sub_book,
	spcd_monthly_index.curve_name + CASE WHEN sssd.source_system_id = 2 THEN '''''''' ELSE ''''.'''' + sssd.source_system_name END AS [proxy_curve2],
	su_uom_proxy2.uom_name [proxy2_position_uom],
	spcd_proxy_curve3.curve_name + CASE WHEN sssd2.source_system_id = 2 THEN '''''''' ELSE ''''.'''' + sssd2.source_system_name END AS [proxy_curve3],
	su_uom_proxy3.uom_name [proxy3_position_uom], 
	sdv_block.code [block_definition],
	sdv_block.value_id [block_definition_id],
	CASE WHEN sdd.deal_volume_frequency = ''''h'''' THEN ''''Hourly''''
		WHEN sdd.deal_volume_frequency = ''''d'''' THEN ''''Daily''''
		WHEN sdd.deal_volume_frequency = ''''m'''' THEN ''''Monthly''''
		WHEN sdd.deal_volume_frequency = ''''t'''' THEN ''''Term''''
		WHEN sdd.deal_volume_frequency = ''''a'''' THEN  ''''Annually''''     
		WHEN sdd.deal_volume_frequency = ''''x'''' THEN ''''15 Minutes''''      
		WHEN sdd.deal_volume_frequency = ''''y'''' THEN  ''''30 Minutes''''   
	END  [deal_volume_frequency]   ,
	spcd_proxy_curve_def.curve_name [proxy_curve],
	spcd_proxy_curve_def.source_curve_def_id [proxy_curve_id],
	su_uom_proxy_curve_def.uom_name [proxy_curve_position_uom],
	sc.source_counterparty_id counterparty_id,
	sml.source_minor_location_id location_id,  
	su_uom_proxy_curve.uom_name proxy_index_position_uom,
	ssbm.book_deal_type_map_id [sub_book_id] ,
	spcd.proxy_curve_id3,
	sdd.contract_expiration_date expiration_date,
	spcd.commodity_id,
	vw.block_name,
	vw.block_type_id,
    vw.[user_defined_block] ,
    vw.[user_defined_block_id] 
	,vw.block_type_group_id
	,case when sdd.buy_sell_flag=''''b'''' then ''''Buy'''' else ''''Sell'''' end  AS [buy_sell_flag]
	,tdr.trader_name [Trader]
	,tdr.source_trader_id [Trader_id]
	,cg.contract_name [Contract]
	,cg.contract_id [Contract_id]
	,sdv_confirm.code [Confirm Status]
	,sdv_confirm.value_id confirm_status_id
	,sdv_deal_staus.code [Deal Status]
	,sdv_deal_staus.value_id deal_status_id
	,sdv_profile.code Profile
	,sdv_profile.value_id profile_id
	 ,ISNULL(sddh.deal_volume, sdd.deal_volume) [Deal Volume]
	,su.uom_name [Volume UOM]
	,ISNULL(sddh.schedule_volume, sdd.schedule_volume) [Scheduled Volume]
	,ISNULL(sddh.actual_volume, sdd.actual_volume) [Actual Volume]
	,left(''+CASE WHEN  @_summary_option IN (''m'',''q'',''a'')  THEN ''vw.term_date'' ELSE ''convert(varchar(10),vw.term_date,120)'' END+'',4)  term_year
	,vw.term_date term_end
	,''+CASE WHEN @_summary_option=''a'' THEN ''null'' else 
	''left(''+CASE WHEN  @_summary_option IN (''m'',''q'',''a'')  THEN ''vw.term_date'' ELSE ''convert(varchar(10),vw.term_date,120)'' END+'',7) '' end +'' term_year_month,
	RIGHT(''''0''''+ CAST(MONTH(sdd.term_start) AS VARCHAR(2)), 2)   [term_start_month],
	DATENAME(m,sdd.term_start) [term_start_month_name],
	--''''Q'''' + CAST(DATEPART(q,sdd.term_start) AS VARCHAR) [term_quarter],
	''''Q'''' + CAST(DATEPART(q, CAST(vw.term_date''+CASE WHEN @_summary_option = ''m'' THEN '' + ''''-01'''''' ELSE '''' END+'' AS DATE)) AS VARCHAR(2)) [term_quarter]
	,DATEPART(d,coalesce(''+CASE WHEN  @_summary_option IN (''m'',''q'',''a'')  THEN ''sdd.term_start'' ELSE ''vw.term_date'' END+'', sdd.term_start)) [term_day],
	sdd.term_start,
	CONVERT(VARCHAR(10),vw.term_date, 101) AS term_start_disp,
   vw.volume Position,
   --from demo4
   vw.volume/
   NULLIF(( (DAY(EOMONTH(sdd.term_start))*24) +
		CASE WHEN mvd.id IS NULL AND mvi.id IS NULL THEN 0 ELSE
			CASE WHEN mvd.id IS NOT NULL THEN -1 WHEN mvi.id IS NOT NULL THEN 1 ELSE 0 END
		 END
   ),0) [base_load_equivalent_volume],''
   --+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN '' cast(isnull(uc.conversion_factor,1) as numeric(21,16))*vw.volume'' else ''vw.volume'' end +''/NULLIF(vw.hr_nos,0) [tou_mwh],
   +''null [tou_mwh], --changed later to null as hr_nos is no longer used
   --from demo4
	su1.uom_name [uom],
	su_pos_uom.uom_name [postion_uom],
	sc.int_ext_flag,
	sdv_entity.value_id entity_type_id,
	sdv_entity.code entity_type,''
set @_rhpb2=''
	bkr.counterparty_name Broker,
	bkr.source_counterparty_id broker_id,
	sdt.source_deal_type_id	deal_type_id,
	sdst.source_deal_type_id deal_sub_type_id,
	sdt.source_deal_type_name	[Deal Type],
	sdst.source_deal_type_name [Deal Sub Type],
	mjr.source_major_location_id location_group_id,
''
+isnull(@_period_from,''null'') +'' period_from,''
+isnull(@_period_to,''null'')+'' period_to,
''+case when  @_summary_option IN (''h'',''x'',''y'') then
	''vw.Period,CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE vw.[Hours] END [Hour],
		CASE WHEN vw.[Hours] = 25 and mvi.[date] is not null THEN 1 ELSE 0 END AS DST''
	else ''null Period,null [Hour],null DST'' end +''
	,''''''+isnull(@_deal_date_from,'''')+'''''' [deal_date_from]
	,''''''+isnull(@_deal_date_to,'''')+'''''' [deal_date_to]
	,''''''+isnull(@_tenor_option,'''')+'''''' tenor_option
	,''''''+isnull(@_summary_option,'''')+'''''' summary_option
	, ssbm.sub_book_group1 sub_book_group1_id
	, ssbm.sub_book_group2 sub_book_group2_id
	, ssbm.sub_book_group3 sub_book_group3_id
	, ssbm.sub_book_group4 sub_book_group4_id
	, sdv_sbg1.code sub_book_group1
	, sdv_sbg2.code sub_book_group2
	, sdv_sbg3.code sub_book_group3
	, sdv_sbg4.code sub_book_group4
	, sdh.internal_deal_type_value_id internal_deal_type_id
	, sdh.internal_deal_subtype_value_id internal_deal_sub_type_id
	, idtst.internal_deal_type_subtype_type internal_deal_type
	, idtst1.internal_deal_type_subtype_type internal_deal_sub_type
	,''''''+isnull(@_convert_to_uom_id,'''')+'''''' [convert_uom_id]
	,coalesce(ISNULL(sddh.actual_volume, sdd.actual_volume),ISNULL(sddh.schedule_volume, sdd.schedule_volume),ISNULL(sddh.deal_volume, sdd.deal_volume)) best_avial_volume
	, isnull(ssbm.percentage_included,1) perc_owned
	,''+isnull(@_convert_to_uom_id,''null'') +'' convert_to_uom_id
	, coalesce(sddh.term_date, sdd.term_start''+CASE WHEN  @_summary_option IN (''m'',''q'',''a'')  THEN '''' ELSE '',vw.term_date'' END+'') [Term_Date]
	, sdh.structured_deal_id
	, CASE WHEN sdh.structured_deal_id IS NULL THEN sdh.deal_id	ELSE sdh1.deal_id END deal_group_reference
	 ,trans_type.code transaction_type
	 ,''''''+isnull(@_include_actuals_from_shape,'''')+'''''' include_actuals_from_shape,
	 ag_t.agg_term,
	 sdht.template_name,
	 sdht.template_id,
	 sdh.description1,
	 sdh.description2,
	 sdh.description3, 
	 sdh.description4,
	 sdh.counterparty_id2,
	 --sc_int_cpty.counterparty_name [internal_counterparty],
	 --fp.profile_name [forecast_profile],
	 sc2.counterparty_name counterparty_name2
	,sdd.leg [Leg]
	, '''''' + isnull(@_deal_status_group,'''') + '''''' [deal_status_group]
	,sdh.commodity_id commodity_d_id
    ,com2.commodity_name deal_commodity
	,''''''+ISNULL(@_proxy_curve_view,''n'')+'''''' proxy_curve_view
	, CAST(NULL AS FLOAT) AS delta
	,'''''' + @_show_delta_volume + '''''' AS show_delta_volume
	,ISNULL(sdv_curve_tou.code,''''Base Load'''') curve_tou,
	sdh.reporting_group1, 
	sdh.reporting_group2, 
	sdh.reporting_group3, 
	sdh.reporting_group4, 
	sdh.reporting_group5,
	reporting_group1.code reporting_group1_name,
	reporting_group2.code reporting_group2_name,
	reporting_group3.code reporting_group3_name,
	reporting_group4.code reporting_group4_name,
	reporting_group5.code reporting_group5_name
	,vw.source_deal_detail_id
INTO #tmp_position_detail
	FROM ''
		+case when  @_summary_option IN (''h'',''x'',''y'') then	''#unpvt''
			--when  @_summary_option IN (''m'',''d'') then ''#unpvt11''
		else 
			''
			(
				SELECT *,[term] term_date FROM #tmp_pos_detail_power
				union all 
				SELECT *,[term] term_date FROM #tmp_pos_detail_gas
				UNION ALL
				SELECT *, NULL block_define_id from  #tmp_pos_detail_torage
				'' +  CASE WHEN @_include_storage = ''y'' THEN '' 
				UNION ALL 
				SELECT *, NULL block_define_id FROM  #injection_withdrawal_deals''
				ELSE '''' END + ''
			)''
		end +'' vw ''
SET @_rhpba1 = ''		
	LEFT JOIN source_minor_location sml WITH (NOLOCK) ON sml.source_minor_location_id = vw.location_id
	left JOIN source_price_curve_def spcd WITH (NOLOCK) ON spcd.source_curve_def_id = vw.source_curve_def_id  
	LEFT JOIN  source_price_curve_def spcd_proxy WITH (NOLOCK) ON spcd_proxy.source_curve_def_id=spcd.proxy_curve_id
	LEFT JOIN  source_price_curve_def spcd_proxy_curve3 WITH (NOLOCK) ON spcd_proxy_curve3.source_curve_def_id=spcd.proxy_curve_id3
	LEFT JOIN  source_price_curve_def spcd_monthly_index WITH (NOLOCK) ON spcd_monthly_index.source_curve_def_id=spcd.monthly_index
	LEFT JOIN  source_price_curve_def spcd_proxy_curve_def WITH (NOLOCK) ON spcd_proxy_curve_def.source_curve_def_id=spcd.proxy_source_curve_def_id
	LEFT JOIN static_data_value sdv_curve_tou WITH (NOLOCK) ON sdv_curve_tou.value_id = spcd.curve_tou
	LEFT JOIN source_system_description sssd WITH (NOLOCK) ON sssd.source_system_id = spcd_monthly_index.source_system_id
	LEFT JOIN source_system_description sssd2 WITH (NOLOCK) ON sssd.source_system_id = spcd_proxy_curve3.source_system_id
	LEFT JOIN static_data_value sdv1 WITH (NOLOCK) ON sdv1.value_id=sml.grid_value_id
	LEFT JOIN static_data_value sdv WITH (NOLOCK) ON sdv.value_id=sml.country
	LEFT JOIN static_data_value sdv2 WITH (NOLOCK) ON sdv2.value_id=sml.region
	LEFT JOIN static_data_value sdv_prov WITH (NOLOCK) ON sdv_prov.value_id=sml.Province
	LEFT JOIN source_major_location mjr WITH (NOLOCK) ON sml.source_major_location_ID=mjr.source_major_location_ID
	LEFT JOIN source_uom AS su_pos_uom WITH (NOLOCK) ON su_pos_uom.source_uom_id = ''+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN @_convert_to_uom_id ELSE ''ISNULL(spcd.display_uom_id,spcd.uom_id)'' END+''
	LEFT JOIN source_uom su_uom  WITH (NOLOCK)ON su_uom.source_uom_id= spcd.uom_id
	LEFT JOIN source_uom su_uom_proxy3 WITH (NOLOCK) ON su_uom_proxy3.source_uom_id= ISNULL(spcd_proxy_curve3.display_uom_id,spcd_proxy_curve3.uom_id)--spcd_proxy_curve3.display_uom_id
	LEFT JOIN source_uom su_uom_proxy2 WITH (NOLOCK) ON su_uom_proxy2.source_uom_id= ISNULL(spcd_monthly_index.display_uom_id,spcd_monthly_index.uom_id)
	''
SET @_rhpb3 = ''
	LEFT JOIN source_uom su_uom_proxy_curve_def WITH (NOLOCK) ON su_uom_proxy_curve_def.source_uom_id= ISNULL(spcd_proxy_curve_def.display_uom_id,spcd_proxy_curve_def.uom_id)--spcd_proxy_curve_def.display_uom_id
	LEFT JOIN source_uom su_uom_proxy_curve WITH (NOLOCK) ON su_uom_proxy_curve.source_uom_id= ISNULL(spcd_proxy.display_uom_id,spcd_proxy.uom_id)
	LEFT JOIN source_counterparty sc WITH (NOLOCK) ON sc.source_counterparty_id = vw.counterparty_id 
	LEFT JOIN source_counterparty psc  WITH (NOLOCK) ON psc.source_counterparty_id=sc.parent_counterparty_id
	LEFT JOIN source_commodity com  WITH (NOLOCK) ON com.source_commodity_id=vw.commodity_id 
	LEFT JOIN portfolio_hierarchy book WITH (NOLOCK) ON book.entity_id = vw.fas_book_id 
	LEFT JOIN portfolio_hierarchy stra WITH (NOLOCK) ON stra.entity_id = book.parent_entity_id 
	LEFT JOIN portfolio_hierarchy sub WITH (NOLOCK) ON sub.entity_id = stra.parent_entity_id
	LEFT JOIN source_deal_detail sdd WITH (NOLOCK) ON sdd.source_deal_detail_id = vw.source_deal_detail_id
	LEFT JOIN source_deal_header sdh WITH (NOLOCK) ON sdh.source_deal_header_id = sdd.source_deal_header_id 
'' +	
	CASE WHEN @_deal_status_group = ''o'' THEN
	'' INNER JOIN deal_status_group dsg ON dsg.status_value_id = sdh.deal_status ''
	WHEN @_deal_status_group = ''u'' THEN
	'' INNER JOIN (SELECT value_id FROM static_data_value WHERE type_id = 5600 EXCEPT SELECT status_value_id FROM deal_status_group) unofficial_status ON unofficial_status.value_id = sdh.deal_status ''
	ELSE '''' END + ''
	LEFT JOIN static_data_value sdv_deal_staus WITH (NOLOCK) ON sdv_deal_staus.value_id = sdh.deal_status
	LEFT JOIN source_commodity com2  WITH (NOLOCK) ON com2.source_commodity_id=sdh.commodity_id
	LEFT JOIN static_data_value sdv_profile WITH (NOLOCK) ON sdv_profile.value_id = sdh.internal_desk_id
	LEFT JOIN static_data_value sdv_confirm WITH (NOLOCK) ON sdv_confirm.value_id = sdh.confirm_status_type
	LEFT JOIN contract_group cg  WITH (NOLOCK) ON cg.contract_id = sdh.contract_id
	left join source_traders tdr on tdr.source_trader_id=sdh.trader_id 
	LEFT JOIN source_uom su  WITH (NOLOCK)ON su.source_uom_id= sdd.deal_volume_uom_id
	LEFT JOIN source_system_book_map ssbm WITH (NOLOCK) ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	LEFT JOIN source_book sb1 WITH (NOLOCK) ON sb1.source_book_id = sdh.source_system_book_id1
	LEFT JOIN source_book sb2 WITH (NOLOCK) ON sb2.source_book_id = sdh.source_system_book_id2
	LEFT JOIN source_book sb3 WITH (NOLOCK) ON sb3.source_book_id = sdh.source_system_book_id3
	LEFT JOIN source_book sb4 WITH (NOLOCK) ON sb4.source_book_id = sdh.source_system_book_id4
	LEFT JOIN static_data_value sdv_block WITH (NOLOCK) ON sdv_block.value_id  = ISNULL(sdh.block_define_id, '' + @_baseload_block_define_id + '')
	LEFT JOIN static_data_value sdv_entity WITH (NOLOCK) ON sdv_entity.value_id  = sc.type_of_entity
	LEFT JOIN source_counterparty bkr WITH (NOLOCK) ON bkr.source_counterparty_id = sdh.broker_id 
	left join source_deal_type sdt on sdt.source_deal_type_id=sdh.source_deal_type_id
	left join source_deal_type sdst on sdst.source_deal_type_id=sdh.deal_sub_type_type_id
	left JOIN  vwDealTimezone tz on tz.source_deal_header_id=sdd.source_deal_header_id
		AND ISNULL(tz.curve_id,-1)=ISNULL(sdd.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(sdd.location_id,-1)
	LEFT JOIN static_data_value sdv_sbg1 ON sdv_sbg1.value_id = ssbm.sub_book_group1
	LEFT JOIN static_data_value sdv_sbg2 ON sdv_sbg2.value_id = ssbm.sub_book_group2
	LEFT JOIN static_data_value sdv_sbg3 ON sdv_sbg3.value_id = ssbm.sub_book_group3
	LEFT JOIN static_data_value sdv_sbg4 ON sdv_sbg4.value_id = ssbm.sub_book_group4
	LEFT JOIN internal_deal_type_subtype_types idtst ON idtst.internal_deal_type_subtype_id = sdh.internal_deal_type_value_id
	LEFT JOIN internal_deal_type_subtype_types idtst1 ON idtst1.internal_deal_type_subtype_id = sdh.internal_deal_subtype_value_id
		LEFT join static_data_value trans_type ON trans_type.value_id = ssbm.fas_deal_type_value_id
	LEFT JOIN source_deal_header sdh1 on CAST(sdh1.source_deal_header_id AS VARCHAR) = sdh.structured_deal_id
	LEFT JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
	LEFT JOIN source_counterparty sc2 ON sc2.source_counterparty_id = sdh.counterparty_id2
		--reporting group
	LEFT JOIN static_data_value reporting_group1 ON reporting_group1.value_id = sdh.[reporting_group1] AND reporting_group1.type_id = 113000
	LEFT JOIN static_data_value reporting_group2 ON reporting_group2.value_id = sdh.[reporting_group2] AND reporting_group2.type_id = 113100
	LEFT JOIN static_data_value reporting_group3 ON reporting_group3.value_id = sdh.[reporting_group3] AND reporting_group3.type_id = 113200
	LEFT JOIN static_data_value reporting_group4 ON reporting_group4.value_id = sdh.[reporting_group4] AND reporting_group4.type_id = 113300
	LEFT JOIN static_data_value reporting_group5 ON reporting_group5.value_id = sdh.[reporting_group5] AND reporting_group5.type_id = 113400
	--from demo4
	LEFT JOIN mv90_DST mvd (nolock) ON YEAR(sdd.[term_start]) = YEAR(mvd.[date]) AND MONTH(sdd.[term_start]) = MONTH(mvd.[date]) AND mvd.insert_delete=''''d'''' AND tz.dst_group_value_id = mvd.dst_group_value_id
	LEFT JOIN mv90_DST mvi (nolock) ON YEAR(sdd.[term_start]) = YEAR(mvi.[date]) AND MONTH(sdd.[term_start]) = MONTH(mvi.[date]) AND mvi.insert_delete=''''i'''' AND tz.dst_group_value_id = mvi.dst_group_value_id
	--from demo4
		''
set @_rhpb4=''
	OUTER APPLY(SELECT TOP 1 CASE WHEN sdd.term_start<''''''++@_as_of_date++'''''' THEN '''' '''' + CAST(YEAR(sdd.term_start) AS VARCHAR) + ''''-YTD''''
			WHEN MONTH(sdd.term_start)=MONTH(''''''+@_as_of_date+'''''') AND YEAR(sdd.term_start)=YEAR(''''''+@_as_of_date+'''''') THEN 
				CAST(YEAR(sdd.term_start) AS VARCHAR) + '''' - Current Month''''
			WHEN DATEDIFF(m,''''''+@_as_of_date+'''''',sdd.term_start) <=3  THEN 
				convert(varchar(4),sdd.term_start,120) +''''-''''+ ''''M'''' + CAST(DATEDIFF(m,''''''+@_as_of_date+'''''',sdd.term_start) AS VARCHAR) +'''' ''''+ ''''('''' + UPPER(LEFT(DATENAME(MONTH,dateadd(MONTH, MONTH(sdd.term_start),-1)),3)) + '''')''''
			WHEN YEAR(''''''+@_as_of_date+'''''') =  YEAR(sdd.term_start) THEN 
				convert(varchar(4),sdd.term_start,120) + ''''-''''+ ''''Q'''' + CAST(DATEPART(q,sdd.term_start) AS VARCHAR)
			ELSE  
				CAST(YEAR(sdd.term_start) AS VARCHAR) 
		END agg_term FROM portfolio_mapping_tenor
	) ag_t
	'' + 
		CASE WHEN @_include_actuals_from_shape = ''y'' THEN ''
			OUTER APPLY (
				SELECT sddh.term_date, sddh.actual_volume, sddh.schedule_volume, sddh.volume deal_volume
				FROM source_deal_detail_hour sddh
				WHERE sddh.source_deal_detail_id = sdd.source_deal_detail_id
			) sddh
		''
		ELSE ''
			OUTER APPLY (
				SELECT NULL term_date, NULL actual_volume, NULL schedule_volume, NULL deal_volume
			) sddh
		''
		END
	+ CASE WHEN @_convert_to_uom_id IS NOT NULL THEN 
		'' LEFT JOIN source_uom su1 on su1.source_uom_id=''+CAST(@_convert_to_uom_id AS VARCHAR)  
	ELSE  
		'' LEFT JOIN source_uom su1 (nolock) on su1.source_uom_id=ISNULL(spcd.display_uom_id,spcd.uom_id)''
	END
	+case when  @_summary_option IN (''h'',''x'',''y'') then ''
		LEFT JOIN mv90_DST mv (nolock) ON (vw.[term_date])=(mv.[date])
			AND mv.insert_delete=''''i'''' AND vw.[Hours]=25 AND tz.dst_group_value_id= mv.dst_group_value_id
		LEFT JOIN mv90_DST mv1 (nolock) ON (vw.[term_date])=(mv1.[date])
			AND mv1.insert_delete=''''d'''' AND mv1.Hour=vw.[Hours]	
			AND tz.dst_group_value_id= mv1.dst_group_value_id	
		LEFT JOIN mv90_DST mv2 (nolock) ON YEAR(vw.[term_date])=(mv2.[YEAR])
			AND mv2.insert_delete=''''d'''' AND tz.dst_group_value_id= mv2.dst_group_value_id
		LEFT JOIN mv90_DST mv3 (nolock) ON YEAR(vw.[term_date])=(mv3.[YEAR])
			AND mv3.insert_delete=''''i'''' AND tz.dst_group_value_id= mv3.dst_group_value_id''
		else '''' end
		+case when  @_summary_option IN (''h'',''x'',''y'') then
		''
		WHERE  (((vw.[Hours]=25 AND mv.[date] IS NOT NULL) OR (vw.[Hours]<>25)) AND (mv1.[date] IS NULL))''
		+ CASE WHEN @_hour_from IS NOT NULL THEN '' and cast(CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE vw.[Hours] END as int) between ''+CAST(@_hour_from AS VARCHAR) +'' and '' +CAST(@_hour_to AS VARCHAR) ELSE '''' END 
		--+ CASE WHEN @_physical_financial_flag IS NOT NULL THEN '' AND vw.physical_financial_flag = '''''' + @_physical_financial_flag + '''''''' ELSE '''' END
	  else '''' END
--CASE WHEN @_physical_financial_flag IS NOT NULL THEN '' WHERE vw.physical_financial_flag = '''''' + @_physical_financial_flag + '''''''' ELSE '''' END end
	+CASE WHEN @_leg IS NOT NULL THEN '' AND sdd.leg =''+@_leg ELSE '''' END
IF @_show_delta_volume = ''y''
SET @_rhpb5 = ''
	select row_number() over(partition by t.source_deal_header_id,t.leg order by t.term_start) row_no,t.source_deal_header_id,t.Leg ,t.term_start,sdpdo.DELTA,sdpdo.DELTA2 
	into #delta_leg1
	from #tmp_position_detail t
		INNER JOIN source_deal_pnl_detail_options sdpdo ON sdpdo.source_deal_header_id = t.source_deal_header_id
			AND sdpdo.as_of_date = t.as_of_date AND sdpdo.term_start = t.term_start
			and t.Leg=1 ;
	select row_number() over(partition by t2.source_deal_header_id,t2.leg order by t2.term_start) row_no,t2.source_deal_header_id,t2.Leg ,t2.term_start
	into #delta_leg2
	from #tmp_position_detail t2
		inner join (select distinct source_deal_header_id from #delta_leg1) t1 on t1.source_deal_header_id=t2.source_deal_header_id
			and t2.Leg=2;
	UPDATE tp SET position = tp.position *d.DELTA
		,delta=d.DELTA
	FROM #tmp_position_detail tp
	inner join
	(
	select source_deal_header_id,1 leg, term_start, DELTA from #delta_leg1 
	union all
	select t2.source_deal_header_id,2 leg, t2.term_start, t1.DELTA2 DELTA from #delta_leg2 t2
		inner join #delta_leg1 t1 on t1.source_deal_header_id=t2.source_deal_header_id
			and t2.row_no=t1.row_no
	) d on d.source_deal_header_id=tp.source_deal_header_id and d.leg=tp.leg and d.term_start=tp.term_start''
--from demo4
SET @_sql_final = ''
	SELECT DISTINCT tpd.source_deal_header_id, tpd.term_end, tpd.index_id, tpd.position
		INTO #tmp_weekend_holiday_position
	FROM #tmp_position_detail tpd
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = tpd.source_deal_header_id
	OUTER APPLY (SELECT 1 total
				FROM source_price_curve_def spcd 
				INNER JOIN holiday_group hg ON hg.hol_group_value_id = spcd.holiday_calendar_id
				AND hg.hol_date = tpd.term_end
				WHERE spcd.source_curve_def_id = tpd.index_id) t
	WHERE (DATEPART(DW, tpd.term_end) IN (1,7) OR t.total IS NOT NULL)
	AND EXISTS(SELECT 1 FROM deal_price_deemed dpd WHERE dpd.source_deal_detail_id = sdd.source_deal_detail_id)
	AND tpd.physical_financial_flag = ''''Financial''''
	AND '''''' + @_summary_option + '''''' = ''''d''''
	SELECT twhp.source_deal_header_id, twhp.index_id, tt.term_end, SUM(twhp.position) position, MIN(twhp.term_end) holiday
		INTO #tmp_final_position
		FROM #tmp_weekend_holiday_position twhp
		OUTER APPLY (SELECT TOP 1 term_end AS term_end 
						FROM #tmp_position_detail tpd
						WHERE tpd.term_end < twhp.term_end
						AND tpd.source_deal_header_id = twhp.source_deal_header_id
						AND tpd.index_id = twhp.index_id
						AND NOT EXISTS(SELECT TOP 1 1 FROM #tmp_weekend_holiday_position WHERE term_end = tpd.term_end)
						ORDER BY tpd.term_end DESC) tt
		GROUP BY twhp.source_deal_header_id, twhp.index_id, tt.term_end
		SELECT tfp.source_deal_header_id, 
			tfp.index_id, 
			dd.sql_date_value AS term_end, 
			tfp.holiday,
			tfp.position
		INTO #tmp_prev_working_day
		FROM #tmp_final_position tfp
		OUTER APPLY(SELECT TOP 1 sql_date_value 
			FROM date_details dd 
			WHERE dd.sql_date_value < tfp.holiday
			AND NOT EXISTS(SELECT 1 total
							FROM source_price_curve_def spcd 
							INNER JOIN holiday_group hg ON hg.hol_group_value_id = spcd.holiday_calendar_id
							AND hg.hol_date = dd.sql_date_value
							WHERE spcd.source_curve_def_id = tfp.index_id)
			AND (DATEPART(DW, dd.sql_date_value) NOT IN (1,7))
			ORDER BY dd.sql_date_value DESC) dd
		WHERE tfp.term_end IS NULL
		DELETE FROM #tmp_final_position WHERE term_end IS NULL
		DELETE tpd
		FROM #tmp_position_detail tpd
		INNER JOIN #tmp_weekend_holiday_position tfp ON tfp.source_deal_header_id = tpd.source_deal_header_id
			AND tfp.term_end = tpd.term_end
			AND tfp.index_id = tpd.index_id
		WHERE NOT EXISTS(SELECT 1 
						FROM #tmp_prev_working_day tpwp
						WHERE tpwp.source_deal_header_id = tfp.source_deal_header_id
						AND tpwp.holiday = tfp.term_end
						AND tpwp.index_id = tfp.index_id)
		UPDATE tpd SET tpd.position = (tpd.position+tfp.position)
		FROM #tmp_position_detail tpd
		INNER JOIN #tmp_final_position tfp ON tfp.source_deal_header_id = tpd.source_deal_header_id
			AND tfp.term_end = tpd.term_end
			AND tfp.index_id = tpd.index_id
		UPDATE tpd SET tpd.term_end = tpwp.term_end, 
			tpd.position = tpwp.position,
			tpd.term_start_disp = CONVERT(VARCHAR(10),tpwp.term_end, 101)
		FROM #tmp_position_detail tpd
		INNER JOIN #tmp_prev_working_day tpwp ON tpwp.source_deal_header_id = tpd.source_deal_header_id
			AND tpwp.holiday = tpd.term_end
			AND tpwp.index_id = tpd.index_id
	SELECT tpd.*,
		CASE WHEN ISNULL(tpd.internal_deal_type_id,-1) IN (15) THEN ''''1900-01-01'''' WHEN COALESCE(t.date_from,t1.exp_date,tpd.term_start) < tpd.as_of_date AND tpd.physical_financial_flag = ''''physical'''' THEN ''''1900-01-01'''' ELSE COALESCE(t.date_from,t1.date_from,tpd.term_start) END date_from,
		CASE WHEN ISNULL(tpd.internal_deal_type_id,-1) IN (15) THEN ''''1'''' WHEN COALESCE(t.date_from,t1.exp_date,tpd.term_start) < tpd.as_of_date AND tpd.physical_financial_flag = ''''physical'''' THEN ''''1'''' ELSE CAST(YEAR(COALESCE(t.date_from,t1.date_from,tpd.term_start)) AS VARCHAR)+RIGHT(''''0''''+CAST(MONTH(COALESCE(t.date_from,t1.date_from,tpd.term_start)) AS VARCHAR),2) END date_sort
		, ''''@include_storage'''' include_storage , sdv.code [pricing_type], sdv_product.code [product_group],pdf.alias_name period_alias_name,pdf.rowid hr_rowid  
	--[__batch_report__]
	FROM #tmp_position_detail tpd
	INNER JOIN #temp_deals td ON td.source_deal_detail_id = tpd.source_deal_detail_id
    LEFT JOIN static_data_value sdv ON sdv.value_id = td.pricing_type AND sdv.type_id = 46700
	LEFT JOIN static_data_value sdv_product ON sdv_product.value_id = td.internal_portfolio_id AND sdv_product.type_id = 39800	
	OUTER APPLY(
		SELECT hg.delivery_period AS date_from FROM source_price_curve_def spcd 
		lEFT JOIN expiration_calendar hg ON hg.calendar_id = spcd.exp_calendar_id
			AND tpd.term_end BETWEEN hg.expiration_from AND hg.expiration_to AND  ((td.physical_financial = ''''p'''' AND tpd.physical_financial_flag=''''financial'''') OR (td.physical_financial = ''''f'''' AND spcd.hourly_volume_allocation = 17607))
		WHERE spcd.source_curve_def_id = tpd.index_id AND hg.delivery_period IS NOT NULL
		AND '''''' + @_summary_option + '''''' = ''''d'''') t
	OUTER APPLY(
		SELECT MAX(hg.exp_date) AS exp_date,MAX(hg.hol_date) date_from
		FROM source_price_curve_def spcd 
		LEFT JOIN holiday_group hg ON hg.hol_group_value_id = spcd.exp_calendar_id
			AND CONVERT(VARCHAR(7),hg.hol_date,120) = CONVERT(VARCHAR(7),tpd.term_end,120) 
			AND tpd.physical_financial_flag=''''physical'''' 
		WHERE spcd.source_curve_def_id = tpd.index_id AND hg.hol_date IS NOT NULL
		AND '''''' + @_summary_option + '''''' = ''''d'''') t1
	left join #period_display_format pdf on pdf.[process_clm_name]= right(''''0''''+cast(tpd.[hour] as varchar),2)+''''_''''+right(''''0''''+cast(tpd.[period] as varchar),2)
				and pdf.is_dst=tpd.dst
	--where tpd.term_end=''''2021-03-12'''' and tpd.source_deal_detail_id=339702
	--order by period_alias_name
	''
DECLARE @_injection_withdrawal_deals VARCHAR(MAX)
SET @_injection_withdrawal_deals = CASE WHEN @_include_storage = ''y'' THEN ''
SELECT 
	NULL source_deal_detail_id
	, MAX(sdd.curve_id) source_curve_def_id
	, ISNULL(sdd.detail_commodity_id, sdh.commodity_id) commodity_id
	, CONVERT(VARCHAR(10), '''''' + CONVERT(VARCHAR(20), @_as_of_date, 120) + '''''') term
	, NULL Period
	, ''''n'''' is_fixedvolume
	, MAX(sdd.physical_financial_flag) physical_financial_flag
	, MAX(sdd.deal_volume_uom_id) source_uom_id
	, MAX(su.uom_name) UOM
	, MAX(sdh.counterparty_id) counterparty_id
	, MAX(sdd.location_id) location_id
	, NULL fas_book_id
	, NULL proxy_curve_id
	, NULL breakdown
	, SUM(CASE WHEN sdd.buy_sell_flag = ''''b'''' THEN -1 ELSE 1 END * ISNULL(td.net_quantity, td.gross_quantity)) volume
	, NULL block_typeid
	, NULL block_nabme
	, NULL user_defined_block
	, NULL user_defined_block_id
	, NULL block_type_group_id
	, MAX(CAST(DATEPART ( YYYY , '''''' + CONVERT(VARCHAR(10), @_as_of_date, 120) + '''''' ) AS VARCHAR(4)) +  ''''-'''' +  CAST(DATEPART ( mm , DATEADD(MONTH, 1, '''''' + CONVERT(VARCHAR(10), @_as_of_date, 120) + '''''')) AS VARCHAR(2)))  term_date
	INTO #injection_withdrawal_deals
FROM ticket_match tm 
INNER JOIN ticket_detail td ON td.ticket_detail_id = tm.ticket_detail_id
INNER JOIN match_group_detail mgd ON mgd.match_group_detail_id = tm.match_group_detail_id
INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mgd.source_deal_detail_id
INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.deal_sub_type_type_id 
INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
INNER JOIN source_commodity sc ON sc.source_commodity_id = ISNULL(sdd.detail_commodity_id, sdh.commodity_id)
LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
LEFT JOIN source_uom su On su.source_uom_id = sdd.deal_volume_uom_id
WHERE CAST(td.movement_date_time AS DATE) <= '''''' + CONVERT(VARCHAR(10), @_as_of_date, 120) + ''''''
	AND deal_type_id IN (''''Injection'''', ''''Withdrawal'''')
	''
	+ CASE WHEN @_source_deal_header_id IS NOT NULL  THEN '' AND sdh.source_deal_header_id IN (''+ CAST(@_source_deal_header_id AS VARCHAR) + '')'' ELSE '''' END
	+ CASE WHEN @_term_start IS NOT NULL THEN '' AND sdd.term_start>= '''''' + CONVERT(VARCHAR(10), @_as_of_date, 120) + '''''' AND sdd.term_start<= '''''' + CONVERT(VARCHAR(10), @_as_of_date, 120) + '''''''' ELSE '''' END 
	+ CASE WHEN @_commodity_id IS NOT NULL THEN '' AND sc.source_commodity_id IN ('' + @_commodity_id + '')'' ELSE '''' END
	+ CASE WHEN @_curve_id IS NOT NULL THEN '' AND sdd.curve_id IN ('' + @_curve_id + '')'' ELSE '''' END
	+ CASE WHEN @_location_id IS NOT NULL THEN '' AND sml.source_minor_location_id IN ('' + @_location_id + '')'' ELSE '''' END
	+ CASE WHEN @_reporting_group1 IS NULL THEN '''' ELSE '' AND sdh.reporting_group1 = '''''' + @_reporting_group1 + '''''''' END
	+ CASE WHEN @_reporting_group2 IS NULL THEN '''' ELSE '' AND sdh.reporting_group2 = '''''' + @_reporting_group2 + '''''''' END
	+ CASE WHEN @_reporting_group3 IS NULL THEN '''' ELSE '' AND sdh.reporting_group3 = '''''' + @_reporting_group3 + '''''''' END
	+ CASE WHEN @_reporting_group4 IS NULL THEN '''' ELSE '' AND sdh.reporting_group4 = '''''' + @_reporting_group4 + '''''''' END
	+ CASE WHEN @_reporting_group5 IS NULL THEN '''' ELSE '' AND sdh.reporting_group5 = '''''' + @_reporting_group5 + '''''''' END
+ ''
GROUP BY sdd.location_id, sdh.contract_id, ISNULL(sdd.detail_commodity_id, sdh.commodity_id) 				 				  
'' 
ELSE ''emply'' END 
SET @_storage_deals = ''
SELECT sdd.source_deal_detail_id,ISNULL(lpi.curve_id,sdd.curve_id) source_curve_def_id,
ISNULL(sdd.detail_commodity_id,sdh.commodity_id) commodity_id,CONVERT(VARCHAR(10),sdd.term_start,120) term,0 Period,''''n'''' is_fixedvolume,sdd.physical_financial_flag,sdd.deal_volume_uom_id source_uom_id,su.uom_name UOM,sdh.counterparty_id,sdd.location_id,NULL fas_book_id,NULL proxy_curve_id,0 breakdown,
CASE WHEN sdd.buy_sell_flag=''''s'''' THEN -1 ELSE 1 END *sdd.total_volume volume,NULL block_typeid,
NULL block_name,NULL user_defined_block,NULL user_defined_block_id,NULL block_type_group_id,CONVERT(VARCHAR(10),sdd.term_start,120)  term_date
INTO  #tmp_pos_detail_torage
FROM 
	#temp_deals td 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = td.source_deal_detail_id
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = td.source_deal_header_id
	INNER JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
	LEFT JOIN source_price_curve_def spcd (nolock) ON spcd.source_curve_def_id=sdd.curve_id 
	LEFT JOIN location_price_index lpi ON lpi.location_id = sdd.location_id AND lpi.commodity_id = ISNULL(sdd.detail_commodity_id,sdh.commodity_id)
WHERE ISNULL(sdh.internal_deal_type_value_id,-1) IN (15) ''
--PRINT ''111111''
EXEC spa_print @_sqry
EXEC spa_print @_rhpb
EXEC spa_print @_volume_clm 
EXEC spa_print @_commodity_str
EXEC spa_print @_rhpb
EXEC spa_print @_volume_clm
EXEC spa_print @_commodity_str1
EXEC spa_print @_storage_deals
EXEC spa_print @_injection_withdrawal_deals
EXEC spa_print @_rhpb_0
EXEC spa_print @_rhpb1 
EXEC spa_print @_rhpb2
EXEC spa_print @_rhpba1 
EXEC spa_print @_rhpb3
EXEC spa_print @_rhpb4
EXEC spa_print @_rhpb5
EXEC spa_print @_sql_final
exec(
	@_sqry+@_rhpb+@_volume_clm+@_commodity_str+ ''; 
	''+@_rhpb+@_volume_clm+ @_commodity_str1 +'';
	''+@_storage_deals+'';
	''+@_injection_withdrawal_deals+ '';
	''+@_rhpb_0 +@_rhpb1 +@_rhpb2+@_rhpba1+@_rhpb3+@_rhpb4+@_rhpb5+@_sql_final
)', report_id = @report_id_data_source_dest,
	system_defined = '1'
	,category = '106500' 
	WHERE [name] = 'Position Detail View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Actual Volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Actual Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Actual Volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Actual Volume' AS [name], 'Actual Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 1, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'As of Date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 1 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'block_definition'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Block Definition'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'block_definition'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'block_definition' AS [name], 'Block Definition' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'block_definition_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Block Definition ID'
			   , reqd_param = 0, widget_id = 2, datatype_id = 4, param_data_source = 'exec spa_StaticDataValues ''h'',@type_id=10018', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'block_definition_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'block_definition_id' AS [name], 'Block Definition ID' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'exec spa_StaticDataValues ''h'',@type_id=10018' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'block_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Block Name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'block_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'block_name' AS [name], 'Block Name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'block_type_group_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Block Type Group ID'
			   , reqd_param = 1, widget_id = 2, datatype_id = 4, param_data_source = 'exec spa_StaticDataValues ''h'',@type_id=15001', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'block_type_group_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'block_type_group_id' AS [name], 'Block Type Group ID' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'exec spa_StaticDataValues ''h'',@type_id=15001' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'block_type_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Block Type ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'block_type_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'block_type_id' AS [name], 'Block Type ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book' AS [name], 'Book' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_id' AS [name], 'Book ID' AS ALIAS, 1 AS reqd_param, 5 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'book_identifier1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Identifier 1'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'book_identifier1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier1' AS [name], 'Book Identifier 1' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'book_identifier1_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Identifier 1 ID'
			   , reqd_param = 0, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_source_book_maintain @flag=''x'', @source_system_book_type_value_id=50', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'book_identifier1_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier1_id' AS [name], 'Book Identifier 1 ID' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_source_book_maintain @flag=''x'', @source_system_book_type_value_id=50' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'book_identifier2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Identifier 2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'book_identifier2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier2' AS [name], 'Book Identifier 2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'book_identifier2_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Identifier 2 ID'
			   , reqd_param = 0, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_source_book_maintain @flag=''x'', @source_system_book_type_value_id=51', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'book_identifier2_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier2_id' AS [name], 'Book Identifier 2 ID' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_source_book_maintain @flag=''x'', @source_system_book_type_value_id=51' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'book_identifier3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Identifier 3'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'book_identifier3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier3' AS [name], 'Book Identifier 3' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'book_identifier3_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Identifier 3 ID'
			   , reqd_param = 0, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_source_book_maintain @flag=''x'', @source_system_book_type_value_id=52', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'book_identifier3_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier3_id' AS [name], 'Book Identifier 3 ID' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_source_book_maintain @flag=''x'', @source_system_book_type_value_id=52' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'book_identifier4'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Identifier 4'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'book_identifier4'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier4' AS [name], 'Book Identifier 4' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'book_identifier4_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Identifier 4 ID'
			   , reqd_param = 0, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_source_book_maintain @flag=''x'', @source_system_book_type_value_id=53', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'book_identifier4_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier4_id' AS [name], 'Book Identifier 4 ID' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_source_book_maintain @flag=''x'', @source_system_book_type_value_id=53' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Broker'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Broker'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Broker'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Broker' AS [name], 'Broker' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'broker_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Broker ID'
			   , reqd_param = 0, widget_id = 9, datatype_id = 4, param_data_source = 'exec spa_source_counterparty_maintain ''c'',@int_ext_flag=''b''', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'broker_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'broker_id' AS [name], 'Broker ID' AS ALIAS, 0 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'exec spa_source_counterparty_maintain ''c'',@int_ext_flag=''b''' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'commodity'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'commodity'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity' AS [name], 'Commodity' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'commodity_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity ID'
			   , reqd_param = 1, widget_id = 9, datatype_id = 4, param_data_source = 'exec spa_source_commodity_maintain  ''a''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 1, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'commodity_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_id' AS [name], 'Commodity ID' AS ALIAS, 1 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'exec spa_source_commodity_maintain  ''a''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Confirm Status'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Confirm Status'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Confirm Status'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Confirm Status' AS [name], 'Confirm Status' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'confirm_status_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Confirm Status ID'
			   , reqd_param = 1, widget_id = 2, datatype_id = 4, param_data_source = 'SELECT sdv.value_id, sdv.code' + CHAR(10) + '    FROM static_data_value sdv   ' + CHAR(10) + '    WHERE sdv.[type_id] = 17200 ORDER BY sdv.code', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'confirm_status_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'confirm_status_id' AS [name], 'Confirm Status ID' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'SELECT sdv.value_id, sdv.code' + CHAR(10) + '    FROM static_data_value sdv   ' + CHAR(10) + '    WHERE sdv.[type_id] = 17200 ORDER BY sdv.code' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Contract'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Contract'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Contract' AS [name], 'Contract' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Contract_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract ID'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = 'browse_contract_counterparty', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 1, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Contract_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Contract_id' AS [name], 'Contract ID' AS ALIAS, 0 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_contract_counterparty' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty ID'
			   , reqd_param = 1, widget_id = 7, datatype_id = 4, param_data_source = 'browse_counterparty', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_id' AS [name], 'Counterparty ID' AS ALIAS, 1 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_counterparty' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_name' AS [name], 'Counterparty' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'country'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Country'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'country'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'country' AS [name], 'Country' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'country_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Country ID'
			   , reqd_param = 1, widget_id = 9, datatype_id = 4, param_data_source = 'exec spa_StaticDataValues ''h'',@type_id=14000', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'country_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'country_id' AS [name], 'Country ID' AS ALIAS, 1 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'exec spa_StaticDataValues ''h'',@type_id=14000' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Deal Status'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Status'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Deal Status'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Deal Status' AS [name], 'Deal Status' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Deal Sub Type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Sub Type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Deal Sub Type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Deal Sub Type' AS [name], 'Deal Sub Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Deal Type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Deal Type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Deal Type' AS [name], 'Deal Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Deal Volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Deal Volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Deal Volume' AS [name], 'Deal Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'deal_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Date'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'deal_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_date' AS [name], 'Deal Date' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'deal_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Reference ID'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'deal_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_id' AS [name], 'Deal Reference ID' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'deal_status_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Status ID'
			   , reqd_param = 1, widget_id = 2, datatype_id = 4, param_data_source = 'exec spa_StaticDataValues ''h'',@type_id=5600', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'deal_status_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_status_id' AS [name], 'Deal Status ID' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'exec spa_StaticDataValues ''h'',@type_id=5600' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'deal_sub_type_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Sub Type ID'
			   , reqd_param = 1, widget_id = 2, datatype_id = 4, param_data_source = 'exec spa_source_deal_type_maintain ''x'',@sub_type=''y''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'deal_sub_type_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_sub_type_id' AS [name], 'Deal Sub Type ID' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'exec spa_source_deal_type_maintain ''x'',@sub_type=''y''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'deal_type_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Type ID'
			   , reqd_param = 1, widget_id = 9, datatype_id = 4, param_data_source = 'exec spa_source_deal_type_maintain ''x''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'deal_type_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_type_id' AS [name], 'Deal Type ID' AS ALIAS, 1 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'exec spa_source_deal_type_maintain ''x''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'deal_volume_frequency'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Volume Frequency'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'deal_volume_frequency'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_volume_frequency' AS [name], 'Deal Volume Frequency' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'DST'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'DST'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'DST'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'DST' AS [name], 'DST' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'entity_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Entity Type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'entity_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'entity_type' AS [name], 'Entity Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'entity_type_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Entity Type ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'entity_type_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'entity_type_id' AS [name], 'Entity Type ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'expiration_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Expiration Date'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'expiration_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'expiration_date' AS [name], 'Expiration Date' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'grid'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Grid'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'grid'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'grid' AS [name], 'Grid' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'grid_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Grid ID'
			   , reqd_param = 1, widget_id = 2, datatype_id = 4, param_data_source = 'exec spa_StaticDataValues ''h'',@type_id=18000', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'grid_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'grid_id' AS [name], 'Grid ID' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'exec spa_StaticDataValues ''h'',@type_id=18000' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Hour'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Hour'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Hour'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Hour' AS [name], 'Hour' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'index'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Index'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'index'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'index' AS [name], 'Index' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'index_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Index ID'
			   , reqd_param = 1, widget_id = 7, datatype_id = 4, param_data_source = 'browse_curve', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 1, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'index_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'index_id' AS [name], 'Index ID' AS ALIAS, 1 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_curve' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'int_ext_flag'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal/External'
			   , reqd_param = 0, widget_id = 1, datatype_id = 1, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'int_ext_flag'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'int_ext_flag' AS [name], 'Internal/External' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 1 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'location'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'location'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location' AS [name], 'Location' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'location_group'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location Group'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'location_group'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_group' AS [name], 'Location Group' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'location_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location ID'
			   , reqd_param = 1, widget_id = 7, datatype_id = 4, param_data_source = 'browse_location', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 1, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'location_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_id' AS [name], 'Location ID' AS ALIAS, 1 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_location' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'parent_counterparty'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Parent Counterparty'
			   , reqd_param = 1, widget_id = 7, datatype_id = 5, param_data_source = 'browse_counterparty', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'parent_counterparty'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'parent_counterparty' AS [name], 'Parent Counterparty' AS ALIAS, 1 AS reqd_param, 7 AS widget_id, 5 AS datatype_id, 'browse_counterparty' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Period'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Period'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Period'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Period' AS [name], 'Period' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'period_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Period From'
			   , reqd_param = 1, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'period_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_from' AS [name], 'Period From' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'period_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Period To'
			   , reqd_param = 1, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'period_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_to' AS [name], 'Period To' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'physical_financial_flag'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Physical/Financial'
			   , reqd_param = 1, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''p'',''Physical''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''f'',''Financial''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'physical_financial_flag'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'physical_financial_flag' AS [name], 'Physical/Financial' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''p'',''Physical''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''f'',''Financial''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Position'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Position'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Position'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Position' AS [name], 'Position' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'postion_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'postion_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'postion_uom' AS [name], 'Position UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Profile'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Profile'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Profile'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Profile' AS [name], 'Profile' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'profile_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Profile ID'
			   , reqd_param = 1, widget_id = 9, datatype_id = 4, param_data_source = 'exec spa_StaticDataValues ''h'',@type_id=17300', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'profile_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'profile_id' AS [name], 'Profile ID' AS ALIAS, 1 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'exec spa_StaticDataValues ''h'',@type_id=17300' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Province'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Province'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Province'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Province' AS [name], 'Province' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Province_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Province ID'
			   , reqd_param = 0, widget_id = 2, datatype_id = 4, param_data_source = 'exec spa_StaticDataValues ''h'',@type_id=29500', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Province_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Province_id' AS [name], 'Province ID' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'exec spa_StaticDataValues ''h'',@type_id=29500' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'proxy_curve'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'proxy_curve'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_curve' AS [name], 'Proxy Curve' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'proxy_curve_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve ID'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = 'browse_curve', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'proxy_curve_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_curve_id' AS [name], 'Proxy Curve ID' AS ALIAS, 0 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_curve' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'proxy_curve_id3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve ID 3'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = 'browse_curve', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'proxy_curve_id3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_curve_id3' AS [name], 'Proxy Curve ID 3' AS ALIAS, 0 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_curve' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'proxy_curve_position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'proxy_curve_position_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_curve_position_uom' AS [name], 'Proxy Curve Position UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'proxy_curve2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve 2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'proxy_curve2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_curve2' AS [name], 'Proxy Curve 2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'proxy_curve3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve 3'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'proxy_curve3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_curve3' AS [name], 'Proxy Curve 3' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'proxy_index'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Index'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'proxy_index'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_index' AS [name], 'Proxy Index' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'proxy_index_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Index ID'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = 'browse_curve', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'proxy_index_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_index_id' AS [name], 'Proxy Index ID' AS ALIAS, 0 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_curve' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'proxy_index_position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Index Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'proxy_index_position_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_index_position_uom' AS [name], 'Proxy Index Position UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'proxy2_position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy 2 Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'proxy2_position_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy2_position_uom' AS [name], 'Proxy 2 Position UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'proxy3_position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy 3 Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'proxy3_position_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy3_position_uom' AS [name], 'Proxy 3 Position UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'region'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Region'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'region'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'region' AS [name], 'Region' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'region_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Region ID'
			   , reqd_param = 1, widget_id = 9, datatype_id = 4, param_data_source = 'exec spa_StaticDataValues ''h'',@type_id=11150', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'region_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'region_id' AS [name], 'Region ID' AS ALIAS, 1 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'exec spa_StaticDataValues ''h'',@type_id=11150' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Scheduled Volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Scheduled Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Scheduled Volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Scheduled Volume' AS [name], 'Scheduled Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal ID'
			   , reqd_param = 1, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 1, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_id' AS [name], 'Deal ID' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy ID'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'stra_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra_id' AS [name], 'Strategy ID' AS ALIAS, 1 AS reqd_param, 4 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'strategy'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'strategy'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'strategy' AS [name], 'Strategy' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'sub'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'sub'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub' AS [name], 'Subsidiary' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'sub_book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'sub_book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book' AS [name], 'Sub Book' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book ID'
			   , reqd_param = 1, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'sub_book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_id' AS [name], 'Sub Book ID' AS ALIAS, 1 AS reqd_param, 8 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary ID'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'Subsidiary ID' AS ALIAS, 1 AS reqd_param, 3 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'tenor_option'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Tenor Option'
			   , reqd_param = 1, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''a'',''Show All''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''f'',''Forward''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'tenor_option'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'tenor_option' AS [name], 'Tenor Option' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''a'',''Show All''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''f'',''Forward''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term End'
			   , reqd_param = 1, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'term_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_end' AS [name], 'Term End' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 1, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'Term Start' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 1 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'term_year'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Year'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'term_year'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_year' AS [name], 'Term Year' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'term_year_month'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Year Month'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'term_year_month'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_year_month' AS [name], 'Term Year Month' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Trader'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Trader'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Trader'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Trader' AS [name], 'Trader' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Trader_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Trader ID'
			   , reqd_param = 1, widget_id = 7, datatype_id = 4, param_data_source = 'BrowseTrader', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 1, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Trader_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Trader_id' AS [name], 'Trader ID' AS ALIAS, 1 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'BrowseTrader' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'uom' AS [name], 'UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'user_defined_block'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'User Defined Block'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'user_defined_block'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'user_defined_block' AS [name], 'User Defined Block' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'user_defined_block_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'User Defined Block ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'user_defined_block_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'user_defined_block_id' AS [name], 'User Defined Block ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Volume UOM'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Volume UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Volume UOM'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Volume UOM' AS [name], 'Volume UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'summary_option'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Summary Option'
			   , reqd_param = 1, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''a'',''Annually''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''m'',''Monthly''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''q'',''Quarterly''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''d'',''Daily''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''h'',''Hourly''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''x'',''15 min''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''y'',''30 min''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'summary_option'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'summary_option' AS [name], 'Summary Option' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''a'',''Annually''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''m'',''Monthly''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''q'',''Quarterly''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''d'',''Daily''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''h'',''Hourly''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''x'',''15 min''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''y'',''30 min''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'location_group_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location Group ID'
			   , reqd_param = 1, widget_id = 2, datatype_id = 4, param_data_source = 'exec spa_source_major_location ''x''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 1, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'location_group_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_group_id' AS [name], 'Location Group ID' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'exec spa_source_major_location ''x''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'deal_date_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Date From'
			   , reqd_param = 1, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'deal_date_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_date_from' AS [name], 'Deal Date From' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'deal_date_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Date To'
			   , reqd_param = 1, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'deal_date_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_date_to' AS [name], 'Deal Date To' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'internal_deal_sub_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Deal Sub Type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'internal_deal_sub_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_deal_sub_type' AS [name], 'Internal Deal Sub Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'internal_deal_sub_type_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Deal Sub Type ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'internal_deal_sub_type_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_deal_sub_type_id' AS [name], 'Internal Deal Sub Type ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'internal_deal_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Deal Type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'internal_deal_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_deal_type' AS [name], 'Internal Deal Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'internal_deal_type_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Deal Type ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'internal_deal_type_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_deal_type_id' AS [name], 'Internal Deal Type ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'sub_book_group1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Report Group 1'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'sub_book_group1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_group1' AS [name], 'Report Group 1' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'sub_book_group1_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Report Group 1 ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'sub_book_group1_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_group1_id' AS [name], 'Report Group 1 ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'sub_book_group2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Report Group 2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'sub_book_group2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_group2' AS [name], 'Report Group 2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'sub_book_group2_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Report Group 2 ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'sub_book_group2_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_group2_id' AS [name], 'Report Group 2 ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'sub_book_group3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Report Group 3'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'sub_book_group3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_group3' AS [name], 'Report Group 3' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'sub_book_group3_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Report Group 3 ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'sub_book_group3_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_group3_id' AS [name], 'Report Group 3 ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'sub_book_group4'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Report Group 4'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'sub_book_group4'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_group4' AS [name], 'Report Group 4' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'sub_book_group4_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Report Group 4 ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'sub_book_group4_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_group4_id' AS [name], 'Report Group 4 ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'convert_uom_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Convert UOM'
			   , reqd_param = 1, widget_id = 2, datatype_id = 5, param_data_source = 'exec [spa_source_uom_maintain] ''s''', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'convert_uom_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'convert_uom_id' AS [name], 'Convert UOM' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'exec [spa_source_uom_maintain] ''s''' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'best_avial_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Best Available Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'best_avial_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'best_avial_volume' AS [name], 'Best Available Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'deal_group_reference'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Group Reference'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'deal_group_reference'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_group_reference' AS [name], 'Deal Group Reference' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'perc_owned'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Perc Owned'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'perc_owned'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'perc_owned' AS [name], 'Perc Owned' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'structured_deal_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Structured Deal ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'structured_deal_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'structured_deal_id' AS [name], 'Structured Deal ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'transaction_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Transaction Type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'transaction_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'transaction_type' AS [name], 'Transaction Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'include_actuals_from_shape'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Include Actuals From Shape'
			   , reqd_param = 1, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''y'',''Yes'' UNION SELECT ''n'', ''No''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'include_actuals_from_shape'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'include_actuals_from_shape' AS [name], 'Include Actuals From Shape' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''y'',''Yes'' UNION SELECT ''n'', ''No''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'term_quarter'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Quarter'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'term_quarter'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_quarter' AS [name], 'Term Quarter' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'term_start_month'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Month'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'term_start_month'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start_month' AS [name], 'Term Month' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'term_start_month_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Month Name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'term_start_month_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start_month_name' AS [name], 'Term Month Name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'agg_term'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Aggregate Term'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'agg_term'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'agg_term' AS [name], 'Aggregate Term' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'counterparty_id2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty ID 2'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = 'browse_counterparty', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'counterparty_id2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_id2' AS [name], 'Counterparty ID 2' AS ALIAS, 0 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_counterparty' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'counterparty_name2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty 2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'counterparty_name2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_name2' AS [name], 'Counterparty 2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'description1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Description 1'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'description1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'description1' AS [name], 'Description 1' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'description2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Description 2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'description2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'description2' AS [name], 'Description 2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'description3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Description 3'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'description3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'description3' AS [name], 'Description 3' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'description4'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Description 4'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'description4'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'description4' AS [name], 'Description 4' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'template_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Template ID'
			   , reqd_param = 0, widget_id = 9, datatype_id = 4, param_data_source = 'EXEC spa_getDealTemplate @flag=''s''', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'template_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'template_id' AS [name], 'Template ID' AS ALIAS, 0 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'EXEC spa_getDealTemplate @flag=''s''' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'template_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Template'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'template_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'template_name' AS [name], 'Template' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'term_day'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Day'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'term_day'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_day' AS [name], 'Term Day' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'convert_to_uom_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Convert To UOM ID'
			   , reqd_param = 1, widget_id = 2, datatype_id = 4, param_data_source = 'exec [spa_source_uom_maintain] ''s''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'convert_to_uom_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'convert_to_uom_id' AS [name], 'Convert To UOM ID' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'exec [spa_source_uom_maintain] ''s''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Leg'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Leg'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Leg'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Leg' AS [name], 'Leg' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'Term_Date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Date'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'Term_Date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Term_Date' AS [name], 'Term Date' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'term_start_disp'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'term_start_disp'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start_disp' AS [name], 'Term' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'buy_sell_flag'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Buy/Sell'
			   , reqd_param = 1, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''b'' Value,''Buy'' Label UNION SELECT ''s'', ''Sell''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'buy_sell_flag'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'buy_sell_flag' AS [name], 'Buy/Sell' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''b'' Value,''Buy'' Label UNION SELECT ''s'', ''Sell''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'deal_status_group'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Status Group'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''a'', ''All'' UNION' + CHAR(10) + 'SELECT ''o'', ''Official'' UNION' + CHAR(10) + 'SELECT ''u'', ''Unofficial''', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'deal_status_group'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_status_group' AS [name], 'Deal Status Group' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''a'', ''All'' UNION' + CHAR(10) + 'SELECT ''o'', ''Official'' UNION' + CHAR(10) + 'SELECT ''u'', ''Unofficial''' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'commodity_d_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity D Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'commodity_d_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_d_id' AS [name], 'Commodity D Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'curve_tou'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Curve Tou'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'curve_tou'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'curve_tou' AS [name], 'Curve Tou' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'deal_commodity'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Commodity'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'deal_commodity'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_commodity' AS [name], 'Deal Commodity' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'delta'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Delta'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'delta'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'delta' AS [name], 'Delta' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'id' AS [name], 'Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'proxy_curve_view'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve View'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'select  ''y'', ''Yes'' UNION ALL' + CHAR(10) + 'select ''n'', ''No''', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'proxy_curve_view'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_curve_view' AS [name], 'Proxy Curve View' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'select  ''y'', ''Yes'' UNION ALL' + CHAR(10) + 'select ''n'', ''No''' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'show_delta_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Show Delta Volume'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''y'', ''Yes'' UNION SELECT ''n'', ''No''', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'show_delta_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'show_delta_volume' AS [name], 'Show Delta Volume' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''y'', ''Yes'' UNION SELECT ''n'', ''No''' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'base_load_equivalent_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Base Load Equivalent Volume'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'base_load_equivalent_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'base_load_equivalent_volume' AS [name], 'Base Load Equivalent Volume' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'date_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Date From'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'date_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'date_from' AS [name], 'Date From' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'date_sort'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Date Sort'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'date_sort'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'date_sort' AS [name], 'Date Sort' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'include_storage'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Include Storage'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'include_storage'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'include_storage' AS [name], 'Include Storage' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'tou_mwh'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Tou Mwh'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'tou_mwh'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'tou_mwh' AS [name], 'Tou Mwh' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'pricing_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Pricing Type'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'EXEC spa_staticdataValues ''h'', 46700', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'pricing_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'pricing_type' AS [name], 'Pricing Type' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'EXEC spa_staticdataValues ''h'', 46700' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'product_group'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Product Group'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'EXEC spa_staticdataValues ''h'', 39800', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'product_group'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'product_group' AS [name], 'Product Group' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'EXEC spa_staticdataValues ''h'', 39800' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'period_alias_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Period Alias Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'period_alias_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_alias_name' AS [name], 'Period Alias Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'hr_rowid'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Hr Rowid'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'hr_rowid'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'hr_rowid' AS [name], 'Hr Rowid' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'reporting_group1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group 1'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113000', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'reporting_group1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group1' AS [name], 'Reporting Group 1' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113000' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'reporting_group2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group 2'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113100', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'reporting_group2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group2' AS [name], 'Reporting Group 2' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113100' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'reporting_group3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group 3'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113200', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'reporting_group3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group3' AS [name], 'Reporting Group 3' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113200' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'reporting_group4'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group 4'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113300', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'reporting_group4'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group4' AS [name], 'Reporting Group 4' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113300' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'reporting_group5'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group 5'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113400', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'reporting_group5'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group5' AS [name], 'Reporting Group 5' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113400' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'reporting_group1_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group1 Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'reporting_group1_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group1_name' AS [name], 'Reporting Group1 Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'reporting_group2_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group2 Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'reporting_group2_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group2_name' AS [name], 'Reporting Group2 Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'reporting_group3_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group3 Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'reporting_group3_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group3_name' AS [name], 'Reporting Group3 Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'reporting_group4_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group4 Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'reporting_group4_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group4_name' AS [name], 'Reporting Group4 Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'reporting_group5_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group5 Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'reporting_group5_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group5_name' AS [name], 'Reporting Group5 Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Detail View'
	            AND dsc.name =  'source_deal_detail_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Source Deal Detail Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Detail View'
			AND dsc.name =  'source_deal_detail_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_detail_id' AS [name], 'Source Deal Detail Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Position Detail View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN;
		
			DECLARE @error_msg VARCHAR(1000)
             	SET @error_msg = ERROR_MESSAGE()
             	RAISERROR (@error_msg, 16, 1);
	END CATCH
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
