IF OBJECT_ID(N'[dbo].[spa_ixp_import_data_source]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_import_data_source]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Used to maintain import data source definiton.

	Parameters
	@flag : Operational Flag.
			'v' - To validate duplicate import function name.
			'i' - Insert script
			'u' - Update script
			'q' - Validate sql syntax.
	@import_data_source_id : Import Data Source Id
	@process_id : Process Id
	@rules_id : Unique identifier of import rule.
	@data_source_type : Import data source type.
	@data_source_location : Source data location.
	@connection_string : Connection String
	@delimiter : Delimiter of source column.
	@source_system_id : Source system id.
	@data_source_alias : Import data source alias.
	@is_customize : Set customize data import or not. Default is 0.
	@customizing_query : Customize script to be executed before collecting source data.
	@is_header_less : Defines source data has column header or not.
	@no_of_columns : No Of Columns if source data is header less.
	@folder_location : Folder Location of import data source.
	@custom_import : Custom Import logic not in use.
	@package : SSIS Package
	@use_parameter : Defines package required parameter or not. Default is 'n'.
	@ssis_table : SSIS Table
	@ws_function_name : Ws Function Name
	@excel_sheet : Excel sheet name to import from. Sheet1 used for single table excel file.
	@clr_function_id : CLR Function used to import data.
	@error_success: variable to identify error message or success message in Inport notification.
*/

CREATE PROCEDURE [dbo].[spa_ixp_import_data_source]    
    @flag CHAR(1),
    @import_data_source_id INT = NULL,
    @process_id VARCHAR(300) = NULL,
    @rules_id INT = NULL,
    @data_source_type INT = NULL,
    @data_source_location VARCHAR(2000) = NULL,
    @connection_string VARCHAR(2000) = NULL,
    @delimiter VARCHAR(10) = NULL,
    @source_system_id INT = 2,
    @data_source_alias VARCHAR(50) = NULL,
    @is_customize CHAR(1) = 0,
    @customizing_query VARCHAR(MAX) = NULL,
    @is_header_less CHAR(1) = NULL,
    @no_of_columns INT = NULL,
    @folder_location VARCHAR(8000) = NULL,
    @custom_import CHAR(1) = NULL,
    @package INT = NULL,
    @use_parameter CHAR(1) = NULL,
    @ssis_table VARCHAR(500) = NULL,
    @ws_function_name VARCHAR(200) = NULL,
	@excel_sheet VARCHAR(100) = NULL,
    @clr_function_id INT = NULL,
	@enable_email_import CHAR(1) = NULL,
	@send_email_import_reply CHAR(1) = NULL,
	@error_success int = 0,
	@file_transfer_endpoint_id INT = NULL,
	@ftp_remote_directory NVARCHAR(1024) = NULL
AS
SET NOCOUNT ON

/** * DEBUG QUERY START *
	SET NOCOUNT ON
EXEC sys.sp_set_session_context @key = N'DB_USER', @value = 'bkarki';
DECLARE 
    @flag CHAR(1),
    @import_data_source_id INT = NULL,
    @process_id VARCHAR(300) = NULL,
    @rules_id INT = NULL,
    @data_source_type INT = NULL,
    @data_source_location VARCHAR(2000) = NULL,
    @connection_string VARCHAR(2000) = NULL,
    @delimiter VARCHAR(10) = NULL,
    @source_system_id INT = 2,
    @data_source_alias VARCHAR(50) = NULL,
    @is_customize CHAR(1) = 0,
    @customizing_query VARCHAR(MAX) = NULL,
    @is_header_less CHAR(1) = NULL,
    @no_of_columns INT = NULL,
    @folder_location VARCHAR(8000) = NULL,
    @custom_import CHAR(1) = NULL,
    @package INT = NULL,
    @use_parameter CHAR(1) = NULL,
    @ssis_table VARCHAR(500) = NULL,
    @ws_function_name VARCHAR(200) = NULL,
	@excel_sheet VARCHAR(100) = NULL,
    @clr_function_id INT = NULL,
	@enable_email_import CHAR(1) = NULL,
	@send_email_import_reply CHAR(1) = NULL,
	@error_success int = 0,
	@file_transfer_endpoint_id INT = NULL,
	@ftp_remote_directory NVARCHAR(1024) = NULL
select
	 @clr_function_id = ''
	,@connection_string = ''
	,@custom_import = 0
	,@data_source_alias = 't'
	,@data_source_location = '\\APP01\shared_docs_TRMTracker_Trunk\temp_Note\0'
	,@data_source_type = null
	,@delimiter = ','
	,@enable_email_import = 0
	,@excel_sheet = ''
	,@file_transfer_endpoint_id = '1'
	,@flag = 'i'
	,@folder_location = '\\fs01\dataimport'
	,@ftp_remote_directory = 'testaaaa'
	,@import_data_source_id = null
	,@is_header_less = 'n'
	,@no_of_columns = ''
	,@package = ''
	,@process_id = '323CF26E_472A_469F_9879_DA02D1B08889'
	,@rules_id = '1'
	,@send_email_import_reply = 0
	,@use_parameter = 0
	,@ws_function_name = ''

-- select * from adiha_process.dbo.ixp_import_data_source_bkarki_CDA1C288_BF65_450F_AFEF_3D45EB697BF5
-- * DEBUG QUERY END * */

DECLARE @sql VARCHAR(MAX)
DECLARE @DESC VARCHAR(500)
DECLARE @err_no INT
DECLARE @user_name VARCHAR(100)
DECLARE @ixp_import_data_source VARCHAR(200)
DECLARE @ixp_import_relation VARCHAR(200)
DECLARE @ixp_import_filter VARCHAR(400)
DECLARE @new_data_source_id INT 
DECLARE @return INT
SET @user_name = dbo.FNADBUser() 
SET @ixp_import_data_source = dbo.FNAProcessTableName('ixp_import_data_source', @user_name, @process_id) 
SET @ixp_import_relation = dbo.FNAProcessTableName('ixp_import_relation', @user_name, @process_id)
SET @ixp_import_filter = dbo.FNAProcessTableName('ixp_import_filter', @user_name, @process_id)
 
IF @flag = 'i'
BEGIN
	BEGIN TRY		
		SET @sql = 'INSERT INTO ' + @ixp_import_data_source + ' (rules_id, data_source_type, data_source_location, connection_string, delimiter, source_system_id, data_source_alias, is_customized, is_header_less, no_of_columns, folder_location, custom_import, ssis_package, use_parameter, ws_function_name, excel_sheet,file_transfer_endpoint_id, remote_directory, clr_function_id, enable_email_import, send_email_import_reply)
					SELECT ' + CAST(@rules_id AS VARCHAR(20)) + ',
						   ' + ISNULL(CAST(@data_source_type AS VARCHAR(20)), 'NULL') + ',
						   ' + ISNULL('''' + @data_source_location + '''', 'NULL') + ',
						   ' + ISNULL('''' + @connection_string + '''', 'NULL') + ',
						   ' + ISNULL('''' + @delimiter + '''', 'NULL') + ',
						   ' + CAST(@source_system_id AS VARCHAR(200)) + ',
						   ' + ISNULL('''' + @data_source_alias + '''', 'NULL') + ',
						   ''' + @custom_import + ''',
						   ' + COALESCE('''' + @is_header_less + '''', 'NULL') + ',
						   ' + ISNULL(CAST(@no_of_columns AS VARCHAR(200)), 'NULL') + ',
						   ' + ISNULL('''' + @folder_location + '''', 'NULL') + ',
						   ''' + @custom_import + ''',
						   ' + COALESCE(CAST(@package AS VARCHAR(20)), 'NULL') + ',
						   ' +  COALESCE('''' + @use_parameter + '''', 'NULL') + ',
						   ' + COALESCE(''''+@ws_function_name+'''', 'NULL') + ',
						   ' + ISNULL('''' + @excel_sheet + '''', 'NULL') + ',
						   ' + CAST(@file_transfer_endpoint_id AS VARCHAR(20)) + ',
						   ''' + ISNULL(NULLIF(CAST(@ftp_remote_directory AS VARCHAR(1024)),''), 'NULL') + ''',
						   ' + COALESCE(CAST(@clr_function_id AS VARCHAR(20)), 'NULL') + ',						  
						   ' +  COALESCE('''' + @enable_email_import + '''', 'NULL') + ',
						   ' +  COALESCE('''' + @send_email_import_reply + '''', 'NULL')

		exec spa_print @sql
		EXEC(@sql)
		
		SELECT @new_data_source_id = IDENT_CURRENT(@ixp_import_data_source);
				
		EXEC spa_ErrorHandler 0
			, 'ixp_import_data_source'
			, 'spa_ixp_import_data_source'
			, 'Success' 
			, 'Successfully saved data.'
			, @new_data_source_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'ixp_import_data_source'
		   , 'spa_ixp_import_data_source'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END
IF @flag = 'u'
BEGIN
	BEGIN TRY
		CREATE TABLE #temp_data_source_alias_exist ([data_exist] TINYINT)
		SET @sql =  'INSERT INTO #temp_data_source_alias_exist ([data_exist]) SELECT 1 FROM ' + @ixp_import_relation + ' WHERE ixp_relation_alias = ''' + @data_source_alias + ''' AND ixp_rules_id = ' + CAST(@rules_id AS VARCHAR(20))
		--PRINT(@sql)
		EXEC(@sql)
		
		IF EXISTS (SELECT 1 FROM #temp_data_source_alias_exist)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'ixp_import_relation',
				 'spa_ixp_import_relation',
				 'DB Error',
				 'Alias is already used for linked datasource.',
				 ''
			RETURN
		END
		SET @sql = 'UPDATE ' + @ixp_import_data_source + '
					SET data_source_type = ' + CAST(@data_source_type AS VARCHAR(20)) + ',
						data_source_location = ' + ISNULL('''' + @data_source_location + '''', 'NULL') + ',	
						connection_string = ' + ISNULL('''' + @connection_string + '''', 'NULL') + ',
						delimiter = ' + ISNULL('''' + @delimiter + '''', 'NULL') + ',
						source_system_id = ' + CAST(@source_system_id AS VARCHAR(20)) + ',
						data_source_alias = ' + ISNULL('''' + @data_source_alias + '''', 'NULL') + ',
						is_customized = ''' + @custom_import + ''',
						is_header_less = ' + COALESCE('''' + @is_header_less + '''', 'NULL') + ',
						no_of_columns = ' + ISNULL(CAST(@no_of_columns AS VARCHAR(20)), 'NULL') + ',
						folder_location = ' + ISNULL('''' + @folder_location + '''', 'NULL') + ',
						custom_import = ''' + @custom_import + ''',
						ssis_package = ' + COALESCE(CAST(@package AS VARCHAR(20)), 'NULL') + ',
						use_parameter = ' + COALESCE('''' + @use_parameter + '''', 'NULL') + ',
						ws_function_name = ' + COALESCE(''''+@ws_function_name+'''', 'NULL') + ',
                        clr_function_id = ' + COALESCE(CAST(@clr_function_id AS VARCHAR(20)), 'NULL') + ',
						excel_sheet = ' + ISNULL('''' + @excel_sheet + '''', 'NULL') + ',
						file_transfer_endpoint_id = ' + ISNULL(CAST(@file_transfer_endpoint_id AS VARCHAR(20)), 'NULL') + ',
						remote_directory = ' + ISNULL('''' + @ftp_remote_directory + '''', 'NULL') + ',
						enable_email_import = ' + COALESCE('''' + @enable_email_import + '''', 'NULL') + ',
						send_email_import_reply = ' + COALESCE('''' + @send_email_import_reply + '''', 'NULL') + ' 
					WHERE ixp_import_data_source_id = ' + CAST(@import_data_source_id AS VARCHAR(10))
		exec spa_print @sql
		EXEC(@sql)

		EXEC spa_ErrorHandler 0
			, 'ixp_import_data_source'
			, 'spa_ixp_import_data_source'
			, 'Success' 
			, 'Successfully saved data.'
			, @import_data_source_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'ixp_import_data_source'
		   , 'spa_ixp_import_data_source'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END

IF @flag = 's'
BEGIN
	SELECT iids.rules_id,
	       iids.ixp_import_data_source_id,
	       iids.data_source_type,
	       REPLACE(iids.connection_string, '\', '\\') connection_string,
	       REPLACE(iids.data_source_location, '\', '\\') data_source_location,
	       iids.delimiter,
	       iids.source_system_id,
	       iids.data_source_alias,
	       iids.is_customized,
	       iids.is_header_less,
	       iids.no_of_columns,
	       REPLACE(iids.folder_location, '\', '\\') folder_location,
	       ISNULL(iids.custom_import, 'n') custom_import,
	       iids.ssis_package,
	       iids.use_parameter,
	       iids.ws_function_name,
		   iids.excel_sheet,
		   iids.customizing_query,
           iids.clr_function_id,
		   iids.enable_email_import,
		   iids.send_email_import_reply,
		   CAST(ftei.file_transfer_endpoint_id AS NVARCHAR(8)) + '|' 
				+ CASE WHEN ftei.file_protocol = 2 THEN 'sftp://' ELSE 'ftp://'  END 
				+ ftei.host_name_url
			file_transfer_endpoint_id,
		   iids.remote_directory
	FROM   ixp_import_data_source iids
	LEFT JOIN file_transfer_endpoint ftei ON ftei.file_transfer_endpoint_id = iids.file_transfer_endpoint_id
	WHERE iids.rules_id = @rules_id
END
IF @flag = 'p'
BEGIN
	BEGIN TRY
		EXEC @return = spa_check_sql_syntax @customizing_query
		
		IF @return = 1
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'ixp_import_data_source',
				 'spa_ixp_import_data_source',
				 'Error',
				 'SQL Statement is Invalid.',
				 ''
			RETURN
		END
		
			SET @sql = 'UPDATE ' + @ixp_import_data_source + '
						SET customizing_query = ' + ISNULL(''''+ REPLACE(dbo.FNADecodeXML(REPLACE(@customizing_query, '&add;', '+')), '''', '''''') + '''', 'NULL') + '
						--WHERE ixp_import_data_source_id = ' + CAST(@import_data_source_id AS VARCHAR(10))
		
		--PRINT(@sql)
		EXEC(@sql)
		
		EXEC spa_ErrorHandler 0
			, 'ixp_import_data_source'
			, 'spa_ixp_import_data_source'
			, 'Success' 
			, 'Successfully saved data.'
			, @import_data_source_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'ixp_import_data_source'
		   , 'spa_ixp_import_data_source'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END
ELSE IF @flag = 'q' -- syntax checking
BEGIN
	--PRINT(@customizing_query)
	EXEC @return = spa_check_sql_syntax @customizing_query
	
	IF @return = 0 
	BEGIN
		EXEC spa_ErrorHandler 0,
			 'ixp_import_data_source',
			 'spa_ixp_import_data_source',
			 'Success',
			 'SQL Statement is Valid.',
			 ''
	END
	ELSE IF @return = 1
	BEGIN
		EXEC spa_ErrorHandler -1,
			 'ixp_import_data_source',
			 'spa_ixp_import_data_source',
			 'Error',
			 'SQL Statement is Invalid.',
			 ''
	END 
END
IF @flag = 'r'
BEGIN
	SET @sql = 'SELECT iids.customizing_query
	            FROM   ' + @ixp_import_data_source + ' iids
	            WHERE ixp_import_data_source_id = ' + CAST(@import_data_source_id AS VARCHAR(10))
	EXEC(@sql)
END
IF @flag = 't'
BEGIN
	DECLARE @custom_query VARCHAR(MAX)
	DECLARE @custom_temp_table VARCHAR(500)
	DECLARE @table_name VARCHAR(500)
	DECLARE @sql_stmt NVARCHAR(MAX)
	
	--SET @custom_temp_table = 'adiha_process.dbo.custom_import_table_' + @user_name  + '_' + @process_id 
	SET @custom_temp_table = dbo.FNAProcessTableName('custom_import_table', @user_name, @process_id )
	--SET @table_name = 'custom_import_table_' + @user_name  + '_' + @process_id
	SET @table_name = REPLACE(@custom_temp_table, 'adiha_process.dbo.', '')
	
	EXEC('IF EXISTS(SELECT * FROM adiha_process.sys.tables WITH(NOLOCK) WHERE [name] = ''' + @table_name + ''')
			DROP TABLE ' + @custom_temp_table)
	SET @sql_stmt = 'SELECT @custom_query = CASE WHEN data_source_type = 21400 THEN REPLACE(customizing_query, ''[temp_process_table]'', ''adiha_process.dbo.temp_import_data_table_' + @process_id + ''') 
	                                             WHEN data_source_type = 21403 THEN REPLACE(customizing_query, ''[temp_process_table]'', ' + ISNULL(@ssis_table, '''''') + ') 
	                                             ELSE REPLACE(customizing_query, ''[temp_process_table]'', connection_string) 
	                                        END 
	                 FROM ' + @ixp_import_data_source + ' 
	                 WHERE ixp_import_data_source_id = ' + CAST(@import_data_source_id AS VARCHAR(20))
	--PRINT(@sql_stmt)
	EXEC sp_executesql @sql_stmt, N'@custom_query varchar(max) output', @custom_query OUTPUT
	
	SET @custom_query = REPLACE(@custom_query, '--[__custom_table__]',  ' INTO ' + @custom_temp_table)
	SET @custom_query = REPLACE(@custom_query, '[__custom_table__]',  @custom_temp_table)
	--PRINT(ISNULL(@custom_query, 'null'))
	EXEC(@custom_query) 
	
	SELECT @table_name
END
IF @flag = 'x'
BEGIN
	SELECT data_source_alias, 
			document_path + '\temp_Note\' [document_path] 
	FROM ixp_import_data_source 
	CROSS JOIN connection_string
	WHERE rules_id = @rules_id

END 

/*
 * To validate duplicate import function name
 */
ELSE IF @flag = 'v'
BEGIN
	IF EXISTS(SELECT 1 FROM ixp_import_data_source WHERE ws_function_name = @ws_function_name AND rules_id <> ISNULL(NULLIF(@rules_id,''),-1) AND NULLIF(@ws_function_name,'') IS NOT NULL)
	BEGIN
		SELECT 'false' [status]
	END
	ELSE
	BEGIN
		SELECT 'true' [status]
	END
END
/*
* To list data in import notification
*/
ELSE IF @flag = 'a'
BEGIN
	SELECT CASE WHEN @error_success = 1 THEN iids.message_id ELSE iids.error_message_id END message_id, 
	@error_success  [action], 
	CASE WHEN @error_success = 1 THEN CONCAT(ir.ixp_rules_name,' Notification') ELSE CONCAT(ir.ixp_rules_name,' Error Notification') END notification_name
	FROM ixp_import_data_source iids
	INNER JOIN ixp_rules ir ON iids.rules_id = ir.ixp_rules_id
	WHERE  
	rules_id  = @rules_id 	
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE FROM workflow_event_user_role 
			WHERE event_message_id = 
							(SELECT message_id FROM ixp_import_data_source WHERE rules_id = @rules_id)
		DELETE FROM workflow_event_user_role 
			WHERE event_message_id =
							(SELECT error_message_id FROM ixp_import_data_source WHERE rules_id = @rules_id)	

			DELETE  wem
			FROM workflow_event_message wem
			INNER JOIN dbo.event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			LEFT JOIN dbo.workflow_activities wa ON wa.workflow_trigger_id = et.event_trigger_id AND wa.event_message_id = wa.event_message_id 
			INNER JOIN ixp_import_data_source iids ON iids.message_id = wa.event_message_id
			AND rules_id = @rules_id

			DELETE  wem
			FROM workflow_event_message wem
			INNER JOIN dbo.event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			LEFT JOIN dbo.workflow_activities wa ON wa.workflow_trigger_id = et.event_trigger_id AND wa.event_message_id = wa.event_message_id 
			INNER JOIN ixp_import_data_source iids ON iids.error_message_id = wa.event_message_id
			AND rules_id = @rules_id

			UPDATE ixp_import_data_source
			SET
				message_id = NULL,
				error_message_id = NULL
			WHERE
				rules_id = @rules_id
			
	EXEC spa_ErrorHandler 0,
					 'Import Notification',
					 'spa_workflow_schedule',
					 'Success',
					 'Import Notification Cleared Successfully',					 
					 ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Import Notification',
             'spa_workflow_schedule',
             'DB Error',
             'Fail',
             ''
	END CATCH
END
