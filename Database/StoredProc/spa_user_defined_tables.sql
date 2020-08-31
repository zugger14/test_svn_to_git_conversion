IF OBJECT_ID(N'[dbo].[spa_user_defined_tables]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_user_defined_tables]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO


/**
	Used to process data related to User defined tables
   
	Parameters:
		@flag					:	Operation flag that decides the action to be performed. Does not accept NULL.	
		@udt_id					:	User defined table Id
		@xml_data				:	XML data to process
		@xml_filter_data		:	XML filter data to process
		@udt_deleted_id			:	Deleted user defined table id
		@system					:	Flag to differentiate if it i system data or not
		@function_id			:	Function id of the menu
		@batch_process_id		:	Batch Processing Id
		@batch_report_param		:	Batch Parameters
		@enable_paging			:	Enable paging mode
		@page_size				:	Paging size
		@page_no				:	Page number
		@output					:	Output variable
*/

CREATE PROCEDURE [dbo].[spa_user_defined_tables]
	@flag NCHAR(1),
	@udt_id NVARCHAR(1000) = NULL,
	@xml_data XML = NULL,
	@xml_filter_data NVARCHAR(MAX) = NULL,
	@udt_deleted_id NVARCHAR(1000) = NULL,
	@system BIT = NULL,
	@function_id INT = NULL,
	@workflow_source_ids NVARCHAR(1000) = NULL,
	@workflow_process_table NVARCHAR(1000) = NULL,
	@batch_process_id NVARCHAR(250) = NULL,
	@batch_report_param NVARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL,
	@output NVARCHAR(MAX) = NULL OUTPUT
AS

/* DEBUG 
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON'); SET CONTEXT_INFO @contextinfo

DECLARE 
	@flag NCHAR(1),
	@udt_id NVARCHAR(1000) = NULL,
	@xml_data XML = NULL,
	@xml_filter_data NVARCHAR(MAX) = NULL,
	@udt_deleted_id NVARCHAR(1000) = NULL,
	@system BIT = NULL,
	@batch_process_id NVARCHAR(250) = NULL,
	@batch_report_param NVARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL

SELECT @flag='r',@udt_id='42,45'
--*/

SET NOCOUNT ON;

DECLARE @idoc INT
DECLARE @sql_string NVARCHAR(MAX)
DECLARE @sql_from NVARCHAR(MAX)
DECLARE @sql_lookup NVARCHAR(MAX)
DECLARE @table_name NVARCHAR(500),
		@table_columns NVARCHAR(MAX),
		@primary_column NVARCHAR(200),
		@identity_column NVARCHAR(200),
		@all_table_columns NVARCHAR(MAX),
		@update_string NVARCHAR(MAX),
		@update_column NVARCHAR(MAX),
		@product_category INT
		
/*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table NVARCHAR(MAX)
DECLARE @user_login_id NVARCHAR(50)
DECLARE @sql_paging NVARCHAR(MAX)
DECLARE @is_batch BIT
 
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
IF @is_batch = 1
   SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
 
IF @enable_paging = 1 --paging processing
BEGIN
   IF @batch_process_id IS NULL
      SET @batch_process_id = dbo.FNAGetNewID()
 
   SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)
 
   --retrieve data from paging table instead of main table
   IF @page_no IS NOT NULL 
   BEGIN
      SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
      EXEC (@sql_paging) 
      RETURN 
   END
END
 
/*******************************************1st Paging Batch END**********************************************/

IF @flag = 'h'
BEGIN
	SELECT	udtm_id,
			udt_id,
			column_name,
			column_descriptions,
			column_type,
			column_length,
			column_prec,
			column_scale,
			column_nullable,
			is_primary,
			is_identity,
			use_as_filter,
			effective_date_filter,
			required_filter,
			static_data_type_id,
			custom_sql,
			sequence_no,
			rounding,
			unique_combination,
			custom_validation,
			reference_column
	FROM user_defined_tables_metadata
	WHERE udt_id = @udt_id ORDER BY sequence_no
END

IF @flag = 'g'
BEGIN
	SELECT	udtm_id,
			udt_id,
			column_name,
			column_descriptions,
			column_type,
			column_length,
			column_prec,
			column_scale,
			column_nullable,
			is_primary,
			is_identity,
			use_as_filter,
			static_data_type_id,
			sequence_no,
			rounding,
			unique_combination,
			CASE custom_validation WHEN -1 THEN 'ValidYear' WHEN -2 THEN 'ValidMonth' ELSE '' END [custom_validation],
			effective_date_filter,
			required_filter,
			custom_sql,
			reference_column
	FROM user_defined_tables_metadata
	WHERE udt_id = @udt_id ORDER BY sequence_no
END

ELSE IF @flag = 'c'
BEGIN
	DECLARE @rename_column_sql NVARCHAR(MAX) = ''
		  , @alter_column_sql NVARCHAR(MAX) = ''
		  , @drop_column_sql NVARCHAR(MAX) = ''

	-- Assign a unique table hash during UDT export if table hash does not exists
	IF EXISTS ( SELECT 1
				FROM user_defined_tables
				WHERE udt_id = @udt_id
				AND udt_hash IS NULL )
	BEGIN
		UPDATE user_defined_tables
		SET udt_hash = dbo.FNAGetNewID()
		WHERE udt_id = @udt_id
			AND udt_hash IS NULL
	END

	-- Assign a unique column hash during UDT export if column hash does not exists
	IF EXISTS ( SELECT 1
				FROM user_defined_tables_metadata
				WHERE udt_id = @udt_id
				AND udt_column_hash IS NULL )
	BEGIN
		UPDATE user_defined_tables_metadata
		SET udt_column_hash = dbo.FNAGetNewID()
		WHERE udt_id = @udt_id
			AND udt_column_hash IS NULL
	END

	-- Generate sql script for table definition
	EXEC spa_user_defined_tables @flag='l', @udt_id=@udt_id, @output = @sql_string OUTPUT

	SELECT @table_name = udt_name FROM user_defined_tables WHERE udt_id = @udt_id
	SELECT @identity_column = column_name FROM user_defined_tables_metadata WHERE udt_id = @udt_id AND is_identity = 1
	SELECT @primary_column = column_name FROM user_defined_tables_metadata WHERE udt_id = @udt_id AND is_primary = 1
	SELECT @table_columns = STUFF((SELECT ',' + NCHAR(10) + NCHAR(9) + NCHAR(9) + NCHAR(9) +
						 '[' + column_name+ '] ' +
						UPPER(sdv.code) +
						CASE WHEN column_type = 104301 THEN '(' + CAST(column_length AS NVARCHAR) + ') ' ELSE ' ' END +
						CASE WHEN is_primary = 1 THEN ' PRIMARY KEY ' ELSE '' END +
						CASE WHEN is_identity = 1 THEN ' IDENTITY(1, 1) ' ELSE '' END +
						CASE WHEN column_nullable = 0 THEN ' NOT NULL' ELSE ' NULL' END
				FROM user_defined_tables_metadata udtm
				INNER JOIN static_data_value sdv ON sdv.value_id = udtm.column_type
				WHERE udt_id = @udt_id
				ORDER BY sequence_no
			  FOR XML PATH('')), 1, 1, '')

	IF @table_columns IS NOT NULL
	BEGIN
		SET @rename_column_sql = '
			-- Rename columns
			DECLARE @column_name NVARCHAR(200)
		'
		-- First we need to have this rename script so that while execution all necessary columns will be renamed first if modified else alter column sql script will add new column without renaming the modified column in destination table
		SELECT @rename_column_sql += '
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = ''udt_' + @table_name + '''
							AND sep.[value] = ''' + udtm.udt_column_hash + '''
							AND sc.[name] <> ''' + udtm.column_name + '''
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = ''udt_' + @table_name + '''
					AND sep.[value] = ''' + udtm.udt_column_hash + '''

				EXEC (''EXEC sp_rename ''''[dbo].[udt_' + @table_name + '].['' + @column_name + '']'''', ''''' + udtm.column_name + ''''', ''''COLUMN'''''')
			END
		'
		FROM user_defined_tables_metadata udtm
		INNER JOIN static_data_value sdv ON sdv.value_id = udtm.column_type
		WHERE udt_id = @udt_id
	
		-- Now create add/alter columns
		SET @alter_column_sql = '
			-- Add/Alter columns'
		SELECT @alter_column_sql += '
			IF COL_LENGTH(''[dbo].[udt_' + @table_name + ']'', ''' + column_name  + ''') IS NULL
			BEGIN
				ALTER TABLE udt_' + @table_name + ' ADD [' + column_name + '] ' + UPPER(sdv.code) + CASE WHEN column_type = 104301 THEN '(' + CAST(column_length AS NVARCHAR) + ') ' 
																									   ELSE ' ' 
																								  END +
																								  CASE WHEN column_nullable = 0 THEN 'NOT NULL' 
																									   ELSE 'NULL'
																								  END + '
			END
			ELSE
			BEGIN
				ALTER TABLE udt_' + @table_name + ' ALTER COLUMN [' + column_name + '] ' + UPPER(sdv.code) + CASE WHEN column_type = 104301 THEN '(' + CAST(column_length AS NVARCHAR) + ') ' 
																									   ELSE ' ' 
																								  END +
																								  CASE WHEN column_nullable = 0 THEN 'NOT NULL' 
																									   ELSE 'NULL'
																								  END + '
			END
		'
		FROM user_defined_tables_metadata udtm
		INNER JOIN static_data_value sdv ON sdv.value_id = udtm.column_type
		WHERE udt_id = @udt_id
	
		-- Then include drop constraint query if primary key exists or is changed
		IF @primary_column IS NOT NULL
		BEGIN
			SET @alter_column_sql += '
				IF EXISTS ( SELECT 1
							FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
							WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + ''.'' + QUOTENAME(CONSTRAINT_NAME)), ''IsPrimaryKey'') = 1
								AND TABLE_NAME = ''' + @table_name + ''' 
								AND TABLE_SCHEMA = ''dbo''
								AND COLUMN_NAME <> ''' + @primary_column  + '''
				)
				BEGIN
					DECLARE @primary_key_constraint NVARCHAR(100) = NULL

					SELECT @primary_key_constraint = [name]
					FROM sys.key_constraints
					WHERE [type] = ''PK''
						AND [parent_object_id] = OBJECT_ID(''dbo.udt_' + @table_name + ''')

					IF OBJECT_ID(N''[dbo].[udt_' + @table_name + ']'', N''U'') IS NOT NULL
					AND @primary_key_constraint IS NOT NULL
					BEGIN
						EXEC (''ALTER TABLE udt_' + @table_name + ' DROP CONSTRAINT '' + @primary_key_constraint)
					END

					IF COL_LENGTH(''[dbo].[udt_' + @table_name + ']'', ''' + @primary_column  + ''') IS NOT NULL
					BEGIN
						ALTER TABLE udt_' + @table_name + ' ADD PRIMARY KEY (' + @primary_column + ')
					END
				END '
		END
		
		-- Finally include drop column scripts at last
		SET @drop_column_sql = '
			-- Drop unused/deleted columns
			DECLARE @column_drop_sql NVARCHAR(MAX) = ''''

			SELECT @column_drop_sql += ''ALTER TABLE [dbo].[udt_' + @table_name + '] DROP COLUMN ['' + isc.COLUMN_NAME + ''];'' + NCHAR(13)
			FROM INFORMATION_SCHEMA.COLUMNS isc
			WHERE TABLE_NAME = N''udt_' + @table_name  + '''
				AND NOT EXISTS (
					SELECT udtm.column_name
					FROM user_defined_tables_metadata udtm
					INNER JOIN user_defined_tables udt
						ON udt.udt_id = udtm.udt_id
					WHERE udt.udt_name = ''' + @table_name + '''
						AND udtm.column_name = isc.COLUMN_NAME
				)
				AND isc.COLUMN_NAME NOT IN (''create_user'', ''create_ts'', ''update_user'', ''update_ts'')
		
			EXEC (@column_drop_sql)
		'
	END
	
	-- Final Script Start
	SET @sql_string =  '
	SET ANSI_NULLS ON
	GO

	SET QUOTED_IDENTIFIER ON
	GO

	-- Check if destination UDT view is already in use
	IF EXISTS ( SELECT 1 FROM [data_source] ds
				INNER JOIN report_dataset rd
					ON ds.data_source_id = rd.source_id
				WHERE ds.[name] = ''udt_' + @table_name + ''' )
	BEGIN
		IF EXISTS ( SELECT 1 FROM [data_source] ds
					INNER JOIN data_source_column dsc
						ON ds.data_source_id = dsc.source_id
					LEFT JOIN report_param rp
						ON dsc.data_source_column_id = rp.column_id
					LEFT JOIN report_tablix_column rtc
						ON dsc.data_source_column_id = rtc.column_id
					LEFT JOIN report_chart_column rcc
						ON dsc.data_source_column_id = rcc.column_id
					LEFT JOIN report_gauge_column rgc
						ON dsc.data_source_column_id = rgc.column_id
					WHERE ds.[name] = ''udt_' + @table_name + '''
					AND COALESCE(rp.report_param_id, rtc.report_tablix_column_id, rcc.report_chart_column_id, rgc.report_gauge_column_id) IS NULL
		)
		BEGIN
			EXEC spa_ErrorHandler 0,
				''Setup User Defined Tables'',
				''spa_user_defined_tables'',
				''Error'',
				''Source and destination user defined table are incompatible. Columns are used in report manager views.'',
				''''
			RETURN
		END
	END
	' + @sql_string
	
	IF @table_columns IS NOT NULL
	BEGIN
		DECLARE @udt_hash NVARCHAR(150)
		SELECT @udt_hash = udt_hash
		FROM user_defined_tables
		WHERE udt_id = @udt_id

		SET @sql_string +=  
		'
		DECLARE @udt_id INT
			  , @udt_name NVARCHAR(200)
	
		SELECT @udt_id = udt_id
			 , @udt_name = udt_name
		FROM user_defined_tables
		WHERE udt_hash = ''' + @udt_hash + '''

		-- Rename table if modified
		IF EXISTS ( SELECT 1
					FROM SYS.EXTENDED_PROPERTIES sep
					INNER JOIN sys.tables st 
						ON sep.major_id = st.object_id
					WHERE sep.minor_id = 0
						AND sep.[name] = ''udt_hash''
						AND sep.[value] = ''' + @udt_hash + '''
						AND st.[name] <> ''udt_'' + @udt_name )
		BEGIN
			-- Get modified udt name and rename it
			SELECT @udt_name = st.[name]
			FROM SYS.EXTENDED_PROPERTIES sep
			INNER JOIN sys.tables st 
				ON sep.major_id = st.object_id
			WHERE sep.minor_id = 0
				AND sep.[name] = ''udt_hash''
				AND sep.[value] = ''' + @udt_hash + '''

			EXEC (''EXEC sp_rename ''''[dbo].['' + @udt_name + '']'''', ''''udt_' + @table_name + ''''''')
		END

		IF OBJECT_ID(N''[dbo].[udt_' + @table_name + ']'', N''U'') IS NULL
		BEGIN
			CREATE TABLE [dbo].[udt_' + @table_name + ']
			(	' + @table_columns + ',
    			[create_user] NVARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    			[create_ts] DATETIME NULL DEFAULT GETDATE(),
    			[update_user] NVARCHAR(50) NULL,
    			[update_ts]	DATETIME NULL
			)
		END
		ELSE
		BEGIN' + @rename_column_sql + '
			' + @alter_column_sql + '
			' + @drop_column_sql + '
		END
		GO

		IF OBJECT_ID(''[dbo].[TRGUPD_udt_' + @table_name + ']'', ''TR'') IS NOT NULL
			DROP TRIGGER [dbo].[TRGUPD_udt_' + @table_name + ']
		GO

		CREATE TRIGGER [dbo].[TRGUPD_udt_' + @table_name + ']
		ON [dbo].[udt_' + @table_name + ']
		FOR UPDATE
		AS
			UPDATE udt_' + @table_name + '
			   SET update_user = dbo.FNADBUser(),
				   update_ts = GETDATE()
			FROM udt_' + @table_name + ' t
			  INNER JOIN DELETED u ON t.[' + @identity_column + '] = u.[' + @identity_column + ']
		GO
		'
	
		SELECT @sql_string +='
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						WHERE sep.minor_id = 0
							AND sep.[name] = ''udt_hash'' )
		BEGIN
			-- Store udt hash in extended property of table so that it can be accessed later to indentify table for renaming purpose
			EXEC sys.sp_addextendedproperty 
				  @name = ''udt_hash''
				, @value = ''' + udt_hash + '''
				, @level0type = N''SCHEMA''
				, @level0name = ''dbo''
				, @level1type = N''TABLE''
				, @level1name = ''udt_' + udt_name + '''
		END
		'
		FROM user_defined_tables
		WHERE udt_id = @udt_id

		SELECT @sql_string += '
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = ''udt_' + udt.udt_name + '''
							AND sc.name = ''' + udtm.column_name + ''' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = ''udt_column_hash''
				, @value = ''' + udtm.udt_column_hash + '''
				, @level0type = N''SCHEMA''
				, @level0name = ''dbo''
				, @level1type = N''TABLE''
				, @level1name = ''udt_' + udt.udt_name + '''
				, @level2type = N''COLUMN''
				, @level2name = ''' + udtm.column_name + '''
		END
		'
		FROM user_defined_tables_metadata udtm
		INNER JOIN user_defined_tables udt
			ON udt.udt_id = udtm.udt_id
		WHERE udtm.udt_id = @udt_id
	END

	SELECT @sql_string AS 'script_sql'
		 , 'udt_' + @table_name + '.sql' AS 'script_name'
END

ELSE IF @flag IN ('s', 'p')
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	DECLARE @udt_column_name NVARCHAR(MAX) 
	DECLARE @udt_column_name_where NVARCHAR(MAX)
	DECLARE @filter_data NVARCHAR(MAX) 

	SELECT @udt_column_name = COALESCE (@udt_column_name + ', ', '') + CASE WHEN udtm.column_type = 104304 THEN '[' + column_name + '_to] NVARCHAR(4000), [' + column_name + '_from] NVARCHAR(4000)' ELSE '[' + column_name + '] NVARCHAR(4000) ' END
	FROM user_defined_tables_metadata udtm
	WHERE udtm.udt_id = @udt_id
	
	-------not needed for filter, makes slow
	--SELECT @udt_column_name_where = COALESCE (@udt_column_name_where + ' AND ', '') + 'CAST(ISNULL(mt.['+ column_name + '], -1)AS NVARCHAR) = ISNULL(NULLIF(filter_table.[' + column_name + '], ''''), ISNULL(mt.['+ column_name + '], -1)) '
	--FROM user_defined_tables_metadata udtm 
	--WHERE udtm.udt_id = @udt_id 
	--AND udtm.is_primary = 0 
	--AND udtm.use_as_filter <> 1

	
	-- Filter column type NVARCHAR
	SELECT @udt_column_name_where = COALESCE (@udt_column_name_where + ' AND ', '') + 'CAST(ISNULL(mt.['+ column_name + '], -1)AS NVARCHAR(500)) LIKE ''%'' + ISNULL(NULLIF(filter_table.[' + column_name + '], ''''), ISNULL(mt.['+ column_name + '], -1)) + ''%'' '
	FROM user_defined_tables_metadata udtm
	WHERE udtm.udt_id = @udt_id 
		AND udtm.use_as_filter = 1 
		AND udtm.column_type = 104301

	-- Filter column type int 
	SELECT @udt_column_name_where = COALESCE (@udt_column_name_where + ' AND ', '') + 'CAST(ISNULL(mt.['+ column_name + '], -1)AS NVARCHAR) = ISNULL(NULLIF(filter_table.[' + column_name + '], ''''), ISNULL(mt.['+ column_name + '], -1)) '
	FROM user_defined_tables_metadata udtm
	WHERE udtm.udt_id = @udt_id 
		AND udtm.use_as_filter = 1 
		AND udtm.column_type = 104302

	-- Filter column type date
	SELECT @udt_column_name_where = COALESCE (@udt_column_name_where + ' AND ', '') + 'CAST(ISNULL(mt.['+ column_name + '], ''1900-01-01'')AS DATE) >= CAST(ISNULL(NULLIF(dbo.FNAClientToSqlDate(filter_table.[' + column_name + '_from]), ''''), ISNULL(mt.['+ column_name + '], ''1900-01-01'')) AS DATE) AND CAST(ISNULL(mt.['+ column_name + '], ''1900-01-01'')AS DATE) <= CAST(ISNULL(NULLIF(dbo.FNAClientToSqlDate(filter_table.[' + column_name + '_to]), ''''), ISNULL(mt.['+ column_name + '], ''1900-01-01'')) AS DATE)'

	FROM user_defined_tables_metadata udtm
	WHERE udtm.udt_id = @udt_id 
		AND udtm.use_as_filter = 1 
		AND udtm.column_type = 104304
		AND (udtm.effective_date_filter <> 1 OR udtm.effective_date_filter IS NULL)

	IF @flag = 's'
	BEGIN
		SELECT @table_columns = STUFF((SELECT ',' + CASE column_type WHEN 104303 THEN 'round(mt.[' + column_name+ '], ' + CAST(ISNULL(rounding, 16) AS NVARCHAR) + ') AS [' + column_name + ']'  ELSE 'mt.[' + column_name+ ']' END
		FROM user_defined_tables_metadata
		WHERE udt_id = @udt_id
		ORDER BY sequence_no
		FOR XML PATH('')), 1, 1, '')
	END
	ELSE
	BEGIN
		/*
			Handle lookup columns
			e.g. SELECT mt.[id]			--regular column
				, mt.[effective_date]	--regular column
				, [sdv_rate_schedule].code as [rate_schedule]	--lookup column
		*/
		SELECT @table_columns = STUFF((SELECT ',' + 
										CASE column_type 
											WHEN 104303 THEN 'round(mt.[' + column_name+ '], ' + CAST(ISNULL(rounding, 16) AS NVARCHAR) + ') AS [' + column_name + ']'  
											ELSE (CASE WHEN udtm.static_data_type_id IS NOT NULL THEN QUOTENAME('sdv_' + udtm.column_name) + '.code' ELSE 'mt.[' + column_name+ ']' END) 
										END + ' AS ' + QUOTENAME(udtm.column_name)
				FROM user_defined_tables_metadata udtm WHERE udt_id = @udt_id ORDER BY sequence_no
			FOR XML PATH('')), 1, 1, '')

		EXEC spa_print @table_columns
	END

	SELECT @table_name = 'udt_' + udt_name FROM user_defined_tables WHERE udt_id = @udt_id
	
	IF OBJECT_ID('tempdb..#tmp_udt_filter_data') IS NOT NULL
		DROP TABLE #tmp_udt_filter_data

	DECLARE @unique_const NVARCHAR(500)
			  , @col_effective_date NVARCHAR(50)
			  , @group_by NVARCHAR(500)
			  , @temp_table NVARCHAR(100)
			  , @eff_date_value_user_format NVARCHAR(20)
			  , @eff_date_value DATETIME
			  , @sql_eff_date NVARCHAR(MAX)

	SET @temp_table = 'adiha_process.dbo.tmp_udt_filter_data_' + dbo.FNADBUSER() + '_' + REPLACE(NEWID(), '-', '_')

	SELECT @col_effective_date = column_name
	FROM user_defined_tables_metadata udtm
	WHERE udtm.udt_id = @udt_id 
		AND effective_date_filter = 1

	SET @sql = N'
			DECLARE @idoc  INT
			DECLARE @xml_filter_data xml =''' + @xml_filter_data + '''
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_filter_data

			SELECT *
			INTO '+ @temp_table + '
			FROM OPENXML(@idoc, ''FormXML'', 1)
			WITH ('
				+ @udt_column_name +
			')
			'

	IF @col_effective_date IS NOT NULL
	BEGIN
		SET @sql += 'SELECT @eff_date_value_user_format_out = ' +  @col_effective_date + '
			FROM '+ @temp_table
	END
	
	-- Get effective_date value from process table
	EXECUTE sp_executesql
		@sql,
		N'@eff_date_value_user_format_out NVARCHAR(20) OUTPUT',
		@eff_date_value_user_format_out=@eff_date_value_user_format OUTPUT
	
	--SET @eff_date_value = dbo.FNAClientToSqlDate(@eff_date_value_user_format)
	
	-- Filter column type date and column is effective date
	IF EXISTS (SELECT 1 FROM user_defined_tables_metadata WHERE udt_id = @udt_id AND effective_date_filter = 1 AND @eff_date_value_user_format <> '')
	BEGIN
		SELECT @unique_const = COALESCE (@unique_const + ' AND ', '') + 'rs_eff_date.' + column_name + ' = ' + 'mt.' + column_name
		FROM user_defined_tables_metadata udtm
		WHERE udtm.udt_id = @udt_id 
		AND unique_combination = 1

		SELECT @group_by = COALESCE (@group_by + ', ', '') + 'mt_inner.' + column_name
		FROM user_defined_tables_metadata udtm
		WHERE udtm.udt_id = @udt_id 
		AND unique_combination = 1
		AND effective_date_filter <> 1

		SET @sql_from = '
			(
				SELECT MAX(' + @col_effective_date + ') effective_date, ' + @group_by  + '
				FROM ' + @table_name + ' mt_inner 
				WHERE mt_inner.' + @col_effective_date + ' <= ''' + @eff_date_value_user_format + '''
				GROUP BY ' + @group_by + '
			) rs_eff_date
			INNER JOIN ' + @table_name + ' mt ON ' + @unique_const + '
			INNER JOIN ' + @temp_table + ' filter_table
			ON 1 = 1 
			'
		EXEC spa_print @sql
	END
	ELSE
	BEGIN
		SET @sql_from = @table_name + ' mt WITH(NOLOCK)
		INNER JOIN ' + @temp_table + ' filter_table WITH(NOLOCK)
		'
	END

	--resolve lookup values (currently only static data are supported for lookup)
	IF @flag = 'p'
	BEGIN
	/*
		e.g.
		LEFT JOIN static_data_value AS [sdv_rate_schedule] 
			ON [sdv_rate_schedule].value_id = mt.rate_schedule
	*/
		SELECT @sql_lookup = COALESCE(@sql_lookup + NCHAR(13) + NCHAR(10), '') + ' 
			LEFT JOIN static_data_value AS ' + QUOTENAME('sdv_' + udtm.column_name) + ' 
				ON ' + QUOTENAME('sdv_' + udtm.column_name) + '.value_id = mt.' + udtm.column_name
		FROM user_defined_tables_metadata udtm
		WHERE udtm.udt_id = @udt_id 
			AND static_data_type_id IS NOT NULL	
	END

	-- When no filter is used.
	IF @xml_filter_data = '<FormXML></FormXML>'
	BEGIN
		SET @sql = '
			SELECT ' + @table_columns + @str_batch_table + '
			FROM ' + @table_name + ' mt'
	END
	ELSE
	BEGIN
		SET @sql = '
			SELECT ' + @table_columns + @str_batch_table + '
			FROM ' + @sql_from + ' ' + ISNULL(@sql_lookup, '') + ' ON ' + ISNULL(@udt_column_name_where, '1 = 1') + ''
	END

	EXEC (@sql)
	/*******************************************2nd Paging Batch START**********************************************/
 
	--update time spent and batch completion message in message board
	IF @is_batch = 1
	BEGIN
	   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
	   EXEC(@sql_paging)
 
	   --TODO: modify sp and report name
	   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_user_defined_tables', 'View User Defined Tables')
	   EXEC(@sql_paging)  
 
	   RETURN
	END
 
	--if it is first call from paging, return total no. of rows and process id instead of actual data
	IF @enable_paging = 1 AND @page_no IS NULL
	BEGIN
	   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	   EXEC(@sql_paging)
	END
 
	/*******************************************2nd Paging Batch END**********************************************/
END

ELSE IF @flag = 'i'
BEGIN
	SELECT @table_name = 'udt_' + udt_name FROM user_defined_tables WHERE udt_id = @udt_id

	IF OBJECT_ID(N'[dbo].['+ @table_name + ']') IS NULL
	BEGIN
		EXEC spa_ErrorHandler -1,
        'View User Defined Tables',
        'spa_user_defined_tables',
        'Error',
        'Table not found. Run generate table script.',
        ''	
		RETURN
	END
	
	SELECT @table_name = udt_name FROM user_defined_tables WHERE udt_id = @udt_id

	SET @sql_string = '
	SET NOCOUNT ON
	DECLARE @ixp_table_id INT,
			@ixp_rule_hash NVARCHAR(50)
	IF NOT EXISTS (SELECT 1 FROM ixp_tables WHERE ixp_tables_name = ''ixp_udt_' + @table_name + ''')
	BEGIN
		INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description)
		SELECT ''ixp_udt_' + @table_name + ''', ''udt_' + @table_name + '''

		SET @ixp_table_id = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = ''ixp_udt_' + @table_name + '''
	END
	
	SET @ixp_rule_hash  = dbo.FNAGETNEWID()

	IF EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = ''' + @table_name + ''') BEGIN
		EXEC spa_ixp_rules @flag = ''d'', @ixp_rules_name = ''' + @table_name + ''', @show_delete_msg = ''n'' END

	DELETE FROM ixp_columns WHERE ixp_table_id = @ixp_table_id

	'

	SELECT @table_columns = STUFF((SELECT NCHAR(10) + '' +
				NCHAR(9) + NCHAR(9) + 'INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq)' + NCHAR(10) +
				NCHAR(9) + NCHAR(9) +'SELECT @ixp_table_id, ''' + column_name + ''', ''NVARCHAR(600)'', 0, ' + CAST(sequence_no AS NVARCHAR(5)) + '' + NCHAR(10)
			FROM user_defined_tables_metadata WHERE udt_id = @udt_id
			AND is_identity <> 1
			FOR XML PATH('')), 1, 1, '')

	SET @sql_string+= NCHAR(10) + NCHAR(10) + @table_columns

	SET @sql_string += NCHAR(10) + NCHAR(10) + '
	IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = ''' + @table_name + ''') BEGIN BEGIN TRY BEGIN TRAN
		INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
					VALUES(
						''' + @table_name + ''' ,
						''n'' ,
						NULL ,
						NULL,
						NULL,
						''i'' ,
						''y'' ,
						''farrms_admin'' ,
						23504,
						1,
						@ixp_rule_hash
						)
		DECLARE @ixp_rules_id_new INT
		SET @ixp_rules_id_new = SCOPE_IDENTITY()

		INSERT INTO ixp_export_tables (ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number)
		SELECT @ixp_rules_id_new,
				it.ixp_tables_id,
				dependent_table.ixp_tables_id,
				0,
				0,
				0
		FROM ixp_tables it
		LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
		WHERE it.ixp_tables_name = ''ixp_udt_' + @table_name + '''

		INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id)
		SELECT @ixp_rules_id_new,
				21400,
				'''',
				''\\PSSJCDEV01\shared_docs_TRMTracker_Trunk\temp_Note\0'',
				NULL,
				'','',
				2,
				''udt'',
				''0'',
				NULL,
				''n'',
				0,
				'''',
				''0'',
				''n'',
				'''',
				isc.ixp_ssis_configurations_id,
				isf.ixp_soap_functions_id
		FROM ixp_rules ir
		LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = ''''
		LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = ''''
		WHERE ir.ixp_rules_id = @ixp_rules_id_new

		INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause )'

	SELECT @table_columns = STUFF((SELECT ' UNION ALL ' +
				NCHAR(9) + NCHAR(9) + 'SELECT @ixp_rules_id_new, it.ixp_tables_id, ''' + column_name + ''', ic.ixp_columns_id, NULL, NULL, 0, NULL ' + NCHAR(10) +
				NCHAR(9) + NCHAR(9) + 'FROM ixp_tables it' + NCHAR(10) +
				NCHAR(9) + NCHAR(9) + 'INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = ''ixp_udt_' + @table_name + '''' + NCHAR(10) +
				NCHAR(9) + NCHAR(9) + 'INNER JOIN ixp_columns ic ON ic.ixp_columns_name = ''' + column_name + ''' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = ''NULL'' OR ic.header_detail IS NULL)' + NCHAR(10) +
				NCHAR(9) + NCHAR(9) + 'WHERE it.ixp_tables_name = ''ixp_udt_' + @table_name + ''''
			FROM user_defined_tables_metadata WHERE udt_id = @udt_id
			AND is_identity <> 1
			FOR XML PATH('')), 1, 12, '')

	SET @sql_string+= NCHAR(10) + NCHAR(9) + @table_columns + '
		COMMIT

		EXEC spa_ErrorHandler 0,
             ''Setup User Defined Tables'',
             ''spa_user_defined_tables'',
             ''Success'',
             ''Changes has been successfully saved.'',
             ''''

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN;

			EXEC spa_ErrorHandler -1,
				''Setup User Defined Tables'',
				''spa_user_defined_tables'',
				''Error'',
				''Create/Update import rule failed.'',
				''''
		END CATCH
	END'

	EXEC (@sql_string)
END

ELSE IF @flag = 't'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

		SELECT @table_name = 'udt_' + udt_name FROM user_defined_tables WHERE udt_id = @udt_id
		SELECT @identity_column = column_name FROM user_defined_tables_metadata WHERE udt_id = @udt_id AND is_identity = 1

		IF OBJECT_ID('tempdb..#tmp_udt_data') IS NOT NULL
			DROP TABLE #tmp_udt_data

		SELECT	row_id			[row_id],
				column_name		[column_name],
				column_value	[column_value]
		INTO #tmp_udt_data
		FROM OPENXML(@idoc, '/Grid/GridData', 1)
		WITH (
			row_id				NVARCHAR(MAX),
			column_name			NVARCHAR(MAX),
			column_value		NVARCHAR(MAX)
		)

		SELECT @table_columns = STUFF((SELECT ',[' + column_name + ']'
				FROM user_defined_tables_metadata WHERE udt_id = @udt_id AND is_identity = 0
				FOR XML PATH('')), 1, 1, '')

		DECLARE @table_columns_from NVARCHAR(MAX)
		SELECT @table_columns_from = STUFF((SELECT ',NULLIF([' + column_name + '], '''')'
				FROM user_defined_tables_metadata WHERE udt_id = @udt_id AND is_identity = 0
				FOR XML PATH('')), 1, 1, '')

		SELECT @all_table_columns = STUFF((SELECT ',[' + column_name + ']'
				FROM user_defined_tables_metadata WHERE udt_id = @udt_id --AND is_identity = 0
				FOR XML PATH('')), 1, 1, '')

		SELECT @update_column = STUFF((SELECT ',' + 't.['+ column_name + ']= NULLIF(b.['+ column_name + '], '''')'
				FROM user_defined_tables_metadata WHERE udt_id = @udt_id AND is_identity = 0
				FOR XML PATH('')), 1, 1, '')

		DECLARE @table_columns_combination NVARCHAR(MAX)
		SELECT @table_columns_combination = COALESCE (@table_columns_combination + ' AND ', '') + 'CAST(ISNULL(mt.['+ column_name + '], -1)AS NVARCHAR(200)) = ISNULL(NULLIF(filter_table.[' + column_name + '], ''''), ISNULL(mt.['+ column_name + '], -1)) '
		FROM user_defined_tables_metadata udtm WHERE udtm.udt_id = @udt_id AND unique_combination = 1

		DECLARE @table_primary_column NVARCHAR(MAX)
		SELECT @table_primary_column = column_name
				FROM user_defined_tables_metadata udtm WHERE udtm.udt_id = @udt_id AND is_identity = 1

		DECLARE @table_columns_unique_combination NVARCHAR(MAX)
		SELECT @table_columns_unique_combination = 	COALESCE (@table_columns_unique_combination + ', ', '') + column_descriptions 
			FROM user_defined_tables_metadata udtm WHERE udtm.udt_id = @udt_id AND unique_combination = 1

		IF OBJECT_ID('tempdb..#Temp_error') IS NOT NULL
			DROP TABLE #Temp

		CREATE TABLE #Temp_error
		(
			ID INT
		)

		--------- Unique combination
		SET @sql = '
			SELECT ' + @all_table_columns + '
			INTO #temp_data_all
			FROM
			(SELECT row_id, column_name, column_value
				FROM #tmp_udt_data
			) AS data_table
			PIVOT
			(
				MAX(column_value)
				FOR column_name IN (' + @all_table_columns + ')
			) AS PivotTable
			
			--SELECT * FROM #temp_data_all

			IF EXISTS(SELECT 1 FROM ' + @table_name + ' mt INNER JOIN #temp_data_all filter_table ON ' + @table_columns_combination + ' WHERE filter_table.' + @table_primary_column + '<> mt.' + @table_primary_column + ')
			BEGIN
				INSERT INTO #Temp_error
				SELECT 1
			END
			'
		--print @sql
		EXEC(@sql)
		---------------

		--select * from #Temp_error
		DECLARE @msg NVARCHAR(MAX)= 'Combination of ' + @table_columns_unique_combination + ' should be unique.'
		IF EXISTS (SELECT 1 FROM #Temp_error)
		BEGIN
			EXEC spa_ErrorHandler -1,
			'View User Defined Tables',
			'spa_user_defined_tables',
			'Error',
			@msg,
			''
			RETURN
		END

		/* Saving the inserted/updated ids to use in workflow */
		IF OBJECT_ID('tempdb..#temp_new_udt_ids') IS NOT NULL
			DROP TABLE #temp_new_udt_ids
		CREATE TABLE #temp_new_udt_ids(source_ids INT, insert_update_flag NCHAR(1))

		SET @update_string = '
			SELECT ' + @all_table_columns + '
			INTO #temp_data_all
			FROM
			(SELECT row_id, column_name, column_value
				FROM #tmp_udt_data
				WHERE LEN(row_id) < 8
			) AS data_table
			PIVOT
			(
				MAX(column_value)
				FOR column_name IN (' + @all_table_columns + ')
			) AS PivotTable

			UPDATE t SET '+ @update_column + '
			FROM ' + @table_name + ' t
			JOIN #temp_data_all b
			ON b.[' + @identity_column + '] = t.[' + @identity_column + ']

			INSERT INTO #temp_new_udt_ids (source_ids, insert_update_flag)
			SELECT t.[' + @identity_column + '], ''u'' [insert_update_flag] FROM ' + @table_name + ' t
			INNER JOIN #temp_data_all b ON b.[' + @identity_column + '] = t.[' + @identity_column + ']
			'
			--DELETE t
			--FROM ' + @table_name + ' t
			--LEFT JOIN #temp_data_all b
			--ON b.[' + @identity_column + '] = t.[' + @identity_column + ']
			--WHERE b.[' + @identity_column + '] IS NULL

		--PRINT @update_string
		EXEC(@update_string)
		SET @sql_string = '
			SELECT ' + @table_columns + '
			INTO #temp_data
			FROM
			(SELECT row_id, column_name, column_value
				FROM #tmp_udt_data
				WHERE LEN(row_id) > 8
			) AS data_table
			PIVOT
			(
				MAX(column_value)
				FOR column_name IN (' + @table_columns + ')
			) AS PivotTable

			INSERT INTO ' + @table_name + '(' + @table_columns + ')
			OUTPUT INSERTED.[' + @identity_column + ']
			INTO #temp_new_udt_ids(source_ids)
			SELECT ' + @table_columns_from + ' FROM #temp_data'
		--print @sql_string
		EXEC(@sql_string)


		/* Call the workflow logic of the UDT */
		SELECT DISTINCT @workflow_source_ids = stuff((select ', ' + CAST(source_ids AS VARCHAR)
					FROM #temp_new_udt_ids t1
					FOR XML PATH('')), 1, 2, '')

		EXEC spa_user_defined_tables @flag = 'w', @udt_id = @udt_id, @workflow_source_ids = @workflow_source_ids

		EXEC spa_ErrorHandler 0,
             'View User Defined Tables',
             'spa_user_defined_tables',
             'Success',
             'Changes has been successfully saved.',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		DECLARE @err_msg NVARCHAR(MAX)
		SELECT @table_name = 'udt_' + udt_name FROM user_defined_tables WHERE udt_id = @udt_id

		IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @table_name)
		BEGIN
			SET @err_msg = 'Table does not exists. Run script to create table.'
		END
		ELSE
		BEGIN
		SET @err_msg = error_message()
		END

		EXEC spa_ErrorHandler -1,
             'View User Defined Tables',
             'spa_user_defined_tables',
             'Error',
             @err_msg,
             ''
	END CATCH

END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
	SELECT @table_name = 'udt_' + udt_name FROM user_defined_tables WHERE udt_id = @udt_id
	SELECT @table_columns = column_name
		FROM user_defined_tables_metadata WHERE udt_id = @udt_id AND is_identity = 1
	
	SET @sql =' 
		DELETE tab1 FROM ' + @table_name + ' tab1 
			INNER JOIN dbo.SplitCommaSeperatedValues('''+ @udt_deleted_id +''') a ON a.[item] = tab1.['+ @table_columns + ']'
	EXEC(@sql)

	EXEC spa_ErrorHandler 0,
        'View User Defined Tables',
        'spa_user_defined_tables',
        'Success',
        'Changes has been successfully saved.',
            ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		SET @err_msg = error_message()
		EXEC spa_ErrorHandler -1,
            'View User Defined Tables',
            'spa_user_defined_tables',
            'Error',
            @err_msg,
            ''
	END CATCH

END

ELSE IF @flag = 'v'
BEGIN
	DECLARE @udt_data_source_name NVARCHAR(200)
	SELECT @table_name = 'udt_' + udt_name FROM user_defined_tables WHERE udt_id = ABS(@udt_id)

	/*
	 * If udt_id is send in negative then it is to create the view for udt workflow.
	 * udt_id < 0 logics are specific to workflow views
	 */

	IF @udt_id < 0
	BEGIN
		SET @udt_data_source_name = 'workflow_' + @table_name
	END
	ELSE 
	BEGIN
		SET @udt_data_source_name = @table_name
	END
		
	IF OBJECT_ID(N'[dbo].['+ @table_name + ']') IS NULL
	BEGIN
		EXEC spa_ErrorHandler -1,
        'View User Defined Tables',
        'spa_user_defined_tables',
        'Error',
        'Table not found. Run generate table script.',
        ''	
		RETURN
	END

	DECLARE @new_data_source_id INT
		
	BEGIN TRY
		BEGIN TRAN
		IF NOT EXISTS (
			SELECT 1 FROM data_source ds 
			INNER JOIN user_defined_tables udt 
				ON CASE WHEN @udt_id < 0 THEN 'workflow_udt_' + udt.udt_name ELSE 'udt_' + udt.udt_name END = ds.name
			WHERE udt.udt_id = ABS(@udt_id)
		) 
		BEGIN
			INSERT INTO data_source(
				[type_id]
			  , [name]
			  , [alias]
			  , [description]
			  , [tsql]
			) 
			SELECT '1'
				 , @udt_data_source_name
				 , 'udt' + CAST(udt_id AS NVARCHAR)
				 , @udt_data_source_name
				 , 'SELECT * FROM ' + 'udt_' + udt_name
			FROM user_defined_tables udt
			WHERE udt.udt_id = ABS(@udt_id)
		END

		SELECT @new_data_source_id = data_source_id
		FROM [data_source]
		WHERE [name] = @udt_data_source_name

		INSERT INTO data_source_column (
			source_id
			, [name]
			, alias
			, widget_id
			, datatype_id
			, param_data_source
			, append_filter
			, key_column
		)
		SELECT @new_data_source_id [source_id]
			, udtm.column_name [name]
			, udtm.column_descriptions [alias]
			, IIF(udtm.static_data_type_id IS NOT NULL,2,1) [widget_id]
			, rd.report_datatype_id [datatype_id]
			, CASE udtm.static_data_type_id 
				WHEN -1 THEN 'SELECT source_counterparty_id,counterparty_id FROM source_counterparty ORDER BY 2' 
				WHEN -2 THEN 'EXEC spa_source_minor_location ''o''' 
				WHEN -3 THEN 'EXEC spa_source_currency_maintain ''p''' 
				WHEN -4 THEN 'EXEC [spa_source_uom_maintain] ''s''' 
				WHEN -5 THEN 'SELECT book_deal_type_map_id,logical_name FROM source_system_book_map' 
				ELSE 'SELECT value_id,code FROM static_data_value WHERE type_id = ' + CAST(udtm.static_data_type_id AS NVARCHAR(20))
				END [param_data_source]
			,0 [append_filter]
			,0 [key_column]
		FROM user_defined_tables_metadata udtm
		LEFT JOIN static_data_value sdv_col_type ON sdv_col_type.value_id = udtm.column_type
		LEFT JOIN report_datatype rd ON rd.name = sdv_col_type.code
		WHERE udtm.udt_id = ABS(@udt_id)
		AND NOT EXISTS (
			SELECT 1 FROM data_source_column dsc
			WHERE dsc.[name] = udtm.column_name
			AND dsc.source_id = @new_data_source_id
		)

		IF @udt_id < 0
		BEGIN
			UPDATE [data_source]
			SET category = 106502
			WHERE data_source_id = @new_data_source_id

			DECLARE @udt_primary_column NVARCHAR(200)
			SELECT @udt_primary_column = column_name
			FROM user_defined_tables_metadata
			WHERE udt_id = ABS(@udt_id) AND is_identity = 1

			IF NOT EXISTS (SELECT 1 FROM alert_table_definition WHERE physical_table_name = @table_name)
			BEGIN
				INSERT INTO alert_table_definition (logical_table_name, physical_table_name, data_source_id, is_action_view, primary_column)
				SELECT @table_name, @table_name, @new_data_source_id, 'y', @udt_primary_column
			END
		END

		COMMIT

		EXEC spa_ErrorHandler 0,
			'View User Defined Tables',
			'spa_user_defined_tables',
			'Success',
			'Changes has been successfully saved.',
				''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
		SET @err_msg = error_message()
		EXEC spa_ErrorHandler -1,
			'View User Defined Tables',
			'spa_user_defined_tables',
			'Error',
			@err_msg,
			''
	END CATCH
END
ELSE IF @flag = 'l'
BEGIN
	DECLARE @select_column NVARCHAR(MAX)
	SET @select_column = NULL
	SELECT @select_column = COALESCE(@select_column + ' UNION ALL ', '') + '
		SELECT ''' + CAST(udtm.column_name AS NVARCHAR(400)) + ''''
	FROM user_defined_tables_metadata udtm
	INNER JOIN user_defined_tables udt
	ON udt.udt_id = udtm.udt_id
	WHERE udt.udt_id = @udt_id

	IF OBJECT_ID('tempdb..#final_query') IS NOT NULL
				DROP TABLE #final_query
	CREATE TABLE #final_query(row_id INT IDENTITY(1, 1)
							 , line_query NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
							 )
	DELETE FROM #final_query
	INSERT INTO #final_query (line_query)
	SELECT '
	BEGIN TRY
		BEGIN TRAN 
		DECLARE @udt_id_new INT
		DECLARE @sql NVARCHAR(MAX)

		IF NOT EXISTS(SELECT 1 FROM user_defined_tables WHERE udt_hash = ''' + udt.udt_hash + ''')
		BEGIN
			INSERT INTO user_defined_tables(udt_name, udt_descriptions, udt_hash)
			SELECT ''' + udt.udt_name + ''', ''' + udt.udt_descriptions + ''', ''' + udt_hash + '''
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables
			SET udt_name = ''' + udt.udt_name + '''
			  , udt_descriptions = ''' + udt.udt_descriptions + '''
			WHERE udt_hash = ''' + udt.udt_hash + '''
		END

		SELECT @udt_id_new = udt_id FROM user_defined_tables WHERE udt_name = ''' + udt.udt_name + '''
		'
	FROM user_defined_tables udt
	WHERE udt.udt_id = @udt_id

	------ Columm delete script -----
	INSERT INTO #final_query (line_query)
	SELECT '
		IF OBJECT_ID(''tempdb..#collect_all_column'') IS NOT NULL
			DROP TABLE #collect_all_column
		CREATE TABLE #collect_all_column(
			id INT IDENTITY(1, 1),
			column_name NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
		)

		INSERT INTO #collect_all_column
		' + @select_column + '
	
		DELETE udtm FROM user_defined_tables_metadata udtm 
		LEFT JOIN user_defined_tables udt
			ON udt.udt_id = udtm.udt_id
		LEFT JOIN #collect_all_column a
			ON udtm.column_name = a.column_name 
		WHERE udt.udt_id = @udt_id_new AND a.id IS NULL'

	INSERT INTO #final_query (line_query)
	SELECT '
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = ''' + udtm.udt_column_hash + ''' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						''' +  udtm.column_name+ ''', '''
						+  udtm.column_descriptions + ''', '''
						+  udtm.column_type + ''', '
						+  ISNULL(CAST(udtm.column_length AS NVARCHAR(10)),'NULL') + ', '
						+  ISNULL(CAST(udtm.column_prec AS NVARCHAR(10)),'NULL') + ', '
						+  ISNULL(CAST(udtm.column_scale AS NVARCHAR(10)),'NULL') + ', '''
						+  udtm.column_nullable + ''', '
						+  ISNULL(CAST(udtm.is_primary  AS NVARCHAR(10)),'NULL') + ','
						+  ISNULL(CAST(udtm.is_identity  AS NVARCHAR(10)),'NULL') + ','
						+  ISNULL(CAST(udtm.static_data_type_id AS NVARCHAR(10)),'NULL') + ', '
						+  ISNULL(CAST(udtm.has_value AS NVARCHAR(10)),'NULL') + ', '
						+  ISNULL(CAST(udtm.use_as_filter AS NVARCHAR(10)),'NULL')  + ', '
						+  ISNULL(CAST(udtm.sequence_no AS NVARCHAR(10)),'NULL') + ', '
						+  ISNULL(CAST(udtm.rounding AS NVARCHAR(10)),'NULL') + ', '
						+  ISNULL(CAST(udtm.unique_combination AS NVARCHAR(10)),'NULL') + ', '
						+  ISNULL(CAST(udtm.custom_validation AS NVARCHAR(10)),'NULL') + ', '''
						+  ISNULL(udtm.udt_column_hash,'NULL') + '''
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = ''' + ISNULL(NULLIF(udtm.column_name,''),'NULL') + '''
				,column_descriptions  = ''' + ISNULL(NULLIF(udtm.column_descriptions,''),'NULL') + '''
				,column_type  = ''' + ISNULL(NULLIF(udtm.column_type,''),'NULL') + '''
				,column_length  = ' + ISNULL(CAST(udtm.column_length AS NVARCHAR(10)),'NULL') + '
				,column_prec  = ' + ISNULL(CAST(udtm.column_prec AS NVARCHAR(10)),'NULL') + '
				,column_scale  = ' + ISNULL(CAST(udtm.column_scale AS NVARCHAR(10)),'NULL') + '
				,column_nullable  = ''' + ISNULL(NULLIF(udtm.column_nullable,''),'NULL') + '''
				,is_primary  = ' + ISNULL(CAST(udtm.is_primary AS NVARCHAR(10)),'NULL') + '
				,is_identity  = ' + ISNULL(CAST(udtm.is_identity AS NVARCHAR(10)),'NULL')+ '
				,static_data_type_id  = ' + ISNULL(CAST(udtm.static_data_type_id AS NVARCHAR(10)),'NULL') + '
				,has_value  = ' + ISNULL(CAST(udtm.has_value AS NVARCHAR(10)),'NULL') + '
				,use_as_filter  = ' + ISNULL(CAST(udtm.use_as_filter AS NVARCHAR(10)),'NULL') + '
				,sequence_no  = ' + ISNULL(CAST(udtm.sequence_no AS NVARCHAR(10)),'NULL') + '
				,rounding  = ' + ISNULL(CAST(udtm.rounding AS NVARCHAR(10)),'NULL') + '
				,unique_combination  = ' + ISNULL(CAST(udtm.unique_combination AS NVARCHAR(10)),'NULL') + '
				,custom_validation  = ' + ISNULL(CAST(udtm.custom_validation AS NVARCHAR(10)),'NULL') + '
			WHERE udt_column_hash = '''+ udtm.udt_column_hash +'''
		END
	'
	FROM user_defined_tables_metadata udtm
	INNER JOIN user_defined_tables udt
		ON udt.udt_id = udtm.udt_id
	WHERE udtm.udt_id = @udt_id

	-- Delete unused columns info from destination
	INSERT INTO #final_query (line_query)
	SELECT '
		DELETE FROM user_defined_tables_metadata
		WHERE udt_column_hash NOT IN (' + STUFF ((SELECT ',''' + udtm.udt_column_hash + ''''
												  FROM user_defined_tables_metadata udtm
												  WHERE udtm.udt_id = @udt_id
												  FOR XML PATH ('')), 1, 1, '') + ')
			AND udt_id = @udt_id_new
	'

	INSERT INTO #final_query (line_query)
	SELECT '
		EXEC spa_ErrorHandler 0,
			''User defined table import'',
			''User defined table import'',
			''Success'',
			''Data has been imported successfully.'',
			''''
		COMMIT TRAN 
	END TRY 
	BEGIN CATCH
		EXEC spa_ErrorHandler 1,
				''User defined table import'',
				''User defined table import'',
				''DB Error'',
				''Fail to import data'',
				''''
		ROLLBACK TRAN
	END CATCH 
	'

	
	SELECT 
	   @sql_string = STUFF( (SELECT ' ' + line_query 
								 FROM #final_query
								 ORDER BY row_id
								 FOR XML PATH(''), type
							).value('.', 'NVARCHAR(MAX)')
							,1, 1, '')
	
	SET @output = @sql_string
END

IF @flag = 'r'
BEGIN
	DECLARE @count INT = NULL
	DECLARE @i INT = 0
	DECLARE @del_id INT
	DECLARE @error_msg NVARCHAR(MAX)
	DECLARE @data_check_sql NVARCHAR(MAX)

	 -- Count number of udf tables to delete.
	SELECT @count = COUNT(1) FROM dbo.FNASplit(@udt_id, ',')

	IF OBJECT_ID('tempdb..#del_tables') IS NOT NULL DROP TABLE #del_tables
	IF OBJECT_ID('tempdb..#data_available') IS NOT NULL DROP TABLE #data_available
	
	-- Insert deleting ids in a temp table with generated ID.
	SELECT ROW_NUMBER() OVER (ORDER BY item ASC) [id], item
	INTO #del_tables
	FROM dbo.FNASplit(@udt_id, ',')

	CREATE TABLE #data_available (table_name NVARCHAR(1000) COLLATE DATABASE_DEFAULT, has_data NCHAR(1) COLLATE DATABASE_DEFAULT)

	SET @sql = ''
	SET @data_check_sql = ''
	
	WHILE @i < @count
	BEGIN
		SELECT @del_id = item FROM #del_tables WHERE id = @count

		SELECT @table_name = 'udt_' + udt_name FROM user_defined_tables WHERE udt_id = @del_id

		-- SQL to check if the udf table has data in it.
		SET @data_check_sql = CONCAT(@data_check_sql, '
			IF OBJECT_ID(N''[dbo].['+ @table_name + ']'') IS NOT NULL
			BEGIN
				IF EXISTS(SELECT 1 FROM [dbo].['+ @table_name + '])
				BEGIN
					INSERT INTO #data_available
					SELECT ''' + @table_name + ''', ''y''
				END
			END
		')

		-- SQL to delete tables and data in udf table.
		SET @sql = CONCAT(@sql, '
			IF OBJECT_ID(N''[dbo].['+ @table_name + ']'') IS NOT NULL
			BEGIN
				DROP TABLE [dbo].[' + @table_name + ']
			END

			DELETE udtm
			FROM user_defined_tables_metadata udtm
			INNER JOIN user_defined_tables udm ON udm.udt_id = udtm.udt_id
			WHERE udm.udt_id = ' + CAST(@del_id AS NVARCHAR(100)) + '

			DELETE udm
			FROM user_defined_tables udm
			WHERE udm.udt_id = ' + CAST(@del_id AS NVARCHAR(100)) + '
		')

		SET @count = @count - 1;
	END
	
	-- First, check if udf table has data.
	EXEC (@data_check_sql)

	-- If UDF has data then give user message to delete the data first.
	IF EXISTS (SELECT 1 FROM #data_available WHERE has_data = 'y')
	BEGIN
		DECLARE @data_in NVARCHAR(1000)

		SELECT @data_in = STUFF((
			SELECT ', ' + table_name
			FROM #data_available
			WHERE has_data = 'y'
			FOR XML PATH('')), 1, 1, '')
		FROM #data_available
		GROUP BY table_name

		DECLARE @errmsg NVARCHAR(MAX) = 'Data available in the tables (<b>' + @data_in + '</b>). Please delete data in these table before deleting.'

		EXEC spa_ErrorHandler -1,
			'View User Defined Tables',
			'spa_user_defined_tables',
			'Error',
			@errmsg,
			''

		RETURN
	END

	BEGIN TRY
		BEGIN TRAN
			EXEC(@sql)
		COMMIT TRAN

		EXEC spa_ErrorHandler 0,
			'View User Defined Tables',
			'spa_user_defined_tables',
			'Success',
			'Changes has been successfully saved.',
			''
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN

		SET @error_msg = ERROR_MESSAGE()

		EXEC spa_ErrorHandler -1,
			'View User Defined Tables',
			'spa_user_defined_tables',
			'Error',
			@error_msg,
			''
	END CATCH
END
ELSE IF @flag = 'x'
BEGIN
	IF @udt_id IS NOT NULL
	BEGIN
		SELECT udt.udt_id
			 , udt.udt_name
			 , udt.udt_descriptions 
		FROM user_defined_tables udt
		LEFT JOIN user_defined_tables_metadata udtm ON udtm.udt_id = udt.udt_id
		WHERE udt.udt_id = @udt_id
		GROUP BY udt.udt_id, udt.udt_name, udt.udt_descriptions
	END
	ELSE IF @system IS NOT NULL
	BEGIN
		SELECT udt.udt_id
			 , udt.udt_name
			 , udt.udt_descriptions
		FROM user_defined_tables udt
		LEFT JOIN user_defined_tables_metadata udtm ON udtm.udt_id = udt.udt_id
		WHERE IIF(is_system = 1, 1, 0) = @system
		GROUP BY udt.udt_id, udt.udt_name, udt.udt_descriptions
	END
	ELSE
	BEGIN
		SELECT udt.udt_id
			 , udt.udt_name
			 , udt.udt_descriptions 
		FROM user_defined_tables udt
		LEFT JOIN user_defined_tables_metadata udtm ON udtm.udt_id = udt.udt_id
		GROUP BY udt.udt_id, udt.udt_name, udt.udt_descriptions
	END
END

ELSE IF @flag = 'w'
BEGIN
	
	SET @udt_id = @udt_id * -1
	IF EXISTS (
		SELECT 1 FROM workflow_module_event_mapping WHERE module_id = @udt_id
		UNION
		SELECT 1 FROM module_events WHERE modules_id = @udt_id
	)
	BEGIN
		DECLARE @process_id NVARCHAR(100) = dbo.FNAGetNewID()
		DECLARE @workflow_primary_column NVARCHAR(100)

		IF @workflow_process_table IS NULL
		BEGIN
			SET @workflow_process_table = dbo.FNAProcessTableName('UDT_workflow_' + CAST(ABS(@udt_id) AS VARCHAR), @user_login_id, @process_id)
			SELECT @workflow_primary_column = column_name FROM user_defined_tables_metadata WHERE udt_id = ABS(@udt_id) AND is_identity = 1
			
			SET @sql = 'CREATE TABLE ' + @workflow_process_table + '
				(
					' + ISNULL(@workflow_primary_column, 'source_id') + ' INT
				)
				INSERT INTO ' + @workflow_process_table + ' (' + ISNULL(@workflow_primary_column, 'source_id') + ')
				SELECT ids.item FROM dbo.SplitCommaSeperatedValues(''' + @workflow_source_ids + ''') ids
			'
			EXEC(@sql)
		END
		EXEC spa_register_event @udt_id, 10000331, @workflow_process_table, 1, @process_id	
	END
	
	--SELECT @udt_id, 10000331, @workflow_process_table, 1, @process_id			
END