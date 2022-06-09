BEGIN TRY
		BEGIN TRAN
	
	declare @new_ds_alias varchar(10) = 'HPPV'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'HPPV' and name <> 'Hourly Position Pipeline View')
	begin
		select top 1 @new_ds_alias = 'HPPV' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'HPPV' + cast(s.n as varchar(5))
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
	           WHERE [name] = 'Hourly Position Pipeline View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'Hourly Position Pipeline View' AND '106500' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], 'Hourly Position Pipeline View' AS [name], @new_ds_alias AS ALIAS, '' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'0' AS [system_defined]
			,'106500' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = ''
	, [tsql] = CAST('' AS VARCHAR(MAX)) + 'SET NOCOUNT ON

DECLARE @_sub_id VARCHAR(MAX) = NULL

	, @_stra_id VARCHAR(MAX) = NULL

	, @_book_id VARCHAR(MAX) = NULL

	, @_sub_book_id VARCHAR(MAX) = NULL

	, @_as_of_date VARCHAR(20) =  NULL

	, @_source_deal_header_id VARCHAR(1000) = NULL 

	, @_period_from VARCHAR(6) = NULL

	, @_period_to VARCHAR(6) = NULL

	, @_tenor_option VARCHAR(6) = NULL

	, @_location_id VARCHAR(1000) = NULL

	, @_curve_id VARCHAR(1000) = NULL

	, @_commodity_id VARCHAR(250) = NULL

	, @_deal_id VARCHAR(1000) = NULL

	, @_location_group_id VARCHAR(1000) = NULL

	, @_grid VARCHAR(1000) = NULL

	, @_country VARCHAR(1000) = NULL

	, @_region VARCHAR(1000) = NULL

	, @_province VARCHAR(1000) = NULL

	, @_station_id VARCHAR(1000) =NULL

	, @_dam_id VARCHAR(1000) =NULL

	, @_deal_status VARCHAR(250) = NULL

	, @_confirm_status VARCHAR(250) = NULL

	, @_profile VARCHAR(250) = NULL

	, @_term_start VARCHAR(20) =  NULL

	, @_term_end VARCHAR(20) =  NULL

	, @_deal_type VARCHAR(500) = NULL

	, @_deal_sub_type VARCHAR(8) = NULL

	, @_buy_sell_flag VARCHAR(6) = NULL

	, @_counterparty VARCHAR(MAX) = NULL

	, @_contract VARCHAR(MAX) = NULL

	, @_hour_from VARCHAR(6) = NULL

	, @_hour_to VARCHAR(6) = NULL

	, @_block_group VARCHAR(10) = NULL

	, @_parent_counterparty VARCHAR(10) = NULL

	, @_deal_date_from VARCHAR(20) = NULL

	, @_deal_date_to VARCHAR(20) = NULL

	, @_block_type_group_id VARCHAR(20) = NULL

	, @_trader_id VARCHAR(100) = NULL

	, @_template_id VARCHAR(MAX) = NULL

	, @_product_id VARCHAR(MAX) = NULL

	, @_mkt_con_flag VARCHAR(MAX) = NULL

	, @_convert_to_uom_id VARCHAR(20) = NULL

	, @_physical_financial_flag NCHAR(6) =  NULL

	, @_include_actuals_from_shape VARCHAR(6)

	, @_leg VARCHAR(6) = NULL

	,@_pricing_type VARCHAR(100)=NULL

	,@_formula_curve_id VARCHAR(1000)

	,@_forecast_profile_id VARCHAR(1000)

	,@_shipper_code_id1 VARCHAR(1000)

	,@_shipper_code_id2 VARCHAR(1000)

	,@_reporting_group1 VARCHAR(1000)

	,@_reporting_group2 VARCHAR(1000)

	,@_reporting_group3 VARCHAR(1000)

	,@_reporting_group4 VARCHAR(1000)

	,@_reporting_group5 VARCHAR(1000)

	,@_show_delta_volume CHAR(1) = null

	,@_path_id VARCHAR(1000)

/* List reports

x03s: 15 Mins Position Summary Report

x03d: 15 Mins Position Extract Report

x02s: 15 Mins Position Summary Report by Book

x01d: 15 Mins Power Position Report by Deal

x01s: 15 Mins Power Position Report by Location

x02d: 15 Mins Position Report by Deal with Profile filter

h00s: Hourly Position Summary Report

h00d: Hourly Position Extract Report

d00s: Daily Position Summary Report

d00d: Daily Position Extract Report

m00s: Monthly Position Summary Report

m00d: Monthly Position Extract Report

*/

--select * from source_minor_location where source_minor_location_id = 2853

--drop table  #temp_mdq_data


Declare @_process_id varchar(1000)

Declare @_position_process_table varchar(1000)

Declare @_user_id varchar(500)

SET @_process_id = REPLACE(newid(),''-'',''_'')

	SET @_user_id = dbo.FNADBUser()

	SET @_position_process_table = dbo.FNAProcessTableName(''temp_process_table'', @_user_id,@_process_id)


DECLARE @_summary_option VARCHAR(6) =''h00s''

	, @_group_by CHAR(1) = ''s'' 

	, @_format_option CHAR(1) = ''r''

	, @_round_value CHAR(1) = ''9''

	, @_convert_uom INT = NULL

	, @_col_7_to_6 VARCHAR(1) = ''n''

	, @_include_no_breakdown VARCHAR(1) = ''n''

	, @_process_table VARCHAR(250) = @_position_process_table

	, @_st VARCHAR(max)

--SELECT @_process_table = nullif(@_process_table, ''<#'' + ''PROCESS_TABLE'' + ''#>'')

SET @_summary_option = nullif(isnull(@_summary_option, nullif(''@summary_option'', replace(''@_summary_option'', ''@_'', ''@''))), ''null'')

SET @_sub_id = nullif(isnull(@_sub_id, nullif(''@sub_id'', replace(''@_sub_id'', ''@_'', ''@''))), ''null'')

SET @_stra_id = nullif(isnull(@_stra_id, nullif(''@stra_id'', replace(''@_stra_id'', ''@_'', ''@''))), ''null'')

SET @_book_id = nullif(isnull(@_book_id, nullif(''@book_id'', replace(''@_book_id'', ''@_'', ''@''))), ''null'')

SET @_sub_book_id = nullif(isnull(@_sub_book_id, nullif(''@sub_book_id'', replace(''@_sub_book_id'', ''@_'', ''@''))), ''null'')

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

SET @_station_id = nullif(isnull(@_station_id, nullif(''@station_id'', replace(''@_station_id'', ''@_'', ''@''))), ''null'')

SET @_dam_id = nullif(isnull(@_dam_id, nullif(''@dam_id'', replace(''@_dam_id'', ''@_'', ''@''))), ''null'')

SET @_deal_status = nullif(isnull(@_deal_status, nullif(''@deal_status_id'', replace(''@_deal_status_id'', ''@_'', ''@''))), ''null'')

SET @_confirm_status = nullif(isnull(@_confirm_status, nullif(''@confirm_status_id'', replace(''@_confirm_status_id'', ''@_'', ''@''))), ''null'')

SET @_profile = nullif(isnull(@_profile, nullif(''@profile_id'', replace(''@_profile_id'', ''@_'', ''@''))), ''null'')

SET @_term_start = nullif(isnull(@_term_start, nullif(''@term_start'', replace(''@_term_start'', ''@_'', ''@''))), ''null'')

SET @_term_end = nullif(isnull(@_term_end, nullif(''@term_end'', replace(''@_term_end'', ''@_'', ''@''))), ''null'')

SET @_deal_type = nullif(isnull(@_deal_type, nullif(''@deal_type'', replace(''@_deal_type'', ''@_'', ''@''))), ''null'')

SET @_deal_sub_type = nullif(isnull(@_deal_sub_type, nullif(''@deal_sub_type_id'', replace(''@_deal_sub_type_id'', ''@_'', ''@''))), ''null'')

SET @_buy_sell_flag = nullif(isnull(@_buy_sell_flag, nullif(''@buy_sell_flag'', replace(''@_buy_sell_flag'', ''@_'', ''@''))), ''null'')

SET @_counterparty = nullif(isnull(@_counterparty, nullif(''@counterparty'', replace(''@_counterparty'', ''@_'', ''@''))), ''null'')

SET @_contract = nullif(isnull(@_contract, nullif(''@contract'', replace(''@_contract'', ''@_'', ''@''))), ''null'')

SET @_hour_from = nullif(isnull(@_hour_from, nullif(''@hour_from'', replace(''@_hour_from'', ''@_'', ''@''))), ''null'')

SET @_hour_to = nullif(isnull(@_hour_to, nullif(''@hour_to'', replace(''@_hour_to'', ''@_'', ''@''))), ''null'')

SET @_block_group = nullif(isnull(@_block_group, nullif(''@block_group'', replace(''@_block_group'', ''@_'', ''@''))), ''null'')

SET @_parent_counterparty = nullif(isnull(@_parent_counterparty, nullif(''@parent_counterparty'', replace(''@_parent_counterparty'', ''@_'', ''@''))), ''null'')

SET @_deal_date_from = nullif(isnull(@_deal_date_from, nullif(''@deal_date_from'', replace(''@_deal_date_from'', ''@_'', ''@''))), ''null'')

SET @_deal_date_to = nullif(isnull(@_deal_date_to, nullif(''@deal_date_to'', replace(''@_deal_date_to'', ''@_'', ''@''))), ''null'')

SET @_block_type_group_id = nullif(isnull(@_block_type_group_id, nullif(''@block_type_group_id'', replace(''@_block_type_group_id'', ''@_'', ''@''))), ''null'')

SET @_deal_id = nullif(isnull(@_deal_id, nullif(''@deal_id'', replace(''@_deal_id'', ''@_'', ''@''))), ''null'')

SET @_trader_id = nullif(isnull(@_trader_id, nullif(''@trader_id'', replace(''@_trader_id'', ''@_'', ''@''))), ''null'')

SET @_template_id = nullif(isnull(@_template_id, nullif(''@template_id'', replace(''@_template_id'', ''@_'', ''@''))), ''null'')

SET @_product_id = nullif(isnull(@_product_id, nullif(''@product_id'', replace(''@_product_id'', ''@_'', ''@''))), ''null'')

SET @_mkt_con_flag = nullif(isnull(@_mkt_con_flag, nullif(''@mkt_con_flag'', replace(''@_mkt_con_flag'', ''@_'', ''@''))), ''null'')

SET @_group_by = nullif(isnull(@_group_by, nullif(''@group_by'', replace(''@_group_by'', ''@_'', ''@''))), ''null'')

SET @_convert_to_uom_id = nullif(isnull(@_convert_to_uom_id, nullif(''@convert_to_uom_id'', replace(''@_convert_to_uom_id'', ''@_'', ''@''))), ''null'')

SET @_physical_financial_flag = nullif(isnull(@_physical_financial_flag, nullif(''@physical_financial_flag'', replace(''@_physical_financial_flag'', ''@_'', ''@''))), ''null'')

SET @_include_actuals_from_shape = nullif(isnull(@_include_actuals_from_shape, nullif(''@include_actuals_from_shape'', replace(''@_include_actuals_from_shape'', ''@_'', ''@''))), ''null'')

SET @_show_delta_volume = nullif(isnull(@_show_delta_volume, nullif(''@show_delta_volume'', replace(''@_show_delta_volume'', ''@_'', ''@''))), ''null'')

SET @_leg = nullif(isnull(@_leg, nullif(''@leg'', replace(''@_leg'', ''@_'', ''@''))), ''null'')

SET @_formula_curve_id = nullif(isnull(@_formula_curve_id, nullif(''@formula_curve_id'', replace(''@_formula_curve_id'', ''@_'', ''@''))), ''null'')

SET @_forecast_profile_id = nullif(isnull(@_forecast_profile_id, nullif(''@forecast_profile_id'', replace(''@_forecast_profile_id'', ''@_'', ''@''))), ''null'')

SET @_shipper_code_id1 = nullif(isnull(@_shipper_code_id1, nullif(''@shipper_code_id1'', replace(''@_shipper_code_id1'', ''@_'', ''@''))), ''null'')

SET @_shipper_code_id2 = nullif(isnull(@_shipper_code_id2, nullif(''@shipper_code_id2'', replace(''@_shipper_code_id2'', ''@_'', ''@''))), ''null'')

SET @_show_delta_volume = isnull(@_show_delta_volume, ''n'')

SET @_pricing_type = NULLIF(ISNULL(@_pricing_type, NULLIF(''@pricing_type'', REPLACE(''@_pricing_type'', ''@_'', ''@''))), ''NULL'')

SET @_reporting_group1 = NULLIF(ISNULL(@_reporting_group1, NULLIF(''@reporting_group1'', REPLACE(''@_reporting_group1'', ''@_'', ''@''))), ''NULL'')

SET @_reporting_group2 = NULLIF(ISNULL(@_reporting_group2, NULLIF(''@reporting_group2'', REPLACE(''@_reporting_group2'', ''@_'', ''@''))), ''NULL'')

SET @_reporting_group3 = NULLIF(ISNULL(@_reporting_group3, NULLIF(''@reporting_group3'', REPLACE(''@_reporting_group3'', ''@_'', ''@''))), ''NULL'')

SET @_reporting_group4 = NULLIF(ISNULL(@_reporting_group4, NULLIF(''@reporting_group4'', REPLACE(''@_reporting_group4'', ''@_'', ''@''))), ''NULL'')

SET @_reporting_group5 = NULLIF(ISNULL(@_reporting_group5, NULLIF(''@reporting_group5'', REPLACE(''@_reporting_group5'', ''@_'', ''@''))), ''NULL'')

SET @_path_id = NULLIF(ISNULL(@_path_id,NULLIF(''@path_id'', REPLACE(''@_path_id'',''@_'',''@''))),''null'')

--SET @_path_id = NULL


DROP TABLE IF EXISTS #temp_mdq

CREATE TABLE #temp_mdq (			

	effective_date DATETIME,

	contract_ids INT ,

	path_id INT ,

	path_name VARCHAR(1000) , 

	hr VARCHAR(6),

	is_dst TINYINT,

	total_volume NUMERIC(38,18),

	available_volume NUMERIC(38,18)

)


INSERT INTO #temp_mdq (effective_date, contract_ids, path_id, path_name, hr, total_volume, available_volume)

EXEC spa_mdq_available ''v'',  '''',  @_term_start,  @_term_end, '''', ''n'','''', @_path_id

UPDATE #temp_mdq SET is_dst = IIF(CHARINDEX(''DST'', hr, 0) > 0, 1, 0), hr = REPLACE(hr, ''_DST'', '''')



if @_deal_type=''1900'' -- validation SQL

    EXEC dbo.spa_position_report @_summary_option = @_summary_option,  @_group_by = @_group_by,@_process_table=@_position_process_table

else


EXEC dbo.spa_position_report @_summary_option = @_summary_option, 

	@_sub_id = @_sub_id

	, @_stra_id = @_stra_id

	, @_book_id = @_book_id

	, @_sub_book_id = @_sub_book_id

	, @_as_of_date = @_as_of_date

	, @_source_deal_header_id = @_source_deal_header_id

	, @_period_from = @_period_from

	, @_period_to = @_period_to

	, @_tenor_option = @_tenor_option

	, @_location_id = @_location_id

	, @_curve_id = @_curve_id

	, @_commodity_id = @_commodity_id

	, @_deal_id = @_deal_id

	, @_location_group_id = @_location_group_id

	, @_grid = @_grid

	, @_country = @_country

	, @_region = @_region

	, @_province = @_province

	--, @_station_id = @_station_id

	--, @_dam_id = @_dam_id

	, @_deal_status = @_deal_status

	, @_confirm_status = @_confirm_status

	, @_profile = @_profile

	, @_term_start = @_term_start

	, @_term_end = @_term_end

	, @_deal_type = @_deal_type

	, @_deal_sub_type = @_deal_sub_type

	, @_buy_sell_flag = @_buy_sell_flag

	, @_counterparty = @_counterparty

	, @_contract = @_contract

	, @_hour_from = @_hour_from

	, @_hour_to = @_hour_to

	, @_block_group = @_block_group

	, @_parent_counterparty = @_parent_counterparty

	, @_deal_date_from = @_deal_date_from

	, @_deal_date_to = @_deal_date_to

	, @_block_type_group_id = @_block_type_group_id

	, @_trader_id = @_trader_id

	, @_convert_to_uom_id = @_convert_to_uom_id

	, @_physical_financial_flag = @_physical_financial_flag

	, @_include_actuals_from_shape = @_include_actuals_from_shape

	, @_leg = @_leg

	, @_format_option = @_format_option

	, @_group_by = @_group_by

	, @_round_value = @_round_value

	, @_convert_uom = @_convert_uom

	, @_col_7_to_6 = @_col_7_to_6

	, @_include_no_breakdown = @_include_no_breakdown

	, @_template_id = @_template_id

	, @_product_id = @_product_id

	, @_mkt_con_flag = @_mkt_con_flag

	,@_formula_curve_id = @_formula_curve_id

	,@_forecast_profile_id = @_forecast_profile_id

	,@_shipper_code_id1 =@_shipper_code_id1

	,@_shipper_code_id2 =@_shipper_code_id2

	,@_show_delta_volume = @_show_delta_volume

	,@_pricing_type = @_pricing_type

	,@_reporting_group1 = @_reporting_group1

	,@_reporting_group2 = @_reporting_group2

	,@_reporting_group3 = @_reporting_group3

	,@_reporting_group4 = @_reporting_group4

	,@_reporting_group5 = @_reporting_group5

	, @_process_table = @_process_table

	, @_batch_process_id = NULL

	

	SELECT 	

	effective_date,

	contract_ids  ,

	path_id ,

	path_name ,

	hr ,

	(hr + IIF(hr <= 18, 6, -18))  [gas_hr],

	CAST(IIF(hr >= 19, DATEADD(DAY, 1, effective_date), effective_date) AS DATE) [gas_hr_term],

	total_volume ,

	available_volume,

	@_term_start from_date,

	@_term_end to_date

	INTO #temp_mdq_data

FROM #temp_mdq


EXEC (''select tc.term_date, tm.[gas_hr] as hours, tc.location_id, tc.counterparty,[counterparty name], sum(tc.position) Position, [location], dv.path_id, dv.path_name,sum(tm.available_volume)  [aviliable volume], sum(tm.total_volume) [Total Volume], as_of_date, term_start, term_end

--[__batch_report__]

FROM '' + @_position_process_table +'' tc 

INNER JOIN  #temp_mdq_data tm ON tc.term_date = tm.gas_hr_term and tc.hours = tm.gas_hr

INNER JOIN delivery_path dv on dv.path_id = tm.path_id

where  

tc.location_id   in (dv.from_location)

AND tc.hours = tm.[gas_hr] 

Group by tc.term_date, tm.gas_hr, tc.location_id, tc.counterparty,[counterparty name], [location], dv.path_id, dv.path_name, as_of_date, term_start, term_end

order by location_id, tc.term_date, gas_hr'')



', report_id = @report_id_data_source_dest,
	system_defined = '0'
	,category = '106500' 
	WHERE [name] = 'Hourly Position Pipeline View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Hourly Position Pipeline View'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Hourly Position Pipeline View'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'As of Date' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Hourly Position Pipeline View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Hourly Position Pipeline View'
	            AND dsc.name =  'aviliable volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Aviliable Volume'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Hourly Position Pipeline View'
			AND dsc.name =  'aviliable volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'aviliable volume' AS [name], 'Aviliable Volume' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Hourly Position Pipeline View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Hourly Position Pipeline View'
	            AND dsc.name =  'counterparty'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty'
			   , reqd_param = NULL, widget_id = 7, datatype_id = 4, param_data_source = 'browse_counterparty', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Hourly Position Pipeline View'
			AND dsc.name =  'counterparty'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty' AS [name], 'Counterparty' AS ALIAS, NULL AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_counterparty' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Hourly Position Pipeline View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Hourly Position Pipeline View'
	            AND dsc.name =  'counterparty name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Hourly Position Pipeline View'
			AND dsc.name =  'counterparty name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty name' AS [name], 'Counterparty Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Hourly Position Pipeline View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Hourly Position Pipeline View'
	            AND dsc.name =  'hours'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Hours'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Hourly Position Pipeline View'
			AND dsc.name =  'hours'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'hours' AS [name], 'Hours' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Hourly Position Pipeline View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Hourly Position Pipeline View'
	            AND dsc.name =  'location'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Hourly Position Pipeline View'
			AND dsc.name =  'location'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location' AS [name], 'Location' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Hourly Position Pipeline View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Hourly Position Pipeline View'
	            AND dsc.name =  'location_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location ID'
			   , reqd_param = NULL, widget_id = 7, datatype_id = 4, param_data_source = 'browse_location', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Hourly Position Pipeline View'
			AND dsc.name =  'location_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_id' AS [name], 'Location ID' AS ALIAS, NULL AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_location' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Hourly Position Pipeline View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Hourly Position Pipeline View'
	            AND dsc.name =  'path_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Path Id'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_delivery_path ''w''', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Hourly Position Pipeline View'
			AND dsc.name =  'path_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'path_id' AS [name], 'Path Id' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_delivery_path ''w''' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Hourly Position Pipeline View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Hourly Position Pipeline View'
	            AND dsc.name =  'path_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Path Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Hourly Position Pipeline View'
			AND dsc.name =  'path_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'path_name' AS [name], 'Path Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Hourly Position Pipeline View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Hourly Position Pipeline View'
	            AND dsc.name =  'Position'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Position'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Hourly Position Pipeline View'
			AND dsc.name =  'Position'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Position' AS [name], 'Position' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Hourly Position Pipeline View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Hourly Position Pipeline View'
	            AND dsc.name =  'term_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Hourly Position Pipeline View'
			AND dsc.name =  'term_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_date' AS [name], 'Term Date' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Hourly Position Pipeline View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Hourly Position Pipeline View'
	            AND dsc.name =  'term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term End'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Hourly Position Pipeline View'
			AND dsc.name =  'term_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_end' AS [name], 'Term End' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Hourly Position Pipeline View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Hourly Position Pipeline View'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Hourly Position Pipeline View'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'Term Start' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Hourly Position Pipeline View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Hourly Position Pipeline View'
	            AND dsc.name =  'Total Volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Total Volume'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Hourly Position Pipeline View'
			AND dsc.name =  'Total Volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Total Volume' AS [name], 'Total Volume' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Hourly Position Pipeline View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Hourly Position Pipeline View'
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