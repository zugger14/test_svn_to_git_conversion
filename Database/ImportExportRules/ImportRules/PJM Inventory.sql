BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = '4033045D_3A02_4EC5_A6C5_650AE51218B9'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'PJM Inventory'
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
					'PJM Inventory' ,
					'N' ,
					NULL ,
					'IF NOT EXISTS(SELECT * FROM adiha_process.sys.columns
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
	EXEC(''	UPDATE b
			SET temp_rid = a.temp_rid			
			FROM [temp_process_table] a
			INNER JOIN [final_process_table] b
				ON  ISNULL(NULLIF(a.[generator],  ''''''''), -1)							= ISNULL(NULLIF(b.[generator], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Vintage Month], ''''''''), -1)						= ISNULL(NULLIF(b.[vintage_month], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Vintage Year], ''''''''), -1)						= ISNULL(NULLIF(b.[vintage_year], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Volume], ''''''''), -1)							= ISNULL(NULLIF(b.[volume], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Jurisdiction], ''''''''), -1)						= ISNULL(NULLIF(b.[jurisdiction], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Tier], ''''''''), -1)								= ISNULL(NULLIF(b.[tier], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate Serial Numbers From], ''''''''), -1)	= ISNULL(NULLIF(b.[certificate_serial_numbers_from], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate Serial Numbers To], ''''''''), -1)		= ISNULL(NULLIF(b.[certificate_serial_numbers_to], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate Seq from], ''''''''), -1)				= ISNULL(NULLIF(b.[certificate_seq_from], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate seq to], ''''''''), -1)				= ISNULL(NULLIF(b.[certificate_seq_to], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Issue Date], ''''''''), -1)						= ISNULL(NULLIF(b.[issue_date], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Expiry Date], ''''''''), -1)						= ISNULL(NULLIF(b.[expiry_date], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Counterparty], ''''''''), -1)						= ISNULL(NULLIF(b.[counterparty], ''''''''), -1)
				AND ISNULL(NULLIF(CAST(a.[Price] AS VARCHAR(40)), ''''''''), -1) =  ISNULL(NULLIF(CAST(b.[Price] AS VARCHAR(40)), ''''''''), -1)
				AND ISNULL(NULLIF(a.[Facility_Name], ''''''''), -1)						= ISNULL(NULLIF(b.[facility_name], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Generation_State], ''''''''), -1)					= ISNULL(NULLIF(b.[generation_state], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Technology], ''''''''), -1)						= ISNULL(NULLIF(b.[technology], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Source Certificate Number], ''''''''), -1)			= ISNULL(NULLIF(b.[source_certificate_number], ''''''''), -1)
				AND ISNULL(NULLIF(a.[action], ''''''''), -1)							= ISNULL(NULLIF(b.[action], ''''''''), -1)
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
/******************/

DECLARE @fuel_type_id INT
DECLARE @gen_state_type_id INT

select @fuel_type_id = type_id from static_data_type where type_name = ''Technology Type''
select @gen_state_type_id = type_id from static_data_type where type_name = ''State'' 

UPDATE gc
SET facility_name	 = a.facility_name,
	technology		 = sdv_t.value_id,
	generation_state = sdv_gs.value_id,
	unit_id			 = a.generator
FROM gis_certificate gc
INNER JOIN [temp_process_table] a
	ON a.certificate_serial_numbers_from = gc.gis_certificate_number_from
	AND a.certificate_serial_numbers_to = gc.gis_certificate_number_to
LEFT JOIN static_data_value sdv_t
	ON sdv_t.code = a.technology
	AND sdv_t.type_id = @fuel_type_id
LEFT JOIN static_data_value sdv_gs
	ON sdv_gs.code = a.generation_state
	AND sdv_gs.type_id = @gen_state_type_id
WHERE a.action = ''Transfer''
',
					'i' ,
					'y' ,
					@admin_user ,
					23502,
					1,
					'4033045D_3A02_4EC5_A6C5_650AE51218B9'
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
			SET ixp_rules_name = 'PJM Inventory'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = 'IF NOT EXISTS(SELECT * FROM adiha_process.sys.columns
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
	EXEC(''	UPDATE b
			SET temp_rid = a.temp_rid			
			FROM [temp_process_table] a
			INNER JOIN [final_process_table] b
				ON  ISNULL(NULLIF(a.[generator],  ''''''''), -1)							= ISNULL(NULLIF(b.[generator], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Vintage Month], ''''''''), -1)						= ISNULL(NULLIF(b.[vintage_month], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Vintage Year], ''''''''), -1)						= ISNULL(NULLIF(b.[vintage_year], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Volume], ''''''''), -1)							= ISNULL(NULLIF(b.[volume], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Jurisdiction], ''''''''), -1)						= ISNULL(NULLIF(b.[jurisdiction], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Tier], ''''''''), -1)								= ISNULL(NULLIF(b.[tier], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate Serial Numbers From], ''''''''), -1)	= ISNULL(NULLIF(b.[certificate_serial_numbers_from], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate Serial Numbers To], ''''''''), -1)		= ISNULL(NULLIF(b.[certificate_serial_numbers_to], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate Seq from], ''''''''), -1)				= ISNULL(NULLIF(b.[certificate_seq_from], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Certificate seq to], ''''''''), -1)				= ISNULL(NULLIF(b.[certificate_seq_to], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Issue Date], ''''''''), -1)						= ISNULL(NULLIF(b.[issue_date], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Expiry Date], ''''''''), -1)						= ISNULL(NULLIF(b.[expiry_date], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Counterparty], ''''''''), -1)						= ISNULL(NULLIF(b.[counterparty], ''''''''), -1)
				AND ISNULL(NULLIF(CAST(a.[Price] AS VARCHAR(40)), ''''''''), -1) =  ISNULL(NULLIF(CAST(b.[Price] AS VARCHAR(40)), ''''''''), -1)
				AND ISNULL(NULLIF(a.[Facility_Name], ''''''''), -1)						= ISNULL(NULLIF(b.[facility_name], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Generation_State], ''''''''), -1)					= ISNULL(NULLIF(b.[generation_state], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Technology], ''''''''), -1)						= ISNULL(NULLIF(b.[technology], ''''''''), -1)
				AND ISNULL(NULLIF(a.[Source Certificate Number], ''''''''), -1)			= ISNULL(NULLIF(b.[source_certificate_number], ''''''''), -1)
				AND ISNULL(NULLIF(a.[action], ''''''''), -1)							= ISNULL(NULLIF(b.[action], ''''''''), -1)
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
/******************/

DECLARE @fuel_type_id INT
DECLARE @gen_state_type_id INT

select @fuel_type_id = type_id from static_data_type where type_name = ''Technology Type''
select @gen_state_type_id = type_id from static_data_type where type_name = ''State'' 

UPDATE gc
SET facility_name	 = a.facility_name,
	technology		 = sdv_t.value_id,
	generation_state = sdv_gs.value_id,
	unit_id			 = a.generator
FROM gis_certificate gc
INNER JOIN [temp_process_table] a
	ON a.certificate_serial_numbers_from = gc.gis_certificate_number_from
	AND a.certificate_serial_numbers_to = gc.gis_certificate_number_to
LEFT JOIN static_data_value sdv_t
	ON sdv_t.code = a.technology
	AND sdv_t.type_id = @fuel_type_id
LEFT JOIN static_data_value sdv_gs
	ON sdv_gs.code = a.generation_state
	AND sdv_gs.type_id = @gen_state_type_id
WHERE a.action = ''Transfer''
'
				, import_export_flag = 'i'
				, ixp_owner = @admin_user
				, ixp_category = 23502
				, is_system_import = 'y'
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
						   'ri',
						   '1',
						   '
IF OBJECT_ID(''tempdb..#temp_table'') IS NOT NULL
	DROP TABLE #temp_table

SELECT [unit id] generator
	 , DATEPART(MONTH,[Month of Generation]) vintage_month
	 , DATEPART(YEAR,[Month of Generation]) vintage_year
	 , [Previous Owner] AS counterparty
	 , LTRIM(RTRIM(SUBSTRING([Certificate Serial Numbers], CHARINDEX(''-'', [Certificate Serial Numbers]) + 1, CHARINDEX(''to'',[Certificate Serial Numbers])- CHARINDEX(''-'',[Certificate Serial Numbers]) -1))) certificate_seq_from
	 , LTRIM(RTRIM(SUBSTRING([Certificate Serial Numbers], CHARINDEX(''to'',[Certificate Serial Numbers]) + 2, 20))) certificate_seq_to
	 , RTRIM(LEFT([Certificate Serial Numbers], CHARINDEX(''-'', [Certificate Serial Numbers])-1)) [source_certificate_number]
	 , [qty] AS volume
	 , CONVERT(MONEY, [price]) AS price
	 , [rec create] AS issue_date
	 , [facility name] [facility_name]
	 , [Loc of generator] [generation_state]
	 , [Fuel Type] [technology]
	 , [action]
	 , [New Jersey]
	 , [NJ State Number]
	 , [NJ Eligibility End Date]
	 , [Maryland]
	 , [MD State Number]
	 , [MD Eligibility End Date]
	 , [District of Columbia]	
	 , [DC State Number]	
	 , [DC Eligibility End Date]	
	 , [Pennsylvania]	
	 , [PA State Number]	
	 , [PA Eligibility End Date]	
	 , [Delaware]	
	 , [DE State Number]	
	 , [DE Eligibility End Date]	
	 , [Illinois]	
	 , [IL State Number]	
	 , [IL Eligibility End Date]	
	 , [Ohio]	
	 , [OH State Number]	
	 , [OH Eligibility End Date]	
	 , [Virginia]	
	 , [VA State Number]	
	 , [VA Eligibility End Date]
	 , [Green-e]
	 , [EFEC]
	 , [EFEC Cert Number]
INTO #temp_table
--FROM adiha_process.dbo.temp_import_data_table_ri_8D6A1F3C_3415_4BC0_9BF1_9E1522259A07
FROM [temp_process_table]

SELECT generator														[Generator]
	 , [facility_name]
	 , [generation_state]
	 , [technology]
	 , [action]
	 , source_certificate_number										[Source Certificate Number]
	 , counterparty														[Counterparty]
	 , vintage_month													[Vintage Month]
	 , vintage_year														[Vintage Year]
	 , LEFT([NJ State Number], charindex(''-'', [NJ State Number]) - 1)	[Jurisdiction]
	 , [New Jersey]														[Tier]
	 , [NJ State Number] + ''-'' + [source_certificate_number] + ''-'' + [certificate_seq_from]				[Certificate Serial Numbers From]
	 , [NJ State Number] + ''-'' + [source_certificate_number] + ''-'' + [certificate_seq_to]					[Certificate Serial Numbers To]
	 , volume															[Volume]
	 , price															[price]
	 , certificate_seq_from												[Certificate Seq From]
	 , certificate_seq_to												[Certificate Seq To]
	 , issue_date														[Issue Date]
	 , [NJ Eligibility End Date]										[Expiry Date]
--[__custom_table__]
FROM #temp_table
WHERE NULLIF([New Jersey], '''') IS NOT NULL
UNION ALL
SELECT generator
	 , [facility_name]
	 , [generation_state]
	 , [technology]
	 , [action]
	 , source_certificate_number										[Source Certificate Number]
	 , counterparty
	 , vintage_month
	 , vintage_year
	 , LEFT([MD State Number], charindex(''-'', [MD State Number]) - 1)
	 , [Maryland]
	 , [MD State Number] + ''-'' + [source_certificate_number] + ''-'' + [certificate_seq_from]
	 , [MD State Number] + ''-'' + [source_certificate_number] + ''-'' + [certificate_seq_to]
	 , volume
	 , price
	 , certificate_seq_from
	 , certificate_seq_to
	 , issue_date
	 , [MD Eligibility End Date]
FROM #temp_table
WHERE NULLIF([Maryland], '''') IS NOT NULL
UNION ALL
SELECT generator
	 , [facility_name]
	 , [generation_state]
	 , [technology]
	 , [action]
	 , source_certificate_number										[Source Certificate Number]
	 , counterparty
	 , vintage_month
	 , vintage_year
	 , LEFT([DC State Number], charindex(''-'', [DC State Number]) - 1)	
	 , [District of Columbia]
	 , [DC State Number] + ''-'' + [source_certificate_number] + ''-'' + [certificate_seq_from]
	 , [DC State Number] + ''-'' + [source_certificate_number] + ''-'' + [certificate_seq_to]
	 , volume
	 , price
	 , certificate_seq_from
	 , certificate_seq_to
	 , issue_date
	 , [DC Eligibility End Date]
FROM #temp_table
WHERE NULLIF([District of Columbia], '''') IS NOT NULL
UNION ALL
SELECT generator
	 , [facility_name]
	 , [generation_state]
	 , [technology]
	 , [action]
	 , source_certificate_number										[Source Certificate Number]
	 , counterparty
	 , vintage_month
	 , vintage_year
	 , LEFT([PA State Number], charindex(''-'', [PA State Number]) - 1)	
	 , [Pennsylvania]
	 , [PA State Number] + ''-'' + [source_certificate_number] + ''-'' + [certificate_seq_from]
	 , [PA State Number] + ''-'' + [source_certificate_number] + ''-'' + [certificate_seq_to]
	 , volume
	 , price
	 , certificate_seq_from
	 , certificate_seq_to
	 , issue_date
	 , [PA Eligibility End Date]	
FROM #temp_table
WHERE NULLIF([Pennsylvania], '''') IS NOT NULL
UNION ALL
SELECT generator
	 , [facility_name]
	 , [generation_state]
	 , [technology]
	 , [action]
	 , source_certificate_number										[Source Certificate Number]
	 , counterparty
	 , vintage_month
	 , vintage_year
	 , LEFT([DE State Number], charindex(''-'', [DE State Number]) - 1)	
	 , [Delaware]
	 , [DE State Number] + ''-'' + [source_certificate_number] + ''-'' + [certificate_seq_from]
	 , [DE State Number] + ''-'' + [source_certificate_number] + ''-'' + [certificate_seq_to]
	 , volume
	 , price
	 , certificate_seq_from
	 , certificate_seq_to
	 , issue_date
	 , [DE Eligibility End Date]
FROM #temp_table
WHERE NULLIF([Delaware], '''') IS NOT NULL
UNION ALL
SELECT generator
	 , [facility_name]
	 , [generation_state]
	 , [technology]
	 , [action]
	 , source_certificate_number										[Source Certificate Number]
	 , counterparty
	 , vintage_month
	 , vintage_year
	 , LEFT([IL State Number], charindex(''-'', [IL State Number]) - 1)	
	 , [Illinois]
	 , [IL State Number] + ''-'' + [source_certificate_number] + ''-'' + [certificate_seq_from]
	 , [IL State Number] + ''-'' + [source_certificate_number] + ''-'' + [certificate_seq_to]
	 , volume
	 , price
	 , certificate_seq_from
	 , certificate_seq_to
	 , issue_date
	 , [IL Eligibility End Date]
FROM #temp_table
WHERE NULLIF([Illinois], '''') IS NOT NULL
UNION ALL
SELECT generator
	 , [facility_name]
	 , [generation_state]
	 , [technology]
	 , [action]
	 , source_certificate_number										[Source Certificate Number]
	 , counterparty
	 , vintage_month
	 , vintage_year
	 , ''OH''--, LEFT([OH State Number], charindex(''-'', [OH State Number]) - 1)	
	 , [Ohio]	
	 , [OH State Number] + ''-'' + [source_certificate_number] + ''-'' + [certificate_seq_from]
	 , [OH State Number] + ''-'' + [source_certificate_number] + ''-'' + [certificate_seq_to]
	 , volume
	 , price
	 , certificate_seq_from
	 , certificate_seq_to
	 , issue_date
	 , [OH Eligibility End Date]
FROM #temp_table
WHERE NULLIF([Ohio], '''') IS NOT NULL
UNION ALL
SELECT generator
	 , [facility_name]
	 , [generation_state]
	 , [technology]
	 , [action]
	 , source_certificate_number										[Source Certificate Number]
	 , counterparty
	 , vintage_month
	 , vintage_year
	 , LEFT([VA State Number], charindex(''-'', [VA State Number]) - 1)
	 , [Virginia]
	 , [VA State Number] + ''-'' + [source_certificate_number] + ''-'' + [certificate_seq_from]
	 , [VA State Number] + ''-'' + [source_certificate_number] + ''-'' + [certificate_seq_to]
	 , volume
	 , price
	 , certificate_seq_from
	 , certificate_seq_to
	 , issue_date
	 , [VA Eligibility End Date]
FROM #temp_table
WHERE NULLIF([Virginia], '''') IS NOT NULL
UNION ALL
SELECT generator														[Generator]
	 , [facility_name]
	 , [generation_state]
	 , [technology]
	 , [action]
	 , source_certificate_number										[Source Certificate Number]
	 , counterparty														[Counterparty]
	 , vintage_month													[Vintage Month]
	 , vintage_year														[Vintage Year]
	 , CASE WHEN [Green-e] = ''Yes'' THEN ''Green-e'' ELSE NULL END		[Jurisdiction]
	 , CASE WHEN [Green-e] = ''Yes'' THEN ''Green-e'' ELSE NULL END		[Tier]
	 , CASE WHEN [Green-e] = ''Yes'' 
		  THEN 
			  ''Green-e'' + ''-'' + generator + ''-'' + RIGHT(''0'' + CAST(vintage_month AS VARCHAR(2)), 2) + CAST(vintage_year AS varchar(4)) + ''-''
		  ELSE 
			  NULL 
	   END + [source_certificate_number] + ''-'' + [certificate_seq_from]										[Certificate Serial Numbers From]
	 , CASE WHEN [Green-e] = ''Yes''
		  THEN 
			  ''Green-e'' + ''-'' + generator + ''-'' + RIGHT(''0'' + CAST(vintage_month AS VARCHAR(2)), 2) + CAST(vintage_year AS varchar(4)) + ''-''
		  ELSE 
			  NULL 
	   END + [source_certificate_number] + ''-'' + [certificate_seq_to]										[Certificate Serial Numbers To]
	 , volume															[Volume]
	 , price															[price]
	 , certificate_seq_from												[Certificate Seq From]
	 , certificate_seq_to												[Certificate Seq To]
	 , issue_date														[Issue Date]
	 , NULL					
FROM #temp_table
WHERE NULLIF([Green-e], '''') IS NOT NULL
UNION ALL
SELECT generator														[Generator]
	 , [facility_name]
	 , [generation_state]
	 , [technology]
	 , [action]
	 , source_certificate_number										[Source Certificate Number]
	 , counterparty														[Counterparty]
	 , vintage_month													[Vintage Month]
	 , vintage_year														[Vintage Year]
	 , CASE WHEN [EFEC] = ''Yes'' THEN ''EFEC'' ELSE NULL END			[Jurisdiction]
	 , CASE WHEN [EFEC] = ''Yes'' THEN ''EFEC'' ELSE NULL END			[Tier]
	 , CASE WHEN [EFEC] = ''Yes'' 
		  THEN 
			  [EFEC Cert Number] + ''-''
		  ELSE 
			  NULL 
	   END + [source_certificate_number] + ''-'' + [certificate_seq_from]										[Certificate Serial Numbers From]
	 , CASE WHEN [EFEC] = ''Yes'' 
		  THEN 
			  [EFEC Cert Number] + ''-''
		  ELSE 
			  NULL 
	   END + [source_certificate_number] + ''-'' + [certificate_seq_to]										[Certificate Serial Numbers To]
	 , volume															[Volume]
	 , price															[price]
	 , certificate_seq_from												[Certificate Seq From]
	 , certificate_seq_to												[Certificate Seq To]
	 , issue_date														[Issue Date]
	 , NULL			
FROM #temp_table
WHERE NULLIF([EFEC], '''') IS NOT NULL
',
						   'n',
						   0,
						   '',
						   '1',
						   'n',
						   'REC Inventory',
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
					

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id)   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[Generator]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'generator' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[Vintage Month]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'vintage_month' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[Vintage Year]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'vintage_year' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[Volume]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[Jurisdiction]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'jurisdiction' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[Tier]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'tier' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[Certificate Serial Numbers From]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'certificate_serial_numbers_from' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[Certificate Serial Numbers To]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'certificate_serial_numbers_to' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[Certificate Seq from]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'certificate_seq_from' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[Certificate seq to]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'certificate_seq_to' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[Issue Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'issue_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[Expiry Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'expiry_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[Counterparty]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'counterparty' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[Price]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'price' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[facility_name]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'facility_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[technology]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'technology' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[generation_state]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'generation_state' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[Source Certificate Number]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_certificate_number' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ri.[action]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_rec_inventory'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'action' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_rec_inventory' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''PJM-GATS''', 'Max', 0, NULL, NULL 
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
