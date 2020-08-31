BEGIN TRY
BEGIN TRAN

IF OBJECT_ID('tempdb..#event_trigger_bkup') IS NULL 
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

IF OBJECT_ID('tempdb..#workflow_event_message_bkup') IS NULL
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

IF OBJECT_ID('tempdb..#module_events_bkup') IS NULL 
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

IF OBJECT_ID('tempdb..#alert_sql_bkup') IS NULL 
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
SELECT @task_id = id FROM workflow_schedule_task w1 WHERE text = 'Upcoming RECs Delivery Alert'
EXEC spa_workflow_schedule  @flag='d',@task_id=@task_id,@task_level=0

IF OBJECT_ID('tempdb..#old_new_id') IS NULL
CREATE TABLE #old_new_id(tran_type VARCHAR(1) COLLATE DATABASE_DEFAULT, table_name VARCHAR(250) COLLATE DATABASE_DEFAULT, new_id INT, old_id INT, unique_key1 VARCHAR(250) COLLATE DATABASE_DEFAULT, unique_key2 VARCHAR(250) COLLATE DATABASE_DEFAULT, unique_key3 VARCHAR(250) COLLATE DATABASE_DEFAULT)
ELSE
TRUNCATE TABLE #old_new_id
;
print('--==============================START alert_table_definition=============================')

	if object_id('tempdb..#alert_table_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049') is null 
	
	CREATE TABLE #alert_table_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049
	 (
	 [alert_table_definition_id] int ,[logical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[physical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[data_source_id] int ,[is_action_view] char(1) COLLATE DATABASE_DEFAULT ,[primary_column] varchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049;
INSERT INTO #alert_table_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049(
	 [alert_table_definition_id],[logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 where alert_table_definition_id is null;
	update #alert_table_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 set logical_table_name='FARRMS1_ '+cast(alert_table_definition_id as varchar(30))  where isnull(logical_table_name,'')='' ;
	
UPDATE dbo.alert_table_definition SET [physical_table_name]=src.[physical_table_name],[data_source_id]=src.[data_source_id],[is_action_view]=src.[is_action_view],[primary_column]=src.[primary_column]
		   OUTPUT 'u','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 src INNER JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name;
insert into alert_table_definition
		([logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column]
		)
		 OUTPUT 'i','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[logical_table_name],src.[physical_table_name],src.[data_source_id],src.[is_action_view],src.[primary_column]
		FROM #alert_table_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 src LEFT JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name
		WHERE dst.[alert_table_definition_id] IS NULL;
UPDATE #alert_table_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 SET new_recid =dst.new_id 
		FROM #alert_table_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 src INNER JOIN #old_new_id dst  ON src.logical_table_name=dst.unique_key1 AND dst.table_name='alert_table_definition'
		;
print('--==============================END alert_table_definition=============================')
print('--==============================START alert_columns_definition=============================')

	if object_id('tempdb..#alert_columns_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049') is null 
	
	CREATE TABLE #alert_columns_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049
	 (
	 [alert_columns_definition_id] int ,[alert_table_id] int ,[column_name] varchar(600) COLLATE DATABASE_DEFAULT ,[is_primary] char(1) COLLATE DATABASE_DEFAULT ,[static_data_type_id] int ,[column_alias] varchar(200) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_columns_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049;
INSERT INTO #alert_columns_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049(
	 [alert_columns_definition_id],[alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_columns_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 where alert_columns_definition_id is null;
	update #alert_columns_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 set column_name='FARRMS1_ '+cast(alert_columns_definition_id as varchar(30))  where isnull(column_name,'')='' ;
	
print('--==============================END alert_columns_definition=============================')

UPDATE acd SET acd.alert_table_id = atd.new_recid
FROM #alert_columns_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 acd INNER JOIN #alert_table_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 atd ON atd.old_recid = acd.alert_table_id

print('--==============================START alert_columns_definition=============================')
UPDATE dbo.alert_columns_definition SET [alert_table_id]=dst.[alert_table_definition_id],[is_primary]=src_c.[is_primary],[static_data_type_id]=src_c.[static_data_type_id],[column_alias]=src_c.[column_alias]
		   OUTPUT 'u','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_table_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 src_c ON src_c.alert_table_id=src.alert_table_definition_id
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name;
insert into alert_columns_definition
		([alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias]
		)
		 OUTPUT 'i','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[alert_table_id],src_c.[column_name],src_c.[is_primary],src_c.[static_data_type_id],src_c.[column_alias]
		FROM #alert_table_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name 
			INNER JOIN #alert_columns_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			LEFT JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name
		WHERE dst_c.[alert_table_id] IS NULL;
UPDATE #alert_columns_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 SET new_recid =dst_c.[alert_columns_definition_id] 
			FROM #alert_table_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id
			 AND src_c.column_name=dst_c.column_name;
print('--==============================END alert_columns_definition=============================')
print('--==============================START static_data_value=============================')

	if object_id('tempdb..#static_data_value_AA8CD682_2FF8_48A9_983E_862A83CC3049') is null 
	
	CREATE TABLE #static_data_value_AA8CD682_2FF8_48A9_983E_862A83CC3049
	 (
	 [value_id] int ,[type_id] int ,[code] varchar(500) COLLATE DATABASE_DEFAULT ,[description] varchar(500) COLLATE DATABASE_DEFAULT ,[entity_id] int ,[xref_value_id] varchar(50) COLLATE DATABASE_DEFAULT ,[xref_value] varchar(250) COLLATE DATABASE_DEFAULT ,[category_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #static_data_value_AA8CD682_2FF8_48A9_983E_862A83CC3049;
INSERT INTO #static_data_value_AA8CD682_2FF8_48A9_983E_862A83CC3049(
	 [value_id],[type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id],old_recid
	 )
	 VALUES
	 
(20610,20600,'Calendar','Calendar',NULL,NULL,NULL,NULL,20610),
(20535,20500,'Calendar - Time Based',' Calendar - Time Based',NULL,NULL,NULL,0,20535),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #static_data_value_AA8CD682_2FF8_48A9_983E_862A83CC3049 where value_id is null;
	update #static_data_value_AA8CD682_2FF8_48A9_983E_862A83CC3049 set code='FARRMS1_ '+cast(value_id as varchar(30))  where isnull(code,'')='' ;
	update #static_data_value_AA8CD682_2FF8_48A9_983E_862A83CC3049 set type_id='FARRMS2_ '+cast(value_id as varchar(30))  where isnull(type_id,'')='' ;
			
UPDATE dbo.static_data_value SET [description]=src.[description],[entity_id]=src.[entity_id],[xref_value_id]=src.[xref_value_id],[xref_value]=src.[xref_value],[category_id]=src.[category_id]
		   OUTPUT 'u','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #static_data_value_AA8CD682_2FF8_48A9_983E_862A83CC3049 src INNER JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id;
insert into static_data_value
		([type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id]
		)
		 OUTPUT 'i','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[type_id],src.[code],src.[description],src.[entity_id],src.[xref_value_id],src.[xref_value],src.[category_id]
		FROM #static_data_value_AA8CD682_2FF8_48A9_983E_862A83CC3049 src LEFT JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id
		WHERE dst.[value_id] IS NULL;
UPDATE #static_data_value_AA8CD682_2FF8_48A9_983E_862A83CC3049 SET new_recid =dst.new_id 
		FROM #static_data_value_AA8CD682_2FF8_48A9_983E_862A83CC3049 src INNER JOIN #old_new_id dst  ON src.code=dst.unique_key1 AND src.type_id=dst.unique_key2 AND dst.table_name='static_data_value'
		;
print('--==============================END static_data_value=============================')
print('--==============================START module_events=============================')

	if object_id('tempdb..#module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049') is null 
	
	CREATE TABLE #module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049
	 (
	 [module_events_id] int ,[modules_id] int ,[event_id] varchar(2000) COLLATE DATABASE_DEFAULT ,[workflow_name] varchar(100) COLLATE DATABASE_DEFAULT ,[workflow_owner] varchar(100) COLLATE DATABASE_DEFAULT ,[rule_table_id] int ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,[eod_as_of_date] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049;
INSERT INTO #module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049(
	 [module_events_id],[modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id],[is_active],[eod_as_of_date],old_recid
	 )
	 VALUES
	 
(1520,20610,'20535','Upcoming RECs Delivery  Workflow',NULL,NULL,'y',NULL,1520),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049 where module_events_id is null;
	update #module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049 set workflow_name='FARRMS1_ '+cast(module_events_id as varchar(30))  where isnull(workflow_name,'')='' ;
	
print('--==============================END module_events=============================')

UPDATE me SET me.rule_table_id = atd.new_recid FROM #module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049 me INNER JOIN #alert_table_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 atd ON atd.old_recid = me.rule_table_id
UPDATE me SET me.modules_id = sdv.new_recid FROM #module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049 me INNER JOIN #static_data_value_AA8CD682_2FF8_48A9_983E_862A83CC3049 sdv ON sdv.old_recid = me.modules_id 
UPDATE me SET me.event_id = sdv.new_recid FROM #module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049 me INNER JOIN #static_data_value_AA8CD682_2FF8_48A9_983E_862A83CC3049 sdv ON sdv.old_recid = me.event_id 

print('--==============================START module_events=============================')
UPDATE dbo.module_events SET [modules_id]=src.[modules_id],[event_id]=src.[event_id],[workflow_owner]=src.[workflow_owner],[rule_table_id]=src.[rule_table_id],[is_active]=src.[is_active],[eod_as_of_date]=src.[eod_as_of_date]
		   OUTPUT 'u','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049 src INNER JOIN module_events dst  ON src.workflow_name=dst.workflow_name;
insert into module_events
		([modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id],[is_active],[eod_as_of_date]
		)
		 OUTPUT 'i','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[modules_id],src.[event_id],src.[workflow_name],src.[workflow_owner],src.[rule_table_id],src.[is_active],src.[eod_as_of_date]
		FROM #module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049 src LEFT JOIN module_events dst  ON src.workflow_name=dst.workflow_name
		WHERE dst.[module_events_id] IS NULL;
UPDATE #module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049 SET new_recid =dst.new_id 
		FROM #module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049 src INNER JOIN #old_new_id dst  ON src.workflow_name=dst.unique_key1 AND dst.table_name='module_events'
		;
print('--==============================END module_events=============================')

INSERT INTO #module_events_bkup(module_events_id, modules_id, event_id, workflow_name, workflow_owner, rule_table_id, new_recid, old_recid)	
SELECT me.module_events_id, me.modules_id, me.event_id, me.workflow_name, me.workflow_owner, me.rule_table_id, me.new_recid, me.old_recid FROM #module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049 me
LEFT JOIN #module_events_bkup meb ON meb.old_recid = me.old_recid 
WHERE meb.old_recid IS NULL
print('--==============================START static_data_value=============================')

	if object_id('tempdb..#static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [value_id] int ,[type_id] int ,[code] varchar(500) COLLATE DATABASE_DEFAULT ,[description] varchar(500) COLLATE DATABASE_DEFAULT ,[entity_id] int ,[xref_value_id] varchar(50) COLLATE DATABASE_DEFAULT ,[xref_value] varchar(250) COLLATE DATABASE_DEFAULT ,[category_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [value_id],[type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id],old_recid
	 )
	 VALUES
	 
(757,750,'Alert','Alert with Beep Sound',NULL,NULL,NULL,NULL,757),
(20601,20600,'Deal','Deal',NULL,NULL,NULL,NULL,20601),
(4,1,'Control Group','Control Group',NULL,NULL,NULL,NULL,4),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where value_id is null;
	update #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set code='FARRMS1_ '+cast(value_id as varchar(30))  where isnull(code,'')='' ;
	update #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set type_id='FARRMS2_ '+cast(value_id as varchar(30))  where isnull(type_id,'')='' ;
			
UPDATE dbo.static_data_value SET [description]=src.[description],[entity_id]=src.[entity_id],[xref_value_id]=src.[xref_value_id],[xref_value]=src.[xref_value],[category_id]=src.[category_id]
		   OUTPUT 'u','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id;
insert into static_data_value
		([type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id]
		)
		 OUTPUT 'i','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[type_id],src.[code],src.[description],src.[entity_id],src.[xref_value_id],src.[xref_value],src.[category_id]
		FROM #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id
		WHERE dst.[value_id] IS NULL;
UPDATE #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid =dst.new_id 
		FROM #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN #old_new_id dst  ON src.code=dst.unique_key1 AND src.type_id=dst.unique_key2 AND dst.table_name='static_data_value'
		;
print('--==============================END static_data_value=============================')
print('--==============================START alert_sql=============================')

	if object_id('tempdb..#alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [alert_sql_id] int ,[workflow_only] varchar(1) COLLATE DATABASE_DEFAULT ,[message] varchar(500) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,[sql_statement] varchar(max) COLLATE DATABASE_DEFAULT ,[alert_sql_name] varchar(100) COLLATE DATABASE_DEFAULT ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,[alert_type] char(1) COLLATE DATABASE_DEFAULT ,[rule_category] int ,[system_rule] char(1) COLLATE DATABASE_DEFAULT ,[alert_category] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [alert_sql_id],[workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category],old_recid
	 )
	 VALUES
	 
(1879,'n',NULL,'757','SELECT sdh.source_deal_header_id [Deal ID], sdh.deal_id [Ref ID], sc.counterparty_name [Counterparty], dbo.FNADateFormat(sdd.delivery_date) [Delivery Date], dbo.FNADateFormat(sdd.term_start) [Vintage Start], dbo.FNADateFormat(sdd.term_end) [Vintage End], dbo.FNARemoveTrailingZero(sdd.deal_volume) [Best Available Volume],
  dbo.FNARemoveTrailingZero(sdd.volume_left) [Volume Left]
INTO adiha_process.dbo.deal_delivery_date_process_id_ddd
FROM source_deal_header sdh 
INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
INNER JOIN source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id
LEFT JOIN source_commodity scom ON scom.source_commodity_id = sdh.commodity_id
WHERE CAST(sdd.delivery_date AS DATE) BETWEEN CAST(GETDATE() AS DATE) AND CAST(DATEADD(DAY,5,GETDATE()) AS DATE)   
AND sdh.header_buy_sell_flag = ''s'' AND scom.commodity_id =  ''Environmental'' ORDER BY sdd.delivery_date DESC','Deal Delivery Date Alert','y','s',20601,'n',NULL,1879),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where alert_sql_id is null;
	update #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set alert_sql_name='FARRMS1_ '+cast(alert_sql_id as varchar(30))  where isnull(alert_sql_name,'')='' ;
	
print('--==============================END alert_sql=============================')

UPDATE dbo.alert_sql SET [workflow_only]=src.[workflow_only],[message]=src.[message],[notification_type]=src.[notification_type],[sql_statement]=src.[sql_statement],[is_active]=src.[is_active],[alert_type]=src.[alert_type],[rule_category]=src.[rule_category],[system_rule]=src.[system_rule],[alert_category]=src.[alert_category]
		   OUTPUT 'u','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name;

IF EXISTS(SELECT 1 FROM #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 WHERE alert_sql_id < 0)
BEGIN
	SET IDENTITY_INSERT alert_sql ON
	INSERT INTO alert_sql
	([alert_sql_id], [workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category]
	)
	OUTPUT 'i','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	SELECT 
	src.alert_sql_id, src.[workflow_only],src.[message],src.[notification_type],src.[sql_statement],src.[alert_sql_name],src.[is_active],src.[alert_type],src.[rule_category],src.[system_rule],src.[alert_category]
	FROM #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
	WHERE dst.[alert_sql_id] IS NULL;
	SET IDENTITY_INSERT alert_sql OFF
END
ELSE
BEGIN
	INSERT INTO alert_sql
	([workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category]
	)
	OUTPUT 'i','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	SELECT 
	src.[workflow_only],src.[message],src.[notification_type],src.[sql_statement],src.[alert_sql_name],src.[is_active],src.[alert_type],src.[rule_category],src.[system_rule],src.[alert_category]
	FROM #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
	WHERE dst.[alert_sql_id] IS NULL;
END

UPDATE #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid = dst.new_id , alert_sql_id =  dst.new_id
FROM #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN #old_new_id dst ON src.alert_sql_name = dst.unique_key1 AND dst.table_name = 'alert_sql'

UPDATE asl SET asl.notification_type = sdv.new_recid 
FROM alert_sql asl INNER JOIN #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6 sdv ON sdv.old_recid = asl.notification_type	

UPDATE asl SET asl.rule_category = sdv.new_recid
FROM alert_sql asl INNER JOIN #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6 sdv ON sdv.old_recid = asl.rule_category	


	INSERT INTO #alert_sql_bkup (alert_sql_id, workflow_only, message, notification_type, sql_statement, alert_sql_name, is_active, alert_type, rule_category, system_rule, alert_category, new_recid, old_recid)
	SELECT asl.alert_sql_id, asl.workflow_only, asl.message, asl.notification_type, asl.sql_statement, asl.alert_sql_name, asl.is_active, asl.alert_type, asl.rule_category, asl.system_rule, asl.alert_category, asl.new_recid, asl.old_recid FROM #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 asl
	LEFT JOIN #alert_sql_bkup aslb ON aslb.old_recid = asl.old_recid
	WHERE aslb.old_recid IS NULL
print('--==============================START alert_table_definition=============================')

	if object_id('tempdb..#alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [alert_table_definition_id] int ,[logical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[physical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[data_source_id] int ,[is_action_view] char(1) COLLATE DATABASE_DEFAULT ,[primary_column] varchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [alert_table_definition_id],[logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where alert_table_definition_id is null;
	update #alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set logical_table_name='FARRMS1_ '+cast(alert_table_definition_id as varchar(30))  where isnull(logical_table_name,'')='' ;
	
UPDATE dbo.alert_table_definition SET [physical_table_name]=src.[physical_table_name],[data_source_id]=src.[data_source_id],[is_action_view]=src.[is_action_view],[primary_column]=src.[primary_column]
		   OUTPUT 'u','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name;
insert into alert_table_definition
		([logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column]
		)
		 OUTPUT 'i','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[logical_table_name],src.[physical_table_name],src.[data_source_id],src.[is_action_view],src.[primary_column]
		FROM #alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name
		WHERE dst.[alert_table_definition_id] IS NULL;
UPDATE #alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid =dst.new_id 
		FROM #alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN #old_new_id dst  ON src.logical_table_name=dst.unique_key1 AND dst.table_name='alert_table_definition'
		;
print('--==============================END alert_table_definition=============================')

UPDATE #alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET alert_table_definition_id = new_recid

print('--==============================START alert_columns_definition=============================')

	if object_id('tempdb..#alert_columns_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #alert_columns_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [alert_columns_definition_id] int ,[alert_table_id] int ,[column_name] varchar(600) COLLATE DATABASE_DEFAULT ,[is_primary] char(1) COLLATE DATABASE_DEFAULT ,[static_data_type_id] int ,[column_alias] varchar(200) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_columns_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #alert_columns_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [alert_columns_definition_id],[alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_columns_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where alert_columns_definition_id is null;
	update #alert_columns_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set column_name='FARRMS1_ '+cast(alert_columns_definition_id as varchar(30))  where isnull(column_name,'')='' ;
	
print('--==============================END alert_columns_definition=============================')

UPDATE acd SET acd.alert_table_id = atd.new_recid
FROM #alert_columns_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 acd INNER JOIN #alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 atd ON atd.old_recid = acd.alert_table_id

print('--==============================START alert_columns_definition=============================')
UPDATE dbo.alert_columns_definition SET [alert_table_id]=dst.[alert_table_definition_id],[is_primary]=src_c.[is_primary],[static_data_type_id]=src_c.[static_data_type_id],[column_alias]=src_c.[column_alias]
		   OUTPUT 'u','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src_c ON src_c.alert_table_id=src.alert_table_definition_id
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name;
insert into alert_columns_definition
		([alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias]
		)
		 OUTPUT 'i','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[alert_table_id],src_c.[column_name],src_c.[is_primary],src_c.[static_data_type_id],src_c.[column_alias]
		FROM #alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name 
			INNER JOIN #alert_columns_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			LEFT JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name
		WHERE dst_c.[alert_table_id] IS NULL;
UPDATE #alert_columns_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid =dst_c.[alert_columns_definition_id] 
			FROM #alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id
			 AND src_c.column_name=dst_c.column_name;
print('--==============================END alert_columns_definition=============================')

DELETE FROM alert_table_relation WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6)
DELETE FROM alert_actions_events WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6)
DELETE FROM alert_actions WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6)
DELETE FROM alert_table_where_clause WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6)
DELETE from alert_conditions WHERE rules_id IN (SELECT alert_sql_id FROM #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6)
DELETE from alert_rule_table where alert_id IN (SELECT alert_sql_id FROM #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6)
print('--==============================START alert_rule_table=============================')

	if object_id('tempdb..#alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [alert_rule_table_id] int ,[alert_id] int ,[table_id] int ,[root_table_id] int ,[table_alias] varchar(50) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [alert_rule_table_id],[alert_id],[table_id],[root_table_id],[table_alias],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where alert_rule_table_id is null;
	update #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set alert_rule_table_id='FARRMS1_ '+cast(alert_rule_table_id as varchar(30))  where isnull(alert_rule_table_id,'')='' ;
	
print('--==============================END alert_rule_table=============================')

UPDATE art SET art.alert_id = asl.new_recid
FROM #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 art INNER JOIN #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 asl ON asl.old_recid = art.alert_id

UPDATE art SET art.table_id = asd.new_recid
FROM #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 art INNER JOIN #alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6  asd ON asd.old_recid = art.table_id

UPDATE dbo.alert_rule_table SET [table_alias]=src.[table_alias]
		   OUTPUT 'u','alert_rule_table',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
insert into alert_rule_table
		([alert_id],[table_id],[root_table_id],[table_alias]
		)
		 OUTPUT 'i','alert_rule_table',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[root_table_id],src.[table_alias]
		FROM #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
		WHERE dst.[alert_rule_table_id] IS NULL;
UPDATE #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid =dst.new_id 
		FROM #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND ISNULL(src.root_table_id, -1)=ISNULL(dst.unique_key3, -1) AND dst.table_name='alert_rule_table'
		;
print('--==============================END alert_rule_table=============================')
	-- need to verify root_table_id
UPDATE art SET art.root_table_id = art2.new_recid FROM #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 art INNER JOIN #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 art2 ON art2.old_recid = art.root_table_id  
UPDATE art SET art.root_table_id = arrt.root_table_id FROM alert_rule_table art INNER JOIN #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 arrt ON arrt.new_recid = art.alert_rule_table_id 

print('--==============================START alert_conditions=============================')

	if object_id('tempdb..#alert_conditions_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #alert_conditions_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [alert_conditions_id] int ,[rules_id] int ,[alert_conditions_name] varchar(100) COLLATE DATABASE_DEFAULT ,[alert_conditions_description] varchar(500) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_conditions_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #alert_conditions_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [alert_conditions_id],[rules_id],[alert_conditions_name],[alert_conditions_description],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,null);
	delete #alert_conditions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where alert_conditions_id is null;
	update #alert_conditions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set alert_conditions_name='FARRMS1_ '+cast(alert_conditions_id as varchar(30))  where isnull(alert_conditions_name,'')='' ;
	
print('--==============================END alert_conditions=============================')

UPDATE ac SET rules_id = asl.new_recid	
FROM #alert_conditions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 ac INNER JOIN #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 asl ON asl.old_recid = ac.rules_id
print('--==============================START alert_conditions=============================')
UPDATE dbo.alert_conditions SET [rules_id]=dst.[alert_sql_id],[alert_conditions_description]=src_c.[alert_conditions_description]
		   OUTPUT 'u','alert_conditions',inserted.alert_conditions_id,inserted.alert_conditions_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
			INNER JOIN #alert_conditions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src_c ON src_c.rules_id=src.alert_sql_id
			INNER JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id AND src_c.alert_conditions_name=dst_c.alert_conditions_name;
insert into alert_conditions
		([rules_id],[alert_conditions_name],[alert_conditions_description]
		)
		 OUTPUT 'i','alert_conditions',inserted.alert_conditions_id,inserted.alert_conditions_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[rules_id],src_c.[alert_conditions_name],src_c.[alert_conditions_description]
		FROM #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name 
			INNER JOIN #alert_conditions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src_c ON src_c.rules_id=src.alert_sql_id	
			LEFT JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id AND src_c.alert_conditions_name=dst_c.alert_conditions_name
		WHERE dst_c.[rules_id] IS NULL;
UPDATE #alert_conditions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid =dst_c.[alert_conditions_id] 
			FROM #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
			INNER JOIN #alert_conditions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src_c ON src_c.rules_id=src.alert_sql_id	
			INNER JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id
			 AND src_c.alert_conditions_name=dst_c.alert_conditions_name;
print('--==============================END alert_conditions=============================')

UPDATE #alert_conditions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET alert_conditions_id = new_recid
print('--==============================START alert_table_where_clause=============================')

	if object_id('tempdb..#alert_table_where_clause_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #alert_table_where_clause_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [alert_table_where_clause_id] int ,[alert_id] int ,[clause_type] int ,[column_id] int ,[operator_id] int ,[column_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[second_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[table_id] int ,[column_function] varchar(1000) COLLATE DATABASE_DEFAULT ,[condition_id] int ,[sequence_no] int ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_where_clause_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #alert_table_where_clause_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [alert_table_where_clause_id],[alert_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[condition_id],[sequence_no],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_where_clause_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where alert_table_where_clause_id is null;
	update #alert_table_where_clause_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set alert_table_where_clause_id='FARRMS1_ '+cast(alert_table_where_clause_id as varchar(30))  where isnull(alert_table_where_clause_id,'')='' ;
	
print('--==============================END alert_table_where_clause=============================')

UPDATE atwc SET atwc.alert_id = asl.new_recid FROM #alert_table_where_clause_079A4C4C_421A_4CD0_8C3C_467DADD479A6 atwc INNER JOIN #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 asl ON asl.old_recid = atwc.alert_id
UPDATE atwc SET atwc.column_id = acd.new_recid FROM #alert_table_where_clause_079A4C4C_421A_4CD0_8C3C_467DADD479A6 atwc INNER JOIN #alert_columns_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6  acd ON acd.old_recid = atwc.column_id
UPDATE atwc SET atwc.table_id = art.new_recid FROM #alert_table_where_clause_079A4C4C_421A_4CD0_8C3C_467DADD479A6 atwc INNER JOIN #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 art ON art.old_recid = atwc.table_id
UPDATE atwc SET atwc.condition_id = ac.new_recid FROM #alert_table_where_clause_079A4C4C_421A_4CD0_8C3C_467DADD479A6 atwc INNER JOIN #alert_conditions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 ac ON ac.old_recid = atwc.condition_id

print('--==============================START alert_table_where_clause=============================')
UPDATE dbo.alert_table_where_clause SET [alert_id]=src.[alert_id],[clause_type]=src.[clause_type],[column_id]=src.[column_id],[operator_id]=src.[operator_id],[column_value]=src.[column_value],[second_value]=src.[second_value],[table_id]=src.[table_id],[column_function]=src.[column_function],[condition_id]=src.[condition_id],[sequence_no]=src.[sequence_no],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','alert_table_where_clause',inserted.alert_table_where_clause_id,inserted.alert_table_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_where_clause_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN alert_table_where_clause dst  ON src.alert_table_where_clause_id=dst.alert_table_where_clause_id;
insert into alert_table_where_clause
		([alert_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[condition_id],[sequence_no],[data_source_column_id]
		)
		 OUTPUT 'i','alert_table_where_clause',inserted.alert_table_where_clause_id,inserted.alert_table_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[clause_type],src.[column_id],src.[operator_id],src.[column_value],src.[second_value],src.[table_id],src.[column_function],src.[condition_id],src.[sequence_no],src.[data_source_column_id]
		FROM #alert_table_where_clause_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN alert_table_where_clause dst  ON src.alert_table_where_clause_id=dst.alert_table_where_clause_id
		WHERE dst.[alert_table_where_clause_id] IS NULL;
UPDATE #alert_table_where_clause_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid =dst.new_id 
		FROM #alert_table_where_clause_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN #old_new_id dst  ON src.alert_table_where_clause_id=dst.unique_key1 AND dst.table_name='alert_table_where_clause'
		;
print('--==============================END alert_table_where_clause=============================')
print('--==============================START alert_actions=============================')

	if object_id('tempdb..#alert_actions_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #alert_actions_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [alert_actions_id] int ,[alert_id] int ,[table_id] int ,[column_id] int ,[column_value] varchar(500) COLLATE DATABASE_DEFAULT ,[condition_id] int ,[sql_statement] varchar(max) COLLATE DATABASE_DEFAULT ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_actions_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #alert_actions_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [alert_actions_id],[alert_id],[table_id],[column_id],[column_value],[condition_id],[sql_statement],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_actions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where alert_actions_id is null;
	update #alert_actions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set alert_id='FARRMS1_ '+cast(alert_actions_id as varchar(30))  where isnull(alert_id,'')='' ;
	
print('--==============================END alert_actions=============================')

UPDATE aa SET aa.column_id = acd.new_recid FROM #alert_actions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 aa INNER JOIN #alert_columns_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6  acd ON acd.old_recid = aa.column_id
UPDATE aa SET aa.table_id = art.new_recid FROM #alert_actions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 aa INNER JOIN #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 art ON art.old_recid = aa.table_id
UPDATE aa SET aa.condition_id = ac.new_recid FROM #alert_actions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 aa INNER JOIN #alert_conditions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 ac ON ac.old_recid = aa.condition_id
UPDATE aa SET aa.alert_id = asl.new_recid FROM #alert_actions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 aa INNER JOIN #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 asl ON asl.old_recid = aa.alert_id

print('--==============================START alert_actions=============================')
UPDATE dbo.alert_actions SET [table_id]=src.[table_id],[column_id]=src.[column_id],[column_value]=src.[column_value],[condition_id]=src.[condition_id],[sql_statement]=src.[sql_statement],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','alert_actions',inserted.alert_actions_id,inserted.alert_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_actions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN alert_actions dst  ON src.alert_id=dst.alert_id;
insert into alert_actions
		([alert_id],[table_id],[column_id],[column_value],[condition_id],[sql_statement],[data_source_column_id]
		)
		 OUTPUT 'i','alert_actions',inserted.alert_actions_id,inserted.alert_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[column_id],src.[column_value],src.[condition_id],src.[sql_statement],src.[data_source_column_id]
		FROM #alert_actions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN alert_actions dst  ON src.alert_id=dst.alert_id
		WHERE dst.[alert_actions_id] IS NULL;
UPDATE #alert_actions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid =dst.new_id 
		FROM #alert_actions_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND dst.table_name='alert_actions'
		;
print('--==============================END alert_actions=============================')
print('--==============================START alert_actions_events=============================')

	if object_id('tempdb..#alert_actions_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #alert_actions_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [alert_actions_events_id] int ,[alert_id] int ,[table_id] int ,[callback_alert_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_actions_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #alert_actions_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [alert_actions_events_id],[alert_id],[table_id],[callback_alert_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,null);
	delete #alert_actions_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where alert_actions_events_id is null;
	update #alert_actions_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set alert_id='FARRMS1_ '+cast(alert_actions_events_id as varchar(30))  where isnull(alert_id,'')='' ;
	update #alert_actions_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set table_id='FARRMS2_ '+cast(alert_actions_events_id as varchar(30))  where isnull(table_id,'')='' ;
			update #alert_actions_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set callback_alert_id='FARRMS3_ '+cast(alert_actions_events_id as varchar(30))  where isnull(callback_alert_id,'')='' ;
			
print('--==============================END alert_actions_events=============================')

UPDATE aae SET aae.alert_id = asl.new_recid FROM #alert_actions_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 aae INNER JOIN #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 asl ON asl.old_recid = aae.alert_id
UPDATE aae SET aae.table_id = art.new_recid FROM #alert_actions_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 aae INNER JOIN #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 art ON art.old_recid = aae.table_id

print('--==============================START alert_actions_events=============================')
UPDATE dbo.alert_actions_events SET [callback_alert_id]=src.[callback_alert_id]
		   OUTPUT 'u','alert_actions_events',inserted.alert_actions_events_id,inserted.alert_id,inserted.table_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_actions_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN alert_actions_events dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id;
insert into alert_actions_events
		([alert_id],[table_id],[callback_alert_id]
		)
		 OUTPUT 'i','alert_actions_events',inserted.alert_actions_events_id,inserted.alert_id,inserted.table_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[callback_alert_id]
		FROM #alert_actions_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN alert_actions_events dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id
		WHERE dst.[alert_actions_events_id] IS NULL;
UPDATE #alert_actions_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid =dst.new_id 
		FROM #alert_actions_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND dst.table_name='alert_actions_events'
		;
print('--==============================END alert_actions_events=============================')
print('--==============================START alert_table_relation=============================')

	if object_id('tempdb..#alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [alert_table_relation_id] int ,[alert_id] int ,[from_table_id] int ,[from_column_id] int ,[to_table_id] int ,[to_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [alert_table_relation_id],[alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where alert_table_relation_id is null;
	update #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set alert_id='FARRMS1_ '+cast(alert_table_relation_id as varchar(30))  where isnull(alert_id,'')='' ;
	update #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set from_table_id='FARRMS2_ '+cast(alert_table_relation_id as varchar(30))  where isnull(from_table_id,'')='' ;
			update #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set to_table_id='FARRMS3_ '+cast(alert_table_relation_id as varchar(30))  where isnull(to_table_id,'')='' ;
			
print('--==============================END alert_table_relation=============================')
	
update #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set from_column_id='FARRMS4_ '+cast(alert_table_relation_id as varchar(30))  where isnull(from_column_id,'')='' ;
update #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set to_column_id='FARRMS5_ '+cast(alert_table_relation_id as varchar(30))  where isnull(to_column_id,'')='' ;

UPDATE atr SET atr.alert_id	= asl.new_recid FROM #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6 atr INNER JOIN #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 asl ON asl.old_recid = atr.alert_id		
UPDATE atr SET atr.from_table_id = atd.new_recid FROM #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6 atr INNER JOIN #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 atd ON atd.old_recid = atr.from_table_id		
UPDATE atr SET atr.to_table_id = atd.new_recid FROM #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6 atr INNER JOIN #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 atd ON atd.old_recid = atr.to_table_id		
UPDATE atr SET atr.from_column_id = atd.new_recid FROM #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6 atr INNER JOIN #alert_columns_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 atd ON atd.old_recid = atr.from_column_id		
UPDATE atr SET atr.to_column_id = atd.new_recid FROM #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6 atr INNER JOIN #alert_columns_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 atd ON atd.old_recid = atr.to_column_id		

insert into alert_table_relation
		([alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id]
		)
		 OUTPUT 'i','alert_table_relation',inserted.alert_table_relation_id,inserted.alert_id,inserted.from_table_id,inserted.to_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[from_table_id],src.[from_column_id],src.[to_table_id],src.[to_column_id]
		FROM #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN alert_table_relation dst  
		ON src.alert_id=dst.alert_id AND src.from_table_id=dst.from_table_id AND src.to_table_id=dst.to_table_id
		AND src.from_column_id=dst.from_column_id AND src.to_column_id=dst.to_column_id
		WHERE dst.[alert_table_relation_id] IS NULL;
UPDATE #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid = atr.alert_table_relation_id 
		FROM #alert_table_relation_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN alert_table_relation atr ON src.alert_id=atr.alert_id 
		AND src.from_table_id=atr.from_table_id AND src.to_table_id=atr.to_table_id 
		AND src.from_column_id=atr.from_column_id AND src.to_column_id=atr.to_column_id 
		;
print('--==============================END alert_table_relation=============================')		

print('--==============================START module_events=============================')

	if object_id('tempdb..#module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [module_events_id] int ,[modules_id] int ,[event_id] varchar(2000) COLLATE DATABASE_DEFAULT ,[workflow_name] varchar(100) COLLATE DATABASE_DEFAULT ,[workflow_owner] varchar(100) COLLATE DATABASE_DEFAULT ,[rule_table_id] int ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,[eod_as_of_date] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [module_events_id],[modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id],[is_active],[eod_as_of_date],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where module_events_id is null;
	update #module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set workflow_name='FARRMS1_ '+cast(module_events_id as varchar(30))  where isnull(workflow_name,'')='' ;
	
print('--==============================END module_events=============================')
	
	UPDATE me SET me.rule_table_id = atd.new_recid FROM #module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 me INNER JOIN #alert_table_definition_079A4C4C_421A_4CD0_8C3C_467DADD479A6 atd ON atd.old_recid = me.rule_table_id

	UPDATE dbo.module_events SET [modules_id]=src.[modules_id],[event_id]=src.[event_id],[workflow_owner]=src.[workflow_owner],[rule_table_id]=src.[rule_table_id]
			   OUTPUT 'u','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
		FROM #module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN module_events dst  ON src.workflow_name=dst.workflow_name;
	insert into module_events
			([modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id]
			)
			 OUTPUT 'i','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_id],src.[event_id],src.[workflow_name],src.[workflow_owner],src.[rule_table_id]
			FROM #module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN module_events dst  ON src.workflow_name=dst.workflow_name
			WHERE dst.[module_events_id] IS NULL;

			UPDATE #module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid = b.new_id 		
			FROM #module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 a 
			INNER JOIN 
			( SELECT TOP(1) new_id, unique_key1 FROM  #module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src 
			INNER JOIN #old_new_id dst ON src.workflow_name=dst.unique_key1 AND dst.table_name='module_events' ORDER BY new_id DESC
			) b ON a.workflow_name= b.unique_key1 

	

	UPDATE me SET me.modules_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6 sdv ON sdv.old_recid = me.modules_id

	UPDATE me SET me.event_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6 sdv ON sdv.old_recid = me.event_id
	
print('--==============================START event_trigger=============================')

	if object_id('tempdb..#event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [event_trigger_id] int ,[modules_event_id] int ,[alert_id] int ,[initial_event] char(1) COLLATE DATABASE_DEFAULT ,[manual_step] char(1) COLLATE DATABASE_DEFAULT ,[is_disable] char(1) COLLATE DATABASE_DEFAULT ,[report_paramset_id] varchar(max) COLLATE DATABASE_DEFAULT ,[report_filters] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [event_trigger_id],[modules_event_id],[alert_id],[initial_event],[manual_step],[is_disable],[report_paramset_id],[report_filters],old_recid
	 )
	 VALUES
	 
(2075,1520,1879,'n','n','n','',0,2075),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where event_trigger_id is null;
	update #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set modules_event_id='FARRMS1_ '+cast(event_trigger_id as varchar(30))  where isnull(modules_event_id,'')='' ;
	update #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set alert_id='FARRMS2_ '+cast(event_trigger_id as varchar(30))  where isnull(alert_id,'')='' ;
			
print('--==============================END event_trigger=============================')

		
		IF EXISTS (SELECT 1 FROM #module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6)
		BEGIN
			DELETE FROM #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6 WHERE modules_event_id NOT IN (
			SELECT mebs.module_events_id FROM #module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 mebs INNER JOIN #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6 et 
			ON et.modules_event_id = mebs.module_events_id)
		END
		ELSE
		BEGIN
			DELETE FROM #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6 WHERE modules_event_id NOT IN 
			(SELECT meb.module_events_id FROM #module_events_bkup meb INNER JOIN #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6 et 
			ON et.modules_event_id = meb.module_events_id)
		END
		
	
	UPDATE et SET et.alert_id = asl.new_recid FROM #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6 et INNER JOIN #alert_sql_079A4C4C_421A_4CD0_8C3C_467DADD479A6 asl ON asl.old_recid = et.alert_id WHERE et.alert_id <> -1
	UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6 et INNER JOIN #module_events_079A4C4C_421A_4CD0_8C3C_467DADD479A6 me ON me.old_recid = et.modules_event_id
	
UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6 et INNER JOIN #module_events_bkup me ON me.old_recid = et.modules_event_id

	print('--==============================START event_trigger=============================')

	UPDATE event_trigger SET 
	 [initial_event] = src.[initial_event]
	, [manual_step] = src.[manual_step]
	, [is_disable] = src.[is_disable]
	, [report_paramset_id] = src.[report_paramset_id]
	, [report_filters] = src.[report_filters]
	 OUTPUT 'u','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,src.report_paramset_id  
	 INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src 
	INNER JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id

	insert into event_trigger
			([modules_event_id],[alert_id],[initial_event], [manual_step], [is_disable], [report_paramset_id], [report_filters]
			)
			 OUTPUT 'i','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,inserted.report_paramset_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_event_id],src.[alert_id],src.[initial_event], src.[manual_step], src.[is_disable], src.[report_paramset_id], src.[report_filters]
			FROM #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id
			WHERE dst.[event_trigger_id] IS NULL;
	UPDATE #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid =dst.new_id 
			FROM #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN #old_new_id dst  ON src.modules_event_id=dst.unique_key1 AND src.alert_id=dst.unique_key2 AND dst.table_name='event_trigger'
			AND ISNULL(src.report_paramset_id,-999) = ISNULL(dst.unique_key3,-999);
	print('--==============================END event_trigger=============================')
print('--==============================START workflow_event_message=============================')

	if object_id('tempdb..#workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [event_message_id] int ,[event_trigger_id] int ,[event_message_name] varchar(100) COLLATE DATABASE_DEFAULT ,[message_template_id] int ,[message] varchar(1000) COLLATE DATABASE_DEFAULT ,[mult_approval_required] char(1) COLLATE DATABASE_DEFAULT ,[comment_required] char(1) COLLATE DATABASE_DEFAULT ,[approval_action_required] char(1) COLLATE DATABASE_DEFAULT ,[self_notify] char(1) COLLATE DATABASE_DEFAULT ,[notify_trader] char(1) COLLATE DATABASE_DEFAULT ,[next_module_events_id] int ,[minimum_approval_required] int ,[optional_event_msg] char(1) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[automatic_proceed] char(1) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [event_message_id],[event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type],old_recid
	 )
	 VALUES
	 
(1815,2075,'Upcoming Delivery',NULL,'There are RECS needs to be delivered :  :  <#ALERT_REPORT>','n','n','n','y','n',NULL,NULL,'n',NULL,'n','757',1815),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where event_message_id is null;
	update #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set event_trigger_id='FARRMS1_ '+cast(event_message_id as varchar(30))  where isnull(event_trigger_id,'')='' ;
	update #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set event_message_name='FARRMS2_ '+cast(event_message_id as varchar(30))  where isnull(event_message_name,'')='' ;
			
print('--==============================END workflow_event_message=============================')

		IF EXISTS (SELECT 1 FROM #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6)
		BEGIN	
			DELETE FROM #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wem INNER JOIN #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6 et ON et.old_recid = wem.event_trigger_id)
		END
		

	UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wem INNER JOIN #event_trigger_079A4C4C_421A_4CD0_8C3C_467DADD479A6 et ON et.old_recid = wem.event_trigger_id

		UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wem INNER JOIN #event_trigger_bkup et ON et.old_recid = wem.event_trigger_id
		UPDATE wem SET wem.next_module_events_id = meb.new_recid FROM #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wem  INNER JOIN #module_events_bkup meb ON meb.old_recid = wem.next_module_events_id
print('--==============================START workflow_event_message=============================')
UPDATE dbo.workflow_event_message SET [message_template_id]=src.[message_template_id],[message]=src.[message],[mult_approval_required]=src.[mult_approval_required],[comment_required]=src.[comment_required],[approval_action_required]=src.[approval_action_required],[self_notify]=src.[self_notify],[notify_trader]=src.[notify_trader],[next_module_events_id]=src.[next_module_events_id],[minimum_approval_required]=src.[minimum_approval_required],[optional_event_msg]=src.[optional_event_msg],[counterparty_contact_type]=src.[counterparty_contact_type],[automatic_proceed]=src.[automatic_proceed],[notification_type]=src.[notification_type]
		   OUTPUT 'u','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name;
insert into workflow_event_message
		([event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type]
		)
		 OUTPUT 'i','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_trigger_id],src.[event_message_name],src.[message_template_id],src.[message],src.[mult_approval_required],src.[comment_required],src.[approval_action_required],src.[self_notify],src.[notify_trader],src.[next_module_events_id],src.[minimum_approval_required],src.[optional_event_msg],src.[counterparty_contact_type],src.[automatic_proceed],src.[notification_type]
		FROM #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name
		WHERE dst.[event_message_id] IS NULL;
UPDATE #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid =dst.new_id 
		FROM #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN #old_new_id dst  ON src.event_trigger_id=dst.unique_key1 AND src.event_message_name=dst.unique_key2 AND dst.table_name='workflow_event_message'
		;
print('--==============================END workflow_event_message=============================')
	
		INSERT INTO #workflow_event_message_bkup (event_message_id, event_trigger_id, event_message_name, message_template_id, message, mult_approval_required, comment_required, approval_action_required, self_notify, notify_trader, counterparty_contact_type, next_module_events_id, minimum_approval_required, optional_event_msg, automatic_proceed, notification_type, new_recid, old_recid)
		SELECT wem.event_message_id, wem.event_trigger_id, wem.event_message_name, wem.message_template_id, wem.message, wem.mult_approval_required, wem.comment_required, wem.approval_action_required, wem.self_notify, wem.notify_trader, wem.counterparty_contact_type, wem.next_module_events_id, wem.minimum_approval_required, wem.optional_event_msg, wem.automatic_proceed, wem.notification_type, wem.new_recid, wem.old_recid FROM #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wem
		LEFT JOIN #workflow_event_message_bkup wemb ON wemb.old_recid = wem.old_recid 
		WHERE wemb.old_recid IS NULL
print('--==============================START application_security_role=============================')

	if object_id('tempdb..#application_security_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #application_security_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [role_id] int ,[role_name] varchar(50) COLLATE DATABASE_DEFAULT ,[role_description] varchar(250) COLLATE DATABASE_DEFAULT ,[role_type_value_id] int ,[process_map_file_name] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #application_security_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #application_security_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [role_id],[role_name],[role_description],[role_type_value_id],[process_map_file_name],old_recid
	 )
	 VALUES
	 
(65,' Back Office Manager','BackOffice',4,NULL,65),
(1284,'Environmental Analyst','Environmental Analyst',4,NULL,1284),
(NULL,NULL,NULL,NULL,NULL,null);
	delete #application_security_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where role_id is null;
	update #application_security_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set role_name='FARRMS1_ '+cast(role_id as varchar(30))  where isnull(role_name,'')='' ;
	
UPDATE dbo.application_security_role SET [role_description]=src.[role_description],[role_type_value_id]=src.[role_type_value_id],[process_map_file_name]=src.[process_map_file_name]
		   OUTPUT 'u','application_security_role',inserted.role_id,inserted.role_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #application_security_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN application_security_role dst  ON src.role_name=dst.role_name;
insert into application_security_role
		([role_name],[role_description],[role_type_value_id],[process_map_file_name]
		)
		 OUTPUT 'i','application_security_role',inserted.role_id,inserted.role_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[role_name],src.[role_description],src.[role_type_value_id],src.[process_map_file_name]
		FROM #application_security_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN application_security_role dst  ON src.role_name=dst.role_name
		WHERE dst.[role_id] IS NULL;
UPDATE #application_security_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid =dst.new_id 
		FROM #application_security_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN #old_new_id dst  ON src.role_name=dst.unique_key1 AND dst.table_name='application_security_role'
		;
print('--==============================END application_security_role=============================')
print('--==============================START workflow_event_user_role=============================')

	if object_id('tempdb..#workflow_event_user_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #workflow_event_user_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [event_user_role_id] int ,[event_message_id] int ,[user_login_id] varchar(50) COLLATE DATABASE_DEFAULT ,[role_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_user_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #workflow_event_user_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [event_user_role_id],[event_message_id],[user_login_id],[role_id],old_recid
	 )
	 VALUES
	 
(10365,1815,NULL,1284,10365),
(10366,1815,NULL,65,10366),
(NULL,NULL,NULL,NULL,null);
	delete #workflow_event_user_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where event_user_role_id is null;
	update #workflow_event_user_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set event_user_role_id='FARRMS1_ '+cast(event_user_role_id as varchar(30))  where isnull(event_user_role_id,'')='' ;
	
print('--==============================END workflow_event_user_role=============================')
	
		DELETE FROM #workflow_event_user_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wem INNER JOIN #workflow_event_user_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 weur ON weur.event_message_id = wem.event_message_id	)
		
	
	UPDATE weur SET weur.role_id = asr.new_recid FROM #workflow_event_user_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 weur INNER JOIN #application_security_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 asr ON asr.old_recid = weur.role_id
	UPDATE weur SET weur.event_message_id = wem.new_recid FROM #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wem INNER JOIN #workflow_event_user_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 weur ON weur.event_message_id = wem.old_recid
	
print('--==============================START workflow_event_user_role=============================')
UPDATE dbo.workflow_event_user_role SET [event_message_id]=src.[event_message_id],[user_login_id]=src.[user_login_id],[role_id]=src.[role_id]
		   OUTPUT 'u','workflow_event_user_role',inserted.event_user_role_id,inserted.event_user_role_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_user_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN workflow_event_user_role dst  ON src.event_user_role_id=dst.event_user_role_id;
insert into workflow_event_user_role
		([event_message_id],[user_login_id],[role_id]
		)
		 OUTPUT 'i','workflow_event_user_role',inserted.event_user_role_id,inserted.event_user_role_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[user_login_id],src.[role_id]
		FROM #workflow_event_user_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN workflow_event_user_role dst  ON src.event_user_role_id=dst.event_user_role_id
		WHERE dst.[event_user_role_id] IS NULL;
UPDATE #workflow_event_user_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid =dst.new_id 
		FROM #workflow_event_user_role_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN #old_new_id dst  ON src.event_user_role_id=dst.unique_key1 AND dst.table_name='workflow_event_user_role'
		;
print('--==============================END workflow_event_user_role=============================')
print('--==============================START workflow_event_message_documents=============================')

	if object_id('tempdb..#workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [message_document_id] int ,[event_message_id] int ,[document_template_id] int ,[effective_date] datetime ,[document_category] int ,[document_template] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [message_document_id],[event_message_id],[document_template_id],[effective_date],[document_category],[document_template],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where message_document_id is null;
	update #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set message_document_id='FARRMS1_ '+cast(message_document_id as varchar(30))  where isnull(message_document_id,'')='' ;
	
print('--==============================END workflow_event_message_documents=============================')

		DELETE FROM #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6 WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wemd ON wem.event_message_id = wemd.event_message_id)

	UPDATE wemd SET wemd.event_message_id = wem.new_recid FROM #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wem INNER JOIN #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wemd ON wemd.event_message_id = wem.old_recid
	UPDATE wemd SET wemd.document_template_id = sdv.new_recid FROM #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wemd INNER JOIN #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6 sdv ON sdv.old_recid = wemd.document_template_id
	UPDATE wemd SET wemd.document_category = sdv.new_recid FROM #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wemd INNER JOIN #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6 sdv ON sdv.old_recid = wemd.document_category
	
print('--==============================START workflow_event_message_documents=============================')
UPDATE dbo.workflow_event_message_documents SET [event_message_id]=src.[event_message_id],[document_template_id]=src.[document_template_id],[effective_date]=src.[effective_date],[document_category]=src.[document_category],[document_template]=src.[document_template]
		   OUTPUT 'u','workflow_event_message_documents',inserted.message_document_id,inserted.message_document_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN workflow_event_message_documents dst  ON src.message_document_id=dst.message_document_id;
insert into workflow_event_message_documents
		([event_message_id],[document_template_id],[effective_date],[document_category],[document_template]
		)
		 OUTPUT 'i','workflow_event_message_documents',inserted.message_document_id,inserted.message_document_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[document_template_id],src.[effective_date],src.[document_category],src.[document_template]
		FROM #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN workflow_event_message_documents dst  ON src.message_document_id=dst.message_document_id
		WHERE dst.[message_document_id] IS NULL;
UPDATE #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid =dst.new_id 
		FROM #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN #old_new_id dst  ON src.message_document_id=dst.unique_key1 AND dst.table_name='workflow_event_message_documents'
		;
print('--==============================END workflow_event_message_documents=============================')

	UPDATE w2 SET w2.new_recid = w1.message_document_id
	FROM workflow_event_message_documents w1 
	INNER JOIN #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6 w2 ON w1.event_message_id = w2.event_message_id
		AND ISNULL(w1.document_template_id, '-1') = ISNULL(w2.document_template_id, '-1')
		AND ISNULL(w1.document_category, '-1') = ISNULL(w2.document_category, '-1')
print('--==============================START workflow_event_message_details=============================')

	if object_id('tempdb..#workflow_event_message_details_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #workflow_event_message_details_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [message_detail_id] int ,[event_message_document_id] int ,[message_template_id] int ,[message] varchar(500) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[delivery_method] int ,[internal_contact_type] int ,[email] varchar(300) COLLATE DATABASE_DEFAULT ,[email_cc] varchar(300) COLLATE DATABASE_DEFAULT ,[email_bcc] varchar(300) COLLATE DATABASE_DEFAULT ,[as_defined_in_contact] char(1) COLLATE DATABASE_DEFAULT ,[subject] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_details_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #workflow_event_message_details_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [message_detail_id],[event_message_document_id],[message_template_id],[message],[counterparty_contact_type],[delivery_method],[internal_contact_type],[email],[email_cc],[email_bcc],[as_defined_in_contact],[subject],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_details_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where message_detail_id is null;
	update #workflow_event_message_details_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set message_detail_id='FARRMS1_ '+cast(message_detail_id as varchar(30))  where isnull(message_detail_id,'')='' ;
	
print('--==============================END workflow_event_message_details=============================')

	DELETE FROM #workflow_event_message_details_079A4C4C_421A_4CD0_8C3C_467DADD479A6 WHERE message_detail_id NOT IN (
		SELECT wemd.message_detail_id from #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wemdd 
		INNER JOIN #workflow_event_message_details_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wemd ON wemd.event_message_document_id = wemdd.message_document_id)

	UPDATE wemd SET wemd.event_message_document_id = wem.new_recid FROM #workflow_event_message_documents_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wem INNER JOIN #workflow_event_message_details_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wemd ON wemd.event_message_document_id = wem.old_recid
	UPDATE wemd SET wemd.counterparty_contact_type = sdv.new_recid FROM #workflow_event_message_details_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wemd INNER JOIN #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6  sdv ON sdv.old_recid = wemd.counterparty_contact_type
	UPDATE wemd SET wemd.delivery_method = sdv.new_recid FROM #workflow_event_message_details_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wemd INNER JOIN #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6  sdv ON sdv.old_recid = wemd.delivery_method
	UPDATE wemd SET wemd.internal_contact_type = sdv.new_recid FROM #workflow_event_message_details_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wemd INNER JOIN #static_data_value_079A4C4C_421A_4CD0_8C3C_467DADD479A6  sdv ON sdv.old_recid = wemd.internal_contact_type
	
print('--==============================START workflow_event_message_details=============================')
UPDATE dbo.workflow_event_message_details SET [event_message_document_id]=src.[event_message_document_id],[message_template_id]=src.[message_template_id],[message]=src.[message],[counterparty_contact_type]=src.[counterparty_contact_type],[delivery_method]=src.[delivery_method],[internal_contact_type]=src.[internal_contact_type],[email]=src.[email],[email_cc]=src.[email_cc],[email_bcc]=src.[email_bcc],[as_defined_in_contact]=src.[as_defined_in_contact],[subject]=src.[subject]
		   OUTPUT 'u','workflow_event_message_details',inserted.message_detail_id,inserted.message_detail_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_details_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN workflow_event_message_details dst  ON src.message_detail_id=dst.message_detail_id;
insert into workflow_event_message_details
		([event_message_document_id],[message_template_id],[message],[counterparty_contact_type],[delivery_method],[internal_contact_type],[email],[email_cc],[email_bcc],[as_defined_in_contact],[subject]
		)
		 OUTPUT 'i','workflow_event_message_details',inserted.message_detail_id,inserted.message_detail_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_document_id],src.[message_template_id],src.[message],src.[counterparty_contact_type],src.[delivery_method],src.[internal_contact_type],src.[email],src.[email_cc],src.[email_bcc],src.[as_defined_in_contact],src.[subject]
		FROM #workflow_event_message_details_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN workflow_event_message_details dst  ON src.message_detail_id=dst.message_detail_id
		WHERE dst.[message_detail_id] IS NULL;
UPDATE #workflow_event_message_details_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid =dst.new_id 
		FROM #workflow_event_message_details_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN #old_new_id dst  ON src.message_detail_id=dst.unique_key1 AND dst.table_name='workflow_event_message_details'
		;
print('--==============================END workflow_event_message_details=============================')
print('--==============================START alert_reports=============================')

	if object_id('tempdb..#alert_reports_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #alert_reports_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [alert_reports_id] int ,[event_message_id] int ,[report_writer] varchar(1) COLLATE DATABASE_DEFAULT ,[paramset_hash] varchar(8000) COLLATE DATABASE_DEFAULT ,[report_param] varchar(1000) COLLATE DATABASE_DEFAULT ,[report_desc] varchar(500) COLLATE DATABASE_DEFAULT ,[table_prefix] varchar(50) COLLATE DATABASE_DEFAULT ,[table_postfix] varchar(50) COLLATE DATABASE_DEFAULT ,[report_where_clause] varchar(max) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_reports_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #alert_reports_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [alert_reports_id],[event_message_id],[report_writer],[paramset_hash],[report_param],[report_desc],[table_prefix],[table_postfix],[report_where_clause],old_recid
	 )
	 VALUES
	 
(279,1815,'n','',NULL,'Upcoming Delivery RECS','deal_delivery_date_','_ddd','',279),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_reports_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where alert_reports_id is null;
	update #alert_reports_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set event_message_id='FARRMS1_ '+cast(alert_reports_id as varchar(30))  where isnull(event_message_id,'')='' ;
	update #alert_reports_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set report_desc='FARRMS2_ '+cast(alert_reports_id as varchar(30))  where isnull(report_desc,'')='' ;
			update #alert_reports_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set table_prefix='FARRMS3_ '+cast(alert_reports_id as varchar(30))  where isnull(table_prefix,'')='' ;
			
print('--==============================END alert_reports=============================')

		DELETE FROM #alert_reports_079A4C4C_421A_4CD0_8C3C_467DADD479A6 WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_reports_079A4C4C_421A_4CD0_8C3C_467DADD479A6 ar ON wem.event_message_id = ar.event_message_id)

	UPDATE ar SET ar.event_message_id = wem.new_recid FROM #workflow_event_message_079A4C4C_421A_4CD0_8C3C_467DADD479A6 wem INNER JOIN #alert_reports_079A4C4C_421A_4CD0_8C3C_467DADD479A6 ar ON ar.event_message_id = wem.old_recid
	
print('--==============================START alert_reports=============================')
UPDATE dbo.alert_reports SET [report_writer]=src.[report_writer],[paramset_hash]=src.[paramset_hash],[report_param]=src.[report_param],[table_postfix]=src.[table_postfix],[report_where_clause]=src.[report_where_clause]
		   OUTPUT 'u','alert_reports',inserted.alert_reports_id,inserted.event_message_id,inserted.report_desc,inserted.table_prefix INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_reports_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN alert_reports dst  ON src.event_message_id=dst.event_message_id AND src.report_desc=dst.report_desc AND src.table_prefix=dst.table_prefix;
insert into alert_reports
		([event_message_id],[report_writer],[paramset_hash],[report_param],[report_desc],[table_prefix],[table_postfix],[report_where_clause]
		)
		 OUTPUT 'i','alert_reports',inserted.alert_reports_id,inserted.event_message_id,inserted.report_desc,inserted.table_prefix INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[report_writer],src.[paramset_hash],src.[report_param],src.[report_desc],src.[table_prefix],src.[table_postfix],src.[report_where_clause]
		FROM #alert_reports_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN alert_reports dst  ON src.event_message_id=dst.event_message_id AND src.report_desc=dst.report_desc AND src.table_prefix=dst.table_prefix
		WHERE dst.[alert_reports_id] IS NULL;
UPDATE #alert_reports_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid =dst.new_id 
		FROM #alert_reports_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN #old_new_id dst  ON src.event_message_id=dst.unique_key1 AND src.report_desc=dst.unique_key2 AND src.table_prefix=dst.unique_key3 AND dst.table_name='alert_reports'
		;
print('--==============================END alert_reports=============================')
print('--==============================START alert_report_params=============================')

	if object_id('tempdb..#alert_report_params_079A4C4C_421A_4CD0_8C3C_467DADD479A6') is null 
	
	CREATE TABLE #alert_report_params_079A4C4C_421A_4CD0_8C3C_467DADD479A6
	 (
	 [alert_report_params_id] int ,[event_message_id] int ,[alert_report_id] int ,[main_table_id] int ,[parameter_name] nvarchar(200) COLLATE DATABASE_DEFAULT ,[parameter_value] nvarchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_report_params_079A4C4C_421A_4CD0_8C3C_467DADD479A6;
INSERT INTO #alert_report_params_079A4C4C_421A_4CD0_8C3C_467DADD479A6(
	 [alert_report_params_id],[event_message_id],[alert_report_id],[main_table_id],[parameter_name],[parameter_value],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_report_params_079A4C4C_421A_4CD0_8C3C_467DADD479A6 where alert_report_params_id is null;
	update #alert_report_params_079A4C4C_421A_4CD0_8C3C_467DADD479A6 set alert_report_id='FARRMS1_ '+cast(alert_report_params_id as varchar(30))  where isnull(alert_report_id,'')='' ;
	
print('--==============================END alert_report_params=============================')

		DELETE FROM #alert_report_params_079A4C4C_421A_4CD0_8C3C_467DADD479A6 WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_report_params_079A4C4C_421A_4CD0_8C3C_467DADD479A6 ar ON wem.event_message_id = ar.event_message_id)

	UPDATE arp SET arp.alert_report_id = ar.alert_reports_id FROM #alert_report_params_079A4C4C_421A_4CD0_8C3C_467DADD479A6 arp INNER JOIN #alert_reports_079A4C4C_421A_4CD0_8C3C_467DADD479A6 ar ON ar.old_recid = arp.alert_report_id
	UPDATE arp SET arp.main_table_id = art.alert_rule_table_id FROM #alert_report_params_079A4C4C_421A_4CD0_8C3C_467DADD479A6 arp INNER JOIN #alert_rule_table_079A4C4C_421A_4CD0_8C3C_467DADD479A6 art ON art.old_recid = arp.main_table_id
	
print('--==============================START alert_report_params=============================')
UPDATE dbo.alert_report_params SET [event_message_id]=src.[event_message_id],[main_table_id]=src.[main_table_id],[parameter_name]=src.[parameter_name],[parameter_value]=src.[parameter_value]
		   OUTPUT 'u','alert_report_params',inserted.alert_report_params_id,inserted.alert_report_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_report_params_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN alert_report_params dst  ON src.alert_report_id=dst.alert_report_id;
insert into alert_report_params
		([event_message_id],[alert_report_id],[main_table_id],[parameter_name],[parameter_value]
		)
		 OUTPUT 'i','alert_report_params',inserted.alert_report_params_id,inserted.alert_report_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[alert_report_id],src.[main_table_id],src.[parameter_name],src.[parameter_value]
		FROM #alert_report_params_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src LEFT JOIN alert_report_params dst  ON src.alert_report_id=dst.alert_report_id
		WHERE dst.[alert_report_params_id] IS NULL;
UPDATE #alert_report_params_079A4C4C_421A_4CD0_8C3C_467DADD479A6 SET new_recid =dst.new_id 
		FROM #alert_report_params_079A4C4C_421A_4CD0_8C3C_467DADD479A6 src INNER JOIN #old_new_id dst  ON src.alert_report_id=dst.unique_key1 AND dst.table_name='alert_report_params'
		;
print('--==============================END alert_report_params=============================')

UPDATE a SET a.new_recid = me.module_events_id from #module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049 a 
INNER JOIN module_events me ON me.modules_id = a.modules_id AND me.event_id = a.event_id AND me.workflow_name = a.workflow_name
	
UPDATE a SET a.new_recid = me.module_events_id from #module_events_bkup a 
INNER JOIN module_events me ON me.modules_id = a.modules_id AND me.event_id = a.event_id AND me.workflow_name = a.workflow_name

print('--==============================START event_trigger=============================')

	if object_id('tempdb..#event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049') is null 
	
	CREATE TABLE #event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049
	 (
	 [event_trigger_id] int ,[modules_event_id] int ,[alert_id] int ,[initial_event] char(1) COLLATE DATABASE_DEFAULT ,[manual_step] char(1) COLLATE DATABASE_DEFAULT ,[is_disable] char(1) COLLATE DATABASE_DEFAULT ,[report_paramset_id] varchar(max) COLLATE DATABASE_DEFAULT ,[report_filters] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049;
INSERT INTO #event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049(
	 [event_trigger_id],[modules_event_id],[alert_id],[initial_event],[manual_step],[is_disable],[report_paramset_id],[report_filters],old_recid
	 )
	 VALUES
	 
(2075,1520,1879,'n','n','n','',0,2075),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049 where event_trigger_id is null;
	update #event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049 set modules_event_id='FARRMS1_ '+cast(event_trigger_id as varchar(30))  where isnull(modules_event_id,'')='' ;
	update #event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049 set alert_id='FARRMS2_ '+cast(event_trigger_id as varchar(30))  where isnull(alert_id,'')='' ;
			
print('--==============================END event_trigger=============================')
 
DELETE FROM #event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049 WHERE modules_event_id NOT IN 
	(SELECT meb.module_events_id FROM #module_events_bkup meb INNER JOIN #event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049 et 
ON et.modules_event_id = meb.module_events_id)

UPDATE et SET et.[alert_id] = asl.new_recid
FROM #event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049 et INNER JOIN #alert_sql_bkup asl ON asl.old_recid = et.alert_id WHERE et.alert_id <> -1

UPDATE et SET et.modules_event_id = me.new_recid
FROM #event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049 et INNER JOIN #module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049 me ON me.module_events_id = et.modules_event_id

UPDATE event_trigger SET 
 [initial_event] = src.[initial_event]
, [manual_step] = src.[manual_step]
, [is_disable] = src.[is_disable]
, [report_paramset_id] = src.[report_paramset_id]
, [report_filters] = src.[report_filters]
 OUTPUT 'u','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,src.report_paramset_id 
 INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
FROM #event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049 src 
INNER JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id

insert into event_trigger
		([modules_event_id],[alert_id],[initial_event], [manual_step], [is_disable], [report_paramset_id], [report_filters]
		)
			OUTPUT 'i','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,inserted.report_paramset_id  INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[modules_event_id],src.[alert_id],src.[initial_event], src.[manual_step], src.[is_disable], src.[report_paramset_id], src.[report_filters]
		FROM #event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049 src LEFT JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id
		WHERE dst.[event_trigger_id] IS NULL;
UPDATE #event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049 SET new_recid =dst.new_id 
		FROM #event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049 src INNER JOIN #old_new_id dst  ON src.modules_event_id=dst.unique_key1 AND src.alert_id=dst.unique_key2 AND dst.table_name='event_trigger'
			AND ISNULL(src.report_paramset_id,-999) = ISNULL(dst.unique_key3,-999)

INSERT INTO #event_trigger_bkup	(event_trigger_id, modules_event_id, alert_id, initial_event, manual_step, is_disable, report_paramset_id, report_filters, new_recid, old_recid)
SELECT et.event_trigger_id, et.modules_event_id, et.alert_id, et.initial_event, et.manual_step, et.is_disable, et.report_paramset_id, et.report_filters, et.new_recid, et.old_recid FROM #event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049 et
LEFT JOIN #event_trigger_bkup etb ON etb.old_recid = et.old_recid 
WHERE etb.old_recid IS NULL
print('--==============================START workflow_event_message=============================')

	if object_id('tempdb..#workflow_event_message_AA8CD682_2FF8_48A9_983E_862A83CC3049') is null 
	
	CREATE TABLE #workflow_event_message_AA8CD682_2FF8_48A9_983E_862A83CC3049
	 (
	 [event_message_id] int ,[event_trigger_id] int ,[event_message_name] varchar(100) COLLATE DATABASE_DEFAULT ,[message_template_id] int ,[message] varchar(1000) COLLATE DATABASE_DEFAULT ,[mult_approval_required] char(1) COLLATE DATABASE_DEFAULT ,[comment_required] char(1) COLLATE DATABASE_DEFAULT ,[approval_action_required] char(1) COLLATE DATABASE_DEFAULT ,[self_notify] char(1) COLLATE DATABASE_DEFAULT ,[notify_trader] char(1) COLLATE DATABASE_DEFAULT ,[next_module_events_id] int ,[minimum_approval_required] int ,[optional_event_msg] char(1) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[automatic_proceed] char(1) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_AA8CD682_2FF8_48A9_983E_862A83CC3049;
INSERT INTO #workflow_event_message_AA8CD682_2FF8_48A9_983E_862A83CC3049(
	 [event_message_id],[event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type],old_recid
	 )
	 VALUES
	 
(1815,2075,'Upcoming Delivery',NULL,'There are RECS needs to be delivered :  :  <#ALERT_REPORT>','n','n','n','y','n',NULL,NULL,'n',NULL,'n','757',1815),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_AA8CD682_2FF8_48A9_983E_862A83CC3049 where event_message_id is null;
	update #workflow_event_message_AA8CD682_2FF8_48A9_983E_862A83CC3049 set event_trigger_id='FARRMS1_ '+cast(event_message_id as varchar(30))  where isnull(event_trigger_id,'')='' ;
	update #workflow_event_message_AA8CD682_2FF8_48A9_983E_862A83CC3049 set event_message_name='FARRMS2_ '+cast(event_message_id as varchar(30))  where isnull(event_message_name,'')='' ;
			
print('--==============================END workflow_event_message=============================')
	
UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_AA8CD682_2FF8_48A9_983E_862A83CC3049 wem INNER JOIN #event_trigger_AA8CD682_2FF8_48A9_983E_862A83CC3049 et ON et.old_recid = wem.event_trigger_id
UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_AA8CD682_2FF8_48A9_983E_862A83CC3049 wem INNER JOIN #event_trigger_bkup et ON et.old_recid = wem.event_trigger_id
UPDATE wem SET wem.next_module_events_id = meb.new_recid FROM #workflow_event_message_AA8CD682_2FF8_48A9_983E_862A83CC3049 wem  INNER JOIN #module_events_bkup meb ON meb.old_recid = wem.next_module_events_id

print('--==============================START workflow_event_message=============================')
UPDATE dbo.workflow_event_message SET [message_template_id]=src.[message_template_id],[message]=src.[message],[mult_approval_required]=src.[mult_approval_required],[comment_required]=src.[comment_required],[approval_action_required]=src.[approval_action_required],[self_notify]=src.[self_notify],[notify_trader]=src.[notify_trader],[next_module_events_id]=src.[next_module_events_id],[minimum_approval_required]=src.[minimum_approval_required],[optional_event_msg]=src.[optional_event_msg],[counterparty_contact_type]=src.[counterparty_contact_type],[automatic_proceed]=src.[automatic_proceed],[notification_type]=src.[notification_type]
		   OUTPUT 'u','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_AA8CD682_2FF8_48A9_983E_862A83CC3049 src INNER JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name;
insert into workflow_event_message
		([event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type]
		)
		 OUTPUT 'i','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_trigger_id],src.[event_message_name],src.[message_template_id],src.[message],src.[mult_approval_required],src.[comment_required],src.[approval_action_required],src.[self_notify],src.[notify_trader],src.[next_module_events_id],src.[minimum_approval_required],src.[optional_event_msg],src.[counterparty_contact_type],src.[automatic_proceed],src.[notification_type]
		FROM #workflow_event_message_AA8CD682_2FF8_48A9_983E_862A83CC3049 src LEFT JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name
		WHERE dst.[event_message_id] IS NULL;
UPDATE #workflow_event_message_AA8CD682_2FF8_48A9_983E_862A83CC3049 SET new_recid =dst.new_id 
		FROM #workflow_event_message_AA8CD682_2FF8_48A9_983E_862A83CC3049 src INNER JOIN #old_new_id dst  ON src.event_trigger_id=dst.unique_key1 AND src.event_message_name=dst.unique_key2 AND dst.table_name='workflow_event_message'
		;
print('--==============================END workflow_event_message=============================')
	
INSERT INTO #workflow_event_message_bkup (event_message_id, event_trigger_id, event_message_name, message_template_id, message, mult_approval_required, comment_required, approval_action_required, self_notify, notify_trader, counterparty_contact_type, next_module_events_id, minimum_approval_required, optional_event_msg, automatic_proceed, notification_type, new_recid, old_recid)
SELECT wem.event_message_id, wem.event_trigger_id, wem.event_message_name, wem.message_template_id, wem.message, wem.mult_approval_required, wem.comment_required, wem.approval_action_required, wem.self_notify, wem.notify_trader, wem.counterparty_contact_type, wem.next_module_events_id, wem.minimum_approval_required, wem.optional_event_msg, wem.automatic_proceed, wem.notification_type, wem.new_recid, wem.old_recid FROM #workflow_event_message_AA8CD682_2FF8_48A9_983E_862A83CC3049 wem
LEFT JOIN #workflow_event_message_bkup wemb ON wemb.old_recid = wem.old_recid 
WHERE wemb.old_recid IS NULL
print('--==============================START workflow_event_action=============================')

	if object_id('tempdb..#workflow_event_action') is null 
	
	CREATE TABLE #workflow_event_action
	 (
	 [event_action_id] int ,[event_message_id] int ,[status_id] int ,[alert_id] int ,[threshold_days] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_action;
INSERT INTO #workflow_event_action(
	 [event_action_id],[event_message_id],[status_id],[alert_id],[threshold_days],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_action where event_action_id is null;
	update #workflow_event_action set event_action_id='FARRMS1_ '+cast(event_action_id as varchar(30))  where isnull(event_action_id,'')='' ;
	
print('--==============================END workflow_event_action=============================')

UPDATE wea SET wea.alert_id = et.new_recid FROM #workflow_event_action wea INNER JOIN #event_trigger_bkup et ON et.old_recid = wea.alert_id
UPDATE wea SET wea.event_message_id = wem.new_recid FROM #workflow_event_action wea INNER JOIN #workflow_event_message_bkup wem ON wem.old_recid = wea.event_message_id
UPDATE wea SET wea.status_id = sdv.new_recid FROM #workflow_event_action wea INNER JOIN #static_data_value_AA8CD682_2FF8_48A9_983E_862A83CC3049 sdv ON sdv.old_recid = wea.status_id	

INSERT INTO workflow_event_action
	([event_message_id],[status_id],[alert_id],[threshold_days]
	)
		OUTPUT 'i','workflow_event_action',inserted.event_action_id,inserted.event_action_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
	SELECT 
	src_c.[event_message_id],src_c.[status_id],src_c.[alert_id],src_c.[threshold_days]
	FROM #workflow_event_action src_c
		
	UPDATE b SET b.new_recid = a.event_action_id
	FROM workflow_event_action a 
	INNER JOIN #workflow_event_action b 
		ON a.event_message_id = b.event_message_id
		AND a.alert_id = b.alert_id
		AND a.status_id = b.status_id

print('--==============================START workflow_schedule_task=============================')

	if object_id('tempdb..#workflow_schedule_task') is null 
	
	CREATE TABLE #workflow_schedule_task
	 (
	 [id] int ,[text] varchar(500) COLLATE DATABASE_DEFAULT ,[start_date] datetime ,[duration] int ,[progress] float ,[sort_order] int ,[parent] int ,[workflow_id] int ,[workflow_id_type] int ,[system_defined] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_schedule_task;
INSERT INTO #workflow_schedule_task(
	 [id],[text],[start_date],[duration],[progress],[sort_order],[parent],[workflow_id],[workflow_id_type],[system_defined],old_recid
	 )
	 VALUES
	 
(7382,NULL,'Jan  5 2015 12:00AM',2,NULL,1,7381,1815,3,NULL,7382),
(7381,NULL,'Jan  2 2015 12:00AM',2,NULL,1,7380,2075,2,NULL,7381),
(7380,NULL,'Jan  2 2015 12:00AM',2,NULL,1,7379,1520,1,NULL,7380),
(7379,'Upcoming RECs Delivery Alert','Jan  2 2015 12:00AM',5,NULL,NULL,NULL,NULL,0,0,7379),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_schedule_task where id is null;
	update #workflow_schedule_task set id='FARRMS1_ '+cast(id as varchar(30))  where isnull(id,'')='' ;
	
print('--==============================END workflow_schedule_task=============================')

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
				OUTPUT 'i','workflow_schedule_task',inserted.id,inserted.id,NULL,NULL,@id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3, old_id)
	
			SELECT 
			src.[text],src.[start_date],src.[duration],src.[progress],src.[sort_order],src.[parent],src.[workflow_id],src.[workflow_id_type],src.[system_defined]
			FROM #workflow_schedule_task src LEFT JOIN workflow_schedule_task dst  ON src.id=dst.id
			--WHERE dst.[id] IS NULL AND src.id = @id;
			WHERE src.id = @id;

	UPDATE #workflow_schedule_task SET new_recid =dst.new_id 
		FROM #workflow_schedule_task src INNER JOIN #old_new_id dst ON src.id=dst.old_id AND dst.table_name='workflow_schedule_task'-- AND src.id = 2730
	UPDATE #workflow_schedule_task SET parent = dst.new_id 
		FROM #workflow_schedule_task src INNER JOIN #old_new_id dst ON src.parent=dst.old_id AND dst.table_name='workflow_schedule_task' 

	FETCH NEXT FROM db_cursor INTO @id 
END   

CLOSE db_cursor   
DEALLOCATE db_cursor
print('--==============================START workflow_where_clause=============================')

	if object_id('tempdb..#workflow_where_clause') is null 
	
	CREATE TABLE #workflow_where_clause
	 (
	 [workflow_where_clause_id] int ,[module_events_id] int ,[clause_type] int ,[column_id] int ,[operator_id] int ,[column_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[second_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[table_id] int ,[column_function] varchar(1000) COLLATE DATABASE_DEFAULT ,[sequence_no] int ,[workflow_schedule_task_id] int ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_where_clause;
INSERT INTO #workflow_where_clause(
	 [workflow_where_clause_id],[module_events_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[sequence_no],[workflow_schedule_task_id],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_where_clause where workflow_where_clause_id is null;
	update #workflow_where_clause set workflow_where_clause_id='FARRMS1_ '+cast(workflow_where_clause_id as varchar(30))  where isnull(workflow_where_clause_id,'')='' ;
	
print('--==============================END workflow_where_clause=============================')

UPDATE wwc SET wwc.table_id = atd.new_recid FROM #workflow_where_clause wwc INNER JOIN #alert_table_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 atd ON atd.old_recid = wwc.table_id
UPDATE wwc SET wwc.column_id = acd.new_recid FROM #workflow_where_clause wwc INNER JOIN #alert_columns_definition_AA8CD682_2FF8_48A9_983E_862A83CC3049 acd ON acd.alert_columns_definition_id = wwc.column_id
UPDATE wwc SET wwc.module_events_id = me.new_recid FROM #workflow_where_clause wwc INNER JOIN #module_events_AA8CD682_2FF8_48A9_983E_862A83CC3049 me ON me.old_recid = wwc.module_events_id
UPDATE wwc SET wwc.workflow_schedule_task_id = wst.new_recid FROM #workflow_where_clause wwc INNER JOIN #workflow_schedule_task wst ON wst.old_recid = wwc.workflow_schedule_task_id
print('--==============================START workflow_where_clause=============================')
UPDATE dbo.workflow_where_clause SET [module_events_id]=src.[module_events_id],[clause_type]=src.[clause_type],[column_id]=src.[column_id],[operator_id]=src.[operator_id],[column_value]=src.[column_value],[second_value]=src.[second_value],[table_id]=src.[table_id],[column_function]=src.[column_function],[sequence_no]=src.[sequence_no],[workflow_schedule_task_id]=src.[workflow_schedule_task_id],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','workflow_where_clause',inserted.workflow_where_clause_id,inserted.workflow_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_where_clause src INNER JOIN workflow_where_clause dst  ON src.workflow_where_clause_id=dst.workflow_where_clause_id;
insert into workflow_where_clause
		([module_events_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[sequence_no],[workflow_schedule_task_id],[data_source_column_id]
		)
		 OUTPUT 'i','workflow_where_clause',inserted.workflow_where_clause_id,inserted.workflow_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[module_events_id],src.[clause_type],src.[column_id],src.[operator_id],src.[column_value],src.[second_value],src.[table_id],src.[column_function],src.[sequence_no],src.[workflow_schedule_task_id],src.[data_source_column_id]
		FROM #workflow_where_clause src LEFT JOIN workflow_where_clause dst  ON src.workflow_where_clause_id=dst.workflow_where_clause_id
		WHERE dst.[workflow_where_clause_id] IS NULL;
UPDATE #workflow_where_clause SET new_recid =dst.new_id 
		FROM #workflow_where_clause src INNER JOIN #old_new_id dst  ON src.workflow_where_clause_id=dst.unique_key1 AND dst.table_name='workflow_where_clause'
		;
print('--==============================END workflow_where_clause=============================')
print('--==============================START workflow_schedule_link=============================')

	if object_id('tempdb..#workflow_schedule_link') is null 
	
	CREATE TABLE #workflow_schedule_link
	 (
	 [id] int ,[source] int ,[target] int ,[type] int ,[action_type] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_schedule_link;
INSERT INTO #workflow_schedule_link(
	 [id],[source],[target],[type],[action_type],old_recid
	 )
	 VALUES
	 
(4884,7381,7382,0,NULL,4884),
(NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_schedule_link where id is null;
	update #workflow_schedule_link set id='FARRMS1_ '+cast(id as varchar(30))  where isnull(id,'')='' ;
	
print('--==============================END workflow_schedule_link=============================')
 
UPDATE wsl SET wsl.[target] = a.new_id FROM #workflow_schedule_link wsl INNER JOIN  #old_new_id a ON wsl.[target] = a.old_id AND table_name = 'workflow_schedule_task' 
UPDATE wsl SET wsl.source = a.new_id FROM #workflow_schedule_link wsl INNER JOIN  #old_new_id a ON wsl.source = a.old_id AND table_name = 'workflow_schedule_task' 

UPDATE dbo.workflow_schedule_link SET [source]=src.[source],[target]=src.[target],[type]=src.[type],[action_type]=src.[action_type]
			OUTPUT 'u','workflow_schedule_link',inserted.id,inserted.id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_schedule_link src INNER JOIN workflow_schedule_link dst  ON src.id=dst.id;
insert into workflow_schedule_link
		([source],[target],[type],[action_type]
		)
			OUTPUT 'i','workflow_schedule_link',inserted.id,inserted.id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[source],src.[target],src.[type],src.[action_type]
		FROM #workflow_schedule_link src LEFT JOIN workflow_schedule_link dst  ON src.id=dst.id
		WHERE dst.[id] IS NULL;
UPDATE #workflow_schedule_link SET new_recid =dst.new_id 
		FROM #workflow_schedule_link src INNER JOIN #old_new_id dst  ON src.id=dst.unique_key1 AND dst.table_name='workflow_schedule_link'
	

	if @@TRANCOUNT>0
		COMMIT
	SELECT 'Workflow Exported successfully' SUCCESS
END TRY
BEGIN CATCH
	if @@TRANCOUNT>0
		ROLLBACK

	SELECT ERROR_MESSAGE() ERROR

END CATCH