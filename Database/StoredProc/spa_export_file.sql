IF OBJECT_ID(N'dbo.[spa_export_file]', N'P') IS NOT NULL
    DROP PROC dbo.[spa_export_file]
GO

CREATE PROC dbo.[spa_export_file]
	@data_table_name	VARCHAR(500) = NULL,
	@file_path			VARCHAR(1000),
	@file_name			VARCHAR(500) = NULL,
	@has_header			VARCHAR(5) = 'True',  -- 'True' or 'False' or '1' or '0'
	@seperator			VARCHAR(10) = ',',
	@process_id			VARCHAR(50) = NULL,
	@user_login_id		VARCHAR(50) = 'farrms_admin',
	@description		VARCHAR(3000) = NULL,
	@system_id			VARCHAR(10) = '2'
AS

	SET @process_id = ISNULL(@process_id, REPLACE(NEWID(), '-', '_') )
	DECLARE @as_of_date DATETIME = GETDATE(), 
			@proc_desc  VARCHAR(50) = 'export_data',
			@job_name   VARCHAR(256),
			@root		VARCHAR(1000),
			@ssis_path  VARCHAR(2000),
			@spa		VARCHAR(MAX),
			@package_source TINYINT = 2,  -- 1:filesystem, 2:msdb
			@database VARCHAR(128) = DB_NAME(),
			@package_name VARCHAR(128) = 'batch_process_export',
			@col_list VARCHAR(MAX),
			@sql VARCHAR(MAX)
	
	SET @job_name = @proc_desc + '_' + @process_id
	-- noSpace and vbTab is used in vb script to recognize seperator i.e empty space and tab
	IF NULLIF(@seperator, '') IS NULL
		SET @seperator = 'noSpace'   
	ELSE IF @seperator = '\t'
		SET @seperator = 'vbTab'

	-- remove trailing slashes if any.
	WHILE RIGHT(@file_path,1) = '\'
	BEGIN
		SELECT @file_path = LEFT(@file_path, LEN(@file_path)-1)
	END
	
	
	    --generate a list of table data columns, also escape HTML tags and wrap under quotation (") to escape comma (,) in data.
    SELECT @col_list = COALESCE('' + @col_list + ',', '') + ''''' + ' 
           + (
               CASE 
                    WHEN DATA_TYPE IN ('varchar', 'nvarchar', 'char', 'nchar') THEN 
                         DB_NAME() + '.dbo.FNAStripHTML(ISNULL(CAST(' + QUOTENAME(COLUMN_NAME) 
                         + ' AS VARCHAR(MAX)), ''''))'
                    WHEN DATA_TYPE IN ('float', 'real', 'money') THEN DB_NAME() + '.dbo.FNAStripHTML(ISNULL(LTRIM(STR(' + QUOTENAME(COLUMN_NAME) 
                         + ', 22, 8)), ''''))'
                    WHEN DATA_TYPE = 'datetime' THEN 'CONVERT(VARCHAR(19), ' + QUOTENAME(COLUMN_NAME) + ' ,120)'
                    ELSE 'CAST(' + QUOTENAME(COLUMN_NAME) + ' AS VARCHAR(MAX))'
               END
           ) + ' + '''' AS ' + QUOTENAME(COLUMN_NAME)
    FROM   adiha_process.INFORMATION_SCHEMA.[COLUMNS] c
    WHERE  'adiha_process.dbo.' + TABLE_NAME = @data_table_name
           AND c.COLUMN_NAME <> 'ROWID'
    ORDER BY
           ORDINAL_POSITION

    SET @sql = 'SELECT ' + ISNULL(@col_list, '*') + ' FROM ' + @data_table_name
	--EXEC(@sql)
	--IF  NOT EXISTS(SELECT 1 FROM import_data_files_audit WHERE process_id = @process_id)
	--BEGIN
	--	EXEC spa_import_data_files_audit 'i', @as_of_date, NULL, @process_id, 'Export Batch Data', 'batch_data', @as_of_date, 'p' ,NULL, @as_of_date, NULL, @system_id
	--END
	/*
	* Package can take a table name or custom Query.
	* But package will look for custom query by default since package has a variable PS_FromTable whose value is false by default
	* PS_FromTable as true can be passed as param if input is a table and in that case PS_TableName should be passed instead of PS_SQLCustom
	*/
	IF @package_source = 1 -- Uses filesystem source for package execution
	BEGIN
		SELECT @root = dbo.FNAGetSSISPkgFullPath('PRJ_batchProcessExport', 'User::PS_PackageSubDir')
        SET @ssis_path = @root + @package_name + '.dtsx'

		SET @spa = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id +
		 '" /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '" /SET "\Package.Variables[User::PS_SQLCustom].Properties[Value]";"' + @sql + 
		 '" /SET "\Package.Variables[User::PS_OutputFolder].Properties[Value]";"' + @file_path + '" /SET "\Package.Variables[User::PS_FileName].Properties[Value]";"' + @file_name + 
		 '" /SET "\Package.Variables[User::PS_HasHeader].Properties[Value]";"' + @has_header + '" /SET "\Package.Variables[User::PS_TextDelimiter].Properties[Value]";"\"' + @seperator + 
		 '"\" /SET "\Package.Variables[User::PS_UserName].Properties[Value]";"' + @user_login_id + 
		 '"'
	END
	
	IF @package_source = 2 -- Uses direct package execution via msdb
	BEGIN
		SET @package_name = '\' + @database + '\' + @package_name

		SET @spa = N'/SQL "' + @package_name + '" /SERVER "' + @@SERVERNAME + '" /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '" /SET "\Package.Variables[User::PS_SQLCustom].Properties[Value]";"' + @sql + 
		 '" /SET "\Package.Variables[User::PS_OutputFolder].Properties[Value]";"' + @file_path + '" /SET "\Package.Variables[User::PS_FileName].Properties[Value]";"' + @file_name + 
		 '" /SET "\Package.Variables[User::PS_HasHeader].Properties[Value]";"' + @has_header + '" /SET "\Package.Variables[User::PS_TextDelimiter].Properties[Value]";"\"' + @seperator + 
		 '"\" /SET "\Package.Variables[User::PS_UserName].Properties[Value]";"' + @user_login_id + 
		 '"'
		
	END
	
	--EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'SSIS_RWE_DE_Export', @user_login_id, 'SSIS', @system_id, 'y'	

	DECLARE @spa_success VARCHAR(1000) = 'EXEC ' + @database + '.dbo.spa_message_board ''i'', ''' + @user_login_id + ''', NULL, ''' + 'SSIS_RWE_DE_Export'  + ''', ''' + @description + ''', '''', '''', ''s'', NULL'
					 
	EXEC [spa_create_job] @job_name, @spa , @spa_success, NULL, 'SSIS_RWE_DE_Export', @user_login_id,'SSIS'

GO