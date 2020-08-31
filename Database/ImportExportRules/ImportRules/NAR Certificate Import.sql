BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = '4E15018B_27EC_485F_B1E0_AC388EC08975'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'NAR Certificate Import'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				-- Added to preserve rule detail like folder location, FTP URL, username and password.
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
					'NAR Certificate Import' ,
					'N' ,
					NULL ,
					'
IF NOT EXISTS(SELECT * FROM adiha_process.sys.columns
			  WHERE [name] = N''temp_rid''
				  AND OBJECT_ID = OBJECT_ID(N''[temp_process_table]''))
BEGIN
	EXEC(''	ALTER TABLE [temp_process_table]
			ADD temp_rid INT IDENTITY(1,1)
	'')
END

IF NOT EXISTS(SELECT * FROM adiha_process.sys.columns
			  WHERE [name] = N''temp_rid''
				  AND OBJECT_ID = OBJECT_ID(N''[final_process_table]''))
BEGIN
	EXEC(''	ALTER TABLE [final_process_table]
			ADD temp_rid INT
	'')
END

IF OBJECT_ID(N''[final_process_table]'', ''U'') IS NOT NULL
BEGIN
	EXEC(''UPDATE b
			SET temp_rid = a.temp_rid,
			source_certificate_number = REVERSE(LEFT(REPLACE(REVERSE(a.[Certificate Serial Numbers]),LEFT(REVERSE(a.[Certificate Serial Numbers]),CHARINDEX(''''-'''',REVERSE(a.[Certificate Serial Numbers]))), ''''''''), CHARINDEX(''''-'''', REPLACE(REVERSE(a.[Certificate Serial Numbers]),LEFT(REVERSE(a.[Certificate Serial Numbers]),CHARINDEX(''''-'''',REVERSE(a.[Certificate Serial Numbers]))), ''''''''))-1)),
			vintage_month = DATEPART(MONTH, dbo.FNAClientToSqlDate(b.[vintage_month])),
			vintage_year = DATEPART(YEAR, dbo.FNAClientToSqlDate(b.[vintage_year])),
			certificate_serial_numbers_from = SUBSTRING (a.[Certificate Serial Numbers] ,0 , CHARINDEX (''''to'''', a.[Certificate Serial Numbers] , 0)),
			certificate_serial_numbers_to = REPLACE (LTRIM(RTRIM(SUBSTRING (a.[Certificate Serial Numbers],0 , CHARINDEX (''''to'''', a.[Certificate Serial Numbers], 0)))) + ''''to'''' , LTRIM(RTRIM(REVERSE(LEFT(REVERSE(SUBSTRING (a.[Certificate Serial Numbers] ,0 , CHARINDEX (''''to'''', a.[Certificate Serial Numbers], 0))), CHARINDEX(''''-'''',REVERSE(SUBSTRING (a.[Certificate Serial Numbers],0 , CHARINDEX (''''to'''',a.[Certificate Serial Numbers], 0))), 0)-1)))) + ''''to'''' , RTRIM(LTRIM(SUBSTRING(a.[Certificate Serial Numbers],CHARINDEX (''''to'''',a.[Certificate Serial Numbers], 0  ) + 2 , LEN(a.[Certificate Serial Numbers]))))),
			certificate_seq_from = REVERSE(LEFT(REVERSE(SUBSTRING (a.[Certificate Serial Numbers],0 , CHARINDEX (''''to'''',a.[Certificate Serial Numbers], 0))), CHARINDEX(''''-'''',REVERSE(SUBSTRING (a.[Certificate Serial Numbers],0 , CHARINDEX (''''to'''',a.[Certificate Serial Numbers], 0))), 0)-1)),
			certificate_seq_to = RTRIM(LTRIM(SUBSTRING (a.[Certificate Serial Numbers],CHARINDEX (''''to'''',a.[Certificate Serial Numbers],0) + 2 ,LEN(a.[Certificate Serial Numbers]))))
			FROM [temp_process_table] a 
			INNER JOIN [final_process_table] b
				ON ISNULL(NULLIF(a.[Certificate Vintage], ''''''''), -1)			    = ISNULL(NULLIF(b.[vintage_month], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate Vintage], ''''''''), -1)				= ISNULL(NULLIF(b.[vintage_year], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Quantity], ''''''''), -1)							= ISNULL(NULLIF(b.[volume], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Sub-Account], ''''''''), -1)						= ISNULL(NULLIF(b.[jurisdiction], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Sub-Account], ''''''''), -1)						= ISNULL(NULLIF(b.[tier], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate Serial Numbers], ''''''''), -1)	    = ISNULL(NULLIF(b.[certificate_serial_numbers_from], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate Serial Numbers], ''''''''), -1)		= ISNULL(NULLIF(b.[certificate_serial_numbers_to], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate Serial Numbers], ''''''''), -1)		= ISNULL(NULLIF(b.[certificate_seq_from], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate Serial Numbers], ''''''''), -1)		= ISNULL(NULLIF(b.[certificate_seq_to], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Transferor], ''''''''), -1)						= ISNULL(NULLIF(b.[counterparty], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Asset], ''''''''), -1)						        = ISNULL(NULLIF(b.[facility_name], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Fuel/Project Type], ''''''''), -1)					= ISNULL(NULLIF(b.[technology], ''''''''), -1)		
				AND ISNULL(NULLIF(a.[NAR ID], ''''''''), -1)						    = ISNULL(NULLIF(b.[generator], ''''''''), -1)	
	'')
END',
					'/*****brought missing report''s hardcoded logic*********/
DECLARE @set_process_id NVARCHAR(40) 
SELECT @set_process_id = REVERSE(SUBSTRING(REVERSE(''[temp_process_table]''), 0,37)) 

DECLARE	@process_table_pre NVARCHAR(MAX)   = dbo.FNAProcessTableName(''ixp_rec_inventory'', ''missing_deals_pre'', @set_process_id)
DECLARE	@process_table_post NVARCHAR(MAX)  = dbo.FNAProcessTableName(''ixp_rec_inventory'', ''missing_deals'', @set_process_id)
DECLARE @column_list NVARCHAR(MAX)

IF OBJECT_ID(@process_table_post) IS NOT NULL
	EXEC(''DROP TABLE '' + @process_table_post)

SELECT @column_list = COALESCE(@column_list + '', '', '''') + dbo.FNAGetSplitPart(imdm.source_column_name, ''.'', 2) + '' '' + MAX(ic.column_datatype)
FROM ixp_columns ic
INNER JOIN ixp_import_data_mapping imdm
	ON ic.ixp_columns_id = imdm.dest_column
INNER JOIN ixp_rules ir
	ON ir.ixp_rules_id = imdm.ixp_rules_id
WHERE ir.ixp_rules_name = ''REC Deals''
	AND NULLIF(imdm.source_column_name, '''') IS NOT NULL
GROUP BY imdm.source_column_name, ic.seq
ORDER BY ic.seq

EXEC(''CREATE TABLE  '' + @process_table_post + '' (  '' + @column_list + '' )'')

EXEC(''INSERT INTO '' + @process_table_post + '' ([Vintage From], [Vintage To], [Counterparty], [Generator], [Fixed Price], [Forecasted Volume], [Deal ID], [Deal Date],
								[Trader], [Contract], [Deal Type], [Template], [Leg], [Pricing Type], [Vintage Year], [Header Buy/Sell],
								[Market Index], [Subbook], [Currency], [REC Status], [jurisdiction], [tier]
	 )
	 SELECT [vintage_from],
	 	    [vintage_to],
	 	    [counterparty],
	 	    [generator],
	 	    [fixed_price],
	 	    [forecasted_volume],
	 	    [deal_id],
	 	    [deal_date],
	 	    [trader],
	 	    [contract],
	 	    [deal_type],
	 	    [template],
	 	    [leg],
	 	    [pricing_type],
	 	    [vintage_year],
	 	    [header_buy_sell],
	 	    [market_index],
	 	    [subbook],
	 	    [currency],
	 	    [rec_status],
	 	    [jurisdiction],
	 	    [tier]
	 FROM '' + @process_table_pre 
)
/******************/',
					'i' ,
					'n' ,
					@admin_user ,
					23502,
					1,
					'4E15018B_27EC_485F_B1E0_AC388EC08975'
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
			SET ixp_rules_name = 'NAR Certificate Import'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = '
IF NOT EXISTS(SELECT * FROM adiha_process.sys.columns
			  WHERE [name] = N''temp_rid''
				  AND OBJECT_ID = OBJECT_ID(N''[temp_process_table]''))
BEGIN
	EXEC(''	ALTER TABLE [temp_process_table]
			ADD temp_rid INT IDENTITY(1,1)
	'')
END

IF NOT EXISTS(SELECT * FROM adiha_process.sys.columns
			  WHERE [name] = N''temp_rid''
				  AND OBJECT_ID = OBJECT_ID(N''[final_process_table]''))
BEGIN
	EXEC(''	ALTER TABLE [final_process_table]
			ADD temp_rid INT
	'')
END

IF OBJECT_ID(N''[final_process_table]'', ''U'') IS NOT NULL
BEGIN
	EXEC(''UPDATE b
			SET temp_rid = a.temp_rid,
			source_certificate_number = REVERSE(LEFT(REPLACE(REVERSE(a.[Certificate Serial Numbers]),LEFT(REVERSE(a.[Certificate Serial Numbers]),CHARINDEX(''''-'''',REVERSE(a.[Certificate Serial Numbers]))), ''''''''), CHARINDEX(''''-'''', REPLACE(REVERSE(a.[Certificate Serial Numbers]),LEFT(REVERSE(a.[Certificate Serial Numbers]),CHARINDEX(''''-'''',REVERSE(a.[Certificate Serial Numbers]))), ''''''''))-1)),
			vintage_month = DATEPART(MONTH, dbo.FNAClientToSqlDate(b.[vintage_month])),
			vintage_year = DATEPART(YEAR, dbo.FNAClientToSqlDate(b.[vintage_year])),
			certificate_serial_numbers_from = SUBSTRING (a.[Certificate Serial Numbers] ,0 , CHARINDEX (''''to'''', a.[Certificate Serial Numbers] , 0)),
			certificate_serial_numbers_to = REPLACE (LTRIM(RTRIM(SUBSTRING (a.[Certificate Serial Numbers],0 , CHARINDEX (''''to'''', a.[Certificate Serial Numbers], 0)))) + ''''to'''' , LTRIM(RTRIM(REVERSE(LEFT(REVERSE(SUBSTRING (a.[Certificate Serial Numbers] ,0 , CHARINDEX (''''to'''', a.[Certificate Serial Numbers], 0))), CHARINDEX(''''-'''',REVERSE(SUBSTRING (a.[Certificate Serial Numbers],0 , CHARINDEX (''''to'''',a.[Certificate Serial Numbers], 0))), 0)-1)))) + ''''to'''' , RTRIM(LTRIM(SUBSTRING(a.[Certificate Serial Numbers],CHARINDEX (''''to'''',a.[Certificate Serial Numbers], 0  ) + 2 , LEN(a.[Certificate Serial Numbers]))))),
			certificate_seq_from = REVERSE(LEFT(REVERSE(SUBSTRING (a.[Certificate Serial Numbers],0 , CHARINDEX (''''to'''',a.[Certificate Serial Numbers], 0))), CHARINDEX(''''-'''',REVERSE(SUBSTRING (a.[Certificate Serial Numbers],0 , CHARINDEX (''''to'''',a.[Certificate Serial Numbers], 0))), 0)-1)),
			certificate_seq_to = RTRIM(LTRIM(SUBSTRING (a.[Certificate Serial Numbers],CHARINDEX (''''to'''',a.[Certificate Serial Numbers],0) + 2 ,LEN(a.[Certificate Serial Numbers]))))
			FROM [temp_process_table] a 
			INNER JOIN [final_process_table] b
				ON ISNULL(NULLIF(a.[Certificate Vintage], ''''''''), -1)			    = ISNULL(NULLIF(b.[vintage_month], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate Vintage], ''''''''), -1)				= ISNULL(NULLIF(b.[vintage_year], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Quantity], ''''''''), -1)							= ISNULL(NULLIF(b.[volume], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Sub-Account], ''''''''), -1)						= ISNULL(NULLIF(b.[jurisdiction], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Sub-Account], ''''''''), -1)						= ISNULL(NULLIF(b.[tier], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate Serial Numbers], ''''''''), -1)	    = ISNULL(NULLIF(b.[certificate_serial_numbers_from], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate Serial Numbers], ''''''''), -1)		= ISNULL(NULLIF(b.[certificate_serial_numbers_to], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate Serial Numbers], ''''''''), -1)		= ISNULL(NULLIF(b.[certificate_seq_from], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate Serial Numbers], ''''''''), -1)		= ISNULL(NULLIF(b.[certificate_seq_to], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Transferor], ''''''''), -1)						= ISNULL(NULLIF(b.[counterparty], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Asset], ''''''''), -1)						        = ISNULL(NULLIF(b.[facility_name], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Fuel/Project Type], ''''''''), -1)					= ISNULL(NULLIF(b.[technology], ''''''''), -1)		
				AND ISNULL(NULLIF(a.[NAR ID], ''''''''), -1)						    = ISNULL(NULLIF(b.[generator], ''''''''), -1)	
	'')
END'
				, after_insert_trigger = '/*****brought missing report''s hardcoded logic*********/
DECLARE @set_process_id NVARCHAR(40) 
SELECT @set_process_id = REVERSE(SUBSTRING(REVERSE(''[temp_process_table]''), 0,37)) 

DECLARE	@process_table_pre NVARCHAR(MAX)   = dbo.FNAProcessTableName(''ixp_rec_inventory'', ''missing_deals_pre'', @set_process_id)
DECLARE	@process_table_post NVARCHAR(MAX)  = dbo.FNAProcessTableName(''ixp_rec_inventory'', ''missing_deals'', @set_process_id)
DECLARE @column_list NVARCHAR(MAX)

IF OBJECT_ID(@process_table_post) IS NOT NULL
	EXEC(''DROP TABLE '' + @process_table_post)

SELECT @column_list = COALESCE(@column_list + '', '', '''') + dbo.FNAGetSplitPart(imdm.source_column_name, ''.'', 2) + '' '' + MAX(ic.column_datatype)
FROM ixp_columns ic
INNER JOIN ixp_import_data_mapping imdm
	ON ic.ixp_columns_id = imdm.dest_column
INNER JOIN ixp_rules ir
	ON ir.ixp_rules_id = imdm.ixp_rules_id
WHERE ir.ixp_rules_name = ''REC Deals''
	AND NULLIF(imdm.source_column_name, '''') IS NOT NULL
GROUP BY imdm.source_column_name, ic.seq
ORDER BY ic.seq

EXEC(''CREATE TABLE  '' + @process_table_post + '' (  '' + @column_list + '' )'')

EXEC(''INSERT INTO '' + @process_table_post + '' ([Vintage From], [Vintage To], [Counterparty], [Generator], [Fixed Price], [Forecasted Volume], [Deal ID], [Deal Date],
								[Trader], [Contract], [Deal Type], [Template], [Leg], [Pricing Type], [Vintage Year], [Header Buy/Sell],
								[Market Index], [Subbook], [Currency], [REC Status], [jurisdiction], [tier]
	 )
	 SELECT [vintage_from],
	 	    [vintage_to],
	 	    [counterparty],
	 	    [generator],
	 	    [fixed_price],
	 	    [forecasted_volume],
	 	    [deal_id],
	 	    [deal_date],
	 	    [trader],
	 	    [contract],
	 	    [deal_type],
	 	    [template],
	 	    [leg],
	 	    [pricing_type],
	 	    [vintage_year],
	 	    [header_buy_sell],
	 	    [market_index],
	 	    [subbook],
	 	    [currency],
	 	    [rec_status],
	 	    [jurisdiction],
	 	    [tier]
	 FROM '' + @process_table_pre 
)
/******************/'
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
									WHERE it.ixp_tables_name = 'ixp_rec_inventory'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, clr_function_id, ws_function_name, enable_email_import, send_email_import_reply)
					SELECT @ixp_rules_id_new,
						   NULL,
						   NULL,
						   '\\SG-D-WEB01\shared_docs_TRMTracker_Release_June2020\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'nci',
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
								, file_transfer_endpoint_id = piids.file_transfer_endpoint_id
								, remote_directory = piids.remote_directory
							FROM ixp_import_data_source iids
							INNER JOIN #pre_ixp_import_data_source piids 
							ON iids.rules_id = piids.rules_id
						END
					

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id)   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'nci.[NAR ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'generator' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'nci.[Certificate Vintage]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'vintage_month' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'nci.[Certificate Vintage]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'vintage_year' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'nci.[Quantity]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Green-e''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'jurisdiction' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Green-e''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'tier' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'nci.[Certificate Serial Numbers]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'certificate_serial_numbers_from' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'nci.[Certificate Serial Numbers]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'certificate_serial_numbers_to' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'nci.[Certificate Serial Numbers]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'certificate_seq_from' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'nci.[Certificate Serial Numbers]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'certificate_seq_to' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'nci.[Transferor]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'counterparty' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'nci.[Asset]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'facility_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'nci.[Fuel/Project Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'technology' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''NAR''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'certification_entity' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory'

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
