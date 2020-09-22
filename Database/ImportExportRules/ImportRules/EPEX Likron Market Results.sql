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
				-- Added to preserve rule detail like folder location, File endpoint details.
				IF OBJECT_ID('tempdb..#pre_ixp_import_data_source') IS NOT NULL
					DROP TABLE #pre_ixp_import_data_source

				SELECT rules_id
					, folder_location
					, file_transfer_endpoint_id
					, remote_directory 
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
					'DELETE ulmr FROM udt_likron_market_results ulmr INNER JOIN 
[temp_process_table] tpt ON ulmr.trade_id = tpt.trade_id AND ulmr.delivery_date  = tpt.delivery_date',
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
				, before_insert_trigger = 'DELETE ulmr FROM udt_likron_market_results ulmr INNER JOIN 
[temp_process_table] tpt ON ulmr.trade_id = tpt.trade_id AND ulmr.delivery_date  = tpt.delivery_date'
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

				

INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter
					, excel_sheet, ssis_package, soap_function_id, clr_function_id, ws_function_name, enable_email_import
					, send_email_import_reply, file_transfer_endpoint_id, remote_directory)
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
						   icf.ixp_clr_functions_id,
						   '', 
						   '0',
						   '0',
						   NULL,
						   NULL
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = 'Likron' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new
						IF OBJECT_ID('tempdb..#pre_ixp_import_data_source') IS NOT NULL
						BEGIN
							UPDATE iids
							SET folder_location = piids.folder_location
								, file_transfer_endpoint_id = piids.file_transfer_endpoint_id
								, remote_directory = piids.remote_directory
							FROM ixp_import_data_source iids
							INNER JOIN #pre_ixp_import_data_source piids 
							ON iids.rules_id = piids.rules_id
						END
					



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
		