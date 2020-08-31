 --============================================================================================================================
 --Create date: 2017-3-10
 --Author : ashakya@pioneersolutionsglobal.com
 --Description: Exports Workflow/Alert
               
 --Params:
 --	@workflow_group VARCHAR(100) = NULL, -- 'Workflow Group name'
 --============================================================================================================================

IF OBJECT_ID('spa_export_alert_workflow') IS NOT NULL
	DROP PROC dbo.spa_export_alert_workflow
GO

CREATE PROC [dbo].[spa_export_alert_workflow]
	@workflow_group VARCHAR(100) = NULL -- Workflow Group
AS

SET NOCOUNT ON

/*	select * from #tmp_wg_task
	select * from module_events --1 asd
	select * from event_trigger where event_trigger_id = 2322 --2 analystconfirm
	select * from workflow_event_message --  3 aaa ert
	select * from workflow_event_action --4 
	*/

--DECLARE @workflow_group VARCHAR(50) = 'atest'
IF OBJECT_ID('tempdb..#query_result') IS NOT NULL
	DROP TABLE #query_result
	
CREATE TABLE #query_result (rowid INT IDENTITY(1,1), query_result VARCHAR(MAX) COLLATE DATABASE_DEFAULT)
		
IF OBJECT_ID('tempdb..#final_query_result') IS NOT NULL
	DROP TABLE #final_query_result
	 
CREATE TABLE #final_query_result (rowid INT, query_result VARCHAR(MAX) COLLATE DATABASE_DEFAULT, alert_seq INT)	
	
IF OBJECT_ID('tempdb..#workflow_query_result') IS NOT NULL
	DROP TABLE #workflow_query_result
	 
CREATE TABLE #workflow_query_result (rowid INT, query_result VARCHAR(MAX) COLLATE DATABASE_DEFAULT)	
	
IF OBJECT_ID('tempdb..#alert_query_result') IS NOT NULL
	DROP TABLE #alert_query_result
	 
CREATE TABLE #alert_query_result (rowid INT IDENTITY(1,1), query_result VARCHAR(MAX) COLLATE DATABASE_DEFAULT, alert_export_seq INT)	
	
DECLARE @task_id INT 
SELECT @task_id = id FROM workflow_schedule_task w1 WHERE text = @workflow_group
	
INSERT INTO #query_result (query_result)
SELECT '

BEGIN TRY
BEGIN TRAN

IF OBJECT_ID(''tempdb..#event_trigger_bkup'') IS NULL 
BEGIN
	CREATE TABLE #event_trigger_bkup
		(
		[event_trigger_id] INT,[modules_event_id] INT,[alert_id] INT,[initial_event] CHAR(1) COLLATE DATABASE_DEFAULT,[manual_step] CHAR(1) COLLATE DATABASE_DEFAULT, [is_disable] CHAR(1) COLLATE DATABASE_DEFAULT, [report_paramset_id] VARCHAR(MAX) COLLATE DATABASE_DEFAULT, [report_filters] INT, new_recid INT, old_recid INT
		);
END
ELSE
BEGIN
	TRUNCATE TABLE #event_trigger_bkup
END

IF OBJECT_ID(''tempdb..#workflow_event_message_bkup'') IS NULL
BEGIN
	CREATE TABLE #workflow_event_message_bkup
		(
		[event_message_id] INT,[event_trigger_id] INT,[event_message_name] VARCHAR(100) COLLATE DATABASE_DEFAULT, [message_template_id] INT,[message] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [mult_approval_required] CHAR(1) COLLATE DATABASE_DEFAULT, [comment_required] CHAR(1) COLLATE DATABASE_DEFAULT, [approval_action_required] CHAR(1) COLLATE DATABASE_DEFAULT, [self_notify] CHAR(1) COLLATE DATABASE_DEFAULT , [notify_trader] CHAR(1) COLLATE DATABASE_DEFAULT, [counterparty_contact_type] INT, [next_module_events_id] INT, [minimum_approval_required] INT, [optional_event_msg] CHAR(1) COLLATE DATABASE_DEFAULT, [automatic_proceed] CHAR(1) COLLATE DATABASE_DEFAULT, notification_type INT, new_recid INT, old_recid INT
		);
END
ELSE
BEGIN
	TRUNCATE TABLE #workflow_event_message_bkup
END

IF OBJECT_ID(''tempdb..#module_events_bkup'') IS NULL 
BEGIN
CREATE TABLE #module_events_bkup
	(
	[module_events_id] INT,[modules_id] INT,[event_id] INT,[workflow_name] VARCHAR(100) COLLATE DATABASE_DEFAULT, [workflow_owner] VARCHAR(100) COLLATE DATABASE_DEFAULT, [rule_table_id] INT, new_recid INT, old_recid INT
	);
END
ELSE
BEGIN
	TRUNCATE TABLE #module_events_bkup
END	

IF OBJECT_ID(''tempdb..#alert_sql_bkup'') IS NULL 
BEGIN
CREATE TABLE #alert_sql_bkup
	(
	 [alert_sql_id] INT,[workflow_only] VARCHAR(1) COLLATE DATABASE_DEFAULT, [message] VARCHAR(500) COLLATE DATABASE_DEFAULT, [notification_type] INT, [sql_statement] VARCHAR(MAX) COLLATE DATABASE_DEFAULT, [alert_sql_name] VARCHAR(100) COLLATE DATABASE_DEFAULT, [is_active] CHAR(1) COLLATE DATABASE_DEFAULT, [alert_type] CHAR(1) COLLATE DATABASE_DEFAULT, [rule_category] INT, [system_rule] CHAR(1) COLLATE DATABASE_DEFAULT, [alert_category] CHAR(1) COLLATE DATABASE_DEFAULT, new_recid INT, old_recid INT
	);
END
ELSE
BEGIN
	TRUNCATE TABLE #alert_sql_bkup
END

DECLARE @task_id INT 
SELECT @task_id = id FROM workflow_schedule_task w1 WHERE text = ''' + @workflow_group + '''
EXEC spa_workflow_schedule  @flag=''d'',@task_id=@task_id,@task_level=0

IF OBJECT_ID(''tempdb..#old_new_id'') IS NULL
CREATE TABLE #old_new_id(tran_type VARCHAR(1) COLLATE DATABASE_DEFAULT, table_name VARCHAR(250) COLLATE DATABASE_DEFAULT, new_id INT, old_id INT, unique_key1 VARCHAR(250) COLLATE DATABASE_DEFAULT, unique_key2 VARCHAR(250) COLLATE DATABASE_DEFAULT, unique_key3 VARCHAR(250) COLLATE DATABASE_DEFAULT)
ELSE
TRUNCATE TABLE #old_new_id
;'

IF OBJECT_ID('tempdb..#tmp_wg_task') IS NOT NULL
	DROP TABLE #tmp_wg_task
CREATE TABLE #tmp_wg_task (task_id INT, [text] VARCHAR(500) COLLATE DATABASE_DEFAULT, [start_date] DATETIME, duration INT, progress FLOAT, sort_order INT,  parent INT, workflow_id INT, workflow_id_type INT, system_defined INT )

IF OBJECT_ID('adiha_process.dbo.workflow_details') IS NOT NULL
	DROP TABLE adiha_process.dbo.workflow_details

CREATE TABLE adiha_process.dbo.workflow_details (task_id INT, [text] VARCHAR(500) COLLATE DATABASE_DEFAULT, [start_date] DATETIME, duration INT, progress FLOAT, sort_order INT,  parent INT, workflow_id INT, workflow_id_type INT, system_defined INT )

INSERT INTO #tmp_wg_task(task_id, [text], [start_date], duration, progress, sort_order, parent, workflow_id, workflow_id_type, system_defined)
SELECT w5.id 
	, w5.[text]
	, w5.[start_date]
	, w5.duration
	, w5.progress
	, w5.sort_order
	, w5.parent
	, w5.workflow_id
	, w5.workflow_id_type
	, w5.system_defined
FROM workflow_schedule_task w1
INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
INNER JOIN workflow_schedule_task w3 ON w2.id = w3.parent
INNER JOIN workflow_schedule_task w4 ON w3.id = w4.parent
INNER JOIN workflow_schedule_task w5 ON w4.id = w5.parent
LEFT JOIN module_events me ON w2.workflow_id = me.module_events_id AND w2.workflow_id_type = 1
WHERE w1.id = @task_id

INSERT INTO #tmp_wg_task(task_id, [text], [start_date], duration, progress, sort_order, parent, workflow_id, workflow_id_type, system_defined)
SELECT w4.id 
	, w4.[text]
	, w4.[start_date]
	, w4.duration
	, w4.progress
	, w4.sort_order
	, w4.parent
	, w4.workflow_id
	, w4.workflow_id_type
	, w4.system_defined
FROM workflow_schedule_task w1
INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
INNER JOIN workflow_schedule_task w3 ON w2.id = w3.parent
INNER JOIN workflow_schedule_task w4 ON w3.id = w4.parent
LEFT JOIN module_events me ON w2.workflow_id = me.module_events_id AND w2.workflow_id_type = 1
WHERE w1.id = @task_id 

INSERT INTO #tmp_wg_task(task_id, [text], [start_date], duration, progress, sort_order, parent, workflow_id, workflow_id_type, system_defined)
SELECT  w3.id 
	, w3.[text]
	, w3.[start_date]
	, w3.duration
	, w3.progress
	, w3.sort_order
	, w3.parent
	, w3.workflow_id
	, w3.workflow_id_type
	, w3.system_defined FROM workflow_schedule_task w1
INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
INNER JOIN workflow_schedule_task w3 ON w2.id = w3.parent
LEFT JOIN module_events me ON w2.workflow_id = me.module_events_id AND w2.workflow_id_type = 1
WHERE w1.id = @task_id 

INSERT INTO #tmp_wg_task(task_id, [text], [start_date], duration, progress, sort_order, parent, workflow_id, workflow_id_type, system_defined)
SELECT  w2.id 
	, w2.[text]
	, w2.[start_date]
	, w2.duration
	, w2.progress
	, w2.sort_order
	, w2.parent
	, w2.workflow_id
	, w2.workflow_id_type
	, w2.system_defined FROM workflow_schedule_task w1
INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
LEFT JOIN module_events me ON w2.workflow_id = me.module_events_id AND w2.workflow_id_type = 1
WHERE w1.id = @task_id
	
INSERT INTO #tmp_wg_task(task_id, [text], [start_date], duration, progress, sort_order, parent, workflow_id, workflow_id_type, system_defined)
SELECT id, [text], [start_date], duration, progress, sort_order, parent, workflow_id, workflow_id_type, system_defined
FROM workflow_schedule_task WHERE id = @task_id

INSERT INTO adiha_process.dbo.workflow_details (task_id, [text], [start_date], duration, progress, sort_order, parent, workflow_id, workflow_id_type, system_defined)
SELECT task_id, [text], [start_date], duration, progress, sort_order, parent, workflow_id, workflow_id_type, system_defined FROM #tmp_wg_task

IF OBJECT_ID('tempdb..#alert_table_definition') IS NOT NULL
	DROP TABLE #alert_table_definition

CREATE TABLE #alert_table_definition (alert_table_definition_id INT)

INSERT INTO #alert_table_definition (alert_table_definition_id)	
SELECT DISTINCT me.rule_table_id
FROM #tmp_wg_task tmp
INNER JOIN module_events me ON me.module_events_id = tmp.workflow_id AND tmp.workflow_id_type = 1

IF OBJECT_ID('tempdb..#alert_columns_definition') IS NOT NULL
	DROP TABLE #alert_columns_definition

CREATE TABLE #alert_columns_definition (alert_table_id INT)

INSERT INTO #alert_columns_definition (alert_table_id)	
SELECT acd.alert_columns_definition_id FROM alert_columns_definition acd INNER JOIN #alert_table_definition atd ON atd.alert_table_definition_id = acd.alert_table_id
		 
IF OBJECT_ID('tempdb..#module_event') IS NOT NULL
	DROP TABLE #module_event

CREATE TABLE #module_event (module_events_id INT)

INSERT INTO #module_event
SELECT module_events_id
FROM #tmp_wg_task tmp
INNER JOIN module_events me ON me.module_events_id = tmp.workflow_id AND tmp.workflow_id_type = 1

IF OBJECT_ID('tempdb..#static_data_value_id') IS NOT NULL
	DROP TABLE #static_data_value_id

CREATE TABLE #static_data_value_id (value_id INT)

INSERT INTO #static_data_value_id (value_id)
SELECT DISTINCT modules_id
FROM #tmp_wg_task tmp
INNER JOIN module_events me ON me.module_events_id = tmp.workflow_id AND tmp.workflow_id_type = 1
LEFT JOIN #static_data_value_id sdv ON sdv.value_id = me.modules_id 
WHERE sdv.value_id IS NULL

INSERT INTO #static_data_value_id (value_id)
SELECT DISTINCT event_id
FROM #tmp_wg_task tmp
INNER JOIN module_events me ON me.module_events_id = tmp.workflow_id AND tmp.workflow_id_type = 1
LEFT JOIN #static_data_value_id sdv ON sdv.value_id = me.event_id 
WHERE sdv.value_id IS NULL
	
INSERT INTO #static_data_value_id (value_id)
SELECT DISTINCT status_id FROM workflow_event_action wea 
INNER JOIN #tmp_wg_task wst ON wst.workflow_id = wea.event_message_id  AND wst.workflow_id_type = 4
LEFT JOIN #static_data_value_id sdv ON sdv.value_id = wea.status_id 
WHERE sdv.value_id IS NULL

IF OBJECT_ID('tempdb..#workflow_event_action') IS NOT NULL
	DROP TABLE #workflow_event_action

CREATE TABLE #workflow_event_action (event_action_id INT)

INSERT INTO #workflow_event_action(event_action_id)
SELECT wea.event_action_id FROM #tmp_wg_task wst
INNER JOIN workflow_event_action wea ON wst.workflow_id = wea.event_message_id
	AND wst.workflow_id_type = 4

IF OBJECT_ID('tempdb..#event_trigger') IS NOT NULL
	DROP TABLE #event_trigger

CREATE TABLE #event_trigger (event_trigger_id INT)

INSERT INTO #event_trigger(event_trigger_id)
SELECT et.event_trigger_id
FROM #tmp_wg_task wst
INNER JOIN event_trigger et ON et.event_trigger_id = wst.workflow_id AND wst.workflow_id_type = 2

IF OBJECT_ID('tempdb..#workflow_event_message') IS NOT NULL
	DROP TABLE #workflow_event_message

CREATE TABLE #workflow_event_message (event_message_id INT)

INSERT INTO #workflow_event_message(event_message_id)
SELECT wem.event_message_id
FROM #tmp_wg_task wst
INNER JOIN workflow_event_message wem ON wem.event_message_id = wst.workflow_id AND wst.workflow_id_type = 3

DECLARE @temp_tbl_pid VARCHAR(50) = dbo.FNAGetNewID()

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

EXEC dbo.spa_export_table_scripter @tbl_name = 'module_events' 
	, @filter = ' INNER JOIN #module_event flt ON flt.module_events_id = src.module_events_id ' --- the alias name for source_table is always src
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

INSERT INTO #query_result (query_result)
SELECT '
UPDATE me SET me.rule_table_id = atd.new_recid FROM #module_events_' + @temp_tbl_pid + ' me INNER JOIN #alert_table_definition_' + @temp_tbl_pid + ' atd ON atd.old_recid = me.rule_table_id
UPDATE me SET me.modules_id = sdv.new_recid FROM #module_events_' + @temp_tbl_pid + ' me INNER JOIN #static_data_value_' + @temp_tbl_pid + ' sdv ON sdv.old_recid = me.modules_id 
UPDATE me SET me.event_id = sdv.new_recid FROM #module_events_' + @temp_tbl_pid + ' me INNER JOIN #static_data_value_' + @temp_tbl_pid + ' sdv ON sdv.old_recid = me.event_id 
'

EXEC dbo.spa_export_table_scripter @tbl_name = 'module_events' 
	, @filter = ' INNER JOIN #module_event flt ON flt.module_events_id = src.module_events_id ' --- the alias name for source_table is always src
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
	, @export_lebel = 2
	, @temp_unique_id = @temp_tbl_pid
		
INSERT INTO #query_result (query_result)
SELECT '
INSERT INTO #module_events_bkup(module_events_id, modules_id, event_id, workflow_name, workflow_owner, rule_table_id, new_recid, old_recid)	
SELECT me.module_events_id, me.modules_id, me.event_id, me.workflow_name, me.workflow_owner, me.rule_table_id, me.new_recid, me.old_recid FROM #module_events_' + @temp_tbl_pid + ' me
LEFT JOIN #module_events_bkup meb ON meb.old_recid = me.old_recid 
WHERE meb.old_recid IS NULL'

INSERT INTO #final_query_result (rowid, query_result)
SELECT rowid, query_result FROM #query_result 
	
TRUNCATE TABLE #query_result

DECLARE @alert_sql_name VARCHAR(500)
DECLARE @alert_num INT = 1
DECLARE @max_final_query_id INT
	
DECLARE @generate_alert_sql CURSOR
SET @generate_alert_sql = CURSOR FOR
	SELECT alert_sql_name FROM alert_sql WHERE alert_sql_id IN (
		SELECT alert_id FROM #tmp_wg_task wst INNER JOIN event_trigger et ON et.event_trigger_id = wst.workflow_id AND wst.workflow_id_type = 2)
OPEN @generate_alert_sql
FETCH NEXT
FROM @generate_alert_sql INTO @alert_sql_name
WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #alert_query_result (alert_export_seq, query_result)
	EXEC spa_export_alert @alert_sql_name, 'y'
		
	SELECT @max_final_query_id = MAX(rowid) FROM #final_query_result

	INSERT INTO #final_query_result (rowid, query_result, alert_seq)
	SELECT alert_export_seq + @max_final_query_id, query_result, @alert_num FROM #alert_query_result

	SET @alert_num = @alert_num + 1
	TRUNCATE TABLE #alert_query_result
	TRUNCATE TABLE #query_result
		
	FETCH NEXT
	FROM @generate_alert_sql INTO @alert_sql_name
END
CLOSE @generate_alert_sql
DEALLOCATE @generate_alert_sql

TRUNCATE TABLE #query_result

INSERT INTO #query_result (query_result)
SELECT'
UPDATE a SET a.new_recid = me.module_events_id from #module_events_' + @temp_tbl_pid + ' a 
INNER JOIN module_events me ON me.modules_id = a.modules_id AND me.event_id = a.event_id AND me.workflow_name = a.workflow_name
	
UPDATE a SET a.new_recid = me.module_events_id from #module_events_bkup a 
INNER JOIN module_events me ON me.modules_id = a.modules_id AND me.event_id = a.event_id AND me.workflow_name = a.workflow_name
'

EXEC dbo.spa_export_table_scripter @tbl_name = 'event_trigger' 
	, @filter = ' INNER JOIN #event_trigger flt ON flt.event_trigger_id = src.event_trigger_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'modules_event_id'
	, @primary_key_column2 = 'alert_id'
	, @primary_key_column3 = NULL
	, @master_table_name = NULL--'module_events' 
	, @join_column_name_master = NULL--'module_events_id' 
	, @join_column_name_child = NULL--'modules_event_id' 
	, @primary_key_column1_master = NULL--'module_events_id'
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 1
	, @temp_unique_id = @temp_tbl_pid


INSERT INTO #query_result (query_result)
SELECT' 
DELETE FROM #event_trigger_' + @temp_tbl_pid + ' WHERE modules_event_id NOT IN 
	(SELECT meb.module_events_id FROM #module_events_bkup meb INNER JOIN #event_trigger_' + @temp_tbl_pid + ' et 
ON et.modules_event_id = meb.module_events_id)

UPDATE et SET et.[alert_id] = asl.new_recid
FROM #event_trigger_' + @temp_tbl_pid + ' et INNER JOIN #alert_sql_bkup asl ON asl.old_recid = et.alert_id WHERE et.alert_id <> -1

UPDATE et SET et.modules_event_id = me.new_recid
FROM #event_trigger_' + @temp_tbl_pid + ' et INNER JOIN #module_events_' + @temp_tbl_pid + ' me ON me.module_events_id = et.modules_event_id

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
			OUTPUT ''i'',''event_trigger'',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,inserted.report_paramset_id  INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[modules_event_id],src.[alert_id],src.[initial_event], src.[manual_step], src.[is_disable], src.[report_paramset_id], src.[report_filters]
		FROM #event_trigger_' + @temp_tbl_pid + ' src LEFT JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id
		WHERE dst.[event_trigger_id] IS NULL;
UPDATE #event_trigger_' + @temp_tbl_pid + ' SET new_recid =dst.new_id 
		FROM #event_trigger_' + @temp_tbl_pid + ' src INNER JOIN #old_new_id dst  ON src.modules_event_id=dst.unique_key1 AND src.alert_id=dst.unique_key2 AND dst.table_name=''event_trigger''
			AND ISNULL(src.report_paramset_id,-999) = ISNULL(dst.unique_key3,-999)

INSERT INTO #event_trigger_bkup	(event_trigger_id, modules_event_id, alert_id, initial_event, manual_step, is_disable, report_paramset_id, report_filters, new_recid, old_recid)
SELECT et.event_trigger_id, et.modules_event_id, et.alert_id, et.initial_event, et.manual_step, et.is_disable, et.report_paramset_id, et.report_filters, et.new_recid, et.old_recid FROM #event_trigger_' + @temp_tbl_pid + ' et
LEFT JOIN #event_trigger_bkup etb ON etb.old_recid = et.old_recid 
WHERE etb.old_recid IS NULL'

EXEC dbo.spa_export_table_scripter @tbl_name = 'workflow_event_message' 
	, @filter = ' INNER JOIN #workflow_event_message flt ON flt.event_message_id = src.event_message_id ' --- the alias name for source_table is always src
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

INSERT INTO #query_result (query_result)
SELECT '	
UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_' + @temp_tbl_pid + ' wem INNER JOIN #event_trigger_' + @temp_tbl_pid + ' et ON et.old_recid = wem.event_trigger_id
UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_' + @temp_tbl_pid + ' wem INNER JOIN #event_trigger_bkup et ON et.old_recid = wem.event_trigger_id
UPDATE wem SET wem.next_module_events_id = meb.new_recid FROM #workflow_event_message_' + @temp_tbl_pid + ' wem  INNER JOIN #module_events_bkup meb ON meb.old_recid = wem.next_module_events_id
'

EXEC dbo.spa_export_table_scripter @tbl_name = 'workflow_event_message' 
	, @filter = ' INNER JOIN #workflow_event_message flt ON flt.event_message_id = src.event_message_id ' --- the alias name for source_table is always src
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
	, @export_lebel = 2	
	, @temp_unique_id = @temp_tbl_pid

INSERT INTO #query_result (query_result)
SELECT '	
INSERT INTO #workflow_event_message_bkup (event_message_id, event_trigger_id, event_message_name, message_template_id, message, mult_approval_required, comment_required, approval_action_required, self_notify, notify_trader, counterparty_contact_type, next_module_events_id, minimum_approval_required, optional_event_msg, automatic_proceed, notification_type, new_recid, old_recid)
SELECT wem.event_message_id, wem.event_trigger_id, wem.event_message_name, wem.message_template_id, wem.message, wem.mult_approval_required, wem.comment_required, wem.approval_action_required, wem.self_notify, wem.notify_trader, wem.counterparty_contact_type, wem.next_module_events_id, wem.minimum_approval_required, wem.optional_event_msg, wem.automatic_proceed, wem.notification_type, wem.new_recid, wem.old_recid FROM #workflow_event_message_' + @temp_tbl_pid + ' wem
LEFT JOIN #workflow_event_message_bkup wemb ON wemb.old_recid = wem.old_recid 
WHERE wemb.old_recid IS NULL'

EXEC dbo.spa_export_table_scripter @tbl_name = 'workflow_event_action' 
	, @filter = ' INNER JOIN #workflow_event_action flt ON flt.event_action_id = src.event_action_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'event_action_id'
	, @primary_key_column2 = NULL--'type_id'
	, @primary_key_column3 = NULL
	, @master_table_name = NULL 
	, @join_column_name_master = NULL 
	, @join_column_name_child = NULL 
	, @primary_key_column1_master = NULL
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 1

INSERT INTO #query_result (query_result)
SELECT '
UPDATE wea SET wea.alert_id = et.new_recid FROM #workflow_event_action wea INNER JOIN #event_trigger_bkup et ON et.old_recid = wea.alert_id
UPDATE wea SET wea.event_message_id = wem.new_recid FROM #workflow_event_action wea INNER JOIN #workflow_event_message_bkup wem ON wem.old_recid = wea.event_message_id
UPDATE wea SET wea.status_id = sdv.new_recid FROM #workflow_event_action wea INNER JOIN #static_data_value_' + @temp_tbl_pid + ' sdv ON sdv.old_recid = wea.status_id	

INSERT INTO workflow_event_action
	([event_message_id],[status_id],[alert_id],[threshold_days]
	)
		OUTPUT ''i'',''workflow_event_action'',inserted.event_action_id,inserted.event_action_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
	SELECT 
	src_c.[event_message_id],src_c.[status_id],src_c.[alert_id],src_c.[threshold_days]
	FROM #workflow_event_action src_c
		
	UPDATE b SET b.new_recid = a.event_action_id
	FROM workflow_event_action a 
	INNER JOIN #workflow_event_action b 
		ON a.event_message_id = b.event_message_id
		AND a.alert_id = b.alert_id
		AND a.status_id = b.status_id
'

EXEC dbo.spa_export_table_scripter @tbl_name = 'workflow_schedule_task' 
	, @filter = ' INNER JOIN #tmp_wg_task flt ON flt.task_id = src.id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'id'
	, @primary_key_column2 = NULL--'type_id'
	, @primary_key_column3 = NULL
	, @master_table_name = NULL 
	, @join_column_name_master = NULL 
	, @join_column_name_child = NULL 
	, @primary_key_column1_master = NULL
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 1

INSERT INTO #query_result (query_result)
SELECT '
UPDATE wst SET wst.workflow_id = me.new_recid FROM #workflow_schedule_task wst INNER JOIN #module_events_bkup me ON me.old_recid = wst.workflow_id AND wst.workflow_id_type = 1 
UPDATE wst SET wst.workflow_id = et.new_recid FROM #workflow_schedule_task wst INNER JOIN #event_trigger_bkup et ON et.old_recid = wst.workflow_id AND wst.workflow_id_type = 2 
UPDATE wst SET wst.workflow_id = wem.new_recid FROM #workflow_schedule_task wst INNER JOIN #workflow_event_message_bkup wem ON wem.old_recid = wst.workflow_id AND wst.workflow_id_type = 3 
UPDATE wst SET wst.workflow_id = wem.new_recid
FROM #workflow_event_action wea 
INNER JOIN #workflow_event_message_bkup wem ON wea.event_message_id = wem.new_recid
INNER JOIN #workflow_schedule_task wst ON wst.workflow_id = wem.old_recid AND wst.workflow_id_type = 4 

DECLARE @id INT

DECLARE db_cursor CURSOR FOR  
	SELECT id FROM #workflow_schedule_task ORDER BY id ASC
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @id
WHILE @@FETCH_STATUS = 0   
BEGIN   
	INSERT INTO workflow_schedule_task
			([text],[start_date],[duration],[progress],[sort_order],[parent],[workflow_id],[workflow_id_type],[system_defined]
			)
				OUTPUT ''i'',''workflow_schedule_task'',inserted.id,inserted.id,NULL,NULL,@id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3, old_id)
	
			SELECT 
			src.[text],src.[start_date],src.[duration],src.[progress],src.[sort_order],src.[parent],src.[workflow_id],src.[workflow_id_type],src.[system_defined]
			FROM #workflow_schedule_task src LEFT JOIN workflow_schedule_task dst  ON src.id=dst.id
			--WHERE dst.[id] IS NULL AND src.id = @id;
			WHERE src.id = @id;

	UPDATE #workflow_schedule_task SET new_recid =dst.new_id 
		FROM #workflow_schedule_task src INNER JOIN #old_new_id dst ON src.id=dst.old_id AND dst.table_name=''workflow_schedule_task''-- AND src.id = 2730
	UPDATE #workflow_schedule_task SET parent = dst.new_id 
		FROM #workflow_schedule_task src INNER JOIN #old_new_id dst ON src.parent=dst.old_id AND dst.table_name=''workflow_schedule_task'' 

	FETCH NEXT FROM db_cursor INTO @id 
END   

CLOSE db_cursor   
DEALLOCATE db_cursor'		

EXEC dbo.spa_export_table_scripter @tbl_name = 'workflow_where_clause' 
	, @filter = ' INNER JOIN #tmp_wg_task twt ON twt.task_id = src.workflow_schedule_task_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'workflow_where_clause_id'
	, @primary_key_column2 = NULL--'type_id'
	, @primary_key_column3 = NULL
	, @master_table_name = NULL 
	, @join_column_name_master = NULL 
	, @join_column_name_child = NULL 
	, @primary_key_column1_master = NULL
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 1

INSERT INTO #query_result (query_result)
SELECT '
UPDATE wwc SET wwc.table_id = atd.new_recid FROM #workflow_where_clause wwc INNER JOIN #alert_table_definition_' + @temp_tbl_pid + ' atd ON atd.old_recid = wwc.table_id
UPDATE wwc SET wwc.column_id = acd.new_recid FROM #workflow_where_clause wwc INNER JOIN #alert_columns_definition_' + @temp_tbl_pid + ' acd ON acd.alert_columns_definition_id = wwc.column_id
UPDATE wwc SET wwc.module_events_id = me.new_recid FROM #workflow_where_clause wwc INNER JOIN #module_events_' + @temp_tbl_pid + ' me ON me.old_recid = wwc.module_events_id
UPDATE wwc SET wwc.workflow_schedule_task_id = wst.new_recid FROM #workflow_where_clause wwc INNER JOIN #workflow_schedule_task wst ON wst.old_recid = wwc.workflow_schedule_task_id'
EXEC dbo.spa_export_table_scripter @tbl_name = 'workflow_where_clause' 
	, @filter = ' INNER JOIN #module_event flt ON flt.module_events_id = src.module_events_id ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'workflow_where_clause_id'
	, @primary_key_column2 = NULL--'type_id'
	, @primary_key_column3 = NULL
	, @master_table_name = NULL 
	, @join_column_name_master = NULL 
	, @join_column_name_child = NULL 
	, @primary_key_column1_master = NULL
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 2

EXEC dbo.spa_export_table_scripter @tbl_name = 'workflow_schedule_link' 
	, @filter = ' INNER JOIN #tmp_wg_task flt ON flt.task_id = src.source ' --- the alias name for source_table is always src
	, @is_result_output = 'n'
	, @primary_key_column1 = 'id'
	, @primary_key_column2 = NULL--'type_id'
	, @primary_key_column3 = NULL
	, @master_table_name = NULL 
	, @join_column_name_master = NULL 
	, @join_column_name_child = NULL 
	, @primary_key_column1_master = NULL
	, @primary_key_column2_master = NULL
	, @primary_key_column3_master = NULL
	, @export_lebel = 1

INSERT INTO #query_result (query_result)
SELECT' 
UPDATE wsl SET wsl.[target] = a.new_id FROM #workflow_schedule_link wsl INNER JOIN  #old_new_id a ON wsl.[target] = a.old_id AND table_name = ''workflow_schedule_task'' 
UPDATE wsl SET wsl.source = a.new_id FROM #workflow_schedule_link wsl INNER JOIN  #old_new_id a ON wsl.source = a.old_id AND table_name = ''workflow_schedule_task'' 

UPDATE dbo.workflow_schedule_link SET [source]=src.[source],[target]=src.[target],[type]=src.[type],[action_type]=src.[action_type]
			OUTPUT ''u'',''workflow_schedule_link'',inserted.id,inserted.id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_schedule_link src INNER JOIN workflow_schedule_link dst  ON src.id=dst.id;
insert into workflow_schedule_link
		([source],[target],[type],[action_type]
		)
			OUTPUT ''i'',''workflow_schedule_link'',inserted.id,inserted.id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[source],src.[target],src.[type],src.[action_type]
		FROM #workflow_schedule_link src LEFT JOIN workflow_schedule_link dst  ON src.id=dst.id
		WHERE dst.[id] IS NULL;
UPDATE #workflow_schedule_link SET new_recid =dst.new_id 
		FROM #workflow_schedule_link src INNER JOIN #old_new_id dst  ON src.id=dst.unique_key1 AND dst.table_name=''workflow_schedule_link''
	'
	
INSERT INTO #query_result (query_result)	
SELECT '
	if @@TRANCOUNT>0
		COMMIT
	SELECT ''Workflow Exported successfully'' SUCCESS
END TRY
BEGIN CATCH
	if @@TRANCOUNT>0
		ROLLBACK

	SELECT ERROR_MESSAGE() ERROR

END CATCH
'

SELECT @max_final_query_id = MAX(rowid) FROM #final_query_result
INSERT INTO #final_query_result (rowid, query_result)	
SELECT rowid + @max_final_query_id, query_result FROM #query_result
	
SELECT query_result FROM #final_query_result ORDER BY rowid ASC

IF OBJECT_ID('adiha_process.dbo.workflow_details') IS NOT NULL
	DROP TABLE adiha_process.dbo.workflow_details

