 --============================================================================================================================
 --Create date: 2017-3-10
 --Author : ashakya@pioneersolutionsglobal.com
 --Description: Exports Alert Rule 
               
 --Params:
 --	@rule_name VARCHAR(500) = NULL, -- 'Rule name'
 --	@call_from_workflow CHAR(1) = 'n' -- Values 'Y', 'N' 
 --============================================================================================================================

IF OBJECT_ID('spa_export_alert') IS NOT NULL
	DROP PROC dbo.spa_export_alert
GO

CREATE PROC dbo.spa_export_alert
	@rule_name VARCHAR(100) = NULL, -- 'Rule name'
	@call_from_workflow CHAR(1) = 'n'
AS

SET NOCOUNT ON

--DECLARE @rule_name VARCHAR(500) = 'Analyst Confirm'

IF OBJECT_ID('tempdb..#rule_id') IS NOT NULL
	DROP TABLE #rule_id

CREATE TABLE #rule_id (rule_id INT, alert_sql_name VARCHAR(100) COLLATE DATABASE_DEFAULT, alert_category CHAR(1) COLLATE DATABASE_DEFAULT)

INSERT INTO #rule_id (rule_id, alert_sql_name, alert_category)
SELECT alert_sql_id, alert_sql_name, alert_category FROM alert_sql WHERE alert_sql_name = @rule_name

DECLARE @alert_category CHAR(1)
SELECT @alert_category = alert_category FROM alert_sql WHERE alert_sql_name = @rule_name

IF OBJECT_ID('tempdb..#static_data_value_id') IS NOT NULL
	DROP TABLE #static_data_value_id

CREATE TABLE #static_data_value_id (value_id INT)

INSERT INTO #static_data_value_id (value_id)
SELECT DISTINCT notification_type FROM alert_sql a INNER JOIN #rule_id ir ON ir.rule_id = a.alert_sql_id
UNION ALL SELECT DISTINCT rule_category FROM alert_sql a INNER JOIN #rule_id ir ON ir.rule_id = a.alert_sql_id

IF OBJECT_ID('tempdb..#alert_rule_table') IS NOT NULL
	DROP TABLE #alert_rule_table
	
CREATE TABLE #alert_rule_table (alert_rule_table_id INT, alert_id INT, table_id INT, root_table_id INT, table_alias VARCHAR(50) COLLATE DATABASE_DEFAULT)

INSERT INTO #alert_rule_table (alert_rule_table_id, alert_id, table_id, root_table_id, table_alias )
SELECT art.alert_rule_table_id, art.alert_id, art.table_id, art.root_table_id ,art.table_alias
FROM #rule_id ri INNER JOIN alert_rule_table art ON ri.rule_id = art.alert_id 

IF OBJECT_ID('tempdb..#alert_table_definition') IS NOT NULL
	DROP TABLE #alert_table_definition

CREATE TABLE #alert_table_definition (alert_table_definition_id INT)

INSERT INTO #alert_table_definition (alert_table_definition_id)	
SELECT table_id FROM alert_rule_table art INNER JOIN #rule_id ri ON ri.rule_id = art.alert_id

INSERT INTO #static_data_value_id (value_id)
SELECT DISTINCT modules_id FROM #rule_id ri INNER JOIN module_events me ON me.workflow_name = ri.alert_sql_name
LEFT JOIN #static_data_value_id sdv ON sdv.value_id = me.modules_id 
WHERE sdv.value_id IS NULL

INSERT INTO #static_data_value_id (value_id)
SELECT DISTINCT event_id FROM #rule_id ri INNER JOIN module_events me ON me.workflow_name = ri.alert_sql_name
LEFT JOIN #static_data_value_id sdv ON sdv.value_id = me.event_id 
WHERE sdv.value_id IS NULL

IF OBJECT_ID('tempdb..#alert_columns_definition') IS NOT NULL
	DROP TABLE #alert_columns_definition

CREATE TABLE #alert_columns_definition (alert_table_id INT)

INSERT INTO #alert_columns_definition (alert_table_id)	
SELECT acd.alert_columns_definition_id FROM alert_columns_definition acd INNER JOIN #alert_table_definition atd ON atd.alert_table_definition_id = acd.alert_table_id

IF OBJECT_ID('tempdb..#alert_conditions') IS NOT NULL
	DROP TABLE #alert_conditions

CREATE TABLE #alert_conditions (alert_conditions_id INT, rules_id INT, alert_conditions_name VARCHAR(100) COLLATE DATABASE_DEFAULT, alert_conditions_description VARCHAR(500) COLLATE DATABASE_DEFAULT)

INSERT INTO #alert_conditions (alert_conditions_id, rules_id, alert_conditions_name, alert_conditions_description)
SELECT ac.alert_conditions_id, ac.rules_id, ac.alert_conditions_name, ac.alert_conditions_description 
FROM #rule_id ri INNER JOIN alert_conditions ac ON ri.rule_id = ac.rules_id 

IF OBJECT_ID('tempdb..#workflow_event_user_role') IS NOT NULL
	DROP TABLE #workflow_event_user_role

CREATE TABLE #workflow_event_user_role (event_user_role_id INT, event_message_id INT, role_id INT)

IF OBJECT_ID('adiha_process.dbo.workflow_details') IS NOT NULL
BEGIN
	INSERT INTO #workflow_event_user_role (event_user_role_id, event_message_id, role_id)
	SELECT weur.event_user_role_id, weur.event_message_id, weur.role_id from workflow_event_message wem 
	INNER JOIN event_trigger et ON et.event_trigger_id = wem.event_trigger_id
	INNER JOIN #rule_id flt ON flt.rule_id = et.alert_id 
	INNER JOIN workflow_event_user_role weur ON weur.event_message_id = wem.event_message_id
	INNER JOIN adiha_process.dbo.workflow_details wd on wd.workflow_id = weur.event_message_id  and wd.workflow_id_type = 3
END 
ELSE
BEGIN
	INSERT INTO #workflow_event_user_role (event_user_role_id, event_message_id, role_id)
	SELECT weur.event_user_role_id, weur.event_message_id, weur.role_id from workflow_event_message wem 
	INNER JOIN event_trigger et ON et.event_trigger_id = wem.event_trigger_id
	INNER JOIN #rule_id flt ON flt.rule_id = et.alert_id 
	INNER JOIN workflow_event_user_role weur ON weur.event_message_id = wem.event_message_id
END

IF OBJECT_ID('tempdb..#application_security_role') IS NOT NULL
	DROP TABLE #application_security_role

CREATE TABLE #application_security_role (role_id INT, role_name VARCHAR(50) COLLATE DATABASE_DEFAULT, role_description VARCHAR(50) COLLATE DATABASE_DEFAULT, role_type_value_id INT, process_map_file_name VARCHAR(1000) COLLATE DATABASE_DEFAULT)
INSERT INTO #application_security_role (role_id, role_name, role_description, role_type_value_id, process_map_file_name)
SELECT DISTINCT asr.role_id, asr.role_name, asr.role_description, asr.role_type_value_id, asr.process_map_file_name 
FROM #workflow_event_user_role weur 
INNER JOIN application_security_role asr ON asr.role_id = weur.role_id

INSERT INTO #static_data_value_id (value_id)
SELECT DISTINCT role_type_value_id FROM #application_security_role asr
LEFT JOIN #static_data_value_id sdv ON sdv.value_id = asr.role_type_value_id 
WHERE sdv.value_id IS NULL

IF OBJECT_ID('tempdb..#workflow_event_message_documents') IS NOT NULL
	DROP TABLE #workflow_event_message_documents

CREATE TABLE #workflow_event_message_documents (message_document_id INT, document_template_id INT, document_category INT)
INSERT INTO #workflow_event_message_documents (message_document_id, document_template_id, document_category)
SELECT wemd.message_document_id, wemd.document_template_id, wemd.document_category 
FROM workflow_event_message wem 
INNER JOIN event_trigger et ON et.event_trigger_id = wem.event_trigger_id
INNER JOIN #rule_id flt ON flt.rule_id = et.alert_id 
INNER JOIN workflow_event_message_documents wemd ON wemd.event_message_id = wem.event_message_id

INSERT INTO #static_data_value_id (value_id)
SELECT DISTINCT document_template_id FROM #workflow_event_message_documents wemd
LEFT JOIN #static_data_value_id sdv ON sdv.value_id = wemd.document_template_id 
WHERE sdv.value_id IS NULL

INSERT INTO #static_data_value_id (value_id)
SELECT DISTINCT document_category FROM #workflow_event_message_documents wemd
LEFT JOIN #static_data_value_id sdv ON sdv.value_id = wemd.document_category 
WHERE sdv.value_id IS NULL

INSERT INTO #static_data_value_id (value_id)
SELECT DISTINCT wwemd.delivery_method FROM #workflow_event_message_documents wemd 
INNER JOIN workflow_event_message_details wwemd ON wwemd.event_message_document_id = wemd.message_document_id
LEFT JOIN #static_data_value_id sdv ON sdv.value_id = wwemd.delivery_method 
WHERE sdv.value_id IS NULL

INSERT INTO #static_data_value_id (value_id)
SELECT DISTINCT wwemd.counterparty_contact_type FROM #workflow_event_message_documents wemd 
INNER JOIN workflow_event_message_details wwemd ON wwemd.event_message_document_id = wemd.message_document_id
LEFT JOIN #static_data_value_id sdv ON sdv.value_id = wwemd.counterparty_contact_type 
WHERE sdv.value_id IS NULL

INSERT INTO #static_data_value_id (value_id)
SELECT DISTINCT wwemd.internal_contact_type FROM #workflow_event_message_documents wemd 
INNER JOIN workflow_event_message_details wwemd ON wwemd.event_message_document_id = wemd.message_document_id
LEFT JOIN #static_data_value_id sdv ON sdv.value_id = wwemd.internal_contact_type 
WHERE sdv.value_id IS NULL

IF OBJECT_ID('tempdb..#alert_reports') IS NOT NULL
	DROP TABLE #alert_reports

CREATE TABLE #alert_reports (alert_report_id INT)

INSERT INTO #alert_reports (alert_report_id)
SELECT ar.alert_reports_id FROM workflow_event_message wem 
INNER JOIN event_trigger et ON et.event_trigger_id = wem.event_trigger_id
INNER JOIN #rule_id flt ON flt.rule_id = et.alert_id 
INNER JOIN alert_reports ar ON ar.event_message_id = wem.event_message_id

DECLARE @temp_tbl_pid VARCHAR(50) = dbo.FNAGetNewID()

IF @call_from_workflow = 'n'
BEGIN
	IF OBJECT_ID('tempdb..#query_result') IS NULL
		CREATE TABLE #query_result (rowid INT IDENTITY(1,1), query_result VARCHAR(MAX) COLLATE DATABASE_DEFAULT)
	ELSE 
		TRUNCATE TABLE #query_result
		
	INSERT INTO #query_result (query_result)
	SELECT '
	BEGIN TRY
	BEGIN TRAN

	IF OBJECT_ID(''tempdb..#old_new_id'') IS NULL
	CREATE TABLE #old_new_id(tran_type VARCHAR(1), table_name VARCHAR(250) COLLATE DATABASE_DEFAULT, new_id INT, old_id INT, unique_key1 VARCHAR(250) COLLATE DATABASE_DEFAULT, unique_key2 VARCHAR(250) COLLATE DATABASE_DEFAULT, unique_key3 VARCHAR(250) COLLATE DATABASE_DEFAULT)
	ELSE
	TRUNCATE TABLE #old_new_id
	; '
END

EXEC dbo.spa_export_table_scripter @tbl_name = 'static_data_value'
	, @filter = ' INNER JOIN #static_data_value_id flt ON flt.value_id = src.value_id'  --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'code'
	, @primary_key_column2 = 'type_id'
	, @primary_key_column3 = NULL
	, @master_table_name = NULL 
	, @join_column_name_master = NULL 
	, @join_column_name_child = NULL 
	, @primary_key_column1_master = NULL
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 0
	, @temp_unique_id = @temp_tbl_pid

EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_sql'
	, @filter = ' INNER JOIN #rule_id flt ON flt.rule_id = src.alert_sql_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'alert_sql_name'
	, @primary_key_column2 = NULL--'type_id'
	, @primary_key_column3 = NULL
	, @master_table_name = NULL 
	, @join_column_name_master = NULL 
	, @join_column_name_child = NULL 
	, @primary_key_column1_master = NULL
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 1
	, @temp_unique_id = @temp_tbl_pid

INSERT INTO #query_result (query_result)
SELECT '
UPDATE dbo.alert_sql SET [workflow_only]=src.[workflow_only],[message]=src.[message],[notification_type]=src.[notification_type],[sql_statement]=src.[sql_statement],[is_active]=src.[is_active],[alert_type]=src.[alert_type],[rule_category]=src.[rule_category],[system_rule]=src.[system_rule],[alert_category]=src.[alert_category]
		   OUTPUT ''u'',''alert_sql'',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_sql_' + @temp_tbl_pid + ' src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name;

IF EXISTS(SELECT 1 FROM #alert_sql_' + @temp_tbl_pid + ' WHERE alert_sql_id < 0)
BEGIN
	SET IDENTITY_INSERT alert_sql ON
	INSERT INTO alert_sql
	([alert_sql_id], [workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category]
	)
	OUTPUT ''i'',''alert_sql'',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	SELECT 
	src.alert_sql_id, src.[workflow_only],src.[message],src.[notification_type],src.[sql_statement],src.[alert_sql_name],src.[is_active],src.[alert_type],src.[rule_category],src.[system_rule],src.[alert_category]
	FROM #alert_sql_' + @temp_tbl_pid + ' src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
	WHERE dst.[alert_sql_id] IS NULL;
	SET IDENTITY_INSERT alert_sql OFF
END
ELSE
BEGIN
	INSERT INTO alert_sql
	([workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category]
	)
	OUTPUT ''i'',''alert_sql'',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	SELECT 
	src.[workflow_only],src.[message],src.[notification_type],src.[sql_statement],src.[alert_sql_name],src.[is_active],src.[alert_type],src.[rule_category],src.[system_rule],src.[alert_category]
	FROM #alert_sql_' + @temp_tbl_pid + ' src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
	WHERE dst.[alert_sql_id] IS NULL;
END

UPDATE #alert_sql_' + @temp_tbl_pid + ' SET new_recid = dst.new_id , alert_sql_id =  dst.new_id
FROM #alert_sql_' + @temp_tbl_pid + ' src INNER JOIN #old_new_id dst ON src.alert_sql_name = dst.unique_key1 AND dst.table_name = ''alert_sql''

UPDATE asl SET asl.notification_type = sdv.new_recid 
FROM alert_sql asl INNER JOIN #alert_sql_' + @temp_tbl_pid + ' tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_' + @temp_tbl_pid + ' sdv ON sdv.old_recid = asl.notification_type	

UPDATE asl SET asl.rule_category = sdv.new_recid
FROM alert_sql asl INNER JOIN #alert_sql_' + @temp_tbl_pid + ' tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_' + @temp_tbl_pid + ' sdv ON sdv.old_recid = asl.rule_category	
'

IF @call_from_workflow = 'y'
BEGIN
	INSERT INTO #query_result (query_result)
	SELECT '
	INSERT INTO #alert_sql_bkup (alert_sql_id, workflow_only, message, notification_type, sql_statement, alert_sql_name, is_active, alert_type, rule_category, system_rule, alert_category, new_recid, old_recid)
	SELECT asl.alert_sql_id, asl.workflow_only, asl.message, asl.notification_type, asl.sql_statement, asl.alert_sql_name, asl.is_active, asl.alert_type, asl.rule_category, asl.system_rule, asl.alert_category, asl.new_recid, asl.old_recid FROM #alert_sql_' + @temp_tbl_pid + ' asl
	LEFT JOIN #alert_sql_bkup aslb ON aslb.old_recid = asl.old_recid
	WHERE aslb.old_recid IS NULL'
END

EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_table_definition' 
	, @filter = ' INNER JOIN #alert_table_definition flt ON flt.alert_table_definition_id = src.alert_table_definition_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'logical_table_name'
	, @primary_key_column2 = NULL--'type_id'
	, @primary_key_column3 = NULL
	, @master_table_name = NULL 
	, @join_column_name_master = NULL 
	, @join_column_name_child = NULL 
	, @primary_key_column1_master = NULL
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 0
	, @temp_unique_id = @temp_tbl_pid

INSERT INTO #query_result (query_result)
SELECT '
UPDATE #alert_table_definition_' + @temp_tbl_pid + ' SET alert_table_definition_id = new_recid
'

EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_columns_definition' 
	, @filter = ' INNER JOIN #alert_columns_definition flt ON flt.alert_table_id = src.alert_columns_definition_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'column_name'
	, @primary_key_column2 = NULL--'type_id'
	, @primary_key_column3 = NULL
	, @master_table_name = 'alert_table_definition' 
	, @join_column_name_master = 'alert_table_definition_id' 
	, @join_column_name_child = 'alert_table_id' 
	, @primary_key_column1_master = 'physical_table_name'
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 1
	, @temp_unique_id = @temp_tbl_pid

INSERT INTO #query_result (query_result)
SELECT '
UPDATE acd SET acd.alert_table_id = atd.new_recid
FROM #alert_columns_definition_' + @temp_tbl_pid + ' acd INNER JOIN #alert_table_definition_' + @temp_tbl_pid + ' atd ON atd.old_recid = acd.alert_table_id
'

EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_columns_definition' 
	, @filter = ' INNER JOIN #alert_columns_definition flt ON flt.alert_table_id = src.alert_columns_definition_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'column_name'
	, @primary_key_column2 = NULL--'type_id'
	, @primary_key_column3 = NULL
	, @master_table_name = 'alert_table_definition' 
	, @join_column_name_master = 'alert_table_definition_id' 
	, @join_column_name_child = 'alert_table_id' 
	, @primary_key_column1_master = 'physical_table_name'
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 2	
	, @temp_unique_id = @temp_tbl_pid

INSERT INTO #query_result (query_result)
SELECT '
DELETE FROM alert_table_relation WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_' + @temp_tbl_pid + ')
DELETE FROM alert_actions_events WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_' + @temp_tbl_pid + ')
DELETE FROM alert_actions WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_' + @temp_tbl_pid + ')
DELETE FROM alert_table_where_clause WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_' + @temp_tbl_pid + ')
DELETE from alert_conditions WHERE rules_id IN (SELECT alert_sql_id FROM #alert_sql_' + @temp_tbl_pid + ')
DELETE from alert_rule_table where alert_id IN (SELECT alert_sql_id FROM #alert_sql_' + @temp_tbl_pid + ')'	

EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_rule_table' 
	, @filter = ' INNER JOIN #rule_id flt ON flt.rule_id = src.alert_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'alert_rule_table_id'
	, @primary_key_column2 = NULL--'type_id'
	, @primary_key_column3 = NULL
	, @master_table_name = 'alert_sql'
	, @join_column_name_master = 'alert_sql_id' 
	, @join_column_name_child = 'alert_id'
	, @primary_key_column1_master = 'alert_sql_name'
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 1
	, @temp_unique_id = @temp_tbl_pid

INSERT INTO #query_result (query_result)
SELECT '
UPDATE art SET art.alert_id = asl.new_recid
FROM #alert_rule_table_' + @temp_tbl_pid + ' art INNER JOIN #alert_sql_' + @temp_tbl_pid + ' asl ON asl.old_recid = art.alert_id

UPDATE art SET art.table_id = asd.new_recid
FROM #alert_rule_table_' + @temp_tbl_pid + ' art INNER JOIN #alert_table_definition_' + @temp_tbl_pid + '  asd ON asd.old_recid = art.table_id

UPDATE dbo.alert_rule_table SET [table_alias]=src.[table_alias]
		   OUTPUT ''u'',''alert_rule_table'',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_rule_table_' + @temp_tbl_pid + ' src INNER JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
insert into alert_rule_table
		([alert_id],[table_id],[root_table_id],[table_alias]
		)
		 OUTPUT ''i'',''alert_rule_table'',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[root_table_id],src.[table_alias]
		FROM #alert_rule_table_' + @temp_tbl_pid + ' src LEFT JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
		WHERE dst.[alert_rule_table_id] IS NULL;
UPDATE #alert_rule_table_' + @temp_tbl_pid + ' SET new_recid =dst.new_id 
		FROM #alert_rule_table_' + @temp_tbl_pid + ' src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND ISNULL(src.root_table_id, -1)=ISNULL(dst.unique_key3, -1) AND dst.table_name=''alert_rule_table''
		;
print(''--==============================END alert_rule_table============================='')
	-- need to verify root_table_id
UPDATE art SET art.root_table_id = art2.new_recid FROM #alert_rule_table_' + @temp_tbl_pid + ' art INNER JOIN #alert_rule_table_' + @temp_tbl_pid + ' art2 ON art2.old_recid = art.root_table_id  
UPDATE art SET art.root_table_id = arrt.root_table_id FROM alert_rule_table art INNER JOIN #alert_rule_table_' + @temp_tbl_pid + ' arrt ON arrt.new_recid = art.alert_rule_table_id 
'

EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_conditions' 
	, @filter = ' INNER JOIN #rule_id flt ON flt.rule_id = src.rules_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'alert_conditions_name'
	, @primary_key_column2 = NULL--'type_id'
	, @primary_key_column3 = NULL
	, @master_table_name = 'alert_sql' 
	, @join_column_name_master = 'alert_sql_id' 
	, @join_column_name_child = 'rules_id' 
	, @primary_key_column1_master = 'alert_sql_name'
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 1
	, @temp_unique_id = @temp_tbl_pid

INSERT INTO #query_result (query_result)
SELECT '
UPDATE ac SET rules_id = asl.new_recid	
FROM #alert_conditions_' + @temp_tbl_pid + ' ac INNER JOIN #alert_sql_' + @temp_tbl_pid + ' asl ON asl.old_recid = ac.rules_id'

EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_conditions' 
	, @filter = ' INNER JOIN #rule_id flt ON flt.rule_id = src.rules_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'alert_conditions_name'
	, @primary_key_column2 = NULL--'type_id'
	, @primary_key_column3 = NULL
	, @master_table_name = 'alert_sql' 
	, @join_column_name_master = 'alert_sql_id' 
	, @join_column_name_child = 'rules_id' 
	, @primary_key_column1_master = 'alert_sql_name'
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 2
	, @temp_unique_id = @temp_tbl_pid

INSERT INTO #query_result (query_result)
SELECT '
UPDATE #alert_conditions_' + @temp_tbl_pid + ' SET alert_conditions_id = new_recid'

EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_table_where_clause' 
	, @filter = ' INNER JOIN #alert_conditions flt ON flt.alert_conditions_id = src.condition_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'alert_table_where_clause_id'
	, @primary_key_column2 = NULL--'type_id'
	, @primary_key_column3 = NULL
	, @master_table_name = NULL 
	, @join_column_name_master = NULL 
	, @join_column_name_child = NULL 
	, @primary_key_column1_master = NULL
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 1
	, @temp_unique_id = @temp_tbl_pid

INSERT INTO #query_result (query_result)
SELECT '
UPDATE atwc SET atwc.alert_id = asl.new_recid FROM #alert_table_where_clause_' + @temp_tbl_pid + ' atwc INNER JOIN #alert_sql_' + @temp_tbl_pid + ' asl ON asl.old_recid = atwc.alert_id
UPDATE atwc SET atwc.column_id = acd.new_recid FROM #alert_table_where_clause_' + @temp_tbl_pid + ' atwc INNER JOIN #alert_columns_definition_' + @temp_tbl_pid + '  acd ON acd.old_recid = atwc.column_id
UPDATE atwc SET atwc.table_id = art.new_recid FROM #alert_table_where_clause_' + @temp_tbl_pid + ' atwc INNER JOIN #alert_rule_table_' + @temp_tbl_pid + ' art ON art.old_recid = atwc.table_id
UPDATE atwc SET atwc.condition_id = ac.new_recid FROM #alert_table_where_clause_' + @temp_tbl_pid + ' atwc INNER JOIN #alert_conditions_' + @temp_tbl_pid + ' ac ON ac.old_recid = atwc.condition_id
'

EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_table_where_clause' 
	, @filter = ' INNER JOIN #alert_conditions flt ON flt.alert_conditions_id = src.condition_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'alert_table_where_clause_id'
	, @primary_key_column2 = NULL--'type_id'
	, @primary_key_column3 = NULL
	, @master_table_name = NULL 
	, @join_column_name_master = NULL 
	, @join_column_name_child = NULL 
	, @primary_key_column1_master = NULL
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 2
	, @temp_unique_id = @temp_tbl_pid

EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_actions' 
	, @filter = ' INNER JOIN #rule_id flt ON flt.rule_id = src.alert_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'alert_id'
	, @primary_key_column2 = NULL--'table_id'--'type_id'
	, @primary_key_column3 = NULL--'column_id'
	, @master_table_name = NULL 
	, @join_column_name_master = NULL 
	, @join_column_name_child = NULL 
	, @primary_key_column1_master = NULL
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 1
	, @temp_unique_id = @temp_tbl_pid

INSERT INTO #query_result (query_result)
SELECT '
UPDATE aa SET aa.column_id = acd.new_recid FROM #alert_actions_' + @temp_tbl_pid + ' aa INNER JOIN #alert_columns_definition_' + @temp_tbl_pid + '  acd ON acd.old_recid = aa.column_id
UPDATE aa SET aa.table_id = art.new_recid FROM #alert_actions_' + @temp_tbl_pid + ' aa INNER JOIN #alert_rule_table_' + @temp_tbl_pid + ' art ON art.old_recid = aa.table_id
UPDATE aa SET aa.condition_id = ac.new_recid FROM #alert_actions_' + @temp_tbl_pid + ' aa INNER JOIN #alert_conditions_' + @temp_tbl_pid + ' ac ON ac.old_recid = aa.condition_id
UPDATE aa SET aa.alert_id = asl.new_recid FROM #alert_actions_' + @temp_tbl_pid + ' aa INNER JOIN #alert_sql_' + @temp_tbl_pid + ' asl ON asl.old_recid = aa.alert_id
'

EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_actions' 
	, @filter = ' INNER JOIN #rule_id flt ON flt.rule_id = src.alert_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'alert_id'
	, @primary_key_column2 = NULL--'table_id'--'type_id'
	, @primary_key_column3 = NULL--'column_id'
	, @master_table_name = NULL 
	, @join_column_name_master = NULL 
	, @join_column_name_child = NULL 
	, @primary_key_column1_master = NULL
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 2
	, @temp_unique_id = @temp_tbl_pid

EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_actions_events'
	, @filter = ' INNER JOIN #rule_id flt ON flt.rule_id = src.alert_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'alert_id'
	, @primary_key_column2 = 'table_id'--'type_id'
	, @primary_key_column3 = 'callback_alert_id'
	, @master_table_name = NULL 
	, @join_column_name_master = NULL 
	, @join_column_name_child = NULL 
	, @primary_key_column1_master = NULL
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 1
	, @temp_unique_id = @temp_tbl_pid

INSERT INTO #query_result (query_result)
SELECT '
UPDATE aae SET aae.alert_id = asl.new_recid FROM #alert_actions_events_' + @temp_tbl_pid + ' aae INNER JOIN #alert_sql_' + @temp_tbl_pid + ' asl ON asl.old_recid = aae.alert_id
UPDATE aae SET aae.table_id = art.new_recid FROM #alert_actions_events_' + @temp_tbl_pid + ' aae INNER JOIN #alert_rule_table_' + @temp_tbl_pid + ' art ON art.old_recid = aae.table_id
'

EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_actions_events'
	, @filter = ' INNER JOIN #rule_id flt ON flt.rule_id = src.alert_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'alert_id'
	, @primary_key_column2 = 'table_id'--'type_id'
	, @primary_key_column3 = NULL --'callback_alert_id'
	, @master_table_name = NULL --
	, @join_column_name_master = NULL 
	, @join_column_name_child = NULL 
	, @primary_key_column1_master = NULL
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 2
	, @temp_unique_id = @temp_tbl_pid

EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_table_relation'
	, @filter = ' INNER JOIN #rule_id flt ON flt.rule_id = src.alert_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'alert_id'
	, @primary_key_column2 = 'from_table_id'--'type_id'
	, @primary_key_column3 = 'to_table_id'
	, @master_table_name = NULL 
	, @join_column_name_master = NULL 
	, @join_column_name_child = NULL 
	, @primary_key_column1_master = NULL
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 1
	, @temp_unique_id = @temp_tbl_pid

INSERT INTO #query_result (query_result)
SELECT '	
update #alert_table_relation_' + @temp_tbl_pid + ' set from_column_id=''FARRMS4_ ''+cast(alert_table_relation_id as varchar(30))  where isnull(from_column_id,'''')='''' ;
update #alert_table_relation_' + @temp_tbl_pid + ' set to_column_id=''FARRMS5_ ''+cast(alert_table_relation_id as varchar(30))  where isnull(to_column_id,'''')='''' ;

UPDATE atr SET atr.alert_id	= asl.new_recid FROM #alert_table_relation_' + @temp_tbl_pid + ' atr INNER JOIN #alert_sql_' + @temp_tbl_pid + ' asl ON asl.old_recid = atr.alert_id		
UPDATE atr SET atr.from_table_id = atd.new_recid FROM #alert_table_relation_' + @temp_tbl_pid + ' atr INNER JOIN #alert_rule_table_' + @temp_tbl_pid + ' atd ON atd.old_recid = atr.from_table_id		
UPDATE atr SET atr.to_table_id = atd.new_recid FROM #alert_table_relation_' + @temp_tbl_pid + ' atr INNER JOIN #alert_rule_table_' + @temp_tbl_pid + ' atd ON atd.old_recid = atr.to_table_id		
UPDATE atr SET atr.from_column_id = atd.new_recid FROM #alert_table_relation_' + @temp_tbl_pid + ' atr INNER JOIN #alert_columns_definition_' + @temp_tbl_pid + ' atd ON atd.old_recid = atr.from_column_id		
UPDATE atr SET atr.to_column_id = atd.new_recid FROM #alert_table_relation_' + @temp_tbl_pid + ' atr INNER JOIN #alert_columns_definition_' + @temp_tbl_pid + ' atd ON atd.old_recid = atr.to_column_id		

insert into alert_table_relation
		([alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id]
		)
		 OUTPUT ''i'',''alert_table_relation'',inserted.alert_table_relation_id,inserted.alert_id,inserted.from_table_id,inserted.to_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[from_table_id],src.[from_column_id],src.[to_table_id],src.[to_column_id]
		FROM #alert_table_relation_' + @temp_tbl_pid + ' src LEFT JOIN alert_table_relation dst  
		ON src.alert_id=dst.alert_id AND src.from_table_id=dst.from_table_id AND src.to_table_id=dst.to_table_id
		AND src.from_column_id=dst.from_column_id AND src.to_column_id=dst.to_column_id
		WHERE dst.[alert_table_relation_id] IS NULL;
UPDATE #alert_table_relation_' + @temp_tbl_pid + ' SET new_recid = atr.alert_table_relation_id 
		FROM #alert_table_relation_' + @temp_tbl_pid + ' src INNER JOIN alert_table_relation atr ON src.alert_id=atr.alert_id 
		AND src.from_table_id=atr.from_table_id AND src.to_table_id=atr.to_table_id 
		AND src.from_column_id=atr.from_column_id AND src.to_column_id=atr.to_column_id 
		;
print(''--==============================END alert_table_relation============================='')		
'
--Below tables are not required for Alerts from Setup Advanced Workflow Rule menu, but required when it is mapped in Workflow 
--alert_category is NULL for Alerts from Setup Advanced Workflow Rule menu
IF (@alert_category IS NOT NULL) OR (@alert_category IS NULL AND @call_from_workflow = 'y') 
BEGIN
	IF OBJECT_ID('adiha_process.dbo.workflow_details') IS NOT NULL
	BEGIN
		EXEC dbo.spa_export_table_scripter @tbl_name = 'module_events' 
			, @filter = ' INNER JOIN #rule_id flt ON flt.alert_sql_name = src.workflow_name AND flt.alert_category = ''w''
					INNER JOIN adiha_process.dbo.workflow_details wd ON wd.workflow_id = src.module_events_id AND wd.workflow_id_type = 1' --- the alias name for source_table is always src
			, @is_result_output = 'n'
			, @primary_key_column1 = 'workflow_name'
			, @primary_key_column2 = NULL--'type_id'
			, @primary_key_column3 = NULL
			, @master_table_name = NULL 
			, @join_column_name_master = NULL 
			, @join_column_name_child = NULL 
			, @primary_key_column1_master = NULL
			, @primary_key_column2_master = NULL
			, @primary_key_column3_master = NULL
			, @export_lebel = 1
			, @temp_unique_id = @temp_tbl_pid
	END 
	ELSE
	BEGIN
		EXEC dbo.spa_export_table_scripter @tbl_name = 'module_events' 
			, @filter = ' INNER JOIN #rule_id flt ON flt.alert_sql_name = src.workflow_name AND flt.alert_category = ''w''' --- the alias name for source_table is always src
			, @is_result_output = 'n'
			, @primary_key_column1 = 'workflow_name'
			, @primary_key_column2 = NULL--'type_id'
			, @primary_key_column3 = NULL
			, @master_table_name = NULL 
			, @join_column_name_master = NULL 
			, @join_column_name_child = NULL 
			, @primary_key_column1_master = NULL
			, @primary_key_column2_master = NULL
			, @primary_key_column3_master = NULL
			, @export_lebel = 1
			, @temp_unique_id = @temp_tbl_pid
	END
	
	INSERT INTO #query_result (query_result)
	SELECT '	
	UPDATE me SET me.rule_table_id = atd.new_recid FROM #module_events_' + @temp_tbl_pid + ' me INNER JOIN #alert_table_definition_' + @temp_tbl_pid + ' atd ON atd.old_recid = me.rule_table_id

	UPDATE dbo.module_events SET [modules_id]=src.[modules_id],[event_id]=src.[event_id],[workflow_owner]=src.[workflow_owner],[rule_table_id]=src.[rule_table_id]
			   OUTPUT ''u'',''module_events'',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
		FROM #module_events_' + @temp_tbl_pid + ' src INNER JOIN module_events dst  ON src.workflow_name=dst.workflow_name;
	insert into module_events
			([modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id]
			)
			 OUTPUT ''i'',''module_events'',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_id],src.[event_id],src.[workflow_name],src.[workflow_owner],src.[rule_table_id]
			FROM #module_events_' + @temp_tbl_pid + ' src LEFT JOIN module_events dst  ON src.workflow_name=dst.workflow_name
			WHERE dst.[module_events_id] IS NULL;

			UPDATE #module_events_' + @temp_tbl_pid + ' SET new_recid = b.new_id 		
			FROM #module_events_' + @temp_tbl_pid + ' a 
			INNER JOIN 
			( SELECT TOP(1) new_id, unique_key1 FROM  #module_events_' + @temp_tbl_pid + ' src 
			INNER JOIN #old_new_id dst ON src.workflow_name=dst.unique_key1 AND dst.table_name=''module_events'' ORDER BY new_id DESC
			) b ON a.workflow_name= b.unique_key1 

	'
	-- Added below portion in case of same workflow and alert name. Alert export deletes previously inserted row for module_events and reinserts new row
	--Start	
	INSERT INTO #query_result (query_result)
	SELECT '
	UPDATE me SET me.modules_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_' + @temp_tbl_pid + ' mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_' + @temp_tbl_pid + ' sdv ON sdv.old_recid = me.modules_id

	UPDATE me SET me.event_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_' + @temp_tbl_pid + ' mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_' + @temp_tbl_pid + ' sdv ON sdv.old_recid = me.event_id
	'
	--END
	IF OBJECT_ID('adiha_process.dbo.workflow_details') IS NOT NULL
	BEGIN
		EXEC dbo.spa_export_table_scripter @tbl_name = 'event_trigger' 
			, @filter = ' INNER JOIN #rule_id flt ON flt.rule_id = src.alert_id INNER JOIN adiha_process.dbo.workflow_details wd ON wd.workflow_id = src.event_trigger_id AND wd.workflow_id_type = 2' --- the alias name for source_table is always src
			, @is_result_output = 'n'
			, @primary_key_column1 = 'modules_event_id'
			, @primary_key_column2 = 'alert_id'--'type_id'
			, @primary_key_column3 = NULL
			, @master_table_name = NULL 
			, @join_column_name_master = NULL 
			, @join_column_name_child = NULL 
			, @primary_key_column1_master = NULL
			, @primary_key_column2_master = NULL
			, @primary_key_column3_master = NULL
			, @export_lebel = 1
			, @temp_unique_id = @temp_tbl_pid
	END
	ELSE
	BEGIN
		EXEC dbo.spa_export_table_scripter @tbl_name = 'event_trigger' 
			, @filter = ' INNER JOIN #rule_id flt ON flt.rule_id = src.alert_id ' --- the alias name for source_table is always src
			, @is_result_output = 'n'
			, @primary_key_column1 = 'modules_event_id'
			, @primary_key_column2 = 'alert_id'--'type_id'
			, @primary_key_column3 = NULL
			, @master_table_name = NULL 
			, @join_column_name_master = NULL 
			, @join_column_name_child = NULL 
			, @primary_key_column1_master = NULL
			, @primary_key_column2_master = NULL
			, @primary_key_column3_master = NULL
			, @export_lebel = 1
			, @temp_unique_id = @temp_tbl_pid
	END
	IF @call_from_workflow = 'y'
	BEGIN
		INSERT INTO #query_result (query_result)
		SELECT '
		
		IF EXISTS (SELECT 1 FROM #module_events_' + @temp_tbl_pid + ')
		BEGIN
			DELETE FROM #event_trigger_' + @temp_tbl_pid + ' WHERE modules_event_id NOT IN (
			SELECT mebs.module_events_id FROM #module_events_' + @temp_tbl_pid + ' mebs INNER JOIN #event_trigger_' + @temp_tbl_pid + ' et 
			ON et.modules_event_id = mebs.module_events_id)
		END
		ELSE
		BEGIN
			DELETE FROM #event_trigger_' + @temp_tbl_pid + ' WHERE modules_event_id NOT IN 
			(SELECT meb.module_events_id FROM #module_events_bkup meb INNER JOIN #event_trigger_' + @temp_tbl_pid + ' et 
			ON et.modules_event_id = meb.module_events_id)
		END
		'
	END

	IF @call_from_workflow = 'n'
	BEGIN
		INSERT INTO #query_result (query_result)
		SELECT '
		-- Added in case of exporting alert only which is mapped in Workflow. There won''t be any value in module_events so foreign key violation message is thrown.
		DELETE FROM #event_trigger_' + @temp_tbl_pid + ' WHERE [modules_event_id] NOT IN (SELECT [module_events_id] FROM #module_events_' + @temp_tbl_pid + ')
		'
	END

	INSERT INTO #query_result (query_result)
	SELECT '	
	UPDATE et SET et.alert_id = asl.new_recid FROM #event_trigger_' + @temp_tbl_pid + ' et INNER JOIN #alert_sql_' + @temp_tbl_pid + ' asl ON asl.old_recid = et.alert_id WHERE et.alert_id <> -1
	UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_' + @temp_tbl_pid + ' et INNER JOIN #module_events_' + @temp_tbl_pid + ' me ON me.old_recid = et.modules_event_id
	'
	IF @call_from_workflow = 'y'
	BEGIN
		INSERT INTO #query_result (query_result)
		SELECT 'UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_' + @temp_tbl_pid + ' et INNER JOIN #module_events_bkup me ON me.old_recid = et.modules_event_id'
	END

	INSERT INTO #query_result (query_result)
		SELECT '
	print(''--==============================START event_trigger============================='')

	UPDATE event_trigger SET 
	 [initial_event] = src.[initial_event]
	, [manual_step] = src.[manual_step]
	, [is_disable] = src.[is_disable]
	, [report_paramset_id] = src.[report_paramset_id]
	, [report_filters] = src.[report_filters]
	 OUTPUT ''u'',''event_trigger'',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,src.report_paramset_id  
	 INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #event_trigger_' + @temp_tbl_pid + ' src 
	INNER JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id

	insert into event_trigger
			([modules_event_id],[alert_id],[initial_event], [manual_step], [is_disable], [report_paramset_id], [report_filters]
			)
			 OUTPUT ''i'',''event_trigger'',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,inserted.report_paramset_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_event_id],src.[alert_id],src.[initial_event], src.[manual_step], src.[is_disable], src.[report_paramset_id], src.[report_filters]
			FROM #event_trigger_' + @temp_tbl_pid + ' src LEFT JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id
			WHERE dst.[event_trigger_id] IS NULL;
	UPDATE #event_trigger_' + @temp_tbl_pid + ' SET new_recid =dst.new_id 
			FROM #event_trigger_' + @temp_tbl_pid + ' src INNER JOIN #old_new_id dst  ON src.modules_event_id=dst.unique_key1 AND src.alert_id=dst.unique_key2 AND dst.table_name=''event_trigger''
			AND ISNULL(src.report_paramset_id,-999) = ISNULL(dst.unique_key3,-999);
	print(''--==============================END event_trigger============================='')'

	IF OBJECT_ID('adiha_process.dbo.workflow_details') IS NOT NULL
	BEGIN
		EXEC dbo.spa_export_table_scripter @tbl_name = 'workflow_event_message' 
			, @filter = ' INNER JOIN event_trigger et ON et.event_trigger_id = src.event_trigger_id INNER JOIN #rule_id flt ON flt.rule_id = et.alert_id INNER JOIN adiha_process.dbo.workflow_details wd ON wd.workflow_id = src.event_message_id AND wd.workflow_id_type = 3' --- the alias name for source_table is always src
			, @is_result_output = 'n'
			, @primary_key_column1 = 'event_trigger_id'
			, @primary_key_column2 = 'event_message_name'--'type_id'
			, @primary_key_column3 = NULL
			, @master_table_name = NULL 
			, @join_column_name_master = NULL 
			, @join_column_name_child = NULL 
			, @primary_key_column1_master = NULL
			, @primary_key_column2_master = NULL
			, @primary_key_column3_master = NULL
			, @export_lebel = 1	
			, @temp_unique_id = @temp_tbl_pid
	END
	ELSE
	BEGIN
	EXEC dbo.spa_export_table_scripter @tbl_name = 'workflow_event_message' 
		, @filter = ' INNER JOIN event_trigger et ON et.event_trigger_id = src.event_trigger_id INNER JOIN #rule_id flt ON flt.rule_id = et.alert_id ' --- the alias name for source_table is always src
		, @is_result_output = 'n'
		, @primary_key_column1 = 'event_trigger_id'
		, @primary_key_column2 = 'event_message_name'--'type_id'
		, @primary_key_column3 = NULL
		, @master_table_name = NULL 
		, @join_column_name_master = NULL 
		, @join_column_name_child = NULL 
		, @primary_key_column1_master = NULL
		, @primary_key_column2_master = NULL
		, @primary_key_column3_master = NULL
		, @export_lebel = 1	
		, @temp_unique_id = @temp_tbl_pid
	END

	IF @call_from_workflow = 'y'
	BEGIN
		INSERT INTO #query_result (query_result)
		SELECT '
		IF EXISTS (SELECT 1 FROM #event_trigger_' + @temp_tbl_pid + ')
		BEGIN	
			DELETE FROM #workflow_event_message_' + @temp_tbl_pid + ' WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_' + @temp_tbl_pid + ' wem INNER JOIN #event_trigger_' + @temp_tbl_pid + ' et ON et.old_recid = wem.event_trigger_id)
		END
		'
	END

	IF @call_from_workflow = 'n'
	BEGIN
		INSERT INTO #query_result (query_result)
		SELECT '
		-- Added in case of exporting alert only which is mapped in Workflow. Delete if event trigger is not defined
		DELETE FROM #workflow_event_message_' + @temp_tbl_pid + ' WHERE [event_trigger_id] NOT IN (SELECT [event_trigger_id] FROM #event_trigger_' + @temp_tbl_pid + ')
		'
	END

	INSERT INTO #query_result (query_result)
	SELECT '
	UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_' + @temp_tbl_pid + ' wem INNER JOIN #event_trigger_' + @temp_tbl_pid + ' et ON et.old_recid = wem.event_trigger_id'

	IF @call_from_workflow = 'y'
	BEGIN
		INSERT INTO #query_result (query_result)
		SELECT '
		UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_' + @temp_tbl_pid + ' wem INNER JOIN #event_trigger_bkup et ON et.old_recid = wem.event_trigger_id
		UPDATE wem SET wem.next_module_events_id = meb.new_recid FROM #workflow_event_message_' + @temp_tbl_pid + ' wem  INNER JOIN #module_events_bkup meb ON meb.old_recid = wem.next_module_events_id'
	END

	EXEC dbo.spa_export_table_scripter @tbl_name = 'workflow_event_message' 
		, @filter = ' INNER JOIN event_trigger et ON et.event_trigger_id = src.event_trigger_id INNER JOIN #rule_id flt ON flt.rule_id = et.alert_id ' --- the alias name for source_table is always src
		, @is_result_output = 'n'
		, @primary_key_column1 = 'event_trigger_id'
		, @primary_key_column2 = 'event_message_name'--
		, @primary_key_column3 = NULL
		, @master_table_name = NULL 
		, @join_column_name_master = NULL 
		, @join_column_name_child = NULL 
		, @primary_key_column1_master = NULL
		, @primary_key_column2_master = NULL
		, @primary_key_column3_master = NULL
		, @export_lebel = 2
		, @temp_unique_id = @temp_tbl_pid

	IF @call_from_workflow = 'y'
	BEGIN
		INSERT INTO #query_result (query_result)
		SELECT '	
		INSERT INTO #workflow_event_message_bkup (event_message_id, event_trigger_id, event_message_name, message_template_id, message, mult_approval_required, comment_required, approval_action_required, self_notify, notify_trader, counterparty_contact_type, next_module_events_id, minimum_approval_required, optional_event_msg, automatic_proceed, notification_type, new_recid, old_recid)
		SELECT wem.event_message_id, wem.event_trigger_id, wem.event_message_name, wem.message_template_id, wem.message, wem.mult_approval_required, wem.comment_required, wem.approval_action_required, wem.self_notify, wem.notify_trader, wem.counterparty_contact_type, wem.next_module_events_id, wem.minimum_approval_required, wem.optional_event_msg, wem.automatic_proceed, wem.notification_type, wem.new_recid, wem.old_recid FROM #workflow_event_message_' + @temp_tbl_pid + ' wem
		LEFT JOIN #workflow_event_message_bkup wemb ON wemb.old_recid = wem.old_recid 
		WHERE wemb.old_recid IS NULL'
	END

	EXEC dbo.spa_export_table_scripter @tbl_name = 'application_security_role'
		, @filter = ' INNER JOIN #application_security_role flt ON flt.role_id = src.role_id'  --- the alias name for source_table is always src
		, @is_result_output = 'n'
		, @primary_key_column1 = 'role_name'
		, @primary_key_column2 = NULL
		, @primary_key_column3 = NULL
		, @master_table_name = NULL 
		, @join_column_name_master = NULL 
		, @join_column_name_child = NULL 
		, @primary_key_column1_master = NULL
		, @primary_key_column2_master = NULL
		, @primary_key_column3_master = NULL
		, @export_lebel = 0
		, @temp_unique_id = @temp_tbl_pid

	EXEC dbo.spa_export_table_scripter @tbl_name = 'workflow_event_user_role'
		, @filter = ' INNER JOIN #workflow_event_user_role flt ON flt.event_user_role_id = src.event_user_role_id'  --- the alias name for source_table is always src
		, @is_result_output = 'n'
		, @primary_key_column1 = 'event_user_role_id'
		, @primary_key_column2 = NULL
		, @primary_key_column3 = NULL
		, @master_table_name = NULL 
		, @join_column_name_master = NULL 
		, @join_column_name_child = NULL 
		, @primary_key_column1_master = NULL
		, @primary_key_column2_master = NULL
		, @primary_key_column3_master = NULL
		, @export_lebel = 1
		, @temp_unique_id = @temp_tbl_pid

		INSERT INTO #query_result (query_result)
		SELECT '	
		DELETE FROM #workflow_event_user_role_' + @temp_tbl_pid + ' WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_' + @temp_tbl_pid + ' wem INNER JOIN #workflow_event_user_role_' + @temp_tbl_pid + ' weur ON weur.event_message_id = wem.event_message_id	)
		'
	
	INSERT INTO #query_result (query_result)
	SELECT '	
	UPDATE weur SET weur.role_id = asr.new_recid FROM #workflow_event_user_role_' + @temp_tbl_pid + ' weur INNER JOIN #application_security_role_' + @temp_tbl_pid + ' asr ON asr.old_recid = weur.role_id
	UPDATE weur SET weur.event_message_id = wem.new_recid FROM #workflow_event_message_' + @temp_tbl_pid + ' wem INNER JOIN #workflow_event_user_role_' + @temp_tbl_pid + ' weur ON weur.event_message_id = wem.old_recid
	'

	EXEC dbo.spa_export_table_scripter @tbl_name = 'workflow_event_user_role'
		, @filter = ' INNER JOIN #workflow_event_user_role flt ON flt.event_user_role_id = src.event_user_role_id'  --- the alias name for source_table is always src
		, @is_result_output = 'n'
		, @primary_key_column1 = 'event_user_role_id'
		, @primary_key_column2 = NULL
		, @primary_key_column3 = NULL
		, @master_table_name = NULL 
		, @join_column_name_master = NULL 
		, @join_column_name_child = NULL 
		, @primary_key_column1_master = NULL
		, @primary_key_column2_master = NULL
		, @primary_key_column3_master = NULL
		, @export_lebel = 2
		, @temp_unique_id = @temp_tbl_pid

	EXEC dbo.spa_export_table_scripter @tbl_name = 'workflow_event_message_documents'
		, @filter = ' INNER JOIN #workflow_event_message_documents flt ON flt.message_document_id = src.message_document_id'  --- the alias name for source_table is always src
		, @is_result_output = 'n'
		, @primary_key_column1 = 'message_document_id'
		, @primary_key_column2 = NULL
		, @primary_key_column3 = NULL
		, @master_table_name = NULL 
		, @join_column_name_master = NULL 
		, @join_column_name_child = NULL 
		, @primary_key_column1_master = NULL
		, @primary_key_column2_master = NULL
		, @primary_key_column3_master = NULL
		, @export_lebel = 1
		, @temp_unique_id = @temp_tbl_pid

	IF @call_from_workflow = 'y'
	BEGIN
		INSERT INTO #query_result (query_result)
		SELECT '
		DELETE FROM #workflow_event_message_documents_' + @temp_tbl_pid + ' WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #workflow_event_message_documents_' + @temp_tbl_pid + ' wemd ON wem.event_message_id = wemd.event_message_id)'	
	END
	ELSE
	BEGIN
		INSERT INTO #query_result (query_result)
		SELECT '
		DELETE FROM #workflow_event_message_documents_' + @temp_tbl_pid + ' WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_' + @temp_tbl_pid + ' wem 
		INNER JOIN #workflow_event_message_documents_' + @temp_tbl_pid + ' wemd ON wem.event_message_id = wemd.event_message_id)'	
	END

	INSERT INTO #query_result (query_result)
	SELECT '
	UPDATE wemd SET wemd.event_message_id = wem.new_recid FROM #workflow_event_message_' + @temp_tbl_pid + ' wem INNER JOIN #workflow_event_message_documents_' + @temp_tbl_pid + ' wemd ON wemd.event_message_id = wem.old_recid
	UPDATE wemd SET wemd.document_template_id = sdv.new_recid FROM #workflow_event_message_documents_' + @temp_tbl_pid + ' wemd INNER JOIN #static_data_value_' + @temp_tbl_pid + ' sdv ON sdv.old_recid = wemd.document_template_id
	UPDATE wemd SET wemd.document_category = sdv.new_recid FROM #workflow_event_message_documents_' + @temp_tbl_pid + ' wemd INNER JOIN #static_data_value_' + @temp_tbl_pid + ' sdv ON sdv.old_recid = wemd.document_category
	'

	-- for document category need to insert in Contract_report_template as well . need to confirm
	EXEC dbo.spa_export_table_scripter @tbl_name = 'workflow_event_message_documents'
		, @filter = ' INNER JOIN #workflow_event_message_documents flt ON flt.message_document_id = src.message_document_id'  --- the alias name for source_table is always src
		, @is_result_output = 'n'
		, @primary_key_column1 = 'message_document_id'
		, @primary_key_column2 = NULL
		, @primary_key_column3 = NULL
		, @master_table_name = NULL 
		, @join_column_name_master = NULL 
		, @join_column_name_child = NULL 
		, @primary_key_column1_master = NULL
		, @primary_key_column2_master = NULL
		, @primary_key_column3_master = NULL
		, @export_lebel = 2
		, @temp_unique_id = @temp_tbl_pid

	INSERT INTO #query_result (query_result)
	SELECT '
	UPDATE w2 SET w2.new_recid = w1.message_document_id
	FROM workflow_event_message_documents w1 
	INNER JOIN #workflow_event_message_documents_' + @temp_tbl_pid + ' w2 ON w1.event_message_id = w2.event_message_id
		AND ISNULL(w1.document_template_id, ''-1'') = ISNULL(w2.document_template_id, ''-1'')
		AND ISNULL(w1.document_category, ''-1'') = ISNULL(w2.document_category, ''-1'')'

	EXEC dbo.spa_export_table_scripter @tbl_name = 'workflow_event_message_details'
		, @filter = ' INNER JOIN #workflow_event_message_documents flt ON flt.message_document_id = src.event_message_document_id'  --- the alias name for source_table is always src
		, @is_result_output = 'n'
		, @primary_key_column1 = 'message_detail_id'
		, @primary_key_column2 = NULL
		, @primary_key_column3 = NULL
		, @master_table_name = NULL 
		, @join_column_name_master = NULL 
		, @join_column_name_child = NULL 
		, @primary_key_column1_master = NULL
		, @primary_key_column2_master = NULL
		, @primary_key_column3_master = NULL
		, @export_lebel = 1
		, @temp_unique_id = @temp_tbl_pid

	INSERT INTO #query_result (query_result)
	SELECT '
	DELETE FROM #workflow_event_message_details_' + @temp_tbl_pid + ' WHERE message_detail_id NOT IN (
		SELECT wemd.message_detail_id from #workflow_event_message_documents_' + @temp_tbl_pid + ' wemdd 
		INNER JOIN #workflow_event_message_details_' + @temp_tbl_pid + ' wemd ON wemd.event_message_document_id = wemdd.message_document_id)

	UPDATE wemd SET wemd.event_message_document_id = wem.new_recid FROM #workflow_event_message_documents_' + @temp_tbl_pid + ' wem INNER JOIN #workflow_event_message_details_' + @temp_tbl_pid + ' wemd ON wemd.event_message_document_id = wem.old_recid
	UPDATE wemd SET wemd.counterparty_contact_type = sdv.new_recid FROM #workflow_event_message_details_' + @temp_tbl_pid + ' wemd INNER JOIN #static_data_value_' + @temp_tbl_pid + '  sdv ON sdv.old_recid = wemd.counterparty_contact_type
	UPDATE wemd SET wemd.delivery_method = sdv.new_recid FROM #workflow_event_message_details_' + @temp_tbl_pid + ' wemd INNER JOIN #static_data_value_' + @temp_tbl_pid + '  sdv ON sdv.old_recid = wemd.delivery_method
	UPDATE wemd SET wemd.internal_contact_type = sdv.new_recid FROM #workflow_event_message_details_' + @temp_tbl_pid + ' wemd INNER JOIN #static_data_value_' + @temp_tbl_pid + '  sdv ON sdv.old_recid = wemd.internal_contact_type
	'

	EXEC dbo.spa_export_table_scripter @tbl_name = 'workflow_event_message_details'
		, @filter = ' INNER JOIN #workflow_event_message_documents flt ON flt.message_document_id = src.event_message_document_id'  --- the alias name for source_table is always src
		, @is_result_output = 'n'
		, @primary_key_column1 = 'message_detail_id'
		, @primary_key_column2 = NULL
		, @primary_key_column3 = NULL
		, @master_table_name = NULL 
		, @join_column_name_master = NULL 
		, @join_column_name_child = NULL 
		, @primary_key_column1_master = NULL
		, @primary_key_column2_master = NULL
		, @primary_key_column3_master = NULL
		, @export_lebel = 2
		, @temp_unique_id = @temp_tbl_pid

	EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_reports' 
		, @filter = ' INNER JOIN #alert_reports flt ON flt.alert_report_id = src.alert_reports_id ' --- the alias name for source_table is always src
		, @is_result_output = 'n'
		, @primary_key_column1 = 'event_message_id'
		, @primary_key_column2 = 'report_desc'
		, @primary_key_column3 = 'table_prefix'
		, @master_table_name = NULL 
		, @join_column_name_master = NULL 
		, @join_column_name_child = NULL 
		, @primary_key_column1_master = NULL
		, @primary_key_column2_master = NULL
		, @primary_key_column3_master = NULL
		, @export_lebel = 1
		, @temp_unique_id = @temp_tbl_pid

	IF @call_from_workflow = 'y'
	BEGIN
		INSERT INTO #query_result (query_result)
		SELECT '
		DELETE FROM #alert_reports_' + @temp_tbl_pid + ' WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_reports_' + @temp_tbl_pid + ' ar ON wem.event_message_id = ar.event_message_id)'	
	END
	ELSE
	BEGIN
		INSERT INTO #query_result (query_result)
		SELECT '
		DELETE FROM #alert_reports_' + @temp_tbl_pid + ' WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_' + @temp_tbl_pid + ' wem 
		INNER JOIN #alert_reports_' + @temp_tbl_pid + ' ar ON wem.event_message_id = ar.event_message_id)'	
	END

	INSERT INTO #query_result (query_result)
	SELECT '
	UPDATE ar SET ar.event_message_id = wem.new_recid FROM #workflow_event_message_' + @temp_tbl_pid + ' wem INNER JOIN #alert_reports_' + @temp_tbl_pid + ' ar ON ar.event_message_id = wem.old_recid
	'	

	EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_reports' 
		, @filter = ' INNER JOIN #alert_reports flt ON flt.alert_report_id = src.alert_reports_id ' --- the alias name for source_table is always src
		, @is_result_output = 'n'
		, @primary_key_column1 = 'event_message_id'
		, @primary_key_column2 = 'report_desc'
		, @primary_key_column3 = 'table_prefix'
		, @master_table_name = NULL 
		, @join_column_name_master = NULL 
		, @join_column_name_child = NULL 
		, @primary_key_column1_master = NULL
		, @primary_key_column2_master = NULL
		, @primary_key_column3_master = NULL
		, @export_lebel = 2	
		, @temp_unique_id = @temp_tbl_pid

	EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_report_params' 
		, @filter = ' INNER JOIN #alert_reports flt ON flt.alert_report_id = src.alert_report_id ' --- the alias name for source_table is always src
		, @is_result_output = 'n'
		, @primary_key_column1 = 'alert_report_id'
		, @primary_key_column2 = NULL--'type_id'
		, @primary_key_column3 = NULL
		, @master_table_name = NULL 
		, @join_column_name_master = NULL 
		, @join_column_name_child = NULL 
		, @primary_key_column1_master = NULL
		, @primary_key_column2_master = NULL
		, @primary_key_column3_master = NULL
		, @export_lebel = 1
		, @temp_unique_id = @temp_tbl_pid

	IF @call_from_workflow = 'y'
	BEGIN
		INSERT INTO #query_result (query_result)
		SELECT '
		DELETE FROM #alert_report_params_' + @temp_tbl_pid + ' WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_report_params_' + @temp_tbl_pid + ' ar ON wem.event_message_id = ar.event_message_id)'	
	END
	ELSE
	BEGIN
		INSERT INTO #query_result (query_result)
		SELECT '
		DELETE FROM #alert_report_params_' + @temp_tbl_pid + ' WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_' + @temp_tbl_pid + ' wem 
		INNER JOIN #alert_report_params_' + @temp_tbl_pid + ' ar ON wem.event_message_id = ar.event_message_id)'	
	END


	INSERT INTO #query_result (query_result)
	SELECT '
	UPDATE arp SET arp.alert_report_id = ar.alert_reports_id FROM #alert_report_params_' + @temp_tbl_pid + ' arp INNER JOIN #alert_reports_' + @temp_tbl_pid + ' ar ON ar.old_recid = arp.alert_report_id
	UPDATE arp SET arp.main_table_id = art.alert_rule_table_id FROM #alert_report_params_' + @temp_tbl_pid + ' arp INNER JOIN #alert_rule_table_' + @temp_tbl_pid + ' art ON art.old_recid = arp.main_table_id
	'	

	EXEC dbo.spa_export_table_scripter @tbl_name = 'alert_report_params' 
		, @filter = ' INNER JOIN #alert_reports flt ON flt.alert_report_id = src.alert_report_id ' --- the alias name for source_table is always src
		, @is_result_output = 'n'
		, @primary_key_column1 = 'alert_report_id'
		, @primary_key_column2 = NULL--'type_id'
		, @primary_key_column3 = NULL
		, @master_table_name = NULL 
		, @join_column_name_master = NULL 
		, @join_column_name_child = NULL 
		, @primary_key_column1_master = NULL
		, @primary_key_column2_master = NULL
		, @primary_key_column3_master = NULL
		, @export_lebel = 2					
		, @temp_unique_id = @temp_tbl_pid
END
IF @call_from_workflow = 'n'
BEGIN
	INSERT INTO #query_result (query_result)
	SELECT '
		if @@TRANCOUNT>0
			COMMIT
		SELECT ''Rule Exported successfully'' SUCCESS
	END TRY
	BEGIN CATCH
		if @@TRANCOUNT>0
			ROLLBACK

		SELECT ERROR_MESSAGE() ERROR

	END CATCH
	'
	SELECT query_result FROM #query_result ORDER BY rowid asc
END
ELSE
BEGIN
	SELECT rowid, query_result FROM #query_result ORDER BY rowid asc
END
GO	
