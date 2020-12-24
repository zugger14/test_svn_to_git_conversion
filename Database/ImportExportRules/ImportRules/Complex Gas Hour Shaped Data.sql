BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = 'F224E702_7357_4EC5_BDE4_544D80D32E9D'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Complex Gas Hour Shaped Data'
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
					'Complex Gas Hour Shaped Data' ,
					'N' ,
					NULL ,
					'UPDATE [temp_process_table]
SET [Term Date] = CONVERT(VARCHAR(10),dbo.FNAClientTosqlDate([Term Date]), 120)

UPDATE a
SET [Term Date] = CAST(DATEADD(DD,-1, [Term Date]) AS DATE) 
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
    ON a.[Deal Ref ID] = sdh.deal_id
INNER JOIN source_deal_detail sdd 
    ON sdh.source_deal_header_id = sdd.source_deal_header_id
	AND a.[Term Date]
		BETWEEN sdd.term_start
		AND DATEADD(DAY, 1, sdd.term_end)
	AND sdd.leg = a.[Leg]
LEFT JOIN source_price_curve_def spcd 
    ON spcd.source_curve_def_id = sdd.curve_id
WHERE spcd.commodity_id = -1
    AND (
		( sdh.profile_granularity = 982
		AND (a.[Hour] BETWEEN 1 AND 6))
		OR (
			sdh.profile_granularity <> 982
			AND (a.[Hour] BETWEEN 0 AND 5
			OR (a.[Hour] = 6 and a.[Minute] = 0))
			)
		)

UPDATE a
SET [Hour] = CASE WHEN [HOUR] BETWEEN  7 AND 24 THEN [HOUR] - 6
        WHEN [HOUR] = 6 AND ISNULL([Minute], '''') <> 0 THEN 0
		WHEN [HOUR] BETWEEN 0 AND 6 THEN [HOUR] + 18
	ELSE [HOUR]
	END
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
    ON a.[Deal Ref ID] = sdh.deal_id
INNER JOIN source_deal_detail sdd 
    ON sdh.source_deal_header_id = sdd.source_deal_header_id
	AND a.[Term Date] BETWEEN sdd.term_start
		AND sdd.term_end
	AND sdd.leg = a.[Leg]
LEFT JOIN source_price_curve_def spcd 
    ON spcd.source_curve_def_id = sdd.curve_id
WHERE spcd.commodity_id = -1',
					'--DECLARE @set_process_id NVARCHAR(40) 
--SELECT @set_process_id = REVERSE(SUBSTRING(REVERSE(''[temp_process_table]''), 0,37)) 

--EXEC spa_transfer_adjust_wrapper @set_process_id

IF OBJECT_ID (N''tempdb..#temp_trans_off'') IS NOT NULL  
	DROP TABLE 	#temp_trans_off

IF OBJECT_ID (N''tempdb..#temp_inserted_sdd'') IS NOT NULL  
	DROP TABLE 	#temp_inserted_sdd

CREATE TABLE #temp_trans_off (
	source_deal_header_id INT,
	transfer_deal_id INT,
	offset_deal_id INT 
)

CREATE TABLE #temp_inserted_sdd (source_deal_detail_id INT)

ALTER TABLE [temp_process_table] 
ALTER COLUMN term_date DATETIME


INSERT INTO #temp_trans_off (source_deal_header_id, offset_deal_id)
SELECT DISTINCT sdh.source_deal_header_id, sdh.close_reference_id
FROM [temp_process_table] t
INNER JOIN source_deal_header sdh
	ON sdh.deal_id = t.deal_id
WHERE  deal_reference_type_id = 12503 --transfer deal

INSERT INTO #temp_trans_off (source_deal_header_id, offset_deal_id)
SELECT DISTINCT sdh.source_deal_header_id, sdh_o.source_deal_header_id
FROM [temp_process_table] t
INNER JOIN source_deal_header sdh
	ON sdh.deal_id = t.deal_id
INNER JOIN source_deal_header sdh_o
	ON sdh_o.close_reference_id = sdh.source_deal_header_id
WHERE sdh.deal_reference_type_id IS NULL --original deal

INSERT INTO #temp_trans_off(source_deal_header_id, transfer_deal_id)
SELECT tto.source_deal_header_id, sdh_t.source_deal_header_id 
FROM #temp_trans_off tto
INNER JOIN source_deal_header sdh_t
	ON sdh_t.close_reference_id = tto.offset_deal_id
INNER JOIN source_deal_header sdh
	ON sdh.source_deal_header_id = tto.source_deal_header_id
WHERE sdh.deal_reference_type_id IS NULL --original deal

IF EXISTS(SELECT 1 FROM #temp_trans_off)
BEGIN
	DELETE sddh 
	FROM [temp_process_table] t
	INNER JOIN source_deal_header sdh
		ON sdh.deal_id = t.deal_id
	INNER JOIN #temp_trans_off tto
		ON tto.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = ISNULL(tto.transfer_deal_id, tto.offset_deal_id)
	INNER JOIN source_deal_detail_hour sddh
		ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
		AND sddh.term_date = t.term_date
		AND sddh.term_date BETWEEN sdd.term_start AND sdd.term_end
		AND t.hr =  RIGHT(''0''+ CAST(LEFT(sddh.hr, 2) - 1 AS VARCHAR(3)) , 2) + '':'' + RIGHT(sddh.hr, 2)
		AND t.is_dst = sddh.is_dst


	INSERT INTO source_deal_detail_hour (
		source_deal_detail_id
		, term_date
		, hr
		, is_dst
		, volume
		, price
		, formula_id
		, granularity
		, schedule_volume
		, actual_volume
		, contractual_volume
		, period
	)
	OUTPUT inserted.source_deal_detail_id
	INTO #temp_inserted_sdd(source_deal_detail_id)
	SELECT sdd_to.source_deal_detail_id
		, sddh.term_date
		, sddh.hr
		, sddh.is_dst
		, sddh.volume
		, sddh.price
		, sddh.formula_id
		, sddh.granularity
		, sddh.schedule_volume
		, sddh.actual_volume
		, sddh.contractual_volume
		, sddh.period
	 FROM [temp_process_table] t
	INNER JOIN source_deal_header sdh
		ON sdh.deal_id = t.deal_id
	INNER JOIN #temp_trans_off tto
		ON tto.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = tto.source_deal_header_id		
	INNER JOIN source_deal_detail sdd_to
		ON sdd_to.source_deal_header_id = ISNULL(tto.transfer_deal_id , tto.offset_deal_id)
	INNER JOIN source_deal_detail_hour sddh
		ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
		AND sddh.term_date = t.term_date
		AND sddh.term_date BETWEEN sdd_to.term_start AND sdd_to.term_end
		AND t.hr =  RIGHT(''0''+ CAST(LEFT(sddh.hr, 2) - 1 AS VARCHAR(3)) , 2) + '':'' + RIGHT(sddh.hr, 2)
		AND t.is_dst = sddh.is_dst


	UPDATE sdd
		SET deal_volume = sub.volume, 
			fixed_price = sub.price
	FROM source_deal_detail sdd
	INNER JOIN (
    	SELECT sddh.source_deal_detail_id,
    			AVG(sddh.volume) volume,
    			SUM(sddh.price * sddh.volume) / NULLIF(SUM(sddh.volume), 0) price
    	FROM source_deal_detail_hour sddh
    	INNER JOIN (SELECT DISTINCT source_deal_detail_id FROM  #temp_inserted_sdd) temp
    		ON sddh.source_deal_detail_id = temp.source_deal_detail_id
    	GROUP BY sddh.source_deal_detail_id
	) sub
	ON sub.source_deal_detail_id = sdd.source_deal_detail_id


	DECLARE @_process_id NVARCHAR(500) = dbo.FNAGetNewID()
	DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()
	DECLARE @job_name VARCHAR(MAX)
	DECLARE @sql NVARCHAR(MAX)
	DECLARE @after_insert_process_table VARCHAR(300)
	
	SET @after_insert_process_table = dbo.FNAProcessTableName(''after_insert_process_table'', @user_name, @_process_id)
	EXEC (''CREATE TABLE '' + @after_insert_process_table + ''( source_deal_header_id INT)'')
		
	SET @sql = ''INSERT INTO '' + @after_insert_process_table + ''(source_deal_header_id) 
				SELECT ISNULL(temp.transfer_deal_id, temp.offset_deal_id) [source_deal_header_id] 
				FROM #temp_trans_off temp 
				UNION ALL 
				SELECT temp.source_deal_header_id [source_deal_header_id] 
				FROM #temp_trans_off temp
				''
	EXEC (@sql)
		
	SET @sql = ''spa_deal_insert_update_jobs ''''u'''', '''''' + @after_insert_process_table + ''''''''

	SET @job_name = ''spa_deal_insert_update_jobs_'' + @_process_id
 		
	EXEC spa_run_sp_as_job @job_name, @sql, ''spa_deal_insert_update_jobs'', @user_name

END

ALTER TABLE  [temp_process_table] 
ALTER COLUMN term_date VARCHAR(50)',
					'i' ,
					'n' ,
					@admin_user ,
					23502,
					1,
					'F224E702_7357_4EC5_BDE4_544D80D32E9D'
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
			SET ixp_rules_name = 'Complex Gas Hour Shaped Data'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = 'UPDATE [temp_process_table]
SET [Term Date] = CONVERT(VARCHAR(10),dbo.FNAClientTosqlDate([Term Date]), 120)

UPDATE a
SET [Term Date] = CAST(DATEADD(DD,-1, [Term Date]) AS DATE) 
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
    ON a.[Deal Ref ID] = sdh.deal_id
INNER JOIN source_deal_detail sdd 
    ON sdh.source_deal_header_id = sdd.source_deal_header_id
	AND a.[Term Date]
		BETWEEN sdd.term_start
		AND DATEADD(DAY, 1, sdd.term_end)
	AND sdd.leg = a.[Leg]
LEFT JOIN source_price_curve_def spcd 
    ON spcd.source_curve_def_id = sdd.curve_id
WHERE spcd.commodity_id = -1
    AND (
		( sdh.profile_granularity = 982
		AND (a.[Hour] BETWEEN 1 AND 6))
		OR (
			sdh.profile_granularity <> 982
			AND (a.[Hour] BETWEEN 0 AND 5
			OR (a.[Hour] = 6 and a.[Minute] = 0))
			)
		)

UPDATE a
SET [Hour] = CASE WHEN [HOUR] BETWEEN  7 AND 24 THEN [HOUR] - 6
        WHEN [HOUR] = 6 AND ISNULL([Minute], '''') <> 0 THEN 0
		WHEN [HOUR] BETWEEN 0 AND 6 THEN [HOUR] + 18
	ELSE [HOUR]
	END
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
    ON a.[Deal Ref ID] = sdh.deal_id
INNER JOIN source_deal_detail sdd 
    ON sdh.source_deal_header_id = sdd.source_deal_header_id
	AND a.[Term Date] BETWEEN sdd.term_start
		AND sdd.term_end
	AND sdd.leg = a.[Leg]
LEFT JOIN source_price_curve_def spcd 
    ON spcd.source_curve_def_id = sdd.curve_id
WHERE spcd.commodity_id = -1'
				, after_insert_trigger = '--DECLARE @set_process_id NVARCHAR(40) 
--SELECT @set_process_id = REVERSE(SUBSTRING(REVERSE(''[temp_process_table]''), 0,37)) 

--EXEC spa_transfer_adjust_wrapper @set_process_id

IF OBJECT_ID (N''tempdb..#temp_trans_off'') IS NOT NULL  
	DROP TABLE 	#temp_trans_off

IF OBJECT_ID (N''tempdb..#temp_inserted_sdd'') IS NOT NULL  
	DROP TABLE 	#temp_inserted_sdd

CREATE TABLE #temp_trans_off (
	source_deal_header_id INT,
	transfer_deal_id INT,
	offset_deal_id INT 
)

CREATE TABLE #temp_inserted_sdd (source_deal_detail_id INT)

ALTER TABLE [temp_process_table] 
ALTER COLUMN term_date DATETIME


INSERT INTO #temp_trans_off (source_deal_header_id, offset_deal_id)
SELECT DISTINCT sdh.source_deal_header_id, sdh.close_reference_id
FROM [temp_process_table] t
INNER JOIN source_deal_header sdh
	ON sdh.deal_id = t.deal_id
WHERE  deal_reference_type_id = 12503 --transfer deal

INSERT INTO #temp_trans_off (source_deal_header_id, offset_deal_id)
SELECT DISTINCT sdh.source_deal_header_id, sdh_o.source_deal_header_id
FROM [temp_process_table] t
INNER JOIN source_deal_header sdh
	ON sdh.deal_id = t.deal_id
INNER JOIN source_deal_header sdh_o
	ON sdh_o.close_reference_id = sdh.source_deal_header_id
WHERE sdh.deal_reference_type_id IS NULL --original deal

INSERT INTO #temp_trans_off(source_deal_header_id, transfer_deal_id)
SELECT tto.source_deal_header_id, sdh_t.source_deal_header_id 
FROM #temp_trans_off tto
INNER JOIN source_deal_header sdh_t
	ON sdh_t.close_reference_id = tto.offset_deal_id
INNER JOIN source_deal_header sdh
	ON sdh.source_deal_header_id = tto.source_deal_header_id
WHERE sdh.deal_reference_type_id IS NULL --original deal

IF EXISTS(SELECT 1 FROM #temp_trans_off)
BEGIN
	DELETE sddh 
	FROM [temp_process_table] t
	INNER JOIN source_deal_header sdh
		ON sdh.deal_id = t.deal_id
	INNER JOIN #temp_trans_off tto
		ON tto.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = ISNULL(tto.transfer_deal_id, tto.offset_deal_id)
	INNER JOIN source_deal_detail_hour sddh
		ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
		AND sddh.term_date = t.term_date
		AND sddh.term_date BETWEEN sdd.term_start AND sdd.term_end
		AND t.hr =  RIGHT(''0''+ CAST(LEFT(sddh.hr, 2) - 1 AS VARCHAR(3)) , 2) + '':'' + RIGHT(sddh.hr, 2)
		AND t.is_dst = sddh.is_dst


	INSERT INTO source_deal_detail_hour (
		source_deal_detail_id
		, term_date
		, hr
		, is_dst
		, volume
		, price
		, formula_id
		, granularity
		, schedule_volume
		, actual_volume
		, contractual_volume
		, period
	)
	OUTPUT inserted.source_deal_detail_id
	INTO #temp_inserted_sdd(source_deal_detail_id)
	SELECT sdd_to.source_deal_detail_id
		, sddh.term_date
		, sddh.hr
		, sddh.is_dst
		, sddh.volume
		, sddh.price
		, sddh.formula_id
		, sddh.granularity
		, sddh.schedule_volume
		, sddh.actual_volume
		, sddh.contractual_volume
		, sddh.period
	 FROM [temp_process_table] t
	INNER JOIN source_deal_header sdh
		ON sdh.deal_id = t.deal_id
	INNER JOIN #temp_trans_off tto
		ON tto.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = tto.source_deal_header_id		
	INNER JOIN source_deal_detail sdd_to
		ON sdd_to.source_deal_header_id = ISNULL(tto.transfer_deal_id , tto.offset_deal_id)
	INNER JOIN source_deal_detail_hour sddh
		ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
		AND sddh.term_date = t.term_date
		AND sddh.term_date BETWEEN sdd_to.term_start AND sdd_to.term_end
		AND t.hr =  RIGHT(''0''+ CAST(LEFT(sddh.hr, 2) - 1 AS VARCHAR(3)) , 2) + '':'' + RIGHT(sddh.hr, 2)
		AND t.is_dst = sddh.is_dst


	UPDATE sdd
		SET deal_volume = sub.volume, 
			fixed_price = sub.price
	FROM source_deal_detail sdd
	INNER JOIN (
    	SELECT sddh.source_deal_detail_id,
    			AVG(sddh.volume) volume,
    			SUM(sddh.price * sddh.volume) / NULLIF(SUM(sddh.volume), 0) price
    	FROM source_deal_detail_hour sddh
    	INNER JOIN (SELECT DISTINCT source_deal_detail_id FROM  #temp_inserted_sdd) temp
    		ON sddh.source_deal_detail_id = temp.source_deal_detail_id
    	GROUP BY sddh.source_deal_detail_id
	) sub
	ON sub.source_deal_detail_id = sdd.source_deal_detail_id


	DECLARE @_process_id NVARCHAR(500) = dbo.FNAGetNewID()
	DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()
	DECLARE @job_name VARCHAR(MAX)
	DECLARE @sql NVARCHAR(MAX)
	DECLARE @after_insert_process_table VARCHAR(300)
	
	SET @after_insert_process_table = dbo.FNAProcessTableName(''after_insert_process_table'', @user_name, @_process_id)
	EXEC (''CREATE TABLE '' + @after_insert_process_table + ''( source_deal_header_id INT)'')
		
	SET @sql = ''INSERT INTO '' + @after_insert_process_table + ''(source_deal_header_id) 
				SELECT ISNULL(temp.transfer_deal_id, temp.offset_deal_id) [source_deal_header_id] 
				FROM #temp_trans_off temp 
				UNION ALL 
				SELECT temp.source_deal_header_id [source_deal_header_id] 
				FROM #temp_trans_off temp
				''
	EXEC (@sql)
		
	SET @sql = ''spa_deal_insert_update_jobs ''''u'''', '''''' + @after_insert_process_table + ''''''''

	SET @job_name = ''spa_deal_insert_update_jobs_'' + @_process_id
 		
	EXEC spa_run_sp_as_job @job_name, @sql, ''spa_deal_insert_update_jobs'', @user_name

END

ALTER TABLE  [temp_process_table] 
ALTER COLUMN term_date VARCHAR(50)'
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
									WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter
					, excel_sheet, ssis_package, soap_function_id, clr_function_id, ws_function_name, enable_email_import
					, send_email_import_reply, file_transfer_endpoint_id, remote_directory)
					SELECT @ixp_rules_id_new,
						   NULL,
						   NULL,
						   '\\EU-T-SQL01\shared_docs_TRMTracker_Enercity\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'SD',
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
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = '' 
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
					

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id)   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Deal Ref ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Term Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Hour]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hr' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Is DST]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'is_dst' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Volume]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Price]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'price' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Leg]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'leg' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Schedule Volume]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'schedule_volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Actual Volume]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'actual_volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Minute]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'minute' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
INSERT INTO ixp_import_where_clause(rules_id, table_id, ixp_import_where_clause, repeat_number)  
										SELECT @ixp_rules_id_new,
										it.ixp_tables_id,
										NULL,
										0
										FROM ixp_tables it 
										WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
										
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
