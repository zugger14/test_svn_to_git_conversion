BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = '26B22427_56C6_466F_A207_A5DCC04CD25B'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Trayport Deal Import Final'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				-- Added to preserve rule detail like folder location, FTP URL, username and password.
				IF OBJECT_ID('tempdb..#pre_ixp_import_data_source') IS NOT NULL
					DROP TABLE #pre_ixp_import_data_source

				SELECT rules_id
					,folder_location
					,ftp_url
					,ftp_username
					,ftp_password 
				INTO #pre_ixp_import_data_source
				FROM ixp_import_data_source 
				WHERE rules_id = @old_ixp_rule_id

				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Trayport Deal Import Final' ,
					'N' ,
					NULL ,
					'EXEC spa_trayport_deal_term_mapping @process_table = ''[final_process_table]''

DECLARE @set_process_id VARCHAR(40)
	, @row_count INT

SELECT @set_process_id = REVERSE(SUBSTRING(REVERSE(''[final_process_table]''), 0,37))

SELECT @row_count = count(*) FROM [temp_process_table]

INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation, rules_name) 
SELECT DISTINCT @set_process_id,
	''Error'',
	''Import Data'',
	''ixp_source_deal_template'',
	''Error'',
	CAST(@row_count AS VARCHAR(5)),
	''Please verify data.'',
	''Trayport''
FROM [temp_process_table] t
LEFT JOIN term_map_detail tmd
	ON t.FirstSequenceItemName = tmd.term_code
WHERE tmd.term_map_id IS NULL

INSERT INTO source_system_data_import_status_detail(
	process_id
	, source
	, [type]
	, description
	, type_error
)
SELECT DISTINCT @set_process_id
	, ''ixp_source_deal_template''
	, ''Missing Value''
	, ''Data '''''' + t.[FirstSequenceItemName] + '''''' not found for Column: FirstSequenceItemName. <span style=''''cursor:pointer'''' onClick=''''window.top.TRMWinHyperlink(20013000, "'' + t.[FirstSequenceItemName] + ''")''''><font color=#0000ff><u><l> Create '' + t.[FirstSequenceItemName] + ''<l></u></font></span>''
	, ''Error''
FROM [temp_process_table] t
LEFT JOIN term_map_detail tmd
	ON t.FirstSequenceItemName = tmd.term_code
WHERE tmd.term_map_id IS NULL

DELETE t
FROM [temp_process_table] t
LEFT JOIN term_map_detail tmd
	ON t.FirstSequenceItemName = tmd.term_code
WHERE tmd.term_map_id IS NULL

UPDATE a
SET a.term_start = CAST(tmd.term_start AS DATE)
	, a.term_end = CAST(tmd.term_end AS DATE)
FROM [final_process_table] a
INNER JOIN term_map_detail tmd
	ON a.udf_value1 = tmd.term_code
	
UPDATE t
    SET t.[CommingledProduct] = sdv.code
FROM
[temp_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[CommingledProduct] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN static_data_value sdv
	ON sdv.value_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Trayport Block Mapping''

UPDATE t
    SET t.[AggressorTrader] = st.trader_id
FROM
[temp_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[AggressorTrader] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_traders st
	ON st.source_trader_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Trayport Trader Mapping''

UPDATE t
SET t.[AggressorBroker] = cg.contract_name
FROM
[temp_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[AggressorBroker] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN contract_group cg
	ON cg.contract_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Trayport Broker Mapping''

DECLARE @cpty_mapping_id INT 
SELECT  @cpty_mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = ''Trayport Counterparty Mapping'' 

UPDATE t
SET t.[AggressorCompany] = ISNULL(sc.counterparty_id, ''Default_Counterparty'')
FROM
[temp_process_table] t
LEFT JOIN generic_mapping_values gmv ON ISNULL(t.[AggressorCompany], '''') = ISNULL(gmv.clm1_value, '''')
	AND gmv.mapping_table_id = @cpty_mapping_id
LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = gmv.clm2_value

UPDATE t
SET t.[InitiatorCompany] = ISNULL(sc.counterparty_id, ''Default_Counterparty'')
FROM
[temp_process_table] t
LEFT JOIN generic_mapping_values gmv ON ISNULL(t.[InitiatorCompany], '''') = ISNULL(gmv.clm1_value, '''')
AND gmv.mapping_table_id = @cpty_mapping_id
LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = gmv.clm2_value

UPDATE t
SET t.[InstName] = spcd.curve_id
FROM
[temp_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[InstName] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_price_curve_def spcd
	ON spcd.source_curve_def_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Trayport product Mapping''

UPDATE t
SET t.[Book] = ssbm.logical_name
FROM
[temp_process_table] t
INNER JOIN generic_mapping_values gmv
    ON ISNULL(t.[Book], '''') = ISNULL(gmv.clm3_value, '''')
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_system_book_map ssbm
	ON ssbm.book_deal_type_map_id = gmv.clm4_value
WHERE gmh.mapping_name = ''Trayport Book Mapping''

',
					'DECLARE @mapping_table_id INT
SELECT @mapping_table_id = mapping_table_id 
FROM generic_mapping_header 
WHERE mapping_name = ''Trayport Contract Mapping''

UPDATE sdh
SET contract_id = gmv.clm3_value
FROM [temp_process_table] s2
INNER JOIN source_counterparty sc ON sc.counterparty_id = s2.counterparty_id
INNER JOIN source_commodity com ON com.commodity_id = s2.commodity_id
INNER JOIN source_deal_header sdh ON sdh.deal_id = s2.deal_id
    AND sdh.counterparty_id = sc.source_counterparty_id
    AND sdh.commodity_id = com.source_commodity_id
INNER JOIN generic_mapping_values gmv ON  mapping_table_id = @mapping_table_id
    AND gmv.clm1_value = sdh.counterparty_id
    AND  gmv.clm2_value = sdh.commodity_id

DECLARE @set_process_id VARCHAR(40)
	, @hyperlink_row_count INT
	, @row_count INT

SELECT @set_process_id = REVERSE(SUBSTRING(REVERSE(''[temp_process_table]''), 0,37))

SELECT @row_count = [description] 
FROM source_system_data_import_status 
WHERE process_id = @set_process_id
	AND rules_name = ''Trayport''

SELECT @hyperlink_row_count = count(*) 
FROM source_system_data_import_status_detail 
WHERE process_id = @set_process_id 
	AND description like ''%Create %''

IF @row_count > @hyperlink_row_count
BEGIN
	DELETE FROM source_system_data_import_status WHERE process_id = @set_process_id AND rules_name = ''Trayport''
END

',
					'i' ,
					'n' ,
					@admin_user ,
					23502,
					1,
					'26B22427_56C6_466F_A207_A5DCC04CD25B'
					 )

				SET @ixp_rules_id_new = SCOPE_IDENTITY()
				EXEC spa_print 	@ixp_rules_id_new

				UPDATE ixp
				SET import_export_id = @ixp_rules_id_new
				FROM ipx_privileges ixp
				WHERE ixp.import_export_id = @old_ixp_rule_id
		END
				
				

		ELSE 
		BEGIN
			SET @ixp_rules_id_new = @old_ixp_rule_id
			EXEC spa_print 	@ixp_rules_id_new
			
			UPDATE
			ixp_rules
			SET ixp_rules_name = 'Trayport Deal Import Final'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = 'EXEC spa_trayport_deal_term_mapping @process_table = ''[final_process_table]''

DECLARE @set_process_id VARCHAR(40)
	, @row_count INT

SELECT @set_process_id = REVERSE(SUBSTRING(REVERSE(''[final_process_table]''), 0,37))

SELECT @row_count = count(*) FROM [temp_process_table]

INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation, rules_name) 
SELECT DISTINCT @set_process_id,
	''Error'',
	''Import Data'',
	''ixp_source_deal_template'',
	''Error'',
	CAST(@row_count AS VARCHAR(5)),
	''Please verify data.'',
	''Trayport''
FROM [temp_process_table] t
LEFT JOIN term_map_detail tmd
	ON t.FirstSequenceItemName = tmd.term_code
WHERE tmd.term_map_id IS NULL

INSERT INTO source_system_data_import_status_detail(
	process_id
	, source
	, [type]
	, description
	, type_error
)
SELECT DISTINCT @set_process_id
	, ''ixp_source_deal_template''
	, ''Missing Value''
	, ''Data '''''' + t.[FirstSequenceItemName] + '''''' not found for Column: FirstSequenceItemName. <span style=''''cursor:pointer'''' onClick=''''window.top.TRMWinHyperlink(20013000, "'' + t.[FirstSequenceItemName] + ''")''''><font color=#0000ff><u><l> Create '' + t.[FirstSequenceItemName] + ''<l></u></font></span>''
	, ''Error''
FROM [temp_process_table] t
LEFT JOIN term_map_detail tmd
	ON t.FirstSequenceItemName = tmd.term_code
WHERE tmd.term_map_id IS NULL

DELETE t
FROM [temp_process_table] t
LEFT JOIN term_map_detail tmd
	ON t.FirstSequenceItemName = tmd.term_code
WHERE tmd.term_map_id IS NULL

UPDATE a
SET a.term_start = CAST(tmd.term_start AS DATE)
	, a.term_end = CAST(tmd.term_end AS DATE)
FROM [final_process_table] a
INNER JOIN term_map_detail tmd
	ON a.udf_value1 = tmd.term_code
	
UPDATE t
    SET t.[CommingledProduct] = sdv.code
FROM
[temp_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[CommingledProduct] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN static_data_value sdv
	ON sdv.value_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Trayport Block Mapping''

UPDATE t
    SET t.[AggressorTrader] = st.trader_id
FROM
[temp_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[AggressorTrader] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_traders st
	ON st.source_trader_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Trayport Trader Mapping''

UPDATE t
SET t.[AggressorBroker] = cg.contract_name
FROM
[temp_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[AggressorBroker] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN contract_group cg
	ON cg.contract_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Trayport Broker Mapping''

DECLARE @cpty_mapping_id INT 
SELECT  @cpty_mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = ''Trayport Counterparty Mapping'' 

UPDATE t
SET t.[AggressorCompany] = ISNULL(sc.counterparty_id, ''Default_Counterparty'')
FROM
[temp_process_table] t
LEFT JOIN generic_mapping_values gmv ON ISNULL(t.[AggressorCompany], '''') = ISNULL(gmv.clm1_value, '''')
	AND gmv.mapping_table_id = @cpty_mapping_id
LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = gmv.clm2_value

UPDATE t
SET t.[InitiatorCompany] = ISNULL(sc.counterparty_id, ''Default_Counterparty'')
FROM
[temp_process_table] t
LEFT JOIN generic_mapping_values gmv ON ISNULL(t.[InitiatorCompany], '''') = ISNULL(gmv.clm1_value, '''')
AND gmv.mapping_table_id = @cpty_mapping_id
LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = gmv.clm2_value

UPDATE t
SET t.[InstName] = spcd.curve_id
FROM
[temp_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[InstName] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_price_curve_def spcd
	ON spcd.source_curve_def_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Trayport product Mapping''

UPDATE t
SET t.[Book] = ssbm.logical_name
FROM
[temp_process_table] t
INNER JOIN generic_mapping_values gmv
    ON ISNULL(t.[Book], '''') = ISNULL(gmv.clm3_value, '''')
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_system_book_map ssbm
	ON ssbm.book_deal_type_map_id = gmv.clm4_value
WHERE gmh.mapping_name = ''Trayport Book Mapping''

'
				, after_insert_trigger = 'DECLARE @mapping_table_id INT
SELECT @mapping_table_id = mapping_table_id 
FROM generic_mapping_header 
WHERE mapping_name = ''Trayport Contract Mapping''

UPDATE sdh
SET contract_id = gmv.clm3_value
FROM [temp_process_table] s2
INNER JOIN source_counterparty sc ON sc.counterparty_id = s2.counterparty_id
INNER JOIN source_commodity com ON com.commodity_id = s2.commodity_id
INNER JOIN source_deal_header sdh ON sdh.deal_id = s2.deal_id
    AND sdh.counterparty_id = sc.source_counterparty_id
    AND sdh.commodity_id = com.source_commodity_id
INNER JOIN generic_mapping_values gmv ON  mapping_table_id = @mapping_table_id
    AND gmv.clm1_value = sdh.counterparty_id
    AND  gmv.clm2_value = sdh.commodity_id

DECLARE @set_process_id VARCHAR(40)
	, @hyperlink_row_count INT
	, @row_count INT

SELECT @set_process_id = REVERSE(SUBSTRING(REVERSE(''[temp_process_table]''), 0,37))

SELECT @row_count = [description] 
FROM source_system_data_import_status 
WHERE process_id = @set_process_id
	AND rules_name = ''Trayport''

SELECT @hyperlink_row_count = count(*) 
FROM source_system_data_import_status_detail 
WHERE process_id = @set_process_id 
	AND description like ''%Create %''

IF @row_count > @hyperlink_row_count
BEGIN
	DELETE FROM source_system_data_import_status WHERE process_id = @set_process_id AND rules_name = ''Trayport''
END

'
				, import_export_flag = 'i'
				, ixp_owner = @admin_user
				, ixp_category = 23502
				, is_system_import = 'n'
				, is_active = 1
			WHERE ixp_rules_id = @ixp_rules_id_new
				
		END

				
INSERT INTO ixp_export_tables (ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number)  
								   SELECT @ixp_rules_id_new,
										  it.ixp_tables_id,
										  dependent_table.ixp_tables_id,
										  0,
										  0,
										  0
									FROM ixp_tables it
									LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
									WHERE it.ixp_tables_name = 'ixp_source_deal_template'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, is_ftp, ftp_url, ftp_username, ftp_password, clr_function_id, ws_function_name, use_sftp, enable_email_import, send_email_import_reply)
					SELECT @ixp_rules_id_new,
						   NULL,
						   NULL,
						   '\\SG-D-WEB01\shared_docs_TRMTracker_Release\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'tdi',
						   '0',
						   NULL,
						   'n',
						   0,
						   '',
						   '0',
						   'n',
						   'Sheet1',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   '0',
						   '',
						   '',
						   0x01000000263DB10F42BB96C141A7F6E976A9423B16ED85726763AC58,
						   icf.ixp_clr_functions_id,
						   '', 
						   '0',
						   '0',
						   '0'
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new
						IF OBJECT_ID('tempdb..#pre_ixp_import_data_source') IS NOT NULL
						BEGIN
							UPDATE iids
							SET folder_location = piids.folder_location
								, ftp_url = piids.ftp_url
								, ftp_username = piids.ftp_username
								, ftp_password = piids.ftp_password
							FROM ixp_import_data_source iids
							INNER JOIN #pre_ixp_import_data_source piids 
							ON iids.rules_id = piids.rules_id
						END
					

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id)   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[TradeID]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[DateTime]', ic.ixp_columns_id, 'GetDate()', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''p''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'physical_financial_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[AggressorCompany]', ic.ixp_columns_id, 'CASE WHEN tdi.AggressorCompany = ''Stadtwerke Hannover AG''
    THEN tdi.[InitiatorCompany]
    ELSE
        tdi.[AggressorCompany]
END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'counterparty_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[AggressorBrokerID]', ic.ixp_columns_id, '''Physical''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_deal_type_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InitiatorOwnedSpread]', ic.ixp_columns_id, 'CASE WHEN tdi.[InitiatorOwnedSpread]=''TRUE'' THEN ''1''
ELSE ''0'' END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'description1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[AggressorOwnedSpread]', ic.ixp_columns_id, 'CASE WHEN tdi.[AggressorOwnedSpread]=''TRUE'' THEN ''1''
ELSE ''0'' END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'description2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[AggSleeve]', ic.ixp_columns_id, 'CASE WHEN tdi.[AggSleeve]=''TRUE'' THEN ''1''
ELSE ''0'' END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'description3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Real''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_category_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[AggressorTrader]', ic.ixp_columns_id, 'CASE WHEN tdi.AggressorCompany = ''Stadtwerke Hannover AG''
    THEN tdi.[AggressorTrader]
    ELSE
        tdi.[InitiatorTrader]
END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'trader_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Physical''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'template_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InitiatorAction]', ic.ixp_columns_id, 'CASE WHEN tdi.AggressorCompany = ''Stadtwerke Hannover AG''
    THEN tdi.[AggressorAction]
    ELSE
        tdi.[InitiatorAction]
END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'header_buy_sell_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''EFET''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''deal volume''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'internal_desk_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[CPTY_Commodity]', ic.ixp_columns_id, 'CASE WHEN tdi.[instname]=''Germany Baseload EEX'' THEN ''POWER''
WHEN tdi.[instname]=''Germany Baseload'' THEN ''POWER''
WHEN tdi.[instname]=''Germany 20-24'' THEN ''POWER''
WHEN tdi.[instname]=''Germany 16-20'' THEN ''POWER''
WHEN tdi.[instname]=''Germany 12-16'' THEN ''POWER''
WHEN tdi.[instname]=''Germany 0-6'' THEN ''POWER''
WHEN tdi.[instname]=''Germany Off-Peaks'' THEN ''POWER''
WHEN tdi.[instname]=''Germany Peaks'' THEN ''POWER''
WHEN tdi.[instname]=''NCG EEX'' THEN ''GAS'' 
WHEN tdi.[instname]=''TTF Hi Cal 51.6 ICE ENDEX'' THEN ''GAS''
WHEN tdi.[instname]=''TTF Hi Cal 51.6'' THEN ''GAS''
WHEN tdi.[instname]=''NCG ICE BLOCK'' THEN ''GAS''
WHEN tdi.[instname]=''GASPOOL'' THEN ''GAS''
WHEN tdi.[instname]=''Germany Baseload EEX'' THEN ''POWER''
WHEN tdi.[instname]=''EUA ECX'' THEN ''EUA''
WHEN tdi.[instname]=''CER ECX'' THEN ''CER''
ELSE ''GAS'' END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'commodity_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[CommingledProduct]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'block_define_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''New''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_status' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''confirmed''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'confirm_status_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[Book]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'sub_book' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InitSleeve]', ic.ixp_columns_id, 'CASE WHEN tdi.[InitSleeve]=''TRUE'' THEN ''1''
ELSE ''0'' END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'description4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[FirstSequenceItemID]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term_start' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[FirstSequenceItemID]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term_end' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''1''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Leg' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''t''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_float_leg' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[AggressorAction]', ic.ixp_columns_id, 'CASE WHEN tdi.AggressorCompany = ''Stadtwerke Hannover AG''
    THEN tdi.[AggressorAction]
    ELSE
        tdi.[InitiatorAction]
END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'buy_sell_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InstName]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'curve_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[price]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_price' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''EUR''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_price_currency_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[volume]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''h''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume_frequency' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[Unit]', ic.ixp_columns_id, '''tons''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume_uom_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[FirstSequenceItemName]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[ForeignLastUpdate]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value13' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Fixed Priced''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'pricing_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InitiatorCompany]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'reporting_group1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[AggressorCompanyID]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'reporting_group2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InitiatorTrader]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'reporting_group3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InitiatorAction]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'reporting_group4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InitiatorBroker]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'reporting_group5' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template'

COMMIT 

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN;
				DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
				DECLARE @msg_severity INT = ERROR_SEVERITY();
				DECLARE @msg_state INT = ERROR_STATE();
					
				RAISERROR(@msg, @msg_severity, @msg_state)
			
				--EXEC spa_print 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
			END CATCH
END
