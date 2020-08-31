BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = 'EC5FA481_EA55_45F1_B23D_DE4470421805'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'EPEX Likron Market Results'
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
					'EPEX Likron Market Results' ,
					'N' ,
					NULL ,
					NULL,
					'IF OBJECT_ID(''tempdb..#tmp_data'') IS NOT NULL
	DROP TABLE #tmp_data

CREATE TABLE #tmp_data(
	[quantity] FLOAT,
	[delivery_date] DATE,
	[hour] NVARCHAR(5) COLLATE DATABASE_DEFAULT,
	[minutes] NVARCHAR(5) COLLATE DATABASE_DEFAULT, 
	deal_reference NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	amount FLOAT 
)

DECLARE @delivery_date DATETIME = GETDATE()

INSERT INTO #tmp_data([quantity], [delivery_date], [hour], [minutes], deal_reference, amount)
SELECT SUM(ulmr.quantity) quantity, ulmr.delivery_date, ulmr.[hour] +1 [hour],ulmr.[minutes], a.deal_ref, SUM(ulmr.quantity*ABS(ulmr.price) )
FROM udt_likron_market_results ulmr
OUTER APPLY (
	SELECT clm1_value texts, clm2_value tso_name,clm3_value buy_sell, clm4_value price_sign, clm5_value analysis_info, clm6_value deal_ref, clm7_value curve_id FROM generic_mapping_values gmv 
	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
	WHERE gmh.mapping_name = ''EPEX Continuous Trading Mapping'' 
) a 
WHERE ISNULL(NULLIF(ulmr.[text], ''''), ''VKW'') = ISNULL(NULLIF(a.texts, ''''), ''VKW'') AND ulmr.tso_name = a.tso_name 
AND ulmr.buy_or_sell = IIF(a.buy_sell = ''b'', ''Buy'', ''Sell'') AND IIF(ulmr.price < 0 , ''n'', ''p'') = a.price_sign
AND is_quarter = ''TRUE'' 
AND ISNULL(NULLIF(a.analysis_info,''''), ''True'') =  IIF(ulmr.analysis_info = ''Netting'', ''Netting'', ''True'')
AND CAST(ulmr.delivery_date AS DATE) = CAST(@delivery_date AS DATE)
AND a.curve_id IS NULL
GROUP BY ulmr.delivery_date, ulmr.[hour],ulmr.[minutes], a.deal_ref

;WITH cte AS (
	SELECT SUM(ulmr.quantity/4) quantity, ulmr.delivery_date, ulmr.[hour] +1 [hour],ulmr.[minutes], a.deal_ref, SUM((ulmr.quantity/4)*ABS(ulmr.price) ) amount
	FROM udt_likron_market_results ulmr
	OUTER APPLY (
		SELECT clm1_value texts, clm2_value tso_name,clm3_value buy_sell, clm4_value price_sign, clm5_value analysis_info, clm6_value deal_ref, clm7_value curve_id FROM generic_mapping_values gmv 
		INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
		WHERE gmh.mapping_name = ''EPEX Continuous Trading Mapping''
	) a 
	WHERE ISNULL(NULLIF(ulmr.[text], ''''), ''VKW'') = ISNULL(NULLIF(a.texts, ''''), ''VKW'') AND ulmr.tso_name = a.tso_name 
		AND ulmr.buy_or_sell = IIF(a.buy_sell = ''b'', ''Buy'', ''Sell'') AND IIF(ulmr.price < 0 , ''n'', ''p'') = a.price_sign
		AND is_hour = ''TRUE'' AND ISNULL(NULLIF(a.analysis_info,''''), ''True'') =  IIF(ulmr.analysis_info = ''Netting'', ''Netting'', ''True'')
		AND CAST(ulmr.delivery_date AS DATE) = CAST(@delivery_date AS DATE)
		AND a.curve_id IS NULL
	GROUP BY ulmr.delivery_date, ulmr.[hour],ulmr.[minutes], a.deal_ref
	UNION ALL
	SELECT quantity, delivery_date, [hour],[minutes] + 15, deal_ref,amount
	FROM cte 	
	WHERE [minutes] + 15 <= 45
)
INSERT INTO #tmp_data([quantity], [delivery_date], [hour], [minutes], deal_reference, amount)
SELECT * FROM cte

UPDATE 
#tmp_data
SET [hour] = IIF(LEN([hour]) < 2,''0'' + [hour], [hour])
, [minutes] = IIF(LEN([minutes]) < 2,''0'' + [minutes], [minutes])

DELETE sddh
FROM #tmp_data td 
INNER JOIN source_deal_header sdh ON sdh.deal_id = td.deal_reference
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = sdd.source_deal_detail_id 
AND CAST(sddh.term_date AS DATE) = td.delivery_date AND sddh.hr = td.[hour] + '':'' + td.[Minutes]

INSERT INTO source_deal_detail_hour (source_deal_detail_id, term_date, hr, is_dst, volume, granularity, price)
SELECT sdd.source_deal_detail_id, td.delivery_date, 
	[hour] + '':''+ [minutes] hr,
	0 is_dst, SUM([quantity]) volume, 987 granularity, SUM(amount)/SUM([quantity]) price FROM #tmp_data td 
INNER JOIN source_deal_header sdh ON sdh.deal_id = td.deal_reference
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id AND td.delivery_date BETWEEN sdd.term_start AND sdd.term_end
GROUP BY sdd.source_deal_detail_id, td.delivery_date,[hour] + '':''+ [minutes]
',
					'i' ,
					'n' ,
					@admin_user ,
					23502,
					1,
					'EC5FA481_EA55_45F1_B23D_DE4470421805'
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
			SET ixp_rules_name = 'EPEX Likron Market Results'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = NULL
				, after_insert_trigger = 'IF OBJECT_ID(''tempdb..#tmp_data'') IS NOT NULL
	DROP TABLE #tmp_data

CREATE TABLE #tmp_data(
	[quantity] FLOAT,
	[delivery_date] DATE,
	[hour] NVARCHAR(5) COLLATE DATABASE_DEFAULT,
	[minutes] NVARCHAR(5) COLLATE DATABASE_DEFAULT, 
	deal_reference NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	amount FLOAT 
)

DECLARE @delivery_date DATETIME = GETDATE()

INSERT INTO #tmp_data([quantity], [delivery_date], [hour], [minutes], deal_reference, amount)
SELECT SUM(ulmr.quantity) quantity, ulmr.delivery_date, ulmr.[hour] +1 [hour],ulmr.[minutes], a.deal_ref, SUM(ulmr.quantity*ABS(ulmr.price) )
FROM udt_likron_market_results ulmr
OUTER APPLY (
	SELECT clm1_value texts, clm2_value tso_name,clm3_value buy_sell, clm4_value price_sign, clm5_value analysis_info, clm6_value deal_ref, clm7_value curve_id FROM generic_mapping_values gmv 
	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
	WHERE gmh.mapping_name = ''EPEX Continuous Trading Mapping'' 
) a 
WHERE ISNULL(NULLIF(ulmr.[text], ''''), ''VKW'') = ISNULL(NULLIF(a.texts, ''''), ''VKW'') AND ulmr.tso_name = a.tso_name 
AND ulmr.buy_or_sell = IIF(a.buy_sell = ''b'', ''Buy'', ''Sell'') AND IIF(ulmr.price < 0 , ''n'', ''p'') = a.price_sign
AND is_quarter = ''TRUE'' 
AND ISNULL(NULLIF(a.analysis_info,''''), ''True'') =  IIF(ulmr.analysis_info = ''Netting'', ''Netting'', ''True'')
AND CAST(ulmr.delivery_date AS DATE) = CAST(@delivery_date AS DATE)
AND a.curve_id IS NULL
GROUP BY ulmr.delivery_date, ulmr.[hour],ulmr.[minutes], a.deal_ref

;WITH cte AS (
	SELECT SUM(ulmr.quantity/4) quantity, ulmr.delivery_date, ulmr.[hour] +1 [hour],ulmr.[minutes], a.deal_ref, SUM((ulmr.quantity/4)*ABS(ulmr.price) ) amount
	FROM udt_likron_market_results ulmr
	OUTER APPLY (
		SELECT clm1_value texts, clm2_value tso_name,clm3_value buy_sell, clm4_value price_sign, clm5_value analysis_info, clm6_value deal_ref, clm7_value curve_id FROM generic_mapping_values gmv 
		INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
		WHERE gmh.mapping_name = ''EPEX Continuous Trading Mapping''
	) a 
	WHERE ISNULL(NULLIF(ulmr.[text], ''''), ''VKW'') = ISNULL(NULLIF(a.texts, ''''), ''VKW'') AND ulmr.tso_name = a.tso_name 
		AND ulmr.buy_or_sell = IIF(a.buy_sell = ''b'', ''Buy'', ''Sell'') AND IIF(ulmr.price < 0 , ''n'', ''p'') = a.price_sign
		AND is_hour = ''TRUE'' AND ISNULL(NULLIF(a.analysis_info,''''), ''True'') =  IIF(ulmr.analysis_info = ''Netting'', ''Netting'', ''True'')
		AND CAST(ulmr.delivery_date AS DATE) = CAST(@delivery_date AS DATE)
		AND a.curve_id IS NULL
	GROUP BY ulmr.delivery_date, ulmr.[hour],ulmr.[minutes], a.deal_ref
	UNION ALL
	SELECT quantity, delivery_date, [hour],[minutes] + 15, deal_ref,amount
	FROM cte 	
	WHERE [minutes] + 15 <= 45
)
INSERT INTO #tmp_data([quantity], [delivery_date], [hour], [minutes], deal_reference, amount)
SELECT * FROM cte

UPDATE 
#tmp_data
SET [hour] = IIF(LEN([hour]) < 2,''0'' + [hour], [hour])
, [minutes] = IIF(LEN([minutes]) < 2,''0'' + [minutes], [minutes])

DELETE sddh
FROM #tmp_data td 
INNER JOIN source_deal_header sdh ON sdh.deal_id = td.deal_reference
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = sdd.source_deal_detail_id 
AND CAST(sddh.term_date AS DATE) = td.delivery_date AND sddh.hr = td.[hour] + '':'' + td.[Minutes]

INSERT INTO source_deal_detail_hour (source_deal_detail_id, term_date, hr, is_dst, volume, granularity, price)
SELECT sdd.source_deal_detail_id, td.delivery_date, 
	[hour] + '':''+ [minutes] hr,
	0 is_dst, SUM([quantity]) volume, 987 granularity, SUM(amount)/SUM([quantity]) price FROM #tmp_data td 
INNER JOIN source_deal_header sdh ON sdh.deal_id = td.deal_reference
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id AND td.delivery_date BETWEEN sdd.term_start AND sdd.term_end
GROUP BY sdd.source_deal_detail_id, td.delivery_date,[hour] + '':''+ [minutes]
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
									WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, is_ftp, ftp_url, ftp_username, ftp_password, clr_function_id, ws_function_name, use_sftp, enable_email_import, send_email_import_reply)
					SELECT @ixp_rules_id_new,
						   NULL,
						   NULL,
						   '\\SG-D-WEB01\shared_docs_TRMTracker_Release\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'udt',
						   '0',
						   NULL,
						   'n',
						   0,
						   '',
						   '0',
						   'n',
						   '',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   '0',
						   '',
						   '',
						   0x0100000086D1C8D5BF6C51EB59FAAAA35B0905148C4564E7CBA6A32F,
						   icf.ixp_clr_functions_id,
						   '', 
						   '0',
						   '0',
						   '0'
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = 'Likron' 
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
					

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id)   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'related_order_id', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'related_order_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'underlying_start', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'underlying_start' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'trader_id', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'trader_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_start_local_time', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_start_local_time' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_start_local_time_cet', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_start_local_time_cet' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_start_ticks', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_start_ticks' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_start_utc_time', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_start_utc_time' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'underlying_end', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'underlying_end' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_start_local_date', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_start_local_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_end_local_time', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_end_local_time' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_end_local_time_cet', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_end_local_time_cet' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'name', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'type', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_end_local_date', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_end_local_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_end_ticks', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_end_ticks' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_end_utc_time', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_end_utc_time' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'daylight_change_suffix', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'daylight_change_suffix' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'short_name', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'short_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'major_type', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'major_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'is_block', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'is_block' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'is_half_hour', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'is_half_hour' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'is_hour', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'is_hour' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'is_quarter', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'is_quarter' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'traded_underlying_delivery_day', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'traded_underlying_delivery_day' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_hour', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_hour' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'scaling_factor', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'scaling_factor' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'target_tso', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'target_tso' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tso', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'tso' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tso_name', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'tso_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'price', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'price' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'quantity', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'quantity' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'is_buy_trade', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'is_buy_trade' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'trade_id', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'trade_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'exchange_id', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'exchange_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'external_trade_id', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'external_trade_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'execution_local_date', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'execution_local_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'execution_time_local_time', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'execution_time_local_time' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'execution_time_local_time_cet', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'execution_time_local_time_cet' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'execution_utc_time', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'execution_utc_time' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'execution_ticks', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'execution_ticks' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'analysis_info', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'analysis_info' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'balance_group', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'balance_group' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'com_xerv_account_type', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'com_xerv_account_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'com_xerv_eic', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'com_xerv_eic' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'external_order_id', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'external_order_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'portfolio', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'portfolio' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pre_arranged_type', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'pre_arranged_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'state', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'state' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'strategy_name', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'strategy_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'strategy_order_id', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'strategy_order_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'text', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'text' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'trading_cost_group', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'trading_cost_group' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'user_code', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'user_code' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pre_arranged', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'pre_arranged' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'com_xerv_product', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'com_xerv_product' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'contract', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'contract_type', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'exchange_key', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'exchange_key' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'product_name', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'product_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'buy_or_sell', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'buy_or_sell' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_day', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_day' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'scaled_quantity', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'scaled_quantity' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'signed_quantity', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'signed_quantity' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'self_trade', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'self_trade' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_date', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hour', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hour' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'minutes', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'minutes' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results'

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
		