BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = 'DFFCDFAF_0B9D_443A_9C9F_CA30BFCCDF15'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'ENMACC Trade Capture'
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
					'ENMACC Trade Capture' ,
					'N' ,
					NULL ,
					'DECLARE @default_code_value INT
SELECT  @default_code_value = [dbo].[FNAGetDefaultCodeValue](36, 1)
--change date to local time
UPDATE t
SET t.[term_start] = [dbo].[FNAGetLOCALTime](t.[term_start] , @default_code_value) ,
t.[term_end] = CASE WHEN (DATEPART(HOUR, [dbo].[FNAGetLOCALTime](t.[term_end], @default_code_value)) in ( 0, 6))
                    THEN DATEADD(DAY, -1, [dbo].[FNAGetLOCALTime](t.[term_end], @default_code_value))
                ELSE [dbo].[FNAGetLOCALTime](t.[term_end], @default_code_value)
                END ,
t.[deal_date] =  [dbo].[FNAGetLOCALTime](t.[deal_date] , @default_code_value) 

FROM  [final_process_table] t

UPDATE t
SET t.[contract_id] =  cg.[contract_name]
FROM [final_process_table] t
INNER JOIN source_commodity sc ON sc.commodity_id = t.commodity_id
INNER JOIN generic_mapping_values gmv ON gmv.clm1_value = t.[counterparty_id]
    AND  gmv.clm2_value = CAST(sc.source_commodity_id AS VARCHAR(10))
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id   
INNER JOIN contract_group cg
	ON cg.contract_id = gmv.clm3_value
WHERE mapping_name = ''ENMACC Contract Mapping'' 


UPDATE t
SET t.[sub_book] =  ssbm.logical_name
FROM [final_process_table] t
INNER JOIN source_commodity sc ON sc.commodity_id = t.commodity_id
INNER JOIN generic_mapping_values gmv ON  gmv.clm1_value = t.[trader_id]
    AND ISNULL(gmv.clm2_value, '''') = ISNULL(CAST(sc.source_commodity_id as VARCHAR(10)), '''')
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_system_book_map ssbm
	ON ssbm.book_deal_type_map_id = gmv.clm4_value
WHERE gmh.mapping_name = ''ENMACC Book Mapping''


UPDATE t
    SET t.[trader_id] = st.trader_id
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[trader_id] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_traders st
	ON st.source_trader_id = gmv.clm2_value
WHERE gmh.mapping_name = ''ENMACC Trader Mapping''


--counterparty mapping
UPDATE t
    SET t.[counterparty_id] = sc.counterparty_id
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[counterparty_id] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_counterparty sc
	ON sc.source_counterparty_id = gmv.clm2_value
WHERE gmh.mapping_name = ''ENMACC Counterparty Mapping''

DECLARE @product_mapping_id INT 
SELECT  @product_mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = ''ENMACC Product Mapping''

--Index mapping
UPDATE t
	SET t.curve_id = ISNULL(spcd.curve_id,t.curve_id)
FROM [final_process_table] t
INNER JOIN source_commodity sc ON sc.commodity_id = t.commodity_id
INNER JOIN generic_mapping_values gmv
    ON gmv.mapping_table_id = @product_mapping_id
    AND ISNULL(gmv.clm1_value, '''') = ISNULL(t.[location_id],'''')
    AND gmv.clm3_value = CAST(sc.source_commodity_id as VARCHAR(10))
	AND ISNULL(gmv.clm4_value,''-1'') = CASE WHEN gmv.clm4_value IS NULL THEN ''-1'' ELSE ISNULL(CASE WHEN DATEDIFF(d, CAST(t.term_start AS DATE), CAST(t.term_end AS DATE)) = 0 THEN ''981''
			WHEN DATEDIFF(d, CAST(t.term_start AS DATE), CAST(t.term_end AS DATE)) = 1 AND DATEPART(DW,CAST(t.term_start AS DATE)) = 7 AND DATEPART(DW,CAST(t.term_end AS DATE)) = 1 THEN ''10000503''
	        WHEN DATEDIFF(d, CAST(t.term_start AS DATE), CAST(t.term_end AS DATE)) BETWEEN 1 AND 6 THEN ''990''
			WHEN DATEDIFF(d, CAST(t.term_start AS DATE), CAST(t.term_end AS DATE)) BETWEEN 7 AND 31 THEN ''980''
			WHEN DATEDIFF(d, CAST(t.term_start AS DATE), CAST(t.term_end AS DATE)) BETWEEN 32 AND 93 THEN ''991''
			WHEN DATEDIFF(d, CAST(t.term_start AS DATE), CAST(t.term_end AS DATE)) > 90 AND DATEDIFF(d, CAST(t.term_start AS DATE), CAST(t.term_end AS DATE)) < 364 THEN ''992''
			WHEN DATEDIFF(d, CAST(t.term_start AS DATE), CAST(t.term_end AS DATE)) >= 364 THEN ''993''
	   ELSE ''981'' END,gmv.clm4_value) END
LEFT JOIN source_price_curve_def spcd
	ON spcd.source_curve_def_id = gmv.clm2_value
	
--location, deal template mapping 
UPDATE t
	SET location_id = ISNULL(sml.location_id,t.location_id),
	 template_id = ISNULL(sdht.template_name,t.template_id)
FROM [final_process_table] t
INNER JOIN source_commodity scm
	ON scm.commodity_id = t.commodity_id
LEFT JOIN generic_mapping_values gmv 
	ON  gmv.mapping_table_id = @product_mapping_id
    AND gmv.clm3_value = scm.source_commodity_id
    AND  ISNULL(gmv.clm1_value,'''') = ISNULL(t.location_id,'''')
LEFT JOIN source_minor_location sml
	ON sml.source_minor_location_id = gmv.clm7_value
LEFT JOIN  source_deal_header_template sdht
	ON sdht.template_id = gmv.clm5_value

UPDATE t
SET deal_volume_frequency = COALESCE( CASE gmv.clm6_value WHEN ''x'' THEN ''15 Minutes''
															   WHEN ''y'' THEN ''30 Minutes''
															   WHEN ''a'' THEN ''Annually''
															   WHEN ''d'' THEN ''Daily''
															   WHEN ''h'' THEN ''Hourly''
															   WHEN ''m'' THEN ''Monthly''
															   WHEN ''t'' THEN ''Term''
										   ELSE NULL END,NULLIF(t.deal_volume_frequency,''''))
FROM [final_process_table] t
INNER JOIN source_deal_header_template sdht
	ON sdht.template_name = t.template_id
LEFT JOIN generic_mapping_values gmv 
	ON  gmv.mapping_table_id = @product_mapping_id
    AND gmv.clm5_value = sdht.template_id


DECLARE @block_mapping_id INT 
SELECT  @block_mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = ''ENMACC Block Mapping''		

UPDATE t 
	SET block_define_id = sdv.code,
	 internal_desk_id = sdv1.code
FROM [final_process_table] t
INNER JOIN [temp_process_table] temp
    ON t.deal_id = temp.short_id
INNER JOIN source_commodity scm
	ON scm.commodity_id = t.commodity_id
LEFT JOIN generic_mapping_values gmv 
	ON  gmv.mapping_table_id = @block_mapping_id
    AND gmv.clm3_value = scm.source_commodity_id
    AND  gmv.clm1_value =  temp.[load]
LEFT JOIN static_data_value sdv
	ON sdv.value_id = gmv.clm2_value AND sdv.type_id = 10018
LEFT JOIN  static_data_value sdv1
	ON sdv1.value_id = gmv.clm4_value AND sdv1.type_id = 17300
',
					NULL,
					'i' ,
					'n' ,
					@admin_user ,
					23502,
					1,
					'DFFCDFAF_0B9D_443A_9C9F_CA30BFCCDF15'
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
			SET ixp_rules_name = 'ENMACC Trade Capture'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = 'DECLARE @default_code_value INT
SELECT  @default_code_value = [dbo].[FNAGetDefaultCodeValue](36, 1)
--change date to local time
UPDATE t
SET t.[term_start] = [dbo].[FNAGetLOCALTime](t.[term_start] , @default_code_value) ,
t.[term_end] = CASE WHEN (DATEPART(HOUR, [dbo].[FNAGetLOCALTime](t.[term_end], @default_code_value)) in ( 0, 6))
                    THEN DATEADD(DAY, -1, [dbo].[FNAGetLOCALTime](t.[term_end], @default_code_value))
                ELSE [dbo].[FNAGetLOCALTime](t.[term_end], @default_code_value)
                END ,
t.[deal_date] =  [dbo].[FNAGetLOCALTime](t.[deal_date] , @default_code_value) 

FROM  [final_process_table] t

UPDATE t
SET t.[contract_id] =  cg.[contract_name]
FROM [final_process_table] t
INNER JOIN source_commodity sc ON sc.commodity_id = t.commodity_id
INNER JOIN generic_mapping_values gmv ON gmv.clm1_value = t.[counterparty_id]
    AND  gmv.clm2_value = CAST(sc.source_commodity_id AS VARCHAR(10))
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id   
INNER JOIN contract_group cg
	ON cg.contract_id = gmv.clm3_value
WHERE mapping_name = ''ENMACC Contract Mapping'' 


UPDATE t
SET t.[sub_book] =  ssbm.logical_name
FROM [final_process_table] t
INNER JOIN source_commodity sc ON sc.commodity_id = t.commodity_id
INNER JOIN generic_mapping_values gmv ON  gmv.clm1_value = t.[trader_id]
    AND ISNULL(gmv.clm2_value, '''') = ISNULL(CAST(sc.source_commodity_id as VARCHAR(10)), '''')
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_system_book_map ssbm
	ON ssbm.book_deal_type_map_id = gmv.clm4_value
WHERE gmh.mapping_name = ''ENMACC Book Mapping''


UPDATE t
    SET t.[trader_id] = st.trader_id
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[trader_id] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_traders st
	ON st.source_trader_id = gmv.clm2_value
WHERE gmh.mapping_name = ''ENMACC Trader Mapping''


--counterparty mapping
UPDATE t
    SET t.[counterparty_id] = sc.counterparty_id
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[counterparty_id] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_counterparty sc
	ON sc.source_counterparty_id = gmv.clm2_value
WHERE gmh.mapping_name = ''ENMACC Counterparty Mapping''

DECLARE @product_mapping_id INT 
SELECT  @product_mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = ''ENMACC Product Mapping''

--Index mapping
UPDATE t
	SET t.curve_id = ISNULL(spcd.curve_id,t.curve_id)
FROM [final_process_table] t
INNER JOIN source_commodity sc ON sc.commodity_id = t.commodity_id
INNER JOIN generic_mapping_values gmv
    ON gmv.mapping_table_id = @product_mapping_id
    AND ISNULL(gmv.clm1_value, '''') = ISNULL(t.[location_id],'''')
    AND gmv.clm3_value = CAST(sc.source_commodity_id as VARCHAR(10))
	AND ISNULL(gmv.clm4_value,''-1'') = CASE WHEN gmv.clm4_value IS NULL THEN ''-1'' ELSE ISNULL(CASE WHEN DATEDIFF(d, CAST(t.term_start AS DATE), CAST(t.term_end AS DATE)) = 0 THEN ''981''
			WHEN DATEDIFF(d, CAST(t.term_start AS DATE), CAST(t.term_end AS DATE)) = 1 AND DATEPART(DW,CAST(t.term_start AS DATE)) = 7 AND DATEPART(DW,CAST(t.term_end AS DATE)) = 1 THEN ''10000503''
	        WHEN DATEDIFF(d, CAST(t.term_start AS DATE), CAST(t.term_end AS DATE)) BETWEEN 1 AND 6 THEN ''990''
			WHEN DATEDIFF(d, CAST(t.term_start AS DATE), CAST(t.term_end AS DATE)) BETWEEN 7 AND 31 THEN ''980''
			WHEN DATEDIFF(d, CAST(t.term_start AS DATE), CAST(t.term_end AS DATE)) BETWEEN 32 AND 93 THEN ''991''
			WHEN DATEDIFF(d, CAST(t.term_start AS DATE), CAST(t.term_end AS DATE)) > 90 AND DATEDIFF(d, CAST(t.term_start AS DATE), CAST(t.term_end AS DATE)) < 364 THEN ''992''
			WHEN DATEDIFF(d, CAST(t.term_start AS DATE), CAST(t.term_end AS DATE)) >= 364 THEN ''993''
	   ELSE ''981'' END,gmv.clm4_value) END
LEFT JOIN source_price_curve_def spcd
	ON spcd.source_curve_def_id = gmv.clm2_value
	
--location, deal template mapping 
UPDATE t
	SET location_id = ISNULL(sml.location_id,t.location_id),
	 template_id = ISNULL(sdht.template_name,t.template_id)
FROM [final_process_table] t
INNER JOIN source_commodity scm
	ON scm.commodity_id = t.commodity_id
LEFT JOIN generic_mapping_values gmv 
	ON  gmv.mapping_table_id = @product_mapping_id
    AND gmv.clm3_value = scm.source_commodity_id
    AND  ISNULL(gmv.clm1_value,'''') = ISNULL(t.location_id,'''')
LEFT JOIN source_minor_location sml
	ON sml.source_minor_location_id = gmv.clm7_value
LEFT JOIN  source_deal_header_template sdht
	ON sdht.template_id = gmv.clm5_value

UPDATE t
SET deal_volume_frequency = COALESCE( CASE gmv.clm6_value WHEN ''x'' THEN ''15 Minutes''
															   WHEN ''y'' THEN ''30 Minutes''
															   WHEN ''a'' THEN ''Annually''
															   WHEN ''d'' THEN ''Daily''
															   WHEN ''h'' THEN ''Hourly''
															   WHEN ''m'' THEN ''Monthly''
															   WHEN ''t'' THEN ''Term''
										   ELSE NULL END,NULLIF(t.deal_volume_frequency,''''))
FROM [final_process_table] t
INNER JOIN source_deal_header_template sdht
	ON sdht.template_name = t.template_id
LEFT JOIN generic_mapping_values gmv 
	ON  gmv.mapping_table_id = @product_mapping_id
    AND gmv.clm5_value = sdht.template_id


DECLARE @block_mapping_id INT 
SELECT  @block_mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = ''ENMACC Block Mapping''		

UPDATE t 
	SET block_define_id = sdv.code,
	 internal_desk_id = sdv1.code
FROM [final_process_table] t
INNER JOIN [temp_process_table] temp
    ON t.deal_id = temp.short_id
INNER JOIN source_commodity scm
	ON scm.commodity_id = t.commodity_id
LEFT JOIN generic_mapping_values gmv 
	ON  gmv.mapping_table_id = @block_mapping_id
    AND gmv.clm3_value = scm.source_commodity_id
    AND  gmv.clm1_value =  temp.[load]
LEFT JOIN static_data_value sdv
	ON sdv.value_id = gmv.clm2_value AND sdv.type_id = 10018
LEFT JOIN  static_data_value sdv1
	ON sdv1.value_id = gmv.clm4_value AND sdv1.type_id = 17300
'
				, after_insert_trigger = NULL
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
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter
					, excel_sheet, ssis_package, soap_function_id, clr_function_id, ws_function_name, enable_email_import
					, send_email_import_reply, file_transfer_endpoint_id, remote_directory)
					SELECT @ixp_rules_id_new,
						   NULL,
						   NULL,
						   '\\CTRMEUWEB-D6001\shared_docs_TRMTracker_Enercity\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'etc',
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
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = 'ENMACC' 
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
					

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id)   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[short_id]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[traded_at]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[settlement]', ic.ixp_columns_id, '''p''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'physical_financial_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[counterparty_name]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'counterparty_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''physical''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_deal_type_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''real''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_category_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[trader]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'trader_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''physical''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'template_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[action]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'header_buy_sell_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''default_contract''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[load]', ic.ixp_columns_id, '''deal volume''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'internal_desk_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[commodity]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'commodity_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[settlement]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'block_define_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''draft''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_status' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''confirmed''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'confirm_status_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''New Subbook''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'sub_book' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[term_start]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term_start' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[term_end]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
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
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[action]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'buy_sell_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''default_curve''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'curve_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[price_value]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_price' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[price_currency]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_price_currency_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[value]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''h''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume_frequency' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[unit]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume_uom_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[location]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'location_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'etc.[pricing_type]', ic.ixp_columns_id, '''Fixed Priced''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'pricing_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
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