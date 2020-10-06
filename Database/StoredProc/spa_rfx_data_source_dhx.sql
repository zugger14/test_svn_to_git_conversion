IF OBJECT_ID(N'[dbo].[spa_rfx_data_source_dhx]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_data_source_dhx]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Add/Update Operations for Report Result set. IMPORTANT NOTE: THIS STORED PROCEDURE MUST NOT CONTAIN print () statement as this SP is called by SQLSRV library (in the application) which creates issues when it encounters print().

	Parameters
	@flag				:	Operation Flag.
	@report_id			:	ID of Report.
	@name				:	Name of Report Data Source.
	@sql_query			:	SQL Query to be verified for the Data Source.
	@type_id			:	Type of Data Source (View/SQL).
	@alias				:	Alias used for Data Source.
	@source_id			:	ID of Data Source.
	@description		:	Description of Data Source.
	@criteria			:	
	@tsql_column_xml	:	List of SQL Columns.
	@category			:	Category of Data Source.
	@system_defined		:	Is System Defined or Not i.e. Protected or Not.
	@wf_primary_table	:	User Defined Table.
	@wf_primary_column	:	User Defined Column.
	@is_action_view		:	Is Action View or not.
	@wf_workflow_module	:	Workflow Module.
*/

CREATE PROCEDURE [dbo].[spa_rfx_data_source_dhx]
	@flag				CHAR(1),
	@report_id			INT = NULL,
	@name				VARCHAR(100)= NULL,
	@sql_query			VARCHAR(MAX) = NULL,
	@type_id			INT = NULL,
	@alias				VARCHAR(100) = NULL,
	@source_id			VARCHAR(1000) = NULL,
	@description		VARCHAR(1000) = NULL,
	@criteria			VARCHAR(5000) = NULL,
	@tsql_column_xml	VARCHAR(MAX) = NULL,
	@category			INT = NULL,
	@system_defined     INT = NULL,
	@wf_primary_table	VARCHAR(100) = NULL,
	@wf_primary_column	VARCHAR(100) = NULL,
	@is_action_view		CHAR(1) = NULL,
	@wf_workflow_module INT = NULL
AS
/*
DECLARE @flag			CHAR(1),
	@report_id			INT = NULL,
	@name				VARCHAR(100)= NULL,
	@sql_query			VARCHAR(MAX) = NULL,
	@type_id			INT = NULL,
	@alias				VARCHAR(100) = NULL,
	@source_id			VARCHAR(1000) = NULL,
	@description		VARCHAR(1000) = NULL,
	@criteria			VARCHAR(5000) = NULL,
	@tsql_column_xml	VARCHAR(MAX) = NULL,
	@category			INT = NULL,
	@system_defined     INT = NULL,
	@wf_primary_table	VARCHAR(100) = NULL,
	@wf_primary_column	VARCHAR(100) = NULL,
	@is_action_view		CHAR(1) = NULL,
	@wf_workflow_module INT = NULL

SELECT @flag='z'
--*/
SET NOCOUNT ON

DECLARE @sql			NVARCHAR(MAX)  
DECLARE @user_name		VARCHAR(50) = dbo.FNADBUser() 


declare @admin_user tinyint = dbo.FNAIsUserOnAdminGroup(@user_name, 1)

IF OBJECT_ID('tempdb..#privileged_data_source') IS NOT NULL 
	DROP TABLE #privileged_data_source
create table #privileged_data_source (
	[data_source_id] int
	,[type_id] int
	,[name] varchar(500) 
	,[alias] varchar(200)
	,[description] varchar(500)
	,[report_id] int
	,[category] int
	,[system_defined] int
)

IF @admin_user = 1 --if user belongs to Application Admin Group or Reporting Admin Group or AppAdminID (normally farrms_admin)
BEGIN
	INSERT INTO #privileged_data_source
	SELECT 
		ds.[data_source_id]
		,ds.[type_id]
		,ds.[name]
		,ds.[alias]
		,ds.[description]
		,ds.[report_id]
		,ds.[category]
		,ds.[system_defined]
	FROM data_source ds
END
ELSE -- if user or its role has given view level privileges
BEGIN
	INSERT INTO #privileged_data_source
	SELECT 
		ds.[data_source_id]
		,ds.[type_id]
		,ds.[name]
		,ds.[alias]
		,ds.[description]
		,ds.[report_id]
		,ds.[category]
		,ds.[system_defined]
	FROM data_source ds
	WHERE EXISTS(
		SELECT TOP 1 1 FROM report_manager_view_users rmvu 
		WHERE rmvu.data_source_id = ds.data_source_id
			AND (rmvu.login_id = @user_name OR rmvu.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(@user_name)))
	)

END

--Resolve Process Table Name
IF @flag = 's'
BEGIN
    SELECT ds.[type_id],
           ds.[data_source_id],
           	CASE WHEN CHARINDEX('[adiha_process].[dbo].[batch_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[batch_export_') 
				 WHEN CHARINDEX('[adiha_process].[dbo].[report_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[report_export_')
				ELSE ds.[name]
			END AS [Name],
          -- ds.[name],
           ds.[alias],
           ds.[description],
           ds.[tsql],
           ds.[report_id]
    FROM   data_source ds
    WHERE (CASE WHEN ds.[type_id] = 2 THEN ds.report_id ELSE @report_id END)  = @report_id 
END
ELSE IF @flag = 'z' -- called from report manager main page for left grid load of datasources
BEGIN
	SELECT DISTINCT
		'a_1' [root_id], 'Datasources' [root_name]
		, 'b_' + cast(ds.type_id AS CHAR(1)) [ds_type_id], CASE ds.type_id WHEN 1 THEN 'View' ELSE 'Other' END [ds_type_name]
		, 'c_' + cast(ds.data_source_id AS VARCHAR(5)) [ds_id], ds.name [ds_name]
		, ds.system_defined [system_defined]	
	FROM #privileged_data_source ds
	WHERE ds.type_id = 1 --view type datasource
		AND ds.category = '106500'
	UNION ALL
	SELECT 
	'a_2' , 'Report Items'
	
	, 'report-item-' + cast(s.n AS CHAR(1)), CASE s.n WHEN 1 THEN 'Chart' WHEN 2 THEN 'Tablix' WHEN 3 THEN 'Text' WHEN 4 THEN 'Image' WHEN 5 THEN 'Gauge' ELSE 'Line' END,NULL,NULL, 0 [system_defined]	
	
	FROM seq s WHERE s.n IN (1,2,3)
	ORDER BY root_id, ds_type_name, ds_name
END

IF @flag = 'i'
BEGIN
	
	CREATE TABLE #temp_errorhandler_result 
	(
		ErrorCode       VARCHAR(50) COLLATE DATABASE_DEFAULT ,
    		Module          VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		Area            VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		[Status]        VARCHAR(100) COLLATE DATABASE_DEFAULT ,
    		[Message]       VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		Recommendation  VARCHAR(500) COLLATE DATABASE_DEFAULT 
	)
	
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM data_source WHERE [name] = @name )
		BEGIN
			BEGIN TRAN
			CREATE TABLE #temp_exist ([alias] TINYINT)
			SET @sql =  'INSERT INTO #temp_exist ([alias]) SELECT TOP(1) 1 FROM data_source WHERE alias = ''' + @alias + ''''
			EXEC(@sql)
			
			IF EXISTS (SELECT 1 FROM #temp_exist)
			BEGIN
				EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_paramset', 'DB Error', 'Alias already exists.', ''
				RETURN
			END

			DECLARE @data_source_id INT
			DECLARE @Params NVARCHAR(500);
			SET @Params = N'@data_source_id INT OUTPUT';
			
			SET @sql = 'INSERT INTO data_source([type_id],[name],report_id,alias,[tsql],[description],[category],[system_defined])
						SELECT	' + CAST (@type_id AS VARCHAR(20)) + '
								,''' + @name + '''
								,' + ISNULL(CAST(@report_id AS VARCHAR(20)), 'NULL') + '
								,''' + ISNULL(@alias, '') + '''
								,''' + ISNULL(REPLACE(@sql_query, '''', ''''''), '') + '''
								,''' + ISNULL(@description, '') + ''' 
								,''' + CAST(@category AS VARCHAR(20)) + '''
								,''' + CAST(@system_defined AS CHAR(1)) + '''
								
						SET @data_source_id = SCOPE_IDENTITY() '

			EXECUTE sp_executesql @sql, @Params, @data_source_id = @data_source_id OUTPUT;

			CREATE TABLE #sql_columns_message_i
			(
				ErrorCode       VARCHAR(50) COLLATE DATABASE_DEFAULT ,
					Module          VARCHAR(100) COLLATE DATABASE_DEFAULT ,
				Area            VARCHAR(100) COLLATE DATABASE_DEFAULT ,
				[Status]        VARCHAR(100) COLLATE DATABASE_DEFAULT ,
					[Message]       VARCHAR(500) COLLATE DATABASE_DEFAULT ,
				Recommendation  VARCHAR(500) COLLATE DATABASE_DEFAULT 
			)
				
			IF @tsql_column_xml IS NOT NULL
			BEGIN
				INSERT INTO #sql_columns_message_i
				EXEC spa_rfx_save_data_source_column 'u', NULL, @data_source_id, @tsql_column_xml	
			END			
				
			DECLARE @state_check_i VARCHAR(200)
			SELECT @state_check_i = ErrorCode FROM #sql_columns_message_i
			IF @state_check_i = 'Error'
			BEGIN
				DECLARE @col_error_msg_i VARCHAR(8000)
				SELECT @col_error_msg_i = [Message] FROM #sql_columns_message_i
				RAISERROR (@col_error_msg_i, 16, 1 )
			END 
			
			IF (@category IN(106502, 106503) AND @wf_workflow_module IS NOT NULL)
			BEGIN
				IF NOT EXISTS(SELECT 1 FROM alert_table_definition WHERE logical_table_name = @name AND @category IN(106502, 106503))
				BEGIN 
					INSERT INTO alert_table_definition (
							logical_table_name
						, physical_table_name
						, data_source_id
						, is_action_view
						, primary_column
						)
					SELECT
						CASE WHEN @category IN(106502, 106503)  THEN @name ELSE NULL END 
						, CASE WHEN @category = 106502  THEN @wf_primary_table 
							   WHEN @category = 106503 	THEN @name
								ELSE NULL END 
						, @data_source_id
						, @is_action_view
						, CASE WHEN @category IN(106502, 106503) THEN NULLIF(@wf_primary_column,'NULL') ELSE NULL END 

					DECLARE @alert_table_definition_id INT
					SET @alert_table_definition_id = SCOPE_IDENTITY()
					INSERT INTO workflow_module_rule_table_mapping (
							module_id
						, rule_table_id
						, is_active
						)
					SELECT 
						  @wf_workflow_module
						, @alert_table_definition_id
						, 1
				END
				ELSE 
				BEGIN
					UPDATE atd
					SET atd.physical_table_name = CASE WHEN @category = 106502  THEN @wf_primary_table 
							   WHEN @category = 106503 	THEN @name
								ELSE NULL END
						, atd.is_action_view = CASE 
							WHEN @category IN(106502, 106503)
								THEN @is_action_view
							ELSE atd.is_action_view 
							END
						, atd.data_source_id = @data_source_id
						, atd.primary_column = CASE 
							WHEN @category IN(106502, 106503)
								THEN @wf_primary_column
							ELSE NULL
							END
					FROM alert_table_definition atd
					WHERE atd.logical_table_name = @name

					UPDATE wmrtm
					SET wmrtm.module_id = ISNULL(@wf_workflow_module, wmrtm.module_id)
						, wmrtm.rule_table_id = ISNULL(@alert_table_definition_id, wmrtm.rule_table_id)
						, wmrtm.is_active = 1
					FROM workflow_module_rule_table_mapping wmrtm
					INNER JOIN alert_table_definition atd
						ON wmrtm.rule_table_id = atd.alert_table_definition_id
					WHERE atd.logical_table_name = @name
				END
			END
				
			EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_data_source_dhx', 'Success', 'Datasource successfully inserted.', @data_source_id
			COMMIT
		END
		ELSE
			EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_data_source_dhx', 'DB Error', 'Name already exists.', ''
	END TRY	
	BEGIN CATCH
		ROLLBACK TRAN
		EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_data_source_dhx', 'DB Error', 'Fail to insert datasource.', @source_id
	END CATCH
END

IF @flag = 'u'
BEGIN
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM data_source WHERE [name] = @name AND data_source_id <> @source_id AND [type_id] IN (1, 3))
		BEGIN
			BEGIN TRAN
			CREATE TABLE #temp_exist_u ([alias] TINYINT)
			SET @sql =  'INSERT INTO #temp_exist_u ([alias]) 
							SELECT TOP(1) 1 FROM data_source 
							WHERE alias = ''' + @alias + ''' AND data_source_id <> '+ CAST(@source_id AS VARCHAR) + '
							AND [type_id] IN (1, 3)'
							
			EXEC(@sql)
			
			IF EXISTS (SELECT 1 FROM #temp_exist_u)
			BEGIN
				EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_paramset', 'DB Error', 'Alias already exists.', ''
				RETURN
			END
		
			SET @sql = 'UPDATE data_source
						SET [type_id] = ' + CAST (@type_id AS VARCHAR(20)) + '
							, [name] = ''' + @name + '''
							, alias = ''' + ISNULL(@alias, '') + '''
							, [description] = ''' + ISNULL(@description, '')  + '''
							, [tsql] = ''' + ISNULL(REPLACE(@sql_query, '''', ''''''), '') + '''
							, report_id = ' + ISNULL(CAST(@report_id AS VARCHAR(20)), 'NULL') + '
							, [category] = ''' + CAST(@category AS VARCHAR(20)) + '''
							, [system_defined] = ''' + CAST(@system_defined AS CHAR(1)) + '''
						WHERE data_source_id = ' + CAST (@source_id AS VARCHAR(20))
			EXEC (@sql)

			IF @category IN(106502, 106503) AND @wf_workflow_module IS NOT NULL
			BEGIN 

				UPDATE atd
				SET atd.logical_table_name = CASE 
						WHEN @category IN(106502, 106503)
							THEN @name
						ELSE atd.logical_table_name
						END
					, atd.physical_table_name = CASE WHEN @category = 106502  THEN @wf_primary_table 
							   WHEN @category = 106503 	THEN @name
								ELSE atd.physical_table_name END
					, atd.primary_column = CASE 
						WHEN @category IN(106502, 106503)
							THEN NULLIF(@wf_primary_column,'NULL')
						ELSE NULLIF(atd.primary_column,'NULL')
						END
					, atd.is_action_view = CASE 
						WHEN @category IN(106502, 106503)
							THEN @is_action_view
						ELSE atd.is_action_view
						END 
					, atd.data_source_id = CASE 
					WHEN @category IN(106502, 106503)
						THEN @source_id
					ELSE atd.data_source_id
					END 
				FROM data_source ds
				LEFT JOIN alert_table_definition atd
					ON atd.logical_table_name = ds.name OR atd.data_source_id = ds.data_source_id
				WHERE ds.data_source_id = @source_id OR atd.logical_table_name  = @name
				 
				IF NOT EXISTS (SELECT 1	FROM workflow_module_rule_table_mapping wmrtm INNER JOIN alert_table_definition atd ON wmrtm.rule_table_id = atd.alert_table_definition_id WHERE atd.logical_table_name = @name )
				BEGIN
					SELECT @alert_table_definition_id = alert_table_definition_id
					FROM alert_table_definition
					WHERE logical_table_name = @name

					INSERT INTO workflow_module_rule_table_mapping (
						module_id
						, rule_table_id
						, is_active
						)
					SELECT @wf_workflow_module
						, @alert_table_definition_id
						, 1
				END
				ELSE
				BEGIN
					UPDATE wmrtm
					SET wmrtm.module_id = ISNULL(@wf_workflow_module, wmrtm.module_id)
					FROM workflow_module_rule_table_mapping wmrtm
					INNER JOIN alert_table_definition atd
						ON wmrtm.rule_table_id = atd.alert_table_definition_id
					WHERE atd.data_source_id = @source_id
						OR atd.logical_table_name = @name
				END

			END
			
			CREATE TABLE #sql_columns_message_u
			(
				ErrorCode       VARCHAR(50) COLLATE DATABASE_DEFAULT ,
				Module          VARCHAR(100) COLLATE DATABASE_DEFAULT ,
				Area            VARCHAR(100) COLLATE DATABASE_DEFAULT ,
				[Status]        VARCHAR(100) COLLATE DATABASE_DEFAULT ,
				[Message]       VARCHAR(500) COLLATE DATABASE_DEFAULT ,
				Recommendation  VARCHAR(500) COLLATE DATABASE_DEFAULT 
			)
			
			IF @tsql_column_xml IS NOT NULL
			BEGIN
				INSERT INTO #sql_columns_message_u
				EXEC spa_rfx_save_data_source_column 'u', NULL, @source_id, @tsql_column_xml	
			END			
			
			
			DECLARE @state_check_u VARCHAR(200)
			SELECT @state_check_u = ErrorCode FROM #sql_columns_message_u
			
			IF @state_check_u = 'Error'
			BEGIN
				DECLARE @col_error_msg VARCHAR(8000)
					SELECT @col_error_msg = [Message] FROM #sql_columns_message_u
				RAISERROR (@col_error_msg, 16, 1 )
			END 	
			
			DECLARE @csv_table VARCHAR(500)
					, @value VARCHAR(max)
			 
			SET @csv_table = dbo.FNAProcessTableName('report_source_CSV' , dbo.FNADBUser(), dbo.FNAGetNewID())

			SET @sql = NULL;

			SELECT @sql  = ISNULL( @sql + ',', '')  +  '['+ dc.alias + '.' + dsc.name + '] ' + rd.name + IIF( CHARINDEX('CHAR', rd.name) <> 0, '(100) ', ' ')  
				, @value = ISNULL(@value + ',', '') + 'NULL'
			FROM [dbo].[data_source_column]  dsc
			INNER JOIN report_datatype rd
				ON dsc.datatype_id = rd.report_datatype_id
			INNER JOIN [data_source] dc
				ON dsc.source_id = dc.data_source_id
			WHERE dsc.source_id = @source_id

		

			SET @sql =  'CREATE TABLE ' + @csv_table + ' ( ' +  @sql + ' )'
		
			EXEC(@sql);

			SET @sql = 'INSERT INTO ' + @csv_table + 
						' SELECT ' +  @value			
			EXEC(@sql)

			DECLARE @document_path VARCHAR(MAX)
					, @csv_file_folder VARCHAR(MAX)
					, @csv_file_name VARCHAR(MAX)

			SELECT @csv_file_folder = cs.document_path + '\report_manager_views\'
			FROM connection_string cs

			SELECT  @csv_file_name =  @csv_file_folder + @name + '.csv';
			DECLARE @result VARCHAR(MAX)

			EXEC spa_export_to_csv @table_name=@csv_table, @export_file_name=@csv_file_name, @include_column_headers='y', @delimiter=',', @compress_file='n',@use_date_conversion='y',@strip_html='y',@enclosed_with_quotes='y',@result=@result OUTPUT, @decimal_Separator = '.'

			EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_data_source_dhx', 'Success', 'Datasource successfully updated.', @source_id
			
		COMMIT
		END
		ELSE
		BEGIN
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN
			EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_data_source_dhx', 'DB Error', 'Name already exists.', ''
		END
			
	END TRY	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
			
			DECLARE @error_msg	VARCHAR(1000)
			DECLARE @error_no	VARCHAR(1000)
			
			SELECT @error_msg = ERROR_MESSAGE()
			SET @error_no = ERROR_NUMBER()
	
			EXEC spa_ErrorHandler @error_no, 'Reporting FX', 'spa_rfx_data_source_dhx', 'DB Error', @error_msg, ''	
			--EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_data_source_dhx', 'DB Error', 'Fail to update datasource.', @source_id
	END CATCH
END

IF @flag = 'p' -- called from dataset page, source listing
BEGIN
		--DECLARE @tid INT = 1
		
		SELECT DISTINCT ds.data_source_id
			, CASE WHEN CHARINDEX('[adiha_process].[dbo].[batch_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[batch_export_') 
						WHEN CHARINDEX('[adiha_process].[dbo].[report_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[report_export_')
					ELSE ds.[name]
			  END + ' (' + case ds.type_id when 1 then 'View' when 2 then 'SQL' when 3 then 'Table' else 'View' end + ')' AS [Name]
			, ds.type_id
		FROM #privileged_data_source ds
		WHERE iif(ds.type_id = 2, ds.report_id, isnull(@report_id, -1)) = isnull(@report_id, -1)	
			AND ds.category = '106500'	
		ORDER BY [type_id],[name]		  
END
IF @flag = 'r' -- called from connected datasources page for grid combo load
BEGIN
	if OBJECT_ID('tempdb..#connectable_source') is not null drop table #connectable_source

	CREATE TABLE #connectable_source (
		connectable_source_id INT
	)

	INSERT INTO #connectable_source (connectable_source_id)
	select distinct dsc.source_id [connectable_source_id]
	from data_source_column dsc
	where dsc.name in (
		select dsc1.name
		from data_source_column dsc1
		where dsc1.source_id = @source_id
			and dsc1.key_column = 1
	)
		and dsc.source_id <> @source_id
	union
	select distinct dsc.source_id
	from data_source_column dsc
	where dsc.key_column = 1
		and dsc.name in (
			select dsc1.name
			from data_source_column dsc1
			where dsc1.source_id = @source_id
		)
		and dsc.source_id <> @source_id
		
	SELECT DISTINCT ds.data_source_id
		, CASE WHEN CHARINDEX('[adiha_process].[dbo].[batch_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[batch_export_') 
					WHEN CHARINDEX('[adiha_process].[dbo].[report_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[report_export_')
				ELSE ds.[name]
			END + ' (' + case ds.type_id when 1 then 'View' when 2 then 'SQL' when 3 then 'Table' else 'View' end + ')' AS [Name]
		, ds.type_id
	FROM #privileged_data_source ds
	inner join #connectable_source cs on cs.connectable_source_id= ds.data_source_id
	WHERE iif(ds.type_id = 2, ds.report_id, isnull(@report_id, -1)) = isnull(@report_id, -1)	
		and ds.data_source_id <> @source_id	
		AND ds.category = '106500'
	ORDER BY [type_id],[name]		  
END


IF @flag = 'v' -- called from report add page datasource combo load, dataset page view list combo load
BEGIN
	SELECT DISTINCT 
		ds.data_source_id
		, CASE WHEN CHARINDEX('[adiha_process].[dbo].[batch_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[batch_export_') 
				WHEN CHARINDEX('[adiha_process].[dbo].[report_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[report_export_')
				ELSE ds.[name]
			END AS [Name]
	FROM #privileged_data_source ds
	WHERE [type_id] = 1 --view type datasource
		AND ds.category = '106500'
		  
END
IF @flag = 'q' OR @flag = 't' -- v => View, q => SQL, t => Table
BEGIN
	declare @tid int = (CASE WHEN @flag = 'q' THEN 2 ELSE 3 END)
	SELECT 
		--[type_id],
			 data_source_id, 
			CASE WHEN CHARINDEX('[adiha_process].[dbo].[batch_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[batch_export_') 
				 WHEN CHARINDEX('[adiha_process].[dbo].[report_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[report_export_')
				 ELSE ds.[name]
				END AS [Name]
			--, ds.alias
			--, [description]
			--, [tsql] 
	FROM   data_source ds WHERE [type_id]= @tid	   
END
IF @flag = 'x' --for especially views stored, called from select privileges
BEGIN
	SELECT ds.data_source_id AS [ID], ds.[name] AS [View Name], ds.alias AS [Alias] FROM   data_source ds WHERE  ds.[type_id] = 1
END

IF @flag = 'w'
BEGIN
	SELECT data_source_id [Data Source ID]
			, CASE WHEN [TYPE_ID] = 1 THEN 'View' WHEN [TYPE_ID] = 3 THEN 'Table' END AS [TYPE]
			--To display only the user given table name excluding the '[adiha_process].[dbo].[batch_export_'
			, CASE WHEN CHARINDEX('[adiha_process].[dbo].[batch_export_', [name], 1) > 0 THEN dbo.[FNAGetUserTableName]([name], '[batch_export_') 
				WHEN CHARINDEX('[adiha_process].[dbo].[report_export_', [name], 1) > 0 THEN dbo.[FNAGetUserTableName]([name], '[report_export_')
					ELSE [name] 
				END AS [Name]
			, ALIAS AS [ALIAS]
			, [description] AS [Description]
	FROM data_source WHERE [TYPE_ID] <> 2
END

IF @flag = 'd'
BEGIN
	IF NOT EXISTS (
		SELECT 1
		FROM report_dataset rd
		INNER JOIN dbo.FNASplit(@source_id, ',') di ON di.item = rd.source_id
	)
	BEGIN
		BEGIN TRY
			BEGIN TRAN
				DELETE dsc
				FROM data_source_column dsc
				INNER JOIN dbo.FNASplit(@source_id, ',') di ON di.item = dsc.source_id

				DELETE rmvu
				FROM report_manager_view_users rmvu
				INNER JOIN dbo.FNASplit(@source_id, ',') di ON di.item = rmvu.data_source_id

				DELETE ds
				FROM [data_source] ds
				INNER JOIN dbo.FNASplit(@source_id, ',') di ON di.item = ds.data_source_id

				DELETE wmrtm
				FROM workflow_module_rule_table_mapping wmrtm
				INNER JOIN alert_table_definition atd ON wmrtm.rule_table_id = atd.alert_table_definition_id
				INNER JOIN dbo.FNASplit(@source_id, ',') di ON di.item = atd.data_source_id

				DELETE atd
				FROM alert_table_definition atd
				INNER JOIN dbo.FNASplit(@source_id, ',') di ON di.item = atd.data_source_id
			COMMIT
			EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_data_source_dhx', 'Success', 'Datasource successfully deleted.', @source_id
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN
			EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_data_source_dhx', 'DB Error', 'Fail to delete datasource.', ''
		END CATCH	
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_data_source_dhx', 'DB Error', 'Datasource being used can not be deleted.', @source_id
	END
END

IF @flag = 'a'
BEGIN
	SELECT ds.data_source_id,
	       ds.[type_id],
	       ds.[name],
	       ds.alias,
	       ds.[description],
	       ds.[tsql],
	       ds.report_id,
		   ds.category,
		   ds.system_defined,
		   atd.physical_table_name,
		   atd.primary_column,
		   atd.is_action_view,
		   wmrtm.module_id
	FROM   data_source ds
    LEFT JOIN alert_table_definition atd ON atd.data_source_id = ds.data_source_id
	LEFT JOIN workflow_module_rule_table_mapping wmrtm  ON wmrtm.rule_table_id = atd.alert_table_definition_id 
	WHERE  ds.data_source_id = @source_id 
END
	
IF @flag = 'y' --for especially views stored, called from pivot template
BEGIN
	SELECT ds.data_source_id AS [ID], ds.[name] AS [View Name] FROM   data_source ds WHERE  ds.[type_id] = 1
END

IF @flag = 'g' -- called from setup user defined view page for grid load
BEGIN
	SELECT DISTINCT
		sdv.code [category],
		ds.name [name],
		ds.data_source_id [id],
		ds.system_defined [system_defined]
	FROM #privileged_data_source ds
	INNER JOIN static_data_value sdv
		ON sdv.value_id = ds.category
	WHERE ds.type_id = 1
	ORDER BY name
END
