IF OBJECT_ID (N'[dbo].[spa_remit]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_remit]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Used for Remit reporting

	Parameters
	@create_date_from		   : Create Date From
	@create_date_to			   : Create Date To
	@generate_xml			   : Generate XML
	@generate_uti			   : - '1' Generate UTI
	                             - '0' UTI won't be generated
	@report_type			   :  Report Type
	@process_id				   :  Process ID
	@flag					   :  Flag
								  - 'i' Generate report
								  - 'r'	Capture response
	@batch_unique_id		   : Batch Unique ID
	@cancellation			   : Cancellation
	@source					   : Source
	@mirror_reporting		   : Mirror reporting1 
	                             - '1' -> Mirror reporting
								 - '0' -> Mirror reporting is not done
	@intragroup				   :  Intra Group
	@as_of_date				   : As of date
	@batch_file_path		   : Batch File Path
	@force_process			   : Force Process
	@sub_type				   : Sub Type
	@include_bfi			   : Include BFI 
	@submission_type		   : Submission Type
	@submission_status		   : Submission Status
	@filter_table_process_id   : Filter Table Process ID
	@batch_process_id		   : Batch process ID
	@batch_report_param	       : Batch report param
*/

CREATE PROCEDURE [dbo].[spa_remit]
	@create_date_from VARCHAR(100) = NULL,
	@create_date_to VARCHAR(100) = NULL,
	@generate_xml INT = 0,
	@generate_uti INT = 0,
	@report_type INT = NULL,
	@process_id VARCHAR(MAX) = NULL,
	@flag CHAR(1) = NULL,
	@batch_unique_id VARCHAR(1000) = NULL,
	@cancellation CHAR(1) = 0,
	@source XML = NULL OUTPUT,
	@mirror_reporting BIT = NULL,
	@intragroup BIT = NULL,
	@as_of_date DATETIME = NULL,
	@batch_file_path VARCHAR (1024) = NULL,
	@force_process BIT = 0,
	@sub_type CHAR(1) = NULL,
	@include_bfi BIT = NULL,
	@submission_type INT = NULL,
	@submission_status INT = NULL,
	@filter_table_process_id VARCHAR(100) = NULL,
	@file_transfer_endpoint_id INT = NULL,
	@remote_directory NVARCHAR(2000) = NULL,
	@batch_process_id VARCHAR(120) = NULL,
	@batch_report_param	VARCHAR(5000) = NULL
AS
/*-------------------------Debug Section---------------------
DECLARE	@create_date_from VARCHAR(100) = NULL,
		@create_date_to VARCHAR(100) = NULL,
		@generate_xml INT = NULL,
		@generate_uti INT = NULL,
		@report_type VARCHAR(MAX) = NULL,
		@process_id VARCHAR(MAX) = NULL,
		@flag CHAR(1) = NULL,
		@batch_unique_id VARCHAR(1000) = NULL,
		@cancellation CHAR(1) = NULL,
		@source XML = NULL,
		@mirror_reporting BIT = NULL,
		@intragroup BIT = NULL,
		@as_of_date DATETIME = NULL,
		@batch_file_path VARCHAR (1024) = NULL,
		@force_process BIT = NULL,
		@sub_type CHAR(1) = NULL,
		@include_bfi BIT = NULL,
		@submission_type INT = NULL,
		@submission_status INT = NULL,
		@filter_table_process_id VARCHAR(100),
		@batch_process_id VARCHAR(120) = NULL,
		@batch_report_param	VARCHAR(5000) = NULL

SELECT @sub_book_id='3490',@sub_id=NULL,@stra_id=NULL,@book_id=NULL,@create_date_from='2017-01-01',@create_date_to='2019-04-22',@flag='s',@report_type='39405',@submission_type='44702',@submission_status='39500'
		
--------------------------------------------------------------------------*/
SET NOCOUNT ON
/*************************************Hardcoding Value Start********************************************************/
DECLARE @RRM VARCHAR(50),
        @RRM_code CHAR(3),
        @dayaheadcurve VARCHAR(500),
		@output_result NVARCHAR(MAX),
	    @download_files NVARCHAR(MAX),
	    @xml_file_content VARCHAR(MAX),
	    @remote_location NVARCHAR(2000),
	    @server_location NVARCHAR(1000),
        @user_name VARCHAR(50),
	    @desc_success VARCHAR(MAX),
	    @url VARCHAR(MAX),
	    @process_table VARCHAR(200),
	    @full_file_path VARCHAR(200),
	    @email_description VARCHAR(MAX)

SET @RRM = 'B00001014.NL'---RWE Group Business Services GmbH
SET @RRM_code = 'ACE'
SET @dayaheadcurve = '23,164,166,198,199,1959,1958,169,165,486,82,206,207,10,152,155,5,145,352,97,355'

DECLARE @job_name VARCHAR(200),
		@user_login_id VARCHAR(50) = dbo.FNADBUser(),
		@desc VARCHAR(MAX)

IF @batch_process_id IS NOT NULL
	SET @job_name = 'batch_' + @batch_process_id

/*************************************Hardcoding Value End********************************************************/
DECLARE @ssbm_table_name VARCHAR(120),
		@deal_header_table_name VARCHAR(120),
		@deal_detail_table_name VARCHAR(120)

SET @ssbm_table_name = dbo.FNAProcessTableName('ssbm', dbo.FNADBUser(), @filter_table_process_id)
SET @deal_header_table_name = dbo.FNAProcessTableName('deal_header', dbo.FNADBUser(), @filter_table_process_id)
SET @deal_detail_table_name = dbo.FNAProcessTableName('deal_detail', dbo.FNADBUser(), @filter_table_process_id)

DECLARE @phy_remit_table_name VARCHAR(50)
SET @as_of_date = ISNULL(@as_of_date, GETDATE())

IF ISNULL(@submission_type, @report_type) = '44705'
BEGIN
    SET @phy_remit_table_name = 'source_ecm'
    SET @report_type = NULL
END
ELSE IF ISNULL(@submission_type, @report_type) = '44701'
BEGIN
    SET @phy_remit_table_name = 'source_ice_trade_vault'
    SET @report_type = NULL
END
ELSE
BEGIN
    IF (@report_type = 39400)
	   SET @phy_remit_table_name = 'source_remit_non_standard'
    ELSE IF (@report_type IN (39401, 39405))
	   SET @phy_remit_table_name = 'source_remit_standard'
    ELSE IF (@report_type IN (39402))
	   SET @phy_remit_table_name = 'source_remit_transport'
END

IF @create_date_from IS NULL
BEGIN
    SET @create_date_from = CONVERT(VARCHAR(10), DATEADD(MONTH, -1, GETDATE()), 120)
END

IF @create_date_to IS NULL
BEGIN
    SET @create_date_to = CONVERT(VARCHAR(10), GETDATE(), 120)
END

IF OBJECT_ID('tempdb..#temp_source_code_map') IS NOT NULL
    DROP TABLE #temp_source_code_map

IF OBJECT_ID('tempdb..#temp_deals') IS NOT NULL
    DROP TABLE #temp_deals
		
IF OBJECT_ID('tempdb..#temp_deal_details') IS NOT NULL
    DROP TABLE #temp_deal_details

IF OBJECT_ID('tempdb..#temp_cpty_udf_values') IS NOT NULL
    DROP TABLE #temp_cpty_udf_values

IF OBJECT_ID(N'tempdb..#formula_curves') IS NOT NULL
    DROP TABLE #formula_curves

IF OBJECT_ID('tempdb..#temp_messages') IS NOT NULL
    DROP TABLE #temp_messages

IF OBJECT_ID('tempdb..#remit_message_validate') IS NOT NULL
	DROP TABLE #remit_message_validate	

DECLARE @show_data INT = 0,
		@xml XML,
		@sql2 VARCHAR(MAX),
		@_sql VARCHAR(MAX),
		@sp VARCHAR(MAX),
		@submission_name VARCHAR(100)

SELECT @submission_name = code
FROM static_Data_value
WHERE value_id = @report_type

SET @submission_name = CASE WHEN @sub_type = 'e' THEN 'ECM' ELSE 'REMIT ' + ISNULL(@submission_name, '') END

IF @flag = 'd'---Delete the selected one or multiple rows
BEGIN
    EXEC ('
		DELETE srns
		FROM ' + @phy_remit_table_name + ' srns
		WHERE process_id IN (' + @process_id + ')
	')
    
    EXEC spa_ErrorHandler 0, 'Source Remit table', 'spa_remit', 'Success', 'Row deleted successfully.', ''
    RETURN
END
ELSE 
IF @flag = 'u'
BEGIN
	IF OBJECT_ID('tempdb..##remit_message_validate') IS NOT NULL
		DROP TABLE #remit_message_validate

	CREATE TABLE #remit_message_validate (
		ID VARCHAR(100) COLLATE DATABASE_DEFAULT
	)

	DECLARE @sql_message_validate VARCHAR(MAX)
	
	SET @sql_message_validate = '
		INSERT INTO #remit_message_validate
		SELECT src_remit_valid.id
		FROM ' + @phy_remit_table_name + ' src_remit_valid
		WHERE process_id = ''' + @process_id + '''
			AND src_remit_valid.error_validation_message IS NOT NULL
	'
	
	EXEC(@sql_message_validate)

	IF EXISTS(SELECT 1 FROM #remit_message_validate)
	BEGIN
		EXEC spa_message_board 'u', @user_login_id, NULL, @submission_name, 
			 'There are validation error(s) for deal(s). Please correct and re-run the process.',
			 '', '', 'e', @job_name, NULL, @batch_process_id, NULL
		RETURN			 
	END
	
	IF @sub_type = 'e'
	BEGIN
		EXEC spa_remit NULL, NULL, NULL, NULL, NULL, NULL, 1, @generate_uti, @report_type, @process_id, 
					   NULL, NULL, NULL, NULL, NULl, NULL, @source OUTPUT, NULL, NULL, NULL, NULL, 0, @sub_type, 0
	END
	ELSE
	BEGIN
		SELECT @batch_file_path = REPLACE(a.file_path, '\\', '\') 
		FROM (
			SELECT TOP 1 gmh.mapping_name,
						 gmv.clm1_value export_source,
						 gmv.clm2_value file_path
			FROM static_data_value sdv 
			INNER JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id AND sdv.type_id = 5500 
			INNER JOIN generic_mapping_definition gmd ON gmd.clm1_udf_id = udft.udf_template_id
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id
			INNER JOIN generic_mapping_values gmv ON gmh.mapping_table_id = gmv.mapping_table_id
			WHERE gmh.mapping_name = 'Custom Export File Path'
				AND gmv.clm1_value = '1' --Remit
		) a
		
		SET @sp = 'EXEC spa_convert_xml NULL, NULL, NULL, NULL, NULL, NULL, ''' + @process_id + ''', ' + CAST(ISNULL(@report_type, 39400) AS VARCHAR(50)) + ', ' + CAST(ISNULL(@mirror_reporting, 0) AS VARCHAR(5)) + ', ' + CAST(ISNULL(@intragroup, 0) AS VARCHAR(5)) + ', ''' + CONVERT(VARCHAR(30), @as_of_date, 120) +  ''', ' + CAST(ISNULL(@generate_uti, 0) AS CHAR(1))
		
		EXEC batch_report_process @sp, 'i', NULL, NULL, 'Run Remit XML', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
								  NULL, NULL, 'r', 1, @create_date_from, NULL, NULL, 751, 'n', @batch_unique_id, NULL, NULL,
								  NULL, NULL, NULL, @batch_file_path, NULL, NULL, 'n', NULL, '1'
	END
    
	IF @report_type = 39402 
	BEGIN
		UPDATE t
		SET t.xml_version = CASE WHEN t.xml_version IS NULL THEN ISNULL(rs.xml_version, 0) + 1 ELSE rs.xml_version END
		FROM source_remit_transport t
		CROSS APPLY (
			SELECT MAX(xml_version) xml_version
			FROM source_remit_transport
			WHERE source_deal_header_id = t.source_deal_header_id
		) rs
		WHERE t.process_id = @process_id
	END

    EXEC ('
		UPDATE ' + @phy_remit_table_name + '
		SET acer_submission_status = 39501 
		WHERE process_id = ''' + @process_id + '''
	')
 
    RETURN
END
ELSE 
IF @flag = 'v'--Grid display in view tab
BEGIN
    SET @sql2 = '
		SELECT DISTINCT
			   dbo.FNAdateformat(create_date_from) [Create Date From],
			   dbo.FNAdateformat(create_date_to) [Create Date To], 
			   sdv_rt.code [Report Type],
			   src_remit.create_user [User],
			   dbo.FNADateTimeFormat(src_remit.create_ts, 2) [Create TS],
			   sdv_st.code [Status],
			   process_id [Process ID],
			   src_remit.report_type [Report Type ID]
		FROM ' + @phy_remit_table_name + ' src_remit
		LEFT JOIN static_data_value sdv_rt ON sdv_rt.value_id = src_remit.report_type
		LEFT JOIN static_data_value sdv_st ON sdv_st.value_id = src_remit.acer_submission_status
		WHERE sdv_st.value_id <> 39500
	'
    
    IF @report_type IS NOT NULL
        SET @sql2 = @sql2 + ' AND src_remit.report_type = ' + CAST(@report_type AS VARCHAR(10))
    
    IF @create_date_from IS NOT NULL
        SET @sql2 = @sql2 + ' AND (src_remit.create_date_from BETWEEN ''' + @create_date_from + ''' AND ''' + @create_date_to + ''''
    
    IF @create_date_to IS NOT NULL
        SET @sql2 = @sql2 + ' OR src_remit.create_date_to BETWEEN ''' + @create_date_from + ''' AND ''' + @create_date_to + ''')'
    
    SET @sql2 = @sql2 + ' ORDER BY [Create Date From]'
    
    EXEC (@sql2)
    RETURN
END
ELSE 
IF @flag = 's' --Grid display in create tab
BEGIN
    SET @sql2 = '
		SELECT DISTINCT 
			   dbo.FNAdateformat(create_date_from) [Create Date From],
			   dbo.FNAdateformat(create_date_to) [Create Date To],
			   sdv_rt.code [Report Type],
			   au.user_f_name + '' '' + ISNULL(user_m_name, '' '') + user_l_name [User],
			   dbo.FNADateTimeFormat(src_remit.create_ts, 2) [Create TS],
			   sdv_st.code [Status],
			   process_id [Process ID],
			   ' + IIF(@submission_type NOT IN (44705, 44701), 'src_remit.report_type', CAST(@submission_type AS VARCHAR(10))) + ' [Report Type ID] 
		FROM ' + @phy_remit_table_name + ' src_remit
		LEFT JOIN static_data_value sdv_rt ON sdv_rt.value_id = ' + IIF(@submission_type NOT IN (44705, 44701), 'src_remit.report_type', CAST(@submission_type AS VARCHAR(10))) + '
		LEFT JOIN static_data_value sdv_st ON sdv_st.value_id = src_remit.acer_submission_status
		LEFT JOIN application_users au ON au.user_login_id = src_remit.create_user
		WHERE 1 = 1 
	'		
    IF @submission_status IS NOT NULL
        SET @sql2 = @sql2 + ' AND sdv_st.value_id = ' + CAST(@submission_status AS VARCHAR(10))

    IF @report_type IS NOT NULL
        SET @sql2 = @sql2 + ' AND src_remit.report_type = ' + CAST(@report_type AS VARCHAR(10))
    
    IF @create_date_from IS NOT NULL
        SET @sql2 = @sql2 + ' AND (src_remit.create_date_from BETWEEN ''' + @create_date_from + ''' AND ''' + @create_date_to + ''''
    
    IF @create_date_to IS NOT NULL
        SET @sql2 = @sql2 + ' OR src_remit.create_date_to BETWEEN ''' + @create_date_from + ''' AND ''' + @create_date_to + ''')'
    
    SET @sql2 = @sql2 + ' ORDER BY [Create Date From]'
	
	EXEC (@sql2)    
    RETURN
END

IF @process_id IS NOT NULL AND ISNULL(@force_process, 0) = 0
    SET @show_data = 1
	


IF @show_data = 1 AND ISNULL(@flag, 'n') NOT IN ('x', 'c')
BEGIN
	IF @report_type IN (39400,39401,39405)
	BEGIN
		
		/*Logic for mirror reporting*/
		IF OBJECT_ID('tempdb..#mirror_source_remit') IS NOT NULL
			DROP TABLE #mirror_source_remit

		CREATE TABLE #mirror_source_remit(
			id INT
		)
		
		IF @report_type = 39400
		BEGIN
			INSERT INTO #mirror_source_remit
			SELECT MAX(srns.id) id
			FROM source_remit_non_standard srns
			INNER JOIN source_deal_header sdh
				ON sdh.source_deal_header_id = srns.source_deal_header_id
			INNER JOIN maintain_udf_static_data_detail_values musddv
				ON musddv.primary_field_object_id = sdh.counterparty_id
			INNER JOIN application_ui_template_fields autf
				ON autf.application_field_id = musddv.application_field_id
			INNER JOIN user_defined_fields_template udft
				ON udft.udf_template_id = autf.udf_template_id
			WHERE srns.process_id = @process_id
			AND udft.Field_label = 'Reporting On Behalf'
			AND ISNULL(musddv.static_data_udf_values, 'n') = 'y'
			GROUP BY srns.source_deal_header_id
			HAVING COUNT(srns.source_deal_header_id) = 1

			INSERT INTO [source_remit_non_standard] (
        		[source_deal_header_id],[deal_id],[sub_book_id],[id_of_the_market_participant_or_counterparty],[type_of_code_used_in_field_1],[id_of_the_other_market_participant_or_counterparty],[type_of_code_used_in_field_3],[reporting_entity_id],[type_of_code_used_in_field_5],[beneficiary_id],[type_of_code_used_in_field_7],[trading_capacity_of_the_market_participant_or_counterparty_in_field_1],[buy_sell_indicator],[contract_id],[contract_date],[contract_type],[energy_commodity],[price],[price_formula],[estimated_notional_amount],[notional_currency],[total_notional_contract_quantity],[volume_optionality_capacity],[notional_quantity_unit],[volume_optionality],[volume_optionality_frequency],[volume_optionality_intervals],[type_of_index_price],[fixing_index],[fixing_index_types],[fixing_index_sources],[first_fixing_date],[last_fixing_date],[fixing_frequency],[settlement_method],[option_style],[option_type],[option_first_exercise_date],[option_last_exercise_date],[option_exercise_frequency],[option_strike_index],[option_strike_index_type],[option_strike_index_source],[option_strike_price],[delivery_point_or_zone],[delivery_start_date],[delivery_end_date],[load_type],[action_type],[report_type],[create_date_from],[create_date_to],[acer_submission_status],[acer_submission_date],[acer_confirmation_date],[process_id],[error_validation_message],[file_export_name],[hash_of_concatenated_values],[progressive_number]
				)
				SELECT [source_deal_header_id],[deal_id],[sub_book_id],[id_of_the_other_market_participant_or_counterparty],[type_of_code_used_in_field_1],[id_of_the_market_participant_or_counterparty],[type_of_code_used_in_field_3],[reporting_entity_id],[type_of_code_used_in_field_5],[beneficiary_id],[type_of_code_used_in_field_7],[trading_capacity_of_the_market_participant_or_counterparty_in_field_1],CASE WHEN [buy_sell_indicator] = 'B' THEN 'S' ELSE 'B' END,[contract_id],[contract_date],[contract_type],[energy_commodity],[price],[price_formula],[estimated_notional_amount],[notional_currency],[total_notional_contract_quantity],[volume_optionality_capacity],[notional_quantity_unit],[volume_optionality],[volume_optionality_frequency],[volume_optionality_intervals],[type_of_index_price],[fixing_index],[fixing_index_types],[fixing_index_sources],[first_fixing_date],[last_fixing_date],[fixing_frequency],[settlement_method],[option_style],[option_type],[option_first_exercise_date],[option_last_exercise_date],[option_exercise_frequency],[option_strike_index],[option_strike_index_type],[option_strike_index_source],[option_strike_price],[delivery_point_or_zone],[delivery_start_date],[delivery_end_date],[load_type],[action_type],[report_type],[create_date_from],[create_date_to],[acer_submission_status],[acer_submission_date],[acer_confirmation_date],[process_id],[error_validation_message],[file_export_name],[hash_of_concatenated_values],[progressive_number]
				FROM source_remit_non_standard srns
				INNER JOIN #mirror_source_remit msr
					ON msr.id = srns.id
				WHERE process_id = @process_id

				--IF different create_ts, data appears in different row
				UPDATE srns
					SET srns.create_ts = tbl.create_ts
				FROM source_remit_non_standard srns
				OUTER APPLY (SELECT TOP 1 create_ts
					FROM source_remit_non_standard
					WHERE process_id = srns.process_id
					ORDER BY create_ts ASC
				) tbl
				WHERE process_id = @process_id
		END
		ELSE IF @report_type IN (39401,39405)
		BEGIN
			INSERT INTO #mirror_source_remit
			SELECT MAX(srns.id) id
			FROM source_remit_standard srns
			INNER JOIN source_deal_header sdh
				ON sdh.source_deal_header_id = srns.source_deal_header_id
			INNER JOIN maintain_udf_static_data_detail_values musddv
				ON musddv.primary_field_object_id = sdh.counterparty_id
			INNER JOIN application_ui_template_fields autf
				ON autf.application_field_id = musddv.application_field_id
			INNER JOIN user_defined_fields_template udft
				ON udft.udf_template_id = autf.udf_template_id
			WHERE srns.process_id = @process_id
			AND udft.Field_label = 'Reporting On Behalf'
			AND ISNULL(musddv.static_data_udf_values, 'n') = 'y'
			GROUP BY srns.source_deal_header_id
			HAVING COUNT(srns.source_deal_header_id) = 1

			INSERT INTO [source_remit_standard] (
        	[source_deal_header_id],[deal_id],[sub_book_id],[market_id_participant_counterparty],[type_of_code_field_1],[trader_id_market_participant],[other_id_market_participant_counterparty],[type_of_code_field_4],[reporting_entity_id],[type_of_code_field_6],[beneficiary_id],[type_of_code_field_8],[trading_capacity_market_participant],[buy_sell_indicator],[initiator_aggressor],[order_id],[order_type],[order_condition],[order_status],[minimum_execution_volume],[price_limit],[undisclosed_volume],[order_duration],[contract_id],[contract_name],[contract_type],[energy_commodity],[fixing_index_or_reference_price],[settlement_method],[organised_market_place_id_otc],[contract_trading_hours],[last_trading_date_and_time],[transaction_timestamp],[unique_transaction_id],[linked_transaction_id],[linked_order_id],[voice_brokered],[price],[index_value],[price_currency],[notional_amount],[notional_currency],[quantity_volume],[total_notional_contract_quantity],[quantity_unit_field_40_and_41],[termination_date],[option_style],[option_type],[option_exercise_date],[option_strike_price],[delivery_point_or_zone],[delivery_start_date],[delivery_end_date],[duration],[load_type],[days_of_the_week],[load_delivery_intervals],[delivery_capacity],[quantity_unit_used_in_field_55],[price_time_interval_quantity],[action_type],[report_type],[create_date_from],[create_date_to],[acer_submission_status],[acer_submission_date],[acer_confirmation_date],[process_id],[error_validation_message],[file_export_name],[hash_of_concatenated_values],[progressive_number]
				)
				SELECT [source_deal_header_id],[deal_id],[sub_book_id],[other_id_market_participant_counterparty],[type_of_code_field_1],[trader_id_market_participant],[market_id_participant_counterparty],[type_of_code_field_4],[reporting_entity_id],[type_of_code_field_6],[beneficiary_id],[type_of_code_field_8],[trading_capacity_market_participant],CASE WHEN [buy_sell_indicator] = 'B' THEN 'S' ELSE 'B' END,[initiator_aggressor],[order_id],[order_type],[order_condition],[order_status],[minimum_execution_volume],[price_limit],[undisclosed_volume],[order_duration],[contract_id],[contract_name],[contract_type],[energy_commodity],[fixing_index_or_reference_price],[settlement_method],[organised_market_place_id_otc],[contract_trading_hours],[last_trading_date_and_time],[transaction_timestamp],[unique_transaction_id],[linked_transaction_id],[linked_order_id],[voice_brokered],[price],[index_value],[price_currency],[notional_amount],[notional_currency],[quantity_volume],[total_notional_contract_quantity],[quantity_unit_field_40_and_41],[termination_date],[option_style],[option_type],[option_exercise_date],[option_strike_price],[delivery_point_or_zone],[delivery_start_date],[delivery_end_date],[duration],[load_type],[days_of_the_week],[load_delivery_intervals],[delivery_capacity],[quantity_unit_used_in_field_55],[price_time_interval_quantity],[action_type],[report_type],[create_date_from],[create_date_to],[acer_submission_status],[acer_submission_date],[acer_confirmation_date],[process_id],[error_validation_message],[file_export_name],[hash_of_concatenated_values],[progressive_number]
				FROM source_remit_standard srs
				INNER JOIN #mirror_source_remit msr
					ON msr.id = srs.id
				WHERE srs.process_id = @process_id

				--IF different create_ts, data appears in different row
				UPDATE srns
					SET srns.create_ts = tbl.create_ts
				FROM source_remit_standard srns
				OUTER APPLY (SELECT TOP 1 create_ts
					FROM source_remit_standard
					WHERE process_id = srns.process_id
					ORDER BY create_ts ASC
				) tbl
				WHERE process_id = @process_id
		END
	END

    IF ISNULL(@generate_xml, -1) <> 1 --Excel export of selected row
    BEGIN
		IF @report_type IS NULL
		BEGIN
			SELECT [TRMDealID] = source_deal_header_id,
				   [RefID] = deal_id,
				   [ProcessID] = process_id,
				   [Subsidiary] = sub.entity_name,
				   [Strategy] = stra.entity_name,
				   [Book] = book.entity_name,
				   [Sub Book] = ssbm.logical_name,
				   [Document ID] = document_id,
				   [Document Usage] = document_usage,
				   [Sender Id] = sender_id,
				   [Receiver Id] = receiver_id,
				   [Receiver Role] = receiver_role,
				   [Document Version] = document_version,
				   [Market] = market,
				   [Commodity] = commodity,
				   [Transaction Type] = transaction_type,
				   [Delivery Point Area] = delivery_point_area,
				   [Buyer Party] = buyer_party,
				   [Seller Party] = seller_party,
				   [Load Type] = load_type,
				   [Agreement] = agreement,
				   [Currency] = currency,
				   [Total Volume] = total_volume,
				   [Total Volume Unit] = total_volume_unit,
				   [Trade Date] = CONVERT(VARCHAR(10), trade_date, 120),
				   [Capacity Unit] = capacity_unit,
				   [Price Unit Currency] = price_unit_currency,
				   [Price Unit Capacity Unit] = price_unit_capacity_unit,
				   [Total Contract Value] = total_contract_value,
				   [Delivery Start] = delivery_start,
				   [Delivery End] = delivery_end,
				   [Contract Capacity] = contract_capacity,
				   [Buyer Hubcode] = buyer_hubcode,
				   [Seller Hubcode] = seller_hubcode,
				   [Trader Name] = trader_name,
				   [Price] = price,
				   [Report Type] = report_type,
				   [Create Date From] = create_date_from,
				   [Create Date To] = create_date_to,
				   [Submission Status] = acer_submission_status,
				   [Submission Date] = CONVERT(VARCHAR(10), acer_submission_date, 120),
				   [Confirmation Date] = CONVERT(VARCHAR(10), acer_confirmation_date, 120),
				   [ErrorValidationMessage] = error_validation_message,
				   [Broker Fee] = broker_fee,
				   [ECM Document Type] = ecm_document_type,
				   [ECM_Log_state] = e.[state],
				   [ECM_Log_transfer_id] = e.transfer_id,
				   [ECM_Log_reason_code] = e.reason_code, 
				   [ECM_Log_reason_text] = e.reason_text,
				   [ECM_Log_timestamp] = e.[timestamp],
				   [ECM_Log_create_ts] = e.create_ts
            FROM source_ecm se
			LEFT JOIN source_system_book_map ssbm ON se.sub_book_id = ssbm.book_deal_type_map_id
			LEFT JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
				AND book.hierarchy_level = 0
			LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id
				AND stra.hierarchy_level = 1
			LEFT JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
				AND sub.hierarchy_level = 2
			OUTER APPLY (
				SELECT erl.[state], erl.transfer_id, erl.reason_code, erl.reason_text, erl.[timestamp], erl.create_ts
				FROM ecm_response_log erl
			    WHERE erl.document_id = se.document_id
					AND erl.document_version = se.document_version
			) e
			WHERE process_id = @process_id
			ORDER BY se.source_deal_header_id, se.ecm_document_type, se.create_ts
		END
		ELSE IF @report_type = 39400
        BEGIN
			SELECT [TRMDealID] = srns.source_deal_header_id,
                   [RefID] = srns.deal_id,
                   [ProcessID] = process_id,
                   [Subsidiary] = sub.entity_name,
                   [Strategy] = stra.entity_name,
                   [Book] = book.entity_name,
                   [Sub Book] = ssbm.logical_name,
				   [Report Type] = sdv_report_type.code,
				   [Reporting Counterparty] = CASE WHEN ROW_NUMBER() OVER ( PARTITION BY srns.process_id,srns.source_deal_header_id ORDER BY srns.id) = 1
										THEN sc_sub.counterparty_name
									ELSE sc.counterparty_name
									END,
                   [ID of the market participant or counterparty] = id_of_the_market_participant_or_counterparty,
                   [Type of code used in field 1] = type_of_code_used_in_field_1,
                   [ID of the other market participant or counterparty] = id_of_the_other_market_participant_or_counterparty,
                   [Type of code used in field 3] = type_of_code_used_in_field_3,
                   [Reporting entity ID] = reporting_entity_id,
                   [Type of code used in field 5] = type_of_code_used_in_field_5,
                   [Beneficiary ID] = beneficiary_id,
                   [Type of code used in field 7] = type_of_code_used_in_field_7,
                   [Trading capacity of the market participant or counterparty in field 1] = trading_capacity_of_the_market_participant_or_counterparty_in_field_1,
                   [Buy/sell indicator] = buy_sell_indicator,
                   [Contract ID] = srns.contract_id,
                   [Contract date] = CONVERT(VARCHAR(10), contract_date, 120),
                   [Contract type] = contract_type,
                   [Energy commodity] = energy_commodity,
                   [Price or price formula] = CASE WHEN price_formula IS NULL THEN CAST(dbo.fnaremovetrailingzeroes(price) AS VARCHAR(50))
												   WHEN CAST(dbo.fnaremovetrailingzeroes(price) AS VARCHAR(50)) IS NULL THEN price_formula
												   ELSE price_formula + ';' + CAST(dbo.fnaremovetrailingzeroes(price) AS VARCHAR(50))
											  END,
                   [Estimated notional amount] = dbo.fnaremovetrailingzeroes(estimated_notional_amount),
                   [Notional currency] = notional_currency,
                   [Total notional contract quantity] = dbo.fnaremovetrailingzeroes(total_notional_contract_quantity),
                   [Volume optionality capacity] = volume_optionality_capacity,
                   [Notional quantity unit] = notional_quantity_unit,
                   [Volume optionality] = volume_optionality,
                   [Volume optionality frequency] = volume_optionality_frequency,
                   [Volume optionality intervals] = volume_optionality_intervals,
                   [Type of index price] = type_of_index_price,
                   [Fixing index] = fixing_index,
                   [Fixing index types] = fixing_index_types,
                   [Fixing index sources] = fixing_index_sources,
                   [First fixing date] = first_fixing_date,
                   [Last fixing date] = last_fixing_date,
                   [Fixing frequency] = fixing_frequency,
                   [Settlement method] = settlement_method,
                   [Option style] = option_style,
                   [Option type] = srns.option_type,
                   [Option first exercise date] = CONVERT(VARCHAR(10), option_first_exercise_date, 120),
                   [Option last exercise date] = CONVERT(VARCHAR(10), option_last_exercise_date, 120),
                   [Option exercise frequency] = option_exercise_frequency,
                   [Option strike index] = option_strike_index,
                   [Option strike index type] = option_strike_index_type,
                   [Option strike index source] = option_strike_index_source,
                   [Option strike price] = option_strike_price,
                   [Delivery point or zone] = delivery_point_or_zone,
                   [Delivery start date] = CONVERT(VARCHAR(10), delivery_start_date, 120),
                   [Delivery end date] = CONVERT(VARCHAR(10), delivery_end_date, 120),
                   [Load type] = load_type,
                   [Action type] = action_type,
                   [ErrorValidationMessage] = error_validation_message
			FROM source_remit_non_standard srns
			INNER JOIN source_deal_header sdh
				ON sdh.source_deal_header_id = srns.source_deal_header_id
			INNER JOIN source_counterparty sc
				ON sc.source_counterparty_id = sdh.counterparty_id
			LEFT JOIN source_system_book_map ssbm ON srns.sub_book_id = ssbm.book_deal_type_map_id
			LEFT JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
				AND book.hierarchy_level = 0
			LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id
				AND stra.hierarchy_level = 1
			LEFT JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
				AND sub.hierarchy_level = 2
			LEFT JOIN fas_subsidiaries fs
				ON fs.fas_subsidiary_id = sub.entity_id
			LEFT JOIN source_counterparty sc_sub
				ON sc_sub.source_counterparty_id = fs.counterparty_id
			LEFT JOIN static_data_value sdv_report_type
				ON sdv_report_type.value_id = srns.report_type
            WHERE process_id = @process_id
        END
        ELSE IF @report_type IN(39401, 39405)
		BEGIN
			SELECT srns.source_deal_header_id [TRMDeal ID], 
				   srns.deal_id [Ref ID], 
				   process_id [Process ID], 
				   sub.entity_name [Subsidiary], 
				   stra.entity_name [Strategy], 
				   book.entity_name [Book], 
				   ssbm.logical_name [SubBook], 
				   sdv_report_type.code [Report Type],
				   CASE WHEN ROW_NUMBER() OVER ( PARTITION BY srns.process_id,srns.source_deal_header_id ORDER BY srns.id) = 1
						THEN sc_sub.counterparty_name
				   ELSE sc.counterparty_name
				   END [Reporting Counterparty],
				   [market_id_participant_counterparty] [ID of the market participant or counterparty], 
				   [type_of_code_field_1] [Type of code used in field 1], 
				   [trader_id_market_participant] [ID of the trader participant or counterparty], 
				   [other_id_market_participant_counterparty] [ID of the other participant or counterparty], 
				   [type_of_code_field_4] [Type of code used in field 4], 
				   [reporting_entity_id] [Reporting Entity ID], 
				   [type_of_code_field_6] [Type of code used in field 6], 
				   [beneficiary_id] [Beneficiary ID], 
				   [type_of_code_field_8] [Type of code used in field 8], 
				   [trading_capacity_market_participant] [Trading capacity of the market participant or counterparty in field 1], 
				   [buy_sell_indicator] [Buy sell indicator], 
				   [initiator_aggressor] [Initiator Aggressor], 
				   [order_id] [Order ID], 
				   [order_type] [Order Type], 
				   [order_condition] [Order Condition], 
				   [order_status] [Order Status], 
				   [minimum_execution_volume] [Min Execution Volume], 
				   [price_limit] [Price Limit], 
				   [undisclosed_volume] [Undisclosed Volume], 
				   [order_duration] [Order Duration], 
				   srns.[contract_id] [Contract ID], 
				   [contract_name] [Contract Name], 
				   [contract_type] [Contract Type], 
				   [energy_commodity] [Energy Commodity], 
				   [fixing_index_or_reference_price] [Fixing index or reference price], 
				   [settlement_method] [Settlement method], 
				   [organised_market_place_id_otc] [Organised market place ID / OTC], 
				   [contract_trading_hours] [Contract trading hours], 
				   [last_trading_date_and_time] [Last trading date and time], 
				   [transaction_timestamp] [Transaction timestamp], 
				   [unique_transaction_id] [Unique transaction ID], 
				   [linked_transaction_id] [Linked transaction ID], 
				   [linked_order_id] [Linked order ID], 
				   [voice_brokered] [Voice-brokered], 
				   [price] [Price], 
				   [index_value] [Index value], 
				   [price_currency] [Price currency], 
				   [notional_amount] [Notional amount], 
				   [notional_currency] [Notional currency], 
				   [quantity_volume] [Quantity / Volume], 
				   [total_notional_contract_quantity] [Total notional contract quantity], 
				   [quantity_unit_field_40_and_41] [Quantity unit for field 40 and 41], 
				   [termination_date] [Termination date], 
				   [option_style] [Option style], 
				   srns.[option_type] [Option type], 
				   [option_exercise_date] [Option exercise date], 
				   [option_strike_price] [Option strike price], 
				   [delivery_point_or_zone] [Delivery point or zone], 
				   dbo.FNADateFormat(delivery_start_date) [Delivery start date], 
				   dbo.FNADateFormat(delivery_end_date) [Delivery end date], 
				   [duration] [Duration], 
				   [load_type] [Load Type], 
				   [days_of_the_week] [Days of the week], 
				   [load_delivery_intervals] [Load delivery Intervals], 
				   [delivery_capacity] [Delivery capacity], 
				   [quantity_unit_used_in_field_55] [Quantity unit used in field 55], 
				   [price_time_interval_quantity] [Price/time interval quantity], 
				   [action_type] [Action type], 
				   error_validation_message [Error Validation Message]
			FROM source_remit_standard srns
			INNER JOIN source_deal_header sdh
				ON sdh.source_deal_header_id = srns.source_deal_header_id
			INNER JOIN source_counterparty sc
				ON sc.source_counterparty_id = sdh.counterparty_id
			LEFT JOIN source_system_book_map ssbm ON srns.sub_book_id = ssbm.book_deal_type_map_id
			LEFT JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
				AND book.hierarchy_level = 0
			LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id
				AND stra.hierarchy_level = 1
			LEFT JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
				AND sub.hierarchy_level = 2
			LEFT JOIN fas_subsidiaries fs
				ON fs.fas_subsidiary_id = sub.entity_id
			LEFT JOIN source_counterparty sc_sub
				ON sc_sub.source_counterparty_id = fs.counterparty_id
			LEFT JOIN static_data_value sdv_report_type
				ON sdv_report_type.value_id = srns.report_type
			WHERE process_id = @process_id
		END
        ELSE IF @report_type = 39401
        BEGIN
            SELECT source_deal_header_id [TRMDeal ID],
                   deal_id [Ref ID],
                   process_id [Process ID],
                   sub.entity_name [Subsidiary],
                   stra.entity_name [Strategy],
                   book.entity_name [Book],
                   ssbm.logical_name [SubBook],
                   [market_id_participant_counterparty] [ID of the market participant or counterparty],
                   [type_of_code_field_1] [Type of code used in field 1],
                   [trader_id_market_participant] [ID of the trader participant or counterparty],
                   [other_id_market_participant_counterparty] [ID of the other participant or counterparty],
                   [type_of_code_field_4] [Type of code used in field 4],
                   [reporting_entity_id] [Reporting Entity ID],
                   [type_of_code_field_6] [Type of code used in field 6],
                   [beneficiary_id] [Beneficiary ID],
                   [type_of_code_field_8] [Type of code used in field 8],
                   [trading_capacity_market_participant] [Trading capacity of the market participant or counterparty in field 1],
                   [buy_sell_indicator] [Buy sell indicator],
                   [initiator_aggressor] [Initiator Aggressor],
                   [order_id] [Order ID],
                   [order_type] [Order Type],
                   [order_condition] [Order Condition],
                   [order_status] [Order Status],
                   [minimum_execution_volume] [Min Execution Volume],
                   [price_limit] [Price Limit],
                   [undisclosed_volume] [Undisclosed Volume],
                   [order_duration] [Order Duration],
                   [contract_id] [Contract ID],
                   [contract_name] [Contract Name],
                   [contract_type] [Contract Type],
                   [energy_commodity] [Energy Commodity],
                   [fixing_index_or_reference_price] [Fixing index or reference price],
                   [settlement_method] [Settlement method],
                   [organised_market_place_id_otc] [Organised market place ID / OTC],
                   [contract_trading_hours] [Contract trading hours],
                   [last_trading_date_and_time] [Last trading date and time],
                   [transaction_timestamp] [Transaction timestamp],
                   [unique_transaction_id] [Unique transaction ID],
                   [linked_transaction_id] [Linked transaction ID],
                   [linked_order_id] [Linked order ID],
                   [voice_brokered] [Voice-brokered],
                   [price] [Price],
                   [index_value] [Index value],
                   [price_currency] [Price currency],
                   [notional_amount] [Notional amount],
                   [notional_currency] [Notional currency],
                   [quantity_volume] [Quantity / Volume],
                   [total_notional_contract_quantity] [Total notional contract quantity],
                   [quantity_unit_field_40_and_41] [Quantity unit for field 40 and 41],
                   [termination_date] [Termination date],
                   [option_style] [Option style],
                   [option_type] [Option type],
                   [option_exercise_date] [Option exercise date],
                   [option_strike_price] [Option strike price],
                   [delivery_point_or_zone] [Delivery point or zone],
                   dbo.FNADateFormat(delivery_start_date) [Delivery start date],
                   dbo.FNADateFormat(delivery_end_date) [Delivery end date],
                   [duration] [Duration],
                   [load_type] [Load Type],
                   [days_of_the_week] [Days of the week],
                   [load_delivery_intervals] [Load delivery Intervals],
                   [delivery_capacity] [Delivery capacity],
                   [quantity_unit_used_in_field_55] [Quantity unit used in field 55],
                   [price_time_interval_quantity] [Price/time interval quantity],
                   [action_type] [Action type],
                   error_validation_message [Error Validation Message]
			FROM source_remit_standard srns
			LEFT JOIN source_system_book_map ssbm ON srns.sub_book_id = ssbm.book_deal_type_map_id
			LEFT JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
				AND book.hierarchy_level = 0
			LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id
				AND stra.hierarchy_level = 1
			LEFT JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
				AND sub.hierarchy_level = 2
            WHERE process_id = @process_id
        END
		IF @report_type = 39402	--Transport
        BEGIN
			SELECT [TRMDealID] = source_deal_header_id,
                   [RefID] = deal_id,
                   [ProcessID] = process_id,
                   [Subsidiary] = sub.entity_name,
                   [Strategy] = stra.entity_name,
                   [Book] = book.entity_name,
                   [Sub Book] = ssbm.logical_name,
                   [Sender Identification] = sender_identification,
				   [Organised Market Place ID] = organised_market_place_id,
				   [Process Identification] = process_identification,
				   [Type of Gas] = type_of_gas,
				   [Transportation Transaction Identification] = transportation_transaction_identification,
				   [Creation Date Time] = creation_date_and_time,
				   [Action Open Date Time] = auction_open_date_and_time,
				   [Auction End Date Time] = auction_end_date_and_time,
				   [Transportation Transaction Type] = transportation_transaction_type,
				   [Start Date Time] = CONVERT(VARCHAR(10), start_date_and_time, 120) + 'T06:00Z',
				   [End Date Time] = CONVERT(VARCHAR(10), DATEADD(Day, 1, [end_date_and_time]), 120) + 'T05:59Z',
				   [Offered Capacity] = offered_capacity,
				   [Capacity Category] = capacity_category,
				   [Quantity] = quantity,
				   [Measure Unit] = measure_unit,
				   [Currency] = currency,
				   [Total Price] = total_price,
				   [Fixed or Floating Reserve Price] = fixed_or_floating_reserve_price,
				   [Reserve Price] = reserve_price,
				   [Premium Price] = premium_price,
				   [Network Point Identification] = network_point_identification,
				   [Bundling] = bundling,
				   [Direction] = direction,
				   [TSO1 Identification] = tso1_identification,
				   [TSO2 Identification] = tso2_identification,
				   [Market Participant Identification] = market_participant_identification,
				   [Balancing Group or Portfolio Code] = balancing_group_or_portfolio_code,
				   [Procedure Applicable] = procedure_applicable,
				   [Maximum Bid Amount] = maximum_bid_amount,
				   [Minimum Bid Amount] = minimum_bid_amount,
				   [Maximum Quantiy] = maximum_quantiy,
				   [Minimum Quantiy] = minimum_quantiy,
				   [Price Paid Tso] = price_paid_to_tso,
				   [Price Transferee Pays Transferor] = price_transferee_pays_transferor,
				   [Transferor Identification] = transferor_identification,
				   [Transferee Identification] = transferee_identification,
				   [Bid ID] = bid_id,
				   [Auction Round Number] = auction_round_number,
				   [Bid Price] = bid_price,
				   [Bid Quantity] = bid_quantity,
				   [Action type] = action_type,
				   [ErrorValidationMessage] = error_validation_message
            FROM source_remit_transport srt
			LEFT JOIN source_system_book_map ssbm ON srt.sub_book_id = ssbm.book_deal_type_map_id
			LEFT JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
				AND book.hierarchy_level = 0
			LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id
				AND stra.hierarchy_level = 1
			LEFT JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
				AND sub.hierarchy_level = 2
            WHERE process_id = @process_id
        END    
    END
    ELSE
    BEGIN -- xml export
        DECLARE @xml_inner XML, @xml_inner2 XML, @xml_innermost XML, @xml_outer XML, @addxml VARCHAR(1000), @xml_inner3 XML, @contract_list XML,
                @order_list XML, @trade_list XML, @col_source_deal_header_id AS INT, @col_document_id AS VARCHAR(500), @col_document_usage AS VARCHAR(500),
				@col_sender_id AS VARCHAR(500), @col_receiver_id AS VARCHAR(500), @col_receiver_role AS VARCHAR(500), @col_document_version AS VARCHAR(500),
				@col_market AS VARCHAR(500), @col_commodity AS VARCHAR(500), @col_transaction_type AS VARCHAR(500), @col_delivery_point_area AS VARCHAR(500),
				@col_buyer_party AS VARCHAR(500), @col_seller_party AS VARCHAR(500), @col_load_type AS VARCHAR(500), @col_agreement AS VARCHAR(500), 
				@col_currency AS VARCHAR(500), @col_total_volume AS VARCHAR(500), @col_total_volume_unit AS VARCHAR(500), @col_trade_date AS VARCHAR(500), 
				@col_capacity_unit AS VARCHAR(500), @col_price_unit_currency AS VARCHAR(500), @col_price_unit_capacity_unit AS VARCHAR(500),
				@col_delivery_start AS VARCHAR(500), @col_delivery_end AS VARCHAR(500), @col_price AS VARCHAR(500), @col_total_contract_value AS VARCHAR(500),
				@col_contract_capacity VARCHAR(100), @col_buyer_hubcode VARCHAR(100), @col_seller_hubcode VARCHAR(100), @col_trader_name VARCHAR(100),
				@col_reference_document_id AS VARCHAR(500), @col_reference_document_version AS VARCHAR(500), @col_broker_fee VARCHAR(100),
				@file_path VARCHAR(1000), @baseload_block_define_id INT, @xml_string VARCHAR(MAX), @result VARCHAR(MAX), @file_name VARCHAR(255), @xml_inner4 XML,
				@include_broker NVARCHAR(12) = 'n', @file_name_export NVARCHAR(MAX) = '', @ecm_document_type NVARCHAR(20)
				, @mapping_table_id INT, @has_interval CHAR(1), @business_day CHAR(1)
		
		SELECT @file_path = gmv.clm1_value
		FROM generic_mapping_header gmh
		INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
		WHERE gmh.mapping_name = 'Ecm_Config'

		SELECT @mapping_table_id = mapping_table_id
		FROM generic_mapping_header
		WHERE mapping_name = 'ECM Broker'

		SELECT @file_path = ISNULL(@file_path, document_path + '/temp_Note/')
		FROM connection_string

  		SET @addxml = '<?xml version="1.0" encoding="ISO-8859-1"?>'
		IF @report_type IS NULL
		BEGIN
			IF EXISTS(SELECT 1 FROM source_ecm se WHERE process_id = @process_id AND error_validation_message IS NOT NULL)
			BEGIN
				SET @source = NULL
				RETURN
			END

			SELECT @baseload_block_define_id = value_id
			FROM static_data_value
			WHERE [TYPE_ID] = 10018 
				AND code LIKE 'Base Load' -- External Static Data

			IF OBJECT_ID('tempdb..#tempblock') IS NOT NULL
				DROP TABLE #tempblock
			CREATE TABLE #tempblock (
				id INT IDENTITY(1, 1), 
				hr INT, 
				source_deal_header_id INT, 
				term_date DATETIME, 
				hr_mult INT
			)

			IF OBJECT_ID('tempdb..#tempblock1') IS NOT NULL
				DROP TABLE #tempblock1
			CREATE TABLE #tempblock1 (
							id INT IDENTITY(1, 1), 
							hr INT, 
							source_deal_header_id INT, 
							term_date DATETIME, 
							hr_mult INT,
							granularity INT,
							volume FLOAT,
							price FLOAT 
						)

			IF OBJECT_ID('tempdb..#tempblock2') IS NOT NULL
				DROP TABLE #tempblock2
			CREATE TABLE #tempblock2 (
					max_hr INT, 
					source_deal_header_id INT, 
					term_date DATETIME, 
					hr_mult INT,
					hr1 INT
				)


			
			DECLARE @default_dst_group VARCHAR(50)

			SELECT  @default_dst_group = tz.dst_group_value_id
			FROM
				(
					SELECT var_value default_timezone_id 
					FROM dbo.adiha_default_codes_values (NOLOCK) 
					WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
				) df  
			INNER JOIN dbo.time_zones tz (NOLOCK) ON tz.timezone_id = df.default_timezone_id

			
			DECLARE c1 CURSOR FOR 
			    SELECT source_deal_Header_id, document_id, document_usage, sender_id, receiver_id, receiver_role, 
					   document_version, market, commodity, transaction_type, delivery_point_area, buyer_party, 
					   seller_party, load_type, agreement, currency, CAST(total_volume AS NUMERIC(38,2)), total_volume_unit, 
					   trade_date, capacity_unit, price_unit_currency, price_unit_capacity_unit, delivery_start, delivery_end,
					   price, CAST(total_contract_value AS NUMERIC(38,2)), CAST(contract_capacity AS NUMERIC(38,2)),
					   buyer_hubcode, seller_hubcode, trader_name, ecm_document_type, CAST(broker_fee AS NUMERIC(38,2))
			    FROM source_ecm se																												  
			    WHERE process_id = @process_id
					AND ecm_document_type IN ('CNF', 'BCN')																			  
				    AND error_validation_message IS NULL 	
			OPEN c1 
			FETCH NEXT FROM c1 INTO @col_source_deal_header_id, @col_document_id, @col_document_usage, @col_sender_id, @col_receiver_id, @col_receiver_role, @col_document_version, @col_market, @col_commodity, @col_transaction_type, @col_delivery_point_area,
									@col_buyer_party, @col_seller_party, @col_load_type, @col_agreement, @col_currency, @col_total_volume, @col_total_volume_unit, @col_trade_date, @col_capacity_unit, @col_price_unit_currency, @col_price_unit_capacity_unit,
									@col_delivery_start, @col_delivery_end, @col_price, @col_total_contract_value, @col_contract_capacity, @col_buyer_hubcode, @col_seller_hubcode, @col_trader_name, @ecm_document_type
									,@col_broker_fee
		    WHILE @@FETCH_STATUS = 0
		    BEGIN
				TRUNCATE TABLE #tempblock
				TRUNCATE TABLE #tempblock1
				TRUNCATE TABLE #tempblock2
				
				SELECT @include_broker = 'y'
				FROM source_deal_header sdh
				INNER JOIN maintain_udf_static_data_detail_values musddv
						ON musddv.primary_field_object_id = sdh.broker_id
					INNER JOIN application_ui_template_fields autf
						ON autf.application_field_id = musddv.application_field_id
					INNER JOIN user_defined_fields_template udft
						ON udft.udf_template_id = autf.udf_template_id
				WHERE sdh.source_deal_header_id = @col_source_deal_header_id
				AND sdh.broker_id IS NOT NULL
				AND udft.Field_label = 'ECM Reportable'
				AND ISNULL(musddv.static_data_udf_values, 'n') = 'y'

				IF @include_broker = 'y'
				BEGIN
					IF EXISTS(SELECT 1 
							  FROM source_deal_header sdh
							  LEFT JOIN setup_submission_rule ssr
								ON ssr.counterparty_id = sdh.counterparty_id
								AND ssr.submission_type_id = 44705
							  WHERE ssr.rule_id IS NULL
					)
					BEGIN
						SELECT @col_trader_name = NULL
						SELECT @xml_inner4 = (SELECT 'Broker' AS [Agent/AgentType]
							,sc.counterparty_name AS [Agent/AgentName]
							,gmv.clm2_value AS [Agent/Broker/BrokerID]
							,@col_broker_fee [Agent/Broker/TotalFee]
						   -- ,@col_currency AS [Agent/Broker/FeeCurrency]
						FROM source_deal_header sdh
						INNER JOIN source_counterparty sc
							ON sc.source_counterparty_id = 	sdh.broker_id
						LEFT JOIN generic_mapping_values gmv
							ON gmv.mapping_table_id = @mapping_table_id
							AND gmv.clm1_value = CAST(sdh.broker_id AS VARCHAR(20))
						WHERE sdh.source_deal_header_id = @col_source_deal_header_id
						FOR XML PATH(''), ROOT('Agents'))
					END
					ELSE
					BEGIN
						SELECT @xml_inner4 = (SELECT 'Broker' AS [Agent/AgentType]
											  ,sc.counterparty_name AS [Agent/AgentName]
											 ,gmv.clm2_value AS [Agent/Broker/BrokerID]
						FROM source_deal_header sdh
						INNER JOIN source_counterparty sc
							ON sc.source_counterparty_id = sdh.broker_id
						LEFT JOIN generic_mapping_values gmv
							ON gmv.mapping_table_id = @mapping_table_id
							AND gmv.clm1_value = CAST(sdh.broker_id AS VARCHAR(20))
						WHERE sdh.source_deal_header_id = @col_source_deal_header_id
						FOR XML PATH(''), ROOT('Agents'))
					END				
				END
				ELSE
				BEGIN
					SET @xml_inner4 = NULL
				END

				SELECT @has_interval = ISNULL(tbl_ecm_time_interval.has_interval,'n')
					  ,@business_day = ISNULL(tbl_ecm_time_interval.business_day,'n')
				FROM source_deal_header sdh
				OUTER APPLY( SELECT ISNULL(gmv.clm4_value, 'n') [business_day], ISNULL(gmv.clm5_value, 'n') [has_interval]
				 FROM generic_mapping_header gmh
				 INNER JOIN generic_mapping_values gmv
					ON gmv.mapping_table_id = gmh.mapping_table_id
				 WHERE gmh.mapping_name = 'ECM Time Interval'
				 AND gmv.clm1_value = CAST(sdh.block_define_id AS VARCHAR(20))
				) tbl_ecm_time_interval
				WHERE sdh.source_deal_header_id = @col_source_deal_header_id

				IF @col_commodity = 'Gas'
				BEGIN
					IF EXISTS(SELECT 1 FROM source_deal_header sdh
						  INNER JOIN source_deal_detail sdd
							ON sdd.source_deal_header_id = sdh.source_deal_header_id
						  INNER JOIN source_deal_detail_hour sddh
							ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
						  WHERE sdh.source_deal_header_id = @col_source_deal_header_id
						  AND sdh.internal_desk_id = 17302
					)
					BEGIN
						INSERT INTO #tempblock1(hr, source_deal_header_id, term_date, hr_mult,granularity,volume,price)
						SELECT CAST(SUBSTRING([hour], 3, 5) AS INT) hr,
								unpvt.source_deal_header_id,
								DATEADD(MINUTE, CAST(LTRIM(DATEDIFF(MINUTE, 0, CASE WHEN CHARINDEX(':', sddh.hr) > 0 THEN RIGHT('00' + CAST((LEFT(sddh.hr, 2) - 1) AS VARCHAR(10)), 2) + RIGHT(sddh.hr, 3) ELSE RIGHT(('00' + (sddh.hr -1)), 2) + ':00' END)) AS INT), unpvt.term_date) term_date,
								hr_mult, sddh.granularity, sddh.volume, sddh.price
						FROM (
							SELECT se.process_id, se.ecm_document_type, se.error_validation_message, se.source_deal_header_id, hb.term_date,
									hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13, hr14, hr15, hr16, hr17, hr18, hr19,
									hr20, hr21, hr22, hr23, hr24
							FROM source_ecm se
							INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id =  se.source_deal_header_id
	
							CROSS APPLY	(
								SELECT h.hr7 AS hr1, h.hr8 AS hr2, h.hr9 AS hr3, h.hr10 AS hr4, h.hr11 AS hr5, h.hr12 AS hr6, h.hr13 AS hr7,
										h.hr14 AS hr8, h.hr15 AS hr9, h.hr16 AS hr10, h.hr17 AS hr11, h.hr18 AS hr12, h.hr19 AS hr13, h.hr20 AS hr14,
										h.hr21 AS hr15, h.hr22 AS hr16, h.hr23 AS hr17, h.hr24 AS hr18, h1.hr1 AS hr19, h1.hr2 AS hr20, h1.hr3 AS hr21,
										h1.hr4 AS hr22, h1.hr5 AS hr23, h1.hr6 AS hr24, h.term_Date
								FROM hour_block_term h WITH (NOLOCK) 
								LEFT JOIN hour_block_term h1 (NOLOCK) 
									ON h1.block_define_id = h.block_define_id
									AND h1.block_type = 12000
									AND h1.term_date = h.term_date + 1
									AND h1.dst_group_value_id = h.dst_group_value_id
								WHERE h.block_define_id = sdh.block_define_id
									AND h.block_type = 12000
									AND h.term_date BETWEEN CAST(se.delivery_start AS DATE) AND CAST(se.delivery_end AS DATE) 
									AND h.dst_group_value_id = @default_dst_group
							) hb 	
							WHERE se.source_deal_header_id = @col_source_deal_header_id
							AND se.process_id = @process_id
						) p UNPIVOT (hr_mult FOR [hour] IN (
								hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13,
								hr14, hr15, hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24
							)
						) AS unpvt
						INNER JOIN source_deal_detail sdd 
							ON sdd.source_deal_header_id = unpvt.source_deal_header_id
							AND unpvt.term_date BETWEEN CAST(sdd.term_start AS DATE) AND CAST(sdd.term_end AS DATE) 
						LEFT JOIN source_deal_detail_hour sddh
								ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
								AND sddh.term_date = unpvt.term_date
								AND CAST(SUBSTRING([hour], 3, 5) AS INT) = CAST(CASE WHEN CHARINDEX(':', sddh.hr) > 0 THEN CAST((LEFT(sddh.hr, 2)) AS VARCHAR(10)) ELSE '0' END AS INT)
						WHERE unpvt.source_deal_header_id = @col_source_deal_header_id
							AND unpvt.process_id = @process_id
							AND unpvt.ecm_document_type = @ecm_document_type
							AND unpvt.error_validation_message IS NULL

						-- Aggregate functions used for Volume and Price, in order to handle duplicate term  dates where DST influenced
						SELECT @xml_inner3 = (
								SELECT CONVERT(VARCHAR(19), DATEADD(hour, 6, term_date), 126) [TimeIntervalQuantity/DeliveryStartDateAndTime],
								CASE WHEN  granularity = 982 THEN CONVERT(VARCHAR(19), DATEADD(hour, 6, DATEADD(hour, 1, term_date)), 126) 
									WHEN granularity = 987  THEN CONVERT(VARCHAR(19), DATEADD(hour, 6, DATEADD(minute, 15, term_date)), 126) 
									ELSE CONVERT(VARCHAR(19), term_date, 126) END
								 AS [TimeIntervalQuantity/DeliveryEndDateAndTime],
								CAST(ISNULL(SUM(volume),@col_contract_capacity) AS NUMERIC(38,2)) AS [TimeIntervalQuantity/ContractCapacity],
								CAST(ISNULL(AVG(price),@col_price) AS NUMERIC(38,2)) AS [TimeIntervalQuantity/Price]
						FROM #tempblock1
						WHERE hr_mult = 1
						GROUP BY term_date, granularity
						ORDER BY term_date
						FOR XML PATH(''), ROOT('TimeIntervalQuantities')
						)
					END
					ELSE IF EXISTS(SELECT 1 FROM source_deal_header sdh
						  INNER JOIN source_deal_detail sdd
							ON sdd.source_deal_header_id = sdh.source_deal_header_id
						  WHERE sdh.source_deal_header_id = @col_source_deal_header_id
						  AND sdh.internal_desk_id = 17301
						  AND sdd.profile_id IS NOT NULL
					)
					BEGIN
						INSERT INTO #tempblock1(hr, source_deal_header_id, term_date, hr_mult,granularity,volume, price)
						SELECT unpvt.[Hour], unpvt.source_deal_header_id, DATEADD(MINUTE,unpvt.period,DATEADD(HOUR,CAST(unpvt.[Hour] AS INT) - 1,term_date)), 1, unpvt.profile_granularity, unpvt.Volume, NULL
						FROM
						(SELECT 
						se.source_deal_header_id, sdh.profile_granularity, ddh.[profile_id], term_date, period, hr1 [1], hr2 [2], hr3 [3], hr4 [4], hr5 [5], hr6 [6], hr7 [7], hr8 [8], hr9 [9], hr10 [10], hr11 [11], hr12 [12], hr13 [13], hr14 [14], hr15 [15], hr16 [16], hr17 [17], hr18 [18], hr19 [19], hr20 [20], hr21 [21], hr22 [22], hr23 [23], hr24 [24]
						--, hr25 [25], hr25 [dd] 
						FROM source_ecm se
						INNER JOIN source_deal_header sdh 
							ON sdh.source_deal_header_id =  se.source_deal_header_id
						INNER JOIN source_deal_detail sdd 
							ON sdd.source_deal_header_id = sdh.source_deal_header_id 
						INNER JOIN deal_detail_hour ddh
							ON ddh.profile_id = sdd.profile_id
							AND ddh.term_date BETWEEN sdd.term_start AND sdd.term_end
						WHERE se.source_deal_header_id = @col_source_deal_header_id
							AND se.process_id = @process_id
							AND se.ecm_document_type = @ecm_document_type
							AND se.error_validation_message IS NULL
						) p
						UNPIVOT
						(Volume for [Hour] IN
							([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24]
							--, [25]
							)
						) AS unpvt

						-- Aggregate functions used for Volume and Price, in order to handle duplicate term  dates where DST influenced
						SELECT @xml_inner3 = (
								SELECT CONVERT(VARCHAR(19), DATEADD(hour, 6, term_date), 126) [TimeIntervalQuantity/DeliveryStartDateAndTime],
								CASE WHEN  granularity = 982 THEN CONVERT(VARCHAR(19), DATEADD(hour, 6, DATEADD(hour, 1, term_date)), 126) 
									WHEN granularity = 987  THEN CONVERT(VARCHAR(19), DATEADD(hour, 6, DATEADD(minute, 15, term_date)), 126) 
									ELSE CONVERT(VARCHAR(19), term_date, 126) END
								 AS [TimeIntervalQuantity/DeliveryEndDateAndTime],
								CAST(ISNULL(SUM(volume),@col_contract_capacity) AS NUMERIC(38,2)) AS [TimeIntervalQuantity/ContractCapacity],
								CAST(ISNULL(AVG(price),@col_price) AS NUMERIC(38,2)) AS [TimeIntervalQuantity/Price]
						FROM #tempblock1
						WHERE hr_mult = 1
						GROUP BY term_date, granularity
						ORDER BY term_date
						FOR XML PATH(''), ROOT('TimeIntervalQuantities'))

					END
					ELSE IF NOT EXISTS (
						SELECT 1 
						FROM source_deal_header 
						WHERE source_deal_header_id = @col_source_deal_header_id
							AND ISNULL(block_define_id, @baseload_block_define_id) = @baseload_block_define_id
					) AND @has_interval = 'y'
					BEGIN
						INSERT INTO #tempblock(hr, source_deal_header_id, term_date, hr_mult)
						SELECT CAST(SUBSTRING([hour], 3, 5) AS INT) hr,
								source_deal_header_id,
								term_date,
								hr_mult
						FROM (
							SELECT se.process_id, se.ecm_document_type, se.error_validation_message, se.source_deal_header_id,
									hb.term_date, hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13, hr14,
									hr15, hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24
							FROM source_ecm se
							INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = se.source_deal_header_id
							CROSS APPLY (
								SELECT h.hr7 AS hr1, h.hr8 AS hr2, h.hr9 AS hr3, h.hr10 AS hr4, h.hr11 AS hr5, h.hr12 AS hr6, h.hr13 AS hr7,
										h.hr14 AS hr8, h.hr15 AS hr9, h.hr16 AS hr10, h.hr17 AS hr11, h.hr18 AS hr12, h.hr19 AS hr13, h.hr20 AS hr14,
										h.hr21 AS hr15, h.hr22 AS hr16, h.hr23 AS hr17, h.hr24 AS hr18, h1.hr1 AS hr19, h1.hr2 AS hr20, h1.hr3 AS hr21,
										h1.hr4 AS hr22, h1.hr5 AS hr23, h1.hr6 AS hr24, h.term_Date
								FROM hour_block_term h WITH (NOLOCK) 
								LEFT JOIN hour_block_term h1 (NOLOCK) ON h1.block_define_id = h.block_define_id
									AND h1.block_type = 12000
									AND h1.term_date = h.term_date + 1
									AND h1.dst_group_value_id = h.dst_group_value_id
								WHERE h.block_define_id = sdh.block_define_id
									AND h.block_type = 12000
									AND h.term_date BETWEEN CASE WHEN @business_day = 'y' AND DATEPART(dw, CAST(sdh.entire_term_start AS DATE)) IN (1,7) THEN dbo.FNAGetBusinessDay('n',CAST(sdh.entire_term_start AS DATE), NULL) ELSE CAST(sdh.entire_term_start AS DATE) END
									AND CASE WHEN @business_day = 'y' AND DATEPART(dw, CAST(sdh.entire_term_end AS DATE) ) IN (1,7) THEN dbo.FNAGetBusinessDay('p',CAST(sdh.entire_term_end AS DATE), NULL) ELSE CAST(sdh.entire_term_end AS DATE)  END
									AND h.dst_group_value_id = @default_dst_group
							) hb
							WHERE se.process_id = @process_id
							AND se.source_deal_header_id = @col_source_deal_header_id
						)p UNPIVOT (hr_mult FOR [hour] IN (
								hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13, 
								hr14, hr15, hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24
							)
						) AS unpvt  
						WHERE unpvt.source_deal_header_id = @col_source_deal_header_id
							AND unpvt.process_id = @process_id
							AND unpvt.ecm_document_type = @ecm_document_type
							AND unpvt.error_validation_message IS NULL

						INSERT INTO #tempblock2(max_hr,source_deal_header_id,term_date,hr_mult,hr1)
						SELECT tb.hr, tb.source_deal_header_id, tb.term_date, tb.hr_mult, LAG (tb.hr) OVER(PARTITION BY tb.source_deal_header_id,tb.term_date ORDER BY tb.hr) hr1
						FROM #tempblock tb
						LEFT JOIN #tempblock tb1
							ON tb1.hr = (tb.hr + 1)
							AND tb1.term_date = tb.term_date
							AND tb1.source_deal_header_id = tb.source_deal_header_id
						WHERE CASE WHEN tb.hr_mult = tb1.hr_mult THEN 1 ELSE 2 END = 2
						AND tb.hr_mult = 1


 						SELECT @xml_inner3 = (
							SELECT CONVERT(VARCHAR(19), DATEADD(hh, min_hr -1 , term_date), 126) AS [TimeIntervalQuantity/DeliveryStartDateAndTime],
									CONVERT(VARCHAR(19), DATEADD(hh, max_hr, term_date), 126) AS [TimeIntervalQuantity/DeliveryEndDateAndTime],
									@col_contract_capacity AS [TimeIntervalQuantity/ContractCapacity],
									@col_price AS [TimeIntervalQuantity/Price]
							FROM #tempblock2 t1
							OUTER APPLY(
								SELECT MIN(hr) min_hr
								FROM #tempblock
								WHERE hr_mult = 1
								AND source_deal_header_id = t1.source_deal_header_id
								AND term_date = t1.term_date
								AND hr > ISNULL(t1.hr1,0) AND hr < t1.max_hr 
							) tbl
							ORDER BY term_date
							FOR XML PATH(''), ROOT('TimeIntervalQuantities')
						)
					END
					ELSE
					BEGIN
 						SELECT @xml_inner3 = (
							SELECT CONVERT(VARCHAR(19), CAST(@col_delivery_start AS DATETIME), 126) AS [TimeIntervalQuantity/DeliveryStartDateAndTime],
									CONVERT(VARCHAR(19), CAST(@col_delivery_end AS DATETIME), 126) AS [TimeIntervalQuantity/DeliveryEndDateAndTime],
									@col_contract_capacity AS [TimeIntervalQuantity/ContractCapacity],
									@col_price AS [TimeIntervalQuantity/Price]
							FOR XML PATH(''), ROOT('TimeIntervalQuantities')
						)
					END

					;WITH XMLNAMESPACES ('dummy' AS xsi) -- declaration of xml namespace prefix xsi is required for xsi:noNamespaceSchemaLocation, later to be removed.
					SELECT @xml_inner = (
						SELECT 'http://www.efet.org/ecm/schemas/V3r2/EFET-CNF-V3R2.xsd' AS '@xsi:noNamespaceSchemaLocation',
								'3' AS '@SchemaRelease',
								'3' AS '@SchemaVersion',
								@col_document_id AS [DocumentID],
								@col_document_usage AS [DocumentUsage],
								@col_sender_id AS [SenderID],
								@col_receiver_id AS [ReceiverID],
								@col_receiver_role AS [ReceiverRole],
								@col_document_version AS [DocumentVersion],
								@col_market AS [Market],
								@col_commodity as [Commodity],
								@col_transaction_type AS [TransactionType],
								@col_delivery_point_area AS [DeliveryPointArea],
								@col_buyer_party AS [BuyerParty],
								@col_seller_party AS [SellerParty],
								@col_load_type AS [LoadType],
								@col_agreement AS [Agreement],
								--CASE WHEN @col_delivery_point_area = '21Z0000000000090' THEN 'true' ELSE 'false' END AS 'Currency/@UseFractionUnit',
								@col_currency AS [Currency],
								@col_total_volume AS [TotalVolume],
								@col_total_volume_unit AS [TotalVolumeUnit],
								CONVERT(VARCHAR(10), CAST(@col_trade_date AS DATETIME), 120) AS [TradeDate],
								@col_capacity_unit AS [CapacityUnit],
								--CASE WHEN @col_delivery_point_area = '21Z0000000000090' THEN 'true' ELSE 'false' END AS 'PriceUnit/Currency/@UseFractionUnit',
								@col_price_unit_currency AS [PriceUnit/Currency],
								@col_price_unit_capacity_unit AS [PriceUnit/CapacityUnit],				    
								@xml_inner3,  --TimeIntervalQuantities
								@col_total_contract_value AS [TotalContractValue],
								@col_buyer_hubcode AS [HubCodificationInformation/BuyerHubCode],
								@col_seller_hubcode AS [HubCodificationInformation/SellerHubCode],
								@xml_inner4,								
								@col_trader_name AS [TraderName] 
    					FOR XML PATH('TradeConfirmation'), TYPE)
				END
				ELSE 
				BEGIN  -- Power does not contain HubCodificationInformation
					IF EXISTS(SELECT 1 FROM source_deal_header sdh
						  INNER JOIN source_deal_detail sdd
							ON sdd.source_deal_header_id = sdh.source_deal_header_id
						  INNER JOIN source_deal_detail_hour sddh
							ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
						  WHERE sdh.source_deal_header_id = @col_source_deal_header_id
						  AND sdh.internal_desk_id = 17302
					)
					BEGIN
						INSERT INTO #tempblock1(hr, source_deal_header_id, term_date, hr_mult,granularity,volume,price)
						SELECT CAST(SUBSTRING([hour], 3, 5) AS INT) hr,
								unpvt.source_deal_header_id,
								DATEADD(MINUTE, CAST(LTRIM(DATEDIFF(MINUTE, 0, CASE WHEN CHARINDEX(':', sddh.hr) > 0 THEN RIGHT('00' + CAST((LEFT(sddh.hr, 2) - 1) AS VARCHAR(10)), 2) + RIGHT(sddh.hr, 3) ELSE RIGHT(('00' + (sddh.hr -1)), 2) + ':00' END)) AS INT), unpvt.term_date) term_date,
								hr_mult, sddh.granularity, sddh.volume, sddh.price
						FROM (
							SELECT se.process_id, se.ecm_document_type, se.error_validation_message, se.source_deal_header_id, hb.term_date,
									hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13, hr14, hr15, hr16, hr17, hr18, hr19,
									hr20, hr21, hr22, hr23, hr24
							FROM source_ecm se
							INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id =  se.source_deal_header_id
	
							CROSS APPLY	(
								SELECT h.*
								FROM hour_block_term h WITH (NOLOCK)
								WHERE block_define_id = sdh.block_define_id
									AND h.block_type = 12000
									AND term_date BETWEEN CAST(se.delivery_start AS DATE) AND CAST(se.delivery_end AS DATE) 
									AND dst_group_value_id = @default_dst_group
							) hb 	
							WHERE se.source_deal_header_id = @col_source_deal_header_id
							AND se.process_id = @process_id
						) p UNPIVOT (hr_mult FOR [hour] IN (
								hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13,
								hr14, hr15, hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24
							)
						) AS unpvt
						INNER JOIN source_deal_detail sdd 
							ON sdd.source_deal_header_id = unpvt.source_deal_header_id
							AND unpvt.term_date BETWEEN CAST(sdd.term_start AS DATE) AND CAST(sdd.term_end AS DATE) 
						LEFT JOIN source_deal_detail_hour sddh
								ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
								AND sddh.term_date = unpvt.term_date
								AND CAST(SUBSTRING([hour], 3, 5) AS INT) = CAST(CASE WHEN CHARINDEX(':', sddh.hr) > 0 THEN CAST((LEFT(sddh.hr, 2)) AS VARCHAR(10)) ELSE '0' END AS INT)
						WHERE unpvt.source_deal_header_id = @col_source_deal_header_id
							AND unpvt.process_id = @process_id
							AND unpvt.ecm_document_type = @ecm_document_type
							AND unpvt.error_validation_message IS NULL

						-- Aggregate functions used for Volume and Price, in order to handle duplicate term  dates where DST influenced
						SELECT @xml_inner3 = (
								SELECT CONVERT(VARCHAR(19), term_date, 126) [TimeIntervalQuantity/DeliveryStartDateAndTime],
								CASE WHEN  granularity = 982 THEN CONVERT(VARCHAR(19), DATEADD(hour, 1, term_date), 126) 
									WHEN granularity = 987  THEN CONVERT(VARCHAR(19), DATEADD(minute, 15, term_date), 126) 
									ELSE CONVERT(VARCHAR(19), term_date, 126) END
								 AS [TimeIntervalQuantity/DeliveryEndDateAndTime],
								CAST(ISNULL(SUM(volume),@col_contract_capacity) AS NUMERIC(38,2)) AS [TimeIntervalQuantity/ContractCapacity],
								CAST(ISNULL(AVG(price),@col_price) AS NUMERIC(38,2)) AS [TimeIntervalQuantity/Price]
						FROM #tempblock1
						WHERE hr_mult = 1
						GROUP BY term_date, granularity
						ORDER BY term_date
						FOR XML PATH(''), ROOT('TimeIntervalQuantities')
						)
					END
					ELSE IF EXISTS(SELECT 1 FROM source_deal_header sdh
						  INNER JOIN source_deal_detail sdd
							ON sdd.source_deal_header_id = sdh.source_deal_header_id
						  WHERE sdh.source_deal_header_id = @col_source_deal_header_id
						  AND sdh.internal_desk_id = 17301
						  AND sdd.profile_id IS NOT NULL
					)
					BEGIN
						INSERT INTO #tempblock1(hr, source_deal_header_id, term_date, hr_mult,granularity,volume, price)
						SELECT unpvt.[Hour], unpvt.source_deal_header_id, DATEADD(MINUTE,unpvt.period,DATEADD(HOUR,CAST(unpvt.[Hour] AS INT) - 1,term_date)), 1, unpvt.profile_granularity, unpvt.Volume, NULL
						FROM
						(SELECT 
						se.source_deal_header_id, sdh.profile_granularity, ddh.[profile_id], term_date, period, hr1 [1], hr2 [2], hr3 [3], hr4 [4], hr5 [5], hr6 [6], hr7 [7], hr8 [8], hr9 [9], hr10 [10], hr11 [11], hr12 [12], hr13 [13], hr14 [14], hr15 [15], hr16 [16], hr17 [17], hr18 [18], hr19 [19], hr20 [20], hr21 [21], hr22 [22], hr23 [23], hr24 [24]
						--, hr25 [25], hr25 [dd] 
						FROM source_ecm se
						INNER JOIN source_deal_header sdh 
							ON sdh.source_deal_header_id =  se.source_deal_header_id
						INNER JOIN source_deal_detail sdd 
							ON sdd.source_deal_header_id = sdh.source_deal_header_id 
						INNER JOIN deal_detail_hour ddh
							ON ddh.profile_id = sdd.profile_id
							AND ddh.term_date BETWEEN sdd.term_start AND sdd.term_end
						WHERE se.source_deal_header_id = @col_source_deal_header_id
							AND se.process_id = @process_id
							AND se.ecm_document_type = @ecm_document_type
							AND se.error_validation_message IS NULL
						) p
						UNPIVOT
						(Volume for [Hour] IN
							([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24]
							--, [25]
							)
						) AS unpvt

						-- Aggregate functions used for Volume and Price, in order to handle duplicate term  dates where DST influenced
						SELECT @xml_inner3 = (
								SELECT CONVERT(VARCHAR(19), term_date, 126) [TimeIntervalQuantity/DeliveryStartDateAndTime],
								CASE WHEN  granularity = 982 THEN CONVERT(VARCHAR(19), DATEADD(hour, 1, term_date), 126) 
									WHEN granularity = 987  THEN CONVERT(VARCHAR(19), DATEADD(minute, 15, term_date), 126) 
									ELSE CONVERT(VARCHAR(19), term_date, 126) END
								 AS [TimeIntervalQuantity/DeliveryEndDateAndTime],
								CAST(ISNULL(SUM(volume),@col_contract_capacity) AS NUMERIC(38,2)) AS [TimeIntervalQuantity/ContractCapacity],
								CAST(ISNULL(AVG(price),@col_price) AS NUMERIC(38,2)) AS [TimeIntervalQuantity/Price]
						FROM #tempblock1
						WHERE hr_mult = 1
						GROUP BY term_date, granularity
						ORDER BY term_date
						FOR XML PATH(''), ROOT('TimeIntervalQuantities'))

					END
					ELSE IF NOT EXISTS (
						SELECT 1 
						FROM source_deal_header 
						WHERE source_deal_header_id = @col_source_deal_header_id 
							AND ISNULL(block_define_id, @baseload_block_define_id) = @baseload_block_define_id
					) AND @has_interval = 'y'
					BEGIN
						INSERT INTO #tempblock(hr, source_deal_header_id, term_date, hr_mult)
						SELECT CAST(SUBSTRING([hour], 3, 5) AS INT) hr,
								source_deal_header_id,
								term_date,
								hr_mult
						FROM (
							SELECT se.process_id, se.ecm_document_type, se.error_validation_message, se.source_deal_header_id, hb.term_date,
									hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13, hr14, hr15, hr16, hr17, hr18, hr19,
									hr20, hr21, hr22, hr23, hr24
							FROM source_ecm se
							INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id =  se.source_deal_header_id
							CROSS APPLY	(
								SELECT h.*
								FROM hour_block_term h WITH (NOLOCK)
								WHERE block_define_id = sdh.block_define_id
									AND h.block_type = 12000
									AND term_date BETWEEN CASE WHEN @business_day = 'y' AND DATEPART(dw, CAST(sdh.entire_term_start AS DATE)) IN (1,7) THEN dbo.FNAGetBusinessDay('n',CAST(sdh.entire_term_start AS DATE), NULL) ELSE CAST(sdh.entire_term_start AS DATE) END
									AND CASE WHEN @business_day = 'y' AND DATEPART(dw, CAST(sdh.entire_term_end AS DATE) ) IN (1,7) THEN dbo.FNAGetBusinessDay('p',CAST(sdh.entire_term_end AS DATE), NULL) ELSE CAST(sdh.entire_term_end AS DATE)  END
									AND h.dst_group_value_id = @default_dst_group
							) hb --todo
							WHERE se.process_id = @process_id
							AND se.source_deal_header_id = @col_source_deal_header_id
						) p UNPIVOT (hr_mult FOR [hour] IN (
								hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13,
								hr14, hr15, hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24
							)
						) AS unpvt
						WHERE unpvt.source_deal_header_id = @col_source_deal_header_id
							AND unpvt.process_id = @process_id
							AND unpvt.ecm_document_type = @ecm_document_type
							AND unpvt.error_validation_message IS NULL

 						INSERT INTO #tempblock2(max_hr,source_deal_header_id,term_date,hr_mult,hr1)
						SELECT tb.hr, tb.source_deal_header_id, tb.term_date, tb.hr_mult, LAG (tb.hr) OVER(PARTITION BY tb.source_deal_header_id,tb.term_date ORDER BY tb.hr) hr1
						FROM #tempblock tb
						LEFT JOIN #tempblock tb1
							ON tb1.hr = (tb.hr + 1)
							AND tb1.term_date = tb.term_date
							AND tb1.source_deal_header_id = tb.source_deal_header_id
						WHERE CASE WHEN tb.hr_mult = tb1.hr_mult THEN 1 ELSE 2 END = 2
						AND tb.hr_mult = 1
						
						SELECT @xml_inner3 = (
							SELECT CONVERT(VARCHAR(19), DATEADD(hh, min_hr -1 , term_date), 126) AS [TimeIntervalQuantity/DeliveryStartDateAndTime],
									CONVERT(VARCHAR(19), DATEADD(hh, max_hr, term_date), 126) AS [TimeIntervalQuantity/DeliveryEndDateAndTime],
									@col_contract_capacity AS [TimeIntervalQuantity/ContractCapacity],
									@col_price AS [TimeIntervalQuantity/Price]
							FROM #tempblock2 t1
							OUTER APPLY(
								SELECT MIN(hr) min_hr
								FROM #tempblock
								WHERE hr_mult = 1
								AND source_deal_header_id = t1.source_deal_header_id
								AND term_date = t1.term_date
								AND hr > ISNULL(t1.hr1,0) AND hr < t1.max_hr 
							) tbl
							ORDER BY term_date
							FOR XML PATH(''), ROOT('TimeIntervalQuantities')
						)
					END 
					ELSE
					BEGIN
 						SELECT @xml_inner3 = (
							SELECT CONVERT(VARCHAR(19), CAST(@col_delivery_start AS DATETIME), 126) AS [TimeIntervalQuantity/DeliveryStartDateAndTime],
									CONVERT(VARCHAR(19), CAST(@col_delivery_end AS DATETIME), 126) AS [TimeIntervalQuantity/DeliveryEndDateAndTime],
									@col_contract_capacity AS [TimeIntervalQuantity/ContractCapacity],
									@col_price AS [TimeIntervalQuantity/Price]
							FOR XML PATH(''), ROOT('TimeIntervalQuantities')
						)
					END

					;WITH XMLNAMESPACES ('dummy' as xsi) -- declaration of xml namespace prefix xsi is required for xsi:noNamespaceSchemaLocation, later to be removed.
					SELECT @xml_inner = (
						SELECT 'http://www.efet.org/ecm/schemas/V3r2/EFET-CNF-V3R2.xsd' AS '@xsi:noNamespaceSchemaLocation',
								'3' AS '@SchemaRelease',
								'3' AS '@SchemaVersion',
								@col_document_id AS [DocumentID],
								@col_document_usage AS [DocumentUsage],
								@col_sender_id AS [SenderID],
								@col_receiver_id AS [ReceiverID],
								@col_receiver_role AS [ReceiverRole],
								@col_document_version AS [DocumentVersion],
								@col_market AS [Market],
								@col_commodity as [Commodity],
								@col_transaction_type AS [TransactionType],
								@col_delivery_point_area AS [DeliveryPointArea],
								@col_buyer_party AS [BuyerParty],
								@col_seller_party AS [SellerParty],
								@col_load_type AS [LoadType],
								@col_agreement AS [Agreement],
								--CASE WHEN @col_delivery_point_area = '21Z0000000000090' THEN 'true' ELSE 'false' END AS 'Currency/@UseFractionUnit',
								@col_currency AS [Currency],
								@col_total_volume AS [TotalVolume],
								@col_total_volume_unit AS [TotalVolumeUnit],
								CONVERT(VARCHAR(10), CAST(@col_trade_date AS DATETIME), 120) AS [TradeDate],
								@col_capacity_unit AS [CapacityUnit],
								-- CASE WHEN @col_delivery_point_area = '21Z0000000000090' THEN 'true' ELSE 'false' END AS 'PriceUnit/Currency/@UseFractionUnit',
								@col_price_unit_currency AS [PriceUnit/Currency],
								@col_price_unit_capacity_unit AS [PriceUnit/CapacityUnit],
								@xml_inner3, --TimeIntervalQuantities
								@col_total_contract_value AS [TotalContractValue],
								@xml_inner4,							
								@col_trader_name AS [TraderName] 
    					FOR XML PATH('TradeConfirmation'), TYPE)
				END

				SELECT @xml_inner2 = (
					SELECT @col_document_id AS [ReferencedDocumentID],
							CONVERT(VARCHAR(19), GETDATE(), 126) AS [CreationTimestamp]
					FOR XML PATH('ECMAdditionalData'), TYPE
				) 

				;WITH XMLNAMESPACES ( 'http://www.w3.org/2001/XMLSchema-instance' AS xsi)
				SELECT @xml = (
					SELECT 'http://www.efet.org/schemas/V4R2/EFET-ENV-V4R2.xsd' AS '@xsi:noNamespaceSchemaLocation', 
							@xml_inner,
							@xml_inner2
					FOR XML PATH('ECMEnvelope'), TYPE
				)

				SET @xml = CONVERT(XML, @xml, 1) 
				SET @xml_string = @addxml + REPLACE(CONVERT(VARCHAR(MAX), @xml, 1), 'xmlns:xsi="dummy"', '')
				SET @file_name = @file_path + @col_document_id + '.xml'

				EXEC [spa_write_to_file] @xml_string, 'n',  @file_name, @result OUTPUT
				IF @result = '1'
				BEGIN
					SELECT @file_name_export += IIF(NULLIF(@file_name_export,'') IS NULL, @file_name, ',' + @file_name)
				END
			
				FETCH NEXT FROM c1 INTO 
					@col_source_deal_header_id, @col_document_id, @col_document_usage, @col_sender_id, @col_receiver_id, 
					@col_receiver_role, @col_document_version, @col_market, @col_commodity, @col_transaction_type, @col_delivery_point_area,
					@col_buyer_party, @col_seller_party, @col_load_type, @col_agreement, @col_currency, @col_total_volume, @col_total_volume_unit,
					@col_trade_date, @col_capacity_unit, @col_price_unit_currency, @col_price_unit_capacity_unit, @col_delivery_start, @col_delivery_end,
					@col_price, @col_total_contract_value, @col_contract_capacity, @col_buyer_hubcode, @col_seller_hubcode, @col_trader_name, @ecm_document_type
					,@col_broker_fee
		    END
		    CLOSE c1
		    DEALLOCATE c1 

			--BFI
			DECLARE c2 CURSOR FOR
			    SELECT document_id, document_usage, sender_id, receiver_id, receiver_role, document_version, currency, CAST(broker_fee AS NUMERIC(38,2)), source_deal_header_id
			    FROM source_ecm se
				WHERE process_id = @process_id
					AND ecm_document_type = 'BFI'
					AND error_validation_message IS NULL 	
			OPEN c2
			FETCH NEXT FROM c2 INTO @col_document_id, @col_document_usage, @col_sender_id, @col_receiver_id, @col_receiver_role, @col_document_version, @col_currency, @col_broker_fee, @col_source_deal_header_id
		    WHILE @@FETCH_STATUS = 0
			BEGIN
				
				;WITH XMLNAMESPACES ('http://www.w3.org/2001/XMLSchema-instance' AS xsi)
				SELECT @xml = (
					SELECT 'http://www.efet.org/ecm/schemas/V3r2/EFET-CNF-V3R2.xsd' AS '@xsi:noNamespaceSchemaLocation',
						   '3' AS '@SchemaRelease', '3' AS '@SchemaVersion',
						   @col_document_id AS [DocumentID],
						   @col_document_usage AS [DocumentUsage],
						   @col_sender_id AS [SenderID],
						   @col_receiver_id AS [ReceiverID],
						   @col_receiver_role AS [ReceiverRole],
						   @col_document_version AS [DocumentVersion],
						   'CNF' + SUBSTRING(@col_document_id, 4, LEN(@col_document_id)) [LinkedTo],
						   @col_broker_fee [TotalFee],
						   @col_currency AS [FeeCurrency]
						FOR XML PATH('BrokerFeeInformation'), TYPE
					)
				
					SET @xml = CONVERT(XML, @xml, 1)
					SET @xml_string = @addxml + CONVERT(VARCHAR(MAX), @xml, 1)
					SET @file_name = @file_path + @col_document_id + '.xml'
				
					EXEC [spa_write_to_file] @xml_string, 'n',  @file_name, @result OUTPUT
					IF @result = '1'
					BEGIN
						SELECT @file_name_export += IIF(NULLIF(@file_name_export,'') IS NULL, @file_name, ',' + @file_name)
					END
			    FETCH NEXT FROM c2 INTO @col_document_id, @col_document_usage, @col_sender_id, @col_receiver_id, @col_receiver_role, @col_document_version, @col_currency, @col_broker_fee, @col_source_deal_header_id
			END
		    CLOSE c2
		    DEALLOCATE c2 	   
  
 			--CAN
			DECLARE c3 CURSOR FOR 
			    SELECT document_id, document_usage, sender_id, receiver_id, receiver_role, reference_document_id, reference_document_version
			    FROM source_ecm se
				WHERE process_id = @process_id
					AND ecm_document_type = 'CAN'
					AND error_validation_message IS NULL 	
			OPEN c3
			FETCH NEXT FROM c3 INTO @col_document_id, @col_document_usage, @col_sender_id, @col_receiver_id, @col_receiver_role, @col_reference_document_id, @col_reference_document_version
			WHILE @@FETCH_STATUS = 0
			BEGIN
				;WITH XMLNAMESPACES ('http://www.w3.org/2001/XMLSchema-instance' AS xsi)
				SELECT @xml = (
					SELECT 'http://www.efet.org/ecm/schemas/V3r2/EFET-CNF-V3R2.xsd' AS '@xsi:noNamespaceSchemaLocation',
						   '3' AS '@SchemaRelease',
						   '3' AS '@SchemaVersion',
						   @col_document_id AS [DocumentID],
						   @col_document_usage AS [DocumentUsage],
						   @col_sender_id AS [SenderID],
						   @col_receiver_id AS [ReceiverID],
						   @col_receiver_role AS [ReceiverRole],
						   @col_reference_document_id AS [ReferencedDocumentID],
						   @col_reference_document_version AS [ReferencedDocumentVersion]
					FOR XML PATH('Cancellation'), TYPE
				)
				
				SET @xml = CONVERT(XML, @xml, 1) 
				SET @xml_string = @addxml + CONVERT(VARCHAR(MAX), @xml, 1)
				SET @file_name = @file_path + @col_document_id + '.xml'
				
				EXEC [spa_write_to_file] @xml_string, 'n',  @file_name, @result OUTPUT
				IF @result = '1'
				BEGIN
					SELECT @file_name_export += IIF(NULLIF(@file_name_export,'') IS NULL, @file_name, ',' + @file_name)
				END

			    FETCH NEXT FROM c3 INTO @col_document_id, @col_document_usage, @col_sender_id, @col_receiver_id, @col_receiver_role, @col_reference_document_id, @col_reference_document_version
		    END
		    CLOSE c3
		    DEALLOCATE c3
			
			SELECT @source = @xml

			UPDATE source_ecm
			SET acer_submission_status = 39501
			WHERE process_id = @process_id

            SET @desc = 'Export process completed for ECM Xml for process_id: ' + @process_id + '. File has been saved at ' + @file_path
			EXEC spa_message_board 'i', @user_login_id, NULL, 'Export Xml', @desc, '', '', 's', 'ECM Xml Export'
			IF @file_transfer_endpoint_id IS NOT NULL
			BEGIN
				EXEC spa_upload_file_to_ftp_using_clr @file_transfer_endpoint_id, @remote_directory, @file_name_export, @result OUTPUT
			END			
			RETURN
		END
        ELSE IF @report_type = 39400
        BEGIN
			IF OBJECT_ID('tempdb..#temp_formula_data') IS NOT NULL
				DROP TABLE #temp_formula_data
			CREATE TABLE #temp_formula_data (
				[source_deal_header_id] INT,
				[term_start] DATETIME,
				[term_end] DATETIME,
				[Curve ID] INT,
				[Strip Month To] INT
			)
			DECLARE @insert_query NVARCHAR(2000),@select_query NVARCHAR(2000), @sql NVARCHAR(MAX)
			SELECT @insert_query = STUFF((SELECT ',' + '[' + field_label + ']'
										FROM formula_editor_parameter
										WHERE function_name = 'LagCurve'
										AND field_label IN ('Curve ID', 'Strip Month To')
										ORDER BY [sequence]
										FOR XML PATH('')), 1, 1, '')
			SELECT @select_query = STUFF((SELECT ',' + 'arg' + CAST(sequence AS VARCHAR(10))
										FROM formula_editor_parameter
										WHERE function_name = 'LagCurve'
										AND field_label IN ('Curve ID', 'Strip Month To')
										ORDER BY [sequence]
										FOR XML PATH('')), 1, 1, '')
			SET @sql = 'INSERT INTO #temp_formula_data(source_deal_header_id,term_start,term_end, ' + @insert_query + ') 
						SELECT srns.source_deal_header_id,sdd.term_start,sdd.term_end,' + @select_query + '
						FROM source_remit_non_standard srns
						INNER JOIN source_deal_header sdh
							ON sdh.source_deal_header_id = srns.source_deal_header_id
						OUTER APPLY (SELECT MAX(formula_id) formula_id, MIN(term_start) term_start, MAX(term_end) term_end
									 FROM source_deal_detail sdd
									 WHERE source_deal_header_id = srns.source_deal_header_id
						) sdd
						INNER JOIN formula_breakdown fb
							ON fb.formula_id = sdd.formula_id
						WHERE srns.process_id = ''' + @process_id + '''
						AND fb.func_name IN (''LagCurve'')
						'
			EXEC(@sql)


			IF OBJECT_ID('tempdb..#temp_source_non_remit_standard_pvt') IS NOT NULL
				DROP TABLE #temp_source_non_remit_standard_pvt

			SELECT  source_deal_header_id, id,
			ace, lei, bic, eic, gin,
			SOURCE_CODE_ace, SOURCE_CODE_lei, SOURCE_CODE_bic, SOURCE_CODE_eic, SOURCE_CODE_gin,
			DEAL_SOURCE_CODE_ace, DEAL_SOURCE_CODE_lei, DEAL_SOURCE_CODE_bic, DEAL_SOURCE_CODE_eic, DEAL_SOURCE_CODE_gin
			INTO #temp_source_non_remit_standard_pvt
			FROM (
							SELECT  source_deal_header_id ,
									id,
									process_id,
									[reporting_entity_id] AS RRM,
								   [type_of_code_used_in_field_5] AS RRM_ID,
								   [id_of_the_market_participant_or_counterparty] AS sub_counterparty_id,
								   'SOURCE_CODE_' + [type_of_code_used_in_field_1] AS sub_source_code,
								   [id_of_the_other_market_participant_or_counterparty] AS deal_counterparty_id,
								   'DEAL_SOURCE_CODE_' + [type_of_code_used_in_field_3] AS deal_source_code,
								   [beneficiary_id] AS beneficiaryIdentification,
								   [type_of_code_used_in_field_7] AS type_of_code_used_in_field_7
							FROM source_remit_non_standard
							WHERE process_id = @process_id
						) AS s PIVOT (MAX(RRM) FOR RRM_ID IN (ace, lei, bic, eic, gin)) AS pvt
						PIVOT (MAX(sub_counterparty_id) FOR sub_source_code IN (SOURCE_CODE_ace, SOURCE_CODE_lei, SOURCE_CODE_bic, SOURCE_CODE_eic, SOURCE_CODE_gin)) AS pvt2
						PIVOT (MAX(deal_counterparty_id) FOR deal_source_code IN (DEAL_SOURCE_CODE_ace, DEAL_SOURCE_CODE_lei, DEAL_SOURCE_CODE_bic, DEAL_SOURCE_CODE_eic, DEAL_SOURCE_CODE_gin)) AS pvt3
		
			SELECT @xml_innermost = (
				SELECT ROW_NUMBER() OVER(ORDER BY [Action_type]) AS
					   RecordSeqNumber,
					   CASE WHEN ROW_NUMBER() OVER(PARTITION BY srs.source_deal_header_id ORDER BY [Action_type]) = 1 THEN SOURCE_CODE_ace ELSE DEAL_SOURCE_CODE_ace END [idOfMarketParticipant/ace],
					   CASE WHEN ROW_NUMBER() OVER(PARTITION BY srs.source_deal_header_id ORDER BY [Action_type]) = 1 THEN SOURCE_CODE_lei ELSE DEAL_SOURCE_CODE_lei END [idOfMarketParticipant/lei],		   
					   CASE WHEN ROW_NUMBER() OVER(PARTITION BY srs.source_deal_header_id ORDER BY [Action_type]) = 1 THEN SOURCE_CODE_bic ELSE DEAL_SOURCE_CODE_bic END [idOfMarketParticipant/bic],		   
					   CASE WHEN ROW_NUMBER() OVER(PARTITION BY srs.source_deal_header_id ORDER BY [Action_type]) = 1 THEN SOURCE_CODE_eic ELSE DEAL_SOURCE_CODE_eic END [idOfMarketParticipant/eic],		   
					   CASE WHEN ROW_NUMBER() OVER(PARTITION BY srs.source_deal_header_id ORDER BY [Action_type]) = 1 THEN SOURCE_CODE_gin ELSE DEAL_SOURCE_CODE_gin END [idOfMarketParticipant/gin],		   
					   CASE WHEN ROW_NUMBER() OVER(PARTITION BY srs.source_deal_header_id ORDER BY [Action_type]) = 1 THEN DEAL_SOURCE_CODE_ace ELSE SOURCE_CODE_ace END [otherMarketParticipant/ace],		   
					   CASE WHEN ROW_NUMBER() OVER(PARTITION BY srs.source_deal_header_id ORDER BY [Action_type]) = 1 THEN DEAL_SOURCE_CODE_lei ELSE SOURCE_CODE_lei END [otherMarketParticipant/lei],		   
					   CASE WHEN ROW_NUMBER() OVER(PARTITION BY srs.source_deal_header_id ORDER BY [Action_type]) = 1 THEN DEAL_SOURCE_CODE_bic ELSE SOURCE_CODE_bic END [otherMarketParticipant/bic],		   
					   CASE WHEN ROW_NUMBER() OVER(PARTITION BY srs.source_deal_header_id ORDER BY [Action_type]) = 1 THEN DEAL_SOURCE_CODE_eic ELSE SOURCE_CODE_eic END [otherMarketParticipant/eic],		   
					   CASE WHEN ROW_NUMBER() OVER(PARTITION BY srs.source_deal_header_id ORDER BY [Action_type]) = 1 THEN DEAL_SOURCE_CODE_gin ELSE SOURCE_CODE_gin END [otherMarketParticipant/gin],
					   [Beneficiary_ID] AS [beneficiaryIdentification],
					   [Trading_capacity_of_the_market_participant_or_counterparty_in_field_1] AS [tradingCapacity],
					   buy_sell_indicator AS [buySellIndicator],
					   [contract_id] AS [contractId],
					   CONVERT(VARCHAR(10), [Contract_Date], 120) AS [contractDate],
					   [Contract_Type] AS [contractType],
					   [Energy_Commodity] AS [energyCommodity],
					   [price_formula] AS [priceOrPriceFormula/priceFormula],
					   --dbo.fnaremovetrailingzeroes([price]) AS [priceOrPriceFormula/price/value],
					   --[Notional_Currency] AS [priceOrPriceFormula/price/currency],
					   --dbo.fnaremovetrailingzeroes([Estimated_Notional_Amount]) AS [estimatedNotionalAmount/value],
					   --[Notional_Currency] AS [estimatedNotionalAmount/currency],
					   --dbo.fnaremovetrailingzeroes([Total_Notional_Contract_Quantity]) AS [totalNotionalContractQuantity/value],
					   --[Notional_Quantity_Unit] AS [totalNotionalContractQuantity/unit],
					   [Volume_Optionality] AS [volumeOptionality],
					   [Volume_Optionality_Frequency] AS [volumeOptionalityFrequency],
					   [Volume_Optionality_Capacity] AS [volumeOptionalityIntervals/capacity/value],
					   SUBSTRING([Volume_optionality_intervals], 0, 11) AS [volumeOptionalityIntervals/startDate],
					   SUBSTRING([Volume_optionality_intervals], CHARINDEX('/', [Volume_optionality_intervals]) + 1, 10) AS [volumeOptionalityIntervals/endDate],
					   [Type_of_Index_Price] AS typeOfIndexPrice,
					   COALESCE(tbl.xml_detail,tbl_f.xml_detail,tbl_index.xml_detail) temp_fixingIndexDetails,
					   [Settlement_Method] AS settlementMethod,
                       [Option_Style] AS [optionDetails/optionStyle],
                       [Option_Type] AS [optionDetails/optionType],
                       CONVERT(VARCHAR(10), [Option_First_Exercise_Date], 120) AS 
                       [optionDetails/optionFirstExerciseDate],
                       CONVERT(VARCHAR(10), [Option_Last_Exercise_Date], 120) AS 
                       [optionDetails/optionLastExerciseDate],
                       [Option_Exercise_Frequency] AS 
                       [optionDetails/optionExerciseFrequency],
                       [Option_Strike_Index] AS 
                       [optionDetails/optionStrikeIndex],
                       [option_strike_index_type] AS 
                       [optionDetails/optionIndexType],
                       [Option_Strike_Index_Source] AS 
                       [optionDetails/optionIndexSource],
                       [Option_Strike_Price] AS [OptionStrikePrice/value],
                       [delivery_point_or_zone] AS [deliveryPointOrZone],
                       CONVERT(VARCHAR(10), Delivery_Start_Date, 120) AS [deliveryStartDate],
                       CONVERT(VARCHAR(10), Delivery_End_Date, 120) AS [deliveryEndDate],
                       [Load_Type] AS [loadType],
                       [Action_type] AS [actionType]
                FROM source_remit_non_standard srs
				INNER JOIN #temp_source_non_remit_standard_pvt tsnrsp
					ON tsnrsp.source_deal_header_id = srs.source_deal_header_id
					AND tsnrsp.id = srs.id
				OUTER APPLY (
					SELECT  MAX(spcd.curve_id) [fixingIndex]
							,'FW' [fixingIndexType]
							,ISNULL(MAX(sdv.code),'') [fixingIndexSource]
							,CONVERT(VARCHAR(10),DATEADD(month, -ISNULL(MAX(pps.average_period),0) - ISNULL(MAX(pps.skip_period),0),MIN(sdd.term_start)),120) [firstFixingDate]
							,CONVERT(VARCHAR(10),DATEADD(month, -ISNULL(MAX(pps.average_period),0) - ISNULL(MAX(pps.skip_period),0),MAX(term_end)),120) [lastFixingDate]
							,'M' [fixingFrequency] 
							FROM source_deal_header sdh
							INNER JOIn source_deal_detail sdd
								ON sdd.source_deal_header_id = sdh.source_deal_header_id
							INNER JOIN deal_price_type dpt
								ON dpt.source_deal_detail_id = sdd.source_deal_detail_id
							INNER JOIN deal_price_deemed dpd
								ON dpd.deal_price_type_id = dpt.deal_price_type_id
							INNER JOIN source_price_curve_def spcd
								ON spcd.source_curve_def_id = dpd.pricing_index
							LEFT JOIN pricing_period_setup pps
								ON pps.pricing_period_value_id = dpd.pricing_period
							LEFT JOIN static_data_value sdv
								ON sdv.value_id = spcd.market_value_desc
								AND sdv.type_id = 29700
					WHERE sdh.source_deal_header_id = srs.source_deal_header_id
					AND dpt.price_type_id = 103601
					GROUP BY dpd.pricing_index
					FOR XML PATH ('fixingIndexDetails'), TYPE
					) AS tbl(xml_detail)
				OUTER APPLY (
					SELECT  spcd.[curve_des] [fixingIndex]
					   ,'FW' [fixingIndexType]
					   ,ISNULL(sdv.code,'') [fixingIndexSource]
					   ,CONVERT(VARCHAR(10),DATEADD(month, -ISNULL(tfd.[Strip Month To],0), tfd.term_start),120) [firstFixingDate]
					   ,CONVERT(VARCHAR(10),DATEADD(month, -ISNULL(tfd.[Strip Month To],0), tfd.term_end),120) [lastFixingDate]
					   ,'M' [fixingFrequency] 
					FROM #temp_formula_data tfd
					INNER JOIN source_price_curve_def spcd
						ON spcd.source_curve_def_id = tfd.[Curve ID]
					LEFT JOIN static_data_value sdv
									ON sdv.value_id = spcd.market_value_desc
									AND sdv.type_id = 29700
					WHERE tfd.source_deal_header_id = srs.source_deal_header_id
					FOR XML PATH ('fixingIndexDetails'), TYPE
				) AS tbl_f(xml_detail)
				OUTER APPLY (
					SELECT  MAX(spcd.curve_des) [fixingIndex]
							,'FW' [fixingIndexType]
							,ISNULL(MAX(sdv.code),'') [fixingIndexSource]
							,CONVERT(VARCHAR(10),MIN(sdd.term_start),120) [firstFixingDate]
							,CONVERT(VARCHAR(10),MAX(term_end),120) [lastFixingDate]
							,'M' [fixingFrequency] 
					FROM source_deal_header sdh
					INNER JOIn source_deal_detail sdd
						ON sdd.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN source_price_curve_def spcd
						ON spcd.source_curve_def_id = sdd.formula_curve_id
					LEFT JOIN static_data_value sdv
						ON sdv.value_id = spcd.market_value_desc
						AND sdv.type_id = 29700
					WHERE sdh.source_deal_header_id = srs.source_deal_header_id
					FOR XML PATH ('fixingIndexDetails'), TYPE
				) AS tbl_index(xml_detail)
                WHERE process_id = @process_id
				FOR XML PATH('nonStandardContractReport'), ROOT('TradeList'), TYPE
			)
            FROM (
				SELECT [reporting_entity_id] AS RRM,
					   [type_of_code_used_in_field_5] AS RRM_ID,
					   [id_of_the_market_participant_or_counterparty] AS sub_counterparty_id,
					   'SOURCE_CODE_' + [type_of_code_used_in_field_1] AS sub_source_code,
					   [id_of_the_other_market_participant_or_counterparty] AS deal_counterparty_id,
					   'DEAL_SOURCE_CODE_' + [type_of_code_used_in_field_3] AS deal_source_code,
					   [beneficiary_id] AS beneficiaryIdentification,
					   [type_of_code_used_in_field_7] AS type_of_code_used_in_field_7
                FROM source_remit_non_standard
				WHERE process_id = @process_id
			) AS s PIVOT (MAX(RRM) FOR RRM_ID IN (ace, lei, bic, eic, gin)) AS pvt
			PIVOT (MAX(sub_counterparty_id) FOR sub_source_code IN (SOURCE_CODE_ace, SOURCE_CODE_lei, SOURCE_CODE_bic, SOURCE_CODE_eic, SOURCE_CODE_gin)) AS pvt2
			PIVOT (MAX(deal_counterparty_id) FOR deal_source_code IN (DEAL_SOURCE_CODE_ace, DEAL_SOURCE_CODE_lei, DEAL_SOURCE_CODE_bic, DEAL_SOURCE_CODE_eic, DEAL_SOURCE_CODE_gin)) AS pvt3
            
			SELECT @xml_innermost = REPLACE(REPLACE(CAST(@xml_innermost AS NVARCHAR(MAX)),'<temp_fixingIndexDetails>',''),'</temp_fixingIndexDetails>','')

            ----Xml export of selected row
            ;WITH XMLNAMESPACES(
                'http://www.acer.europa.eu/REMIT/REMITTable2_V1.xsd' AS ns1
            )
            SELECT @xml_inner = (
				SELECT ace AS [reportingEntityID/ace],
					   lei AS [reportingEntityID/lei],
					   bic AS [reportingEntityID/bic],
					   eic AS [reportingEntityID/eic],
					   gin AS [reportingEntityID/gin],
					   @xml_innermost
                FROM (
					SELECT TOP 1 ISNULL([reporting_entity_id], '') AS RRM,
						   ISNULL([type_of_code_used_in_field_5], '') AS RRM_ID,
						   [id_of_the_market_participant_or_counterparty] AS sub_counterparty_id,
						   'SOURCE_CODE_' + [type_of_code_used_in_field_1] AS sub_source_code,
						   [id_of_the_other_market_participant_or_counterparty] AS deal_counterparty_id,
						   'DEAL_SOURCE_CODE_' + [type_of_code_used_in_field_3] AS deal_source_code,
						   [beneficiary_id] AS beneficiaryIdentification,
						   [type_of_code_used_in_field_7] AS type_of_code_used_in_field_7
					FROM source_remit_non_standard
					WHERE process_id = @process_id
				) AS s
				PIVOT(MAX(RRM) FOR RRM_ID IN (ace, lei, bic, eic, gin)) AS pvt
				PIVOT(MAX(sub_counterparty_id) FOR sub_source_code IN (SOURCE_CODE_ace, SOURCE_CODE_lei, SOURCE_CODE_bic, SOURCE_CODE_eic, SOURCE_CODE_gin)) AS pvt2
				PIVOT(MAX(deal_counterparty_id) FOR deal_source_code IN (DEAL_SOURCE_CODE_ace, DEAL_SOURCE_CODE_lei, DEAL_SOURCE_CODE_bic, DEAL_SOURCE_CODE_eic, DEAL_SOURCE_CODE_gin)) AS pvt3
				FOR XML PATH('REMITTable2'), TYPE
			)
            
            /*SELECT @xml_outer = (SELECT @xml_inner 	FOR XML PATH('RemitReport'), TYPE) 
		
			SET @addxml = '<?xml version="1.0" encoding="UTF-8"?>'

			;WITH XMLNAMESPACES ('http://Essent/REM/Remit' AS ns2, 'http://www.w3.org/2001/XMLSchema' AS xsd , 'http://www.w3.org/2001/XMLSchema-instance' AS xsi)
			SELECT @xml = (
				SELECT TOP 1 'TRMTracker' [Creator],
					   'Remit_XML_Report_' + REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), @as_of_date, 120), ':', ''), ' ', '_'), '-', '_') + '.xml' AS [Reference], --filename
					   GETDATE() AS [CreationDateTime],
					   process_id AS [TransmissionID],
					   CASE WHEN @mirror_reporting = 1 THEN 'true' ELSE 'false' END [MirrorReporting],
					   'false' [DelegatedReporting],
					   CASE WHEN @intragroup = 1 THEN 'true' ELSE 'false' END [Intragroup],
					   CASE WHEN @generate_uti = 1 THEN 'true' ELSE 'false' END [GenerateUTI],
					   @xml_outer
				FROM source_remit_non_standard srns 
				WHERE process_id = @process_id
				FOR XML PATH('REMRemit'), TYPE
			)

			SELECT @xml = CONVERT(XML, REPLACE(CONVERT(VARCHAR(MAX), @xml), 'xmlns:ns2', 'xmlns'))
			SELECT @xml = CONVERT(XML, REPLACE(CONVERT(VARCHAR(MAX), @xml), 'xmlns:ns1', 'xmlns'))*/

			SELECT @xml_inner = CONVERT(XML, REPLACE(CONVERT(VARCHAR(MAX), @xml_inner), 'xmlns:ns1', 'xmlns'))

	 		SELECT @source = @xml_inner
			SELECT @xml_string = @addxml + CAST(@xml_inner AS VARCHAR(MAX))
			SET @file_name = 'remit_non_standard_' + @process_id + '_' + CONVERT(VARCHAR(7), GETDATE(), 112) + '.xml'
			SET @full_file_path = @file_path + @file_name
			EXEC [spa_write_to_file] @xml_string, 'n',  @full_file_path, @result OUTPUT
			IF @result = '1'
			BEGIN
				UPDATE source_remit_non_standard
				SET file_export_name = @file_name
				    ,acer_submission_status =39501
				WHERE process_id = @process_id
				IF @file_transfer_endpoint_id IS NOT NULL
				BEGIN
					EXEC spa_upload_file_to_ftp_using_clr @file_transfer_endpoint_id, @remote_directory, @full_file_path, @result OUTPUT
				END
			END
            RETURN
        END
        ELSE IF @report_type = 39401
		BEGIN
			IF OBJECT_ID('tempdb..#temp_source_remit_standard_pvt') IS NOT NULL
				DROP TABLE #temp_source_remit_standard_pvt

			SELECT  source_deal_header_id, id,
			DEAL_SOURCE_CODE_ace, DEAL_SOURCE_CODE_lei, DEAL_SOURCE_CODE_bic, DEAL_SOURCE_CODE_eic, DEAL_SOURCE_CODE_gin,
			ace, lei, bic, eic, gin,
			SOURCE_CODE_ace, SOURCE_CODE_lei, SOURCE_CODE_bic, SOURCE_CODE_eic, SOURCE_CODE_gin
			INTO #temp_source_remit_standard_pvt
			FROM (
				SELECT  source_deal_header_id ,
						id,
						process_id,
						[reporting_entity_id] AS RRM,
						[type_of_code_field_6] AS RRM_ID,
						[market_id_participant_counterparty] AS sub_counterparty_id,
						'SOURCE_CODE_' + [type_of_code_field_1]  AS sub_source_code,
						[other_id_market_participant_counterparty] AS deal_counterparty_id,
						'DEAL_SOURCE_CODE_' + [type_of_code_field_4] AS deal_source_code,
						[beneficiary_id] AS beneficiaryIdentification,
						[type_of_code_field_8] AS type_of_code_used_in_field_8
				FROM source_remit_standard
				WHERE process_id = @process_id

			) AS s 
			PIVOT (MAX(deal_counterparty_id) FOR deal_source_code IN (DEAL_SOURCE_CODE_ace, DEAL_SOURCE_CODE_lei, DEAL_SOURCE_CODE_bic, DEAL_SOURCE_CODE_eic, DEAL_SOURCE_CODE_gin)) AS pvt3
			PIVOT (MAX(RRM) FOR RRM_ID IN (ace, lei, bic, eic, gin)) AS pvt
			PIVOT (MAX(sub_counterparty_id) FOR sub_source_code IN (SOURCE_CODE_ace, SOURCE_CODE_lei, SOURCE_CODE_bic, SOURCE_CODE_eic, SOURCE_CODE_gin)) AS pvt2

			SELECT @trade_list = (
				SELECT -- according to generated sample by xsd
					   ROW_NUMBER() OVER(ORDER BY [Action_type]) AS RecordSeqNumber,
					   SOURCE_CODE_ace AS [idOfMarketParticipant/ace],
					   SOURCE_CODE_lei AS [idOfMarketParticipant/lei], 
					   SOURCE_CODE_bic AS [idOfMarketParticipant/bic],
					   SOURCE_CODE_eic AS [idOfMarketParticipant/eic],
					   SOURCE_CODE_gin AS [idOfMarketParticipant/gin],
					   [trader_id_market_participant] AS [traderID/traderIdForMarketParticipant],
					   DEAL_SOURCE_CODE_ace AS [otherMarketParticipant/ace],
					   DEAL_SOURCE_CODE_lei AS [otherMarketParticipant/lei],
					   DEAL_SOURCE_CODE_bic AS [otherMarketParticipant/bic],
					   DEAL_SOURCE_CODE_eic AS [otherMarketParticipant/eic],
					   DEAL_SOURCE_CODE_gin AS [otherMarketParticipant/gin],
					   [beneficiary_id] AS [beneficiaryIdentification],
					   [trading_capacity_market_participant] AS [tradingCapacity],
					   [buy_sell_indicator] AS [buySellIndicator],
					   [initiator_aggressor] AS [aggressor],
					   [order_type] AS [clickAndTradeDetails/orderType],
					   [order_condition] AS [clickAndTradeDetails/orderCondition],
					   [order_status] AS [clickAndTradeDetails/orderStatus],
					   [minimum_execution_volume] AS [clickAndTradeDetails/minimumExecuteVolume/value],
					   NULL AS [clickAndTradeDetails/minimumExecuteVolume/unit],
					   [price_limit] AS [clickAndTradeDetails/triggerDetails/priceLimit/value],
					   NULL AS [clickAndTradeDetails/triggerDetails/priceLimit/currency],
					   NULL AS [clickAndTradeDetails/triggerDetails/triggerContractId],
					   undisclosed_volume AS [clickAndTradeDetails/undisclosedVolume/value],
					   NULL AS [clickAndTradeDetails/undisclosedVolume/unit],
					   [order_duration] AS [clickAndTradeDetails/orderDuration/duration],
					   NULL AS [clickAndTradeDetails/orderDuration/expirationDateTime],
					   srs.[source_deal_header_id] AS [contractInfo/contract/contractId],
					   --CONVERT(VARCHAR(10), sdh.deal_date, 120) [contractInfo/contract/contractDate],
					   [contract_name] AS [contractInfo/contract/contractName],
					   [contract_type] AS [contractInfo/contract/contractType],					   
					   [energy_commodity] AS [contractInfo/contract/energyCommodity],
					   [settlement_method] AS [contractInfo/contract/settlementMethod],
					   [organised_market_place_id_otc] AS [contractInfo/contract/organisedMarketPlaceIdentifier/bil],
					   SUBSTRING ([contract_trading_hours], 0, CHARINDEX('Z/', [contract_trading_hours], 0)) + ':00'  AS [contractInfo/contract/contractTradingHours/startTime],
					   LEFT (SUBSTRING ([contract_trading_hours], CHARINDEX('Z/',[contract_trading_hours], 0) + 2, 5), 5) + ':00'  AS [contractInfo/contract/contractTradingHours/endTime],
					   [delivery_point_or_zone] AS [contractInfo/contract/deliveryPointOrZone],
					   CONVERT(char(10), [delivery_start_date],126) AS [contractInfo/contract/deliveryStartDate],
					   CONVERT(char(10), [delivery_end_date],126) AS [contractInfo/contract/deliveryEndDate],
					   load_type [contractInfo/contract/loadType],
					   dbo.FNATimeWithLeadingZero(RTRIM(LEFT(NULLIF([load_delivery_intervals],''), 5))) [contractInfo/contract/deliveryProfile/loadDeliveryStartTime],
					   dbo.FNATimeWithLeadingZero(LTRIM(RIGHT(NULLIF([load_delivery_intervals],''), 5))) [contractInfo/contract/deliveryProfile/loadDeliveryEndTime],
					   [organised_market_place_id_otc] AS [organisedMarketPlaceIdentifier/bil],
					   [transaction_timestamp] AS [transactionTime],
					   [transaction_timestamp] AS [executionTime],
					   [unique_transaction_id]  AS [uniqueTransactionIdentifier/uniqueTransactionIdentifier],
					   [linked_transaction_id] AS [linkedTransactionId],
					   [linked_order_id] AS [linkedOrderId],
					   [voice_brokered] AS [voiceBrokered],
					   [price] AS [priceDetails/price],
					   [price_currency] AS [priceDetails/priceCurrency],
					   [notional_amount] AS [notionalAmountDetails/notionalAmount],
					   [notional_currency] AS [notionalAmountDetails/notionalCurrency],
					   [quantity_volume] AS [quantity/value],
					   CASE WHEN [quantity_volume] IS NOT NULL THEN ISNULL(NULLIF(SUBSTRING(quantity_unit_field_40_and_41, 0, CHARINDEX(' /', quantity_unit_field_40_and_41, 0)), ''), quantity_unit_field_40_and_41) ELSE NULL END AS [quantity/unit],
					   [total_notional_contract_quantity] AS [totalNotionalContractQuantity/value],
					   CASE WHEN [quantity_unit_field_40_and_41] = 'MW / MWh' THEN 'MWh' ELSE [quantity_unit_field_40_and_41] END AS [totalNotionalContractQuantity/unit],
					   [termination_date] AS [terminationDate],
					   [action_type] AS [actionType],
					   NULL AS [Extra]
				FROM source_remit_standard srs
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = srs.source_deal_header_id
				INNER JOIN #temp_source_remit_standard_pvt rsrsp
					ON rsrsp.source_deal_header_id = srs.source_deal_header_id
					AND rsrsp.id = srs.id
				WHERE process_id = @process_id
				FOR XML PATH ('TradeReport'), Root('TradeList'), TYPE)
			
		
		----Xml export of selected row
			;WITH XMLNAMESPACES (
				'http://www.w3.org/2001/XMLSchema-instance' AS xsi,
				'http://www.acer.europa.eu/REMIT/REMITTable1_V2.xsd' AS ns1
			)
			SELECT @xml_inner = ( 
				SELECT ace AS [reportingEntityID/ace],
					   lei AS [reportingEntityID/lei],
					   bic AS [reportingEntityID/bic],
					   eic AS [reportingEntityID/eic],
					   gin AS [reportingEntityID/gin],
					   @trade_list
				FROM (
					SELECT TOP 1 ISNULL([reporting_entity_id], '') AS RRM,
						   ISNULL([type_of_code_field_6], '') AS RRM_ID,
						   [market_id_participant_counterparty] AS sub_counterparty_id,
						   'SOURCE_CODE_' + [type_of_code_field_1]  AS sub_source_code,
						   [other_id_market_participant_counterparty] AS deal_counterparty_id,
						   'DEAL_SOURCE_CODE_' + [type_of_code_field_4] AS deal_source_code,
						   [beneficiary_id] AS beneficiaryIdentification,
						   [type_of_code_field_8] AS type_of_code_used_in_field_8
					FROM source_remit_standard
					WHERE process_id = @process_id
				) AS s
				PIVOT (MAX(RRM) FOR RRM_ID IN (ace, lei, bic, eic, gin)) AS pvt
				PIVOT (MAX(sub_counterparty_id) FOR sub_source_code IN (SOURCE_CODE_ace, SOURCE_CODE_lei, SOURCE_CODE_bic, SOURCE_CODE_eic, SOURCE_CODE_gin)) AS pvt2
				PIVOT (MAX(deal_counterparty_id) FOR deal_source_code IN (DEAL_SOURCE_CODE_ace, DEAL_SOURCE_CODE_lei, DEAL_SOURCE_CODE_bic, DEAL_SOURCE_CODE_eic, DEAL_SOURCE_CODE_gin)) AS pvt3
				FOR XML PATH('REMITTable1'), TYPE
			)

			--SELECT @xml_inner = CONVERT(XML, REPLACE(CONVERT(VARCHAR(MAX), @xml_inner), 'xmlns:ns2', 'xmlns'))
			--SELECT @xml_inner = CONVERT(XML, REPLACE(CONVERT(VARCHAR(MAX), @xml_inner), 'xmlns:ns1', 'xmlns'))
			--SELECT @xml_outer = (SELECT @xml_inner 	FOR XML PATH('RemitReport'), TYPE) 
		
			--SET @addxml = '<?xml version="1.0" encoding="UTF-8"?>'

			--;WITH XMLNAMESPACES (
			--	'http://Essent/REM/Remit' AS ns2,
			--	'http://www.w3.org/2001/XMLSchema' AS xsd ,
			--	'http://www.w3.org/2001/XMLSchema-instance' AS xsi
			--)
			--SELECT @xml = (
			--	SELECT TOP 1
			--		   'TRMTracker' [Creator],
			--		   'Remit_XML_Report_' + REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), @as_of_date, 120), ':', ''), ' ', '_'), '-', '_') + '.xml' AS [Reference], --filename
			--		   GETDATE() AS [CreationDateTime],
			--		   process_id AS [TransmissionID],
			--		   CASE WHEN @mirror_reporting = 1 THEN 'true' ELSE 'false' END [MirrorReporting],
			--		   'false' [DelegatedReporting],
			--		   CASE WHEN @intragroup = 1 THEN 'true' ELSE 'false' END [Intragroup],
			--		   CASE WHEN @generate_uti = 1 THEN 'true' ELSE 'false' END [GenerateUTI],
			--		   @xml_outer
			--	FROM source_remit_standard srs 
			--	WHERE process_id = @process_id
			--	FOR XML PATH('REMRemit'), TYPE
			--)
			SELECT @xml = @xml_inner
			SELECT @xml = CONVERT(XML, REPLACE(CONVERT(VARCHAR(MAX), @xml), 'xmlns:ns2', 'xmlns'))
			SELECT @xml = CONVERT(XML, REPLACE(CONVERT(VARCHAR(MAX), @xml), 'xmlns:ns1', 'xmlns'))
	 		SELECT @source = @xml
			SELECT @xml_string = @addxml + CAST(@xml AS VARCHAR(MAX))
			SET @file_name = 'remit_standard_' + @process_id + '_' + CONVERT(VARCHAR(7), GETDATE(), 112) + '.xml'
			SET @full_file_path = @file_path + @file_name
			EXEC [spa_write_to_file] @xml_string, 'n',  @full_file_path, @result OUTPUT
			IF @result = '1'
			BEGIN
				UPDATE source_remit_standard
				SET file_export_name = @file_name
					,acer_submission_status =39501
				WHERE process_id = @process_id
				IF @file_transfer_endpoint_id IS NOT NULL
				BEGIN
					EXEC spa_upload_file_to_ftp_using_clr @file_transfer_endpoint_id, @remote_directory, @full_file_path, @result OUTPUT
				END
			END
			RETURN
		END
		ELSE IF @report_type = 39405
		BEGIN
		
			IF OBJECT_ID('tempdb..#temp_source_remit_standard_pvt1') IS NOT NULL
				DROP TABLE #temp_source_remit_standard_pvt1

			SELECT  source_deal_header_id, id1,
			ace,lei,bic,eic,gin,
			SOURCE_CODE_ace, SOURCE_CODE_lei, SOURCE_CODE_bic, SOURCE_CODE_eic, SOURCE_CODE_gin,
			DEAL_SOURCE_CODE_ace, DEAL_SOURCE_CODE_lei, DEAL_SOURCE_CODE_bic, DEAL_SOURCE_CODE_eic, DEAL_SOURCE_CODE_gin
			INTO #temp_source_remit_standard_pvt1
			FROM (
				SELECT source_deal_header_id ,
						id [id1],
						process_id,
						[reporting_entity_id] AS RRM,
						[type_of_code_field_6] AS RRM_ID,
						[market_id_participant_counterparty] AS sub_counterparty_id,
						'SOURCE_CODE_' + [type_of_code_field_1]  AS sub_source_code,
						[other_id_market_participant_counterparty] AS deal_counterparty_id,
						'DEAL_SOURCE_CODE_' + [type_of_code_field_4] AS deal_source_code,
						[beneficiary_id] AS beneficiaryIdentification,
						[type_of_code_field_8] AS type_of_code_used_in_field_8
				FROM source_remit_standard
				WHERE process_id = @process_id
			) AS s PIVOT (MAX(RRM) FOR RRM_ID IN (ace,lei,bic,eic,gin)) AS pvt
			PIVOT (MAX(sub_counterparty_id) FOR sub_source_code IN (SOURCE_CODE_ace, SOURCE_CODE_lei, SOURCE_CODE_bic, SOURCE_CODE_eic, SOURCE_CODE_gin)) AS pvt2
			PIVOT (MAX(deal_counterparty_id) FOR deal_source_code IN (DEAL_SOURCE_CODE_ace, DEAL_SOURCE_CODE_lei, DEAL_SOURCE_CODE_bic, DEAL_SOURCE_CODE_eic, DEAL_SOURCE_CODE_gin)) AS pvt3

			SELECT @contract_list = (
				SELECT [contract_id] AS [contractId],
					   [contract_name] AS [contractName],
					   [contract_type] AS [contractType],
					   [energy_commodity] AS [energyCommodity],
					   (
							SELECT rs.item AS [indexName],
								   dbo.FNAGetSplitPart(LTRIM([index_value]), ', ', rs.id) AS [indexValue]
							FROM (
								SELECT ROW_NUMBER() OVER(ORDER BY item) AS id,
									   item 
								FROM dbo.SplitCommaSeperatedValues([fixing_index_or_reference_price])
							) rs
							FOR XML PATH('fixingIndex'), TYPE),
					   [settlement_method] AS [settlementMethod],
					   [organised_market_place_id_otc] AS [organisedMarketPlaceIdentifier/bil],
					   SUBSTRING ([contract_trading_hours], 0, CHARINDEX('Z/', [contract_trading_hours], 0)) + ':00'  AS [contractTradingHours/startTime],
					   LEFT (SUBSTRING ([contract_trading_hours], CHARINDEX('Z/',[contract_trading_hours], 0) + 2, 5), 5) + ':00'  AS [contractTradingHours/endTime],
					   [last_trading_date_and_time] AS [lastTradingDateTime],
					   [option_style] AS [optionDetails/optionStyle],
					   [option_type] AS [optionDetails/optionType],
					   [option_exercise_date] AS [optionDetails/optionExerciseDate],
					   [option_strike_price] AS [optionDetails/optionStrikePrice/value],
					   NULL AS [optionDetails/optionStrikePrice/currency],
					   [delivery_point_or_zone] AS [deliveryPointOrZone],
					   CONVERT(VARCHAR(10), [delivery_start_date], 120) AS [deliveryStartDate],
					   CONVERT(VARCHAR(10), [delivery_end_date], 120) AS [deliveryEndDate],
					   [duration] AS [duration],
					   [load_type] [loadType],
					   CONVERT(VARCHAR(10), [delivery_start_date], 120) [deliveryProfile/loadDeliveryStartDate],
					   CONVERT(VARCHAR(10), [delivery_end_date], 120) [deliveryProfile/loadDeliveryEndDate],
					   days_of_the_week [deliveryProfile/daysOfTheWeek],
					   dbo.FNATimeWithLeadingZero(RTRIM(LEFT([load_delivery_intervals], 5))) [deliveryProfile/loadDeliveryStartTime],
					   dbo.FNATimeWithLeadingZero(LTRIM(RIGHT([load_delivery_intervals], 5))) [deliveryProfile/loadDeliveryEndTime]
				FROM source_remit_standard srs
				INNER JOIN #temp_source_remit_standard_pvt1 tsrsp
					ON tsrsp.source_deal_header_id = srs.source_deal_header_id
					AND tsrsp.id1 = srs.id1
				WHERE process_id = @process_id 
				FOR XML PATH ('contract'), Root('contractList'), TYPE)

			IF OBJECT_ID('tempdb..#temp_source_remit_standard_pvt2') IS NOT NULL
				DROP TABLE #temp_source_remit_standard_pvt2

			SELECT source_deal_header_id,id1, ace, lei, bic, eic, gin,
			SOURCE_CODE_ace, SOURCE_CODE_lei, SOURCE_CODE_bic, SOURCE_CODE_eic, SOURCE_CODE_gin,
			DEAL_SOURCE_CODE_ace, DEAL_SOURCE_CODE_lei, DEAL_SOURCE_CODE_bic, DEAL_SOURCE_CODE_eic, DEAL_SOURCE_CODE_gin
			INTO #temp_source_remit_standard_pvt2
			FROM (
				SELECT  source_deal_header_id ,
						id [id1],
						process_id,
						[reporting_entity_id] AS RRM,
						[type_of_code_field_6] AS RRM_ID,
						[market_id_participant_counterparty] AS sub_counterparty_id,
						'SOURCE_CODE_' + [type_of_code_field_1]  AS sub_source_code,
						[other_id_market_participant_counterparty] AS deal_counterparty_id,
						'DEAL_SOURCE_CODE_' + [type_of_code_field_4] AS deal_source_code,
						[beneficiary_id] AS beneficiaryIdentification,
						[type_of_code_field_8] AS type_of_code_used_in_field_8
				FROM source_remit_standard
				WHERE process_id = @process_id
			) AS s 
			PIVOT (MAX(RRM) FOR RRM_ID IN (ace, lei, bic, eic, gin)) AS pvt
			PIVOT (MAX(sub_counterparty_id) FOR sub_source_code IN (SOURCE_CODE_ace, SOURCE_CODE_lei, SOURCE_CODE_bic, SOURCE_CODE_eic, SOURCE_CODE_gin)) AS pvt2
			PIVOT (MAX(deal_counterparty_id) FOR deal_source_code IN (DEAL_SOURCE_CODE_ace, DEAL_SOURCE_CODE_lei, DEAL_SOURCE_CODE_bic, DEAL_SOURCE_CODE_eic, DEAL_SOURCE_CODE_gin)) AS pvt3

			SELECT @trade_list = (
				SELECT -- according to generated sample by xsd
					   ROW_NUMBER() OVER(ORDER BY [Action_type]) AS RecordSeqNumber,
					   SOURCE_CODE_ace AS [idOfMarketParticipant/ace],
					   SOURCE_CODE_lei AS [idOfMarketParticipant/lei], 
					   SOURCE_CODE_bic AS [idOfMarketParticipant/bic],
					   SOURCE_CODE_eic AS [idOfMarketParticipant/eic],
					   SOURCE_CODE_gin AS [idOfMarketParticipant/gin],
					   [trader_id_market_participant] AS [traderID/traderIdForMarketParticipant],
					   DEAL_SOURCE_CODE_ace AS [otherMarketParticipant/ace],
					   DEAL_SOURCE_CODE_lei AS [otherMarketParticipant/lei],
					   DEAL_SOURCE_CODE_bic AS [otherMarketParticipant/bic],
					   DEAL_SOURCE_CODE_eic AS [otherMarketParticipant/eic],
					   DEAL_SOURCE_CODE_gin AS [otherMarketParticipant/gin],
					   [beneficiary_id] AS [beneficiaryIdentification],
					   [trading_capacity_market_participant] AS [tradingCapacity],
					   [buy_sell_indicator] AS [buySellIndicator],
					   [initiator_aggressor] AS [aggressor],
					   [order_type] AS [clickAndTradeDetails/orderType],
					   [order_condition] AS [clickAndTradeDetails/orderCondition],
					   [order_status] AS [clickAndTradeDetails/orderStatus],
					   [minimum_execution_volume] AS [clickAndTradeDetails/minimumExecuteVolume/value],
					   NULL AS [clickAndTradeDetails/minimumExecuteVolume/unit],
					   [price_limit] AS [clickAndTradeDetails/triggerDetails/priceLimit/value],
					   NULL AS [clickAndTradeDetails/triggerDetails/priceLimit/currency],
					   NULL AS [clickAndTradeDetails/triggerDetails/triggerContractId],
					   undisclosed_volume AS [clickAndTradeDetails/undisclosedVolume/value],
					   NULL AS [clickAndTradeDetails/undisclosedVolume/unit],
					   [order_duration] AS [clickAndTradeDetails/orderDuration/duration],
					   NULL AS [clickAndTradeDetails/orderDuration/expirationDateTime],
					   srs.[source_deal_header_id] AS [contractInfo/contract/contractId],
					   [contract_name] AS [contractInfo/contract/contractName],
					   [contract_type] AS [contractInfo/contract/contractType],
					   [energy_commodity] AS [contractInfo/contract/energyCommodity],
					   [settlement_method] AS [contractInfo/contract/settlementMethod],
					   [organised_market_place_id_otc] AS [contractInfo/contract/organisedMarketPlaceIdentifier/bil],
					   [delivery_point_or_zone] AS [contractInfo/contract/deliveryPointOrZone],
					   CONVERT(char(10), [delivery_start_date],126) AS [contractInfo/contract/deliveryStartDate],
					   CONVERT(char(10), [delivery_end_date],126) AS [contractInfo/contract/deliveryEndDate],
					   dbo.FNATimeWithLeadingZero(RTRIM(LEFT([load_delivery_intervals], 5))) [contractInfo/contract/deliveryProfile/loadDeliveryStartTime],
					   dbo.FNATimeWithLeadingZero(LTRIM(RIGHT([load_delivery_intervals], 5))) [contractInfo/contract/deliveryProfile/loadDeliveryEndTime],
					   [organised_market_place_id_otc] AS [organisedMarketPlaceIdentifier/bil],
					   [transaction_timestamp] AS [transactionTime],
					   --[transaction_timestamp] AS [executionTime],
					   [unique_transaction_id]  AS [uniqueTransactionIdentifier/uniqueTransactionIdentifier],
					   [linked_transaction_id] AS [linkedTransactionId],
					   [linked_order_id] AS [linkedOrderId],
					   [voice_brokered] AS [voiceBrokered],
					   [price] AS [priceDetails/price],
					   [price_currency] AS [priceDetails/priceCurrency],
					   [notional_amount] AS [notionalAmountDetails/notionalAmount],
					   [notional_currency] AS [notionalAmountDetails/notionalCurrency],
					   [quantity_volume] AS [quantity/value],
					   CASE WHEN [quantity_volume] IS NOT NULL THEN SUBSTRING(quantity_unit_field_40_and_41, 0, CHARINDEX(' /', quantity_unit_field_40_and_41, 0)) ELSE NULL END AS [quantity/unit],
					   [total_notional_contract_quantity] AS [totalNotionalContractQuantity/value],
					   CASE WHEN [quantity_unit_field_40_and_41] = 'MW / MWh' THEN 'MWh' ELSE [quantity_unit_field_40_and_41] END AS [totalNotionalContractQuantity/unit],
					   [termination_date] AS [terminationDate],
					   [action_type] AS [actionType],
					   NULL AS [Extra]
				FROM source_remit_standard srs
				INNER JOIN #temp_source_remit_standard_pvt2  tsrsp
					ON tsrsp.source_deal_header_id = srs.source_deal_header_id
					AND tsrsp.id1 = srs.id1
				WHERE process_id = @process_id
				FOR XML PATH ('TradeReport'), Root('TradeList'), TYPE)
					
		----Xml export of selected row
			;WITH XMLNAMESPACES (
				'http://www.w3.org/2001/XMLSchema-instance' AS xsi,
				'http://www.acer.europa.eu/REMIT/REMITTable1_V2.xsd' AS ns1
			)
			SELECT @xml_inner = ( 
				SELECT ace AS [reportingEntityID/ace],
					   lei AS [reportingEntityID/lei],
					   bic AS [reportingEntityID/bic],
					   eic AS [reportingEntityID/eic],
					   gin AS [reportingEntityID/gin],
					   @trade_list
				FROM (
					SELECT TOP 1 ISNULL([reporting_entity_id], '') AS RRM,
						   ISNULL([type_of_code_field_6], '') AS RRM_ID,
						   [market_id_participant_counterparty] AS sub_counterparty_id,
						   'SOURCE_CODE_' + [type_of_code_field_1]  AS sub_source_code,
						   [other_id_market_participant_counterparty] AS deal_counterparty_id,
						   'DEAL_SOURCE_CODE_' + [type_of_code_field_4] AS deal_source_code,
						   [beneficiary_id] AS beneficiaryIdentification,
						   [type_of_code_field_8] AS type_of_code_used_in_field_8
					FROM source_remit_standard
					WHERE process_id = @process_id
				) AS s
				PIVOT (MAX(RRM) FOR RRM_ID IN (ace, lei, bic, eic, gin)) AS pvt
				PIVOT (MAX(sub_counterparty_id) FOR sub_source_code IN (SOURCE_CODE_ace, SOURCE_CODE_lei, SOURCE_CODE_bic, SOURCE_CODE_eic, SOURCE_CODE_gin)) AS pvt2
				PIVOT (MAX(deal_counterparty_id) FOR deal_source_code IN (DEAL_SOURCE_CODE_ace, DEAL_SOURCE_CODE_lei, DEAL_SOURCE_CODE_bic, DEAL_SOURCE_CODE_eic, DEAL_SOURCE_CODE_gin)) AS pvt3
				FOR XML PATH('REMITTable1'), TYPE
			)

			--SELECT @xml_inner = CONVERT(XML, REPLACE(CONVERT(VARCHAR(MAX), @xml_inner), 'xmlns:ns2', 'xmlns'))
			--SELECT @xml_inner = CONVERT(XML, REPLACE(CONVERT(VARCHAR(MAX), @xml_inner), 'xmlns:ns1', 'xmlns'))
			--SELECT @xml_outer = (SELECT @xml_inner 	FOR XML PATH('RemitReport'), TYPE) 
		
			--SET @addxml = '<?xml version="1.0" encoding="UTF-8"?>'

			--;WITH XMLNAMESPACES (
			--	'http://Essent/REM/Remit' AS ns2,
			--	'http://www.w3.org/2001/XMLSchema' AS xsd ,
			--	'http://www.w3.org/2001/XMLSchema-instance' AS xsi
			--)
			--SELECT @xml = (
			--	SELECT TOP 1
			--		   'TRMTracker' [Creator],
			--		   'Remit_XML_Report_' + REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), @as_of_date, 120), ':', ''), ' ', '_'), '-', '_') + '.xml' AS [Reference], --filename
			--		   GETDATE() AS [CreationDateTime],
			--		   process_id AS [TransmissionID],
			--		   CASE WHEN @mirror_reporting = 1 THEN 'true' ELSE 'false' END [MirrorReporting],
			--		   'false' [DelegatedReporting],
			--		   CASE WHEN @intragroup = 1 THEN 'true' ELSE 'false' END [Intragroup],
			--		   CASE WHEN @generate_uti = 1 THEN 'true' ELSE 'false' END [GenerateUTI],
			--		   @xml_outer
			--	FROM source_remit_standard srs 
			--	WHERE process_id = @process_id
			--	FOR XML PATH('REMRemit'), TYPE
			--)

			SELECT @xml = @xml_inner
			SELECT @xml = CONVERT(XML, REPLACE(CONVERT(VARCHAR(MAX), @xml), 'xmlns:ns2', 'xmlns'))
			SELECT @xml = CONVERT(XML, REPLACE(CONVERT(VARCHAR(MAX), @xml), 'xmlns:ns1', 'xmlns'))
	 		SELECT @source = @xml
			SELECT @xml_string = @addxml + CAST(@xml AS VARCHAR(MAX))
			SET @file_name = 'remit_execution_' + @process_id + '_' + CONVERT(VARCHAR(7), GETDATE(), 112) + '.xml'
			SET @full_file_path = @file_path + @file_name
			EXEC [spa_write_to_file] @xml_string, 'n',  @full_file_path, @result OUTPUT
			IF @result = '1'
			BEGIN
				UPDATE source_remit_standard
				SET file_export_name = @file_name
					,acer_submission_status =39501
				WHERE process_id = @process_id
				IF @file_transfer_endpoint_id IS NOT NULL
				BEGIN
					EXEC spa_upload_file_to_ftp_using_clr @file_transfer_endpoint_id, @remote_directory, @full_file_path, @result OUTPUT
				END
			END
			RETURN
		END
		ELSE IF @report_type = 39402
        BEGIN
			--Starts Remit Transport xml generation code
			SET @addxml = '<?xml version="1.0" encoding="UTF-8"?>'

            ;WITH XMLNAMESPACES(				
                'urn:easee-gas.eu:edigas:remit:gascapacityallocationsdocument:5:1' AS ns1
            )
            SELECT @xml = (
				SELECT '23X--121101ESPMJ_' + CAST(source_deal_header_id AS VARCHAR(20)) AS identification,
					   CASE WHEN t.xml_version IS NULL THEN  ISNULL(rs.xml_version, 0) + 1 ELSE  rs.xml_version END AS [version],
					   'ANI' AS [type],
					   CONVERT(VARCHAR(22), GETDATE(), 127) + 'Z' AS [CreationDateTime],
					   (CONVERT(VARCHAR(10),[start_date_and_time],120)  + 'T06:00Z' + '/' + CONVERT(VARCHAR(10),dateadd(Day,1,[end_date_and_time]), 120) + 'T05:59Z') AS validityPeriod,
					   ISNULL([market_participant_identification], '') AS [issuer_MarketParticipant.identification],
					   'ZUF' AS [issuer_MarketParticipant.marketRole.code],
					   '10X1001B1001B61Q' AS [receiver_MarketParticipant.identification],
					   'ZUA' AS [receiver_MarketParticipant.marketRole.code],
					   ISNULL([organised_market_place_id], '') AS [organisedMarketPlace_MarketParticipant.identification],
					   ISNULL(currency, '') AS [currency.code],
					   ISNULL([measure_unit], '') AS [quantity_MeasureUnit.code],
					   ISNULL(process_identification, '') AS [process_Transaction.identification],
					   ISNULL(transportation_transaction_type, '') AS [process_Transaction.type],
					   ISNULL(network_point_identification, '') AS [process_Transaction.connectionPoint.identification],
					   ISNULL(tso1_identification, '') AS [process_Transaction.responsibleTso_MarketParticipant.identification],
					   ISNULL(tso2_identification, '') AS [process_Transaction.adjacentTso_MarketParticipant.identification],
					   ISNULL([creation_date_and_time], '') AS [process_Transaction.transaction_DateTime.dateTime],
					   ISNULL([action_type], '') AS [process_Transaction.action_Status.code],
					   ISNULL(procedure_applicable, '') AS [process_Transaction.secondaryMarket_Procedure.code],
					   ISNULL([transportation_transaction_identification], '') AS [Transportation_Transaction/identification],
					   '23X--121101ESPMJ' AS [Transportation_Transaction/primary_MarketParticipant.identification],
					   '11XRWETRADING--0' AS [Transportation_Transaction/transferor_MarketParticipant.identification],
					   ISNULL([transferee_identification], '') AS [Transportation_Transaction/transferee_MarketParticipant.identification],
					   (CONVERT(VARCHAR(10),[start_date_and_time],120) + 'T06:00Z' + '/' + CONVERT(VARCHAR(10),dateadd(Day,1,[end_date_and_time]), 120) + 'T05:59Z') AS [Transportation_Transaction/Transportation_Period/timeInterval],
					   ISNULL(direction, '') AS [Transportation_Transaction/Transportation_Period/direction.code],
					   dbo.FNARemoveTrailingZero([quantity]) AS [Transportation_Transaction/Transportation_Period/contract_Quantity.amount],
					   dbo.FNARemoveTrailingZero([total_price]) AS [Transportation_Transaction/Transportation_Period/total_Price.amount],
					   0 AS [Transportation_Transaction/Transportation_Period/transfer_Price.amount],
					   dbo.FNARemoveTrailingZero([price_paid_to_tso]) AS [Transportation_Transaction/Transportation_Period/underlyingtso_Price.amount]
				FROM source_remit_transport t
				CROSS APPLY (
					SELECT MAX(xml_version) xml_version 
					FROM source_remit_transport 
					WHERE source_deal_header_id = t.source_deal_header_id
				) rs
				WHERE process_id = @process_id
				FOR XML PATH('GasCapacityAllcations_Document'), TYPE
			) 
         	
			IF @xml IS NOT NULL
			BEGIN
				DECLARE @codingSchema INT = 305,
						@release INT = 1

				SET @XML.modify('insert attribute codingSchema {sql:variable("@codingSchema")} into (/GasCapacityAllcations_Document/issuer_MarketParticipant.identification)[1]')
				SET @XML.modify('insert attribute codingSchema {sql:variable("@codingSchema")} into (/GasCapacityAllcations_Document/receiver_MarketParticipant.identification)[1]')
				SET @XML.modify('insert attribute codingSchema {sql:variable("@codingSchema")} into (/GasCapacityAllcations_Document/organisedMarketPlace_MarketParticipant.identification)[1]')
				SET @XML.modify('insert attribute codingSchema {sql:variable("@codingSchema")} into (/GasCapacityAllcations_Document/process_Transaction.connectionPoint.identification)[1]')
				SET @XML.modify('insert attribute codingSchema {sql:variable("@codingSchema")} into (/GasCapacityAllcations_Document/process_Transaction.responsibleTso_MarketParticipant.identification)[1]')
				SET @XML.modify('insert attribute codingSchema {sql:variable("@codingSchema")} into (/GasCapacityAllcations_Document/process_Transaction.adjacentTso_MarketParticipant.identification)[1]')
				SET @XML.modify('insert attribute codingSchema {sql:variable("@codingSchema")} into (/GasCapacityAllcations_Document/Transportation_Transaction/transferor_MarketParticipant.identification)[1]')
				SET @XML.modify('insert attribute codingSchema {sql:variable("@codingSchema")} into (/GasCapacityAllcations_Document/Transportation_Transaction/primary_MarketParticipant.identification)[1]')
				SET @XML.modify('insert attribute codingSchema {sql:variable("@codingSchema")} into (/GasCapacityAllcations_Document/Transportation_Transaction/transferee_MarketParticipant.identification)[1]')
				SET @XML.modify('insert attribute release {sql:variable("@release")} into (/GasCapacityAllcations_Document)[1]')			
			END			

			SELECT @xml = CONVERT(XML, REPLACE(CONVERT(VARCHAR(MAX), @xml), 'xmlns:ns1', 'xmlns'))
			SELECT @xml = CONVERT(XML, REPLACE(CONVERT(VARCHAR(MAX), @xml), 'xmlns:ns2', 'xmlns'))

	 		SELECT @source = @xml 
			-- Ends Remit Transport xml generation code
            RETURN
        END
	END
END

IF @flag = 'i'--To generate new REMIT report
BEGIN
    DECLARE @_cpty_udf_cpty_id VARCHAR(100) = 'Counterparty ID',
			@_cpty_udf_source_code VARCHAR(100) = 'Source Code',
			@_deal_udf_src_class_field_id VARCHAR(100) = -5561,
			@_deal_udf_frcst_grp_field_id VARCHAR(100) = -5581,
			@_deal_udf_UTI VARCHAR(100) = 'UTI',
			@_cpty_udf_tab_name VARCHAR(100) = 'Remit',
            @err_msg VARCHAR(200) = ''
           
    CREATE TABLE #temp_deals (
        source_deal_header_id INT,
        deal_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
        template_id INT,
        counterparty_id INT,
        sub_book_id INT,
        deal_date DATETIME,
        physical_financial_flag CHAR(10) COLLATE DATABASE_DEFAULT,
        entire_term_start DATETIME,
        entire_term_end DATETIME,
        source_deal_type_id INT,
        deal_sub_type_type_id INT,
        option_flag CHAR(1) COLLATE DATABASE_DEFAULT,
        option_type CHAR(1) COLLATE DATABASE_DEFAULT,
        option_excercise_type CHAR(1) COLLATE DATABASE_DEFAULT,
        header_buy_sell_flag VARCHAR(1) COLLATE DATABASE_DEFAULT,
        create_ts DATETIME,
        update_ts DATETIME,
        internal_desk_id INT,
        product_id INT,
        commodity_id INT,
        block_define_id INT,
        deal_status INT,
        description1 VARCHAR(260) COLLATE DATABASE_DEFAULT,
        description2 VARCHAR(260) COLLATE DATABASE_DEFAULT,
		trader_id INT,
		contract_id INT,
		deal_group_id INT,
		ext_deal_id VARCHAR(512) COLLATE DATABASE_DEFAULT,
		confirm_status VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		[commodity_name] VARCHAR(1000) COLLATE DATABASE_DEFAULT
    )

	EXEC ('
		INSERT INTO #temp_deals
		SELECT * FROM ' + @deal_header_table_name + '
	')
	
	/************************************* Deal validation starts********************************************************/
	BEGIN
		DECLARE @validate_deal_log VARCHAR(100),
				@log_process_id VARCHAR(50) = dbo.FNAGetNewID()
        
		SET @validate_deal_log = dbo.FNAProcessTableName('collect_submitted_deals', dbo.FNADBUser(), @log_process_id) 
        
		IF OBJECT_ID('tempdb..#collect_submitted_deals') IS NOT NULL
			DROP TABLE #collect_submitted_deals
        
		CREATE TABLE #collect_submitted_deals (
        	source_deal_header_id INT,
        	allow_insert BIT
		)
		
		--As Standard Execution are submitted per month so submission check should not be done			    
		IF (@cancellation = 0)
		BEGIN   
			SET @sql2 = '
				INSERT INTO #collect_submitted_deals(source_deal_header_id, allow_insert)
				SELECT sdh.source_deal_header_id,
					  CASE WHEN MAX(src_remit.source_deal_header_id) IS NULL THEN 1
					       WHEN MAX(sdha.update_ts) IS NOT NULL AND MAX(sdha.update_ts) > MAX(src_remit.create_ts) THEN 1
					       WHEN MAX(submission_status.status) = 39502 THEN 0
					  ELSE 1
				END allow_insert
				FROM #temp_deals sdh
				LEFT JOIN source_deal_header_audit sdha ON sdha.source_deal_header_id = sdh.source_deal_header_id
				LEFT JOIN ' + @phy_remit_table_name + ' src_remit ON src_remit.source_deal_header_id = sdh.source_deal_header_id
				OUTER APPLY (SELECT TOP 1 acer_submission_status [status]
					 FROM source_remit_non_standard
					 WHERE source_deal_header_id = sdh.source_deal_header_id
					 AND acer_submission_status = 39502
					 ORDER BY create_ts
					 DESC
				) submission_status
				WHERE ISNULL(src_remit.report_type, 0) <> 39405 ---ignoring standard execution report type
					AND ISNULL(acer_submission_status, 0) NOT IN (39500) ---excluding outstanding
				GROUP BY sdh.source_deal_header_id
			'
        
			EXEC (@sql2)
		END
	
		IF EXISTS (SELECT 1 FROM #collect_submitted_deals WHERE allow_insert = 0) AND
		   EXISTS (SELECT 1 FROM #collect_submitted_deals WHERE allow_insert = 1)
		BEGIN
			SET @err_msg = 'Few deal(s) are already submitted. Only remaining deals will be submitted.'
			EXEC spa_ErrorHandler -1, 'Source Remit table', 'spa_remit', 'Error', @err_msg, 'Success'
		END
		
		IF EXISTS (SELECT 1 FROM #collect_submitted_deals WHERE allow_insert = 0) AND
		   NOT EXISTS (SELECT 1 FROM #collect_submitted_deals WHERE allow_insert = 1)
		BEGIN
			SET @err_msg = 'Selected deal(s) are already submitted.'
			EXEC spa_ErrorHandler -1, 'Source Remit table', 'spa_remit', 'Error', @err_msg, 'Error'
			RETURN
		END
		
		DELETE td
		FROM #temp_deals td
		INNER JOIN #collect_submitted_deals csd ON td.source_deal_header_id = csd.source_deal_header_id
		WHERE allow_insert = 0
	END        
    /************************************* Deal validation ends********************************************************/   
    
	CREATE TABLE #temp_deal_details (
		[source_deal_header_id] INT NULL,
		[source_deal_detail_id] INT NULL,
		[term_start] DATETIME NOT NULL,
		[term_end] DATETIME NOT NULL,
		[leg] INT NOT NULL,
		[fixed_float_leg] CHAR(1) COLLATE DATABASE_DEFAULT NOT NULL,
		[buy_sell_flag] CHAR(1) COLLATE DATABASE_DEFAULT NOT NULL,
		[curve_id] INT NULL,
		[location_id] INT NULL,
		[physical_financial_flag] CHAR(1) COLLATE DATABASE_DEFAULT NULL,
		[deal_volume] NUMERIC(38, 20) NULL,
		[total_volume] NUMERIC(38, 20) NULL,
		[standard_yearly_volume] NUMERIC(22, 8) NULL,
		[deal_volume_frequency] CHAR(1) COLLATE DATABASE_DEFAULT NOT NULL,
		[deal_volume_uom_id] INT NOT NULL,
		[multiplier] NUMERIC(38, 20) NULL,
		[volume_multiplier2] NUMERIC(38, 20) NULL,
		[fixed_price] NUMERIC(38, 20) NULL,
		[fixed_price_currency_id] INT NULL,
		[option_strike_price] NUMERIC(38, 20) NULL,
		[fixed_cost] NUMERIC(38, 20) NULL,
		[formula_id] INT NULL,
		[formula_curve_id] INT NULL,
		[price_adder] NUMERIC(38, 20) NULL,
		[price_multiplier] NUMERIC(38, 20) NULL,
		[adder_currency_id] INT NULL,
		[fixed_cost_currency_id] INT NULL,
		[formula_currency_id] INT NULL,
		[price_adder2] NUMERIC(38, 20) NULL,
		[price_adder_currency2] INT NULL,
		[price_uom_id] INT NULL,
		[contract_expiration_date] DATETIME,
		position_uom INT NULL
	)
	
	EXEC ('
		INSERT INTO #temp_deal_details
		SELECT * FROM ' + @deal_detail_table_name + '
	')

	/*************************************Counterparty UDF Values START********************************************************/
    DECLARE @_cpty_udf_source_code_sql VARCHAR(5000)

    SELECT @_cpty_udf_source_code_sql = a.sql_string
    FROM [user_defined_fields_template] a
    WHERE field_id = -5616

    CREATE TABLE #temp_source_code_map (
        value_id VARCHAR(150) COLLATE DATABASE_DEFAULT,
        code VARCHAR(150) COLLATE DATABASE_DEFAULT
    )
		
    IF @_cpty_udf_source_code_sql IS NOT NULL
    BEGIN
        INSERT INTO #temp_source_code_map (value_id, code)
        EXEC [dbo].[spa_execute_query] @_cpty_udf_source_code_sql
    END
		
    DECLARE @_pivot_header VARCHAR(1000) = '[Sub Code], [Sub Code Type], [Deal Code], [Deal Code Type]'
        	
    CREATE TABLE #temp_cpty_udf_values (
        source_deal_header_id INT,
        [Sub Code] VARCHAR(150) COLLATE DATABASE_DEFAULT,
        [Sub Code Type] VARCHAR(150) COLLATE DATABASE_DEFAULT,
        [Deal Code] VARCHAR(150) COLLATE DATABASE_DEFAULT,
        [Deal Code Type] VARCHAR(150) COLLATE DATABASE_DEFAULT
    )
        	
    SET @_sql = '
		INSERT INTO #temp_cpty_udf_values (
			source_deal_header_id, [Sub Code], [Sub Code Type], [Deal Code], [Deal Code Type]
		)
		SELECT source_deal_header_id,
				[Sub Code],
				(CASE WHEN [Sub Code Type] = ''ACER'' THEN ''ACE'' ELSE [Sub Code Type] END) [Sub Code Type],
				[Deal Code],
				(CASE WHEN [Deal Code Type] = ''ACER'' THEN ''ACE'' ELSE [Deal Code Type] END) [Deal Code Type] 
		FROM (
			SELECT cpty.source_deal_header_id,
					CASE cpty.cpty_type WHEN 1 THEN ''Sub '' ELSE ''Deal '' END + ISNULL(udft.field_label, '''') field_label,
					ISNULL(NULLIF(tscm.code, ''NULL''), NULLIF(musddv.static_data_udf_values, ''NULL'')) udf_values
			FROM (
				SELECT td.source_deal_header_id,
						fs.counterparty_id,
						1 cpty_type
				FROM #temp_deals td
				INNER JOIN ' + @ssbm_table_name + ' book ON td.sub_book_id = book.sub_book_id
				INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = book.sub_id
				UNION
				SELECT td.source_deal_header_id, td.counterparty_id, 2 cpty_type
				FROM #temp_deals td
			) cpty
			INNER JOIN maintain_udf_static_data_detail_values musddv
				ON musddv.primary_field_object_id = cpty.counterparty_id
			INNER JOIN application_ui_template_fields autf
				ON autf.application_field_id = musddv.application_field_id
			INNER JOIN user_defined_fields_template udft
				ON udft.udf_template_id = autf.udf_template_id
			LEFT JOIN #temp_source_code_map tscm ON tscm.value_id = musddv.static_data_udf_values
				AND udft.field_label = ''' + @_cpty_udf_source_code + '''
		) rs
		PIVOT (MAX(udf_values) FOR field_label IN (' + @_pivot_header + ')) pvt											
	'
	--PRINT @_sql
	EXEC (@_sql)

	IF OBJECT_ID('tempdb..#temp_deal_udf_values') IS NOT NULL
		DROP TABLE #temp_deal_udf_values

	CREATE TABLE #temp_deal_udf_values (
		[source_deal_header_id] INT, 
		[Brent Weight] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Brent Base Value] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[API2 Weight] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[API2 Base Value] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[D35 Weight] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[D35 Base Value] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Price Formula] VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[Trayport Date Time] VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[Execution Timestamp] VARCHAR(500) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #temp_deal_udf_values (source_deal_header_id, [Brent Weight], [Brent Base Value], [API2 Weight], [API2 Base Value], [D35 Weight], [D35 Base Value],[Price Formula], [Trayport Date Time], [Execution Timestamp])
	SELECT source_deal_header_id, [Brent Weight], [Brent Base Value], [API2 Weight], [API2 Base Value], [D35 Weight], [D35 Base Value], [Price Formula], [Trayport Date Time], [Execution Timestamp]
	FROM (
		SELECT sdh.source_deal_header_id, udft.field_label, uddf.udf_value
		FROM #temp_deals sdh
		INNER JOIN #temp_deal_details sdd
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN user_defined_deal_fields uddf
			ON uddf.source_deal_header_id = sdh.source_deal_header_id
				AND NULLIF(uddf.udf_value, '') IS NOT NULL
		INNER JOIN user_defined_deal_fields_template uddft
			ON uddft.udf_template_id = uddf.udf_template_id
		INNER JOIN user_defined_fields_template udft
			ON udft.field_id = uddft.field_id
		) AS a
	PIVOT (MAX(a.udf_value) FOR a.Field_label IN ([Brent Weight], [Brent Base Value], [API2 Weight], [API2 Base Value], [D35 Weight], [D35 Base Value], [Price Formula], [Trayport Date Time],[Execution Timestamp])) AS p
		
	/*************************************Counterparty UDF Values END********************************************************/
        		
    /****pre volume and price columns starts*****/
        	
    IF OBJECT_ID('tempdb..#temp_vol') IS NOT NULL
        DROP TABLE #temp_vol
        	
    IF OBJECT_ID('tempdb..#temp_vol_final') IS NOT NULL
        DROP TABLE #temp_vol_final
        	
    IF OBJECT_ID('tempdb..#temp_fixing') IS NOT NULL
        DROP TABLE #temp_fixing
        	
    IF OBJECT_ID('tempdb..#temp_fixing1') IS NOT NULL
        DROP TABLE #temp_fixing1
        	
    IF OBJECT_ID('tempdb..#temp_fixing2') IS NOT NULL
        DROP TABLE #temp_fixing2
        	
    IF OBJECT_ID('tempdb..#temp_vol_final') IS NOT NULL
        DROP TABLE #temp_vol_final
        	
    IF OBJECT_ID('tempdb..#temp_vol_final1') IS NOT NULL
        DROP TABLE #temp_vol_final1
        	
    IF OBJECT_ID('tempdb..#temp_vol_final2') IS NOT NULL
        DROP TABLE #temp_vol_final2
    		
   	IF OBJECT_ID('tempdb..#udf_on_off_peak_value') IS NOT NULL
        DROP TABLE #udf_on_off_peak_value	
				
				
	CREATE TABLE #udf_on_off_peak_value (
		source_deal_header_id INT, 
		udf_value NUMERIC(20, 5), 
		On_off char
	)
		
	INSERT INTO #udf_on_off_peak_value
	SELECT uddf.source_deal_header_id,
			SUM(CAST(uddf.udf_value AS NUMERIC(20, 5))),
			CASE 
				WHEN uddft.field_label LIKE '%OnPeak%' THEN 'o' 
				WHEN uddft.field_label LIKE '%OffPeak%' THEN 'f'
				ELSE NULL
			END On_off
	FROM user_defined_deal_fields_template uddft
	INNER JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id
	INNER JOIN #temp_deals tdd ON tdd.source_deal_header_id = uddf.source_deal_header_id 
	WHERE uddft.internal_field_type IN (18715, 18710, 18705, 18700)
		AND ISNUMERIC(uddf.udf_value) = 1
	GROUP BY uddf.source_deal_header_id,
				CASE
				WHEN uddft.field_label LIKE '%OnPeak%' THEN 'o'
				WHEN uddft.field_label LIKE '%OffPeak%' THEN 'f'
				ELSE NULL
				END
		
	SELECT tdd.source_deal_header_id,
			tdd.curve_id,
        	tdd.buy_sell_flag,
        	SUM(tdd.deal_volume)      deal_volume,
        	MAX(standard_yearly_volume) standard_yearly_volume,
        	SUM(tdd.total_volume)     total_volume,
        	MAX(deal_volume_frequency) deal_volume_frequency,
        	MAX(deal_volume_uom_id) deal_volume_uom_id,
        	MAX(internal_desk_id)     internal_desk_id,
        	MAX(product_id)           product_id,
        	AVG(fixed_price)          fixed_price,
        	MAX(fixed_price_currency_id) fixed_price_currency_id,
        	MAX(price_uom_Id) price_uom_Id
    INTO #temp_vol
    FROM #temp_deals td
	INNER JOIN #temp_deal_details tdd ON td.source_deal_header_id = tdd.source_deal_header_id
	GROUP BY tdd.source_deal_header_id, tdd.curve_id, tdd.buy_sell_flag
        	
    CREATE TABLE #temp_vol_final (
        source_deal_header_id INT,
        curve_id INT,
        total_notional_contract_quantity NUMERIC(20, 5),
        notional_quantity_unit INT,
        Volume_optionality VARCHAR(1) COLLATE DATABASE_DEFAULT,
        estimated_notional_amount NUMERIC(20, 5),
        notional_currency INT,
        price_uom_id INT,
        fixed_price NUMERIC(20, 5)
    )
		
	INSERT INTO #temp_vol_final (
		source_deal_header_id, curve_id, total_notional_contract_quantity, notional_quantity_unit,
		volume_optionality, notional_currency, price_uom_id, fixed_price
	)
	SELECT tv.source_deal_header_id, tv.curve_id,
			ROUND(
			CASE WHEN MAX(ISNULL(internal_desk_id, 17300)) = 17300 THEN SUM(total_volume)
					WHEN MAX(ISNULL(internal_desk_id, 17300)) = 17302 THEN SUM(CASE WHEN buy_sell_flag = 's' THEN total_volume * -1 ELSE total_volume END)
					ELSE ISNULL(NULLIF(SUM(deal_volume), 0), SUM(total_volume))
			END, 5
			) AS [total_notional_contract_quantity],
			CASE WHEN MAX(ISNULL(internal_desk_id, 17300)) IN (17300, 17302) THEN COALESCE(MAX(spcd.display_uom_id), MAX(spcd.uom_id), MAX(tv.deal_volume_uom_id))
				WHEN NULLIF(SUM(deal_volume), 0) IS NOT NULL THEN MAX(tv.deal_volume_uom_id)
				ELSE COALESCE(MAX(spcd.display_uom_id), MAX(spcd.uom_id), MAX(tv.deal_volume_uom_id))
			END [notional_quantity_unit],
			CASE WHEN MAX(ISNULL(internal_desk_id, 17300)) IN (17300, 17302) THEN 'F'
				WHEN MAX(ISNULL(internal_desk_id, 17300)) = 17301 THEN 'V'
				ELSE 'O'
			END [volume_optionality],
			MAX(fixed_price_currency_id) AS notional_currency,
			MAX(price_uom_Id)  AS price_uom_id,
			AVG(fixed_price) + AVG(ISNULL(uoopvv.udf_value, 0)) + AVG(ISNULL(uoopvv1.udf_value, 0))
	FROM #temp_vol tv
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tv.curve_id
	LEFT JOIN rec_volume_unit_conversion conv ON conv.FROM_source_uom_id = tv.price_uom_id
		AND conv.to_source_uom_id = tv.deal_volume_uom_id
	LEFT JOIN #udf_on_off_peak_value uoopvv ON uoopvv.source_deal_header_id = tv.source_deal_header_id
		AND spcd.curve_tou = 18900
		AND uoopvv.On_off = 'o'
	LEFT JOIN #udf_on_off_peak_value uoopvv1 ON uoopvv1.source_deal_header_id = tv.source_deal_header_id
		AND spcd.curve_tou = 18901
		AND uoopvv1.On_off = 'f'
	GROUP BY tv.source_deal_header_id, tv.curve_id
		
	SELECT source_deal_header_id, tvf.curve_id, total_notional_contract_quantity, notional_quantity_unit, volume_optionality, estimated_notional_amount,
		    CASE WHEN conv.conversion_factor <> 0 THEN ISNULL(1 / conv.conversion_factor, 1)
				ELSE 1
			END conversion_factor, notional_currency, fixed_price
	INTO #temp_vol_final1
	FROM #temp_vol_final tvf
	LEFT JOIN rec_volume_unit_conversion conv ON conv.FROM_source_uom_id = tvf.price_uom_id
		AND conv.to_source_uom_id = tvf.notional_quantity_unit

    SELECT tvf1.source_deal_header_id,
        	SUM(total_notional_contract_quantity) 
        	total_notional_contract_quantity,
        	MAX(notional_quantity_unit) notional_quantity_unit,
        	MAX(volume_optionality) volume_optionality,
        	SUM(total_notional_contract_quantity * (fixed_price + ISNULL(uoopv.udf_value,0))) AS estimated_notional_amount,
			SUM(total_notional_contract_quantity * deal_wa.weighted_average_price) AS estimated_notional_amount_wa_average,
			MAX(notional_currency) notional_currency,
			(CASE WHEN SUM(total_notional_contract_quantity) <> 0 THEN SUM(total_notional_contract_quantity * fixed_price) /  NULLIF(SUM(total_notional_contract_quantity),0) ELSE 0 END)+ MAX(ISNULL(uoopv.udf_value,0)) price
    INTO #temp_vol_final2
	FROM #temp_vol_final1 tvf1
	LEFT JOIN #udf_on_off_peak_value uoopv ON uoopv.source_deal_header_id = tvf1.source_deal_header_id
		AND uoopv.On_off IS NULL
	OUTER APPLY (
		SELECT CASE WHEN SUM(ISNULL(a.Volume, 0)) <> 0 THEN SUM(CASE WHEN sdd.buy_sell_flag = 'b' THEN ISNULL(a.volume, 0) ELSE  - ISNULL(a.volume, 0) END * (ISNULL(a.price, 0) + ISNULL(sdd.price_Adder, 0))) / NULLIF(SUM(ISNULL(CASE WHEN sdd.buy_sell_flag = 'b' THEN ISNULL(a.volume, 0) ELSE - ISNULL(a.volume, 0) END, 0)), 0)
					ELSE 0 
				END weighted_average_price
		FROM source_deal_detail_hour a
		INNER JOIN source_deal_detail sdd ON a.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE sdd.source_deal_header_id = tvf1.source_deal_header_id
	) deal_wa
	GROUP BY tvf1.source_deal_header_id
		
	/************Start Fixing curve logic ******************/        	
    SELECT DISTINCT 
			tdd.source_deal_header_id,
        	entire_term_start,
        	entire_term_end,
        	spcd.exp_calendar_id,
        	arg1 curve_id,
        	'Default-Curve' market_value_desc,--spcd.market_value_desc, TO DO: Build actual logic 
        	spcd.granularity,
        	arg3,
        	arg4,
        	arg5,
        	arg10 AS REBD
    INTO #temp_fixing
    FROM #temp_deal_details tdd
	INNER JOIN #temp_deals td ON tdd.source_deal_header_id = td.source_deal_header_id
	INNER JOIN formula_breakdown fb ON tdd.formula_id = fb.formula_id
	INNER JOIN source_price_curve_def spcd ON CASE WHEN fb.arg1 = 'NULL' THEN NULL ELSE fb.arg1 END = spcd.source_curve_def_id
    WHERE tdd.formula_id IS NOT NULL
		AND fb.func_name IN ('Curve15', 'CurveD', 'CurveH', 'CurveM', 'CurveY', 'LagCurve')
        	
    IF @report_type NOT IN (39402) --Skip this block for transport
    BEGIN
        INSERT INTO #temp_fixing
        SELECT DISTINCT
			   tdd.source_deal_header_id,
			   entire_term_start,
			   entire_term_end,
			   spcd.exp_calendar_id,
			   tdd.curve_id,
			   'Default-Curve' market_value_desc,--spcd.market_value_desc, TO DO: Build actual logic 
			   spcd.granularity,
			   NULL,
			   NULL,
			   NULL,
			   NULL
        FROM #temp_deal_details tdd
		INNER JOIN #temp_deals td ON tdd.source_deal_header_id = td.source_deal_header_id
		INNER JOIN source_price_curve_def spcd ON tdd.curve_id = spcd.source_curve_def_id
		WHERE td.physical_financial_flag = 'f'
			AND ISNULL(td.product_id, -1) <> 4100

        UPDATE #temp_fixing
        SET [REBD] = NULL
        WHERE [REBD] = 'NULL'
        	
        UPDATE #temp_fixing
        SET [REBD] = NULL
        WHERE [REBD] = ''
        	
        CREATE TABLE #temp_fixing1 (
        	[source_deal_header_id] INT,
        	[type_of_index_price] VARCHAR(1) COLLATE DATABASE_DEFAULT,
        	[fixing_index] VARCHAR(150) COLLATE DATABASE_DEFAULT,
        	[fixing_index_types] VARCHAR(2) COLLATE DATABASE_DEFAULT,
        	[fixing_index_sources] VARCHAR(100) COLLATE DATABASE_DEFAULT,
        	[first_fixing_date] DATETIME,
        	[last_fixing_date] DATETIME,
        	[fixing_frequency] VARCHAR(1) COLLATE DATABASE_DEFAULT
        )
        	
        INSERT INTO #temp_fixing1 (
			source_deal_header_id, [Type_of_index_price], [Fixing_index],
        	[Fixing_index_types], [Fixing_index_sources], [fixing_frequency]
        )
        SELECT tf.source_deal_header_id,
        	   CASE WHEN MAX(counttype.countcurve) = 1 THEN 'I' WHEN MAX(counttype.countcurve) > 1 THEN 'C' ELSE 'O' END AS [Type_of_index_price],
			   LEFT(tf.market_value_desc, CHARINDEX('-', tf.market_value_desc) - 1) AS [Fixing_index],
			   SUBSTRING(tf.market_value_desc, LEN(LEFT(tf.market_value_desc, CHARINDEX('-', market_value_desc) - 1)) + 2, 2) AS [Fixing_index_types],
			   RIGHT(tf.market_value_desc, LEN(tf.market_value_desc) - (LEN(LEFT(tf.market_value_desc, CHARINDEX('-', tf.market_value_desc) - 1)) + 4)) [Fixing_index_sources],
			   CASE MAX(sdv.code) WHEN '30Min' THEN 'X' WHEN 'Hourly' THEN 'H' WHEN 'Daily' THEN 'D' WHEN 'Weekly' THEN 'W' WHEN 'Monthly' THEN 'M' WHEN 'Quarterly' THEN 'Q' WHEN 'Semi-Annually' THEN 'S' WHEN 'Annually' THEN 'A' ELSE 'O' END AS [Fixing_frequency]
        FROM #temp_fixing tf
		LEFT JOIN static_data_value sdv ON sdv.value_id = tf.granularity
		LEFT JOIN (
			SELECT source_deal_header_id, COUNT(market_value_desc) countcurve
			FROM #temp_fixing
			GROUP BY source_deal_header_id
		) counttype ON counttype.source_deal_header_id = tf.source_deal_header_id
		GROUP BY tf.source_deal_header_id, LEFT(tf.market_value_desc, CHARINDEX('-', tf.market_value_desc) - 1), SUBSTRING(tf.market_value_desc, LEN(LEFT(tf.market_value_desc, CHARINDEX('-', market_value_desc) - 1)) + 2, 2), RIGHT(tf.market_value_desc, LEN(tf.market_value_desc) - (LEN(LEFT(tf.market_value_desc, CHARINDEX('-', tf.market_value_desc) - 1)) + 4))

		/****REDB starts*****/        	
		IF OBJECT_ID('tempdb..#date20') IS NOT NULL
        	DROP TABLE #date20	
        	
		IF OBJECT_ID('tempdb..#date21') IS NOT NULL
        	DROP TABLE #date21	
        	
		IF OBJECT_ID('tempdb..#date22') IS NOT NULL
        	DROP TABLE #date22 
        	
		SELECT ROW_NUMBER() OVER(ORDER BY exp_date) row_no,
        		tf.source_deal_header_id,
        		market_value_desc,
        		CAST(tf.REBD AS FLOAT) REBD,
        		hg.hol_group_value_id,
        		hg.exp_date,
        		hg.hol_date,
        		MAX(td.entire_term_start) entire_term_start,
        		MAX(td.entire_term_end) entire_term_end
		INTO #date20
		FROM holiday_group hg
		INNER JOIN #temp_fixing tf ON hg.hol_group_value_id = tf.exp_calendar_id
		INNER JOIN #temp_deals td ON tf.source_deal_header_id = td.source_deal_header_id
			AND hg.exp_date < td.entire_term_start
			AND hg.exp_date > DATEADD(YY, -1, td.entire_term_start)
		WHERE REBD IS NOT NULL
			AND MONTH(hg.exp_Date) IN (3, 6, 9, 12)
		GROUP BY tf.source_deal_header_id, market_value_desc, tf.REBD, hg.hol_group_value_id, hg.exp_date, hg.hol_date
        	
		SELECT DISTINCT
				source_deal_header_id,
        		entire_term_start,
        		market_value_desc,
        		MAX(REBD) REBD,
        		MAX(row_no) row_no,
        		MAX(exp_date) exp_date
		INTO #date21
		FROM #date20
		GROUP BY source_deal_header_id, entire_term_start, market_value_desc
		HAVING MAX(exp_date) <= entire_term_start
        	
		SELECT d21.source_deal_header_id,
        		d21.market_value_desc,
        		d20.exp_date
		INTO #date22
		FROM #date20 d20
		INNER JOIN (
			SELECT DISTINCT source_Deal_header_id, COUNT(market_value_desc) countmvd
			FROM #date21
			GROUP BY source_Deal_header_id
		) aaa ON d20.source_deal_header_id = aaa.source_deal_header_id
		INNER JOIN #date21 d21 ON d20.source_deal_header_id = d21.source_deal_header_id
			AND d20.market_value_desc = d21.market_value_desc
			AND d20.row_no = (d21.row_no - (ABS(d20.REBD) * countmvd))
        	
		UPDATE tf1
		SET tf1.first_fixing_date = d22.exp_date,
        	tf1.last_fixing_date = d22.exp_date
		FROM #temp_fixing1 tf1
		INNER JOIN #date22 d22 ON tf1.source_deal_header_id = d22.source_deal_header_id
		INNER JOIN #temp_fixing tf ON tf1.source_deal_header_id = tf.source_deal_header_id
			AND tf.market_value_desc = d22.market_value_desc

		/****REDB END*****/
        	
		---001 first_fixing_date
		UPDATE tf1
		SET tf1.first_fixing_date = aaa.exp_date
		FROM #temp_fixing1 tf1
		INNER JOIN (
			SELECT tf.source_deal_header_id, MIN(hg.exp_date) exp_date
			FROM #temp_fixing tf
			LEFT JOIN holiday_group hg ON tf.exp_calendar_id = hg.hol_group_value_id
				AND hg.hol_date = DATEADD(mm, DATEDIFF(mm, 0, tf.entire_term_start), 0)
			WHERE tf.arg3 = 0
				AND tf.arg4 = 0
				AND tf.arg5 = 1
			GROUP BY tf.source_deal_header_id
		) aaa ON tf1.source_deal_header_id = aaa.source_deal_header_id
		INNER JOIN #temp_fixing tf ON tf1.source_deal_header_id = tf.source_deal_header_id
		WHERE tf.arg3 = 0
			AND tf.arg4 = 0
			AND tf.arg5 = 1
			AND tf.REBD IS NULL        	
        	
        	---001 last_fixing_date
		UPDATE tf1
		SET tf1.last_fixing_date = aaa.exp_date
		FROM #temp_fixing1 tf1
		LEFT JOIN (
			SELECT tf.source_deal_header_id, MAX(hg.exp_date) exp_date
			FROM #temp_fixing tf
			LEFT JOIN holiday_group hg ON tf.exp_calendar_id = hg.hol_group_value_id
				AND hg.hol_date = DATEADD(mm, DATEDIFF(mm, 0, tf.entire_term_end), 0)
			WHERE tf.arg3 = 0
				AND tf.arg4 = 0
				AND tf.arg5 = 1
			GROUP BY tf.source_deal_header_id
		) aaa ON tf1.source_deal_header_id = aaa.source_deal_header_id
		INNER JOIN #temp_fixing tf ON tf1.source_deal_header_id = tf.source_deal_header_id
		WHERE tf.arg3 = 0
			AND tf.arg4 = 0
			AND tf.arg5 = 1
			AND tf.REBD IS NULL
        	
		---003 first_fixing_date
		UPDATE tf1
		SET tf1.first_fixing_date = aaa.exp_date
		FROM #temp_fixing1 tf1
		LEFT JOIN (
			SELECT tf.source_deal_header_id, MIN(hg.exp_date) exp_date
			FROM #temp_fixing tf
			LEFT JOIN holiday_group hg ON tf.exp_calendar_id = hg.hol_group_value_id
				AND hg.hol_date = DATEADD(qq, DATEDIFF(qq, 0, tf.entire_term_start), 0)
			WHERE tf.arg3 = 0
				AND tf.arg4 = 0
				AND tf.arg5 = 3
			GROUP BY tf.source_deal_header_id
		) aaa ON tf1.source_deal_header_id = aaa.source_deal_header_id
		INNER JOIN #temp_fixing tf ON tf1.source_deal_header_id = tf.source_deal_header_id
		WHERE tf.arg3 = 0
			AND tf.arg4 = 0
			AND tf.arg5 = 3
			AND tf.REBD IS NULL
        	
		---003 last_fixing_date
		UPDATE tf1
		SET tf1.last_fixing_date = aaa.exp_date
		FROM #temp_fixing1 tf1
		LEFT JOIN (
			SELECT tf.source_deal_header_id, MAX(hg.exp_date) exp_date
			FROM #temp_fixing tf
			LEFT JOIN holiday_group hg ON tf.exp_calendar_id = hg.hol_group_value_id
				AND hg.hol_date = DATEADD(qq, DATEDIFF(qq, 0, tf.entire_term_end), 0)
			WHERE tf.arg3 = 0
				AND tf.arg4 = 0
				AND tf.arg5 = 3
			GROUP BY tf.source_deal_header_id
		) aaa ON tf1.source_deal_header_id = aaa.source_deal_header_id
		INNER JOIN #temp_fixing tf ON tf1.source_deal_header_id = tf.source_deal_header_id
		WHERE tf.arg3 = 0
			AND tf.arg4 = 0
			AND tf.arg5 = 3
			AND tf.REBD IS NULL
        	
		---0012 first_fixing_date
		UPDATE tf1
		SET tf1.first_fixing_date = aaa.exp_date
		FROM #temp_fixing1 tf1
		LEFT JOIN (
			SELECT tf.source_deal_header_id, MIN(hg.exp_date) exp_date
			FROM #temp_fixing tf
			LEFT JOIN holiday_group hg ON tf.exp_calendar_id = hg.hol_group_value_id
				AND hg.hol_date = DATEADD(yy, DATEDIFF(yy, 0, tf.entire_term_start), 0)
			WHERE tf.arg3 = 0
        		AND tf.arg4 = 0
        		AND tf.arg5 = 12
			GROUP BY tf.source_deal_header_id
		) aaa ON tf1.source_deal_header_id = aaa.source_deal_header_id
		INNER JOIN #temp_fixing tf ON tf1.source_deal_header_id = tf.source_deal_header_id
		WHERE tf.arg3 = 0
			AND tf.arg4 = 0
			AND tf.arg5 = 12
			AND tf.REBD IS NULL
        	
		---0012 last_fixing_date
		UPDATE tf1
		SET tf1.last_fixing_date = aaa.exp_date
		FROM #temp_fixing1 tf1
		LEFT JOIN (
			SELECT tf.source_deal_header_id, MAX(hg.exp_date) exp_date
			FROM #temp_fixing tf
			LEFT JOIN holiday_group hg ON tf.exp_calendar_id = hg.hol_group_value_id
				AND hg.hol_date = DATEADD(yy, DATEDIFF(yy, 0, tf.entire_term_end), 0)
			WHERE tf.arg3 = 0
				AND tf.arg4 = 0
				AND tf.arg5 = 12
			GROUP BY tf.source_deal_header_id
		) aaa ON tf1.source_deal_header_id = aaa.source_deal_header_id
		INNER JOIN #temp_fixing tf ON tf1.source_deal_header_id = tf.source_deal_header_id
		WHERE tf.arg3 = 0
			AND tf.arg4 = 0
			AND tf.arg5 = 12
			AND tf.REBD IS NULL        	
        	
		---603 first_fixing_date
		UPDATE tf1
		SET tf1.first_fixing_date = aaa.exp_date
		FROM #temp_fixing1 tf1
		LEFT JOIN (
			SELECT tf.source_deal_header_id, MIN(hg.exp_date) exp_date
			FROM #temp_fixing tf 
			LEFT JOIN holiday_group hg ON tf.exp_calendar_id = hg.hol_group_value_id
			WHERE tf.arg3 = 6
				AND tf.arg4 = 0
				AND tf.arg5 = 3
				AND CONVERT(VARCHAR(07), hol_date, 120) = CONVERT(VARCHAR(07), DATEADD(mm, -6, tf.entire_term_start), 120)
			GROUP BY tf.source_deal_header_id
		) aaa ON tf1.source_deal_header_id = aaa.source_deal_header_id
		INNER JOIN #temp_fixing tf ON tf1.source_deal_header_id = tf.source_deal_header_id
		WHERE tf.arg3 = 6
			AND tf.arg4 = 0
			AND tf.arg5 = 3
			AND tf.REBD IS NULL
        	
		---603 last_fixing_date
		UPDATE tf1
		SET tf1.last_fixing_date = aaa.exp_date
		FROM #temp_fixing1 tf1
		LEFT JOIN (
			SELECT tf.source_deal_header_id, MAX(hg.exp_date) exp_date
			FROM #temp_fixing tf
			LEFT JOIN holiday_group hg ON tf.exp_calendar_id = hg.hol_group_value_id
			WHERE tf.arg3 = 6
        		AND tf.arg4 = 0
        		AND tf.arg5 = 3
        		AND CONVERT(VARCHAR(07), hol_date, 120) = CONVERT(VARCHAR(07), DATEADD(mm, -3, tf.entire_term_end), 120)
			GROUP BY tf.source_deal_header_id
		) aaa ON tf1.source_deal_header_id = aaa.source_deal_header_id
		INNER JOIN #temp_fixing tf ON tf1.source_deal_header_id = tf.source_deal_header_id
		WHERE tf.arg3 = 6
			AND tf.arg4 = 0
			AND tf.arg5 = 3
			AND tf.REBD IS NULL
        	
		---626 first_fixing_date
		UPDATE tf1
		SET tf1.first_fixing_date = aaa.exp_date
		FROM #temp_fixing1 tf1
		LEFT JOIN (
			SELECT tf.source_deal_header_id, MIN(hg.exp_date) exp_date
			FROM #temp_fixing tf
			LEFT JOIN holiday_group hg ON tf.exp_calendar_id = hg.hol_group_value_id
			WHERE tf.arg3 = 6
				AND tf.arg4 = 2
				AND tf.arg5 = 6
				AND CONVERT(VARCHAR(07), hol_date, 120) = CONVERT(VARCHAR(07), DATEADD(mm, -8, tf.entire_term_start), 120)
			GROUP BY tf.source_deal_header_id
		) aaa ON tf1.source_deal_header_id = aaa.source_deal_header_id
		INNER JOIN #temp_fixing tf ON tf1.source_deal_header_id = tf.source_deal_header_id
		WHERE tf.arg3 = 6
			AND tf.arg4 = 2
			AND tf.arg5 = 6
			AND tf.REBD IS NULL
        	
		---626 last_fixing_date
		UPDATE tf1
		SET tf1.last_fixing_date = aaa.exp_date
		FROM #temp_fixing1 tf1
		LEFT JOIN (
			SELECT tf.source_deal_header_id, MAX(hg.exp_date) exp_date
			FROM #temp_fixing tf
			LEFT JOIN holiday_group hg ON tf.exp_calendar_id = hg.hol_group_value_id
			WHERE tf.arg3 = 6
				AND tf.arg4 = 2
        		AND tf.arg5 = 6
        		AND CONVERT(VARCHAR(07), hol_date, 120) = CONVERT(VARCHAR(07), DATEADD(mm, -8, tf.entire_term_end), 120)
			GROUP BY tf.source_deal_header_id
		) aaa ON tf1.source_deal_header_id = aaa.source_deal_header_id
		INNER JOIN #temp_fixing tf ON tf1.source_deal_header_id = tf.source_deal_header_id
		WHERE tf.arg3 = 6
			AND tf.arg4 = 2 
			AND tf.arg5 = 6
			AND tf.REBD IS NULL
        	
		/*****Lagging end*******/
        	
		/*****Other curveD, Curve H,etc start*******/
        	
		UPDATE tf1
		SET tf1.first_fixing_date = CASE WHEN tf.exp_calendar_id IS NULL THEN tf.entire_term_start ELSE aaa.exp_date END ---if no calendar mapped in curve and deal header entire_term_start
		FROM  #temp_fixing1 tf1
		LEFT JOIN (
        	SELECT tf.source_deal_header_id,
        			MIN(hg.exp_date) exp_date
        	FROM #temp_fixing tf
			LEFT JOIN holiday_group hg ON tf.exp_calendar_id = hg.hol_group_value_id
				AND hg.hol_date = tf.entire_term_start
			WHERE tf.arg3 IS NULL
        		AND tf.arg4 IS NULL
        		AND tf.arg5 IS NULL
        		AND tf.exp_calendar_id IS NOT NULL
        	GROUP BY tf.source_deal_header_id
		) aaa ON tf1.source_deal_header_id = aaa.source_deal_header_id
		INNER JOIN #temp_fixing tf ON tf1.source_deal_header_id = tf.source_deal_header_id
		WHERE tf.arg3 IS NULL
			AND tf.arg4 IS NULL
			AND tf.arg5 IS NULL
			AND tf.REBD IS NULL
        	
		UPDATE tf1
		SET tf1.last_fixing_date = CASE WHEN tf.exp_calendar_id IS NULL THEN tf.entire_term_end ELSE aaa.exp_date END---if no calendar mapped in curve and deal header entire_term_end
		FROM #temp_fixing1 tf1
		LEFT JOIN (
        	SELECT tf.source_deal_header_id,
        			MAX(hg.exp_date) exp_date
        	FROM #temp_fixing tf
			LEFT JOIN holiday_group hg ON tf.exp_calendar_id = hg.hol_group_value_id
				AND hg.hol_date = tf.entire_term_end
        	WHERE tf.arg3 IS NULL
        		AND tf.arg4 IS NULL
        		AND tf.arg5 IS NULL
        		AND tf.exp_calendar_id IS NOT NULL
        	GROUP BY tf.source_deal_header_id
		) aaa ON tf1.source_deal_header_id = aaa.source_deal_header_id
		INNER JOIN #temp_fixing tf ON tf1.source_deal_header_id = tf.source_deal_header_id
		WHERE tf.arg3 IS NULL
			AND tf.arg4 IS NULL
			AND tf.arg5 IS NULL
			AND tf.REBD IS NULL
        	
		/*****Other curveD, Curve H,etc end*******/
        	
		/*****if @dayahead curve defined. this will update all deals with fixings date regardless lagging, formula etc start *******/
		DECLARE @sqlfixing VARCHAR(MAX)
        	
		SET @sqlfixing = '
			UPDATE tf1 
			SET tf1.first_fixing_date= DATEADD(DD, -1, aaa.entire_term_start), tf1.last_fixing_date = DATEADD(DD, -1, aaa.entire_term_end)
			FROM #temp_fixing1 tf1
			INNER JOIN (
				SELECT tf.source_deal_header_id,
						tf1.fixing_index,
						MAX(tf.entire_term_start) entire_term_start,
						MAX(tf.entire_term_end) entire_term_end
				FROM #temp_fixing tf
				LEFT JOIN #temp_fixing1 tf1 ON tf.source_deal_header_id = tf1.source_deal_header_id
				WHERE tf.curve_id IN (' + @dayaheadcurve + ')
					AND tf.REBD IS NULL
				GROUP BY tf.source_deal_header_id, tf1.fixing_index
			) aaa ON tf1.source_deal_header_id = aaa.source_deal_header_id
				AND tf1.fixing_index = aaa.fixing_index
		'
    
		EXEC (@sqlfixing)

		/*****if @dayahead curve defined. this will update all deals with fixings date regardless lagging, formula etc end *******/
        	
		CREATE TABLE #temp_fixing2 (
			[source_deal_header_id] INT,
			[type_of_index_price] VARCHAR(1) COLLATE DATABASE_DEFAULT,
			[fixing_index] VARCHAR(2000) COLLATE DATABASE_DEFAULT,
			[fixing_index_types] VARCHAR(200) COLLATE DATABASE_DEFAULT,
			[fixing_index_sources] VARCHAR(1000) COLLATE DATABASE_DEFAULT,
			[first_fixing_date] VARCHAR(1000) COLLATE DATABASE_DEFAULT,
			[last_fixing_date] VARCHAR(1000) COLLATE DATABASE_DEFAULT,
			[fixing_frequency] VARCHAR(50) COLLATE DATABASE_DEFAULT
		)

		INSERT INTO #temp_fixing2
		SELECT td.source_deal_header_id,
				td.type_of_index_price,
				STUFF((SELECT ', ' + tf1.[fixing_index]
					FROM #temp_fixing1 tf1
					WHERE tf1.source_deal_header_id = td.source_deal_header_id
					FOR XML PATH('')), 1, 1, ''),
				STUFF((SELECT ', ' + tf1.[fixing_index_types]
						FROM #temp_fixing1 tf1
						WHERE tf1.source_deal_header_id = td.source_deal_header_id
						FOR XML PATH('')), 1, 1, ''),
				STUFF((SELECT ', ' + tf1.[fixing_index_sources]
						FROM #temp_fixing1 tf1
						WHERE tf1.source_deal_header_id = td.source_deal_header_id
						FOR XML PATH('')), 1, 1, ''),
				STUFF((SELECT ', ' + CONVERT(VARCHAR(10),tf1.[first_fixing_date],120)
						FROM #temp_fixing1 tf1
						WHERE tf1.source_deal_header_id = td.source_deal_header_id
						FOR XML PATH('')), 1, 1, ''),
				STUFF((SELECT ', ' + CONVERT(VARCHAR(10),tf1.[last_fixing_date],120)
						FROM #temp_fixing1 tf1
						WHERE tf1.source_deal_header_id = td.source_deal_header_id
						FOR XML PATH('')), 1, 1, ''),
				STUFF((SELECT ', ' + CONVERT(VARCHAR(10),tf1.[fixing_frequency],120)
						FROM #temp_fixing1 tf1
						WHERE tf1.source_deal_header_id = td.source_deal_header_id
						FOR XML PATH('')), 1, 1, '')
		FROM #temp_fixing1 td
		GROUP BY td.source_deal_header_id,td.type_of_index_price        	
	END
        	
	/****pre volume and price columns ends*****/
	IF @process_id IS NULL
		SET @process_id = dbo.FNAGetNewID()

	/* for validation messaging */
	CREATE TABLE #temp_messages (
		source_deal_header_id INT,
		[column] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[messages] VARCHAR(5000) COLLATE DATABASE_DEFAULT
	)

	IF OBJECT_ID ('tempdb..#cancelled_deals') IS NOT NULL
		DROP TABLE #cancelled_deals

	CREATE TABLE #cancelled_deals(
		id INT IDENTITY(1, 1),
		source_deal_header_id INT
	)
        
	IF OBJECT_ID('tempdb..#temp_settlement') IS NOT NULL
		DROP TABLE #temp_settlement

	CREATE TABLE #temp_settlement (
		source_deal_header_id INT,
		term_start DATETIME,
		term_end DATETIME,
		volume FLOAT,
		settlement_amount FLOAT,
		volume_uom INT
	)
	
	DECLARE @sql_settlement VARCHAR(2000)
	SET @sql_settlement = '
		INSERT INTO #temp_settlement (source_deal_header_id, term_start, term_end, volume, settlement_amount, volume_uom)
		SELECT tf.source_deal_header_id,
				COALESCE(tbl_index.term_start,tbl_source.term_start),
				COALESCE(tbl_index.term_end,tbl_source.term_end), 
				COALESCE(NULLIF(tbl_index.volume,0),NULLIF(tbl_source.volume,0),0), 
				COALESCE(NULLIF(tbl_index.settlement_amount,0),NULLIF(tbl_source.settlement_amount,0),0), 
				tbl_source.volume_uom
		FROM  #temp_deals tf
		OUTER APPLY (
			SELECT MIN(term_start) [term_start], MAX(term_end) [term_end], MAX(volume) [volume], SUM([value]) [settlement_amount]
			FROM index_fees_breakdown_settlement
			WHERE source_deal_header_id = tf.source_deal_header_id
			AND term_start BETWEEN ''' + @create_date_from + ''' AND ''' + @create_date_to + '''
			GROUP BY source_deal_header_id
		) tbl_index
		OUTER APPLY (
			SELECT MIN(term_start) [term_start], MAX(term_end) [term_end], SUM(volume) [volume], SUM(settlement_amount) [settlement_amount], MAX(volume_uom) [volume_uom]
			FROM source_deal_settlement
			WHERE source_deal_header_id = tf.source_deal_header_id
			AND term_start BETWEEN ''' + @create_date_from + ''' AND ''' + @create_date_to + '''
			GROUP BY source_deal_header_id
		) tbl_source
	'

	EXEC (@sql_settlement)
	BEGIN TRY
		BEGIN TRANSACTION
		IF @report_type = 39400 --Generate REMIT Report for Non Standard Contracts
		BEGIN
			INSERT INTO #cancelled_deals (source_deal_header_id)
			SELECT DISTINCT srns.source_deal_header_id
			FROM #temp_deals td
			LEFT JOIN source_remit_non_standard srns ON td.source_deal_header_id = srns.source_deal_header_id
				AND srns.acer_submission_status IN (39501, 39502)
			WHERE td.deal_status = 5607
				AND srns.id IS NULL

			INSERT INTO [source_remit_non_standard] (
        		[source_deal_header_id], [deal_id], [sub_book_id], [id_of_the_market_participant_or_counterparty], [type_of_code_used_in_field_1],
        		[id_of_the_other_market_participant_or_counterparty], [type_of_code_used_in_field_3], [reporting_entity_id], [type_of_code_used_in_field_5],
        		[beneficiary_id], [type_of_code_used_in_field_7], [trading_capacity_of_the_market_participant_or_counterparty_in_field_1],
        		[buy_sell_indicator], [contract_id], [contract_date], [contract_type], [energy_commodity], [price], [price_formula],
        		[estimated_notional_amount], [notional_currency], [total_notional_contract_quantity], [volume_optionality_capacity],
				[notional_quantity_unit], [volume_optionality], [volume_optionality_frequency], [volume_optionality_intervals], [type_of_index_price],
        		[fixing_index], [fixing_index_types], [fixing_index_sources], [first_fixing_date], [last_fixing_date], [fixing_frequency],
        		[settlement_method], [option_style], [option_type], [option_first_exercise_date], [option_last_exercise_date], [option_exercise_frequency],
        		[option_strike_index], [option_strike_index_type], [option_strike_index_source], [option_strike_price], [delivery_point_or_zone],
        		[delivery_start_date], [delivery_end_date], [load_type], [action_type], [report_type], [create_date_from], [create_date_to],
        		[acer_submission_status], [process_id]
			)
			SELECT DISTINCT
				source_deal_header_id = td.source_deal_header_id,
				deal_id = MAX(td.deal_id),
				sub_book_id = MAX(td.sub_book_id),
				[ID of the market participant or counterparty] = MAX(tcuv.[Sub Code]),
				[Type of code used in field 1] = 'ACE',--MAX(tcuv.[Sub Code Type]),
				[ID of the other market participant or counterparty] = MAX(tcuv.[Deal Code]),
				[Type of code used in field 3] = 'ACE',--MAX(tcuv.[Deal Code Type]),
				[Reporting entity ID] = @RRM,
				[Type of code used in field 5] = @RRM_code,
				[Beneficiary ID] = NULL,
				[Type of code used in field 7] = NULL,
				[Trading capacity of the market participant or counterparty in field 1] = 'P',
				[Buy_sell_indicator] = CASE WHEN ROUND(MAX(tvf.total_notional_contract_quantity), 5) < 0 THEN CASE WHEN MAX(UPPER(td.header_buy_sell_flag)) = 'b' THEN 'S' WHEN MAX(UPPER(td.header_buy_sell_flag)) = 's' THEN 'B' END ELSE MAX(UPPER(td.header_buy_sell_flag)) END,
				[Contract ID] = 'ENERCITY' + CAST(MAX(td.source_deal_header_id) AS VARCHAR(40)) ,
				[Contract date] = MAX(td.deal_date),
				[Contract type] = MAX(rs_contract_type.[Contract Type]),
				[Energy commodity] = MAX(CASE WHEN (scom.commodity_name) IN ('ELectricity', 'Power') THEN 'EL' 
											  WHEN (scom.source_commodity_id) = -1 THEN 'NG' 
											  WHEN (scom.commodity_name) = 'LNG' THEN 'LNG'
											  END),
				[Price] = CASE WHEN MAX(td.physical_financial_flag) = 'f' THEN NULL ELSE MAX(tvf.price)END,
				[Price formula] = CASE WHEN ISNULL(MAX(tduv.[Price Formula]),'') IS NOT NULL THEN MAX(tduv.[Price Formula])
								  ELSE '(' +   MAX(tduv.[Brent Weight]) + '*Brent_6kk/' + MAX(tduv.[Brent Base Value]) + ')+' + '(' + MAX(tduv.[API2 Weight]) + '*API2_6kk/' + MAX(tduv.[API2 Base Value]) + ')+' +'(' + MAX(tduv.[D35 Weight]) + '*D35_6kk/' + MAX(tduv.[D35 Base Value]) + ')'
								  END , 
				[Estimated notional amount] = ABS(CASE WHEN MAX(td.physical_financial_flag) = 'f' THEN NULL ELSE ROUND(MAX(tvf.estimated_notional_amount), 5) END),
        		[Notional currency] = CASE WHEN MAX(td.physical_financial_flag) = 'f' THEN NULL
										   WHEN MAX(tvf.price) IS NULL THEN NULL
										   ELSE MAX(
													CASE scur_fixed.currency_name WHEN 'Euro' THEN 'EUR'
																				  WHEN 'Ect' THEN 'EUX'
																				  WHEN 'GPC' THEN 'GBX'
																				  ELSE UPPER(scur_fixed.currency_name)
													END
        										) 
									  END,
        		[Total notional contract quantity] = ABS(ROUND(MAX(tvf.total_notional_contract_quantity), 5)),
        		[Volume optionality capacity] = NULL,
        		[Notional quantity unit] = CASE WHEN MAX(tsu.uom_name) = 'mwh' THEN 'MWh'
												WHEN MAX(tsu.uom_name) = 'kwh' THEN 'KWh'
												WHEN MAX(tsu.uom_name) = 'gwh' THEN 'GWh'
												WHEN MAX(tsu.uom_name) = 'therm' THEN 'Therm'
												WHEN MAX(tsu.uom_name) = 'mmbtu' THEN 'MMBtu'
												WHEN MAX(tsu.uom_name) = 'gj' THEN 'GJ'
												WHEN MAX(tsu.uom_name) = 'm3' THEN 'cm'
												WHEN MAX(tsu.uom_name) = 'm3/hr' THEN 'cm'
												WHEN MAX(tsu.uom_name) = 'm3(n,35.17)' THEN 'cm'
												WHEN MAX(tsu.uom_name) = 'Metric Tons' THEN 'cm'
												WHEN MAX(tsu.uom_name) = 'MT' THEN 'cm'
												WHEN MAX(tsu.uom_name) = 'mw' THEN 'MWh'
												ELSE NULL
										   END,
				[Volume optionality] = CASE WHEN MAX(td.counterparty_id) = 20 THEN 'M'ELSE MAX(tvf.volume_optionality) END,
        		[Volume optionality frequency] = NULL,
        		[Volume optionality intervals] = NULL,
				[Type of index price] = 'C',--ISNULL(MAX(tf2.type_of_index_price), 'F'),
        		[Fixing index] = MAX(tf2.fixing_index),
        		[Fixing index types] = MAX(tf2.fixing_index_types),
        		[Fixing index sources] = MAX(tf2.fixing_index_sources),
        		[First fixing date] = MAX(tf2.first_fixing_date),
        		[Last fixing date] = MAX(tf2.last_fixing_date),
        		[Fixing frequency] = MAX(tf2.fixing_frequency),
        		[Settlement method] = 'P',
				--For contracts such as options on forwards, futures or swaps, as the option settles into the underlying forward, future or swap, this should be considered for physical delivery of the underlying contract and the value of GǣPGǥ should be reported.
				--A majority of contracts traded under REMIT are for physical delivery, but there may also be derivative contracts that are not reported under EMIR and thus reported under REMIT		
        		[Option style] = NULL,
        		[Option type] = NULL,
        		[Option first exercise date] = NULL,
        		[Option last exercise date] = NULL,
        		[Option exercise frequency] = NULL,
        		[Option strike index] = NULL,
        		[Option strike index type] = NULL,
        		[Option strike index source] = NULL,
        		[Option strike price] = NULL,
				[Delivery point or zone] = MAX(tbl_delivery_point_area.delivery_point_area),--MAX(sml.Location_Description),
				[Delivery start date] = MAX(td.entire_term_start),
				[Delivery end date] = MAX(td.entire_term_end),
				[Load type] = CASE WHEN MAX(ISNULL(internal_desk_id,17300))=17302 THEN 'SH'
								   WHEN MAX(scom.commodity_name) IN ('Gas', 'Natural Gas', 'LNG', 'NG') THEN 'GD' 
								   WHEN MAX(sdv_block.code) LIKE '%Base%' THEN 'BL'
								   WHEN MAX(sdv_block.code) LIKE '%Peak%' THEN 'PL'
								   WHEN MAX(sdv_block.code) LIKE '%Offpeak%' THEN 'OP'
								   ELSE 'OT'
							  END,
				[Action type] = CASE WHEN @cancellation = '1' THEN 'E'---to cancel previously submitted report wtih action type= Error
									 WHEN MAX(sdv_deal_status.value_id) = 5607 AND MAX(srns.source_deal_header_id) IS NOT NULL THEN 'C'---Deal with cancelled status
									 WHEN MAX(srns.source_deal_header_id) IS NULL AND MAX(sdv_deal_status.value_id) <> 5607 THEN 'N'
									 WHEN MAX(srns.source_deal_header_id) IS NOT NULL AND MAX(sdv_deal_status.value_id) <> 5607 THEN 'M'
									 ELSE NULL
								END,
        		report_type = @report_type,
        		create_date_from = @create_date_from,
        		create_date_to = @create_date_to,
        		acer_submission_status = 39500,
        		process_id = @process_id
			FROM #temp_deals td
        	INNER JOIN #temp_deal_details tdd ON td.source_deal_header_id = tdd.source_deal_header_id
        	LEFT JOIN #temp_cpty_udf_values tcuv ON tcuv.source_deal_header_id = td.source_deal_header_id 
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tdd.curve_id
        	LEFT JOIN source_commodity scom ON scom.source_commodity_id = ISNULL(spcd.commodity_id, td.commodity_id)
        	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = tdd.location_id
        	LEFT JOIN static_data_value sdv_cntry ON sdv_cntry.value_id = sml.country
        	LEFT JOIN source_remit_non_standard srns ON td.source_deal_header_id = srns.source_deal_header_id
        		AND srns.acer_submission_status = 39502 --Submitted Deals on ACER
        	LEFT JOIN static_data_value sdv_deal_status ON sdv_deal_status.value_id = td.deal_status
        	LEFT JOIN #temp_vol_final2 tvf ON td.source_deal_header_id = tvf.source_deal_header_id
        	LEFT JOIN source_uom tsu ON tvf.notional_quantity_unit = tsu.source_uom_id
        	LEFT JOIN #temp_fixing2 tf2 ON tf2.source_deal_header_id = tvf.source_deal_header_id
        	LEFT JOIN source_currency scur_fixed ON scur_fixed.source_currency_id = tdd.fixed_price_currency_id
        	LEFT JOIN static_data_value sdv_block ON sdv_block.value_id = ISNULL(td.block_define_id,-10000298)
        	LEFT JOIN source_deal_type sd_type ON sd_type.source_deal_type_id = td.source_deal_type_id
        		AND sd_type.sub_type = 'n'
        	LEFT JOIN source_deal_type sd_sub_type ON sd_sub_type.source_deal_type_id = td.deal_sub_type_type_id
        		AND sd_sub_type.sub_type = 'y'
        	OUTER APPLY (
					SELECT CASE
								WHEN ((sd_type.source_deal_type_name) = 'Future' OR (sd_sub_type.source_deal_type_name) = 'Future') THEN 'FU'
								WHEN td.physical_financial_flag='p' THEN 'FW'
								WHEN ((sd_type.source_deal_type_name) LIKE '%Swap%'  OR (sd_sub_type.source_deal_type_name) LIKE '%Swap%') AND td.physical_financial_flag = 'f' THEN 'SW'
								WHEN ((sd_type.source_deal_type_name) = 'Option' AND (sd_sub_type.source_deal_type_name) = 'Future') OR ((sd_type.source_deal_type_name) = 'Future' AND (sd_sub_type.source_deal_type_name) = 'Option') THEN 'OP_FU'
								WHEN ((sd_type.source_deal_type_name) = 'Option' AND (sd_sub_type.source_deal_type_name) = 'Forward') OR ((sd_type.source_deal_type_name) = 'Forward' AND (sd_sub_type.source_deal_type_name) = 'Option') THEN 'OP_FW'
								WHEN ((sd_type.source_deal_type_name) = 'Option' AND (sd_sub_type.source_deal_type_name) = 'Swap') OR ((sd_type.source_deal_type_name) = 'Swap' AND (sd_sub_type.source_deal_type_name) = 'Option') THEN 'OP_SW'
								WHEN ((sd_type.source_deal_type_name) = 'Option' AND (sd_sub_type.source_deal_type_name) = 'Option') THEN 'OP'
								WHEN (sd_type.source_deal_type_name) = 'Spread' AND (sd_sub_type.source_deal_type_name) = 'Spread' THEN 'SP'
								WHEN ((sd_type.source_deal_type_name) = 'Future' OR (sd_sub_type.source_deal_type_name) = 'Future') THEN 'FU'
								ELSE 'OT'
						   END [Contract Type]
			) rs_contract_type
        	LEFT JOIN #cancelled_deals c ON c.source_deal_header_id = td.source_deal_header_id
			LEFT JOIN #temp_deal_udf_values tduv ON tduv.source_deal_header_id = td.source_deal_header_id
			OUTER APPLY( SELECT gmv.clm3_value delivery_point_area
				 FROM generic_mapping_header gmh
				 INNER JOIN generic_mapping_values gmv
					ON gmv.mapping_table_id = gmh.mapping_table_id
				 WHERE gmh.mapping_name = 'ECM /Remit Delivery Point'
				 AND gmv.clm1_value = CAST(tdd.location_id AS VARCHAR(20))
				 AND gmv.clm2_value = CAST(scom.source_commodity_id AS VARCHAR(20))
			) tbl_delivery_point_area
			WHERE c.id IS NULL
			GROUP BY  td.source_deal_header_id

			IF EXISTS (SELECT 1 FROM source_remit_non_standard WHERE process_id = @process_id AND action_type IS NULL)
			BEGIN 
				DELETE FROM source_remit_non_standard WHERE process_id = @process_id AND action_type IS NULL
			END
				  
			--Update price, estimated_notional_amount and notional_currency to NULL when price_formula is filled
			IF EXISTS (SELECT 1 FROM source_remit_non_standard WHERE process_id = @process_id AND price_formula IS NOT NULL)
			BEGIN
				UPDATE source_remit_non_standard
				SET price = NULL,
					estimated_notional_amount = NULL,
					notional_currency = NULL
				WHERE process_id = @process_id
					AND price_formula IS NOT NULL
			END
        	    
			BEGIN --Validations starts
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'id_of_the_market_participant_or_counterparty', 'id_of_the_market_participant_or_counterparty Must not be NULL'
				FROM source_remit_non_standard
				WHERE id_of_the_market_participant_or_counterparty IS NULL
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'id_of_the_market_participant_or_counterparty', 'id_of_the_market_participant_or_counterparty Must have length of 12'
				FROM source_remit_non_standard
				WHERE LEN(id_of_the_market_participant_or_counterparty) <> 12
					AND process_id = @process_id		

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'id_of_the_other_market_participant_or_counterparty', 'id_of_the_other_market_participant_or_counterparty Must not be NULL'
				FROM source_remit_non_standard 
				WHERE id_of_the_other_market_participant_or_counterparty IS NULL 
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Sellers_acer_code', 'Sellers acer code Must have length of 12'
				FROM source_remit_non_standard 
				WHERE LEN(id_of_the_other_market_participant_or_counterparty) <> 12
					AND process_id = @process_id

    			INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Contract_type', 'Contract type '+ Contract_type + ' Not in Value List.'
				FROM source_remit_non_standard
				WHERE LEN(Contract_type) > 0
					AND Contract_type NOT IN ('SO', 'FW', 'FU', 'OP', 'OP_FW', 'OP_FU', 'OP_SW', 'SP', 'SW', 'OT') 
					AND process_id = @process_id
					
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Contract_type', 'Contract Type Must not be NULL'
				FROM source_remit_non_standard
				WHERE Contract_type IS NULL
					AND process_id = @process_id
		
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Commodity', 'Commodity '+ energy_commodity + ' Not in Value List.'
				FROM source_remit_non_standard 
				WHERE LEN(energy_commodity) > 0 
					AND energy_commodity NOT IN ('EL', 'NG') 
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Commodity', 'Commodity Must not be NULL'
				FROM source_remit_non_standard 
				WHERE energy_commodity IS NULL
					AND process_id = @process_id		

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Settlement', 'Settlement '+ settlement_method + ' Not in Value List.'
				FROM source_remit_non_standard 
				WHERE LEN(settlement_method) > 0 
					AND settlement_method NOT IN ('P', 'C', 'O')
					AND process_id = @process_id		
		
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Settlement', 'Settlement Must not be NULL'
				FROM source_remit_non_standard 
				WHERE settlement_method IS NULL 
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'currency', 'currency Should be NULL if price_or_price_formula IS NULL if price IS NULL'
				FROM source_remit_non_standard
				WHERE notional_currency IS NOT NULL
					AND process_id = @process_id
					AND price IS NULL

				IF EXISTS(SELECT 1 FROM source_remit_non_standard WHERE notional_currency IS NOT NULL AND process_id = @process_id )
				BEGIN
					IF EXISTS(SELECT 1 FROM source_remit_non_standard WHERE notional_currency IS NOT NULL AND process_id = @process_id AND notional_currency NOT IN ('BGN', 'CHF', 'CZK', 'DKK', 'EUR', 'EUX', 'GBX', 'GBP', 'HRK', 'HUF', 'ISK', 'NOK', 'PCT', 'PLN', 'RON', 'SEK', 'USD', 'OTH'))
					BEGIN
						INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
						SELECT source_deal_header_id, 'Currency', 'Currency '+ notional_currency + ' Not in Value List.'
						FROM source_remit_non_standard 
						WHERE notional_currency IS NOT NULL 
							AND notional_currency NOT IN ('BGN', 'CHF', 'CZK', 'DKK', 'EUR', 'EUX', 'GBX', 'GBP', 'HRK', 'HUF', 'ISK', 'NOK', 'PCT', 'PLN', 'RON', 'SEK', 'USD', 'OTH')
							AND process_id = @process_id
					END
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT 1 FROM source_remit_non_standard WHERE process_id = @process_id AND (price_formula IS NULL OR price IS NULL))
					BEGIN
						INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
						SELECT source_deal_header_id, 'currency', 'currency cannot be NULL if price is not null'
						FROM source_remit_non_standard
						WHERE process_id = @process_id 
							AND price IS NOT NULL
					END
				END

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'currency', 'notional_quantity_unit Should be NULL if Total_notional_contract_quantity IS NULL'
				FROM source_remit_non_standard
				WHERE total_notional_contract_quantity IS NULL
					AND notional_quantity_unit IS NOT NULL
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'notional_quantity_unit', 'notional_quantity_unit '+ notional_quantity_unit + ' Not in Value List.'
				FROM source_remit_non_standard
				WHERE total_notional_contract_quantity IS NOT NULL
					AND notional_quantity_unit NOT IN ('KWh', 'MWh', 'GWh', 'Therm', 'Ktherm', 'MTherm', 'cm', 'mcm', 'MMBtu', 'GJ', 'Btu/d', 'MJ/d', '100MJ/d', 'MMJ/d')
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'notional_quantity_unit', 'notional_quantity_unit cannot be NULL if Total_Notional_contract_quantity is not null'
				FROM source_remit_non_standard
				WHERE notional_quantity_unit IS NULL
					AND total_notional_contract_quantity IS NOT NULL
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'delivery_point_or_zone', 'delivery_point_or_zone Must match [0-9][0-9][XYZTWV].+'
				FROM source_remit_non_standard
				WHERE  dbo.IsValidDeliveryPoint(delivery_point_or_zone) = 0 
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'delivery_point_or_zone', 'delivery_point_or_zone Must have length of 16'
				FROM source_remit_non_standard 
				WHERE LEN(delivery_point_or_zone) <> 16 
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'delivery_point_or_zone', 'delivery_point_or_zone Must not be NULL'
				FROM source_remit_non_standard 
				WHERE delivery_point_or_zone IS NULL
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Delivery_start_date', 'Delivery start date Must match YYYY-MM-DD'
				FROM source_remit_non_standard 
				WHERE dbo.IsValidDatePattern(CONVERT(VARCHAR(10),Delivery_start_date,120)) = 0
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Delivery_start_date', 'Delivery start date Must not be NULL'
				FROM source_remit_non_standard 
				WHERE Delivery_start_date IS NULL
					AND process_id = @process_id
        
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Delivery_end_date', 'Delivery end date Must match YYYY-MM-DD'
				FROM source_remit_non_standard 
				WHERE dbo.IsValidDatePattern(CONVERT(VARCHAR(10), Delivery_end_date, 120)) = 0 
					AND process_id = @process_id


				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Delivery_end_date', 'Delivery end date Must not be NULL'
				FROM source_remit_non_standard 
				WHERE Delivery_end_date IS NULL 
					AND process_id = @process_id
 
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'contract_date', 'Contract_date must match YYYY-MM-DD'
				FROM source_remit_non_standard 
				WHERE dbo.IsValidDatePattern(CONVERT(VARCHAR(10), contract_date, 120)) = 0 
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'contract_date', 'Contract_date Must not be NULL'
				FROM source_remit_non_standard 
				WHERE contract_date IS NULL
					AND process_id = @process_id

				UPDATE srns 
				SET srns.[error_validation_message] = s.msg 
				FROM source_remit_non_standard srns
				INNER JOIN source_remit_non_standard vt_outer ON vt_outer.source_deal_header_id = srns.source_deal_header_id
					AND srns.process_id = @process_id
				CROSS APPLY (
					SELECT STUFF((
								SELECT DISTINCT ', '  + ISNULL((tm.[messages]), '')
								FROM source_remit_non_standard vt
								INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
								WHERE tm.messages IS NOT NULL
									AND vt_outer.source_deal_header_id = vt.source_deal_header_id
								FOR XML PATH('')) , 1, 1, ''
						   ) AS msg
					FROM source_remit_non_standard vt
					INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
					WHERE tm.messages IS NOT NULL
						AND vt_outer.source_deal_header_id = vt.source_deal_header_id
					GROUP BY vt.source_deal_header_id
				) s
			END				
		END
		ELSE IF @report_type = 39401 --Generate REMIT Report for Standard Contracts
		BEGIN
			IF OBJECT_ID ('tempdb..#source_remit_standard') IS NOT NULL
				DROP TABLE #source_remit_standard
				
			SELECT DISTINCT
				source_deal_header_id= td.source_deal_header_id,
			deal_id= MAX(td.deal_id),
			sub_book_id= MAX(td.sub_book_id),
			-----Parties of Contract
			[ID of the market participant or counterparty]= MAX(tcuv.[Sub Code]) ,
			[Type of code used in field 1]= @RRM_code,--MAX(tcuv.[Sub Code Type]),
			[ID of the other market participant or counterparty] = MAX(st.trader_name), -- As per greenchoice they always trade with GROENE
			[trader_id_market_participant] = MAX(tcuv.[Deal Code]),
			[Type of code used in field 4]= @RRM_code,--MAX(tcuv.[Deal Code Type]),
			[Reporting entity ID]= @RRM,
			[Type of code used in field 6]= @RRM_code,
			[Beneficiary ID]= NULL, --check later if needed to be implemented
			[Type of code used in field 8]= NULL,  --check later if needed to be implemented
			[Trading capacity of the market participant or counterparty in field 1]= 'P',--check later if more logic needed to be implemented
			[Buy Sell Indicator]= MAX(deal_flag.buy_sell), -- MAX(UPPER(td.header_buy_sell_flag)),
			[initiator_aggressor] = NULL,
			------Contract Details
			--[Contract ID]= MAX(cg.[name]), 
			[Contract ID] = CASE WHEN MAX(td.deal_group_id) = 1 THEN MAX(cg.[name]) WHEN MAX(td.deal_group_id) = 2 THEN ISNULL(MAX(td.ext_deal_id), '') ELSE NULL END,
			[contract_name] = 'BILCONTRACT',
			[Contract type]= MAX(rs_contract_type.[Contract Type]),
			[Energy commodity]= MAX(CASE WHEN (scom.commodity_name) IN ('ELectricity', 'Power') THEN 'EL' WHEN (scom.commodity_name) IN ('Gas', 'Natural Gas', 'LNG') THEN 'NG' END),
			[fixing_index_or_reference_price] = NULL,		
			[Settlement method]= MAX(CASE (td.physical_financial_flag) WHEN 'f' THEN 'C' WHEN 'p' THEN 'P' ELSE 'O' END),
			[organised_market_place_id_otc] = 'XBIL',
			[contract_trading_hours] = CASE WHEN MAX(td.commodity_name) = 'Power' THEN '00:00Z/24:00Z' ELSE CASE WHEN ISNULL(MAX(tz.TIMEZONE_NAME),'') = '(GMT +1:00 hour) Brussels, Copenhagen, Madrid, Paris' THEN '06:00Z/06:00Z' 
																										  WHEN  ISNULL(MAX(tz.TIMEZONE_NAME),'') = '(GMT +3:00) Eastern European Time' THEN '07:00Z/07:00Z'
																											   ELSE '06:00Z/06:00Z'
																									END END,
			[last_trading_date_and_time] = NULL,
			----------Transaction details
			[transaction_timestamp] = ISNULL(MAX(tduv.[Execution Timestamp]),CONVERT(VARCHAR(10), MAX(td.deal_date),120) + 'T' +  CAST(CAST( MAX(td.create_ts) as time) AS VARCHAR(12)))  ,--CONVERT(char(10), MAX(td.deal_date),120) + 'T' + MAX(gm_ts.[timestamp]) + '.00Z' ,
			[unique_transaction_id] = NULL,-- MAX(td.deal_id), --will be filled with UTI code later if @generate_uti=1
			[linked_transaction_id] = NULL,
			[linked_order_id] = NULL,
			[voice_brokered] = NULL,
			[Price] = CASE WHEN MAX(td.physical_financial_flag)='f'  THEN NULL ELSE CASE WHEN MAX(td.deal_group_id) = 1 THEN MAX(deal_wa.WeightedAverage) ELSE  MAX(tvf.price) END END,
			[index_value] = CASE WHEN MAX(td.physical_financial_flag)='f' THEN CAST(MAX(tvf.price) AS VARCHAR(100)) +' - '+ MAX(tf2.fixing_index) 
								WHEN MAX(tdd.formula_id) IS NOT NULL THEN MAX(tf2.fixing_index) 
								ELSE NULL 
							END,	
			[price_currency] = CASE WHEN MAX(td.physical_financial_flag)='f'  THEN NULL	
									WHEN MAX(tvf.price) IS NULL THEN NULL ELSE
									MAX(CASE scur_fixed.currency_name WHEN 'Euro' 	THEN 'EUR' 
									WHEN 'Ect' THEN 'EUX' 
									WHEN 'GPC'THEN 'GBX'
									ELSE UPPER(scur_fixed.currency_name) END) 
								END, 
			--[notional_amount] = CASE WHEN MAX(td.physical_financial_flag)='f' THEN NULL ELSE CASE WHEN MAX(td.deal_group_id) = 1 THEN (MAX(tvf.estimated_notional_amount_wa_average)) ELSE ABS(ROUND(MAX(tvf.estimated_notional_amount),5)) END END,--swaps no est. amt
			[notional_amount] = CASE WHEN MAX(td.physical_financial_flag)='f' THEN NULL ELSE CASE WHEN MAX(td.deal_group_id) = 1 THEN CASE WHEN MAX(deal_flag.buy_sell) = 'B' THEN MAX(tvf.estimated_notional_amount_wa_average) ELSE  -MAX(tvf.estimated_notional_amount_wa_average) END ELSE ABS(ROUND(MAX(tvf.estimated_notional_amount),5)) END END,--swaps no est. amt
			[Notional currency]= CASE WHEN MAX(td.physical_financial_flag)='f'  THEN NULL	
									  WHEN MAX(tvf.price) IS NULL THEN NULL ELSE
									  MAX(CASE scur_fixed.currency_name WHEN 'Euro' 	THEN 'EUR' 
									  WHEN 'Ect' THEN 'EUX' 
									  WHEN 'GPC'THEN 'GBX'
									  ELSE UPPER(scur_fixed.currency_name) END) END, 
			[quantity_volume] = CASE WHEN (MAX(td.deal_group_id) = 1 AND MAX(td.commodity_name) = 'Power' AND MAX(td.internal_desk_id) = 17302) THEN  NULL ELSE AVG(tdd.deal_volume) END,
			[Total notional contract quantity]= ABS(ROUND(MAX(tvf.total_notional_contract_quantity),5)) ,
			[quantity_unit_field_40_and_41] = CASE --WHEN MAX(tsu.uom_name)='mwh' THEN 'MWh'
												  WHEN MAX(tsu.uom_name)='kwh' THEN 'KWh'
												  WHEN MAX(tsu.uom_name)='gwh' THEN 'GWh'
												  WHEN MAX(tsu.uom_name)='therm' THEN 'Therm'
												  WHEN MAX(tsu.uom_name)='mmbtu' THEN 'MMBtu'
												  WHEN MAX(tsu.uom_name)='gj' THEN 'GJ'
												  WHEN MAX(tsu.uom_name)='m3' THEN 'cm'
												  WHEN MAX(tsu.uom_name)='m3/hr' THEN 'cm'
												  WHEN MAX(tsu.uom_name)='m3(n,35.17)' THEN 'cm'
												  WHEN MAX(tsu.uom_name)='Metric Tons' THEN 'cm'
												  WHEN MAX(tsu.uom_name)='MT' THEN 'cm'
												  --WHEN MAX(tsu.uom_name)='mw' THEN 'MWh'
												  WHEN MAX(dv_uom.uom_name) <> MAX(spc_uom.uom_name) THEN CASE WHEN MAX(dv_uom.uom_name) IS NOT NULL AND  MAX(spc_uom.uom_name) IS NOT NULL THEN  MAX(dv_uom.uom_name) + ' / ' + MAX(spc_uom.uom_name) WHEN MAX(spc_uom.uom_name) IS NULL THEN MAX(dv_uom.uom_name)  END
												  WHEN MAX(dv_uom.uom_name) = MAX(spc_uom.uom_name) THEN MAX(dv_uom.uom_name)
												  ELSE NULL 
												END,
			[termination_date] = NULL,
			---------Option details
			[option_style] = NULL,
			[option_type] = NULL,
			[option_exercise_date] = NULL,
			[option_strike_price] = NULL,
			-----------Order Detail
			--[order_id] = CASE WHEN MAX(td.deal_group_id) = 1 THEN REPLACE(CONVERT(char(10), MAX(td.entire_term_start), 126),'-','') + '_GROENE_AXPO_APX' WHEN MAX(td.deal_group_id) = 2 THEN ISNULL(MAX(td.ext_deal_id), '') ELSE '' END,
			[order_id] = CASE WHEN MAX(td.deal_group_id) = 1 THEN REPLACE(CONVERT(char(10), MAX(td.entire_term_start), 126),'-','') + '_GROENE_AXPO_APX' WHEN MAX(td.deal_group_id) = 2 THEN '' ELSE '' END,
			--[order_id] = CASE WHEN MAX(sc.counterparty_name) LIKE '%Axpo Trading AG%' THEN REPLACE(CONVERT(char(10), MAX(td.entire_term_start), 126),'-','') + '_GROENE_AXPO_APX' ELSE NULL END,
			--[order_type] = CASE WHEN MAX(td.commodity_name) = 'Power' AND MAX(td.deal_group_id) = 1 THEN 'LIM' WHEN MAX(td.deal_group_id) = 2 THEN 'BLO' ELSE NULL END,
			[order_type] = CASE WHEN MAX(td.commodity_name) = 'Power' AND MAX(td.deal_group_id) = 1 THEN 'LIM' WHEN MAX(td.deal_group_id) = 2 THEN NULL ELSE NULL END,
			[order_condition] =  NULL,
			[order_status] = CASE WHEN MAX(td.commodity_name) = 'Power' AND MAX(td.deal_group_id) = 1 THEN 'MAC' ELSE NULL END,
			[minimum_execution_volume] = NULL,
			[price_limit] = NULL,
			[undisclosed_volume] = NULL,
			[order_duration] = CASE WHEN MAX(td.deal_group_id) = 1 THEN 'GTC' ELSE NULL END,
			---------Delivery Profile
			[Delivery point or zone]= MAX(tbl_delivery_point_area.delivery_point_area),--MAX(sml.location_description), --CASE WHEN MAX(sdv_cntry.code) = 'NL' THEN '10YCB-NL-------V' WHEN MAX(sdv_cntry.code) IN ('BE', 'BELGIUM') THEN '10YDOM--BE-NL--8' END,
			[Delivery start date]= MAX(td.entire_term_start),
			[Delivery end date]= CASE WHEN MAX(td.deal_group_id) = 3 THEN DATEADD(DAY, 1, MAX(td.entire_term_end)) ELSE MAX(td.entire_term_end) END, -- for gas add 1 day
			[Delivery Duration] =  CASE WHEN DATEDIFF(dd,MAX(td.entire_term_start),MAX(td.entire_term_end)) = 0 AND MAX(td.commodity_id) = -1  THEN 'D'
										WHEN DATEDIFF(dd,MAX(td.entire_term_start),MAX(td.entire_term_end)) = 0 AND MAX(td.commodity_name) = 'Power'  THEN 'H'
										WHEN DATEDIFF(dd,MAX(td.entire_term_start),MAX(td.entire_term_end)) >= 1 AND DATEDIFF(dd,MAX(td.entire_term_start),MAX(td.entire_term_end)) < 8 THEN 'W'
										WHEN DATEDIFF(dd,MAX(td.entire_term_start),MAX(td.entire_term_end)) >= 8 AND DATEDIFF(dd,MAX(td.entire_term_start),MAX(td.entire_term_end)) < 32 THEN 'M'
										WHEN DATEDIFF(dd,MAX(td.entire_term_start),MAX(td.entire_term_end)) >= 32 AND DATEDIFF(dd,MAX(td.entire_term_start),MAX(td.entire_term_end)) < 94 THEN 'Q'
										WHEN DATEDIFF(dd,MAX(td.entire_term_start),MAX(td.entire_term_end)) >= 94 AND DATEDIFF(dd,MAX(td.entire_term_start),MAX(td.entire_term_end)) < 186 THEN 'S'
										WHEN DATEDIFF(dd,MAX(td.entire_term_start),MAX(td.entire_term_end)) >= 186 AND DATEDIFF(dd,MAX(td.entire_term_start),MAX(td.entire_term_end)) < 367 THEN 'Y'
										ELSE 'O'
								END, --Derived based on term start and term end
			[Load Type] = CASE WHEN MAX(ISNULL(internal_desk_id,17300))=17302 AND MAX(td.deal_group_id) = 1 THEN 'SH'
							  WHEN MAX(ISNULL(internal_desk_id,17300))=17302 AND MAX(td.deal_group_id) = 1 AND MAX(td.commodity_name) = 'Power'  THEN 'BH'
							  WHEN MAX(scom.commodity_name) IN ('Gas', 'Natural Gas', 'LNG', 'NG') THEN 'GD' 
							  WHEN MAX(sdv_block.code) LIKE '%Base%' THEN 'BL' 
							  WHEN MAX(sdv_block.code) LIKE '%Peak%' THEN 'PL' 
							  WHEN MAX(sdv_block.code) LIKE '%OffPeak%' THEN 'OP' ELSE 'OT'
						END,
			[days_of_the_week] = NULL, --Derive based on term start and term end
			[load_delivery_intervals] = CASE WHEN DATEDIFF(DAY, MAX(td.entire_term_start),MAX(td.entire_term_end)) = 0 AND ISNULL(MAX(gm_ts.deal_group_id),MAX(td.deal_group_id)) = 1 THEN MAX(delivery_profile.load_delivery_intervals) 
											 WHEN  (ISNULL(MAX(gm_ts.deal_group_id),MAX(td.deal_group_id)) = 2 AND MAX(sdv_block.code) LIKE 'Peak%') THEN '08:00 / 20:00'  
											 WHEN  (ISNULL(MAX(gm_ts.deal_group_id),MAX(td.deal_group_id)) = 2 AND MAX(sdv_block.code) NOT LIKE 'Peak%') THEN '00:00 / 00:00'  
											 WHEN ISNULL(MAX(gm_ts.deal_group_id),MAX(td.deal_group_id)) = 3 AND MAX(td.commodity_id)=-1 THEN '06:00 / 06:00'
											 ELSE ISNULL(MAX(hb.interval),'')  
			                            END, -- Daily deal, power and shaped only
			[delivery_capacity] =CASE WHEN DATEDIFF(DAY, MAX(td.entire_term_start),MAX(td.entire_term_end)) = 0 AND MAX(td.internal_desk_id) = 17302 AND MAX(td.commodity_name) = 'Power' THEN  MAX(delivery_profile.delivery_capacity) ELSE '' END, -- Daily deal, power and shaped only
			[quantity_unit_used_in_field_55] = CASE WHEN DATEDIFF(DAY, MAX(td.entire_term_start),MAX(td.entire_term_end)) = 0 AND MAX(td.internal_desk_id) = 17302 AND MAX(td.commodity_name) = 'Power' THEN  MAX(delivery_profile.quantity_unit_used) ELSE '' END, -- Daily deal, power and shaped only
			[price_time_interval_quantity] = CASE WHEN DATEDIFF(DAY, MAX(td.entire_term_start),MAX(td.entire_term_end)) = 0 AND MAX(td.internal_desk_id) = 17302 AND MAX(td.commodity_name) = 'Power' THEN  MAX(delivery_profile.price_time_interval_quantity) ELSE NULL END, -- Daily deal, power and shaped only
			----------Life cycle information
			[Action type]= 	CASE WHEN @cancellation='1' THEN 'E'---to cancel previously submitted report wtih action type= Error
								 WHEN MAX(sdv_deal_status.value_id)=5629 THEN 'C'---Deal with cancelled status
								 WHEN MAX(src_remit.source_deal_header_id) IS NULL THEN 'N'
								 WHEN MAX(src_remit.source_deal_header_id) IS NOT NULL THEN 'M' 
								 ELSE NULL END,
			report_type = @report_type ,
			create_date_from = @create_date_from,
			create_date_to =@create_date_to,
			acer_submission_status =39500,
			process_id= @process_id
				INTO #source_remit_standard
				FROM #temp_deals td
				LEFT JOIN #temp_settlement ts ON td.source_deal_header_id=ts.source_deal_header_id	
				INNER JOIN #temp_deal_details tdd ON td.source_deal_header_id=tdd.source_deal_header_id
				LEFT JOIN #temp_deal_udf_values tduv ON tduv.source_deal_header_id = td.source_deal_header_id
				LEFT JOIN #temp_cpty_udf_values tcuv ON tcuv.source_deal_header_id = td.source_deal_header_id
				LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tdd.curve_id
				LEFT JOIN source_uom spc_uom ON spcd.uom_id = spc_uom.source_uom_id
				LEFT JOIN source_uom dv_uom ON tdd.deal_volume_uom_id = dv_uom.source_uom_id
				LEFT JOIN source_commodity scom ON scom.source_commodity_id = ISNULL(spcd.commodity_id, td.commodity_id)
				LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = tdd.location_id
				LEFT JOIN time_zones tz ON tz.TIMEZONE_ID = sml.time_zone
				LEFT JOIN static_data_value sdv_cntry ON sdv_cntry.value_id = sml.country
				LEFT JOIN source_remit_standard src_remit ON td.source_deal_header_id=src_remit.source_deal_header_id 
					AND src_remit.acer_submission_status = 39502
				LEFT JOIN static_data_value sdv_deal_status ON sdv_deal_status.value_id = td.deal_status
				LEFT JOIN #temp_vol_final2 tvf ON td.source_deal_header_id=tvf.source_deal_header_id
				LEFT JOIN source_uom tsu ON tvf.notional_quantity_unit=tsu.source_uom_id
				LEFT JOIN #temp_fixing2 tf2 ON tf2.source_deal_header_id=tvf.source_deal_header_id
				LEFT JOIN source_currency scur_fixed ON scur_fixed.source_currency_id = tdd.fixed_price_currency_id
				LEFT JOIN static_data_value sdv_block ON sdv_block.value_id = ISNULL(td.block_define_id,-10000298)
				LEFT JOIN source_deal_type sd_type ON sd_type.source_deal_type_id = td.source_deal_type_id
					AND sd_type.sub_type = 'n'
				LEFT JOIN source_deal_type sd_sub_type ON sd_sub_type.source_deal_type_id = td.deal_sub_type_type_id
					AND sd_sub_type.sub_type = 'y'
				LEFT JOIN source_traders st ON st.source_trader_id = td.trader_id
				LEFT JOIN contract_group cg ON cg.contract_id = td.contract_id
				LEFT JOIN source_counterparty sc ON td.counterparty_id = sc.source_counterparty_id		
				OUTER APPLY (
					SELECT CASE WHEN SUM(CASE WHEN d.buy_sell_flag = 's' THEN -d.total_volume ELSE d.total_volume END) >= 0 THEN 'B'ELSE 'S'END buy_sell
					FROM #temp_deal_details d
					WHERE  source_deal_header_id = td.source_deal_header_id
				) deal_flag
				OUTER APPLY (
					SELECT STUFF((
								SELECT ', ' + RIGHT('00' + CONVERT(NVARCHAR, CAST(CAST(LEFT(a.hr, 2) AS INT) - 1 AS NVARCHAR(10))), 2) + ':00/' + RIGHT('00' + CONVERT(NVARCHAR, CAST(CAST(LEFT(a.hr, 2) AS INT) AS NVARCHAR(10))), 2) + ':00' [text()]
								FROM source_deal_detail_hour a
								INNER JOIN source_deal_detail sdd ON a.source_deal_detail_id = sdd.source_deal_detail_id
								WHERE sdd.source_deal_header_id = td.source_deal_header_id
									AND a.volume <> 0
								ORDER BY CAST(LEFT(a.hr, 2) AS INT)
								FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, ''
							) load_delivery_intervals,
							STUFF((
								SELECT ', ' + CONVERT(NVARCHAR, CAST(ROUND(CAST(CASE WHEN (deal_flag.buy_sell = 'B') THEN CASE WHEN sdd.buy_sell_flag = 'b' THEN  a.volume ELSE - a.volume END ELSE CASE WHEN deal_flag.buy_sell = 'S' THEN CASE WHEN sdd.buy_sell_flag = 'b' THEN -a.volume ELSE a.volume END ELSE -a.volume END END AS FLOAT), 4) AS NVARCHAR(10))) [text()]
								FROM source_deal_detail_hour a
								INNER JOIN source_deal_detail sdd ON a.source_deal_detail_id = sdd.source_deal_detail_id
								WHERE sdd.source_deal_header_id = td.source_deal_header_id
									AND a.volume <> 0
								ORDER BY CAST(LEFT(a.hr,2) AS INT)
								FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, ''
							) delivery_capacity,
							STUFF((
								SELECT ', ' + CONVERT(NVARCHAR, CAST(ROUND(CAST(a.price AS FLOAT) + ISNULL(sdd.price_adder, 0), 4) AS NVARCHAR(55))) [text()]
								FROM source_deal_detail_hour a
								INNER JOIN source_deal_detail sdd ON a.source_deal_detail_id = sdd.source_deal_detail_id  
								WHERE sdd.source_deal_header_id = td.source_deal_header_id
									AND a.volume <> 0 
								ORDER BY CAST(LEFT(a.hr,2) AS INT)
								FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, ''
							) price_time_interval_quantity,
							STUFF((
								SELECT ', ' + su.uom_name [text()]
								FROM source_deal_detail_hour a
								INNER JOIN source_deal_detail sdd ON a.source_deal_detail_id = sdd.source_deal_detail_id  
								LEFT JOIN source_uom su ON sdd.deal_volume_uom_id = su.source_uom_id
								WHERE sdd.source_deal_header_id = td.source_deal_header_id
									AND a.volume <> 0 
								ORDER BY CAST(LEFT(a.hr,2) AS INT)
								FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, ''
							) quantity_unit_used
					FROM source_deal_detail d
					INNER JOIN source_deal_detail_hour sddh ON d.source_deal_detail_id = d.source_deal_detail_id
					WHERE d.source_deal_header_id = td.source_deal_header_id
					GROUP BY d.source_deal_header_id
				) delivery_profile
				OUTER APPLY (
					SELECT CASE WHEN SUM(ISNULL(a.Volume, 0)) <> 0 THEN SUM(CASE WHEN sdd.buy_sell_flag = 'b' THEN ISNULL(a.volume, 0) ELSE - ISNULL(a.volume, 0) END * (ISNULL(a.price, 0) + ISNULL(sdd.price_Adder, 0))) / SUM(ISNULL(CASE WHEN sdd.buy_sell_flag = 'b' THEN ISNULL(a.volume, 0) ELSE - ISNULL(a.volume, 0) END, 0)) ELSE 0 END WeightedAverage
					FROM source_deal_detail_hour a
					INNER JOIN source_deal_detail sdd ON a.source_deal_detail_id = sdd.source_deal_detail_id
					WHERE sdd.source_deal_header_id = td.source_deal_header_id
				) deal_wa
				OUTER APPLY (
					SELECT CAST(MIN(CAST(SUBSTRING(hour_series, 3, LEN(hour_series) - 2) AS INT)) AS VARCHAR) + ':00 / ' + CAST(MAX(CAST(SUBSTRING(hour_series, 3, LEN(hour_series) - 2) AS INT)) AS VARCHAR) + ':00' [interval]
					FROM hourly_block hb
					UNPIVOT(selected FOR [hour_series] IN (
							Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13,
							Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24
						)
					) AS P
					WHERE block_value_id = ISNULL(td.block_define_id,-10000298)
						AND selected = 1
				) hb
				OUTER APPLY (
					SELECT CASE
								WHEN (td.internal_desk_id = 17302 AND td.commodity_name = 'Power' AND td.deal_group_id IN (1, 3)) THEN 'CO'
								WHEN ((sd_type.source_deal_type_name) = 'Future' OR (sd_sub_type.source_deal_type_name) = 'Future') THEN 'FU'
								WHEN td.physical_financial_flag='p' THEN 'FW'
								WHEN ((sd_type.source_deal_type_name) LIKE '%Swap%' OR (sd_sub_type.source_deal_type_name) LIKE '%Swap%') AND td.physical_financial_flag = 'f' THEN 'SW'
								WHEN ((sd_type.source_deal_type_name) = 'Option' AND (sd_sub_type.source_deal_type_name) = 'Future') OR ((sd_type.source_deal_type_name) = 'Future' AND (sd_sub_type.source_deal_type_name) = 'Option') THEN 'OP_FU'
								WHEN ((sd_type.source_deal_type_name) = 'Option' AND (sd_sub_type.source_deal_type_name) = 'Forward') OR ((sd_type.source_deal_type_name) = 'Forward' AND (sd_sub_type.source_deal_type_name) = 'Option') THEN 'OP_FW'
								WHEN ((sd_type.source_deal_type_name) = 'Option' AND (sd_sub_type.source_deal_type_name) = 'Swap') OR ((sd_type.source_deal_type_name) = 'Swap' AND (sd_sub_type.source_deal_type_name) = 'Option') THEN 'OP_SW'
								WHEN ((sd_type.source_deal_type_name) = 'Option' AND (sd_sub_type.source_deal_type_name) = 'Option') THEN 'OP'
								WHEN (sd_type.source_deal_type_name) = 'Spread' AND (sd_sub_type.source_deal_type_name) = 'Spread' THEN 'SP'
								WHEN ((sd_type.source_deal_type_name) = 'Future' OR (sd_sub_type.source_deal_type_name) = 'Future') THEN 'FU'
								ELSE 'OT' 
							END [Contract Type]
				) rs_contract_type
				OUTER APPLY(
					SELECT TOP 1 ISNULL(gmv.clm6_value, '12:00:00') [timestamp], gmv.clm5_value [deal_group_id]
					FROM generic_mapping_header gmh
					INNER JOIN generic_mapping_values gmv ON gmh.mapping_table_id = gmv.mapping_table_id
					WHERE gmh.mapping_name = 'Remit'
						AND CAST(gmv.clm1_value AS VARCHAR(25)) = CAST(td.counterparty_id AS VARCHAR(25))
						AND CAST(gmv.clm2_value AS VARCHAR(25)) = CAST(td.contract_id AS VARCHAR(25))
						--AND CAST(gmv.clm5_value AS VARCHAR(25)) = CAST(td.deal_group_id  AS VARCHAR(25))
						AND CAST(gmv.clm3_value AS VARCHAR(25)) = CAST(td.internal_desk_id  AS VARCHAR(25))
				) gm_ts
				OUTER APPLY( SELECT gmv.clm3_value delivery_point_area
					 FROM generic_mapping_header gmh
					 INNER JOIN generic_mapping_values gmv
						ON gmv.mapping_table_id = gmh.mapping_table_id
					 WHERE gmh.mapping_name = 'ECM /Remit Delivery Point'
					 AND gmv.clm1_value = CAST(tdd.location_id AS VARCHAR(20))
					 AND gmv.clm2_value = CAST(scom.source_commodity_id AS VARCHAR(20))
				) tbl_delivery_point_area
			GROUP BY  td.source_deal_header_id
		
			IF NOT EXISTS (SELECT 1 FROM #source_remit_standard)
			BEGIN
				ROLLBACK
				EXEC spa_ErrorHandler -1, 'Regulatory Submission', 'spa_remit', 'Error', 'No Valid Deals found.', ''
				
				RETURN
			END
					
			INSERT INTO [source_remit_standard] (
				[source_deal_header_id], [deal_id], [sub_book_id], [market_id_participant_counterparty], [type_of_code_field_1], [trader_id_market_participant], [other_id_market_participant_counterparty],
				[type_of_code_field_4], [reporting_entity_id], [type_of_code_field_6], [beneficiary_id], [type_of_code_field_8], [trading_capacity_market_participant], [buy_sell_indicator], [initiator_aggressor],
				[contract_id], [contract_name], [contract_type], [energy_commodity], [fixing_index_or_reference_price], [settlement_method], [organised_market_place_id_otc], [contract_trading_hours],
				[last_trading_date_and_time], [transaction_timestamp], [unique_transaction_id], [linked_transaction_id], [linked_order_id], [voice_brokered], [price], [index_value], [price_currency],
				[notional_amount], [notional_currency], [quantity_volume], [total_notional_contract_quantity], [quantity_unit_field_40_and_41], [termination_date], [option_style], [option_type], [option_exercise_date],
				[option_strike_price], [order_id], [order_type], [order_condition], [order_status], [minimum_execution_volume], [price_limit], [undisclosed_volume], [order_duration], [delivery_point_or_zone],
				[delivery_start_date], [delivery_end_date], [duration], [load_type], [days_of_the_week], [load_delivery_intervals], [delivery_capacity], [quantity_unit_used_in_field_55], [price_time_interval_quantity],
				[action_type], [report_type], [create_date_from], [create_date_to], [acer_submission_status], [process_id]
			)
			SELECT * FROM #source_remit_standard
			
			IF EXISTS (SELECT 1 FROM source_remit_standard WHERE process_id = @process_id AND action_type IS NULL)
			BEGIN 
				DELETE FROM source_remit_standard WHERE process_id = @process_id AND action_type IS NULL
			END

			BEGIN --Validations starts
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'market_id_participant_counterparty', 'market_id_participant_counterparty Must not be NULL'
				FROM source_remit_standard
				WHERE market_id_participant_counterparty IS NULL
					AND process_id = @process_id
        	            	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'market_id_participant_counterparty', 'market_id_participant_counterparty Must have length of 12'
				FROM source_remit_standard
				WHERE LEN(market_id_participant_counterparty) <> 12
					AND process_id = @process_id        	    
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'other_id_market_participant_counterparty', 'other_id_market_participant_counterparty Must not be NULL'
				FROM source_remit_standard
				WHERE other_id_market_participant_counterparty IS NULL
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Sellers_acer_code', 'Sellers acer code Must have length of 12'
				FROM source_remit_standard
				WHERE LEN(other_id_market_participant_counterparty) <> 12
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Contract_type', 'Contract type ' + Contract_type + ' Not in Value List.'
				FROM source_remit_standard
				WHERE LEN(Contract_type) > 0
					AND Contract_type NOT IN ('SO', 'CO', 'FW', 'FU', 'OP', 'OP_FW', 'OP_FU', 'OP_SW', 'SP', 'SW', 'OT')
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Contract_type', 'Contract Type Must not be NULL'
				FROM source_remit_standard
				WHERE Contract_type IS NULL
					AND process_id = @process_id
        	            	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Commodity', 'Commodity ' + energy_commodity + ' Not in Value List.'
				FROM source_remit_standard
				WHERE LEN(energy_commodity) > 0
					AND energy_commodity NOT IN ('EL', 'NG')
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Commodity', 'Commodity Must not be NULL'
				FROM source_remit_standard
				WHERE energy_commodity IS NULL
					AND process_id = @process_id
        	            	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Settlement', 'Settlement ' + settlement_method + ' Not in Value List.'
				FROM source_remit_standard
				WHERE LEN(settlement_method) > 0
					AND settlement_method NOT IN ('P', 'C', 'O')
					AND process_id = @process_id
        	            	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Settlement', 'Settlement Must not be NULL'
				FROM source_remit_standard
				WHERE settlement_method IS NULL
					AND process_id = @process_id
        	            	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'currency', 'currency Should be NULL if price and index_value IS NULL'
				FROM source_remit_standard
				WHERE notional_currency IS NOT NULL
					AND process_id = @process_id
					AND (index_value IS NULL
					AND price IS NULL)
        	    
				IF EXISTS(SELECT 1 FROM source_remit_standard WHERE notional_currency IS NOT NULL AND process_id = @process_id)
				BEGIN
        			IF EXISTS(SELECT 1 FROM source_remit_standard WHERE notional_currency IS NOT NULL AND process_id = @process_id AND notional_currency NOT IN ('BGN', 'CHF', 'CZK', 'DKK', 'EUR', 'EUX', 'GBX', 'GBP', 'HRK', 'HUF', 'ISK', 'NOK', 'PCT', 'PLN', 'RON', 'SEK', 'USD', 'OTH'))
        			BEGIN
        				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
        				SELECT source_deal_header_id, 'Currency', 'Currency ' + notional_currency + ' Not in Value List.'
						FROM source_remit_standard
						WHERE notional_currency IS NOT NULL
        					AND notional_currency NOT IN ('BGN', 'CHF', 'CZK', 'DKK', 'EUR', 'EUX', 'GBX', 'GBP', 'HRK', 'HUF', 'ISK', 'NOK', 'PCT', 'PLN', 'RON', 'SEK', 'USD', 'OTH')
        					AND process_id = @process_id
        			END
				END
        	    
				--INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				--SELECT source_deal_header_id, 'quantity_unit_field_40_and_41', 'quantity_unit_field_40_and_41 ' + quantity_unit_field_40_and_41 + ' Not in Value List.'
				--FROM source_remit_standard
				--WHERE total_notional_contract_quantity IS NOT NULL
				--	AND quantity_unit_field_40_and_41 NOT IN ('KWh', 'MWh', 'GWh', 'Therm', 'Ktherm', 'MTherm', 'cm', 'mcm', 'MMBtu', 'GJ', 'Btu/d', 'MJ/d', '100MJ/d', 'MMJ/d', 'Mw', 'Mw / Mwh')
				--	AND process_id = @process_id 
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'delivery_point_or_zone', 'delivery_point_or_zone Must match [0-9][0-9][XYZTWV].+'
				FROM source_remit_standard
				WHERE dbo.IsValidDeliveryPoint(delivery_point_or_zone) = 0
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'delivery_point_or_zone', 'delivery_point_or_zone Must have length of 16' FROM   source_remit_standard WHERE  LEN(delivery_point_or_zone) <> 16 AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'delivery_point_or_zone', 'delivery_point_or_zone Must not be NULL'
				FROM source_remit_standard
				WHERE delivery_point_or_zone IS NULL
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Delivery_start_date', 'Delivery start date Must match YYYY-MM-DD'
				FROM source_remit_standard 
				WHERE dbo.IsValidDatePattern(CONVERT(VARCHAR(10), Delivery_start_date, 120)) = 0
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Delivery_start_date', 'Delivery start date Must not be NULL'
				FROM source_remit_standard
				WHERE Delivery_start_date IS NULL
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Delivery_end_date', 'Delivery end date Must match YYYY-MM-DD'
				FROM source_remit_standard
				WHERE dbo.IsValidDatePattern(CONVERT(VARCHAR(10), Delivery_end_date, 120)) = 0
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Delivery_end_date', 'Delivery end date Must not be NULL'
				FROM source_remit_standard
				WHERE Delivery_end_date IS NULL
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Price', 'Price Must not be NULL'
				FROM source_remit_standard
				WHERE price IS NULL
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'price_currency', 'price_currency Must not be NULL'
				FROM source_remit_standard
				WHERE price_currency IS NULL
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'transaction_timestamp', 'transaction_timestamp must not be NULL'
				FROM source_remit_standard
				WHERE transaction_timestamp IS NULL
					AND process_id = @process_id

				UPDATE srns
				SET srns.[error_validation_message] = s.msg
				FROM source_remit_standard srns
				INNER JOIN source_remit_standard vt_outer ON vt_outer.source_deal_header_id = srns.source_deal_header_id
					AND srns.process_id = @process_id
				CROSS APPLY (
        			SELECT STUFF((
						SELECT DISTINCT ', ' + ISNULL((tm.[messages]), '')
						FROM source_remit_standard vt
						INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
						WHERE tm.messages IS NOT NULL
							AND vt_outer.source_deal_header_id = vt.source_deal_header_id
						FOR XML PATH('')),1,1, '') AS msg
        			FROM source_remit_standard vt
					INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
					WHERE tm.messages IS NOT NULL
						AND vt_outer.source_deal_header_id = vt.source_deal_header_id
					GROUP BY vt.source_deal_header_id
				) s
			END
		END -- ends inserting data in source_remit_standard
		ELSE IF @report_type = 39405 ---Generate REMIT Report for Standard Contracts Execution
		BEGIN
			INSERT INTO [source_remit_standard] (
				[source_deal_header_id], [deal_id], [sub_book_id], [market_id_participant_counterparty], [type_of_code_field_1], [trader_id_market_participant],
				[other_id_market_participant_counterparty], [type_of_code_field_4], [reporting_entity_id], [type_of_code_field_6], [beneficiary_id],
				[type_of_code_field_8], [trading_capacity_market_participant], [buy_sell_indicator], [initiator_aggressor], [contract_id],
				[contract_name], [contract_type], [energy_commodity], [fixing_index_or_reference_price], [settlement_method], [organised_market_place_id_otc],
				[contract_trading_hours], [last_trading_date_and_time], [transaction_timestamp], [unique_transaction_id], [linked_transaction_id],
				[linked_order_id], [voice_brokered], [price], [index_value], [price_currency], [notional_amount], [notional_currency],
				[quantity_volume], [total_notional_contract_quantity], [quantity_unit_field_40_and_41], [termination_date], [option_style],
				[option_type], [option_exercise_date], [option_strike_price], [order_id], [order_type], [order_condition], [order_status],
				[minimum_execution_volume], [price_limit], [undisclosed_volume], [order_duration], [delivery_point_or_zone], [delivery_start_date],
				[delivery_end_date], [duration], [load_type], [days_of_the_week], [load_delivery_intervals], [delivery_capacity], [quantity_unit_used_in_field_55],
				[price_time_interval_quantity], [action_type], [report_type], [create_date_from], [create_date_to], [acer_submission_status], [process_id]
			)
			SELECT DISTINCT
				   source_deal_header_id = td.source_deal_header_id,
				   deal_id = MAX(td.deal_id),
				   sub_book_id = MAX(td.sub_book_id),
				   [ID of the market participant or counterparty] = MAX(tcuv.[Sub Code]),
				   [Type of code used in field 1] = 'ACE',--MAX(tcuv.[Sub Code Type]),
				   [trader_id_market_participant] = MAX(st.trader_id),
				   [ID of the other market participant or counterparty] = MAX(tcuv.[Deal Code]),
				   [Type of code used in field 4] = 'ACE',--MAX(tcuv.[Deal Code Type]),
				   [Reporting entity ID]= @RRM,
				   [Type of code used in field 6] = @RRM_code,
				   [Beneficiary ID] = NULL,
				   [Type of code used in field 8] = NULL,
				   [Trading capacity of the market participant or counterparty in field 1] = 'P',
				   [Buy Sell Indicator] = CASE WHEN MAX(UPPER(td.header_buy_sell_flag)) = 's' THEN CASE WHEN ROUND(MAX(ts.volume),5) >= 0 THEN 'B' ELSE 'S' END WHEN MAX(UPPER(td.header_buy_sell_flag)) = 'b' THEN CASE WHEN ROUND(MAX(ts.volume),5) < 0 THEN 'S' ELSE 'B' END ELSE '' END,
				   [initiator_aggressor] = NULL,
				   [Contract ID] = MAX(td.source_deal_header_id),
				   [contract_name] = 'EXECUTION',
				   [Contract type] = MAX(rs_contract_type.[Contract Type]),
				   [Energy commodity] = MAX(CASE WHEN (scom.commodity_name) IN ('ELectricity', 'Power') THEN 'EL' 
											  WHEN (scom.source_commodity_id) = -1 THEN 'NG' 
											  WHEN (scom.commodity_name) = 'LNG' THEN 'LNG'
											  END),
				   [fixing_index_or_reference_price] = NULL,
				   [Settlement method] = 'P',
				   --For contracts such as options on forwards, futures or swaps, as the option settles into the underlying forward, future or swap, this should be considered for physical delivery of the underlying contract and the value of GǣPGǥ should be reported.
				   --A majority of contracts traded under REMIT are for physical delivery, but there may also be derivative contracts that are not reported under EMIR and thus reported under REMIT
				   [organised_market_place_id_otc] = 'XBIL',
				   [contract_trading_hours] = NULL,
				   [last_trading_date_and_time] = NULL,
				   [transaction_timestamp] = CONVERT(VARCHAR(10), CAST(MAX(gmv_rid.[date]) AS DATETIME),126) + 'T' + MAX(gmv_rid.[time]), --This field should indicate the date each MP confirms the price and the quantity for the delivery period.
				   [unique_transaction_id] = td.source_deal_header_id,
				   [linked_transaction_id] = 'ENERCITY' + CAST(td.source_deal_header_id AS VARCHAR(40)),
				   [linked_order_id] = NULL,
				   [voice_brokered] = NULL,
				   [Price] = CASE WHEN MAX(ts.volume) <> 0 THEN ABS(ROUND(MAX(ts.settlement_amount)/MAX(ts.volume), 5)) ELSE 0 END,---amount divided by volume
				   [index_value] = NULL,
				   [price_currency] = CASE WHEN MAX(scur_fixed.currency_name) = 'Euro' THEN 'EUR'
										   WHEN MAX(scur_fixed.currency_name) = 'Ect' THEN 'EUX' 
										   WHEN MAX(scur_fixed.currency_name) = 'GPC' THEN 'GBX'
										   ELSE MAX(UPPER(scur_fixed.currency_name))
									  END,
				   [notional_amount] = ABS(ROUND(MAX(ts.settlement_amount), 5)),
				   [Notional currency] = CASE WHEN MAX(scur_fixed.currency_name) = 'Euro' THEN 'EUR'
											  WHEN MAX(scur_fixed.currency_name) = 'Ect' THEN 'EUX'
											  WHEN MAX(scur_fixed.currency_name) = 'GPC' THEN 'GBX'
											  ELSE MAX(UPPER(scur_fixed.currency_name))
										 END,
				   [quantity_volume] = NULL,
				   [Total notional contract quantity] = ABS(ROUND(MAX(ts.volume), 5)),
				   [quantity_unit_field_40_and_41] = CASE WHEN MAX(tsu.uom_name) = 'mwh' THEN 'MWh'
														  WHEN MAX(tsu.uom_name) = 'kwh' THEN 'KWh'
														  WHEN MAX(tsu.uom_name) = 'gwh' THEN 'GWh'
														  WHEN MAX(tsu.uom_name) = 'therm' THEN 'Therm'
														  WHEN MAX(tsu.uom_name) = 'mmbtu' THEN 'MMBtu'
														  WHEN MAX(tsu.uom_name) = 'gj' THEN 'GJ'
														  WHEN MAX(tsu.uom_name) = 'm3' THEN 'cm'
														  WHEN MAX(tsu.uom_name) = 'm3/hr' THEN 'cm'
														  WHEN MAX(tsu.uom_name) = 'm3(n,35.17)' THEN 'cm'
														  WHEN MAX(tsu.uom_name) = 'Metric Tons' THEN 'cm'
														  WHEN MAX(tsu.uom_name) = 'MT' THEN 'cm'
														  WHEN MAX(tsu.uom_name) = 'mw' THEN 'MW'
														  ELSE NULL
													 END,
				   [termination_date] = NULL,
				   [option_style] = NULL,
				   [option_type] = NULL,
				   [option_exercise_date] = NULL,
				   [option_strike_price] = NULL,
				   [order_id] = NULL,
				   [order_type] = NULL,
				   [order_condition] =  NULL,
				   [order_status] = NULL,
				   [minimum_execution_volume] = NULL,
				   [price_limit] = NULL,
				   [undisclosed_volume] = NULL,
				   [order_duration] = NULL,
				   [Delivery point or zone] = MAX(tbl_delivery_point_area.delivery_point_area),--MAX(sml.Location_Description),
				   [Delivery start date] = MAX(ts.term_start),
				   [Delivery end date] = MAX(ts.term_end),
				   [Delivery Duration] = NULL,
				   [Load Type] = CASE WHEN MAX(ISNULL(internal_desk_id,17300))=17302 THEN 'SH'
								   WHEN MAX(scom.commodity_name) IN ('Gas', 'Natural Gas', 'LNG', 'NG') THEN 'GD' 
								   WHEN MAX(sdv_block.code) LIKE '%Base%' THEN 'BL'
								   WHEN MAX(sdv_block.code) LIKE '%Peak%' THEN 'PL'
								   WHEN MAX(sdv_block.code) LIKE '%Offpeak%' THEN 'OP'
								   ELSE 'OT'
							  END,
				   [days_of_the_week] = NULL,
				   [load_delivery_intervals] = CASE WHEN MAX(scom.commodity_name) IN ('ELectricity', 'Power') THEN '00:00/24:00'
													WHEN MAX(scom.commodity_name) IN ('Gas', 'Natural Gas', 'LNG', 'NG') THEN '07:00/07:00'
													ELSE NULL
											   END,
				   [delivery_capacity] = NULL,
				   [quantity_unit_used_in_field_55] = NULL,
				   [price_time_interval_quantity] = NULL,
				   [Action type] = CASE WHEN @cancellation = '1' THEN 'E'---to cancel previously submitted report wtih action type= Error
										WHEN MAX(sdv_deal_status.value_id) = 5607 AND MAX(src_remit.source_deal_header_id) IS NOT NULL THEN 'C'---Deal with cancelled status
										WHEN MAX(src_remit.source_deal_header_id) IS NULL AND MAX(sdv_deal_status.value_id) <> 5607 THEN 'N'
										WHEN MAX(src_remit.source_deal_header_id) IS NOT NULL AND MAX(sdv_deal_status.value_id) <> 5607 THEN 'N' --'M'
										ELSE NULL
								   END,
				   report_type = @report_type,
				   create_date_from = @create_date_from,
				   create_date_to = @create_date_to,
				   acer_submission_status = 39500,
				   process_id= @process_id
			FROM #temp_deals td	
			LEFT JOIN #temp_settlement ts ON td.source_deal_header_id = ts.source_deal_header_id
			INNER JOIN #temp_deal_details tdd ON td.source_deal_header_id = tdd.source_deal_header_id --AND ts.term_start = tdd.term_start
			INNER JOIN source_deal_detail sdd  
				ON sdd.source_deal_header_id = tdd.source_deal_header_id
				ANd sdd.source_deal_detail_id = tdd.source_deal_detail_id
			LEFT JOIN #temp_cpty_udf_values tcuv ON tcuv.source_deal_header_id = td.source_deal_header_id
			LEFT JOIN source_uom tsu ON ISNULL(ts.volume_uom,sdd.position_uom) = tsu.source_uom_id
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tdd.curve_id
			LEFT JOIN source_commodity scom ON scom.source_commodity_id = ISNULL(spcd.commodity_id,td.commodity_id)
			LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = tdd.location_id
			LEFT JOIN static_data_value sdv_cntry ON sdv_cntry.value_id = sml.country
			LEFT JOIN source_remit_standard src_remit ON td.source_deal_header_id=src_remit.source_deal_header_id 
				AND src_remit.acer_submission_status IN (39501,39502)  --Submitted Deals on ACER
				AND ts.term_start = src_remit.delivery_start_date 
				AND ts.term_end = src_remit.delivery_end_date
			LEFT JOIN static_data_value sdv_deal_status ON sdv_deal_status.value_id = td.deal_status
			LEFT JOIN source_currency scur_fixed ON scur_fixed.source_currency_id = tdd.fixed_price_currency_id
			LEFT JOIN static_data_value sdv_block ON sdv_block.value_id = ISNULL(td.block_define_id,-10000298)
			LEFT JOIN source_deal_type sd_type ON sd_type.source_deal_type_id = td.source_deal_type_id
				AND sd_type.sub_type = 'n'
			LEFT JOIN source_deal_type sd_sub_type ON sd_sub_type.source_deal_type_id = td.deal_sub_type_type_id
				AND sd_sub_type.sub_type = 'y'
			LEFT JOIN contract_group cg ON cg.contract_id = td.contract_id
			LEFT JOIN source_traders st
				ON st.source_trader_id = td.trader_id
			OUTER APPLY (
        		SELECT CASE
							WHEN ((sd_type.source_deal_type_name) = 'Future' OR (sd_sub_type.source_deal_type_name) = 'Future') THEN 'FU'
							WHEN td.physical_financial_flag='p' THEN 'FW'
							WHEN ((sd_type.source_deal_type_name) like '%Swap%'  OR (sd_sub_type.source_deal_type_name) like '%Swap%') AND td.physical_financial_flag='f' THEN 'SW'
							WHEN ((sd_type.source_deal_type_name) = 'Option' AND (sd_sub_type.source_deal_type_name) = 'Future') OR ((sd_type.source_deal_type_name) = 'Future' AND (sd_sub_type.source_deal_type_name) = 'Option') THEN 'OP_FU'
							WHEN ((sd_type.source_deal_type_name) = 'Option' AND (sd_sub_type.source_deal_type_name) = 'Forward') OR ((sd_type.source_deal_type_name) = 'Forward' AND (sd_sub_type.source_deal_type_name) = 'Option') THEN 'OP_FW'
							WHEN ((sd_type.source_deal_type_name) = 'Option' AND (sd_sub_type.source_deal_type_name) = 'Swap') OR ((sd_type.source_deal_type_name) = 'Swap' AND (sd_sub_type.source_deal_type_name) = 'Option') THEN 'OP_SW'
							WHEN ((sd_type.source_deal_type_name) = 'Option' AND (sd_sub_type.source_deal_type_name) = 'Option') THEN 'OP'
							WHEN (sd_type.source_deal_type_name) = 'Spread' AND (sd_sub_type.source_deal_type_name) = 'Spread' THEN 'SP'
							WHEN ((sd_type.source_deal_type_name) = 'Future' OR (sd_sub_type.source_deal_type_name) = 'Future') THEN 'FU'
							ELSE 'OT'
						END [Contract Type]
			) rs_contract_type
			OUTER APPLY( SELECT gmv.clm3_value delivery_point_area
					 FROM generic_mapping_header gmh
					 INNER JOIN generic_mapping_values gmv
						ON gmv.mapping_table_id = gmh.mapping_table_id
					 WHERE gmh.mapping_name = 'ECM /Remit Delivery Point'
					 AND gmv.clm1_value = CAST(tdd.location_id AS VARCHAR(20))
					 AND gmv.clm2_value = CAST(scom.source_commodity_id AS VARCHAR(20))
				) tbl_delivery_point_area
			OUTER APPLY (
								SELECT clm3_value [date], clm4_value [time]
								FROM   generic_mapping_header gmh
									   INNER JOIN generic_mapping_values gmv
											ON  gmh.mapping_table_id = gmv.mapping_table_id
											AND gmh.mapping_name = 'Remit Invoice Date'
											--AND CAST(gmv.clm2_value AS VARCHAR(10)) = CAST(civv.counterparty_id AS VARCHAR(10))
											--AND CAST(gmv.clm1_value  AS VARCHAR(10))= CAST(civv.contract_id AS VARCHAR(10))
								WHERE  gmh.mapping_name = 'Remit Invoice Date'
								AND MONTH(TRY_CAST(gmv.clm3_value AS DATE)) = MONTH(DATEADD(month, 1, CAST(@create_date_from AS DATE)))
								AND YEAR(TRY_CAST(gmv.clm3_value AS DATE)) = YEAR(DATEADD(month, 1, CAST(@create_date_from AS DATE)))
							) gmv_rid
			GROUP BY td.source_deal_header_id
        	
			IF EXISTS (SELECT 1 FROM source_remit_standard WHERE process_id = @process_id AND action_type IS NULL)
			BEGIN 
				DELETE FROM source_remit_standard WHERE process_id = @process_id AND action_type IS NULL
			END    
        
			BEGIN -- Validation Starts	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'market_id_participant_counterparty', 'market_id_participant_counterparty Must not be NULL'
				FROM source_remit_standard
				WHERE market_id_participant_counterparty IS NULL
					AND process_id = @process_id        	    
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'market_id_participant_counterparty', 'market_id_participant_counterparty Must have length of 12'
				FROM source_remit_standard
				WHERE LEN(market_id_participant_counterparty) <> 12
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'other_id_market_participant_counterparty', 'other_id_market_participant_counterparty Must not be NULL'
				FROM source_remit_standard
				WHERE other_id_market_participant_counterparty IS NULL
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Sellers_acer_code', 'Sellers acer code Must have length of 12'
				FROM source_remit_standard
				WHERE LEN(other_id_market_participant_counterparty) <> 12
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Contract_type', 'Contract type ' + Contract_type + ' Not in Value List.'
				FROM source_remit_standard
				WHERE LEN(Contract_type) > 0
					AND Contract_type NOT IN ('SO', 'CO', 'FW', 'FU', 'OP', 'OP_FW', 'OP_FU', 'OP_SW', 'SP', 'SW', 'OT')
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Contract_type', 'Contract Type Must not be NULL'
				FROM source_remit_standard
				WHERE Contract_type IS NULL
					AND process_id = @process_id
        	            	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Commodity', 'Commodity ' + energy_commodity + ' Not in Value List.'
				FROM source_remit_standard
				WHERE LEN(energy_commodity) > 0
					AND energy_commodity NOT IN ('EL', 'NG')
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Commodity', 'Commodity Must not be NULL'
				FROM source_remit_standard
				WHERE energy_commodity IS NULL
					AND process_id = @process_id        	    
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Settlement', 'Settlement ' + settlement_method + ' Not in Value List.'
				FROM source_remit_standard
				WHERE LEN(settlement_method) > 0
					AND settlement_method NOT IN ('P', 'C', 'O')
					AND process_id = @process_id        	    
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Settlement', 'Settlement Must not be NULL'
				FROM source_remit_standard
				WHERE settlement_method IS NULL
					AND process_id = @process_id
			
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'currency', 'currency Should be NULL if price and index_value IS NULL'
				FROM source_remit_standard
				WHERE notional_currency IS NOT NULL
					AND process_id = @process_id
					AND (index_value IS NULL
					AND price IS NULL)
        	    
				IF EXISTS(SELECT 1 FROM source_remit_standard WHERE notional_currency IS NOT NULL AND process_id = @process_id)
				BEGIN
					IF EXISTS(SELECT 1 FROM source_remit_standard WHERE notional_currency IS NOT NULL AND process_id = @process_id AND notional_currency NOT IN ('BGN', 'CHF', 'CZK', 'DKK', 'EUR', 'EUX', 'GBX', 'GBP', 'HRK', 'HUF', 'ISK', 'NOK', 'PCT', 'PLN', 'RON', 'SEK', 'USD', 'OTH'))
					BEGIN
        				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
        				SELECT source_deal_header_id, 'Currency', 'Currency ' + notional_currency + ' Not in Value List.'
						FROM source_remit_standard
        				WHERE notional_currency IS NOT NULL
							AND notional_currency NOT IN ('BGN', 'CHF', 'CZK', 'DKK', 'EUR', 'EUX', 'GBX', 'GBP', 'HRK', 'HUF', 'ISK', 'NOK', 'PCT', 'PLN', 'RON', 'SEK', 'USD', 'OTH')
							AND process_id = @process_id
        			END
				END

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'quantity_unit_field_40_and_41', 'quantity_unit_field_40_and_41 ' + quantity_unit_field_40_and_41 + ' Not in Value List.'
				FROM source_remit_standard
				WHERE total_notional_contract_quantity IS NOT NULL
					AND quantity_unit_field_40_and_41 NOT IN ('KWh', 'MWh', 'GWh', 'Therm', 'Ktherm', 'MTherm', 'cm', 'mcm', 'MMBtu', 'GJ', 'Btu/d', 'MJ/d', '100MJ/d', 'MMJ/d', 'Mw', 'Mw / Mwh')
					AND process_id = @process_id 
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'delivery_point_or_zone', 'delivery_point_or_zone Must match [0-9][0-9][XYZTWV].+'
				FROM source_remit_standard
				WHERE dbo.IsValidDeliveryPoint(delivery_point_or_zone) = 0
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'delivery_point_or_zone', 'delivery_point_or_zone Must have length of 16'
				FROM source_remit_standard
				WHERE LEN(delivery_point_or_zone) <> 16
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'delivery_point_or_zone', 'delivery_point_or_zone Must not be NULL'
				FROM source_remit_standard
				WHERE delivery_point_or_zone IS NULL
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Delivery_start_date', 'Delivery start date Must match YYYY-MM-DD'
				FROM source_remit_standard
				WHERE dbo.IsValidDatePattern(CONVERT(VARCHAR(10), Delivery_start_date, 120)) = 0
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Delivery_start_date', 'Delivery start date Must not be NULL'
				FROM source_remit_standard
				WHERE Delivery_start_date IS NULL
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'Delivery_end_date', 'Delivery end date Must match YYYY-MM-DD'
				FROM source_remit_standard
				WHERE dbo.IsValidDatePattern(CONVERT(VARCHAR(10), Delivery_end_date, 120)) = 0
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages] )
				SELECT source_deal_header_id, 'Delivery_end_date', 'Delivery end date Must not be NULL'
				FROM source_remit_standard
				WHERE Delivery_end_date IS NULL
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages] )
				SELECT source_deal_header_id, 'Price', 'Price Must not be NULL'
				FROM source_remit_standard 
				WHERE price IS NULL
					AND process_id = @process_id
        	    
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'price_currency', 'price_currency Must not be NULL'
				FROM source_remit_standard
				WHERE price_currency IS NULL
					AND process_id = @process_id

				UPDATE srns
				SET srns.[error_validation_message] = s.msg
				FROM source_remit_standard srns
				INNER JOIN source_remit_standard vt_outer ON vt_outer.source_deal_header_id = srns.source_deal_header_id
					AND srns.process_id = @process_id
				CROSS APPLY (
        			SELECT STUFF((
						SELECT DISTINCT ', ' + ISNULL((tm.[messages]), '')
						FROM source_remit_standard vt INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
        				WHERE tm.messages IS NOT NULL
							AND vt_outer.source_deal_header_id = vt.source_deal_header_id
						FOR XML PATH('')), 1, 1, '') AS msg
        			FROM source_remit_standard vt
					INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
					WHERE tm.messages IS NOT NULL
						AND vt_outer.source_deal_header_id = vt.source_deal_header_id
        			GROUP BY vt.source_deal_header_id
				) s
			END 	        
		END -- ends inserting data in source_remit_standard execution
		ELSE IF @report_type = 39402 ---Generate REMIT Report for Transport
		BEGIN
			IF OBJECT_ID('tempdb..#collect_transport_deal_udf_data') IS NOT NULL
				DROP TABLE #collect_transport_deal_udf_data
				
			SELECT * 
			INTO #collect_transport_deal_udf_data
			FROM (
				SELECT sdh.source_deal_header_id,
					  ('C'+ CAST(ABS(uddft.field_id) AS VARCHAR(10))) Field_label,
					  udf_value
				FROM user_defined_deal_fields_template uddft
				INNER JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id
				INNER JOIN #temp_deals sdh ON sdh.source_deal_header_id = uddf.source_deal_header_id
				WHERE uddft.field_id IN (-10000000,-10000001,-10000002,-10000003, -10000004, -10000005, -10000006, -10000007, -10000008, -10000009, -10000010, -10000011)
				) a PIVOT(MAX(udf_value) FOR Field_label IN ([C10000000], [C10000001], [C10000002], [C10000003], [C10000004], [C10000005], [C10000006], [C10000007], [C10000008], [C10000009], [C10000010], [C10000011])
			) AS a

			INSERT INTO [source_remit_transport] (
				[source_deal_header_id], [deal_id], [sub_book_id], [sender_identification], [organised_market_place_id], [process_identification],
				[type_of_gas], [transportation_transaction_identification], [creation_date_and_time], [auction_open_date_and_time], [auction_end_date_and_time],
				[transportation_transaction_type], [start_date_and_time], [end_date_and_time], [offered_capacity], [capacity_category], [quantity],
				[measure_unit], [currency], [total_price], [fixed_or_floating_reserve_price], [reserve_price], [premium_price], [network_point_identification],			
				[bundling], [direction], [tso1_identification], [tso2_identification], [market_participant_identification], [balancing_group_or_portfolio_code],
				[procedure_applicable], [maximum_bid_amount], [minimum_bid_amount], [maximum_quantiy], [minimum_quantiy], [price_paid_to_tso],
				[price_transferee_pays_transferor], [transferor_identification], [transferee_identification], [bid_id], [auction_round_number], [bid_price],
				[bid_quantity], [action_type], [report_type], [create_date_from], [create_date_to], [acer_submission_status], [process_id]
			)
			SELECT DISTINCT
				   source_deal_header_id = td.source_deal_header_id,
				   deal_id = MAX(td.deal_id),
				   sub_book_id = MAX(td.sub_book_id),
				   sender_identification = '23X--121101ESPMJ',
				   [organised_market_place_id] = '21X-XXXXXXXXXXXY',
				   [process_identification] = MAX(tmp_udf.[C10000000]),
				   [type_of_gas] = MAX(rs_location.location_name),
				   [transportation_transaction_identification] = MAX(tmp_udf.[C10000001]),
				   [creation_date_and_time] = MAX(tmp_udf.[C10000002]),
				   [auction_open_date_and_time] = NULL,
				   [auction_end_date_and_time] = NULL,
				   [transportation_transaction_type] = CASE WHEN MAX(tmp_udf.[C10000003]) = 'Secondary' THEN 'ZSZ' ELSE NULL END,
				   [start_date_and_time] = CONVERT(VARCHAR(20), MAX(td.entire_term_start), 120),
				   [end_date_and_time] =  CONVERT(VARCHAR(20), MAX(td.entire_term_end), 120),
				   [offered_capacity] = NULL,
				   [capacity_category]= MAX(tmp_udf.[C10000004]),
				   [quantity] = ISNULL(MAX(rs_conv_factor.value), 1) * AVG(tdd.capacity),
				   [measure_unit] = 'KW1',
				   [currency] = LEFT(MAX(sc.currency_name), 3),
				   [total_price] = ISNULL((MAX(rs_total.total_price) / ISNULL(MAX(rs_conv_factor.value), 1)) * (ISNULL(MAX(rs_conv_factor.value), 1) * AVG(tdd.capacity)), 0) + ISNULL(SUM(CAST(udddf.udf_value AS FLOAT) /ISNULL((rs_conv_factor.value), 1)) * (sdd.capacity) *ISNULL((rs_conv_factor.value), 1),0),
				   [fixed_or_floating_reserve_price] = NULL,
				   [reserve_price] = NULL,
				   [premium_price] = NULL,
				   [network_point_identification] = MAX(tmp_udf.[C10000011]),
				   [bundling] = MAX(tmp_udf.[C10000005]),
				   [direction] = MAX(tmp_udf.[C10000006]),
				   [tso1_identification] = MAX(tmp_udf.[C10000007]),
				   [tso2_identification] = MAX(tmp_udf.[C10000008]),
				   [market_participant_identification] = '11X---RWE-GBS-S',
				   [balancing_group_or_portfolio_code] = 'GSESSENTNL',
				   [procedure_applicable] = MAX(tmp_udf.[C10000009]),
				   [maximum_bid_amount] = NULL,
				   [minimum_bid_amount] = NULL,
				   [maximum_quantiy] = NULL,
				   [minimum_quantiy] = NULL,
				   [price_paid_to_tso] = MAX(tmp_udf.[C10000010]) / ISNULL(MAX(rs_conv_factor.value), 1),
				   [price_transferee_pays_transferor] = ISNULL(MAX(rs_total.total_price) / ISNULL(MAX(rs_conv_factor.value), 1) ,0) + ISNULL(SUM(CAST(udddf.udf_value AS FLOAT)/ ISNULL(rs_conv_factor.value, 1)),0),
				   [transferor_identification] = '23X--121101ESPMJ',
				   [transferee_identification] = '23X--121101ESPMJ',
				   [bid_id] = NULL,
				   [auction_round_number] = NULL,
				   [bid_price] = NULL,
				   [bid_quantity] = NULL,
				   [Action type] = CASE
										WHEN MAX(sdv_deal_status.value_id) = 5607 AND MAX(srt.source_deal_header_id) IS NOT NULL THEN '63G' --Deal with cancelled status
										WHEN MAX(srt.source_deal_header_id) IS NULL AND MAX(sdv_deal_status.value_id) <> 5607 THEN '62G' -- New
										WHEN MAX(srt.source_deal_header_id) IS NOT NULL AND MAX(sdv_deal_status.value_id) <> 5607 THEN '66G' -- Modified
								   END,
        			report_type = @report_type,
        			create_date_from = @create_date_from,
        			create_date_to = @create_date_to,
        			acer_submission_status = 39500,
        			process_id = @process_id
			FROM #temp_deals td
			INNER JOIN #temp_deal_details tdd ON td.source_deal_header_id = tdd.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = tdd.source_deal_header_id
				AND tdd.leg = sdd.Leg
				AND tdd.term_start = sdd.term_start
			LEFT JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = sdd.source_deal_detail_id AND ISNUMERIC(udddf.udf_value) = 1
			LEFT JOIN user_defined_deal_fields_template udddft ON udddft.udf_template_id = udddf.udf_template_id
				AND udddft.field_name = -10000015
				AND ISNUMERIC(udddf.udf_value) = 1
			OUTER APPLY (
				SELECT CASE WHEN sdv.code IN ('Fluxys L', 'GTS') THEN 'LC1'
							WHEN sdv.code = 'Fluxys H' THEN 'HC1'
							ELSE NULL
						END location_name 
				FROM source_minor_location sml
				LEFT JOIN static_data_value sdv ON sdv.value_id = sml.grid_value_id
				WHERE sml.source_minor_location_id = tdd.location_id
					AND tdd.leg = 1
			) rs_location
			LEFT JOIN #collect_transport_deal_udf_data tmp_udf ON tmp_udf.source_deal_header_id = td.source_deal_header_id
			LEFT JOIN source_currency sc ON sc.source_currency_id = tdd.fixed_price_currency_id
			LEFT JOIN source_uom su ON su.source_uom_id = tdd.deal_volume_uom_id
			LEFT JOIN static_data_value sdv_deal_status ON sdv_deal_status.value_id = td.deal_status
			LEFT JOIN source_remit_transport srt ON td.source_deal_header_id = srt.source_deal_header_id
				AND srt.acer_submission_status IN (39501, 39502)--Submitted Deals on ACER        	           
			OUTER APPLY (
				SELECT SUM(CAST(uddf.udf_value AS NUMERIC(38, 20))) total_price
				FROM user_defined_deal_fields_template uddft
				INNER JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id
					AND td.source_deal_header_id = uddf.source_deal_header_id
				WHERE Field_label IN ('Term Capacity Fee', 'Annual Capacity Fee')
					AND ISNUMERIC(uddf.udf_value) = 1
			) rs_total 
			OUTER APPLY (
				--pick conversion_factor FROM FROM_source_uom_id to KWh
				SELECT MAX(conversion_factor) value
				FROM source_deal_detail tdd
				INNER JOIN source_uom su ON su.source_uom_id = tdd.deal_volume_uom_id
				INNER JOIN rec_volume_unit_conversion uc ON uc.FROM_source_uom_id = su.source_uom_id
				INNER JOIN source_uom su_to ON su_to.source_uom_id = uc.to_source_uom_id
					AND su_to.uom_name = 'KWh'
				WHERE tdd.source_deal_header_id = td.source_deal_header_id 
			) rs_conv_factor
			GROUP BY td.source_deal_header_id, rs_conv_factor.value, sdd.capacity
        	    
			IF EXISTS (SELECT 1 FROM source_remit_transport WHERE process_id = @process_id AND action_type IS NULL)
			BEGIN
				DELETE FROM source_remit_transport WHERE process_id = @process_id AND action_type IS NULL				
			END
		
			BEGIN --Validations
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'sender_identification', 'Sender Identification Must not be NULL'
				FROM source_remit_transport
				WHERE sender_identification IS NULL
					AND process_id = @process_id
				
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'organised_market_place_id', 'Organised Market Place ID Must not be NULL'
				FROM source_remit_transport
				WHERE organised_market_place_id IS NULL
					AND process_id = @process_id
			
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'process_identification', 'Process Identification Must not be NULL'
				FROM source_remit_transport
				WHERE process_identification IS NULL
					AND process_id = @process_id

    			INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'transportation_transaction_identification', 'Transportation Transaction Identification Must not be NULL.'
				FROM source_remit_transport
				WHERE transportation_transaction_identification IS NULL
					AND process_id = @process_id
				
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'creation_date_and_time', 'Creation Date and Time Must not be NULL.'
				FROM source_remit_transport
				WHERE creation_date_and_time IS NULL
					AND process_id = @process_id		

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'start_date_and_time', 'start_date_and_time  Must not be NULL.'
				FROM source_remit_transport
				WHERE start_date_and_time IS NULL
				AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'end_date_and_time', 'end_date_and_time Must not be NULL.'
				FROM source_remit_transport
				WHERE end_date_and_time IS NULL
					AND process_id = @process_id
		
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'measure_unit', 'Measure Unit '+ ISNULL(measure_unit, '') + ' Not in Value List.'
				FROM source_remit_transport
				WHERE measure_unit IS NULL
					OR measure_unit NOT IN ('KW1', 'KW2', 'HM1', 'HM2', 'TQH', 'TQD', 'MQ6', 'MQ7', 'KWH', 'GWH')
					AND process_id = @process_id
		
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'action_type', 'Action Type '+ ISNULL(action_type, '') + ' Not in Value List.'
				FROM source_remit_transport 
				WHERE action_type IS NULL 
					OR action_type NOT IN ('62G', '63G', '66G') 
					AND process_id = @process_id		
		
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'quantity', 'Quantity Must not be NULL'
				FROM source_remit_transport 
				WHERE quantity IS NULL 
					AND process_id = @process_id
				
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'currency', 'Currency Must not be ''EUR'''
				FROM source_remit_transport 
				WHERE currency IS NULL 
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'total_price', 'total_price Must not be null'
				FROM source_remit_transport 
				WHERE total_price IS NULL 
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'network_point_identification', 'Network Point Identification Must not be NULL.'
				FROM source_remit_transport 
				WHERE network_point_identification IS NULL
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'bundling', 'Bundling '+ ISNULL(bundling, '') + ' Must be ''ZEO'', ''ZEP''.'
				FROM source_remit_transport 
				WHERE bundling IS NULL 
					OR bundling NOT IN ('ZEO', 'ZEP') 
					AND process_id = @process_id
						
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'direction', 'Direction '+ ISNULL(direction, '') + ' Must be ''Z02'', ''Z03''.'
				FROM source_remit_transport 
				WHERE direction IS NULL 
					OR direction NOT IN ('Z02', 'Z03') 
					AND process_id = @process_id
		
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'tso1_identification', 'TSO1 Identification Must not be NULL'
				FROM source_remit_transport 
				WHERE tso1_identification IS NULL
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'tso2_identification', 'TSO2 Identification Must not be NULL'
				FROM source_remit_transport 
				WHERE tso2_identification IS NULL
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'market_participant_identification', 'market_participant_identification Identification Must not be NULL'
				FROM source_remit_transport 
				WHERE market_participant_identification IS NULL
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'balancing_group_or_portfolio_code', 'balancing_group_or_portfolio_codeMust not be NULL'
				FROM source_remit_transport 
				WHERE balancing_group_or_portfolio_code IS NULL
					AND process_id = @process_id
						
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'procedure_applicable', 'Procedure Applicable '+ ISNULL(procedure_applicable, '') + ' Must be ''A01'', ''A02'', ''A03'', ''A04''.'
				FROM source_remit_transport 
				WHERE procedure_applicable IS NULL 
					OR procedure_applicable NOT IN ('A01', 'A02', 'A03', 'A04') 
					AND process_id = @process_id
		
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'price_transferee_pays_transferor', 'Price Transferee pays transferor Must not be NULL'
				FROM source_remit_transport 
				WHERE price_transferee_pays_transferor IS NULL 
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'transferor_identification', 'Transferor Identification Must not be NULL'
				FROM source_remit_transport 
				WHERE transferor_identification IS NULL 
					AND process_id = @process_id

				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, 'transferee_identification', 'Transferee Identification Must not be NULL'
				FROM source_remit_transport 
				WHERE transferee_identification IS NULL 
					AND process_id = @process_id
												
				-- Generate error validation messages
				UPDATE srns
				SET srns.[error_validation_message] = s.msg 
				FROM source_remit_transport srns
				INNER JOIN source_remit_transport vt_outer ON vt_outer.source_deal_header_id = srns.source_deal_header_id
					AND srns.process_id = @process_id
				CROSS APPLY (
					SELECT STUFF((
								SELECT DISTINCT ', '  + ISNULL((tm.[messages]), '')
								FROM source_remit_transport vt
								INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
								WHERE tm.messages IS NOT NULL
									AND vt_outer.source_deal_header_id = vt.source_deal_header_id
								FOR XML PATH('')
						   ), 1, 1, '') AS msg
					FROM source_remit_transport vt
					INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
					WHERE tm.messages IS NOT NULL
						AND vt_outer.source_deal_header_id = vt.source_deal_header_id
					GROUP BY vt.source_deal_header_id
				) s
			END
		END-- ends inserting data in source_remit_transport
        	
		IF OBJECT_ID('tempdb..#temp_strTrade') IS NOT NULL
			DROP TABLE #temp_strTrade
        	
		IF OBJECT_ID('tempdb..#temp_strHash') IS NOT NULL
			DROP TABLE #temp_strHash
        	
		CREATE TABLE #temp_strTrade (
			source_deal_header_id INT,
			strTrade VARCHAR(MAX) COLLATE DATABASE_DEFAULT
		)

		CREATE TABLE #temp_strHash (
			source_deal_header_id INT,
			strHash VARCHAR(MAX) COLLATE DATABASE_DEFAULT
		)
        	
		--Start UTI Generation
		DECLARE @create_tab_sql VARCHAR(MAX)
	
		SET @create_tab_sql = '
			SELECT DISTINCT
				   dbo.FNAdateformat((create_date_from)) [Create Date From],
				   dbo.FNAdateformat((create_date_to)) [Create Date To],
				   sdv_rt.code [Report Type],
				   srns.create_user [User],
				   dbo.FNAdateformat((srns.create_ts)) [Create Time],
				   sdv_st.code [Status],
				   process_id [Process ID] 
			FROM ' + @phy_remit_table_name + ' srns
			LEFT JOIN static_data_value sdv_rt ON sdv_rt.value_id = srns.report_type
			LEFT JOIN static_data_value sdv_st ON sdv_st.value_id = srns.acer_submission_status
			WHERE sdv_st.value_id = 39500
		'
	
		IF @report_type IS NOT NULL
			SET @create_tab_sql = @create_tab_sql + ' AND srns.report_type=' + CAST(@report_type AS VARCHAR)
	
		IF @create_date_from IS NOT NULL
			SET @create_tab_sql = @create_tab_sql + ' AND (srns.create_date_from BETWEEN ''' + @create_date_from + ''' AND ''' + @create_date_to + ''''
	
		IF @create_date_to IS NOT NULL
			SET @create_tab_sql = @create_tab_sql + ' OR srns.create_date_to BETWEEN ''' + @create_date_from + ''' AND ''' + @create_date_to + ''')'
	
		SET @create_tab_sql = @create_tab_sql + ' ORDER BY dbo.FNAdateformat(create_date_from)'
		-- Above Executes after uti generations only
				
		IF ISNULL(@generate_uti, 0) = 1 AND @report_type = 39400 --To generate remit report for non-standard contracts with UTI codes
		BEGIN
			INSERT INTO #temp_strTrade(source_deal_header_id, strTrade)
			SELECT source_deal_header_id,
				   id_of_the_market_participant_or_counterparty + id_of_the_other_market_participant_or_counterparty +  contract_type + energy_commodity + settlement_method + CONVERT(VARCHAR(10), contract_date, 120) + delivery_point_or_zone + CONVERT(VARCHAR(10), Delivery_start_date, 120) + CONVERT(VARCHAR(10), Delivery_end_date, 120)
			FROM source_remit_non_standard vt
			WHERE process_id = @process_id
				AND error_validation_message IS NULL
		
			INSERT INTO #temp_strHash (source_deal_header_id, strHash)
			SELECT source_deal_header_id,
				   dbo.BASE64SHA256(strTrade)
			FROM #temp_strTrade
		
			UPDATE srns
			SET srns.hash_of_concatenated_values = ts.strHash
			FROM source_remit_non_standard srns
			INNER JOIN #temp_strHash ts ON srns.source_deal_header_id = ts.source_deal_header_id
			WHERE srns.process_id = @process_id
        	    
			UPDATE srns
			SET srns.progressive_number = rank_table.[rank]
			FROM (
				SELECT srns.source_deal_header_id deal_id,
					   RANK() OVER(PARTITION BY srns.hash_of_concatenated_values ORDER BY srns.id ASC) [rank],
					   srns.hash_of_concatenated_values
				FROM source_remit_non_standard srns
				WHERE srns.hash_of_concatenated_values IS NOT NULL
					AND srns.process_id = @process_id
			) rank_table
			INNER JOIN #temp_strHash ts ON rank_table.deal_id = ts.source_deal_header_id
			INNER JOIN source_remit_non_standard srns ON srns.source_deal_header_id = ts.source_deal_header_id
			WHERE srns.process_id = @process_id
        	    
			-- 42 is hardcoded length defined in excel uti generation logic
			UPDATE srns
			SET srns.contract_id = LEFT(srns.Hash_of_concatenated_values + REPLICATE('E', 42), 42) + RIGHT('00000' + CAST(srns.progressive_number AS VARCHAR), 3)
			FROM source_remit_non_standard srns
			INNER JOIN #temp_strHash ts ON srns.source_deal_header_id = ts.source_deal_header_id
			WHERE srns.process_id = @process_id
		END
        	
		IF ISNULL(@generate_uti, 0) = 1 AND @report_type IN (39401, 39405) ---To generate remit report for standard contracts with UTI codes / Standard Execution
		BEGIN
			INSERT INTO #temp_strTrade (source_deal_header_id, strTrade)
			SELECT vt.source_deal_header_id,
				   vt.market_id_participant_counterparty + vt.other_id_market_participant_counterparty + vt.contract_type + vt.energy_commodity + vt.settlement_method + CONVERT(VARCHAR(10), sdh.deal_date, 120) + CAST(vt.price AS VARCHAR(50)) + vt.price_currency + ou.quantity_volume + CASE WHEN ou.quantity_volume = '' THEN ''ELSE vt.quantity_unit_field_40_and_41 END + vt.delivery_point_or_zone + CONVERT(VARCHAR(10), vt.Delivery_start_date, 120) + CONVERT(VARCHAR(10), vt.Delivery_end_date, 120)
			FROM source_remit_standard vt
			OUTER APPLY (
				SELECT ISNULL(CAST(CASE WHEN vt.quantity_volume = 0 THEN NULL ELSE vt.quantity_volume END AS VARCHAR(50)), '') quantity_volume
			) ou
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = vt.source_deal_header_id
			WHERE vt.process_id = @process_id
				AND vt.error_validation_message IS NULL
			
			INSERT INTO #temp_strHash (source_deal_header_id, strHash)
			SELECT source_deal_header_id,
				   dbo.BASE64SHA256(strTrade)
			FROM #temp_strTrade
        	    
			UPDATE srns
			SET srns.hash_of_concatenated_values = ts.strHash
			FROM source_remit_standard srns
			INNER JOIN #temp_strHash ts ON srns.source_deal_header_id = ts.source_deal_header_id
			WHERE srns.process_id = @process_id
        	    
			UPDATE srns
			SET srns.progressive_number = rank_table.[rank]
			FROM (
				SELECT srns.source_deal_header_id deal_id,
					   RANK() OVER(PARTITION BY srns.hash_of_concatenated_values ORDER BY srns.id ASC) [rank],
					   srns.hash_of_concatenated_values
				FROM source_remit_standard srns
				WHERE srns.hash_of_concatenated_values IS NOT NULL
					AND srns.process_id = @process_id
			) rank_table
			INNER JOIN #temp_strHash ts ON rank_table.deal_id = ts.source_deal_header_id
			INNER JOIN source_remit_standard srns ON srns.source_deal_header_id = ts.source_deal_header_id
			WHERE srns.process_id = @process_id
        	    
			-- 42 is hardcoded length defined in excel uti generation logic
			UPDATE srns
			SET srns.unique_transaction_id = LEFT(srns.Hash_of_concatenated_values + REPLICATE('E', 42), 42) + RIGHT('00000' + CAST(srns.progressive_number AS VARCHAR), 3)
			FROM source_remit_standard srns
			INNER JOIN #temp_strHash ts ON srns.source_deal_header_id = ts.source_deal_header_id
			WHERE srns.process_id = @process_id
		END
       			
		COMMIT
		EXEC spa_ErrorHandler 0, 'Regulatory Submission', 'spa_source_remit', 'Success', 'Data Saved Successfully.', @process_id
	END TRY
    BEGIN CATCH
    	DECLARE @err_no INT
    	PRINT 'Catch Error:' + ERROR_MESSAGE()
    	ROLLBACK	
    	EXEC spa_ErrorHandler -1, 'Regulatory Submission', 'spa_source_remit', 'Error', 'Failed to save data.', ''
    END CATCH
END
ELSE IF @flag = 'x'
BEGIN
	BEGIN TRY
		DECLARE @status VARCHAR(100),
				@export_xml VARCHAR(MAX),
				@xml_file_path VARCHAR(1000)

		SELECT @xml_file_path = document_path + '\temp_Note\' + @process_id + '.xml'
		FROM connection_string
		
		IF @report_type IS NULL
		BEGIN
			EXEC spa_ErrorHandler -1, 'Regulatory Submission', 'spa_source_remit', 'Warning', 'XML for ECM cannot be generated.', @process_id
		END

		EXEC spa_convert_xml @process_id = @process_id,
							 @report_type = @report_type,
							 @mirror_reporting = @mirror_reporting,
							 @intragroup = @intragroup,
							 @call_from_export = 1,
							 @xml_out = @export_xml OUTPUT

		EXEC spa_write_to_file @export_xml , 'n', @xml_file_path, @status OUTPUT

		IF @status = 1
		BEGIN
			EXEC spa_ErrorHandler 0, 'Regulatory Submission', 'spa_source_remit', 'Success', 'XML Generated.', @process_id
		END
	END TRY
	BEGIN CATCH
		DECLARE @err VARCHAR(MAX)
		SET @err = 'Error Occurred<a href="#" onclick="$(this).next(''div'').toggle();"><br/><font size=1>Technical Details.</font></a>'		
		SET @err += '<div style="font-size:10px;color:red;display:none;" id="target"><b><i>' + ERROR_MESSAGE() + '</i></b></div>'
		EXEC spa_ErrorHandler -1, 'Regulatory Submission', 'spa_remit', 'Error', @err, @process_id
	END CATCH
END
ELSE IF @flag = 'c'
BEGIN
	IF OBJECT_ID('tempdb..#regulatory_tables') IS NOT NULL
		DROP TABLE #regulatory_tables

	CREATE TABLE #regulatory_tables (
		table_id CHAR(5) COLLATE DATABASE_DEFAULT,
		table_name VARCHAR(100) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #regulatory_tables
	SELECT NULL table_id, 'source_ecm' table_name UNION ALL
	SELECT '39400', 'source_remit_non_standard' UNION ALL
	SELECT '39401', 'source_remit_standard' UNION ALL
	SELECT '39402', 'source_remit_transport' UNION ALL
	SELECT '39405', 'source_remit_standard'
	SET @report_type = ISNULL(@report_type, -1)

	EXEC('
		DECLARE @tbl_name VARCHAR(100)

		SELECT @tbl_name = table_name
		FROM #regulatory_tables
		WHERE ISNULL(table_id, -1) = ' + @report_type + '

		EXEC(''
			IF EXISTS (SELECT 1 FROM '' + @tbl_name + '' WHERE process_id = ''''' + @process_id + ''''' AND error_validation_message IS NOT NULL AND acer_submission_status = 39500)
			BEGIN
				EXEC spa_ErrorHandler -1, ''''Regulatory Submission'''', ''''spa_remit'''', ''''Error'''', ''''Data contains some error. Please check details in excel detail.'''', ''''''''
			END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler 0, ''''Regulatory Submission'''', ''''spa_remit'''', ''''Success'''', ''''Data ready to submit.'''', ''''''''
			END
		'')
	')
	RETURN
END
ELSE IF @flag = 'r'
BEGIN
	SELECT @server_location = document_path + '\temp_note\ECM'
	FROM connection_string 

	IF OBJECT_ID('tempdb..#temp_ftp_files') IS NOT NULL
		DROP TABLE #temp_ftp_files
	CREATE TABLE #temp_ftp_files(ftp_url NVARCHAR(1000), dir_file NVARCHAR(2000))
	INSERT INTO #temp_ftp_files
	EXEC spa_list_ftp_contents_using_clr @file_transfer_endpoint_id, @remote_directory , @output_result OUTPUT

	DELETE FROM #temp_ftp_files 
	WHERE dir_file not like '%.xml%'

	SELECT @download_files = STUFF((SELECT DISTINCT ',' +  dir_file 
									FROM #temp_ftp_files
									WHERE (CHARINDEX('payload-id',dir_file) > 0 
									)
							FOR XML PATH('')), 1, 1, '')
	--SELECT @download_files
	IF @download_files IS NOT NULL
	BEGIN
		EXEC spa_download_file_from_ftp_using_clr @file_transfer_endpoint_id, @remote_directory, @download_files, @server_location, '.xml', @output_result OUTPUT
		
		IF OBJECT_ID('tempdb..#temp_remit_xml_data') IS NOT NULL
			DROP TABLE #temp_remit_xml_data

		CREATE TABLE #temp_remit_xml_data(
			receipt_timestamp  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			acer  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			data_type  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			reported_filename  NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			error_count  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			logical_record_identifier  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			logical_record_type  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			[status]  NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			error_code  NVARCHAR(500) COLLATE DATABASE_DEFAULT,
			error_description  NVARCHAR(2000) COLLATE DATABASE_DEFAULT,
			error_details  NVARCHAR(4000) COLLATE DATABASE_DEFAULT,
			comment  NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
			logical_record_timestamp  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			[receipt_type] NVARCHAR(300) COLLATE DATABASE_DEFAULT,
			download_file_name  NVARCHAR(100) COLLATE DATABASE_DEFAULT	
		)

		DECLARE @dir_file NVARCHAR(1000), @target_remote_directory VARCHAR(MAX)
				, @success_files VARCHAR(MAX)
				, @error_files VARCHAR(MAX)
		SELECT @success_files = '', @error_files = ''
		DECLARE db_cursor CURSOR FOR  
			SELECT dir_file 
			FROM #temp_ftp_files
		OPEN db_cursor   
		FETCH NEXT FROM db_cursor INTO @dir_file
		WHILE @@FETCH_STATUS = 0   
		BEGIN   
			SELECT @xml_file_content = dbo.FNAReadFileContents(@server_location + '\' + @dir_file)
			IF @xml_file_content IS NOT NULL
			BEGIN
				;WITH XMLNAMESPACES ('http://www.acer.europa.eu/REMIT/REMITReceiptSchema_V1.xsd' AS ns)	
				INSERT INTO #temp_remit_xml_data(receipt_timestamp,acer,data_type,reported_filename,error_count,logical_record_identifier,logical_record_type,[status],error_code,error_description,error_details,comment,logical_record_timestamp,[receipt_type], download_file_name)
				SELECT x.xml_col.value('(ns:receiptTimestamp)[1]','VARCHAR(100)') as [receipt_timestamp]
						, x.xml_col.value('(ns:rrmId/ns:acer)[1]','VARCHAR(100)') as [acer]
						, x.xml_col.value('(ns:dataType)[1]','VARCHAR(100)') [data_type]
						, x.xml_col.value('(ns:validationReceipt/ns:reportedFilename)[1]','VARCHAR(200)') [reported_filename]
						, x.xml_col.value('(ns:validationReceipt/ns:errorCount)[1]','VARCHAR(100)') [error_count]
						, child.xml_col.value('(ns:logicalRecordIdentifier)[1]','VARCHAR(100)') [logical_record_identifier]
						, child.xml_col.value('(ns:logicalRecordType)[1]','VARCHAR(100)') [logical_record_type]
						, child.xml_col.value('(ns:status)[1]','VARCHAR(200)') [status]
						, child.xml_col.value('(ns:errorCode)[1]','VARCHAR(500)') [error_code]
						, child.xml_col.value('(ns:errorDescription)[1]','VARCHAR(2000)') [error_description]
						, child.xml_col.value('(ns:errorDetails)[1]','VARCHAR(4000)') [error_details]
						, child.xml_col.value('(ns:comment)[1]','VARCHAR(1000)') [comment]
						, child.xml_col.value('(ns:logicalRecordTimestamp)[1]','VARCHAR(100)') [logical_record_timestamp]
						, x.xml_col.value('(ns:receiptType)[1]','VARCHAR(100)') [receipt_type]
						, @dir_file
				FROM ( SELECT  CAST(@xml_file_content AS xml) RawXml) b
				CROSS APPLY b.RawXml.nodes('/ns:REMITReceipt') x(xml_col)
				CROSS APPLY b.RawXml.nodes('/ns:REMITReceipt/ns:validationReceipt/ns:globalReceiptItem') child(xml_col);

				;WITH XMLNAMESPACES ('http://www.acer.europa.eu/REMIT/REMITReceiptSchema_V1.xsd' AS ns)
				INSERT INTO #temp_remit_xml_data(receipt_timestamp,acer,data_type,reported_filename,error_count,logical_record_identifier,logical_record_type,[status],error_code,error_description,error_details,comment,logical_record_timestamp,[receipt_type], download_file_name)
				SELECT x.xml_col.value('(ns:receiptTimestamp)[1]','VARCHAR(100)') as [receipt_timestamp]
					  , x.xml_col.value('(ns:rrmId/ns:acer)[1]','VARCHAR(100)') as [acer]
					  , x.xml_col.value('(ns:dataType)[1]','VARCHAR(100)') [data_type]
					  , x.xml_col.value('(ns:technicalReceipt/ns:reportedFilename)[1]','VARCHAR(100)') [reported_filename]
					  , NULL [error_count]
					  , NULL [logical_record_identifier]
					  , NULL [logical_record_type]
					  , x.xml_col.value('(ns:technicalReceipt/ns:status)[1]','VARCHAR(100)') [status]
					  , NULL [error_code]
					  , NULL [error_description]
					  , NULL [error_details]
					  , x.xml_col.value('(ns:technicalReceipt/ns:comment)[1]','VARCHAR(100)') [comment]
					  , x.xml_col.value('(/Envelope/TransmissionInformation/TransmissionCharacteristics/TransmissionTimeStamp)[1]','VARCHAR(100)') [logical_record_timestamp]
					  , x.xml_col.value('(ns:receiptType)[1]','VARCHAR(100)') [receipt_type]
					  , @dir_file
				FROM ( SELECT  CAST(@xml_file_content AS xml) RawXml) b
				CROSS APPLY b.RawXml.nodes('/Envelope/Payload/Message/ns:REMITReceipt') x(xml_col)
				WHERE x.xml_col.value('(ns:receiptType)[1]','VARCHAR(100)') = 'technical'

				;WITH XMLNAMESPACES ('http://www.acer.europa.eu/REMIT/REMITReceiptSchema_V1.xsd' AS ns)
				INSERT INTO #temp_remit_xml_data(receipt_timestamp,acer,data_type,reported_filename,error_count,logical_record_identifier,logical_record_type,[status],error_code,error_description,error_details,comment,logical_record_timestamp,[receipt_type], download_file_name)
				SELECT x.xml_col.value('(ns:receiptTimestamp)[1]','VARCHAR(100)') as [receipt_timestamp]
						, x.xml_col.value('(ns:rrmId/ns:acer)[1]','VARCHAR(100)') as [acer]
						, x.xml_col.value('(ns:dataType)[1]','VARCHAR(100)') [data_type]
						, x.xml_col.value('(ns:validationReceipt/ns:reportedFilename)[1]','VARCHAR(100)') [reported_filename]
						, x.xml_col.value('(ns:validationReceipt/ns:errorCount)[1]','VARCHAR(100)') [error_count]
						, child.xml_col.value('(ns:logicalRecordIdentifier)[1]','VARCHAR(100)') [logical_record_identifier]
						, child.xml_col.value('(ns:logicalRecordType)[1]','VARCHAR(100)') [logical_record_type]
						, child.xml_col.value('(ns:status)[1]','VARCHAR(100)') [status]
						, child.xml_col.value('(ns:errorCode)[1]','VARCHAR(100)') [error_code]
						, child.xml_col.value('(ns:errorDescription)[1]','VARCHAR(100)') [error_description]
						, child.xml_col.value('(ns:errorDetails)[1]','VARCHAR(100)') [error_details]
						, child.xml_col.value('(ns:comment)[1]','VARCHAR(100)') [comment]
						, child.xml_col.value('(ns:logicalRecordTimestamp)[1]','VARCHAR(100)') [logical_record_timestamp]
						, x.xml_col.value('(ns:receiptType)[1]','VARCHAR(100)') [receipt_type] 
						, @dir_file
				FROM ( SELECT  CAST(@xml_file_content AS xml) RawXml) b
				CROSS APPLY b.RawXml.nodes('/Envelope/Payload/Message/ns:REMITReceipt') x(xml_col)
				CROSS APPLY b.RawXml.nodes('/Envelope/Payload/Message/ns:REMITReceipt/ns:validationReceipt/ns:globalReceiptItem') child(xml_col)
				WHERE x.xml_col.value('(ns:receiptType)[1]','VARCHAR(100)') = 'validation'

				IF EXISTS(SELECT 1 FROM #temp_remit_xml_data WHERE [status] IN ('Accepted') AND download_file_name = @dir_file)
				BEGIN
					SELECT @success_files += IIF(NULLIF(@success_files,'') IS NULL, @dir_file, ',' + @dir_file)
		
				END
				ELSE IF EXISTS(SELECT 1 FROM #temp_remit_xml_data WHERE [status] IN ('Rejected_Content') AND download_file_name = @dir_file)
				BEGIN
					SELECT @error_files += IIF(NULLIF(@error_files,'') IS NULL, @dir_file, ',' + @dir_file)
				END
			END
			FETCH NEXT FROM db_cursor INTO @dir_file
		END   

		CLOSE db_cursor   
		DEALLOCATE db_cursor

		IF EXISTS(SELECT 1 FROM #temp_remit_xml_data WHERE [status] IN ('Accepted','Rejected_Content'))
		BEGIN
			IF @success_files IS NOT NULL
			BEGIN
				SET @target_remote_directory = @remote_directory + '/Processed/' + CONVERT(VARCHAR(7), GETDATE(), 120) + '/'
				EXEC spa_move_ftp_file_to_folder_using_clr @file_transfer_endpoint_id, @remote_directory , @target_remote_directory, @success_files, @output_result OUTPUT
			END

			IF @error_files IS NOT NULL
			BEGIN
				SET @target_remote_directory = @remote_location + '/Error/' + CONVERT(VARCHAR(7), GETDATE(), 120) + '/'
				EXEC spa_move_ftp_file_to_folder_using_clr @file_transfer_endpoint_id, @remote_directory , @target_remote_directory, @error_files, @output_result OUTPUT
			END



			SELECT @process_id = dbo.FNAGETNEWID()
					SELECT @user_name  = dbo.FNAdbuser()
					SELECT @file_name = 'Remit_Feedback_' + CONVERT(VARCHAR(30), GETDATE(),112) + REPLACE(CONVERT(VARCHAR(30), GETDATE(),108),':','') + '.csv'

					SELECT @process_table = dbo.FNAProcessTableName('remit_feedback_', dbo.FNADBUser(), @process_id) 
					SELECT @server_location = document_path
					FROM connection_string 
					SELECT @full_file_path = @server_location + '\temp_Note\' + @file_name

					EXEC('SELECT receipt_timestamp,acer,data_type,reported_filename,error_count,logical_record_identifier,logical_record_type,[status],error_code
								,error_description,error_details,comment
							   ,logical_record_timestamp
						  INTO ' + @process_table + ' FROM #temp_remit_xml_data
						  WHERE [status] IN (''Accepted'',''Rejected_Content'')
					')


					IF EXISTS(SELECT 1 FROM #temp_remit_xml_data temp
							WHERE ISNULL([status],'-1') IN ('Rejected_Content')
					)
					BEGIN
						EXEC spa_export_to_csv @process_table, @full_file_path, 'y', ',', 'n','y','n','n',@output_result OUTPUT
						INSERT INTO source_system_data_import_status (process_id, code, module, source, type, description)
						SELECT @process_id, temp.[status], 'Remit Feedback', 'Remit Feedback', temp.[status], temp.error_description + ' ' + ISNULL(temp.error_details,'') + ' ' + ISNULL(temp.comment,'')
						FROM #temp_remit_xml_data temp
						WHERE [status] IN ('Accepted','Rejected_Content')
						SELECT @url = '../../adiha.php.scripts/dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_name+''''
						SELECT @desc_success = 'Remit Feedback captured with error. <a target="_blank" href="' + @url + '">Click here.</a>'
					END
					ELSE
					BEGIN
						EXEC spa_export_to_csv @process_table, @full_file_path, 'y', ',', 'n','y','n','n',@output_result OUTPUT
						SET @desc_success = 'Remit Feedback captured successfully.<br>'
											+  '<b>Response :</b> ' + 'Success'
					END

					INSERT INTO message_board(user_login_id, source, [description], url_desc, url, [type], job_name, as_of_date, process_id, process_type)
					SELECT DISTINCT au.user_login_id, 'Remit Feedback' , ISNULL(@desc_success, 'Description is null'), NULL, NULL, 's',NULL, NULL,@process_id,NULL
					FROM dbo.application_role_user aru
					INNER JOIN dbo.application_security_role asr ON aru.role_id = asr.role_id 
					INNER JOIN dbo.application_users au ON aru.user_login_id = au.user_login_id
					WHERE (au.user_active = 'y') AND (asr.role_type_value_id = 22) AND au.user_emal_add IS NOT NULL
					GROUP BY au.user_login_id, au.user_emal_add	

					INSERT INTO email_notes
						(
							notes_subject,
							notes_text,
							send_from,
							send_to,
							send_status,
							active_flag,
							attachment_file_name
						)		
					SELECT DB_NAME() + ': Remit Feedback',
						'Dear <b>' + MAX(au.user_l_name) + '</b><br><br>

						 Remit Feedback has been captured. Please check the Summary Report attached in email.',
						'noreply@pioneersolutionsglobal.com',
						au.user_emal_add,
						'n',
						'y',
						@full_file_path
					FROM dbo.application_role_user aru
					INNER JOIN dbo.application_security_role asr ON aru.role_id = asr.role_id 
					INNER JOIN dbo.application_users au ON aru.user_login_id = au.user_login_id
					WHERE (au.user_active = 'y') AND (asr.role_type_value_id = 22) AND au.user_emal_add IS NOT NULL
					GROUP BY au.user_login_id, au.user_emal_add 

			IF OBJECT_ID('tempdb..#temp_source_remit_data') IS NOT NULL
				DROP TABLE #temp_source_remit_data

			CREATE TABLE #temp_source_remit_data(
				id INT,
				record_identifier INT,
				source_deal_header_id INT,
				deal_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
				report_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
				process_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				report_type INT
			)

			INSERT INTO #temp_source_remit_data(id,record_identifier,source_deal_header_id,deal_id,process_id,report_type,report_id)
			SELECT srns.id, ROW_NUMBER() OVER(PARTITION BY srns.[process_id] ORDER BY srns.[Action_type]),  srns.source_deal_header_id, srns.deal_id, srns.process_id, 39400, tbl.reported_filename
			FROM  ( SELECT reported_filename
						 FROM #temp_remit_xml_data
						 GROUP BY reported_filename
			) tbl
			INNER JOIN source_remit_non_standard srns
			ON srns.file_export_name = tbl.reported_filename
			UNION
			SELECT srns.id, ROW_NUMBER() OVER(PARTITION BY srns.[process_id] ORDER BY srns.[Action_type]),  srns.source_deal_header_id, srns.deal_id, srns.process_id, srns.report_type, tbl.reported_filename
			FROM  ( SELECT reported_filename
						 FROM #temp_remit_xml_data
						 GROUP BY reported_filename
			) tbl
			INNER JOIN source_remit_standard srns
			ON srns.file_export_name = tbl.reported_filename
			
			IF OBJECT_ID('tempdb..#temp_source_remit') IS NOT NULL
				DROP TABLE #temp_source_remit

			CREATE TABLE #temp_source_remit(
				id INT,
				record_identifier INT,
				source_deal_header_id INT,
				deal_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
				report_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
				process_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				report_type INT,
				[status] VARCHAR(200) COLLATE DATABASE_DEFAULT,
				[receipt_type] VARCHAR(200) COLLATE DATABASE_DEFAULT
			)


			INSERT INTO #temp_source_remit(id,record_identifier,source_deal_header_id,deal_id,process_id,report_type,report_id, [status], [receipt_type])
			SELECT srns.id, srns.record_identifier,  srns.source_deal_header_id, srns.deal_id, srns.process_id, srns.report_type, trxd.reported_filename, trxd.[status], trxd.[receipt_type]
			FROM #temp_remit_xml_data trxd
			INNER JOIN ( SELECT MAX(receipt_timestamp) receipt_timestamp, reported_filename
						 FROM #temp_remit_xml_data
						 GROUP BY reported_filename
			) tbl ON tbl.reported_filename = trxd.reported_filename
			AND tbl.receipt_timestamp = trxd.receipt_timestamp
			INNER JOIN #temp_source_remit_data srns
				ON srns.report_id = trxd.reported_filename
				AND srns.record_identifier = ISNULL(trxd.logical_record_identifier,srns.record_identifier)
			
			INSERT INTO source_remit_audit(message_received_timestamp, [status],  error_code, error_description, [type], [source_file_name], [action], [uti_id], [trade_id])
			SELECT DISTINCT receipt_timestamp, trxd.[status], error_code, ISNULL(error_description,'') + ' ' + ISNULL(error_details,'') + ' ' + ISNULL(comment,'')
				  , tsr.report_type
				  , reported_filename
				  , trxd.[receipt_type]
				  , tsr.id
				  , tsr.deal_id
			FROM #temp_remit_xml_data trxd
			INNER JOIN #temp_source_remit tsr
				ON tsr.report_id = trxd.reported_filename
				AND tsr.record_identifier = ISNULL(trxd.logical_record_identifier,tsr.record_identifier)

			UPDATE srns
				SET srns.acer_submission_status = CASE WHEN tsr.[receipt_type] = 'validation' 
													      THEN CASE WHEN tsr.[status] IN ('Accepted') THEN 39501 ELSE 39503 END
													   WHEN tsr.[receipt_type] = 'technical' 
													      THEN CASE WHEN tsr.[status] IN ('Accepted') THEN 39502 ELSE 39503 END
												  END
			FROM #temp_source_remit tsr
			INNER JOIN source_remit_non_standard srns
				ON CAST(srns.id AS VARCHAR(20)) = tsr.id
			WHERE tsr.report_type = 39400

			UPDATE srns
				SET srns.acer_submission_status = CASE WHEN tsr.[receipt_type] = 'validation' 
													      THEN CASE WHEN tsr.[status] IN ('Accepted') THEN 39501 ELSE 39503 END
													   WHEN tsr.[receipt_type] = 'technical' 
													      THEN CASE WHEN tsr.[status] IN ('Accepted') THEN 39502 ELSE 39503 END
												  END
			FROM #temp_source_remit tsr
			INNER JOIN source_remit_standard srns
				ON CAST(srns.id AS VARCHAR(20)) = tsr.id
			WHERE tsr.report_type <> 39400
			
		END
	END
END
