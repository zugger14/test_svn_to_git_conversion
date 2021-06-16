IF OBJECT_ID(N'[dbo].[spa_workflow_import_export]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_workflow_import_export]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

 /**
	Import Export Workflow and Workflow Module Mapping

	Parameters :
	@flag : Flag
			'export_definitions' -- Export the JSON file having Module Mapping data
			'import_definitions' -- Create the module mapping based on JSON import file
			'export_workflow' -- Export the JSON file having Workflow data
			'copy_workflow' -- Make a copy of the workflow
			'import_workflow' -- Create the workflow based on JSON import file
	@module_id : static_data_values - type_id = 20600
	@import_string : JSON data String to import
	@import_file : JSON Filename
	@import_type : Not in Use
	@module_event_id : module_events_id Filter (module_events_id FROM module_events)
	@workflow_group_id : Workflow Group ID of the workflow
	@import_as : Import Workflow As given value
 */

CREATE PROCEDURE [dbo].[spa_workflow_import_export]
	@flag			VARCHAR(200),
	@module_id		INT = NULL,
	@import_string	NVARCHAR(MAX) = NULL,
	@import_file	VARCHAR(2000) = NULL,
	@import_type	VARCHAR(100) = NULL,
	@module_event_id	VARCHAR(200) = NULL,
	@workflow_group_id	INT = NULL,
	@import_as		VARCHAR(100) = NULL
AS

/* DEBUG SP
DECLARE
	@flag			VARCHAR(200),
	@module_id		INT = NULL,
	@import_string	NVARCHAR(MAX) = NULL,
	@import_file	VARCHAR(2000) = NULL,
	@import_type	VARCHAR(100) = NULL,
	@module_event_id	VARCHAR(200) = NULL,
	@workflow_group_id	INT = NULL

SELECT @flag = 'import_definitions', @import_file = 'EOD_import.txt'

--*/

SET NOCOUNT ON;

DECLARE @sql VARCHAR(MAX)
DECLARE @process_id VARCHAR(100) = dbo.FNAGetNewID()
DECLARE @json_output NVARCHAR(MAX)
DECLARE @json_final_output NVARCHAR(MAX) = '{'
DECLARE @import_file_name VARCHAR(2000) = @import_file
SELECT @import_file = document_path + '\temp_Note\' + @import_file
FROM connection_string
SET @import_as = NULLIF(@import_as,'')

IF @flag = 'export_definitions'
BEGIN
	
	/*
	 * MODULE_EVENT_MAPPING
	 */
	SET @sql = '
	SELECT	[module_id],
			[event_id],
			[is_active] 
	FROM workflow_module_event_mapping
	WHERE module_id = ' + CAST(@module_id AS VARCHAR)
		
	EXEC spa_build_json @sql, '', @json_output OUTPUT
	SET @json_final_output = @json_final_output + ' "module_event_mapping":'+  @json_output
	
	/*
	 * ALERT_TABLE_DEFINITION
	 */
	SET @sql = '
	SELECT	[logical_table_name],
			[physical_table_name],
			ISNULL([is_action_view],''n'') [is_action_view],
			ISNULL([primary_column],'''') [primary_column]
	FROM alert_table_definition atd
	INNER JOIN workflow_module_rule_table_mapping mp ON atd.alert_table_definition_id = mp.rule_table_id
	WHERE module_id = ' + CAST(@module_id AS VARCHAR)
		
	EXEC spa_build_json @sql, '', @json_output OUTPUT
	SET @json_final_output = @json_final_output + ', "alert_table_definition":'+  @json_output
	
	/*
	 * MODULE_RULE_TABLE_MAPPING
	 */
	SET @sql = '
	SELECT	[module_id],
			[logical_table_name],
			[is_active]
	FROM alert_table_definition atd
	INNER JOIN workflow_module_rule_table_mapping mp ON atd.alert_table_definition_id = mp.rule_table_id
	WHERE module_id = ' + CAST(@module_id AS VARCHAR)
		
	EXEC spa_build_json @sql, '', @json_output OUTPUT
	SET @json_final_output = @json_final_output + ', "module_rule_table_mapping":'+  @json_output

	/*
	 * WORKFLOW_MESSAGE_TAG
	 */
	SET @sql = '
	SELECT	[workflow_message_tag_name],
			[workflow_message_tag],
			[module_id],
			dbo.FNAEncodeXML([workflow_tag_query]) [workflow_tag_query],
			[system_defined],
			[is_hyperlink],
			[application_function_id] 
	FROM workflow_message_tag
	WHERE module_id = ' + CAST(@module_id AS VARCHAR)
		
	EXEC spa_build_json @sql, '', @json_output OUTPUT
	SET @json_final_output = @json_final_output + ', "workflow_message_tag":'+  @json_output

	/*
	 * WORKFLOW_CONTACTS
	 */
	SET @sql = '
	SELECT	[workflow_contacts_id],
			[module_id],
			[email_group],
			[email_group_query],
			[group_type],
			[email_address_query]  
	FROM workflow_contacts
	WHERE module_id = ' + CAST(@module_id AS VARCHAR)
		
	EXEC spa_build_json @sql, '', @json_output OUTPUT
	SET @json_final_output = @json_final_output + ', "workflow_contacts":'+  @json_output
	
	SET @json_final_output = @json_final_output + '}'
	SELECT REPLACE(REPLACE(@json_final_output, CHAR(13), ''), CHAR(10), '') [json_output]
END

ELSE IF @flag = 'import_definitions'
BEGIN
BEGIN TRAN
BEGIN TRY
	DECLARE @module_event_mapping_table VARCHAR(200) = 'adiha_process.dbo.module_event_mapping_table_' + @process_id
	DECLARE @alert_table_definition_table VARCHAR(200) = 'adiha_process.dbo.alert_table_definition_table_' + @process_id
	DECLARE @module_rule_table_mapping_table VARCHAR(200) = 'adiha_process.dbo.module_rule_table_mapping_table_' + @process_id
	DECLARE @workflow_message_tag_table VARCHAR(200) = 'adiha_process.dbo.workflow_message_tag_table_' + @process_id
	DECLARE @workflow_contacts_table VARCHAR(200) = 'adiha_process.dbo.workflow_contacts_table_' + @process_id

	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'module_event_mapping', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @module_event_mapping_table, @return_output = 0
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'alert_table_definition', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @alert_table_definition_table, @return_output = 0
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'module_rule_table_mapping', @json_string = @import_string, @json_full_path=@import_file,@output_process_table = @module_rule_table_mapping_table, @return_output = 0
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'workflow_message_tag', @json_string = @import_string, @json_full_path=@import_file,@output_process_table = @workflow_message_tag_table, @return_output = 0
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'workflow_contacts', @json_string = @import_string, @json_full_path=@import_file,@output_process_table = @workflow_contacts_table, @return_output = 0


	SET @sql = '
	DECLARE @module_id VARCHAR(10) = ''''

	IF (OBJECT_ID(N''' + @alert_table_definition_table + ''', N''U'') IS NOT NULL) 
	BEGIN
		SELECT @module_id = module_id FROM ' + @module_event_mapping_table + '

		DELETE me
		FROM workflow_module_event_mapping me
		WHERE me.module_id = (
			SELECT DISTINCT module_id FROM ' + @module_event_mapping_table + '
		)

		INSERT INTO workflow_module_event_mapping ([module_id], [event_id], [is_active])
		SELECT	tmp.[module_id],
				tmp.[event_id],
				tmp.[is_active]  
		FROM ' + @module_event_mapping_table + ' tmp
	END

	IF (OBJECT_ID(N''' + @alert_table_definition_table + ''', N''U'') IS NOT NULL) 
	BEGIN
		INSERT INTO alert_table_definition ([logical_table_name], [physical_table_name], [is_action_view], [primary_column])
		SELECT	tmp.[logical_table_name],
				tmp.[physical_table_name],
				tmp.[is_action_view],
				tmp.[primary_column]
		FROM ' + @alert_table_definition_table + ' tmp
		LEFT JOIN alert_table_definition atd ON tmp.physical_table_name = atd.physical_table_name AND tmp.logical_table_name = atd.logical_table_name
		WHERE atd.alert_table_definition_id IS NULL

		DELETE atdc
		FROM alert_table_definition atd
		INNER JOIN alert_columns_definition atdc ON atdc.alert_table_id =  atd.alert_table_definition_id
		INNER JOIN workflow_module_rule_table_mapping mp On atd.alert_table_definition_id = mp.rule_table_id
		LEFT JOIN ' + @alert_table_definition_table + ' tmp ON tmp.physical_table_name = atd.physical_table_name AND tmp.logical_table_name = atd.logical_table_name
		WHERE tmp.logical_table_name IS NULL AND 
			mp.module_id = (SELECT DISTINCT module_id FROM ' + @module_rule_table_mapping_table + ')
		
		IF OBJECT_ID(''tempdb..#temp_delete_alert_table_definition'') IS NOT NULL
			DROP TABLE #temp_delete_alert_table_definition

		SELECT atd.* INTO #temp_delete_alert_table_definition
		FROM alert_table_definition atd
		INNER JOIN workflow_module_rule_table_mapping mp On atd.alert_table_definition_id = mp.rule_table_id
		LEFT JOIN ' + @alert_table_definition_table + ' tmp ON tmp.physical_table_name = atd.physical_table_name AND tmp.logical_table_name = atd.logical_table_name
		WHERE tmp.logical_table_name IS NULL AND 
			mp.module_id = (SELECT DISTINCT module_id FROM ' + @module_rule_table_mapping_table + ')

		
		DELETE tmp FROM #temp_delete_alert_table_definition tmp
        INNER JOIN alert_rule_table art ON tmp.alert_table_definition_id = art.table_id

		DELETE tmp FROM #temp_delete_alert_table_definition tmp
        INNER JOIN workflow_where_clause wwc ON tmp.alert_table_definition_id = wwc.table_id

		DELETE tmp FROM #temp_delete_alert_table_definition tmp
        INNER JOIN workflow_link_where_clause wlwc ON tmp.alert_table_definition_id = wlwc.table_id
		
		DELETE mp
		FROM workflow_module_rule_table_mapping mp
		WHERE mp.module_id = (SELECT DISTINCT module_id FROM ' + @module_rule_table_mapping_table + ')

		DELETE atd
		FROM alert_table_definition atd 
		INNER JOIN #temp_delete_alert_table_definition tdatd ON atd.alert_table_definition_id = tdatd.alert_table_definition_id
		
		INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
		SELECT	tmp.[module_id],
				atd.[alert_table_definition_id],
				tmp.[is_active]
		FROM ' + @module_rule_table_mapping_table + ' tmp
		INNER JOIN alert_table_definition atd ON atd.logical_table_name = tmp.logical_table_name 		
	END
	
	IF (OBJECT_ID(N''' + @workflow_message_tag_table + ''', N''U'') IS NOT NULL) 
	BEGIN
		DELETE wet
		FROM workflow_message_tag wet
		WHERE wet.module_id = (
			SELECT DISTINCT module_id FROM ' + @workflow_message_tag_table + '
		)

		INSERT INTO workflow_message_tag (workflow_message_tag_name, workflow_message_tag, module_id, workflow_tag_query, system_defined, is_hyperlink,application_function_id)
		SELECT	tmp.workflow_message_tag_name, 
				tmp.workflow_message_tag, 
				tmp.module_id, 
				dbo.FNADecodeXML(tmp.workflow_tag_query), 
				tmp.system_defined, 
				tmp.is_hyperlink,
				tmp.application_function_id
		FROM ' + @workflow_message_tag_table + ' tmp
	END

	IF (OBJECT_ID(N''' + @workflow_contacts_table + ''', N''U'') IS NOT NULL) 
	BEGIN
		INSERT INTO workflow_contacts (module_id, email_group, email_group_query, group_type, email_address_query)
		SELECT	tmp.module_id, 
				tmp.email_group, 
				tmp.email_group_query, 
				tmp.group_type, 
				tmp.email_address_query
		FROM ' + @workflow_contacts_table + ' tmp
		LEFT JOIN workflow_contacts wc ON (tmp.email_group = wc.email_group OR tmp.email_group_query = wc.email_group_query) AND tmp.module_id = wc.module_id
		WHERE wc.workflow_contacts_id IS NULL

		UPDATE wc
		SET wc.email_group_query = tmp.email_group_query, 
			wc.group_type = tmp.group_type, 
			wc.email_address_query = tmp.email_address_query
		FROM ' + @workflow_contacts_table + ' tmp
		INNER JOIN workflow_contacts wc ON (tmp.email_group = wc.email_group OR tmp.email_group_query = wc.email_group_query) AND tmp.module_id = wc.module_id
	
		DELETE wc
		FROM ' + @workflow_contacts_table + ' tmp
		RIGHT JOIN workflow_contacts wc ON (tmp.email_group = wc.email_group OR tmp.email_group_query = wc.email_group_query) AND tmp.module_id = wc.module_id
		WHERE tmp.workflow_contacts_id IS NULL
			AND wc.module_id = (SELECT DISTINCT module_id FROM ' + @workflow_contacts_table + ')
	END

	IF (OBJECT_ID(N''' + @alert_table_definition_table + ''', N''U'') IS NOT NULL) 
	BEGIN
		IF EXISTS ( SELECT 1 
					FROM ' + @alert_table_definition_table + ' tmp
					LEFT JOIN alert_table_definition atd
						ON tmp.physical_table_name = atd.physical_table_name AND tmp.logical_table_name = atd.logical_table_name
					WHERE atd.alert_table_definition_id IS NULL )
		BEGIN
			EXEC spa_ErrorHandler -1
				, ''spa_workflow_import_export''
				, ''spa_workflow_import_export''
				, ''Success''
				, ''One or more values are missing. Please check the imported alert.''
				, @module_id

			RETURN
		END
	END

	EXEC spa_ErrorHandler 0
		, ''spa_workflow_import_export''
		, ''spa_workflow_import_export''
		, ''Success''
		, ''Successfully saved data.''
		, @module_id
	'	
	EXEC(@sql)
COMMIT TRAN 
END TRY
BEGIN CATCH
	DECLARE @desc VARCHAR(500)
	DECLARE @err_no INT
 
	IF @@TRANCOUNT > 0
		ROLLBACK
 
	SELECT @err_no = ERROR_NUMBER()
 
	SET @desc = 'Fail to import workflow definition ( Errr Description:' + ERROR_MESSAGE() + ').'
  
	EXEC spa_ErrorHandler @err_no
		, 'spa_workflow_import_export'
		, 'spa_workflow_import_export'
		, 'Error'
		, @desc
		, ''
END CATCH
END

ELSE IF @flag IN ('export_workflow','copy_workflow')
BEGIN
	DECLARE @copy_val VARCHAR(100) = ''
	IF @flag = 'copy_workflow'
		SET @copy_val = ' Copy_' + CAST(CAST(RAND()*1000 AS INT) AS VARCHAR);
	
	IF @workflow_group_id IS NOT NULL
	BEGIN
		SELECT @module_event_id = ISNULL(@module_event_id + ',','') + CAST(workflow_id AS VARCHAR) FROM workflow_schedule_task WHERE parent = @workflow_group_id AND workflow_id_type = 1
	END
	
	/*
	 * [BUILD JSON FOR RULES START]
	 */
	SET @sql = '
	SELECT	asl.alert_sql_id,
			asl.notification_type,
			REPLACE(asl.sql_statement,''"'',''&#DBQUOTE#&'') [sql_statement],
			asl.alert_sql_name  + ''' + @copy_val + ''' [alert_sql_name],
			asl.is_active,
			asl.alert_type,
			asl.rule_category,
			asl.system_rule,
			asl.alert_category,
			0 [new_alert_sql_id]	
	FROM module_events me
	INNER JOIN event_trigger et ON me.module_events_id = et.modules_event_id
	INNER JOIN alert_sql asl ON asl.alert_sql_id = et.alert_id
	WHERE me.module_events_id IN (' + CAST(@module_event_id AS VARCHAR) + ')'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ' "alert_sql":'+  @json_output

	SET @sql = '
	SELECT	art.alert_rule_table_id,
			art.alert_id,
			atd.logical_table_name,
			art.table_alias,
			0 [new_alert_rule_table_id]
	FROM module_events me
	INNER JOIN event_trigger et ON me.module_events_id = et.modules_event_id
	INNER JOIN alert_sql asl ON asl.alert_sql_id = et.alert_id
	INNER JOIN alert_rule_table art ON art.alert_id = asl.alert_sql_id
	LEFT JOIN alert_table_definition atd ON atd.alert_table_definition_id = art.table_id
	WHERE me.module_events_id IN (' + CAST(@module_event_id AS VARCHAR) + ')'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "alert_rule_table":'+  @json_output

	SET @sql = '
	SELECT	ac.alert_conditions_id,
			ac.rules_id,
			ac.alert_conditions_name + ''' + @copy_val + ''' [alert_conditions_name],
			0 [new_alert_conditions_id]
	FROM module_events me
	INNER JOIN event_trigger et ON me.module_events_id = et.modules_event_id
	INNER JOIN alert_sql asl ON asl.alert_sql_id = et.alert_id
	INNER JOIN alert_conditions ac ON ac.rules_id = asl.alert_sql_id
	WHERE me.module_events_id IN (' + CAST(@module_event_id AS VARCHAR) + ')'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "alert_conditions":'+  @json_output

	SET @sql = '
	SELECT	atwc.alert_id,
			atwc.clause_type,
			atwc.operator_id,
			atwc.table_id,
			atwc.condition_id,
			atwc.sequence_no,
			atwc.column_id,
			atwc.column_value,
			atwc.second_value,
			dsc.name [data_source_column_name]
	FROM module_events me
	INNER JOIN event_trigger et ON me.module_events_id = et.modules_event_id
	INNER JOIN alert_sql asl ON asl.alert_sql_id = et.alert_id
	INNER JOIN alert_table_where_clause atwc ON atwc.alert_id = asl.alert_sql_id
	LEFT JOIN data_source_column dsc ON atwc.data_source_column_id = dsc.data_source_column_id
	WHERE me.module_events_id IN (' + CAST(@module_event_id AS VARCHAR) + ')'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "alert_table_where_clause":'+  @json_output

	SET @sql = '
	SELECT	aa.alert_id,
			aa.table_id,
			aa.condition_id,
			aa.column_id,
			aa.column_value,
			dsc.name [data_source_column_name],
			aa.sql_statement
	FROM module_events me
	INNER JOIN event_trigger et ON me.module_events_id = et.modules_event_id
	INNER JOIN alert_sql asl ON asl.alert_sql_id = et.alert_id
	INNER JOIN alert_actions aa ON aa.alert_id = asl.alert_sql_id
	LEFT JOIN data_source_column dsc ON aa.data_source_column_id = dsc.data_source_column_id
	WHERE me.module_events_id IN (' + CAST(@module_event_id AS VARCHAR) + ')'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "alert_actions":'+  @json_output


	/*
	 * [BUILD JSON FOR SIMPLE ALERT/WORKFLOW START]
	 */
	SET @sql = '
	SELECT	me.module_events_id,
			me.modules_id, 
			me.event_id,
			me.workflow_name + ''' + @copy_val + ''' [workflow_name],
			atd.logical_table_name,
			me.is_active,
			0 [new_module_events_id]
	FROM module_events me
	LEFT JOIN alert_table_definition atd ON me.rule_table_id = atd.alert_table_definition_id
	WHERE me.module_events_id IN (' + CAST(@module_event_id AS VARCHAR) + ')'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "module_events":'+  @json_output


	SET @sql = '
	SELECT	et.event_trigger_id,
			et.modules_event_id,
			et.alert_id,
			et.initial_event,
			et.manual_step,
			et.is_disable,
			et.report_paramset_id,
			et.report_filters,
			0 [new_event_trigger_id]
	FROM module_events me
	INNER JOIN event_trigger et ON me.module_events_id = et.modules_event_id
	WHERE me.module_events_id IN (' + CAST(@module_event_id AS VARCHAR) + ')'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "event_trigger":'+  @json_output

	SET @sql = '
	SELECT	wem.event_message_id,
			wem.event_trigger_id,
			wem.event_message_name + ''' + @copy_val + ''' [event_message_name],
			wem.[message],
			wem.mult_approval_required,
			wem.comment_required,
			wem.approval_action_required,
			wem.self_notify,
			wem.notify_trader,
			wem.next_module_events_id,
			wem.minimum_approval_required,
			wem.optional_event_msg,
			wem.automatic_proceed,
			wem.notification_type,
			wem.next_module_events_id,
			0 [new_event_message_id],
			wem.skip_log
	FROM module_events me
	INNER JOIN event_trigger et ON me.module_events_id = et.modules_event_id
	INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
	WHERE me.module_events_id IN (' + CAST(@module_event_id AS VARCHAR) + ')'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "workflow_event_message":'+  @json_output

	SET @sql = '
	SELECT wemd.message_document_id,
		   wemd.event_message_id,
		   wemd.document_template_id,
		   wemd.effective_date,
		   wemd.document_category,
		   wemd.document_template,
		   0 [new_message_document_id],
		   wemd.use_generated_document
	FROM module_events me
	INNER JOIN event_trigger et ON me.module_events_id = et.modules_event_id
	INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
	INNER JOIN workflow_event_message_documents wemd ON wemd.event_message_id = wem.event_message_id
	WHERE me.module_events_id IN (' + CAST(@module_event_id AS VARCHAR) + ')'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "workflow_event_message_documents":'+  @json_output

	SET @sql = '
	SELECT	wemdd.message_detail_id,
			wemdd.event_message_document_id,
			aec.template_name [message_template_id],
			cc_type.code [counterparty_contact_type],
			wemdd.delivery_method,
			icc_type.code [internal_contact_type],
			wemdd.email,
			wemdd.email_cc,
			wemdd.email_bcc,
			wemdd.as_defined_in_contact,
			wemdd.[message],
			0 [new_message_detail_id],
			wemdd.subject
	FROM module_events me
	INNER JOIN event_trigger et ON me.module_events_id = et.modules_event_id
	INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
	INNER JOIN workflow_event_message_documents wemd ON wemd.event_message_id = wem.event_message_id 
	INNER JOIN workflow_event_message_details wemdd ON wemdd.event_message_document_id = wemd.message_document_id
	LEFT JOIN admin_email_configuration aec ON aec.admin_email_configuration_id = wemdd.message_template_id
	LEFT JOIN static_data_value cc_type ON cc_type.value_id = wemdd.counterparty_contact_type AND cc_type.value_id = 32200
	LEFT JOIN static_data_value icc_type ON icc_type.value_id = wemdd.internal_contact_type AND icc_type.value_id = 32200
	WHERE me.module_events_id IN (' + CAST(@module_event_id AS VARCHAR) + ')'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "workflow_event_message_details":'+  @json_output


	SET @sql = '
	SELECT	weme.message_detail_id,
			weme.group_type,
			wc.email_group [workflow_contacts],
			weme.query_value
	FROM module_events me
	INNER JOIN event_trigger et ON me.module_events_id = et.modules_event_id
	INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
	INNER JOIN workflow_event_message_documents wemd ON wemd.event_message_id = wem.event_message_id 
	INNER JOIN workflow_event_message_details wemdd ON wemdd.event_message_document_id = wemd.message_document_id
	INNER JOIN workflow_event_message_email weme ON weme.message_detail_id = wemdd.message_detail_id
	LEFT JOIN workflow_contacts wc ON wc.workflow_contacts_id = weme.workflow_contacts_id
	WHERE me.module_events_id IN (' + CAST(@module_event_id AS VARCHAR) + ')'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "workflow_event_message_email":'+  @json_output


	SET @sql = '
	SELECT	weur.event_message_id,
			weur.user_login_id,
			asr.role_name
	FROM module_events me
	INNER JOIN event_trigger et ON me.module_events_id = et.modules_event_id
	INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
	INNER JOIN workflow_event_user_role weur ON weur.event_message_id = wem.event_message_id
	LEFT JOIN application_security_role asr ON asr.role_id = weur.role_id
	WHERE me.module_events_id IN (' + CAST(@module_event_id AS VARCHAR) + ')'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "workflow_event_user_role":'+  @json_output
	
	SET @sql = '
	SELECT	ar.event_message_id,
			ar.report_writer,
			ar.paramset_hash,
			ar.report_param,
			ar.report_desc,
			ar.table_prefix,
			ar.table_postfix,
			ar.report_where_clause
	FROM module_events me
	INNER JOIN event_trigger et ON me.module_events_id = et.modules_event_id
	INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
	INNER JOIN alert_reports ar ON ar.event_message_id = wem.event_message_id
	WHERE me.module_events_id IN (' + CAST(@module_event_id AS VARCHAR) + ')'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "alert_reports":'+  @json_output

	/*
	 * [BUILD JSON FOR WORKFLOW START]
	 */
	SET @sql = '
	SELECT	wea.event_action_id,
			wea.event_message_id,
			wea.status_id,
			wea.alert_id,
			wea.threshold_days,
			0 [new_event_action_id]
	FROM module_events me
	INNER JOIN event_trigger et ON me.module_events_id = et.modules_event_id
	INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
	LEFT JOIN workflow_event_message_documents wemd ON wemd.event_message_id = wem.event_message_id
	INNER JOIN workflow_event_action wea ON wea.event_message_id = wem.event_message_id
	WHERE me.module_events_id IN (' + CAST(@module_event_id AS VARCHAR) + ')'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "workflow_event_action":'+  @json_output

	SELECT	wst.id,
			wst.[start_date],
			wst.[text] + @copy_val [text],
			wst.[duration],
			wst.[sort_order],
			wst.parent,
			wst.workflow_id,
			wst.workflow_id_type,
			wst.system_defined,
			0 [new_id]
	INTO #temp_workflow_schedule_task
	FROM workflow_schedule_task wst
	WHERE wst.id = ISNULL(@workflow_group_id,-1)
	UNION ALL
	SELECT	wst1.id,
			wst1.[start_date],
			wst1.[text],
			wst1.[duration],
			wst1.[sort_order],
			wst1.parent,
			wst1.workflow_id,
			wst1.workflow_id_type,
			wst1.system_defined,
			0 [new_id]
	FROM workflow_schedule_task wst
	INNER JOIN workflow_schedule_task wst1 ON wst1.parent = wst.id
	WHERE wst.id = ISNULL(@workflow_group_id,-1) 
	UNION ALL
	SELECT	wst2.id,
			wst2.[start_date],
			wst2.[text],
			wst2.[duration],
			wst2.[sort_order],
			wst2.parent,
			wst2.workflow_id,
			wst2.workflow_id_type,
			wst2.system_defined,
			0 [new_id]
	FROM workflow_schedule_task wst
	INNER JOIN workflow_schedule_task wst1 ON wst1.parent = wst.id
	INNER JOIN workflow_schedule_task wst2 ON wst2.parent = wst1.id
	WHERE wst.id = ISNULL(@workflow_group_id,-1) 
	UNION ALL
	SELECT	wst3.id,
			wst3.[start_date],
			wst3.[text],
			wst3.[duration],
			wst3.[sort_order],
			wst3.parent,
			wst3.workflow_id,
			wst3.workflow_id_type,
			wst3.system_defined,
			0 [new_id]
	FROM workflow_schedule_task wst
	INNER JOIN workflow_schedule_task wst1 ON wst1.parent = wst.id
	INNER JOIN workflow_schedule_task wst2 ON wst2.parent = wst1.id
	INNER JOIN workflow_schedule_task wst3 ON wst3.parent = wst2.id
	WHERE wst.id = ISNULL(@workflow_group_id,-1) 
	UNION ALL
	SELECT	wst4.id,
			wst4.[start_date],
			wst4.[text],
			wst4.[duration],
			wst4.[sort_order],
			wst4.parent,
			wst4.workflow_id,
			wst4.workflow_id_type,
			wst4.system_defined,
			0 [new_id]
	FROM workflow_schedule_task wst
	INNER JOIN workflow_schedule_task wst1 ON wst1.parent = wst.id
	INNER JOIN workflow_schedule_task wst2 ON wst2.parent = wst1.id
	INNER JOIN workflow_schedule_task wst3 ON wst3.parent = wst2.id
	INNER JOIN workflow_schedule_task wst4 ON wst4.parent = wst3.id
	WHERE wst.id = ISNULL(@workflow_group_id,-1)

	SET @sql = 'SELECT * FROM #temp_workflow_schedule_task'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "workflow_schedule_task":'+  @json_output

	SET @sql = '
	SELECT	wsl.id,
			wsl.source, 
			wsl.target, 
			wsl.type,
			ISNULL(wsl.action_type,'''') [action_type]
	FROM workflow_schedule_link wsl 
	INNER JOIN #temp_workflow_schedule_task twt ON wsl.source = twt.id OR wsl.target = twt.id'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "workflow_schedule_link":'+  @json_output

	
	SET @sql = '
	SELECT	wwc.clause_type,
			wwc.column_id,
			wwc.operator_id,
			wwc.column_value,
			wwc.second_value,
			atd.logical_table_name,
			wwc.column_function,
			wwc.sequence_no,
			wwc.workflow_schedule_task_id,
			dsc.name [data_source_column_name]
	FROM workflow_where_clause wwc
	INNER JOIN #temp_workflow_schedule_task wst ON wst.workflow_id_type = 1 AND wwc.workflow_schedule_task_id = wst.id
	LEFT JOIN alert_table_definition atd ON atd.alert_table_definition_id = wwc.table_id
	LEFT JOIN data_source_column dsc ON wwc.data_source_column_id = dsc.data_source_column_id'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "workflow_where_clause":'+  @json_output

	SET @sql = '
	SELECT	wl.workflow_link_id,
			wl.workflow_schedule_task_id,
			wl.modules_event_id,
			wl.[description],
			0 [new_workflow_link_id]
	FROM workflow_link wl
	INNER JOIN #temp_workflow_schedule_task twt ON wl.workflow_schedule_task_id = twt.id AND twt.workflow_id_type = 1'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "workflow_link":'+  @json_output
	
	SET @sql = '
	SELECT	wlwc.workflow_link_id,
			wlwc.clause_type,
			wlwc.column_id,
			wlwc.operator_id,
			wlwc.column_value,
			wlwc.second_value,
			atd.logical_table_name,
			wlwc.column_function,
			wlwc.sequence_no,
			dsc.name [data_source_column_name]
	FROM workflow_link wl
	INNER JOIN #temp_workflow_schedule_task twt ON wl.workflow_schedule_task_id = twt.id AND twt.workflow_id_type = 1
	INNER JOIN workflow_link_where_clause wlwc ON wlwc.workflow_link_id = wl.workflow_link_id
	LEFT JOIN alert_table_definition atd ON atd.alert_table_definition_id = wlwc.table_id
	LEFT JOIN data_source_column dsc ON wlwc.data_source_column_id = dsc.data_source_column_id'

	EXEC spa_build_json @sql, '', @json_output OUTPUT
	IF @json_output <> '[]' SET @json_final_output = @json_final_output + ', "workflow_link_where_clause":'+  @json_output

	SET @json_final_output = @json_final_output + '}'
	SELECT REPLACE(REPLACE(@json_final_output, CHAR(13), ''), CHAR(10), '')  [json_output]


	END

ELSE IF @flag = 'import_workflow'
BEGIN
BEGIN TRAN
BEGIN TRY
	IF OBJECT_ID('tempdb..#temp_error_log') IS NOT NULL
			DROP TABLE #temp_error_log
	CREATE TABLE #temp_error_log(
		ErrorCode VARCHAR(100) COLLATE DATABASE_DEFAULT,
		Module VARCHAR(200) COLLATE DATABASE_DEFAULT,
		Area VARCHAR(200) COLLATE DATABASE_DEFAULT,
		[Status] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Message] VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		Recommendation VARCHAR(1000) COLLATE DATABASE_DEFAULT
	)
	/*
	 * [Tables for RULES]
	 */
	DECLARE @alert_sql_table VARCHAR(200) = 'adiha_process.dbo.alert_sql_' + @process_id
	DECLARE @input_alert_sql_table VARCHAR(200) = 'adiha_process.dbo.alert_sql_input_' + @process_id
	DECLARE @alert_rule_table_table VARCHAR(200) = 'adiha_process.dbo.alert_rule_table_' + @process_id
	DECLARE @alert_conditions_table VARCHAR(200) = 'adiha_process.dbo.alert_conditions_' + @process_id
	DECLARE @alert_table_where_clause_table VARCHAR(200) = 'adiha_process.dbo.alert_table_where_clause_' + @process_id
	DECLARE @alert_actions_table VARCHAR(200) = 'adiha_process.dbo.alert_actions_' + @process_id
	
	/*
	 * [Tables for SIMPLE ALERT/WORKFLOW]
	 */
	DECLARE @module_events_table VARCHAR(200) = 'adiha_process.dbo.module_events_' + @process_id
	DECLARE @event_trigger_table VARCHAR(200) = 'adiha_process.dbo.event_trigger_' + @process_id
	DECLARE @workflow_event_message_table VARCHAR(200) = 'adiha_process.dbo.workflow_event_message_' + @process_id
	DECLARE @workflow_event_message_documents_table VARCHAR(200) = 'adiha_process.dbo.workflow_event_message_documents_' + @process_id
	DECLARE @workflow_event_message_details_table VARCHAR(200) = 'adiha_process.dbo.workflow_event_message_details_' + @process_id
	DECLARE @workflow_event_message_email_table VARCHAR(200) = 'adiha_process.dbo.workflow_event_message_email_' + @process_id
	DECLARE @workflow_event_user_role_table VARCHAR(200) = 'adiha_process.dbo.workflow_event_user_role_' + @process_id
	DECLARE @alert_reports_table VARCHAR(200) = 'adiha_process.dbo.alert_reports_' + @process_id

	/*
	 * [Tables for WORKFLOW]
	 */
	DECLARE @workflow_event_action_table VARCHAR(200) = 'adiha_process.dbo.workflow_event_action_' + @process_id
	DECLARE @workflow_schedule_task_table VARCHAR(200) = 'adiha_process.dbo.workflow_schedule_task_' + @process_id
	DECLARE @workflow_schedule_link_table VARCHAR(200) = 'adiha_process.dbo.workflow_schedule_link_' + @process_id
	DECLARE @workflow_where_clause_table VARCHAR(200) = 'adiha_process.dbo.workflow_where_clause_' + @process_id
	DECLARE @workflow_link_table VARCHAR(200) = 'adiha_process.dbo.workflow_link_' + @process_id
	DECLARE @workflow_link_where_clause_table VARCHAR(200) = 'adiha_process.dbo.workflow_link_where_clause_' + @process_id

	IF @import_file IS NOT NULL
	BEGIN
		SET @import_string = dbo.FNAReadFileContents(@import_file);
		IF OBJECT_ID('tempdb..#temp_parseJSON_result') IS NOT NULL
		DROP TABLE #temp_parseJSON_result
		SELECT * 
		INTO #temp_parseJSON_result
		from dbo.FNAParseJSON(@import_string)

		EXEC( ' SELECT *
				INTO ' + @input_alert_sql_table + '
				FROM #temp_parseJSON_result
		')
	END
	ELSE
	BEGIN
		SET @input_alert_sql_table = NULL
	END

	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'alert_sql', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @alert_sql_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'alert_rule_table', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @alert_rule_table_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'alert_conditions', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @alert_conditions_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'alert_table_where_clause', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @alert_table_where_clause_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'alert_actions', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @alert_actions_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'module_events', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @module_events_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'event_trigger', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @event_trigger_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'workflow_event_message', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @workflow_event_message_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'workflow_event_message_documents', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @workflow_event_message_documents_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'workflow_event_message_details', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @workflow_event_message_details_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'workflow_event_message_email', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @workflow_event_message_email_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'workflow_event_user_role', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @workflow_event_user_role_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'alert_reports', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @alert_reports_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'workflow_event_action', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @workflow_event_action_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'workflow_schedule_task', @json_string = @import_string ,@json_full_path=@import_file, @output_process_table = @workflow_schedule_task_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'workflow_schedule_link', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @workflow_schedule_link_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'workflow_where_clause', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @workflow_where_clause_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'workflow_link', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @workflow_link_table, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'workflow_link_where_clause', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @workflow_link_where_clause_table, @return_output = 0, @input_process_table  = @input_alert_sql_table

	EXEC ('IF OBJECT_ID(N''' + @workflow_event_message_documents_table + ''', N''U'') IS NOT NULL AND COL_LENGTH(''' + @workflow_event_message_documents_table + ''', ''use_generated_document'') IS NULL 
			ALTER TABLE ' + @workflow_event_message_documents_table + ' ADD [use_generated_document] NCHAR(1) NULL')

	EXEC('	IF COL_LENGTH(''' + @workflow_event_message_table  + ''', ''skip_log'') IS NULL 
			ALTER TABLE ' + @workflow_event_message_table  + ' ADD [skip_log] NCHAR(1) NULL')


	IF OBJECT_ID('tempdb..#validations') IS NOT NULL
		DROP TABLE #validations

	CREATE TABLE #validations(
		missing_value_exists INT,
		column_name VARCHAR(50) COLLATE DATABASE_DEFAULT
	)
	
	EXEC ('
		INSERT INTO #validations (missing_value_exists, column_name)
		SELECT a.event_id, ''event_id''
		FROM (
			SELECT event_id
			FROM ' + @module_events_table + ' mv		
		) mv 
		OUTER APPLY (SELECT item event_id FROM dbo.SplitCommaSeperatedValues(mv.event_id)) a
		LEFT JOIN static_data_value sdv ON sdv.value_id = a.event_id 
		WHERE sdv.value_id IS NULL
		UNION ALL
		SELECT mv.modules_id , ''modules_id'' FROM ' + @module_events_table + ' mv 
		LEFT JOIN static_data_value sdv ON sdv.value_id = mv.modules_id 
		WHERE sdv.value_id IS NULL
		UNION ALL
		SELECT mv.module_events_id, ''module_event_mapping''
		FROM (
			SELECT event_id, modules_id, module_events_id
			FROM ' + @module_events_table + '		
		) mv  		
		OUTER APPLY (SELECT item event_id FROM dbo.SplitCommaSeperatedValues(mv.event_id)) a
		LEFT JOIN workflow_module_event_mapping wmem ON wmem.module_id = mv.modules_id AND wmem.event_id = a.event_id 
		WHERE wmem.mapping_id IS NULL 	
	')
	
	SET @sql = 'IF (OBJECT_ID(N''' + @alert_reports_table + ''', N''U'') IS NOT NULL) 	
				BEGIN
					INSERT INTO #validations (missing_value_exists, column_name)
					SELECT arp.event_message_id, ''paramset_hash'' FROM ' + @alert_reports_table + ' arp	
					LEFT JOIN alert_reports ar ON (ar.paramset_hash = arp.paramset_hash OR ar.report_desc = arp.report_desc)
					WHERE ar.alert_reports_id IS NULL
				END	'
	EXEC spa_print @sql
	EXEC(@sql) 
	
	IF @import_as IS NOT NULL 
	BEGIN 
		SET @sql = 'IF (OBJECT_ID(N''' + @workflow_schedule_task_table + ''', N''U'') IS NOT NULL) 	
					BEGIN
						UPDATE ' + @alert_sql_table + ' SET alert_sql_name = alert_sql_name + ''_'' + ''' + @import_as + ''' WHERE alert_sql_id > 0
						IF (OBJECT_ID(N''' + @alert_conditions_table + ''', N''U'') IS NOT NULL)    
                        BEGIN
                            UPDATE ' + @alert_conditions_table + ' SET alert_conditions_name = alert_conditions_name + ''_'' + ''' + @import_as + '''
                        END
						UPDATE ' + @module_events_table + ' SET workflow_name = workflow_name + ''_'' + ''' + @import_as + '''
						IF (OBJECT_ID(N''' + @workflow_event_message_table + ''', N''U'') IS NOT NULL)    
                        BEGIN
                            UPDATE ' + @workflow_event_message_table + ' SET event_message_name = event_message_name + ''_'' + ''' + @import_as + '''
                        END
						UPDATE ' + @workflow_schedule_task_table + ' SET text = ''' + @import_as + '''
					END
					ELSE
					BEGIN
						IF (OBJECT_ID(N''' + @alert_sql_table + ''', N''U'') IS NOT NULL) 	
						BEGIN
							UPDATE ' + @alert_sql_table + ' SET alert_sql_name = ''' + @import_as + '''
						END
						IF (OBJECT_ID(N''' + @module_events_table + ''', N''U'') IS NOT NULL) 	
						BEGIN
							UPDATE ' + @module_events_table + ' SET workflow_name = ''' + @import_as + '''
						END
					END
					'
		EXEC spa_print @sql
		EXEC(@sql) 
	END
	
	SET @sql = '
	DECLARE @rules_ids VARCHAR(1000)
	 
	SELECT @rules_ids = ISNULl(@rules_ids + '','','''') + CAST(asl.alert_sql_id AS VARCHAR) 
	FROM ' + @module_events_table + ' tmp
	INNER JOIN module_events me ON tmp.workflow_name = me.workflow_name 
	INNER JOIN event_trigger et ON et.modules_event_id = me.module_events_id
	INNER JOIN alert_sql asl ON asl.alert_sql_id = et.alert_id
	WHERE asl.alert_sql_id > 0
	
	IF (OBJECT_ID(N''' + @workflow_schedule_task_table + ''', N''U'') IS NOT NULL) 
	BEGIN
		DECLARE @workflow_group_id INT
		SELECT @workflow_group_id = wst.[id] 
		FROM ' + @workflow_schedule_task_table + ' tmp
		INNER JOIN workflow_schedule_task wst ON tmp.[text] = wst.[text] and wst.workflow_id_type = 0

		INSERT INTO #temp_error_log
		EXEC spa_workflow_schedule @flag = ''d'', @task_id = @workflow_group_id, @task_level = 0
	END
	INSERT INTO #temp_error_log
	EXEC spa_setup_rule_workflow @flag = ''l'', @alert_rule_id = @rules_ids

	IF EXISTS(SELECT 1 FROM #temp_error_log
			  WHERE ErrorCode = ''Error''
	)
	BEGIN
		RAISERROR (N''Error while deleting previous workflow/alert.'', -- Message text.
						12, -- Severity,
						1, -- State
						''''
					);
	END
	
	' 
	EXEC(@sql)
	
	/*
	 * IMPORT THE RULE
	 */
	SET @sql = '
	DECLARE @alert_sql_id INT,@alert_sql_name VARCHAR(100)
	DECLARE alert_sql_cursor CURSOR FOR  
	SELECT DISTINCT alert_sql_id,alert_sql_name FROM ' + @alert_sql_table + '			  
	OPEN alert_sql_cursor;  
	FETCH NEXT FROM alert_sql_cursor INTO @alert_sql_id,@alert_sql_name;   
	WHILE @@FETCH_STATUS = 0   
	BEGIN   
		IF EXISTS (SELECT 1 FROM ' + @alert_sql_table + ' WHERE alert_sql_id = @alert_sql_id AND alert_sql_id < 0)
		BEGIN
			UPDATE ' + @alert_sql_table + '		
			SET new_alert_sql_id = @alert_sql_id
			WHERE alert_sql_id = @alert_sql_id
		END
		ELSE IF EXISTS (SELECT 1 FROM alert_sql WHERE alert_sql_name = @alert_sql_name AND alert_sql_id > 0) --Added when same alert already present
		BEGIN
			SELECT @alert_sql_id = alert_sql_id
			FROM alert_sql
			WHERE alert_sql_name = @alert_sql_name

			UPDATE as1
				SET as1.workflow_only = ''n'',
					as1.notification_type = as2.notification_type,
					as1.sql_statement = REPLACE(as2.sql_statement,''&#DBQUOTE#&'', ''"''),
					as1.is_active = as2.is_active,
					as1.alert_type = as2.alert_type,
					as1.rule_category = as2.rule_category,
					as1.system_rule = as2.system_rule,
					as1.alert_category = NULLIF(as2.alert_category,'''')
			FROM alert_sql as1
			INNER JOIN ' + @alert_sql_table + ' as2
			ON as2.alert_sql_name = as1.alert_sql_name
			WHERE as1.alert_sql_name = @alert_sql_name

			UPDATE ' + @alert_sql_table + '		
			SET new_alert_sql_id = @alert_sql_id
			WHERE alert_sql_name = @alert_sql_name
		END
		ELSE
		BEGIN
			INSERT INTO alert_sql (
					workflow_only, 
					notification_type,
					sql_statement, 
					alert_sql_name, 
					is_active, 
					alert_type, 
					rule_category, 
					system_rule, 
					alert_category)
			SELECT	DISTINCT ''n'' [workflow_only],
					notification_type,
					REPLACE(sql_statement,''&#DBQUOTE#&'', ''"'') [sql_statement],
					alert_sql_name,
					is_active, 
					alert_type, 
					rule_category, 
					system_rule, 
					NULLIF(alert_category,'''')
			FROM ' + @alert_sql_table + '
			WHERE alert_sql_id = @alert_sql_id

			UPDATE ' + @alert_sql_table + '
			SET new_alert_sql_id = SCOPE_IDENTITY()  
			WHERE alert_sql_id = @alert_sql_id

			IF (OBJECT_ID(N''' + @alert_rule_table_table + ''', N''U'') IS NOT NULL) 
			BEGIN
				INSERT INTO alert_rule_table (
					alert_id,
					table_id,
					table_alias
				)
				SELECT DISTINCT
				asl.new_alert_sql_id, atd.alert_table_definition_id, art.table_alias 
				FROM ' + @alert_rule_table_table + ' art
				CROSS APPLY( SELECT DISTINCT asl.alert_sql_id, asl.new_alert_sql_id FROM ' + @alert_sql_table + ' asl WHERE art.alert_id = asl.alert_sql_id) asl
				INNER JOIN alert_table_definition atd ON atd.logical_table_name = art.logical_table_name
				WHERE asl.alert_sql_id = @alert_sql_id

				UPDATE art
				SET new_alert_rule_table_id = SCOPE_IDENTITY()  
				FROM ' + @alert_rule_table_table + ' art
				INNER JOIN ' + @alert_sql_table + ' asl ON art.alert_id = asl.alert_sql_id
				WHERE asl.alert_sql_id = @alert_sql_id
			
				IF (OBJECT_ID(N''' + @alert_conditions_table + ''', N''U'') IS NOT NULL) 
				BEGIN
					INSERT INTO alert_conditions (
						rules_id,
						alert_conditions_name
					)
					SELECT	DISTINCT 
							asl.new_alert_sql_id,
							ac.alert_conditions_name 
					FROM ' + @alert_conditions_table + ' ac
					CROSS APPLY( SELECT DISTINCT asl.alert_sql_id, asl.new_alert_sql_id FROM ' + @alert_sql_table + ' asl WHERE ac.rules_id = asl.alert_sql_id) asl
					WHERE asl.alert_sql_id = @alert_sql_id

					UPDATE ac
					SET new_alert_conditions_id = SCOPE_IDENTITY()  
					FROM ' + @alert_conditions_table + ' ac
					INNER JOIN ' + @alert_sql_table + ' asl ON ac.rules_id = asl.alert_sql_id
					WHERE asl.alert_sql_id = @alert_sql_id
				END


				IF (OBJECT_ID(N''' + @alert_table_where_clause_table + ''', N''U'') IS NOT NULL) 
				BEGIN
					INSERT INTO alert_table_where_clause (
						alert_id,
						clause_type,
						operator_id,
						table_id,
						condition_id,
						sequence_no,
						data_source_column_id,
						column_value,
						second_value,
						column_id
					)
					SELECT	DISTINCT asl.new_alert_sql_id,
							atwc.clause_type,
							atwc.operator_id,
							art.new_alert_rule_table_id,
							ac.new_alert_conditions_id,
							atwc.sequence_no,
							ISNULL(dsc.data_source_column_id,-1) [data_source_column_id],
							atwc.column_value,
							atwc.second_value,
							NULLIF(atwc.column_id,'''')
					FROM ' + @alert_table_where_clause_table + ' atwc
					CROSS APPLY( SELECT DISTINCT asl.alert_sql_id, asl.new_alert_sql_id FROM ' + @alert_sql_table + ' asl WHERE atwc.alert_id = asl.alert_sql_id) asl
					INNER JOIN ' + @alert_rule_table_table + ' art ON art.alert_rule_table_id = atwc.table_id
					INNER JOIN ' + @alert_conditions_table + ' ac ON ac.alert_conditions_id = atwc.condition_id
					LEFT JOIN alert_rule_table art1
						ON art1.alert_rule_table_id = art.new_alert_rule_table_id
					LEFT JOIN alert_table_definition atd ON atd.alert_table_definition_id = art1.table_id
					LEFT JOIN data_source_column dsc ON dsc.source_id = atd.data_source_id AND dsc.[name] = atwc.[data_source_column_name]
					WHERE asl.alert_sql_id = @alert_sql_id
				END

				IF (OBJECT_ID(N''' + @alert_actions_table + ''', N''U'') IS NOT NULL) 
				BEGIN
					INSERT INTO alert_actions (
						alert_id,
						table_id,
						condition_id,
						data_source_column_id,
						column_value,
						sql_statement
					)
					SELECT	DISTINCT asl.new_alert_sql_id,
							art.new_alert_rule_table_id,
							ac.new_alert_conditions_id,
							ISNULL(dsc.data_source_column_id,-1) [data_source_column_id],
							aa.column_value,
							aa.sql_statement
					FROM ' + @alert_actions_table + ' aa
					CROSS APPLY( SELECT DISTINCT asl.alert_sql_id, asl.new_alert_sql_id FROM ' + @alert_sql_table + ' asl WHERE aa.alert_id = asl.alert_sql_id) asl
					INNER JOIN ' + @alert_rule_table_table + ' art ON art.alert_rule_table_id = aa.table_id
					INNER JOIN ' + @alert_conditions_table + ' ac ON ac.alert_conditions_id = aa.condition_id
					LEFT JOIN alert_table_definition atd ON atd.logical_table_name = art.logical_table_name
					LEFT JOIN data_source_column dsc ON dsc.source_id = atd.data_source_id AND dsc.[name] = aa.[data_source_column_name]
					WHERE asl.alert_sql_id = @alert_sql_id
				END
			END
		END

		FETCH NEXT FROM alert_sql_cursor INTO @alert_sql_id,@alert_sql_name;				
	END
	CLOSE alert_sql_cursor   
	DEALLOCATE alert_sql_cursor
	'  
	
	EXEC(@sql)

	/*
	 * IMPORT THE WORKFLOW
	 */
	SET @sql = CAST('' AS VARCHAR(MAX)) + '
	DECLARE @module_events_id INT
	DECLARE module_events_cursor CURSOR FOR  
	SELECT module_events_id FROM ' + @module_events_table + '  

	OPEN module_events_cursor;  
	FETCH NEXT FROM module_events_cursor INTO @module_events_id;   
	WHILE @@FETCH_STATUS = 0   
	BEGIN   

		INSERT INTO module_events (
				modules_id, 
				event_id,
				workflow_name,
				rule_table_id,
				is_active
				)
		SELECT	me.modules_id,
				me.event_id,
				me.workflow_name,
				atd.alert_table_definition_id,
				me.is_active
		FROM ' + @module_events_table + ' me
		LEFT JOIN alert_table_definition atd ON atd.logical_table_name = me.logical_table_name
		WHERE me.module_events_id = @module_events_id
	
		UPDATE me
		SET new_module_events_id = SCOPE_IDENTITY() 
		FROM ' + @module_events_table + ' me
		WHERE me.module_events_id = @module_events_id

		IF (OBJECT_ID(N''' + @workflow_schedule_task_table + ''', N''U'') IS NULL) 
		BEGIN
			INSERT INTO workflow_schedule_task (text, start_date, parent, workflow_id, workflow_id_type, system_defined)
			SELECT	''Internal Workflow '' + CAST(new_module_events_id AS VARCHAR),
					GETDATE(),
					-999,
					new_module_events_id,
					1,
					0
			 FROM ' + @module_events_table + ' me
			WHERE me.module_events_id = @module_events_id
		END

		DECLARE @event_trigger_id INT
		DECLARE event_trigger_cursor CURSOR FOR
		SELECT event_trigger_id FROM ' + @event_trigger_table + ' WHERE modules_event_id = @module_events_id

		OPEN event_trigger_cursor;  
		FETCH NEXT FROM event_trigger_cursor INTO @event_trigger_id;   
		WHILE @@FETCH_STATUS = 0   
		BEGIN   
			
			INSERT INTO event_trigger (
					modules_event_id,
					initial_event,
					manual_step,
					is_disable,
					report_paramset_id
			)
			SELECT	me.new_module_events_id, 
					et.initial_event, 
					et.manual_step, 
					et.is_disable, 
					et.report_paramset_id
			FROM ' + @event_trigger_table + ' et
			INNER JOIN ' + @module_events_table + ' me ON et.modules_event_id = me.module_events_id
			WHERE et.event_trigger_id = @event_trigger_id

			UPDATE et
			SET new_event_trigger_id = SCOPE_IDENTITY()
			FROM ' + @event_trigger_table + ' et
			WHERE event_trigger_id = @event_trigger_id

			IF (OBJECT_ID(N''' + @workflow_event_message_table + ''', N''U'') IS NOT NULL) 
			BEGIN
				DECLARE @event_message_id INT
				DECLARE event_message_cursor CURSOR FOR
				SELECT event_message_id FROM ' + @workflow_event_message_table + ' WHERE event_trigger_id = @event_trigger_id

				OPEN event_message_cursor;  
				FETCH NEXT FROM event_message_cursor INTO @event_message_id;   
				WHILE @@FETCH_STATUS = 0   
				BEGIN   
					
					INSERT INTO workflow_event_message (
							event_trigger_id,
							event_message_name,
							[message],
							mult_approval_required,
							comment_required,
							approval_action_required,
							self_notify,
							notify_trader,
							minimum_approval_required,
							optional_event_msg,
							automatic_proceed,
							notification_type,
							next_module_events_id,
							skip_log
					)
					SELECT  et.new_event_trigger_id,
							wem.event_message_name,
							wem.[message],
							wem.mult_approval_required,
							wem.comment_required,
							wem.approval_action_required,
							wem.self_notify,
							wem.notify_trader,
							wem.minimum_approval_required,
							wem.optional_event_msg,
							wem.automatic_proceed,
							wem.notification_type,
							wem.next_module_events_id,
							wem.skip_log
					FROM ' + @workflow_event_message_table + ' wem
					INNER JOIN ' + @event_trigger_table + ' et ON wem.event_trigger_id = et.event_trigger_id
					WHERE wem.event_message_id = @event_message_id

					UPDATE wem
					SET new_event_message_id = SCOPE_IDENTITY()
					FROM ' + @workflow_event_message_table + ' wem
					WHERE event_message_id = @event_message_id

					IF (OBJECT_ID(N''' + @workflow_event_user_role_table + ''', N''U'') IS NOT NULL) 
					BEGIN
						INSERT INTO workflow_event_user_role (
							event_message_id,
							user_login_id,
							role_id
						)
						SELECT wem.new_event_message_id,
								au.user_login_id,
								asr.role_id
						FROM ' + @workflow_event_user_role_table + ' weur
						INNER JOIN ' + @workflow_event_message_table + ' wem ON weur.event_message_id = wem.event_message_id
						LEFT JOIN application_users au ON au.user_login_id = weur.user_login_id
						LEFT JOIN application_security_role asr ON LTRIM(RTRIM(asr.role_name)) = weur.role_name
						WHERE wem.event_message_id = @event_message_id
					END

					IF (OBJECT_ID(N''' + @alert_reports_table + ''', N''U'') IS NOT NULL) 
					BEGIN
						INSERT INTO alert_reports (
							event_message_id,
							report_writer,
							paramset_hash,
							report_param,
							report_desc,
							table_prefix,
							table_postfix,
							report_where_clause
						)
						SELECT	wem.new_event_message_id,
								ar.report_writer,
								ar.paramset_hash,
								ar.report_param,
								ar.report_desc,
								ar.table_prefix,
								ar.table_postfix,
								ar.report_where_clause
						FROM ' + @alert_reports_table + ' ar
						INNER JOIN ' + @workflow_event_message_table + ' wem ON ar.event_message_id = wem.event_message_id
						WHERE wem.event_message_id = @event_message_id
					END

					IF (OBJECT_ID(N''' + @workflow_event_message_documents_table + ''', N''U'') IS NOT NULL) 
					BEGIN
						DECLARE @message_document_id INT
						DECLARE message_document_cursor CURSOR FOR
						SELECT message_document_id FROM ' + @workflow_event_message_documents_table + ' WHERE event_message_id = @event_message_id

						OPEN message_document_cursor;  
						FETCH NEXT FROM message_document_cursor INTO @message_document_id;   
						WHILE @@FETCH_STATUS = 0   
						BEGIN  
							INSERT INTO workflow_event_message_documents(
									event_message_id,
									document_template_id,
									effective_date,
									document_category,
									document_template,
									use_generated_document
							)
							SELECT	wem.new_event_message_id,
									wemd.document_template_id,
									wemd.effective_date,
									wemd.document_category,
									wemd.document_template,
									wemd.use_generated_document
							FROM ' + @workflow_event_message_documents_table + ' wemd
							INNER JOIN ' + @workflow_event_message_table + ' wem ON wemd.event_message_id = wem.event_message_id
							WHERE wemd.message_document_id = @message_document_id

							UPDATE wemd
							SET new_message_document_id = SCOPE_IDENTITY()
							FROM ' + @workflow_event_message_documents_table + ' wemd
							WHERE wemd.message_document_id = @message_document_id

							IF (OBJECT_ID(N''' + @workflow_event_message_details_table + ''', N''U'') IS NOT NULL) 
							BEGIN
								INSERT INTO workflow_event_message_details (
										event_message_document_id,
										message_template_id,
										message,
										counterparty_contact_type,
										delivery_method,
										internal_contact_type,
										email,
										email_cc,
										email_bcc,
										as_defined_in_contact,
										subject
								)
								SELECT	wmd.new_message_document_id,
										aec.admin_email_configuration_id,
										wmdd.[message],
										sdv.value_id,
										wmdd.delivery_method,
										sdv1.value_id,
										wmdd.email,
										wmdd.email_cc,
										wmdd.email_bcc,
										wmdd.as_defined_in_contact,
										wmdd.subject
								FROM ' + @workflow_event_message_details_table + ' wmdd
								INNER JOIN ' + @workflow_event_message_documents_table + ' wmd ON wmdd.event_message_document_id = wmd.message_document_id
								LEFT JOIN static_data_value sdv ON sdv.code = wmdd.counterparty_contact_type AND sdv.[type_id] = 32200
								LEFT JOIN static_data_value sdv1 ON sdv1.code = wmdd.internal_contact_type AND sdv1.[type_id] = 32200
								LEFT JOIN admin_email_configuration aec ON aec.template_name = wmdd.message_template_id
								WHERE wmdd.event_message_document_id = @message_document_id

								UPDATE wemd
								SET new_message_detail_id = SCOPE_IDENTITY()
								FROM ' + @workflow_event_message_details_table + ' wemd
								INNER JOIN ' + @workflow_event_message_documents_table + ' wmd ON wemd.event_message_document_id = wmd.message_document_id
								WHERE wemd.event_message_document_id = @message_document_id
							END

							IF (OBJECT_ID(N''' + @workflow_event_message_email_table + ''', N''U'') IS NOT NULL) 
							BEGIN
								INSERT INTO workflow_event_message_email (
										message_detail_id,
										group_type,
										workflow_contacts_id,
										query_value
								)
								SELECT	wmdd.new_message_detail_id,
										weme.group_type,
										workflow_contacts_id,
										weme.query_value
								FROM ' + @workflow_event_message_email_table + ' weme
								INNER JOIN ' + @workflow_event_message_details_table + ' wmdd ON weme.message_detail_id = wmdd.message_detail_id
								INNER JOIN ' + @workflow_event_message_documents_table + ' wmd ON wmdd.event_message_document_id = wmd.message_document_id
								LEFT JOIN workflow_contacts wc ON NULLIF(wc.email_group,'''') = NULLIF(weme.workflow_contacts,'''')
								WHERE wmdd.event_message_document_id = @message_document_id
							END

						FETCH NEXT FROM message_document_cursor INTO @message_document_id;
						END
						CLOSE message_document_cursor
						DEALLOCATE  message_document_cursor
					END

					FETCH NEXT FROM event_message_cursor INTO @event_message_id;
				END
				CLOSE event_message_cursor
				DEALLOCATE  event_message_cursor

			END

			FETCH NEXT FROM event_trigger_cursor INTO @event_trigger_id;
		END
		CLOSE event_trigger_cursor
		DEALLOCATE  event_trigger_cursor

		FETCH NEXT FROM module_events_cursor INTO @module_events_id;				
	END
	CLOSE module_events_cursor   
	DEALLOCATE module_events_cursor
	'
	EXEC(@sql)
	--SELECT @sql

	/*
	 * MAP THE RULE AND WORKFLOW
	 */
	SET @sql =  CAST('' AS VARCHAR(MAX)) + '
	UPDATE et_n
	SET alert_id = asl.new_alert_sql_id
	FROM ' + @event_trigger_table + ' et
	INNER JOIN ' + @alert_sql_table + ' asl ON et.alert_id = asl.alert_sql_id
	INNER JOIN event_trigger et_n ON et_n.event_trigger_id = et.new_event_trigger_id
	'
	EXEC(@sql)
	--SELECT @sql


	/*
	 * IMPORT FOR WORKFLOW
	 */
	SET @sql =  CAST('' AS VARCHAR(MAX)) + '
	IF (OBJECT_ID(N''' + @workflow_event_action_table + ''', N''U'') IS NOT NULL) 
	BEGIN

		DECLARE @event_action_id INT
		DECLARE event_action_cursor CURSOR FOR
		SELECT event_action_id FROM ' + @workflow_event_action_table + '

		OPEN event_action_cursor;  
		FETCH NEXT FROM event_action_cursor INTO @event_action_id;   
		WHILE @@FETCH_STATUS = 0   
		BEGIN   
	
			INSERT INTO workflow_event_action (
					alert_id,
					event_message_id,
					status_id,
					threshold_days
			)
			SELECT	et.new_event_trigger_id,
					wem.new_event_message_id,
					wea.status_id,
					wea.threshold_days 
			FROM ' + @workflow_event_action_table + ' wea
			INNER JOIN ' + @workflow_event_message_table + ' wem ON wea.event_message_id = wem.event_message_id
			INNER JOIN ' + @event_trigger_table + ' et ON wea.alert_id = et.event_trigger_id
			WHERE event_action_id = @event_action_id	
	
			UPDATE wea
			SET new_event_action_id = @event_action_id
			FROM ' + @workflow_event_action_table + ' wea

			FETCH NEXT FROM event_action_cursor INTO @event_action_id;
		END
		CLOSE event_action_cursor
		DEALLOCATE  event_action_cursor
	END


	IF (OBJECT_ID(N''' + @workflow_schedule_task_table + ''', N''U'') IS NOT NULL) 
	BEGIN
		INSERT INTO workflow_schedule_task (
				[text],
				[start_date],
				[system_defined],
				[workflow_id_type],
				[duration]
		)
		SELECT  wst.[text],
				wst.[start_date],
				wst.system_defined,
				wst.workflow_id_type,
				ISNULL(wst.duration,2)
		FROM ' + @workflow_schedule_task_table + ' wst
		WHERE wst.workflow_id_type = 0

		UPDATE wst
		SET new_id = SCOPE_IDENTITY()  
		FROM ' + @workflow_schedule_task_table + ' wst
		WHERE wst.workflow_id_type = 0


		DECLARE @wst_me_id INT
		DECLARE wst_me_cursor CURSOR FOR
		SELECT [id] FROM ' + @workflow_schedule_task_table + ' WHERE workflow_id_type = 1

		OPEN wst_me_cursor;  
		FETCH NEXT FROM wst_me_cursor INTO @wst_me_id;   
		WHILE @@FETCH_STATUS = 0   
		BEGIN   
		
			INSERT INTO workflow_schedule_task(
					[start_date],
					duration,
					sort_order,
					parent,
					workflow_id,
					workflow_id_type,
					system_defined
			)
			SELECT	wst.[start_date],
					wst.[duration],
					wst.sort_order,
					wst_p.new_id,
					me.new_module_events_id,
					wst.workflow_id_type,
					wst.system_defined
			FROM ' + @workflow_schedule_task_table + ' wst
			INNER JOIN ' + @module_events_table + ' me ON wst.workflow_id_type = 1 AND wst.workflow_id = me.module_events_id
			INNER JOIN ' + @workflow_schedule_task_table + ' wst_p on wst.parent = wst_p.id
			WHERE wst.id = @wst_me_id

			UPDATE wst
			SET new_id = SCOPE_IDENTITY()  
			FROM ' + @workflow_schedule_task_table + ' wst
			WHERE wst.id = @wst_me_id
	

			FETCH NEXT FROM wst_me_cursor INTO @wst_me_id;
		END
		CLOSE wst_me_cursor
		DEALLOCATE  wst_me_cursor

	
		DECLARE @wst_et_id INT
		DECLARE wst_et_cursor CURSOR FOR
		SELECT [id] FROM ' + @workflow_schedule_task_table + ' WHERE workflow_id_type = 2

		OPEN wst_et_cursor;  
		FETCH NEXT FROM wst_et_cursor INTO @wst_et_id;   
		WHILE @@FETCH_STATUS = 0   
		BEGIN   
		
			INSERT INTO workflow_schedule_task(
					[start_date],
					duration,
					sort_order,
					parent,
					workflow_id,
					workflow_id_type,
					system_defined
			)
			SELECT	wst.[start_date],
					wst.[duration],
					wst.sort_order,
					wst_p.new_id,
					et.new_event_trigger_id,
					wst.workflow_id_type,
					wst.system_defined
			FROM ' + @workflow_schedule_task_table + ' wst
			INNER JOIN ' + @event_trigger_table + ' et ON wst.workflow_id_type = 2 AND wst.workflow_id = et.event_trigger_id
			INNER JOIN ' + @workflow_schedule_task_table + ' wst_p on wst.parent = wst_p.id
			WHERE wst.id = @wst_et_id

			UPDATE wst
			SET new_id = SCOPE_IDENTITY()  
			FROM ' + @workflow_schedule_task_table + ' wst
			WHERE wst.id = @wst_et_id

		
			FETCH NEXT FROM wst_et_cursor INTO @wst_et_id;
		END
		CLOSE wst_et_cursor
		DEALLOCATE  wst_et_cursor


		DECLARE @wst_msg_id INT
		DECLARE wst_msg_cursor CURSOR FOR
		SELECT [id] FROM ' + @workflow_schedule_task_table + ' WHERE workflow_id_type = 3

		OPEN wst_msg_cursor;  
		FETCH NEXT FROM wst_msg_cursor INTO @wst_msg_id;   
		WHILE @@FETCH_STATUS = 0   
		BEGIN   
		
			INSERT INTO workflow_schedule_task(
					[start_date],
					duration,
					sort_order,
					parent,
					workflow_id,
					workflow_id_type,
					system_defined
			)
			SELECT	wst.[start_date],
					wst.[duration],
					wst.sort_order,
					wst_p.new_id,
					wem.new_event_message_id,
					wst.workflow_id_type,
					wst.system_defined
			FROM ' + @workflow_schedule_task_table + ' wst
			INNER JOIN ' + @workflow_event_message_table + ' wem ON wst.workflow_id_type = 3 AND wst.workflow_id = wem.event_message_id
			INNER JOIN ' + @workflow_schedule_task_table + ' wst_p on wst.parent = wst_p.id
			WHERE wst.id = @wst_msg_id

			UPDATE wst
			SET new_id = SCOPE_IDENTITY()  
			FROM ' + @workflow_schedule_task_table + ' wst
			WHERE wst.id = @wst_msg_id

							
			FETCH NEXT FROM wst_msg_cursor INTO @wst_msg_id;
		END
		CLOSE wst_msg_cursor
		DEALLOCATE  wst_msg_cursor


		DECLARE @wst_act_id INT
		DECLARE wst_act_cursor CURSOR FOR
		SELECT [id] FROM ' + @workflow_schedule_task_table + ' WHERE workflow_id_type = 4

		OPEN wst_act_cursor;  
		FETCH NEXT FROM wst_act_cursor INTO @wst_act_id;   
		WHILE @@FETCH_STATUS = 0   
		BEGIN   
		
			INSERT INTO workflow_schedule_task(
					[start_date],
					duration,
					sort_order,
					parent,
					workflow_id,
					workflow_id_type,
					system_defined
			)
			SELECT	wst.[start_date],
					wst.[duration],
					wst.sort_order,
					wst_p.new_id,
					wem.new_event_message_id,
					wst.workflow_id_type,
					wst.system_defined
			FROM ' + @workflow_schedule_task_table + ' wst
			INNER JOIN ' + @workflow_event_message_table + ' wem ON wst.workflow_id_type = 4 AND wst.workflow_id = wem.event_message_id
			INNER JOIN ' + @workflow_schedule_task_table + ' wst_p on wst.parent = wst_p.id
			WHERE wst.id = @wst_act_id

			UPDATE wst
			SET new_id = SCOPE_IDENTITY()  
			FROM ' + @workflow_schedule_task_table + ' wst
			WHERE wst.id = @wst_act_id

			FETCH NEXT FROM wst_act_cursor INTO @wst_act_id;
		END
		CLOSE wst_act_cursor
		DEALLOCATE  wst_act_cursor
	END

	IF (OBJECT_ID(N''' + @workflow_schedule_link_table + ''', N''U'') IS NOT NULL) 
	BEGIN
		INSERT INTO workflow_schedule_link (
				[source],
				[target],
				[type],
				[action_type]
		)
		SELECT	tsk1.new_id [source],
				tsk2.new_id [target],
				lnk.type [type],
				NULLIF(lnk.action_type,'''') [action_type]
		FROM ' + @workflow_schedule_link_table + ' lnk
		INNER JOIN ' + @workflow_schedule_task_table + ' tsk1 ON lnk.source = tsk1.id
		INNER JOIN ' + @workflow_schedule_task_table + ' tsk2 ON lnk.target = tsk2.id
	END

	IF (OBJECT_ID(N''' + @workflow_where_clause_table + ''', N''U'') IS NOT NULL) 
	BEGIN
		INSERT INTO workflow_where_clause (
			clause_type,
			column_id,
			operator_id,
			column_value,
			second_value,
			table_id,
			column_function,
			sequence_no,
			workflow_schedule_task_id,
			data_source_column_id
		)
		SELECT	wwc.clause_type, 
				wwc.column_id,
				wwc.operator_id,
				wwc.column_value,
				wwc.second_value,
				atd.alert_table_definition_id,
				wwc.column_function,
				wwc.sequence_no,
				wst.new_id,
				ISNULL(dsc.data_source_column_id,-1) [data_source_column_id]
		FROM ' + @workflow_where_clause_table + ' wwc
		INNER JOIN ' + @workflow_schedule_task_table + ' wst ON wwc.workflow_schedule_task_id = wst.id AND wst.workflow_id_type = 1
		LEFT JOIN alert_table_definition atd ON atd.logical_table_name = wwc.logical_table_name
		LEFT JOIN data_source_column dsc ON dsc.source_id = atd.data_source_id AND dsc.[name] = wwc.[data_source_column_name]
	END

	IF (OBJECT_ID(N''' + @workflow_link_table + ''', N''U'') IS NOT NULL) 
	BEGIN
		DECLARE @workflow_link_id INT
		DECLARE workflow_link_cursor CURSOR FOR
		SELECT workflow_link_id FROM ' + @workflow_link_table + '

		OPEN workflow_link_cursor;  
		FETCH NEXT FROM workflow_link_cursor INTO @workflow_link_id;   
		WHILE @@FETCH_STATUS = 0   
		BEGIN   
			INSERT INTO workflow_link (
					workflow_schedule_task_id,
					modules_event_id,
					[description]		
			)
			SELECT	wst.new_id,
					me.new_module_events_id,
					wl.[description] 
			FROM ' + @workflow_link_table + ' wl
			INNER JOIN ' + @workflow_schedule_task_table + ' wst ON wl.workflow_schedule_task_id = wst.id AND wst.workflow_id_type = 1
			INNER JOIN ' + @module_events_table + ' me ON me.module_events_id = wl.modules_event_id
			WHERE wl.workflow_link_id = @workflow_link_id

			UPDATE wl
			SET new_workflow_link_id = SCOPE_IDENTITY()  
			FROM ' + @workflow_link_table + ' wl
			WHERE wl.workflow_link_id = @workflow_link_id


			IF (OBJECT_ID(N''' + @workflow_link_where_clause_table + ''', N''U'') IS NOT NULL) 
			BEGIN
				INSERT INTO workflow_link_where_clause (
					workflow_link_id,
					clause_type,
					column_id,
					operator_id,
					column_value,
					second_value,
					table_id,
					column_function,
					sequence_no,
					data_source_column_id
				)
				SELECT	wl.new_workflow_link_id,
						wlwc.clause_type, 
						wlwc.column_id,
						wlwc.operator_id,
						wlwc.column_value,
						wlwc.second_value,
						atd.alert_table_definition_id,
						wlwc.column_function,
						wlwc.sequence_no,
						ISNULL(dsc.data_source_column_id,-1) [data_source_column_id]
				FROM ' + @workflow_link_where_clause_table + ' wlwc
				INNER JOIN ' + @workflow_link_table + ' wl ON wl.workflow_link_id = wlwc.workflow_link_id
				LEFT JOIN alert_table_definition atd ON atd.logical_table_name = wlwc.logical_table_name
				LEFT JOIN data_source_column dsc ON dsc.source_id = atd.data_source_id AND dsc.[name] = wlwc.[data_source_column_name]
				WHERE wlwc.workflow_link_id = @workflow_link_id
			END


			FETCH NEXT FROM workflow_link_cursor INTO @workflow_link_id;
		END
		CLOSE workflow_link_cursor
		DEALLOCATE  workflow_link_cursor
	END
	'
	EXEC(@sql)
	IF EXISTS (SELECT 1 FROM #validations)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'spa_workflow_import_export'
			, 'spa_workflow_import_export'
			, 'Error' 
			, 'One or more values are missing. Please check the imported alert.'
			, ''
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0
			, 'spa_workflow_import_export'
			, 'spa_workflow_import_export'
			, 'Success' 
			, 'Successfully saved data.'
			, ''
	END

COMMIT TRAN 
END TRY
BEGIN CATCH
	DECLARE @desc1 VARCHAR(500)
	DECLARE @err_no1 INT
 
	IF @@TRANCOUNT > 0
		ROLLBACK
 
	SELECT @err_no1 = ERROR_NUMBER()
	IF @err_no1 = 50000	--thrown by RAISE statement
	BEGIN
		SET @desc1 = ERROR_MESSAGE()
		EXEC spa_ErrorHandler @err_no1
							, 'spa_workflow_import_export'
							, 'spa_workflow_import_export'
							, 'Error'
							, @desc1
							, ''
	END
	ELSE
	BEGIN
		SET @desc1 = 'Fail to import alert/workflow ( Errr Description:' + ERROR_MESSAGE() + ').'
		EXEC spa_ErrorHandler @err_no1
							, 'spa_workflow_import_export'
							, 'spa_workflow_import_export'
							, 'Error'
							, @desc1
							, ''
	END
	
	
END CATCH
END
ELSE IF @flag='check_if_module_event_exists'
BEGIN
	DECLARE @module_event_mapping_table_name VARCHAR(200) = 'adiha_process.dbo.module_event_mapping_table_' + @process_id

	IF (JSON_QUERY(dbo.FNAReadFileContents(@import_file), '$.module_event_mapping') = '[]')
	BEGIN
		EXEC spa_ErrorHandler 1
			, 'spa_workflow_import_export'
			, 'spa_workflow_import_export'
			, 'Error'
			, 'Import file is empty'
			, -1 -- JSON file is empty.

		RETURN
	END

	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'module_event_mapping', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @module_event_mapping_table_name, @return_output = 0

	EXEC ('
		IF EXISTS ( SELECT 1
					FROM workflow_module_event_mapping wmem
					INNER JOIN ' + @module_event_mapping_table_name + ' temp
						ON wmem.module_id = temp.module_id
		)
		BEGIN
			EXEC spa_ErrorHandler 0
				, ''spa_workflow_import_export''
				, ''spa_workflow_import_export''
				, ''Success''
				, ''Import Mapping started''
				, 1 -- Module exists
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler 0
				, ''spa_workflow_import_export''
				, ''spa_workflow_import_export''
				, ''Success''
				, ''Import Mapping started.''
				, 0 -- Module does not exist
		END')
END
ELSE IF @flag = 'confirm_override'
BEGIN 
	IF @import_file IS NOT NULL
	BEGIN
		SET @import_string = dbo.FNAReadFileContents(@import_file);	
	END
		
	SET @process_id = dbo.FNAGETNEWID()
	DECLARE @user_name VARCHAR(100) = dbo.FNADBUser() 
	DECLARE @alert_sql_table_vld VARCHAR(200) = dbo.FNAProcessTableName('alert_sql', @user_name, @process_id)
	DECLARE @workflow_schedule_task_table_vld VARCHAR(200) = dbo.FNAProcessTableName('workflow_schedule_task', @user_name, @process_id)
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'workflow_schedule_task', @json_string = @import_string ,@json_full_path=@import_file, @output_process_table = @workflow_schedule_task_table_vld, @return_output = 0, @input_process_table  = @input_alert_sql_table
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'alert_sql', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @alert_sql_table_vld, @return_output = 0, @input_process_table = @input_alert_sql_table
	
	IF OBJECT_ID('tempdb..#alert_workflow_info') IS NOT NULL 
	DROP TABLE #alert_workflow_info

	CREATE TABLE #alert_workflow_info(alert_work_flow_name VARCHAR(1000) COLLATE DATABASE_DEFAULT, id INT)	

	SET @sql = 'IF (OBJECT_ID(N''' + @workflow_schedule_task_table_vld + ''', N''U'') IS NOT NULL) 	
				BEGIN
					INSERT INTO #alert_workflow_info(alert_work_flow_name, id)
					SELECT wst.text, wst.id 
					FROM ' + @workflow_schedule_task_table_vld + ' a
					INNER JOIN workflow_schedule_task wst ON wst.text = ' + CASE WHEN @import_as IS NULL THEN 'a.text ' ELSE '''' + @import_as + '''' END + '
					WHERE 1 = 1
				END	
				ELSE
				IF (OBJECT_ID(N''' + @alert_sql_table_vld + ''', N''U'') IS NOT NULL) 	
				BEGIN
					INSERT INTO #alert_workflow_info(alert_work_flow_name, id)
					SELECT asl.alert_sql_name, asl.alert_sql_id 
					FROM ' + @alert_sql_table_vld + ' a
					INNER JOIN alert_sql asl ON asl.alert_sql_name = ' + CASE WHEN @import_as IS NULL THEN 'a.alert_sql_name ' ELSE '''' + @import_as + '''' END + '
					WHERE 1 = 1
				END
				'
	EXEC spa_print @sql
 	EXEC(@sql)

	IF EXISTS(SELECT 1 FROM #alert_workflow_info)
	BEGIN 
		SELECT 'r' confirm_override, @import_file_name import_file_name, @import_as copy_as --confirmation requried
	END 
	ELSE 
	BEGIN 
		SELECT 'n' confirm_override, @import_file_name import_file_name, @import_as copy_as --confirmation not requried
	END
END
