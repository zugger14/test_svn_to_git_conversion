IF OBJECT_ID(N'[dbo].[spa_data_import_export_rules]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_data_import_export_rules
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].spa_data_import_export_rules
	@flag				VARCHAR(200),
 	@rule_ids			VARCHAR(MAX) = NULL,
	@import_file_name	VARCHAR(MAX) = NULL,
	@copy_as			VARCHAR(MAX) = NULL		

AS
SET NOCOUNT ON;

/* DEBUG QUERY
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo

DECLARE @flag				VARCHAR(200),
 		@rule_ids			VARCHAR(MAX) = NULL,
		@import_file_name	VARCHAR(MAX) = NULL,
		@copy_as			VARCHAR(MAX) = NULL	

DECLARE @copy_as VARCHAR(max) = ''
  
SET @flag		= 'import_file_data_mapping' 
SET @import_file_name = 'Jsoncheck_2020_04_09_import.txt' 
SET @copy_as = ''

--SELECT * FROM ixp_custom_import_mapping WHERE ixp_rules_id = @rule_ids
--SELECT * FROM ixp_import_query_builder_relation WHERE ixp_rules_id = @rule_ids
--SELECT * FROM ixp_import_query_builder_import_tables WHERE ixp_rules_id = @rule_ids
--SELECT * FROM ixp_import_query_builder_tables WHERE ixp_rules_id = @rule_ids
--SELECT * FROM ixp_export_relation WHERE ixp_rules_id	= @rule_ids
--SELECT * FROM ixp_import_data_mapping WHERE ixp_rules_id = @rule_ids
--SELECT * FROM ixp_import_relation WHERE ixp_rules_id	= @rule_ids
--SELECT * FROM ixp_import_data_source WHERE rules_id = @rule_ids
--SELECT * FROM ixp_data_mapping WHERE ixp_rules_id	= @rule_ids	
--SELECT * FROM ixp_export_data_source WHERE ixp_rules_id = @rule_ids
--SELECT * FROM ixp_export_tables WHERE ixp_rules_id = @rule_ids	
--SELECT * FROM ixp_import_where_clause WHERE rules_id = @rule_ids
--SELECT * FROM  ixp_rules WHERE ixp_rules_id = @rule_ids	


--SELECT * FROM  ixp_tables  	where ixp_tables_id = 78
--SELECT * FROM  ixp_columns    	where ixp_table_id = 78
--return 
-- */



DECLARE @sql VARCHAR(MAX)
DECLARE @process_id VARCHAR(100) = dbo.FNAGetNewID()
DECLARE @json_output NVARCHAR(MAX)
DECLARE @json_final_output NVARCHAR(MAX) = '{'
DECLARE @user_name VARCHAR(1000)
DECLARE @ixp_rules									VARCHAR(1000)
DECLARE @ixp_data_mapping							VARCHAR(1000)
DECLARE @ixp_export_tables							VARCHAR(1000)
DECLARE @ixp_import_data_source						VARCHAR(1000)
DECLARE @ixp_import_data_mapping					VARCHAR(1000)
DECLARE @ixp_import_relation						VARCHAR(1000)
DECLARE @ixp_import_where_clause					VARCHAR(1000)
DECLARE @ixp_export_data_source						VARCHAR(1000)
DECLARE @ixp_export_relation						VARCHAR(1000)
DECLARE @ixp_import_query_builder_tables			VARCHAR(1000)
DECLARE @ixp_import_query_builder_relation			VARCHAR(1000)
DECLARE @ixp_custom_import_mapping					VARCHAR(1000)
DECLARE @ixp_import_query_builder_import_tables 	VARCHAR(1000)
DECLARE @ixp_parameters								VARCHAR(1000)
DECLARE @ixp_import_filter							VARCHAR(1000)
DECLARE @import_file								VARCHAR(5000)
DECLARE @ixp_tables 								VARCHAR(5000)
DECLARE @ixp_columns								VARCHAR(5000)
DECLARE @import_string	NVARCHAR(MAX) = NULL
DECLARE @table_mapping_id VARCHAR(100)
 
IF OBJECT_ID('tempdb..#ixp_rules_name') IS NOT NULL 
	DROP TABLE #ixp_rules_name

CREATE TABLE #ixp_rules_name(ixp_rules_name VARCHAR(1000) COLLATE DATABASE_DEFAULT, ixp_rules_id INT)

SELECT @import_file = document_path + '\temp_Note\' + @import_file_name
FROM connection_string

IF @flag IN('export_rule', 'export_rule_copy_as')
BEGIN
	BEGIN TRY 
	BEGIN TRAN

		SELECT TOP 1 @table_mapping_id = dest_table_id FROM ixp_import_data_mapping  WHERE ixp_rules_id = @rule_ids

		SET @sql = 'SELECT 
						isp.[ixp_parameters_id]
						, isp.[parameter_name]
						, isp.[parameter_label]
						, isp.[operator_id]
						, isp.[field_type]
						, isp.[default_value]
						, isp.[default_value2]
						, isp.[grid_name]
						, isp.[clr_function_id]
						, isp.[ssis_package]
						, isp.[validation_message]
						, isp.[insert_required]
					FROM ixp_parameters isp
					INNER JOIN ixp_import_data_source iids
					ON ISNULL(isp.ssis_package, -1) = ISNULL(iids.ssis_package, -1)
						AND ISNULL(isp.clr_function_id, -1) = ISNULL(iids.clr_function_id, -1)
					INNER JOIN dbo.FNASplit(''' + @rule_ids + ''', '','') itm ON itm.item = iids.rules_id '
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ' "ixp_parameters":' +  @json_output

		SET @sql = 'SELECT  [ixp_tables_id]
							, [ixp_tables_name]
							, [ixp_tables_description]
							, [import_export_flag]
					FROM  ixp_tables  header
					INNER JOIN dbo.FNASplit(''' + @table_mapping_id + ''', '','') itm ON itm.item = header.ixp_tables_id '
	
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "ixp_tables":' +  @json_output

		SET @sql = 'SELECT 
						[ixp_columns_id]
						, [ixp_table_id]
						, [ixp_columns_name]
						, [column_datatype]
						, [is_major]
						, [header_detail]
						, [seq]
						, [datatype]
						, [is_required]
					FROM  ixp_columns  header
					INNER JOIN dbo.FNASplit(''' + @table_mapping_id + ''', '','') itm ON itm.item = header.ixp_table_id '
	
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "ixp_columns":' +  @json_output

		SET @sql = 'SELECT 
							[ixp_import_filter_id]
							, ' + CASE WHEN @flag = 'export_rule_copy_as' THEN '-1' ELSE 'ixp_rules_id' END + ' [ixp_rules_id]
							, [filter_group]
							, [filter_id]
							, [filter_value]
							, [ixp_import_data_source]
					FROM  ixp_import_filter  header
					INNER JOIN dbo.FNASplit(''' + @rule_ids + ''', '','') itm ON itm.item = header.ixp_rules_id '
	
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "ixp_import_filter":' +  @json_output

		SET @sql = 'SELECT 
							[ixp_custom_import_mapping_id]
							, ' + CASE WHEN @flag = 'export_rule_copy_as' THEN '-1' ELSE 'ixp_rules_id' END + ' [ixp_rules_id]
							, [dest_table_id]
							, [destination_column]
							, [source_table_id]
							, [source_column]
							, [filter]
							, [default_value]
					FROM  ixp_custom_import_mapping  header
					INNER JOIN dbo.FNASplit(''' + @rule_ids + ''', '','') itm ON itm.item = header.ixp_rules_id '
	
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "ixp_custom_import_mapping":' +  @json_output
 
		SET @sql = 'SELECT 
							[ixp_import_query_builder_relation_id]
							, ' + CASE WHEN @flag = 'export_rule_copy_as' THEN '-1' ELSE 'ixp_rules_id' END + ' [ixp_rules_id]
							, [from_table_id]
							, [from_column]
							, [to_table_id]
							, [to_column]
					FROM  ixp_import_query_builder_relation header
					INNER JOIN dbo.FNASplit(''' + @rule_ids + ''', '','') itm ON itm.item = header.ixp_rules_id '
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "ixp_import_query_builder_relation":' +  @json_output

		SET @sql = 'SELECT 
						 [ixp_import_query_builder_import_tables_id]
						, ' + CASE WHEN @flag = 'export_rule_copy_as' THEN '-1' ELSE 'ixp_rules_id' END + ' [ixp_rules_id]
						, [table_id]
						, [sequence_number]
					FROM  ixp_import_query_builder_import_tables  header
					INNER JOIN dbo.FNASplit(''' + @rule_ids + ''', '','') itm ON itm.item = header.ixp_rules_id '
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "ixp_import_query_builder_import_tables":' +  @json_output

		SET @sql = 'SELECT 
							 [ixp_import_query_builder_tables_id]
							, ' + CASE WHEN @flag = 'export_rule_copy_as' THEN '-1' ELSE 'ixp_rules_id' END + ' [ixp_rules_id]
							, [tables_name]
							, [root_table_id]
							, [table_alias]					
					FROM  ixp_import_query_builder_tables  header
					INNER JOIN dbo.FNASplit(''' + @rule_ids + ''', '','') itm ON itm.item = header.ixp_rules_id '
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "ixp_import_query_builder_tables":' +  @json_output

		SET @sql = 'SELECT 
						 [ixp_export_relation_id]
						, ' + CASE WHEN @flag = 'export_rule_copy_as' THEN '-1' ELSE 'ixp_rules_id' END + ' [ixp_rules_id]
						, [from_data_source]
						, [to_data_source]
						, [from_column]
						, [to_column]
						, [data_source]
					FROM  ixp_export_relation  header
					INNER JOIN dbo.FNASplit(''' + @rule_ids + ''', '','') itm ON itm.item = header.ixp_rules_id '
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "ixp_export_relation":' +  @json_output

		SET @sql = 'SELECT 
						 [ixp_import_data_mapping_id]
						, ' + CASE WHEN @flag = 'export_rule_copy_as' THEN '-1' ELSE 'ixp_rules_id' END + ' [ixp_rules_id]
						, header.[dest_table_id]
						, header.[source_column_name]
						, header.[column_function]
						, header.[column_aggregation]
						, header.[where_clause]
						, header.[repeat_number]
						, header.[dest_column]
						, header.[udf_field_id]
						, ic.ixp_columns_name [src_col_name]
						, ic.header_detail
					FROM  ixp_import_data_mapping  header
					INNER JOIN dbo.FNASplit(''' + @rule_ids + ''', '','') itm ON itm.item = header.ixp_rules_id 
					INNER JOIN ixp_columns ic ON ic.ixp_columns_id = header.dest_column'
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "ixp_import_data_mapping":' +  @json_output

		SET @sql = 'SELECT 
						 [ixp_import_relation_id]
						, ' + CASE WHEN @flag = 'export_rule_copy_as' THEN '-1' ELSE 'ixp_rules_id' END + ' [ixp_rules_id]
						, [ixp_relation_alias]
						, [relation_source_type]
						, [connection_string]
						, [relation_location]
						, [join_clause]
						, [delimiter]
						, [excel_sheet]
					FROM  ixp_import_relation  header
					INNER JOIN dbo.FNASplit(''' + @rule_ids + ''', '','') itm ON itm.item = header.ixp_rules_id '
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "ixp_import_relation":' +  @json_output

		SET @sql = 'SELECT	
						 [ixp_import_data_source_id]
						, ' + CASE WHEN @flag = 'export_rule_copy_as' THEN '-1' ELSE 'rules_id' END + ' [rules_id]
						, [data_source_type]
						, [connection_string]
						, [data_source_location]
						, [destination_table]
						, [delimiter]
						, [source_system_id]
						, [data_source_alias]
						, [is_customized]
						, [customizing_query]
						, [is_header_less]
						, [no_of_columns]
						, [folder_location]
						, [custom_import]
						, [ssis_package]
						, [use_parameter]
						, [soap_function_id]
						, [excel_sheet]
						, [source_file_type]
						, NULL [ws_function_name]
						, [clr_function_id]
						, [enable_email_import]
						, [send_email_import_reply]
						, [file_transfer_endpoint_id]
						, [remote_directory]
					FROM  ixp_import_data_source  header
					INNER JOIN dbo.FNASplit(''' + @rule_ids + ''', '','') itm ON itm.item = header.rules_id '
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "ixp_import_data_source":' +  @json_output

		SET @sql = 'SELECT 
						 [ixp_data_mapping_id]
						, ' + CASE WHEN @flag = 'export_rule_copy_as' THEN '-1' ELSE 'ixp_rules_id' END + ' [ixp_rules_id]
						, [table_id]
						, [column_name]
						, [column_function]
						, [column_aggregation]
						, [column_filter]
						, [insert_type]
						, [enable_identity_insert]
						, [create_destination_table]
						, [source_column]
						, [export_folder]
						, [export_delim]
						, [generate_script]
						, [column_alias]
						, [main_table]
					FROM  ixp_data_mapping  header
					INNER JOIN dbo.FNASplit(''' + @rule_ids + ''', '','') itm ON itm.item = header.ixp_rules_id '
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "ixp_data_mapping":' +  @json_output

		SET @sql = 'SELECT 
					 [ixp_export_data_source_id]
					, ' + CASE WHEN @flag = 'export_rule_copy_as' THEN '-1' ELSE 'ixp_rules_id' END + ' [ixp_rules_id]
					, [export_table]
					, [export_table_alias]
					, [root_table_id]
				FROM  ixp_export_data_source  header
				INNER JOIN dbo.FNASplit(''' + @rule_ids + ''', '','') itm ON itm.item = header.ixp_rules_id '
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "ixp_export_data_source":' +  @json_output

		SET @sql = 'SELECT 
					 [ixp_export_tables_id]
					, ' + CASE WHEN @flag = 'export_rule_copy_as' THEN '-1' ELSE 'ixp_rules_id' END + ' [ixp_rules_id]
					, [table_id]
					, [dependent_table_id]
					, [sequence_number]
					, [dependent_table_order]
					, [repeat_number]
				FROM  ixp_export_tables  header
				INNER JOIN dbo.FNASplit(''' + @rule_ids + ''', '','') itm ON itm.item = header.ixp_rules_id '
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "ixp_export_tables":' +  @json_output

		SET @sql = 'SELECT 
					 [ixp_import_where_clause_id]
					, ' + CASE WHEN @flag = 'export_rule_copy_as' THEN '-1' ELSE 'rules_id' END + ' [rules_id]
					, [table_id]
					, [ixp_import_where_clause]
					, [repeat_number]
				FROM  ixp_import_where_clause  header
				INNER JOIN dbo.FNASplit(''' + @rule_ids + ''', '','') itm ON itm.item = header.rules_id '
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "ixp_import_where_clause":' +  @json_output

		SET @sql = 'SELECT 
					' + CASE WHEN @flag = 'export_rule_copy_as' THEN '-1' ELSE 'ixp_rules_id' END + ' [ixp_rules_id]
					, ' + CASE WHEN @flag = 'export_rule_copy_as' THEN  + '''' + @copy_as + ''''  ELSE 'ixp_rules_name' END + ' [ixp_rules_name]
					, [individuals_script_per_ojbect]
					, [limit_rows_to]
					, [before_insert_trigger]
					, [after_insert_trigger]
					, [import_export_flag]
					, dbo.FNAdbUser() [ixp_owner]
					, [ixp_category]
					, ''n'' [is_system_import]
					, [is_active]
					, [ixp_rule_hash]
				FROM  ixp_rules  header
				INNER JOIN dbo.FNASplit(''' + @rule_ids + ''', '','') itm ON itm.item = header.ixp_rules_id '
		EXEC spa_print @sql 
		--EXEC(@sql)

		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "ixp_rules":' +  @json_output
		
		SET @json_final_output = @json_final_output + '}'
		DECLARE @export_file_name VARCHAR(MAX)
		SELECT @export_file_name = ixp_rules_name FROM ixp_rules WHERE ixp_rules_id = @rule_ids

		SELECT REPLACE(REPLACE(@json_final_output, CHAR(13), ''), CHAR(10), '')  [json_output]
			, CASE WHEN @flag = 'export_rule_copy_as' THEN @copy_as ELSE @export_file_name END export_file_name
	COMMIT TRAN 
	END TRY 
	BEGIN CATCH 
		--SELECT ERROR_MESSAGE()
		IF @@TRANCOUNT > 0
		   ROLLBACK  
		EXEC spa_ErrorHandler -1
		   , 'Import/Export FX'
		   , 'spa_ixp_rules'
		   , 'Error'
		   , 'Error Exporting Rule'
		   , 'Contact Technical Suporrt.'   		 
	END CATCH
END 
ELSE IF @flag = 'import_file_data_mapping'
BEGIN  
    IF @copy_as = ''
		SET @copy_as = NULL

	BEGIN TRY 
	BEGIN TRAN 
		IF @import_file_name IS NOT NULL
		BEGIN
			SET @import_string = dbo.FNAReadFileContents(@import_file);
		END
		
		SET @process_id = dbo.FNAGETNEWID()
		SET @user_name = dbo.FNADBUser() 
		SET @ixp_rules								= dbo.FNAProcessTableName('ixp_rules', @user_name, @process_id)
		SET @ixp_data_mapping						= dbo.FNAProcessTableName('ixp_data_mapping', @user_name, @process_id)
		SET @ixp_export_tables						= dbo.FNAProcessTableName('ixp_export_tables', @user_name, @process_id)
		SET @ixp_import_data_source					= dbo.FNAProcessTableName('ixp_import_data_source', @user_name, @process_id)
		SET @ixp_import_data_mapping				= dbo.FNAProcessTableName('ixp_import_data_mapping', @user_name, @process_id)
		SET @ixp_import_relation					= dbo.FNAProcessTableName('ixp_import_relation', @user_name, @process_id)
		SET @ixp_import_where_clause				= dbo.FNAProcessTableName('ixp_import_where_clause', @user_name, @process_id)
		SET @ixp_export_data_source					= dbo.FNAProcessTableName('ixp_export_data_source', @user_name, @process_id) 
		SET @ixp_export_relation					= dbo.FNAProcessTableName('ixp_export_relation', @user_name, @process_id)
		SET @ixp_import_query_builder_tables		= dbo.FNAProcessTableName('ixp_import_query_builder_tables', @user_name, @process_id)
		SET @ixp_import_query_builder_relation		= dbo.FNAProcessTableName('ixp_import_query_builder_relation', @user_name, @process_id)
		SET @ixp_custom_import_mapping				= dbo.FNAProcessTableName('ixp_custom_import_mapping', @user_name, @process_id) 
		SET @ixp_import_query_builder_import_tables = dbo.FNAProcessTableName('ixp_import_query_builder_import_tables', @user_name, @process_id)
		SET @ixp_parameters							= dbo.FNAProcessTableName('ixp_parameters', @user_name, @process_id)
		SET @ixp_import_filter						= dbo.FNAProcessTableName('ixp_import_filter', @user_name, @process_id)
		SET @ixp_tables  = dbo.FNAProcessTableName('ixp_tables', @user_name, @process_id)
		SET @ixp_columns = dbo.FNAProcessTableName('ixp_columns', @user_name, @process_id)
		
		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_tables', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_tables, @return_output = 0
	
		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_columns', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_columns, @return_output = 0
	
		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_rules', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_rules, @return_output = 0
	
		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_data_mapping', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_data_mapping, @return_output = 0

		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_export_tables', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_export_tables, @return_output = 0

		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_import_data_source', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_import_data_source, @return_output = 0

		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_import_data_mapping', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_import_data_mapping, @return_output = 0

		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_import_relation', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_import_relation, @return_output = 0

		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_import_where_clause', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_import_where_clause, @return_output = 0

		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_export_data_source', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_export_data_source, @return_output = 0

		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_export_relation', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_export_relation, @return_output = 0

		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_import_query_builder_tables', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_import_query_builder_tables, @return_output = 0

		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_custom_import_mapping', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_custom_import_mapping, @return_output = 0

		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_import_query_builder_relation', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_import_query_builder_relation, @return_output = 0

		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_import_query_builder_import_tables', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_import_query_builder_import_tables, @return_output = 0

		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_parameters', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_parameters, @return_output = 0
		
		EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_import_filter', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_import_filter, @return_output = 0
 
		SET @sql = 	'IF OBJECT_ID(''' + @ixp_rules + ''') IS NULL SELECT *  INTO ' + @ixp_rules + ' FROM ixp_rules WHERE 1 = 2'
		SET @sql = @sql + ' IF OBJECT_ID(''' + @ixp_data_mapping + ''') IS NULL SELECT *  INTO ' + @ixp_data_mapping + ' FROM ixp_data_mapping WHERE 1 = 2'
		SET @sql = @sql + ' IF OBJECT_ID(''' + @ixp_export_tables + ''') IS NULL SELECT *  INTO ' + @ixp_export_tables + ' FROM ixp_export_tables WHERE 1 = 2'
		SET @sql = @sql + ' IF OBJECT_ID(''' + @ixp_import_data_source + ''') IS NULL SELECT *  INTO ' + @ixp_import_data_source + ' FROM ixp_import_data_source WHERE 1 = 2'
		SET @sql = @sql + ' IF OBJECT_ID(''' + @ixp_import_data_mapping + ''') IS NULL SELECT *  INTO ' + @ixp_import_data_mapping + ' FROM ixp_import_data_mapping WHERE 1 = 2'
		SET @sql = @sql + ' IF OBJECT_ID(''' + @ixp_import_relation + ''') IS NULL SELECT *  INTO ' + @ixp_import_relation + ' FROM ixp_import_relation WHERE 1 = 2'
		SET @sql = @sql + ' IF OBJECT_ID(''' + @ixp_import_where_clause + ''') IS NULL SELECT *  INTO ' + @ixp_import_where_clause + ' FROM ixp_import_where_clause WHERE 1 = 2'
		SET @sql = @sql + ' IF OBJECT_ID(''' + @ixp_export_data_source + ''') IS NULL SELECT *  INTO ' + @ixp_export_data_source + ' FROM ixp_export_data_source WHERE 1 = 2'
		SET @sql = @sql + ' IF OBJECT_ID(''' + @ixp_export_relation + ''') IS NULL SELECT *  INTO ' + @ixp_export_relation + ' FROM ixp_export_relation WHERE 1 = 2'
		SET @sql = @sql + ' IF OBJECT_ID(''' + @ixp_import_query_builder_tables + ''') IS NULL SELECT *  INTO ' + @ixp_import_query_builder_tables + ' FROM ixp_import_query_builder_tables WHERE 1 = 2'
		SET @sql = @sql + ' IF OBJECT_ID(''' + @ixp_import_query_builder_relation + ''') IS NULL SELECT *  INTO ' + @ixp_import_query_builder_relation + ' FROM ixp_import_query_builder_relation WHERE 1 = 2'
		SET @sql = @sql + ' IF OBJECT_ID(''' + @ixp_custom_import_mapping + ''') IS NULL SELECT *  INTO ' + @ixp_custom_import_mapping + ' FROM ixp_custom_import_mapping WHERE 1 = 2'
		SET @sql = @sql + ' IF OBJECT_ID(''' + @ixp_import_query_builder_import_tables + ''') IS NULL SELECT *  INTO ' + @ixp_import_query_builder_import_tables + ' FROM ixp_import_query_builder_import_tables WHERE 1 = 2'
		SET @sql = @sql + ' IF OBJECT_ID(''' + @ixp_parameters + ''') IS NULL SELECT *  INTO ' + @ixp_parameters + ' FROM ixp_parameters WHERE 1 = 2'
		SET @sql = @sql + ' IF OBJECT_ID(''' + @ixp_import_filter + ''') IS NULL SELECT *  INTO ' + @ixp_import_filter + ' FROM ixp_import_filter WHERE 1 = 2'
		SET @sql = @sql + ' IF OBJECT_ID(''' + @ixp_tables + ''') IS NULL SELECT * INTO ' + @ixp_tables + ' FROM ixp_tables WHERE 1 = 2'
		SET @sql = @sql + ' IF OBJECT_ID(''' + @ixp_columns + ''') IS NULL SELECT * INTO ' + @ixp_columns + ' FROM ixp_columns WHERE 1 = 2'
		SET @sql = @sql + ' UPDATE ' + @ixp_columns +  ' SET header_detail = NULL WHERE header_detail = '''''
		SET @sql = @sql + ' UPDATE ' + @ixp_import_data_mapping + ' SET column_function = NULL WHERE column_function = '''''
		SET @sql = @sql + ' UPDATE ' + @ixp_import_data_mapping + ' SET column_aggregation = NULL WHERE column_aggregation = '''''

		EXEC spa_print @sql
 		EXEC(@sql)
		
		SET @sql = ' IF OBJECT_ID(''' + @ixp_import_data_source + ''') IS NOT NULL
			UPDATE a SET a.folder_location = ids.folder_location, a.file_transfer_endpoint_id = ids.file_transfer_endpoint_id
				, a.remote_directory = ids.remote_directory
			FROM ' + @ixp_import_data_source + ' a INNER JOIN ixp_import_data_source ids ON a.rules_id = ids.rules_id'
		EXEC(@sql)

		SET @sql =  'IF COL_LENGTH(''' + @ixp_import_data_mapping + ''', ''src_col_name'') IS NULL
					BEGIN
						ALTER TABLE ' + @ixp_import_data_mapping + '
						ADD src_col_name VARCHAR(MAX)
					END '

		EXEC spa_print @sql
 		EXEC(@sql)

		SET @sql =  'IF COL_LENGTH(''' + @ixp_import_data_mapping + ''', ''header_detail'') IS NULL
					BEGIN
						ALTER TABLE ' + @ixp_import_data_mapping + '
						ADD header_detail VARCHAR(MAX)
					END '

		EXEC spa_print @sql
 		EXEC(@sql)

		IF OBJECT_ID('tempdb..#ixp_tables') IS NOT NULL 
			DROP TABLE #ixp_tables

		IF OBJECT_ID('tempdb..#new_ixp_tables') IS NOT NULL 
			DROP TABLE #new_ixp_tables
 
		CREATE TABLE #ixp_tables (import_export_flag CHAR(1) COLLATE DATABASE_DEFAULT, ixp_tables_description VARCHAR(1000) COLLATE DATABASE_DEFAULT, ixp_tables_id INT, ixp_tables_name VARCHAR(1000) COLLATE DATABASE_DEFAULT)
	 	CREATE TABLE #new_ixp_tables (ixp_tables_id INT, ixp_tables_name VARCHAR(1000) COLLATE DATABASE_DEFAULT)
	 
		SET @sql = 'INSERT INTO #ixp_tables
					SELECT import_export_flag, ixp_tables_description, ixp_tables_id, ixp_tables_name 
					FROM ' + @ixp_tables

		EXEC spa_print @sql
 		EXEC(@sql)

		--merge table definition
		MERGE ixp_tables AS stm
		USING (SELECT import_export_flag,	ixp_tables_description,	ixp_tables_id,	ixp_tables_name 
				FROM #ixp_tables) AS sd ON stm.ixp_tables_name = sd.ixp_tables_name
 		WHEN MATCHED THEN UPDATE
		SET 
			stm.import_export_flag = sd.import_export_flag					 
			, stm.ixp_tables_description = sd.ixp_tables_description	 
			, stm.ixp_tables_name = sd.ixp_tables_name 
		WHEN NOT MATCHED THEN
		INSERT(import_export_flag, ixp_tables_description, ixp_tables_name )
		VALUES(sd.import_export_flag, sd.ixp_tables_description, sd.ixp_tables_name )
		OUTPUT INSERTED.ixp_tables_id, INSERTED.ixp_tables_name INTO #new_ixp_tables;

		--update column wiht new ids
		SET @sql = 'UPDATE a 
					SET a.ixp_table_id = z.ixp_tables_id
					FROM ' + @ixp_columns + ' a 
					CROSS APPLY (SELECT ixp_tables_id FROM #new_ixp_tables) z '
		EXEC spa_print @sql
 		EXEC(@sql)

		SET @sql = 'UPDATE a 
					SET a.table_id = z.ixp_tables_id
					FROM ' + @ixp_import_where_clause + ' a 
					CROSS APPLY (SELECT ixp_tables_id FROM #new_ixp_tables) z '
		EXEC spa_print @sql
 		EXEC(@sql)

		SET @sql = 'UPDATE a 
					SET a.table_id = z.ixp_tables_id
					FROM ' + @ixp_export_tables + ' a 
					CROSS APPLY (SELECT ixp_tables_id FROM #new_ixp_tables) z '
		EXEC spa_print @sql
 		EXEC(@sql)
				
		IF OBJECT_ID('tempdb..#new_ixp_columns') IS NOT NULL 
			DROP TABLE #new_ixp_columns
 
		CREATE TABLE #new_ixp_columns (ixp_table_id INT, ixp_columns_id INT, ixp_columns_name VARCHAR(1000) COLLATE DATABASE_DEFAULT, header_detail CHAR(1) COLLATE DATABASE_DEFAULT)

		 --EXEC('SELECT ixp_table_id
			--					, ixp_columns_name
			--					, column_datatype
			--					, is_major
			--					, header_detail
			--					, seq
			--					, datatype
			--					, is_required
			--		FROM ' + @ixp_columns )

		SET @sql = ' 
					MERGE ixp_columns AS stm
					USING (SELECT ixp_table_id
								, ixp_columns_name
								, column_datatype
								, is_major
								, header_detail
								, seq
								, datatype
								, is_required
					FROM ' + @ixp_columns + ') AS sd ON stm.ixp_columns_name = sd.ixp_columns_name
						AND stm.ixp_table_id = sd.ixp_table_id
						AND ISNULL(stm.header_detail, '''') = ISNULL(sd.header_detail, '''')
 					WHEN MATCHED THEN UPDATE
					SET 
						stm.column_datatype	= sd.column_datatype
						, stm.is_major		= sd.is_major
						, stm.header_detail	= sd.header_detail
						, stm.seq			= sd.seq
						, stm.datatype		= sd.datatype
						, stm.is_required	= sd.is_required
					WHEN NOT MATCHED THEN
					INSERT(ixp_table_id
								, ixp_columns_name
								, column_datatype
								, is_major
								, header_detail
								, seq
								, datatype
								, is_required)
					VALUES(sd.ixp_table_id
						, sd.ixp_columns_name
						, sd.column_datatype
						, sd.is_major
						, sd.header_detail
						, sd.seq
						, sd.datatype
						, sd.is_required)
					OUTPUT INSERTED.ixp_table_id, INSERTED.ixp_columns_id, INSERTED.ixp_columns_name, INSERTED.header_detail INTO #new_ixp_columns;
					'
		EXEC spa_print @sql
		EXEC(@sql) 

		SET @sql = '
					--select * 
					UPDATE b
					SET b.dest_table_id = ixp_table_id
						, b.dest_column = a.ixp_columns_id
					FROM #new_ixp_columns a
					INNER JOIN ' + @ixp_import_data_mapping + ' b ON a.ixp_columns_name = b.src_col_name 
						AND ISNULL(a.header_detail, '''') = ISNULL(b.header_detail, '''') '

		EXEC spa_print @sql
		EXEC(@sql) 

		IF @copy_as IS NOT NULL 
		BEGIN 
			SET @sql = 'UPDATE ' + @ixp_rules + ' SET ixp_rules_name = ''' + @copy_as + '''' 
			EXEC spa_print @sql
 			EXEC(@sql)
		END

		SET @sql = 'INSERT INTO #ixp_rules_name(ixp_rules_name, ixp_rules_id)
					SELECT ir.ixp_rules_name, ir.ixp_rules_id 
					FROM ' + @ixp_rules + ' a
					INNER JOIN ixp_rules ir ON ir.ixp_rules_name = a.ixp_rules_name 
					WHERE 1 = 1'

		EXEC spa_print @sql
 		EXEC(@sql)

		DECLARE @to_import_ixp_rules_id INT = NULL

		IF EXISTS(SELECT 1 FROM #ixp_rules_name)
		BEGIN
			SELECT @to_import_ixp_rules_id = ixp_rules_id FROM #ixp_rules_name
		END 
		ELSE
		BEGIN 
			SELECT @to_import_ixp_rules_id = -1		
		END 

		SET @sql = 'UPDATE ' + @ixp_rules										+ ' SET ixp_rules_id = ' + CAST(@to_import_ixp_rules_id AS VARCHAR(50))
		SET @sql = @sql + ' UPDATE ' + @ixp_data_mapping						+ ' SET ixp_rules_id = ' + CAST(@to_import_ixp_rules_id AS VARCHAR(50))
		SET @sql = @sql + ' UPDATE ' + @ixp_export_tables						+ ' SET ixp_rules_id = ' + CAST(@to_import_ixp_rules_id AS VARCHAR(50))
		SET @sql = @sql + ' UPDATE ' + @ixp_import_data_source					+ ' SET rules_id = ' + CAST(@to_import_ixp_rules_id AS VARCHAR(50))
		SET @sql = @sql + ' UPDATE ' + @ixp_import_data_mapping					+ ' SET ixp_rules_id = ' + CAST(@to_import_ixp_rules_id AS VARCHAR(50))
		SET @sql = @sql + ' UPDATE ' + @ixp_import_relation						+ ' SET ixp_rules_id = ' + CAST(@to_import_ixp_rules_id AS VARCHAR(50))
		SET @sql = @sql + ' UPDATE ' + @ixp_import_where_clause					+ ' SET rules_id = ' + CAST(@to_import_ixp_rules_id AS VARCHAR(50))
		SET @sql = @sql + ' UPDATE ' + @ixp_export_data_source					+ ' SET ixp_rules_id = ' + CAST(@to_import_ixp_rules_id AS VARCHAR(50))
		SET @sql = @sql + ' UPDATE ' + @ixp_export_relation						+ ' SET ixp_rules_id = ' + CAST(@to_import_ixp_rules_id AS VARCHAR(50))
		SET @sql = @sql + ' UPDATE ' + @ixp_import_query_builder_tables			+ ' SET ixp_rules_id = ' + CAST(@to_import_ixp_rules_id AS VARCHAR(50))
		SET @sql = @sql + ' UPDATE ' + @ixp_import_query_builder_relation		+ ' SET ixp_rules_id = ' + CAST(@to_import_ixp_rules_id AS VARCHAR(50))
		SET @sql = @sql + ' UPDATE ' + @ixp_custom_import_mapping				+ ' SET ixp_rules_id = ' + CAST(@to_import_ixp_rules_id AS VARCHAR(50))
		SET @sql = @sql + ' UPDATE ' + @ixp_import_query_builder_import_tables 	+ ' SET ixp_rules_id = ' + CAST(@to_import_ixp_rules_id AS VARCHAR(50))
 		SET @sql = @sql + ' UPDATE ' + @ixp_import_filter 						+ ' SET ixp_rules_id = ' + CAST(@to_import_ixp_rules_id AS VARCHAR(50))
		SET @sql = @sql + ' UPDATE ' + @ixp_export_tables						+ ' SET dependent_table_id = NULL WHERE dependent_table_id = '''''
		SET @sql = @sql + ' UPDATE ' + @ixp_import_relation						+ ' SET connection_string = NULL WHERE connection_string = '''''

		EXEC spa_print @sql
 		EXEC(@sql) 
		
		DECLARE @server_path VARCHAR(MAX)
		SELECT @server_path = document_path + '\temp_Note'
		FROM connection_string

		--EXEC('select * from ' + @ixp_import_data_source)	
		--rollback tran return 
		--EXEC('select * from ' + @ixp_export_tables)					

 		EXEC spa_ixp_rules  
			@flag = 'p'
			, @ixp_rules_id = @to_import_ixp_rules_id
			, @run_rules = 'n'
			, @server_path = @import_file
			, @import_export_flag = 'i'
			, @process_id = @process_id
			, @encrypt_password = 1
			 
		/*
 
		EXEC('select * from ' + @ixp_rules)							
		EXEC('select * from ' + @ixp_data_mapping)						
		EXEC('select * from ' + @ixp_export_tables)					
		EXEC('select * from ' + @ixp_import_data_source)					
		EXEC('select * from ' + @ixp_import_data_mapping)				
		EXEC('select * from ' + @ixp_import_relation)					
		EXEC('select * from ' + @ixp_import_where_clause)				
		EXEC('select * from ' + @ixp_export_data_source)					
		EXEC('select * from ' + @ixp_export_relation)					
		EXEC('select * from ' + @ixp_import_query_builder_tables)		
		EXEC('select * from ' + @ixp_import_query_builder_relation	)	
		EXEC('select * from ' + @ixp_custom_import_mapping	)			
		EXEC('select * from ' + @ixp_import_query_builder_import_tables) 
		EXEC('select * from ' + @ixp_parameters)
		EXEC('select * from ' + @ixp_tables)
		EXEC('select * from ' + @ixp_columns)
 
		--*/
	COMMIT TRAN 
	END TRY 
	BEGIN CATCH 
		--SELECT ERROR_MESSAGE()
		IF @@TRANCOUNT > 0
		   ROLLBACK TRAN
		
		EXEC spa_ErrorHandler -1
		   , 'Import/Export Rules'
		   , 'spa_ixp_rules'
		   , 'Error'
		   , 'Error Importing Rules'
		   , 'Contact Technical Suporrt.'   
		 
	END CATCH
END
IF @flag = 'confirm_override'
BEGIN 
	IF @copy_as = ''
		SET @copy_as = NULL 

	IF @import_file_name IS NOT NULL
	BEGIN
		SET @import_string = dbo.FNAReadFileContents(@import_file);	
	END

	SET @ixp_rules = dbo.FNAProcessTableName('ixp_rules', @user_name, @process_id)
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'ixp_rules', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @ixp_rules, @return_output = 0 

	SET @sql = 'INSERT INTO #ixp_rules_name(ixp_rules_name, ixp_rules_id)
				SELECT ir.ixp_rules_name, ir.ixp_rules_id 
				FROM ' + @ixp_rules + ' a
				INNER JOIN ixp_rules ir ON ir.ixp_rules_name = ' + CASE WHEN @copy_as IS NOT NULL THEN '''' + @copy_as + ''''  ELSE 'a.ixp_rules_name ' END + '
				WHERE 1 = 1'

	EXEC spa_print @sql
 	EXEC(@sql)

	IF EXISTS(SELECT 1 FROM #ixp_rules_name)
	BEGIN 
		SELECT 'r' confirm_override, @import_file_name import_file_name, @copy_as copy_as  --confirmation requried
	END 
	ELSE 
	BEGIN 
		SELECT 'n' confirm_override, @import_file_name import_file_name, @copy_as copy_as --confirmation not requried
	END
END
GO
