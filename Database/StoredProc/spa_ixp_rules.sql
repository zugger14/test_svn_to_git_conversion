SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

 /**
	CRUD operations for table ixp_rules
 
	Parameters:
	@flag : Operation flag
					 - 'i' - insert rule detail in process table 
					 - 'y' - update rule detail in process table 
					 - 'x' - list import rules
					 - 'a' - get rule detail for specific rule id
					 - 'u' - update triggers in process table
					 - 'p' - save data from process table and proceed
					 - 'q' - execute without saving, uses process table data to execute rules.
					 - 'r' - execute rules after saving data or execute rules for batch process
					 - 't' - execute rules immediately for given import file. 
					 - 'd' - Delete rule
					 - 'c' - Call to import data to first staging table according to file exten. 
					 - 'e' - Used by excel add-in to list import rules. [DO NOT CHANGE COLUMN SELECTION IN THIS FLAG]
					 - 'g' - select in grid of data import
					 - 'v' - import into first staging table from excel file
					 - 'z' - get sheet name of excel file
	@process_id : Unique id for running process
	@ixp_rules_id : Unique id of import export rule.
	@ixp_rules_name : Unique name of import export rules.
	@individual_script_per_object : Flag to generate individual script for individual object Expected value - 'y' or 'n'
	@limit_rows_to : Maximum number of rows in each file
	@before_insert_triger : Script used to trigger before import process. 
	@after_insert_triger : Script used to trigger after import process.
	@import_export_flag : Flag to distinguish import or export rules expected value - 'i' - Import, 'm' - Data Migration(Export)
	@run_rules : Run flag(while saving) - 'y' - run 'n' - do not run
	@ixp_owner : Rule Owner
	@ixp_category : Rule category
	@is_system_import : System flag - 'y' - system, 'n' - general
	@run_table : Table used to run rule(triggered from run button and SOAP interface)
	@run_with_custom_enable : Use custom query while running rule (triggered from run button and SOAP interface)
	@source : Source of import.
	@server_path : Server location for files.
	@parameter_xml : XML - parameter for SSIS package.
	@active_flag : Determine active rule Expected value - '1' or '0'
	@show_delete_msg : Show hide deleted message.
	@excel_sheet_name : Sheet name for excel import
	@run_in_debug_mode : Run flag used while running from SOAP
	@batch_process_id : Unique batch identifer of import process.
	@batch_report_param : paramater to run through barch
	@rule_name : Import rule name.
	@source_delimiter : Delimeter to seperate columns. Applicabhle for csv file extension.
	@source_with_header : Speicfies file has columns header or not or not Expected value - 'y' or 'n'.
	@enable_ftp : Set 1 to import from ftp server. Default is 0.
	@encrypt_password : Is password encrypted. Default is 0.
	@email_notes_id : Email notes id use to import from email.
	@execute_in_queue : NULL -> Execute as per from adiha_configuration
						1 -> Execute in Queue
						2 -> Execute in parallel
	@file_transfer_endpoint_id	:	File transfer endpoint id, configured in file_transfer_endpoint table
	@ftp_remote_directory		:	Ftp target remote target, NULL will point endpoint remote directory if setup, otherwise to root folder
 */

CREATE OR ALTER PROCEDURE [dbo].[spa_ixp_rules]
	@flag NCHAR(1),
	@process_id NVARCHAR(300) = NULL,
	@ixp_rules_id NVARCHAR(MAX) = NULL,
	@ixp_rules_name NVARCHAR(100) = NULL,
	@individual_script_per_object NCHAR(1) = NULL,
	@limit_rows_to INT = NULL,
	@before_insert_triger NVARCHAR(MAX) = NULL,
	@after_insert_triger NVARCHAR(MAX) = NULL,
	@import_export_flag NCHAR(1) = NULL,
	@run_rules NCHAR(1) = NULL,
	@ixp_owner NVARCHAR(1000) = NULL,
	@ixp_category INT = NULL,
	@is_system_import NCHAR(1) = NULL,
	@run_table NVARCHAR(400) = NULL,
	@run_with_custom_enable NCHAR(1) = 'n',
	@source INT = NULL,
	@server_path NVARCHAR(2000) = NULL,
	@parameter_xml TEXT = NULL,
	@active_flag INT = 1,
	@show_delete_msg NCHAR(1) = 'y',
	@excel_sheet_name NVARCHAR(100) = NULL,
	@run_in_debug_mode NCHAR(1) = NULL,
	@batch_process_id NVARCHAR(50) = NULL,
	@batch_report_param NVARCHAR(1000) = NULL,
	@rule_name NVARCHAR(1000) = NULL
    --todo new paramter added
	, @source_delimiter NCHAR(1) = ','
	, @source_with_header NCHAR(1) = 'y'
	, @enable_ftp INT = 0
	, @encrypt_password INT = 0
	, @email_notes_id INT = NULL
	, @execute_in_queue INT = NULL
	, @file_transfer_endpoint_id INT = NULL
	, @ftp_remote_directory NVARCHAR(1024) = NULL
    
AS

SET NOCOUNT ON
/*
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
EXEC spa_print 'In debug mode important informations are printed through spa_print statement instead of PRINT. Any PRINT statement if found should be replaced with spa_print.'
EXEC sys.sp_set_session_context @key = N'DB_USER', @value = 'farrms_admin';
declare @flag NCHAR(1) = 't',
	@process_id NVARCHAR(300) = '2D179B43_19DB_4BEF_B068_2F18A1309B05',
	@ixp_rules_id NVARCHAR(MAX) = 14411,
	@ixp_rules_name NVARCHAR(100) = NULL,
	@individual_script_per_object NCHAR(1) = NULL,
	@limit_rows_to INT = NULL,
	@before_insert_triger NVARCHAR(MAX) = NULL,
	@after_insert_triger NVARCHAR(MAX) = NULL,
	@import_export_flag NCHAR(1) = NULL,
	@run_rules NCHAR(1) = NULL,
	@ixp_owner NVARCHAR(1000) = NULL,
	@ixp_category INT = NULL,
	@is_system_import NCHAR(1) = NULL,
	@run_table NVARCHAR(400) = NULL,
	@run_with_custom_enable NCHAR(1) = 'n',
	@source INT = NULL,
	@server_path NVARCHAR(2000) = NULL,
	@parameter_xml  NVARCHAR(2000) = NULL,
	@active_flag INT = 1,
	@show_delete_msg NCHAR(1) = 'y',
	@excel_sheet_name NVARCHAR(100) = NULL,
	@run_in_debug_mode NCHAR(1) = NULL,
	@batch_process_id NVARCHAR(50) = NULL,
	@batch_report_param NVARCHAR(1000) = NULL,
	@rule_name NVARCHAR(1000) = NULL
	, @source_delimiter NCHAR(1) = ','
	, @source_with_header NCHAR(1) = 'y'
	, @encrypt_password INT = 0
	, @enable_ftp INT = 0
	, @email_notes_id INT = NULL
	, @execute_in_queue INT = 0
	, @file_transfer_endpoint_id INT = NULL
	, @ftp_remote_directory NVARCHAR(1024) = NULL

SELECT  @flag='t', @process_id='D7C87DB3_4FCF_41BA_9340_9F19976AF041', @ixp_rules_id='6149'
, @run_table='adiha_process.dbo.temp_import_data_table_fv_D7C87DB3_4FCF_41BA_9340_9F19976AF041', @source = '21405'
, @run_with_custom_enable = 'n', @server_path='RETAIL_ST_SOURCE_OCT.xlsx', @source_delimiter=',' 
, @source_with_header='y', @enable_ftp=0

-- select *   from source_system_data_import_status_detail where process_id = '540420C9_C2D9_4EBF_A586_77A255EDD93G'
-- select * from adiha_process.dbo.temp_import_data_table_fv_D7C87DB3_4FCF_41BA_9340_9F19976AF041
-- select * from adiha_process.dbo.ixp_source_price_curve_def_template_0_msingh_540420C9_C2D9_4EBF_A586_77A255EDD93G
--*/

IF @process_id IS NULL
    SET @process_id = ISNULL(@batch_process_id,  dbo.FNAGETNEWID())
    
IF @run_in_debug_mode IS NULL
	SET @run_in_debug_mode = 'n'

SET @enable_ftp = ISNULL(@enable_ftp,0)

DECLARE @user_name              NVARCHAR(100)
	, @sql                      NVARCHAR(MAX)
	, @ixp_rules                NVARCHAR(300)
	, @ixp_data_mapping         NVARCHAR(300)
	, @ixp_export_tables        NVARCHAR(300)
	, @ixp_import_data_source   NVARCHAR(200)
	, @ixp_import_data_mapping  NVARCHAR(200)
	, @ixp_import_relation      NVARCHAR(300)
	, @ixp_export_data_source   NVARCHAR(400)
	, @ixp_export_relation      NVARCHAR(400)
	, @DESC                     NVARCHAR(MAX)
	, @ixp_import_where_clause  NVARCHAR(300)
	, @err_no                   INT
	, @rules_id INT
	, @trigger_before_import NVARCHAR(MAX)
	, @trigger_after_import NVARCHAR(MAX)
	, @ixp_table_id INT
	, @table_name NVARCHAR(MAX)
	, @table_desc NVARCHAR(300)
	, @where_clause NVARCHAR(MAX)
	, @job_name NVARCHAR(500)
	, @url NVARCHAR(MAX)
	, @ixp_import_query_builder_tables NVARCHAR(500)
	, @ixp_import_query_builder_relation NVARCHAR(600)
	, @ixp_custom_import_mapping NVARCHAR(500)
	, @ixp_import_query_builder_import_tables NVARCHAR(600)
	, @rules_names NVARCHAR(MAX)
	, @ixp_parameters NVARCHAR(400)
	, @ixp_import_filter NVARCHAR(400)
	, @elasped_time NVARCHAR(100) 
	, @server_name NVARCHAR(200)
	, @csv_import_status NVARCHAR(MAX)
	, @excel_import_status NVARCHAR(MAX)
	, @full_file_path NVARCHAR(2000)
	, @clr_function_id INT
	, @message NVARCHAR(MAX)
	, @clr_function_name NVARCHAR(50) 
	, @is_custom_ftp INT = 0
	, @supress NVARCHAR(100)
	, @response_message NVARCHAR(1000)
	, @data_source_view_sql NVARCHAR(MAX)
	, @data_source_result_table NVARCHAR(MAX) 
	, @lse_import_status NVARCHAR(100)
	, @ixp_rule_hash NVARCHAR(50) 
	, @source_data_download_status NVARCHAR(MAX)
	, @chk_file_exists NVARCHAR(max)
	, @final_print_data NVARCHAR(max)
	, @debug_mode NVARCHAR(50) 
	, @status NVARCHAR(100)
	, @total_columns INT = NULL
	, @source_ixp_column_mapping NVARCHAR(200)

IF @execute_in_queue IS NULL
BEGIN
	SELECT @execute_in_queue = ISNULL(var_value,1) FROM adiha_default_codes adc
	INNER JOIN adiha_default_codes_values adcv ON adc.default_code_id = adcv.default_code_id
	WHERE adc.default_code_id = 203
END

IF @execute_in_queue = 1
	SET @run_in_debug_mode = 'n' 

SELECT @debug_mode = REPLACE(CONVERT(VARCHAR(128), CONTEXT_INFO()), 0x0, '') --Check context info debug mode on or not and used to debugging purpose.
SELECT  @server_name = CONVERT(NVARCHAR(200),ServerProperty('ServerName'))

IF @flag IN ('p', 'i', 'y')
BEGIN
	SELECT @ixp_rule_hash = ixp_rule_hash FROM ixp_rules WHERE ixp_rules_id = @ixp_rules_id
	SET @ixp_rule_hash  = ISNULL(@ixp_rule_hash, dbo.FNAGETNEWID())
END

SET @user_name = dbo.FNADBUser() 
SET @ixp_rules = dbo.FNAProcessTableName('ixp_rules', @user_name, @process_id)
SET @ixp_data_mapping = dbo.FNAProcessTableName('ixp_data_mapping', @user_name, @process_id)
SET @ixp_export_tables = dbo.FNAProcessTableName('ixp_export_tables', @user_name, @process_id)
SET @ixp_import_data_source = dbo.FNAProcessTableName('ixp_import_data_source', @user_name, @process_id)
SET @ixp_import_data_mapping = dbo.FNAProcessTableName('ixp_import_data_mapping', @user_name, @process_id)
SET @ixp_import_relation = dbo.FNAProcessTableName('ixp_import_relation', @user_name, @process_id)
SET @ixp_import_where_clause = dbo.FNAProcessTableName('ixp_import_where_clause', @user_name, @process_id)
SET @ixp_export_data_source = dbo.FNAProcessTableName('ixp_export_data_source', @user_name, @process_id) 
SET @ixp_export_relation = dbo.FNAProcessTableName('ixp_export_relation', @user_name, @process_id)
SET @ixp_import_query_builder_tables = dbo.FNAProcessTableName('ixp_import_query_builder_tables', @user_name, @process_id)
SET @ixp_import_query_builder_relation = dbo.FNAProcessTableName('ixp_import_query_builder_relation', @user_name, @process_id)
SET @ixp_custom_import_mapping = dbo.FNAProcessTableName('ixp_custom_import_mapping', @user_name, @process_id) 
SET @ixp_import_query_builder_import_tables = dbo.FNAProcessTableName('ixp_import_query_builder_import_tables', @user_name, @process_id)
SET @ixp_parameters = dbo.FNAProcessTableName('ixp_parameters', @user_name, @process_id)
SET @ixp_import_filter = dbo.FNAProcessTableName('ixp_import_filter', @user_name, @process_id)
SET @source_ixp_column_mapping = dbo.FNAProcessTableName('source_ixp_column_mapping', @user_name, @process_id)

IF NULLIF(CAST(@parameter_xml AS NVARCHAR(MAX)),'') IS NOT NULL 
BEGIN
	IF OBJECT_ID('tempdb..#temp_params') IS NOT NULL
		DROP TABLE #temp_params
	DECLARE @idoc1 INT

	EXEC sp_xml_preparedocument @idoc1 OUTPUT, @parameter_xml
	
	SELECT * INTO #temp_params
	FROM  OPENXML (@idoc1, '/Root/PSRecordset')
	WITH (paramName NVARCHAR(100) '@paramName', paramValue NVARCHAR(MAX) '@paramValue', paramType NVARCHAR(100) '@paramType' ) 
	EXEC sp_xml_removedocument @idoc1 
	UPDATE #temp_params SET paramValue = dbo.FNAResolveDynamicDate(paramValue) WHERE paramType = 'dyn_calendar'
	SET @parameter_xml = '<Root>' + CAST((SELECT * FROM #temp_params FOR XML RAW('PSRecordset'), TYPE) AS NVARCHAR(MAX)) + '</Root>'	
END

IF @flag = 'i' OR @flag = 'y' -- insert rules name to process table.
BEGIN
    BEGIN TRY
    	CREATE TABLE #temp_exist ([name] TINYINT)
		SET @sql =  'INSERT INTO #temp_exist ([name]) SELECT TOP(1) 1 FROM ixp_rules WHERE ixp_rules_name = ''' + @ixp_rules_name + '''' 
	
		IF @flag = 'y'
			SET @sql = @sql + ' AND ixp_rules_id <> ' + CAST(@ixp_rules_id AS NVARCHAR(10))
						
		exec spa_print @sql
		EXEC(@sql)
		
		IF EXISTS (SELECT 1 FROM #temp_exist)
		BEGIN
			EXEC spa_ErrorHandler -1,
					 'Import/Export Wizard',
					 'spa_ixp_rules',
					 'DB Error',
					 'Rule name already exists.',
					 ''
			RETURN
		END
		
		IF @flag = 'i'
		BEGIN
			SET @sql = 'INSERT INTO ' + @ixp_rules + ' (ixp_rules_name, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
						VALUES (''' + @ixp_rules_name + ''',''' + @import_export_flag + ''', ''' + @is_system_import + ''', ''' + @user_name + ''',' + ISNULL(CAST(@ixp_category AS NVARCHAR(20)), 'NULL') + ',' + CAST(@active_flag AS NVARCHAR) + ',''' + ISNULL(@ixp_rule_hash,'') + ''') '
			exec spa_print @sql			
			EXEC (@sql)
		END
		IF @flag = 'y'
		BEGIN
			SET @sql = 'UPDATE ' + @ixp_rules + '
						SET ixp_rules_name = ''' + @ixp_rules_name + ''',
							is_system_import = ''' + @is_system_import + ''',
							ixp_category = ' + ISNULL(CAST(@ixp_category AS NVARCHAR(20)), 'NULL') + ',
							is_active = ' + CAST(@active_flag AS NVARCHAR) + ',
							ixp_rule_hash = ''' + ISNULL(@ixp_rule_hash,'') + '''					
						WHERE ixp_rules_id = ' + CAST(@ixp_rules_id AS NVARCHAR(10))
			exec spa_print @sql				
			EXEC (@sql)
		END
		
    	DECLARE @ixp_id_new INT
    	
    	IF @flag = 'i'
			SET @ixp_id_new = IDENT_CURRENT(@ixp_rules)
		IF @flag = 'y'
			SET @ixp_id_new = @ixp_rules_id
			
		exec spa_print  @ixp_id_new
	    
		EXEC spa_ErrorHandler 0,
			 'Import/Export FX',
			 'spa_ixp_rules',
			 'Success',
			 @ixp_rules,
			 @ixp_id_new
    END TRY
    BEGIN CATCH	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	  
		IF ERROR_MESSAGE() = 'CatchError'
		   SET @DESC = N'Fail to insert data ( Error Description:' + @DESC + ').'
		ELSE
		   SET @DESC = N'Fail to insert data ( Error Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'Import/Export FX'
		   , 'spa_ixp_rules'
		   , 'Error'
		   , @DESC
		   , 'Contact Technical Suporrt.'
    END CATCH
END
ELSE IF @flag = 'x' -- populates Import/Export rules dropdown 
BEGIN
	SET @sql = 'SELECT ir.ixp_rules_id,
	                   ir.ixp_rules_name
	            FROM   ixp_rules ir'
	IF @import_export_flag <> 'x'
		SET @sql  = @sql + ' WHERE ir.import_export_flag = ''' +  @import_export_flag + ''''
	--PRINT(@sql)
	EXEC(@sql)
END
ELSE IF @flag = 'a' 
BEGIN
	SELECT ir.ixp_rules_id rules_id,
	       ir.ixp_rules_name rules_name,
	       ir.individuals_script_per_ojbect individuals_script_per_ojbect,
	       CASE 
	            WHEN limit_rows_to IS NOT NULL THEN 'y'
	            ELSE 'n'
	       END limit_enabled,
	       ir.limit_rows_to limit_rows_to,
	       REPLACE(REPLACE(ir.before_insert_trigger, '+', '&add;'), '\', '\\') 
	       before_insert_trigger,
	       REPLACE(REPLACE(ir.after_insert_trigger, '+', '&add;'), '\', '\\') 
	       after_insert_trigger,
	       ir.import_export_flag import_export_flag,
	       ir.ixp_owner,
	       ir.ixp_category,
	       ir.is_system_import,
		   ir.is_active
	FROM   ixp_rules ir
	WHERE  ir.ixp_rules_id = @ixp_rules_id
END
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		SET @sql = 'UPDATE ' + @ixp_rules + '
					SET individuals_script_per_ojbect = ''' + ISNULL(@individual_script_per_object, 'NULL') + ''',
						limit_rows_to = ' + ISNULL(CAST(@limit_rows_to AS NVARCHAR(100)), 'NULL') + ',
						before_insert_trigger = ' + ISNULL(''''+ REPLACE(dbo.FNADecodeXML(REPLACE(@before_insert_triger, '&add;', '+')), '''', '''''') + '''', 'NULL') + ',
						after_insert_trigger = ' + ISNULL('''' + REPLACE(dbo.FNADecodeXML(REPLACE(@after_insert_triger, '&add;', '+')), '''', '''''') + '''', 'NULL') + '
					WHERE ixp_rules_id = ' + CAST(@ixp_rules_id AS NVARCHAR(10))
		--PRINT (@sql)
		EXEC(@sql)
		
		EXEC spa_ErrorHandler 0,
			 'Import/Export FX',
			 'spa_ixp_rules',
			 'Success',
			 'Data successfully updated.',
			 @ixp_rules_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	  
		SET @DESC = N'Fail to update data ( Error Description:' + ERROR_MESSAGE() + ').'
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'Import/Export FX'
		   , 'spa_ixp_rules'
		   , 'Error'
		   , @DESC
		   , 'Contact Technical Suporrt.'
	END CATCH
END
ELSE IF @flag = 'p' -- saves rules to physical table from process table
BEGIN
	IF OBJECT_ID('tempdb..#rules_id') IS NOT NULL
		DROP TABLE #rules_id

	CREATE TABLE #rules_id (rules_id INT)
	DECLARE @sql1 NVARCHAR(MAX)
	DECLARE @sql2 NVARCHAR(MAX) = ''
	DECLARE @sql3 NVARCHAR(MAX) = ''

	BEGIN TRY

		  
		SET @sql1 = CAST('' AS NVARCHAR(MAX)) + N' DECLARE @old_rules_id INT
					 SELECT @old_rules_id = ir.ixp_rules_id FROM ixp_rules ir INNER JOIN ' + @ixp_rules + ' temp_ir ON ir.ixp_rules_id = '  + CAST(@ixp_rules_id AS NVARCHAR(20)) + '
					
					IF OBJECT_ID(''tempdb..#old_data_source_values'') IS NOT NULL
							DROP TABLE #old_data_source_values
					CREATE TABLE #old_data_source_values(process_table_ixp_export_data_source_id INT, ixp_export_data_source_id INT, export_table INT, export_table_alias NVARCHAR(50) COLLATE DATABASE_DEFAULT, root_table_id INT)
					
					IF OBJECT_ID(''tempdb..#old_ixp_import_query_builder_tables'') IS NOT NULL
						DROP TABLE #old_ixp_import_query_builder_tables
					CREATE TABLE #old_ixp_import_query_builder_tables(process_table_builder_tables_id INT, builder_tables_id INT, tables_name NVARCHAR(200) COLLATE DATABASE_DEFAULT, table_alias NVARCHAR(100) COLLATE DATABASE_DEFAULT, root_table_id INT)
					
					IF OBJECT_ID(''tempdb..#old_query_builder_import_tables'') IS NOT NULL
						DROP TABLE #old_query_builder_import_tables
					CREATE TABLE #old_query_builder_import_tables(process_table_builder_import_tables INT, builder_import_tables INT, table_id INT, sequence_number INT)
					
					Declare @old_message_id int 
					Declare @old_error_message_id int

					SELECT @old_message_id = message_id from ixp_import_data_source where rules_id = @old_rules_id
					SELECT @old_error_message_id = error_message_id from ixp_import_data_source where rules_id = @old_rules_id


					DECLARE @ixp_new_rule_id INT
					IF @old_rules_id IS NOT NULL
					BEGIN
					   DELETE isp 
					   FROM ixp_parameters isp
					   INNER JOIN ixp_import_data_source iids
						ON ISNULL(isp.ssis_package, -1) = ISNULL(iids.ssis_package, -1)
							AND ISNULL(isp.clr_function_id, -1) = ISNULL(iids.clr_function_id, -1)
					    WHERE iids.rules_id	= @old_rules_id
						DELETE FROM ixp_custom_import_mapping WHERE ixp_rules_id = @old_rules_id
						DELETE FROM ixp_import_query_builder_relation WHERE ixp_rules_id = @old_rules_id
						DELETE FROM ixp_import_query_builder_import_tables WHERE ixp_rules_id = @old_rules_id
						DELETE FROM ixp_import_query_builder_tables WHERE ixp_rules_id = @old_rules_id
						DELETE FROM ixp_export_relation WHERE ixp_rules_id	= @old_rules_id
						DELETE FROM ixp_import_data_mapping WHERE ixp_rules_id = @old_rules_id
						DELETE FROM ixp_import_relation WHERE ixp_rules_id	= @old_rules_id
						DELETE FROM ixp_import_data_source WHERE rules_id = @old_rules_id
						DELETE FROM ixp_data_mapping WHERE ixp_rules_id	= @old_rules_id	
					
						DELETE FROM ixp_export_data_source WHERE ixp_rules_id = @old_rules_id
						DELETE FROM ixp_export_tables WHERE ixp_rules_id = @old_rules_id	
						DELETE FROM ixp_import_where_clause WHERE rules_id = @old_rules_id
						DELETE FROM ixp_import_filter WHERE ixp_rules_id = @old_rules_id

						--DELETE FROM ixp_rules WHERE ixp_rules_id = @old_rules_id
						
					END					
					'
				
			SET @sql1 += CAST('' AS NVARCHAR(MAX)) + N'	
					IF @old_rules_id IS NULL
					BEGIN								
						INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
						SELECT ir.ixp_rules_name,
						   ir.individuals_script_per_ojbect,
						   ir.limit_rows_to,
						   dbo.FNADecodeXML(ir.before_insert_trigger),
						   dbo.FNADecodeXML(ir.after_insert_trigger),
						   ir.import_export_flag,
						   ir.is_system_import, 
						   ir.ixp_owner, 
						   ir.ixp_category,
							   ir.is_active,
							   ''' + ISNULL(@ixp_rule_hash,'') + '''
						FROM ' + @ixp_rules + ' ir
					
						
						SET @ixp_new_rule_id = SCOPE_IDENTITY()
					END
					ELSE
					BEGIN
						UPDATE ir
						SET 
						  ir.ixp_rules_name = irtemp.ixp_rules_name,
						  ir.individuals_script_per_ojbect = irtemp.individuals_script_per_ojbect,
						  ir.limit_rows_to = irtemp.limit_rows_to,
						  ir.before_insert_trigger = dbo.FNADecodeXML(irtemp.before_insert_trigger),
						  ir.after_insert_trigger = dbo.FNADecodeXML(irtemp.after_insert_trigger),
						  ir.import_export_flag = irtemp.import_export_flag,
						  ir.is_system_import = irtemp.is_system_import, 
						  ir.ixp_owner = irtemp.ixp_owner, 
						  ir.ixp_category = irtemp.ixp_category,
						  ir.is_active = irtemp.is_active,
						  ir.ixp_rule_hash = ''' + ISNULL(@ixp_rule_hash,'') + '''
						FROM ixp_rules ir 
						INNER JOIN ' + @ixp_rules + ' irtemp
						  ON ir.ixp_rules_id =  irtemp.ixp_rules_id

						--Here existing rule id is set to @ixp_new_rule_id to proceed following with existing id.
						SET @ixp_new_rule_id = @old_rules_id
					END

					INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, delimiter, source_system_id, data_source_alias, is_customized ,customizing_query, is_header_less, no_of_columns, folder_location, custom_import, ssis_package, use_parameter, ws_function_name, excel_sheet, clr_function_id, enable_email_import, send_email_import_reply, file_transfer_endpoint_id, remote_directory)
					SELECT @ixp_new_rule_id,
					       NULLIF(iids.data_source_type,0),
					       NULLIF(iids.connection_string,''''),
					       iids.data_source_location,
					       iids.delimiter,
					       iids.source_system_id,
					       iids.data_source_alias,
					       iids.is_customized,
						   iids.customizing_query,
						   iids.is_header_less, 
						   iids.no_of_columns,
						   iids.folder_location,
						   iids.custom_import,
						   NULLIF(iids.ssis_package, 0),
						   CASE WHEN iids.use_parameter = ''1'' THEN ''y'' ELSE ''n'' END,
						   iids.ws_function_name,
						   iids.excel_sheet,
                           NULLIF(iids.clr_function_id, 0),
						   iids.enable_email_import,
						   iids.send_email_import_reply,
						   NULLIF(iids.file_transfer_endpoint_id, ''''),
						   NULLIF(iids.remote_directory, '''')
					FROM   ' + @ixp_import_data_source + ' iids

					INSERT INTO ixp_import_filter (ixp_rules_id, filter_group, filter_id, filter_value, ixp_import_data_source)
					SELECT @ixp_new_rule_id,
					       iifs.filter_group,
					       iifs.filter_id,
					       iifs.filter_value,
					       iifs.ixp_import_data_source
					FROM   ' + @ixp_import_filter + ' iifs
					'
					
		SET @sql2 += CAST('' AS NVARCHAR(MAX)) + N' INSERT INTO ixp_parameters ( parameter_name, parameter_label, operator_id, field_type, default_value, default_value2, clr_function_id, ssis_package, grid_name, validation_message, insert_required, sql_string, default_format)
					SELECT 
					       parameter_name,
					       parameter_label,
					       operator_id,
					       field_type,
					       NULLIF(default_value, ''''),
					       NULLIF(default_value2, ''''),
                           clr_function_id,
						   ssis_package,
						   grid_name,
						   validation_message,
						   insert_required,
						   sql_string,
						   default_format
					FROM ' + @ixp_parameters + '
					
					INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
					OUTPUT INSERTED.ixp_export_data_source_id, INSERTED.export_table, INSERTED.export_table_alias, INSERTED.root_table_id
					INTO #old_data_source_values(ixp_export_data_source_id, export_table, export_table_alias, root_table_id)
					SELECT @ixp_new_rule_id,
						   iedt.export_table,
						   iedt.export_table_alias,
						   iedt.root_table_id
					FROM ' + @ixp_export_data_source + ' iedt
					
					UPDATE #old_data_source_values
					SET process_table_ixp_export_data_source_id = ixds.ixp_export_data_source_id
					FROM #old_data_source_values odsv
					INNER JOIN ' + @ixp_export_data_source + ' ixds ON ixds.export_table = odsv.export_table AND ixds.export_table_alias = odsv.export_table_alias
					
					
					UPDATE iiqbt
					SET root_table_id = odsv2.ixp_export_data_source_id
					FROM ' + @ixp_export_data_source + ' temp_ieds
					INNER JOIN #old_data_source_values odsv ON temp_ieds.ixp_export_data_source_id = odsv.process_table_ixp_export_data_source_id
					INNER JOIN #old_data_source_values odsv2 ON temp_ieds.root_table_id = odsv2.process_table_ixp_export_data_source_id
					INNER JOIN ixp_export_data_source iiqbt ON iiqbt.ixp_export_data_source_id = odsv.ixp_export_data_source_id
					WHERE temp_ieds.root_table_id IS NOT NULL
					
					INSERT INTO ixp_export_relation (ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source)
					SELECT @ixp_new_rule_id,
						   old_from.ixp_export_data_source_id,
						   old_to.ixp_export_data_source_id,
						   ier.from_column,
						   ier.to_column,
						   old_from.ixp_export_data_source_id
					FROM ' + @ixp_export_relation + ' ier
					INNER JOIN #old_data_source_values old_from  ON old_from.process_table_ixp_export_data_source_id = ier.from_data_source
					INNER JOIN #old_data_source_values old_to ON old_to.process_table_ixp_export_data_source_id = ier.to_data_source
					
					INSERT INTO ixp_export_tables (ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number)
					SELECT @ixp_new_rule_id,
						   iet.table_id,
						   iet.dependent_table_id,
						   iet.sequence_number,
						   iet.dependent_table_order,
						   ISNULL(iet.repeat_number, 0)
					FROM ' + @ixp_export_tables + ' iet
					
					'
					
		SET @sql2 += CAST('' AS NVARCHAR(MAX)) + N' INSERT INTO ixp_data_mapping (ixp_rules_id, table_id, column_name, source_column, column_function, column_aggregation, column_filter, export_folder, export_delim, generate_script, column_alias, main_table)
					  SELECT @ixp_new_rule_id,
						   idm.table_id,
						   idm.column_name,
						   idm.source_column,
						   idm.column_function,
						   idm.column_aggregation,
						   idm.column_filter,
						   idm.export_folder,
						   idm.export_delim,
						   idm.generate_script, 
						   idm.column_alias, 
						   odsv.ixp_export_data_source_id
					  FROM  ' + @ixp_data_mapping + ' idm
					  LEFT JOIN #old_data_source_values odsv ON idm.main_table = odsv.process_table_ixp_export_data_source_id 
					
					INSERT INTO ixp_import_data_mapping (ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number,udf_field_id)
					SELECT @ixp_new_rule_id,
						   iidm.dest_table_id,
						   iidm.source_column_name,
						   iidm.dest_column,
						   iidm.column_function,
						   iidm.column_aggregation,
						   ISNULL(iidm.repeat_number, 0),
						   NULLIF(iidm.udf_field_id,0)
					FROM ' + @ixp_import_data_mapping + ' iidm
					INNER JOIN ' + @ixp_export_tables + ' iet ON iet.ixp_rules_id = iidm.ixp_rules_id AND iidm.dest_table_id = ISNULL(iet.dependent_table_id, iet.table_id) AND iet.repeat_number = ISNULL(iidm.repeat_number, 0)
					
					INSERT INTO ixp_import_relation (ixp_rules_id, ixp_relation_alias, relation_source_type, connection_string, relation_location, join_clause, delimiter, excel_sheet)
					SELECT @ixp_new_rule_id,
					       iir.ixp_relation_alias,
					       iir.relation_source_type,
					       iir.connection_string,
					       iir.relation_location,
					       iir.join_clause,
					       iir.delimiter,
						   iir.excel_sheet
					FROM ' + @ixp_import_relation + ' iir 
					
					INSERT INTO ixp_import_query_builder_tables (ixp_rules_id, tables_name, root_table_id, table_alias)
					OUTPUT INSERTED.ixp_import_query_builder_tables_id, INSERTED.tables_name, INSERTED.table_alias, INSERTED.root_table_id
					INTO #old_ixp_import_query_builder_tables(builder_tables_id, tables_name, table_alias, root_table_id)
					SELECT @ixp_new_rule_id,
						   iiqbt.tables_name,
						   iiqbt.root_table_id,
						   iiqbt.table_alias
					FROM  ' + @ixp_import_query_builder_tables + ' iiqbt 
					
					UPDATE #old_ixp_import_query_builder_tables
					SET process_table_builder_tables_id = iiqbt.ixp_import_query_builder_tables_id
					FROM #old_ixp_import_query_builder_tables oiiqbt
					INNER JOIN ' + @ixp_import_query_builder_tables + ' iiqbt ON iiqbt.tables_name = oiiqbt.tables_name AND iiqbt.table_alias = oiiqbt.table_alias
					
					UPDATE iiqbt
					SET root_table_id = oiiqbt2.builder_tables_id
					FROM ' + @ixp_import_query_builder_tables + ' temp_iiqbt
					INNER JOIN #old_ixp_import_query_builder_tables oiiqbt ON temp_iiqbt.ixp_import_query_builder_tables_id = oiiqbt.process_table_builder_tables_id
					INNER JOIN #old_ixp_import_query_builder_tables oiiqbt2 ON temp_iiqbt.root_table_id = oiiqbt2.process_table_builder_tables_id
					INNER JOIN ixp_import_query_builder_tables iiqbt ON iiqbt.ixp_import_query_builder_tables_id = oiiqbt.builder_tables_id
					WHERE temp_iiqbt.root_table_id IS NOT NULL					
					
					INSERT INTO ixp_import_query_builder_import_tables (ixp_rules_id, table_id, sequence_number)
					OUTPUT INSERTED.ixp_import_query_builder_import_tables_id, INSERTED.table_id, INSERTED.sequence_number
					INTO #old_query_builder_import_tables(builder_import_tables, table_id, sequence_number)
					SELECT @ixp_new_rule_id,
						   iiqbit.table_id,
						   iiqbit.sequence_number
					FROM ' + @ixp_import_query_builder_import_tables + ' iiqbit
					'
					
		SET @sql3 = CAST('' AS NVARCHAR(MAX)) + N' UPDATE #old_query_builder_import_tables
					SET process_table_builder_import_tables = iiqbt.ixp_import_query_builder_import_tables_id
					FROM #old_query_builder_import_tables oiiqbt
					INNER JOIN ' + @ixp_import_query_builder_import_tables + ' iiqbt ON iiqbt.table_id = oiiqbt.table_id AND iiqbt.sequence_number = oiiqbt.sequence_number
					
					INSERT INTO ixp_import_query_builder_relation (ixp_rules_id, from_table_id, from_column, to_table_id, to_column)
					SELECT @ixp_new_rule_id,
						   oiiqbt_from.builder_tables_id,
						   iiqbr.from_column,
						   oiiqbt_to.builder_tables_id,
						   iiqbr.to_column
					FROM  ' + @ixp_import_query_builder_relation + ' iiqbr
					INNER JOIN #old_ixp_import_query_builder_tables oiiqbt_from ON iiqbr.from_table_id = oiiqbt_from.process_table_builder_tables_id
					INNER JOIN #old_ixp_import_query_builder_tables oiiqbt_to ON iiqbr.to_table_id = oiiqbt_to.process_table_builder_tables_id
					
					INSERT INTO ixp_custom_import_mapping (ixp_rules_id, dest_table_id, destination_column, source_table_id, source_column, filter, default_value)
					SELECT @ixp_new_rule_id,
						   oqbit.builder_import_tables,
						   icim.destination_column,
						   oiiqbt.builder_tables_id,
						   icim.source_column,
						   icim.filter,
						   icim.default_value
					FROM ' + @ixp_custom_import_mapping + ' icim
					INNER JOIN #old_ixp_import_query_builder_tables oiiqbt ON icim.source_table_id = oiiqbt.process_table_builder_tables_id
					INNER JOIN #old_query_builder_import_tables oqbit ON icim.dest_table_id = oqbit.process_table_builder_import_tables
				
					INSERT INTO ixp_import_where_clause (rules_id, table_id, ixp_import_where_clause, repeat_number)
					SELECT @ixp_new_rule_id, iiwc.[table_id], NULLIF(iiwc.[ixp_import_where_clause],''''), ISNULL(iiwc.repeat_number, 0) FROM ' + @ixp_import_where_clause + ' iiwc
					INNER JOIN ' + @ixp_export_tables + ' iet ON iet.ixp_rules_id = iiwc.rules_id 
					
					INSERT INTO #rules_id (rules_id) select @ixp_new_rule_id
					
					UPDATE ipx_privileges SET import_export_id = @ixp_new_rule_id WHERE import_export_id = @old_rules_id
					'
					
		--PRINT(@sql1)
		--PRINT(@sql2)
		EXEC(@sql1 + @sql2 + @sql3)	
		--return 

		DECLARE @new_rules_id INT
		SELECT @new_rules_id = rules_id FROM #rules_id
					
		IF @import_export_flag = 'i' AND @run_rules = 'y'
		BEGIN
			SET @sql = 'spa_ixp_rules ''r'', ''' + @process_id + ''',''' + CAST(@new_rules_id AS NVARCHAR(20)) + ''', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ' + ISNULL('''' + @server_path + '''', 'NULL') + ''
			SET @job_name = 'ImportData_' + dbo.FNAGetNewID()
			--PRINT(ISNULL(@sql, 'isnull'))
			EXEC spa_run_sp_as_job @job_name,  @sql, 'ImportData', @user_name
		END			
			
		IF @import_export_flag = 'e' AND @run_rules = 'y'
		BEGIN
			SET @sql = 'spa_ixp_rules ''m'', ''' + @process_id + ''',''' + CAST(@new_rules_id AS NVARCHAR(20)) + ''', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL'
			SET @job_name = 'ExportData_' + @process_id
			
			EXEC spa_run_sp_as_job @job_name,  @sql, 'ExportData', @user_name
		END		
			
		IF @run_rules = 'n' 
		BEGIN
			EXEC('DROP TABLE ' + @ixp_export_relation)
			EXEC('DROP TABLE ' + @ixp_import_where_clause)
			EXEC('DROP TABLE ' + @ixp_import_relation)			
			EXEC('DROP TABLE ' + @ixp_import_data_source)
			EXEC('DROP TABLE ' + @ixp_import_data_mapping)
			EXEC('DROP TABLE ' + @ixp_export_data_source)
			EXEC('DROP TABLE ' + @ixp_data_mapping)
			EXEC('DROP TABLE ' + @ixp_export_tables)
			EXEC('DROP TABLE ' + @ixp_rules)
		END
		
		EXEC spa_ErrorHandler 0
			, 'Import/Export FX'
			, 'spa_ixp_rules'
			, 'Success' 
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	   
		SET @DESC = N'Fail to insert Data ( Error Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'Import/Export FX'
		   , 'spa_ixp_rules'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END
ELSE IF @flag = 'q' OR @flag = 'r' OR @flag = 't'
BEGIN

	BEGIN TRY
		DECLARE @as_of_date DATETIME 
		DECLARE @idoc INT

		DECLARE @download_date DATETIME
		DECLARE @downloaded_file_name NVARCHAR(1000)
		DECLARE @year NVARCHAR(4)
		DECLARE @month NVARCHAR(2) 

		DECLARE @data_source_alias NVARCHAR(50)
		DECLARE @insert_process_table NVARCHAR(300)
				, @dest_column_lists NVARCHAR(MAX)
				, @source_column_lists NVARCHAR(MAX)
				, @grouping_columns NVARCHAR(MAX)
				, @temp_process_table NVARCHAR(300)				
				, @table_ids NVARCHAR(MAX)
				, @file_full_path NVARCHAR(2000)
				, @folder_loaction NVARCHAR(2000)
				, @template_file_path NVARCHAR(2000)
				, @connection_string NVARCHAR(MAX)
				, @delimiter NVARCHAR(10) 
				, @trigger_output INT
				, @source_system_id NVARCHAR(10)
				, @datasource_alias NVARCHAR(100)
				, @join_statement NVARCHAR(MAX)
				, @generic_flag NCHAR(1)
				, @relation_type INT
				, @relation_alias NVARCHAR(100)
				, @relation_delimiter NVARCHAR(20)
				, @relation_join_clause NVARCHAR(MAX)
				, @relation_excel_sheet NVARCHAR(100)
				, @ixp_repeat_number INT
				, @is_datasource_customized NCHAR(20) 
				, @customizing_query NVARCHAR(MAX)
				, @is_header_less NCHAR(1)
				, @column_number INT
				, @is_custom_import NCHAR(1)
				, @command_lines NVARCHAR(MAX)
				, @custom_table NVARCHAR(500)
				, @final_custom_table NVARCHAR(600)
				, @use_customization NCHAR(1)
				, @data_source_id INT
				, @ssis_package INT
				, @use_parameter NCHAR(1)	
				, @soap_table_id INT	
				, @count_tables INT
		
	--TODO remove this logic once previous step to insert in this table is removed from front end.
--IF @data_source_id IN (21400)
--begin
--	SET @sql='TRUNCATE TABLE ' + @run_table
--	EXEC (@sql)	--data is later populated.
--END
	IF OBJECT_ID('tempdb..#temp_parameter') IS NOT NULL
			DROP TABLE #temp_parameter

		CREATE TABLE #temp_parameter(
			[name] NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			[value] NVARCHAR(500) COLLATE DATABASE_DEFAULT
		)

		IF NOT EXISTS (
		       SELECT 1
		       FROM   dbo.SplitCommaSeperatedValues(@ixp_rules_id) scsv
		       INNER JOIN ixp_rules ir ON  scsv.item = ir.ixp_rules_id
		   )
		BEGIN
			IF @flag = 'q'
			BEGIN
				EXEC spa_ErrorHandler -1, 'Import/Export FX', 'spa_ixp_rules', 'Error', 'Rule not found.', ''
				RETURN
			END	    
		END
		
		IF CURSOR_STATUS('global','rules_cursor') > = -1
		BEGIN
			DEALLOCATE rules_cursor
		END
		
		DECLARE rules_cursor CURSOR FOR
		SELECT scsv.item, ir.ixp_rules_name
		FROM   dbo.SplitCommaSeperatedValues(@ixp_rules_id) scsv
		INNER JOIN ixp_rules ir ON scsv.item = ir.ixp_rules_id
		
		OPEN rules_cursor
		FETCH NEXT FROM rules_cursor
		INTO @rules_id, @rules_names
		WHILE @@FETCH_STATUS = 0
		BEGIN
				
			IF @source = '21406' AND ISNULL(@lse_import_status,'') <>'Success'		--LSE
			BEGIN 
				EXEC spa_ixp_rules @flag = 'l',@server_path = @server_path,@run_table = @run_table
			END
		
			INSERT import_data_files_audit (dir_path, imp_file_name, as_of_date, STATUS, elapsed_time, process_id, create_user, create_ts)
			VALUES (
				'Rules:' + @rules_names,
				'Data Import',
				GETDATE(),
				's',
				0,
				@process_id,
				@user_name,
				GETDATE()
			)
		
			SET @table_ids = NULL
			
			IF OBJECT_ID('tempdb..#relations') IS NOT NULL
				DROP TABLE #relations
			IF OBJECT_ID('tempdb..#tables') IS NOT NULL
				DROP TABLE #tables
			IF OBJECT_ID('tempdb..#temp_ixp_rules') IS NOT NULL
				DROP TABLE #temp_ixp_rules
			IF OBJECT_ID('tempdb..#ixp_import_data_source') IS NOT NULL
				DROP TABLE #ixp_import_data_source
			IF OBJECT_ID('tempdb..#ixp_import_data_mapping') IS NOT NULL
				DROP TABLE #ixp_import_data_mapping
			IF OBJECT_ID('tempdb..#ixp_export_tables_import') IS NOT NULL
				DROP TABLE #ixp_export_tables_import
				
			SELECT * INTO #temp_ixp_rules FROM ixp_rules WHERE 1 = 2
			SELECT * INTO #ixp_import_data_source FROM ixp_import_data_source WHERE 1 = 2
			SELECT * INTO #ixp_import_data_mapping FROM ixp_import_data_mapping WHERE 1 = 2 
			SELECT * INTO #ixp_export_tables_import FROM ixp_export_tables WHERE 1 = 2

			SET @sql = 'SET IDENTITY_INSERT #temp_ixp_rules ON
						INSERT INTO #temp_ixp_rules (ixp_rules_id, ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, ixp_rule_hash)
						SELECT ixp_rules_id, ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, ixp_rule_hash
						FROM ' + CASE WHEN @flag = 'q' THEN @ixp_rules ELSE 'ixp_rules' END + '
						WHERE ixp_rules_id = ' + CAST(@rules_id AS NVARCHAR(20)) + '
						SET IDENTITY_INSERT #temp_ixp_rules OFF'
			--PRINT(@sql)
			EXEC(@sql)
			
			SET @sql = 'SET IDENTITY_INSERT #ixp_import_data_source ON
						INSERT INTO #ixp_import_data_source (ixp_import_data_source_id, rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import,ssis_package,use_parameter,clr_function_id,enable_email_import,send_email_import_reply, file_transfer_endpoint_id, remote_directory)
						SELECT ixp_import_data_source_id, rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import,ssis_package,use_parameter,clr_function_id,enable_email_import,send_email_import_reply, file_transfer_endpoint_id, remote_directory
						FROM ' + CASE WHEN @flag = 'q' THEN @ixp_import_data_source ELSE 'ixp_import_data_source' END + '
						WHERE rules_id = ' + CAST(@rules_id AS NVARCHAR(20)) + '
						SET IDENTITY_INSERT #ixp_import_data_source OFF'
			--PRINT(@sql)
			EXEC(@sql)
			
			SET @sql = 'SET IDENTITY_INSERT #ixp_import_data_mapping ON
						INSERT INTO #ixp_import_data_mapping (ixp_import_data_mapping_id, ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause,udf_field_id)
						SELECT ixp_import_data_mapping_id, ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause,udf_field_id
						FROM ' + CASE WHEN @flag = 'q' THEN @ixp_import_data_mapping ELSE 'ixp_import_data_mapping' END + '
						WHERE ixp_rules_id = ' + CAST(@rules_id AS NVARCHAR(20)) + '
						SET IDENTITY_INSERT #ixp_import_data_mapping OFF'
			--PRINT(@sql)
			EXEC(@sql)
		
			SET @sql = 'SET IDENTITY_INSERT #ixp_export_tables_import ON
						INSERT INTO #ixp_export_tables_import (ixp_export_tables_id, ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number)
						SELECT ixp_export_tables_id, ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number 
						FROM ' + CASE WHEN @flag = 'q' THEN @ixp_export_tables ELSE 'ixp_export_tables' END + '
						WHERE ixp_rules_id = ' + CAST(@rules_id AS NVARCHAR(20)) + '
						SET IDENTITY_INSERT #ixp_export_tables_import OFF'
			--PRINT(@sql)	
			EXEC(@sql)
			CREATE TABLE #relations (rules_id INT, ixp_relation_alias NVARCHAR(20) COLLATE DATABASE_DEFAULT, joining_table NVARCHAR(2000) COLLATE DATABASE_DEFAULT, join_clause NVARCHAR(MAX) COLLATE DATABASE_DEFAULT, relation_id INT, relation_source_type INT, delimiter NVARCHAR(20) COLLATE DATABASE_DEFAULT, excel_sheet NVARCHAR(100) COLLATE DATABASE_DEFAULT)
			CREATE TABLE #tables (table_id INT, repeat_number INT)
				
			SET @sql = 'INSERT INTO #relations(rules_id, ixp_relation_alias, joining_table, join_clause, relation_id, relation_source_type, delimiter, excel_sheet)
						SELECT iir.ixp_rules_id,
							   iir.ixp_relation_alias,
							   CASE 
									WHEN iir.relation_source_type = 21401 THEN iir.connection_string
									ELSE iir.relation_location
							   END [joining_table],
							   iir.join_clause,
							   iir.ixp_import_relation_id,
							   iir.relation_source_type,
							   iir.delimiter,
							   iir.excel_sheet
						FROM ' + CASE WHEN @flag = 'q' THEN @ixp_import_relation ELSE 'ixp_import_relation ' END + ' iir
						WHERE iir.ixp_rules_id = ' + CAST(@rules_id AS NVARCHAR(10))
			--PRINT(@sql)
			EXEC(@sql)		
			

			IF OBJECT_ID(N'tempdb..#ixp_columns') IS NOT NULL
			DROP TABLE #ixp_columns

			SELECT ic.ixp_columns_id
				, ic.ixp_table_id
				, ic.ixp_columns_name
				, ic.column_datatype
				, ic.is_major
				, ic.header_detail
				, ic.seq
				, ic.datatype
				, is_required
			INTO #ixp_columns
			FROM ixp_rules ir
			INNER JOIN ixp_import_data_mapping iidm ON iidm.ixp_rules_id = ir.ixp_rules_id
			INNER JOIN ixp_tables it ON iidm.dest_table_id = it.ixp_tables_id
			INNER JOIN ixp_columns ic ON it.ixp_tables_id = ic.ixp_table_id AND ic.ixp_columns_id = iidm.dest_column
			WHERE ir.ixp_rules_id = @ixp_rules_id

			SELECT @trigger_before_import = ir.before_insert_trigger,
				   @trigger_after_import = ir.after_insert_trigger
			FROM   #temp_ixp_rules ir	
			 
			SELECT @folder_loaction = iids.folder_location,
				   @template_file_path = IIF(@enable_ftp = 1, NULL, iids.data_source_location),
				   @connection_string = iids.connection_string,
				   @delimiter = iids.delimiter,
				   @source_system_id = iids.source_system_id,
				   @datasource_alias = iids.data_source_alias,
				   @is_datasource_customized = CASE WHEN iids.is_customized = '1' OR iids.is_customized = 'y' THEN 'y' ELSE 'n' END,
				   @customizing_query = iids.customizing_query,
				   @is_header_less = iids.is_header_less,
				   @column_number = iids.no_of_columns,
				   @is_custom_import = custom_import,
				   @data_source_id = NULLIF(@source, 0),
				   @ssis_package = ssis_package,
				   @use_parameter = use_parameter,
				   @clr_function_id = NULLIF(iids.clr_function_id, 0),
				   @file_transfer_endpoint_id = IIF(@enable_ftp = 0, NULL, NULLIF(iids.file_transfer_endpoint_id, '')),
				   @ftp_remote_directory = IIF(@enable_ftp = 0, NULL, NULLIF(iids.remote_directory, ''))
			FROM #ixp_import_data_source iids	
			
   			-- SELECT @clr_function_name = ixp_clr_functions_name FROM ixp_clr_functions WHERE ixp_clr_functions_id = @clr_function_id

			--IF ISNULL(@clr_function_name, '') = 'AFM MIFID Reporting' -- Implemented custom FTP download for AFM Feedback Import (CLR function)
			--	SET @is_custom_ftp = 1

			INSERT INTO #tables (table_id, repeat_number)
			SELECT table_id, repeat_number
			 FROM 
				(SELECT iet_dep.dependent_table_id table_id,
				        it_dep.ixp_tables_name table_name,
				        it_dep.ixp_tables_description table_desc,
				        iet_dep.dependent_table_order seq_num1,
				        -1 seq_num2,
				        ISNULL(idm.repeat_number, 0) repeat_number,
				        ROW_NUMBER() OVER(ORDER BY iet_dep.dependent_table_order) row_num
				 FROM #ixp_export_tables_import iet_dep
		         INNER JOIN (SELECT DISTINCT dest_table_id, repeat_number FROM #ixp_import_data_mapping) idm ON  idm.dest_table_id = iet_dep.dependent_table_id
		         INNER JOIN ixp_tables it_dep ON  iet_dep.dependent_table_id = it_dep.ixp_tables_id
				 UNION ALL
				 SELECT DISTINCT iet_tables.table_id,
				       it_tables.ixp_tables_name table_name,
				       it_tables.ixp_tables_description table_desc,
				       999999 seq_num1,
				       iet_tables.sequence_number,
				       ISNULL(idm.repeat_number, 0) repeat_number,
				       ROW_NUMBER() OVER(ORDER BY iet_tables.sequence_number) row_num
				 FROM #ixp_export_tables_import iet_tables
		         INNER JOIN ixp_tables it_tables ON  iet_tables.table_id = it_tables.ixp_tables_id
		         INNER JOIN (SELECT DISTINCT dest_table_id, ixp_rules_id, repeat_number FROM #ixp_import_data_mapping) idm
		            ON  idm.dest_table_id = iet_tables.table_id
		            AND idm.ixp_rules_id = iet_tables.ixp_rules_id
				WHERE iet_tables.dependent_table_id IS NULL
				) a 
			 ORDER BY a.seq_num1, a.seq_num2
			
			SELECT @count_tables = COUNT(*) FROM #tables
			
			SET @temp_process_table = 'adiha_process.dbo.temp_import_data_table_' + @process_id
			DECLARE @reimport_data NVARCHAR(500) = dbo.FNAProcessTableName('reimport_data', @datasource_alias, @process_id)
			 
			--SET @custom_table = 'adiha_process.dbo.custom_import_table_' + @user_name  + '_' + @process_id
			SET @custom_table = dbo.FNAProcessTableName('custom_import_table', @user_name, @process_id)
			SET @generic_flag = CASE WHEN @flag = 'q' THEN 'b' ELSE 'a' END
			
			DECLARE @ssis_table TABLE (error_code NVARCHAR(20), module NVARCHAR(30), area NVARCHAR(500), err_status NVARCHAR(20), msg NVARCHAR(200), table_name NVARCHAR(500))
			
			IF OBJECT_ID('tempdb..#temp_soap_table_name') IS NOT NULL
				DROP TABLE #temp_soap_table_name
			CREATE TABLE #temp_soap_table_name (table_name NVARCHAR(600) COLLATE DATABASE_DEFAULT)
			
			IF OBJECT_ID('tempdb..#temp_files_list') IS NOT NULL
				DROP TABLE #temp_files_list
						
			CREATE TABLE #temp_files_list (files_names NVARCHAR(MAX) COLLATE DATABASE_DEFAULT)
					
			IF @flag IN ('q', 'r')
			BEGIN
			
				SET @use_customization = 'n'
				
				EXEC('IF OBJECT_ID(''' + @temp_process_table + ''') IS NOT NULL
					   BEGIN
	       					DROP TABLE ' + @temp_process_table + '
					   END'
				)		
					
				IF @file_transfer_endpoint_id IS NOT NULL --AND @is_custom_ftp = 0 
				BEGIN
					/*
					By default files are downloaded from FTP server to temp_Note folder. To handle session, session sepecific folder is created to dump downloaded files.
					
					*/
					SELECT @folder_loaction = document_path + '\temp_Note\ftp_documents_' + @process_id FROM connection_string

					DECLARE @msg NVARCHAR(max)
					EXEC [spa_create_folder] @folder_loaction, @msg
					
					EXEC dbo.spa_download_file_from_ftp  @file_transfer_endpoint_id = @file_transfer_endpoint_id, @local_destination = @folder_loaction, @source_filename= '', @remote_directory= @ftp_remote_directory, @extension= '', @result= @msg OUTPUT


					IF @msg <> 'success'
					BEGIN
						SET @desc = N'Import process failed. <font color="red"> Failed to download file from (S)FTP.</font><br /> (ERRORS found)'
						SET @job_name = 'ImportData_' + @process_id
						EXEC  spa_message_board 'u', @user_name,NULL, 'ImportData', @desc, '', '', 'e' , @job_name, NULL, @process_id, '', '', '', 'y'
						RETURN
				END
				END
					
				IF ((@folder_loaction IS NOT NULL AND @folder_loaction <> '') AND @data_source_id NOT IN (21407, 21401)) OR @data_source_id = 21409
				BEGIN
					IF @data_source_id = 21409
					BEGIN
						IF OBJECT_ID('tempdb..#ixp_email_notes_list') IS NOT NULL
							DROP TABLE #ixp_email_notes_list
						CREATE TABLE #ixp_email_notes_list (notes_id INT)

						IF @email_notes_id IS NULL
						BEGIN
							SET @data_source_result_table = 'adiha_process.dbo.ixp_import_filter_' + dbo.FNAGetNewID() + '_result'

							SELECT	@data_source_view_sql = REPLACE(REPLACE(ds.tsql,'--[__batch_report__]', 'INTO ' + @data_source_result_table),'@ixp_rules_id',@ixp_rules_id)
							FROM data_source ds
							WHERE ds.category = 106504 AND ds.name = 21409
						
						
							IF @data_source_view_sql IS NOT NULL
							BEGIN
								EXEC(@data_source_view_sql)
								IF OBJECT_ID(@data_source_result_table) IS NOT NULL
								BEGIN
									EXEC('INSERT INTO #ixp_email_notes_list (notes_id) SELECT notes_id FROM ' +  @data_source_result_table)
								END
							END
						END
						ELSE IF @email_notes_id IS NOT NULL
						BEGIN
							INSERT INTO #ixp_email_notes_list (notes_id) SELECT @email_notes_id
						END
											
						INSERT INTO #temp_files_list (files_names)
						SELECT cs.document_path + '\' + REPLACE(attachment_file_path,'/','\') 
						FROM #ixp_email_notes_list tmp
						INNER JOIN attachment_detail_info adi ON tmp.notes_id = adi.email_id
						OUTER APPLY (SELECT document_path FROM connection_string) cs 

						UPDATE adi
						SET adi.is_imported = 'y' 
						FROM attachment_detail_info adi
						INNER JOIN #ixp_email_notes_list tmp ON tmp.notes_id = adi.email_id

					END 
					ELSE IF @data_source_id NOT IN (21407, 21401)
					BEGIN
						SET @data_source_result_table = 'adiha_process.dbo.ixp_import_filter_' + dbo.FNAGetNewID() + '_result'

						SELECT	@data_source_view_sql = REPLACE(REPLACE(REPLACE(REPLACE(ds.tsql,'--[__batch_report__]', 'INTO ' + @data_source_result_table),'@ixp_rules_id',@ixp_rules_id),'@folder_location',@folder_loaction), '@is_ftp', ISNULL(@enable_ftp, ''))
						FROM [data_source] ds
						WHERE ds.category = 106504 AND ds.[name] = '21400'
						
						IF @data_source_view_sql IS NOT NULL
						BEGIN
							EXEC(@data_source_view_sql)
						END

						IF OBJECT_ID(@data_source_result_table) IS NOT NULL
						BEGIN
							EXEC('INSERT INTO #temp_files_list (files_names) SELECT [filename] FROM ' +  @data_source_result_table)
						END
						ELSE
						BEGIN
							INSERT INTO #temp_files_list (files_names)
							SELECT ff.[filename] FROM dbo.FNAListFiles(@folder_loaction, '*.*', 'n') ff
						END
					END
							
					IF NOT EXISTS(SELECT 1 FROM #temp_files_list)
					BEGIN
						SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_name+''''
		
						SET @desc = N'Import process failed. <font color="red"> File not found.</font><br /> (ERRORS found)'										
						INSERT INTO source_system_data_import_status (process_id, code, [module], [source], [TYPE], [description], recommendation)
						SELECT @process_id,
								'Error',
								'Import Data',
								@rules_names,
								'Data Error',
								@desc,
								'Please check your ' + 
								CASE 
									WHEN @data_source_id IN (21400, 21402) THEN 'file.' 					
									ELSE 'data' + CASE WHEN @data_source_id = 21401 THEN ' source' ELSE '' END + '.'
								END

		
						--EXEC  spa_message_board 'u', @user_name,NULL, 'ImportData', @desc, '', '', 'e' , @job_name, NULL, @process_id, '', '', '', 'y'
						EXEC spa_ixp_notification @process_id, @ixp_rules_id, @desc, @job_name	
						
						EXEC  spa_message_board 'u', @user_name,NULL, 'ImportData', @desc, '', '', 'e' , @job_name, NULL, @process_id, '', '', '', 'y'
						RETURN
					END
				END			
	
				--Process to dump in first stg table starts
				-- Common logic starts
				IF @data_source_id IN (21400,21402,21405,21409)  -- Flat file, Excel,XML
				BEGIN
				
					EXEC spa_print 'Batch import process. Flag ''c'' used to dump source data to first stg table for data source Flat file, Excel,XML'
					IF NULLIF(@folder_loaction, '') IS NOT NULL
					BEGIN
						DECLARE @temp_file_table NVARCHAR(300)
						
						SET @final_custom_table = dbo.FNAProcessTableName('final_custom_table', @user_name, @process_id) 												
						SET @temp_file_table = dbo.FNAProcessTableName('temp_file_table', @user_name, @process_id) 						
						
						SET @sql = 'IF OBJECT_ID(''' + @final_custom_table + ''') IS NOT NULL
								    BEGIN
	       								DROP TABLE ' + @final_custom_table + '
								    END
									
									IF OBJECT_ID(''' + @temp_file_table + ''') IS NOT NULL
								    BEGIN
	       								DROP TABLE ' + @temp_file_table + '
								    END
									'
						EXEC(@sql)

						IF @flag = 'r'
							SET @source_delimiter = ISNULL(@delimiter,@source_delimiter)

						IF (SELECT CURSOR_STATUS('global','files_cursor')) >=0 
						BEGIN
						DEALLOCATE files_cursor
						END

						DECLARE files_cursor CURSOR FOR
						SELECT files_names
						FROM  #temp_files_list
						
						OPEN files_cursor
						FETCH NEXT FROM files_cursor
						INTO @file_full_path 
						WHILE @@FETCH_STATUS = 0
						BEGIN							
							EXEC spa_ixp_rules 'c' , @process_id
								, @ixp_rules_id
								, @ixp_rules_name
								, @individual_script_per_object
								, @limit_rows_to
								, @before_insert_triger
								, @after_insert_triger
								, @import_export_flag
								, @run_rules
								, @ixp_owner
								, @ixp_category
								, @is_system_import
								, @temp_file_table	--  stg table for each file
								, @run_with_custom_enable
								, @source
								, @file_full_path
								, @parameter_xml
								, @active_flag
								, @show_delete_msg
								, @excel_sheet_name
								, @run_in_debug_mode
								, @batch_process_id
								, @batch_report_param
								, @rule_name
								, @source_delimiter
								, @source_with_header
							
							SET @sql = 'IF COL_LENGTH(''' + @temp_file_table + ''', ''import_file_name'') IS NULL
										BEGIN
											ALTER TABLE ' + @temp_file_table + ' ADD import_file_name NVARCHAR(2000)
										END'					
							EXEC(@sql)
							
							SET @sql = 'UPDATE ' + @temp_file_table + ' SET import_file_name = ''' + @file_full_path + '''' 
							--PRINT(@sql)					
							EXEC(@sql)
							
							IF NOT EXISTS(SELECT 1 FROM import_process_info 
								WHERE process_id = @process_id AND ixp_rule_id = @ixp_rules_id AND import_file_name = @file_full_path)
							BEGIN
								INSERT INTO import_process_info(process_id, ixp_rule_id,import_file_name)
								SELECT @process_id, @ixp_rules_id, @file_full_path
							END
													
							IF @is_datasource_customized = 'y'
							BEGIN
								EXEC ('IF OBJECT_ID(''' + @custom_table + ''') IS NOT NULL
									   BEGIN
				       						DROP TABLE ' + @custom_table + '
									   END'
								)									
								
								SET @customizing_query = REPLACE(@customizing_query, '[temp_process_table]', @temp_file_table)
								SET @customizing_query = REPLACE(@customizing_query, '--[__custom_table__]',  ' INTO ' + @custom_table)
								SET @customizing_query = REPLACE(@customizing_query, '[__custom_table__]',  @custom_table)
								
								--PRINT(@customizing_query)
								EXEC(@customizing_query)								
																
								SET @sql = 'IF COL_LENGTH(''' + @custom_table + ''', ''import_file_name'') IS NULL
											BEGIN
												ALTER TABLE ' + @custom_table + ' ADD import_file_name NVARCHAR(2000)
											END'					
								EXEC(@sql)
								
								SET @sql = 'UPDATE ' + @custom_table + ' SET import_file_name = ''' + @file_full_path + '''' 					
								EXEC(@sql)
								
								EXEC ('IF OBJECT_ID(''' + @final_custom_table + ''') IS NULL
									   BEGIN
	       									SELECT * INTO ' + @final_custom_table + ' FROM ' + @custom_table + ' WHERE 1 = 2
									   END'
								)
															
								EXEC('INSERT INTO ' + @final_custom_table + ' SELECT * FROM ' + @custom_table)
								EXEC('DELETE FROM ' + @temp_file_table)
							END
							ELSE 
							BEGIN
								
								EXEC ('IF OBJECT_ID(''' + @temp_process_table + ''') IS NOT NULL
										BEGIN
				       						EXEC(''INSERT INTO ' + @temp_process_table + ' SELECT * FROM ' + @temp_file_table + ''')
									   END
									   ELSE 
									   BEGIN
											EXEC (''SELECT * INTO ' + @temp_process_table + ' FROM ' + @temp_file_table + ''')	
									   END
									   '
								)
							
								--PRINT('INSERT INTO ' + @temp_process_table + ' SELECT * FROM ' + @temp_file_table)
								--EXEC('INSERT INTO ' + @temp_process_table + ' SELECT * FROM ' + @temp_file_table)
								--EXEC('DELETE FROM ' + @temp_file_table)
							END	
							
							FETCH NEXT FROM files_cursor
							INTO @file_full_path
						END
						CLOSE files_cursor
						DEALLOCATE files_cursor
						
						IF @is_datasource_customized = 'y'
						BEGIN
							SET @temp_process_table = @final_custom_table		
							--PRINT('Final Custom Table - ' + @final_custom_table)
						END
					END
					ELSE
					BEGIN
						EXEC spa_ixp_rules 'c' , @process_id
							, @ixp_rules_id
							, @ixp_rules_name
							, @individual_script_per_object
							, @limit_rows_to
							, @before_insert_triger
							, @after_insert_triger
							, @import_export_flag
							, @run_rules
							, @ixp_owner
							, @ixp_category
							, @is_system_import
							, @temp_process_table
							, @run_with_custom_enable
							, @source
							, @template_file_path
							, @parameter_xml
							, @active_flag
							, @show_delete_msg
							, @excel_sheet_name
							, @run_in_debug_mode
							, @batch_process_id
							, @batch_report_param
							, @rule_name
							, @source_delimiter
							, @source_with_header

					
					SET @sql = 'IF COL_LENGTH(''' + @temp_process_table + ''', ''import_file_name'') IS NULL
								BEGIN
									ALTER TABLE ' + @temp_process_table + ' ADD import_file_name NVARCHAR(2000)
								END'					
					EXEC(@sql)
							
					SET @sql = 'UPDATE ' + @temp_process_table + ' SET import_file_name = ''' + @template_file_path + '''' 
					
						IF NOT EXISTS(SELECT 1 FROM import_process_info 
									WHERE process_id = @process_id AND ixp_rule_id = @ixp_rules_id AND import_file_name = @template_file_path)
						BEGIN
							INSERT INTO import_process_info(process_id, ixp_rule_id,import_file_name)
							SELECT @process_id, @ixp_rules_id, @template_file_path
						END
								
						IF @is_datasource_customized = 'y'
							SET @use_customization = 'y'
					END
					
				END
				-- Common logic ends
				

				IF  @data_source_id = 21406	--LSE
				BEGIN 
					IF (@folder_loaction IS NOT NULL AND @folder_loaction <> '')
					BEGIN
						DECLARE @lse_full_path NVARCHAR(MAX)
						DECLARE @a NVARCHAR(100)
							EXEC spa_ixp_rules @flag = 'w',@run_table = @temp_process_table
									SET @sql = 'IF COL_LENGTH(''' + @temp_process_table + ''', ''import_file_name'') IS NULL
								BEGIN
									ALTER TABLE ' + @temp_process_table + ' ADD import_file_name NVARCHAR(2000) DEFAULT(''' + @template_file_path + ''')
								END'					
								EXEC(@sql)
						DECLARE lse_files_cursor CURSOR LOCAL FOR
							SELECT files_names
							FROM  #temp_files_list
							
							OPEN lse_files_cursor
							FETCH NEXT FROM lse_files_cursor
							INTO @lse_full_path 
							WHILE @@FETCH_STATUS = 0
							BEGIN							
								EXEC spa_import_from_lse @lse_full_path,@temp_process_table,@a OUTPUT					
								FETCH NEXT FROM lse_files_cursor INTO @lse_full_path
							END
							CLOSE lse_files_cursor
							DEALLOCATE lse_files_cursor
					END
				END
				ELSE IF @data_source_id = 21401	--Link Server
				BEGIN
					SET @sql = 'SELECT * INTO ' + @temp_process_table  + ' FROM ' + @connection_string
					--PRINT('Connection String based import -> ' + @sql)
					EXEC(@sql)
					
					SET @sql = 'ALTER TABLE ' + @temp_process_table + ' ADD import_file_name NVARCHAR(2000)'					
					EXEC(@sql)
										
					IF @is_datasource_customized = 'y'
							SET @use_customization = 'y'
				END	
				ELSE IF @data_source_id = 21403	--SSIS
				BEGIN
					INSERT INTO @ssis_table (error_code, module, area, err_status, msg, table_name)
					EXEC spa_ixp_run_ssis_package 'r', @ssis_package, @use_parameter, @process_id, @rules_id, @parameter_xml	

					IF EXISTS (SELECT 1 FROM @ssis_table WHERE error_code = 'Error')
					BEGIN
						IF @batch_process_id IS NULL
						BEGIN
							EXEC spa_ErrorHandler -1,
								 'Import/Export FX',
								 'spa_ixp_rules',
								 'Import Fail.',
								 'Package Execution Failed.',
								 ''
							RETURN
						END		
						ELSE
						BEGIN
							
							SET @desc = N'Import process failed <font color="red">(ERRORS found).</font> Package Execution Failed.'
							
							INSERT INTO source_system_data_import_status (process_id, code, [module], [source], [TYPE], [description], recommendation)
							SELECT @process_id,
									'Error',
									'Import Data',
									@rules_names,
									'Data Error',
									@desc,
									'Please check your ' + 
									CASE 
										WHEN @data_source_id IN (21400, 21402) THEN 'file.' 					
										ELSE 'data' + CASE WHEN @data_source_id = 21401 THEN ' source' ELSE '' END + '.'
									END


							--EXEC  spa_message_board 'u', @user_name,NULL, 'ImportData', @desc, '', '', 'e' , @job_name, NULL, @process_id, '', '', '', 'y'
							EXEC spa_ixp_notification @process_id, @ixp_rules_id, @desc, @job_name	
							RETURN
						END	
					END
					ELSE
					BEGIN
						SELECT @temp_process_table = table_name FROM @ssis_table
						SET @sql = 'IF COL_LENGTH(''' + @temp_process_table + ''', ''import_file_name'') IS NULL
									BEGIN
										ALTER TABLE ' + @temp_process_table + ' ADD import_file_name NVARCHAR(2000)
									END'					
						EXEC(@sql)
											
						IF @is_datasource_customized = 'y'
							SET @use_customization = 'y'
					END	
				END
				ELSE IF @data_source_id = 21404	--Web Service
				BEGIN
					DECLARE @temp_process_id NVARCHAR(200)
					SET @temp_process_table = dbo.FNAGetNewID()
					SELECT @soap_table_id = iet.table_id
					FROM ixp_export_tables iet
					WHERE iet.ixp_rules_id = @ixp_rules_id
					
					--PRINT('EXEC spa_import_table_template ''s'', ' + CAST(@soap_table_id AS NVARCHAR(10)) + ',''' +  @temp_process_table + ''', 0, ' + CAST(@rules_names AS NVARCHAR(60)) + '')
					
					INSERT INTO #temp_soap_table_name (table_name)
					EXEC spa_import_table_template 's', @soap_table_id, @temp_process_table, 0, @rules_names
					
					SELECT @temp_process_table = table_name FROM #temp_soap_table_name
					
					IF @temp_process_table IS NULL
					BEGIN
						IF @batch_process_id IS NULL
						BEGIN
							EXEC spa_ErrorHandler -1,
								 'Import/Export FX',
								 'spa_ixp_rules',
								 'Import Fail.',
								 'Failed to initialize web service.',
								 ''
							RETURN
						END		
						ELSE
						BEGIN
							SET @desc = N'Import process failed <font color="red">(ERRORS found).</font> Failed to initialize web service.'
							
							INSERT INTO source_system_data_import_status (process_id, code, [module], [source], [TYPE], [description], recommendation)
							SELECT @process_id,
									'Error',
									'Import Data',
									@rules_names,
									'Data Error',
									@desc,
									'Please check your ' + 
									CASE 
										WHEN @data_source_id IN (21400, 21402) THEN 'file.' 					
										ELSE 'data' + CASE WHEN @data_source_id = 21401 THEN ' source' ELSE '' END + '.'
									END


							--EXEC  spa_message_board 'u', @user_name,NULL, 'ImportData', @desc, '', '', 'e' , @job_name, NULL, @process_id, '', '', '', 'y'
							EXEC spa_ixp_notification @process_id, @ixp_rules_id, @desc, @job_name	
							RETURN
						END	
					END
					ELSE
					BEGIN						
						SET @sql = 'IF COL_LENGTH(''' + @temp_process_table + ''', ''import_file_name'') IS NULL
									BEGIN
										ALTER TABLE ' + @temp_process_table + ' ADD import_file_name NVARCHAR(2000)
									END'					
						EXEC(@sql)
											
						IF @is_datasource_customized = 'y'
							SET @use_customization = 'y'
					END	
				END
	           ELSE IF @data_source_id = 21407 --CLR FUNCTION
				BEGIN
					SET @parameter_xml = ISNULL(@parameter_xml, '')

					IF OBJECT_ID ('tempdb..#clr_import_status') IS NOT NULL
						DROP TABLE #clr_import_status
					
					CREATE TABLE #clr_import_status (
						[error_code] NVARCHAR(15) COLLATE DATABASE_DEFAULT,
						[module] NVARCHAR(255) COLLATE DATABASE_DEFAULT,
						[area] NVARCHAR(255) COLLATE DATABASE_DEFAULT,
						[status] NVARCHAR(255) COLLATE DATABASE_DEFAULT,
						[message] NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
						[supress] NVARCHAR(5) COLLATE DATABASE_DEFAULT,
						[process_table] NVARCHAR(1000) COLLATE DATABASE_DEFAULT

					)

					INSERT INTO #clr_import_status
					EXEC spa_ixp_call_clr_function  @parameter_xml, @ixp_rules_id, @process_id -- CLR spa
			
					SELECT @supress = [supress],
						   @response_message = [message],
						   @run_table = [process_table]
					FROM #clr_import_status

					IF @supress = 'True'
					BEGIN
						EXEC spa_ErrorHandler -1
									, 'Import/Export'
									, 'spa_ixp_rules'									
									, 'Error'
									, @response_message
									, 'Please Check/Refresh your message board.'

						RETURN
					END

					IF EXISTS(SELECT 1 FROM  clr_error_log WHERE process_id = @process_id)
					BEGIN
						
						EXEC spa_ErrorHandler -1
									, 'Import/Export'
									, 'spa_ixp_rules'									
									, 'Error'
									, 'Import process has been run and will complete shortly.'
									, 'Please Check/Refresh your message board.'

						
						SELECT @message = message FROM  clr_error_log WHERE process_id = @process_id

						RAISERROR (@message, -- Message text.
									16, -- Severity.
									1 -- State.
									);

					END		
					SET @temp_process_table = @run_table	
					
					SET @sql = 'IF COL_LENGTH(''' + @temp_process_table + ''', ''import_file_name'') IS NULL
								BEGIN
									ALTER TABLE ' + @temp_process_table + ' ADD import_file_name NVARCHAR(2000)
								END'					
					EXEC(@sql)
					IF @is_datasource_customized = 'y'
							SET @use_customization = 'y'
				END	
				
			END

			ELSE IF @flag = 't'
			BEGIN
			
				IF(NULLIF(@server_path,'') IS NOT NULL)
				BEGIN
					SELECT @full_file_path = document_path + '\temp_Note\' + @server_path FROM connection_string
					SELECT @chk_file_exists = dbo.FNAFileExists(@full_file_path)
				END
				ELSE 
				BEGIN 
					SET @chk_file_exists = 1 
				END
				
				IF @chk_file_exists = 0				
				BEGIN
					SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_name+''''
		
					SET @desc = N'<a target="_blank" href="' + @url + '">' 
									+ 'Import process failed. <font color="red"> File not found.</font><br />'
									+ ' (ERRORS found)'
									+ '.</a>'
					
					INSERT INTO source_system_data_import_status (process_id, code, [module], [source], [TYPE], [description], recommendation)
					SELECT @process_id,
							'Error',
							'Import Data',
							@rules_names,
							'Data Error',
							@desc,
							'Please check your ' + 
							CASE 
								WHEN @data_source_id IN (21400, 21402) THEN 'file.' 					
								ELSE 'data' + CASE WHEN @data_source_id = 21401 THEN ' source' ELSE '' END + '.'
							END

					--EXEC  spa_message_board 'u', @user_name,NULL, 'ImportData', @desc, '', '', 'e' , @job_name, NULL, @process_id, '', '', '', 'y'
					EXEC spa_ixp_notification @process_id, @ixp_rules_id, @desc, @job_name	
					RETURN
				END

				EXEC spa_print 'Flag c block starts here. Dump source data from ',@full_file_path,' to ',@run_table	
				
				DECLARE @first_stg_table NVARCHAR(200)
				SET @first_stg_table = ISNULL(@run_table,@temp_process_table)
				
				SET @use_customization = 'n'
				IF @source = 21403
				BEGIN
					SELECT @ssis_package = iids.ssis_package,
					       @use_parameter = IIF(ip.ixp_parameters_id IS NOT NULL, 'y', 'n')
					FROM   ixp_import_data_source iids
					LEFT JOIN ixp_parameters ip ON ip.ssis_package = iids.ssis_package
					WHERE  iids.rules_id = @rules_id
					
					INSERT INTO @ssis_table (error_code, module, area, err_status, msg, table_name)
					EXEC spa_ixp_run_ssis_package 'r', @ssis_package, @use_parameter, @process_id, @rules_id, @parameter_xml	

					IF EXISTS (SELECT 1 FROM @ssis_table WHERE error_code = 'Error')
					BEGIN
						IF @batch_process_id IS NULL
						BEGIN
							EXEC spa_ErrorHandler -1,
								 'Import/Export FX',
								 'spa_ixp_rules',
								 'Import Fail.',
								 'Package Execution Failed.',
								 ''
							RETURN
						END		
						ELSE
						BEGIN
							SET @desc = N'Import process failed <font color="red">(ERRORS found).</font> Package Execution Failed.'
							
							INSERT INTO source_system_data_import_status (process_id, code, [module], [source], [TYPE], [description], recommendation)
							SELECT @process_id,
									'Error',
									'Import Data',
									@rules_names,
									'Data Error',
									@desc,
									'Please check your ' + 
									CASE 
										WHEN @data_source_id IN (21400, 21402) THEN 'file.' 					
										ELSE 'data' + CASE WHEN @data_source_id = 21401 THEN ' source' ELSE '' END + '.'
									END


							--EXEC  spa_message_board 'u', @user_name,NULL, 'ImportData', @desc, '', '', 'e' , @job_name, NULL, @process_id, '', '', '', 'y'
							EXEC spa_ixp_notification @process_id, @ixp_rules_id, @desc, @job_name	
							RETURN
						END	
					END
					ELSE
					BEGIN
						SELECT @temp_process_table = table_name FROM @ssis_table
							
						IF @is_datasource_customized = 'y'
							SET @use_customization = 'y'
					END	
				END
				ELSE IF @source = 21404 AND NULLIF(@server_path,'') IS NULL
				BEGIN
					SELECT @soap_table_id = iet.table_id
					FROM ixp_export_tables iet
					WHERE iet.ixp_rules_id = @ixp_rules_id
					
					INSERT INTO #temp_soap_table_name (table_name)
					EXEC spa_import_table_template 's', @soap_table_id, @process_id, 0, @rules_names
					
					SELECT @temp_process_table = table_name FROM #temp_soap_table_name
					
					IF @temp_process_table IS NULL
					BEGIN
						IF @batch_process_id IS NULL
						BEGIN
							EXEC spa_ErrorHandler -1,
								 'Import/Export FX',
								 'spa_ixp_rules',
								 'Import Fail.',
								 'Failed to initialize web service.',
								 ''
							RETURN
						END		
						ELSE
						BEGIN
							SET @desc = N'Import process failed <font color="red">(ERRORS found).</font> Failed to initialize web service.'
							
							INSERT INTO source_system_data_import_status (process_id, code, [module], [source], [TYPE], [description], recommendation)
							SELECT @process_id,
									'Error',
									'Import Data',
									@rules_names,
									'Data Error',
									@desc,
									'Please check your ' + 
									CASE 
										WHEN @data_source_id IN (21400, 21402) THEN 'file.' 					
										ELSE 'data' + CASE WHEN @data_source_id = 21401 THEN ' source' ELSE '' END + '.'
									END


							--EXEC  spa_message_board 'u', @user_name,NULL, 'ImportData', @desc, '', '', 'e' , @job_name, NULL, @process_id, '', '', '', 'y'
							EXEC spa_ixp_notification @process_id, @ixp_rules_id, @desc, @job_name	
							RETURN
						END	
					END
					ELSE
					BEGIN						
						SET @sql = 'IF COL_LENGTH(''' + @temp_process_table + ''', ''import_file_name'') IS NULL
									BEGIN
										ALTER TABLE ' + @temp_process_table + ' ADD import_file_name NVARCHAR(2000)
									END'					
						EXEC(@sql)
											
						IF @is_datasource_customized = 'y'
							SET @use_customization = 'y'
					END	
				END	
				ELSE IF @source IN (21400,21402,21405,21404,21401) AND NULLIF(@server_path,'') IS NOT NULL  -- Flat file, Excel,XML,Web Service, Link Server
					BEGIN
					EXEC spa_print 'Flag ''c'' used to dump source data to first stg table for data source Flat file, Excel,XML'
					
					IF @data_source_id = 21401
					BEGIN
						DECLARE @ls_name NVARCHAR(100)			
						DECLARE @clm1 NVARCHAR(100)
						DECLARE @clm2 NVARCHAR(100)
						DECLARE @clm3 NVARCHAR(100)
						DECLARE @clm4 NVARCHAR(100)

						SELECT @ls_name = connection_string FROM ixp_import_data_source WHERE rules_id = @ixp_rules_id

						SELECT @clm1 = clm1,
							   @clm2 = clm2,
							   @clm3 = clm3,
							   @clm4 = clm4
						FROM [dbo].[FNASplitAndTranspose](@ls_name,'.')

						IF EXISTS ( SELECT 1 FROM sys.servers
									WHERE is_linked = 1 
										AND [name] = @clm1
						)
						BEGIN
							BEGIN TRY
								EXEC('SELECT top 1 1 FROM ' + @ls_name) --distributed query ... linkedserver.<database>.<schema>.<object>             								

							END TRY
							BEGIN CATCH
								IF ERROR_NUMBER() = 10060
									SET @DESC = N'Import process failed <font color="red">(ERRORS found).</font> Linked Server connection attempt failed.'
								ELSE
									SET @DESC = N'Import process failed <font color="red">(ERRORS found).</font>.Data source does not exist or user does not have permission.'
							END CATCH
						END
						ELSE
							SET @DESC = N'Import process failed <font color="red">(ERRORS found).</font> Link Server is not configured.'
						IF @DESC IS NOT NULL
							RAISERROR(@DESC,16,1)
					END

					EXEC spa_ixp_rules 'c' , @process_id
						, @ixp_rules_id
						, @ixp_rules_name
						, @individual_script_per_object
						, @limit_rows_to
						, @before_insert_triger
						, @after_insert_triger
						, @import_export_flag
						, @run_rules
						, @ixp_owner
						, @ixp_category
						, @is_system_import
						, @first_stg_table
						, @run_with_custom_enable
						, @source
						, @full_file_path
						, @parameter_xml
						, @active_flag
						, @show_delete_msg
						, @excel_sheet_name
						, @run_in_debug_mode
						, @batch_process_id
						, @batch_report_param
						, @rule_name
						, @source_delimiter
						, @source_with_header

					SELECT @temp_process_table  = @first_stg_table
					SET @sql = 'IF COL_LENGTH(''' + @temp_process_table + ''', ''import_file_name'') IS NULL
										BEGIN
											ALTER TABLE ' + @temp_process_table + ' ADD import_file_name NVARCHAR(2000)
										END'					
					EXEC(@sql)
							
					SET @sql = 'UPDATE ' + @temp_process_table + ' SET import_file_name = ''' + @full_file_path + '''' 
					--PRINT(@sql)					
					EXEC(@sql)

					IF NOT EXISTS(SELECT 1 FROM import_process_info 
									WHERE process_id = @process_id AND ixp_rule_id = @ixp_rules_id AND import_file_name = @full_file_path) AND NULLIF(@full_file_path,'') IS NOT NULL
					BEGIN
						INSERT INTO import_process_info(process_id, ixp_rule_id,import_file_name)
						SELECT @process_id, @ixp_rules_id, @full_file_path
					END

					EXEC spa_print 'Check if source data imported to first stg. If failed check flag c', ' select * FROM ', @temp_process_table
						
				END
				ELSE IF @source = 21407 --CLR FUNCTION
					BEGIN
						SET @parameter_xml = ISNULL(@parameter_xml, '')
						-- Immediate call
				
						IF OBJECT_ID ('tempdb..#clr_import_status1') IS NOT NULL
							DROP TABLE #clr_import_status1
					
						CREATE TABLE #clr_import_status1 (
							[error_code] NVARCHAR(15) COLLATE DATABASE_DEFAULT,
							[module] NVARCHAR(255) COLLATE DATABASE_DEFAULT,
							[area] NVARCHAR(255) COLLATE DATABASE_DEFAULT,
							[status] NVARCHAR(255) COLLATE DATABASE_DEFAULT,
							[message] NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							[supress] NVARCHAR(5) COLLATE DATABASE_DEFAULT,
							[process_table] NVARCHAR(1000) COLLATE DATABASE_DEFAULT

						)

						INSERT INTO #clr_import_status1
						EXEC spa_ixp_call_clr_function  @parameter_xml, @ixp_rules_id, @process_id --CLR spa
			
						SELECT @supress = [supress],
							   @response_message = [message],
							   @run_table = [process_table]
						FROM #clr_import_status1

						IF @supress = 'True'
						BEGIN
							EXEC spa_ErrorHandler -1
										, 'Import/Export'
										, 'spa_ixp_rules'									
										, 'Error'
										, @response_message
										, 'Please Check/Refresh your message board.'

							RETURN
						END
						IF EXISTS(SELECT * FROM  clr_error_log WHERE process_id = @process_id)
						BEGIN
						
							EXEC spa_ErrorHandler -1
										, 'Import/Export'
										, 'spa_ixp_rules'									
										, 'Error'
										, 'Import process has been run and will complete shortly.'
										, 'Please Check/Refresh your message board.'

						
							SELECT @message = message FROM  clr_error_log WHERE process_id = @process_id

							RAISERROR (@message, -- Message text.
										16, -- Severity.
										1 -- State.
										);						
						END

						SET @temp_process_table = @run_table

						SET @sql = 'IF COL_LENGTH(''' + @temp_process_table + ''', ''import_file_name'') IS NULL
								BEGIN
									ALTER TABLE ' + @temp_process_table + ' ADD import_file_name NVARCHAR(2000)
								END'
						EXEC(@sql)	
						IF @is_datasource_customized = 'y'
							SET @use_customization = 'y'						
					END
				ELSE IF @source = 21408 -- Json
				BEGIN
					IF CHARINDEX('\', @server_path) = 0
						SELECT @full_file_path = document_path + '\temp_Note\' + @server_path FROM connection_string
					ELSE SET @full_file_path = @server_path

					EXEC spa_parse_json 'simple_parse', @full_file_path, '',  @temp_process_table

				END
				ELSE
				BEGIN
					EXEC ('IF OBJECT_ID(''' + @temp_process_table + ''') IS NOT NULL
						   BEGIN
	       						DROP TABLE ' + @temp_process_table + '
						   END'
					)
					SET @sql = 'SELECT * INTO ' + @temp_process_table  + ' FROM ' + @run_table

					--PRINT('Connection String based import -> ' + @sql)
					EXEC(@sql)
				END
								
				SET @sql = 'IF COL_LENGTH(''' + @temp_process_table + ''', ''import_file_name'') IS NULL
							BEGIN
								ALTER TABLE ' + @temp_process_table + ' ADD import_file_name NVARCHAR(2000) 
							END'					
				EXEC(@sql)
								
				IF @run_with_custom_enable = 'y' OR @is_datasource_customized = 'y'
					SET @use_customization = 'y'
			END	
			IF @source  IN (21400,21402,21405)
			BEGIN
				/*
					Update numeric data according to decimal and group separator starts
					This logic is bypassed for reimport and excel files.  Excel application auto corrects numeric data so conversion is not required.
					Conversion is applicable only for non excel file based import.
						1. Folder based import (batch) with non excel file.
						2. Non excel uploaded file
			*/

				DECLARE @decimal_group_separator BIT = 0

				if OBJECT_ID(@reimport_data) IS NOT NULL 
				SET @decimal_group_separator = 0
				ELSE
				if @flag = 'r' AND EXISTS(SELECT files_names FROM  #temp_files_list WHERE files_names NOT LIKE '%.xls%') 
				SET @decimal_group_separator = 1
				ELSE
				IF @flag = 't' AND NULLIF(@server_path,'') IS NOT NULL AND CHARINDEX('.', @server_path) > 0 AND (CHARINDEX('.xls', RIGHT(@server_path,5)) = 0)
				SET @decimal_group_separator = 1

				IF @decimal_group_separator = 1
			BEGIN 	
				DECLARE @decimal_separator NVARCHAR(100), @group_separator  NVARCHAR(100)
				SELECT @decimal_separator = decimal_separator
					,  @group_separator = group_separator
				FROM company_info 
		
				SELECT @decimal_separator = ISNULL(au.decimal_separator,@decimal_separator)
					, @group_separator = ISNULL(au.group_separator, @group_separator)
				FROM application_users au 
				WHERE user_login_id = @user_name
			
				IF OBJECT_ID('tempdb..#stg1') IS NOT NULL DROP TABLE #stg1
				CREATE TABLE #stg1(column_name NVARCHAR(20) COLLATE DATABASE_DEFAULT)

				SET @sql = 'SELECT TOP 1 * FROM '+ @temp_process_table 
	
				EXEC spa_get_output_schema_or_data @sql_query = @sql
						, @process_table_name = '#stg1'
						, @data_output_col_count = @total_columns OUTPUT
						, @flag = 'schema'
			
				DECLARE @sql_updt NVARCHAR(max)
				SELECT @sql_updt = COALESCE(@sql_updt + ',','') +  iidm.source_column_name + ' = REPLACE(REPLACE(REPLACE(' + iidm.source_column_name + ',''' + @group_separator + ''',''''),''' + @decimal_separator + ''',''.''),''"'','''')'
				FROM ixp_rules ir
				INNER JOIN ixp_import_data_source iids ON iids.rules_id = ir.ixp_rules_id
				INNER JOIN ixp_import_data_mapping iidm ON iidm.ixp_rules_id = ir.ixp_rules_id
				INNER JOIN ixp_tables it ON it.ixp_tables_id = iidm.dest_table_id
				INNER JOIN ixp_columns ic ON ic.ixp_columns_id = iidm.dest_column
				INNER JOIN #stg1  ss ON ss.columnname = IIF(CHARINDEX('[', iidm.source_column_name) > 0,SUBSTRING(iidm.source_column_name, CHARINDEX('[', iidm.source_column_name) + 1, CHARINDEX(']', iidm.source_column_name) - CHARINDEX('[', iidm.source_column_name) - 1 ),iidm.source_column_name)
				WHERE ic.datatype like 'numeric%' AND 
				ir.ixp_rules_id = @ixp_rules_id

				SELECT @data_source_alias =  data_source_alias FROM ixp_import_data_source WHERE rules_id = @ixp_rules_id

				SELECT @sql_updt = 'UPDATE ' + @data_source_alias + ' SET ' + @sql_updt 
						+ ' FROM ' + @temp_process_table + ' ' + @data_source_alias
				
				EXEC(@sql_updt)	
			END
			END
			--------------------Update numeric data according to decimal and group separator ends------------------------------------
				
			/*Rename staging 1 user profile column header to english. If not defined in vw_locale_mapping then same string is used.*/
			DECLARE @translate_language BIT = 0

			DROP TABLE IF EXISTS #col_rename_query
			CREATE TABLE #col_rename_query(sql_query NVARCHAR(MAX) COLLATE DATABASE_DEFAULT)

			SET @sql = 'INSERT INTO #col_rename_query
					SELECT  ''EXEC adiha_process..sp_rename N'' + '''''''' + QUOTENAME(s.name) + ''.'' + QUOTENAME(o.name) + ''.'' + QUOTENAME(REPLACE(c.name, '''''''','''''''''''')) 
						+ '''''''' + '', '' + ''N'''''' +  REPLACE(vlm.original_keyword, '''''''','''''''''''') + ''''''''
					FROM adiha_process.sys.columns c  WITH(NOLOCK)
					INNER JOIN adiha_process.sys.objects o  WITH(NOLOCK) ON c.object_id = o.object_id
					INNER JOIN adiha_process.sys.schemas s  WITH(NOLOCK) ON o.schema_id = s.schema_id
					LEFT JOIN vw_locale_mapping vlm ON vlm.translated_keyword = c.[name]
					WHERE c.object_id = OBJECT_ID(''' + @temp_process_table + ''')
						AND vlm.original_keyword IS NOT NULL
					'

			IF OBJECT_ID('vw_locale_mapping') IS NOT NULL AND OBJECT_ID('import_process_info') IS NOT NULL
			BEGIN
				EXEC(@sql)
			END
		
			IF EXISTS(SELECT 1 FROM #col_rename_query)
			BEGIN
				SET @translate_language = 1
				IF NOT EXISTS(SELECT 1 FROM import_process_info WHERE process_id = @process_id AND ixp_rule_id = @ixp_rules_id)
				BEGIN
					INSERT INTO import_process_info (process_id,ixp_rule_id, translate_language)
					SELECT @process_id, @ixp_rules_id,@translate_language
				END
				ELSE
				BEGIN
					UPDATE  import_process_info SET translate_language = @translate_language WHERE process_id = @process_id AND ixp_rule_id = @ixp_rules_id
				END

				IF (SELECT CURSOR_STATUS('global','cur_rename_column')) >=0 
				BEGIN
					DEALLOCATE cur_rename_column
				END
					
				DECLARE cur_rename_column CURSOR FOR
				SELECT sql_query
				FROM #col_rename_query					
				OPEN cur_rename_column
				FETCH NEXT FROM cur_rename_column
				INTO @sql 
				WHILE @@FETCH_STATUS = 0
				BEGIN
					
					EXEC(@sql)
					FETCH NEXT FROM cur_rename_column INTO @sql
				END
				CLOSE cur_rename_column
				DEALLOCATE cur_rename_column	
			END

			-- ends
			IF @use_customization = 'y'
			BEGIN
				EXEC ('IF OBJECT_ID(''' + @custom_table + ''') IS NOT NULL
					   BEGIN
			       			DROP TABLE ' + @custom_table + '
					   END'
				)
								
				SET @customizing_query = REPLACE(@customizing_query, '[temp_process_table]', @temp_process_table)
				SET @customizing_query = REPLACE(@customizing_query, '--[__custom_table__]',  ' INTO ' + @custom_table)
				--PRINT(@customizing_query)
				EXEC(@customizing_query)
				
				SET @sql = 'IF COL_LENGTH(''' + @custom_table + ''', ''import_file_name'') IS NULL
							BEGIN
								ALTER TABLE ' + @custom_table + ' ADD import_file_name NVARCHAR(2000)
							END'					
				EXEC(@sql)
				--PRINT(@sql)	
				
				SET @temp_process_table = NULL
				SET @temp_process_table = @custom_table		
				--PRINT('Custom Table - ' + @custom_table)	
				
				SET @use_customization = 'n'	
			END		
			
			IF NOT EXISTS (SELECT 1 FROM #tables) 
			BEGIN
				IF @trigger_before_import IS NOT NULL
				BEGIN
					SET @trigger_before_import = REPLACE(@trigger_before_import, '[temp_process_table]', @temp_process_table) 
					SET @trigger_output = NULL
				
					EXEC spa_import_trigger 'b', @trigger_before_import, @process_id, @trigger_output OUTPUT

				END
			END
			ELSE
			BEGIN
				BEGIN TRY

			/* In case of generic mapping import mapping source column name and required unique column definition is defined in generic mapping definition. So update ixp colummns and mapping column information accordingly. */


			IF EXISTS (SELECT TOP 1 1 FROM ixp_tables it
					INNER JOIN ixp_import_data_mapping iidm ON iidm.dest_table_id = it.ixp_tables_id
					WHERE it.ixp_tables_name = 'ixp_generic_mapping' 
					AND iidm.ixp_rules_id = @ixp_rules_id )
			BEGIN
				--This table is used in next process to resolve column header in data validation logic.
	
				DECLARE @tbl_ixp_columns NVARCHAR(200) = dbo.FNAProcessTableName('dyn_ixp_columns', @user_name, @process_id)
				, @tbl_ixp_import_data_mapping NVARCHAR(200) = dbo.FNAProcessTableName('dyn_ixp_import_data_mapping', @user_name, @process_id)
				, @gen_mapping_col_name NVARCHAR(200) = 'Mapping Name'
	
				SET @sql ='
						SELECT *
							, IIF(CHARINDEX(''['', iidm.source_column_name) > 0,SUBSTRING(iidm.source_column_name, CHARINDEX(''['', iidm.source_column_name) + 1, CHARINDEX('']'', iidm.source_column_name) - CHARINDEX(''['', iidm.source_column_name) - 1 ),iidm.source_column_name)
						valid_column_name 
						FROM ixp_import_data_mapping iidm WHERE iidm.ixp_rules_id = ' + CAST(@rules_id AS NVARCHAR(20))
	
				EXEC spa_get_output_schema_or_data @sql_query = @sql
						, @process_table_name = @tbl_ixp_import_data_mapping
						, @data_output_col_count = @total_columns OUTPUT
						, @flag = 'data'
	
				DROP TABLE IF EXISTS #gen_mapping_col_name
				CREATE TABLE #gen_mapping_col_name(column_name NVARCHAR(20) COLLATE DATABASE_DEFAULT)

				EXEC('INSERT INTO #gen_mapping_col_name
				SELECT valid_column_name 
				FROM ' + @tbl_ixp_import_data_mapping + ' a
				INNER JOIN ixp_columns ic ON ic.ixp_columns_id = a.dest_column
				WHERE ic.ixp_columns_name = ''mapping_name''')

				IF OBJECT_ID('tempdb..#sch_stg1') IS NOT NULL DROP TABLE #sch_stg1
				CREATE TABLE #sch_stg1(column_name NVARCHAR(20) COLLATE DATABASE_DEFAULT)

				SET @sql = 'SELECT TOP 1 * FROM '+ @temp_process_table 
	
				EXEC spa_get_output_schema_or_data @sql_query = @sql
						, @process_table_name = '#sch_stg1'
						, @data_output_col_count = @total_columns OUTPUT
						, @flag = 'schema'
	
				SELECT @gen_mapping_col_name = column_name FROM #gen_mapping_col_name

				IF EXISTS(SELECT 1 FROM #sch_stg1 WHERE columnname = @gen_mapping_col_name)
				BEGIN
					DECLARE @clm_udf_id NVARCHAR(MAX)
						, @mapping_table_id INT
						, @unique_columns_index NVARCHAR(500)
						, @required_columns_index NVARCHAR(500)
			
					IF OBJECT_ID('tempdb..#gmh') is not null DROP TABLE #gmh
					CREATE TABLE #gmh(mapping_table_id INT
						, mapping_name NVARCHAR(50) COLLATE DATABASE_DEFAULT
						, unique_columns_index NVARCHAR(500) COLLATE DATABASE_DEFAULT
						, required_columns_index NVARCHAR(500) COLLATE DATABASE_DEFAULT
					)
					-- update generic_mapping_definition set required_columns_index = '1,3' where mapping_table_id = 47
					SET @sql = 'INSERT INTO #gmh(mapping_table_id, mapping_name, unique_columns_index, required_columns_index)
						SELECT DISTINCT gmh.mapping_table_id, gmh.mapping_name, gmd.unique_columns_index, gmd.required_columns_index
						FROM (SELECT TOP 1 * FROM ' + @temp_process_table + ') a 
						INNER JOIN generic_mapping_header gmh ON  gmh.mapping_name = a.[' + @gen_mapping_col_name + ']
						INNER JOIN generic_mapping_definition gmd ON gmd.mapping_table_id = gmh.mapping_table_id
						'

					EXEC(@sql)

					SELECT TOP 1 @mapping_table_id = mapping_table_id 
						, @unique_columns_index = unique_columns_index	
						, @required_columns_index = required_columns_index
					FROM #gmh

					IF OBJECT_ID('tempdb..#gmd_col') is not null DROP TABLE #gmd_col
					CREATE TABLE #gmd_col(a INT)

					IF OBJECT_ID('tempdb..#gmd') is not null DROP TABLE #gmd
					CREATE TABLE #gmd(src_column NVARCHAR(20) COLLATE DATABASE_DEFAULT, udf_column_id NVARCHAR(20) COLLATE DATABASE_DEFAULT, udf_template_id NVARCHAR(20) COLLATE DATABASE_DEFAULT)
		
					EXEC spa_get_output_schema_or_data @sql_query = 'SELECT TOP 1 * FROM generic_mapping_definition'
							, @process_table_name = '#gmd_col'
							, @data_output_col_count = @total_columns OUTPUT
							, @flag = 'schema'
	
					SELECT @clm_udf_id = COALESCE(@clm_udf_id + ',','') + columnname from #gmd_col where columnname like 'clm%_udf_id'
	
					SET @sql = 'INSERT INTO #gmd(src_column,udf_column_id,udf_template_id)
							SELECT ''column'' + CAST(REPLACE(REPLACE(column_id, ''clm'',''''),''_udf_id'','''') + 1 AS NCHAR(2)) src_column,  column_id udf_column_id, column_name udf_template_id
							FROM (SELECT * FROM generic_mapping_definition gmd WHERE gmd.mapping_table_id = ' + CAST(@mapping_table_id AS NVARCHAR(8)) + ') p
							UNPIVOT (column_name FOR column_id IN (' + @clm_udf_id + ')
									) AS unpvt'
					EXEC(@sql)
	
					SET @sql = 'IF EXISTS (SELECT 1 FROM adiha_process.dbo.sysobjects WHERE id = OBJECT_ID(''' +  @tbl_ixp_columns + ''') )
									DROP TABLE ' + @tbl_ixp_columns + '
							SELECT ic.ixp_columns_id
							, ic.ixp_table_id
							, ic.ixp_columns_name
							, ic.column_datatype
							, COALESCE(IIF(u.item IS NOT NULL, 1,NULL),ic.is_major,0) is_major
							, ic.header_detail
							, ic.seq
							, ic.datatype
							, COALESCE(IIF(r.item IS NOT NULL, 1,NULL),ic.is_required,0) is_required
						INTO ' + @tbl_ixp_columns + '
						FROM ixp_columns ic
						INNER JOIN ixp_tables it ON it.ixp_tables_id = ic.ixp_table_id
							AND it.ixp_tables_name = ''ixp_generic_mapping''		
						LEFT JOIN dbo.FNASplit(''' + ISNULL(@required_columns_index,'') + ''','','') r ON r.item = REPLACE(REPLACE(ic.ixp_columns_name,''clm'',''''),''_value'','''')
						LEFT JOIN dbo.FNASplit(''' + ISNULL(@unique_columns_index,'') + ''','','') u ON u.item = REPLACE(REPLACE(ic.ixp_columns_name,''clm'',''''),''_value'','''')
						'
	
					EXEC(@sql)
	
					SET @sql = ' UPDATE iidm
							SET valid_column_name = udft.field_label
								, udf_field_id = udft.field_id				
						FROM ' + @tbl_ixp_import_data_mapping + ' iidm
						INNER JOIN ' + @tbl_ixp_columns + ' c ON c.ixp_columns_id = iidm.dest_column
						INNER JOIN #gmd g ON REPLACE(c.ixp_columns_name,''_value'','''') = REPLACE(g.udf_column_id,''_udf_id'','''')
						INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = g.udf_template_id
						OUTER APPLY(SELECT clm1,clm2 FROM dbo.FNASplitAndTranspose(udft.data_type,''('')) i
						'
	
					EXEC(@sql)
	
					EXEC('UPDATE ic
						SET is_major = ic_gm.is_major
							, is_required = ic_gm.is_required
						FROM #ixp_columns ic
						INNER JOIN ' + @tbl_ixp_columns + ' ic_gm ON ic_gm.ixp_columns_id = ic.ixp_columns_id')

					EXEC('UPDATE iidm
						SET source_column_name = IIF(CHARINDEX(''['', iidm.source_column_name)>0, SUBSTRING(iidm.source_column_name, 1,CHARINDEX(''['', iidm.source_column_name)) + iidm_gm.valid_column_name + '']'', iidm_gm.valid_column_name)	

						FROM #ixp_import_data_mapping iidm
						INNER JOIN ' + @tbl_ixp_import_data_mapping + ' iidm_gm ON iidm_gm.ixp_import_data_mapping_id = iidm.ixp_import_data_mapping_id')
				END -- end if mapping column exists block.
			END --end of generic mapping block


				IF OBJECT_ID('tempdb..#valid_source_columns') IS NOT NULL
					DROP TABLE #valid_source_columns
				IF OBJECT_ID('tempdb..#available_col') IS NOT NULL
					DROP TABLE #available_col
				IF OBJECT_ID('tempdb..#missing_columns') IS NOT NULL
					DROP TABLE #missing_columns

				CREATE TABLE #valid_source_columns(source_column_name NVARCHAR(500) COLLATE DATABASE_DEFAULT
					, map_column_name NVARCHAR(500) COLLATE DATABASE_DEFAULT)
				CREATE TABLE #available_col(sheet_name NVARCHAR(100) COLLATE DATABASE_DEFAULT
					,column_name NVARCHAR(500) COLLATE DATABASE_DEFAULT)
				CREATE TABLE #missing_columns(column_name NVARCHAR(500) COLLATE DATABASE_DEFAULT)
				DECLARE @sheetname NVARCHAR(100) =  CASE WHEN  (CHARINDEX('xls', RIGHT(@server_path,4)) > 0) THEN ISNULL(@excel_sheet_name, 'Sheet1') ELSE '' END
				
				EXEC('INSERT INTO #available_col(sheet_name,column_name) 
					SELECT ''' + @sheetname  + ''', name FROM adiha_process.sys.columns sc WITH(NOLOCK)
					LEFT JOIN #available_col i ON i.column_name = sc.name								
					WHERE object_id = OBJECT_ID(''' + @temp_process_table + ''')
					AND i.column_name is null' )

				
				
				SET @sql = 'SELECT idm.source_column_name, ic.ixp_columns_name ixp_column_name
					FROM #ixp_import_data_mapping idm
					INNER JOIN #ixp_columns ic ON ic.ixp_columns_id = idm.dest_column
						AND ic.ixp_table_id = idm.dest_table_id
					INNER JOIN #available_col src_col ON src_col.column_name = IIF(CHARINDEX(''['', idm.source_column_name) > 0,SUBSTRING(idm.source_column_name, CHARINDEX(''['', idm.source_column_name) + 1, CHARINDEX('']'', idm.source_column_name) - CHARINDEX(''['', idm.source_column_name) - 1 ),REPLACE(idm.source_column_name,''' + @datasource_alias + '.'', ''''))
					'
		
				EXEC spa_get_output_schema_or_data @sql_query = @sql
						, @process_table_name = @source_ixp_column_mapping
						, @data_output_col_count = @total_columns OUTPUT
						, @flag = 'data'
					
					IF (SELECT CURSOR_STATUS('global','import_cursor')) >=0 
					BEGIN
					DEALLOCATE import_cursor
					END

					DECLARE import_cursor CURSOR FOR
					SELECT t.table_id, t.repeat_number
					FROM #tables t
					
					OPEN import_cursor
					FETCH NEXT FROM import_cursor
					INTO @ixp_table_id, @ixp_repeat_number 
					WHILE @@FETCH_STATUS = 0
					BEGIN

						SET @trigger_output = NULL
						
						SELECT @table_name = it.ixp_tables_name
						FROM   ixp_tables it
						WHERE  it.ixp_tables_id = @ixp_table_id
						
						SET @insert_process_table = dbo.FNAProcessTableName(@table_name + '_' + CAST(@ixp_repeat_number as NVARCHAR(10)), @user_name, @process_id)
						
						EXEC spa_import_table_template 'b', @ixp_table_id, @process_id, @ixp_repeat_number
						
						SET @where_clause = NULL
							
						IF @flag = 'r' OR @flag = 't'
						BEGIN
							SELECT @where_clause = NULLIF(ixp_import_where_clause,'') FROM ixp_import_where_clause WHERE rules_id = @rules_id AND table_id = @ixp_table_id AND repeat_number = @ixp_repeat_number
						END					
						ELSE
						BEGIN
							DECLARE @sql_stmt NVARCHAR(MAX)
							SET @sql_stmt = 'SELECT @where_clause = NULLIF(ixp_import_where_clause,'''') FROM ' + @ixp_import_where_clause + ' WHERE rules_id = ' + CAST(@rules_id AS NVARCHAR(10)) + ' AND table_id = ' + CAST(@ixp_table_id AS NVARCHAR(10)) + ' AND repeat_number = ' + CAST(@ixp_repeat_number AS NVARCHAR(20))
							EXEC sp_executesql @sql_stmt, N'@where_clause NVARCHAR(max) output', @where_clause OUTPUT
						END
						
						SET @dest_column_lists = NULL
						SET @source_column_lists = NULL
						SET @grouping_columns = NULL
						
						--Collect list of mapped column to validate. Mapped column without column aggregation and Mandatory, optional column if marked as is_major(unique column identifier) must exists in source.
						INSERT INTO #valid_source_columns(source_column_name,map_column_name)					
						SELECT DISTINCT REPLACE(REPLACE(SUBSTRING( idm.source_column_name, CHARINDEX('.', idm.source_column_name, 0)+1, len(idm.source_column_name) - CHARINDEX('.', idm.source_column_name, 0)+1), '[', ''), ']', '') source_column_name
						, ic.ixp_columns_name				
						FROM #ixp_import_data_mapping idm
						INNER JOIN #ixp_columns ic ON ic.ixp_columns_id = idm.dest_column AND ic.ixp_table_id = idm.dest_table_id		       
						LEFT JOIN #valid_source_columns i ON i.map_column_name = ic.ixp_columns_name	       
						WHERE idm.dest_table_id = @ixp_table_id AND idm.repeat_number = @ixp_repeat_number
							AND i.map_column_name IS NULL
							AND idm.column_aggregation IS NULL 
							AND (ic.is_required = 1 OR ic.is_major = 1)
											
						SELECT @dest_column_lists = COALESCE(@dest_column_lists + ', ', '') + '[' + ic.ixp_columns_name + ']'
							,@source_column_lists = COALESCE(@source_column_lists + ', ', '') + CASE 
								WHEN idm.column_function IS NOT NULL
									THEN idm.column_function
								WHEN src_col.column_name IS NULL
									THEN 'NULL'
								ELSE CASE 
										WHEN idm.column_aggregation IS NOT NULL
											THEN idm.column_aggregation + '(NULLIF(NULLIF(CAST(LTRIM(RTRIM(' + idm.source_column_name + ')) AS NVARCHAR(2000)),''NULL''),''''))'
										ELSE 'NULLIF(NULLIF(CAST(LTRIM(RTRIM(' + idm.source_column_name + ')) AS NVARCHAR(2000)), ''NULL''),'''')'
										END
								END
							   --@grouping_columns = CASE WHEN idm.column_aggregation IS NOT NULL THEN '' ELSE COALESCE(NULLIF(@grouping_columns, '') + ', ', '') +  idm.source_column_name END 
					FROM #ixp_import_data_mapping idm
					INNER JOIN #ixp_columns ic ON ic.ixp_columns_id = idm.dest_column
						AND ic.ixp_table_id = idm.dest_table_id
					LEFT JOIN #available_col src_col ON src_col.column_name = IIF(CHARINDEX('[', idm.source_column_name) > 0,SUBSTRING(idm.source_column_name, CHARINDEX('[', idm.source_column_name) + 1, CHARINDEX(']', idm.source_column_name) - CHARINDEX('[', idm.source_column_name) - 1 ),REPLACE(idm.source_column_name, @datasource_alias+'.',''))
					WHERE idm.dest_table_id = @ixp_table_id
						AND idm.repeat_number = @ixp_repeat_number

					
						SELECT @grouping_columns = Stuff((SELECT ', ' + source_column_name AS [text()]
													FROM  
													(SELECT DISTINCT idm.source_column_name FROM #ixp_import_data_mapping idm
													INNER JOIN #available_col src_col ON src_col.column_name = IIF(CHARINDEX('[', idm.source_column_name) > 0,SUBSTRING(idm.source_column_name, CHARINDEX('[', idm.source_column_name) + 1, CHARINDEX(']', idm.source_column_name) - CHARINDEX('[', idm.source_column_name) - 1 ),REPLACE(idm.source_column_name, @datasource_alias+'.',''))
													WHERE idm.column_aggregation IS NULL AND idm.dest_table_id = @ixp_table_id 
														AND idm.repeat_number = @ixp_repeat_number) x
													For XML PATH ('')),1,1,'')   
	
						--SET @grouping_columns = REPLACE(@grouping_columns, ', NULL', '')
					
						IF @table_name IS NOT NULL
						BEGIN
							DECLARE @relation_id INT
							DECLARE @temp_conn_string NVARCHAR(1000)	
							DECLARE @temp_relation_table NVARCHAR(1000)
							
							IF OBJECT_ID('tempdb..#grouping_relation_columns') IS NOT NULL
								DROP TABLE #grouping_relation_columns       
							CREATE TABLE #grouping_relation_columns (rel_columns NVARCHAR(500) COLLATE DATABASE_DEFAULT)
							
							SET @join_statement = ''
							
							DECLARE relation_cursor CURSOR  
							FOR SELECT [relation_id] FROM #relations
							OPEN relation_cursor
							FETCH NEXT FROM relation_cursor INTO @relation_id
							WHILE @@FETCH_STATUS = 0
							BEGIN
								SELECT @temp_conn_string = joining_table,
									   @relation_type = relation_source_type,
									   @relation_alias = ixp_relation_alias,
									   @relation_delimiter = delimiter,
									   @relation_join_clause = join_clause,
									   @relation_excel_sheet = excel_sheet
								FROM   #relations
								WHERE  relation_id = @relation_id
								
								IF @relation_type = 21400 OR @relation_type = 21405
								BEGIN
									
									SET @temp_relation_table = 'adiha_process.dbo.relation_table_' + @relation_alias + '_' + @process_id
									SET @temp_conn_string = CASE WHEN @relation_type = 21405 THEN @server_path ELSE @temp_conn_string END
									SET @source_with_header = CASE WHEN @is_header_less = 'y' THEN 'n' ELSE 'y' END
																		
									EXEC spa_ixp_rules 'c' , @process_id
										, @ixp_rules_id
										, @ixp_rules_name
										, @individual_script_per_object
										, @limit_rows_to
										, @before_insert_triger
										, @after_insert_triger
										, @import_export_flag
										, @run_rules
										, @ixp_owner
										, @ixp_category
										, @is_system_import
										, @temp_relation_table
										, @run_with_custom_enable
										, @source
										, @temp_conn_string
										, @parameter_xml
										, @active_flag
										, @show_delete_msg
										, @relation_excel_sheet
										, @run_in_debug_mode
										, @batch_process_id
										, @batch_report_param
										, @rule_name
										, @relation_delimiter
										, @source_with_header

										--/*

										DROP TABLE IF EXISTS #rel_col_rename_query
										CREATE TABLE #rel_col_rename_query(sql_query NVARCHAR(MAX) COLLATE DATABASE_DEFAULT)

										IF OBJECT_ID('vw_locale_mapping') IS NOT NULL AND OBJECT_ID('import_process_info') IS NOT NULL
										BEGIN
											EXEC( 'INSERT INTO #rel_col_rename_query
												SELECT  ''EXEC adiha_process..sp_rename N'' + '''''''' + QUOTENAME(s.name) + ''.'' + QUOTENAME(o.name) + ''.'' + QUOTENAME(REPLACE(c.name, '''''''','''''''''''')) 
													+ '''''''' + '', '' + ''N'''''' +  REPLACE(vlm.original_keyword, '''''''','''''''''''') + ''''''''
												FROM adiha_process.sys.columns c  WITH(NOLOCK)
												INNER JOIN adiha_process.sys.objects o  WITH(NOLOCK) ON c.object_id = o.object_id
												INNER JOIN adiha_process.sys.schemas s  WITH(NOLOCK) ON o.schema_id = s.schema_id
												LEFT JOIN vw_locale_mapping vlm ON vlm.translated_keyword = c.[name]
												WHERE c.object_id = OBJECT_ID(''' + @temp_relation_table + ''')
													AND vlm.original_keyword IS NOT NULL
												')
										END
		
										IF EXISTS(SELECT 1 FROM #rel_col_rename_query) AND @translate_language = 1
										BEGIN
											IF (SELECT CURSOR_STATUS('global','cur_rename_rel_column')) >=0 
											BEGIN
												DEALLOCATE cur_rename_rel_column
											END

											DECLARE cur_rename_rel_column CURSOR FOR
											SELECT sql_query
											FROM #rel_col_rename_query					
											OPEN cur_rename_rel_column
											FETCH NEXT FROM cur_rename_rel_column
											INTO @sql 
											WHILE @@FETCH_STATUS = 0
											BEGIN
												EXEC(@sql)
												FETCH NEXT FROM cur_rename_rel_column INTO @sql
											END
											CLOSE cur_rename_rel_column
											DEALLOCATE cur_rename_rel_column	
										END

										
										EXEC('INSERT INTO #available_col(sheet_name,column_name) 
											SELECT  ''' + @relation_excel_sheet +  ''',name FROM adiha_process.sys.columns sc WITH(NOLOCK)
											LEFT JOIN #available_col i ON i.column_name = sc.name
											WHERE object_id = OBJECT_ID(''' + @temp_relation_table + ''')
											AND i.column_name is null' )
								END
								ELSE
								BEGIN
									--need to chk this clause
									SET @temp_relation_table = @temp_conn_string
								END
								
								SET @join_statement = ISNULL(@join_statement, '') + ' LEFT JOIN ' + @temp_relation_table + ' ' +  @relation_alias + ' ON ' + @relation_join_clause
								
								DECLARE @temp_linked_table NVARCHAR(200)
								SET @temp_linked_table = 'import_linked_table_columns_' + @process_id
								EXEC ('IF OBJECT_ID(''adiha_process.dbo.' + @temp_linked_table + ''') IS NOT NULL 
										DROP TABLE adiha_process.dbo.' + @temp_linked_table)
										
								--PRINT('SELECT TOP 1 * INTO adiha_process.dbo.' + @temp_linked_table  + ' FROM ' + @temp_relation_table)
								EXEC('SELECT TOP 1 * INTO adiha_process.dbo.' + @temp_linked_table  + ' FROM ' + @temp_relation_table)
								
								SET @sql = 'INSERT INTO #grouping_relation_columns (rel_columns)
											SELECT ISNULL(iir.ixp_relation_alias + ''.'', '''') + + ''['' + COLUMN_NAME + '']'' [column_name]
											FROM  adiha_process.INFORMATION_SCHEMA.COLUMNS WITH(NOLOCK)'
								
								IF @flag = 'r' OR @flag = 't'
									SET @sql = @sql + ' LEFT JOIN ixp_import_relation  iir ON iir.ixp_import_relation_id = ' + CAST(@relation_id AS NVARCHAR(20))
								ELSE 
									SET @sql = @sql + ' LEFT JOIN ' + @ixp_import_relation + ' iir ON iir.ixp_import_relation_id = ' + CAST(@relation_id AS NVARCHAR(20))
											
								SET @sql = @sql + ' WHERE  TABLE_NAME = ''' + @temp_linked_table + ''' ORDER BY COLUMN_NAME'
								--PRINT(@sql)
								EXEC(@sql)
								
								FETCH NEXT FROM relation_cursor INTO @relation_id
							END
							CLOSE relation_cursor
							DEALLOCATE relation_cursor	
						
							DECLARE @grouping_relation_cloumns NVARCHAR(MAX)
							SELECT @grouping_relation_cloumns = COALESCE(@grouping_relation_cloumns + ', ', '') + rel_columns FROM #grouping_relation_columns grm
							
							IF @grouping_relation_cloumns IS NOT NULL 
								SET @grouping_columns = @grouping_columns + ',' + @grouping_relation_cloumns 
								
							SET @sql = 'ALTER TABLE ' + @insert_process_table + ' ADD import_file_name NVARCHAR(2000)'					
							EXEC(@sql)
							DECLARE @before_trigger_final_table NVARCHAR(max)
							DECLARE @before_trigger_temp_table NVARCHAR(max)
							
		
							IF @trigger_before_import IS NOT NULL AND CHARINDEX('__[final_process_table]__', @trigger_before_import) > 0
								BEGIN
									SET @before_trigger_temp_table = SUBSTRING(@trigger_before_import, 0, CHARINDEX('__[final_process_table]__',@trigger_before_import)-2 )
									SET @before_trigger_final_table = SUBSTRING(@trigger_before_import,CHARINDEX('__[final_process_table]__',@trigger_before_import)+LEN('--__[final_process_table]__')-2,LEN(@trigger_before_import))
									SET	@trigger_before_import = @before_trigger_temp_table
								END	
							IF @trigger_before_import IS NOT NULL AND CHARINDEX('[temp_process_table]', @trigger_before_import) > 0
							BEGIN
								SET @trigger_before_import = REPLACE(@trigger_before_import, '[temp_process_table]', @temp_process_table) 

								IF CHARINDEX('[final_process_table]', @trigger_before_import) > 0
									SET @trigger_before_import = REPLACE(@trigger_before_import, '[final_process_table]', @insert_process_table)  
								
								SET @trigger_output = NULL
								EXEC spa_import_trigger 'b', @trigger_before_import, @process_id, @trigger_output OUTPUT
							END	
																									  						
							TRUNCATE TABLE #missing_columns						  						
							INSERT INTO #missing_columns(column_name)
							SELECT sc.source_column_name from #valid_source_columns sc
							INNER JOIN #ixp_columns ic ON ic.ixp_table_id = @ixp_table_id AND ic.ixp_columns_name = sc.map_column_name
							LEFT JOIN #missing_columns i ON i.column_name = sc.source_column_name
							WHERE i.column_name is null
							EXCEPT
							SELECT column_name from #available_col
										

							--SELECT 'valid_source_columns', * from #valid_source_columns
							--SELECT 'available_col', * from #available_col
							--SELECT 'missingcol', * FROM #missing_columns


				DECLARE @missing_columns NVARCHAR(MAX)
				IF EXISTS (SELECT 1 FROM #missing_columns)
					BEGIN
						SELECT @missing_columns = COALESCE(@missing_columns + ', ', '') + '''' + REPLACE(ISNULL(lm.translated_keyword,mc.column_name), '''','''''') + ''''
						FROM #missing_columns mc
						LEFT JOIN vw_locale_mapping lm ON lm.original_keyword = mc.column_name and lm.language_id = 101602
							AND @translate_language = 1
						GROUP BY ISNULL(lm.translated_keyword,mc.column_name)												
												
						INSERT INTO source_system_data_import_status (process_id, code, [module], [source], [TYPE], [description], recommendation)
						SELECT @process_id, message_status, 'Import Data', @rules_names, message_type, REPLACE([message],'<mismatch_column>', (SELECT CAST(count(1) AS NVARCHAR(10)) FROM #missing_columns)), recommendation
						FROM message_log_template WHERE [message_number] = 10003

						INSERT INTO source_system_data_import_status_detail (process_id, [source], [TYPE], [description])
						SELECT @process_id,
							   @rules_names,
							   message_type,
							   REPLACE([message],'<mismatch_column>', @missing_columns)							   
						FROM message_log_template WHERE [message_number] = 10021

					END
					ELSE
					BEGIN
				/*	insert source file data into staging table and allow user to re import data without uploading source file for import failed data.
					This feature is not ready to release. Data grows fast in this table frequently. So unless this feature is well tested it is disabled in release version.
				*/
				DECLARE @disable_re_import_feature BIT = 0

				IF @disable_re_import_feature = 1
				BEGIN
					IF OBJECT_ID('tempdb..#number_of_columns') IS NOT NULL
					DROP TABLE #number_of_columns 
					
							SELECT source_column_name
								,iidm.dest_table_id
								,dest_column
								,ixp_rules_id
								,seq
								,is_major
								,c.ixp_columns_name
								,'column_'+CAST(row_number() OVER(Order by seq) as NVARCHAR) staging_table_column_name
								,COALESCE(c.datatype,c.column_datatype)  datatype 
							INTO #number_of_columns
							FROM ixp_import_data_mapping iidm 
							INNER JOIN #ixp_columns c on iidm.dest_column = c.ixp_columns_id
							LEFT JOIN #relations r on r.rules_id = iidm.ixp_rules_id
							WHERE iidm.ixp_rules_id = @ixp_rules_id AND iidm.source_column_name is not null and dest_table_id =@ixp_table_id
							ORDER BY seq
							
			
								DECLARE @insert_query NVARCHAR(MAX)
								DECLARE @select_query NVARCHAR(MAX)
								DECLARE @col_staging_table NVARCHAR(MAX)
								DECLARE @col_raw_data NVARCHAR(MAX) 
								DECLARE @staging_col NVARCHAR(MAX)
								DECLARE @column_data NVARCHAR(MAX) = '';
								DECLARE @loopCount INT
					
								SET @col_staging_table =''
								SET @col_raw_data =''
								SET @staging_col = ''
								SET @column_data =''
								SET @insert_query = ' INSERT INTO ixp_import_data_interface_staging'
								SET @select_query = ' SELECT DISTINCT ' 
								DECLARE create_column_list CURSOR FOR     
								SELECT source_column_name,staging_table_column_name FROM #number_of_columns where NULLIF(source_column_name,'') IS NOT NULL	ORDER BY seq
  
								OPEN create_column_list    
  
								FETCH NEXT FROM create_column_list     
								INTO @col_raw_data,@col_staging_table
  
								WHILE @@FETCH_STATUS = 0    
								BEGIN   
							 
									if(@column_data!='')
										SET @column_data =@column_data +','
									if(@staging_col!='')
										SET @staging_col =@staging_col +','

									SET @column_data =@column_data + @col_raw_data 
									SET @staging_col = @staging_col + @col_staging_table
							
 
							
									FETCH NEXT FROM create_column_list     
								INTO @col_raw_data,@col_staging_table
   
								END     
								CLOSE create_column_list;    
								DEALLOCATE create_column_list;    
							
								SELECT @insert_query = @insert_query  +'( ' + @staging_col+','+' ixp_rule_id '  +' )'
								SELECT @select_query = @select_query +' '+ @column_data +', '''+@ixp_rules_id + '''' + ' FROM ' + @temp_process_table + ' ' + @datasource_alias
				

							 
								IF @insert_query IS NOT NULL AND @select_query is not NULL
								BEGIN
									  EXEC(@insert_query+@select_query + ' ' + @join_statement)
								END
				END 
				/* End of ixp_import_data_interface_staging*/
						
							--ixp_source_unique_id column added to link between first staging table and second staging table and dump error data into interface staging table to reimport later after correcting source data.
							IF OBJECT_ID(@reimport_data) IS NULL
							BEGIN
								SET @sql = 'IF COL_LENGTH(''' + @temp_process_table + ''', ''ixp_source_unique_id'') IS NULL
											BEGIN
												ALTER TABLE ' + @temp_process_table + ' ADD ixp_source_unique_id INT
											END'
								EXEC(@sql)
							
								SET @sql = '
									BEGIN
										DECLARE @id INT 
										SET @id = 0	
									
										UPDATE ' + @temp_process_table + '
										SET @id = ixp_source_unique_id = @id + 1 
									END'

								EXEC(@sql)
							END
							SET @sql = 'IF COL_LENGTH(''' + @insert_process_table + ''', ''ixp_source_unique_id'') IS NULL
										BEGIN
											ALTER TABLE ' + @insert_process_table + ' ADD ixp_source_unique_id INT
										END'
							EXEC(@sql)
							
							SET @sql = 'INSERT INTO ' + @insert_process_table + ' (' + @dest_column_lists + ', import_file_name, ixp_source_unique_id)
										SELECT ' + CASE WHEN @join_statement IS NULL THEN '' ELSE ' DISTINCT ' END + @source_column_lists + ',' + @datasource_alias + '.' + ' import_file_name, MAX(' + @datasource_alias + '.' + 'ixp_source_unique_id) 
										FROM ' + @temp_process_table + ' ' + @datasource_alias + ' ' + ISNULL(@join_statement, '') + ' WHERE 1 = 1 ' + ISNULL(' AND ' + @where_clause, '') + ISNULL(' GROUP BY ' + @grouping_columns + ',' + @datasource_alias + '.' + 'import_file_name', ' GROUP BY ' + @datasource_alias + '.' + 'import_file_name ')
						
							--PRINT(ISNULL(@sql , 'nukkkkk'))							
							EXEC(@sql)

							-- hardcoded for eneco version. needs to change this logic to be defined from front end later on.
							SET @sql = 'DELETE ' + @insert_process_table + ' WHERE ' + REPLACE(@dest_column_lists,  ',','  IS NULL AND ') + ' IS NULL'
							--PRINT(ISNULL(@sql, 'sql to delete null row is null'))
							EXEC(@sql)							
					END
							/* It is necessary to update these two query (Alter and Update) separately, when kept in same EXEC, SQL SERVER starts parsing the Update statement before it executes the Alter statement and throws error.*/
							SET @sql = 'IF COL_LENGTH(''' + @insert_process_table + ''', ''source_system_id'') IS NULL
										BEGIN
											ALTER TABLE ' + @insert_process_table + ' ADD source_system_id NVARCHAR(10) NOT NULL DEFAULT(' + @source_system_id + ')
										END'
							EXEC(@sql) 
							 
							SET @sql = 'UPDATE ' + @insert_process_table + ' SET source_system_id = ' + @source_system_id + ''
							EXEC(@sql)
							
							SELECT @trigger_before_import = NULLIF(ir.before_insert_trigger,''),
								   @trigger_after_import = NULLIF(ir.after_insert_trigger,'')
							FROM   #temp_ixp_rules ir
							
							IF @trigger_before_import IS NOT NULL AND CHARINDEX('__[final_process_table]__', @trigger_before_import) > 0
							BEGIN
								SET @trigger_before_import = @before_trigger_final_table
							END
							
							IF @trigger_before_import IS NOT NULL AND CHARINDEX('[final_process_table]', @trigger_before_import) > 0
							BEGIN
							    SET @trigger_before_import = REPLACE(@trigger_before_import, '[temp_process_table]', @temp_process_table) 
								SET @trigger_before_import = REPLACE(@trigger_before_import, '[final_process_table]', @insert_process_table) 
								SET @trigger_output = NULL
								
								EXEC spa_import_trigger 'b', @trigger_before_import, @process_id, @trigger_output OUTPUT
							END	
							
							UPDATE import_data_files_audit
							SET import_source = @table_name
							WHERE process_id = @process_id  AND dir_path = 'Rules:'+ @rules_names
											
							
							
							IF @trigger_output = 1 OR @trigger_before_import IS NULL
							BEGIN
								DECLARE @batch_unique_id NVARCHAR(50)
								IF @batch_process_id IS NOT NULL
									SET @batch_unique_id = '_' + RIGHT(@batch_process_id, 13)
								ELSE
									SET @batch_unique_id = ''
										
								SET @job_name = 'ImportData_' + dbo.FNAGetNewID() + @batch_unique_id
								
								IF (@table_name = 'ixp_source_deal_template')
								BEGIN
									IF @source_system_id <> 2
									BEGIN
										EXEC('UPDATE ' + @insert_process_table + ' SET template_id = ''Import Template sample'' WHERE template_id IS NULL')
										EXEC('UPDATE ' + @insert_process_table + ' SET deal_category_value_id = 475 WHERE deal_category_value_id IS NULL')
									END
									EXEC('UPDATE ' + @insert_process_table + ' SET option_flag = ''n'' WHERE option_flag IS NULL')
								END
								
								IF @is_custom_import = 'y'
								BEGIN
										SET @sql = 'spa_ixp_generic_import_job @import_temp_table_name=''' + @insert_process_table + ''',@table_name=NULL,@process_id=''' + @process_id + ''',@job_name=''' + @job_name + ''',@schedule_run=''n'', @exec_mode=12, @import_from=NULL, @generic_mapping_flag=''' + @generic_flag + ''',@rules_id=' + CAST(@rules_id AS NVARCHAR(20)) +',@import_flag=''' + @flag + ''', @rules_names=''' + @rules_names + ''', @drilldown_level=NULL, @temp_header_table=NULL, @run_in_debug_mode=''' + @run_in_debug_mode + ''', @file_transfer_endpoint_id=' + ISNULL(CAST(@file_transfer_endpoint_id AS VARCHAR), 'NULL') + ', @ftp_remote_directory=''' + ISNULL(@ftp_remote_directory, '') + ''''
								END
								ELSE
								BEGIN
									SET @sql = 'spa_ixp_generic_import_job @import_temp_table_name=''' + @insert_process_table + ''',@table_name=''' + @table_name + ''',@process_id=''' + @process_id + ''',@job_name=''' + @job_name + ''',@schedule_run=''n'', @exec_mode=12, @import_from=NULL, @generic_mapping_flag=''' + @generic_flag + ''',@rules_id=' + CAST(@rules_id AS NVARCHAR(20)) + ',@import_flag=''' + @flag + ''', @rules_names=''' + @rules_names + ''',@drilldown_level= NULL, @temp_header_table=NULL, @run_in_debug_mode=''' + @run_in_debug_mode + ''', @file_transfer_endpoint_id=' + ISNULL(CAST(@file_transfer_endpoint_id AS VARCHAR), 'NULL') + ', @ftp_remote_directory=''' + ISNULL(@ftp_remote_directory, '') + ''''
								END
								 
								SET @final_print_data = ISNULL(@sql,'final script to import is null')
								EXEC spa_print 'Below is the final import step which is not executed in debug mode. Run this statement manually to drill down issue. '
								EXEC spa_print @final_print_data
 
								IF @debug_mode = 'DEBUG_MODE_ON'
								BEGIN
									SELECT 'In debug mode. Check message tab. Run final import script in second column manually in debug mode.', @sql
									RETURN
								END
								ELSE 
								BEGIN
									-- Few templates are using this @final_stg_table to preserve original final stg data and to prevent issue while running generic import logic multiple times in debug mode.
									EXEC ('IF EXISTS(
 										   SELECT 1
 										   FROM   adiha_process.sys.tables  WITH(NOLOCK)
 										   WHERE  [name] =  REPLACE(''' + @insert_process_table + '_pre'',''adiha_process.dbo.'','''')
 												  AND [type] = ''U''
 											)
 											DROP TABLE ' + @insert_process_table + '_pre'
										 )
								
									-- for debugging purpose only
									IF (ISNULL(@execute_in_queue, 0) = 0 AND (@run_in_debug_mode = 'y' OR @count_tables > 1)) 
									BEGIN
										EXEC(@sql)
									END
									ELSE
									BEGIN
									
										IF @execute_in_queue = 1
										BEGIN
											DECLARE @queue_sql NVARCHAR(MAX) = 'EXEC ' + @sql

											DECLARE @process_queue_status NVARCHAR(100)
											EXEC spa_process_queue	@flag = 'create_process_queue',
																	@source_id = @ixp_rules_id,
																	@process_queue_type = 112300,
																	@queue_sql = @queue_sql,
																	@process_id = @process_id,
																	@output_status = @process_queue_status
											
											EXEC spa_process_queue @flag = 'create_or_start_queue_job',@output_status = @process_queue_status
										END
										ELSE
										BEGIN
											EXEC spa_run_sp_as_job @job_name,  @sql, 'ImportData', @user_name	
										END
									END						
								END
							END
							ELSE
							BEGIN							
								IF OBJECT_ID('tempdb..#temp_tot_count') IS NOT NULL
									DROP TABLE #temp_tot_count

								CREATE TABLE #temp_tot_count (
 									totcount  INT
								)
								
								EXEC ('INSERT INTO #temp_tot_count(totcount) SELECT COUNT(*) AS totcount FROM ' + @temp_process_table)
								
								DECLARE @errorMsg NVARCHAR(MAX)
                                DECLARE @errorMsgDetail NVARCHAR(500)
								DECLARE @type NVARCHAR(100)
								DECLARE @rowcount NVARCHAR(100)
								SELECT  @rowcount =  totcount FROM #temp_tot_count
								SELECT @elasped_time = CONVERT(NCHAR(8),DATEADD(second,MAX(elapsed_time), 0), 108) FROM import_data_files_audit WHERE  process_id = @process_id
								SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_name+''''
								SET @errorMsg = '<a target="_blank" href="' + @url + '"> 0 Data imported Successfully out of ' + @rowcount + ' rows.</a>'

								IF EXISTS(
									SELECT 1 FROM sys.sysmessages
									WHERE [description] like '%conversion%'
										AND msglangid = 1033 
										AND error = @trigger_output
								)								
								BEGIN
									SET @errorMsgDetail = 'Data type in file and ''Pre Trigger'' script mismatched. Please check the data and re-import.'
									SET @type = 'Data Mismatch'
								END
								ELSE
								BEGIN
									SET @errorMsgDetail = 'Verify your <b>Pre Trigger</b> script of rule and re-import.'
									SET @type = 'Syntax Error'
								END

								INSERT INTO source_system_data_import_status (process_id, code, [rules_name], [source], [TYPE], [description], recommendation)
								SELECT @process_id,
									  'Error',
									  @rules_names,
									  @rules_names,
									  @type,
									  @errorMsg,
									  'Please check your ' + CASE WHEN @data_source_id IN (21400, 21402) THEN 'file.' ELSE 'data.' END
									  --select * from source_system_data_import_status_detail order by 1 desc
								INSERT INTO source_system_data_import_status_detail (process_id, type_error, [source], [TYPE], [description])
								SELECT @process_id,
									  'Error',
									  @rules_names,
									  @type,
									  @errorMsgDetail
									  
								SET @errorMsg = '<a target="_blank" href="' + @url + '">'
								SET @errorMsg += 'Import Process completed for as of date:' + dbo.FNAUserDateFormat(GETDATE(), @user_name) + '<br/>Rules Executed:<br/><ul style="padding:0px 0px 0px 10px;margin:0px 0px 0px 10px;list-style-type:square;"><li>' + @rules_names + '</li></ul>Elapsed Time:' + @elasped_time + ' <font color="red"><br/>(Errors Found)</font></a>'
								
								IF @flag <> 'q'								
								BEGIN	
									EXEC  spa_message_board 'u', @user_name,NULL, 'ImportData', @errorMsg , '', '', 'e' , @job_name, NULL, @process_id, '', '', '', 'y'
								END
							END		
						END
						FETCH NEXT FROM import_cursor
						INTO @ixp_table_id, @ixp_repeat_number
					END
					CLOSE import_cursor
					DEALLOCATE import_cursor
					
					SET @run_in_debug_mode = 'n'
				END TRY
				BEGIN CATCH
					UPDATE import_data_files_audit
					SET [status] = 'e',
						elapsed_time = DATEDIFF(ss, create_ts, GETDATE())
					WHERE process_id = @process_id

					IF @@TRANCOUNT > 0
					   ROLLBACK
					   
					-- Added to track actual message in debug mode.
					SET @DESC = N'Fail to start import job. ( Error Description:' + ERROR_MESSAGE() + ').'
					EXEC spa_print @DESC
					
					SET @DESC = N'Fail to start import job.'
				
					SELECT @err_no = ERROR_NUMBER()
		
					INSERT INTO source_system_data_import_status (process_id, code, [module], [source], [TYPE], [description], recommendation)
					SELECT @process_id,
						  'Error',
						  'Import Data',
						  @rules_names,
						  'Data Error',
						  @DESC,
						  'Please check your ' + CASE WHEN @data_source_id IN (21400, 21402) THEN 'file.' ELSE 'data.' END

					INSERT INTO source_system_data_import_status_detail (process_id, [source], [TYPE], [description])
					SELECT @process_id,
						  @rules_names,
						  'Data Error',
						  @DESC
						  		
					SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_name+''''
		
					IF @flag = 'q'
						EXEC spa_ErrorHandler @err_no,
							 'Import/Export FX',
							 'spa_ixp_rules',
							 'Import Fail.',
							 @DESC,
							 ''
				 		
					SET @desc = N'<a target="_blank" href="' + @url + '">' 
								   + 'Import process could not complete. <br /> Rules Executed: ' + @rules_names + '.<br />'
								   + ' (ERRORS found)'
								   + '.</a>'
		
					IF @job_name IS NULL
						SET @job_name = 'ImportData_' + @process_id + @batch_unique_id
		
					IF @flag <> 'q'			   
						EXEC  spa_message_board 'u', @user_name,NULL, 'ImportData', @desc, '', '', 'e' , @job_name, NULL, @process_id, '', '', '', 'y'

					EXEC spa_NotificationUserByRole 2, @process_id, 'ImportData', @desc , 'e', @job_name, 0,1
					END CATCH
				END
		
			FETCH NEXT FROM rules_cursor
			INTO @rules_id, @rules_names
		END
		CLOSE rules_cursor
		DEALLOCATE rules_cursor
		
		IF @flag = 't'
		BEGIN
			EXEC spa_ErrorHandler 0, 
				 'Import/Export FX', 
				 @process_id, 
				 'Status', 
			     'Import process has been run and will complete shortly.', 
			     'Please Check/Refresh your message board.'
		END
		ELSE 
		BEGIN
			IF @batch_process_id IS NULL
				EXEC spa_ErrorHandler 0,
						 'Import/Export FX',
						 'spa_ixp_rules',
						 'Success',
						 'Import Successful.',
						 ''
		END
	END TRY
	BEGIN CATCH 
		UPDATE import_data_files_audit
		SET [status] = 'e',
			elapsed_time = DATEDIFF(ss, create_ts, GETDATE())
		WHERE process_id = @process_id
		
		IF @@TRANCOUNT > 0
		   ROLLBACK
		
		IF @data_source_id IN (21400, 21402)
			SET @DESC = N'Import process failed <font color="red">(ERRORS found).</font> Failed to start import process.'		
		ELSE 
			SET @DESC = N'Fail to start import process. ( Error Description:' + ERROR_MESSAGE() + ').'
			
		SELECT @err_no = ERROR_NUMBER()
		EXEC spa_print @DESC
		INSERT INTO source_system_data_import_status (process_id, code, [module], [source], [TYPE], [description], recommendation)
		SELECT @process_id,
			  'Error',
			  'Import Data',
			  @rules_names,
			  'Data Error',
			  @DESC,
			  'Please check your ' + 
				CASE 
					WHEN @data_source_id IN (21400, 21402) THEN 'file.' 					
					ELSE 'data' + CASE WHEN @data_source_id = 21401 THEN ' source' ELSE '' END + '.'
				END
		
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_name+''''
		
		IF @flag = 'q'
			EXEC spa_ErrorHandler @err_no,
				 'Import/Export FX',
				 'spa_ixp_rules',
				 'Import Fail.',
				 @DESC,
				 ''
				 		
		SET @desc = N'<a target="_blank" href="' + @url + '">' 
					   + 'Import process could not complete. <br /> Rules Executed: ' + @rules_names + '.<br />'
					   + ' <font color="red">(ERRORS found).</font>'
					   + '</a>'
		
		IF @job_name IS NULL
			SET @job_name = 'ImportData_' + @process_id + @batch_unique_id
		
		
		IF @flag <> 'q'			   
		BEGIN
			--EXEC  spa_message_board 'u', @user_name,NULL, 'ImportData', @desc, '', '', 'e' , @job_name, NULL, @process_id, '', '', '', 'y'
			EXEC spa_ixp_notification @process_id, @ixp_rules_id, @desc, @job_name	
		END
	END CATCH	
END

ELSE IF @flag = 's'
BEGIN
	--Same code block is also used in @flag = e for Excel AddIn with out system_defined column
	SET @sql = ' SELECT sdv1.code [category],
					   ir.ixp_rules_name[Rules Name],
					   ir.ixp_rules_id [Rules ID],
					   CASE 
							WHEN ir.import_export_flag = ''e'' THEN ''Export''
							ELSE ''Import''
					   END [Rules Type],
					   CASE WHEN ir.is_system_import = ''n'' THEN ''y'' WHEN ir.is_system_import = ''y'' AND (asr.role_type_value_id = 7 OR ir.ixp_owner = ''' + @user_name + ''') THEN ''y'' ELSE ''n'' END [Updatable],
					   CASE WHEN ir.is_system_import = ''y'' THEN ''Yes'' ELSE ''No'' END [System Rule], 
					   ir.ixp_owner [Owner],
					   CASE WHEN ir.import_export_flag = ''i'' THEN sdv.code  ELSE '''' END  [Data Source],
					   CASE WHEN ir.is_system_import = ''y'' THEN ''1'' ELSE ''0'' END [system_defined]
				INTO #temp_ixp_rules
				FROM ixp_rules ir 
				INNER JOIN application_users au ON au.user_login_id = ''' + @user_name + '''
				LEFT JOIN application_role_user aru ON  aru.user_login_id = au.user_login_id
				LEFT JOIN application_security_role asr ON  asr.role_id = aru.role_id
				LEFT JOIN ixp_import_data_source iids ON iids.rules_id = ir.ixp_rules_id 
				LEFT JOIN static_data_value sdv ON iids.data_source_type = sdv.value_id
				LEFT JOIN static_data_value sdv1 ON ir.ixp_category = sdv1.value_id '				
	
	
	DECLARE @app_admin_role_check INT	
		, @ixp_admin_user BIT
		, @user_role NVARCHAR(2000)

	SET @app_admin_role_check = dbo.FNAAppAdminRoleCheck (@user_name)
	SET @ixp_admin_user = [dbo].[FNAImportAdminRoleCheck](@user_name)
	
	SELECT @user_role = COALESCE(@user_role  + ',', '') + CAST(role_id AS NVARCHAR(8)) FROM dbo.FNAGetUserRole(@user_name)
	
	SET @sql = @sql + CASE 
						   WHEN @app_admin_role_check = 1 THEN ' WHERE 1 = 1 '
						   ELSE ' INNER JOIN ipx_privileges ip 
									ON ip.import_export_id = ir.ixp_rules_id
									AND (ip.[user_id] = ''' + @user_name + ''''
										+  CASE WHEN @user_role IS NULL THEN '' ELSE ' OR ip.role_id IN (' + ISNULL(@user_role,'') + ') '  END +
									')
							  		OR ' + CAST(@ixp_admin_user AS NCHAR(1)) + ' = 1
									WHERE 1=1 '
					  END 		
		
	SET @sql = @sql + ' UNION 
						SELECT sdv1.code [category],
							   ir.ixp_rules_name[Rules Name],
							   ir.ixp_rules_id [Rules ID],
						       CASE 
						            WHEN ir.import_export_flag = ''e'' THEN ''Export''
						            ELSE ''Import''
						       END [Rules Type],
						       CASE WHEN ir.is_system_import = ''n'' THEN ''y'' WHEN ir.is_system_import = ''y'' AND (asr.role_type_value_id = 7 OR ir.ixp_owner = ''' + @user_name + ''') THEN ''y'' ELSE ''n'' END [Updatable],
						       CASE WHEN ir.is_system_import = ''y'' THEN ''Yes'' ELSE ''No'' END [System Rule],
							   ir.ixp_owner [Owner],
							   CASE WHEN ir.import_export_flag = ''i'' THEN sdv.code  ELSE '''' END  [Data Source],
							   CASE WHEN ir.is_system_import = ''y'' THEN ''1'' ELSE ''0'' END [system_defined]
						FROM   ixp_rules ir 
						INNER JOIN application_users au ON au.user_login_id = ''' + @user_name + '''
						LEFT JOIN ixp_import_data_source iids ON iids.rules_id = ir.ixp_rules_id 
						LEFT JOIN static_data_value sdv ON iids.data_source_type = sdv.value_id
						LEFT JOIN application_role_user aru ON  aru.user_login_id = au.user_login_id
						LEFT JOIN application_security_role asr ON  asr.role_id = aru.role_id
						LEFT JOIN static_data_value sdv1 ON ir.ixp_category = sdv1.value_id 
						WHERE 1 = 1 AND ir.ixp_owner = ''' + @user_name + ''''
	
	-- do not change the label	ixp_rules_id,ixp_rules_name,rule_type,updatable,system_rule,owner,data_source			
	SET @sql = @sql + '	SELECT [category] [category],
							   [Rules Name] ixp_rules_name,
	                   	       [Rules ID] ixp_rules_id,
	                   	       [Rules Type] rule_type,
	                   	       MAX([Updatable]) [updatable],
	                   	       [System Rule] system_rule,
	                   	       [Owner] owner,
	                   	       [Data Source] data_source,
							   MAX([system_defined]) system_defined
	                   	FROM   #temp_ixp_rules t'
	
	IF @active_flag = 1
	BEGIN
		SET @sql = @sql + ' INNER JOIN ixp_rules ir ON t.[Rules ID] = ir.ixp_rules_id AND ir.is_active = 1 '	
	END

	SET @sql = @sql + '	GROUP BY
							   [category],
	                   	       [Rules ID],
	                   	       [Rules Name],
	                   	       [Rules Type],
	                   	       [System Rule],
	                   	       [Owner],
	                   	       [Data Source]
						ORDER BY [Rules Name] '
	EXEC(@sql)
END
ELSE IF @flag IN ('d', 'f')
BEGIN
	BEGIN TRY
		IF OBJECT_ID('tempdb..#temp_rules_delete') IS NOT NULL
			DROP TABLE #temp_rules_delete
		
		IF @ixp_rules_name IS NOT NULL
		BEGIN
			SELECT @ixp_rules_id = ixp_rules_id FROM ixp_rules WHERE ixp_rules_name = @ixp_rules_name
		END
			
		SELECT item 
		INTO #temp_rules_delete
		FROM dbo.SplitCommaSeperatedValues(@ixp_rules_id) scsv
		
		--DELETE ixp FROM ixp_parameters ixp INNER JOIN #temp_rules_delete temp ON temp.item = ixp.ixp_rules_id
		DELETE ixp FROM ixp_custom_import_mapping ixp INNER JOIN #temp_rules_delete temp ON temp.item = ixp.ixp_rules_id 
		DELETE ixp FROM ixp_import_query_builder_import_tables ixp INNER JOIN #temp_rules_delete temp ON temp.item = ixp.ixp_rules_id 
		DELETE ixp FROM ixp_import_query_builder_relation ixp INNER JOIN #temp_rules_delete temp ON temp.item = ixp.ixp_rules_id 
		DELETE ixp FROM ixp_import_query_builder_tables ixp INNER JOIN #temp_rules_delete temp ON temp.item = ixp.ixp_rules_id	
		DELETE ixp FROM ixp_export_relation ixp INNER JOIN #temp_rules_delete temp ON temp.item = ixp.ixp_rules_id 
		DELETE ixp FROM ixp_import_where_clause ixp INNER JOIN #temp_rules_delete temp ON temp.item = ixp.rules_id 
		DELETE ixp FROM ixp_import_relation ixp INNER JOIN #temp_rules_delete temp ON temp.item = ixp.ixp_rules_id		
		DELETE ixp FROM ixp_import_data_mapping ixp INNER JOIN #temp_rules_delete temp ON temp.item = ixp.ixp_rules_id
		DELETE ixp FROM ixp_import_data_source ixp INNER JOIN #temp_rules_delete temp ON temp.item = ixp.rules_id
		DELETE ixp FROM ixp_data_mapping ixp INNER JOIN #temp_rules_delete temp ON temp.item = ixp.ixp_rules_id
		DELETE ixp FROM ixp_export_data_source ixp INNER JOIN #temp_rules_delete temp ON temp.item = ixp.ixp_rules_id
		DELETE ixp FROM ixp_export_tables ixp INNER JOIN #temp_rules_delete temp ON temp.item = ixp.ixp_rules_id
		DELETE ixp FROM ixp_import_filter ixp INNER JOIN #temp_rules_delete temp ON temp.item = ixp.ixp_rules_id

		IF @flag = 'd'
		BEGIN
			DELETE ixp FROM ixp_rules ixp INNER JOIN #temp_rules_delete temp ON temp.item = ixp.ixp_rules_id
			DELETE ixp FROM ipx_privileges ixp INNER JOIN #temp_rules_delete temp ON temp.item = ixp.import_export_id
		END

		IF @show_delete_msg = 'n'
			RETURN

		EXEC spa_ErrorHandler 0
				, 'Import/Export'
				, '[spa_ixp_rules]'
				, 'Success'
				, 'Changes have been saved successfully.'
				, ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		IF ERROR_MESSAGE() = 'CatchError'
		   SET @DESC = N'Fail to delete data ( Error Description:' + @DESC + ').'
		ELSE
		   SET @DESC = N'Fail to delete data ( Error Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'Import/Export'
			, '[spa_ixp_rules]'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END

ELSE IF @flag = 'm' OR @flag = 'n'
BEGIN
	BEGIN TRY
		DECLARE @export_table_alias NVARCHAR(200)
		DECLARE @export_table_id INT
		DECLARE @from_clause NVARCHAR(MAX)
		DECLARE @physical_name NVARCHAR(300)	
		DECLARE @physical_table_alias NVARCHAR(50)	
		DECLARE @combined_rules_name NVARCHAR(MAX)
		
		IF CURSOR_STATUS('global','export_rules_cursor')>=-1
		BEGIN
			DEALLOCATE export_rules_cursor
		END
		
		DECLARE export_rules_cursor CURSOR FOR
		SELECT scsv.item, ir.ixp_rules_name
		FROM   dbo.SplitCommaSeperatedValues(@ixp_rules_id) scsv
		INNER JOIN ixp_rules ir ON scsv.item = ir.ixp_rules_id
		
		OPEN export_rules_cursor
		FETCH NEXT FROM export_rules_cursor
		INTO @rules_id, @rules_names 
		WHILE @@FETCH_STATUS = 0
		BEGIN
			BEGIN TRY
				SELECT @combined_rules_name = COALESCE(@combined_rules_name + ' ' , '') + '<li>' + ir.ixp_rules_name + '</li>'
				FROM ixp_rules ir WHERE ir.ixp_rules_id = @rules_id
				
				INSERT import_data_files_audit (dir_path, imp_file_name, as_of_date, STATUS, elapsed_time, process_id, create_user, create_ts)
				VALUES (
					'Rules:'+ @rules_names,
					'Data export',
					GETDATE(),
					's',
					0,
					@process_id,
					@user_name,
					GETDATE()
				)
				
				IF OBJECT_ID('tempdb..#export_relations') IS NOT NULL
					DROP TABLE #export_relations
				IF OBJECT_ID('tempdb..#export_data_source') IS NOT NULL
					DROP TABLE #export_data_source
				IF OBJECT_ID('tempdb..#export_tables') IS NOT NULL
					DROP TABLE #export_tables
				IF OBJECT_ID('tempdb..#ixp_data_mapping') IS NOT NULL
					DROP TABLE #ixp_data_mapping
				IF OBJECT_ID('tempdb..#ixp_export_tables') IS NOT NULL
					DROP TABLE #ixp_export_tables
				IF OBJECT_ID('tempdb..#ixp_rules') IS NOT NULL
					DROP TABLE #ixp_rules
				IF OBJECT_ID('tempdb..#ixp_export_data_source') IS NOT NULL
					DROP TABLE #ixp_export_data_source
				IF OBJECT_ID('tempdb..#ixp_export_relation') IS NOT NULL
					DROP TABLE #ixp_export_relation
				IF OBJECT_ID('tempdb..#export_resolved_data_source') IS NOT NULL
					DROP TABLE #export_resolved_data_source
				IF OBJECT_ID('tempdb..#temp_from_column') IS NOT NULL
					DROP TABLE #temp_from_column
				IF OBJECT_ID('tempdb..#final_from_clause') IS NOT NULL
					DROP TABLE #final_from_clause
								
				CREATE TABLE #export_tables (table_id INT, table_name NVARCHAR(300) COLLATE DATABASE_DEFAULT, table_desc NVARCHAR(300) COLLATE DATABASE_DEFAULT)
				CREATE TABLE #export_data_source (data_source_id INT, export_table_id INT, export_table_alias NVARCHAR(200) COLLATE DATABASE_DEFAULT)
				CREATE TABLE #export_relations (rules_id INT, export_relation_id INT, from_data_source INT, to_data_source INT, from_column NVARCHAR(300) COLLATE DATABASE_DEFAULT, to_column NVARCHAR(300) COLLATE DATABASE_DEFAULT)
				
				SELECT * INTO #ixp_data_mapping FROM ixp_data_mapping WHERE 1 = 2
				SELECT * INTO #ixp_export_tables FROM ixp_export_tables WHERE 1 = 2
				SELECT * INTO #ixp_rules FROM ixp_rules WHERE 1 = 2	
				SELECT * INTO #ixp_export_data_source FROM ixp_export_data_source WHERE 1 = 2	
				SELECT * INTO #ixp_export_relation FROM ixp_export_relation WHERE 1 = 2					
				
				SET @sql = 'SET IDENTITY_INSERT #ixp_data_mapping ON
							INSERT INTO #ixp_data_mapping(ixp_data_mapping_id, ixp_rules_id, table_id, column_name, column_function, column_aggregation, column_filter, source_column, export_folder, export_delim, generate_script, column_alias, main_table)
							SELECT ixp_data_mapping_id, ixp_rules_id, table_id, column_name, column_function, column_aggregation, column_filter, source_column, export_folder, export_delim, generate_script, column_alias, main_table
							FROM ' + CASE WHEN @flag = 'n' THEN @ixp_data_mapping ELSE 'ixp_data_mapping' END + '
							WHERE ixp_rules_id = ' + CAST(@rules_id AS NVARCHAR(20)) + '
							SET IDENTITY_INSERT #ixp_data_mapping OFF'
				--PRINT(@sql)
				EXEC(@sql)
				
				SET @sql = 'SET IDENTITY_INSERT #ixp_export_tables ON
							INSERT INTO #ixp_export_tables (ixp_export_tables_id, ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number)
							SELECT ixp_export_tables_id, ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number 
							FROM ' + CASE WHEN @flag = 'n' THEN @ixp_export_tables ELSE 'ixp_export_tables' END + '
							WHERE ixp_rules_id = ' + CAST(@rules_id AS NVARCHAR(20)) + '
							SET IDENTITY_INSERT #ixp_export_tables OFF'
				--PRINT(@sql)
				EXEC(@sql)
				
				SET @sql = 'SET IDENTITY_INSERT #ixp_rules ON
							INSERT INTO #ixp_rules (ixp_rules_id, ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag)
							SELECT ixp_rules_id, ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag 
							FROM ' + CASE WHEN @flag = 'n' THEN @ixp_rules ELSE 'ixp_rules' END + '
							WHERE ixp_rules_id = ' + CAST(@rules_id AS NVARCHAR(20)) + '
							SET IDENTITY_INSERT #ixp_rules OFF'
				--PRINT(@sql)
				EXEC(@sql)
				
				SET @sql = 'SET IDENTITY_INSERT #ixp_export_data_source ON
							INSERT INTO #ixp_export_data_source (ixp_export_data_source_id, ixp_rules_id, export_table, export_table_alias, root_table_id)
							SELECT ixp_export_data_source_id, ixp_rules_id, export_table, export_table_alias,root_table_id
							FROM ' + CASE WHEN @flag = 'n' THEN @ixp_export_data_source ELSE 'ixp_export_data_source' END + '
							WHERE ixp_rules_id = ' + CAST(@rules_id AS NVARCHAR(20)) + '
							SET IDENTITY_INSERT #ixp_export_data_source OFF'
							
				--PRINT(@sql)
				EXEC(@sql)
				
				SET @sql = 'SET IDENTITY_INSERT #ixp_export_relation ON
							INSERT INTO #ixp_export_relation (ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source)
							SELECT ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source
							FROM ' + CASE WHEN @flag = 'n' THEN @ixp_export_relation ELSE 'ixp_export_relation' END + '
							WHERE ixp_rules_id = ' + CAST(@rules_id AS NVARCHAR(20)) + '
							SET IDENTITY_INSERT #ixp_export_relation OFF'
							
				--PRINT(@sql)
				EXEC(@sql)			
				
				INSERT INTO #export_tables (table_id, table_name, table_desc)
				SELECT table_id, table_name, table_desc
				FROM 
					(SELECT iet_dep.dependent_table_id table_id,
					        it_dep.ixp_tables_name table_name,
					        it_dep.ixp_tables_description table_desc,
					        iet_dep.dependent_table_order seq_num1,
					        -1 seq_num2,
					        ROW_NUMBER() OVER(ORDER BY iet_dep.dependent_table_order) row_num
					 FROM #ixp_export_tables iet_dep
					 INNER JOIN (SELECT DISTINCT table_id FROM #ixp_data_mapping) idm ON  idm.table_id = iet_dep.dependent_table_id
					 INNER JOIN ixp_tables it_dep ON  iet_dep.dependent_table_id = it_dep.ixp_tables_id
					 UNION ALL
					 SELECT DISTINCT iet_tables.table_id,
					       it_tables.ixp_tables_name table_name,
					       it_tables.ixp_tables_description table_desc,
					       999999 seq_num1,
					       iet_tables.sequence_number,
					       ROW_NUMBER() OVER(ORDER BY iet_tables.sequence_number) row_num
					 FROM #ixp_export_tables iet_tables
			         INNER JOIN ixp_tables it_tables ON  iet_tables.table_id = it_tables.ixp_tables_id
			         INNER JOIN (SELECT DISTINCT table_id, ixp_rules_id FROM #ixp_data_mapping) idm
			            ON  idm.table_id = iet_tables.table_id
			            AND idm.ixp_rules_id = iet_tables.ixp_rules_id
					 WHERE iet_tables.dependent_table_id IS NULL
					) a 
				ORDER BY a.seq_num1, a.seq_num2
				
				;WITH cte AS (
					SELECT ixp_export_data_source_id, ixp_rules_id, export_table, export_table_alias, ROW_NUMBER () OVER (ORDER BY ixp_export_data_source_id) rownum FROM #ixp_export_data_source WHERE root_table_id IS NULL
				)
				,cte_dataset_rel (data_source, source_id, [alias], from_alias, from_column, to_alias, to_column, relationship_level) AS ( 
					SELECT ixp_export_data_source_id, ixp_export_data_source_id source_id, export_table_alias [alias], export_table_alias [from_alias], CAST(NULL AS NVARCHAR(200)) from_column, CAST(NULL AS NVARCHAR(200)) to_alias, CAST(NULL AS NVARCHAR(200)) to_column, 0 relationship_level  FROM cte WHERE rownum = 1
					UNION ALL
					--connected dataset
					SELECT 
					ier.data_source, ier_main.ixp_export_data_source_id, ier_main.export_table_alias, ier_from.export_table_alias from_alias, CAST(ier.from_column AS NVARCHAR(200)) from_column, CAST(cdr.from_alias as NVARCHAR(200)) to_alias, CAST(ier.to_column AS NVARCHAR(200)) to_column, (cdr.relationship_level + 1) relationship_level
					FROM cte_dataset_rel cdr
					INNER JOIN #ixp_export_relation ier ON ier.to_data_source = cdr.data_source
					INNER JOIN #ixp_export_data_source ier_from ON ier.from_data_source = ier_from.ixp_export_data_source_id
					INNER JOIN #ixp_export_data_source ier_main ON ier.data_source = ier_main.ixp_export_data_source_id
				)

				SELECT @from_clause = 
						STUFF(
						(
							SELECT NCHAR(10) + (CASE WHEN MAX(relationship_level) = 0 THEN ' FROM ' ELSE ' LEFT JOIN ' END) 
								+ ' ' + QUOTENAME(MAX(cte.[table_name])) + ' ' + QUOTENAME(MAX(cte.[alias]))			--datasource [alias]
								+ ISNULL(' ON ' + MAX(join_cols), '') 		--join keys
							FROM
							(
								SELECT data_source, source_id, iet.ixp_exportable_table_name [table_name], [alias], from_alias, from_column, to_alias, to_column, MAX(relationship_level) relationship_level
								FROM cte_dataset_rel cdr
								INNER JOIN #ixp_export_data_source ieds ON cdr.data_source = ieds.ixp_export_data_source_id 
								INNER JOIN ixp_exportable_table iet ON ieds.export_table = iet.ixp_exportable_table_id 
								GROUP BY data_source, source_id, iet.ixp_exportable_table_name, [alias], from_alias, from_column, to_alias, to_column
								--ORDER BY relationship_level
							) cte
							INNER JOIN ixp_export_data_source ieds ON ieds.ixp_export_data_source_id = cte.source_id
							OUTER APPLY (
								 SELECT
								   STUFF(
				   					(  
				   					   SELECT DISTINCT ' AND ' + CAST((from_alias + '.' + QUOTENAME(from_column) + ' = ' + to_alias +  '.' + QUOTENAME(to_column)) AS NVARCHAR(MAX))
									   FROM cte_dataset_rel cdr_inner
									   WHERE cdr_inner.data_source = cte.data_source
									   FOR XML PATH(''), TYPE
								   ).value('.[1]', 'NVARCHAR(MAX)'), 1, 5, '') join_cols
							) join_key_set
							GROUP BY data_source
							ORDER BY MAX(relationship_level)
							FOR XML PATH(''), TYPE
						).value('.[1]', 'NVARCHAR(MAX)'), 1, 1, '')
				
				--PRINT('SELECT * ' +  @from_clause)
				
				SELECT @individual_script_per_object = individuals_script_per_ojbect,
					   @limit_rows_to = limit_rows_to
				FROM   #ixp_rules
				
				DECLARE @counter INT
				DECLARE @param NVARCHAR(100)
				DECLARE @total_file_number INT
				DECLARE @file_part INT
				DECLARE @from INT
				DECLARE @to INT
				DECLARE @new_table NVARCHAR(500)
				DECLARE @script_table NVARCHAR(500)
				DECLARE @nsql NVARCHAR(2000)
				DECLARE @new_process_id NVARCHAR(300)
				DECLARE @export_table_name NVARCHAR(600)
				DECLARE @generate_script NCHAR(1)
				DECLARE @insert_column_list NVARCHAR(MAX)
				DECLARE @create_column_list NVARCHAR(MAX)
				DECLARE @scripting_column_list NVARCHAR(MAX)
				DECLARE @source_column_list NVARCHAR(MAX)
				DECLARE @grouping_list NVARCHAR(MAX)
				DECLARE @file_name NVARCHAR(500)
				DECLARE @folder_path NVARCHAR(MAX)
				DECLARE @export_delim NVARCHAR(20)
									
				DECLARE export_table_cursor CURSOR FOR
				SELECT t.table_id, t.table_name, t.table_desc
				FROM #export_tables t
				
				OPEN export_table_cursor
				FETCH NEXT FROM export_table_cursor
				INTO @ixp_table_id, @table_name, @table_desc
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @insert_column_list = NULL				
					SET @source_column_list = NULL	
					SET @create_column_list = NULL			
					SET @grouping_list = NULL				
					SET @where_clause = NULL				
					SET @folder_path = NULL
					SET @export_delim = NULL
					
					SET @new_process_id = dbo.FNAGetNewID()
					SET @export_table_name = dbo.FNAProcessTableName(@table_name, @user_name , @new_process_id)
					
					SELECT @generate_script = generate_script FROM #ixp_data_mapping idm WHERE table_id = @ixp_table_id GROUP BY generate_script
					
					SELECT @insert_column_list = COALESCE(@insert_column_list + ',', '') + QUOTENAME(idm.column_alias),
						   @create_column_list = COALESCE(@create_column_list + ',', '') + QUOTENAME(idm.column_alias) + ' NVARCHAR(600) ',
						   @source_column_list = COALESCE(@source_column_list + ',', '') + CASE WHEN idm.column_function IS NOT NULL THEN idm.column_function ELSE CASE WHEN idm.column_aggregation IS NOT NULL THEN idm.column_aggregation + '(' +  idm.source_column + ')' ELSE idm.source_column END END,
						   @grouping_list = CASE WHEN idm.column_aggregation IS NOT NULL THEN @grouping_list ELSE COALESCE(@grouping_list + ',', '') +  idm.source_column END,
						   @where_clause = idm.column_filter,
						   @folder_path = idm.export_folder,
						   @export_delim = idm.export_delim
					FROM #ixp_data_mapping idm WHERE table_id = @ixp_table_id		
					
					SELECT @physical_name = iet.ixp_exportable_table_name
						  ,@physical_table_alias = ieds.export_table_alias
					FROM #ixp_data_mapping idm 
					INNER JOIN ixp_export_data_source ieds ON idm.main_table = ieds.ixp_export_data_source_id
					INNER JOIN ixp_exportable_table iet ON ieds.export_table = iet.ixp_exportable_table_id
					WHERE table_id = @ixp_table_id
					GROUP BY iet.ixp_exportable_table_name, ieds.export_table_alias
					
					IF @generate_script = 'n'
					BEGIN
						--EXEC spa_import_table_template 'd', @ixp_table_id, @new_process_id
						--PRINT('CREATE TABLE  ' + @export_table_name + ' (  ' + @create_column_list + ' )')
						EXEC('CREATE TABLE  ' + @export_table_name + ' (  ' + @create_column_list + ' )')
										
						SET @sql = 'INSERT INTO ' + @export_table_name + '(' + @insert_column_list + ')
									SELECT ' + @source_column_list + '
									' + @from_clause + '
									WHERE 1 = 1 ' + ISNULL(' AND ' + @where_clause, '') + 
									ISNULL(' GROUP BY ' + @grouping_list, '') + '							
								   '
						--PRINT(@sql)
						EXEC(@sql)
							
						--SET @data_table_name = REPLACE(@export_table_name, 'aiha_process.dbo.', '')
						SET @file_name = @folder_path + '\' + @table_desc + '_' +  @new_process_id +  '.csv'
						--PRINT @file_name
						--PRINT @export_delim
						--PRINT @data_table_name
						
						EXEC spa_dump_csv
							@data_table_name = @export_table_name,
							@file_path = @file_name,
							@compress_file = NULL,
							@delim = @export_delim,
							@is_header = '1'					
					END	
					ELSE
					BEGIN
						DECLARE @reference_table NVARCHAR(500)
						SET @reference_table = dbo.FNAProcessTableName('temp_process_table', @user_name, dbo.FNAGetNewID())
						
						IF OBJECT_ID(@reference_table) IS NOT NULL
						BEGIN
							EXEC('DROP TABLE ' + @reference_table)
						END						
						
						SET @sql = 'CREATE TABLE ' + @reference_table + ' (
										column_name        NVARCHAR(300),
										referenced_table   NVARCHAR(300),
										referenced_column  NVARCHAR(300)
									)
						
									INSERT INTO ' + @reference_table + '
									SELECT QUOTENAME(idm.column_name),
										   iet.ixp_exportable_table_name,
										   QUOTENAME(PARSENAME(REPLACE(idm.source_column, ''.'', ''.''), 1))
									FROM #ixp_data_mapping idm
									INNER JOIN #ixp_export_data_source ieds ON ieds.export_table_alias = PARSENAME(REPLACE(idm.source_column, ''.'', ''.''), 2)
									INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_id = ieds.export_table
									WHERE ieds.export_table_alias <> ''' + @physical_table_alias + ''' AND idm.table_id = ' + CAST(@ixp_table_id AS NVARCHAR(20)) + '
									'
						
						--PRINT(@sql)
						EXEC(@sql)
						
						IF OBJECT_ID('tempdb..#include_columns') IS NOT NULL
							DROP TABLE #include_columns				
						CREATE TABLE #include_columns (column_name NVARCHAR(300) COLLATE DATABASE_DEFAULT)
						
						SET @sql = 'INSERT INTO #include_columns
									SELECT ISNULL(SUBSTRING(rt.column_name,2,LEN(rt.column_name)-2), PARSENAME(REPLACE(idm.source_column, ''.'', ''.''), 1))
									FROM   #ixp_data_mapping idm
									LEFT JOIN ' + @reference_table + ' rt ON QUOTENAME(PARSENAME(REPLACE(idm.source_column, ''.'', ''.''), 1)) = rt.referenced_column
									WHERE  table_id = ' + CAST(@ixp_table_id AS NVARCHAR(10)) + '
									UNION
									SELECT c.name
									FROM   sys.columns c
									INNER JOIN sys.objects o ON  c.object_id = o.object_id
									WHERE  o.[name] = ''' + @physical_name + ''' AND c.is_nullable = 0 AND c.is_identity = 0 '
						--PRINT(@sql)
						EXEC(@sql)
						
						SET @scripting_column_list = NULL
						SELECT @scripting_column_list = COALESCE(@scripting_column_list + ',', '') + column_name
						FROM #include_columns

						--PRINT(@scripting_column_list)
						 
						DECLARE @script_process_id NVARCHAR(500)
						
						IF @individual_script_per_object = 'y'
							SET @script_process_id = dbo.FNAGetNewID()
						ELSE 
							SET @script_process_id = @process_id
							
						SET @script_table = dbo.FNAProcessTableName('export_script', @user_name, @script_process_id)
						
						IF OBJECT_ID(@script_table) IS NULL
						BEGIN
							EXEC('CREATE TABLE ' + @script_table + ' (
									query_string NVARCHAR(MAX)
							)')
						END					
							
						IF OBJECT_ID('tempdb..#export_script') IS NOT NULL
							DROP TABLE #export_script
						CREATE TABLE #export_script (query_string NVARCHAR(MAX) COLLATE DATABASE_DEFAULT)
						
						DECLARE @from_with_where NVARCHAR(MAX)
						SET @from_with_where = NULL
						SET @from_with_where = @from_clause + ' WHERE 1 = 1 ' + ISNULL(' AND ' + @where_clause, '')													
						
						--PRINT('EXEC spa_generate_insert_scripts ''' +  @physical_name + ''', @cols_to_include = ''' +  @scripting_column_list + ''', @from = ''' +   @from_with_where + ''', @reference_keys_process_table = ''' + @reference_table + ''', @parent_alias = ''' + @physical_table_alias + ''', @output_table = ''' + @script_table + '''')
						EXEC spa_generate_insert_scripts @physical_name , @cols_to_include =  @scripting_column_list, @from =  @from_with_where , @reference_keys_process_table = @reference_table, @parent_alias = @physical_table_alias, @output_table = @script_table
											
						IF @individual_script_per_object = 'y'
						BEGIN
							SET @file_part = 0
							SET @from = 0
							
							IF @limit_rows_to IS NULL
							BEGIN
								SET @file_name = @folder_path + '\' + 'InsertScripts_' + @table_desc + '_' +  @new_process_id + '.csv'
								
								EXEC spa_bcp_table_to_text_file @script_table, @file_name
							END
							ELSE
							BEGIN
								SET @file_part = 0
								SET @from = 0
								SELECT @nsql = N'SELECT @inside_counter = COUNT(query_string) FROM ' + @script_table;  
								SET @param = N'@inside_counter INT OUTPUT';
								
								EXEC sp_executesql @nsql, @param, @inside_counter=@counter OUTPUT;
								SET @total_file_number = CEILING(@counter/CAST(@limit_rows_to AS FLOAT))
								SET @to = @limit_rows_to
								
								WHILE @total_file_number <> 0
								BEGIN
									SET @file_part = @file_part + 1
									SET @file_name = @folder_path + '\' + 'InsertScripts_' + @table_desc + '_' +  @new_process_id + '_part_' + CAST(@file_part AS NVARCHAR(10)) + '.csv'
									SET @total_file_number = @total_file_number - 1
									SET @new_table = dbo.FNAProcessTableName('new_export_script', @user_name, dbo.FNAGetNewID())
									
									SET @sql = 'WITH CTE AS (
															SELECT query_string, ROW_NUMBER() OVER(ORDER BY query_string) row_num
															FROM ' + @script_table + '
														)
												SELECT query_string
												INTO ' + @new_table + '
												FROM   CTE
												WHERE  row_num > ' + CAST(@from AS NVARCHAR(10)) + '
													   AND row_num <= ' + CAST(@to AS NVARCHAR(10))
									--PRINT(@sql)
									EXEC(@sql)		
									
									SET @from = @to
									SET @to = @to + @limit_rows_to
									
									EXEC spa_bcp_table_to_text_file @new_table, @file_name
								END
							END
						END
						
						SET @sql = 'SELECT * FROM ' + @script_table
						--PRINT(@sql)
					END	  
					
					INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation, rules_name) 
					SELECT @process_id,
						   'Success',
						   'Export Data',
						   @table_name,
						   'Export Success',
						   'Data export successful for ' + @table_desc + ' .',
						   '',
						   @rules_names
					
					INSERT INTO source_system_data_import_status_detail (process_id, [source], [type], [description], type_error)
					SELECT @process_id, @table_desc, 'Export Data', 'Data export successful for ' + @table_desc + ' .', 's'
					
					FETCH NEXT FROM export_table_cursor
					INTO @ixp_table_id, @table_name, @table_desc
					
					IF @individual_script_per_object = 'n' AND OBJECT_ID(@script_table) IS NOT NULL
					BEGIN
						IF @limit_rows_to IS NULL
						BEGIN
							SET @file_name = @folder_path + '\' + 'InsertScripts_' + @table_desc + '_' +  @new_process_id + '.csv'
						END
						ELSE
						BEGIN						
							SET @file_part = 0
							SET @from = 0
							SELECT @nsql = N'SELECT @inside_counter = COUNT(query_string) FROM ' + @script_table;  
							SET @param = N'@inside_counter INT OUTPUT';
							
							EXEC sp_executesql @nsql, @param, @inside_counter=@counter OUTPUT;
							SET @total_file_number = CEILING(@counter/CAST(@limit_rows_to AS FLOAT))
							SET @to = @limit_rows_to
							
							WHILE @total_file_number <> 0
							BEGIN
								SET @file_part = @file_part + 1
								SET @file_part = CASE WHEN @total_file_number = @file_part AND @file_part = 1 THEN NULL ELSE @file_part END
								SET @file_name = @folder_path + '\' + 'InsertScripts_' + @table_desc + '_' +  @new_process_id + ISNULL('_part_' + CAST(@file_part AS NVARCHAR(10)), '') + '.csv'
								SET @total_file_number = @total_file_number - 1
								SET @new_table = dbo.FNAProcessTableName('new_export_script', @user_name, dbo.FNAGetNewID())
															
								SET @sql = 'WITH CTE AS (
														SELECT query_string, ROW_NUMBER() OVER(ORDER BY query_string) row_num
														FROM ' + @script_table + '
													)
											SELECT query_string
											INTO ' + @new_table + '
											FROM   CTE
											WHERE  row_num > ' + CAST(@from AS NVARCHAR(10)) + '
												   AND row_num <= ' + CAST(@to AS NVARCHAR(10))
								--PRINT(@sql)
								EXEC(@sql)		
								
								SET @from = @to
								SET @to = @to + @limit_rows_to
							END
						END
					END			
					
					UPDATE import_data_files_audit
					SET [status] = 's',
						elapsed_time = DATEDIFF(ss, create_ts, GETDATE())
					WHERE process_id = @process_id
					
				END
				CLOSE export_table_cursor
				DEALLOCATE export_table_cursor

				
				IF @individual_script_per_object = 'n' AND OBJECT_ID(@script_table) IS NOT NULL
				BEGIN
					IF @limit_rows_to IS NULL
						EXEC spa_bcp_table_to_text_file @script_table, @file_name
					ELSE
						EXEC spa_bcp_table_to_text_file @new_table, @file_name
				END
			END TRY
			BEGIN CATCH 
				IF CURSOR_STATUS('global','export_table_cursor')>=-1
				BEGIN
					CLOSE export_table_cursor
					DEALLOCATE export_table_cursor
				END
				
				IF @@TRANCOUNT > 0
				   ROLLBACK
			 
				SET @DESC = N'Fail to export Data ( Error Description:' + ERROR_MESSAGE() + ').'
				
				INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation, rules_name) 
				SELECT @process_id,
					   'Error',
					   'Export Data',
					   @table_name,
					   'Export Failed',
					   @DESC,
					   'Check your rules.',
					   @rules_names
				
				INSERT INTO source_system_data_import_status_detail (process_id, [source], [type], [description], type_error)
				SELECT @process_id, 'Export', 'Export Data', @DESC, 'e'
				
				UPDATE import_data_files_audit
				SET [status] = 'e',
					elapsed_time = DATEDIFF(ss, create_ts, GETDATE())
				WHERE process_id = @process_id
			END CATCH
			
			FETCH NEXT FROM export_rules_cursor
			INTO @rules_id, @rules_names
		END
		CLOSE export_rules_cursor
		DEALLOCATE export_rules_cursor
		
		SELECT @elasped_time = CONVERT(NCHAR(8),DATEADD(second,MAX(elapsed_time), 0), 108) FROM import_data_files_audit WHERE  process_id = @process_id
		
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_name+''''
		
		DECLARE @err_present NCHAR(1)
		SELECT TOP(1) @err_present = CASE WHEN ssdisd.status_id IS NULL THEN 'n' ELSE 'y' END
		FROM  source_system_data_import_status_detail ssdisd
		WHERE ssdisd.process_id = @process_id AND ssdisd.type_error = 'e'
		
		SELECT @desc = N'<a target="_blank" href="' + @url + '"><ul style="padding:0px;margin:0px;list-style-type:none;">' 
					   + '<li>Export process completed for as of date:' + dbo.FNAUserDateFormat(GETDATE(), @user_name) + '<br /> Rules Executed:<ul style="padding:0px 0px 0px 10px;margin:0px 0px 0px 10px;list-style-type:square;">' + @combined_rules_name + '<ul/></li><li>Elasped Time: ' + @elasped_time + ' mins.</li>'
					   + CASE WHEN (@err_present = 'y') THEN '</li>(ERRORS FOUND).</li></a>' ELSE '</a>' END 
		
		
		
		IF @batch_process_id IS NULL
			EXEC spa_ErrorHandler 0,
					 'Import/Export FX',
					 'spa_ixp_rules',
					 'Success',
					 'Export rules created successfully.',
					 ''
					 
		SET @batch_process_id = ISNULL(@batch_process_id, dbo.FNAGetNewID())
		SET @job_name = 'ExportData_' + @batch_process_id			 		
		EXEC spa_message_board 'u', @user_name, NULL, 'ExportData', @desc, '', '', 's', @job_name, NULL, @batch_process_id, '', '', '', 'y'
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = N'Fail to export Data ( Error Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
		
		INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation, rules_name) 
		SELECT @process_id,
			   'Error',
			   'Export Data',
			   @table_name,
			   'Export Failed',
			   @DESC,
			   'Check your rules.',
			   @rules_names
		
		INSERT INTO source_system_data_import_status_detail (process_id, [source], [type], [description], type_error)
		SELECT @process_id, 'Export', 'Export Data', @DESC, 'e'
		
		UPDATE import_data_files_audit
		SET [status] = 'e',
			elapsed_time = DATEDIFF(ss, create_ts, GETDATE())
		WHERE process_id = @process_id
		
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_name+''''
		SELECT @elasped_time = CONVERT(NCHAR(8),DATEADD(second,MAX(elapsed_time), 0), 108) FROM import_data_files_audit WHERE  process_id = @process_id
		
		SELECT @desc = N'<a target="_blank" href="' + @url + '"><ul style="padding:0px;margin:0px;list-style-type:none;">' 
					   + '<li>Export process completed for as of date:' + dbo.FNAUserDateFormat(GETDATE(), @user_name) + '<br /> Rules Executed:<ul style="padding:0px 0px 0px 10px;margin:0px 0px 0px 10px;list-style-type:square;">' + @combined_rules_name + '<ul/></li><li>Elasped Time: ' + @elasped_time + ' mins.</li>'
					   + '</li>(ERRORS FOUND).</li></a>'
		
		IF @batch_process_id IS NULL
			EXEC spa_ErrorHandler @err_no,
				 'Import/Export FX',
				 'spa_ixp_rules',
				 'Export Rules Creation Fail.',
				 @DESC,
				 ''
		SET @batch_process_id = ISNULL(@batch_process_id, dbo.FNAGetNewID())
		SET @job_name = 'ExportData_' + @batch_process_id			 		   
		EXEC spa_message_board 'u', @user_name, NULL, 'ExportData', @desc, '', '', 'e', @job_name, NULL, @batch_process_id, '', '', '', 'y'
	END CATCH	
END

ELSE IF @flag = 'z'
BEGIN
	IF OBJECT_ID('tempdb..#tmp_excel_sheets') IS NOT NULL
		DROP TABLE #tmp_excel_sheets
	CREATE TABLE #tmp_excel_sheets (sheet_name NVARCHAR(200) COLLATE DATABASE_DEFAULT)

	INSERT INTO #tmp_excel_sheets (sheet_name)
	EXEC spa_excel_sheets @server_path

	SELECT sheet_name [id], sheet_name [value] FROM #tmp_excel_sheets
END

ELSE IF @flag = 'v'
BEGIN
	SELECT @full_file_path = document_path + '\temp_Note\' + @server_path FROM connection_string
	IF @ixp_rules_id = '' OR @ixp_rules_id IS NULL
		SELECT @excel_sheet_name = excel_sheet FROM ixp_import_data_source WHERE rules_id = @ixp_rules_id

	EXEC spa_import_from_excel @full_file_path, @excel_sheet_name,@run_table, @excel_import_status  OUTPUT
END
ELSE IF @flag = 'l'
BEGIN
	SELECT @full_file_path = document_path + '\temp_Note\' + @server_path FROM connection_string
	--SELECT @full_file_path = @full_file_path + @excel_sheet_name+'.lse'

	EXEC spa_import_from_lse @full_file_path,@run_table,@lse_import_status OUTPUT
END
ELSE IF @flag = 'w'
BEGIN
	EXEC('IF OBJECT_ID(''' + @run_table + ''') IS NOT NULL
				BEGIN
	       			DROP TABLE ' + @run_table + '
				END'
		)		
	SET  @sql = 'CREATE TABLE '+@run_table +'(meter_id NVARCHAR(1000),channel INT,date DATETIME,hour NVARCHAR(5),period INT,Volume Numeric(38,20),is_dst INT)'
	EXEC(@sql)
END
ELSE IF @flag = 'g' 
BEGIN 
SET @sql = 'SELECT 	DISTINCT	   sdv1.code [category],
							   ir.ixp_rules_id [Rules ID],
							   ir.ixp_rules_name[Rules Name],
						       CASE 
						            WHEN ir.import_export_flag = ''e'' THEN ''Export''
						            ELSE ''Import''
						       END [Rules Type],
						       --CASE WHEN ir.is_system_import = ''n'' THEN ''y'' WHEN ir.is_system_import = ''y'' AND (asr.role_type_value_id = 7 OR ir.ixp_owner = ''' + @user_name + ''') THEN ''y'' ELSE ''n'' END [Updatable],
						       CASE WHEN ir.is_system_import = ''y'' THEN ''Yes'' ELSE ''No'' END [System Rule],
						       ir.ixp_owner [Owner],
							   CASE WHEN ir.import_export_flag = ''i'' THEN sdv.code  ELSE '''' END  [Data Source],
							   CASE WHEN (SELECT cast((ip.user_id) as NVARCHAR(50)) + '','' FROM ipx_privileges AS ip WHERE ip.import_export_id = ir.ixp_rules_id FOR XML PATH('''')) != ''''
							   THEN							   
							   (SELECT LEFT((SELECT cast((ip.user_id) as NVARCHAR(50)) + '','' FROM ipx_privileges AS ip WHERE ip.import_export_id = ir.ixp_rules_id FOR XML PATH('''')),LEN((SELECT cast((ip.user_id) as NVARCHAR(50)) + '','' FROM ipx_privileges AS ip WHERE ip.import_export_id = ir.ixp_rules_id FOR XML PATH(''''))) -1)) 
							   ELSE ''None''
							   END [User ID],
							   CASE WHEN (SELECT cast((ip.user_id) as NVARCHAR(50)) + '','' FROM ipx_privileges AS ip WHERE ip.import_export_id = ir.ixp_rules_id FOR XML PATH('''')) != ''''
							   THEN							   
							   (SELECT LEFT((SELECT cast((dbo.FNAGetUserName(ip.user_id)) as NVARCHAR(50)) + '','' FROM ipx_privileges AS ip WHERE ip.import_export_id = ir.ixp_rules_id FOR XML PATH('''')),LEN((SELECT cast((dbo.FNAGetUserName(ip.user_id)) as NVARCHAR(50)) + '','' FROM ipx_privileges AS ip WHERE ip.import_export_id = ir.ixp_rules_id FOR XML PATH(''''))) -1)) 
							   ELSE ''None''
							   END [User Name],
							   ISNULL((SELECT LEFT((SELECT cast((asr.role_name) as NVARCHAR(50)) + '','' FROM application_security_role asr INNER JOIN ipx_privileges ip ON asr.role_id = ip.role_id WHERE ip.import_export_id = ir.ixp_rules_id FOR XML PATH('''')),LEN((SELECT cast((asr.role_name) as NVARCHAR(50)) + '','' FROM application_security_role asr INNER JOIN ipx_privileges ip ON asr.role_id = ip.role_id WHERE ip.import_export_id = ir.ixp_rules_id FOR XML PATH(''''))) -1)), ''None'') [Role ID],
							   (SELECT LEFT((SELECT cast((asr.role_id) as NVARCHAR(50)) + '','' FROM application_security_role asr INNER JOIN ipx_privileges ip ON asr.role_id = ip.role_id WHERE ip.import_export_id = ir.ixp_rules_id FOR XML PATH('''')),LEN((SELECT cast((asr.role_id) as NVARCHAR(50)) + '','' FROM application_security_role asr INNER JOIN ipx_privileges ip ON asr.role_id = ip.role_id WHERE ip.import_export_id = ir.ixp_rules_id FOR XML PATH(''''))) -1)) [Role IDs]		  		  
				FROM   ixp_rules ir 
				INNER JOIN application_users au ON au.user_login_id = ''' + @user_name + '''
				LEFT JOIN ixp_import_data_source iids ON iids.rules_id = ir.ixp_rules_id 
				LEFT JOIN static_data_value sdv ON iids.data_source_type = sdv.value_id
				LEFT JOIN application_role_user aru ON  aru.user_login_id = au.user_login_id
				LEFT JOIN application_security_role asr ON  asr.role_id = aru.role_id
				LEFT JOIN static_data_value sdv1 ON ir.ixp_category = sdv1.value_id
				--INNER JOIN ipx_privileges ip ON ip.import_export_id = ir.ixp_rules_id
				WHERE ir.ixp_rules_id IN ('+@rule_name+') 
             
				'
	EXEC (@sql) 	 				 
END
ELSE IF @flag = 'e'
BEGIN
	DECLARE @import_admin_role int = [dbo].[FNAImportAdminRoleCheck](@user_name)
 
	-- Use by Excel add-in to list import rule, Please do not change column selection here , it will break excel add-in
	SET @sql = ' SELECT sdv1.code [category],
					   ir.ixp_rules_name[Rules Name],
					   ir.ixp_rules_id [Rules ID],
					   CASE 
							WHEN ir.import_export_flag = ''e'' THEN ''Export''
							ELSE ''Import''
					   END [Rules Type],
					   CASE WHEN ir.is_system_import = ''n'' THEN ''y'' WHEN ir.is_system_import = ''y'' AND (asr.role_type_value_id = 7 OR ir.ixp_owner = ''' + @user_name + ''') THEN ''y'' ELSE ''n'' END [Updatable],
					   CASE WHEN ir.is_system_import = ''y'' THEN ''Yes'' ELSE ''No'' END [System Rule], 
					   ir.ixp_owner [Owner],
					   ir.ixp_rule_hash  [ixp_rule_hash]
				INTO #temp_ixp_rules
				FROM ixp_rules ir 
				INNER JOIN application_users au ON au.user_login_id = ''' + @user_name + '''
				LEFT JOIN application_role_user aru ON  aru.user_login_id = au.user_login_id
				LEFT JOIN application_security_role asr ON  asr.role_id = aru.role_id
				LEFT JOIN ixp_import_data_source iids ON iids.rules_id = ir.ixp_rules_id 
				LEFT JOIN static_data_value sdv ON iids.data_source_type = sdv.value_id
				LEFT JOIN static_data_value sdv1 ON ir.ixp_category = sdv1.value_id '				
	
	
	DECLARE @app_admin_check_role INT	
	SET @app_admin_check_role = dbo.FNAAppAdminRoleCheck (@user_name)
	
	SET @sql = @sql + CASE 
						   WHEN @app_admin_check_role = 1 THEN ' WHERE 1 = 1 '
						   ELSE ' INNER JOIN ipx_privileges ip 
									ON ip.import_export_id = ir.ixp_rules_id
									AND (ip.[user_id] = ''' + @user_name + ''' OR ip.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(''' + @user_name + ''') fur))
							  		OR ' + CAST(@import_admin_role AS NVARCHAR) + ' = 1
									WHERE 1=1 '
					  END 		
		
	SET @sql = @sql + ' UNION 
						SELECT sdv1.code [category],
							   ir.ixp_rules_name[Rules Name],
							   ir.ixp_rules_id [Rules ID],
						       CASE 
						            WHEN ir.import_export_flag = ''e'' THEN ''Export''
						            ELSE ''Import''
						       END [Rules Type],
						       CASE WHEN ir.is_system_import = ''n'' THEN ''y'' WHEN ir.is_system_import = ''y'' AND (asr.role_type_value_id = 7 OR ir.ixp_owner = ''' + @user_name + ''') THEN ''y'' ELSE ''n'' END [Updatable],
						       CASE WHEN ir.is_system_import = ''y'' THEN ''Yes'' ELSE ''No'' END [System Rule],
						       ir.ixp_owner [Owner],
							   ir.ixp_rule_hash  [ixp_rule_hash]
						FROM   ixp_rules ir 
						INNER JOIN application_users au ON au.user_login_id = ''' + @user_name + '''
						LEFT JOIN ixp_import_data_source iids ON iids.rules_id = ir.ixp_rules_id 
						LEFT JOIN static_data_value sdv ON iids.data_source_type = sdv.value_id
						LEFT JOIN application_role_user aru ON  aru.user_login_id = au.user_login_id
						LEFT JOIN application_security_role asr ON  asr.role_id = aru.role_id
						LEFT JOIN static_data_value sdv1 ON ir.ixp_category = sdv1.value_id 
						WHERE 1 = 1 AND ir.ixp_owner = ''' + @user_name + ''''
	
	-- do not change the label	ixp_rules_id,ixp_rules_name,rule_type,updatable,system_rule,owner,data_source			
	SET @sql = @sql + '	SELECT [category] [category],
							   [Rules Name] ixp_rules_name,
	                   	       [Rules ID] ixp_rules_id,
	                   	       [Rules Type] rule_type,
	                   	       MAX([Updatable]) [updatable],
	                   	       [System Rule] system_rule,
	                   	       [Owner] owner,
	                   	       t.[ixp_rule_hash] IxpRuleHash
	                   	FROM   #temp_ixp_rules t'
	
	IF @active_flag = 1
	BEGIN
		SET @sql = @sql + ' INNER JOIN ixp_rules ir ON t.[Rules ID] = ir.ixp_rules_id AND ir.is_active = 1 '	
	END

	SET @sql = @sql + '	GROUP BY
							   [category],
	                   	       [Rules ID],
	                   	       [Rules Name],
	                   	       [Rules Type],
	                   	       [System Rule],
	                   	       [Owner],
	                   	       t.[ixp_rule_hash]
						ORDER BY [Rules Name] '
	EXEC(@sql)
END
ELSE IF @flag = 'c' 
BEGIN
/*
if file is uploaded for data source In (21400 flat file,21401 ,21402 xml,21404 web service,21405 excel,21406 lse)
Call flag 'c' to import data to first staging table. 
If file is not updated then take below action
excel,xml,flat file,lse data source import from folder location where source data is expected. if source files are not found then notify to user.
in case of Web Service data source, do not allow to run import job from UI without file. coz folder path is not defined in rule definition.
in case of Link Server if source file is not uploded connect link server defined in rule definition for data.

*/
	DECLARE @error_msg NVARCHAR(2000), @format_column_header_for_xml NCHAR(1) = 'n'

	IF @ixp_rules_id = ''
	BEGIN
		DECLARE @ds_sql NVARCHAR(500), @alias_sql NVARCHAR(500)
		SELECT @ds_sql = N'SELECT @ds_id = data_source_type  FROM ' + @ixp_import_data_source;
		EXEC sp_executesql @ds_sql,  N'@ds_id int OUTPUT', @ds_id=@data_source_id OUTPUT;
		
		SELECT @alias_sql = N'SELECT @alias_id = data_source_type  FROM ' + @ixp_import_data_source;
		EXEC sp_executesql @alias_sql,  N'@alias_id int OUTPUT', @alias_id = @data_source_alias OUTPUT;

	END
	ELSE
	BEGIN
		SELECT @data_source_id =   data_source_type 
			, @data_source_alias = data_source_alias
		FROM ixp_import_data_source WHERE rules_id = @ixp_rules_id
	END

	IF CHARINDEX('\', @server_path) = 0
	SELECT @full_file_path = document_path + '\temp_Note\' + @server_path FROM connection_string
	ELSE SET @full_file_path = @server_path
	
	EXEC spa_print 'Flag c block starts here. Dump source data from ',@full_file_path,' to ',@run_table	
	
	select @chk_file_exists = dbo.FNAFileExists(@full_file_path)
	IF @chk_file_exists = 0
	BEGIN
		
		SET @error_msg = 'Source file does not exists. Please check in ' + @full_file_path
		EXEC spa_print  @error_msg
	END

	IF (CHARINDEX('xls', RIGHT(@server_path,4)) > 0)
	BEGIN
		--import data from excel formatted source file to first staging table
		IF @excel_sheet_name IS NULL
		BEGIN
			IF OBJECT_ID('tempdb..#excel_sheet_list') IS NOT NULL
			DROP TABLE #excel_sheet_list
						
			CREATE TABLE #excel_sheet_list(sheet_name NVARCHAR(500) COLLATE DATABASE_DEFAULT)		

			INSERT INTO #excel_sheet_list(sheet_name)
			EXEC spa_excel_sheets @full_file_path
			--@ixp_rules_id is 1 for new rules, added for new rules setup for multipletab
			IF @ixp_rules_id <> 1
			BEGIN
				SET @excel_sheet_name = ''		

				IF EXISTS (SELECT count(1) FROM #excel_sheet_list having count(1) > 1) 		
				SELECT @excel_sheet_name =  excel_sheet FROM ixp_import_data_source WHERE rules_id = @ixp_rules_id
			END
		END
		/*
		Excel file formatted file must have column header.
		*/	

		EXEC spa_print 'EXEC spa_import_from_excel ', @full_file_path, @excel_sheet_name,@run_table
		
		--If data source is XML then rule expects source data column header without space. So replace whitespace with underscore NCHARacter. format_column_header_for_xml = 'y' is used for this purpose.
		IF @data_source_id = 21402
		SET @format_column_header_for_xml = 'y'

		EXEC spa_import_from_excel @full_file_path, @excel_sheet_name,@run_table, @excel_import_status  OUTPUT,@format_column_header_for_xml,@source_with_header
		SELECT @temp_process_table = @run_table
		
		IF @excel_import_status <> 'success'
		BEGIN
			SELECT 'dump excel data to process table' code_block , @full_file_path source_path,@excel_sheet_name sheetname, @temp_process_table stg_table ,@source_with_header has_column_headers,@excel_import_status source_data_download_status
				,case when @chk_file_exists = 1 then 'Source file exists.' ELSE 'Source file doesnot exists.' END file_exists
				
		END
	END
	ELSE IF (CHARINDEX('lse', RIGHT(@server_path,4)) > 0)
	BEGIN
		--import data from lse formatted source file to first staging table. This is not implemented yet. LSE is used by only one client for meter data import so it is defferred.
		EXEC('IF OBJECT_ID(''' + @run_table + ''') IS NOT NULL
				BEGIN
	       			DROP TABLE ' + @run_table + '
				END'
		)		
		SET  @sql = 'CREATE TABLE '+@run_table +'(meter_id NVARCHAR(1000),channel INT,date DATETIME,hour NVARCHAR(5),period INT,Volume Numeric(38,20),is_dst INT)'
	
		EXEC(@sql)
		EXEC spa_import_from_lse @full_file_path,@run_table,@a OUTPUT
		
		SELECT @temp_process_table = @run_table

		IF @a <> 'success'
		BEGIN			
			SELECT @chk_file_exists = dbo.FNAFileExists(@full_file_path)

			SELECT 'dump lse data to process table' code_block , @full_file_path source_path,@temp_process_table stg_table
				,case when @chk_file_exists = 1 then 'Source file exists.' ELSE 'Source file doesnot exists.' END file_exists
		END
		
	END
	ELSE IF (CHARINDEX('xml', RIGHT(@server_path,4)) > 0)
	BEGIN
		--import data from xml formatted source file to first staging table.

		-- This temp table is added to suppress the result set of spa_import_from_xml
		IF OBJECT_ID('tempdb..#xml_output_table') IS NOT NULL 
		DROP TABLE #xml_output_table 

		CREATE TABLE #xml_output_table (tablename NVARCHAR(1000) COLLATE DATABASE_DEFAULT)

		INSERT INTO #xml_output_table
		EXEC spa_import_from_xml NULL, @full_file_path, @run_table, 'n', @status OUTPUT

		SET @temp_process_table = @run_table
		
		IF NOT EXISTS(select 1 from #xml_output_table)
		BEGIN
			SELECT 'dump xml data to process table' code_block , @full_file_path source_path,@temp_process_table stg_table
				,case when @chk_file_exists = 1 then 'Source file exists.' ELSE 'Source file doesnot exists.' END file_exists
			 
		END
	END	
	ELSE IF (CHARINDEX('json', RIGHT(@server_path,4)) > 0)
	BEGIN
		IF CHARINDEX('\', @server_path) = 0
			SELECT @full_file_path = document_path + '\temp_Note\' + @server_path FROM connection_string
		ELSE SET @full_file_path = @server_path

		--INSERT INTO #xml_output_table
		EXEC spa_parse_json 'simple_parse', @full_file_path, '',  @run_table, '', 0
	END
	ELSE --IF (CHARINDEX('csv', RIGHT(@server_path,4)) > 0) 
	BEGIN
	
		-- import data from csv formatted source file to first staging table.
		-- If datasource of import rule is other than FLatfile and excel then valid column header is expected.
		SET @source_with_header = CASE WHEN @data_source_id NOT IN (21405,21400) THEN 'y' ELSE @source_with_header END
		
		--If data source is XML then rule expects source data column header without space. So replace whitespace with underscore NCHARacter. format_column_header_for_xml = 'y' is used for this purpose.
		IF @data_source_id = 21402
		SET @format_column_header_for_xml = 'y'
		
		--spa_import_from_csv is used for file format csv,prn,txt etc.
		EXEC spa_import_from_csv	
			@csv_file_path = @full_file_path,
			@process_table_name = @run_table,
			@delimeter = @source_delimiter,
			@row_terminator = '\n',
			@has_column_headers = @source_with_header,
			@has_fields_enclosed_in_quotes = 'n',
			@include_filename = 'n',
			@result = @source_data_download_status OUTPUT,
			@format_column_header_for_xml = @format_column_header_for_xml

			SELECT @temp_process_table = @run_table
		
		IF @source_data_download_status <> 'success'
		BEGIN
			SELECT 'dump csv data to process table' code_block , @full_file_path source_path,@temp_process_table stg_table, @source_delimiter delimiter ,@source_with_header had_header,@source_data_download_status source_data_download_status
				,case when @chk_file_exists = 1 then 'Source file exists.' ELSE 'Source file doesnot exists.' END file_exists
			
		END		
	END
END

/*
 * [To List all the import function for web services]
 */
ELSE IF @flag = '1'
BEGIN
	SET @sql = 'SELECT iids.ws_function_name [import_function] 
				INTO #temp_ixp_rules
				FROM ixp_rules ir 
				INNER JOIN application_users au ON au.user_login_id = ''' + @user_name + '''
				LEFT JOIN application_role_user aru ON  aru.user_login_id = au.user_login_id
				LEFT JOIN application_security_role asr ON  asr.role_id = aru.role_id
				LEFT JOIN ixp_import_data_source iids ON iids.rules_id = ir.ixp_rules_id '				
	
	DECLARE @user_role1 NVARCHAR(2000)
	SELECT @user_role1 = COALESCE(@user_role1  + ',', '') + CAST(role_id AS NVARCHAR(8)) FROM dbo.FNAGetUserRole(@user_name)
	
	SET @sql = @sql + CASE 
						   WHEN dbo.FNAAppAdminRoleCheck (@user_name) = 1 THEN ' WHERE 1 = 1 AND ir.is_active=1 '
						   ELSE ' INNER JOIN ipx_privileges ip 
									ON ip.import_export_id = ir.ixp_rules_id
									AND (ip.[user_id] = ''' + @user_name + ''''
										+  CASE WHEN @user_role1 IS NULL THEN '' ELSE ' OR ip.role_id IN (' + ISNULL(@user_role1,'') + ') '  END +
									')
							  		OR ' + CAST([dbo].[FNAImportAdminRoleCheck](@user_name) AS NCHAR(1)) + ' = 1
									WHERE 1=1  AND ir.is_active=1'
					  END 		
		
	SET @sql = @sql + ' UNION 
						SELECT  iids.ws_function_name [import_function] 
						FROM   ixp_rules ir 
						INNER JOIN application_users au ON au.user_login_id = ''' + @user_name + '''
						LEFT JOIN ixp_import_data_source iids ON iids.rules_id = ir.ixp_rules_id 
						LEFT JOIN static_data_value sdv ON iids.data_source_type = sdv.value_id
						LEFT JOIN application_role_user aru ON  aru.user_login_id = au.user_login_id
						LEFT JOIN application_security_role asr ON  asr.role_id = aru.role_id
						WHERE 1 = 1 AND ir.is_active=1 AND ir.ixp_owner = ''' + @user_name + ''''
	
		
	SET @sql = @sql + '	SELECT  t.import_function [import_function] 
	                   	FROM   #temp_ixp_rules t 
						WHERE NULLIF(t.import_function,'''') IS NOT NULL
						ORDER BY  t.import_function  '
	EXEC(@sql)
END

/*
 * [To list the import format for web services]
 */
ELSE IF @flag = '2'
BEGIN
	IF OBJECT_ID('tempdb..#temp_mapping') IS NOT NULL
		DROP TABLE #temp_mapping

	SELECT	RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(dm.source_column_name,CHARINDEX('.',dm.source_column_name)+1,LEN(dm.source_column_name)),'[',''),']','')))   [Key], 
			RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(dm.source_column_name,CHARINDEX('.',dm.source_column_name)+1,LEN(dm.source_column_name)),'[',''),']',''))) + 'Test' [Value] 
	INTO #temp_mapping
	FROM ixp_import_data_source ds
	LEFT JOIN ixp_import_data_mapping dm ON ds.rules_id = dm.ixp_rules_id
	WHERE ds.ws_function_name = @rule_name

	DECLARE @col_list NVARCHAR(MAX) = NULL
	SELECT @col_list = ISNULL(@col_list + '],[','[') + [Key] FROM #temp_mapping
	SET @col_list = @col_list + ']'

	SET @sql = '
	SELECT ' + @col_list + '
	FROM  
	(SELECT [Key],[Value] FROM #temp_mapping) AS Src  
	PIVOT  
	(  
		MAX([Value])  
		FOR [Key] IN (' + @col_list + ')  
	) AS Pvt;' 


	EXEC(@sql)
END


ELSE IF @flag = '3'
BEGIN
	IF OBJECT_ID('tempdb..#temp_data_source') IS NOT NULL
		DROP TABLE #temp_data_source

	CREATE TABLE #temp_data_source (
		value_id	INT,
		[code]		NVARCHAR(200) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #temp_data_source (value_id, code)
	SELECT NULL, NULL

	IF EXISTS(SELECT 1 FROM ixp_import_data_source WHERE rules_id = @ixp_rules_id AND NULLIF(folder_location,'') IS NOT NULL)
	BEGIN
		INSERT INTO #temp_data_source (value_id, code)
		SELECT 21400, 'Folder Location'
	END

	IF EXISTS(SELECT 1 FROM ixp_import_data_source WHERE rules_id = @ixp_rules_id AND NULLIF(NULLIF(ssis_package,''),0) IS NOT NULL)
	BEGIN
		INSERT INTO #temp_data_source (value_id, code)
		SELECT 21403, 'SSIS'
	END

	IF EXISTS(SELECT 1 FROM ixp_import_data_source WHERE rules_id = @ixp_rules_id AND NULLIF(NULLIF(connection_string,''),'0') IS NOT NULL)
	BEGIN
		INSERT INTO #temp_data_source (value_id, code)
		SELECT 21401, 'Link Server'
	END
	
	IF EXISTS(SELECT 1 FROM ixp_import_data_source WHERE rules_id = @ixp_rules_id AND NULLIF(NULLIF(clr_function_id,''),0) IS NOT NULL)
	BEGIN
		INSERT INTO #temp_data_source (value_id, code)
		SELECT 21407, 'CLR Functions'
	END

	IF EXISTS(SELECT 1 FROM ixp_import_data_source WHERE rules_id = @ixp_rules_id AND file_transfer_endpoint_id IS NOT NULL)
	BEGIN
		INSERT INTO #temp_data_source (value_id, code)
		SELECT -1, '(S)FTP'
	END

	IF EXISTS(SELECT 1 FROM ixp_import_data_source WHERE rules_id = @ixp_rules_id AND ISNULL(NULLIF(enable_email_import,''),'0') = '1')
	BEGIN
		INSERT INTO #temp_data_source (value_id, code)
		SELECT 21409, 'Email Import'
	END

	SELECT * FROM #temp_data_source
END

/*
 * [To show the import status for web services]
 */
ELSE IF @flag = '4'
BEGIN

	SELECT	ISNULL(NULLIF(ids.ws_function_name,''),ss.rules_name) [import_function],
			code			[status],
			[description] 	[description],
			dbo.FNADateTimeFormat(ss.create_ts,1) [import_timestamp]			
	 FROM source_system_data_import_status ss
	 LEFT JOIN ixp_rules ir ON ss.rules_name = ir.ixp_rules_name
	 LEFT JOIN ixp_import_data_source ids ON ir.ixp_rules_id = ids.rules_id
	 WHERE ss.process_id = @process_id
END

ELSE IF @flag = '5' -- create json sample file.
BEGIN
	SELECT	RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(dm.source_column_name,CHARINDEX('.',dm.source_column_name)+1,LEN(dm.source_column_name)),'[',''),']','')))   [Key], 
			RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(dm.source_column_name,CHARINDEX('.',dm.source_column_name)+1,LEN(dm.source_column_name)),'[',''),']',''))) + 'Test' [Value] 
	INTO #temp_mapping1
	FROM ixp_rules ir
	LEFT JOIN ixp_import_data_mapping dm ON ir.ixp_rules_id = dm.ixp_rules_id
	WHERE ir.ixp_rules_name = @rule_name

	SELECT @col_list = ISNULL(@col_list + '],[','[') + [Key] FROM #temp_mapping1
	SET @col_list = @col_list + ']'

	SELECT '"' + [key] + '" : "' + [value] + '"' col into #temp1 FROM #temp_mapping1

	SELECT @DESC = '{' + NCHAR(10) + NCHAR(9) + '"import_data": [' + NCHAR(10) + NCHAR(9) + NCHAR(9) + '{' + (STUFF((SELECT CAST(', ' + NCHAR(10) + NCHAR(9) + NCHAR(9) + NCHAR(9) + col AS NVARCHAR(MAX)) 
		FROM #temp1
	FOR XML PATH ('')), 1, 2, '')) + NCHAR(10) + NCHAR(9) + NCHAR(9) + '}' + NCHAR(10) + NCHAR(9) + ']' + NCHAR(10) + '}' 

	DECLARE @file_path NVARCHAR(MAX)
	SELECT @file_path = document_path + '\import_samples\' + @rule_name FROM connection_string

	DECLARE @outputvar NVARCHAR(200)
	EXEC spa_create_folder @file_path, @outputvar
	--SELECT dbo.FNAFileExists('D:\Data\sample1.json')

	SET @full_file_path = @file_path + '\' + @rule_name + '.json'
	exec spa_delete_file @full_file_path, @outputvar

	EXEC spa_write_to_file @DESC,'y', @full_file_path, @outputvar OUT
	--SELECT @outputvar

END

/*
 * [To show the import rule enabled for email import]
 */
ELSE IF @flag = '6'
BEGIN
	SELECT ixp.ixp_rules_id [Rule_ID], ixp.ixp_rules_name [Rule_Name]
	FROM ixp_import_data_source iids
	INNER JOIN ixp_rules ixp ON iids.rules_id = ixp.ixp_rules_id
	WHERE ISNULL(enable_email_import,0) = 1
END
