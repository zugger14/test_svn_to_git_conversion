IF OBJECT_ID(N'[dbo].[spa_deal_copy]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_copy]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**	
	Deal Creation Logic when the deal is copied. Called when deal is copied.

	Parameters:
		@flag									:	Operation Flag. Does not accept NULL.
		@copy_deal_id							:	Deal ID which is to be copied.
		@header_xml								:	Deal Header fields and values built as XML.
		@detail_xml								:	Deal Detail fields and values built as XML.
		@header_cost_xml						:	Deal Header Cost field and values built as XML, when Header Cost is enabled.
		@header_cost_process_id					:	Unique Identifier used to build process table where Header Cost data are stored.
		@pricing_process_id						:	Unique Identifier used to build process table where Pricing data are stored.
		@shaped_process_id						:	Unique Identifier used to build process table where Shaped data are stored.
		@environment_process_id					:	Unique Identifier used to build process table where Environmental data are stored. Sent when Environment tab is enabled.
		@certificate_process_id					:	Unique Identifier used to build process table where Certificate data are stored. Sent when Certificate tab is enabled.
		@deal_price_data_process_id				:	Unique Identifier used to build process table where Deal Complex Pricing data are stored.
		@deal_provisional_price_data_process_id	:	Unique Identifier used to build process table where Deal Complex Provisional Pricing data are stored.
*/

CREATE PROCEDURE [dbo].[spa_deal_copy]
	@flag NCHAR(1),
	@copy_deal_id INT = NULL,    
	@header_xml XML = NULL,
	@detail_xml XML = NULL,
	@header_cost_xml XML = NULL,
	@header_cost_process_id NVARCHAR(200) = NULL,
	@pricing_process_id NVARCHAR(200) = NULL,
	@shaped_process_id NVARCHAR(200) = NULL,
	@environment_process_id NVARCHAR(200) = NULL,
	@certificate_process_id NVARCHAR(200) = NULL,
	@deal_price_data_process_id NVARCHAR(100) = NULL,
	@deal_provisional_price_data_process_id NVARCHAR(100) = NULL
AS

/*---------------------Debug Section---------------------------
EXEC sys.sp_set_session_context @key = N'DB_USER', @value = 'bkarki';
exec spa_drop_all_temp_table

DECLARE @flag NCHAR(1),
		@copy_deal_id INT = NULL,    
		@header_xml XML = NULL,
		@detail_xml XML = NULL,
		@header_cost_xml XML = NULL,
		@header_cost_process_id NVARCHAR(200) = NULL,
		@pricing_process_id NVARCHAR(200) = NULL,
		@shaped_process_id NVARCHAR(200) = NULL,
		@environment_process_id NVARCHAR(200) = NULL,
		@certificate_process_id NVARCHAR(200) = NULL,
		@deal_price_data_process_id NVARCHAR(100) = NULL,
		@deal_provisional_price_data_process_id NVARCHAR(100) = NULL

SELECT @flag = 's', @copy_deal_id = '105710', @header_xml = '<Root><FormXML  UDF___-1495="" ext_deal_id="" reference="" close_reference_id="" confirmation_type="" confirmation_template="" counterparty_id2="" counterparty2_trader="" internal_counterparty="" description1="" description2="" description3="" description4="" create_user="Shekhar  Ghimire" create_ts="2020-11-16 11:53:00" update_user="Bijan  Karki" update_ts="2021-11-22 06:31:00" sub_book="12" header_buy_sell_flag="b" deal_id="COPY_105710" deal_date="2020-10-09" counterparty_id="7715" trader_id="1206" contract_id="8210" entire_term_start="2020-11-01" entire_term_end="2021-12-31" broker_id="" block_define_id="" deal_status="5606" confirm_status_type="17200" deal_category_value_id="475" deal_locked="y" reporting_group1="" reporting_group2="" reporting_group3="" UDF___1759="" reporting_group4="" reporting_group5="" UDF___1342="" UDF___1958="" UDF___1959="" UDF___1953="" UDF___1346="" UDF___1760="" UDF___1761="" UDF___1762="" UDF___1763="" pricing="" fx_conversion_market="" payment_term="" payment_days="" template_id="2751" source_deal_type_id="2288" deal_sub_type_type_id="" internal_desk_id="17302" commodity_id="" pricing_type="46701" physical_financial_flag="p" granularity_id="" internal_portfolio_id="" profile_granularity="987" UDF___1796="" UDF___1722=""></FormXML></Root>', @detail_xml = '<GridXML>
	<GridRow row_id="1" is_break="n" deal_group="01.11.2021 - 31.12.2021" group_id="1" detail_flag="1" blotterleg="1" source_deal_detail_id="NEW_1_1109750ABA" lock_deal_detail="n" term_start="2020-11-01" term_end="2020-11-30" location_id="2848" profile_id="" meter_id="" curve_id="7227" upstream_counterparty="" upstream_contract="" deal_volume="-121.5076" multiplier="" actual_volume="" deal_volume_uom_id="1158" deal_volume_frequency="x" total_volume="9113.0664" position_uom="1159" fixed_price="" formula_curve_id="" price_adder="" formula_id="" fixed_price_currency_id="1109" fx_conversion_rate="" physical_financial_flag="p" Leg="1" cycle="" schedule_volume="" detail_commodity_id="123" settlement_date="" shipper_code1="" shipper_code2="" UDF___1919=""/>
	<GridRow row_id="1" is_break="n" deal_group="01.11.2021 - 31.12.2021" group_id="2" detail_flag="1" blotterleg="1" source_deal_detail_id="NEW_1_0FBDD9A5DC" lock_deal_detail="n" term_start="2020-12-01" term_end="2020-12-31" location_id="2848" profile_id="" meter_id="" curve_id="7227" upstream_counterparty="" upstream_contract="" deal_volume="" multiplier="" actual_volume="" deal_volume_uom_id="1158" deal_volume_frequency="x" total_volume="" position_uom="1159" fixed_price="" formula_curve_id="" price_adder="" formula_id="" fixed_price_currency_id="1109" fx_conversion_rate="" physical_financial_flag="p" Leg="1" cycle="" schedule_volume="" detail_commodity_id="123" settlement_date="" shipper_code1="" shipper_code2="" UDF___1919=""/>
	<GridRow row_id="1" is_break="n" deal_group="01.11.2021 - 31.12.2021" group_id="3" detail_flag="1" blotterleg="1" source_deal_detail_id="NEW_1_222F270B4C" lock_deal_detail="n" term_start="2021-01-01" term_end="2021-01-31" location_id="2855" profile_id="" meter_id="" curve_id="7227" upstream_counterparty="" upstream_contract="" deal_volume="-305.1755" multiplier="" actual_volume="" deal_volume_uom_id="1158" deal_volume_frequency="x" total_volume="37231.4134" position_uom="1159" fixed_price="" formula_curve_id="" price_adder="" formula_id="" fixed_price_currency_id="1109" fx_conversion_rate="" physical_financial_flag="p" Leg="1" cycle="" schedule_volume="" detail_commodity_id="123" settlement_date="" shipper_code1="729" shipper_code2="729" UDF___1919=""/>
	<GridRow row_id="1" is_break="n" deal_group="01.11.2021 - 31.12.2021" group_id="4" detail_flag="1" blotterleg="1" source_deal_detail_id="NEW_1_3451AF0C0E" lock_deal_detail="n" term_start="2021-02-01" term_end="2021-02-28" location_id="2855" profile_id="" meter_id="" curve_id="7227" upstream_counterparty="" upstream_contract="" deal_volume="1520.4754" multiplier="" actual_volume="" deal_volume_uom_id="1158" deal_volume_frequency="x" total_volume="109474.2302" position_uom="1159" fixed_price="" formula_curve_id="" price_adder="" formula_id="" fixed_price_currency_id="1109" fx_conversion_rate="" physical_financial_flag="p" Leg="1" cycle="" schedule_volume="" detail_commodity_id="123" settlement_date="" shipper_code1="729" shipper_code2="729" UDF___1919=""/>
	<GridRow row_id="1" is_break="n" deal_group="01.11.2021 - 31.12.2021" group_id="5" detail_flag="1" blotterleg="1" source_deal_detail_id="NEW_1_646A45B9F9" lock_deal_detail="n" term_start="2021-03-01" term_end="2021-03-31" location_id="2855" profile_id="" meter_id="" curve_id="7227" upstream_counterparty="" upstream_contract="" deal_volume="1234.2451" multiplier="" actual_volume="" deal_volume_uom_id="1158" deal_volume_frequency="x" total_volume="88865.647" position_uom="1159" fixed_price="" formula_curve_id="" price_adder="" formula_id="" fixed_price_currency_id="1109" fx_conversion_rate="" physical_financial_flag="p" Leg="1" cycle="" schedule_volume="" detail_commodity_id="123" settlement_date="" shipper_code1="729" shipper_code2="729" UDF___1919=""/>
	<GridRow row_id="1" is_break="n" deal_group="01.11.2021 - 31.12.2021" group_id="6" detail_flag="1" blotterleg="1" source_deal_detail_id="NEW_1_E5F137C30D" lock_deal_detail="n" term_start="2021-04-01" term_end="2021-04-30" location_id="2855" profile_id="" meter_id="" curve_id="7227" upstream_counterparty="" upstream_contract="" deal_volume="1131.4864" multiplier="" actual_volume="" deal_volume_uom_id="1158" deal_volume_frequency="x" total_volume="108622.6957" position_uom="1159" fixed_price="" formula_curve_id="" price_adder="" formula_id="" fixed_price_currency_id="1109" fx_conversion_rate="" physical_financial_flag="p" Leg="1" cycle="" schedule_volume="" detail_commodity_id="123" settlement_date="" shipper_code1="729" shipper_code2="729" UDF___1919=""/>
	<GridRow row_id="1" is_break="n" deal_group="01.11.2021 - 31.12.2021" group_id="7" detail_flag="1" blotterleg="1" source_deal_detail_id="NEW_1_5563D928DA" lock_deal_detail="n" term_start="2021-05-01" term_end="2021-05-31" location_id="2855" profile_id="" meter_id="" curve_id="7227" upstream_counterparty="" upstream_contract="" deal_volume="" multiplier="" actual_volume="" deal_volume_uom_id="1158" deal_volume_frequency="x" total_volume="" position_uom="1159" fixed_price="" formula_curve_id="" price_adder="" formula_id="" fixed_price_currency_id="1109" fx_conversion_rate="" physical_financial_flag="p" Leg="1" cycle="" schedule_volume="" detail_commodity_id="123" settlement_date="" shipper_code1="729" shipper_code2="729" UDF___1919=""/>
	<GridRow row_id="1" is_break="n" deal_group="01.11.2021 - 31.12.2021" group_id="8" detail_flag="1" blotterleg="1" source_deal_detail_id="NEW_1_6F042421EB" lock_deal_detail="n" term_start="2021-06-01" term_end="2021-06-30" location_id="2855" profile_id="" meter_id="" curve_id="7227" upstream_counterparty="" upstream_contract="" deal_volume="" multiplier="" actual_volume="" deal_volume_uom_id="1158" deal_volume_frequency="x" total_volume="" position_uom="1159" fixed_price="" formula_curve_id="" price_adder="" formula_id="" fixed_price_currency_id="1109" fx_conversion_rate="" physical_financial_flag="p" Leg="1" cycle="" schedule_volume="" detail_commodity_id="123" settlement_date="" shipper_code1="729" shipper_code2="729" UDF___1919=""/>
	<GridRow row_id="1" is_break="n" deal_group="01.11.2021 - 31.12.2021" group_id="9" detail_flag="1" blotterleg="1" source_deal_detail_id="NEW_1_AE29773A69" lock_deal_detail="n" term_start="2021-07-01" term_end="2021-07-31" location_id="2855" profile_id="" meter_id="" curve_id="7227" upstream_counterparty="" upstream_contract="" deal_volume="" multiplier="" actual_volume="" deal_volume_uom_id="1158" deal_volume_frequency="x" total_volume="" position_uom="1159" fixed_price="" formula_curve_id="" price_adder="" formula_id="" fixed_price_currency_id="1109" fx_conversion_rate="" physical_financial_flag="p" Leg="1" cycle="" schedule_volume="" detail_commodity_id="123" settlement_date="" shipper_code1="729" shipper_code2="729" UDF___1919=""/>
	<GridRow row_id="1" is_break="n" deal_group="01.11.2021 - 31.12.2021" group_id="10" detail_flag="1" blotterleg="1" source_deal_detail_id="NEW_1_E97874DE23" lock_deal_detail="n" term_start="2021-08-01" term_end="2021-08-31" location_id="2855" profile_id="" meter_id="" curve_id="7227" upstream_counterparty="" upstream_contract="" deal_volume="" multiplier="" actual_volume="" deal_volume_uom_id="1158" deal_volume_frequency="x" total_volume="" position_uom="1159" fixed_price="" formula_curve_id="" price_adder="" formula_id="" fixed_price_currency_id="1109" fx_conversion_rate="" physical_financial_flag="p" Leg="1" cycle="" schedule_volume="" detail_commodity_id="123" settlement_date="" shipper_code1="729" shipper_code2="729" UDF___1919=""/>
	<GridRow row_id="1" is_break="n" deal_group="01.11.2021 - 31.12.2021" group_id="11" detail_flag="1" blotterleg="1" source_deal_detail_id="NEW_1_1331C577D2" lock_deal_detail="n" term_start="2021-09-01" term_end="2021-09-30" location_id="2855" profile_id="" meter_id="" curve_id="7227" upstream_counterparty="" upstream_contract="" deal_volume="" multiplier="" actual_volume="" deal_volume_uom_id="1158" deal_volume_frequency="x" total_volume="" position_uom="1159" fixed_price="" formula_curve_id="" price_adder="" formula_id="" fixed_price_currency_id="1109" fx_conversion_rate="" physical_financial_flag="p" Leg="1" cycle="" schedule_volume="" detail_commodity_id="123" settlement_date="" shipper_code1="729" shipper_code2="729" UDF___1919=""/>
	<GridRow row_id="1" is_break="n" deal_group="01.11.2021 - 31.12.2021" group_id="12" detail_flag="1" blotterleg="1" source_deal_detail_id="NEW_1_7DAC158EA4" lock_deal_detail="n" term_start="2021-10-01" term_end="2021-10-31" location_id="2855" profile_id="" meter_id="" curve_id="7227" upstream_counterparty="" upstream_contract="" deal_volume="1644.4953" multiplier="" actual_volume="" deal_volume_uom_id="1158" deal_volume_frequency="x" total_volume="41112.3813" position_uom="1159" fixed_price="" formula_curve_id="" price_adder="" formula_id="" fixed_price_currency_id="1109" fx_conversion_rate="" physical_financial_flag="p" Leg="1" cycle="" schedule_volume="" detail_commodity_id="123" settlement_date="" shipper_code1="729" shipper_code2="729" UDF___1919=""/>
	<GridRow row_id="1" is_break="n" deal_group="01.11.2021 - 31.12.2021" group_id="13" detail_flag="1" blotterleg="1" source_deal_detail_id="NEW_1_BC3EED47E4" lock_deal_detail="n" term_start="2021-11-01" term_end="2021-11-30" location_id="2855" profile_id="" meter_id="" curve_id="7227" upstream_counterparty="" upstream_contract="" deal_volume="1152.2829" multiplier="" actual_volume="" deal_volume_uom_id="1158" deal_volume_frequency="x" total_volume="27654.7907" position_uom="1159" fixed_price="" formula_curve_id="" price_adder="" formula_id="" fixed_price_currency_id="1109" fx_conversion_rate="" physical_financial_flag="p" Leg="1" cycle="" schedule_volume="" detail_commodity_id="123" settlement_date="" shipper_code1="729" shipper_code2="729" UDF___1919=""/>
	<GridRow row_id="1" is_break="n" deal_group="01.11.2021 - 31.12.2021" group_id="14" detail_flag="1" blotterleg="1" source_deal_detail_id="NEW_1_FA6F9957A3" lock_deal_detail="n" term_start="2021-12-01" term_end="2021-12-31" location_id="2855" profile_id="" meter_id="" curve_id="7227" upstream_counterparty="" upstream_contract="" deal_volume="" multiplier="" actual_volume="" deal_volume_uom_id="1158" deal_volume_frequency="x" total_volume="" position_uom="1159" fixed_price="" formula_curve_id="" price_adder="" formula_id="" fixed_price_currency_id="1109" fx_conversion_rate="" physical_financial_flag="p" Leg="1" cycle="" schedule_volume="" detail_commodity_id="123" settlement_date="" shipper_code1="729" shipper_code2="729" UDF___1919=""/>
</GridXML>', @header_cost_xml = '<GridXML><GridRow  
seq_no="0"  cost_id="270" cost_name="Commodity Energy Tax" internal_field_type_id="18745" internal_field_type="Energy Tax" udf_value="67" currency_id="" uom_id="" 
counterparty_id="" contract_id="" receive_pay="" udf_field_type="w" settlement_date="" settlement_calendar="" settlement_days="" payment_date="" payment_calendar="" payment_days="" fixed_fx_rate=""></GridRow><GridRow  seq_no="1"  cost_id="271" cost_name="Positive Price Commodity VAT" internal_field_type_id="18744" internal_field_type="VAT" udf_value="65" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" udf_field_type="w" settlement_date="" settlement_calendar="" settlement_days="" payment_date="" payment_calendar="" payment_days="" fixed_fx_rate=""></GridRow><GridRow  seq_no="2"  cost_id="272" cost_name="Negative Price Commodity VAT" internal_field_type_id="18744" internal_field_type="VAT" udf_value="66" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" udf_field_type="w" settlement_date="" settlement_calendar="" settlement_days="" payment_date="" payment_calendar="" payment_days="" fixed_fx_rate=""></GridRow><GridRow  seq_no="3"  cost_id="-1742" cost_name="Clearing Fees" internal_field_type_id="18700" internal_field_type="Position based fee" udf_value="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" udf_field_type="t" settlement_date="" settlement_calendar="" settlement_days="" payment_date="" payment_calendar="" payment_days="" fixed_fx_rate=""></GridRow><GridRow  seq_no="4"  cost_id="-1856" cost_name="Transportation Fees" internal_field_type_id="18730" internal_field_type="Fees" udf_value="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" udf_field_type="t" settlement_date="" settlement_calendar="" settlement_days="" payment_date="" payment_calendar="" payment_days="" fixed_fx_rate=""></GridRow></GridXML>', @header_cost_process_id = 'EFCE22A3_6B91_4A21_A6DA_1E7F8DF54D28', @pricing_process_id = '', @shaped_process_id = 'A48EAA1B_C357_42BD_B0E3_C32AB62B68B5', @environment_process_id = '', @certificate_process_id = '', @deal_price_data_process_id = 'D9923478_4266_45FD_BCDF_BC7CE2D2055A', @deal_provisional_price_data_process_id = 'E1EC93A4_FF19_4AC4_AC25_394F9EB5C510'


----------------------------------------------------------------------------*/
SET NOCOUNT ON
DECLARE @SQL NVARCHAR(MAX)
 
IF @flag = 's'
BEGIN
	IF OBJECT_ID('tempdb..#temp_copy_sdh') IS NOT NULL
		DROP TABLE #temp_copy_sdh
			
	DECLARE @header_process_table NVARCHAR(200),
			@detail_process_table NVARCHAR(200),
			@user_name NVARCHAR(200) = dbo.FNADBUser(),
			@process_id NVARCHAR(200) = dbo.FNAGETNewID(),
			@deal_id INT,
			@template_id INT,
			@term_frequency NCHAR(1),
			@header_costs_xml_table NVARCHAR(200),
			@header_costs_table NVARCHAR(200),
			@enable_document_tab NCHAR(1),
			@enable_deal_remarks NCHAR(1),
			@min_value NVARCHAR(200), 
			@max_value NVARCHAR(200),
			@column_name NVARCHAR(200),
			@err_msg NVARCHAR(MAX),
			@field_template_id     INT

	SELECT @template_id = template_id
	FROM source_deal_header
	WHERE source_deal_header_id = @copy_deal_id
	
	SELECT @enable_document_tab = sdht.enable_document_tab, @enable_deal_remarks = sdht.enable_remarks, @field_template_id = sdht.field_template_id
	FROM source_deal_header sdh 
	INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
	WHERE sdh.source_deal_header_id = @copy_deal_id
	
	DECLARE @enable_environemet NCHAR
	SELECT @enable_environemet = sdh.is_environmental
	FROM source_deal_header sdh
	WHERE sdh.source_deal_header_id = @copy_deal_id
			
	IF @header_xml IS NULL OR @detail_xml IS NULL
	BEGIN
		EXEC spa_ErrorHandler -1, 'spa_insert_blotter_deal', 'spa_insert_blotter_deal', 'DB Error', 'Incomplete information.', ''
		RETURN
	END
		
	IF @header_xml IS NOT NULL
	BEGIN
		SET @header_process_table = dbo.FNAProcessTableName('header_xml_table', @user_name, @process_id)		
		EXEC spa_parse_xml_file 'b', NULL, @header_xml, @header_process_table
		
		IF OBJECT_ID('tempdb..#field_template') IS NOT NULL
			DROP TABLE #field_template

		CREATE TABLE #field_template (
			farrms_field_id NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			field_label NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			default_value NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			data_type NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			is_udf NCHAR(1) COLLATE DATABASE_DEFAULT,
			insert_required NCHAR(1) COLLATE DATABASE_DEFAULT,
			update_required NCHAR(1) COLLATE DATABASE_DEFAULT,
			min_value NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			max_value NVARCHAR(200) COLLATE DATABASE_DEFAULT
		)

		INSERT #field_template
		SELECT *
		FROM FNAGetTemplateFieldTable(@template_id, 'h', 'y') j

		IF OBJECT_ID('tempdb..#temp_min_max_error_handler') IS NOT NULL
			DROP TABLE #temp_min_max_error_handler
		
		CREATE TABLE #temp_min_max_error_handler (
			err_id INT IDENTITY(1,1),
			column_name NVARCHAR(300) COLLATE DATABASE_DEFAULT,
			error_type NVARCHAR(10) COLLATE DATABASE_DEFAULT
		)

		DECLARE min_max_columns_cursor CURSOR  
		FOR
			SELECT ft.farrms_field_id,
				   ft.max_value,
				   ft.min_value
			FROM #field_template ft
			WHERE (ft.min_value IS NOT NULL OR ft.max_value IS NOT NULL)
				AND (ISNULL(ft.min_value,0) <> ISNULL(ft.max_value, 0))
		OPEN min_max_columns_cursor
		FETCH NEXT FROM min_max_columns_cursor INTO @column_name, @max_value, @min_value
		WHILE @@FETCH_STATUS = 0   
		BEGIN
			SET @sql = 'INSERT INTO #temp_min_max_error_handler '
			DECLARE @min_val_check INT = 0
			
			IF @min_value IS NOT NULL
			BEGIN
				SET @sql += ' SELECT ''' + @column_name + ''', ''go beneath''
							  FROM ' + @header_process_table + '
							  WHERE ' + @column_name + ' < ' + @min_value + ''
				SET @min_val_check = 1
			END	
			
			IF @max_value IS NOT NULL
			BEGIN
				SET @sql += CASE WHEN @min_val_check = 1 THEN ' UNION ALL ' ELSE '' END + '
							SELECT ''' + @column_name + ''', ''exceed''
							FROM ' + @header_process_table + '
							WHERE ' + @column_name + ' > ' + @max_value + ''
			END		
			--PRINT(@sql)
			EXEC(@sql)
		
			FETCH NEXT FROM min_max_columns_cursor INTO @column_name, @max_value, @min_value	
		END
		CLOSE min_max_columns_cursor
		DEALLOCATE min_max_columns_cursor
		
		IF EXISTS (SELECT 1 FROM #temp_min_max_error_handler)
		BEGIN
			SELECT TOP(1) @err_msg = 'Value for ' + ft.field_label + ' should not ' + tnne.error_type + ' ' + CASE WHEN tnne.error_type = 'exceed' THEN ft.max_value ELSE ft.min_value END
			FROM #temp_min_max_error_handler tnne
			INNER JOIN #field_template ft ON ft.farrms_field_id = tnne.column_name 
			
			EXEC spa_ErrorHandler -1, 'spa_deal_copy', 'spa_deal_copy', 'DB Error', @err_msg, ''
			RETURN
		END
		ELSE
		BEGIN
			DROP TABLE #temp_min_max_error_handler
		END
		
		SELECT *
		INTO #temp_copy_sdh
		FROM source_deal_header
		WHERE source_deal_header_id = @copy_deal_id

		--UPDATE #temp_copy_sdh 
		--SET close_reference_id = @copy_deal_id 
		--WHERE source_deal_header_id = @copy_deal_id
		
		IF OBJECT_ID('tempdb..#temp_header_columns') IS NOT NULL
			DROP TABLE #temp_header_columns
		
		IF OBJECT_ID('tempdb..#temp_sdh') IS NOT NULL
			DROP TABLE #temp_sdh
			
		CREATE TABLE #temp_header_columns (
			columns_name NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
			columns_value NVARCHAR(800) COLLATE DATABASE_DEFAULT 
		)
		CREATE TABLE #temp_sdh(
			columns_name NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
			data_type NVARCHAR(200) COLLATE DATABASE_DEFAULT 
		)
		
		DECLARE @table_name NVARCHAR(200) = REPLACE(@header_process_table, 'adiha_process.dbo.', '')
		
		INSERT INTO #temp_header_columns	
		EXEC spa_Transpose @table_name, NULL, 1

		--update deal_id if deal reference id is null with copy
		UPDATE thc
		SET columns_value = 'COPY_' + CONVERT(VARCHAR(10), original.source_deal_header_id)-- + '_' + CONVERT(VARCHAR(10), copi.source_deal_header_id)
		FROM #temp_header_columns thc
		CROSS APPLY (SELECT source_deal_header_id source_deal_header_id FROM #temp_copy_sdh) original
		CROSS APPLY (SELECT MAX(source_deal_header_id) + 1 source_deal_header_id FROM source_deal_header) copi
		WHERE thc.columns_name = 'deal_id'
			AND thc.columns_value IS NULL

		INSERT INTO #temp_sdh
		SELECT column_name,
			   DATA_TYPE
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'source_deal_header'
		
		DECLARE @update_string NVARCHAR(MAX),
				@insert_string NVARCHAR(MAX),
				@SELECT_string NVARCHAR(MAX),
				@h_udf_update_string NVARCHAR(MAX)
		
		SELECT @update_string = COALESCE(@update_string + ',', '') + tsdh.columns_name + ISNULL(' = N''' + CASE WHEN tsdh.data_type = 'datetime' THEN dbo.FNAGetSQLStandardDate(thc.columns_value) ELSE CAST(thc.columns_value AS NVARCHAR(MAX)) END + '''', '= NULL')
		FROM #temp_header_columns thc
		INNER JOIN #temp_sdh tsdh ON tsdh.columns_name = thc.columns_name
		WHERE tsdh.columns_name NOT IN ('source_deal_header_id', 'update_ts', 'update_user', 'create_ts', 'create_user', 'template_id', 'close_reference_id')
		AND thc.columns_name NOT LIKE '%UDF___%'
		
		SELECT @insert_string = COALESCE(@insert_string + ',', '') + tsdh.columns_name
		FROM #temp_sdh tsdh
		WHERE tsdh.columns_name NOT IN ('source_deal_header_id', 'update_ts', 'update_user', 'create_ts', 'create_user', 'reference_detail_id')
		
		SET @sql = ' 
			UPDATE sdh
			SET ' + @update_string + '
			FROM #temp_copy_sdh sdh
		'
		--PRINT(@sql)
		EXEC(@sql)
	END
	
	IF @detail_xml IS NOT NULL
	BEGIN	
		SET @detail_process_table = dbo.FNAProcessTableName('detail_xml_table', @user_name, @process_id)			
		EXEC spa_parse_xml_file 'b', NULL, @detail_xml, @detail_process_table
		
		IF EXISTS (
			SELECT 1
			FROM maintain_field_template_detail d
			INNER JOIN maintain_field_deal f
				ON  d.field_id = f.field_id
			INNER JOIN source_deal_header_template sdht
				ON sdht.field_template_id = d.field_template_id
			INNER JOIN source_deal_detail_template sddt
				ON sddt.template_id = sdht.template_id
			WHERE farrms_field_id = 'vintage' 
				AND udf_or_system = 's'
				AND sdht.template_id = @template_id
		)
		BEGIN
			SET @sql = '
				IF COL_LENGTH(''' + @detail_process_table + ''', ''term_start'') IS NULL
				BEGIN
					ALTER TABLE ' + @detail_process_table + ' ADD term_start DATETIME
				END
				
				IF COL_LENGTH(''' + @detail_process_table + ''', ''term_end'') IS NULL
				BEGIN
					ALTER TABLE ' + @detail_process_table + ' ADD term_end DATETIME
				END

				IF COL_LENGTH(''' + @detail_process_table + ''', ''vintage'') IS NULL
				BEGIN
					ALTER TABLE ' + @detail_process_table + ' ADD vintage NVARCHAR(10)
				END
			'
			EXEC (@sql)

			SET @sql = '
				UPDATE dxt
				SET dxt.term_start = CONVERT(DATE, ISNULL(sdv.code, 1900) + ''-01-01'', 120), 
						dxt.term_end = CONVERT(DATE, ISNULL(sdv.code, 1900) + ''-12-31'', 120)
				FROM ' + @detail_process_table + ' dxt
				INNER JOIN static_data_value sdv
					ON sdv.value_id = dxt.vintage
						AND sdv.type_id = 10092
			'

			EXEC(@sql)
			
			SET @sql = '
				UPDATE dxt
				SET dxt.vintage = sdv.value_id 
				FROM ' + @detail_process_table + ' dxt
				INNER JOIN static_data_value sdv
					ON sdv.code = YEAR(dxt.term_start)
						AND sdv.type_id = 10092
			'
			EXEC(@sql)
		END
			

		IF OBJECT_ID('tempdb..#field_template_detail') IS NOT NULL
			DROP TABLE #field_template_detail

		CREATE TABLE #field_template_detail (
			farrms_field_id NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			field_label NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			default_value NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			data_type NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			is_udf NCHAR(1) COLLATE DATABASE_DEFAULT,
			insert_required NCHAR(1) COLLATE DATABASE_DEFAULT,
			update_required NCHAR(1) COLLATE DATABASE_DEFAULT,
			min_value NVARCHAR(200) COLLATE DATABASE_DEFAULT,				
			max_value NVARCHAR(200) COLLATE DATABASE_DEFAULT
		)
			
		INSERT #field_template_detail
		SELECT *
		FROM FNAGetTemplateFieldTable(@template_id, 'd', 'y') j 

		IF OBJECT_ID('tempdb..#temp_min_max_error_handler_detail') IS NOT NULL
			DROP TABLE #temp_min_max_error_handler_detail
		
		CREATE TABLE #temp_min_max_error_handler_detail (
			err_id INT IDENTITY(1,1),
			column_name NVARCHAR(300) COLLATE DATABASE_DEFAULT,
			error_type NVARCHAR(10) COLLATE DATABASE_DEFAULT
		)

		DECLARE min_max_columns_cursor_detail CURSOR  
		FOR
			SELECT ft.farrms_field_id,
				   ft.max_value,
				   ft.min_value
			FROM #field_template_detail ft
			WHERE (ft.min_value IS NOT NULL OR ft.max_value IS NOT NULL)
				AND (ISNULL(ft.min_value,0) <> ISNULL(ft.max_value, 0))
		OPEN min_max_columns_cursor_detail
		FETCH NEXT FROM min_max_columns_cursor_detail INTO @column_name, @max_value, @min_value
		WHILE @@FETCH_STATUS = 0   
		BEGIN
			SET @sql = 'INSERT INTO #temp_min_max_error_handler_detail '
			DECLARE @min_val_check_detail INT = 0
			
			IF @min_value IS NOT NULL
			BEGIN
				SET @sql += ' 
					SELECT ''' + @column_name + ''', ''go beneath''
					FROM ' + @detail_process_table + '
					WHERE ' + @column_name + ' < ' + @min_value + ''
				SET @min_val_check_detail = 1
			END	
			
			IF @max_value IS NOT NULL
			BEGIN
				SET @sql += CASE WHEN @min_val_check_detail = 1 THEN ' UNION ALL ' ELSE '' END + '
					SELECT ''' + @column_name + ''', ''exceed''
					FROM ' + @detail_process_table + '
					WHERE ' + @column_name + ' > ' + @max_value + ''
			END		
			--PRINT(@sql)
			EXEC(@sql)
		
			FETCH NEXT FROM min_max_columns_cursor_detail INTO @column_name, @max_value, @min_value	
		END
		CLOSE min_max_columns_cursor_detail
		DEALLOCATE min_max_columns_cursor_detail
		
		IF EXISTS (SELECT 1 FROM #temp_min_max_error_handler_detail)
		BEGIN
			SELECT TOP(1) @err_msg = 'Value for ' + ft.field_label + ' should not ' + tnne.error_type + ' ' + CASE WHEN tnne.error_type = 'exceed' THEN ft.max_value ELSE ft.min_value END
			FROM #temp_min_max_error_handler_detail tnne
			INNER JOIN #field_template_detail ft ON ft.farrms_field_id = tnne.column_name 
			
			EXEC spa_ErrorHandler -1, 'spa_deal_copy', 'spa_deal_copy', 'DB Error', @err_msg, ''

			IF @@TRANCOUNT > 0
				ROLLBACK
			RETURN
		END
		ELSE
		BEGIN
			DROP TABLE #temp_min_max_error_handler_detail
		END
		
		IF OBJECT_ID('tempdb..#detail_xml_columns') IS NOT NULL
			DROP TABLE #detail_xml_columns
			
		CREATE TABLE #detail_xml_columns (
			id INT IDENTITY(1, 1),
			column_name NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			data_type NVARCHAR(2000) COLLATE DATABASE_DEFAULT
		)

		DECLARE @detail_table_name NVARCHAR(200) = REPLACE(@detail_process_table, 'adiha_process.dbo.', '')
		
		INSERT INTO #detail_xml_columns(column_name, data_type)
		SELECT COLUMN_NAME, DATA_TYPE
		FROM adiha_process.INFORMATION_SCHEMA.COLUMNS WITH(NOLOCK)
		WHERE TABLE_NAME = @detail_table_name
		
		DECLARE @detail_update_list NVARCHAR(MAX),
				@detail_insert_list NVARCHAR(MAX),
				@detail_create_list NVARCHAR(MAX),
				@detail_SELECT_list NVARCHAR(MAX),
				@detail_final_insert_list NVARCHAR(MAX),
				@detail_final_SELECT_list NVARCHAR(MAX),
				@udf_insert NVARCHAR(MAX),
				@udf_create NVARCHAR(MAX),
				@udf_SELECT NVARCHAR(MAX)
				
		SELECT @detail_SELECT_list = COALESCE(@detail_SELECT_list + ',', '') + 'NULLIF(LTRIM(RTRIM(temp.' + dxc.column_name + ')), '''') ',
			   @detail_insert_list = COALESCE(@detail_insert_list + ',', '') + dxc.column_name
		FROM #detail_xml_columns dxc
		WHERE dxc.column_name NOT IN ('deal_group', 'group_id', 'detail_flag', 'row_id', 'is_break', 'blotterleg', 'source_deal_detail_id', 'leg', 'update_ts', 'update_user', 'create_ts', 'create_user', 'source_deal_header_id', 'total_volume')
			AND dxc.column_name NOT LIKE '%UDF___%'
		
		SELECT @udf_insert = COALESCE(@udf_insert + ',', '') + '[' + dxc.column_name + ']',
			   @udf_SELECT = COALESCE(@udf_SELECT + ',', '') + 'NULLIF(LTRIM(RTRIM(temp.[' + dxc.column_name + '])), '''') ',
			   @udf_create = COALESCE(@udf_create + ',', '') + '[' + dxc.column_name + '] NVARCHAR(MAX)'
		FROM #detail_xml_columns dxc
		WHERE dxc.column_name LIKE '%UDF___%'
		
		IF @udf_insert IS NULL
		BEGIN
			SET @udf_insert = ''
			SET @udf_SELECT = ''
			SET @udf_create = ''
		END
		ELSE 
		BEGIN
			SET @udf_insert = ',' + @udf_insert
			SET @udf_SELECT = ',' + @udf_SELECT
			SET @udf_create = ',' + @udf_create
		END
				
		IF OBJECT_ID('tempdb..#temp_sdd') IS NOT NULL
			DROP TABLE #temp_sdd
			
		CREATE TABLE #temp_sdd(
			columns_name NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
			data_type NVARCHAR(200) COLLATE DATABASE_DEFAULT 
		)
		
		INSERT INTO #temp_sdd
		SELECT column_name,
			   CASE DATA_TYPE WHEN 'Numeric' THEN 'NUMERIC(38, 20)' WHEN 'NCHAR' THEN 'NCHAR(1) ' WHEN 'NVARCHAR' THEN 'NVARCHAR(2000) ' ELSE DATA_TYPE END
		FROM INFORMATION_SCHEMA.Columns
		WHERE TABLE_NAME = 'source_deal_detail'
		
		SELECT @detail_final_insert_list = COALESCE(@detail_final_insert_list + ',', '') + tsdh.columns_name,
			   @detail_final_SELECT_list = COALESCE(@detail_final_SELECT_list + ',', '') + 'COALESCE(temp.' + tsdh.columns_name + ', sdd.' + tsdh.columns_name + ',sddt.' + tsdh.columns_name + ') AS [' + tsdh.columns_name + ']',
			   @detail_create_list = COALESCE(@detail_create_list + ',', '') + tsdh.columns_name + ' ' + tsdh.data_type
		FROM #temp_sdd tsdh
		WHERE tsdh.columns_name NOT IN (
			'buy_sell_flag',
			'fixed_float_leg',
			'contract_expiration_date',
			'source_deal_header_id',
			'update_ts',
			'update_user',
			'create_ts',
			'create_user',
			'source_deal_detail_id',
			'leg',
			'source_deal_group_id',
			'pricing_type',
			'pricing_period',
			'event_defination',
			'apply_to_all_legs',
			'deal_volume_frequency',
			'deal_volume_uom_id',
			'total_volume',
			'shipper_code1',
			'shipper_code2'
		)
		
		IF OBJECT_ID('tempdb..#temp_source_deal_detail') IS NOT NULL
			DROP TABLE #temp_source_deal_detail
			
		CREATE TABLE #temp_source_deal_detail (
			sno INT IDENTITY(1,1)
		)		
		SET @sql = ' ALTER TABLE #temp_source_deal_detail ADD ' + @detail_create_list + ', detail_flag INT, leg INT, source_deal_header_id INT, group_id INT, group_name NVARCHAR(1000)  COLLATE DATABASE_DEFAULT, contract_expiration_date DATETIME, buy_sell_flag NCHAR(1) COLLATE DATABASE_DEFAULT  , fixed_float_leg NCHAR(1)  COLLATE DATABASE_DEFAULT, deal_volume_frequency NCHAR(1) COLLATE DATABASE_DEFAULT, deal_volume_uom_id INT,  shipper_code1 NVARCHAR(25) COLLATE DATABASE_DEFAULT, shipper_code2 NVARCHAR(25) COLLATE DATABASE_DEFAULT' + @udf_create
		--PRINT(@sql)
		EXEC(@sql)
		
		SET @sql = 'INSERT INTO #temp_source_deal_detail (leg, group_id, detail_flag, group_name, ' + @detail_insert_list + @udf_insert + ')
					SELECT temp.blotterleg, temp.group_id, temp.detail_flag, temp.deal_group, ' + @detail_SELECT_list + @udf_SELECT + '
					FROM ' + @detail_process_table + ' temp	
					WHERE is_break = ''y''					
				'
		--PRINT(@sql)
		EXEC(@sql)
		
		-- Delete data from xml table if it is present in term level breakdown detail level process table
		SET @sql = '
			DELETE dxt
			FROM ' + @detail_process_table + ' dxt
			WHERE is_break = ''y''
		'

		EXEC(@sql)
		
		IF OBJECT_ID('tempdb..#temp_break_down_data') IS NOT NULL
			DROP TABLE #temp_break_down_data
		
		SELECT * INTO #temp_break_down_data FROM #temp_source_deal_detail WHERE 1 = 2
		
		SET @sql = '
			INSERT INTO #temp_break_down_data (leg, group_id, group_name, ' + @detail_insert_list + @udf_insert + ')
			SELECT temp.blotterleg, temp.group_id, deal_group, ' + @detail_SELECT_list + @udf_SELECT + '
			FROM ' + @detail_process_table + ' temp	
			WHERE is_break = ''n''					
		'
		--PRINT(@sql)
		EXEC(@sql)
		
		IF EXISTS(SELECT 1 FROM #temp_break_down_data) 
		BEGIN
			IF OBJECT_ID('tempdb..#temp_terms') IS NOT NULL
				DROP TABLE #temp_terms
			
			CREATE TABLE #temp_terms (
				term_start DATETIME,
				term_end DATETIME,
				row_id INT,
				leg INT,
				group_id INT
			)
			
			SELECT @term_frequency = ISNULL(sdh.term_frequency, sdht.term_frequency_type)
			FROM source_deal_header sdh 
			INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
			WHERE sdh.source_deal_header_id = @copy_deal_id
			
			IF @term_frequency <> 'h'
			BEGIN
				IF @term_frequency = 't'
				BEGIN
					INSERT INTO #temp_terms(term_start, term_end, leg, group_id)
					SELECT [term_start], [term_end], leg, group_id
 					FROM #temp_break_down_data
				END
				ELSE 
				BEGIN
					WITH cte_terms AS (
						SELECT [term_start], CASE WHEN [term_end] IS NOT NULL THEN CASE WHEN [term_end] < dbo.FNAGetTermEndDate(@term_frequency, [term_start], 0) THEN [term_end] ELSE dbo.FNAGetTermEndDate(@term_frequency, [term_start], 0) END ELSE NULL END [term_end], leg, [term_end] [final_term_start], group_id
						FROM #temp_break_down_data
						UNION ALL
						SELECT dbo.FNAGetTermStartDate(@term_frequency, cte.[term_start], 1), CASE WHEN [final_term_start] < dbo.FNAGetTermEndDate(@term_frequency, dbo.FNAGetTermStartDate(@term_frequency, cte.[term_start], 1), 0) THEN [final_term_start] ELSE dbo.FNAGetTermEndDate(@term_frequency, dbo.FNAGetTermStartDate(@term_frequency, cte.[term_start], 1), 0) END, cte.leg, [final_term_start], group_id
						FROM cte_terms cte 
						WHERE dbo.FNAGetTermStartDate(@term_frequency, cte.[term_start], 1) <= [final_term_start]
					) 
					INSERT INTO #temp_terms(term_start, term_end, leg, group_id)
					SELECT term_start, term_end, leg, group_id
					FROM cte_terms
					OPTION (maxrecursion 0)
				END				
			END
			IF EXISTS (SELECT 1 FROM #temp_terms)
			BEGIN				
				SET @detail_SELECT_list = REPLACE(REPLACE(@detail_SELECT_list, 'temp.term_start', 'tt.term_start'), 'temp.term_end', 'tt.term_end')
				
				SET @sql = '
					INSERT INTO #temp_source_deal_detail (leg, group_id, detail_flag, group_name, ' + @detail_insert_list + @udf_insert + ')
					SELECT temp.leg, temp.group_id, 0, temp.group_name, ' + @detail_SELECT_list + @udf_SELECT + '
					FROM #temp_terms tt
					INNER JOIN #temp_break_down_data temp ON tt.leg = temp.leg AND tt.group_id = temp.group_id
				'
				--PRINT(@sql)
				EXEC(@sql)
			END
		END
	END
	
	IF OBJECT_ID('tempdb..#temp_source_deal_detail') IS NULL OR OBJECT_ID('tempdb..#temp_copy_sdh') IS NULL
	BEGIN
		EXEC spa_ErrorHandler -1, 'spa_insert_blotter_deal', 'spa_insert_blotter_deal', 'DB Error', 'Incomplete information.', ''
		RETURN
	END
		
	IF NOT EXISTS (SELECT 1 FROM #temp_source_deal_detail) 
	BEGIN
		EXEC spa_ErrorHandler -1, 'spa_insert_blotter_deal', 'spa_insert_blotter_deal', 'DB Error', 'Incomplete information.', ''
		RETURN
	END
	IF NOT EXISTS (SELECT 1 FROM #temp_copy_sdh) 
	BEGIN
		EXEC spa_ErrorHandler -1, 'spa_insert_blotter_deal', 'spa_insert_blotter_deal', 'DB Error', 'Incomplete information.', ''
		RETURN
	END
	 
	BEGIN TRAN
	BEGIN TRY
		IF OBJECT_ID('tempdb..#temp_inserted_sdh') IS NOT NULL
			DROP TABLE #temp_inserted_sdh
	
		CREATE TABLE #temp_inserted_sdh (
			source_deal_header_id NVARCHAR(300) COLLATE DATABASE_DEFAULT 
		)

		SET @sql = '
			INSERT INTO source_deal_header (' + @insert_string + ')
			OUTPUT INSERTED.source_deal_header_id INTO #temp_inserted_sdh(source_deal_header_id)
			SELECT ' + @insert_string + '
			FROM #temp_copy_sdh'
		--PRINT(@sql)
		EXEC(@sql)

		IF(@enable_environemet = 'y')
		BEGIN
			DECLARE @environmental_process_table NVARCHAR (200), 
					@certificate_process_table NVARCHAR (200)
		
			SET @environmental_process_table = dbo.FNAProcessTableName('environmental', @user_name, @environment_process_id)
			SET @certificate_process_table = dbo.FNAProcessTableName('certificate', @user_name, @certificate_process_id)
		
			DECLARE @rec_check INT = 0		
			IF OBJECT_ID (@certificate_process_table) IS NOT NULL
			BEGIN
				SET	@rec_check = 1	
			END

			IF OBJECT_ID (@environmental_process_table) IS NOT NULL
			BEGIN
				SET	@rec_check = 1	
			END
			IF EXISTS (SELECT columns_value FROM #temp_header_columns WHERE columns_name IN ('state_value_id') AND columns_value IS NOT NULL) AND 
			   EXISTS (SELECT columns_value FROM #temp_header_columns WHERE columns_name IN ('tier_value_id') AND columns_value IS NOT NULL)
			BEGIN 
				SET @rec_check = 1
			END

			IF EXISTS (
				SELECT 1
				FROM source_deal_header sdh
				INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
				INNER JOIN eligibility_mapping_template_detail emtd ON emtd.template_id = rg.eligibility_mapping_template_id
				WHERE sdh.generator_id IS NOT NULL 
					AND source_deal_header_id = (SELECT source_deal_header_id FROM #temp_inserted_sdh)
			)
			BEGIN
				SET @rec_check = 1
			END
							
			IF (@rec_check = 0)
			BEGIN
				EXEC spa_ErrorHandler -1, 'spa_insert_blotter_deal', 'spa_insert_blotter_deal', 'DB Error', 'Data in Jurisdiction OR Tier field is missing. Please check the data and resave.', ''
				RETURN
			END
		END
		
		UPDATE sdh
		SET source_system_book_id1 = ssbm.source_system_book_id1,
			source_system_book_id2 = ssbm.source_system_book_id2,
			source_system_book_id3 = ssbm.source_system_book_id3,
			source_system_book_id4 = ssbm.source_system_book_id4
		FROM source_deal_header sdh
		INNER JOIN #temp_inserted_sdh temp ON sdh.source_deal_header_id = temp.source_deal_header_id
		INNER JOIN source_system_book_map ssbm ON  ssbm.book_deal_type_map_id = sdh.sub_book
			
		SELECT @deal_id = sdh.source_deal_header_id,
			   @template_id = sdh.template_id
		FROM  #temp_inserted_sdh temp
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = temp.source_deal_header_id
		
		UPDATE sdh
		SET deal_status = ISNULL(sdht.deal_status, 5604),
			deal_locked = 'n',
			confirm_status_type = ISNULL(sdht.confirm_status_type, 17200)
		FROM source_deal_header sdh
		INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
		WHERE sdh.source_Deal_header_id = @deal_id
	
		-- insert udf if not present
		INSERT INTO user_defined_deal_fields (source_deal_header_id, udf_template_id, udf_value)
		SELECT @deal_id, uddft.udf_template_id, thc.columns_value
		FROM user_defined_deal_fields_template uddft
		INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
		INNER JOIN #temp_header_columns thc ON REPLACE(thc.columns_name, 'UDF___', '') = CAST(udft.udf_template_id AS NVARCHAR(20))
		LEFT JOIN user_defined_deal_fields uddf ON uddft.udf_template_id = uddf.udf_template_id
			AND uddf.source_deal_header_id = @deal_id
		WHERE uddft.template_id = @template_id
			AND uddf.udf_deal_id IS NULL
		
		--inserts hidden header udf
		INSERT INTO [dbo].[user_defined_deal_fields] (
			[source_deal_header_id],
			udf.udf_template_id,
			[udf_value], 
			currency_id, 
			counterparty_id, 
			uom_id, 
			contract_id, 
			receive_pay
		)
		SELECT @deal_id, uddf_old.udf_template_id, uddf_old.udf_value, uddf_old.currency_id, uddf_old.counterparty_id, uddf_old.uom_id, uddf_old.contract_id, uddf_old.receive_pay
		FROM user_defined_deal_fields uddf_old
		LEFT JOIN user_defined_deal_fields uddf_new ON uddf_new.source_deal_header_id = @deal_id
			AND uddf_new.udf_template_id = uddf_old.udf_template_id
		WHERE uddf_new.udf_deal_id IS NULL
			AND uddf_old.source_deal_header_id = @copy_deal_id
		
		IF @header_costs_table IS NOT NULL
		BEGIN
			IF OBJECT_ID(@header_costs_table) IS NOT NULL
			BEGIN
				SET @sql = 'UPDATE uddf
							SET udf_value = hct.udf_value,
								currency_id = hct.currency_id,
								uom_id = hct.uom_id,
								counterparty_id = hct.counterparty_id,
								contract_id = hct.contract_id,
								receive_pay = hct.receive_pay
							FROM user_defined_deal_fields uddf
							INNER JOIN ' + @header_costs_table + ' hct ON hct.cost_id = uddf.udf_template_id
								AND uddf.source_deal_header_id = ' + CAST(@deal_id AS NVARCHAR(20)) + '
							'
				--PRINT(@sql)
				EXEC(@sql)
			END			
		END
		
		IF @enable_document_tab = 'y'
 		BEGIN	
 			INSERT INTO deal_required_document (source_deal_header_id, document_type, comments)
 			SELECT @deal_id, drd.document_type, drd.comments
 			FROM deal_required_document drd
			WHERE drd.source_deal_header_id = @copy_deal_id
 		END
 		
 		IF @enable_deal_remarks = 'y'
 		BEGIN
 			INSERT INTO deal_remarks (source_deal_header_id, deal_remarks)
 			SELECT @deal_id,
				   deal_remarks
			FROM deal_remarks
			WHERE source_deal_header_id = @copy_deal_id
 		END
 		
		DECLARE @header_buy_sell NCHAR(1),
				@original_deal_buy_sell_flag NCHAR(1)

		SELECT @header_buy_sell = header_buy_sell_flag
		FROM source_deal_header
		WHERE source_deal_header_id = @deal_id

		SELECT @original_deal_buy_sell_flag = header_buy_sell_flag
		FROM source_deal_header
		WHERE source_deal_header_id = @copy_deal_id
		
		IF OBJECT_ID('tempdb..#temp_sdg') IS NOT NULL
			DROP TABLE #temp_sdg
			
		CREATE TABLE #temp_sdg (
 			id INT IDENTITY(1, 1),
 			old_group_id INT NULL,
 			group_id INT,
 			source_deal_header_id INT
 		)
		
		IF OBJECT_ID('tempdb..#temp_sdg_update') IS NOT NULL
 			DROP TABLE #temp_sdg_update
 				
 		CREATE TABLE #temp_sdg_update (
 			id INT IDENTITY(1,1),
 			group_id INT,
  			source_deal_header_id INT,
  			group_name NVARCHAR(1000) COLLATE DATABASE_DEFAULT  
 		)
		
		DECLARE @grouping_info NVARCHAR(MAX),
				@grouping_alter_cols NVARCHAR(MAX),
				@grouping_where NVARCHAR(MAX),
				@grouping_info_SELECT NVARCHAR(MAX)
 		
 		SELECT @grouping_info = dgi.grouping_columns
 		FROM deal_grouping_information dgi 
 		WHERE dgi.template_id = @template_id
 		
 		SELECT @grouping_alter_cols = COALESCE(@grouping_alter_cols + ',', '') + spvc.item + ' NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ',
 			   @grouping_where = COALESCE(@grouping_where + ' AND ', '') + 'ISNULL(t1.' + spvc.item + ', '''') = ISNULL(tsdg.' + spvc.item + ', '''')',
 			   @grouping_info_SELECT = COALESCE(@grouping_info_SELECT + ',', '') + 't1.' + spvc.item
 		FROM dbo.SplitCommaSeperatedValues(@grouping_info) spvc
 		
 		IF @grouping_alter_cols IS NOT NULL
 		BEGIN
 			EXEC('ALTER TABLE #temp_sdg_update ADD ' + @grouping_alter_cols) 
 		END		
 				
  		SET @sql = '
			INSERT INTO #temp_sdg_update (group_id, source_deal_header_id, group_name ' + ISNULL(',' + @grouping_info, '') + ')
  			SELECT ROW_NUMBER() OVER(ORDER BY t1.source_deal_header_id ASC), 
				   ' + CAST(@deal_id AS NVARCHAR(20)) + ',
				   t1.group_name ' + ISNULL(',' + @grouping_info_SELECT, '') + '
			FROM #temp_source_deal_detail t1
			GROUP BY t1.source_deal_header_id, t1.group_name ' + ISNULL(',' + @grouping_info_SELECT, '')
 			--PRINT(@sql)	
 			EXEC(@sql)
 		 		
 		INSERT INTO source_deal_groups (
			source_deal_header_id,
			source_deal_groups_name, 
			static_group_name,
			quantity
		)
		OUTPUT INSERTED.source_deal_groups_id, INSERTED.source_deal_header_id INTO #temp_sdg(group_id, source_deal_header_id)
		SELECT @deal_id,
				CASE WHEN CHARINDEX(' :: ', group_name) = 0 AND CHARINDEX('x->', group_name) = 0 THEN group_name
 					 WHEN CHARINDEX('x->', group_name) <> 0 AND CHARINDEX(' :: ', group_name) = 0 THEN SUBSTRING(group_name, CHARINDEX('x->', group_name)+3, LEN(group_name))
 					 ELSE SUBSTRING(group_name,  CHARINDEX(' :: ', group_name) + 4, LEN(group_name))
 				END,
 				CASE WHEN CHARINDEX(' :: ', group_name) = 0 THEN NULL
 					 WHEN CHARINDEX('x->', group_name) <> 0 AND CHARINDEX(' :: ', group_name) <> 0 THEN SUBSTRING(SUBSTRING(group_name, 0, CHARINDEX(' :: ', group_name)), CHARINDEX('x->', group_name)+3, LEN(group_name))
 					 ELSE SUBSTRING(group_name,  0, CHARINDEX(' :: ', group_name))
 				END,
 				CASE WHEN CHARINDEX('x->', group_name) = 0 THEN NULL
 					 ELSE SUBSTRING(group_name, 0, CHARINDEX('x->', group_name))
 				END  
		FROM #temp_sdg_update
		ORDER BY id ASC
		
		UPDATE temp
 		SET old_group_id = t1.group_id
 		FROM #temp_sdg temp
 		INNER JOIN #temp_sdg_update t1
 			ON t1.id = temp.id
			
 		SET @sql = '
			UPDATE t1
 			SET group_id = t2.group_id
 			FROM #temp_source_deal_detail t1
 			INNER JOIN #temp_sdg_update tsdg 
				ON t1.group_name = tsdg.group_name
 				' + ISNULL(' AND ' + @grouping_where, '') + '
 			OUTER APPLY (
 				SELECT temp.group_id
 				FROM #temp_sdg temp
 				INNER JOIN source_deal_groups sdg ON sdg.source_deal_groups_id = temp.group_id
 				WHERE temp.source_deal_header_id = tsdg.source_deal_header_id 
 				AND t1.group_name = ISNULL(LTRIM(RTRIM(CAST(sdg.quantity AS NVARCHAR(10)))) + ''x->'', '''') + ISNULL(RTRIM(LTRIM(sdg.static_group_name)) + '' :: '', '''') + RTRIM(LTRIM(sdg.source_deal_groups_name))
 			) t2 
 		'
 		--PRINT(@sql)
 		EXEC(@sql)
		
		IF OBJECT_ID('tempdb..#temp_inserted_sdd') IS NOT NULL	
			DROP TABLE #temp_inserted_sdd
		
		CREATE TABLE #temp_inserted_sdd(
			source_deal_header_id INT,
			source_deal_detail_id INT,
			term_start DATETIME,
			term_end DATETIME,
			leg INT,
			old_id INT
		)
		
		DECLARE @contract_expiration_column NVARCHAR(50),
				@contract_expiration_value NVARCHAR(MAX),
				@buy_sell_column NVARCHAR(50),
				@buy_sell_value NVARCHAR(MAX),
				@fixed_float_leg_column NVARCHAR(50),
				@fixed_float_leg_value NVARCHAR(MAX),
				@deal_volume_frequency_column NVARCHAR(50),
				@deal_volume_frequency_value NVARCHAR(MAX),
				@deal_volume_uom_id_column NVARCHAR(50),
				@deal_volume_uom_id_value NVARCHAR(MAX),
				@shipper_code1_column NVARCHAR(50),
				@shipper_code1_value NVARCHAR(50),
				@shipper_code2_column NVARCHAR(50),
				@shipper_code2_value NVARCHAR(50)

		IF ISNULL(CHARINDEX('contract_expiration_date', @detail_final_insert_list), 0) = 0 AND ISNULL(CHARINDEX('contract_expiration_date', @detail_final_SELECT_list), 0) = 0
 		BEGIN
 			SET @contract_expiration_column = ', contract_expiration_date'
 			SET @contract_expiration_value = ', COALESCE(temp.contract_expiration_date, temp.term_end, sdd.contract_expiration_date, sddt.contract_expiration_date)'
 		END

		IF ISNULL(CHARINDEX('buy_sell_flag', @detail_final_insert_list), 0) = 0 AND ISNULL(CHARINDEX('contract_expiration_date', @detail_final_SELECT_list), 0) = 0
 		BEGIN
 			SET @buy_sell_column = ', buy_sell_flag'
			SET @buy_sell_value = ', COALESCE(temp.buy_sell_flag, sdd.buy_sell_flag, ''' + @original_deal_buy_sell_flag + ''', sddt.buy_sell_flag)'
 		END

		IF ISNULL(CHARINDEX('shipper_code1', @detail_final_insert_list), 0) = 0 
 		BEGIN
 			SET @shipper_code1_column = ', shipper_code1'
			SET @shipper_code1_value = ', ISNULL(temp.shipper_code1, sddt.shipper_code1)'
 		END

		IF ISNULL(CHARINDEX('shipper_code2', @detail_final_insert_list), 0) = 0 
 		BEGIN
 			SET @shipper_code2_column = ', shipper_code2'
			SET @shipper_code2_value = ', ISNULL(temp.shipper_code2, sddt.shipper_code2)'
 		END
		
		IF ISNULL(CHARINDEX('fixed_float_leg', @detail_final_insert_list), 0) = 0 AND ISNULL(CHARINDEX('fixed_float_leg', @detail_final_SELECT_list), 0) = 0
 		BEGIN
 			SET @fixed_float_leg_column = ', fixed_float_leg'
			DECLARE @max_fixed_float NCHAR(1)
 			
			SELECT @max_fixed_float = MAX(fixed_float_leg)
			FROM source_deal_detail
			WHERE source_deal_header_id = @copy_deal_id
			
			SET @fixed_float_leg_value = ', COALESCE(temp.fixed_float_leg, sdd.fixed_float_leg, sddt.fixed_float_leg, ''' + @max_fixed_float + ''')'
 		END

		IF ISNULL(CHARINDEX('deal_volume_frequency', @detail_final_insert_list), 0) = 0 AND ISNULL(CHARINDEX('deal_volume_frequency', @detail_final_SELECT_list), 0) = 0
 		BEGIN
 			SET @deal_volume_frequency_column = ', deal_volume_frequency'
			DECLARE @max_deal_vol_freq NCHAR(1)
 			
			SELECT @max_deal_vol_freq = MAX(deal_volume_frequency)
			FROM source_deal_detail
			WHERE source_deal_header_id = @copy_deal_id
			
			SET @deal_volume_frequency_value = ', COALESCE(temp.deal_volume_frequency, sdd.deal_volume_frequency, sddt.deal_volume_frequency, ''' + @max_deal_vol_freq + ''')'
 		END

		IF ISNULL(CHARINDEX('deal_volume_uom_id', @detail_final_insert_list), 0) = 0 AND ISNULL(CHARINDEX('deal_volume_uom_id', @detail_final_SELECT_list), 0) = 0
 		BEGIN
 			SET @deal_volume_uom_id_column = ', deal_volume_uom_id'
			DECLARE @max_deal_vol_uom NVARCHAR(10)
 			
			SELECT @max_deal_vol_uom = MAX(deal_volume_uom_id)
			FROM source_deal_detail
			WHERE source_deal_header_id = @copy_deal_id
			
			SET @deal_volume_uom_id_value = ', COALESCE(temp.deal_volume_uom_id, sdd.deal_volume_uom_id, sddt.deal_volume_uom_id, ''' + @max_deal_vol_uom + ''')'
 		END

		SET @sql = '
			INSERT INTO source_deal_detail (
				source_deal_header_id, leg, source_deal_group_id, ' 
				+ @detail_final_insert_list 
				+ ISNULL(@contract_expiration_column, '') 
				+ ISNULL(@buy_sell_column, '')
				+ ISNULL(@fixed_float_leg_column, '')
				+ ISNULL(@deal_volume_frequency_column, '')
				+ ISNULL(@deal_volume_uom_id_column, '')
				+ ISNULL(@shipper_code1_column, '') 
				+ ISNULL(@shipper_code2_column, '') 
				+'
			)
			OUTPUT INSERTED.source_deal_header_id, INSERTED.source_deal_detail_id, INSERTED.leg, INSERTED.term_start, INSERTED.term_end INTO #temp_inserted_sdd (source_deal_header_id, source_deal_detail_id, leg, term_start, term_end)
			SELECT ' + CAST(@deal_id AS NVARCHAR(20)) + ', temp.leg, temp.group_id, ' + @detail_final_SELECT_list 
						+ ISNULL(@contract_expiration_value, '') 
						+ ISNULL(@buy_sell_value, '') 
						+ ISNULL(@fixed_float_leg_value, '') 
						+ ISNULL(@deal_volume_frequency_value, '') 
						+ ISNULL(@deal_volume_uom_id_value, '')
						+ ISNULL(@shipper_code1_value, '') 
						+ ISNULL(@shipper_code2_value, '') 
						+ '
			FROM #temp_source_deal_detail temp			
			OUTER APPLY ( 
				SELECT * FROM source_deal_detail_template sddt
				WHERE sddt.template_id = ' + CAST(@template_id AS NVARCHAR(20)) + '
				AND sddt.leg = temp.leg
			) sddt
			LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = ' + CAST(@copy_deal_id AS NVARCHAR(20)) + '
				AND sdd.term_start = temp.term_start
				AND sdd.term_end = temp.term_end
				AND sdd.leg = temp.leg
		'
		--PRINT(RIGHT(@sql, 8000))
		EXEC(@sql)
			
		SET @sql = '
			UPDATE tid
			SET old_id = sdd.source_deal_detail_id
			FROM #temp_inserted_sdd tid
			INNER JOIN source_deal_detail sdd ON tid.term_start = sdd.term_start 
				AND tid.term_end = sdd.term_end
				AND tid.leg = sdd.leg
			WHERE sdd.source_deal_header_id = ' + CAST(@copy_deal_id AS NVARCHAR(20)) + '
		'
		--PRINT(@sql)
		EXEC(@sql)

		IF @shaped_process_id IS NOT NULL
		BEGIN
			DECLARE @shaped_process_table NVARCHAR(400) = dbo.FNAProcessTableName('shaped_volume', @user_name, @shaped_process_id)
				
			IF OBJECT_ID(@shaped_process_table) IS NOT NULL
			BEGIN
				SET @sql = '
					UPDATE temp
					SET source_deal_detail_id = sdd.source_deal_detail_id
					FROM ' + @shaped_process_table + ' temp
					INNER JOIN (
						SELECT sdd.* 
						FROM #temp_inserted_sdd tsdd
						INNER JOIN source_deal_detail sdd ON tsdd.source_deal_detail_id = sdd.source_deal_detail_id
					) sdd ON sdd.leg = temp.leg
						AND temp.term_date BETWEEN sdd.term_start AND sdd.term_end	
				'
				
				EXEC(@sql)			
					
				DECLARE @sdh_id INT
				SELECT @sdh_id = @deal_id				
					
				EXEC spa_update_shaped_volume  @flag='v',@source_deal_header_id=@sdh_id, @process_id=@shaped_process_id, @response='n'
			END
			
			/* -- Do Not enable this
			INSERT INTO source_deal_detail_hour (
				source_deal_detail_id,
				term_date,
				hr,
				is_dst,
				volume,
				price,
				formula_id,
				granularity,
				actual_volume,
				schedule_volume
			)
			SELECT 
				tsdd.source_deal_detail_id,
				sddh.term_date,
				sddh.hr,
				sddh.is_dst,
				sddh.volume,
				sddh.price,
				sddh.formula_id,
				sddh.granularity,
				sddh.actual_volume,
				sddh.schedule_volume
			FROM #temp_inserted_sdd tsdd
			INNER JOIN source_deal_detail sdd 
				ON sdd.source_deal_header_id = @copy_deal_id
				AND sdd.term_start = tsdd.term_start
				AND sdd.term_end = tsdd.term_end
				AND sdd.leg = tsdd.leg				
			INNER JOIN source_deal_detail_hour sddh
				ON sdd.source_deal_detail_id = sddh.source_deal_detail_id 
				AND sddh.term_date BETWEEN tsdd.term_start and tsdd.term_end			
			LEFT JOIN source_deal_detail_hour sddh_new
				ON sddh_new.source_deal_detail_id = tsdd.source_deal_detail_id
				AND sddh_new.term_date = sddh.term_date	
			WHERE sddh_new.source_deal_detail_id IS NULL
			*/
		END
		
		IF (@rec_check = 1)
		BEGIN
			IF @environment_process_id IS NOT NULL
			BEGIN				
				IF OBJECT_ID(@environmental_process_table) IS NOT NULL
				BEGIN
					SET @sql = '
						UPDATE temp
						SET temp.source_deal_header_id = tsdh.source_deal_header_id
						FROM ' + @environmental_process_table + ' temp
						INNER JOIN #temp_inserted_sdh tsdh ON 1 = 1							
					'
					
					EXEC (@sql)								
					EXEC spa_gis_product_detail  @flag  = 'v', @environment_process_id = @environment_process_id
				END
			END

			IF OBJECT_ID(@certificate_process_table) IS NOT NULL
			BEGIN					
				SET @sql = '
					SELECT c.source_certificate_number,
							t.source_deal_detail_id source_deal_header_id,
							c.certificate_number_from_int,
							c.certificate_number_to_int,
							c.gis_certificate_number_from,
							c.gis_certificate_number_to,
							c.gis_cert_date,
							c.state_value_id,
							c.tier_type,
							c.contract_expiration_date,
							c.year,
							c.certification_entity,
							c.insert_del
					INTO #temp_certificate
					FROM ' + @certificate_process_table + ' c
					CROSS JOIN #temp_inserted_sdd t

					DELETE FROM ' + @certificate_process_table + '
					
					INSERT INTO ' + @certificate_process_table + '
					SELECT * from #temp_certificate
				'
				
				EXEC (@sql)								
				EXEC spa_gis_certificate_detail  @flag  = 'v', @certificate_process_id = @certificate_process_id
			END
		END
		
		UPDATE sdd
 		SET deal_volume = COALESCE(sdd.actual_volume, sdd.contractual_volume, sdd.deal_volume),
 			deal_volume_frequency = CASE WHEN sdd.actual_volume IS NOT NULL THEN 't' ELSE sdd.deal_volume_frequency END
 		FROM source_deal_detail sdd
		INNER JOIN #temp_inserted_sdd t1 ON t1.source_deal_detail_id = sdd.source_deal_detail_id 
 		WHERE COALESCE(sdd.actual_volume, sdd.contractual_volume) IS NOT NULL	
 					
 		UPDATE sdd
 		SET multiplier = sdg.quantity
 		FROM source_deal_detail sdd
		INNER JOIN #temp_inserted_sdd t1 ON t1.source_deal_detail_id = sdd.source_deal_detail_id 
 		INNER JOIN source_deal_groups sdg ON sdg.source_deal_groups_id = sdd.source_deal_group_id
 		WHERE NULLIF(sdg.quantity, 0) IS NOT NULL
				
		IF @header_buy_sell <> @original_deal_buy_sell_flag AND EXISTS (SELECT 1 from maintain_field_template_detail mftd
															INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
															WHERE mftd.field_template_id = @field_template_id
															AND mfd.farrms_field_id = 'buy_sell_flag'
															AND mfd.header_detail = 'd'
															AND mftd.update_required = 'n')
		BEGIN
			UPDATE sdd
			SET buy_sell_flag = CASE WHEN buy_sell_flag = 's' THEN 'b' ELSE 's' END
			FROM source_deal_detail sdd
			INNER JOIN #temp_inserted_sdd temp ON temp.source_deal_detail_id = sdd.source_deal_detail_id
		END
		
		IF @udf_insert <> ''
		BEGIN
			SET @sql = '
				INSERT INTO [dbo].user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id, [udf_value])
				SELECT source_deal_detail_id, uddft.udf_template_id, udf_value
				FROM (
					SELECT tid.source_deal_detail_id ' + @udf_insert + '
					FROM #temp_source_deal_detail tsdd
					INNER JOIN #temp_inserted_sdd tid ON tid.term_start = tsdd.term_start
						AND tid.term_end = tsdd.term_end
						AND tid.leg = tsdd.leg
				) a UNPIVOT (udf_value FOR udf_template_id IN (' + SUBSTRING(@udf_insert, 2, LEN(@udf_insert)) + ')) unpvt
				INNER JOIN user_defined_fields_template udft ON CAST(udft.udf_template_id AS NVARCHAR) = REPLACE(unpvt.udf_template_id, ''UDF___'', '''')
					AND udft.udf_type = ''d''
				INNER JOIN user_defined_deal_fields_template uddft ON udft.field_name = uddft.field_name
					AND uddft.template_id = ' + CAST(@template_id AS NVARCHAR(200)) + '
			'
			--PRINT (@sql)
			EXEC(@sql)
		END
		--inserts hidden udfs						
		INSERT INTO [dbo].user_defined_deal_detail_fields (
			source_deal_detail_id, udf_template_id, [udf_value], currency_id,
			counterparty_id, uom_id, contract_id, receive_pay
		)
		SELECT tsdd.source_deal_detail_id,
			   uddf_old.udf_template_id,
			   uddf_old.udf_value, 
			   uddf_old.currency_id, 
			   uddf_old.counterparty_id, 
			   uddf_old.uom_id, 
			   uddf_old.contract_id, 
			   uddf_old.receive_pay
		FROM #temp_inserted_sdd tsdd
		INNER JOIN user_defined_deal_detail_fields uddf_old ON uddf_old.source_deal_detail_id = tsdd.old_id
		LEFT JOIN user_defined_deal_detail_fields udddf_new ON udddf_new.source_deal_detail_id = tsdd.source_deal_detail_id 
			AND uddf_old.udf_template_id = udddf_new.udf_template_id
		WHERE udddf_new.udf_deal_id IS NULL
			
		IF NULLIF(@pricing_process_id, '') IS NOT NULL
		BEGIN
			DECLARE @detail_cost_table NVARCHAR(200)
			SET @detail_cost_table = dbo.FNAProcessTableName('detail_cost_table', @user_name, @pricing_process_id)
			
			IF OBJECT_ID(@detail_cost_table) IS NOT NULL
			BEGIN
				SET @sql = '
					UPDATE user_defined_deal_detail_fields
					SET udf_value = u.udf_value,
						currency_id = u.currency_id,
						uom_id = u.uom_id,
						counterparty_id = u.counterparty_id,
						contract_id = u.contract_id,
						receive_pay= u.receive_pay
					FROM user_defined_deal_detail_fields udf
					LEFT JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = udf.udf_template_id						
					INNER JOIN #temp_inserted_sdd tid ON udf.source_deal_detail_id = tid.source_deal_detail_id
					INNER JOIN ' + @detail_cost_table + ' u ON  u.cost_id = udf.udf_template_id
						AND u.detail_id = tid.old_id				
				'
				--PRINT(@sql)
				EXEC(@sql)
			END
		END
		
		-- update audit info
		UPDATE sdh
		SET create_ts = GETDATE(),
			create_user = dbo.FNADBUser(),
			update_user = NULL,
			update_ts = NULL,
			deal_id = deal_id + '_' + CAST(@deal_id AS NVARCHAR(20)),
			term_frequency = @term_frequency,
 			entire_term_start = t.term_start,
 			entire_term_end = t.term_end
		FROM source_deal_header sdh
		OUTER APPLY (
			SELECT MIN(sdd.term_start) term_start,
				   MAX(sdd.term_end) term_end
			FROM source_deal_detail sdd
			WHERE sdd.source_deal_header_id = @deal_id
		) t
		WHERE sdh.source_deal_header_id = @deal_id
			
		UPDATE sdd
		SET create_ts = GETDATE(),
			create_user = dbo.FNADBUser(),
			update_user = NULL,
			update_ts = NULL
		FROM source_deal_detail sdd
		WHERE sdd.source_deal_header_id = @deal_id

		--Insert prepay value
		INSERT INTO source_deal_prepay (
			prepay, [value], [percentage], formula_id, settlement_date, settlement_calendar, settlement_days,
			payment_date, payment_calendar, payment_days, granularity, source_deal_header_id
		)
		SELECT prepay, [value], [percentage], formula_id, settlement_date, settlement_calendar, settlement_days,
			   payment_date, payment_calendar, payment_days, granularity, @deal_id
		FROM source_deal_prepay
		WHERE source_deal_header_id = @copy_deal_id

		-- Saved Year of 'Term Start' in Vintage year field.
		DECLARE @rec_template_id INT

		SELECT @rec_template_id = sdht.template_id
 		FROM source_deal_header sdh 
 		INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id 
 		WHERE sdh.source_deal_header_id = @copy_deal_id

		IF EXISTS(
			SELECT 1
			FROM maintain_field_template_detail d
			INNER JOIN maintain_field_deal f ON d.field_id = f.field_id
			INNER JOIN source_deal_header_template sdht ON sdht.field_template_id = d.field_template_id			
			INNER JOIN source_deal_detail_template sddt ON sddt.template_id = sdht.template_id
			WHERE farrms_field_id = 'vintage' 
				AND udf_or_system = 's'
				AND sdht.template_id = @rec_template_id
		)
		BEGIN		
			IF EXISTS (
				SELECT 1 
				FROM source_deal_header sdh
				INNER JOIN source_deal_header_template sdht ON sdh.template_id = sdht.template_id
				WHERE sdh.source_deal_header_id = @copy_deal_id
					AND sdht.term_frequency_type = 'a' 
			)
			BEGIN
				UPDATE sdd
 				SET sdd.term_start = CONVERT(DATE, (sdv.code + '-01-01'), 120),
					sdd.term_end = CONVERT(DATE, (sdv.code + '-12-31'), 120)
				FROM source_deal_detail sdd
				INNER JOIN static_data_value sdv ON sdv.value_id = sdd.vintage
					AND sdv.type_id = 10092
				INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id 
 				WHERE sdd.source_deal_header_id = @deal_id
					AND sdd.vintage IS NOT NULL
			END

			UPDATE sdd
 			SET sdd.vintage = sdv.value_id
			FROM source_deal_detail sdd
			INNER JOIN static_data_value sdv ON sdv.code = YEAR(sdd.term_start)
				AND sdv.type_id = 10092
 			WHERE sdd.source_deal_header_id = @deal_id
		END
		
		----Copy Price Logic Start			
		IF OBJECT_ID('tempdb..#temp_inserted_dpt') IS NOT NULL
			DROP TABLE #temp_inserted_dpt
			
		CREATE TABLE #temp_inserted_dpt (
			source_deal_detail_id INT,
			price_type_id INT,
			deal_price_type_id INT,
			old_deal_price_type_id INT,
			[priority] INT
		)
			
		UPDATE sdd
		SET pricing_type = NULLIF(old_sdd.pricing_type, ''),
			tiered = old_sdd.tiered,
			settlement_date = NULLIF(old_sdd.settlement_date, ''),
			settlement_currency = old_sdd.settlement_currency,
			settlement_uom = old_sdd.settlement_uom,
			fx_conversion_rate = NULLIF(old_sdd.fx_conversion_rate, ''),
			pricing_description = old_sdd.pricing_description				
		FROM #temp_inserted_sdd t
		INNER JOIN source_deal_detail old_sdd ON t.old_id = old_sdd.source_deal_detail_id 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = t.source_deal_detail_id
		WHERE old_sdd.source_deal_header_id = @copy_deal_id
			
		INSERT INTO deal_price_type (source_deal_detail_id, price_type_id, [description], [priority])
		OUTPUT INSERTED.source_deal_detail_id, INSERTED.price_type_id, INSERTED.deal_price_type_id, INSERTED.[priority]
		INTO #temp_inserted_dpt (source_deal_detail_id, price_type_id, deal_price_type_id, [priority])
		SELECT t.source_deal_detail_id, dpt.price_type_id, dpt.[description], dpt.[priority]
		FROM deal_price_type dpt
		INNER JOIN source_deal_detail sdd ON dpt.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN #temp_inserted_sdd t ON t.old_id = sdd.source_deal_detail_id 
		WHERE sdd.source_deal_header_id = @copy_deal_id
				
		UPDATE t 
		SET old_deal_price_type_id = dpt.deal_price_type_id
		FROM #temp_inserted_dpt t				
		INNER JOIN #temp_inserted_sdd tsdd ON tsdd.source_deal_detail_id = t.source_deal_detail_id 
		INNER JOIN source_deal_detail sdd ON tsdd.old_id = sdd.source_deal_detail_id
		INNER JOIN deal_price_type dpt ON tsdd.old_id = dpt.source_deal_detail_id
			AND t.price_type_id = dpt.price_type_id
			AND t.[priority] = dpt.[priority]
		WHERE sdd.source_deal_header_id = @copy_deal_id
				
		INSERT INTO deal_price_deemed (
			source_deal_detail_id, pricing_index, pricing_start,pricing_end, adder, currency, multiplier, volume, uom, pricing_provisional,
			pricing_type, pricing_period, fixed_price, pricing_uom, adder_currency, formula_id, [priority], formula_currency, fixed_cost,
			fixed_cost_currency, include_weekends, rounding, deal_price_type_id
		)
		SELECT t.source_deal_detail_id, dpd.pricing_index, dpd.pricing_start, dpd.pricing_end, dpd.adder, dpd.currency, dpd.multiplier, dpd.volume,
				dpd.uom, dpd.pricing_provisional, dpd.pricing_type, dpd.pricing_period, dpd.fixed_price, dpd.pricing_uom, dpd.adder_currency, dpd.formula_id,
				dpd.[priority], dpd.formula_currency, dpd.fixed_cost, dpd.fixed_cost_currency, dpd.include_weekends, dpd.rounding, tid.deal_price_type_id						
		FROM deal_price_deemed dpd
		INNER JOIN source_deal_detail sdd ON dpd.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN #temp_inserted_sdd t ON t.old_id = sdd.source_deal_detail_id 
		INNER JOIN #temp_inserted_dpt tid ON dpd.deal_price_type_id = tid.old_deal_price_type_id
		WHERE sdd.source_deal_header_id = @copy_deal_id

		INSERT INTO deal_price_custom_event (
			source_deal_detail_id, event_type, event_date, pricing_index, skip_days, quotes_before, quotes_after, include_event_date,
			include_holidays, adder, currency, multiplier, volume, uom, pricing_provisional, pricing_type, rounding, deal_price_type_id			
		)
		SELECT t.source_deal_detail_id, dpd.event_type, dpd.event_date, dpd.pricing_index, dpd.skip_days, dpd.quotes_before, dpd.quotes_after,
				dpd.include_event_date, dpd.include_holidays, dpd.adder, dpd.currency, dpd.multiplier, dpd.volume, dpd.uom, dpd.pricing_provisional,
				dpd.pricing_type, dpd.rounding, tid.deal_price_type_id
		FROM deal_price_custom_event dpd
		INNER JOIN source_deal_detail sdd ON dpd.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN #temp_inserted_sdd t ON t.old_id = sdd.source_deal_detail_id 
		INNER JOIN #temp_inserted_dpt tid ON dpd.deal_price_type_id = tid.old_deal_price_type_id
		WHERE sdd.source_deal_header_id = @copy_deal_id

		INSERT INTO deal_price_std_event (
			source_deal_detail_id, event_type, event_date, event_pricing_type, pricing_index, adder, currency,
			multiplier, volume, uom, pricing_provisional, pricing_type, rounding, deal_price_type_id
		)				
		SELECT t.source_deal_detail_id, dpd.event_type, dpd.event_date, dpd.event_pricing_type, dpd.pricing_index, dpd.adder, dpd.currency,
				dpd.multiplier, dpd.volume, dpd.uom, dpd.pricing_provisional, dpd.pricing_type, dpd.rounding, tid.deal_price_type_id
		FROM deal_price_std_event dpd
		INNER JOIN source_deal_detail sdd ON dpd.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN #temp_inserted_sdd t ON t.old_id = sdd.source_deal_detail_id 
		INNER JOIN #temp_inserted_dpt tid ON dpd.deal_price_type_id = tid.old_deal_price_type_id
		WHERE sdd.source_deal_header_id = @copy_deal_id

		INSERT INTO deal_detail_formula_udf (source_deal_detail_id, udf_template_id, udf_value, formula_id, deal_price_type_id)
		SELECT t.source_deal_detail_id, dpd.udf_template_id, dpd.udf_value, dpd.formula_id, tid.deal_price_type_id 
		FROM deal_detail_formula_udf dpd
		INNER JOIN source_deal_detail sdd ON dpd.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN #temp_inserted_sdd t ON t.old_id = sdd.source_deal_detail_id 
		INNER JOIN #temp_inserted_dpt tid ON dpd.deal_price_type_id = tid.old_deal_price_type_id
		WHERE sdd.source_deal_header_id = @copy_deal_id

		INSERT INTO deal_price_adjustment (source_deal_detail_id, udf_template_id, udf_value, formula_id, deal_price_type_id)
		SELECT t.source_deal_detail_id, dpd.udf_template_id, dpd.udf_value, dpd.formula_id, tid.deal_price_type_id 
		FROM deal_price_adjustment dpd
		INNER JOIN source_deal_detail sdd ON dpd.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN #temp_inserted_sdd t ON t.old_id = sdd.source_deal_detail_id 
		INNER JOIN #temp_inserted_dpt tid ON dpd.deal_price_type_id = tid.old_deal_price_type_id
		WHERE sdd.source_deal_header_id = @copy_deal_id

		INSERT INTO deal_price_quality (source_deal_detail_id, attribute, operator, numeric_value, text_value, uom, basis)
		SELECT t.source_deal_detail_id, dpd.attribute, dpd.operator, dpd.numeric_value, dpd.text_value, dpd.uom, dpd.basis				
		FROM deal_price_quality dpd
		INNER JOIN source_deal_detail sdd ON dpd.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN #temp_inserted_sdd t ON t.old_id = sdd.source_deal_detail_id 
		WHERE sdd.source_deal_header_id = @copy_deal_id
		----Copy Price Logic End
	
		----Copy Provisional price Start
		IF OBJECT_ID('tempdb..#temp_inserted_dpt') IS NOT NULL
			DROP TABLE #temp_inserted_dpt
			
		CREATE TABLE #temp_inserted_dpt_provisional (
			source_deal_detail_id INT,
			price_type_id INT,
			deal_price_type_id INT,
			old_deal_price_type_id INT,
			[priority] INT
		)
			
		INSERT INTO deal_price_type_provisional (source_deal_detail_id, price_type_id, [description], [priority])
		OUTPUT INSERTED.source_deal_detail_id, INSERTED.price_type_id, INSERTED.deal_price_type_provisional_id, INSERTED.[priority]
		INTO #temp_inserted_dpt_provisional (source_deal_detail_id, price_type_id, deal_price_type_id, [priority])
		SELECT t.source_deal_detail_id, dpt.price_type_id, dpt.[description], dpt.[priority]
		FROM deal_price_type_provisional dpt
		INNER JOIN source_deal_detail sdd ON dpt.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN #temp_inserted_sdd t ON t.old_id = sdd.source_deal_detail_id 
		WHERE sdd.source_deal_header_id = @copy_deal_id
				
		UPDATE t 
		SET old_deal_price_type_id = dpt.deal_price_type_provisional_id
		FROM #temp_inserted_dpt_provisional t				
		INNER JOIN #temp_inserted_sdd tsdd ON tsdd.source_deal_detail_id = t.source_deal_detail_id 
		INNER JOIN source_deal_detail sdd ON tsdd.old_id = sdd.source_deal_detail_id
		INNER JOIN deal_price_type_provisional dpt ON tsdd.old_id = dpt.source_deal_detail_id
			AND t.price_type_id = dpt.price_type_id
			AND t.[priority] = dpt.[priority]
		WHERE sdd.source_deal_header_id = @copy_deal_id
				
		INSERT INTO deal_price_deemed_provisional (
			source_deal_detail_id, pricing_index, pricing_start,pricing_end, adder, currency, multiplier, volume, uom, pricing_provisional,
			pricing_type, pricing_period, fixed_price, pricing_uom, adder_currency, formula_id, [priority], formula_currency, fixed_cost,
			fixed_cost_currency, include_weekends, rounding, deal_price_type_id
		)
		SELECT t.source_deal_detail_id, dpd.pricing_index, dpd.pricing_start, dpd.pricing_end, dpd.adder, dpd.currency, dpd.multiplier, dpd.volume,
			   dpd.uom, dpd.pricing_provisional, dpd.pricing_type, dpd.pricing_period, dpd.fixed_price, dpd.pricing_uom, dpd.adder_currency, dpd.formula_id,
			   dpd.[priority], dpd.formula_currency, dpd.fixed_cost, dpd.fixed_cost_currency, dpd.include_weekends, dpd.rounding, tid.deal_price_type_id						
		FROM deal_price_deemed_provisional dpd
		INNER JOIN source_deal_detail sdd ON dpd.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN #temp_inserted_sdd t ON t.old_id = sdd.source_deal_detail_id 
		INNER JOIN #temp_inserted_dpt_provisional tid ON dpd.deal_price_type_id = tid.old_deal_price_type_id
		WHERE sdd.source_deal_header_id = @copy_deal_id

		INSERT INTO deal_price_custom_event_provisional (
			source_deal_detail_id, event_type, event_date, pricing_index, skip_days, quotes_before, quotes_after, include_event_date,
			include_holidays, adder, currency, multiplier, volume, uom, pricing_provisional, pricing_type, rounding, deal_price_type_id			
		)
		SELECT t.source_deal_detail_id, dpd.event_type, dpd.event_date, dpd.pricing_index, dpd.skip_days, dpd.quotes_before, dpd.quotes_after,
			   dpd.include_event_date, dpd.include_holidays, dpd.adder, dpd.currency, dpd.multiplier, dpd.volume, dpd.uom, dpd.pricing_provisional,
			   dpd.pricing_type, dpd.rounding, tid.deal_price_type_id
		FROM deal_price_custom_event_provisional dpd
		INNER JOIN source_deal_detail sdd ON dpd.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN #temp_inserted_sdd t ON t.old_id = sdd.source_deal_detail_id 
		INNER JOIN #temp_inserted_dpt_provisional tid ON dpd.deal_price_type_id = tid.old_deal_price_type_id
		WHERE sdd.source_deal_header_id = @copy_deal_id

		INSERT INTO deal_price_std_event_provisional (
			source_deal_detail_id, event_type, event_date, event_pricing_type, pricing_index, adder, currency,
			multiplier, volume, uom, pricing_provisional, pricing_type, rounding, deal_price_type_id
		)				
		SELECT t.source_deal_detail_id, dpd.event_type, dpd.event_date, dpd.event_pricing_type, dpd.pricing_index, dpd.adder, dpd.currency,
				dpd.multiplier, dpd.volume, dpd.uom, dpd.pricing_provisional, dpd.pricing_type, dpd.rounding, tid.deal_price_type_id
		FROM deal_price_std_event_provisional dpd
		INNER JOIN source_deal_detail sdd ON dpd.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN #temp_inserted_sdd t ON t.old_id = sdd.source_deal_detail_id 
		INNER JOIN #temp_inserted_dpt_provisional tid ON dpd.deal_price_type_id = tid.old_deal_price_type_id
		WHERE sdd.source_deal_header_id = @copy_deal_id

		INSERT INTO deal_detail_formula_udf_provisional (source_deal_detail_id, udf_template_id, udf_value, formula_id, deal_price_type_id)
		SELECT t.source_deal_detail_id, dpd.udf_template_id, dpd.udf_value, dpd.formula_id, tid.deal_price_type_id 
		FROM deal_detail_formula_udf_provisional dpd
		INNER JOIN source_deal_detail sdd ON dpd.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN #temp_inserted_sdd t ON t.old_id = sdd.source_deal_detail_id 
		INNER JOIN #temp_inserted_dpt_provisional tid ON dpd.deal_price_type_id = tid.old_deal_price_type_id
		WHERE sdd.source_deal_header_id = @copy_deal_id

		INSERT INTO deal_price_adjustment_provisional (source_deal_detail_id, udf_template_id, udf_value, formula_id, deal_price_type_id)
		SELECT t.source_deal_detail_id, dpd.udf_template_id, dpd.udf_value, dpd.formula_id, tid.deal_price_type_id 
		FROM deal_price_adjustment_provisional dpd
		INNER JOIN source_deal_detail sdd ON dpd.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN #temp_inserted_sdd t ON t.old_id = sdd.source_deal_detail_id 
		INNER JOIN #temp_inserted_dpt_provisional tid ON dpd.deal_price_type_id = tid.old_deal_price_type_id
		WHERE sdd.source_deal_header_id = @copy_deal_id

		INSERT INTO deal_price_quality_provisional (source_deal_detail_id, attribute, operator, numeric_value, text_value, uom, basis)
		SELECT t.source_deal_detail_id, dpd.attribute, dpd.operator, dpd.numeric_value, dpd.text_value, dpd.uom, dpd.basis				
		FROM deal_price_quality_provisional dpd
		INNER JOIN source_deal_detail sdd ON dpd.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN #temp_inserted_sdd t ON t.old_id = sdd.source_deal_detail_id 
		WHERE sdd.source_deal_header_id = @copy_deal_id
		----Copy Provisional price End
	
		COMMIT TRAN
			
		EXEC spa_ErrorHandler 0, 'spa_insert_blotter_deal', 'spa_insert_blotter_deal', 'Success', 'Successfully saved data.', @deal_id
					
		DECLARE @after_insert_process_table NVARCHAR(300), 
				@job_name NVARCHAR(200),
				@job_process_id NVARCHAR(200) = dbo.FNAGETNEWID()
	
		SET @after_insert_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)
	
		IF OBJECT_ID(@after_insert_process_table) IS NOT NULL
		BEGIN
			EXEC('DROP TABLE ' + @after_insert_process_table)
		END
				
		EXEC ('CREATE TABLE ' + @after_insert_process_table + '(source_deal_header_id INT)')

		SET @sql = 'INSERT INTO ' + @after_insert_process_table + '(source_deal_header_id) 
					SELECT ' + CAST(@deal_id AS NVARCHAR(20))
		EXEC(@sql)
		
		/***************MultiStep Job Start*************************/
		DECLARE @step1 NVARCHAR(MAX), @cal_position NVARCHAR(MAX), @auto_transfer NVARCHAR(MAX)

		SET @cal_position = 'EXEC spa_deal_insert_update_jobs ''i'', ''' + @after_insert_process_table + ''''
		SET @job_name = 'Deal_Post_Copy_Operations_' + @job_process_id
 		
		--EXEC spa_run_sp_as_job @job_name, @sql, 'spa_deal_insert_update_jobs', @user_name
		
		-- transfer deal
		SET @auto_transfer = 'EXEC spa_auto_transfer @source_deal_header_id = ' + CAST(@deal_id AS NVARCHAR(20))
		--SET @job_name = 'DealTransfer_' + @job_process_id
		--EXEC spa_run_sp_as_job @job_name, @sql, 'spa_auto_transfer', @user_name
		
		--Add logic to insert pricing details.
		IF NULLIF(@deal_price_data_process_id, '') IS NOT NULL
		BEGIN
			DECLARE @price_process_id NVARCHAR(50) = dbo.FNAGetNewID()			
			
			IF @deal_price_data_process_id IS NOT NULL
			BEGIN
				DECLARE @pricing_process_table NVARCHAR(2000)

				SET @pricing_process_table = 'adiha_process.dbo.pricing_xml_' + dbo.FNADBUser() + '_' + @deal_price_data_process_id

				EXEC ('
					DELETE FROM ' + @pricing_process_table + '
					WHERE update_status IS NULL
				')

				IF OBJECT_ID('tempdb..#pricing_table_status') IS NOT NULL
					DROP TABLE #pricing_table_status

				CREATE TABLE #pricing_table_status (
					check_flag BIT
				)

				EXEC ('
					INSERT INTO #pricing_table_status
					SELECT TOP 1 1 FROM ' + @pricing_process_table + '
				')
			END
			
			IF NOT EXISTS (SELECT 1 FROM #pricing_table_status)
				SET @step1 = ''

			SET @step1 = '
				DECLARE @flag NCHAR(1),
						@source_deal_detail_id INT,
						@xml_value NVARCHAR(MAX),
						@apply_to_xml NVARCHAR(MAX),
						@is_apply_to_all NCHAR(1),
						@call_from NVARCHAR(50),
						@process_id NVARCHAR(200)

				DECLARE @get_source_deal_detail_id CURSOR
				SET @get_source_deal_detail_id = CURSOR FOR

				SELECT ''m'',
						sdd.source_deal_detail_id,
						p.xml_value,
						p.apply_to_xml,
						p.is_apply_to_all,
						p.call_from,
						p.process_id
				FROM ' + @detail_process_table + ' d
				INNER JOIN ' + @pricing_process_table + ' p
					ON d.source_deal_detail_id = p.source_deal_detail_id
				INNER JOIN source_deal_detail sdd 
					ON CONVERT(NVARCHAR(10), d.term_start, 120) <= CONVERT(NVARCHAR(10), sdd.term_start, 120)
						AND CONVERT(NVARCHAR(10), d.term_end, 120) >= CONVERT(NVARCHAR(10), sdd.term_end, 120)
						AND d.blotterleg = sdd.leg
				WHERE sdd.source_deal_header_id = ' + CAST(@deal_id AS NVARCHAR(10)) + '

				OPEN @get_source_deal_detail_id
				FETCH NEXT
				FROM @get_source_deal_detail_id INTO @flag, @source_deal_detail_id, @xml_value, @apply_to_xml, @is_apply_to_all, @call_from, @process_id
				WHILE @@FETCH_STATUS = 0
				BEGIN
					EXEC [dbo].[spa_deal_pricing_detail] @flag = @flag,
														@source_deal_detail_id = @source_deal_detail_id,
														@xml = @xml_value,
														@apply_to_xml = @apply_to_xml,
														@is_apply_to_all = @is_apply_to_all,
														@call_from = @call_from,
														@process_id = @process_id,
														@mode = ''save'',
														@xml_process_id = NULL
				FETCH NEXT
				FROM @get_source_deal_detail_id INTO @flag, @source_deal_detail_id, @xml_value, @apply_to_xml, @is_apply_to_all, @call_from, @process_id
				END
				CLOSE @get_source_deal_detail_id
				DEALLOCATE @get_source_deal_detail_id;

			'
			--Add logic to insert provisional pricing details.
			IF NULLIF(@deal_provisional_price_data_process_id, '') IS NOT NULL
			BEGIN
				DECLARE @provisional_price_process_id NVARCHAR(50) = dbo.FNAGetNewID()			
			
				IF @deal_price_data_process_id IS NOT NULL
				BEGIN
					DECLARE @provisional_pricing_process_table NVARCHAR(2000)

					SET @provisional_pricing_process_table = 'adiha_process.dbo.provisional_pricing_xml_' + dbo.FNADBUser() + '_' + @deal_provisional_price_data_process_id

					EXEC ('
						DELETE FROM ' + @provisional_pricing_process_table + '
						WHERE update_status IS NULL
					')

					IF OBJECT_ID('tempdb..#provisional_pricing_table_status') IS NOT NULL
						DROP TABLE #provisional_pricing_table_status

					CREATE TABLE #provisional_pricing_table_status (
						check_flag BIT
					)

					EXEC ('
						INSERT INTO #provisional_pricing_table_status
						SELECT TOP 1 1 FROM ' + @provisional_pricing_process_table + '
					')
				END
			
				IF NOT EXISTS (SELECT 1 FROM #provisional_pricing_table_status)
					SET @step1 = ''

				SET @step1 = ISNULL(@step1, '')

				SET @step1 += '

					DECLARE @flag_p NCHAR(1),
							@source_deal_detail_id_p INT,
							@xml_value_p NVARCHAR(MAX),
							@apply_to_xml_p NVARCHAR(MAX),
							@is_apply_to_all_p NCHAR(1),
							@call_from_p NVARCHAR(50),
							@process_id_p NVARCHAR(200)

					DECLARE @get_source_deal_detail_id_p CURSOR
					SET @get_source_deal_detail_id_p = CURSOR FOR

					SELECT ''m'',
							sdd.source_deal_detail_id,
							p.xml_value,
							p.apply_to_xml,
							p.is_apply_to_all,
							p.call_from,
							p.process_id
					FROM ' + @detail_process_table + ' d
					INNER JOIN ' + @provisional_pricing_process_table + ' p
						ON d.source_deal_detail_id = p.source_deal_detail_id
					INNER JOIN source_deal_detail sdd 
						ON CONVERT(NVARCHAR(10), d.term_start, 120) <= CONVERT(NVARCHAR(10), sdd.term_start, 120)
							AND CONVERT(NVARCHAR(10), d.term_end, 120) >= CONVERT(NVARCHAR(10), sdd.term_end, 120)
							AND d.blotterleg = sdd.leg
					WHERE sdd.source_deal_header_id = ' + CAST(@deal_id AS NVARCHAR(10)) + '

					OPEN @get_source_deal_detail_id_p
					FETCH NEXT
					FROM @get_source_deal_detail_id_p INTO @flag_p, @source_deal_detail_id_p, @xml_value_p, @apply_to_xml_p, @is_apply_to_all_p, @call_from_p, @process_id_p
					WHILE @@FETCH_STATUS = 0
					BEGIN
						EXEC [dbo].[spa_deal_pricing_detail_provisional] @flag = @flag_p,
															@source_deal_detail_id = @source_deal_detail_id_p,
															@xml = @xml_value_p,
															@apply_to_xml = @apply_to_xml_p,
															@is_apply_to_all = @is_apply_to_all_p,
															@call_from = @call_from_p,
															@process_id = @process_id_p,
															@mode = ''save'',
															@xml_process_id = NULL
					FETCH NEXT
					FROM @get_source_deal_detail_id_p INTO @flag_p, @source_deal_detail_id_p, @xml_value_p, @apply_to_xml_p, @is_apply_to_all_p, @call_from_p, @process_id_p
					END
					CLOSE @get_source_deal_detail_id_p
					DEALLOCATE @get_source_deal_detail_id_p
				'

				SET @step1 = NULLIF(@step1, '')
			END
		END
		
		IF @step1 IS NOT NULL
			EXEC spa_run_multi_step_job @job_name = @job_name, 
									@job_description  = 'Post deal copy operations',
									@step1 = @step1,
									@step2 = @cal_position,
									@step3 = @auto_transfer,							
									@process_id = @job_process_id
		ELSE
			EXEC spa_run_multi_step_job @job_name = @job_name, 
									@job_description  = 'Post deal copy operations',
									@step1 = @cal_position,
									@step2 = @auto_transfer,							
									@process_id = @job_process_id


		DROP TABLE #temp_header_columns
		DROP TABLE #temp_sdh
		DROP TABLE #detail_xml_columns
		DROP TABLE #temp_sdd
		DROP TABLE #temp_source_deal_detail
		DROP TABLE #temp_inserted_sdh
		DROP TABLE #temp_sdg
		DROP TABLE #temp_inserted_sdd
	END TRY
	BEGIN CATCH
		DECLARE @desc NVARCHAR(500),
				@err_no INT
		
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = dbo.FNAHandleDBError(10131000)
		SELECT @err_no = -1
		
 		EXEC spa_ErrorHandler @err_no, 'source_deal_header', 'spa_deal_copy', 'Error', @DESC, ''
	END CATCH
END