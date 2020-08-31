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
SELECT @task_id = id FROM workflow_schedule_task w1 WHERE text = 'Alerts'
EXEC spa_workflow_schedule  @flag='d',@task_id=@task_id,@task_level=0

IF OBJECT_ID('tempdb..#old_new_id') IS NULL
CREATE TABLE #old_new_id(tran_type VARCHAR(1) COLLATE DATABASE_DEFAULT, table_name VARCHAR(250) COLLATE DATABASE_DEFAULT, new_id INT, old_id INT, unique_key1 VARCHAR(250) COLLATE DATABASE_DEFAULT, unique_key2 VARCHAR(250) COLLATE DATABASE_DEFAULT, unique_key3 VARCHAR(250) COLLATE DATABASE_DEFAULT)
ELSE
TRUNCATE TABLE #old_new_id
;
print('--==============================START alert_table_definition=============================')

	if object_id('tempdb..#alert_table_definition_7C8FADC9_8875_4FAC_852B_09331A760A25') is null 
	
	CREATE TABLE #alert_table_definition_7C8FADC9_8875_4FAC_852B_09331A760A25
	 (
	 [alert_table_definition_id] int ,[logical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[physical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[data_source_id] int ,[is_action_view] char(1) COLLATE DATABASE_DEFAULT ,[primary_column] varchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_definition_7C8FADC9_8875_4FAC_852B_09331A760A25;
INSERT INTO #alert_table_definition_7C8FADC9_8875_4FAC_852B_09331A760A25(
	 [alert_table_definition_id],[logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column],old_recid
	 )
	 VALUES
	 
(3,'Deal Header','vwSourceDealHeader',NULL,NULL,NULL,3),
(13,'Credit Exposure Detail','vwCreditExposureDetail',NULL,NULL,NULL,13),
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 where alert_table_definition_id is null;
	update #alert_table_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 set logical_table_name='FARRMS1_ '+cast(alert_table_definition_id as varchar(30))  where isnull(logical_table_name,'')='' ;
	
UPDATE dbo.alert_table_definition SET [physical_table_name]=src.[physical_table_name],[data_source_id]=src.[data_source_id],[is_action_view]=src.[is_action_view],[primary_column]=src.[primary_column]
		   OUTPUT 'u','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 src INNER JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name;
insert into alert_table_definition
		([logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column]
		)
		 OUTPUT 'i','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[logical_table_name],src.[physical_table_name],src.[data_source_id],src.[is_action_view],src.[primary_column]
		FROM #alert_table_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 src LEFT JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name
		WHERE dst.[alert_table_definition_id] IS NULL;
UPDATE #alert_table_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 SET new_recid =dst.new_id 
		FROM #alert_table_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 src INNER JOIN #old_new_id dst  ON src.logical_table_name=dst.unique_key1 AND dst.table_name='alert_table_definition'
		;
print('--==============================END alert_table_definition=============================')
print('--==============================START alert_columns_definition=============================')

	if object_id('tempdb..#alert_columns_definition_7C8FADC9_8875_4FAC_852B_09331A760A25') is null 
	
	CREATE TABLE #alert_columns_definition_7C8FADC9_8875_4FAC_852B_09331A760A25
	 (
	 [alert_columns_definition_id] int ,[alert_table_id] int ,[column_name] varchar(600) COLLATE DATABASE_DEFAULT ,[is_primary] char(1) COLLATE DATABASE_DEFAULT ,[static_data_type_id] int ,[column_alias] varchar(200) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_columns_definition_7C8FADC9_8875_4FAC_852B_09331A760A25;
INSERT INTO #alert_columns_definition_7C8FADC9_8875_4FAC_852B_09331A760A25(
	 [alert_columns_definition_id],[alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias],old_recid
	 )
	 VALUES
	 
(198,3,'aggregate_environment','n',NULL,NULL,198),
(199,3,'aggregate_envrionment_comment','n',NULL,NULL,199),
(200,3,'assigned_by','n',NULL,NULL,200),
(201,3,'assigned_date','n',NULL,NULL,201),
(202,3,'assignment_type_value_id','n',NULL,NULL,202),
(203,3,'back_office_sign_off_by','n',NULL,NULL,203),
(204,3,'back_office_sign_off_date','n',NULL,NULL,204),
(205,3,'block_define_id','n',NULL,NULL,205),
(206,3,'block_type','n',NULL,NULL,206),
(207,3,'book_transfer_id','n',NULL,NULL,207),
(208,3,'broker_currency_id','n',NULL,NULL,208),
(209,3,'broker_fixed_cost','n',NULL,NULL,209),
(210,3,'broker_id','n',NULL,NULL,210),
(211,3,'broker_unit_fees','n',NULL,NULL,211),
(212,3,'close_reference_id','n',NULL,NULL,212),
(213,3,'commodity_id','n',NULL,NULL,213),
(214,3,'compliance_year','n',NULL,NULL,214),
(215,3,'confirm_rule','n',NULL,NULL,215),
(216,3,'confirm_status_type','n',17200,NULL,216),
(217,3,'contract_id','n',NULL,NULL,217),
(218,3,'counterparty_id','n',NULL,NULL,218),
(219,3,'create_ts','n',NULL,NULL,219),
(220,3,'create_user','n',NULL,NULL,220),
(221,3,'deal_category_value_id','n',NULL,NULL,221),
(222,3,'deal_date','n',NULL,NULL,222),
(223,3,'deal_id','n',NULL,NULL,223),
(224,3,'deal_locked','n',NULL,NULL,224),
(225,3,'deal_reference_type_id','n',NULL,NULL,225),
(226,3,'deal_rules','n',NULL,NULL,226),
(227,3,'deal_status','n',5600,NULL,227),
(228,3,'deal_sub_type_type_id','n',NULL,NULL,228),
(229,3,'description1','n',NULL,NULL,229),
(230,3,'description2','n',NULL,NULL,230),
(231,3,'description3','n',NULL,NULL,231),
(232,3,'description4','n',NULL,NULL,232),
(233,3,'entire_term_end','n',NULL,NULL,233),
(234,3,'entire_term_start','n',NULL,NULL,234),
(235,3,'ext_deal_id','n',NULL,NULL,235),
(236,3,'generation_source','n',NULL,NULL,236),
(237,3,'generator_id','n',NULL,NULL,237),
(238,3,'granularity_id','n',NULL,NULL,238),
(239,3,'header_buy_sell_flag','n',NULL,NULL,239),
(240,3,'internal_deal_subtype_value_id','n',NULL,NULL,240),
(241,3,'internal_deal_type_value_id','n',NULL,NULL,241),
(242,3,'internal_desk_id','n',NULL,NULL,242),
(243,3,'internal_portfolio_id','n',NULL,NULL,243),
(244,3,'legal_entity','n',NULL,NULL,244),
(245,3,'option_excercise_type','n',NULL,NULL,245),
(246,3,'option_flag','n',NULL,NULL,246),
(247,3,'option_settlement_date','n',NULL,NULL,247),
(248,3,'option_type','n',NULL,NULL,248),
(249,3,'physical_financial_flag','n',NULL,NULL,249),
(250,3,'Pricing','n',NULL,NULL,250),
(251,3,'product_id','n',NULL,NULL,251),
(252,3,'rec_formula_id','n',NULL,NULL,252),
(253,3,'rec_price','n',NULL,NULL,253),
(254,3,'reference','n',NULL,NULL,254),
(255,3,'risk_sign_off_by','n',NULL,NULL,255),
(256,3,'risk_sign_off_date','n',NULL,NULL,256),
(257,3,'rolling_avg','n',NULL,NULL,257),
(258,3,'source_deal_header_id','y',NULL,NULL,258),
(260,3,'source_deal_type_id','n',NULL,NULL,260),
(261,3,'source_system_book_id1','n',NULL,NULL,261),
(262,3,'source_system_book_id2','n',NULL,NULL,262),
(263,3,'source_system_book_id3','n',NULL,NULL,263),
(264,3,'source_system_book_id4','n',NULL,NULL,264),
(265,3,'source_system_id','n',NULL,NULL,265),
(266,3,'state_value_id','n',NULL,NULL,266),
(267,3,'status_date','n',NULL,NULL,267),
(268,3,'status_value_id','n',NULL,NULL,268),
(269,3,'structured_deal_id','n',NULL,NULL,269),
(270,3,'sub_book','n',NULL,NULL,270),
(271,3,'template_id','n',NULL,NULL,271),
(272,3,'term_frequency','n',NULL,NULL,272),
(273,3,'trader_id','n',NULL,NULL,273),
(274,3,'unit_fixed_flag','n',NULL,NULL,274),
(275,3,'update_ts','n',NULL,NULL,275),
(276,3,'update_user','n',NULL,NULL,276),
(277,3,'verified_by','n',NULL,NULL,277),
(278,3,'verified_date','n',NULL,NULL,278),
(470,13,'as_of_date','n',NULL,NULL,470),
(471,13,'counterparty_name','n',NULL,NULL,471),
(472,13,'exposure_percent','n',NULL,NULL,472),
(473,13,'counterparty_id','y',NULL,NULL,473),
(474,13,'limit_to_us_avail','n',NULL,NULL,474),
(475,13,'limit_variance','n',NULL,NULL,475),
(476,13,'net_exposure_to_us','n',NULL,NULL,476),
(477,13,'parent_counterparty_us','n',NULL,NULL,477),
(478,13,'total_limit_provided','n',NULL,NULL,478),
(656,3,'timezone_id','n',NULL,NULL,656),
(803,3,'counterparty_trader','n',NULL,NULL,803),
(816,3,'internal_counterparty','n',NULL,NULL,816),
(833,3,'reference_detail_id','n',NULL,NULL,833),
(838,3,'settlement_vol_type','n',NULL,NULL,838),
(849,3,'counterparty_id2','n',NULL,NULL,849),
(855,3,'trader_id2','n',NULL,NULL,855),
(919,3,'sample_control','n',NULL,'Subject to Sample Control',919),
(920,3,'recent_deal_status','n',NULL,'Recent Deal Status',920),
(921,3,'recent_confirm_status','n',NULL,'Recent Confirm Status',921),
(922,3,'subsidiary','n',NULL,'Subsidiary',922),
(923,3,'strategy','n',NULL,'Strategy',923),
(924,3,'book','n',NULL,'Book',924),
(963,3,'deal_date_term_difference','n',NULL,'deal_date_term_difference',963),
(964,3,'valid_template','n',NULL,'valid_template',964),
(966,13,'Is_Margin_call','n',NULL,'Is Margin Call',966),
(967,13,'internal_counterparty_id','n',NULL,'Internal Counterparty ID',967),
(968,13,'contract_id','n',NULL,'Contract ID',968),
(969,13,'net_exposure_to_them','n',NULL,'Net Exposure To Them',969),
(970,13,'cash_collateral_provided','n',NULL,'Cash Collateral Provided',970),
(971,13,'cash_collateral_received','n',NULL,'Cash Collateral Received',971),
(972,13,'effective_Exposure_to_us','n',NULL,'Exposure Exposure To Us',972),
(973,13,'effective_exposure_to_them','n',NULL,'Effective Exposure To Them',973),
(974,13,'collateral_received','n',NULL,'Collateral Received',974),
(975,13,'collateral_provided','n',NULL,'Collateral Provided',975),
(976,13,'limit_received','n',NULL,'Limit Received',976),
(977,13,'limit_provided','n',NULL,'Limit Provided',977),
(978,13,'margin_provision','n',NULL,'Margin Provision',978),
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_columns_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 where alert_columns_definition_id is null;
	update #alert_columns_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 set column_name='FARRMS1_ '+cast(alert_columns_definition_id as varchar(30))  where isnull(column_name,'')='' ;
	
print('--==============================END alert_columns_definition=============================')

UPDATE acd SET acd.alert_table_id = atd.new_recid
FROM #alert_columns_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 acd INNER JOIN #alert_table_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 atd ON atd.old_recid = acd.alert_table_id

print('--==============================START alert_columns_definition=============================')
UPDATE dbo.alert_columns_definition SET [alert_table_id]=dst.[alert_table_definition_id],[is_primary]=src_c.[is_primary],[static_data_type_id]=src_c.[static_data_type_id],[column_alias]=src_c.[column_alias]
		   OUTPUT 'u','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_table_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 src_c ON src_c.alert_table_id=src.alert_table_definition_id
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name;
insert into alert_columns_definition
		([alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias]
		)
		 OUTPUT 'i','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[alert_table_id],src_c.[column_name],src_c.[is_primary],src_c.[static_data_type_id],src_c.[column_alias]
		FROM #alert_table_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name 
			INNER JOIN #alert_columns_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			LEFT JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name
		WHERE dst_c.[alert_table_id] IS NULL;
UPDATE #alert_columns_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 SET new_recid =dst_c.[alert_columns_definition_id] 
			FROM #alert_table_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id
			 AND src_c.column_name=dst_c.column_name;
print('--==============================END alert_columns_definition=============================')
print('--==============================START static_data_value=============================')

	if object_id('tempdb..#static_data_value_7C8FADC9_8875_4FAC_852B_09331A760A25') is null 
	
	CREATE TABLE #static_data_value_7C8FADC9_8875_4FAC_852B_09331A760A25
	 (
	 [value_id] int ,[type_id] int ,[code] varchar(500) COLLATE DATABASE_DEFAULT ,[description] varchar(500) COLLATE DATABASE_DEFAULT ,[entity_id] int ,[xref_value_id] varchar(50) COLLATE DATABASE_DEFAULT ,[xref_value] varchar(250) COLLATE DATABASE_DEFAULT ,[category_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #static_data_value_7C8FADC9_8875_4FAC_852B_09331A760A25;
INSERT INTO #static_data_value_7C8FADC9_8875_4FAC_852B_09331A760A25(
	 [value_id],[type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id],old_recid
	 )
	 VALUES
	 
(20601,20600,'Deal','Deal',NULL,NULL,NULL,NULL,20601),
(20604,20600,'Counterparty Credit File','Counterparty Credit File',NULL,NULL,NULL,NULL,20604),
(20609,20600,'Counterparty Credit Limit','Counterparty Credit Limit',NULL,NULL,NULL,NULL,20609),
(20610,20600,'Calendar','Calendar',NULL,NULL,NULL,NULL,20610),
(20623,20600,'Credit Exposure','Credit Exposure',NULL,NULL,NULL,0,20623),
(20507,20500,'Counterparty Credit File Update','Counterparty Credit File Update',NULL,NULL,NULL,NULL,20507),
(20508,20500,'Counterparty Credit Exposure Calculation','Counterparty Credit Exposure Calculation',NULL,NULL,NULL,NULL,20508),
(20524,20500,'Counterparty Credit Limit Update','Counterparty Credit Limit Update',NULL,NULL,NULL,NULL,20524),
(20535,20500,'Calendar - Time Based',' Calendar - Time Based',NULL,NULL,NULL,0,20535),
(20537,20500,'Deal - Post Insert and Update',' Deal - Post Insert And Update',NULL,NULL,NULL,0,20537),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #static_data_value_7C8FADC9_8875_4FAC_852B_09331A760A25 where value_id is null;
	update #static_data_value_7C8FADC9_8875_4FAC_852B_09331A760A25 set code='FARRMS1_ '+cast(value_id as varchar(30))  where isnull(code,'')='' ;
	update #static_data_value_7C8FADC9_8875_4FAC_852B_09331A760A25 set type_id='FARRMS2_ '+cast(value_id as varchar(30))  where isnull(type_id,'')='' ;
			
UPDATE dbo.static_data_value SET [description]=src.[description],[entity_id]=src.[entity_id],[xref_value_id]=src.[xref_value_id],[xref_value]=src.[xref_value],[category_id]=src.[category_id]
		   OUTPUT 'u','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #static_data_value_7C8FADC9_8875_4FAC_852B_09331A760A25 src INNER JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id;
insert into static_data_value
		([type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id]
		)
		 OUTPUT 'i','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[type_id],src.[code],src.[description],src.[entity_id],src.[xref_value_id],src.[xref_value],src.[category_id]
		FROM #static_data_value_7C8FADC9_8875_4FAC_852B_09331A760A25 src LEFT JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id
		WHERE dst.[value_id] IS NULL;
UPDATE #static_data_value_7C8FADC9_8875_4FAC_852B_09331A760A25 SET new_recid =dst.new_id 
		FROM #static_data_value_7C8FADC9_8875_4FAC_852B_09331A760A25 src INNER JOIN #old_new_id dst  ON src.code=dst.unique_key1 AND src.type_id=dst.unique_key2 AND dst.table_name='static_data_value'
		;
print('--==============================END static_data_value=============================')
print('--==============================START module_events=============================')

	if object_id('tempdb..#module_events_7C8FADC9_8875_4FAC_852B_09331A760A25') is null 
	
	CREATE TABLE #module_events_7C8FADC9_8875_4FAC_852B_09331A760A25
	 (
	 [module_events_id] int ,[modules_id] int ,[event_id] varchar(2000) COLLATE DATABASE_DEFAULT ,[workflow_name] varchar(100) COLLATE DATABASE_DEFAULT ,[workflow_owner] varchar(100) COLLATE DATABASE_DEFAULT ,[rule_table_id] int ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #module_events_7C8FADC9_8875_4FAC_852B_09331A760A25;
INSERT INTO #module_events_7C8FADC9_8875_4FAC_852B_09331A760A25(
	 [module_events_id],[modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id],[is_active],old_recid
	 )
	 VALUES
	 
(1174,20610,'20535','Collateral Expiring Alert',NULL,NULL,'y',1174),
(1175,20623,'20508','Credit Limit Violation',NULL,13,'y',1175),
(1176,20610,'20535','Credit File Review Reminder',NULL,NULL,'y',1176),
(1177,20610,'20535','Contract Expiration Alert',NULL,NULL,NULL,1177),
(1178,20601,'20537','Incomplete Deals While Insert',NULL,3,NULL,1178),
(1179,20604,'20507','Counterparty Credit File Update Alert',NULL,NULL,'y',1179),
(1180,20609,'20524','Credit Limit Update Alert',NULL,NULL,'y',1180),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #module_events_7C8FADC9_8875_4FAC_852B_09331A760A25 where module_events_id is null;
	update #module_events_7C8FADC9_8875_4FAC_852B_09331A760A25 set workflow_name='FARRMS1_ '+cast(module_events_id as varchar(30))  where isnull(workflow_name,'')='' ;
	
print('--==============================END module_events=============================')

UPDATE me SET me.rule_table_id = atd.new_recid FROM #module_events_7C8FADC9_8875_4FAC_852B_09331A760A25 me INNER JOIN #alert_table_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 atd ON atd.old_recid = me.rule_table_id
UPDATE me SET me.modules_id = sdv.new_recid FROM #module_events_7C8FADC9_8875_4FAC_852B_09331A760A25 me INNER JOIN #static_data_value_7C8FADC9_8875_4FAC_852B_09331A760A25 sdv ON sdv.old_recid = me.modules_id 
UPDATE me SET me.event_id = sdv.new_recid FROM #module_events_7C8FADC9_8875_4FAC_852B_09331A760A25 me INNER JOIN #static_data_value_7C8FADC9_8875_4FAC_852B_09331A760A25 sdv ON sdv.old_recid = me.event_id 

print('--==============================START module_events=============================')
UPDATE dbo.module_events SET [modules_id]=src.[modules_id],[event_id]=src.[event_id],[workflow_owner]=src.[workflow_owner],[rule_table_id]=src.[rule_table_id],[is_active]=src.[is_active]
		   OUTPUT 'u','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #module_events_7C8FADC9_8875_4FAC_852B_09331A760A25 src INNER JOIN module_events dst  ON src.workflow_name=dst.workflow_name;
insert into module_events
		([modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id],[is_active]
		)
		 OUTPUT 'i','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[modules_id],src.[event_id],src.[workflow_name],src.[workflow_owner],src.[rule_table_id],src.[is_active]
		FROM #module_events_7C8FADC9_8875_4FAC_852B_09331A760A25 src LEFT JOIN module_events dst  ON src.workflow_name=dst.workflow_name
		WHERE dst.[module_events_id] IS NULL;
UPDATE #module_events_7C8FADC9_8875_4FAC_852B_09331A760A25 SET new_recid =dst.new_id 
		FROM #module_events_7C8FADC9_8875_4FAC_852B_09331A760A25 src INNER JOIN #old_new_id dst  ON src.workflow_name=dst.unique_key1 AND dst.table_name='module_events'
		;
print('--==============================END module_events=============================')

INSERT INTO #module_events_bkup(module_events_id, modules_id, event_id, workflow_name, workflow_owner, rule_table_id, new_recid, old_recid)	
SELECT me.module_events_id, me.modules_id, me.event_id, me.workflow_name, me.workflow_owner, me.rule_table_id, me.new_recid, me.old_recid FROM #module_events_7C8FADC9_8875_4FAC_852B_09331A760A25 me
LEFT JOIN #module_events_bkup meb ON meb.old_recid = me.old_recid 
WHERE meb.old_recid IS NULL
print('--==============================START static_data_value=============================')

	if object_id('tempdb..#static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [value_id] int ,[type_id] int ,[code] varchar(500) COLLATE DATABASE_DEFAULT ,[description] varchar(500) COLLATE DATABASE_DEFAULT ,[entity_id] int ,[xref_value_id] varchar(50) COLLATE DATABASE_DEFAULT ,[xref_value] varchar(250) COLLATE DATABASE_DEFAULT ,[category_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [value_id],[type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id],old_recid
	 )
	 VALUES
	 
(757,750,'Alert','Alert with Beep Sound',NULL,NULL,NULL,NULL,757),
(4,1,'Control Group','Control Group',NULL,NULL,NULL,NULL,4),
(7,1,'Application Admin Group','Application Admin Group',NULL,NULL,NULL,NULL,7),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where value_id is null;
	update #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set code='FARRMS1_ '+cast(value_id as varchar(30))  where isnull(code,'')='' ;
	update #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set type_id='FARRMS2_ '+cast(value_id as varchar(30))  where isnull(type_id,'')='' ;
			
UPDATE dbo.static_data_value SET [description]=src.[description],[entity_id]=src.[entity_id],[xref_value_id]=src.[xref_value_id],[xref_value]=src.[xref_value],[category_id]=src.[category_id]
		   OUTPUT 'u','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id;
insert into static_data_value
		([type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id]
		)
		 OUTPUT 'i','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[type_id],src.[code],src.[description],src.[entity_id],src.[xref_value_id],src.[xref_value],src.[category_id]
		FROM #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id
		WHERE dst.[value_id] IS NULL;
UPDATE #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid =dst.new_id 
		FROM #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN #old_new_id dst  ON src.code=dst.unique_key1 AND src.type_id=dst.unique_key2 AND dst.table_name='static_data_value'
		;
print('--==============================END static_data_value=============================')
print('--==============================START alert_sql=============================')

	if object_id('tempdb..#alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [alert_sql_id] int ,[workflow_only] varchar(1) COLLATE DATABASE_DEFAULT ,[message] varchar(500) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,[sql_statement] varchar(max) COLLATE DATABASE_DEFAULT ,[alert_sql_name] varchar(100) COLLATE DATABASE_DEFAULT ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,[alert_type] char(1) COLLATE DATABASE_DEFAULT ,[rule_category] int ,[system_rule] char(1) COLLATE DATABASE_DEFAULT ,[alert_category] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [alert_sql_id],[workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category],old_recid
	 )
	 VALUES
	 
(1,'n','Credit Limit Violation Threshold Check','757','SET NOCOUNT ON 
IF EXISTS (SELECT 1
           FROM   adiha_process.sys.tables
           WHERE  [name] = ''alert_credit_exposure_process_id_ace'')
  BEGIN
     
	IF  OBJECT_ID(''tempdb..#cpty_unique_list'') IS NOT NULL
		DROP TABLE #cpty_unique_list
	IF OBJECT_ID(''tempdb..#temp_counterparty_credit_data'') IS NOT NULL
		DROP TABLE #temp_counterparty_credit_data
	IF OBJECT_ID(''tempdb..#min_violation'') IS NOT NULL
		DROP TABLE #min_violation
	IF OBJECT_ID(''tempdb..#credit_limit_violated'') IS NOT NULL
		DROP TABLE #credit_limit_violated
	IF OBJECT_ID(''tempdb..#max_violation'') IS NOT NULL
		DROP TABLE #max_violation
	IF OBJECT_ID(''tempdb..#limit_violation'') IS NOT NULL
		DROP TABLE #limit_violation
      -- Same counterparty can mapped in multiple subsidiary so collect only one information. --adiha_process.dbo.alert_credit_exposure_process_id_ace 
      SELECT DISTINCT counterparty_id,
			as_of_date,
			internal_counterparty_id,
			contract_id
      INTO   #cpty_unique_list
      FROM  staging_table.alert_credit_exposure_process_id_ace

      SELECT ced.source_counterparty_id,
             ccl.internal_counterparty_id,
             Max(sc1.counterparty_name)
             internal_counterparty,
             ccl.contract_id,
             Max(cg.contract_name)  AS [CONTRACT],
             a.as_of_date,
             Max(sc.counterparty_name)  [Counterparty],
             Round(Sum(Isnull(d_effective_exposure_to_us, 0)), 2) [effective exposure],
             Round(Sum(limit_available_to_them), 2) limit_available,
             Round(Sum(ced.limit_provided), 0)  [Limit]
		INTO   #temp_counterparty_credit_data
		FROM   #cpty_unique_list a
        INNER JOIN credit_exposure_summary ced ON a.counterparty_id = ced.source_counterparty_id
                AND a.as_of_date = ced.as_of_date
                AND ( ced.internal_counterparty_id = a.internal_counterparty_id OR NULLIF(a.internal_counterparty_id, '''') IS NULL)
                AND ( ced.contract_id = a.contract_id OR NULLIF(a.contract_id, '''') IS NULL )
		INNER JOIN source_counterparty sc ON ced.source_counterparty_id=sc.source_counterparty_id
        LEFT JOIN counterparty_credit_limits AS ccl ON a.counterparty_id = ccl.counterparty_id
			AND ( a.internal_counterparty_id = ccl.internal_counterparty_id OR NULLIF(ccl.internal_counterparty_id, '''') IS NULL)
            AND ( a.contract_id = ccl.contract_id OR NULLIF(ccl.contract_id, '''') IS NULL )
        LEFT JOIN source_counterparty sc1 ON sc1.source_counterparty_id = a.internal_counterparty_id
        LEFT JOIN contract_group cg ON cg.contract_id = ccl.contract_id
      WHERE  ced.as_of_date = a.as_of_date
      GROUP  BY ced.source_counterparty_id,
                ccl.internal_counterparty_id,
                ccl.contract_id,
                a.as_of_date
      ORDER  BY ced.source_counterparty_id,
                ccl.internal_counterparty_id,
				ccl.contract_id,
                a.as_of_date

      SELECT [source_counterparty_id],
             internal_counterparty,
             [contract],
             [counterparty],
             [effective exposure],
             limit_available,
             limit,
             ccl.max_threshold,
             ccl.min_threshold
      INTO   #credit_limit_violated
      FROM   #temp_counterparty_credit_data a
             INNER JOIN counterparty_credit_info cci
                     ON a.[source_counterparty_id] = cci.counterparty_id
             OUTER apply (SELECT TOP(1) ccl.internal_counterparty_id,
                                        ccl.contract_id,
                                        ccl.effective_date,
                                        Isnull(ccl.min_threshold, 0)
                                        min_threshold
                                        ,
                         Isnull(ccl.max_threshold, 0) max_threshold
                          FROM   counterparty_credit_limits ccl
                          WHERE  ccl.counterparty_id = a.source_counterparty_id
                                 AND ( ccl.internal_counterparty_id =
                                       a.internal_counterparty_id
                                        OR NULLIF(ccl.internal_counterparty_id,
                                           ''''
                                           ) IS
                                           NULL )
                                 AND ( ccl.contract_id = a.contract_id
                                        OR NULLIF(ccl.contract_id, '''') IS NULL )
                                 AND a.as_of_date >= ccl.effective_date
                          ORDER  BY
                    Isnull(NULLIF(ccl.internal_counterparty_id, ''''), 9999999),
                    Isnull(NULLIF(ccl.contract_id, ''''), 9999999),
                    ccl.effective_date) ccl

      SELECT [source_counterparty_id],
             internal_counterparty,
             [contract],
             [counterparty],
             [effective exposure],
             limit_available,
             limit,
             ( ( Isnull(min_threshold, 0) * [limit] ) / 100 ) [Min Threshold],
             ( ( Isnull(max_threshold, 0) * [limit] ) / 100 ) [Max Threshold],
             ''Minimum Threshold Reached''
             [Notification Type]
      INTO   #min_violation
      FROM   #credit_limit_violated
      WHERE  ( [effective exposure] > ( ( Isnull(min_threshold, 100) * [limit] )
                                        /
                                        100 ) )
             AND limit_available > 0

      SELECT [source_counterparty_id],
             internal_counterparty,
             [contract],
             [counterparty],
             [effective exposure],
             limit_available,
             limit,
             ( ( Isnull(min_threshold, 0) * [limit] ) / 100 )
             [Min Threshold],
             ( ( Isnull(max_threshold, 100) * [limit] ) / 100 )
             [Max Threshold],
             ''Maximum Threshold Reached and Counterparty is blocked''
             [Notification Type]
      INTO   #max_violation
      FROM   #credit_limit_violated
      WHERE  ( [effective exposure] > ( ( Isnull(max_threshold, 100) * [limit] )
                                        /
                                        100 ) )
             AND limit_available < 0

      SELECT [source_counterparty_id],
             internal_counterparty,
             [contract],
             [counterparty],
             [effective exposure],
             limit_available,
             limit,
             ( ( Isnull(min_threshold, 0) * [limit] ) / 100 )   [Min Threshold],
             ( ( Isnull(max_threshold, 100) * [limit] ) / 100 ) [Max Threshold],
             ''Limit Violation''
             [Notification Type]
      INTO   #limit_violation
      FROM   #credit_limit_violated
      WHERE  ( [effective exposure] < ( ( Isnull(max_threshold, 100) * [limit] )
                                        /
                                        100 ) )
             AND limit_available < 0

      SELECT [Counterparty],
			internal_counterparty [Internal Counterparty],
            [Contract],
           REPLACE(CONVERT(VARCHAR, CAST(ROUND([Effective Exposure],0) AS MONEY), 1), ''.0'', '''') [Effective Exposure],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Limit],0) AS MONEY), 1), ''.0'', '''')                 [Limit],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Min threshold],0)AS MONEY), 1), ''.0'', '''')     [Min threshold],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Max threshold],0) AS MONEY), 1), ''.0'', '''') [Max threshold],
			REPLACE(CONVERT(VARCHAR, CAST(ROUND(limit_available,0)  AS MONEY), 1), ''.0'', '''')       [ Limit Available],
             ''Minimum Threshold Reached'' [Notification Type]
		INTO  adiha_process.dbo.credit_limit_violation_process_id_clv 
      FROM   #min_violation
      UNION ALL
      SELECT [Counterparty],
			internal_counterparty [Internal Counterparty],
            [Contract],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Effective Exposure],0) AS MONEY), 1), ''.0'', '''') [Effective Exposure],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Limit],0) AS MONEY), 1), ''.0'', '''')                 [Limit],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Min threshold],0)AS MONEY), 1), ''.0'', '''')     [Min threshold],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Max threshold],0) AS MONEY), 1), ''.0'', '''') [Max threshold],
			REPLACE(CONVERT(VARCHAR, CAST(ROUND(limit_available,0)  AS MONEY), 1), ''.0'', '''')       [ Limit Available],
             ''Maximum Threshold Reached and Counterparty is blocked''
             [Notification Type]
      FROM   #max_violation
      UNION ALL
      SELECT 
			[Counterparty],
			internal_counterparty [Internal Counterparty],
            [Contract],
           REPLACE(CONVERT(VARCHAR, CAST(ROUND([Effective Exposure],0) AS MONEY), 1), ''.0'', '''') [Effective Exposure],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Limit],0) AS MONEY), 1), ''.0'', '''')                 [Limit],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Min threshold],0)AS MONEY), 1), ''.0'', '''')     [Min threshold],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Max threshold],0) AS MONEY), 1), ''.0'', '''') [Max threshold],
			REPLACE(CONVERT(VARCHAR, CAST(ROUND(limit_available,0)  AS MONEY), 1), ''.0'', '''')       [ Limit Available],
            ''Limit Violation''     [Notification Type]
      FROM   #limit_violation

	DECLARE @counterparty_id VARCHAR(MAX)  
    SELECT @counterparty_id = COALESCE(@counterparty_id+'','' ,'''') + cast(source_counterparty_id as varchar)
    FROM (SELECT 
				DISTINCT sc.source_counterparty_id
           FROM adiha_process.dbo.credit_limit_violation_process_id_clv  clvp 
		   INNER JOIN source_counterparty AS sc ON sc.counterparty_name = clvp.[Counterparty] 
			WHERE [Notification Type] = ''Maximum Threshold Reached and Counterparty is blocked'') t

		DELETE ccbt
		FROM counterparty_credit_block_trading ccbt
		INNER JOIN #cpty_unique_list cul ON cul.counterparty_id = ccbt.counterparty_id
			AND cul.contract_id = ccbt.[contract]
			AND ISNULL(cul.internal_counterparty_id, -1) = COALESCE(ccbt.internal_counterparty_id, cul.internal_counterparty_id, -1)
		INNER JOIN counterparty_contract_address cca ON cca.counterparty_id = cul.counterparty_id
			AND cul.contract_id = cca.contract_id
			AND ISNULL(cul.internal_counterparty_id, -1) = COALESCE(cca.internal_counterparty_id, cul.internal_counterparty_id, -1)

		INSERT INTO counterparty_credit_block_trading (
			counterparty_contract_address_id,
			counterparty_id, 
			[contract], 
			internal_counterparty_id,
			buysell_allow,
			buy_sell)
		SELECT DISTINCT
			cca.counterparty_contract_address_id,
			cca.counterparty_id, 
			cca.contract_id, 
			cca.internal_counterparty_id,
			''y'',
			''3''
		FROM counterparty_contract_address cca
		INNER JOIN #cpty_unique_list cul ON cul.counterparty_id = cca.counterparty_id
			AND cul.contract_id = cca.contract_id
			AND ISNULL(cul.internal_counterparty_id, -1) = COALESCE(cca.internal_counterparty_id, cul.internal_counterparty_id, -1)
	  
		IF NOT EXISTS (SELECT 1 FROM adiha_process.dbo.credit_limit_violation_process_id_clv) 
        BEGIN 
            RETURN 
        END 
		
		DECLARE @top_counterparty_id INT
		DECLARE @top_contract_id INT
		DECLARE @top_internal_counterparty_id INT 

		SELECT TOP(1) @top_counterparty_id = counterparty_id, 
			@top_contract_id = contract_id 
		FROM adiha_process.dbo.alert_credit_exposure_process_id_ace 
		ORDER BY contract_id DESC

		DELETE a 
		FROM adiha_process.dbo.alert_credit_exposure_process_id_ace a
		LEFT JOIN (
		SELECT * FROM adiha_process.dbo.alert_credit_exposure_process_id_ace
				WHERE counterparty_id = @top_counterparty_id 
				AND contract_id = @top_contract_id											
		) b ON a.counterparty_id = b.counterparty_id AND a.contract_id=b.contract_id
		WHERE b.counterparty_id IS NULL

  END','Credit Limit Violation Threshold Check','y','s',-1,'n',NULL,1),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where alert_sql_id is null;
	update #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set alert_sql_name='FARRMS1_ '+cast(alert_sql_id as varchar(30))  where isnull(alert_sql_name,'')='' ;
	
print('--==============================END alert_sql=============================')

UPDATE dbo.alert_sql SET [workflow_only]=src.[workflow_only],[message]=src.[message],[notification_type]=src.[notification_type],[sql_statement]=src.[sql_statement],[is_active]=src.[is_active],[alert_type]=src.[alert_type],[rule_category]=src.[rule_category],[system_rule]=src.[system_rule],[alert_category]=src.[alert_category]
		   OUTPUT 'u','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name;

IF EXISTS(SELECT 1 FROM #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 WHERE alert_sql_id < 0)
BEGIN
	SET IDENTITY_INSERT alert_sql ON
	INSERT INTO alert_sql
	([alert_sql_id], [workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category]
	)
	OUTPUT 'i','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	SELECT 
	src.alert_sql_id, src.[workflow_only],src.[message],src.[notification_type],src.[sql_statement],src.[alert_sql_name],src.[is_active],src.[alert_type],src.[rule_category],src.[system_rule],src.[alert_category]
	FROM #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
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
	FROM #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
	WHERE dst.[alert_sql_id] IS NULL;
END

UPDATE #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid = dst.new_id , alert_sql_id =  dst.new_id
FROM #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN #old_new_id dst ON src.alert_sql_name = dst.unique_key1 AND dst.table_name = 'alert_sql'

UPDATE asl SET asl.notification_type = sdv.new_recid 
FROM alert_sql asl INNER JOIN #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 sdv ON sdv.old_recid = asl.notification_type	

UPDATE asl SET asl.rule_category = sdv.new_recid
FROM alert_sql asl INNER JOIN #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 sdv ON sdv.old_recid = asl.rule_category	


	INSERT INTO #alert_sql_bkup (alert_sql_id, workflow_only, message, notification_type, sql_statement, alert_sql_name, is_active, alert_type, rule_category, system_rule, alert_category, new_recid, old_recid)
	SELECT asl.alert_sql_id, asl.workflow_only, asl.message, asl.notification_type, asl.sql_statement, asl.alert_sql_name, asl.is_active, asl.alert_type, asl.rule_category, asl.system_rule, asl.alert_category, asl.new_recid, asl.old_recid FROM #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 asl
	LEFT JOIN #alert_sql_bkup aslb ON aslb.old_recid = asl.old_recid
	WHERE aslb.old_recid IS NULL
print('--==============================START alert_table_definition=============================')

	if object_id('tempdb..#alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [alert_table_definition_id] int ,[logical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[physical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[data_source_id] int ,[is_action_view] char(1) COLLATE DATABASE_DEFAULT ,[primary_column] varchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [alert_table_definition_id],[logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column],old_recid
	 )
	 VALUES
	 
(14,'Counterparty Credit Info Audit','vwCounterPartyCreditInfoAudit',NULL,NULL,NULL,14),
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where alert_table_definition_id is null;
	update #alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set logical_table_name='FARRMS1_ '+cast(alert_table_definition_id as varchar(30))  where isnull(logical_table_name,'')='' ;
	
UPDATE dbo.alert_table_definition SET [physical_table_name]=src.[physical_table_name],[data_source_id]=src.[data_source_id],[is_action_view]=src.[is_action_view],[primary_column]=src.[primary_column]
		   OUTPUT 'u','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name;
insert into alert_table_definition
		([logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column]
		)
		 OUTPUT 'i','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[logical_table_name],src.[physical_table_name],src.[data_source_id],src.[is_action_view],src.[primary_column]
		FROM #alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name
		WHERE dst.[alert_table_definition_id] IS NULL;
UPDATE #alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid =dst.new_id 
		FROM #alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN #old_new_id dst  ON src.logical_table_name=dst.unique_key1 AND dst.table_name='alert_table_definition'
		;
print('--==============================END alert_table_definition=============================')

UPDATE #alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET alert_table_definition_id = new_recid

print('--==============================START alert_columns_definition=============================')

	if object_id('tempdb..#alert_columns_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #alert_columns_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [alert_columns_definition_id] int ,[alert_table_id] int ,[column_name] varchar(600) COLLATE DATABASE_DEFAULT ,[is_primary] char(1) COLLATE DATABASE_DEFAULT ,[static_data_type_id] int ,[column_alias] varchar(200) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_columns_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #alert_columns_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [alert_columns_definition_id],[alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias],old_recid
	 )
	 VALUES
	 
(479,14,'account_status_compare','n',NULL,NULL,479),
(480,14,'counterparty_id','y',NULL,NULL,480),
(481,14,'credit_limit_compare','n',NULL,NULL,481),
(482,14,'debt_rating_compare','n',NULL,NULL,482),
(483,14,'debt_rating2_compare','n',NULL,NULL,483),
(484,14,'debt_rating3_compare','n',NULL,NULL,484),
(485,14,'debt_rating4_compare','n',NULL,NULL,485),
(486,14,'debt_rating5_compare','n',NULL,NULL,486),
(487,14,'previous_account_status','n',NULL,NULL,487),
(488,14,'previous_credit_limit','n',NULL,NULL,488),
(489,14,'previous_Debt_rating','n',NULL,NULL,489),
(490,14,'previous_Debt_Rating2','n',NULL,NULL,490),
(491,14,'previous_Debt_Rating3','n',NULL,NULL,491),
(492,14,'previous_Debt_Rating4','n',NULL,NULL,492),
(493,14,'previous_Debt_Rating5','n',NULL,NULL,493),
(962,14,'previous_risk_rating','n',NULL,'Previous Risk Rating',962),
(961,14,'risk_rating_compare','n',NULL,'Risk Rating Compare',961),
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_columns_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where alert_columns_definition_id is null;
	update #alert_columns_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set column_name='FARRMS1_ '+cast(alert_columns_definition_id as varchar(30))  where isnull(column_name,'')='' ;
	
print('--==============================END alert_columns_definition=============================')

UPDATE acd SET acd.alert_table_id = atd.new_recid
FROM #alert_columns_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 acd INNER JOIN #alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 atd ON atd.old_recid = acd.alert_table_id

print('--==============================START alert_columns_definition=============================')
UPDATE dbo.alert_columns_definition SET [alert_table_id]=dst.[alert_table_definition_id],[is_primary]=src_c.[is_primary],[static_data_type_id]=src_c.[static_data_type_id],[column_alias]=src_c.[column_alias]
		   OUTPUT 'u','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src_c ON src_c.alert_table_id=src.alert_table_definition_id
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name;
insert into alert_columns_definition
		([alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias]
		)
		 OUTPUT 'i','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[alert_table_id],src_c.[column_name],src_c.[is_primary],src_c.[static_data_type_id],src_c.[column_alias]
		FROM #alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name 
			INNER JOIN #alert_columns_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			LEFT JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name
		WHERE dst_c.[alert_table_id] IS NULL;
UPDATE #alert_columns_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid =dst_c.[alert_columns_definition_id] 
			FROM #alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id
			 AND src_c.column_name=dst_c.column_name;
print('--==============================END alert_columns_definition=============================')

DELETE FROM alert_table_relation WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3)
DELETE FROM alert_actions_events WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3)
DELETE FROM alert_actions WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3)
DELETE FROM alert_table_where_clause WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3)
DELETE from alert_conditions WHERE rules_id IN (SELECT alert_sql_id FROM #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3)
DELETE from alert_rule_table where alert_id IN (SELECT alert_sql_id FROM #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3)
print('--==============================START alert_rule_table=============================')

	if object_id('tempdb..#alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [alert_rule_table_id] int ,[alert_id] int ,[table_id] int ,[root_table_id] int ,[table_alias] varchar(50) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [alert_rule_table_id],[alert_id],[table_id],[root_table_id],[table_alias],old_recid
	 )
	 VALUES
	 
(259,1,14,NULL,'ccia',259),
(NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where alert_rule_table_id is null;
	update #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set alert_rule_table_id='FARRMS1_ '+cast(alert_rule_table_id as varchar(30))  where isnull(alert_rule_table_id,'')='' ;
	
print('--==============================END alert_rule_table=============================')

UPDATE art SET art.alert_id = asl.new_recid
FROM #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 art INNER JOIN #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 asl ON asl.old_recid = art.alert_id

UPDATE art SET art.table_id = asd.new_recid
FROM #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 art INNER JOIN #alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3  asd ON asd.old_recid = art.table_id

UPDATE dbo.alert_rule_table SET [table_alias]=src.[table_alias]
		   OUTPUT 'u','alert_rule_table',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
insert into alert_rule_table
		([alert_id],[table_id],[root_table_id],[table_alias]
		)
		 OUTPUT 'i','alert_rule_table',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[root_table_id],src.[table_alias]
		FROM #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
		WHERE dst.[alert_rule_table_id] IS NULL;
UPDATE #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid =dst.new_id 
		FROM #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND ISNULL(src.root_table_id, -1)=ISNULL(dst.unique_key3, -1) AND dst.table_name='alert_rule_table'
		;
print('--==============================END alert_rule_table=============================')
	-- need to verify root_table_id
UPDATE art SET art.root_table_id = art2.new_recid FROM #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 art INNER JOIN #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 art2 ON art2.old_recid = art.root_table_id  
UPDATE art SET art.root_table_id = arrt.root_table_id FROM alert_rule_table art INNER JOIN #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 arrt ON arrt.new_recid = art.alert_rule_table_id 

print('--==============================START alert_conditions=============================')

	if object_id('tempdb..#alert_conditions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #alert_conditions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [alert_conditions_id] int ,[rules_id] int ,[alert_conditions_name] varchar(100) COLLATE DATABASE_DEFAULT ,[alert_conditions_description] varchar(500) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_conditions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #alert_conditions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [alert_conditions_id],[rules_id],[alert_conditions_name],[alert_conditions_description],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,null);
	delete #alert_conditions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where alert_conditions_id is null;
	update #alert_conditions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set alert_conditions_name='FARRMS1_ '+cast(alert_conditions_id as varchar(30))  where isnull(alert_conditions_name,'')='' ;
	
print('--==============================END alert_conditions=============================')

UPDATE ac SET rules_id = asl.new_recid	
FROM #alert_conditions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 ac INNER JOIN #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 asl ON asl.old_recid = ac.rules_id
print('--==============================START alert_conditions=============================')
UPDATE dbo.alert_conditions SET [rules_id]=dst.[alert_sql_id],[alert_conditions_description]=src_c.[alert_conditions_description]
		   OUTPUT 'u','alert_conditions',inserted.alert_conditions_id,inserted.alert_conditions_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
			INNER JOIN #alert_conditions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src_c ON src_c.rules_id=src.alert_sql_id
			INNER JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id AND src_c.alert_conditions_name=dst_c.alert_conditions_name;
insert into alert_conditions
		([rules_id],[alert_conditions_name],[alert_conditions_description]
		)
		 OUTPUT 'i','alert_conditions',inserted.alert_conditions_id,inserted.alert_conditions_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[rules_id],src_c.[alert_conditions_name],src_c.[alert_conditions_description]
		FROM #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name 
			INNER JOIN #alert_conditions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src_c ON src_c.rules_id=src.alert_sql_id	
			LEFT JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id AND src_c.alert_conditions_name=dst_c.alert_conditions_name
		WHERE dst_c.[rules_id] IS NULL;
UPDATE #alert_conditions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid =dst_c.[alert_conditions_id] 
			FROM #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
			INNER JOIN #alert_conditions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src_c ON src_c.rules_id=src.alert_sql_id	
			INNER JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id
			 AND src_c.alert_conditions_name=dst_c.alert_conditions_name;
print('--==============================END alert_conditions=============================')

UPDATE #alert_conditions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET alert_conditions_id = new_recid
print('--==============================START alert_table_where_clause=============================')

	if object_id('tempdb..#alert_table_where_clause_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #alert_table_where_clause_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [alert_table_where_clause_id] int ,[alert_id] int ,[clause_type] int ,[column_id] int ,[operator_id] int ,[column_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[second_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[table_id] int ,[column_function] varchar(1000) COLLATE DATABASE_DEFAULT ,[condition_id] int ,[sequence_no] int ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_where_clause_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #alert_table_where_clause_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [alert_table_where_clause_id],[alert_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[condition_id],[sequence_no],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_where_clause_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where alert_table_where_clause_id is null;
	update #alert_table_where_clause_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set alert_table_where_clause_id='FARRMS1_ '+cast(alert_table_where_clause_id as varchar(30))  where isnull(alert_table_where_clause_id,'')='' ;
	
print('--==============================END alert_table_where_clause=============================')

UPDATE atwc SET atwc.alert_id = asl.new_recid FROM #alert_table_where_clause_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 atwc INNER JOIN #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 asl ON asl.old_recid = atwc.alert_id
UPDATE atwc SET atwc.column_id = acd.new_recid FROM #alert_table_where_clause_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 atwc INNER JOIN #alert_columns_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3  acd ON acd.old_recid = atwc.column_id
UPDATE atwc SET atwc.table_id = art.new_recid FROM #alert_table_where_clause_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 atwc INNER JOIN #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 art ON art.old_recid = atwc.table_id
UPDATE atwc SET atwc.condition_id = ac.new_recid FROM #alert_table_where_clause_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 atwc INNER JOIN #alert_conditions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 ac ON ac.old_recid = atwc.condition_id

print('--==============================START alert_table_where_clause=============================')
UPDATE dbo.alert_table_where_clause SET [alert_id]=src.[alert_id],[clause_type]=src.[clause_type],[column_id]=src.[column_id],[operator_id]=src.[operator_id],[column_value]=src.[column_value],[second_value]=src.[second_value],[table_id]=src.[table_id],[column_function]=src.[column_function],[condition_id]=src.[condition_id],[sequence_no]=src.[sequence_no],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','alert_table_where_clause',inserted.alert_table_where_clause_id,inserted.alert_table_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_where_clause_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN alert_table_where_clause dst  ON src.alert_table_where_clause_id=dst.alert_table_where_clause_id;
insert into alert_table_where_clause
		([alert_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[condition_id],[sequence_no],[data_source_column_id]
		)
		 OUTPUT 'i','alert_table_where_clause',inserted.alert_table_where_clause_id,inserted.alert_table_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[clause_type],src.[column_id],src.[operator_id],src.[column_value],src.[second_value],src.[table_id],src.[column_function],src.[condition_id],src.[sequence_no],src.[data_source_column_id]
		FROM #alert_table_where_clause_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN alert_table_where_clause dst  ON src.alert_table_where_clause_id=dst.alert_table_where_clause_id
		WHERE dst.[alert_table_where_clause_id] IS NULL;
UPDATE #alert_table_where_clause_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid =dst.new_id 
		FROM #alert_table_where_clause_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN #old_new_id dst  ON src.alert_table_where_clause_id=dst.unique_key1 AND dst.table_name='alert_table_where_clause'
		;
print('--==============================END alert_table_where_clause=============================')
print('--==============================START alert_actions=============================')

	if object_id('tempdb..#alert_actions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #alert_actions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [alert_actions_id] int ,[alert_id] int ,[table_id] int ,[column_id] int ,[column_value] varchar(500) COLLATE DATABASE_DEFAULT ,[condition_id] int ,[sql_statement] varchar(max) COLLATE DATABASE_DEFAULT ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_actions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #alert_actions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [alert_actions_id],[alert_id],[table_id],[column_id],[column_value],[condition_id],[sql_statement],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_actions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where alert_actions_id is null;
	update #alert_actions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set alert_id='FARRMS1_ '+cast(alert_actions_id as varchar(30))  where isnull(alert_id,'')='' ;
	
print('--==============================END alert_actions=============================')

UPDATE aa SET aa.column_id = acd.new_recid FROM #alert_actions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 aa INNER JOIN #alert_columns_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3  acd ON acd.old_recid = aa.column_id
UPDATE aa SET aa.table_id = art.new_recid FROM #alert_actions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 aa INNER JOIN #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 art ON art.old_recid = aa.table_id
UPDATE aa SET aa.condition_id = ac.new_recid FROM #alert_actions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 aa INNER JOIN #alert_conditions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 ac ON ac.old_recid = aa.condition_id
UPDATE aa SET aa.alert_id = asl.new_recid FROM #alert_actions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 aa INNER JOIN #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 asl ON asl.old_recid = aa.alert_id

print('--==============================START alert_actions=============================')
UPDATE dbo.alert_actions SET [table_id]=src.[table_id],[column_id]=src.[column_id],[column_value]=src.[column_value],[condition_id]=src.[condition_id],[sql_statement]=src.[sql_statement],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','alert_actions',inserted.alert_actions_id,inserted.alert_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_actions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN alert_actions dst  ON src.alert_id=dst.alert_id;
insert into alert_actions
		([alert_id],[table_id],[column_id],[column_value],[condition_id],[sql_statement],[data_source_column_id]
		)
		 OUTPUT 'i','alert_actions',inserted.alert_actions_id,inserted.alert_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[column_id],src.[column_value],src.[condition_id],src.[sql_statement],src.[data_source_column_id]
		FROM #alert_actions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN alert_actions dst  ON src.alert_id=dst.alert_id
		WHERE dst.[alert_actions_id] IS NULL;
UPDATE #alert_actions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid =dst.new_id 
		FROM #alert_actions_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND dst.table_name='alert_actions'
		;
print('--==============================END alert_actions=============================')
print('--==============================START alert_actions_events=============================')

	if object_id('tempdb..#alert_actions_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #alert_actions_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [alert_actions_events_id] int ,[alert_id] int ,[table_id] int ,[callback_alert_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_actions_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #alert_actions_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [alert_actions_events_id],[alert_id],[table_id],[callback_alert_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,null);
	delete #alert_actions_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where alert_actions_events_id is null;
	update #alert_actions_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set alert_id='FARRMS1_ '+cast(alert_actions_events_id as varchar(30))  where isnull(alert_id,'')='' ;
	update #alert_actions_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set table_id='FARRMS2_ '+cast(alert_actions_events_id as varchar(30))  where isnull(table_id,'')='' ;
			update #alert_actions_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set callback_alert_id='FARRMS3_ '+cast(alert_actions_events_id as varchar(30))  where isnull(callback_alert_id,'')='' ;
			
print('--==============================END alert_actions_events=============================')

UPDATE aae SET aae.alert_id = asl.new_recid FROM #alert_actions_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 aae INNER JOIN #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 asl ON asl.old_recid = aae.alert_id
UPDATE aae SET aae.table_id = art.new_recid FROM #alert_actions_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 aae INNER JOIN #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 art ON art.old_recid = aae.table_id

print('--==============================START alert_actions_events=============================')
UPDATE dbo.alert_actions_events SET [callback_alert_id]=src.[callback_alert_id]
		   OUTPUT 'u','alert_actions_events',inserted.alert_actions_events_id,inserted.alert_id,inserted.table_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_actions_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN alert_actions_events dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id;
insert into alert_actions_events
		([alert_id],[table_id],[callback_alert_id]
		)
		 OUTPUT 'i','alert_actions_events',inserted.alert_actions_events_id,inserted.alert_id,inserted.table_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[callback_alert_id]
		FROM #alert_actions_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN alert_actions_events dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id
		WHERE dst.[alert_actions_events_id] IS NULL;
UPDATE #alert_actions_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid =dst.new_id 
		FROM #alert_actions_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND dst.table_name='alert_actions_events'
		;
print('--==============================END alert_actions_events=============================')
print('--==============================START alert_table_relation=============================')

	if object_id('tempdb..#alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [alert_table_relation_id] int ,[alert_id] int ,[from_table_id] int ,[from_column_id] int ,[to_table_id] int ,[to_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [alert_table_relation_id],[alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where alert_table_relation_id is null;
	update #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set alert_id='FARRMS1_ '+cast(alert_table_relation_id as varchar(30))  where isnull(alert_id,'')='' ;
	update #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set from_table_id='FARRMS2_ '+cast(alert_table_relation_id as varchar(30))  where isnull(from_table_id,'')='' ;
			update #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set to_table_id='FARRMS3_ '+cast(alert_table_relation_id as varchar(30))  where isnull(to_table_id,'')='' ;
			
print('--==============================END alert_table_relation=============================')
	
update #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set from_column_id='FARRMS4_ '+cast(alert_table_relation_id as varchar(30))  where isnull(from_column_id,'')='' ;
update #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set to_column_id='FARRMS5_ '+cast(alert_table_relation_id as varchar(30))  where isnull(to_column_id,'')='' ;

UPDATE atr SET atr.alert_id	= asl.new_recid FROM #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 atr INNER JOIN #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 asl ON asl.old_recid = atr.alert_id		
UPDATE atr SET atr.from_table_id = atd.new_recid FROM #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 atr INNER JOIN #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 atd ON atd.old_recid = atr.from_table_id		
UPDATE atr SET atr.to_table_id = atd.new_recid FROM #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 atr INNER JOIN #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 atd ON atd.old_recid = atr.to_table_id		
UPDATE atr SET atr.from_column_id = atd.new_recid FROM #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 atr INNER JOIN #alert_columns_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 atd ON atd.old_recid = atr.from_column_id		
UPDATE atr SET atr.to_column_id = atd.new_recid FROM #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 atr INNER JOIN #alert_columns_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 atd ON atd.old_recid = atr.to_column_id		

insert into alert_table_relation
		([alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id]
		)
		 OUTPUT 'i','alert_table_relation',inserted.alert_table_relation_id,inserted.alert_id,inserted.from_table_id,inserted.to_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[from_table_id],src.[from_column_id],src.[to_table_id],src.[to_column_id]
		FROM #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN alert_table_relation dst  
		ON src.alert_id=dst.alert_id AND src.from_table_id=dst.from_table_id AND src.to_table_id=dst.to_table_id
		AND src.from_column_id=dst.from_column_id AND src.to_column_id=dst.to_column_id
		WHERE dst.[alert_table_relation_id] IS NULL;
UPDATE #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid = atr.alert_table_relation_id 
		FROM #alert_table_relation_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN alert_table_relation atr ON src.alert_id=atr.alert_id 
		AND src.from_table_id=atr.from_table_id AND src.to_table_id=atr.to_table_id 
		AND src.from_column_id=atr.from_column_id AND src.to_column_id=atr.to_column_id 
		;
print('--==============================END alert_table_relation=============================')		

print('--==============================START module_events=============================')

	if object_id('tempdb..#module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [module_events_id] int ,[modules_id] int ,[event_id] varchar(2000) COLLATE DATABASE_DEFAULT ,[workflow_name] varchar(100) COLLATE DATABASE_DEFAULT ,[workflow_owner] varchar(100) COLLATE DATABASE_DEFAULT ,[rule_table_id] int ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [module_events_id],[modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id],[is_active],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where module_events_id is null;
	update #module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set workflow_name='FARRMS1_ '+cast(module_events_id as varchar(30))  where isnull(workflow_name,'')='' ;
	
print('--==============================END module_events=============================')
	
	UPDATE me SET me.rule_table_id = atd.new_recid FROM #module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 me INNER JOIN #alert_table_definition_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 atd ON atd.old_recid = me.rule_table_id

	UPDATE dbo.module_events SET [modules_id]=src.[modules_id],[event_id]=src.[event_id],[workflow_owner]=src.[workflow_owner],[rule_table_id]=src.[rule_table_id]
			   OUTPUT 'u','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
		FROM #module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN module_events dst  ON src.workflow_name=dst.workflow_name;
	insert into module_events
			([modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id]
			)
			 OUTPUT 'i','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_id],src.[event_id],src.[workflow_name],src.[workflow_owner],src.[rule_table_id]
			FROM #module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN module_events dst  ON src.workflow_name=dst.workflow_name
			WHERE dst.[module_events_id] IS NULL;

			UPDATE #module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid = b.new_id 		
			FROM #module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 a 
			INNER JOIN 
			( SELECT TOP(1) new_id, unique_key1 FROM  #module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src 
			INNER JOIN #old_new_id dst ON src.workflow_name=dst.unique_key1 AND dst.table_name='module_events' ORDER BY new_id DESC
			) b ON a.workflow_name= b.unique_key1 

	

	UPDATE me SET me.modules_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 sdv ON sdv.old_recid = me.modules_id

	UPDATE me SET me.event_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 sdv ON sdv.old_recid = me.event_id
	
print('--==============================START event_trigger=============================')

	if object_id('tempdb..#event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [event_trigger_id] int ,[modules_event_id] int ,[alert_id] int ,[initial_event] char(1) COLLATE DATABASE_DEFAULT ,[manual_step] char(1) COLLATE DATABASE_DEFAULT ,[is_disable] char(1) COLLATE DATABASE_DEFAULT ,[report_paramset_id] varchar(max) COLLATE DATABASE_DEFAULT ,[report_filters] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [event_trigger_id],[modules_event_id],[alert_id],[initial_event],[manual_step],[is_disable],[report_paramset_id],[report_filters],old_recid
	 )
	 VALUES
	 
(1356,1175,1,'n','n','n','',0,1356),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where event_trigger_id is null;
	update #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set modules_event_id='FARRMS1_ '+cast(event_trigger_id as varchar(30))  where isnull(modules_event_id,'')='' ;
	update #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set alert_id='FARRMS2_ '+cast(event_trigger_id as varchar(30))  where isnull(alert_id,'')='' ;
			
print('--==============================END event_trigger=============================')

		
		IF EXISTS (SELECT 1 FROM #module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3)
		BEGIN
			DELETE FROM #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 WHERE modules_event_id NOT IN (
			SELECT mebs.module_events_id FROM #module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 mebs INNER JOIN #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 et 
			ON et.modules_event_id = mebs.module_events_id)
		END
		ELSE
		BEGIN
			DELETE FROM #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 WHERE modules_event_id NOT IN 
			(SELECT meb.module_events_id FROM #module_events_bkup meb INNER JOIN #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 et 
			ON et.modules_event_id = meb.module_events_id)
		END
		
	
	UPDATE et SET et.alert_id = asl.new_recid FROM #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 et INNER JOIN #alert_sql_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 asl ON asl.old_recid = et.alert_id WHERE et.alert_id <> -1
	UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 et INNER JOIN #module_events_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 me ON me.old_recid = et.modules_event_id
	
UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 et INNER JOIN #module_events_bkup me ON me.old_recid = et.modules_event_id

	print('--==============================START event_trigger=============================')

	UPDATE event_trigger SET 
	 [initial_event] = src.[initial_event]
	, [manual_step] = src.[manual_step]
	, [is_disable] = src.[is_disable]
	, [report_paramset_id] = src.[report_paramset_id]
	, [report_filters] = src.[report_filters]
	 OUTPUT 'u','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,src.report_paramset_id  
	 INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src 
	INNER JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id

	insert into event_trigger
			([modules_event_id],[alert_id],[initial_event], [manual_step], [is_disable], [report_paramset_id], [report_filters]
			)
			 OUTPUT 'i','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,inserted.report_paramset_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_event_id],src.[alert_id],src.[initial_event], src.[manual_step], src.[is_disable], src.[report_paramset_id], src.[report_filters]
			FROM #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id
			WHERE dst.[event_trigger_id] IS NULL;
	UPDATE #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid =dst.new_id 
			FROM #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN #old_new_id dst  ON src.modules_event_id=dst.unique_key1 AND src.alert_id=dst.unique_key2 AND dst.table_name='event_trigger'
			AND ISNULL(src.report_paramset_id,-999) = ISNULL(dst.unique_key3,-999);
	print('--==============================END event_trigger=============================')
print('--==============================START workflow_event_message=============================')

	if object_id('tempdb..#workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [event_message_id] int ,[event_trigger_id] int ,[event_message_name] varchar(100) COLLATE DATABASE_DEFAULT ,[message_template_id] int ,[message] varchar(1000) COLLATE DATABASE_DEFAULT ,[mult_approval_required] char(1) COLLATE DATABASE_DEFAULT ,[comment_required] char(1) COLLATE DATABASE_DEFAULT ,[approval_action_required] char(1) COLLATE DATABASE_DEFAULT ,[self_notify] char(1) COLLATE DATABASE_DEFAULT ,[notify_trader] char(1) COLLATE DATABASE_DEFAULT ,[next_module_events_id] int ,[minimum_approval_required] int ,[optional_event_msg] char(1) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[automatic_proceed] char(1) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [event_message_id],[event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type],old_recid
	 )
	 VALUES
	 
(1254,1356,'Credit Limit Violated',0,'Credit Limit Violated for :  <#ALERT_REPORT>','n','n','n','y','n',NULL,NULL,'n',NULL,'n','757',1254),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where event_message_id is null;
	update #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set event_trigger_id='FARRMS1_ '+cast(event_message_id as varchar(30))  where isnull(event_trigger_id,'')='' ;
	update #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set event_message_name='FARRMS2_ '+cast(event_message_id as varchar(30))  where isnull(event_message_name,'')='' ;
			
print('--==============================END workflow_event_message=============================')

		IF EXISTS (SELECT 1 FROM #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3)
		BEGIN	
			DELETE FROM #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wem INNER JOIN #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 et ON et.old_recid = wem.event_trigger_id)
		END
		

	UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wem INNER JOIN #event_trigger_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 et ON et.old_recid = wem.event_trigger_id

		UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wem INNER JOIN #event_trigger_bkup et ON et.old_recid = wem.event_trigger_id
		UPDATE wem SET wem.next_module_events_id = meb.new_recid FROM #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wem  INNER JOIN #module_events_bkup meb ON meb.old_recid = wem.next_module_events_id
print('--==============================START workflow_event_message=============================')
UPDATE dbo.workflow_event_message SET [message_template_id]=src.[message_template_id],[message]=src.[message],[mult_approval_required]=src.[mult_approval_required],[comment_required]=src.[comment_required],[approval_action_required]=src.[approval_action_required],[self_notify]=src.[self_notify],[notify_trader]=src.[notify_trader],[next_module_events_id]=src.[next_module_events_id],[minimum_approval_required]=src.[minimum_approval_required],[optional_event_msg]=src.[optional_event_msg],[counterparty_contact_type]=src.[counterparty_contact_type],[automatic_proceed]=src.[automatic_proceed],[notification_type]=src.[notification_type]
		   OUTPUT 'u','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name;
insert into workflow_event_message
		([event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type]
		)
		 OUTPUT 'i','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_trigger_id],src.[event_message_name],src.[message_template_id],src.[message],src.[mult_approval_required],src.[comment_required],src.[approval_action_required],src.[self_notify],src.[notify_trader],src.[next_module_events_id],src.[minimum_approval_required],src.[optional_event_msg],src.[counterparty_contact_type],src.[automatic_proceed],src.[notification_type]
		FROM #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name
		WHERE dst.[event_message_id] IS NULL;
UPDATE #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid =dst.new_id 
		FROM #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN #old_new_id dst  ON src.event_trigger_id=dst.unique_key1 AND src.event_message_name=dst.unique_key2 AND dst.table_name='workflow_event_message'
		;
print('--==============================END workflow_event_message=============================')
	
		INSERT INTO #workflow_event_message_bkup (event_message_id, event_trigger_id, event_message_name, message_template_id, message, mult_approval_required, comment_required, approval_action_required, self_notify, notify_trader, counterparty_contact_type, next_module_events_id, minimum_approval_required, optional_event_msg, automatic_proceed, notification_type, new_recid, old_recid)
		SELECT wem.event_message_id, wem.event_trigger_id, wem.event_message_name, wem.message_template_id, wem.message, wem.mult_approval_required, wem.comment_required, wem.approval_action_required, wem.self_notify, wem.notify_trader, wem.counterparty_contact_type, wem.next_module_events_id, wem.minimum_approval_required, wem.optional_event_msg, wem.automatic_proceed, wem.notification_type, wem.new_recid, wem.old_recid FROM #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wem
		LEFT JOIN #workflow_event_message_bkup wemb ON wemb.old_recid = wem.old_recid 
		WHERE wemb.old_recid IS NULL
print('--==============================START application_security_role=============================')

	if object_id('tempdb..#application_security_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #application_security_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [role_id] int ,[role_name] varchar(50) COLLATE DATABASE_DEFAULT ,[role_description] varchar(250) COLLATE DATABASE_DEFAULT ,[role_type_value_id] int ,[process_map_file_name] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #application_security_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #application_security_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [role_id],[role_name],[role_description],[role_type_value_id],[process_map_file_name],old_recid
	 )
	 VALUES
	 
(103,'Administrator','Application Admin',7,NULL,103),
(1239,'Credit Analyst','Credit Analyst',4,NULL,1239),
(NULL,NULL,NULL,NULL,NULL,null);
	delete #application_security_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where role_id is null;
	update #application_security_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set role_name='FARRMS1_ '+cast(role_id as varchar(30))  where isnull(role_name,'')='' ;
	
UPDATE dbo.application_security_role SET [role_description]=src.[role_description],[role_type_value_id]=src.[role_type_value_id],[process_map_file_name]=src.[process_map_file_name]
		   OUTPUT 'u','application_security_role',inserted.role_id,inserted.role_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #application_security_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN application_security_role dst  ON src.role_name=dst.role_name;
insert into application_security_role
		([role_name],[role_description],[role_type_value_id],[process_map_file_name]
		)
		 OUTPUT 'i','application_security_role',inserted.role_id,inserted.role_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[role_name],src.[role_description],src.[role_type_value_id],src.[process_map_file_name]
		FROM #application_security_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN application_security_role dst  ON src.role_name=dst.role_name
		WHERE dst.[role_id] IS NULL;
UPDATE #application_security_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid =dst.new_id 
		FROM #application_security_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN #old_new_id dst  ON src.role_name=dst.unique_key1 AND dst.table_name='application_security_role'
		;
print('--==============================END application_security_role=============================')
print('--==============================START workflow_event_user_role=============================')

	if object_id('tempdb..#workflow_event_user_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #workflow_event_user_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [event_user_role_id] int ,[event_message_id] int ,[user_login_id] varchar(50) COLLATE DATABASE_DEFAULT ,[role_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_user_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #workflow_event_user_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [event_user_role_id],[event_message_id],[user_login_id],[role_id],old_recid
	 )
	 VALUES
	 
(7881,1254,'bhshrestha',NULL,7881),
(7882,1254,'dkathet',NULL,7882),
(7883,1254,'farrms_admin',NULL,7883),
(7884,1254,'nradhikari',NULL,7884),
(7885,1254,NULL,1239,7885),
(7886,1254,NULL,103,7886),
(NULL,NULL,NULL,NULL,null);
	delete #workflow_event_user_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where event_user_role_id is null;
	update #workflow_event_user_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set event_user_role_id='FARRMS1_ '+cast(event_user_role_id as varchar(30))  where isnull(event_user_role_id,'')='' ;
	
print('--==============================END workflow_event_user_role=============================')
	
		DELETE FROM #workflow_event_user_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wem INNER JOIN #workflow_event_user_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 weur ON weur.event_message_id = wem.event_message_id	)
		
	
	UPDATE weur SET weur.role_id = asr.new_recid FROM #workflow_event_user_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 weur INNER JOIN #application_security_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 asr ON asr.old_recid = weur.role_id
	UPDATE weur SET weur.event_message_id = wem.new_recid FROM #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wem INNER JOIN #workflow_event_user_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 weur ON weur.event_message_id = wem.old_recid
	
print('--==============================START workflow_event_user_role=============================')
UPDATE dbo.workflow_event_user_role SET [event_message_id]=src.[event_message_id],[user_login_id]=src.[user_login_id],[role_id]=src.[role_id]
		   OUTPUT 'u','workflow_event_user_role',inserted.event_user_role_id,inserted.event_user_role_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_user_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN workflow_event_user_role dst  ON src.event_user_role_id=dst.event_user_role_id;
insert into workflow_event_user_role
		([event_message_id],[user_login_id],[role_id]
		)
		 OUTPUT 'i','workflow_event_user_role',inserted.event_user_role_id,inserted.event_user_role_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[user_login_id],src.[role_id]
		FROM #workflow_event_user_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN workflow_event_user_role dst  ON src.event_user_role_id=dst.event_user_role_id
		WHERE dst.[event_user_role_id] IS NULL;
UPDATE #workflow_event_user_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid =dst.new_id 
		FROM #workflow_event_user_role_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN #old_new_id dst  ON src.event_user_role_id=dst.unique_key1 AND dst.table_name='workflow_event_user_role'
		;
print('--==============================END workflow_event_user_role=============================')
print('--==============================START workflow_event_message_documents=============================')

	if object_id('tempdb..#workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [message_document_id] int ,[event_message_id] int ,[document_template_id] int ,[effective_date] datetime ,[document_category] int ,[document_template] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [message_document_id],[event_message_id],[document_template_id],[effective_date],[document_category],[document_template],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where message_document_id is null;
	update #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set message_document_id='FARRMS1_ '+cast(message_document_id as varchar(30))  where isnull(message_document_id,'')='' ;
	
print('--==============================END workflow_event_message_documents=============================')

		DELETE FROM #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wemd ON wem.event_message_id = wemd.event_message_id)

	UPDATE wemd SET wemd.event_message_id = wem.new_recid FROM #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wem INNER JOIN #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wemd ON wemd.event_message_id = wem.old_recid
	UPDATE wemd SET wemd.document_template_id = sdv.new_recid FROM #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wemd INNER JOIN #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 sdv ON sdv.old_recid = wemd.document_template_id
	UPDATE wemd SET wemd.document_category = sdv.new_recid FROM #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wemd INNER JOIN #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 sdv ON sdv.old_recid = wemd.document_category
	
print('--==============================START workflow_event_message_documents=============================')
UPDATE dbo.workflow_event_message_documents SET [event_message_id]=src.[event_message_id],[document_template_id]=src.[document_template_id],[effective_date]=src.[effective_date],[document_category]=src.[document_category],[document_template]=src.[document_template]
		   OUTPUT 'u','workflow_event_message_documents',inserted.message_document_id,inserted.message_document_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN workflow_event_message_documents dst  ON src.message_document_id=dst.message_document_id;
insert into workflow_event_message_documents
		([event_message_id],[document_template_id],[effective_date],[document_category],[document_template]
		)
		 OUTPUT 'i','workflow_event_message_documents',inserted.message_document_id,inserted.message_document_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[document_template_id],src.[effective_date],src.[document_category],src.[document_template]
		FROM #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN workflow_event_message_documents dst  ON src.message_document_id=dst.message_document_id
		WHERE dst.[message_document_id] IS NULL;
UPDATE #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid =dst.new_id 
		FROM #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN #old_new_id dst  ON src.message_document_id=dst.unique_key1 AND dst.table_name='workflow_event_message_documents'
		;
print('--==============================END workflow_event_message_documents=============================')

	UPDATE w2 SET w2.new_recid = w1.message_document_id
	FROM workflow_event_message_documents w1 
	INNER JOIN #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 w2 ON w1.event_message_id = w2.event_message_id
		AND ISNULL(w1.document_template_id, '-1') = ISNULL(w2.document_template_id, '-1')
		AND ISNULL(w1.document_category, '-1') = ISNULL(w2.document_category, '-1')
print('--==============================START workflow_event_message_details=============================')

	if object_id('tempdb..#workflow_event_message_details_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #workflow_event_message_details_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [message_detail_id] int ,[event_message_document_id] int ,[message_template_id] int ,[message] varchar(500) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[delivery_method] int ,[internal_contact_type] int ,[email] varchar(300) COLLATE DATABASE_DEFAULT ,[email_cc] varchar(300) COLLATE DATABASE_DEFAULT ,[email_bcc] varchar(300) COLLATE DATABASE_DEFAULT ,[as_defined_in_contact] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_details_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #workflow_event_message_details_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [message_detail_id],[event_message_document_id],[message_template_id],[message],[counterparty_contact_type],[delivery_method],[internal_contact_type],[email],[email_cc],[email_bcc],[as_defined_in_contact],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_details_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where message_detail_id is null;
	update #workflow_event_message_details_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set message_detail_id='FARRMS1_ '+cast(message_detail_id as varchar(30))  where isnull(message_detail_id,'')='' ;
	
print('--==============================END workflow_event_message_details=============================')

	DELETE FROM #workflow_event_message_details_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 WHERE message_detail_id NOT IN (
		SELECT wemd.message_detail_id from #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wemdd 
		INNER JOIN #workflow_event_message_details_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wemd ON wemd.event_message_document_id = wemdd.message_document_id)

	UPDATE wemd SET wemd.event_message_document_id = wem.new_recid FROM #workflow_event_message_documents_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wem INNER JOIN #workflow_event_message_details_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wemd ON wemd.event_message_document_id = wem.old_recid
	UPDATE wemd SET wemd.counterparty_contact_type = sdv.new_recid FROM #workflow_event_message_details_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wemd INNER JOIN #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3  sdv ON sdv.old_recid = wemd.counterparty_contact_type
	UPDATE wemd SET wemd.delivery_method = sdv.new_recid FROM #workflow_event_message_details_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wemd INNER JOIN #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3  sdv ON sdv.old_recid = wemd.delivery_method
	UPDATE wemd SET wemd.internal_contact_type = sdv.new_recid FROM #workflow_event_message_details_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wemd INNER JOIN #static_data_value_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3  sdv ON sdv.old_recid = wemd.internal_contact_type
	
print('--==============================START workflow_event_message_details=============================')
UPDATE dbo.workflow_event_message_details SET [event_message_document_id]=src.[event_message_document_id],[message_template_id]=src.[message_template_id],[message]=src.[message],[counterparty_contact_type]=src.[counterparty_contact_type],[delivery_method]=src.[delivery_method],[internal_contact_type]=src.[internal_contact_type],[email]=src.[email],[email_cc]=src.[email_cc],[email_bcc]=src.[email_bcc],[as_defined_in_contact]=src.[as_defined_in_contact]
		   OUTPUT 'u','workflow_event_message_details',inserted.message_detail_id,inserted.message_detail_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_details_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN workflow_event_message_details dst  ON src.message_detail_id=dst.message_detail_id;
insert into workflow_event_message_details
		([event_message_document_id],[message_template_id],[message],[counterparty_contact_type],[delivery_method],[internal_contact_type],[email],[email_cc],[email_bcc],[as_defined_in_contact]
		)
		 OUTPUT 'i','workflow_event_message_details',inserted.message_detail_id,inserted.message_detail_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_document_id],src.[message_template_id],src.[message],src.[counterparty_contact_type],src.[delivery_method],src.[internal_contact_type],src.[email],src.[email_cc],src.[email_bcc],src.[as_defined_in_contact]
		FROM #workflow_event_message_details_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN workflow_event_message_details dst  ON src.message_detail_id=dst.message_detail_id
		WHERE dst.[message_detail_id] IS NULL;
UPDATE #workflow_event_message_details_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid =dst.new_id 
		FROM #workflow_event_message_details_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN #old_new_id dst  ON src.message_detail_id=dst.unique_key1 AND dst.table_name='workflow_event_message_details'
		;
print('--==============================END workflow_event_message_details=============================')
print('--==============================START alert_reports=============================')

	if object_id('tempdb..#alert_reports_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #alert_reports_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [alert_reports_id] int ,[event_message_id] int ,[report_writer] varchar(1) COLLATE DATABASE_DEFAULT ,[paramset_hash] varchar(8000) COLLATE DATABASE_DEFAULT ,[report_param] varchar(1000) COLLATE DATABASE_DEFAULT ,[report_desc] varchar(500) COLLATE DATABASE_DEFAULT ,[table_prefix] varchar(50) COLLATE DATABASE_DEFAULT ,[table_postfix] varchar(50) COLLATE DATABASE_DEFAULT ,[report_where_clause] varchar(max) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_reports_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #alert_reports_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [alert_reports_id],[event_message_id],[report_writer],[paramset_hash],[report_param],[report_desc],[table_prefix],[table_postfix],[report_where_clause],old_recid
	 )
	 VALUES
	 
(45,1254,'n','',NULL,'Credit Limit','credit_limit_violation_','_clv','',45),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_reports_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where alert_reports_id is null;
	update #alert_reports_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set event_message_id='FARRMS1_ '+cast(alert_reports_id as varchar(30))  where isnull(event_message_id,'')='' ;
	update #alert_reports_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set report_desc='FARRMS2_ '+cast(alert_reports_id as varchar(30))  where isnull(report_desc,'')='' ;
			update #alert_reports_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set table_prefix='FARRMS3_ '+cast(alert_reports_id as varchar(30))  where isnull(table_prefix,'')='' ;
			
print('--==============================END alert_reports=============================')

		DELETE FROM #alert_reports_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_reports_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 ar ON wem.event_message_id = ar.event_message_id)

	UPDATE ar SET ar.event_message_id = wem.new_recid FROM #workflow_event_message_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 wem INNER JOIN #alert_reports_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 ar ON ar.event_message_id = wem.old_recid
	
print('--==============================START alert_reports=============================')
UPDATE dbo.alert_reports SET [report_writer]=src.[report_writer],[paramset_hash]=src.[paramset_hash],[report_param]=src.[report_param],[table_postfix]=src.[table_postfix],[report_where_clause]=src.[report_where_clause]
		   OUTPUT 'u','alert_reports',inserted.alert_reports_id,inserted.event_message_id,inserted.report_desc,inserted.table_prefix INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_reports_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN alert_reports dst  ON src.event_message_id=dst.event_message_id AND src.report_desc=dst.report_desc AND src.table_prefix=dst.table_prefix;
insert into alert_reports
		([event_message_id],[report_writer],[paramset_hash],[report_param],[report_desc],[table_prefix],[table_postfix],[report_where_clause]
		)
		 OUTPUT 'i','alert_reports',inserted.alert_reports_id,inserted.event_message_id,inserted.report_desc,inserted.table_prefix INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[report_writer],src.[paramset_hash],src.[report_param],src.[report_desc],src.[table_prefix],src.[table_postfix],src.[report_where_clause]
		FROM #alert_reports_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN alert_reports dst  ON src.event_message_id=dst.event_message_id AND src.report_desc=dst.report_desc AND src.table_prefix=dst.table_prefix
		WHERE dst.[alert_reports_id] IS NULL;
UPDATE #alert_reports_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid =dst.new_id 
		FROM #alert_reports_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN #old_new_id dst  ON src.event_message_id=dst.unique_key1 AND src.report_desc=dst.unique_key2 AND src.table_prefix=dst.unique_key3 AND dst.table_name='alert_reports'
		;
print('--==============================END alert_reports=============================')
print('--==============================START alert_report_params=============================')

	if object_id('tempdb..#alert_report_params_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3') is null 
	
	CREATE TABLE #alert_report_params_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3
	 (
	 [alert_report_params_id] int ,[event_message_id] int ,[alert_report_id] int ,[main_table_id] int ,[parameter_name] nvarchar(200) COLLATE DATABASE_DEFAULT ,[parameter_value] nvarchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_report_params_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3;
INSERT INTO #alert_report_params_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3(
	 [alert_report_params_id],[event_message_id],[alert_report_id],[main_table_id],[parameter_name],[parameter_value],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_report_params_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 where alert_report_params_id is null;
	update #alert_report_params_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 set alert_report_id='FARRMS1_ '+cast(alert_report_params_id as varchar(30))  where isnull(alert_report_id,'')='' ;
	
print('--==============================END alert_report_params=============================')

		DELETE FROM #alert_report_params_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_report_params_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 ar ON wem.event_message_id = ar.event_message_id)

	UPDATE arp SET arp.alert_report_id = ar.alert_reports_id FROM #alert_report_params_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 arp INNER JOIN #alert_reports_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 ar ON ar.old_recid = arp.alert_report_id
	UPDATE arp SET arp.main_table_id = art.alert_rule_table_id FROM #alert_report_params_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 arp INNER JOIN #alert_rule_table_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 art ON art.old_recid = arp.main_table_id
	
print('--==============================START alert_report_params=============================')
UPDATE dbo.alert_report_params SET [event_message_id]=src.[event_message_id],[main_table_id]=src.[main_table_id],[parameter_name]=src.[parameter_name],[parameter_value]=src.[parameter_value]
		   OUTPUT 'u','alert_report_params',inserted.alert_report_params_id,inserted.alert_report_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_report_params_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN alert_report_params dst  ON src.alert_report_id=dst.alert_report_id;
insert into alert_report_params
		([event_message_id],[alert_report_id],[main_table_id],[parameter_name],[parameter_value]
		)
		 OUTPUT 'i','alert_report_params',inserted.alert_report_params_id,inserted.alert_report_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[alert_report_id],src.[main_table_id],src.[parameter_name],src.[parameter_value]
		FROM #alert_report_params_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src LEFT JOIN alert_report_params dst  ON src.alert_report_id=dst.alert_report_id
		WHERE dst.[alert_report_params_id] IS NULL;
UPDATE #alert_report_params_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 SET new_recid =dst.new_id 
		FROM #alert_report_params_CD7E8F21_3D2B_47DA_AECB_7FEAA7FEFAD3 src INNER JOIN #old_new_id dst  ON src.alert_report_id=dst.unique_key1 AND dst.table_name='alert_report_params'
		;
print('--==============================END alert_report_params=============================')
print('--==============================START static_data_value=============================')

	if object_id('tempdb..#static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [value_id] int ,[type_id] int ,[code] varchar(500) COLLATE DATABASE_DEFAULT ,[description] varchar(500) COLLATE DATABASE_DEFAULT ,[entity_id] int ,[xref_value_id] varchar(50) COLLATE DATABASE_DEFAULT ,[xref_value] varchar(250) COLLATE DATABASE_DEFAULT ,[category_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [value_id],[type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id],old_recid
	 )
	 VALUES
	 
(757,750,'Alert','Alert with Beep Sound',NULL,NULL,NULL,NULL,757),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where value_id is null;
	update #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set code='FARRMS1_ '+cast(value_id as varchar(30))  where isnull(code,'')='' ;
	update #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set type_id='FARRMS2_ '+cast(value_id as varchar(30))  where isnull(type_id,'')='' ;
			
UPDATE dbo.static_data_value SET [description]=src.[description],[entity_id]=src.[entity_id],[xref_value_id]=src.[xref_value_id],[xref_value]=src.[xref_value],[category_id]=src.[category_id]
		   OUTPUT 'u','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id;
insert into static_data_value
		([type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id]
		)
		 OUTPUT 'i','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[type_id],src.[code],src.[description],src.[entity_id],src.[xref_value_id],src.[xref_value],src.[category_id]
		FROM #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id
		WHERE dst.[value_id] IS NULL;
UPDATE #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid =dst.new_id 
		FROM #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN #old_new_id dst  ON src.code=dst.unique_key1 AND src.type_id=dst.unique_key2 AND dst.table_name='static_data_value'
		;
print('--==============================END static_data_value=============================')
print('--==============================START alert_sql=============================')

	if object_id('tempdb..#alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [alert_sql_id] int ,[workflow_only] varchar(1) COLLATE DATABASE_DEFAULT ,[message] varchar(500) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,[sql_statement] varchar(max) COLLATE DATABASE_DEFAULT ,[alert_sql_name] varchar(100) COLLATE DATABASE_DEFAULT ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,[alert_type] char(1) COLLATE DATABASE_DEFAULT ,[rule_category] int ,[system_rule] char(1) COLLATE DATABASE_DEFAULT ,[alert_category] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [alert_sql_id],[workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category],old_recid
	 )
	 VALUES
	 
(6,'n','Reminder: Counterparty Credit File Review Due','757','SELECT 
sc.counterparty_id [Counterparty Name] ,
 CONVERT(VARCHAR(12), cci.Last_review_date, 107) [Last Review Date],
CONVERT(VARCHAR(12), cci.Next_review_date, 107) [Next Review Date],
DATEDIFF(DAY,CURRENT_TIMESTAMP,cci.Next_review_date) [Days Remaining for Review],
''Please review credit file.'' [Recommendation]
INTO  adiha_process.dbo.credit_file_process_id_cf
FROM counterparty_credit_info cci 
INNER JOIN source_counterparty sc ON sc.source_counterparty_id = cci.counterparty_id
WHERE ABS(DATEDIFF(DAY,cci.Next_review_date,CURRENT_TIMESTAMP)) < = 5','Credit File Review Reminder Alert','y','s',-1,'n',NULL,6),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where alert_sql_id is null;
	update #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set alert_sql_name='FARRMS1_ '+cast(alert_sql_id as varchar(30))  where isnull(alert_sql_name,'')='' ;
	
print('--==============================END alert_sql=============================')

UPDATE dbo.alert_sql SET [workflow_only]=src.[workflow_only],[message]=src.[message],[notification_type]=src.[notification_type],[sql_statement]=src.[sql_statement],[is_active]=src.[is_active],[alert_type]=src.[alert_type],[rule_category]=src.[rule_category],[system_rule]=src.[system_rule],[alert_category]=src.[alert_category]
		   OUTPUT 'u','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name;

IF EXISTS(SELECT 1 FROM #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 WHERE alert_sql_id < 0)
BEGIN
	SET IDENTITY_INSERT alert_sql ON
	INSERT INTO alert_sql
	([alert_sql_id], [workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category]
	)
	OUTPUT 'i','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	SELECT 
	src.alert_sql_id, src.[workflow_only],src.[message],src.[notification_type],src.[sql_statement],src.[alert_sql_name],src.[is_active],src.[alert_type],src.[rule_category],src.[system_rule],src.[alert_category]
	FROM #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
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
	FROM #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
	WHERE dst.[alert_sql_id] IS NULL;
END

UPDATE #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid = dst.new_id , alert_sql_id =  dst.new_id
FROM #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN #old_new_id dst ON src.alert_sql_name = dst.unique_key1 AND dst.table_name = 'alert_sql'

UPDATE asl SET asl.notification_type = sdv.new_recid 
FROM alert_sql asl INNER JOIN #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 sdv ON sdv.old_recid = asl.notification_type	

UPDATE asl SET asl.rule_category = sdv.new_recid
FROM alert_sql asl INNER JOIN #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 sdv ON sdv.old_recid = asl.rule_category	


	INSERT INTO #alert_sql_bkup (alert_sql_id, workflow_only, message, notification_type, sql_statement, alert_sql_name, is_active, alert_type, rule_category, system_rule, alert_category, new_recid, old_recid)
	SELECT asl.alert_sql_id, asl.workflow_only, asl.message, asl.notification_type, asl.sql_statement, asl.alert_sql_name, asl.is_active, asl.alert_type, asl.rule_category, asl.system_rule, asl.alert_category, asl.new_recid, asl.old_recid FROM #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 asl
	LEFT JOIN #alert_sql_bkup aslb ON aslb.old_recid = asl.old_recid
	WHERE aslb.old_recid IS NULL
print('--==============================START alert_table_definition=============================')

	if object_id('tempdb..#alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [alert_table_definition_id] int ,[logical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[physical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[data_source_id] int ,[is_action_view] char(1) COLLATE DATABASE_DEFAULT ,[primary_column] varchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [alert_table_definition_id],[logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column],old_recid
	 )
	 VALUES
	 
(14,'Counterparty Credit Info Audit','vwCounterPartyCreditInfoAudit',NULL,NULL,NULL,14),
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where alert_table_definition_id is null;
	update #alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set logical_table_name='FARRMS1_ '+cast(alert_table_definition_id as varchar(30))  where isnull(logical_table_name,'')='' ;
	
UPDATE dbo.alert_table_definition SET [physical_table_name]=src.[physical_table_name],[data_source_id]=src.[data_source_id],[is_action_view]=src.[is_action_view],[primary_column]=src.[primary_column]
		   OUTPUT 'u','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name;
insert into alert_table_definition
		([logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column]
		)
		 OUTPUT 'i','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[logical_table_name],src.[physical_table_name],src.[data_source_id],src.[is_action_view],src.[primary_column]
		FROM #alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name
		WHERE dst.[alert_table_definition_id] IS NULL;
UPDATE #alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid =dst.new_id 
		FROM #alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN #old_new_id dst  ON src.logical_table_name=dst.unique_key1 AND dst.table_name='alert_table_definition'
		;
print('--==============================END alert_table_definition=============================')

UPDATE #alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET alert_table_definition_id = new_recid

print('--==============================START alert_columns_definition=============================')

	if object_id('tempdb..#alert_columns_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #alert_columns_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [alert_columns_definition_id] int ,[alert_table_id] int ,[column_name] varchar(600) COLLATE DATABASE_DEFAULT ,[is_primary] char(1) COLLATE DATABASE_DEFAULT ,[static_data_type_id] int ,[column_alias] varchar(200) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_columns_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #alert_columns_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [alert_columns_definition_id],[alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias],old_recid
	 )
	 VALUES
	 
(479,14,'account_status_compare','n',NULL,NULL,479),
(480,14,'counterparty_id','y',NULL,NULL,480),
(481,14,'credit_limit_compare','n',NULL,NULL,481),
(482,14,'debt_rating_compare','n',NULL,NULL,482),
(483,14,'debt_rating2_compare','n',NULL,NULL,483),
(484,14,'debt_rating3_compare','n',NULL,NULL,484),
(485,14,'debt_rating4_compare','n',NULL,NULL,485),
(486,14,'debt_rating5_compare','n',NULL,NULL,486),
(487,14,'previous_account_status','n',NULL,NULL,487),
(488,14,'previous_credit_limit','n',NULL,NULL,488),
(489,14,'previous_Debt_rating','n',NULL,NULL,489),
(490,14,'previous_Debt_Rating2','n',NULL,NULL,490),
(491,14,'previous_Debt_Rating3','n',NULL,NULL,491),
(492,14,'previous_Debt_Rating4','n',NULL,NULL,492),
(493,14,'previous_Debt_Rating5','n',NULL,NULL,493),
(962,14,'previous_risk_rating','n',NULL,'Previous Risk Rating',962),
(961,14,'risk_rating_compare','n',NULL,'Risk Rating Compare',961),
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_columns_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where alert_columns_definition_id is null;
	update #alert_columns_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set column_name='FARRMS1_ '+cast(alert_columns_definition_id as varchar(30))  where isnull(column_name,'')='' ;
	
print('--==============================END alert_columns_definition=============================')

UPDATE acd SET acd.alert_table_id = atd.new_recid
FROM #alert_columns_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 acd INNER JOIN #alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 atd ON atd.old_recid = acd.alert_table_id

print('--==============================START alert_columns_definition=============================')
UPDATE dbo.alert_columns_definition SET [alert_table_id]=dst.[alert_table_definition_id],[is_primary]=src_c.[is_primary],[static_data_type_id]=src_c.[static_data_type_id],[column_alias]=src_c.[column_alias]
		   OUTPUT 'u','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src_c ON src_c.alert_table_id=src.alert_table_definition_id
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name;
insert into alert_columns_definition
		([alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias]
		)
		 OUTPUT 'i','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[alert_table_id],src_c.[column_name],src_c.[is_primary],src_c.[static_data_type_id],src_c.[column_alias]
		FROM #alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name 
			INNER JOIN #alert_columns_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			LEFT JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name
		WHERE dst_c.[alert_table_id] IS NULL;
UPDATE #alert_columns_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid =dst_c.[alert_columns_definition_id] 
			FROM #alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id
			 AND src_c.column_name=dst_c.column_name;
print('--==============================END alert_columns_definition=============================')

DELETE FROM alert_table_relation WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1)
DELETE FROM alert_actions_events WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1)
DELETE FROM alert_actions WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1)
DELETE FROM alert_table_where_clause WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1)
DELETE from alert_conditions WHERE rules_id IN (SELECT alert_sql_id FROM #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1)
DELETE from alert_rule_table where alert_id IN (SELECT alert_sql_id FROM #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1)
print('--==============================START alert_rule_table=============================')

	if object_id('tempdb..#alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [alert_rule_table_id] int ,[alert_id] int ,[table_id] int ,[root_table_id] int ,[table_alias] varchar(50) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [alert_rule_table_id],[alert_id],[table_id],[root_table_id],[table_alias],old_recid
	 )
	 VALUES
	 
(260,6,14,NULL,'ccia',260),
(NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where alert_rule_table_id is null;
	update #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set alert_rule_table_id='FARRMS1_ '+cast(alert_rule_table_id as varchar(30))  where isnull(alert_rule_table_id,'')='' ;
	
print('--==============================END alert_rule_table=============================')

UPDATE art SET art.alert_id = asl.new_recid
FROM #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 art INNER JOIN #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 asl ON asl.old_recid = art.alert_id

UPDATE art SET art.table_id = asd.new_recid
FROM #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 art INNER JOIN #alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1  asd ON asd.old_recid = art.table_id

UPDATE dbo.alert_rule_table SET [table_alias]=src.[table_alias]
		   OUTPUT 'u','alert_rule_table',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
insert into alert_rule_table
		([alert_id],[table_id],[root_table_id],[table_alias]
		)
		 OUTPUT 'i','alert_rule_table',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[root_table_id],src.[table_alias]
		FROM #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
		WHERE dst.[alert_rule_table_id] IS NULL;
UPDATE #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid =dst.new_id 
		FROM #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND ISNULL(src.root_table_id, -1)=ISNULL(dst.unique_key3, -1) AND dst.table_name='alert_rule_table'
		;
print('--==============================END alert_rule_table=============================')
	-- need to verify root_table_id
UPDATE art SET art.root_table_id = art2.new_recid FROM #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 art INNER JOIN #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 art2 ON art2.old_recid = art.root_table_id  
UPDATE art SET art.root_table_id = arrt.root_table_id FROM alert_rule_table art INNER JOIN #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 arrt ON arrt.new_recid = art.alert_rule_table_id 

print('--==============================START alert_conditions=============================')

	if object_id('tempdb..#alert_conditions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #alert_conditions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [alert_conditions_id] int ,[rules_id] int ,[alert_conditions_name] varchar(100) COLLATE DATABASE_DEFAULT ,[alert_conditions_description] varchar(500) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_conditions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #alert_conditions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [alert_conditions_id],[rules_id],[alert_conditions_name],[alert_conditions_description],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,null);
	delete #alert_conditions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where alert_conditions_id is null;
	update #alert_conditions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set alert_conditions_name='FARRMS1_ '+cast(alert_conditions_id as varchar(30))  where isnull(alert_conditions_name,'')='' ;
	
print('--==============================END alert_conditions=============================')

UPDATE ac SET rules_id = asl.new_recid	
FROM #alert_conditions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 ac INNER JOIN #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 asl ON asl.old_recid = ac.rules_id
print('--==============================START alert_conditions=============================')
UPDATE dbo.alert_conditions SET [rules_id]=dst.[alert_sql_id],[alert_conditions_description]=src_c.[alert_conditions_description]
		   OUTPUT 'u','alert_conditions',inserted.alert_conditions_id,inserted.alert_conditions_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
			INNER JOIN #alert_conditions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src_c ON src_c.rules_id=src.alert_sql_id
			INNER JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id AND src_c.alert_conditions_name=dst_c.alert_conditions_name;
insert into alert_conditions
		([rules_id],[alert_conditions_name],[alert_conditions_description]
		)
		 OUTPUT 'i','alert_conditions',inserted.alert_conditions_id,inserted.alert_conditions_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[rules_id],src_c.[alert_conditions_name],src_c.[alert_conditions_description]
		FROM #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name 
			INNER JOIN #alert_conditions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src_c ON src_c.rules_id=src.alert_sql_id	
			LEFT JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id AND src_c.alert_conditions_name=dst_c.alert_conditions_name
		WHERE dst_c.[rules_id] IS NULL;
UPDATE #alert_conditions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid =dst_c.[alert_conditions_id] 
			FROM #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
			INNER JOIN #alert_conditions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src_c ON src_c.rules_id=src.alert_sql_id	
			INNER JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id
			 AND src_c.alert_conditions_name=dst_c.alert_conditions_name;
print('--==============================END alert_conditions=============================')

UPDATE #alert_conditions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET alert_conditions_id = new_recid
print('--==============================START alert_table_where_clause=============================')

	if object_id('tempdb..#alert_table_where_clause_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #alert_table_where_clause_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [alert_table_where_clause_id] int ,[alert_id] int ,[clause_type] int ,[column_id] int ,[operator_id] int ,[column_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[second_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[table_id] int ,[column_function] varchar(1000) COLLATE DATABASE_DEFAULT ,[condition_id] int ,[sequence_no] int ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_where_clause_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #alert_table_where_clause_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [alert_table_where_clause_id],[alert_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[condition_id],[sequence_no],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_where_clause_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where alert_table_where_clause_id is null;
	update #alert_table_where_clause_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set alert_table_where_clause_id='FARRMS1_ '+cast(alert_table_where_clause_id as varchar(30))  where isnull(alert_table_where_clause_id,'')='' ;
	
print('--==============================END alert_table_where_clause=============================')

UPDATE atwc SET atwc.alert_id = asl.new_recid FROM #alert_table_where_clause_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 atwc INNER JOIN #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 asl ON asl.old_recid = atwc.alert_id
UPDATE atwc SET atwc.column_id = acd.new_recid FROM #alert_table_where_clause_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 atwc INNER JOIN #alert_columns_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1  acd ON acd.old_recid = atwc.column_id
UPDATE atwc SET atwc.table_id = art.new_recid FROM #alert_table_where_clause_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 atwc INNER JOIN #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 art ON art.old_recid = atwc.table_id
UPDATE atwc SET atwc.condition_id = ac.new_recid FROM #alert_table_where_clause_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 atwc INNER JOIN #alert_conditions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 ac ON ac.old_recid = atwc.condition_id

print('--==============================START alert_table_where_clause=============================')
UPDATE dbo.alert_table_where_clause SET [alert_id]=src.[alert_id],[clause_type]=src.[clause_type],[column_id]=src.[column_id],[operator_id]=src.[operator_id],[column_value]=src.[column_value],[second_value]=src.[second_value],[table_id]=src.[table_id],[column_function]=src.[column_function],[condition_id]=src.[condition_id],[sequence_no]=src.[sequence_no],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','alert_table_where_clause',inserted.alert_table_where_clause_id,inserted.alert_table_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_where_clause_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN alert_table_where_clause dst  ON src.alert_table_where_clause_id=dst.alert_table_where_clause_id;
insert into alert_table_where_clause
		([alert_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[condition_id],[sequence_no],[data_source_column_id]
		)
		 OUTPUT 'i','alert_table_where_clause',inserted.alert_table_where_clause_id,inserted.alert_table_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[clause_type],src.[column_id],src.[operator_id],src.[column_value],src.[second_value],src.[table_id],src.[column_function],src.[condition_id],src.[sequence_no],src.[data_source_column_id]
		FROM #alert_table_where_clause_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN alert_table_where_clause dst  ON src.alert_table_where_clause_id=dst.alert_table_where_clause_id
		WHERE dst.[alert_table_where_clause_id] IS NULL;
UPDATE #alert_table_where_clause_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid =dst.new_id 
		FROM #alert_table_where_clause_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN #old_new_id dst  ON src.alert_table_where_clause_id=dst.unique_key1 AND dst.table_name='alert_table_where_clause'
		;
print('--==============================END alert_table_where_clause=============================')
print('--==============================START alert_actions=============================')

	if object_id('tempdb..#alert_actions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #alert_actions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [alert_actions_id] int ,[alert_id] int ,[table_id] int ,[column_id] int ,[column_value] varchar(500) COLLATE DATABASE_DEFAULT ,[condition_id] int ,[sql_statement] varchar(max) COLLATE DATABASE_DEFAULT ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_actions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #alert_actions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [alert_actions_id],[alert_id],[table_id],[column_id],[column_value],[condition_id],[sql_statement],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_actions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where alert_actions_id is null;
	update #alert_actions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set alert_id='FARRMS1_ '+cast(alert_actions_id as varchar(30))  where isnull(alert_id,'')='' ;
	
print('--==============================END alert_actions=============================')

UPDATE aa SET aa.column_id = acd.new_recid FROM #alert_actions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 aa INNER JOIN #alert_columns_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1  acd ON acd.old_recid = aa.column_id
UPDATE aa SET aa.table_id = art.new_recid FROM #alert_actions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 aa INNER JOIN #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 art ON art.old_recid = aa.table_id
UPDATE aa SET aa.condition_id = ac.new_recid FROM #alert_actions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 aa INNER JOIN #alert_conditions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 ac ON ac.old_recid = aa.condition_id
UPDATE aa SET aa.alert_id = asl.new_recid FROM #alert_actions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 aa INNER JOIN #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 asl ON asl.old_recid = aa.alert_id

print('--==============================START alert_actions=============================')
UPDATE dbo.alert_actions SET [table_id]=src.[table_id],[column_id]=src.[column_id],[column_value]=src.[column_value],[condition_id]=src.[condition_id],[sql_statement]=src.[sql_statement],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','alert_actions',inserted.alert_actions_id,inserted.alert_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_actions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN alert_actions dst  ON src.alert_id=dst.alert_id;
insert into alert_actions
		([alert_id],[table_id],[column_id],[column_value],[condition_id],[sql_statement],[data_source_column_id]
		)
		 OUTPUT 'i','alert_actions',inserted.alert_actions_id,inserted.alert_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[column_id],src.[column_value],src.[condition_id],src.[sql_statement],src.[data_source_column_id]
		FROM #alert_actions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN alert_actions dst  ON src.alert_id=dst.alert_id
		WHERE dst.[alert_actions_id] IS NULL;
UPDATE #alert_actions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid =dst.new_id 
		FROM #alert_actions_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND dst.table_name='alert_actions'
		;
print('--==============================END alert_actions=============================')
print('--==============================START alert_actions_events=============================')

	if object_id('tempdb..#alert_actions_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #alert_actions_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [alert_actions_events_id] int ,[alert_id] int ,[table_id] int ,[callback_alert_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_actions_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #alert_actions_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [alert_actions_events_id],[alert_id],[table_id],[callback_alert_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,null);
	delete #alert_actions_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where alert_actions_events_id is null;
	update #alert_actions_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set alert_id='FARRMS1_ '+cast(alert_actions_events_id as varchar(30))  where isnull(alert_id,'')='' ;
	update #alert_actions_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set table_id='FARRMS2_ '+cast(alert_actions_events_id as varchar(30))  where isnull(table_id,'')='' ;
			update #alert_actions_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set callback_alert_id='FARRMS3_ '+cast(alert_actions_events_id as varchar(30))  where isnull(callback_alert_id,'')='' ;
			
print('--==============================END alert_actions_events=============================')

UPDATE aae SET aae.alert_id = asl.new_recid FROM #alert_actions_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 aae INNER JOIN #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 asl ON asl.old_recid = aae.alert_id
UPDATE aae SET aae.table_id = art.new_recid FROM #alert_actions_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 aae INNER JOIN #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 art ON art.old_recid = aae.table_id

print('--==============================START alert_actions_events=============================')
UPDATE dbo.alert_actions_events SET [callback_alert_id]=src.[callback_alert_id]
		   OUTPUT 'u','alert_actions_events',inserted.alert_actions_events_id,inserted.alert_id,inserted.table_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_actions_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN alert_actions_events dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id;
insert into alert_actions_events
		([alert_id],[table_id],[callback_alert_id]
		)
		 OUTPUT 'i','alert_actions_events',inserted.alert_actions_events_id,inserted.alert_id,inserted.table_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[callback_alert_id]
		FROM #alert_actions_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN alert_actions_events dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id
		WHERE dst.[alert_actions_events_id] IS NULL;
UPDATE #alert_actions_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid =dst.new_id 
		FROM #alert_actions_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND dst.table_name='alert_actions_events'
		;
print('--==============================END alert_actions_events=============================')
print('--==============================START alert_table_relation=============================')

	if object_id('tempdb..#alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [alert_table_relation_id] int ,[alert_id] int ,[from_table_id] int ,[from_column_id] int ,[to_table_id] int ,[to_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [alert_table_relation_id],[alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where alert_table_relation_id is null;
	update #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set alert_id='FARRMS1_ '+cast(alert_table_relation_id as varchar(30))  where isnull(alert_id,'')='' ;
	update #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set from_table_id='FARRMS2_ '+cast(alert_table_relation_id as varchar(30))  where isnull(from_table_id,'')='' ;
			update #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set to_table_id='FARRMS3_ '+cast(alert_table_relation_id as varchar(30))  where isnull(to_table_id,'')='' ;
			
print('--==============================END alert_table_relation=============================')
	
update #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set from_column_id='FARRMS4_ '+cast(alert_table_relation_id as varchar(30))  where isnull(from_column_id,'')='' ;
update #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set to_column_id='FARRMS5_ '+cast(alert_table_relation_id as varchar(30))  where isnull(to_column_id,'')='' ;

UPDATE atr SET atr.alert_id	= asl.new_recid FROM #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 atr INNER JOIN #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 asl ON asl.old_recid = atr.alert_id		
UPDATE atr SET atr.from_table_id = atd.new_recid FROM #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 atr INNER JOIN #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 atd ON atd.old_recid = atr.from_table_id		
UPDATE atr SET atr.to_table_id = atd.new_recid FROM #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 atr INNER JOIN #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 atd ON atd.old_recid = atr.to_table_id		
UPDATE atr SET atr.from_column_id = atd.new_recid FROM #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 atr INNER JOIN #alert_columns_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 atd ON atd.old_recid = atr.from_column_id		
UPDATE atr SET atr.to_column_id = atd.new_recid FROM #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 atr INNER JOIN #alert_columns_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 atd ON atd.old_recid = atr.to_column_id		

insert into alert_table_relation
		([alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id]
		)
		 OUTPUT 'i','alert_table_relation',inserted.alert_table_relation_id,inserted.alert_id,inserted.from_table_id,inserted.to_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[from_table_id],src.[from_column_id],src.[to_table_id],src.[to_column_id]
		FROM #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN alert_table_relation dst  
		ON src.alert_id=dst.alert_id AND src.from_table_id=dst.from_table_id AND src.to_table_id=dst.to_table_id
		AND src.from_column_id=dst.from_column_id AND src.to_column_id=dst.to_column_id
		WHERE dst.[alert_table_relation_id] IS NULL;
UPDATE #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid = atr.alert_table_relation_id 
		FROM #alert_table_relation_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN alert_table_relation atr ON src.alert_id=atr.alert_id 
		AND src.from_table_id=atr.from_table_id AND src.to_table_id=atr.to_table_id 
		AND src.from_column_id=atr.from_column_id AND src.to_column_id=atr.to_column_id 
		;
print('--==============================END alert_table_relation=============================')		

print('--==============================START module_events=============================')

	if object_id('tempdb..#module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [module_events_id] int ,[modules_id] int ,[event_id] varchar(2000) COLLATE DATABASE_DEFAULT ,[workflow_name] varchar(100) COLLATE DATABASE_DEFAULT ,[workflow_owner] varchar(100) COLLATE DATABASE_DEFAULT ,[rule_table_id] int ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [module_events_id],[modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id],[is_active],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where module_events_id is null;
	update #module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set workflow_name='FARRMS1_ '+cast(module_events_id as varchar(30))  where isnull(workflow_name,'')='' ;
	
print('--==============================END module_events=============================')
	
	UPDATE me SET me.rule_table_id = atd.new_recid FROM #module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 me INNER JOIN #alert_table_definition_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 atd ON atd.old_recid = me.rule_table_id

	UPDATE dbo.module_events SET [modules_id]=src.[modules_id],[event_id]=src.[event_id],[workflow_owner]=src.[workflow_owner],[rule_table_id]=src.[rule_table_id]
			   OUTPUT 'u','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
		FROM #module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN module_events dst  ON src.workflow_name=dst.workflow_name;
	insert into module_events
			([modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id]
			)
			 OUTPUT 'i','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_id],src.[event_id],src.[workflow_name],src.[workflow_owner],src.[rule_table_id]
			FROM #module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN module_events dst  ON src.workflow_name=dst.workflow_name
			WHERE dst.[module_events_id] IS NULL;

			UPDATE #module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid = b.new_id 		
			FROM #module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 a 
			INNER JOIN 
			( SELECT TOP(1) new_id, unique_key1 FROM  #module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src 
			INNER JOIN #old_new_id dst ON src.workflow_name=dst.unique_key1 AND dst.table_name='module_events' ORDER BY new_id DESC
			) b ON a.workflow_name= b.unique_key1 

	

	UPDATE me SET me.modules_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 sdv ON sdv.old_recid = me.modules_id

	UPDATE me SET me.event_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 sdv ON sdv.old_recid = me.event_id
	
print('--==============================START event_trigger=============================')

	if object_id('tempdb..#event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [event_trigger_id] int ,[modules_event_id] int ,[alert_id] int ,[initial_event] char(1) COLLATE DATABASE_DEFAULT ,[manual_step] char(1) COLLATE DATABASE_DEFAULT ,[is_disable] char(1) COLLATE DATABASE_DEFAULT ,[report_paramset_id] varchar(max) COLLATE DATABASE_DEFAULT ,[report_filters] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [event_trigger_id],[modules_event_id],[alert_id],[initial_event],[manual_step],[is_disable],[report_paramset_id],[report_filters],old_recid
	 )
	 VALUES
	 
(1357,1176,6,'n',NULL,NULL,NULL,NULL,1357),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where event_trigger_id is null;
	update #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set modules_event_id='FARRMS1_ '+cast(event_trigger_id as varchar(30))  where isnull(modules_event_id,'')='' ;
	update #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set alert_id='FARRMS2_ '+cast(event_trigger_id as varchar(30))  where isnull(alert_id,'')='' ;
			
print('--==============================END event_trigger=============================')

		
		IF EXISTS (SELECT 1 FROM #module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1)
		BEGIN
			DELETE FROM #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 WHERE modules_event_id NOT IN (
			SELECT mebs.module_events_id FROM #module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 mebs INNER JOIN #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 et 
			ON et.modules_event_id = mebs.module_events_id)
		END
		ELSE
		BEGIN
			DELETE FROM #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 WHERE modules_event_id NOT IN 
			(SELECT meb.module_events_id FROM #module_events_bkup meb INNER JOIN #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 et 
			ON et.modules_event_id = meb.module_events_id)
		END
		
	
	UPDATE et SET et.alert_id = asl.new_recid FROM #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 et INNER JOIN #alert_sql_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 asl ON asl.old_recid = et.alert_id WHERE et.alert_id <> -1
	UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 et INNER JOIN #module_events_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 me ON me.old_recid = et.modules_event_id
	
UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 et INNER JOIN #module_events_bkup me ON me.old_recid = et.modules_event_id

	print('--==============================START event_trigger=============================')

	UPDATE event_trigger SET 
	 [initial_event] = src.[initial_event]
	, [manual_step] = src.[manual_step]
	, [is_disable] = src.[is_disable]
	, [report_paramset_id] = src.[report_paramset_id]
	, [report_filters] = src.[report_filters]
	 OUTPUT 'u','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,src.report_paramset_id  
	 INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src 
	INNER JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id

	insert into event_trigger
			([modules_event_id],[alert_id],[initial_event], [manual_step], [is_disable], [report_paramset_id], [report_filters]
			)
			 OUTPUT 'i','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,inserted.report_paramset_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_event_id],src.[alert_id],src.[initial_event], src.[manual_step], src.[is_disable], src.[report_paramset_id], src.[report_filters]
			FROM #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id
			WHERE dst.[event_trigger_id] IS NULL;
	UPDATE #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid =dst.new_id 
			FROM #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN #old_new_id dst  ON src.modules_event_id=dst.unique_key1 AND src.alert_id=dst.unique_key2 AND dst.table_name='event_trigger'
			AND ISNULL(src.report_paramset_id,-999) = ISNULL(dst.unique_key3,-999);
	print('--==============================END event_trigger=============================')
print('--==============================START workflow_event_message=============================')

	if object_id('tempdb..#workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [event_message_id] int ,[event_trigger_id] int ,[event_message_name] varchar(100) COLLATE DATABASE_DEFAULT ,[message_template_id] int ,[message] varchar(1000) COLLATE DATABASE_DEFAULT ,[mult_approval_required] char(1) COLLATE DATABASE_DEFAULT ,[comment_required] char(1) COLLATE DATABASE_DEFAULT ,[approval_action_required] char(1) COLLATE DATABASE_DEFAULT ,[self_notify] char(1) COLLATE DATABASE_DEFAULT ,[notify_trader] char(1) COLLATE DATABASE_DEFAULT ,[next_module_events_id] int ,[minimum_approval_required] int ,[optional_event_msg] char(1) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[automatic_proceed] char(1) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [event_message_id],[event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type],old_recid
	 )
	 VALUES
	 
(1255,1357,'Credit File Review',0,'Please Review Credit File of attached Counterparty. <#ALERT_REPORT>','n','n','n','y','n',NULL,NULL,'n',NULL,'n','757',1255),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where event_message_id is null;
	update #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set event_trigger_id='FARRMS1_ '+cast(event_message_id as varchar(30))  where isnull(event_trigger_id,'')='' ;
	update #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set event_message_name='FARRMS2_ '+cast(event_message_id as varchar(30))  where isnull(event_message_name,'')='' ;
			
print('--==============================END workflow_event_message=============================')

		IF EXISTS (SELECT 1 FROM #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1)
		BEGIN	
			DELETE FROM #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wem INNER JOIN #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 et ON et.old_recid = wem.event_trigger_id)
		END
		

	UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wem INNER JOIN #event_trigger_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 et ON et.old_recid = wem.event_trigger_id

		UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wem INNER JOIN #event_trigger_bkup et ON et.old_recid = wem.event_trigger_id
		UPDATE wem SET wem.next_module_events_id = meb.new_recid FROM #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wem  INNER JOIN #module_events_bkup meb ON meb.old_recid = wem.next_module_events_id
print('--==============================START workflow_event_message=============================')
UPDATE dbo.workflow_event_message SET [message_template_id]=src.[message_template_id],[message]=src.[message],[mult_approval_required]=src.[mult_approval_required],[comment_required]=src.[comment_required],[approval_action_required]=src.[approval_action_required],[self_notify]=src.[self_notify],[notify_trader]=src.[notify_trader],[next_module_events_id]=src.[next_module_events_id],[minimum_approval_required]=src.[minimum_approval_required],[optional_event_msg]=src.[optional_event_msg],[counterparty_contact_type]=src.[counterparty_contact_type],[automatic_proceed]=src.[automatic_proceed],[notification_type]=src.[notification_type]
		   OUTPUT 'u','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name;
insert into workflow_event_message
		([event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type]
		)
		 OUTPUT 'i','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_trigger_id],src.[event_message_name],src.[message_template_id],src.[message],src.[mult_approval_required],src.[comment_required],src.[approval_action_required],src.[self_notify],src.[notify_trader],src.[next_module_events_id],src.[minimum_approval_required],src.[optional_event_msg],src.[counterparty_contact_type],src.[automatic_proceed],src.[notification_type]
		FROM #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name
		WHERE dst.[event_message_id] IS NULL;
UPDATE #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid =dst.new_id 
		FROM #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN #old_new_id dst  ON src.event_trigger_id=dst.unique_key1 AND src.event_message_name=dst.unique_key2 AND dst.table_name='workflow_event_message'
		;
print('--==============================END workflow_event_message=============================')
	
		INSERT INTO #workflow_event_message_bkup (event_message_id, event_trigger_id, event_message_name, message_template_id, message, mult_approval_required, comment_required, approval_action_required, self_notify, notify_trader, counterparty_contact_type, next_module_events_id, minimum_approval_required, optional_event_msg, automatic_proceed, notification_type, new_recid, old_recid)
		SELECT wem.event_message_id, wem.event_trigger_id, wem.event_message_name, wem.message_template_id, wem.message, wem.mult_approval_required, wem.comment_required, wem.approval_action_required, wem.self_notify, wem.notify_trader, wem.counterparty_contact_type, wem.next_module_events_id, wem.minimum_approval_required, wem.optional_event_msg, wem.automatic_proceed, wem.notification_type, wem.new_recid, wem.old_recid FROM #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wem
		LEFT JOIN #workflow_event_message_bkup wemb ON wemb.old_recid = wem.old_recid 
		WHERE wemb.old_recid IS NULL
print('--==============================START application_security_role=============================')

	if object_id('tempdb..#application_security_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #application_security_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [role_id] int ,[role_name] varchar(50) COLLATE DATABASE_DEFAULT ,[role_description] varchar(250) COLLATE DATABASE_DEFAULT ,[role_type_value_id] int ,[process_map_file_name] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #application_security_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #application_security_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [role_id],[role_name],[role_description],[role_type_value_id],[process_map_file_name],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,null);
	delete #application_security_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where role_id is null;
	update #application_security_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set role_name='FARRMS1_ '+cast(role_id as varchar(30))  where isnull(role_name,'')='' ;
	
UPDATE dbo.application_security_role SET [role_description]=src.[role_description],[role_type_value_id]=src.[role_type_value_id],[process_map_file_name]=src.[process_map_file_name]
		   OUTPUT 'u','application_security_role',inserted.role_id,inserted.role_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #application_security_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN application_security_role dst  ON src.role_name=dst.role_name;
insert into application_security_role
		([role_name],[role_description],[role_type_value_id],[process_map_file_name]
		)
		 OUTPUT 'i','application_security_role',inserted.role_id,inserted.role_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[role_name],src.[role_description],src.[role_type_value_id],src.[process_map_file_name]
		FROM #application_security_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN application_security_role dst  ON src.role_name=dst.role_name
		WHERE dst.[role_id] IS NULL;
UPDATE #application_security_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid =dst.new_id 
		FROM #application_security_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN #old_new_id dst  ON src.role_name=dst.unique_key1 AND dst.table_name='application_security_role'
		;
print('--==============================END application_security_role=============================')
print('--==============================START workflow_event_user_role=============================')

	if object_id('tempdb..#workflow_event_user_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #workflow_event_user_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [event_user_role_id] int ,[event_message_id] int ,[user_login_id] varchar(50) COLLATE DATABASE_DEFAULT ,[role_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_user_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #workflow_event_user_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [event_user_role_id],[event_message_id],[user_login_id],[role_id],old_recid
	 )
	 VALUES
	 
(7741,1255,'pioneer',NULL,7741),
(7742,1255,'nradhikari',NULL,7742),
(7743,1255,'user1',NULL,7743),
(NULL,NULL,NULL,NULL,null);
	delete #workflow_event_user_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where event_user_role_id is null;
	update #workflow_event_user_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set event_user_role_id='FARRMS1_ '+cast(event_user_role_id as varchar(30))  where isnull(event_user_role_id,'')='' ;
	
print('--==============================END workflow_event_user_role=============================')
	
		DELETE FROM #workflow_event_user_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wem INNER JOIN #workflow_event_user_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 weur ON weur.event_message_id = wem.event_message_id	)
		
	
	UPDATE weur SET weur.role_id = asr.new_recid FROM #workflow_event_user_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 weur INNER JOIN #application_security_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 asr ON asr.old_recid = weur.role_id
	UPDATE weur SET weur.event_message_id = wem.new_recid FROM #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wem INNER JOIN #workflow_event_user_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 weur ON weur.event_message_id = wem.old_recid
	
print('--==============================START workflow_event_user_role=============================')
UPDATE dbo.workflow_event_user_role SET [event_message_id]=src.[event_message_id],[user_login_id]=src.[user_login_id],[role_id]=src.[role_id]
		   OUTPUT 'u','workflow_event_user_role',inserted.event_user_role_id,inserted.event_user_role_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_user_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN workflow_event_user_role dst  ON src.event_user_role_id=dst.event_user_role_id;
insert into workflow_event_user_role
		([event_message_id],[user_login_id],[role_id]
		)
		 OUTPUT 'i','workflow_event_user_role',inserted.event_user_role_id,inserted.event_user_role_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[user_login_id],src.[role_id]
		FROM #workflow_event_user_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN workflow_event_user_role dst  ON src.event_user_role_id=dst.event_user_role_id
		WHERE dst.[event_user_role_id] IS NULL;
UPDATE #workflow_event_user_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid =dst.new_id 
		FROM #workflow_event_user_role_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN #old_new_id dst  ON src.event_user_role_id=dst.unique_key1 AND dst.table_name='workflow_event_user_role'
		;
print('--==============================END workflow_event_user_role=============================')
print('--==============================START workflow_event_message_documents=============================')

	if object_id('tempdb..#workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [message_document_id] int ,[event_message_id] int ,[document_template_id] int ,[effective_date] datetime ,[document_category] int ,[document_template] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [message_document_id],[event_message_id],[document_template_id],[effective_date],[document_category],[document_template],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where message_document_id is null;
	update #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set message_document_id='FARRMS1_ '+cast(message_document_id as varchar(30))  where isnull(message_document_id,'')='' ;
	
print('--==============================END workflow_event_message_documents=============================')

		DELETE FROM #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wemd ON wem.event_message_id = wemd.event_message_id)

	UPDATE wemd SET wemd.event_message_id = wem.new_recid FROM #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wem INNER JOIN #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wemd ON wemd.event_message_id = wem.old_recid
	UPDATE wemd SET wemd.document_template_id = sdv.new_recid FROM #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wemd INNER JOIN #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 sdv ON sdv.old_recid = wemd.document_template_id
	UPDATE wemd SET wemd.document_category = sdv.new_recid FROM #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wemd INNER JOIN #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 sdv ON sdv.old_recid = wemd.document_category
	
print('--==============================START workflow_event_message_documents=============================')
UPDATE dbo.workflow_event_message_documents SET [event_message_id]=src.[event_message_id],[document_template_id]=src.[document_template_id],[effective_date]=src.[effective_date],[document_category]=src.[document_category],[document_template]=src.[document_template]
		   OUTPUT 'u','workflow_event_message_documents',inserted.message_document_id,inserted.message_document_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN workflow_event_message_documents dst  ON src.message_document_id=dst.message_document_id;
insert into workflow_event_message_documents
		([event_message_id],[document_template_id],[effective_date],[document_category],[document_template]
		)
		 OUTPUT 'i','workflow_event_message_documents',inserted.message_document_id,inserted.message_document_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[document_template_id],src.[effective_date],src.[document_category],src.[document_template]
		FROM #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN workflow_event_message_documents dst  ON src.message_document_id=dst.message_document_id
		WHERE dst.[message_document_id] IS NULL;
UPDATE #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid =dst.new_id 
		FROM #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN #old_new_id dst  ON src.message_document_id=dst.unique_key1 AND dst.table_name='workflow_event_message_documents'
		;
print('--==============================END workflow_event_message_documents=============================')

	UPDATE w2 SET w2.new_recid = w1.message_document_id
	FROM workflow_event_message_documents w1 
	INNER JOIN #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 w2 ON w1.event_message_id = w2.event_message_id
		AND ISNULL(w1.document_template_id, '-1') = ISNULL(w2.document_template_id, '-1')
		AND ISNULL(w1.document_category, '-1') = ISNULL(w2.document_category, '-1')
print('--==============================START workflow_event_message_details=============================')

	if object_id('tempdb..#workflow_event_message_details_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #workflow_event_message_details_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [message_detail_id] int ,[event_message_document_id] int ,[message_template_id] int ,[message] varchar(500) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[delivery_method] int ,[internal_contact_type] int ,[email] varchar(300) COLLATE DATABASE_DEFAULT ,[email_cc] varchar(300) COLLATE DATABASE_DEFAULT ,[email_bcc] varchar(300) COLLATE DATABASE_DEFAULT ,[as_defined_in_contact] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_details_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #workflow_event_message_details_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [message_detail_id],[event_message_document_id],[message_template_id],[message],[counterparty_contact_type],[delivery_method],[internal_contact_type],[email],[email_cc],[email_bcc],[as_defined_in_contact],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_details_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where message_detail_id is null;
	update #workflow_event_message_details_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set message_detail_id='FARRMS1_ '+cast(message_detail_id as varchar(30))  where isnull(message_detail_id,'')='' ;
	
print('--==============================END workflow_event_message_details=============================')

	DELETE FROM #workflow_event_message_details_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 WHERE message_detail_id NOT IN (
		SELECT wemd.message_detail_id from #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wemdd 
		INNER JOIN #workflow_event_message_details_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wemd ON wemd.event_message_document_id = wemdd.message_document_id)

	UPDATE wemd SET wemd.event_message_document_id = wem.new_recid FROM #workflow_event_message_documents_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wem INNER JOIN #workflow_event_message_details_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wemd ON wemd.event_message_document_id = wem.old_recid
	UPDATE wemd SET wemd.counterparty_contact_type = sdv.new_recid FROM #workflow_event_message_details_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wemd INNER JOIN #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1  sdv ON sdv.old_recid = wemd.counterparty_contact_type
	UPDATE wemd SET wemd.delivery_method = sdv.new_recid FROM #workflow_event_message_details_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wemd INNER JOIN #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1  sdv ON sdv.old_recid = wemd.delivery_method
	UPDATE wemd SET wemd.internal_contact_type = sdv.new_recid FROM #workflow_event_message_details_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wemd INNER JOIN #static_data_value_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1  sdv ON sdv.old_recid = wemd.internal_contact_type
	
print('--==============================START workflow_event_message_details=============================')
UPDATE dbo.workflow_event_message_details SET [event_message_document_id]=src.[event_message_document_id],[message_template_id]=src.[message_template_id],[message]=src.[message],[counterparty_contact_type]=src.[counterparty_contact_type],[delivery_method]=src.[delivery_method],[internal_contact_type]=src.[internal_contact_type],[email]=src.[email],[email_cc]=src.[email_cc],[email_bcc]=src.[email_bcc],[as_defined_in_contact]=src.[as_defined_in_contact]
		   OUTPUT 'u','workflow_event_message_details',inserted.message_detail_id,inserted.message_detail_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_details_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN workflow_event_message_details dst  ON src.message_detail_id=dst.message_detail_id;
insert into workflow_event_message_details
		([event_message_document_id],[message_template_id],[message],[counterparty_contact_type],[delivery_method],[internal_contact_type],[email],[email_cc],[email_bcc],[as_defined_in_contact]
		)
		 OUTPUT 'i','workflow_event_message_details',inserted.message_detail_id,inserted.message_detail_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_document_id],src.[message_template_id],src.[message],src.[counterparty_contact_type],src.[delivery_method],src.[internal_contact_type],src.[email],src.[email_cc],src.[email_bcc],src.[as_defined_in_contact]
		FROM #workflow_event_message_details_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN workflow_event_message_details dst  ON src.message_detail_id=dst.message_detail_id
		WHERE dst.[message_detail_id] IS NULL;
UPDATE #workflow_event_message_details_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid =dst.new_id 
		FROM #workflow_event_message_details_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN #old_new_id dst  ON src.message_detail_id=dst.unique_key1 AND dst.table_name='workflow_event_message_details'
		;
print('--==============================END workflow_event_message_details=============================')
print('--==============================START alert_reports=============================')

	if object_id('tempdb..#alert_reports_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #alert_reports_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [alert_reports_id] int ,[event_message_id] int ,[report_writer] varchar(1) COLLATE DATABASE_DEFAULT ,[paramset_hash] varchar(8000) COLLATE DATABASE_DEFAULT ,[report_param] varchar(1000) COLLATE DATABASE_DEFAULT ,[report_desc] varchar(500) COLLATE DATABASE_DEFAULT ,[table_prefix] varchar(50) COLLATE DATABASE_DEFAULT ,[table_postfix] varchar(50) COLLATE DATABASE_DEFAULT ,[report_where_clause] varchar(max) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_reports_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #alert_reports_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [alert_reports_id],[event_message_id],[report_writer],[paramset_hash],[report_param],[report_desc],[table_prefix],[table_postfix],[report_where_clause],old_recid
	 )
	 VALUES
	 
(46,1255,'n','',NULL,'Credit File','credit_file_','_cf','',46),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_reports_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where alert_reports_id is null;
	update #alert_reports_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set event_message_id='FARRMS1_ '+cast(alert_reports_id as varchar(30))  where isnull(event_message_id,'')='' ;
	update #alert_reports_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set report_desc='FARRMS2_ '+cast(alert_reports_id as varchar(30))  where isnull(report_desc,'')='' ;
			update #alert_reports_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set table_prefix='FARRMS3_ '+cast(alert_reports_id as varchar(30))  where isnull(table_prefix,'')='' ;
			
print('--==============================END alert_reports=============================')

		DELETE FROM #alert_reports_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_reports_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 ar ON wem.event_message_id = ar.event_message_id)

	UPDATE ar SET ar.event_message_id = wem.new_recid FROM #workflow_event_message_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 wem INNER JOIN #alert_reports_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 ar ON ar.event_message_id = wem.old_recid
	
print('--==============================START alert_reports=============================')
UPDATE dbo.alert_reports SET [report_writer]=src.[report_writer],[paramset_hash]=src.[paramset_hash],[report_param]=src.[report_param],[table_postfix]=src.[table_postfix],[report_where_clause]=src.[report_where_clause]
		   OUTPUT 'u','alert_reports',inserted.alert_reports_id,inserted.event_message_id,inserted.report_desc,inserted.table_prefix INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_reports_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN alert_reports dst  ON src.event_message_id=dst.event_message_id AND src.report_desc=dst.report_desc AND src.table_prefix=dst.table_prefix;
insert into alert_reports
		([event_message_id],[report_writer],[paramset_hash],[report_param],[report_desc],[table_prefix],[table_postfix],[report_where_clause]
		)
		 OUTPUT 'i','alert_reports',inserted.alert_reports_id,inserted.event_message_id,inserted.report_desc,inserted.table_prefix INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[report_writer],src.[paramset_hash],src.[report_param],src.[report_desc],src.[table_prefix],src.[table_postfix],src.[report_where_clause]
		FROM #alert_reports_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN alert_reports dst  ON src.event_message_id=dst.event_message_id AND src.report_desc=dst.report_desc AND src.table_prefix=dst.table_prefix
		WHERE dst.[alert_reports_id] IS NULL;
UPDATE #alert_reports_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid =dst.new_id 
		FROM #alert_reports_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN #old_new_id dst  ON src.event_message_id=dst.unique_key1 AND src.report_desc=dst.unique_key2 AND src.table_prefix=dst.unique_key3 AND dst.table_name='alert_reports'
		;
print('--==============================END alert_reports=============================')
print('--==============================START alert_report_params=============================')

	if object_id('tempdb..#alert_report_params_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1') is null 
	
	CREATE TABLE #alert_report_params_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1
	 (
	 [alert_report_params_id] int ,[event_message_id] int ,[alert_report_id] int ,[main_table_id] int ,[parameter_name] nvarchar(200) COLLATE DATABASE_DEFAULT ,[parameter_value] nvarchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_report_params_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1;
INSERT INTO #alert_report_params_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1(
	 [alert_report_params_id],[event_message_id],[alert_report_id],[main_table_id],[parameter_name],[parameter_value],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_report_params_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 where alert_report_params_id is null;
	update #alert_report_params_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 set alert_report_id='FARRMS1_ '+cast(alert_report_params_id as varchar(30))  where isnull(alert_report_id,'')='' ;
	
print('--==============================END alert_report_params=============================')

		DELETE FROM #alert_report_params_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_report_params_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 ar ON wem.event_message_id = ar.event_message_id)

	UPDATE arp SET arp.alert_report_id = ar.alert_reports_id FROM #alert_report_params_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 arp INNER JOIN #alert_reports_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 ar ON ar.old_recid = arp.alert_report_id
	UPDATE arp SET arp.main_table_id = art.alert_rule_table_id FROM #alert_report_params_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 arp INNER JOIN #alert_rule_table_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 art ON art.old_recid = arp.main_table_id
	
print('--==============================START alert_report_params=============================')
UPDATE dbo.alert_report_params SET [event_message_id]=src.[event_message_id],[main_table_id]=src.[main_table_id],[parameter_name]=src.[parameter_name],[parameter_value]=src.[parameter_value]
		   OUTPUT 'u','alert_report_params',inserted.alert_report_params_id,inserted.alert_report_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_report_params_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN alert_report_params dst  ON src.alert_report_id=dst.alert_report_id;
insert into alert_report_params
		([event_message_id],[alert_report_id],[main_table_id],[parameter_name],[parameter_value]
		)
		 OUTPUT 'i','alert_report_params',inserted.alert_report_params_id,inserted.alert_report_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[alert_report_id],src.[main_table_id],src.[parameter_name],src.[parameter_value]
		FROM #alert_report_params_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src LEFT JOIN alert_report_params dst  ON src.alert_report_id=dst.alert_report_id
		WHERE dst.[alert_report_params_id] IS NULL;
UPDATE #alert_report_params_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 SET new_recid =dst.new_id 
		FROM #alert_report_params_18A65C2E_C6BC_4A13_AB9A_A3D7DC0B20B1 src INNER JOIN #old_new_id dst  ON src.alert_report_id=dst.unique_key1 AND dst.table_name='alert_report_params'
		;
print('--==============================END alert_report_params=============================')
print('--==============================START static_data_value=============================')

	if object_id('tempdb..#static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [value_id] int ,[type_id] int ,[code] varchar(500) COLLATE DATABASE_DEFAULT ,[description] varchar(500) COLLATE DATABASE_DEFAULT ,[entity_id] int ,[xref_value_id] varchar(50) COLLATE DATABASE_DEFAULT ,[xref_value] varchar(250) COLLATE DATABASE_DEFAULT ,[category_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [value_id],[type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id],old_recid
	 )
	 VALUES
	 
(757,750,'Alert','Alert with Beep Sound',NULL,NULL,NULL,NULL,757),
(20610,20600,'Calendar','Calendar',NULL,NULL,NULL,NULL,20610),
(20535,20500,'Calendar - Time Based',' Calendar - Time Based',NULL,NULL,NULL,0,20535),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where value_id is null;
	update #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set code='FARRMS1_ '+cast(value_id as varchar(30))  where isnull(code,'')='' ;
	update #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set type_id='FARRMS2_ '+cast(value_id as varchar(30))  where isnull(type_id,'')='' ;
			
UPDATE dbo.static_data_value SET [description]=src.[description],[entity_id]=src.[entity_id],[xref_value_id]=src.[xref_value_id],[xref_value]=src.[xref_value],[category_id]=src.[category_id]
		   OUTPUT 'u','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id;
insert into static_data_value
		([type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id]
		)
		 OUTPUT 'i','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[type_id],src.[code],src.[description],src.[entity_id],src.[xref_value_id],src.[xref_value],src.[category_id]
		FROM #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id
		WHERE dst.[value_id] IS NULL;
UPDATE #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid =dst.new_id 
		FROM #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN #old_new_id dst  ON src.code=dst.unique_key1 AND src.type_id=dst.unique_key2 AND dst.table_name='static_data_value'
		;
print('--==============================END static_data_value=============================')
print('--==============================START alert_sql=============================')

	if object_id('tempdb..#alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [alert_sql_id] int ,[workflow_only] varchar(1) COLLATE DATABASE_DEFAULT ,[message] varchar(500) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,[sql_statement] varchar(max) COLLATE DATABASE_DEFAULT ,[alert_sql_name] varchar(100) COLLATE DATABASE_DEFAULT ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,[alert_type] char(1) COLLATE DATABASE_DEFAULT ,[rule_category] int ,[system_rule] char(1) COLLATE DATABASE_DEFAULT ,[alert_category] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [alert_sql_id],[workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category],old_recid
	 )
	 VALUES
	 
(7,'n','Counterparty Collateral Renewal Date Approaching','757','select [Counterparty],
  [Internal Counterparty],
  [Contract],
  [Enhancement Type],
  [Guarantee Counterparty],
  [Amount],
  [Currency],
  [Effective Date],
  [Expiration date],
  [Approved By],
  [Receive Type],
  [Remaining Days]
INTO adiha_process.dbo.collatral_voilation_process_id_cv
from(
SELECT 
  cce.counterparty_credit_enhancement_id,
  ROW_NUMBER() over(partition by sc.counterparty_name order by cce.eff_date desc) rnk,
  sc.counterparty_name [Counterparty],
    sci.counterparty_name  [Internal Counterparty],
    cg.contract_name [Contract],
       sdv.code [Enhancement Type],
       sc_g.counterparty_id [Guarantee Counterparty],
       CONVERT(VARCHAR, CAST(dbo.FNARemoveTrailingZero(cce.amount) AS MONEY), 1) [Amount],
       sc2.currency_id [Currency],
        CONVERT(VARCHAR(12), cce.eff_date, 107)[Effective Date],
       CONVERT(VARCHAR(12), cce.expiration_date, 107) [Expiration date],
       cce.approved_by [Approved By],
       CASE WHEN cce.margin = ''y'' THEN ''Recieve'' ELSE ''Provide'' END [Receive Type],
       DATEDIFF(DAY, CURRENT_TIMESTAMP, expiration_date) [Remaining Days]
FROM   counterparty_credit_enhancements cce 
INNER JOIN counterparty_credit_info cci on cce.counterparty_credit_info_id = cci.counterparty_credit_info_id 
INNER JOIN source_counterparty sc on sc.source_counterparty_id = cci.Counterparty_id
    AND sc.is_active = ''y''
INNER JOIN static_data_value sdv ON sdv.value_id = cce.enhance_type
LEFT JOIN source_counterparty sc_g ON sc_g.source_counterparty_id = cce.guarantee_counterparty
LEFT JOIN source_currency sc2 ON sc2.source_currency_id = cce.currency_code
LEFT JOIN source_counterparty sci On sci.source_counterparty_id=cce.internal_counterparty
LEFT JOIN contract_group cg ON cg.contract_id=cce.contract_id
) a
WHERE 
1=1 and a.rnk = 1
and DATEDIFF(Day,CURRENT_TIMESTAMP,a.[Expiration date]) < =15','Collateral Expiring Alert','y','s',-1,'n',NULL,7),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where alert_sql_id is null;
	update #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set alert_sql_name='FARRMS1_ '+cast(alert_sql_id as varchar(30))  where isnull(alert_sql_name,'')='' ;
	
print('--==============================END alert_sql=============================')

UPDATE dbo.alert_sql SET [workflow_only]=src.[workflow_only],[message]=src.[message],[notification_type]=src.[notification_type],[sql_statement]=src.[sql_statement],[is_active]=src.[is_active],[alert_type]=src.[alert_type],[rule_category]=src.[rule_category],[system_rule]=src.[system_rule],[alert_category]=src.[alert_category]
		   OUTPUT 'u','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name;

IF EXISTS(SELECT 1 FROM #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B WHERE alert_sql_id < 0)
BEGIN
	SET IDENTITY_INSERT alert_sql ON
	INSERT INTO alert_sql
	([alert_sql_id], [workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category]
	)
	OUTPUT 'i','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	SELECT 
	src.alert_sql_id, src.[workflow_only],src.[message],src.[notification_type],src.[sql_statement],src.[alert_sql_name],src.[is_active],src.[alert_type],src.[rule_category],src.[system_rule],src.[alert_category]
	FROM #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
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
	FROM #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
	WHERE dst.[alert_sql_id] IS NULL;
END

UPDATE #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid = dst.new_id , alert_sql_id =  dst.new_id
FROM #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN #old_new_id dst ON src.alert_sql_name = dst.unique_key1 AND dst.table_name = 'alert_sql'

UPDATE asl SET asl.notification_type = sdv.new_recid 
FROM alert_sql asl INNER JOIN #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B sdv ON sdv.old_recid = asl.notification_type	

UPDATE asl SET asl.rule_category = sdv.new_recid
FROM alert_sql asl INNER JOIN #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B sdv ON sdv.old_recid = asl.rule_category	


	INSERT INTO #alert_sql_bkup (alert_sql_id, workflow_only, message, notification_type, sql_statement, alert_sql_name, is_active, alert_type, rule_category, system_rule, alert_category, new_recid, old_recid)
	SELECT asl.alert_sql_id, asl.workflow_only, asl.message, asl.notification_type, asl.sql_statement, asl.alert_sql_name, asl.is_active, asl.alert_type, asl.rule_category, asl.system_rule, asl.alert_category, asl.new_recid, asl.old_recid FROM #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B asl
	LEFT JOIN #alert_sql_bkup aslb ON aslb.old_recid = asl.old_recid
	WHERE aslb.old_recid IS NULL
print('--==============================START alert_table_definition=============================')

	if object_id('tempdb..#alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [alert_table_definition_id] int ,[logical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[physical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[data_source_id] int ,[is_action_view] char(1) COLLATE DATABASE_DEFAULT ,[primary_column] varchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [alert_table_definition_id],[logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column],old_recid
	 )
	 VALUES
	 
(14,'Counterparty Credit Info Audit','vwCounterPartyCreditInfoAudit',NULL,NULL,NULL,14),
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where alert_table_definition_id is null;
	update #alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set logical_table_name='FARRMS1_ '+cast(alert_table_definition_id as varchar(30))  where isnull(logical_table_name,'')='' ;
	
UPDATE dbo.alert_table_definition SET [physical_table_name]=src.[physical_table_name],[data_source_id]=src.[data_source_id],[is_action_view]=src.[is_action_view],[primary_column]=src.[primary_column]
		   OUTPUT 'u','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name;
insert into alert_table_definition
		([logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column]
		)
		 OUTPUT 'i','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[logical_table_name],src.[physical_table_name],src.[data_source_id],src.[is_action_view],src.[primary_column]
		FROM #alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name
		WHERE dst.[alert_table_definition_id] IS NULL;
UPDATE #alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid =dst.new_id 
		FROM #alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN #old_new_id dst  ON src.logical_table_name=dst.unique_key1 AND dst.table_name='alert_table_definition'
		;
print('--==============================END alert_table_definition=============================')

UPDATE #alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET alert_table_definition_id = new_recid

print('--==============================START alert_columns_definition=============================')

	if object_id('tempdb..#alert_columns_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #alert_columns_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [alert_columns_definition_id] int ,[alert_table_id] int ,[column_name] varchar(600) COLLATE DATABASE_DEFAULT ,[is_primary] char(1) COLLATE DATABASE_DEFAULT ,[static_data_type_id] int ,[column_alias] varchar(200) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_columns_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #alert_columns_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [alert_columns_definition_id],[alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias],old_recid
	 )
	 VALUES
	 
(479,14,'account_status_compare','n',NULL,NULL,479),
(480,14,'counterparty_id','y',NULL,NULL,480),
(481,14,'credit_limit_compare','n',NULL,NULL,481),
(482,14,'debt_rating_compare','n',NULL,NULL,482),
(483,14,'debt_rating2_compare','n',NULL,NULL,483),
(484,14,'debt_rating3_compare','n',NULL,NULL,484),
(485,14,'debt_rating4_compare','n',NULL,NULL,485),
(486,14,'debt_rating5_compare','n',NULL,NULL,486),
(487,14,'previous_account_status','n',NULL,NULL,487),
(488,14,'previous_credit_limit','n',NULL,NULL,488),
(489,14,'previous_Debt_rating','n',NULL,NULL,489),
(490,14,'previous_Debt_Rating2','n',NULL,NULL,490),
(491,14,'previous_Debt_Rating3','n',NULL,NULL,491),
(492,14,'previous_Debt_Rating4','n',NULL,NULL,492),
(493,14,'previous_Debt_Rating5','n',NULL,NULL,493),
(962,14,'previous_risk_rating','n',NULL,'Previous Risk Rating',962),
(961,14,'risk_rating_compare','n',NULL,'Risk Rating Compare',961),
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_columns_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where alert_columns_definition_id is null;
	update #alert_columns_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set column_name='FARRMS1_ '+cast(alert_columns_definition_id as varchar(30))  where isnull(column_name,'')='' ;
	
print('--==============================END alert_columns_definition=============================')

UPDATE acd SET acd.alert_table_id = atd.new_recid
FROM #alert_columns_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B acd INNER JOIN #alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B atd ON atd.old_recid = acd.alert_table_id

print('--==============================START alert_columns_definition=============================')
UPDATE dbo.alert_columns_definition SET [alert_table_id]=dst.[alert_table_definition_id],[is_primary]=src_c.[is_primary],[static_data_type_id]=src_c.[static_data_type_id],[column_alias]=src_c.[column_alias]
		   OUTPUT 'u','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src_c ON src_c.alert_table_id=src.alert_table_definition_id
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name;
insert into alert_columns_definition
		([alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias]
		)
		 OUTPUT 'i','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[alert_table_id],src_c.[column_name],src_c.[is_primary],src_c.[static_data_type_id],src_c.[column_alias]
		FROM #alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name 
			INNER JOIN #alert_columns_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			LEFT JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name
		WHERE dst_c.[alert_table_id] IS NULL;
UPDATE #alert_columns_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid =dst_c.[alert_columns_definition_id] 
			FROM #alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id
			 AND src_c.column_name=dst_c.column_name;
print('--==============================END alert_columns_definition=============================')

DELETE FROM alert_table_relation WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B)
DELETE FROM alert_actions_events WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B)
DELETE FROM alert_actions WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B)
DELETE FROM alert_table_where_clause WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B)
DELETE from alert_conditions WHERE rules_id IN (SELECT alert_sql_id FROM #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B)
DELETE from alert_rule_table where alert_id IN (SELECT alert_sql_id FROM #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B)
print('--==============================START alert_rule_table=============================')

	if object_id('tempdb..#alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [alert_rule_table_id] int ,[alert_id] int ,[table_id] int ,[root_table_id] int ,[table_alias] varchar(50) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [alert_rule_table_id],[alert_id],[table_id],[root_table_id],[table_alias],old_recid
	 )
	 VALUES
	 
(261,7,14,NULL,'ccia',261),
(NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where alert_rule_table_id is null;
	update #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set alert_rule_table_id='FARRMS1_ '+cast(alert_rule_table_id as varchar(30))  where isnull(alert_rule_table_id,'')='' ;
	
print('--==============================END alert_rule_table=============================')

UPDATE art SET art.alert_id = asl.new_recid
FROM #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B art INNER JOIN #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B asl ON asl.old_recid = art.alert_id

UPDATE art SET art.table_id = asd.new_recid
FROM #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B art INNER JOIN #alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B  asd ON asd.old_recid = art.table_id

UPDATE dbo.alert_rule_table SET [table_alias]=src.[table_alias]
		   OUTPUT 'u','alert_rule_table',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
insert into alert_rule_table
		([alert_id],[table_id],[root_table_id],[table_alias]
		)
		 OUTPUT 'i','alert_rule_table',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[root_table_id],src.[table_alias]
		FROM #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
		WHERE dst.[alert_rule_table_id] IS NULL;
UPDATE #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid =dst.new_id 
		FROM #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND ISNULL(src.root_table_id, -1)=ISNULL(dst.unique_key3, -1) AND dst.table_name='alert_rule_table'
		;
print('--==============================END alert_rule_table=============================')
	-- need to verify root_table_id
UPDATE art SET art.root_table_id = art2.new_recid FROM #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B art INNER JOIN #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B art2 ON art2.old_recid = art.root_table_id  
UPDATE art SET art.root_table_id = arrt.root_table_id FROM alert_rule_table art INNER JOIN #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B arrt ON arrt.new_recid = art.alert_rule_table_id 

print('--==============================START alert_conditions=============================')

	if object_id('tempdb..#alert_conditions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #alert_conditions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [alert_conditions_id] int ,[rules_id] int ,[alert_conditions_name] varchar(100) COLLATE DATABASE_DEFAULT ,[alert_conditions_description] varchar(500) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_conditions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #alert_conditions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [alert_conditions_id],[rules_id],[alert_conditions_name],[alert_conditions_description],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,null);
	delete #alert_conditions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where alert_conditions_id is null;
	update #alert_conditions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set alert_conditions_name='FARRMS1_ '+cast(alert_conditions_id as varchar(30))  where isnull(alert_conditions_name,'')='' ;
	
print('--==============================END alert_conditions=============================')

UPDATE ac SET rules_id = asl.new_recid	
FROM #alert_conditions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B ac INNER JOIN #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B asl ON asl.old_recid = ac.rules_id
print('--==============================START alert_conditions=============================')
UPDATE dbo.alert_conditions SET [rules_id]=dst.[alert_sql_id],[alert_conditions_description]=src_c.[alert_conditions_description]
		   OUTPUT 'u','alert_conditions',inserted.alert_conditions_id,inserted.alert_conditions_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
			INNER JOIN #alert_conditions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src_c ON src_c.rules_id=src.alert_sql_id
			INNER JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id AND src_c.alert_conditions_name=dst_c.alert_conditions_name;
insert into alert_conditions
		([rules_id],[alert_conditions_name],[alert_conditions_description]
		)
		 OUTPUT 'i','alert_conditions',inserted.alert_conditions_id,inserted.alert_conditions_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[rules_id],src_c.[alert_conditions_name],src_c.[alert_conditions_description]
		FROM #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name 
			INNER JOIN #alert_conditions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src_c ON src_c.rules_id=src.alert_sql_id	
			LEFT JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id AND src_c.alert_conditions_name=dst_c.alert_conditions_name
		WHERE dst_c.[rules_id] IS NULL;
UPDATE #alert_conditions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid =dst_c.[alert_conditions_id] 
			FROM #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
			INNER JOIN #alert_conditions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src_c ON src_c.rules_id=src.alert_sql_id	
			INNER JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id
			 AND src_c.alert_conditions_name=dst_c.alert_conditions_name;
print('--==============================END alert_conditions=============================')

UPDATE #alert_conditions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET alert_conditions_id = new_recid
print('--==============================START alert_table_where_clause=============================')

	if object_id('tempdb..#alert_table_where_clause_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #alert_table_where_clause_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [alert_table_where_clause_id] int ,[alert_id] int ,[clause_type] int ,[column_id] int ,[operator_id] int ,[column_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[second_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[table_id] int ,[column_function] varchar(1000) COLLATE DATABASE_DEFAULT ,[condition_id] int ,[sequence_no] int ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_where_clause_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #alert_table_where_clause_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [alert_table_where_clause_id],[alert_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[condition_id],[sequence_no],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_where_clause_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where alert_table_where_clause_id is null;
	update #alert_table_where_clause_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set alert_table_where_clause_id='FARRMS1_ '+cast(alert_table_where_clause_id as varchar(30))  where isnull(alert_table_where_clause_id,'')='' ;
	
print('--==============================END alert_table_where_clause=============================')

UPDATE atwc SET atwc.alert_id = asl.new_recid FROM #alert_table_where_clause_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B atwc INNER JOIN #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B asl ON asl.old_recid = atwc.alert_id
UPDATE atwc SET atwc.column_id = acd.new_recid FROM #alert_table_where_clause_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B atwc INNER JOIN #alert_columns_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B  acd ON acd.old_recid = atwc.column_id
UPDATE atwc SET atwc.table_id = art.new_recid FROM #alert_table_where_clause_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B atwc INNER JOIN #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B art ON art.old_recid = atwc.table_id
UPDATE atwc SET atwc.condition_id = ac.new_recid FROM #alert_table_where_clause_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B atwc INNER JOIN #alert_conditions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B ac ON ac.old_recid = atwc.condition_id

print('--==============================START alert_table_where_clause=============================')
UPDATE dbo.alert_table_where_clause SET [alert_id]=src.[alert_id],[clause_type]=src.[clause_type],[column_id]=src.[column_id],[operator_id]=src.[operator_id],[column_value]=src.[column_value],[second_value]=src.[second_value],[table_id]=src.[table_id],[column_function]=src.[column_function],[condition_id]=src.[condition_id],[sequence_no]=src.[sequence_no],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','alert_table_where_clause',inserted.alert_table_where_clause_id,inserted.alert_table_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_where_clause_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN alert_table_where_clause dst  ON src.alert_table_where_clause_id=dst.alert_table_where_clause_id;
insert into alert_table_where_clause
		([alert_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[condition_id],[sequence_no],[data_source_column_id]
		)
		 OUTPUT 'i','alert_table_where_clause',inserted.alert_table_where_clause_id,inserted.alert_table_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[clause_type],src.[column_id],src.[operator_id],src.[column_value],src.[second_value],src.[table_id],src.[column_function],src.[condition_id],src.[sequence_no],src.[data_source_column_id]
		FROM #alert_table_where_clause_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN alert_table_where_clause dst  ON src.alert_table_where_clause_id=dst.alert_table_where_clause_id
		WHERE dst.[alert_table_where_clause_id] IS NULL;
UPDATE #alert_table_where_clause_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid =dst.new_id 
		FROM #alert_table_where_clause_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN #old_new_id dst  ON src.alert_table_where_clause_id=dst.unique_key1 AND dst.table_name='alert_table_where_clause'
		;
print('--==============================END alert_table_where_clause=============================')
print('--==============================START alert_actions=============================')

	if object_id('tempdb..#alert_actions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #alert_actions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [alert_actions_id] int ,[alert_id] int ,[table_id] int ,[column_id] int ,[column_value] varchar(500) COLLATE DATABASE_DEFAULT ,[condition_id] int ,[sql_statement] varchar(max) COLLATE DATABASE_DEFAULT ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_actions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #alert_actions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [alert_actions_id],[alert_id],[table_id],[column_id],[column_value],[condition_id],[sql_statement],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_actions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where alert_actions_id is null;
	update #alert_actions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set alert_id='FARRMS1_ '+cast(alert_actions_id as varchar(30))  where isnull(alert_id,'')='' ;
	
print('--==============================END alert_actions=============================')

UPDATE aa SET aa.column_id = acd.new_recid FROM #alert_actions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B aa INNER JOIN #alert_columns_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B  acd ON acd.old_recid = aa.column_id
UPDATE aa SET aa.table_id = art.new_recid FROM #alert_actions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B aa INNER JOIN #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B art ON art.old_recid = aa.table_id
UPDATE aa SET aa.condition_id = ac.new_recid FROM #alert_actions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B aa INNER JOIN #alert_conditions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B ac ON ac.old_recid = aa.condition_id
UPDATE aa SET aa.alert_id = asl.new_recid FROM #alert_actions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B aa INNER JOIN #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B asl ON asl.old_recid = aa.alert_id

print('--==============================START alert_actions=============================')
UPDATE dbo.alert_actions SET [table_id]=src.[table_id],[column_id]=src.[column_id],[column_value]=src.[column_value],[condition_id]=src.[condition_id],[sql_statement]=src.[sql_statement],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','alert_actions',inserted.alert_actions_id,inserted.alert_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_actions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN alert_actions dst  ON src.alert_id=dst.alert_id;
insert into alert_actions
		([alert_id],[table_id],[column_id],[column_value],[condition_id],[sql_statement],[data_source_column_id]
		)
		 OUTPUT 'i','alert_actions',inserted.alert_actions_id,inserted.alert_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[column_id],src.[column_value],src.[condition_id],src.[sql_statement],src.[data_source_column_id]
		FROM #alert_actions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN alert_actions dst  ON src.alert_id=dst.alert_id
		WHERE dst.[alert_actions_id] IS NULL;
UPDATE #alert_actions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid =dst.new_id 
		FROM #alert_actions_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND dst.table_name='alert_actions'
		;
print('--==============================END alert_actions=============================')
print('--==============================START alert_actions_events=============================')

	if object_id('tempdb..#alert_actions_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #alert_actions_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [alert_actions_events_id] int ,[alert_id] int ,[table_id] int ,[callback_alert_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_actions_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #alert_actions_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [alert_actions_events_id],[alert_id],[table_id],[callback_alert_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,null);
	delete #alert_actions_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where alert_actions_events_id is null;
	update #alert_actions_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set alert_id='FARRMS1_ '+cast(alert_actions_events_id as varchar(30))  where isnull(alert_id,'')='' ;
	update #alert_actions_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set table_id='FARRMS2_ '+cast(alert_actions_events_id as varchar(30))  where isnull(table_id,'')='' ;
			update #alert_actions_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set callback_alert_id='FARRMS3_ '+cast(alert_actions_events_id as varchar(30))  where isnull(callback_alert_id,'')='' ;
			
print('--==============================END alert_actions_events=============================')

UPDATE aae SET aae.alert_id = asl.new_recid FROM #alert_actions_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B aae INNER JOIN #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B asl ON asl.old_recid = aae.alert_id
UPDATE aae SET aae.table_id = art.new_recid FROM #alert_actions_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B aae INNER JOIN #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B art ON art.old_recid = aae.table_id

print('--==============================START alert_actions_events=============================')
UPDATE dbo.alert_actions_events SET [callback_alert_id]=src.[callback_alert_id]
		   OUTPUT 'u','alert_actions_events',inserted.alert_actions_events_id,inserted.alert_id,inserted.table_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_actions_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN alert_actions_events dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id;
insert into alert_actions_events
		([alert_id],[table_id],[callback_alert_id]
		)
		 OUTPUT 'i','alert_actions_events',inserted.alert_actions_events_id,inserted.alert_id,inserted.table_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[callback_alert_id]
		FROM #alert_actions_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN alert_actions_events dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id
		WHERE dst.[alert_actions_events_id] IS NULL;
UPDATE #alert_actions_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid =dst.new_id 
		FROM #alert_actions_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND dst.table_name='alert_actions_events'
		;
print('--==============================END alert_actions_events=============================')
print('--==============================START alert_table_relation=============================')

	if object_id('tempdb..#alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [alert_table_relation_id] int ,[alert_id] int ,[from_table_id] int ,[from_column_id] int ,[to_table_id] int ,[to_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [alert_table_relation_id],[alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where alert_table_relation_id is null;
	update #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set alert_id='FARRMS1_ '+cast(alert_table_relation_id as varchar(30))  where isnull(alert_id,'')='' ;
	update #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set from_table_id='FARRMS2_ '+cast(alert_table_relation_id as varchar(30))  where isnull(from_table_id,'')='' ;
			update #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set to_table_id='FARRMS3_ '+cast(alert_table_relation_id as varchar(30))  where isnull(to_table_id,'')='' ;
			
print('--==============================END alert_table_relation=============================')
	
update #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set from_column_id='FARRMS4_ '+cast(alert_table_relation_id as varchar(30))  where isnull(from_column_id,'')='' ;
update #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set to_column_id='FARRMS5_ '+cast(alert_table_relation_id as varchar(30))  where isnull(to_column_id,'')='' ;

UPDATE atr SET atr.alert_id	= asl.new_recid FROM #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B atr INNER JOIN #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B asl ON asl.old_recid = atr.alert_id		
UPDATE atr SET atr.from_table_id = atd.new_recid FROM #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B atr INNER JOIN #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B atd ON atd.old_recid = atr.from_table_id		
UPDATE atr SET atr.to_table_id = atd.new_recid FROM #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B atr INNER JOIN #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B atd ON atd.old_recid = atr.to_table_id		
UPDATE atr SET atr.from_column_id = atd.new_recid FROM #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B atr INNER JOIN #alert_columns_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B atd ON atd.old_recid = atr.from_column_id		
UPDATE atr SET atr.to_column_id = atd.new_recid FROM #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B atr INNER JOIN #alert_columns_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B atd ON atd.old_recid = atr.to_column_id		

insert into alert_table_relation
		([alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id]
		)
		 OUTPUT 'i','alert_table_relation',inserted.alert_table_relation_id,inserted.alert_id,inserted.from_table_id,inserted.to_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[from_table_id],src.[from_column_id],src.[to_table_id],src.[to_column_id]
		FROM #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN alert_table_relation dst  
		ON src.alert_id=dst.alert_id AND src.from_table_id=dst.from_table_id AND src.to_table_id=dst.to_table_id
		AND src.from_column_id=dst.from_column_id AND src.to_column_id=dst.to_column_id
		WHERE dst.[alert_table_relation_id] IS NULL;
UPDATE #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid = atr.alert_table_relation_id 
		FROM #alert_table_relation_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN alert_table_relation atr ON src.alert_id=atr.alert_id 
		AND src.from_table_id=atr.from_table_id AND src.to_table_id=atr.to_table_id 
		AND src.from_column_id=atr.from_column_id AND src.to_column_id=atr.to_column_id 
		;
print('--==============================END alert_table_relation=============================')		

print('--==============================START module_events=============================')

	if object_id('tempdb..#module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [module_events_id] int ,[modules_id] int ,[event_id] varchar(2000) COLLATE DATABASE_DEFAULT ,[workflow_name] varchar(100) COLLATE DATABASE_DEFAULT ,[workflow_owner] varchar(100) COLLATE DATABASE_DEFAULT ,[rule_table_id] int ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [module_events_id],[modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id],[is_active],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where module_events_id is null;
	update #module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set workflow_name='FARRMS1_ '+cast(module_events_id as varchar(30))  where isnull(workflow_name,'')='' ;
	
print('--==============================END module_events=============================')
	
	UPDATE me SET me.rule_table_id = atd.new_recid FROM #module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B me INNER JOIN #alert_table_definition_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B atd ON atd.old_recid = me.rule_table_id

	UPDATE dbo.module_events SET [modules_id]=src.[modules_id],[event_id]=src.[event_id],[workflow_owner]=src.[workflow_owner],[rule_table_id]=src.[rule_table_id]
			   OUTPUT 'u','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
		FROM #module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN module_events dst  ON src.workflow_name=dst.workflow_name;
	insert into module_events
			([modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id]
			)
			 OUTPUT 'i','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_id],src.[event_id],src.[workflow_name],src.[workflow_owner],src.[rule_table_id]
			FROM #module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN module_events dst  ON src.workflow_name=dst.workflow_name
			WHERE dst.[module_events_id] IS NULL;

			UPDATE #module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid = b.new_id 		
			FROM #module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B a 
			INNER JOIN 
			( SELECT TOP(1) new_id, unique_key1 FROM  #module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src 
			INNER JOIN #old_new_id dst ON src.workflow_name=dst.unique_key1 AND dst.table_name='module_events' ORDER BY new_id DESC
			) b ON a.workflow_name= b.unique_key1 

	

	UPDATE me SET me.modules_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B sdv ON sdv.old_recid = me.modules_id

	UPDATE me SET me.event_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B sdv ON sdv.old_recid = me.event_id
	
print('--==============================START event_trigger=============================')

	if object_id('tempdb..#event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [event_trigger_id] int ,[modules_event_id] int ,[alert_id] int ,[initial_event] char(1) COLLATE DATABASE_DEFAULT ,[manual_step] char(1) COLLATE DATABASE_DEFAULT ,[is_disable] char(1) COLLATE DATABASE_DEFAULT ,[report_paramset_id] varchar(max) COLLATE DATABASE_DEFAULT ,[report_filters] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [event_trigger_id],[modules_event_id],[alert_id],[initial_event],[manual_step],[is_disable],[report_paramset_id],[report_filters],old_recid
	 )
	 VALUES
	 
(1358,1174,7,'n',NULL,NULL,NULL,NULL,1358),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where event_trigger_id is null;
	update #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set modules_event_id='FARRMS1_ '+cast(event_trigger_id as varchar(30))  where isnull(modules_event_id,'')='' ;
	update #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set alert_id='FARRMS2_ '+cast(event_trigger_id as varchar(30))  where isnull(alert_id,'')='' ;
			
print('--==============================END event_trigger=============================')

		
		IF EXISTS (SELECT 1 FROM #module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B)
		BEGIN
			DELETE FROM #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B WHERE modules_event_id NOT IN (
			SELECT mebs.module_events_id FROM #module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B mebs INNER JOIN #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B et 
			ON et.modules_event_id = mebs.module_events_id)
		END
		ELSE
		BEGIN
			DELETE FROM #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B WHERE modules_event_id NOT IN 
			(SELECT meb.module_events_id FROM #module_events_bkup meb INNER JOIN #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B et 
			ON et.modules_event_id = meb.module_events_id)
		END
		
	
	UPDATE et SET et.alert_id = asl.new_recid FROM #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B et INNER JOIN #alert_sql_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B asl ON asl.old_recid = et.alert_id WHERE et.alert_id <> -1
	UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B et INNER JOIN #module_events_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B me ON me.old_recid = et.modules_event_id
	
UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B et INNER JOIN #module_events_bkup me ON me.old_recid = et.modules_event_id

	print('--==============================START event_trigger=============================')

	UPDATE event_trigger SET 
	 [initial_event] = src.[initial_event]
	, [manual_step] = src.[manual_step]
	, [is_disable] = src.[is_disable]
	, [report_paramset_id] = src.[report_paramset_id]
	, [report_filters] = src.[report_filters]
	 OUTPUT 'u','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,src.report_paramset_id  
	 INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src 
	INNER JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id

	insert into event_trigger
			([modules_event_id],[alert_id],[initial_event], [manual_step], [is_disable], [report_paramset_id], [report_filters]
			)
			 OUTPUT 'i','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,inserted.report_paramset_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_event_id],src.[alert_id],src.[initial_event], src.[manual_step], src.[is_disable], src.[report_paramset_id], src.[report_filters]
			FROM #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id
			WHERE dst.[event_trigger_id] IS NULL;
	UPDATE #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid =dst.new_id 
			FROM #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN #old_new_id dst  ON src.modules_event_id=dst.unique_key1 AND src.alert_id=dst.unique_key2 AND dst.table_name='event_trigger'
			AND ISNULL(src.report_paramset_id,-999) = ISNULL(dst.unique_key3,-999);
	print('--==============================END event_trigger=============================')
print('--==============================START workflow_event_message=============================')

	if object_id('tempdb..#workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [event_message_id] int ,[event_trigger_id] int ,[event_message_name] varchar(100) COLLATE DATABASE_DEFAULT ,[message_template_id] int ,[message] varchar(1000) COLLATE DATABASE_DEFAULT ,[mult_approval_required] char(1) COLLATE DATABASE_DEFAULT ,[comment_required] char(1) COLLATE DATABASE_DEFAULT ,[approval_action_required] char(1) COLLATE DATABASE_DEFAULT ,[self_notify] char(1) COLLATE DATABASE_DEFAULT ,[notify_trader] char(1) COLLATE DATABASE_DEFAULT ,[next_module_events_id] int ,[minimum_approval_required] int ,[optional_event_msg] char(1) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[automatic_proceed] char(1) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [event_message_id],[event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type],old_recid
	 )
	 VALUES
	 
(1256,1358,'Collateral Expiring',0,'Collateral is expiring for few counterparty. <#ALERT_REPORT>','n','n','n','y','n',NULL,NULL,'n',NULL,'n','',1256),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where event_message_id is null;
	update #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set event_trigger_id='FARRMS1_ '+cast(event_message_id as varchar(30))  where isnull(event_trigger_id,'')='' ;
	update #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set event_message_name='FARRMS2_ '+cast(event_message_id as varchar(30))  where isnull(event_message_name,'')='' ;
			
print('--==============================END workflow_event_message=============================')

		IF EXISTS (SELECT 1 FROM #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B)
		BEGIN	
			DELETE FROM #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wem INNER JOIN #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B et ON et.old_recid = wem.event_trigger_id)
		END
		

	UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wem INNER JOIN #event_trigger_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B et ON et.old_recid = wem.event_trigger_id

		UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wem INNER JOIN #event_trigger_bkup et ON et.old_recid = wem.event_trigger_id
		UPDATE wem SET wem.next_module_events_id = meb.new_recid FROM #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wem  INNER JOIN #module_events_bkup meb ON meb.old_recid = wem.next_module_events_id
print('--==============================START workflow_event_message=============================')
UPDATE dbo.workflow_event_message SET [message_template_id]=src.[message_template_id],[message]=src.[message],[mult_approval_required]=src.[mult_approval_required],[comment_required]=src.[comment_required],[approval_action_required]=src.[approval_action_required],[self_notify]=src.[self_notify],[notify_trader]=src.[notify_trader],[next_module_events_id]=src.[next_module_events_id],[minimum_approval_required]=src.[minimum_approval_required],[optional_event_msg]=src.[optional_event_msg],[counterparty_contact_type]=src.[counterparty_contact_type],[automatic_proceed]=src.[automatic_proceed],[notification_type]=src.[notification_type]
		   OUTPUT 'u','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name;
insert into workflow_event_message
		([event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type]
		)
		 OUTPUT 'i','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_trigger_id],src.[event_message_name],src.[message_template_id],src.[message],src.[mult_approval_required],src.[comment_required],src.[approval_action_required],src.[self_notify],src.[notify_trader],src.[next_module_events_id],src.[minimum_approval_required],src.[optional_event_msg],src.[counterparty_contact_type],src.[automatic_proceed],src.[notification_type]
		FROM #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name
		WHERE dst.[event_message_id] IS NULL;
UPDATE #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid =dst.new_id 
		FROM #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN #old_new_id dst  ON src.event_trigger_id=dst.unique_key1 AND src.event_message_name=dst.unique_key2 AND dst.table_name='workflow_event_message'
		;
print('--==============================END workflow_event_message=============================')
	
		INSERT INTO #workflow_event_message_bkup (event_message_id, event_trigger_id, event_message_name, message_template_id, message, mult_approval_required, comment_required, approval_action_required, self_notify, notify_trader, counterparty_contact_type, next_module_events_id, minimum_approval_required, optional_event_msg, automatic_proceed, notification_type, new_recid, old_recid)
		SELECT wem.event_message_id, wem.event_trigger_id, wem.event_message_name, wem.message_template_id, wem.message, wem.mult_approval_required, wem.comment_required, wem.approval_action_required, wem.self_notify, wem.notify_trader, wem.counterparty_contact_type, wem.next_module_events_id, wem.minimum_approval_required, wem.optional_event_msg, wem.automatic_proceed, wem.notification_type, wem.new_recid, wem.old_recid FROM #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wem
		LEFT JOIN #workflow_event_message_bkup wemb ON wemb.old_recid = wem.old_recid 
		WHERE wemb.old_recid IS NULL
print('--==============================START application_security_role=============================')

	if object_id('tempdb..#application_security_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #application_security_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [role_id] int ,[role_name] varchar(50) COLLATE DATABASE_DEFAULT ,[role_description] varchar(250) COLLATE DATABASE_DEFAULT ,[role_type_value_id] int ,[process_map_file_name] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #application_security_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #application_security_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [role_id],[role_name],[role_description],[role_type_value_id],[process_map_file_name],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,null);
	delete #application_security_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where role_id is null;
	update #application_security_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set role_name='FARRMS1_ '+cast(role_id as varchar(30))  where isnull(role_name,'')='' ;
	
UPDATE dbo.application_security_role SET [role_description]=src.[role_description],[role_type_value_id]=src.[role_type_value_id],[process_map_file_name]=src.[process_map_file_name]
		   OUTPUT 'u','application_security_role',inserted.role_id,inserted.role_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #application_security_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN application_security_role dst  ON src.role_name=dst.role_name;
insert into application_security_role
		([role_name],[role_description],[role_type_value_id],[process_map_file_name]
		)
		 OUTPUT 'i','application_security_role',inserted.role_id,inserted.role_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[role_name],src.[role_description],src.[role_type_value_id],src.[process_map_file_name]
		FROM #application_security_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN application_security_role dst  ON src.role_name=dst.role_name
		WHERE dst.[role_id] IS NULL;
UPDATE #application_security_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid =dst.new_id 
		FROM #application_security_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN #old_new_id dst  ON src.role_name=dst.unique_key1 AND dst.table_name='application_security_role'
		;
print('--==============================END application_security_role=============================')
print('--==============================START workflow_event_user_role=============================')

	if object_id('tempdb..#workflow_event_user_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #workflow_event_user_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [event_user_role_id] int ,[event_message_id] int ,[user_login_id] varchar(50) COLLATE DATABASE_DEFAULT ,[role_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_user_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #workflow_event_user_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [event_user_role_id],[event_message_id],[user_login_id],[role_id],old_recid
	 )
	 VALUES
	 
(7744,1256,'farrms_admin',NULL,7744),
(7745,1256,'bipana',NULL,7745),
(7746,1256,'bneupane',NULL,7746),
(NULL,NULL,NULL,NULL,null);
	delete #workflow_event_user_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where event_user_role_id is null;
	update #workflow_event_user_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set event_user_role_id='FARRMS1_ '+cast(event_user_role_id as varchar(30))  where isnull(event_user_role_id,'')='' ;
	
print('--==============================END workflow_event_user_role=============================')
	
		DELETE FROM #workflow_event_user_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wem INNER JOIN #workflow_event_user_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B weur ON weur.event_message_id = wem.event_message_id	)
		
	
	UPDATE weur SET weur.role_id = asr.new_recid FROM #workflow_event_user_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B weur INNER JOIN #application_security_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B asr ON asr.old_recid = weur.role_id
	UPDATE weur SET weur.event_message_id = wem.new_recid FROM #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wem INNER JOIN #workflow_event_user_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B weur ON weur.event_message_id = wem.old_recid
	
print('--==============================START workflow_event_user_role=============================')
UPDATE dbo.workflow_event_user_role SET [event_message_id]=src.[event_message_id],[user_login_id]=src.[user_login_id],[role_id]=src.[role_id]
		   OUTPUT 'u','workflow_event_user_role',inserted.event_user_role_id,inserted.event_user_role_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_user_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN workflow_event_user_role dst  ON src.event_user_role_id=dst.event_user_role_id;
insert into workflow_event_user_role
		([event_message_id],[user_login_id],[role_id]
		)
		 OUTPUT 'i','workflow_event_user_role',inserted.event_user_role_id,inserted.event_user_role_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[user_login_id],src.[role_id]
		FROM #workflow_event_user_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN workflow_event_user_role dst  ON src.event_user_role_id=dst.event_user_role_id
		WHERE dst.[event_user_role_id] IS NULL;
UPDATE #workflow_event_user_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid =dst.new_id 
		FROM #workflow_event_user_role_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN #old_new_id dst  ON src.event_user_role_id=dst.unique_key1 AND dst.table_name='workflow_event_user_role'
		;
print('--==============================END workflow_event_user_role=============================')
print('--==============================START workflow_event_message_documents=============================')

	if object_id('tempdb..#workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [message_document_id] int ,[event_message_id] int ,[document_template_id] int ,[effective_date] datetime ,[document_category] int ,[document_template] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [message_document_id],[event_message_id],[document_template_id],[effective_date],[document_category],[document_template],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where message_document_id is null;
	update #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set message_document_id='FARRMS1_ '+cast(message_document_id as varchar(30))  where isnull(message_document_id,'')='' ;
	
print('--==============================END workflow_event_message_documents=============================')

		DELETE FROM #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wemd ON wem.event_message_id = wemd.event_message_id)

	UPDATE wemd SET wemd.event_message_id = wem.new_recid FROM #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wem INNER JOIN #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wemd ON wemd.event_message_id = wem.old_recid
	UPDATE wemd SET wemd.document_template_id = sdv.new_recid FROM #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wemd INNER JOIN #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B sdv ON sdv.old_recid = wemd.document_template_id
	UPDATE wemd SET wemd.document_category = sdv.new_recid FROM #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wemd INNER JOIN #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B sdv ON sdv.old_recid = wemd.document_category
	
print('--==============================START workflow_event_message_documents=============================')
UPDATE dbo.workflow_event_message_documents SET [event_message_id]=src.[event_message_id],[document_template_id]=src.[document_template_id],[effective_date]=src.[effective_date],[document_category]=src.[document_category],[document_template]=src.[document_template]
		   OUTPUT 'u','workflow_event_message_documents',inserted.message_document_id,inserted.message_document_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN workflow_event_message_documents dst  ON src.message_document_id=dst.message_document_id;
insert into workflow_event_message_documents
		([event_message_id],[document_template_id],[effective_date],[document_category],[document_template]
		)
		 OUTPUT 'i','workflow_event_message_documents',inserted.message_document_id,inserted.message_document_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[document_template_id],src.[effective_date],src.[document_category],src.[document_template]
		FROM #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN workflow_event_message_documents dst  ON src.message_document_id=dst.message_document_id
		WHERE dst.[message_document_id] IS NULL;
UPDATE #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid =dst.new_id 
		FROM #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN #old_new_id dst  ON src.message_document_id=dst.unique_key1 AND dst.table_name='workflow_event_message_documents'
		;
print('--==============================END workflow_event_message_documents=============================')

	UPDATE w2 SET w2.new_recid = w1.message_document_id
	FROM workflow_event_message_documents w1 
	INNER JOIN #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B w2 ON w1.event_message_id = w2.event_message_id
		AND ISNULL(w1.document_template_id, '-1') = ISNULL(w2.document_template_id, '-1')
		AND ISNULL(w1.document_category, '-1') = ISNULL(w2.document_category, '-1')
print('--==============================START workflow_event_message_details=============================')

	if object_id('tempdb..#workflow_event_message_details_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #workflow_event_message_details_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [message_detail_id] int ,[event_message_document_id] int ,[message_template_id] int ,[message] varchar(500) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[delivery_method] int ,[internal_contact_type] int ,[email] varchar(300) COLLATE DATABASE_DEFAULT ,[email_cc] varchar(300) COLLATE DATABASE_DEFAULT ,[email_bcc] varchar(300) COLLATE DATABASE_DEFAULT ,[as_defined_in_contact] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_details_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #workflow_event_message_details_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [message_detail_id],[event_message_document_id],[message_template_id],[message],[counterparty_contact_type],[delivery_method],[internal_contact_type],[email],[email_cc],[email_bcc],[as_defined_in_contact],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_details_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where message_detail_id is null;
	update #workflow_event_message_details_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set message_detail_id='FARRMS1_ '+cast(message_detail_id as varchar(30))  where isnull(message_detail_id,'')='' ;
	
print('--==============================END workflow_event_message_details=============================')

	DELETE FROM #workflow_event_message_details_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B WHERE message_detail_id NOT IN (
		SELECT wemd.message_detail_id from #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wemdd 
		INNER JOIN #workflow_event_message_details_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wemd ON wemd.event_message_document_id = wemdd.message_document_id)

	UPDATE wemd SET wemd.event_message_document_id = wem.new_recid FROM #workflow_event_message_documents_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wem INNER JOIN #workflow_event_message_details_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wemd ON wemd.event_message_document_id = wem.old_recid
	UPDATE wemd SET wemd.counterparty_contact_type = sdv.new_recid FROM #workflow_event_message_details_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wemd INNER JOIN #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B  sdv ON sdv.old_recid = wemd.counterparty_contact_type
	UPDATE wemd SET wemd.delivery_method = sdv.new_recid FROM #workflow_event_message_details_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wemd INNER JOIN #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B  sdv ON sdv.old_recid = wemd.delivery_method
	UPDATE wemd SET wemd.internal_contact_type = sdv.new_recid FROM #workflow_event_message_details_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wemd INNER JOIN #static_data_value_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B  sdv ON sdv.old_recid = wemd.internal_contact_type
	
print('--==============================START workflow_event_message_details=============================')
UPDATE dbo.workflow_event_message_details SET [event_message_document_id]=src.[event_message_document_id],[message_template_id]=src.[message_template_id],[message]=src.[message],[counterparty_contact_type]=src.[counterparty_contact_type],[delivery_method]=src.[delivery_method],[internal_contact_type]=src.[internal_contact_type],[email]=src.[email],[email_cc]=src.[email_cc],[email_bcc]=src.[email_bcc],[as_defined_in_contact]=src.[as_defined_in_contact]
		   OUTPUT 'u','workflow_event_message_details',inserted.message_detail_id,inserted.message_detail_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_details_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN workflow_event_message_details dst  ON src.message_detail_id=dst.message_detail_id;
insert into workflow_event_message_details
		([event_message_document_id],[message_template_id],[message],[counterparty_contact_type],[delivery_method],[internal_contact_type],[email],[email_cc],[email_bcc],[as_defined_in_contact]
		)
		 OUTPUT 'i','workflow_event_message_details',inserted.message_detail_id,inserted.message_detail_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_document_id],src.[message_template_id],src.[message],src.[counterparty_contact_type],src.[delivery_method],src.[internal_contact_type],src.[email],src.[email_cc],src.[email_bcc],src.[as_defined_in_contact]
		FROM #workflow_event_message_details_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN workflow_event_message_details dst  ON src.message_detail_id=dst.message_detail_id
		WHERE dst.[message_detail_id] IS NULL;
UPDATE #workflow_event_message_details_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid =dst.new_id 
		FROM #workflow_event_message_details_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN #old_new_id dst  ON src.message_detail_id=dst.unique_key1 AND dst.table_name='workflow_event_message_details'
		;
print('--==============================END workflow_event_message_details=============================')
print('--==============================START alert_reports=============================')

	if object_id('tempdb..#alert_reports_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #alert_reports_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [alert_reports_id] int ,[event_message_id] int ,[report_writer] varchar(1) COLLATE DATABASE_DEFAULT ,[paramset_hash] varchar(8000) COLLATE DATABASE_DEFAULT ,[report_param] varchar(1000) COLLATE DATABASE_DEFAULT ,[report_desc] varchar(500) COLLATE DATABASE_DEFAULT ,[table_prefix] varchar(50) COLLATE DATABASE_DEFAULT ,[table_postfix] varchar(50) COLLATE DATABASE_DEFAULT ,[report_where_clause] varchar(max) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_reports_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #alert_reports_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [alert_reports_id],[event_message_id],[report_writer],[paramset_hash],[report_param],[report_desc],[table_prefix],[table_postfix],[report_where_clause],old_recid
	 )
	 VALUES
	 
(47,1256,'n','',NULL,'Collateral Expiration','collatral_voilation_','_cv','',47),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_reports_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where alert_reports_id is null;
	update #alert_reports_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set event_message_id='FARRMS1_ '+cast(alert_reports_id as varchar(30))  where isnull(event_message_id,'')='' ;
	update #alert_reports_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set report_desc='FARRMS2_ '+cast(alert_reports_id as varchar(30))  where isnull(report_desc,'')='' ;
			update #alert_reports_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set table_prefix='FARRMS3_ '+cast(alert_reports_id as varchar(30))  where isnull(table_prefix,'')='' ;
			
print('--==============================END alert_reports=============================')

		DELETE FROM #alert_reports_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_reports_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B ar ON wem.event_message_id = ar.event_message_id)

	UPDATE ar SET ar.event_message_id = wem.new_recid FROM #workflow_event_message_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B wem INNER JOIN #alert_reports_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B ar ON ar.event_message_id = wem.old_recid
	
print('--==============================START alert_reports=============================')
UPDATE dbo.alert_reports SET [report_writer]=src.[report_writer],[paramset_hash]=src.[paramset_hash],[report_param]=src.[report_param],[table_postfix]=src.[table_postfix],[report_where_clause]=src.[report_where_clause]
		   OUTPUT 'u','alert_reports',inserted.alert_reports_id,inserted.event_message_id,inserted.report_desc,inserted.table_prefix INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_reports_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN alert_reports dst  ON src.event_message_id=dst.event_message_id AND src.report_desc=dst.report_desc AND src.table_prefix=dst.table_prefix;
insert into alert_reports
		([event_message_id],[report_writer],[paramset_hash],[report_param],[report_desc],[table_prefix],[table_postfix],[report_where_clause]
		)
		 OUTPUT 'i','alert_reports',inserted.alert_reports_id,inserted.event_message_id,inserted.report_desc,inserted.table_prefix INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[report_writer],src.[paramset_hash],src.[report_param],src.[report_desc],src.[table_prefix],src.[table_postfix],src.[report_where_clause]
		FROM #alert_reports_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN alert_reports dst  ON src.event_message_id=dst.event_message_id AND src.report_desc=dst.report_desc AND src.table_prefix=dst.table_prefix
		WHERE dst.[alert_reports_id] IS NULL;
UPDATE #alert_reports_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid =dst.new_id 
		FROM #alert_reports_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN #old_new_id dst  ON src.event_message_id=dst.unique_key1 AND src.report_desc=dst.unique_key2 AND src.table_prefix=dst.unique_key3 AND dst.table_name='alert_reports'
		;
print('--==============================END alert_reports=============================')
print('--==============================START alert_report_params=============================')

	if object_id('tempdb..#alert_report_params_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B') is null 
	
	CREATE TABLE #alert_report_params_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B
	 (
	 [alert_report_params_id] int ,[event_message_id] int ,[alert_report_id] int ,[main_table_id] int ,[parameter_name] nvarchar(200) COLLATE DATABASE_DEFAULT ,[parameter_value] nvarchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_report_params_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B;
INSERT INTO #alert_report_params_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B(
	 [alert_report_params_id],[event_message_id],[alert_report_id],[main_table_id],[parameter_name],[parameter_value],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_report_params_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B where alert_report_params_id is null;
	update #alert_report_params_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B set alert_report_id='FARRMS1_ '+cast(alert_report_params_id as varchar(30))  where isnull(alert_report_id,'')='' ;
	
print('--==============================END alert_report_params=============================')

		DELETE FROM #alert_report_params_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_report_params_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B ar ON wem.event_message_id = ar.event_message_id)

	UPDATE arp SET arp.alert_report_id = ar.alert_reports_id FROM #alert_report_params_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B arp INNER JOIN #alert_reports_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B ar ON ar.old_recid = arp.alert_report_id
	UPDATE arp SET arp.main_table_id = art.alert_rule_table_id FROM #alert_report_params_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B arp INNER JOIN #alert_rule_table_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B art ON art.old_recid = arp.main_table_id
	
print('--==============================START alert_report_params=============================')
UPDATE dbo.alert_report_params SET [event_message_id]=src.[event_message_id],[main_table_id]=src.[main_table_id],[parameter_name]=src.[parameter_name],[parameter_value]=src.[parameter_value]
		   OUTPUT 'u','alert_report_params',inserted.alert_report_params_id,inserted.alert_report_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_report_params_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN alert_report_params dst  ON src.alert_report_id=dst.alert_report_id;
insert into alert_report_params
		([event_message_id],[alert_report_id],[main_table_id],[parameter_name],[parameter_value]
		)
		 OUTPUT 'i','alert_report_params',inserted.alert_report_params_id,inserted.alert_report_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[alert_report_id],src.[main_table_id],src.[parameter_name],src.[parameter_value]
		FROM #alert_report_params_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src LEFT JOIN alert_report_params dst  ON src.alert_report_id=dst.alert_report_id
		WHERE dst.[alert_report_params_id] IS NULL;
UPDATE #alert_report_params_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B SET new_recid =dst.new_id 
		FROM #alert_report_params_A08DD19E_3CB8_4FCC_9179_B8FC59AF5F7B src INNER JOIN #old_new_id dst  ON src.alert_report_id=dst.unique_key1 AND dst.table_name='alert_report_params'
		;
print('--==============================END alert_report_params=============================')
print('--==============================START static_data_value=============================')

	if object_id('tempdb..#static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [value_id] int ,[type_id] int ,[code] varchar(500) COLLATE DATABASE_DEFAULT ,[description] varchar(500) COLLATE DATABASE_DEFAULT ,[entity_id] int ,[xref_value_id] varchar(50) COLLATE DATABASE_DEFAULT ,[xref_value] varchar(250) COLLATE DATABASE_DEFAULT ,[category_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [value_id],[type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id],old_recid
	 )
	 VALUES
	 
(757,750,'Alert','Alert with Beep Sound',NULL,NULL,NULL,NULL,757),
(20610,20600,'Calendar','Calendar',NULL,NULL,NULL,NULL,20610),
(20535,20500,'Calendar - Time Based',' Calendar - Time Based',NULL,NULL,NULL,0,20535),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D where value_id is null;
	update #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D set code='FARRMS1_ '+cast(value_id as varchar(30))  where isnull(code,'')='' ;
	update #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D set type_id='FARRMS2_ '+cast(value_id as varchar(30))  where isnull(type_id,'')='' ;
			
UPDATE dbo.static_data_value SET [description]=src.[description],[entity_id]=src.[entity_id],[xref_value_id]=src.[xref_value_id],[xref_value]=src.[xref_value],[category_id]=src.[category_id]
		   OUTPUT 'u','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id;
insert into static_data_value
		([type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id]
		)
		 OUTPUT 'i','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[type_id],src.[code],src.[description],src.[entity_id],src.[xref_value_id],src.[xref_value],src.[category_id]
		FROM #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id
		WHERE dst.[value_id] IS NULL;
UPDATE #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid =dst.new_id 
		FROM #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN #old_new_id dst  ON src.code=dst.unique_key1 AND src.type_id=dst.unique_key2 AND dst.table_name='static_data_value'
		;
print('--==============================END static_data_value=============================')
print('--==============================START alert_sql=============================')

	if object_id('tempdb..#alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [alert_sql_id] int ,[workflow_only] varchar(1) COLLATE DATABASE_DEFAULT ,[message] varchar(500) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,[sql_statement] varchar(max) COLLATE DATABASE_DEFAULT ,[alert_sql_name] varchar(100) COLLATE DATABASE_DEFAULT ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,[alert_type] char(1) COLLATE DATABASE_DEFAULT ,[rule_category] int ,[system_rule] char(1) COLLATE DATABASE_DEFAULT ,[alert_category] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [alert_sql_id],[workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category],old_recid
	 )
	 VALUES
	 
(69,'n',NULL,'757','SELECT 
cg.contract_name [Contract Name] ,
CONVERT(VARCHAR(12), cg.term_start, 107) [Contract Start Date],
CONVERT(VARCHAR(12), cg.term_end, 107) [Contract End Date],
ABS(DATEDIFF(DAY,ISNULL(cg.term_end,''9999-12-31''),CURRENT_TIMESTAMP) )[Days Remaining to Expire],
''Please review Contracts.'' [Recommendation]
INTO adiha_process.dbo.contract_date_process_id_cd
FROM contract_group cg 
WHERE ABS(DATEDIFF(DAY,ISNULL(cg.term_end,''9999-12-31''),CURRENT_TIMESTAMP)) < = 5','Contract Expiration Alert','y','s',-1,'n',NULL,69),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D where alert_sql_id is null;
	update #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D set alert_sql_name='FARRMS1_ '+cast(alert_sql_id as varchar(30))  where isnull(alert_sql_name,'')='' ;
	
print('--==============================END alert_sql=============================')

UPDATE dbo.alert_sql SET [workflow_only]=src.[workflow_only],[message]=src.[message],[notification_type]=src.[notification_type],[sql_statement]=src.[sql_statement],[is_active]=src.[is_active],[alert_type]=src.[alert_type],[rule_category]=src.[rule_category],[system_rule]=src.[system_rule],[alert_category]=src.[alert_category]
		   OUTPUT 'u','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name;

IF EXISTS(SELECT 1 FROM #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D WHERE alert_sql_id < 0)
BEGIN
	SET IDENTITY_INSERT alert_sql ON
	INSERT INTO alert_sql
	([alert_sql_id], [workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category]
	)
	OUTPUT 'i','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	SELECT 
	src.alert_sql_id, src.[workflow_only],src.[message],src.[notification_type],src.[sql_statement],src.[alert_sql_name],src.[is_active],src.[alert_type],src.[rule_category],src.[system_rule],src.[alert_category]
	FROM #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
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
	FROM #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
	WHERE dst.[alert_sql_id] IS NULL;
END

UPDATE #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid = dst.new_id , alert_sql_id =  dst.new_id
FROM #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN #old_new_id dst ON src.alert_sql_name = dst.unique_key1 AND dst.table_name = 'alert_sql'

UPDATE asl SET asl.notification_type = sdv.new_recid 
FROM alert_sql asl INNER JOIN #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D sdv ON sdv.old_recid = asl.notification_type	

UPDATE asl SET asl.rule_category = sdv.new_recid
FROM alert_sql asl INNER JOIN #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D sdv ON sdv.old_recid = asl.rule_category	


	INSERT INTO #alert_sql_bkup (alert_sql_id, workflow_only, message, notification_type, sql_statement, alert_sql_name, is_active, alert_type, rule_category, system_rule, alert_category, new_recid, old_recid)
	SELECT asl.alert_sql_id, asl.workflow_only, asl.message, asl.notification_type, asl.sql_statement, asl.alert_sql_name, asl.is_active, asl.alert_type, asl.rule_category, asl.system_rule, asl.alert_category, asl.new_recid, asl.old_recid FROM #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D asl
	LEFT JOIN #alert_sql_bkup aslb ON aslb.old_recid = asl.old_recid
	WHERE aslb.old_recid IS NULL
print('--==============================START alert_table_definition=============================')

	if object_id('tempdb..#alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [alert_table_definition_id] int ,[logical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[physical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[data_source_id] int ,[is_action_view] char(1) COLLATE DATABASE_DEFAULT ,[primary_column] varchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [alert_table_definition_id],[logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D where alert_table_definition_id is null;
	update #alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D set logical_table_name='FARRMS1_ '+cast(alert_table_definition_id as varchar(30))  where isnull(logical_table_name,'')='' ;
	
UPDATE dbo.alert_table_definition SET [physical_table_name]=src.[physical_table_name],[data_source_id]=src.[data_source_id],[is_action_view]=src.[is_action_view],[primary_column]=src.[primary_column]
		   OUTPUT 'u','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name;
insert into alert_table_definition
		([logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column]
		)
		 OUTPUT 'i','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[logical_table_name],src.[physical_table_name],src.[data_source_id],src.[is_action_view],src.[primary_column]
		FROM #alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name
		WHERE dst.[alert_table_definition_id] IS NULL;
UPDATE #alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid =dst.new_id 
		FROM #alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN #old_new_id dst  ON src.logical_table_name=dst.unique_key1 AND dst.table_name='alert_table_definition'
		;
print('--==============================END alert_table_definition=============================')

UPDATE #alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D SET alert_table_definition_id = new_recid

print('--==============================START alert_columns_definition=============================')

	if object_id('tempdb..#alert_columns_definition_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #alert_columns_definition_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [alert_columns_definition_id] int ,[alert_table_id] int ,[column_name] varchar(600) COLLATE DATABASE_DEFAULT ,[is_primary] char(1) COLLATE DATABASE_DEFAULT ,[static_data_type_id] int ,[column_alias] varchar(200) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_columns_definition_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #alert_columns_definition_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [alert_columns_definition_id],[alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_columns_definition_297A7211_6F53_4A51_A45F_CD717A365E4D where alert_columns_definition_id is null;
	update #alert_columns_definition_297A7211_6F53_4A51_A45F_CD717A365E4D set column_name='FARRMS1_ '+cast(alert_columns_definition_id as varchar(30))  where isnull(column_name,'')='' ;
	
print('--==============================END alert_columns_definition=============================')

UPDATE acd SET acd.alert_table_id = atd.new_recid
FROM #alert_columns_definition_297A7211_6F53_4A51_A45F_CD717A365E4D acd INNER JOIN #alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D atd ON atd.old_recid = acd.alert_table_id

print('--==============================START alert_columns_definition=============================')
UPDATE dbo.alert_columns_definition SET [alert_table_id]=dst.[alert_table_definition_id],[is_primary]=src_c.[is_primary],[static_data_type_id]=src_c.[static_data_type_id],[column_alias]=src_c.[column_alias]
		   OUTPUT 'u','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_297A7211_6F53_4A51_A45F_CD717A365E4D src_c ON src_c.alert_table_id=src.alert_table_definition_id
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name;
insert into alert_columns_definition
		([alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias]
		)
		 OUTPUT 'i','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[alert_table_id],src_c.[column_name],src_c.[is_primary],src_c.[static_data_type_id],src_c.[column_alias]
		FROM #alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name 
			INNER JOIN #alert_columns_definition_297A7211_6F53_4A51_A45F_CD717A365E4D src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			LEFT JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name
		WHERE dst_c.[alert_table_id] IS NULL;
UPDATE #alert_columns_definition_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid =dst_c.[alert_columns_definition_id] 
			FROM #alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_297A7211_6F53_4A51_A45F_CD717A365E4D src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id
			 AND src_c.column_name=dst_c.column_name;
print('--==============================END alert_columns_definition=============================')

DELETE FROM alert_table_relation WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D)
DELETE FROM alert_actions_events WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D)
DELETE FROM alert_actions WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D)
DELETE FROM alert_table_where_clause WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D)
DELETE from alert_conditions WHERE rules_id IN (SELECT alert_sql_id FROM #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D)
DELETE from alert_rule_table where alert_id IN (SELECT alert_sql_id FROM #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D)
print('--==============================START alert_rule_table=============================')

	if object_id('tempdb..#alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [alert_rule_table_id] int ,[alert_id] int ,[table_id] int ,[root_table_id] int ,[table_alias] varchar(50) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [alert_rule_table_id],[alert_id],[table_id],[root_table_id],[table_alias],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D where alert_rule_table_id is null;
	update #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D set alert_rule_table_id='FARRMS1_ '+cast(alert_rule_table_id as varchar(30))  where isnull(alert_rule_table_id,'')='' ;
	
print('--==============================END alert_rule_table=============================')

UPDATE art SET art.alert_id = asl.new_recid
FROM #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D art INNER JOIN #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D asl ON asl.old_recid = art.alert_id

UPDATE art SET art.table_id = asd.new_recid
FROM #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D art INNER JOIN #alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D  asd ON asd.old_recid = art.table_id

UPDATE dbo.alert_rule_table SET [table_alias]=src.[table_alias]
		   OUTPUT 'u','alert_rule_table',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
insert into alert_rule_table
		([alert_id],[table_id],[root_table_id],[table_alias]
		)
		 OUTPUT 'i','alert_rule_table',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[root_table_id],src.[table_alias]
		FROM #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
		WHERE dst.[alert_rule_table_id] IS NULL;
UPDATE #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid =dst.new_id 
		FROM #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND ISNULL(src.root_table_id, -1)=ISNULL(dst.unique_key3, -1) AND dst.table_name='alert_rule_table'
		;
print('--==============================END alert_rule_table=============================')
	-- need to verify root_table_id
UPDATE art SET art.root_table_id = art2.new_recid FROM #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D art INNER JOIN #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D art2 ON art2.old_recid = art.root_table_id  
UPDATE art SET art.root_table_id = arrt.root_table_id FROM alert_rule_table art INNER JOIN #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D arrt ON arrt.new_recid = art.alert_rule_table_id 

print('--==============================START alert_conditions=============================')

	if object_id('tempdb..#alert_conditions_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #alert_conditions_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [alert_conditions_id] int ,[rules_id] int ,[alert_conditions_name] varchar(100) COLLATE DATABASE_DEFAULT ,[alert_conditions_description] varchar(500) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_conditions_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #alert_conditions_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [alert_conditions_id],[rules_id],[alert_conditions_name],[alert_conditions_description],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,null);
	delete #alert_conditions_297A7211_6F53_4A51_A45F_CD717A365E4D where alert_conditions_id is null;
	update #alert_conditions_297A7211_6F53_4A51_A45F_CD717A365E4D set alert_conditions_name='FARRMS1_ '+cast(alert_conditions_id as varchar(30))  where isnull(alert_conditions_name,'')='' ;
	
print('--==============================END alert_conditions=============================')

UPDATE ac SET rules_id = asl.new_recid	
FROM #alert_conditions_297A7211_6F53_4A51_A45F_CD717A365E4D ac INNER JOIN #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D asl ON asl.old_recid = ac.rules_id
print('--==============================START alert_conditions=============================')
UPDATE dbo.alert_conditions SET [rules_id]=dst.[alert_sql_id],[alert_conditions_description]=src_c.[alert_conditions_description]
		   OUTPUT 'u','alert_conditions',inserted.alert_conditions_id,inserted.alert_conditions_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
			INNER JOIN #alert_conditions_297A7211_6F53_4A51_A45F_CD717A365E4D src_c ON src_c.rules_id=src.alert_sql_id
			INNER JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id AND src_c.alert_conditions_name=dst_c.alert_conditions_name;
insert into alert_conditions
		([rules_id],[alert_conditions_name],[alert_conditions_description]
		)
		 OUTPUT 'i','alert_conditions',inserted.alert_conditions_id,inserted.alert_conditions_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[rules_id],src_c.[alert_conditions_name],src_c.[alert_conditions_description]
		FROM #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name 
			INNER JOIN #alert_conditions_297A7211_6F53_4A51_A45F_CD717A365E4D src_c ON src_c.rules_id=src.alert_sql_id	
			LEFT JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id AND src_c.alert_conditions_name=dst_c.alert_conditions_name
		WHERE dst_c.[rules_id] IS NULL;
UPDATE #alert_conditions_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid =dst_c.[alert_conditions_id] 
			FROM #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
			INNER JOIN #alert_conditions_297A7211_6F53_4A51_A45F_CD717A365E4D src_c ON src_c.rules_id=src.alert_sql_id	
			INNER JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id
			 AND src_c.alert_conditions_name=dst_c.alert_conditions_name;
print('--==============================END alert_conditions=============================')

UPDATE #alert_conditions_297A7211_6F53_4A51_A45F_CD717A365E4D SET alert_conditions_id = new_recid
print('--==============================START alert_table_where_clause=============================')

	if object_id('tempdb..#alert_table_where_clause_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #alert_table_where_clause_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [alert_table_where_clause_id] int ,[alert_id] int ,[clause_type] int ,[column_id] int ,[operator_id] int ,[column_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[second_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[table_id] int ,[column_function] varchar(1000) COLLATE DATABASE_DEFAULT ,[condition_id] int ,[sequence_no] int ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_where_clause_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #alert_table_where_clause_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [alert_table_where_clause_id],[alert_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[condition_id],[sequence_no],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_where_clause_297A7211_6F53_4A51_A45F_CD717A365E4D where alert_table_where_clause_id is null;
	update #alert_table_where_clause_297A7211_6F53_4A51_A45F_CD717A365E4D set alert_table_where_clause_id='FARRMS1_ '+cast(alert_table_where_clause_id as varchar(30))  where isnull(alert_table_where_clause_id,'')='' ;
	
print('--==============================END alert_table_where_clause=============================')

UPDATE atwc SET atwc.alert_id = asl.new_recid FROM #alert_table_where_clause_297A7211_6F53_4A51_A45F_CD717A365E4D atwc INNER JOIN #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D asl ON asl.old_recid = atwc.alert_id
UPDATE atwc SET atwc.column_id = acd.new_recid FROM #alert_table_where_clause_297A7211_6F53_4A51_A45F_CD717A365E4D atwc INNER JOIN #alert_columns_definition_297A7211_6F53_4A51_A45F_CD717A365E4D  acd ON acd.old_recid = atwc.column_id
UPDATE atwc SET atwc.table_id = art.new_recid FROM #alert_table_where_clause_297A7211_6F53_4A51_A45F_CD717A365E4D atwc INNER JOIN #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D art ON art.old_recid = atwc.table_id
UPDATE atwc SET atwc.condition_id = ac.new_recid FROM #alert_table_where_clause_297A7211_6F53_4A51_A45F_CD717A365E4D atwc INNER JOIN #alert_conditions_297A7211_6F53_4A51_A45F_CD717A365E4D ac ON ac.old_recid = atwc.condition_id

print('--==============================START alert_table_where_clause=============================')
UPDATE dbo.alert_table_where_clause SET [alert_id]=src.[alert_id],[clause_type]=src.[clause_type],[column_id]=src.[column_id],[operator_id]=src.[operator_id],[column_value]=src.[column_value],[second_value]=src.[second_value],[table_id]=src.[table_id],[column_function]=src.[column_function],[condition_id]=src.[condition_id],[sequence_no]=src.[sequence_no],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','alert_table_where_clause',inserted.alert_table_where_clause_id,inserted.alert_table_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_where_clause_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN alert_table_where_clause dst  ON src.alert_table_where_clause_id=dst.alert_table_where_clause_id;
insert into alert_table_where_clause
		([alert_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[condition_id],[sequence_no],[data_source_column_id]
		)
		 OUTPUT 'i','alert_table_where_clause',inserted.alert_table_where_clause_id,inserted.alert_table_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[clause_type],src.[column_id],src.[operator_id],src.[column_value],src.[second_value],src.[table_id],src.[column_function],src.[condition_id],src.[sequence_no],src.[data_source_column_id]
		FROM #alert_table_where_clause_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN alert_table_where_clause dst  ON src.alert_table_where_clause_id=dst.alert_table_where_clause_id
		WHERE dst.[alert_table_where_clause_id] IS NULL;
UPDATE #alert_table_where_clause_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid =dst.new_id 
		FROM #alert_table_where_clause_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN #old_new_id dst  ON src.alert_table_where_clause_id=dst.unique_key1 AND dst.table_name='alert_table_where_clause'
		;
print('--==============================END alert_table_where_clause=============================')
print('--==============================START alert_actions=============================')

	if object_id('tempdb..#alert_actions_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #alert_actions_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [alert_actions_id] int ,[alert_id] int ,[table_id] int ,[column_id] int ,[column_value] varchar(500) COLLATE DATABASE_DEFAULT ,[condition_id] int ,[sql_statement] varchar(max) COLLATE DATABASE_DEFAULT ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_actions_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #alert_actions_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [alert_actions_id],[alert_id],[table_id],[column_id],[column_value],[condition_id],[sql_statement],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_actions_297A7211_6F53_4A51_A45F_CD717A365E4D where alert_actions_id is null;
	update #alert_actions_297A7211_6F53_4A51_A45F_CD717A365E4D set alert_id='FARRMS1_ '+cast(alert_actions_id as varchar(30))  where isnull(alert_id,'')='' ;
	
print('--==============================END alert_actions=============================')

UPDATE aa SET aa.column_id = acd.new_recid FROM #alert_actions_297A7211_6F53_4A51_A45F_CD717A365E4D aa INNER JOIN #alert_columns_definition_297A7211_6F53_4A51_A45F_CD717A365E4D  acd ON acd.old_recid = aa.column_id
UPDATE aa SET aa.table_id = art.new_recid FROM #alert_actions_297A7211_6F53_4A51_A45F_CD717A365E4D aa INNER JOIN #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D art ON art.old_recid = aa.table_id
UPDATE aa SET aa.condition_id = ac.new_recid FROM #alert_actions_297A7211_6F53_4A51_A45F_CD717A365E4D aa INNER JOIN #alert_conditions_297A7211_6F53_4A51_A45F_CD717A365E4D ac ON ac.old_recid = aa.condition_id
UPDATE aa SET aa.alert_id = asl.new_recid FROM #alert_actions_297A7211_6F53_4A51_A45F_CD717A365E4D aa INNER JOIN #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D asl ON asl.old_recid = aa.alert_id

print('--==============================START alert_actions=============================')
UPDATE dbo.alert_actions SET [table_id]=src.[table_id],[column_id]=src.[column_id],[column_value]=src.[column_value],[condition_id]=src.[condition_id],[sql_statement]=src.[sql_statement],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','alert_actions',inserted.alert_actions_id,inserted.alert_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_actions_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN alert_actions dst  ON src.alert_id=dst.alert_id;
insert into alert_actions
		([alert_id],[table_id],[column_id],[column_value],[condition_id],[sql_statement],[data_source_column_id]
		)
		 OUTPUT 'i','alert_actions',inserted.alert_actions_id,inserted.alert_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[column_id],src.[column_value],src.[condition_id],src.[sql_statement],src.[data_source_column_id]
		FROM #alert_actions_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN alert_actions dst  ON src.alert_id=dst.alert_id
		WHERE dst.[alert_actions_id] IS NULL;
UPDATE #alert_actions_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid =dst.new_id 
		FROM #alert_actions_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND dst.table_name='alert_actions'
		;
print('--==============================END alert_actions=============================')
print('--==============================START alert_actions_events=============================')

	if object_id('tempdb..#alert_actions_events_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #alert_actions_events_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [alert_actions_events_id] int ,[alert_id] int ,[table_id] int ,[callback_alert_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_actions_events_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #alert_actions_events_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [alert_actions_events_id],[alert_id],[table_id],[callback_alert_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,null);
	delete #alert_actions_events_297A7211_6F53_4A51_A45F_CD717A365E4D where alert_actions_events_id is null;
	update #alert_actions_events_297A7211_6F53_4A51_A45F_CD717A365E4D set alert_id='FARRMS1_ '+cast(alert_actions_events_id as varchar(30))  where isnull(alert_id,'')='' ;
	update #alert_actions_events_297A7211_6F53_4A51_A45F_CD717A365E4D set table_id='FARRMS2_ '+cast(alert_actions_events_id as varchar(30))  where isnull(table_id,'')='' ;
			update #alert_actions_events_297A7211_6F53_4A51_A45F_CD717A365E4D set callback_alert_id='FARRMS3_ '+cast(alert_actions_events_id as varchar(30))  where isnull(callback_alert_id,'')='' ;
			
print('--==============================END alert_actions_events=============================')

UPDATE aae SET aae.alert_id = asl.new_recid FROM #alert_actions_events_297A7211_6F53_4A51_A45F_CD717A365E4D aae INNER JOIN #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D asl ON asl.old_recid = aae.alert_id
UPDATE aae SET aae.table_id = art.new_recid FROM #alert_actions_events_297A7211_6F53_4A51_A45F_CD717A365E4D aae INNER JOIN #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D art ON art.old_recid = aae.table_id

print('--==============================START alert_actions_events=============================')
UPDATE dbo.alert_actions_events SET [callback_alert_id]=src.[callback_alert_id]
		   OUTPUT 'u','alert_actions_events',inserted.alert_actions_events_id,inserted.alert_id,inserted.table_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_actions_events_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN alert_actions_events dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id;
insert into alert_actions_events
		([alert_id],[table_id],[callback_alert_id]
		)
		 OUTPUT 'i','alert_actions_events',inserted.alert_actions_events_id,inserted.alert_id,inserted.table_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[callback_alert_id]
		FROM #alert_actions_events_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN alert_actions_events dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id
		WHERE dst.[alert_actions_events_id] IS NULL;
UPDATE #alert_actions_events_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid =dst.new_id 
		FROM #alert_actions_events_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND dst.table_name='alert_actions_events'
		;
print('--==============================END alert_actions_events=============================')
print('--==============================START alert_table_relation=============================')

	if object_id('tempdb..#alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [alert_table_relation_id] int ,[alert_id] int ,[from_table_id] int ,[from_column_id] int ,[to_table_id] int ,[to_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [alert_table_relation_id],[alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D where alert_table_relation_id is null;
	update #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D set alert_id='FARRMS1_ '+cast(alert_table_relation_id as varchar(30))  where isnull(alert_id,'')='' ;
	update #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D set from_table_id='FARRMS2_ '+cast(alert_table_relation_id as varchar(30))  where isnull(from_table_id,'')='' ;
			update #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D set to_table_id='FARRMS3_ '+cast(alert_table_relation_id as varchar(30))  where isnull(to_table_id,'')='' ;
			
print('--==============================END alert_table_relation=============================')
	
update #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D set from_column_id='FARRMS4_ '+cast(alert_table_relation_id as varchar(30))  where isnull(from_column_id,'')='' ;
update #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D set to_column_id='FARRMS5_ '+cast(alert_table_relation_id as varchar(30))  where isnull(to_column_id,'')='' ;

UPDATE atr SET atr.alert_id	= asl.new_recid FROM #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D atr INNER JOIN #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D asl ON asl.old_recid = atr.alert_id		
UPDATE atr SET atr.from_table_id = atd.new_recid FROM #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D atr INNER JOIN #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D atd ON atd.old_recid = atr.from_table_id		
UPDATE atr SET atr.to_table_id = atd.new_recid FROM #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D atr INNER JOIN #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D atd ON atd.old_recid = atr.to_table_id		
UPDATE atr SET atr.from_column_id = atd.new_recid FROM #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D atr INNER JOIN #alert_columns_definition_297A7211_6F53_4A51_A45F_CD717A365E4D atd ON atd.old_recid = atr.from_column_id		
UPDATE atr SET atr.to_column_id = atd.new_recid FROM #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D atr INNER JOIN #alert_columns_definition_297A7211_6F53_4A51_A45F_CD717A365E4D atd ON atd.old_recid = atr.to_column_id		

insert into alert_table_relation
		([alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id]
		)
		 OUTPUT 'i','alert_table_relation',inserted.alert_table_relation_id,inserted.alert_id,inserted.from_table_id,inserted.to_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[from_table_id],src.[from_column_id],src.[to_table_id],src.[to_column_id]
		FROM #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN alert_table_relation dst  
		ON src.alert_id=dst.alert_id AND src.from_table_id=dst.from_table_id AND src.to_table_id=dst.to_table_id
		AND src.from_column_id=dst.from_column_id AND src.to_column_id=dst.to_column_id
		WHERE dst.[alert_table_relation_id] IS NULL;
UPDATE #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid = atr.alert_table_relation_id 
		FROM #alert_table_relation_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN alert_table_relation atr ON src.alert_id=atr.alert_id 
		AND src.from_table_id=atr.from_table_id AND src.to_table_id=atr.to_table_id 
		AND src.from_column_id=atr.from_column_id AND src.to_column_id=atr.to_column_id 
		;
print('--==============================END alert_table_relation=============================')		

print('--==============================START module_events=============================')

	if object_id('tempdb..#module_events_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #module_events_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [module_events_id] int ,[modules_id] int ,[event_id] varchar(2000) COLLATE DATABASE_DEFAULT ,[workflow_name] varchar(100) COLLATE DATABASE_DEFAULT ,[workflow_owner] varchar(100) COLLATE DATABASE_DEFAULT ,[rule_table_id] int ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #module_events_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #module_events_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [module_events_id],[modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id],[is_active],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #module_events_297A7211_6F53_4A51_A45F_CD717A365E4D where module_events_id is null;
	update #module_events_297A7211_6F53_4A51_A45F_CD717A365E4D set workflow_name='FARRMS1_ '+cast(module_events_id as varchar(30))  where isnull(workflow_name,'')='' ;
	
print('--==============================END module_events=============================')
	
	UPDATE me SET me.rule_table_id = atd.new_recid FROM #module_events_297A7211_6F53_4A51_A45F_CD717A365E4D me INNER JOIN #alert_table_definition_297A7211_6F53_4A51_A45F_CD717A365E4D atd ON atd.old_recid = me.rule_table_id

	UPDATE dbo.module_events SET [modules_id]=src.[modules_id],[event_id]=src.[event_id],[workflow_owner]=src.[workflow_owner],[rule_table_id]=src.[rule_table_id]
			   OUTPUT 'u','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
		FROM #module_events_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN module_events dst  ON src.workflow_name=dst.workflow_name;
	insert into module_events
			([modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id]
			)
			 OUTPUT 'i','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_id],src.[event_id],src.[workflow_name],src.[workflow_owner],src.[rule_table_id]
			FROM #module_events_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN module_events dst  ON src.workflow_name=dst.workflow_name
			WHERE dst.[module_events_id] IS NULL;

			UPDATE #module_events_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid = b.new_id 		
			FROM #module_events_297A7211_6F53_4A51_A45F_CD717A365E4D a 
			INNER JOIN 
			( SELECT TOP(1) new_id, unique_key1 FROM  #module_events_297A7211_6F53_4A51_A45F_CD717A365E4D src 
			INNER JOIN #old_new_id dst ON src.workflow_name=dst.unique_key1 AND dst.table_name='module_events' ORDER BY new_id DESC
			) b ON a.workflow_name= b.unique_key1 

	

	UPDATE me SET me.modules_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_297A7211_6F53_4A51_A45F_CD717A365E4D mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D sdv ON sdv.old_recid = me.modules_id

	UPDATE me SET me.event_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_297A7211_6F53_4A51_A45F_CD717A365E4D mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D sdv ON sdv.old_recid = me.event_id
	
print('--==============================START event_trigger=============================')

	if object_id('tempdb..#event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [event_trigger_id] int ,[modules_event_id] int ,[alert_id] int ,[initial_event] char(1) COLLATE DATABASE_DEFAULT ,[manual_step] char(1) COLLATE DATABASE_DEFAULT ,[is_disable] char(1) COLLATE DATABASE_DEFAULT ,[report_paramset_id] varchar(max) COLLATE DATABASE_DEFAULT ,[report_filters] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [event_trigger_id],[modules_event_id],[alert_id],[initial_event],[manual_step],[is_disable],[report_paramset_id],[report_filters],old_recid
	 )
	 VALUES
	 
(1359,1177,69,'n',NULL,NULL,NULL,NULL,1359),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D where event_trigger_id is null;
	update #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D set modules_event_id='FARRMS1_ '+cast(event_trigger_id as varchar(30))  where isnull(modules_event_id,'')='' ;
	update #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D set alert_id='FARRMS2_ '+cast(event_trigger_id as varchar(30))  where isnull(alert_id,'')='' ;
			
print('--==============================END event_trigger=============================')

		
		IF EXISTS (SELECT 1 FROM #module_events_297A7211_6F53_4A51_A45F_CD717A365E4D)
		BEGIN
			DELETE FROM #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D WHERE modules_event_id NOT IN (
			SELECT mebs.module_events_id FROM #module_events_297A7211_6F53_4A51_A45F_CD717A365E4D mebs INNER JOIN #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D et 
			ON et.modules_event_id = mebs.module_events_id)
		END
		ELSE
		BEGIN
			DELETE FROM #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D WHERE modules_event_id NOT IN 
			(SELECT meb.module_events_id FROM #module_events_bkup meb INNER JOIN #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D et 
			ON et.modules_event_id = meb.module_events_id)
		END
		
	
	UPDATE et SET et.alert_id = asl.new_recid FROM #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D et INNER JOIN #alert_sql_297A7211_6F53_4A51_A45F_CD717A365E4D asl ON asl.old_recid = et.alert_id WHERE et.alert_id <> -1
	UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D et INNER JOIN #module_events_297A7211_6F53_4A51_A45F_CD717A365E4D me ON me.old_recid = et.modules_event_id
	
UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D et INNER JOIN #module_events_bkup me ON me.old_recid = et.modules_event_id

	print('--==============================START event_trigger=============================')

	UPDATE event_trigger SET 
	 [initial_event] = src.[initial_event]
	, [manual_step] = src.[manual_step]
	, [is_disable] = src.[is_disable]
	, [report_paramset_id] = src.[report_paramset_id]
	, [report_filters] = src.[report_filters]
	 OUTPUT 'u','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,src.report_paramset_id  
	 INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D src 
	INNER JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id

	insert into event_trigger
			([modules_event_id],[alert_id],[initial_event], [manual_step], [is_disable], [report_paramset_id], [report_filters]
			)
			 OUTPUT 'i','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,inserted.report_paramset_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_event_id],src.[alert_id],src.[initial_event], src.[manual_step], src.[is_disable], src.[report_paramset_id], src.[report_filters]
			FROM #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id
			WHERE dst.[event_trigger_id] IS NULL;
	UPDATE #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid =dst.new_id 
			FROM #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN #old_new_id dst  ON src.modules_event_id=dst.unique_key1 AND src.alert_id=dst.unique_key2 AND dst.table_name='event_trigger'
			AND ISNULL(src.report_paramset_id,-999) = ISNULL(dst.unique_key3,-999);
	print('--==============================END event_trigger=============================')
print('--==============================START workflow_event_message=============================')

	if object_id('tempdb..#workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [event_message_id] int ,[event_trigger_id] int ,[event_message_name] varchar(100) COLLATE DATABASE_DEFAULT ,[message_template_id] int ,[message] varchar(1000) COLLATE DATABASE_DEFAULT ,[mult_approval_required] char(1) COLLATE DATABASE_DEFAULT ,[comment_required] char(1) COLLATE DATABASE_DEFAULT ,[approval_action_required] char(1) COLLATE DATABASE_DEFAULT ,[self_notify] char(1) COLLATE DATABASE_DEFAULT ,[notify_trader] char(1) COLLATE DATABASE_DEFAULT ,[next_module_events_id] int ,[minimum_approval_required] int ,[optional_event_msg] char(1) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[automatic_proceed] char(1) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [event_message_id],[event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type],old_recid
	 )
	 VALUES
	 
(1257,1359,'Contract Expiration Alert',0,'Some Contracts are expiring soon. Please review Contracts. <#ALERT_REPORT>','n','n','n','y','n',NULL,NULL,'n',NULL,'n','0',1257),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D where event_message_id is null;
	update #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D set event_trigger_id='FARRMS1_ '+cast(event_message_id as varchar(30))  where isnull(event_trigger_id,'')='' ;
	update #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D set event_message_name='FARRMS2_ '+cast(event_message_id as varchar(30))  where isnull(event_message_name,'')='' ;
			
print('--==============================END workflow_event_message=============================')

		IF EXISTS (SELECT 1 FROM #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D)
		BEGIN	
			DELETE FROM #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D wem INNER JOIN #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D et ON et.old_recid = wem.event_trigger_id)
		END
		

	UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D wem INNER JOIN #event_trigger_297A7211_6F53_4A51_A45F_CD717A365E4D et ON et.old_recid = wem.event_trigger_id

		UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D wem INNER JOIN #event_trigger_bkup et ON et.old_recid = wem.event_trigger_id
		UPDATE wem SET wem.next_module_events_id = meb.new_recid FROM #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D wem  INNER JOIN #module_events_bkup meb ON meb.old_recid = wem.next_module_events_id
print('--==============================START workflow_event_message=============================')
UPDATE dbo.workflow_event_message SET [message_template_id]=src.[message_template_id],[message]=src.[message],[mult_approval_required]=src.[mult_approval_required],[comment_required]=src.[comment_required],[approval_action_required]=src.[approval_action_required],[self_notify]=src.[self_notify],[notify_trader]=src.[notify_trader],[next_module_events_id]=src.[next_module_events_id],[minimum_approval_required]=src.[minimum_approval_required],[optional_event_msg]=src.[optional_event_msg],[counterparty_contact_type]=src.[counterparty_contact_type],[automatic_proceed]=src.[automatic_proceed],[notification_type]=src.[notification_type]
		   OUTPUT 'u','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name;
insert into workflow_event_message
		([event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type]
		)
		 OUTPUT 'i','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_trigger_id],src.[event_message_name],src.[message_template_id],src.[message],src.[mult_approval_required],src.[comment_required],src.[approval_action_required],src.[self_notify],src.[notify_trader],src.[next_module_events_id],src.[minimum_approval_required],src.[optional_event_msg],src.[counterparty_contact_type],src.[automatic_proceed],src.[notification_type]
		FROM #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name
		WHERE dst.[event_message_id] IS NULL;
UPDATE #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid =dst.new_id 
		FROM #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN #old_new_id dst  ON src.event_trigger_id=dst.unique_key1 AND src.event_message_name=dst.unique_key2 AND dst.table_name='workflow_event_message'
		;
print('--==============================END workflow_event_message=============================')
	
		INSERT INTO #workflow_event_message_bkup (event_message_id, event_trigger_id, event_message_name, message_template_id, message, mult_approval_required, comment_required, approval_action_required, self_notify, notify_trader, counterparty_contact_type, next_module_events_id, minimum_approval_required, optional_event_msg, automatic_proceed, notification_type, new_recid, old_recid)
		SELECT wem.event_message_id, wem.event_trigger_id, wem.event_message_name, wem.message_template_id, wem.message, wem.mult_approval_required, wem.comment_required, wem.approval_action_required, wem.self_notify, wem.notify_trader, wem.counterparty_contact_type, wem.next_module_events_id, wem.minimum_approval_required, wem.optional_event_msg, wem.automatic_proceed, wem.notification_type, wem.new_recid, wem.old_recid FROM #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D wem
		LEFT JOIN #workflow_event_message_bkup wemb ON wemb.old_recid = wem.old_recid 
		WHERE wemb.old_recid IS NULL
print('--==============================START application_security_role=============================')

	if object_id('tempdb..#application_security_role_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #application_security_role_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [role_id] int ,[role_name] varchar(50) COLLATE DATABASE_DEFAULT ,[role_description] varchar(250) COLLATE DATABASE_DEFAULT ,[role_type_value_id] int ,[process_map_file_name] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #application_security_role_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #application_security_role_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [role_id],[role_name],[role_description],[role_type_value_id],[process_map_file_name],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,null);
	delete #application_security_role_297A7211_6F53_4A51_A45F_CD717A365E4D where role_id is null;
	update #application_security_role_297A7211_6F53_4A51_A45F_CD717A365E4D set role_name='FARRMS1_ '+cast(role_id as varchar(30))  where isnull(role_name,'')='' ;
	
UPDATE dbo.application_security_role SET [role_description]=src.[role_description],[role_type_value_id]=src.[role_type_value_id],[process_map_file_name]=src.[process_map_file_name]
		   OUTPUT 'u','application_security_role',inserted.role_id,inserted.role_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #application_security_role_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN application_security_role dst  ON src.role_name=dst.role_name;
insert into application_security_role
		([role_name],[role_description],[role_type_value_id],[process_map_file_name]
		)
		 OUTPUT 'i','application_security_role',inserted.role_id,inserted.role_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[role_name],src.[role_description],src.[role_type_value_id],src.[process_map_file_name]
		FROM #application_security_role_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN application_security_role dst  ON src.role_name=dst.role_name
		WHERE dst.[role_id] IS NULL;
UPDATE #application_security_role_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid =dst.new_id 
		FROM #application_security_role_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN #old_new_id dst  ON src.role_name=dst.unique_key1 AND dst.table_name='application_security_role'
		;
print('--==============================END application_security_role=============================')
print('--==============================START workflow_event_user_role=============================')

	if object_id('tempdb..#workflow_event_user_role_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #workflow_event_user_role_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [event_user_role_id] int ,[event_message_id] int ,[user_login_id] varchar(50) COLLATE DATABASE_DEFAULT ,[role_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_user_role_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #workflow_event_user_role_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [event_user_role_id],[event_message_id],[user_login_id],[role_id],old_recid
	 )
	 VALUES
	 
(7747,1257,'farrms_admin',NULL,7747),
(NULL,NULL,NULL,NULL,null);
	delete #workflow_event_user_role_297A7211_6F53_4A51_A45F_CD717A365E4D where event_user_role_id is null;
	update #workflow_event_user_role_297A7211_6F53_4A51_A45F_CD717A365E4D set event_user_role_id='FARRMS1_ '+cast(event_user_role_id as varchar(30))  where isnull(event_user_role_id,'')='' ;
	
print('--==============================END workflow_event_user_role=============================')
	
		DELETE FROM #workflow_event_user_role_297A7211_6F53_4A51_A45F_CD717A365E4D WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D wem INNER JOIN #workflow_event_user_role_297A7211_6F53_4A51_A45F_CD717A365E4D weur ON weur.event_message_id = wem.event_message_id	)
		
	
	UPDATE weur SET weur.role_id = asr.new_recid FROM #workflow_event_user_role_297A7211_6F53_4A51_A45F_CD717A365E4D weur INNER JOIN #application_security_role_297A7211_6F53_4A51_A45F_CD717A365E4D asr ON asr.old_recid = weur.role_id
	UPDATE weur SET weur.event_message_id = wem.new_recid FROM #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D wem INNER JOIN #workflow_event_user_role_297A7211_6F53_4A51_A45F_CD717A365E4D weur ON weur.event_message_id = wem.old_recid
	
print('--==============================START workflow_event_user_role=============================')
UPDATE dbo.workflow_event_user_role SET [event_message_id]=src.[event_message_id],[user_login_id]=src.[user_login_id],[role_id]=src.[role_id]
		   OUTPUT 'u','workflow_event_user_role',inserted.event_user_role_id,inserted.event_user_role_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_user_role_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN workflow_event_user_role dst  ON src.event_user_role_id=dst.event_user_role_id;
insert into workflow_event_user_role
		([event_message_id],[user_login_id],[role_id]
		)
		 OUTPUT 'i','workflow_event_user_role',inserted.event_user_role_id,inserted.event_user_role_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[user_login_id],src.[role_id]
		FROM #workflow_event_user_role_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN workflow_event_user_role dst  ON src.event_user_role_id=dst.event_user_role_id
		WHERE dst.[event_user_role_id] IS NULL;
UPDATE #workflow_event_user_role_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid =dst.new_id 
		FROM #workflow_event_user_role_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN #old_new_id dst  ON src.event_user_role_id=dst.unique_key1 AND dst.table_name='workflow_event_user_role'
		;
print('--==============================END workflow_event_user_role=============================')
print('--==============================START workflow_event_message_documents=============================')

	if object_id('tempdb..#workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [message_document_id] int ,[event_message_id] int ,[document_template_id] int ,[effective_date] datetime ,[document_category] int ,[document_template] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [message_document_id],[event_message_id],[document_template_id],[effective_date],[document_category],[document_template],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D where message_document_id is null;
	update #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D set message_document_id='FARRMS1_ '+cast(message_document_id as varchar(30))  where isnull(message_document_id,'')='' ;
	
print('--==============================END workflow_event_message_documents=============================')

		DELETE FROM #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D wemd ON wem.event_message_id = wemd.event_message_id)

	UPDATE wemd SET wemd.event_message_id = wem.new_recid FROM #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D wem INNER JOIN #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D wemd ON wemd.event_message_id = wem.old_recid
	UPDATE wemd SET wemd.document_template_id = sdv.new_recid FROM #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D wemd INNER JOIN #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D sdv ON sdv.old_recid = wemd.document_template_id
	UPDATE wemd SET wemd.document_category = sdv.new_recid FROM #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D wemd INNER JOIN #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D sdv ON sdv.old_recid = wemd.document_category
	
print('--==============================START workflow_event_message_documents=============================')
UPDATE dbo.workflow_event_message_documents SET [event_message_id]=src.[event_message_id],[document_template_id]=src.[document_template_id],[effective_date]=src.[effective_date],[document_category]=src.[document_category],[document_template]=src.[document_template]
		   OUTPUT 'u','workflow_event_message_documents',inserted.message_document_id,inserted.message_document_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN workflow_event_message_documents dst  ON src.message_document_id=dst.message_document_id;
insert into workflow_event_message_documents
		([event_message_id],[document_template_id],[effective_date],[document_category],[document_template]
		)
		 OUTPUT 'i','workflow_event_message_documents',inserted.message_document_id,inserted.message_document_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[document_template_id],src.[effective_date],src.[document_category],src.[document_template]
		FROM #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN workflow_event_message_documents dst  ON src.message_document_id=dst.message_document_id
		WHERE dst.[message_document_id] IS NULL;
UPDATE #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid =dst.new_id 
		FROM #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN #old_new_id dst  ON src.message_document_id=dst.unique_key1 AND dst.table_name='workflow_event_message_documents'
		;
print('--==============================END workflow_event_message_documents=============================')

	UPDATE w2 SET w2.new_recid = w1.message_document_id
	FROM workflow_event_message_documents w1 
	INNER JOIN #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D w2 ON w1.event_message_id = w2.event_message_id
		AND ISNULL(w1.document_template_id, '-1') = ISNULL(w2.document_template_id, '-1')
		AND ISNULL(w1.document_category, '-1') = ISNULL(w2.document_category, '-1')
print('--==============================START workflow_event_message_details=============================')

	if object_id('tempdb..#workflow_event_message_details_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #workflow_event_message_details_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [message_detail_id] int ,[event_message_document_id] int ,[message_template_id] int ,[message] varchar(500) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[delivery_method] int ,[internal_contact_type] int ,[email] varchar(300) COLLATE DATABASE_DEFAULT ,[email_cc] varchar(300) COLLATE DATABASE_DEFAULT ,[email_bcc] varchar(300) COLLATE DATABASE_DEFAULT ,[as_defined_in_contact] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_details_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #workflow_event_message_details_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [message_detail_id],[event_message_document_id],[message_template_id],[message],[counterparty_contact_type],[delivery_method],[internal_contact_type],[email],[email_cc],[email_bcc],[as_defined_in_contact],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_details_297A7211_6F53_4A51_A45F_CD717A365E4D where message_detail_id is null;
	update #workflow_event_message_details_297A7211_6F53_4A51_A45F_CD717A365E4D set message_detail_id='FARRMS1_ '+cast(message_detail_id as varchar(30))  where isnull(message_detail_id,'')='' ;
	
print('--==============================END workflow_event_message_details=============================')

	DELETE FROM #workflow_event_message_details_297A7211_6F53_4A51_A45F_CD717A365E4D WHERE message_detail_id NOT IN (
		SELECT wemd.message_detail_id from #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D wemdd 
		INNER JOIN #workflow_event_message_details_297A7211_6F53_4A51_A45F_CD717A365E4D wemd ON wemd.event_message_document_id = wemdd.message_document_id)

	UPDATE wemd SET wemd.event_message_document_id = wem.new_recid FROM #workflow_event_message_documents_297A7211_6F53_4A51_A45F_CD717A365E4D wem INNER JOIN #workflow_event_message_details_297A7211_6F53_4A51_A45F_CD717A365E4D wemd ON wemd.event_message_document_id = wem.old_recid
	UPDATE wemd SET wemd.counterparty_contact_type = sdv.new_recid FROM #workflow_event_message_details_297A7211_6F53_4A51_A45F_CD717A365E4D wemd INNER JOIN #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D  sdv ON sdv.old_recid = wemd.counterparty_contact_type
	UPDATE wemd SET wemd.delivery_method = sdv.new_recid FROM #workflow_event_message_details_297A7211_6F53_4A51_A45F_CD717A365E4D wemd INNER JOIN #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D  sdv ON sdv.old_recid = wemd.delivery_method
	UPDATE wemd SET wemd.internal_contact_type = sdv.new_recid FROM #workflow_event_message_details_297A7211_6F53_4A51_A45F_CD717A365E4D wemd INNER JOIN #static_data_value_297A7211_6F53_4A51_A45F_CD717A365E4D  sdv ON sdv.old_recid = wemd.internal_contact_type
	
print('--==============================START workflow_event_message_details=============================')
UPDATE dbo.workflow_event_message_details SET [event_message_document_id]=src.[event_message_document_id],[message_template_id]=src.[message_template_id],[message]=src.[message],[counterparty_contact_type]=src.[counterparty_contact_type],[delivery_method]=src.[delivery_method],[internal_contact_type]=src.[internal_contact_type],[email]=src.[email],[email_cc]=src.[email_cc],[email_bcc]=src.[email_bcc],[as_defined_in_contact]=src.[as_defined_in_contact]
		   OUTPUT 'u','workflow_event_message_details',inserted.message_detail_id,inserted.message_detail_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_details_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN workflow_event_message_details dst  ON src.message_detail_id=dst.message_detail_id;
insert into workflow_event_message_details
		([event_message_document_id],[message_template_id],[message],[counterparty_contact_type],[delivery_method],[internal_contact_type],[email],[email_cc],[email_bcc],[as_defined_in_contact]
		)
		 OUTPUT 'i','workflow_event_message_details',inserted.message_detail_id,inserted.message_detail_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_document_id],src.[message_template_id],src.[message],src.[counterparty_contact_type],src.[delivery_method],src.[internal_contact_type],src.[email],src.[email_cc],src.[email_bcc],src.[as_defined_in_contact]
		FROM #workflow_event_message_details_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN workflow_event_message_details dst  ON src.message_detail_id=dst.message_detail_id
		WHERE dst.[message_detail_id] IS NULL;
UPDATE #workflow_event_message_details_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid =dst.new_id 
		FROM #workflow_event_message_details_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN #old_new_id dst  ON src.message_detail_id=dst.unique_key1 AND dst.table_name='workflow_event_message_details'
		;
print('--==============================END workflow_event_message_details=============================')
print('--==============================START alert_reports=============================')

	if object_id('tempdb..#alert_reports_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #alert_reports_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [alert_reports_id] int ,[event_message_id] int ,[report_writer] varchar(1) COLLATE DATABASE_DEFAULT ,[paramset_hash] varchar(8000) COLLATE DATABASE_DEFAULT ,[report_param] varchar(1000) COLLATE DATABASE_DEFAULT ,[report_desc] varchar(500) COLLATE DATABASE_DEFAULT ,[table_prefix] varchar(50) COLLATE DATABASE_DEFAULT ,[table_postfix] varchar(50) COLLATE DATABASE_DEFAULT ,[report_where_clause] varchar(max) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_reports_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #alert_reports_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [alert_reports_id],[event_message_id],[report_writer],[paramset_hash],[report_param],[report_desc],[table_prefix],[table_postfix],[report_where_clause],old_recid
	 )
	 VALUES
	 
(48,1257,'n','',NULL,'Contract Expiration','contract_date_','_cd',NULL,48),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_reports_297A7211_6F53_4A51_A45F_CD717A365E4D where alert_reports_id is null;
	update #alert_reports_297A7211_6F53_4A51_A45F_CD717A365E4D set event_message_id='FARRMS1_ '+cast(alert_reports_id as varchar(30))  where isnull(event_message_id,'')='' ;
	update #alert_reports_297A7211_6F53_4A51_A45F_CD717A365E4D set report_desc='FARRMS2_ '+cast(alert_reports_id as varchar(30))  where isnull(report_desc,'')='' ;
			update #alert_reports_297A7211_6F53_4A51_A45F_CD717A365E4D set table_prefix='FARRMS3_ '+cast(alert_reports_id as varchar(30))  where isnull(table_prefix,'')='' ;
			
print('--==============================END alert_reports=============================')

		DELETE FROM #alert_reports_297A7211_6F53_4A51_A45F_CD717A365E4D WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_reports_297A7211_6F53_4A51_A45F_CD717A365E4D ar ON wem.event_message_id = ar.event_message_id)

	UPDATE ar SET ar.event_message_id = wem.new_recid FROM #workflow_event_message_297A7211_6F53_4A51_A45F_CD717A365E4D wem INNER JOIN #alert_reports_297A7211_6F53_4A51_A45F_CD717A365E4D ar ON ar.event_message_id = wem.old_recid
	
print('--==============================START alert_reports=============================')
UPDATE dbo.alert_reports SET [report_writer]=src.[report_writer],[paramset_hash]=src.[paramset_hash],[report_param]=src.[report_param],[table_postfix]=src.[table_postfix],[report_where_clause]=src.[report_where_clause]
		   OUTPUT 'u','alert_reports',inserted.alert_reports_id,inserted.event_message_id,inserted.report_desc,inserted.table_prefix INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_reports_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN alert_reports dst  ON src.event_message_id=dst.event_message_id AND src.report_desc=dst.report_desc AND src.table_prefix=dst.table_prefix;
insert into alert_reports
		([event_message_id],[report_writer],[paramset_hash],[report_param],[report_desc],[table_prefix],[table_postfix],[report_where_clause]
		)
		 OUTPUT 'i','alert_reports',inserted.alert_reports_id,inserted.event_message_id,inserted.report_desc,inserted.table_prefix INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[report_writer],src.[paramset_hash],src.[report_param],src.[report_desc],src.[table_prefix],src.[table_postfix],src.[report_where_clause]
		FROM #alert_reports_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN alert_reports dst  ON src.event_message_id=dst.event_message_id AND src.report_desc=dst.report_desc AND src.table_prefix=dst.table_prefix
		WHERE dst.[alert_reports_id] IS NULL;
UPDATE #alert_reports_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid =dst.new_id 
		FROM #alert_reports_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN #old_new_id dst  ON src.event_message_id=dst.unique_key1 AND src.report_desc=dst.unique_key2 AND src.table_prefix=dst.unique_key3 AND dst.table_name='alert_reports'
		;
print('--==============================END alert_reports=============================')
print('--==============================START alert_report_params=============================')

	if object_id('tempdb..#alert_report_params_297A7211_6F53_4A51_A45F_CD717A365E4D') is null 
	
	CREATE TABLE #alert_report_params_297A7211_6F53_4A51_A45F_CD717A365E4D
	 (
	 [alert_report_params_id] int ,[event_message_id] int ,[alert_report_id] int ,[main_table_id] int ,[parameter_name] nvarchar(200) COLLATE DATABASE_DEFAULT ,[parameter_value] nvarchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_report_params_297A7211_6F53_4A51_A45F_CD717A365E4D;
INSERT INTO #alert_report_params_297A7211_6F53_4A51_A45F_CD717A365E4D(
	 [alert_report_params_id],[event_message_id],[alert_report_id],[main_table_id],[parameter_name],[parameter_value],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_report_params_297A7211_6F53_4A51_A45F_CD717A365E4D where alert_report_params_id is null;
	update #alert_report_params_297A7211_6F53_4A51_A45F_CD717A365E4D set alert_report_id='FARRMS1_ '+cast(alert_report_params_id as varchar(30))  where isnull(alert_report_id,'')='' ;
	
print('--==============================END alert_report_params=============================')

		DELETE FROM #alert_report_params_297A7211_6F53_4A51_A45F_CD717A365E4D WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_report_params_297A7211_6F53_4A51_A45F_CD717A365E4D ar ON wem.event_message_id = ar.event_message_id)

	UPDATE arp SET arp.alert_report_id = ar.alert_reports_id FROM #alert_report_params_297A7211_6F53_4A51_A45F_CD717A365E4D arp INNER JOIN #alert_reports_297A7211_6F53_4A51_A45F_CD717A365E4D ar ON ar.old_recid = arp.alert_report_id
	UPDATE arp SET arp.main_table_id = art.alert_rule_table_id FROM #alert_report_params_297A7211_6F53_4A51_A45F_CD717A365E4D arp INNER JOIN #alert_rule_table_297A7211_6F53_4A51_A45F_CD717A365E4D art ON art.old_recid = arp.main_table_id
	
print('--==============================START alert_report_params=============================')
UPDATE dbo.alert_report_params SET [event_message_id]=src.[event_message_id],[main_table_id]=src.[main_table_id],[parameter_name]=src.[parameter_name],[parameter_value]=src.[parameter_value]
		   OUTPUT 'u','alert_report_params',inserted.alert_report_params_id,inserted.alert_report_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_report_params_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN alert_report_params dst  ON src.alert_report_id=dst.alert_report_id;
insert into alert_report_params
		([event_message_id],[alert_report_id],[main_table_id],[parameter_name],[parameter_value]
		)
		 OUTPUT 'i','alert_report_params',inserted.alert_report_params_id,inserted.alert_report_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[alert_report_id],src.[main_table_id],src.[parameter_name],src.[parameter_value]
		FROM #alert_report_params_297A7211_6F53_4A51_A45F_CD717A365E4D src LEFT JOIN alert_report_params dst  ON src.alert_report_id=dst.alert_report_id
		WHERE dst.[alert_report_params_id] IS NULL;
UPDATE #alert_report_params_297A7211_6F53_4A51_A45F_CD717A365E4D SET new_recid =dst.new_id 
		FROM #alert_report_params_297A7211_6F53_4A51_A45F_CD717A365E4D src INNER JOIN #old_new_id dst  ON src.alert_report_id=dst.unique_key1 AND dst.table_name='alert_report_params'
		;
print('--==============================END alert_report_params=============================')
print('--==============================START static_data_value=============================')

	if object_id('tempdb..#static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [value_id] int ,[type_id] int ,[code] varchar(500) COLLATE DATABASE_DEFAULT ,[description] varchar(500) COLLATE DATABASE_DEFAULT ,[entity_id] int ,[xref_value_id] varchar(50) COLLATE DATABASE_DEFAULT ,[xref_value] varchar(250) COLLATE DATABASE_DEFAULT ,[category_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [value_id],[type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id],old_recid
	 )
	 VALUES
	 
(757,750,'Alert','Alert with Beep Sound',NULL,NULL,NULL,NULL,757),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA where value_id is null;
	update #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA set code='FARRMS1_ '+cast(value_id as varchar(30))  where isnull(code,'')='' ;
	update #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA set type_id='FARRMS2_ '+cast(value_id as varchar(30))  where isnull(type_id,'')='' ;
			
UPDATE dbo.static_data_value SET [description]=src.[description],[entity_id]=src.[entity_id],[xref_value_id]=src.[xref_value_id],[xref_value]=src.[xref_value],[category_id]=src.[category_id]
		   OUTPUT 'u','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id;
insert into static_data_value
		([type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id]
		)
		 OUTPUT 'i','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[type_id],src.[code],src.[description],src.[entity_id],src.[xref_value_id],src.[xref_value],src.[category_id]
		FROM #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id
		WHERE dst.[value_id] IS NULL;
UPDATE #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid =dst.new_id 
		FROM #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN #old_new_id dst  ON src.code=dst.unique_key1 AND src.type_id=dst.unique_key2 AND dst.table_name='static_data_value'
		;
print('--==============================END static_data_value=============================')
print('--==============================START alert_sql=============================')

	if object_id('tempdb..#alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [alert_sql_id] int ,[workflow_only] varchar(1) COLLATE DATABASE_DEFAULT ,[message] varchar(500) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,[sql_statement] varchar(max) COLLATE DATABASE_DEFAULT ,[alert_sql_name] varchar(100) COLLATE DATABASE_DEFAULT ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,[alert_type] char(1) COLLATE DATABASE_DEFAULT ,[rule_category] int ,[system_rule] char(1) COLLATE DATABASE_DEFAULT ,[alert_category] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [alert_sql_id],[workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category],old_recid
	 )
	 VALUES
	 
(71,'n',NULL,'757','IF OBJECT_ID(''tempdb..#temp_deals'') IS NOT NULL
 DROP TABLE #temp_deals
 
SELECT dbo.FNATrmHyperlink(''i'', 10131010, sdh.source_deal_header_id, sdh.source_deal_header_id, ''n'', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT) [Deal ID],
       sdh.deal_id [Reference ID],
       sc.counterparty_id [Counterparty],
       cg.contract_name [Contract],
       dbo.FNADateFormat(sdd.term_start) [Flow Date],
       sml.location_id [Location],
       sc_up.counterparty_name [Upstream Cpty],
    udddf_contract.udf_value [Upstream Contract],
       udddf_duns.udf_value [Upstream Duns],
       REPLACE(CONVERT(VARCHAR, CAST(sdd.deal_volume AS MONEY), 1), ''.00'', '''') [Volume],
    au.user_f_name + '' '' + ISNULL(au.user_m_name + '' '', '''') + au.user_l_name + '' ('' + sdh.create_user + '')'' [Trader]
INTO #temp_deals
FROM source_deal_header sdh 
OUTER APPLY (SELECT TOP(1) * FROM source_deal_detail sdd WHERE sdh.source_deal_header_id = sdd.source_deal_header_id ORDER BY sdd.leg, sdd.term_start) sdd
INNER JOIN source_minor_location sml ON  sdd.location_id = sml.source_minor_location_id
INNER JOIN source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id
INNER JOIN contract_group cg ON sdh.contract_id = cg.contract_id
INNER JOIN source_deal_header_template sdht 
 ON sdht.template_id = sdh.template_id
 AND sdht.template_name IN (''1Index Physical Gas'', ''FP Physical Gas'', ''Free Formula PHY NG'', ''Formula Phy Gas'', ''Physical NG'')
INNER JOIN user_defined_deal_fields_template uddft_cpty
    ON  uddft_cpty.field_name = 303948
AND uddft_cpty.template_id = sdh.template_id
LEFT JOIN user_defined_deal_detail_fields udddf_cpty
    ON  udddf_cpty.source_deal_detail_id = sdd.source_deal_detail_id
    AND uddft_cpty.udf_template_id = udddf_cpty.udf_template_id
INNER JOIN user_defined_deal_fields_template uddft_duns
    ON  uddft_duns.field_name = 303949
 AND uddft_duns.template_id = sdh.template_id
LEFT JOIN user_defined_deal_detail_fields udddf_duns
    ON  udddf_duns.source_deal_detail_id = sdd.source_deal_detail_id
    AND uddft_duns.udf_template_id = udddf_duns.udf_template_id
INNER JOIN user_defined_deal_fields_template uddft_contract
    ON  uddft_contract.field_name = 303947
 AND uddft_contract.template_id = sdh.template_id
LEFT JOIN user_defined_deal_detail_fields udddf_contract
    ON  udddf_contract.source_deal_detail_id = sdd.source_deal_detail_id
    AND uddft_contract.udf_template_id = udddf_contract.udf_template_id
LEFT JOIN source_counterparty sc_up ON sc_up.source_counterparty_id = udddf_cpty.udf_value
INNER JOIN application_users au ON au.user_login_id = sdh.create_user
WHERE (sml.location_name = ''UNKNOWN_LOCATION'' OR  NULLIF(udddf_cpty.udf_value, '''') IS NULL OR NULLIF(udddf_contract.udf_value, '''') IS NULL)
AND DATEDIFF(day, GETDATE(), sdd.term_start) < 10 
AND DATEDIFF(day, GETDATE(), sdd.term_start) > -1 
ORDER BY sdd.term_start

IF EXISTS (SELECT 1 FROM #temp_deals) 
BEGIN
 SELECT * INTO staging_table.alert_incomplete_deal_process_id_aid FROM #temp_deals
 
 IF EXISTS (SELECT * FROM adiha_process.sys.tables WHERE [name] = ''alert_deal_process_id_ad'')
 BEGIN
  UPDATE staging_table.alert_deal_process_id_ad
  SET hyperlink1 = NULL,
  hyperlink2 = NULL
 END

 EXEC spa_insert_alert_output_status var_alert_sql_id, ''process_id'', NULL, NULL, NULL
END
BEGIN
RETURN
END','Incomplete Deal Alert','y','s',-1,'n',NULL,71),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA where alert_sql_id is null;
	update #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA set alert_sql_name='FARRMS1_ '+cast(alert_sql_id as varchar(30))  where isnull(alert_sql_name,'')='' ;
	
print('--==============================END alert_sql=============================')

UPDATE dbo.alert_sql SET [workflow_only]=src.[workflow_only],[message]=src.[message],[notification_type]=src.[notification_type],[sql_statement]=src.[sql_statement],[is_active]=src.[is_active],[alert_type]=src.[alert_type],[rule_category]=src.[rule_category],[system_rule]=src.[system_rule],[alert_category]=src.[alert_category]
		   OUTPUT 'u','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name;

IF EXISTS(SELECT 1 FROM #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA WHERE alert_sql_id < 0)
BEGIN
	SET IDENTITY_INSERT alert_sql ON
	INSERT INTO alert_sql
	([alert_sql_id], [workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category]
	)
	OUTPUT 'i','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	SELECT 
	src.alert_sql_id, src.[workflow_only],src.[message],src.[notification_type],src.[sql_statement],src.[alert_sql_name],src.[is_active],src.[alert_type],src.[rule_category],src.[system_rule],src.[alert_category]
	FROM #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
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
	FROM #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
	WHERE dst.[alert_sql_id] IS NULL;
END

UPDATE #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid = dst.new_id , alert_sql_id =  dst.new_id
FROM #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN #old_new_id dst ON src.alert_sql_name = dst.unique_key1 AND dst.table_name = 'alert_sql'

UPDATE asl SET asl.notification_type = sdv.new_recid 
FROM alert_sql asl INNER JOIN #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA sdv ON sdv.old_recid = asl.notification_type	

UPDATE asl SET asl.rule_category = sdv.new_recid
FROM alert_sql asl INNER JOIN #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA sdv ON sdv.old_recid = asl.rule_category	


	INSERT INTO #alert_sql_bkup (alert_sql_id, workflow_only, message, notification_type, sql_statement, alert_sql_name, is_active, alert_type, rule_category, system_rule, alert_category, new_recid, old_recid)
	SELECT asl.alert_sql_id, asl.workflow_only, asl.message, asl.notification_type, asl.sql_statement, asl.alert_sql_name, asl.is_active, asl.alert_type, asl.rule_category, asl.system_rule, asl.alert_category, asl.new_recid, asl.old_recid FROM #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA asl
	LEFT JOIN #alert_sql_bkup aslb ON aslb.old_recid = asl.old_recid
	WHERE aslb.old_recid IS NULL
print('--==============================START alert_table_definition=============================')

	if object_id('tempdb..#alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [alert_table_definition_id] int ,[logical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[physical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[data_source_id] int ,[is_action_view] char(1) COLLATE DATABASE_DEFAULT ,[primary_column] varchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [alert_table_definition_id],[logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA where alert_table_definition_id is null;
	update #alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA set logical_table_name='FARRMS1_ '+cast(alert_table_definition_id as varchar(30))  where isnull(logical_table_name,'')='' ;
	
UPDATE dbo.alert_table_definition SET [physical_table_name]=src.[physical_table_name],[data_source_id]=src.[data_source_id],[is_action_view]=src.[is_action_view],[primary_column]=src.[primary_column]
		   OUTPUT 'u','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name;
insert into alert_table_definition
		([logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column]
		)
		 OUTPUT 'i','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[logical_table_name],src.[physical_table_name],src.[data_source_id],src.[is_action_view],src.[primary_column]
		FROM #alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name
		WHERE dst.[alert_table_definition_id] IS NULL;
UPDATE #alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid =dst.new_id 
		FROM #alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN #old_new_id dst  ON src.logical_table_name=dst.unique_key1 AND dst.table_name='alert_table_definition'
		;
print('--==============================END alert_table_definition=============================')

UPDATE #alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA SET alert_table_definition_id = new_recid

print('--==============================START alert_columns_definition=============================')

	if object_id('tempdb..#alert_columns_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #alert_columns_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [alert_columns_definition_id] int ,[alert_table_id] int ,[column_name] varchar(600) COLLATE DATABASE_DEFAULT ,[is_primary] char(1) COLLATE DATABASE_DEFAULT ,[static_data_type_id] int ,[column_alias] varchar(200) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_columns_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #alert_columns_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [alert_columns_definition_id],[alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_columns_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA where alert_columns_definition_id is null;
	update #alert_columns_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA set column_name='FARRMS1_ '+cast(alert_columns_definition_id as varchar(30))  where isnull(column_name,'')='' ;
	
print('--==============================END alert_columns_definition=============================')

UPDATE acd SET acd.alert_table_id = atd.new_recid
FROM #alert_columns_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA acd INNER JOIN #alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA atd ON atd.old_recid = acd.alert_table_id

print('--==============================START alert_columns_definition=============================')
UPDATE dbo.alert_columns_definition SET [alert_table_id]=dst.[alert_table_definition_id],[is_primary]=src_c.[is_primary],[static_data_type_id]=src_c.[static_data_type_id],[column_alias]=src_c.[column_alias]
		   OUTPUT 'u','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA src_c ON src_c.alert_table_id=src.alert_table_definition_id
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name;
insert into alert_columns_definition
		([alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias]
		)
		 OUTPUT 'i','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[alert_table_id],src_c.[column_name],src_c.[is_primary],src_c.[static_data_type_id],src_c.[column_alias]
		FROM #alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name 
			INNER JOIN #alert_columns_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			LEFT JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name
		WHERE dst_c.[alert_table_id] IS NULL;
UPDATE #alert_columns_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid =dst_c.[alert_columns_definition_id] 
			FROM #alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id
			 AND src_c.column_name=dst_c.column_name;
print('--==============================END alert_columns_definition=============================')

DELETE FROM alert_table_relation WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA)
DELETE FROM alert_actions_events WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA)
DELETE FROM alert_actions WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA)
DELETE FROM alert_table_where_clause WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA)
DELETE from alert_conditions WHERE rules_id IN (SELECT alert_sql_id FROM #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA)
DELETE from alert_rule_table where alert_id IN (SELECT alert_sql_id FROM #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA)
print('--==============================START alert_rule_table=============================')

	if object_id('tempdb..#alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [alert_rule_table_id] int ,[alert_id] int ,[table_id] int ,[root_table_id] int ,[table_alias] varchar(50) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [alert_rule_table_id],[alert_id],[table_id],[root_table_id],[table_alias],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA where alert_rule_table_id is null;
	update #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA set alert_rule_table_id='FARRMS1_ '+cast(alert_rule_table_id as varchar(30))  where isnull(alert_rule_table_id,'')='' ;
	
print('--==============================END alert_rule_table=============================')

UPDATE art SET art.alert_id = asl.new_recid
FROM #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA art INNER JOIN #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA asl ON asl.old_recid = art.alert_id

UPDATE art SET art.table_id = asd.new_recid
FROM #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA art INNER JOIN #alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA  asd ON asd.old_recid = art.table_id

UPDATE dbo.alert_rule_table SET [table_alias]=src.[table_alias]
		   OUTPUT 'u','alert_rule_table',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
insert into alert_rule_table
		([alert_id],[table_id],[root_table_id],[table_alias]
		)
		 OUTPUT 'i','alert_rule_table',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[root_table_id],src.[table_alias]
		FROM #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
		WHERE dst.[alert_rule_table_id] IS NULL;
UPDATE #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid =dst.new_id 
		FROM #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND ISNULL(src.root_table_id, -1)=ISNULL(dst.unique_key3, -1) AND dst.table_name='alert_rule_table'
		;
print('--==============================END alert_rule_table=============================')
	-- need to verify root_table_id
UPDATE art SET art.root_table_id = art2.new_recid FROM #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA art INNER JOIN #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA art2 ON art2.old_recid = art.root_table_id  
UPDATE art SET art.root_table_id = arrt.root_table_id FROM alert_rule_table art INNER JOIN #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA arrt ON arrt.new_recid = art.alert_rule_table_id 

print('--==============================START alert_conditions=============================')

	if object_id('tempdb..#alert_conditions_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #alert_conditions_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [alert_conditions_id] int ,[rules_id] int ,[alert_conditions_name] varchar(100) COLLATE DATABASE_DEFAULT ,[alert_conditions_description] varchar(500) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_conditions_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #alert_conditions_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [alert_conditions_id],[rules_id],[alert_conditions_name],[alert_conditions_description],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,null);
	delete #alert_conditions_2137322B_A8D8_4321_AC4E_11E3481C19FA where alert_conditions_id is null;
	update #alert_conditions_2137322B_A8D8_4321_AC4E_11E3481C19FA set alert_conditions_name='FARRMS1_ '+cast(alert_conditions_id as varchar(30))  where isnull(alert_conditions_name,'')='' ;
	
print('--==============================END alert_conditions=============================')

UPDATE ac SET rules_id = asl.new_recid	
FROM #alert_conditions_2137322B_A8D8_4321_AC4E_11E3481C19FA ac INNER JOIN #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA asl ON asl.old_recid = ac.rules_id
print('--==============================START alert_conditions=============================')
UPDATE dbo.alert_conditions SET [rules_id]=dst.[alert_sql_id],[alert_conditions_description]=src_c.[alert_conditions_description]
		   OUTPUT 'u','alert_conditions',inserted.alert_conditions_id,inserted.alert_conditions_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
			INNER JOIN #alert_conditions_2137322B_A8D8_4321_AC4E_11E3481C19FA src_c ON src_c.rules_id=src.alert_sql_id
			INNER JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id AND src_c.alert_conditions_name=dst_c.alert_conditions_name;
insert into alert_conditions
		([rules_id],[alert_conditions_name],[alert_conditions_description]
		)
		 OUTPUT 'i','alert_conditions',inserted.alert_conditions_id,inserted.alert_conditions_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[rules_id],src_c.[alert_conditions_name],src_c.[alert_conditions_description]
		FROM #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name 
			INNER JOIN #alert_conditions_2137322B_A8D8_4321_AC4E_11E3481C19FA src_c ON src_c.rules_id=src.alert_sql_id	
			LEFT JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id AND src_c.alert_conditions_name=dst_c.alert_conditions_name
		WHERE dst_c.[rules_id] IS NULL;
UPDATE #alert_conditions_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid =dst_c.[alert_conditions_id] 
			FROM #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
			INNER JOIN #alert_conditions_2137322B_A8D8_4321_AC4E_11E3481C19FA src_c ON src_c.rules_id=src.alert_sql_id	
			INNER JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id
			 AND src_c.alert_conditions_name=dst_c.alert_conditions_name;
print('--==============================END alert_conditions=============================')

UPDATE #alert_conditions_2137322B_A8D8_4321_AC4E_11E3481C19FA SET alert_conditions_id = new_recid
print('--==============================START alert_table_where_clause=============================')

	if object_id('tempdb..#alert_table_where_clause_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #alert_table_where_clause_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [alert_table_where_clause_id] int ,[alert_id] int ,[clause_type] int ,[column_id] int ,[operator_id] int ,[column_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[second_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[table_id] int ,[column_function] varchar(1000) COLLATE DATABASE_DEFAULT ,[condition_id] int ,[sequence_no] int ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_where_clause_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #alert_table_where_clause_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [alert_table_where_clause_id],[alert_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[condition_id],[sequence_no],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_where_clause_2137322B_A8D8_4321_AC4E_11E3481C19FA where alert_table_where_clause_id is null;
	update #alert_table_where_clause_2137322B_A8D8_4321_AC4E_11E3481C19FA set alert_table_where_clause_id='FARRMS1_ '+cast(alert_table_where_clause_id as varchar(30))  where isnull(alert_table_where_clause_id,'')='' ;
	
print('--==============================END alert_table_where_clause=============================')

UPDATE atwc SET atwc.alert_id = asl.new_recid FROM #alert_table_where_clause_2137322B_A8D8_4321_AC4E_11E3481C19FA atwc INNER JOIN #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA asl ON asl.old_recid = atwc.alert_id
UPDATE atwc SET atwc.column_id = acd.new_recid FROM #alert_table_where_clause_2137322B_A8D8_4321_AC4E_11E3481C19FA atwc INNER JOIN #alert_columns_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA  acd ON acd.old_recid = atwc.column_id
UPDATE atwc SET atwc.table_id = art.new_recid FROM #alert_table_where_clause_2137322B_A8D8_4321_AC4E_11E3481C19FA atwc INNER JOIN #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA art ON art.old_recid = atwc.table_id
UPDATE atwc SET atwc.condition_id = ac.new_recid FROM #alert_table_where_clause_2137322B_A8D8_4321_AC4E_11E3481C19FA atwc INNER JOIN #alert_conditions_2137322B_A8D8_4321_AC4E_11E3481C19FA ac ON ac.old_recid = atwc.condition_id

print('--==============================START alert_table_where_clause=============================')
UPDATE dbo.alert_table_where_clause SET [alert_id]=src.[alert_id],[clause_type]=src.[clause_type],[column_id]=src.[column_id],[operator_id]=src.[operator_id],[column_value]=src.[column_value],[second_value]=src.[second_value],[table_id]=src.[table_id],[column_function]=src.[column_function],[condition_id]=src.[condition_id],[sequence_no]=src.[sequence_no],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','alert_table_where_clause',inserted.alert_table_where_clause_id,inserted.alert_table_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_where_clause_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN alert_table_where_clause dst  ON src.alert_table_where_clause_id=dst.alert_table_where_clause_id;
insert into alert_table_where_clause
		([alert_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[condition_id],[sequence_no],[data_source_column_id]
		)
		 OUTPUT 'i','alert_table_where_clause',inserted.alert_table_where_clause_id,inserted.alert_table_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[clause_type],src.[column_id],src.[operator_id],src.[column_value],src.[second_value],src.[table_id],src.[column_function],src.[condition_id],src.[sequence_no],src.[data_source_column_id]
		FROM #alert_table_where_clause_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN alert_table_where_clause dst  ON src.alert_table_where_clause_id=dst.alert_table_where_clause_id
		WHERE dst.[alert_table_where_clause_id] IS NULL;
UPDATE #alert_table_where_clause_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid =dst.new_id 
		FROM #alert_table_where_clause_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN #old_new_id dst  ON src.alert_table_where_clause_id=dst.unique_key1 AND dst.table_name='alert_table_where_clause'
		;
print('--==============================END alert_table_where_clause=============================')
print('--==============================START alert_actions=============================')

	if object_id('tempdb..#alert_actions_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #alert_actions_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [alert_actions_id] int ,[alert_id] int ,[table_id] int ,[column_id] int ,[column_value] varchar(500) COLLATE DATABASE_DEFAULT ,[condition_id] int ,[sql_statement] varchar(max) COLLATE DATABASE_DEFAULT ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_actions_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #alert_actions_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [alert_actions_id],[alert_id],[table_id],[column_id],[column_value],[condition_id],[sql_statement],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_actions_2137322B_A8D8_4321_AC4E_11E3481C19FA where alert_actions_id is null;
	update #alert_actions_2137322B_A8D8_4321_AC4E_11E3481C19FA set alert_id='FARRMS1_ '+cast(alert_actions_id as varchar(30))  where isnull(alert_id,'')='' ;
	
print('--==============================END alert_actions=============================')

UPDATE aa SET aa.column_id = acd.new_recid FROM #alert_actions_2137322B_A8D8_4321_AC4E_11E3481C19FA aa INNER JOIN #alert_columns_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA  acd ON acd.old_recid = aa.column_id
UPDATE aa SET aa.table_id = art.new_recid FROM #alert_actions_2137322B_A8D8_4321_AC4E_11E3481C19FA aa INNER JOIN #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA art ON art.old_recid = aa.table_id
UPDATE aa SET aa.condition_id = ac.new_recid FROM #alert_actions_2137322B_A8D8_4321_AC4E_11E3481C19FA aa INNER JOIN #alert_conditions_2137322B_A8D8_4321_AC4E_11E3481C19FA ac ON ac.old_recid = aa.condition_id
UPDATE aa SET aa.alert_id = asl.new_recid FROM #alert_actions_2137322B_A8D8_4321_AC4E_11E3481C19FA aa INNER JOIN #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA asl ON asl.old_recid = aa.alert_id

print('--==============================START alert_actions=============================')
UPDATE dbo.alert_actions SET [table_id]=src.[table_id],[column_id]=src.[column_id],[column_value]=src.[column_value],[condition_id]=src.[condition_id],[sql_statement]=src.[sql_statement],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','alert_actions',inserted.alert_actions_id,inserted.alert_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_actions_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN alert_actions dst  ON src.alert_id=dst.alert_id;
insert into alert_actions
		([alert_id],[table_id],[column_id],[column_value],[condition_id],[sql_statement],[data_source_column_id]
		)
		 OUTPUT 'i','alert_actions',inserted.alert_actions_id,inserted.alert_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[column_id],src.[column_value],src.[condition_id],src.[sql_statement],src.[data_source_column_id]
		FROM #alert_actions_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN alert_actions dst  ON src.alert_id=dst.alert_id
		WHERE dst.[alert_actions_id] IS NULL;
UPDATE #alert_actions_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid =dst.new_id 
		FROM #alert_actions_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND dst.table_name='alert_actions'
		;
print('--==============================END alert_actions=============================')
print('--==============================START alert_actions_events=============================')

	if object_id('tempdb..#alert_actions_events_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #alert_actions_events_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [alert_actions_events_id] int ,[alert_id] int ,[table_id] int ,[callback_alert_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_actions_events_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #alert_actions_events_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [alert_actions_events_id],[alert_id],[table_id],[callback_alert_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,null);
	delete #alert_actions_events_2137322B_A8D8_4321_AC4E_11E3481C19FA where alert_actions_events_id is null;
	update #alert_actions_events_2137322B_A8D8_4321_AC4E_11E3481C19FA set alert_id='FARRMS1_ '+cast(alert_actions_events_id as varchar(30))  where isnull(alert_id,'')='' ;
	update #alert_actions_events_2137322B_A8D8_4321_AC4E_11E3481C19FA set table_id='FARRMS2_ '+cast(alert_actions_events_id as varchar(30))  where isnull(table_id,'')='' ;
			update #alert_actions_events_2137322B_A8D8_4321_AC4E_11E3481C19FA set callback_alert_id='FARRMS3_ '+cast(alert_actions_events_id as varchar(30))  where isnull(callback_alert_id,'')='' ;
			
print('--==============================END alert_actions_events=============================')

UPDATE aae SET aae.alert_id = asl.new_recid FROM #alert_actions_events_2137322B_A8D8_4321_AC4E_11E3481C19FA aae INNER JOIN #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA asl ON asl.old_recid = aae.alert_id
UPDATE aae SET aae.table_id = art.new_recid FROM #alert_actions_events_2137322B_A8D8_4321_AC4E_11E3481C19FA aae INNER JOIN #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA art ON art.old_recid = aae.table_id

print('--==============================START alert_actions_events=============================')
UPDATE dbo.alert_actions_events SET [callback_alert_id]=src.[callback_alert_id]
		   OUTPUT 'u','alert_actions_events',inserted.alert_actions_events_id,inserted.alert_id,inserted.table_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_actions_events_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN alert_actions_events dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id;
insert into alert_actions_events
		([alert_id],[table_id],[callback_alert_id]
		)
		 OUTPUT 'i','alert_actions_events',inserted.alert_actions_events_id,inserted.alert_id,inserted.table_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[callback_alert_id]
		FROM #alert_actions_events_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN alert_actions_events dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id
		WHERE dst.[alert_actions_events_id] IS NULL;
UPDATE #alert_actions_events_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid =dst.new_id 
		FROM #alert_actions_events_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND dst.table_name='alert_actions_events'
		;
print('--==============================END alert_actions_events=============================')
print('--==============================START alert_table_relation=============================')

	if object_id('tempdb..#alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [alert_table_relation_id] int ,[alert_id] int ,[from_table_id] int ,[from_column_id] int ,[to_table_id] int ,[to_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [alert_table_relation_id],[alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA where alert_table_relation_id is null;
	update #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA set alert_id='FARRMS1_ '+cast(alert_table_relation_id as varchar(30))  where isnull(alert_id,'')='' ;
	update #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA set from_table_id='FARRMS2_ '+cast(alert_table_relation_id as varchar(30))  where isnull(from_table_id,'')='' ;
			update #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA set to_table_id='FARRMS3_ '+cast(alert_table_relation_id as varchar(30))  where isnull(to_table_id,'')='' ;
			
print('--==============================END alert_table_relation=============================')
	
update #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA set from_column_id='FARRMS4_ '+cast(alert_table_relation_id as varchar(30))  where isnull(from_column_id,'')='' ;
update #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA set to_column_id='FARRMS5_ '+cast(alert_table_relation_id as varchar(30))  where isnull(to_column_id,'')='' ;

UPDATE atr SET atr.alert_id	= asl.new_recid FROM #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA atr INNER JOIN #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA asl ON asl.old_recid = atr.alert_id		
UPDATE atr SET atr.from_table_id = atd.new_recid FROM #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA atr INNER JOIN #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA atd ON atd.old_recid = atr.from_table_id		
UPDATE atr SET atr.to_table_id = atd.new_recid FROM #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA atr INNER JOIN #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA atd ON atd.old_recid = atr.to_table_id		
UPDATE atr SET atr.from_column_id = atd.new_recid FROM #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA atr INNER JOIN #alert_columns_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA atd ON atd.old_recid = atr.from_column_id		
UPDATE atr SET atr.to_column_id = atd.new_recid FROM #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA atr INNER JOIN #alert_columns_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA atd ON atd.old_recid = atr.to_column_id		

insert into alert_table_relation
		([alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id]
		)
		 OUTPUT 'i','alert_table_relation',inserted.alert_table_relation_id,inserted.alert_id,inserted.from_table_id,inserted.to_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[from_table_id],src.[from_column_id],src.[to_table_id],src.[to_column_id]
		FROM #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN alert_table_relation dst  
		ON src.alert_id=dst.alert_id AND src.from_table_id=dst.from_table_id AND src.to_table_id=dst.to_table_id
		AND src.from_column_id=dst.from_column_id AND src.to_column_id=dst.to_column_id
		WHERE dst.[alert_table_relation_id] IS NULL;
UPDATE #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid = atr.alert_table_relation_id 
		FROM #alert_table_relation_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN alert_table_relation atr ON src.alert_id=atr.alert_id 
		AND src.from_table_id=atr.from_table_id AND src.to_table_id=atr.to_table_id 
		AND src.from_column_id=atr.from_column_id AND src.to_column_id=atr.to_column_id 
		;
print('--==============================END alert_table_relation=============================')		

print('--==============================START module_events=============================')

	if object_id('tempdb..#module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [module_events_id] int ,[modules_id] int ,[event_id] varchar(2000) COLLATE DATABASE_DEFAULT ,[workflow_name] varchar(100) COLLATE DATABASE_DEFAULT ,[workflow_owner] varchar(100) COLLATE DATABASE_DEFAULT ,[rule_table_id] int ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [module_events_id],[modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id],[is_active],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA where module_events_id is null;
	update #module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA set workflow_name='FARRMS1_ '+cast(module_events_id as varchar(30))  where isnull(workflow_name,'')='' ;
	
print('--==============================END module_events=============================')
	
	UPDATE me SET me.rule_table_id = atd.new_recid FROM #module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA me INNER JOIN #alert_table_definition_2137322B_A8D8_4321_AC4E_11E3481C19FA atd ON atd.old_recid = me.rule_table_id

	UPDATE dbo.module_events SET [modules_id]=src.[modules_id],[event_id]=src.[event_id],[workflow_owner]=src.[workflow_owner],[rule_table_id]=src.[rule_table_id]
			   OUTPUT 'u','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
		FROM #module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN module_events dst  ON src.workflow_name=dst.workflow_name;
	insert into module_events
			([modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id]
			)
			 OUTPUT 'i','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_id],src.[event_id],src.[workflow_name],src.[workflow_owner],src.[rule_table_id]
			FROM #module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN module_events dst  ON src.workflow_name=dst.workflow_name
			WHERE dst.[module_events_id] IS NULL;

			UPDATE #module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid = b.new_id 		
			FROM #module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA a 
			INNER JOIN 
			( SELECT TOP(1) new_id, unique_key1 FROM  #module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA src 
			INNER JOIN #old_new_id dst ON src.workflow_name=dst.unique_key1 AND dst.table_name='module_events' ORDER BY new_id DESC
			) b ON a.workflow_name= b.unique_key1 

	

	UPDATE me SET me.modules_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA sdv ON sdv.old_recid = me.modules_id

	UPDATE me SET me.event_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA sdv ON sdv.old_recid = me.event_id
	
print('--==============================START event_trigger=============================')

	if object_id('tempdb..#event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [event_trigger_id] int ,[modules_event_id] int ,[alert_id] int ,[initial_event] char(1) COLLATE DATABASE_DEFAULT ,[manual_step] char(1) COLLATE DATABASE_DEFAULT ,[is_disable] char(1) COLLATE DATABASE_DEFAULT ,[report_paramset_id] varchar(max) COLLATE DATABASE_DEFAULT ,[report_filters] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [event_trigger_id],[modules_event_id],[alert_id],[initial_event],[manual_step],[is_disable],[report_paramset_id],[report_filters],old_recid
	 )
	 VALUES
	 
(1360,1178,71,'n',NULL,NULL,NULL,NULL,1360),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA where event_trigger_id is null;
	update #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA set modules_event_id='FARRMS1_ '+cast(event_trigger_id as varchar(30))  where isnull(modules_event_id,'')='' ;
	update #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA set alert_id='FARRMS2_ '+cast(event_trigger_id as varchar(30))  where isnull(alert_id,'')='' ;
			
print('--==============================END event_trigger=============================')

		
		IF EXISTS (SELECT 1 FROM #module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA)
		BEGIN
			DELETE FROM #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA WHERE modules_event_id NOT IN (
			SELECT mebs.module_events_id FROM #module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA mebs INNER JOIN #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA et 
			ON et.modules_event_id = mebs.module_events_id)
		END
		ELSE
		BEGIN
			DELETE FROM #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA WHERE modules_event_id NOT IN 
			(SELECT meb.module_events_id FROM #module_events_bkup meb INNER JOIN #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA et 
			ON et.modules_event_id = meb.module_events_id)
		END
		
	
	UPDATE et SET et.alert_id = asl.new_recid FROM #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA et INNER JOIN #alert_sql_2137322B_A8D8_4321_AC4E_11E3481C19FA asl ON asl.old_recid = et.alert_id WHERE et.alert_id <> -1
	UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA et INNER JOIN #module_events_2137322B_A8D8_4321_AC4E_11E3481C19FA me ON me.old_recid = et.modules_event_id
	
UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA et INNER JOIN #module_events_bkup me ON me.old_recid = et.modules_event_id

	print('--==============================START event_trigger=============================')

	UPDATE event_trigger SET 
	 [initial_event] = src.[initial_event]
	, [manual_step] = src.[manual_step]
	, [is_disable] = src.[is_disable]
	, [report_paramset_id] = src.[report_paramset_id]
	, [report_filters] = src.[report_filters]
	 OUTPUT 'u','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,src.report_paramset_id  
	 INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA src 
	INNER JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id

	insert into event_trigger
			([modules_event_id],[alert_id],[initial_event], [manual_step], [is_disable], [report_paramset_id], [report_filters]
			)
			 OUTPUT 'i','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,inserted.report_paramset_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_event_id],src.[alert_id],src.[initial_event], src.[manual_step], src.[is_disable], src.[report_paramset_id], src.[report_filters]
			FROM #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id
			WHERE dst.[event_trigger_id] IS NULL;
	UPDATE #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid =dst.new_id 
			FROM #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN #old_new_id dst  ON src.modules_event_id=dst.unique_key1 AND src.alert_id=dst.unique_key2 AND dst.table_name='event_trigger'
			AND ISNULL(src.report_paramset_id,-999) = ISNULL(dst.unique_key3,-999);
	print('--==============================END event_trigger=============================')
print('--==============================START workflow_event_message=============================')

	if object_id('tempdb..#workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [event_message_id] int ,[event_trigger_id] int ,[event_message_name] varchar(100) COLLATE DATABASE_DEFAULT ,[message_template_id] int ,[message] varchar(1000) COLLATE DATABASE_DEFAULT ,[mult_approval_required] char(1) COLLATE DATABASE_DEFAULT ,[comment_required] char(1) COLLATE DATABASE_DEFAULT ,[approval_action_required] char(1) COLLATE DATABASE_DEFAULT ,[self_notify] char(1) COLLATE DATABASE_DEFAULT ,[notify_trader] char(1) COLLATE DATABASE_DEFAULT ,[next_module_events_id] int ,[minimum_approval_required] int ,[optional_event_msg] char(1) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[automatic_proceed] char(1) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [event_message_id],[event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type],old_recid
	 )
	 VALUES
	 
(1258,1360,'Incomplete Deal Alert',0,'There are some incomplete deals.<#ALERT_REPORT><ALERT_REPORT#>','n','n','n','y','n',NULL,NULL,'n',NULL,'n',NULL,1258),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA where event_message_id is null;
	update #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA set event_trigger_id='FARRMS1_ '+cast(event_message_id as varchar(30))  where isnull(event_trigger_id,'')='' ;
	update #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA set event_message_name='FARRMS2_ '+cast(event_message_id as varchar(30))  where isnull(event_message_name,'')='' ;
			
print('--==============================END workflow_event_message=============================')

		IF EXISTS (SELECT 1 FROM #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA)
		BEGIN	
			DELETE FROM #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA wem INNER JOIN #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA et ON et.old_recid = wem.event_trigger_id)
		END
		

	UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA wem INNER JOIN #event_trigger_2137322B_A8D8_4321_AC4E_11E3481C19FA et ON et.old_recid = wem.event_trigger_id

		UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA wem INNER JOIN #event_trigger_bkup et ON et.old_recid = wem.event_trigger_id
		UPDATE wem SET wem.next_module_events_id = meb.new_recid FROM #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA wem  INNER JOIN #module_events_bkup meb ON meb.old_recid = wem.next_module_events_id
print('--==============================START workflow_event_message=============================')
UPDATE dbo.workflow_event_message SET [message_template_id]=src.[message_template_id],[message]=src.[message],[mult_approval_required]=src.[mult_approval_required],[comment_required]=src.[comment_required],[approval_action_required]=src.[approval_action_required],[self_notify]=src.[self_notify],[notify_trader]=src.[notify_trader],[next_module_events_id]=src.[next_module_events_id],[minimum_approval_required]=src.[minimum_approval_required],[optional_event_msg]=src.[optional_event_msg],[counterparty_contact_type]=src.[counterparty_contact_type],[automatic_proceed]=src.[automatic_proceed],[notification_type]=src.[notification_type]
		   OUTPUT 'u','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name;
insert into workflow_event_message
		([event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type]
		)
		 OUTPUT 'i','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_trigger_id],src.[event_message_name],src.[message_template_id],src.[message],src.[mult_approval_required],src.[comment_required],src.[approval_action_required],src.[self_notify],src.[notify_trader],src.[next_module_events_id],src.[minimum_approval_required],src.[optional_event_msg],src.[counterparty_contact_type],src.[automatic_proceed],src.[notification_type]
		FROM #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name
		WHERE dst.[event_message_id] IS NULL;
UPDATE #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid =dst.new_id 
		FROM #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN #old_new_id dst  ON src.event_trigger_id=dst.unique_key1 AND src.event_message_name=dst.unique_key2 AND dst.table_name='workflow_event_message'
		;
print('--==============================END workflow_event_message=============================')
	
		INSERT INTO #workflow_event_message_bkup (event_message_id, event_trigger_id, event_message_name, message_template_id, message, mult_approval_required, comment_required, approval_action_required, self_notify, notify_trader, counterparty_contact_type, next_module_events_id, minimum_approval_required, optional_event_msg, automatic_proceed, notification_type, new_recid, old_recid)
		SELECT wem.event_message_id, wem.event_trigger_id, wem.event_message_name, wem.message_template_id, wem.message, wem.mult_approval_required, wem.comment_required, wem.approval_action_required, wem.self_notify, wem.notify_trader, wem.counterparty_contact_type, wem.next_module_events_id, wem.minimum_approval_required, wem.optional_event_msg, wem.automatic_proceed, wem.notification_type, wem.new_recid, wem.old_recid FROM #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA wem
		LEFT JOIN #workflow_event_message_bkup wemb ON wemb.old_recid = wem.old_recid 
		WHERE wemb.old_recid IS NULL
print('--==============================START application_security_role=============================')

	if object_id('tempdb..#application_security_role_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #application_security_role_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [role_id] int ,[role_name] varchar(50) COLLATE DATABASE_DEFAULT ,[role_description] varchar(250) COLLATE DATABASE_DEFAULT ,[role_type_value_id] int ,[process_map_file_name] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #application_security_role_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #application_security_role_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [role_id],[role_name],[role_description],[role_type_value_id],[process_map_file_name],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,null);
	delete #application_security_role_2137322B_A8D8_4321_AC4E_11E3481C19FA where role_id is null;
	update #application_security_role_2137322B_A8D8_4321_AC4E_11E3481C19FA set role_name='FARRMS1_ '+cast(role_id as varchar(30))  where isnull(role_name,'')='' ;
	
UPDATE dbo.application_security_role SET [role_description]=src.[role_description],[role_type_value_id]=src.[role_type_value_id],[process_map_file_name]=src.[process_map_file_name]
		   OUTPUT 'u','application_security_role',inserted.role_id,inserted.role_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #application_security_role_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN application_security_role dst  ON src.role_name=dst.role_name;
insert into application_security_role
		([role_name],[role_description],[role_type_value_id],[process_map_file_name]
		)
		 OUTPUT 'i','application_security_role',inserted.role_id,inserted.role_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[role_name],src.[role_description],src.[role_type_value_id],src.[process_map_file_name]
		FROM #application_security_role_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN application_security_role dst  ON src.role_name=dst.role_name
		WHERE dst.[role_id] IS NULL;
UPDATE #application_security_role_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid =dst.new_id 
		FROM #application_security_role_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN #old_new_id dst  ON src.role_name=dst.unique_key1 AND dst.table_name='application_security_role'
		;
print('--==============================END application_security_role=============================')
print('--==============================START workflow_event_user_role=============================')

	if object_id('tempdb..#workflow_event_user_role_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #workflow_event_user_role_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [event_user_role_id] int ,[event_message_id] int ,[user_login_id] varchar(50) COLLATE DATABASE_DEFAULT ,[role_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_user_role_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #workflow_event_user_role_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [event_user_role_id],[event_message_id],[user_login_id],[role_id],old_recid
	 )
	 VALUES
	 
(7748,1258,'uat.tester',NULL,7748),
(7749,1258,'binisha',NULL,7749),
(7750,1258,'farrms_admin',NULL,7750),
(NULL,NULL,NULL,NULL,null);
	delete #workflow_event_user_role_2137322B_A8D8_4321_AC4E_11E3481C19FA where event_user_role_id is null;
	update #workflow_event_user_role_2137322B_A8D8_4321_AC4E_11E3481C19FA set event_user_role_id='FARRMS1_ '+cast(event_user_role_id as varchar(30))  where isnull(event_user_role_id,'')='' ;
	
print('--==============================END workflow_event_user_role=============================')
	
		DELETE FROM #workflow_event_user_role_2137322B_A8D8_4321_AC4E_11E3481C19FA WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA wem INNER JOIN #workflow_event_user_role_2137322B_A8D8_4321_AC4E_11E3481C19FA weur ON weur.event_message_id = wem.event_message_id	)
		
	
	UPDATE weur SET weur.role_id = asr.new_recid FROM #workflow_event_user_role_2137322B_A8D8_4321_AC4E_11E3481C19FA weur INNER JOIN #application_security_role_2137322B_A8D8_4321_AC4E_11E3481C19FA asr ON asr.old_recid = weur.role_id
	UPDATE weur SET weur.event_message_id = wem.new_recid FROM #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA wem INNER JOIN #workflow_event_user_role_2137322B_A8D8_4321_AC4E_11E3481C19FA weur ON weur.event_message_id = wem.old_recid
	
print('--==============================START workflow_event_user_role=============================')
UPDATE dbo.workflow_event_user_role SET [event_message_id]=src.[event_message_id],[user_login_id]=src.[user_login_id],[role_id]=src.[role_id]
		   OUTPUT 'u','workflow_event_user_role',inserted.event_user_role_id,inserted.event_user_role_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_user_role_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN workflow_event_user_role dst  ON src.event_user_role_id=dst.event_user_role_id;
insert into workflow_event_user_role
		([event_message_id],[user_login_id],[role_id]
		)
		 OUTPUT 'i','workflow_event_user_role',inserted.event_user_role_id,inserted.event_user_role_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[user_login_id],src.[role_id]
		FROM #workflow_event_user_role_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN workflow_event_user_role dst  ON src.event_user_role_id=dst.event_user_role_id
		WHERE dst.[event_user_role_id] IS NULL;
UPDATE #workflow_event_user_role_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid =dst.new_id 
		FROM #workflow_event_user_role_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN #old_new_id dst  ON src.event_user_role_id=dst.unique_key1 AND dst.table_name='workflow_event_user_role'
		;
print('--==============================END workflow_event_user_role=============================')
print('--==============================START workflow_event_message_documents=============================')

	if object_id('tempdb..#workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [message_document_id] int ,[event_message_id] int ,[document_template_id] int ,[effective_date] datetime ,[document_category] int ,[document_template] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [message_document_id],[event_message_id],[document_template_id],[effective_date],[document_category],[document_template],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA where message_document_id is null;
	update #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA set message_document_id='FARRMS1_ '+cast(message_document_id as varchar(30))  where isnull(message_document_id,'')='' ;
	
print('--==============================END workflow_event_message_documents=============================')

		DELETE FROM #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA wemd ON wem.event_message_id = wemd.event_message_id)

	UPDATE wemd SET wemd.event_message_id = wem.new_recid FROM #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA wem INNER JOIN #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA wemd ON wemd.event_message_id = wem.old_recid
	UPDATE wemd SET wemd.document_template_id = sdv.new_recid FROM #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA wemd INNER JOIN #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA sdv ON sdv.old_recid = wemd.document_template_id
	UPDATE wemd SET wemd.document_category = sdv.new_recid FROM #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA wemd INNER JOIN #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA sdv ON sdv.old_recid = wemd.document_category
	
print('--==============================START workflow_event_message_documents=============================')
UPDATE dbo.workflow_event_message_documents SET [event_message_id]=src.[event_message_id],[document_template_id]=src.[document_template_id],[effective_date]=src.[effective_date],[document_category]=src.[document_category],[document_template]=src.[document_template]
		   OUTPUT 'u','workflow_event_message_documents',inserted.message_document_id,inserted.message_document_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN workflow_event_message_documents dst  ON src.message_document_id=dst.message_document_id;
insert into workflow_event_message_documents
		([event_message_id],[document_template_id],[effective_date],[document_category],[document_template]
		)
		 OUTPUT 'i','workflow_event_message_documents',inserted.message_document_id,inserted.message_document_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[document_template_id],src.[effective_date],src.[document_category],src.[document_template]
		FROM #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN workflow_event_message_documents dst  ON src.message_document_id=dst.message_document_id
		WHERE dst.[message_document_id] IS NULL;
UPDATE #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid =dst.new_id 
		FROM #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN #old_new_id dst  ON src.message_document_id=dst.unique_key1 AND dst.table_name='workflow_event_message_documents'
		;
print('--==============================END workflow_event_message_documents=============================')

	UPDATE w2 SET w2.new_recid = w1.message_document_id
	FROM workflow_event_message_documents w1 
	INNER JOIN #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA w2 ON w1.event_message_id = w2.event_message_id
		AND ISNULL(w1.document_template_id, '-1') = ISNULL(w2.document_template_id, '-1')
		AND ISNULL(w1.document_category, '-1') = ISNULL(w2.document_category, '-1')
print('--==============================START workflow_event_message_details=============================')

	if object_id('tempdb..#workflow_event_message_details_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #workflow_event_message_details_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [message_detail_id] int ,[event_message_document_id] int ,[message_template_id] int ,[message] varchar(500) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[delivery_method] int ,[internal_contact_type] int ,[email] varchar(300) COLLATE DATABASE_DEFAULT ,[email_cc] varchar(300) COLLATE DATABASE_DEFAULT ,[email_bcc] varchar(300) COLLATE DATABASE_DEFAULT ,[as_defined_in_contact] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_details_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #workflow_event_message_details_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [message_detail_id],[event_message_document_id],[message_template_id],[message],[counterparty_contact_type],[delivery_method],[internal_contact_type],[email],[email_cc],[email_bcc],[as_defined_in_contact],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_details_2137322B_A8D8_4321_AC4E_11E3481C19FA where message_detail_id is null;
	update #workflow_event_message_details_2137322B_A8D8_4321_AC4E_11E3481C19FA set message_detail_id='FARRMS1_ '+cast(message_detail_id as varchar(30))  where isnull(message_detail_id,'')='' ;
	
print('--==============================END workflow_event_message_details=============================')

	DELETE FROM #workflow_event_message_details_2137322B_A8D8_4321_AC4E_11E3481C19FA WHERE message_detail_id NOT IN (
		SELECT wemd.message_detail_id from #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA wemdd 
		INNER JOIN #workflow_event_message_details_2137322B_A8D8_4321_AC4E_11E3481C19FA wemd ON wemd.event_message_document_id = wemdd.message_document_id)

	UPDATE wemd SET wemd.event_message_document_id = wem.new_recid FROM #workflow_event_message_documents_2137322B_A8D8_4321_AC4E_11E3481C19FA wem INNER JOIN #workflow_event_message_details_2137322B_A8D8_4321_AC4E_11E3481C19FA wemd ON wemd.event_message_document_id = wem.old_recid
	UPDATE wemd SET wemd.counterparty_contact_type = sdv.new_recid FROM #workflow_event_message_details_2137322B_A8D8_4321_AC4E_11E3481C19FA wemd INNER JOIN #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA  sdv ON sdv.old_recid = wemd.counterparty_contact_type
	UPDATE wemd SET wemd.delivery_method = sdv.new_recid FROM #workflow_event_message_details_2137322B_A8D8_4321_AC4E_11E3481C19FA wemd INNER JOIN #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA  sdv ON sdv.old_recid = wemd.delivery_method
	UPDATE wemd SET wemd.internal_contact_type = sdv.new_recid FROM #workflow_event_message_details_2137322B_A8D8_4321_AC4E_11E3481C19FA wemd INNER JOIN #static_data_value_2137322B_A8D8_4321_AC4E_11E3481C19FA  sdv ON sdv.old_recid = wemd.internal_contact_type
	
print('--==============================START workflow_event_message_details=============================')
UPDATE dbo.workflow_event_message_details SET [event_message_document_id]=src.[event_message_document_id],[message_template_id]=src.[message_template_id],[message]=src.[message],[counterparty_contact_type]=src.[counterparty_contact_type],[delivery_method]=src.[delivery_method],[internal_contact_type]=src.[internal_contact_type],[email]=src.[email],[email_cc]=src.[email_cc],[email_bcc]=src.[email_bcc],[as_defined_in_contact]=src.[as_defined_in_contact]
		   OUTPUT 'u','workflow_event_message_details',inserted.message_detail_id,inserted.message_detail_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_details_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN workflow_event_message_details dst  ON src.message_detail_id=dst.message_detail_id;
insert into workflow_event_message_details
		([event_message_document_id],[message_template_id],[message],[counterparty_contact_type],[delivery_method],[internal_contact_type],[email],[email_cc],[email_bcc],[as_defined_in_contact]
		)
		 OUTPUT 'i','workflow_event_message_details',inserted.message_detail_id,inserted.message_detail_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_document_id],src.[message_template_id],src.[message],src.[counterparty_contact_type],src.[delivery_method],src.[internal_contact_type],src.[email],src.[email_cc],src.[email_bcc],src.[as_defined_in_contact]
		FROM #workflow_event_message_details_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN workflow_event_message_details dst  ON src.message_detail_id=dst.message_detail_id
		WHERE dst.[message_detail_id] IS NULL;
UPDATE #workflow_event_message_details_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid =dst.new_id 
		FROM #workflow_event_message_details_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN #old_new_id dst  ON src.message_detail_id=dst.unique_key1 AND dst.table_name='workflow_event_message_details'
		;
print('--==============================END workflow_event_message_details=============================')
print('--==============================START alert_reports=============================')

	if object_id('tempdb..#alert_reports_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #alert_reports_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [alert_reports_id] int ,[event_message_id] int ,[report_writer] varchar(1) COLLATE DATABASE_DEFAULT ,[paramset_hash] varchar(8000) COLLATE DATABASE_DEFAULT ,[report_param] varchar(1000) COLLATE DATABASE_DEFAULT ,[report_desc] varchar(500) COLLATE DATABASE_DEFAULT ,[table_prefix] varchar(50) COLLATE DATABASE_DEFAULT ,[table_postfix] varchar(50) COLLATE DATABASE_DEFAULT ,[report_where_clause] varchar(max) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_reports_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #alert_reports_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [alert_reports_id],[event_message_id],[report_writer],[paramset_hash],[report_param],[report_desc],[table_prefix],[table_postfix],[report_where_clause],old_recid
	 )
	 VALUES
	 
(49,1258,'n','',NULL,'Incomplete Deal','alert_incomplete_deal_','_aid',NULL,49),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_reports_2137322B_A8D8_4321_AC4E_11E3481C19FA where alert_reports_id is null;
	update #alert_reports_2137322B_A8D8_4321_AC4E_11E3481C19FA set event_message_id='FARRMS1_ '+cast(alert_reports_id as varchar(30))  where isnull(event_message_id,'')='' ;
	update #alert_reports_2137322B_A8D8_4321_AC4E_11E3481C19FA set report_desc='FARRMS2_ '+cast(alert_reports_id as varchar(30))  where isnull(report_desc,'')='' ;
			update #alert_reports_2137322B_A8D8_4321_AC4E_11E3481C19FA set table_prefix='FARRMS3_ '+cast(alert_reports_id as varchar(30))  where isnull(table_prefix,'')='' ;
			
print('--==============================END alert_reports=============================')

		DELETE FROM #alert_reports_2137322B_A8D8_4321_AC4E_11E3481C19FA WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_reports_2137322B_A8D8_4321_AC4E_11E3481C19FA ar ON wem.event_message_id = ar.event_message_id)

	UPDATE ar SET ar.event_message_id = wem.new_recid FROM #workflow_event_message_2137322B_A8D8_4321_AC4E_11E3481C19FA wem INNER JOIN #alert_reports_2137322B_A8D8_4321_AC4E_11E3481C19FA ar ON ar.event_message_id = wem.old_recid
	
print('--==============================START alert_reports=============================')
UPDATE dbo.alert_reports SET [report_writer]=src.[report_writer],[paramset_hash]=src.[paramset_hash],[report_param]=src.[report_param],[table_postfix]=src.[table_postfix],[report_where_clause]=src.[report_where_clause]
		   OUTPUT 'u','alert_reports',inserted.alert_reports_id,inserted.event_message_id,inserted.report_desc,inserted.table_prefix INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_reports_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN alert_reports dst  ON src.event_message_id=dst.event_message_id AND src.report_desc=dst.report_desc AND src.table_prefix=dst.table_prefix;
insert into alert_reports
		([event_message_id],[report_writer],[paramset_hash],[report_param],[report_desc],[table_prefix],[table_postfix],[report_where_clause]
		)
		 OUTPUT 'i','alert_reports',inserted.alert_reports_id,inserted.event_message_id,inserted.report_desc,inserted.table_prefix INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[report_writer],src.[paramset_hash],src.[report_param],src.[report_desc],src.[table_prefix],src.[table_postfix],src.[report_where_clause]
		FROM #alert_reports_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN alert_reports dst  ON src.event_message_id=dst.event_message_id AND src.report_desc=dst.report_desc AND src.table_prefix=dst.table_prefix
		WHERE dst.[alert_reports_id] IS NULL;
UPDATE #alert_reports_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid =dst.new_id 
		FROM #alert_reports_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN #old_new_id dst  ON src.event_message_id=dst.unique_key1 AND src.report_desc=dst.unique_key2 AND src.table_prefix=dst.unique_key3 AND dst.table_name='alert_reports'
		;
print('--==============================END alert_reports=============================')
print('--==============================START alert_report_params=============================')

	if object_id('tempdb..#alert_report_params_2137322B_A8D8_4321_AC4E_11E3481C19FA') is null 
	
	CREATE TABLE #alert_report_params_2137322B_A8D8_4321_AC4E_11E3481C19FA
	 (
	 [alert_report_params_id] int ,[event_message_id] int ,[alert_report_id] int ,[main_table_id] int ,[parameter_name] nvarchar(200) COLLATE DATABASE_DEFAULT ,[parameter_value] nvarchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_report_params_2137322B_A8D8_4321_AC4E_11E3481C19FA;
INSERT INTO #alert_report_params_2137322B_A8D8_4321_AC4E_11E3481C19FA(
	 [alert_report_params_id],[event_message_id],[alert_report_id],[main_table_id],[parameter_name],[parameter_value],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_report_params_2137322B_A8D8_4321_AC4E_11E3481C19FA where alert_report_params_id is null;
	update #alert_report_params_2137322B_A8D8_4321_AC4E_11E3481C19FA set alert_report_id='FARRMS1_ '+cast(alert_report_params_id as varchar(30))  where isnull(alert_report_id,'')='' ;
	
print('--==============================END alert_report_params=============================')

		DELETE FROM #alert_report_params_2137322B_A8D8_4321_AC4E_11E3481C19FA WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_report_params_2137322B_A8D8_4321_AC4E_11E3481C19FA ar ON wem.event_message_id = ar.event_message_id)

	UPDATE arp SET arp.alert_report_id = ar.alert_reports_id FROM #alert_report_params_2137322B_A8D8_4321_AC4E_11E3481C19FA arp INNER JOIN #alert_reports_2137322B_A8D8_4321_AC4E_11E3481C19FA ar ON ar.old_recid = arp.alert_report_id
	UPDATE arp SET arp.main_table_id = art.alert_rule_table_id FROM #alert_report_params_2137322B_A8D8_4321_AC4E_11E3481C19FA arp INNER JOIN #alert_rule_table_2137322B_A8D8_4321_AC4E_11E3481C19FA art ON art.old_recid = arp.main_table_id
	
print('--==============================START alert_report_params=============================')
UPDATE dbo.alert_report_params SET [event_message_id]=src.[event_message_id],[main_table_id]=src.[main_table_id],[parameter_name]=src.[parameter_name],[parameter_value]=src.[parameter_value]
		   OUTPUT 'u','alert_report_params',inserted.alert_report_params_id,inserted.alert_report_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_report_params_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN alert_report_params dst  ON src.alert_report_id=dst.alert_report_id;
insert into alert_report_params
		([event_message_id],[alert_report_id],[main_table_id],[parameter_name],[parameter_value]
		)
		 OUTPUT 'i','alert_report_params',inserted.alert_report_params_id,inserted.alert_report_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[alert_report_id],src.[main_table_id],src.[parameter_name],src.[parameter_value]
		FROM #alert_report_params_2137322B_A8D8_4321_AC4E_11E3481C19FA src LEFT JOIN alert_report_params dst  ON src.alert_report_id=dst.alert_report_id
		WHERE dst.[alert_report_params_id] IS NULL;
UPDATE #alert_report_params_2137322B_A8D8_4321_AC4E_11E3481C19FA SET new_recid =dst.new_id 
		FROM #alert_report_params_2137322B_A8D8_4321_AC4E_11E3481C19FA src INNER JOIN #old_new_id dst  ON src.alert_report_id=dst.unique_key1 AND dst.table_name='alert_report_params'
		;
print('--==============================END alert_report_params=============================')
print('--==============================START static_data_value=============================')

	if object_id('tempdb..#static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [value_id] int ,[type_id] int ,[code] varchar(500) COLLATE DATABASE_DEFAULT ,[description] varchar(500) COLLATE DATABASE_DEFAULT ,[entity_id] int ,[xref_value_id] varchar(50) COLLATE DATABASE_DEFAULT ,[xref_value] varchar(250) COLLATE DATABASE_DEFAULT ,[category_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [value_id],[type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id],old_recid
	 )
	 VALUES
	 
(757,750,'Alert','Alert with Beep Sound',NULL,NULL,NULL,NULL,757),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where value_id is null;
	update #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set code='FARRMS1_ '+cast(value_id as varchar(30))  where isnull(code,'')='' ;
	update #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set type_id='FARRMS2_ '+cast(value_id as varchar(30))  where isnull(type_id,'')='' ;
			
UPDATE dbo.static_data_value SET [description]=src.[description],[entity_id]=src.[entity_id],[xref_value_id]=src.[xref_value_id],[xref_value]=src.[xref_value],[category_id]=src.[category_id]
		   OUTPUT 'u','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id;
insert into static_data_value
		([type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id]
		)
		 OUTPUT 'i','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[type_id],src.[code],src.[description],src.[entity_id],src.[xref_value_id],src.[xref_value],src.[category_id]
		FROM #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id
		WHERE dst.[value_id] IS NULL;
UPDATE #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid =dst.new_id 
		FROM #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN #old_new_id dst  ON src.code=dst.unique_key1 AND src.type_id=dst.unique_key2 AND dst.table_name='static_data_value'
		;
print('--==============================END static_data_value=============================')
print('--==============================START alert_sql=============================')

	if object_id('tempdb..#alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [alert_sql_id] int ,[workflow_only] varchar(1) COLLATE DATABASE_DEFAULT ,[message] varchar(500) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,[sql_statement] varchar(max) COLLATE DATABASE_DEFAULT ,[alert_sql_name] varchar(100) COLLATE DATABASE_DEFAULT ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,[alert_type] char(1) COLLATE DATABASE_DEFAULT ,[rule_category] int ,[system_rule] char(1) COLLATE DATABASE_DEFAULT ,[alert_category] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [alert_sql_id],[workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category],old_recid
	 )
	 VALUES
	 
(1120,'n',NULL,'757','IF EXISTS (SELECT 1 FROM adiha_process.sys.tables WHERE [name] = ''alert_counterparty_credit_info_process_id_acci'')
BEGIN


SELECT sc.counterparty_id [Counterparty],
	 
''Account Status'' [Changed Column],
 
sdv_p.code [Previous Value],
 
sdv_c.code [Current Value]

INTO adiha_process.dbo.alert_credit_file_output_process_id_acfo

FROM adiha_process.dbo.[alert_counterparty_credit_info_process_id_acci] temp
INNER JOIN vwCounterPartyCreditInfoAudit cci ON temp.counterparty_id = cci.counterparty_id
INNER JOIN counterparty_credit_info ci ON ci.Counterparty_id = temp.counterparty_id

INNER JOIN source_counterparty sc ON cci.Counterparty_id = sc.source_counterparty_id

LEFT JOIN static_data_value sdv_p ON sdv_p.value_id = cci.previous_account_status

LEFT JOIN static_data_value sdv_c ON sdv_c.value_id = ci.account_status

WHERE cci.account_status_compare = 0

UNION ALL


SELECT sc.counterparty_id [Counterparty],
       ''Primary Debt Rating'' [Changed Column],
       sdv_p.code [Previous Value],
       sdv_c.code [Current Value]
FROM adiha_process.dbo.[alert_counterparty_credit_info_process_id_acci] temp
INNER JOIN vwCounterPartyCreditInfoAudit cci ON temp.counterparty_id = cci.counterparty_id
INNER JOIN counterparty_credit_info ci ON ci.Counterparty_id = temp.counterparty_id

INNER JOIN source_counterparty sc ON cci.Counterparty_id = sc.source_counterparty_id
LEFT JOIN static_data_value sdv_p ON  sdv_p.value_id = cci.previous_Debt_rating
LEFT JOIN static_data_value sdv_c ON  sdv_c.value_id = ci.Debt_rating
WHERE  cci.debt_rating_compare = 0

UNION ALL

SELECT sc.counterparty_id [Counterparty],
		''Debt Rating 2'' [Changed Column],
       sdv_p.code [Previous Value],
       sdv_c.code [Current Value]
FROM adiha_process.dbo.[alert_counterparty_credit_info_process_id_acci] temp
INNER JOIN vwCounterPartyCreditInfoAudit cci ON temp.counterparty_id = cci.counterparty_id
INNER JOIN counterparty_credit_info ci ON  ci.counterparty_id = temp.counterparty_id
INNER JOIN source_counterparty sc ON cci.Counterparty_id = sc.source_counterparty_id
LEFT JOIN static_data_value sdv_p ON  sdv_p.value_id = cci.previous_Debt_Rating2
LEFT JOIN static_data_value sdv_c ON  sdv_c.value_id = ci.Debt_Rating2
WHERE  cci.debt_rating2_compare = 0


UNION ALL

SELECT sc.counterparty_id [Counterparty],
	   ''Debt Rating 3'' [Changed Column],
       sdv_p.code [Previous Value],
       sdv_c.code [Current Value]
FROM adiha_process.dbo.[alert_counterparty_credit_info_process_id_acci] temp
INNER JOIN vwCounterPartyCreditInfoAudit cci ON temp.counterparty_id = cci.counterparty_id
INNER JOIN counterparty_credit_info ci ON  ci.counterparty_id = temp.counterparty_id
INNER JOIN source_counterparty sc ON cci.Counterparty_id = sc.source_counterparty_id
LEFT JOIN static_data_value sdv_p ON  sdv_p.value_id = cci.previous_Debt_Rating3
LEFT JOIN static_data_value sdv_c ON  sdv_c.value_id = ci.Debt_Rating3
WHERE  cci.debt_rating3_compare = 0

UNION ALL

SELECT sc.counterparty_id [Counterparty],
	   ''Debt Rating 4'' [Changed Column],
       sdv_p.code [Previous Value],
       sdv_c.code [Current Value]
FROM adiha_process.dbo.[alert_counterparty_credit_info_process_id_acci] temp
INNER JOIN vwCounterPartyCreditInfoAudit cci ON temp.counterparty_id = cci.counterparty_id
INNER JOIN counterparty_credit_info ci ON  ci.counterparty_id = temp.counterparty_id
INNER JOIN source_counterparty sc ON cci.Counterparty_id = sc.source_counterparty_id
LEFT JOIN static_data_value sdv_p ON  sdv_p.value_id = cci.previous_Debt_Rating4
LEFT JOIN static_data_value sdv_c ON  sdv_c.value_id = ci.Debt_Rating4
WHERE  cci.debt_rating4_compare = 0

UNION ALL

SELECT sc.counterparty_id [Counterparty],
       ''Debt Rating 5'' [Changed Column],
       sdv_p.code [Previous Value],
       sdv_c.code [Current Value]
FROM adiha_process.dbo.[alert_counterparty_credit_info_process_id_acci] temp
INNER JOIN vwCounterPartyCreditInfoAudit cci ON temp.counterparty_id = cci.counterparty_id
INNER JOIN counterparty_credit_info ci ON  ci.counterparty_id = temp.counterparty_id
INNER JOIN source_counterparty sc ON cci.Counterparty_id = sc.source_counterparty_id
LEFT JOIN static_data_value sdv_p ON  sdv_p.value_id = cci.previous_Debt_Rating5
LEFT JOIN static_data_value sdv_c ON  sdv_c.value_id = ci.Debt_Rating5
WHERE  cci.debt_rating5_compare = 0


END','Counterparty Credit File','y','s',-1,'n',NULL,1120),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where alert_sql_id is null;
	update #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set alert_sql_name='FARRMS1_ '+cast(alert_sql_id as varchar(30))  where isnull(alert_sql_name,'')='' ;
	
print('--==============================END alert_sql=============================')

UPDATE dbo.alert_sql SET [workflow_only]=src.[workflow_only],[message]=src.[message],[notification_type]=src.[notification_type],[sql_statement]=src.[sql_statement],[is_active]=src.[is_active],[alert_type]=src.[alert_type],[rule_category]=src.[rule_category],[system_rule]=src.[system_rule],[alert_category]=src.[alert_category]
		   OUTPUT 'u','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name;

IF EXISTS(SELECT 1 FROM #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 WHERE alert_sql_id < 0)
BEGIN
	SET IDENTITY_INSERT alert_sql ON
	INSERT INTO alert_sql
	([alert_sql_id], [workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category]
	)
	OUTPUT 'i','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	SELECT 
	src.alert_sql_id, src.[workflow_only],src.[message],src.[notification_type],src.[sql_statement],src.[alert_sql_name],src.[is_active],src.[alert_type],src.[rule_category],src.[system_rule],src.[alert_category]
	FROM #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
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
	FROM #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
	WHERE dst.[alert_sql_id] IS NULL;
END

UPDATE #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid = dst.new_id , alert_sql_id =  dst.new_id
FROM #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN #old_new_id dst ON src.alert_sql_name = dst.unique_key1 AND dst.table_name = 'alert_sql'

UPDATE asl SET asl.notification_type = sdv.new_recid 
FROM alert_sql asl INNER JOIN #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 sdv ON sdv.old_recid = asl.notification_type	

UPDATE asl SET asl.rule_category = sdv.new_recid
FROM alert_sql asl INNER JOIN #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 sdv ON sdv.old_recid = asl.rule_category	


	INSERT INTO #alert_sql_bkup (alert_sql_id, workflow_only, message, notification_type, sql_statement, alert_sql_name, is_active, alert_type, rule_category, system_rule, alert_category, new_recid, old_recid)
	SELECT asl.alert_sql_id, asl.workflow_only, asl.message, asl.notification_type, asl.sql_statement, asl.alert_sql_name, asl.is_active, asl.alert_type, asl.rule_category, asl.system_rule, asl.alert_category, asl.new_recid, asl.old_recid FROM #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 asl
	LEFT JOIN #alert_sql_bkup aslb ON aslb.old_recid = asl.old_recid
	WHERE aslb.old_recid IS NULL
print('--==============================START alert_table_definition=============================')

	if object_id('tempdb..#alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [alert_table_definition_id] int ,[logical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[physical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[data_source_id] int ,[is_action_view] char(1) COLLATE DATABASE_DEFAULT ,[primary_column] varchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [alert_table_definition_id],[logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where alert_table_definition_id is null;
	update #alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set logical_table_name='FARRMS1_ '+cast(alert_table_definition_id as varchar(30))  where isnull(logical_table_name,'')='' ;
	
UPDATE dbo.alert_table_definition SET [physical_table_name]=src.[physical_table_name],[data_source_id]=src.[data_source_id],[is_action_view]=src.[is_action_view],[primary_column]=src.[primary_column]
		   OUTPUT 'u','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name;
insert into alert_table_definition
		([logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column]
		)
		 OUTPUT 'i','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[logical_table_name],src.[physical_table_name],src.[data_source_id],src.[is_action_view],src.[primary_column]
		FROM #alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name
		WHERE dst.[alert_table_definition_id] IS NULL;
UPDATE #alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid =dst.new_id 
		FROM #alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN #old_new_id dst  ON src.logical_table_name=dst.unique_key1 AND dst.table_name='alert_table_definition'
		;
print('--==============================END alert_table_definition=============================')

UPDATE #alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET alert_table_definition_id = new_recid

print('--==============================START alert_columns_definition=============================')

	if object_id('tempdb..#alert_columns_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #alert_columns_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [alert_columns_definition_id] int ,[alert_table_id] int ,[column_name] varchar(600) COLLATE DATABASE_DEFAULT ,[is_primary] char(1) COLLATE DATABASE_DEFAULT ,[static_data_type_id] int ,[column_alias] varchar(200) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_columns_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #alert_columns_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [alert_columns_definition_id],[alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_columns_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where alert_columns_definition_id is null;
	update #alert_columns_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set column_name='FARRMS1_ '+cast(alert_columns_definition_id as varchar(30))  where isnull(column_name,'')='' ;
	
print('--==============================END alert_columns_definition=============================')

UPDATE acd SET acd.alert_table_id = atd.new_recid
FROM #alert_columns_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 acd INNER JOIN #alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 atd ON atd.old_recid = acd.alert_table_id

print('--==============================START alert_columns_definition=============================')
UPDATE dbo.alert_columns_definition SET [alert_table_id]=dst.[alert_table_definition_id],[is_primary]=src_c.[is_primary],[static_data_type_id]=src_c.[static_data_type_id],[column_alias]=src_c.[column_alias]
		   OUTPUT 'u','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src_c ON src_c.alert_table_id=src.alert_table_definition_id
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name;
insert into alert_columns_definition
		([alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias]
		)
		 OUTPUT 'i','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[alert_table_id],src_c.[column_name],src_c.[is_primary],src_c.[static_data_type_id],src_c.[column_alias]
		FROM #alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name 
			INNER JOIN #alert_columns_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			LEFT JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name
		WHERE dst_c.[alert_table_id] IS NULL;
UPDATE #alert_columns_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid =dst_c.[alert_columns_definition_id] 
			FROM #alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id
			 AND src_c.column_name=dst_c.column_name;
print('--==============================END alert_columns_definition=============================')

DELETE FROM alert_table_relation WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1)
DELETE FROM alert_actions_events WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1)
DELETE FROM alert_actions WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1)
DELETE FROM alert_table_where_clause WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1)
DELETE from alert_conditions WHERE rules_id IN (SELECT alert_sql_id FROM #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1)
DELETE from alert_rule_table where alert_id IN (SELECT alert_sql_id FROM #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1)
print('--==============================START alert_rule_table=============================')

	if object_id('tempdb..#alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [alert_rule_table_id] int ,[alert_id] int ,[table_id] int ,[root_table_id] int ,[table_alias] varchar(50) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [alert_rule_table_id],[alert_id],[table_id],[root_table_id],[table_alias],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where alert_rule_table_id is null;
	update #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set alert_rule_table_id='FARRMS1_ '+cast(alert_rule_table_id as varchar(30))  where isnull(alert_rule_table_id,'')='' ;
	
print('--==============================END alert_rule_table=============================')

UPDATE art SET art.alert_id = asl.new_recid
FROM #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 art INNER JOIN #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 asl ON asl.old_recid = art.alert_id

UPDATE art SET art.table_id = asd.new_recid
FROM #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 art INNER JOIN #alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1  asd ON asd.old_recid = art.table_id

UPDATE dbo.alert_rule_table SET [table_alias]=src.[table_alias]
		   OUTPUT 'u','alert_rule_table',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
insert into alert_rule_table
		([alert_id],[table_id],[root_table_id],[table_alias]
		)
		 OUTPUT 'i','alert_rule_table',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[root_table_id],src.[table_alias]
		FROM #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
		WHERE dst.[alert_rule_table_id] IS NULL;
UPDATE #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid =dst.new_id 
		FROM #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND ISNULL(src.root_table_id, -1)=ISNULL(dst.unique_key3, -1) AND dst.table_name='alert_rule_table'
		;
print('--==============================END alert_rule_table=============================')
	-- need to verify root_table_id
UPDATE art SET art.root_table_id = art2.new_recid FROM #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 art INNER JOIN #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 art2 ON art2.old_recid = art.root_table_id  
UPDATE art SET art.root_table_id = arrt.root_table_id FROM alert_rule_table art INNER JOIN #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 arrt ON arrt.new_recid = art.alert_rule_table_id 

print('--==============================START alert_conditions=============================')

	if object_id('tempdb..#alert_conditions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #alert_conditions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [alert_conditions_id] int ,[rules_id] int ,[alert_conditions_name] varchar(100) COLLATE DATABASE_DEFAULT ,[alert_conditions_description] varchar(500) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_conditions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #alert_conditions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [alert_conditions_id],[rules_id],[alert_conditions_name],[alert_conditions_description],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,null);
	delete #alert_conditions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where alert_conditions_id is null;
	update #alert_conditions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set alert_conditions_name='FARRMS1_ '+cast(alert_conditions_id as varchar(30))  where isnull(alert_conditions_name,'')='' ;
	
print('--==============================END alert_conditions=============================')

UPDATE ac SET rules_id = asl.new_recid	
FROM #alert_conditions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 ac INNER JOIN #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 asl ON asl.old_recid = ac.rules_id
print('--==============================START alert_conditions=============================')
UPDATE dbo.alert_conditions SET [rules_id]=dst.[alert_sql_id],[alert_conditions_description]=src_c.[alert_conditions_description]
		   OUTPUT 'u','alert_conditions',inserted.alert_conditions_id,inserted.alert_conditions_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
			INNER JOIN #alert_conditions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src_c ON src_c.rules_id=src.alert_sql_id
			INNER JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id AND src_c.alert_conditions_name=dst_c.alert_conditions_name;
insert into alert_conditions
		([rules_id],[alert_conditions_name],[alert_conditions_description]
		)
		 OUTPUT 'i','alert_conditions',inserted.alert_conditions_id,inserted.alert_conditions_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[rules_id],src_c.[alert_conditions_name],src_c.[alert_conditions_description]
		FROM #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name 
			INNER JOIN #alert_conditions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src_c ON src_c.rules_id=src.alert_sql_id	
			LEFT JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id AND src_c.alert_conditions_name=dst_c.alert_conditions_name
		WHERE dst_c.[rules_id] IS NULL;
UPDATE #alert_conditions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid =dst_c.[alert_conditions_id] 
			FROM #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
			INNER JOIN #alert_conditions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src_c ON src_c.rules_id=src.alert_sql_id	
			INNER JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id
			 AND src_c.alert_conditions_name=dst_c.alert_conditions_name;
print('--==============================END alert_conditions=============================')

UPDATE #alert_conditions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET alert_conditions_id = new_recid
print('--==============================START alert_table_where_clause=============================')

	if object_id('tempdb..#alert_table_where_clause_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #alert_table_where_clause_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [alert_table_where_clause_id] int ,[alert_id] int ,[clause_type] int ,[column_id] int ,[operator_id] int ,[column_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[second_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[table_id] int ,[column_function] varchar(1000) COLLATE DATABASE_DEFAULT ,[condition_id] int ,[sequence_no] int ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_where_clause_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #alert_table_where_clause_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [alert_table_where_clause_id],[alert_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[condition_id],[sequence_no],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_where_clause_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where alert_table_where_clause_id is null;
	update #alert_table_where_clause_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set alert_table_where_clause_id='FARRMS1_ '+cast(alert_table_where_clause_id as varchar(30))  where isnull(alert_table_where_clause_id,'')='' ;
	
print('--==============================END alert_table_where_clause=============================')

UPDATE atwc SET atwc.alert_id = asl.new_recid FROM #alert_table_where_clause_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 atwc INNER JOIN #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 asl ON asl.old_recid = atwc.alert_id
UPDATE atwc SET atwc.column_id = acd.new_recid FROM #alert_table_where_clause_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 atwc INNER JOIN #alert_columns_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1  acd ON acd.old_recid = atwc.column_id
UPDATE atwc SET atwc.table_id = art.new_recid FROM #alert_table_where_clause_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 atwc INNER JOIN #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 art ON art.old_recid = atwc.table_id
UPDATE atwc SET atwc.condition_id = ac.new_recid FROM #alert_table_where_clause_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 atwc INNER JOIN #alert_conditions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 ac ON ac.old_recid = atwc.condition_id

print('--==============================START alert_table_where_clause=============================')
UPDATE dbo.alert_table_where_clause SET [alert_id]=src.[alert_id],[clause_type]=src.[clause_type],[column_id]=src.[column_id],[operator_id]=src.[operator_id],[column_value]=src.[column_value],[second_value]=src.[second_value],[table_id]=src.[table_id],[column_function]=src.[column_function],[condition_id]=src.[condition_id],[sequence_no]=src.[sequence_no],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','alert_table_where_clause',inserted.alert_table_where_clause_id,inserted.alert_table_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_where_clause_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN alert_table_where_clause dst  ON src.alert_table_where_clause_id=dst.alert_table_where_clause_id;
insert into alert_table_where_clause
		([alert_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[condition_id],[sequence_no],[data_source_column_id]
		)
		 OUTPUT 'i','alert_table_where_clause',inserted.alert_table_where_clause_id,inserted.alert_table_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[clause_type],src.[column_id],src.[operator_id],src.[column_value],src.[second_value],src.[table_id],src.[column_function],src.[condition_id],src.[sequence_no],src.[data_source_column_id]
		FROM #alert_table_where_clause_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN alert_table_where_clause dst  ON src.alert_table_where_clause_id=dst.alert_table_where_clause_id
		WHERE dst.[alert_table_where_clause_id] IS NULL;
UPDATE #alert_table_where_clause_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid =dst.new_id 
		FROM #alert_table_where_clause_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN #old_new_id dst  ON src.alert_table_where_clause_id=dst.unique_key1 AND dst.table_name='alert_table_where_clause'
		;
print('--==============================END alert_table_where_clause=============================')
print('--==============================START alert_actions=============================')

	if object_id('tempdb..#alert_actions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #alert_actions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [alert_actions_id] int ,[alert_id] int ,[table_id] int ,[column_id] int ,[column_value] varchar(500) COLLATE DATABASE_DEFAULT ,[condition_id] int ,[sql_statement] varchar(max) COLLATE DATABASE_DEFAULT ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_actions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #alert_actions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [alert_actions_id],[alert_id],[table_id],[column_id],[column_value],[condition_id],[sql_statement],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_actions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where alert_actions_id is null;
	update #alert_actions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set alert_id='FARRMS1_ '+cast(alert_actions_id as varchar(30))  where isnull(alert_id,'')='' ;
	
print('--==============================END alert_actions=============================')

UPDATE aa SET aa.column_id = acd.new_recid FROM #alert_actions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 aa INNER JOIN #alert_columns_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1  acd ON acd.old_recid = aa.column_id
UPDATE aa SET aa.table_id = art.new_recid FROM #alert_actions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 aa INNER JOIN #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 art ON art.old_recid = aa.table_id
UPDATE aa SET aa.condition_id = ac.new_recid FROM #alert_actions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 aa INNER JOIN #alert_conditions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 ac ON ac.old_recid = aa.condition_id
UPDATE aa SET aa.alert_id = asl.new_recid FROM #alert_actions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 aa INNER JOIN #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 asl ON asl.old_recid = aa.alert_id

print('--==============================START alert_actions=============================')
UPDATE dbo.alert_actions SET [table_id]=src.[table_id],[column_id]=src.[column_id],[column_value]=src.[column_value],[condition_id]=src.[condition_id],[sql_statement]=src.[sql_statement],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','alert_actions',inserted.alert_actions_id,inserted.alert_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_actions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN alert_actions dst  ON src.alert_id=dst.alert_id;
insert into alert_actions
		([alert_id],[table_id],[column_id],[column_value],[condition_id],[sql_statement],[data_source_column_id]
		)
		 OUTPUT 'i','alert_actions',inserted.alert_actions_id,inserted.alert_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[column_id],src.[column_value],src.[condition_id],src.[sql_statement],src.[data_source_column_id]
		FROM #alert_actions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN alert_actions dst  ON src.alert_id=dst.alert_id
		WHERE dst.[alert_actions_id] IS NULL;
UPDATE #alert_actions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid =dst.new_id 
		FROM #alert_actions_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND dst.table_name='alert_actions'
		;
print('--==============================END alert_actions=============================')
print('--==============================START alert_actions_events=============================')

	if object_id('tempdb..#alert_actions_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #alert_actions_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [alert_actions_events_id] int ,[alert_id] int ,[table_id] int ,[callback_alert_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_actions_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #alert_actions_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [alert_actions_events_id],[alert_id],[table_id],[callback_alert_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,null);
	delete #alert_actions_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where alert_actions_events_id is null;
	update #alert_actions_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set alert_id='FARRMS1_ '+cast(alert_actions_events_id as varchar(30))  where isnull(alert_id,'')='' ;
	update #alert_actions_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set table_id='FARRMS2_ '+cast(alert_actions_events_id as varchar(30))  where isnull(table_id,'')='' ;
			update #alert_actions_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set callback_alert_id='FARRMS3_ '+cast(alert_actions_events_id as varchar(30))  where isnull(callback_alert_id,'')='' ;
			
print('--==============================END alert_actions_events=============================')

UPDATE aae SET aae.alert_id = asl.new_recid FROM #alert_actions_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 aae INNER JOIN #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 asl ON asl.old_recid = aae.alert_id
UPDATE aae SET aae.table_id = art.new_recid FROM #alert_actions_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 aae INNER JOIN #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 art ON art.old_recid = aae.table_id

print('--==============================START alert_actions_events=============================')
UPDATE dbo.alert_actions_events SET [callback_alert_id]=src.[callback_alert_id]
		   OUTPUT 'u','alert_actions_events',inserted.alert_actions_events_id,inserted.alert_id,inserted.table_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_actions_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN alert_actions_events dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id;
insert into alert_actions_events
		([alert_id],[table_id],[callback_alert_id]
		)
		 OUTPUT 'i','alert_actions_events',inserted.alert_actions_events_id,inserted.alert_id,inserted.table_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[callback_alert_id]
		FROM #alert_actions_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN alert_actions_events dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id
		WHERE dst.[alert_actions_events_id] IS NULL;
UPDATE #alert_actions_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid =dst.new_id 
		FROM #alert_actions_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND dst.table_name='alert_actions_events'
		;
print('--==============================END alert_actions_events=============================')
print('--==============================START alert_table_relation=============================')

	if object_id('tempdb..#alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [alert_table_relation_id] int ,[alert_id] int ,[from_table_id] int ,[from_column_id] int ,[to_table_id] int ,[to_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [alert_table_relation_id],[alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where alert_table_relation_id is null;
	update #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set alert_id='FARRMS1_ '+cast(alert_table_relation_id as varchar(30))  where isnull(alert_id,'')='' ;
	update #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set from_table_id='FARRMS2_ '+cast(alert_table_relation_id as varchar(30))  where isnull(from_table_id,'')='' ;
			update #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set to_table_id='FARRMS3_ '+cast(alert_table_relation_id as varchar(30))  where isnull(to_table_id,'')='' ;
			
print('--==============================END alert_table_relation=============================')
	
update #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set from_column_id='FARRMS4_ '+cast(alert_table_relation_id as varchar(30))  where isnull(from_column_id,'')='' ;
update #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set to_column_id='FARRMS5_ '+cast(alert_table_relation_id as varchar(30))  where isnull(to_column_id,'')='' ;

UPDATE atr SET atr.alert_id	= asl.new_recid FROM #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 atr INNER JOIN #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 asl ON asl.old_recid = atr.alert_id		
UPDATE atr SET atr.from_table_id = atd.new_recid FROM #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 atr INNER JOIN #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 atd ON atd.old_recid = atr.from_table_id		
UPDATE atr SET atr.to_table_id = atd.new_recid FROM #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 atr INNER JOIN #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 atd ON atd.old_recid = atr.to_table_id		
UPDATE atr SET atr.from_column_id = atd.new_recid FROM #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 atr INNER JOIN #alert_columns_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 atd ON atd.old_recid = atr.from_column_id		
UPDATE atr SET atr.to_column_id = atd.new_recid FROM #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 atr INNER JOIN #alert_columns_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 atd ON atd.old_recid = atr.to_column_id		

insert into alert_table_relation
		([alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id]
		)
		 OUTPUT 'i','alert_table_relation',inserted.alert_table_relation_id,inserted.alert_id,inserted.from_table_id,inserted.to_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[from_table_id],src.[from_column_id],src.[to_table_id],src.[to_column_id]
		FROM #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN alert_table_relation dst  
		ON src.alert_id=dst.alert_id AND src.from_table_id=dst.from_table_id AND src.to_table_id=dst.to_table_id
		AND src.from_column_id=dst.from_column_id AND src.to_column_id=dst.to_column_id
		WHERE dst.[alert_table_relation_id] IS NULL;
UPDATE #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid = atr.alert_table_relation_id 
		FROM #alert_table_relation_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN alert_table_relation atr ON src.alert_id=atr.alert_id 
		AND src.from_table_id=atr.from_table_id AND src.to_table_id=atr.to_table_id 
		AND src.from_column_id=atr.from_column_id AND src.to_column_id=atr.to_column_id 
		;
print('--==============================END alert_table_relation=============================')		

print('--==============================START module_events=============================')

	if object_id('tempdb..#module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [module_events_id] int ,[modules_id] int ,[event_id] varchar(2000) COLLATE DATABASE_DEFAULT ,[workflow_name] varchar(100) COLLATE DATABASE_DEFAULT ,[workflow_owner] varchar(100) COLLATE DATABASE_DEFAULT ,[rule_table_id] int ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [module_events_id],[modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id],[is_active],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where module_events_id is null;
	update #module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set workflow_name='FARRMS1_ '+cast(module_events_id as varchar(30))  where isnull(workflow_name,'')='' ;
	
print('--==============================END module_events=============================')
	
	UPDATE me SET me.rule_table_id = atd.new_recid FROM #module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 me INNER JOIN #alert_table_definition_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 atd ON atd.old_recid = me.rule_table_id

	UPDATE dbo.module_events SET [modules_id]=src.[modules_id],[event_id]=src.[event_id],[workflow_owner]=src.[workflow_owner],[rule_table_id]=src.[rule_table_id]
			   OUTPUT 'u','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
		FROM #module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN module_events dst  ON src.workflow_name=dst.workflow_name;
	insert into module_events
			([modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id]
			)
			 OUTPUT 'i','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_id],src.[event_id],src.[workflow_name],src.[workflow_owner],src.[rule_table_id]
			FROM #module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN module_events dst  ON src.workflow_name=dst.workflow_name
			WHERE dst.[module_events_id] IS NULL;

			UPDATE #module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid = b.new_id 		
			FROM #module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 a 
			INNER JOIN 
			( SELECT TOP(1) new_id, unique_key1 FROM  #module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src 
			INNER JOIN #old_new_id dst ON src.workflow_name=dst.unique_key1 AND dst.table_name='module_events' ORDER BY new_id DESC
			) b ON a.workflow_name= b.unique_key1 

	

	UPDATE me SET me.modules_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 sdv ON sdv.old_recid = me.modules_id

	UPDATE me SET me.event_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 sdv ON sdv.old_recid = me.event_id
	
print('--==============================START event_trigger=============================')

	if object_id('tempdb..#event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [event_trigger_id] int ,[modules_event_id] int ,[alert_id] int ,[initial_event] char(1) COLLATE DATABASE_DEFAULT ,[manual_step] char(1) COLLATE DATABASE_DEFAULT ,[is_disable] char(1) COLLATE DATABASE_DEFAULT ,[report_paramset_id] varchar(max) COLLATE DATABASE_DEFAULT ,[report_filters] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [event_trigger_id],[modules_event_id],[alert_id],[initial_event],[manual_step],[is_disable],[report_paramset_id],[report_filters],old_recid
	 )
	 VALUES
	 
(1361,1179,1120,'n',NULL,NULL,NULL,NULL,1361),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where event_trigger_id is null;
	update #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set modules_event_id='FARRMS1_ '+cast(event_trigger_id as varchar(30))  where isnull(modules_event_id,'')='' ;
	update #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set alert_id='FARRMS2_ '+cast(event_trigger_id as varchar(30))  where isnull(alert_id,'')='' ;
			
print('--==============================END event_trigger=============================')

		
		IF EXISTS (SELECT 1 FROM #module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1)
		BEGIN
			DELETE FROM #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 WHERE modules_event_id NOT IN (
			SELECT mebs.module_events_id FROM #module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 mebs INNER JOIN #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 et 
			ON et.modules_event_id = mebs.module_events_id)
		END
		ELSE
		BEGIN
			DELETE FROM #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 WHERE modules_event_id NOT IN 
			(SELECT meb.module_events_id FROM #module_events_bkup meb INNER JOIN #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 et 
			ON et.modules_event_id = meb.module_events_id)
		END
		
	
	UPDATE et SET et.alert_id = asl.new_recid FROM #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 et INNER JOIN #alert_sql_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 asl ON asl.old_recid = et.alert_id WHERE et.alert_id <> -1
	UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 et INNER JOIN #module_events_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 me ON me.old_recid = et.modules_event_id
	
UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 et INNER JOIN #module_events_bkup me ON me.old_recid = et.modules_event_id

	print('--==============================START event_trigger=============================')

	UPDATE event_trigger SET 
	 [initial_event] = src.[initial_event]
	, [manual_step] = src.[manual_step]
	, [is_disable] = src.[is_disable]
	, [report_paramset_id] = src.[report_paramset_id]
	, [report_filters] = src.[report_filters]
	 OUTPUT 'u','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,src.report_paramset_id  
	 INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src 
	INNER JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id

	insert into event_trigger
			([modules_event_id],[alert_id],[initial_event], [manual_step], [is_disable], [report_paramset_id], [report_filters]
			)
			 OUTPUT 'i','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,inserted.report_paramset_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_event_id],src.[alert_id],src.[initial_event], src.[manual_step], src.[is_disable], src.[report_paramset_id], src.[report_filters]
			FROM #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id
			WHERE dst.[event_trigger_id] IS NULL;
	UPDATE #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid =dst.new_id 
			FROM #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN #old_new_id dst  ON src.modules_event_id=dst.unique_key1 AND src.alert_id=dst.unique_key2 AND dst.table_name='event_trigger'
			AND ISNULL(src.report_paramset_id,-999) = ISNULL(dst.unique_key3,-999);
	print('--==============================END event_trigger=============================')
print('--==============================START workflow_event_message=============================')

	if object_id('tempdb..#workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [event_message_id] int ,[event_trigger_id] int ,[event_message_name] varchar(100) COLLATE DATABASE_DEFAULT ,[message_template_id] int ,[message] varchar(1000) COLLATE DATABASE_DEFAULT ,[mult_approval_required] char(1) COLLATE DATABASE_DEFAULT ,[comment_required] char(1) COLLATE DATABASE_DEFAULT ,[approval_action_required] char(1) COLLATE DATABASE_DEFAULT ,[self_notify] char(1) COLLATE DATABASE_DEFAULT ,[notify_trader] char(1) COLLATE DATABASE_DEFAULT ,[next_module_events_id] int ,[minimum_approval_required] int ,[optional_event_msg] char(1) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[automatic_proceed] char(1) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [event_message_id],[event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type],old_recid
	 )
	 VALUES
	 
(1259,1361,'Counterparty Credit Info Change',0,'<#COUNTERPARTY><COUNTERPARTY><COUNTERPARTY#> Counterparty credit file has been updated.  <#ALERT_REPORT>','n','n','n','y','n',NULL,NULL,'n',NULL,'n','757',1259),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where event_message_id is null;
	update #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set event_trigger_id='FARRMS1_ '+cast(event_message_id as varchar(30))  where isnull(event_trigger_id,'')='' ;
	update #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set event_message_name='FARRMS2_ '+cast(event_message_id as varchar(30))  where isnull(event_message_name,'')='' ;
			
print('--==============================END workflow_event_message=============================')

		IF EXISTS (SELECT 1 FROM #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1)
		BEGIN	
			DELETE FROM #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wem INNER JOIN #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 et ON et.old_recid = wem.event_trigger_id)
		END
		

	UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wem INNER JOIN #event_trigger_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 et ON et.old_recid = wem.event_trigger_id

		UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wem INNER JOIN #event_trigger_bkup et ON et.old_recid = wem.event_trigger_id
		UPDATE wem SET wem.next_module_events_id = meb.new_recid FROM #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wem  INNER JOIN #module_events_bkup meb ON meb.old_recid = wem.next_module_events_id
print('--==============================START workflow_event_message=============================')
UPDATE dbo.workflow_event_message SET [message_template_id]=src.[message_template_id],[message]=src.[message],[mult_approval_required]=src.[mult_approval_required],[comment_required]=src.[comment_required],[approval_action_required]=src.[approval_action_required],[self_notify]=src.[self_notify],[notify_trader]=src.[notify_trader],[next_module_events_id]=src.[next_module_events_id],[minimum_approval_required]=src.[minimum_approval_required],[optional_event_msg]=src.[optional_event_msg],[counterparty_contact_type]=src.[counterparty_contact_type],[automatic_proceed]=src.[automatic_proceed],[notification_type]=src.[notification_type]
		   OUTPUT 'u','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name;
insert into workflow_event_message
		([event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type]
		)
		 OUTPUT 'i','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_trigger_id],src.[event_message_name],src.[message_template_id],src.[message],src.[mult_approval_required],src.[comment_required],src.[approval_action_required],src.[self_notify],src.[notify_trader],src.[next_module_events_id],src.[minimum_approval_required],src.[optional_event_msg],src.[counterparty_contact_type],src.[automatic_proceed],src.[notification_type]
		FROM #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name
		WHERE dst.[event_message_id] IS NULL;
UPDATE #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid =dst.new_id 
		FROM #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN #old_new_id dst  ON src.event_trigger_id=dst.unique_key1 AND src.event_message_name=dst.unique_key2 AND dst.table_name='workflow_event_message'
		;
print('--==============================END workflow_event_message=============================')
	
		INSERT INTO #workflow_event_message_bkup (event_message_id, event_trigger_id, event_message_name, message_template_id, message, mult_approval_required, comment_required, approval_action_required, self_notify, notify_trader, counterparty_contact_type, next_module_events_id, minimum_approval_required, optional_event_msg, automatic_proceed, notification_type, new_recid, old_recid)
		SELECT wem.event_message_id, wem.event_trigger_id, wem.event_message_name, wem.message_template_id, wem.message, wem.mult_approval_required, wem.comment_required, wem.approval_action_required, wem.self_notify, wem.notify_trader, wem.counterparty_contact_type, wem.next_module_events_id, wem.minimum_approval_required, wem.optional_event_msg, wem.automatic_proceed, wem.notification_type, wem.new_recid, wem.old_recid FROM #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wem
		LEFT JOIN #workflow_event_message_bkup wemb ON wemb.old_recid = wem.old_recid 
		WHERE wemb.old_recid IS NULL
print('--==============================START application_security_role=============================')

	if object_id('tempdb..#application_security_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #application_security_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [role_id] int ,[role_name] varchar(50) COLLATE DATABASE_DEFAULT ,[role_description] varchar(250) COLLATE DATABASE_DEFAULT ,[role_type_value_id] int ,[process_map_file_name] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #application_security_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #application_security_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [role_id],[role_name],[role_description],[role_type_value_id],[process_map_file_name],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,null);
	delete #application_security_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where role_id is null;
	update #application_security_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set role_name='FARRMS1_ '+cast(role_id as varchar(30))  where isnull(role_name,'')='' ;
	
UPDATE dbo.application_security_role SET [role_description]=src.[role_description],[role_type_value_id]=src.[role_type_value_id],[process_map_file_name]=src.[process_map_file_name]
		   OUTPUT 'u','application_security_role',inserted.role_id,inserted.role_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #application_security_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN application_security_role dst  ON src.role_name=dst.role_name;
insert into application_security_role
		([role_name],[role_description],[role_type_value_id],[process_map_file_name]
		)
		 OUTPUT 'i','application_security_role',inserted.role_id,inserted.role_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[role_name],src.[role_description],src.[role_type_value_id],src.[process_map_file_name]
		FROM #application_security_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN application_security_role dst  ON src.role_name=dst.role_name
		WHERE dst.[role_id] IS NULL;
UPDATE #application_security_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid =dst.new_id 
		FROM #application_security_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN #old_new_id dst  ON src.role_name=dst.unique_key1 AND dst.table_name='application_security_role'
		;
print('--==============================END application_security_role=============================')
print('--==============================START workflow_event_user_role=============================')

	if object_id('tempdb..#workflow_event_user_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #workflow_event_user_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [event_user_role_id] int ,[event_message_id] int ,[user_login_id] varchar(50) COLLATE DATABASE_DEFAULT ,[role_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_user_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #workflow_event_user_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [event_user_role_id],[event_message_id],[user_login_id],[role_id],old_recid
	 )
	 VALUES
	 
(7865,1259,'farrms_admin',NULL,7865),
(7866,1259,'bipana',NULL,7866),
(7867,1259,'bneupane',NULL,7867),
(7868,1259,'spanta',NULL,7868),
(NULL,NULL,NULL,NULL,null);
	delete #workflow_event_user_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where event_user_role_id is null;
	update #workflow_event_user_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set event_user_role_id='FARRMS1_ '+cast(event_user_role_id as varchar(30))  where isnull(event_user_role_id,'')='' ;
	
print('--==============================END workflow_event_user_role=============================')
	
		DELETE FROM #workflow_event_user_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wem INNER JOIN #workflow_event_user_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 weur ON weur.event_message_id = wem.event_message_id	)
		
	
	UPDATE weur SET weur.role_id = asr.new_recid FROM #workflow_event_user_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 weur INNER JOIN #application_security_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 asr ON asr.old_recid = weur.role_id
	UPDATE weur SET weur.event_message_id = wem.new_recid FROM #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wem INNER JOIN #workflow_event_user_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 weur ON weur.event_message_id = wem.old_recid
	
print('--==============================START workflow_event_user_role=============================')
UPDATE dbo.workflow_event_user_role SET [event_message_id]=src.[event_message_id],[user_login_id]=src.[user_login_id],[role_id]=src.[role_id]
		   OUTPUT 'u','workflow_event_user_role',inserted.event_user_role_id,inserted.event_user_role_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_user_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN workflow_event_user_role dst  ON src.event_user_role_id=dst.event_user_role_id;
insert into workflow_event_user_role
		([event_message_id],[user_login_id],[role_id]
		)
		 OUTPUT 'i','workflow_event_user_role',inserted.event_user_role_id,inserted.event_user_role_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[user_login_id],src.[role_id]
		FROM #workflow_event_user_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN workflow_event_user_role dst  ON src.event_user_role_id=dst.event_user_role_id
		WHERE dst.[event_user_role_id] IS NULL;
UPDATE #workflow_event_user_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid =dst.new_id 
		FROM #workflow_event_user_role_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN #old_new_id dst  ON src.event_user_role_id=dst.unique_key1 AND dst.table_name='workflow_event_user_role'
		;
print('--==============================END workflow_event_user_role=============================')
print('--==============================START workflow_event_message_documents=============================')

	if object_id('tempdb..#workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [message_document_id] int ,[event_message_id] int ,[document_template_id] int ,[effective_date] datetime ,[document_category] int ,[document_template] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [message_document_id],[event_message_id],[document_template_id],[effective_date],[document_category],[document_template],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where message_document_id is null;
	update #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set message_document_id='FARRMS1_ '+cast(message_document_id as varchar(30))  where isnull(message_document_id,'')='' ;
	
print('--==============================END workflow_event_message_documents=============================')

		DELETE FROM #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wemd ON wem.event_message_id = wemd.event_message_id)

	UPDATE wemd SET wemd.event_message_id = wem.new_recid FROM #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wem INNER JOIN #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wemd ON wemd.event_message_id = wem.old_recid
	UPDATE wemd SET wemd.document_template_id = sdv.new_recid FROM #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wemd INNER JOIN #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 sdv ON sdv.old_recid = wemd.document_template_id
	UPDATE wemd SET wemd.document_category = sdv.new_recid FROM #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wemd INNER JOIN #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 sdv ON sdv.old_recid = wemd.document_category
	
print('--==============================START workflow_event_message_documents=============================')
UPDATE dbo.workflow_event_message_documents SET [event_message_id]=src.[event_message_id],[document_template_id]=src.[document_template_id],[effective_date]=src.[effective_date],[document_category]=src.[document_category],[document_template]=src.[document_template]
		   OUTPUT 'u','workflow_event_message_documents',inserted.message_document_id,inserted.message_document_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN workflow_event_message_documents dst  ON src.message_document_id=dst.message_document_id;
insert into workflow_event_message_documents
		([event_message_id],[document_template_id],[effective_date],[document_category],[document_template]
		)
		 OUTPUT 'i','workflow_event_message_documents',inserted.message_document_id,inserted.message_document_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[document_template_id],src.[effective_date],src.[document_category],src.[document_template]
		FROM #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN workflow_event_message_documents dst  ON src.message_document_id=dst.message_document_id
		WHERE dst.[message_document_id] IS NULL;
UPDATE #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid =dst.new_id 
		FROM #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN #old_new_id dst  ON src.message_document_id=dst.unique_key1 AND dst.table_name='workflow_event_message_documents'
		;
print('--==============================END workflow_event_message_documents=============================')

	UPDATE w2 SET w2.new_recid = w1.message_document_id
	FROM workflow_event_message_documents w1 
	INNER JOIN #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 w2 ON w1.event_message_id = w2.event_message_id
		AND ISNULL(w1.document_template_id, '-1') = ISNULL(w2.document_template_id, '-1')
		AND ISNULL(w1.document_category, '-1') = ISNULL(w2.document_category, '-1')
print('--==============================START workflow_event_message_details=============================')

	if object_id('tempdb..#workflow_event_message_details_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #workflow_event_message_details_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [message_detail_id] int ,[event_message_document_id] int ,[message_template_id] int ,[message] varchar(500) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[delivery_method] int ,[internal_contact_type] int ,[email] varchar(300) COLLATE DATABASE_DEFAULT ,[email_cc] varchar(300) COLLATE DATABASE_DEFAULT ,[email_bcc] varchar(300) COLLATE DATABASE_DEFAULT ,[as_defined_in_contact] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_details_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #workflow_event_message_details_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [message_detail_id],[event_message_document_id],[message_template_id],[message],[counterparty_contact_type],[delivery_method],[internal_contact_type],[email],[email_cc],[email_bcc],[as_defined_in_contact],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_details_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where message_detail_id is null;
	update #workflow_event_message_details_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set message_detail_id='FARRMS1_ '+cast(message_detail_id as varchar(30))  where isnull(message_detail_id,'')='' ;
	
print('--==============================END workflow_event_message_details=============================')

	DELETE FROM #workflow_event_message_details_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 WHERE message_detail_id NOT IN (
		SELECT wemd.message_detail_id from #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wemdd 
		INNER JOIN #workflow_event_message_details_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wemd ON wemd.event_message_document_id = wemdd.message_document_id)

	UPDATE wemd SET wemd.event_message_document_id = wem.new_recid FROM #workflow_event_message_documents_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wem INNER JOIN #workflow_event_message_details_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wemd ON wemd.event_message_document_id = wem.old_recid
	UPDATE wemd SET wemd.counterparty_contact_type = sdv.new_recid FROM #workflow_event_message_details_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wemd INNER JOIN #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1  sdv ON sdv.old_recid = wemd.counterparty_contact_type
	UPDATE wemd SET wemd.delivery_method = sdv.new_recid FROM #workflow_event_message_details_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wemd INNER JOIN #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1  sdv ON sdv.old_recid = wemd.delivery_method
	UPDATE wemd SET wemd.internal_contact_type = sdv.new_recid FROM #workflow_event_message_details_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wemd INNER JOIN #static_data_value_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1  sdv ON sdv.old_recid = wemd.internal_contact_type
	
print('--==============================START workflow_event_message_details=============================')
UPDATE dbo.workflow_event_message_details SET [event_message_document_id]=src.[event_message_document_id],[message_template_id]=src.[message_template_id],[message]=src.[message],[counterparty_contact_type]=src.[counterparty_contact_type],[delivery_method]=src.[delivery_method],[internal_contact_type]=src.[internal_contact_type],[email]=src.[email],[email_cc]=src.[email_cc],[email_bcc]=src.[email_bcc],[as_defined_in_contact]=src.[as_defined_in_contact]
		   OUTPUT 'u','workflow_event_message_details',inserted.message_detail_id,inserted.message_detail_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_details_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN workflow_event_message_details dst  ON src.message_detail_id=dst.message_detail_id;
insert into workflow_event_message_details
		([event_message_document_id],[message_template_id],[message],[counterparty_contact_type],[delivery_method],[internal_contact_type],[email],[email_cc],[email_bcc],[as_defined_in_contact]
		)
		 OUTPUT 'i','workflow_event_message_details',inserted.message_detail_id,inserted.message_detail_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_document_id],src.[message_template_id],src.[message],src.[counterparty_contact_type],src.[delivery_method],src.[internal_contact_type],src.[email],src.[email_cc],src.[email_bcc],src.[as_defined_in_contact]
		FROM #workflow_event_message_details_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN workflow_event_message_details dst  ON src.message_detail_id=dst.message_detail_id
		WHERE dst.[message_detail_id] IS NULL;
UPDATE #workflow_event_message_details_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid =dst.new_id 
		FROM #workflow_event_message_details_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN #old_new_id dst  ON src.message_detail_id=dst.unique_key1 AND dst.table_name='workflow_event_message_details'
		;
print('--==============================END workflow_event_message_details=============================')
print('--==============================START alert_reports=============================')

	if object_id('tempdb..#alert_reports_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #alert_reports_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [alert_reports_id] int ,[event_message_id] int ,[report_writer] varchar(1) COLLATE DATABASE_DEFAULT ,[paramset_hash] varchar(8000) COLLATE DATABASE_DEFAULT ,[report_param] varchar(1000) COLLATE DATABASE_DEFAULT ,[report_desc] varchar(500) COLLATE DATABASE_DEFAULT ,[table_prefix] varchar(50) COLLATE DATABASE_DEFAULT ,[table_postfix] varchar(50) COLLATE DATABASE_DEFAULT ,[report_where_clause] varchar(max) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_reports_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #alert_reports_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [alert_reports_id],[event_message_id],[report_writer],[paramset_hash],[report_param],[report_desc],[table_prefix],[table_postfix],[report_where_clause],old_recid
	 )
	 VALUES
	 
(50,1259,'n','',NULL,'Account Status Change Report','alert_credit_file_output_','_acfo','',50),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_reports_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where alert_reports_id is null;
	update #alert_reports_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set event_message_id='FARRMS1_ '+cast(alert_reports_id as varchar(30))  where isnull(event_message_id,'')='' ;
	update #alert_reports_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set report_desc='FARRMS2_ '+cast(alert_reports_id as varchar(30))  where isnull(report_desc,'')='' ;
			update #alert_reports_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set table_prefix='FARRMS3_ '+cast(alert_reports_id as varchar(30))  where isnull(table_prefix,'')='' ;
			
print('--==============================END alert_reports=============================')

		DELETE FROM #alert_reports_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_reports_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 ar ON wem.event_message_id = ar.event_message_id)

	UPDATE ar SET ar.event_message_id = wem.new_recid FROM #workflow_event_message_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 wem INNER JOIN #alert_reports_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 ar ON ar.event_message_id = wem.old_recid
	
print('--==============================START alert_reports=============================')
UPDATE dbo.alert_reports SET [report_writer]=src.[report_writer],[paramset_hash]=src.[paramset_hash],[report_param]=src.[report_param],[table_postfix]=src.[table_postfix],[report_where_clause]=src.[report_where_clause]
		   OUTPUT 'u','alert_reports',inserted.alert_reports_id,inserted.event_message_id,inserted.report_desc,inserted.table_prefix INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_reports_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN alert_reports dst  ON src.event_message_id=dst.event_message_id AND src.report_desc=dst.report_desc AND src.table_prefix=dst.table_prefix;
insert into alert_reports
		([event_message_id],[report_writer],[paramset_hash],[report_param],[report_desc],[table_prefix],[table_postfix],[report_where_clause]
		)
		 OUTPUT 'i','alert_reports',inserted.alert_reports_id,inserted.event_message_id,inserted.report_desc,inserted.table_prefix INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[report_writer],src.[paramset_hash],src.[report_param],src.[report_desc],src.[table_prefix],src.[table_postfix],src.[report_where_clause]
		FROM #alert_reports_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN alert_reports dst  ON src.event_message_id=dst.event_message_id AND src.report_desc=dst.report_desc AND src.table_prefix=dst.table_prefix
		WHERE dst.[alert_reports_id] IS NULL;
UPDATE #alert_reports_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid =dst.new_id 
		FROM #alert_reports_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN #old_new_id dst  ON src.event_message_id=dst.unique_key1 AND src.report_desc=dst.unique_key2 AND src.table_prefix=dst.unique_key3 AND dst.table_name='alert_reports'
		;
print('--==============================END alert_reports=============================')
print('--==============================START alert_report_params=============================')

	if object_id('tempdb..#alert_report_params_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1') is null 
	
	CREATE TABLE #alert_report_params_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1
	 (
	 [alert_report_params_id] int ,[event_message_id] int ,[alert_report_id] int ,[main_table_id] int ,[parameter_name] nvarchar(200) COLLATE DATABASE_DEFAULT ,[parameter_value] nvarchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_report_params_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1;
INSERT INTO #alert_report_params_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1(
	 [alert_report_params_id],[event_message_id],[alert_report_id],[main_table_id],[parameter_name],[parameter_value],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_report_params_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 where alert_report_params_id is null;
	update #alert_report_params_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 set alert_report_id='FARRMS1_ '+cast(alert_report_params_id as varchar(30))  where isnull(alert_report_id,'')='' ;
	
print('--==============================END alert_report_params=============================')

		DELETE FROM #alert_report_params_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_report_params_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 ar ON wem.event_message_id = ar.event_message_id)

	UPDATE arp SET arp.alert_report_id = ar.alert_reports_id FROM #alert_report_params_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 arp INNER JOIN #alert_reports_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 ar ON ar.old_recid = arp.alert_report_id
	UPDATE arp SET arp.main_table_id = art.alert_rule_table_id FROM #alert_report_params_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 arp INNER JOIN #alert_rule_table_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 art ON art.old_recid = arp.main_table_id
	
print('--==============================START alert_report_params=============================')
UPDATE dbo.alert_report_params SET [event_message_id]=src.[event_message_id],[main_table_id]=src.[main_table_id],[parameter_name]=src.[parameter_name],[parameter_value]=src.[parameter_value]
		   OUTPUT 'u','alert_report_params',inserted.alert_report_params_id,inserted.alert_report_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_report_params_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN alert_report_params dst  ON src.alert_report_id=dst.alert_report_id;
insert into alert_report_params
		([event_message_id],[alert_report_id],[main_table_id],[parameter_name],[parameter_value]
		)
		 OUTPUT 'i','alert_report_params',inserted.alert_report_params_id,inserted.alert_report_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[alert_report_id],src.[main_table_id],src.[parameter_name],src.[parameter_value]
		FROM #alert_report_params_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src LEFT JOIN alert_report_params dst  ON src.alert_report_id=dst.alert_report_id
		WHERE dst.[alert_report_params_id] IS NULL;
UPDATE #alert_report_params_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 SET new_recid =dst.new_id 
		FROM #alert_report_params_5C9227A3_F2D2_4CBD_9A67_3F2155094AA1 src INNER JOIN #old_new_id dst  ON src.alert_report_id=dst.unique_key1 AND dst.table_name='alert_report_params'
		;
print('--==============================END alert_report_params=============================')
print('--==============================START static_data_value=============================')

	if object_id('tempdb..#static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [value_id] int ,[type_id] int ,[code] varchar(500) COLLATE DATABASE_DEFAULT ,[description] varchar(500) COLLATE DATABASE_DEFAULT ,[entity_id] int ,[xref_value_id] varchar(50) COLLATE DATABASE_DEFAULT ,[xref_value] varchar(250) COLLATE DATABASE_DEFAULT ,[category_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [value_id],[type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id],old_recid
	 )
	 VALUES
	 
(757,750,'Alert','Alert with Beep Sound',NULL,NULL,NULL,NULL,757),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where value_id is null;
	update #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set code='FARRMS1_ '+cast(value_id as varchar(30))  where isnull(code,'')='' ;
	update #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set type_id='FARRMS2_ '+cast(value_id as varchar(30))  where isnull(type_id,'')='' ;
			
UPDATE dbo.static_data_value SET [description]=src.[description],[entity_id]=src.[entity_id],[xref_value_id]=src.[xref_value_id],[xref_value]=src.[xref_value],[category_id]=src.[category_id]
		   OUTPUT 'u','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id;
insert into static_data_value
		([type_id],[code],[description],[entity_id],[xref_value_id],[xref_value],[category_id]
		)
		 OUTPUT 'i','static_data_value',inserted.value_id,inserted.code,inserted.type_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[type_id],src.[code],src.[description],src.[entity_id],src.[xref_value_id],src.[xref_value],src.[category_id]
		FROM #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN static_data_value dst  ON src.code=dst.code AND src.type_id=dst.type_id
		WHERE dst.[value_id] IS NULL;
UPDATE #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid =dst.new_id 
		FROM #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN #old_new_id dst  ON src.code=dst.unique_key1 AND src.type_id=dst.unique_key2 AND dst.table_name='static_data_value'
		;
print('--==============================END static_data_value=============================')
print('--==============================START alert_sql=============================')

	if object_id('tempdb..#alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [alert_sql_id] int ,[workflow_only] varchar(1) COLLATE DATABASE_DEFAULT ,[message] varchar(500) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,[sql_statement] varchar(max) COLLATE DATABASE_DEFAULT ,[alert_sql_name] varchar(100) COLLATE DATABASE_DEFAULT ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,[alert_type] char(1) COLLATE DATABASE_DEFAULT ,[rule_category] int ,[system_rule] char(1) COLLATE DATABASE_DEFAULT ,[alert_category] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [alert_sql_id],[workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category],old_recid
	 )
	 VALUES
	 
(1139,'n',NULL,'757','IF EXISTS (SELECT 1 FROM adiha_process.sys.tables WHERE [name] = ''counterparty_credit_limits_process_id_ccl'')
BEGIN
 SELECT sc.counterparty_id [Counterparty], 		
		cci.internal_counterparty_id [Internal Counterparty ID],
		cci.contract_id [Contract ID],
		''Limit'' [Changed Column],
		 CONVERT(VARCHAR, CAST(ISNULL(vcpcla.previous_credit_limit, 0) AS MONEY), 1) [Previous Value],
		CONVERT(VARCHAR, CAST(ISNULL(cci.credit_limit, 0) AS MONEY), 1) [Current Value]		
 INTO adiha_process.dbo.alert_credit_limits_output_process_id_aclo
 FROM adiha_process.dbo.[counterparty_credit_limits_process_id_ccl] temp
 INNER JOIN vwCounterPartyCreditLimitsAudit AS vcpcla on vcpcla.counterparty_id = temp.counterparty_id AND vcpcla.counterparty_credit_limit_id = temp.counterparty_credit_limit_id
 INNER JOIN counterparty_credit_limits cci ON  cci.counterparty_credit_limit_id = temp.counterparty_credit_limit_id
 INNER JOIN source_counterparty sc ON cci.Counterparty_id = sc.source_counterparty_id
 WHERE vcpcla.credit_limit_compare = 0
  
 UNION ALL
 
  SELECT sc.counterparty_id [Counterparty], 		
		cci.internal_counterparty_id [Internal Counterparty ID],
		cci.contract_id [Contract ID],
		''Limit To Us'' [Changed Column],
		 CONVERT(VARCHAR, CAST(ISNULL(vcpcla.previous_credit_limit_to_us, 0) AS MONEY), 1) [Previous Value],
		CONVERT(VARCHAR, CAST(ISNULL(cci.credit_limit_to_us, 0) AS MONEY), 1) [Current Value]		 
 FROM adiha_process.dbo.[counterparty_credit_limits_process_id_ccl] temp
 INNER JOIN vwCounterPartyCreditLimitsAudit AS vcpcla on vcpcla.counterparty_id = temp.counterparty_id AND vcpcla.counterparty_credit_limit_id = temp.counterparty_credit_limit_id
 INNER JOIN counterparty_credit_limits cci ON  cci.counterparty_credit_limit_id = temp.counterparty_credit_limit_id
 INNER JOIN source_counterparty sc ON cci.Counterparty_id = sc.source_counterparty_id
 WHERE vcpcla.credit_limit_to_us_compare = 0

END','Counterparty Credit Limit Update','y','s',-1,'n',NULL,1139),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where alert_sql_id is null;
	update #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set alert_sql_name='FARRMS1_ '+cast(alert_sql_id as varchar(30))  where isnull(alert_sql_name,'')='' ;
	
print('--==============================END alert_sql=============================')

UPDATE dbo.alert_sql SET [workflow_only]=src.[workflow_only],[message]=src.[message],[notification_type]=src.[notification_type],[sql_statement]=src.[sql_statement],[is_active]=src.[is_active],[alert_type]=src.[alert_type],[rule_category]=src.[rule_category],[system_rule]=src.[system_rule],[alert_category]=src.[alert_category]
		   OUTPUT 'u','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name;

IF EXISTS(SELECT 1 FROM #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 WHERE alert_sql_id < 0)
BEGIN
	SET IDENTITY_INSERT alert_sql ON
	INSERT INTO alert_sql
	([alert_sql_id], [workflow_only],[message],[notification_type],[sql_statement],[alert_sql_name],[is_active],[alert_type],[rule_category],[system_rule],[alert_category]
	)
	OUTPUT 'i','alert_sql',inserted.alert_sql_id,inserted.alert_sql_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	SELECT 
	src.alert_sql_id, src.[workflow_only],src.[message],src.[notification_type],src.[sql_statement],src.[alert_sql_name],src.[is_active],src.[alert_type],src.[rule_category],src.[system_rule],src.[alert_category]
	FROM #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
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
	FROM #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
	WHERE dst.[alert_sql_id] IS NULL;
END

UPDATE #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid = dst.new_id , alert_sql_id =  dst.new_id
FROM #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN #old_new_id dst ON src.alert_sql_name = dst.unique_key1 AND dst.table_name = 'alert_sql'

UPDATE asl SET asl.notification_type = sdv.new_recid 
FROM alert_sql asl INNER JOIN #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29 sdv ON sdv.old_recid = asl.notification_type	

UPDATE asl SET asl.rule_category = sdv.new_recid
FROM alert_sql asl INNER JOIN #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 tasl ON tasl.new_recid = asl.alert_sql_id 
INNER JOIN #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29 sdv ON sdv.old_recid = asl.rule_category	


	INSERT INTO #alert_sql_bkup (alert_sql_id, workflow_only, message, notification_type, sql_statement, alert_sql_name, is_active, alert_type, rule_category, system_rule, alert_category, new_recid, old_recid)
	SELECT asl.alert_sql_id, asl.workflow_only, asl.message, asl.notification_type, asl.sql_statement, asl.alert_sql_name, asl.is_active, asl.alert_type, asl.rule_category, asl.system_rule, asl.alert_category, asl.new_recid, asl.old_recid FROM #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 asl
	LEFT JOIN #alert_sql_bkup aslb ON aslb.old_recid = asl.old_recid
	WHERE aslb.old_recid IS NULL
print('--==============================START alert_table_definition=============================')

	if object_id('tempdb..#alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [alert_table_definition_id] int ,[logical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[physical_table_name] varchar(1000) COLLATE DATABASE_DEFAULT ,[data_source_id] int ,[is_action_view] char(1) COLLATE DATABASE_DEFAULT ,[primary_column] varchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [alert_table_definition_id],[logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where alert_table_definition_id is null;
	update #alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set logical_table_name='FARRMS1_ '+cast(alert_table_definition_id as varchar(30))  where isnull(logical_table_name,'')='' ;
	
UPDATE dbo.alert_table_definition SET [physical_table_name]=src.[physical_table_name],[data_source_id]=src.[data_source_id],[is_action_view]=src.[is_action_view],[primary_column]=src.[primary_column]
		   OUTPUT 'u','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name;
insert into alert_table_definition
		([logical_table_name],[physical_table_name],[data_source_id],[is_action_view],[primary_column]
		)
		 OUTPUT 'i','alert_table_definition',inserted.alert_table_definition_id,inserted.logical_table_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[logical_table_name],src.[physical_table_name],src.[data_source_id],src.[is_action_view],src.[primary_column]
		FROM #alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN alert_table_definition dst  ON src.logical_table_name=dst.logical_table_name
		WHERE dst.[alert_table_definition_id] IS NULL;
UPDATE #alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid =dst.new_id 
		FROM #alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN #old_new_id dst  ON src.logical_table_name=dst.unique_key1 AND dst.table_name='alert_table_definition'
		;
print('--==============================END alert_table_definition=============================')

UPDATE #alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET alert_table_definition_id = new_recid

print('--==============================START alert_columns_definition=============================')

	if object_id('tempdb..#alert_columns_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #alert_columns_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [alert_columns_definition_id] int ,[alert_table_id] int ,[column_name] varchar(600) COLLATE DATABASE_DEFAULT ,[is_primary] char(1) COLLATE DATABASE_DEFAULT ,[static_data_type_id] int ,[column_alias] varchar(200) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_columns_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #alert_columns_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [alert_columns_definition_id],[alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_columns_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where alert_columns_definition_id is null;
	update #alert_columns_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set column_name='FARRMS1_ '+cast(alert_columns_definition_id as varchar(30))  where isnull(column_name,'')='' ;
	
print('--==============================END alert_columns_definition=============================')

UPDATE acd SET acd.alert_table_id = atd.new_recid
FROM #alert_columns_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 acd INNER JOIN #alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 atd ON atd.old_recid = acd.alert_table_id

print('--==============================START alert_columns_definition=============================')
UPDATE dbo.alert_columns_definition SET [alert_table_id]=dst.[alert_table_definition_id],[is_primary]=src_c.[is_primary],[static_data_type_id]=src_c.[static_data_type_id],[column_alias]=src_c.[column_alias]
		   OUTPUT 'u','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src_c ON src_c.alert_table_id=src.alert_table_definition_id
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name;
insert into alert_columns_definition
		([alert_table_id],[column_name],[is_primary],[static_data_type_id],[column_alias]
		)
		 OUTPUT 'i','alert_columns_definition',inserted.alert_columns_definition_id,inserted.column_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[alert_table_id],src_c.[column_name],src_c.[is_primary],src_c.[static_data_type_id],src_c.[column_alias]
		FROM #alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name 
			INNER JOIN #alert_columns_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			LEFT JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id AND src_c.column_name=dst_c.column_name
		WHERE dst_c.[alert_table_id] IS NULL;
UPDATE #alert_columns_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid =dst_c.[alert_columns_definition_id] 
			FROM #alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN alert_table_definition dst  ON src.physical_table_name=dst.physical_table_name
			INNER JOIN #alert_columns_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src_c ON src_c.alert_table_id=src.alert_table_definition_id	
			INNER JOIN alert_columns_definition dst_c ON dst_c.alert_table_id=dst.alert_table_definition_id
			 AND src_c.column_name=dst_c.column_name;
print('--==============================END alert_columns_definition=============================')

DELETE FROM alert_table_relation WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29)
DELETE FROM alert_actions_events WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29)
DELETE FROM alert_actions WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29)
DELETE FROM alert_table_where_clause WHERE alert_id IN (SELECT alert_sql_id FROM #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29)
DELETE from alert_conditions WHERE rules_id IN (SELECT alert_sql_id FROM #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29)
DELETE from alert_rule_table where alert_id IN (SELECT alert_sql_id FROM #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29)
print('--==============================START alert_rule_table=============================')

	if object_id('tempdb..#alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [alert_rule_table_id] int ,[alert_id] int ,[table_id] int ,[root_table_id] int ,[table_alias] varchar(50) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [alert_rule_table_id],[alert_id],[table_id],[root_table_id],[table_alias],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where alert_rule_table_id is null;
	update #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set alert_rule_table_id='FARRMS1_ '+cast(alert_rule_table_id as varchar(30))  where isnull(alert_rule_table_id,'')='' ;
	
print('--==============================END alert_rule_table=============================')

UPDATE art SET art.alert_id = asl.new_recid
FROM #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 art INNER JOIN #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 asl ON asl.old_recid = art.alert_id

UPDATE art SET art.table_id = asd.new_recid
FROM #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 art INNER JOIN #alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29  asd ON asd.old_recid = art.table_id

UPDATE dbo.alert_rule_table SET [table_alias]=src.[table_alias]
		   OUTPUT 'u','alert_rule_table',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
insert into alert_rule_table
		([alert_id],[table_id],[root_table_id],[table_alias]
		)
		 OUTPUT 'i','alert_rule_table',inserted.alert_rule_table_id,inserted.alert_id,inserted.table_id,inserted.root_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[root_table_id],src.[table_alias]
		FROM #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN alert_rule_table dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id AND ISNULL(src.root_table_id, -1)=ISNULL(dst.root_table_id, -1)
		WHERE dst.[alert_rule_table_id] IS NULL;
UPDATE #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid =dst.new_id 
		FROM #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND ISNULL(src.root_table_id, -1)=ISNULL(dst.unique_key3, -1) AND dst.table_name='alert_rule_table'
		;
print('--==============================END alert_rule_table=============================')
	-- need to verify root_table_id
UPDATE art SET art.root_table_id = art2.new_recid FROM #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 art INNER JOIN #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 art2 ON art2.old_recid = art.root_table_id  
UPDATE art SET art.root_table_id = arrt.root_table_id FROM alert_rule_table art INNER JOIN #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 arrt ON arrt.new_recid = art.alert_rule_table_id 

print('--==============================START alert_conditions=============================')

	if object_id('tempdb..#alert_conditions_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #alert_conditions_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [alert_conditions_id] int ,[rules_id] int ,[alert_conditions_name] varchar(100) COLLATE DATABASE_DEFAULT ,[alert_conditions_description] varchar(500) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_conditions_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #alert_conditions_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [alert_conditions_id],[rules_id],[alert_conditions_name],[alert_conditions_description],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,null);
	delete #alert_conditions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where alert_conditions_id is null;
	update #alert_conditions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set alert_conditions_name='FARRMS1_ '+cast(alert_conditions_id as varchar(30))  where isnull(alert_conditions_name,'')='' ;
	
print('--==============================END alert_conditions=============================')

UPDATE ac SET rules_id = asl.new_recid	
FROM #alert_conditions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 ac INNER JOIN #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 asl ON asl.old_recid = ac.rules_id
print('--==============================START alert_conditions=============================')
UPDATE dbo.alert_conditions SET [rules_id]=dst.[alert_sql_id],[alert_conditions_description]=src_c.[alert_conditions_description]
		   OUTPUT 'u','alert_conditions',inserted.alert_conditions_id,inserted.alert_conditions_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	 FROM #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
			INNER JOIN #alert_conditions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src_c ON src_c.rules_id=src.alert_sql_id
			INNER JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id AND src_c.alert_conditions_name=dst_c.alert_conditions_name;
insert into alert_conditions
		([rules_id],[alert_conditions_name],[alert_conditions_description]
		)
		 OUTPUT 'i','alert_conditions',inserted.alert_conditions_id,inserted.alert_conditions_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src_c.[rules_id],src_c.[alert_conditions_name],src_c.[alert_conditions_description]
		FROM #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name 
			INNER JOIN #alert_conditions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src_c ON src_c.rules_id=src.alert_sql_id	
			LEFT JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id AND src_c.alert_conditions_name=dst_c.alert_conditions_name
		WHERE dst_c.[rules_id] IS NULL;
UPDATE #alert_conditions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid =dst_c.[alert_conditions_id] 
			FROM #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN alert_sql dst  ON src.alert_sql_name=dst.alert_sql_name
			INNER JOIN #alert_conditions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src_c ON src_c.rules_id=src.alert_sql_id	
			INNER JOIN alert_conditions dst_c ON dst_c.rules_id=dst.alert_sql_id
			 AND src_c.alert_conditions_name=dst_c.alert_conditions_name;
print('--==============================END alert_conditions=============================')

UPDATE #alert_conditions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET alert_conditions_id = new_recid
print('--==============================START alert_table_where_clause=============================')

	if object_id('tempdb..#alert_table_where_clause_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #alert_table_where_clause_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [alert_table_where_clause_id] int ,[alert_id] int ,[clause_type] int ,[column_id] int ,[operator_id] int ,[column_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[second_value] varchar(1000) COLLATE DATABASE_DEFAULT ,[table_id] int ,[column_function] varchar(1000) COLLATE DATABASE_DEFAULT ,[condition_id] int ,[sequence_no] int ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_where_clause_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #alert_table_where_clause_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [alert_table_where_clause_id],[alert_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[condition_id],[sequence_no],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_where_clause_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where alert_table_where_clause_id is null;
	update #alert_table_where_clause_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set alert_table_where_clause_id='FARRMS1_ '+cast(alert_table_where_clause_id as varchar(30))  where isnull(alert_table_where_clause_id,'')='' ;
	
print('--==============================END alert_table_where_clause=============================')

UPDATE atwc SET atwc.alert_id = asl.new_recid FROM #alert_table_where_clause_3C32F5D7_8948_48AF_9864_BDA418FDFA29 atwc INNER JOIN #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 asl ON asl.old_recid = atwc.alert_id
UPDATE atwc SET atwc.column_id = acd.new_recid FROM #alert_table_where_clause_3C32F5D7_8948_48AF_9864_BDA418FDFA29 atwc INNER JOIN #alert_columns_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29  acd ON acd.old_recid = atwc.column_id
UPDATE atwc SET atwc.table_id = art.new_recid FROM #alert_table_where_clause_3C32F5D7_8948_48AF_9864_BDA418FDFA29 atwc INNER JOIN #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 art ON art.old_recid = atwc.table_id
UPDATE atwc SET atwc.condition_id = ac.new_recid FROM #alert_table_where_clause_3C32F5D7_8948_48AF_9864_BDA418FDFA29 atwc INNER JOIN #alert_conditions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 ac ON ac.old_recid = atwc.condition_id

print('--==============================START alert_table_where_clause=============================')
UPDATE dbo.alert_table_where_clause SET [alert_id]=src.[alert_id],[clause_type]=src.[clause_type],[column_id]=src.[column_id],[operator_id]=src.[operator_id],[column_value]=src.[column_value],[second_value]=src.[second_value],[table_id]=src.[table_id],[column_function]=src.[column_function],[condition_id]=src.[condition_id],[sequence_no]=src.[sequence_no],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','alert_table_where_clause',inserted.alert_table_where_clause_id,inserted.alert_table_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_table_where_clause_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN alert_table_where_clause dst  ON src.alert_table_where_clause_id=dst.alert_table_where_clause_id;
insert into alert_table_where_clause
		([alert_id],[clause_type],[column_id],[operator_id],[column_value],[second_value],[table_id],[column_function],[condition_id],[sequence_no],[data_source_column_id]
		)
		 OUTPUT 'i','alert_table_where_clause',inserted.alert_table_where_clause_id,inserted.alert_table_where_clause_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[clause_type],src.[column_id],src.[operator_id],src.[column_value],src.[second_value],src.[table_id],src.[column_function],src.[condition_id],src.[sequence_no],src.[data_source_column_id]
		FROM #alert_table_where_clause_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN alert_table_where_clause dst  ON src.alert_table_where_clause_id=dst.alert_table_where_clause_id
		WHERE dst.[alert_table_where_clause_id] IS NULL;
UPDATE #alert_table_where_clause_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid =dst.new_id 
		FROM #alert_table_where_clause_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN #old_new_id dst  ON src.alert_table_where_clause_id=dst.unique_key1 AND dst.table_name='alert_table_where_clause'
		;
print('--==============================END alert_table_where_clause=============================')
print('--==============================START alert_actions=============================')

	if object_id('tempdb..#alert_actions_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #alert_actions_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [alert_actions_id] int ,[alert_id] int ,[table_id] int ,[column_id] int ,[column_value] varchar(500) COLLATE DATABASE_DEFAULT ,[condition_id] int ,[sql_statement] varchar(max) COLLATE DATABASE_DEFAULT ,[data_source_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_actions_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #alert_actions_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [alert_actions_id],[alert_id],[table_id],[column_id],[column_value],[condition_id],[sql_statement],[data_source_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_actions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where alert_actions_id is null;
	update #alert_actions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set alert_id='FARRMS1_ '+cast(alert_actions_id as varchar(30))  where isnull(alert_id,'')='' ;
	
print('--==============================END alert_actions=============================')

UPDATE aa SET aa.column_id = acd.new_recid FROM #alert_actions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 aa INNER JOIN #alert_columns_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29  acd ON acd.old_recid = aa.column_id
UPDATE aa SET aa.table_id = art.new_recid FROM #alert_actions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 aa INNER JOIN #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 art ON art.old_recid = aa.table_id
UPDATE aa SET aa.condition_id = ac.new_recid FROM #alert_actions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 aa INNER JOIN #alert_conditions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 ac ON ac.old_recid = aa.condition_id
UPDATE aa SET aa.alert_id = asl.new_recid FROM #alert_actions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 aa INNER JOIN #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 asl ON asl.old_recid = aa.alert_id

print('--==============================START alert_actions=============================')
UPDATE dbo.alert_actions SET [table_id]=src.[table_id],[column_id]=src.[column_id],[column_value]=src.[column_value],[condition_id]=src.[condition_id],[sql_statement]=src.[sql_statement],[data_source_column_id]=src.[data_source_column_id]
		   OUTPUT 'u','alert_actions',inserted.alert_actions_id,inserted.alert_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_actions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN alert_actions dst  ON src.alert_id=dst.alert_id;
insert into alert_actions
		([alert_id],[table_id],[column_id],[column_value],[condition_id],[sql_statement],[data_source_column_id]
		)
		 OUTPUT 'i','alert_actions',inserted.alert_actions_id,inserted.alert_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[column_id],src.[column_value],src.[condition_id],src.[sql_statement],src.[data_source_column_id]
		FROM #alert_actions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN alert_actions dst  ON src.alert_id=dst.alert_id
		WHERE dst.[alert_actions_id] IS NULL;
UPDATE #alert_actions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid =dst.new_id 
		FROM #alert_actions_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND dst.table_name='alert_actions'
		;
print('--==============================END alert_actions=============================')
print('--==============================START alert_actions_events=============================')

	if object_id('tempdb..#alert_actions_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #alert_actions_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [alert_actions_events_id] int ,[alert_id] int ,[table_id] int ,[callback_alert_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_actions_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #alert_actions_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [alert_actions_events_id],[alert_id],[table_id],[callback_alert_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,null);
	delete #alert_actions_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where alert_actions_events_id is null;
	update #alert_actions_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set alert_id='FARRMS1_ '+cast(alert_actions_events_id as varchar(30))  where isnull(alert_id,'')='' ;
	update #alert_actions_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set table_id='FARRMS2_ '+cast(alert_actions_events_id as varchar(30))  where isnull(table_id,'')='' ;
			update #alert_actions_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set callback_alert_id='FARRMS3_ '+cast(alert_actions_events_id as varchar(30))  where isnull(callback_alert_id,'')='' ;
			
print('--==============================END alert_actions_events=============================')

UPDATE aae SET aae.alert_id = asl.new_recid FROM #alert_actions_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 aae INNER JOIN #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 asl ON asl.old_recid = aae.alert_id
UPDATE aae SET aae.table_id = art.new_recid FROM #alert_actions_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 aae INNER JOIN #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 art ON art.old_recid = aae.table_id

print('--==============================START alert_actions_events=============================')
UPDATE dbo.alert_actions_events SET [callback_alert_id]=src.[callback_alert_id]
		   OUTPUT 'u','alert_actions_events',inserted.alert_actions_events_id,inserted.alert_id,inserted.table_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_actions_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN alert_actions_events dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id;
insert into alert_actions_events
		([alert_id],[table_id],[callback_alert_id]
		)
		 OUTPUT 'i','alert_actions_events',inserted.alert_actions_events_id,inserted.alert_id,inserted.table_id,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[table_id],src.[callback_alert_id]
		FROM #alert_actions_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN alert_actions_events dst  ON src.alert_id=dst.alert_id AND src.table_id=dst.table_id
		WHERE dst.[alert_actions_events_id] IS NULL;
UPDATE #alert_actions_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid =dst.new_id 
		FROM #alert_actions_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN #old_new_id dst  ON src.alert_id=dst.unique_key1 AND src.table_id=dst.unique_key2 AND dst.table_name='alert_actions_events'
		;
print('--==============================END alert_actions_events=============================')
print('--==============================START alert_table_relation=============================')

	if object_id('tempdb..#alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [alert_table_relation_id] int ,[alert_id] int ,[from_table_id] int ,[from_column_id] int ,[to_table_id] int ,[to_column_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [alert_table_relation_id],[alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where alert_table_relation_id is null;
	update #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set alert_id='FARRMS1_ '+cast(alert_table_relation_id as varchar(30))  where isnull(alert_id,'')='' ;
	update #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set from_table_id='FARRMS2_ '+cast(alert_table_relation_id as varchar(30))  where isnull(from_table_id,'')='' ;
			update #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set to_table_id='FARRMS3_ '+cast(alert_table_relation_id as varchar(30))  where isnull(to_table_id,'')='' ;
			
print('--==============================END alert_table_relation=============================')
	
update #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set from_column_id='FARRMS4_ '+cast(alert_table_relation_id as varchar(30))  where isnull(from_column_id,'')='' ;
update #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set to_column_id='FARRMS5_ '+cast(alert_table_relation_id as varchar(30))  where isnull(to_column_id,'')='' ;

UPDATE atr SET atr.alert_id	= asl.new_recid FROM #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29 atr INNER JOIN #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 asl ON asl.old_recid = atr.alert_id		
UPDATE atr SET atr.from_table_id = atd.new_recid FROM #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29 atr INNER JOIN #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 atd ON atd.old_recid = atr.from_table_id		
UPDATE atr SET atr.to_table_id = atd.new_recid FROM #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29 atr INNER JOIN #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 atd ON atd.old_recid = atr.to_table_id		
UPDATE atr SET atr.from_column_id = atd.new_recid FROM #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29 atr INNER JOIN #alert_columns_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 atd ON atd.old_recid = atr.from_column_id		
UPDATE atr SET atr.to_column_id = atd.new_recid FROM #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29 atr INNER JOIN #alert_columns_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 atd ON atd.old_recid = atr.to_column_id		

insert into alert_table_relation
		([alert_id],[from_table_id],[from_column_id],[to_table_id],[to_column_id]
		)
		 OUTPUT 'i','alert_table_relation',inserted.alert_table_relation_id,inserted.alert_id,inserted.from_table_id,inserted.to_table_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[alert_id],src.[from_table_id],src.[from_column_id],src.[to_table_id],src.[to_column_id]
		FROM #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN alert_table_relation dst  
		ON src.alert_id=dst.alert_id AND src.from_table_id=dst.from_table_id AND src.to_table_id=dst.to_table_id
		AND src.from_column_id=dst.from_column_id AND src.to_column_id=dst.to_column_id
		WHERE dst.[alert_table_relation_id] IS NULL;
UPDATE #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid = atr.alert_table_relation_id 
		FROM #alert_table_relation_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN alert_table_relation atr ON src.alert_id=atr.alert_id 
		AND src.from_table_id=atr.from_table_id AND src.to_table_id=atr.to_table_id 
		AND src.from_column_id=atr.from_column_id AND src.to_column_id=atr.to_column_id 
		;
print('--==============================END alert_table_relation=============================')		

print('--==============================START module_events=============================')

	if object_id('tempdb..#module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [module_events_id] int ,[modules_id] int ,[event_id] varchar(2000) COLLATE DATABASE_DEFAULT ,[workflow_name] varchar(100) COLLATE DATABASE_DEFAULT ,[workflow_owner] varchar(100) COLLATE DATABASE_DEFAULT ,[rule_table_id] int ,[is_active] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [module_events_id],[modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id],[is_active],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where module_events_id is null;
	update #module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set workflow_name='FARRMS1_ '+cast(module_events_id as varchar(30))  where isnull(workflow_name,'')='' ;
	
print('--==============================END module_events=============================')
	
	UPDATE me SET me.rule_table_id = atd.new_recid FROM #module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 me INNER JOIN #alert_table_definition_3C32F5D7_8948_48AF_9864_BDA418FDFA29 atd ON atd.old_recid = me.rule_table_id

	UPDATE dbo.module_events SET [modules_id]=src.[modules_id],[event_id]=src.[event_id],[workflow_owner]=src.[workflow_owner],[rule_table_id]=src.[rule_table_id]
			   OUTPUT 'u','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
		FROM #module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN module_events dst  ON src.workflow_name=dst.workflow_name;
	insert into module_events
			([modules_id],[event_id],[workflow_name],[workflow_owner],[rule_table_id]
			)
			 OUTPUT 'i','module_events',inserted.module_events_id,inserted.workflow_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_id],src.[event_id],src.[workflow_name],src.[workflow_owner],src.[rule_table_id]
			FROM #module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN module_events dst  ON src.workflow_name=dst.workflow_name
			WHERE dst.[module_events_id] IS NULL;

			UPDATE #module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid = b.new_id 		
			FROM #module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 a 
			INNER JOIN 
			( SELECT TOP(1) new_id, unique_key1 FROM  #module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src 
			INNER JOIN #old_new_id dst ON src.workflow_name=dst.unique_key1 AND dst.table_name='module_events' ORDER BY new_id DESC
			) b ON a.workflow_name= b.unique_key1 

	

	UPDATE me SET me.modules_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29 sdv ON sdv.old_recid = me.modules_id

	UPDATE me SET me.event_id = sdv.new_recid FROM module_events me 
	INNER JOIN #module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 mee ON mee.new_recid = me.module_events_id
	INNER JOIN #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29 sdv ON sdv.old_recid = me.event_id
	
print('--==============================START event_trigger=============================')

	if object_id('tempdb..#event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [event_trigger_id] int ,[modules_event_id] int ,[alert_id] int ,[initial_event] char(1) COLLATE DATABASE_DEFAULT ,[manual_step] char(1) COLLATE DATABASE_DEFAULT ,[is_disable] char(1) COLLATE DATABASE_DEFAULT ,[report_paramset_id] varchar(max) COLLATE DATABASE_DEFAULT ,[report_filters] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [event_trigger_id],[modules_event_id],[alert_id],[initial_event],[manual_step],[is_disable],[report_paramset_id],[report_filters],old_recid
	 )
	 VALUES
	 
(1362,1180,1139,'n','n','n','',0,1362),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where event_trigger_id is null;
	update #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set modules_event_id='FARRMS1_ '+cast(event_trigger_id as varchar(30))  where isnull(modules_event_id,'')='' ;
	update #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set alert_id='FARRMS2_ '+cast(event_trigger_id as varchar(30))  where isnull(alert_id,'')='' ;
			
print('--==============================END event_trigger=============================')

		
		IF EXISTS (SELECT 1 FROM #module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29)
		BEGIN
			DELETE FROM #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29 WHERE modules_event_id NOT IN (
			SELECT mebs.module_events_id FROM #module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 mebs INNER JOIN #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29 et 
			ON et.modules_event_id = mebs.module_events_id)
		END
		ELSE
		BEGIN
			DELETE FROM #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29 WHERE modules_event_id NOT IN 
			(SELECT meb.module_events_id FROM #module_events_bkup meb INNER JOIN #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29 et 
			ON et.modules_event_id = meb.module_events_id)
		END
		
	
	UPDATE et SET et.alert_id = asl.new_recid FROM #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29 et INNER JOIN #alert_sql_3C32F5D7_8948_48AF_9864_BDA418FDFA29 asl ON asl.old_recid = et.alert_id WHERE et.alert_id <> -1
	UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29 et INNER JOIN #module_events_3C32F5D7_8948_48AF_9864_BDA418FDFA29 me ON me.old_recid = et.modules_event_id
	
UPDATE et SET et.modules_event_id = me.new_recid FROM #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29 et INNER JOIN #module_events_bkup me ON me.old_recid = et.modules_event_id

	print('--==============================START event_trigger=============================')

	UPDATE event_trigger SET 
	 [initial_event] = src.[initial_event]
	, [manual_step] = src.[manual_step]
	, [is_disable] = src.[is_disable]
	, [report_paramset_id] = src.[report_paramset_id]
	, [report_filters] = src.[report_filters]
	 OUTPUT 'u','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,src.report_paramset_id  
	 INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src 
	INNER JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id

	insert into event_trigger
			([modules_event_id],[alert_id],[initial_event], [manual_step], [is_disable], [report_paramset_id], [report_filters]
			)
			 OUTPUT 'i','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,inserted.report_paramset_id INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
			SELECT 
			src.[modules_event_id],src.[alert_id],src.[initial_event], src.[manual_step], src.[is_disable], src.[report_paramset_id], src.[report_filters]
			FROM #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id
			WHERE dst.[event_trigger_id] IS NULL;
	UPDATE #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid =dst.new_id 
			FROM #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN #old_new_id dst  ON src.modules_event_id=dst.unique_key1 AND src.alert_id=dst.unique_key2 AND dst.table_name='event_trigger'
			AND ISNULL(src.report_paramset_id,-999) = ISNULL(dst.unique_key3,-999);
	print('--==============================END event_trigger=============================')
print('--==============================START workflow_event_message=============================')

	if object_id('tempdb..#workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [event_message_id] int ,[event_trigger_id] int ,[event_message_name] varchar(100) COLLATE DATABASE_DEFAULT ,[message_template_id] int ,[message] varchar(1000) COLLATE DATABASE_DEFAULT ,[mult_approval_required] char(1) COLLATE DATABASE_DEFAULT ,[comment_required] char(1) COLLATE DATABASE_DEFAULT ,[approval_action_required] char(1) COLLATE DATABASE_DEFAULT ,[self_notify] char(1) COLLATE DATABASE_DEFAULT ,[notify_trader] char(1) COLLATE DATABASE_DEFAULT ,[next_module_events_id] int ,[minimum_approval_required] int ,[optional_event_msg] char(1) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[automatic_proceed] char(1) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [event_message_id],[event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type],old_recid
	 )
	 VALUES
	 
(1260,1362,'Credit Limi Update Alert',NULL,'<#COUNTERPARTY><COUNTERPARTY><COUNTERPARTY#> Counterparty credit limit has been updated.  <#ALERT_REPORT>','n','n','n','y','n',NULL,NULL,'n',NULL,'n','757',1260),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where event_message_id is null;
	update #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set event_trigger_id='FARRMS1_ '+cast(event_message_id as varchar(30))  where isnull(event_trigger_id,'')='' ;
	update #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set event_message_name='FARRMS2_ '+cast(event_message_id as varchar(30))  where isnull(event_message_name,'')='' ;
			
print('--==============================END workflow_event_message=============================')

		IF EXISTS (SELECT 1 FROM #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29)
		BEGIN	
			DELETE FROM #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wem INNER JOIN #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29 et ON et.old_recid = wem.event_trigger_id)
		END
		

	UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wem INNER JOIN #event_trigger_3C32F5D7_8948_48AF_9864_BDA418FDFA29 et ON et.old_recid = wem.event_trigger_id

		UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wem INNER JOIN #event_trigger_bkup et ON et.old_recid = wem.event_trigger_id
		UPDATE wem SET wem.next_module_events_id = meb.new_recid FROM #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wem  INNER JOIN #module_events_bkup meb ON meb.old_recid = wem.next_module_events_id
print('--==============================START workflow_event_message=============================')
UPDATE dbo.workflow_event_message SET [message_template_id]=src.[message_template_id],[message]=src.[message],[mult_approval_required]=src.[mult_approval_required],[comment_required]=src.[comment_required],[approval_action_required]=src.[approval_action_required],[self_notify]=src.[self_notify],[notify_trader]=src.[notify_trader],[next_module_events_id]=src.[next_module_events_id],[minimum_approval_required]=src.[minimum_approval_required],[optional_event_msg]=src.[optional_event_msg],[counterparty_contact_type]=src.[counterparty_contact_type],[automatic_proceed]=src.[automatic_proceed],[notification_type]=src.[notification_type]
		   OUTPUT 'u','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name;
insert into workflow_event_message
		([event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type]
		)
		 OUTPUT 'i','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_trigger_id],src.[event_message_name],src.[message_template_id],src.[message],src.[mult_approval_required],src.[comment_required],src.[approval_action_required],src.[self_notify],src.[notify_trader],src.[next_module_events_id],src.[minimum_approval_required],src.[optional_event_msg],src.[counterparty_contact_type],src.[automatic_proceed],src.[notification_type]
		FROM #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name
		WHERE dst.[event_message_id] IS NULL;
UPDATE #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid =dst.new_id 
		FROM #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN #old_new_id dst  ON src.event_trigger_id=dst.unique_key1 AND src.event_message_name=dst.unique_key2 AND dst.table_name='workflow_event_message'
		;
print('--==============================END workflow_event_message=============================')
	
		INSERT INTO #workflow_event_message_bkup (event_message_id, event_trigger_id, event_message_name, message_template_id, message, mult_approval_required, comment_required, approval_action_required, self_notify, notify_trader, counterparty_contact_type, next_module_events_id, minimum_approval_required, optional_event_msg, automatic_proceed, notification_type, new_recid, old_recid)
		SELECT wem.event_message_id, wem.event_trigger_id, wem.event_message_name, wem.message_template_id, wem.message, wem.mult_approval_required, wem.comment_required, wem.approval_action_required, wem.self_notify, wem.notify_trader, wem.counterparty_contact_type, wem.next_module_events_id, wem.minimum_approval_required, wem.optional_event_msg, wem.automatic_proceed, wem.notification_type, wem.new_recid, wem.old_recid FROM #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wem
		LEFT JOIN #workflow_event_message_bkup wemb ON wemb.old_recid = wem.old_recid 
		WHERE wemb.old_recid IS NULL
print('--==============================START application_security_role=============================')

	if object_id('tempdb..#application_security_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #application_security_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [role_id] int ,[role_name] varchar(50) COLLATE DATABASE_DEFAULT ,[role_description] varchar(250) COLLATE DATABASE_DEFAULT ,[role_type_value_id] int ,[process_map_file_name] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #application_security_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #application_security_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [role_id],[role_name],[role_description],[role_type_value_id],[process_map_file_name],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,null);
	delete #application_security_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where role_id is null;
	update #application_security_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set role_name='FARRMS1_ '+cast(role_id as varchar(30))  where isnull(role_name,'')='' ;
	
UPDATE dbo.application_security_role SET [role_description]=src.[role_description],[role_type_value_id]=src.[role_type_value_id],[process_map_file_name]=src.[process_map_file_name]
		   OUTPUT 'u','application_security_role',inserted.role_id,inserted.role_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #application_security_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN application_security_role dst  ON src.role_name=dst.role_name;
insert into application_security_role
		([role_name],[role_description],[role_type_value_id],[process_map_file_name]
		)
		 OUTPUT 'i','application_security_role',inserted.role_id,inserted.role_name,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[role_name],src.[role_description],src.[role_type_value_id],src.[process_map_file_name]
		FROM #application_security_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN application_security_role dst  ON src.role_name=dst.role_name
		WHERE dst.[role_id] IS NULL;
UPDATE #application_security_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid =dst.new_id 
		FROM #application_security_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN #old_new_id dst  ON src.role_name=dst.unique_key1 AND dst.table_name='application_security_role'
		;
print('--==============================END application_security_role=============================')
print('--==============================START workflow_event_user_role=============================')

	if object_id('tempdb..#workflow_event_user_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #workflow_event_user_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [event_user_role_id] int ,[event_message_id] int ,[user_login_id] varchar(50) COLLATE DATABASE_DEFAULT ,[role_id] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_user_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #workflow_event_user_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [event_user_role_id],[event_message_id],[user_login_id],[role_id],old_recid
	 )
	 VALUES
	 
(7754,1260,'farrms_admin',NULL,7754),
(7755,1260,'user1',NULL,7755),
(7756,1260,'bipana',NULL,7756),
(7757,1260,'jenish',NULL,7757),
(NULL,NULL,NULL,NULL,null);
	delete #workflow_event_user_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where event_user_role_id is null;
	update #workflow_event_user_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set event_user_role_id='FARRMS1_ '+cast(event_user_role_id as varchar(30))  where isnull(event_user_role_id,'')='' ;
	
print('--==============================END workflow_event_user_role=============================')
	
		DELETE FROM #workflow_event_user_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 WHERE event_message_id NOT IN (SELECT wem.event_message_id FROM #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wem INNER JOIN #workflow_event_user_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 weur ON weur.event_message_id = wem.event_message_id	)
		
	
	UPDATE weur SET weur.role_id = asr.new_recid FROM #workflow_event_user_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 weur INNER JOIN #application_security_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 asr ON asr.old_recid = weur.role_id
	UPDATE weur SET weur.event_message_id = wem.new_recid FROM #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wem INNER JOIN #workflow_event_user_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 weur ON weur.event_message_id = wem.old_recid
	
print('--==============================START workflow_event_user_role=============================')
UPDATE dbo.workflow_event_user_role SET [event_message_id]=src.[event_message_id],[user_login_id]=src.[user_login_id],[role_id]=src.[role_id]
		   OUTPUT 'u','workflow_event_user_role',inserted.event_user_role_id,inserted.event_user_role_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_user_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN workflow_event_user_role dst  ON src.event_user_role_id=dst.event_user_role_id;
insert into workflow_event_user_role
		([event_message_id],[user_login_id],[role_id]
		)
		 OUTPUT 'i','workflow_event_user_role',inserted.event_user_role_id,inserted.event_user_role_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[user_login_id],src.[role_id]
		FROM #workflow_event_user_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN workflow_event_user_role dst  ON src.event_user_role_id=dst.event_user_role_id
		WHERE dst.[event_user_role_id] IS NULL;
UPDATE #workflow_event_user_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid =dst.new_id 
		FROM #workflow_event_user_role_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN #old_new_id dst  ON src.event_user_role_id=dst.unique_key1 AND dst.table_name='workflow_event_user_role'
		;
print('--==============================END workflow_event_user_role=============================')
print('--==============================START workflow_event_message_documents=============================')

	if object_id('tempdb..#workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [message_document_id] int ,[event_message_id] int ,[document_template_id] int ,[effective_date] datetime ,[document_category] int ,[document_template] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [message_document_id],[event_message_id],[document_template_id],[effective_date],[document_category],[document_template],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where message_document_id is null;
	update #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set message_document_id='FARRMS1_ '+cast(message_document_id as varchar(30))  where isnull(message_document_id,'')='' ;
	
print('--==============================END workflow_event_message_documents=============================')

		DELETE FROM #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29 WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wemd ON wem.event_message_id = wemd.event_message_id)

	UPDATE wemd SET wemd.event_message_id = wem.new_recid FROM #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wem INNER JOIN #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wemd ON wemd.event_message_id = wem.old_recid
	UPDATE wemd SET wemd.document_template_id = sdv.new_recid FROM #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wemd INNER JOIN #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29 sdv ON sdv.old_recid = wemd.document_template_id
	UPDATE wemd SET wemd.document_category = sdv.new_recid FROM #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wemd INNER JOIN #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29 sdv ON sdv.old_recid = wemd.document_category
	
print('--==============================START workflow_event_message_documents=============================')
UPDATE dbo.workflow_event_message_documents SET [event_message_id]=src.[event_message_id],[document_template_id]=src.[document_template_id],[effective_date]=src.[effective_date],[document_category]=src.[document_category],[document_template]=src.[document_template]
		   OUTPUT 'u','workflow_event_message_documents',inserted.message_document_id,inserted.message_document_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN workflow_event_message_documents dst  ON src.message_document_id=dst.message_document_id;
insert into workflow_event_message_documents
		([event_message_id],[document_template_id],[effective_date],[document_category],[document_template]
		)
		 OUTPUT 'i','workflow_event_message_documents',inserted.message_document_id,inserted.message_document_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[document_template_id],src.[effective_date],src.[document_category],src.[document_template]
		FROM #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN workflow_event_message_documents dst  ON src.message_document_id=dst.message_document_id
		WHERE dst.[message_document_id] IS NULL;
UPDATE #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid =dst.new_id 
		FROM #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN #old_new_id dst  ON src.message_document_id=dst.unique_key1 AND dst.table_name='workflow_event_message_documents'
		;
print('--==============================END workflow_event_message_documents=============================')

	UPDATE w2 SET w2.new_recid = w1.message_document_id
	FROM workflow_event_message_documents w1 
	INNER JOIN #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29 w2 ON w1.event_message_id = w2.event_message_id
		AND ISNULL(w1.document_template_id, '-1') = ISNULL(w2.document_template_id, '-1')
		AND ISNULL(w1.document_category, '-1') = ISNULL(w2.document_category, '-1')
print('--==============================START workflow_event_message_details=============================')

	if object_id('tempdb..#workflow_event_message_details_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #workflow_event_message_details_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [message_detail_id] int ,[event_message_document_id] int ,[message_template_id] int ,[message] varchar(500) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[delivery_method] int ,[internal_contact_type] int ,[email] varchar(300) COLLATE DATABASE_DEFAULT ,[email_cc] varchar(300) COLLATE DATABASE_DEFAULT ,[email_bcc] varchar(300) COLLATE DATABASE_DEFAULT ,[as_defined_in_contact] char(1) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_details_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #workflow_event_message_details_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [message_detail_id],[event_message_document_id],[message_template_id],[message],[counterparty_contact_type],[delivery_method],[internal_contact_type],[email],[email_cc],[email_bcc],[as_defined_in_contact],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_details_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where message_detail_id is null;
	update #workflow_event_message_details_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set message_detail_id='FARRMS1_ '+cast(message_detail_id as varchar(30))  where isnull(message_detail_id,'')='' ;
	
print('--==============================END workflow_event_message_details=============================')

	DELETE FROM #workflow_event_message_details_3C32F5D7_8948_48AF_9864_BDA418FDFA29 WHERE message_detail_id NOT IN (
		SELECT wemd.message_detail_id from #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wemdd 
		INNER JOIN #workflow_event_message_details_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wemd ON wemd.event_message_document_id = wemdd.message_document_id)

	UPDATE wemd SET wemd.event_message_document_id = wem.new_recid FROM #workflow_event_message_documents_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wem INNER JOIN #workflow_event_message_details_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wemd ON wemd.event_message_document_id = wem.old_recid
	UPDATE wemd SET wemd.counterparty_contact_type = sdv.new_recid FROM #workflow_event_message_details_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wemd INNER JOIN #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29  sdv ON sdv.old_recid = wemd.counterparty_contact_type
	UPDATE wemd SET wemd.delivery_method = sdv.new_recid FROM #workflow_event_message_details_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wemd INNER JOIN #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29  sdv ON sdv.old_recid = wemd.delivery_method
	UPDATE wemd SET wemd.internal_contact_type = sdv.new_recid FROM #workflow_event_message_details_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wemd INNER JOIN #static_data_value_3C32F5D7_8948_48AF_9864_BDA418FDFA29  sdv ON sdv.old_recid = wemd.internal_contact_type
	
print('--==============================START workflow_event_message_details=============================')
UPDATE dbo.workflow_event_message_details SET [event_message_document_id]=src.[event_message_document_id],[message_template_id]=src.[message_template_id],[message]=src.[message],[counterparty_contact_type]=src.[counterparty_contact_type],[delivery_method]=src.[delivery_method],[internal_contact_type]=src.[internal_contact_type],[email]=src.[email],[email_cc]=src.[email_cc],[email_bcc]=src.[email_bcc],[as_defined_in_contact]=src.[as_defined_in_contact]
		   OUTPUT 'u','workflow_event_message_details',inserted.message_detail_id,inserted.message_detail_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_details_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN workflow_event_message_details dst  ON src.message_detail_id=dst.message_detail_id;
insert into workflow_event_message_details
		([event_message_document_id],[message_template_id],[message],[counterparty_contact_type],[delivery_method],[internal_contact_type],[email],[email_cc],[email_bcc],[as_defined_in_contact]
		)
		 OUTPUT 'i','workflow_event_message_details',inserted.message_detail_id,inserted.message_detail_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_document_id],src.[message_template_id],src.[message],src.[counterparty_contact_type],src.[delivery_method],src.[internal_contact_type],src.[email],src.[email_cc],src.[email_bcc],src.[as_defined_in_contact]
		FROM #workflow_event_message_details_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN workflow_event_message_details dst  ON src.message_detail_id=dst.message_detail_id
		WHERE dst.[message_detail_id] IS NULL;
UPDATE #workflow_event_message_details_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid =dst.new_id 
		FROM #workflow_event_message_details_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN #old_new_id dst  ON src.message_detail_id=dst.unique_key1 AND dst.table_name='workflow_event_message_details'
		;
print('--==============================END workflow_event_message_details=============================')
print('--==============================START alert_reports=============================')

	if object_id('tempdb..#alert_reports_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #alert_reports_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [alert_reports_id] int ,[event_message_id] int ,[report_writer] varchar(1) COLLATE DATABASE_DEFAULT ,[paramset_hash] varchar(8000) COLLATE DATABASE_DEFAULT ,[report_param] varchar(1000) COLLATE DATABASE_DEFAULT ,[report_desc] varchar(500) COLLATE DATABASE_DEFAULT ,[table_prefix] varchar(50) COLLATE DATABASE_DEFAULT ,[table_postfix] varchar(50) COLLATE DATABASE_DEFAULT ,[report_where_clause] varchar(max) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_reports_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #alert_reports_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [alert_reports_id],[event_message_id],[report_writer],[paramset_hash],[report_param],[report_desc],[table_prefix],[table_postfix],[report_where_clause],old_recid
	 )
	 VALUES
	 
(51,1260,'n','',NULL,'Credit Limit Update Report','alert_credit_limits_output_','_aclo','',51),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_reports_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where alert_reports_id is null;
	update #alert_reports_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set event_message_id='FARRMS1_ '+cast(alert_reports_id as varchar(30))  where isnull(event_message_id,'')='' ;
	update #alert_reports_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set report_desc='FARRMS2_ '+cast(alert_reports_id as varchar(30))  where isnull(report_desc,'')='' ;
			update #alert_reports_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set table_prefix='FARRMS3_ '+cast(alert_reports_id as varchar(30))  where isnull(table_prefix,'')='' ;
			
print('--==============================END alert_reports=============================')

		DELETE FROM #alert_reports_3C32F5D7_8948_48AF_9864_BDA418FDFA29 WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_reports_3C32F5D7_8948_48AF_9864_BDA418FDFA29 ar ON wem.event_message_id = ar.event_message_id)

	UPDATE ar SET ar.event_message_id = wem.new_recid FROM #workflow_event_message_3C32F5D7_8948_48AF_9864_BDA418FDFA29 wem INNER JOIN #alert_reports_3C32F5D7_8948_48AF_9864_BDA418FDFA29 ar ON ar.event_message_id = wem.old_recid
	
print('--==============================START alert_reports=============================')
UPDATE dbo.alert_reports SET [report_writer]=src.[report_writer],[paramset_hash]=src.[paramset_hash],[report_param]=src.[report_param],[table_postfix]=src.[table_postfix],[report_where_clause]=src.[report_where_clause]
		   OUTPUT 'u','alert_reports',inserted.alert_reports_id,inserted.event_message_id,inserted.report_desc,inserted.table_prefix INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_reports_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN alert_reports dst  ON src.event_message_id=dst.event_message_id AND src.report_desc=dst.report_desc AND src.table_prefix=dst.table_prefix;
insert into alert_reports
		([event_message_id],[report_writer],[paramset_hash],[report_param],[report_desc],[table_prefix],[table_postfix],[report_where_clause]
		)
		 OUTPUT 'i','alert_reports',inserted.alert_reports_id,inserted.event_message_id,inserted.report_desc,inserted.table_prefix INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[report_writer],src.[paramset_hash],src.[report_param],src.[report_desc],src.[table_prefix],src.[table_postfix],src.[report_where_clause]
		FROM #alert_reports_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN alert_reports dst  ON src.event_message_id=dst.event_message_id AND src.report_desc=dst.report_desc AND src.table_prefix=dst.table_prefix
		WHERE dst.[alert_reports_id] IS NULL;
UPDATE #alert_reports_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid =dst.new_id 
		FROM #alert_reports_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN #old_new_id dst  ON src.event_message_id=dst.unique_key1 AND src.report_desc=dst.unique_key2 AND src.table_prefix=dst.unique_key3 AND dst.table_name='alert_reports'
		;
print('--==============================END alert_reports=============================')
print('--==============================START alert_report_params=============================')

	if object_id('tempdb..#alert_report_params_3C32F5D7_8948_48AF_9864_BDA418FDFA29') is null 
	
	CREATE TABLE #alert_report_params_3C32F5D7_8948_48AF_9864_BDA418FDFA29
	 (
	 [alert_report_params_id] int ,[event_message_id] int ,[alert_report_id] int ,[main_table_id] int ,[parameter_name] nvarchar(200) COLLATE DATABASE_DEFAULT ,[parameter_value] nvarchar(2000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #alert_report_params_3C32F5D7_8948_48AF_9864_BDA418FDFA29;
INSERT INTO #alert_report_params_3C32F5D7_8948_48AF_9864_BDA418FDFA29(
	 [alert_report_params_id],[event_message_id],[alert_report_id],[main_table_id],[parameter_name],[parameter_value],old_recid
	 )
	 VALUES
	 
(NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #alert_report_params_3C32F5D7_8948_48AF_9864_BDA418FDFA29 where alert_report_params_id is null;
	update #alert_report_params_3C32F5D7_8948_48AF_9864_BDA418FDFA29 set alert_report_id='FARRMS1_ '+cast(alert_report_params_id as varchar(30))  where isnull(alert_report_id,'')='' ;
	
print('--==============================END alert_report_params=============================')

		DELETE FROM #alert_report_params_3C32F5D7_8948_48AF_9864_BDA418FDFA29 WHERE event_message_id NOT IN (
		SELECT wem.event_message_id FROM #workflow_event_message_bkup wem 
		INNER JOIN #alert_report_params_3C32F5D7_8948_48AF_9864_BDA418FDFA29 ar ON wem.event_message_id = ar.event_message_id)

	UPDATE arp SET arp.alert_report_id = ar.alert_reports_id FROM #alert_report_params_3C32F5D7_8948_48AF_9864_BDA418FDFA29 arp INNER JOIN #alert_reports_3C32F5D7_8948_48AF_9864_BDA418FDFA29 ar ON ar.old_recid = arp.alert_report_id
	UPDATE arp SET arp.main_table_id = art.alert_rule_table_id FROM #alert_report_params_3C32F5D7_8948_48AF_9864_BDA418FDFA29 arp INNER JOIN #alert_rule_table_3C32F5D7_8948_48AF_9864_BDA418FDFA29 art ON art.old_recid = arp.main_table_id
	
print('--==============================START alert_report_params=============================')
UPDATE dbo.alert_report_params SET [event_message_id]=src.[event_message_id],[main_table_id]=src.[main_table_id],[parameter_name]=src.[parameter_name],[parameter_value]=src.[parameter_value]
		   OUTPUT 'u','alert_report_params',inserted.alert_report_params_id,inserted.alert_report_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #alert_report_params_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN alert_report_params dst  ON src.alert_report_id=dst.alert_report_id;
insert into alert_report_params
		([event_message_id],[alert_report_id],[main_table_id],[parameter_name],[parameter_value]
		)
		 OUTPUT 'i','alert_report_params',inserted.alert_report_params_id,inserted.alert_report_id,NULL,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_message_id],src.[alert_report_id],src.[main_table_id],src.[parameter_name],src.[parameter_value]
		FROM #alert_report_params_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src LEFT JOIN alert_report_params dst  ON src.alert_report_id=dst.alert_report_id
		WHERE dst.[alert_report_params_id] IS NULL;
UPDATE #alert_report_params_3C32F5D7_8948_48AF_9864_BDA418FDFA29 SET new_recid =dst.new_id 
		FROM #alert_report_params_3C32F5D7_8948_48AF_9864_BDA418FDFA29 src INNER JOIN #old_new_id dst  ON src.alert_report_id=dst.unique_key1 AND dst.table_name='alert_report_params'
		;
print('--==============================END alert_report_params=============================')

UPDATE a SET a.new_recid = me.module_events_id from #module_events_7C8FADC9_8875_4FAC_852B_09331A760A25 a 
INNER JOIN module_events me ON me.modules_id = a.modules_id AND me.event_id = a.event_id AND me.workflow_name = a.workflow_name
	
UPDATE a SET a.new_recid = me.module_events_id from #module_events_bkup a 
INNER JOIN module_events me ON me.modules_id = a.modules_id AND me.event_id = a.event_id AND me.workflow_name = a.workflow_name

print('--==============================START event_trigger=============================')

	if object_id('tempdb..#event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25') is null 
	
	CREATE TABLE #event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25
	 (
	 [event_trigger_id] int ,[modules_event_id] int ,[alert_id] int ,[initial_event] char(1) COLLATE DATABASE_DEFAULT ,[manual_step] char(1) COLLATE DATABASE_DEFAULT ,[is_disable] char(1) COLLATE DATABASE_DEFAULT ,[report_paramset_id] varchar(max) COLLATE DATABASE_DEFAULT ,[report_filters] int ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25;
INSERT INTO #event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25(
	 [event_trigger_id],[modules_event_id],[alert_id],[initial_event],[manual_step],[is_disable],[report_paramset_id],[report_filters],old_recid
	 )
	 VALUES
	 
(1358,1174,7,'n',NULL,NULL,NULL,NULL,1358),
(1356,1175,1,'n','n','n','',0,1356),
(1357,1176,6,'n',NULL,NULL,NULL,NULL,1357),
(1359,1177,69,'n',NULL,NULL,NULL,NULL,1359),
(1360,1178,71,'n',NULL,NULL,NULL,NULL,1360),
(1361,1179,1120,'n',NULL,NULL,NULL,NULL,1361),
(1362,1180,1139,'n','n','n','',0,1362),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25 where event_trigger_id is null;
	update #event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25 set modules_event_id='FARRMS1_ '+cast(event_trigger_id as varchar(30))  where isnull(modules_event_id,'')='' ;
	update #event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25 set alert_id='FARRMS2_ '+cast(event_trigger_id as varchar(30))  where isnull(alert_id,'')='' ;
			
print('--==============================END event_trigger=============================')
 
DELETE FROM #event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25 WHERE modules_event_id NOT IN 
	(SELECT meb.module_events_id FROM #module_events_bkup meb INNER JOIN #event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25 et 
ON et.modules_event_id = meb.module_events_id)

UPDATE et SET et.[alert_id] = asl.new_recid
FROM #event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25 et INNER JOIN #alert_sql_bkup asl ON asl.old_recid = et.alert_id WHERE et.alert_id <> -1

UPDATE et SET et.modules_event_id = me.new_recid
FROM #event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25 et INNER JOIN #module_events_7C8FADC9_8875_4FAC_852B_09331A760A25 me ON me.module_events_id = et.modules_event_id

UPDATE event_trigger SET 
 [initial_event] = src.[initial_event]
, [manual_step] = src.[manual_step]
, [is_disable] = src.[is_disable]
, [report_paramset_id] = src.[report_paramset_id]
, [report_filters] = src.[report_filters]
 OUTPUT 'u','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,src.report_paramset_id 
 INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
FROM #event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25 src 
INNER JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id

insert into event_trigger
		([modules_event_id],[alert_id],[initial_event], [manual_step], [is_disable], [report_paramset_id], [report_filters]
		)
			OUTPUT 'i','event_trigger',inserted.event_trigger_id,inserted.modules_event_id,inserted.alert_id,inserted.report_paramset_id  INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[modules_event_id],src.[alert_id],src.[initial_event], src.[manual_step], src.[is_disable], src.[report_paramset_id], src.[report_filters]
		FROM #event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25 src LEFT JOIN event_trigger dst  ON src.modules_event_id=dst.modules_event_id AND src.alert_id=dst.alert_id
		WHERE dst.[event_trigger_id] IS NULL;
UPDATE #event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25 SET new_recid =dst.new_id 
		FROM #event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25 src INNER JOIN #old_new_id dst  ON src.modules_event_id=dst.unique_key1 AND src.alert_id=dst.unique_key2 AND dst.table_name='event_trigger'
			AND ISNULL(src.report_paramset_id,-999) = ISNULL(dst.unique_key3,-999)

INSERT INTO #event_trigger_bkup	(event_trigger_id, modules_event_id, alert_id, initial_event, manual_step, is_disable, report_paramset_id, report_filters, new_recid, old_recid)
SELECT et.event_trigger_id, et.modules_event_id, et.alert_id, et.initial_event, et.manual_step, et.is_disable, et.report_paramset_id, et.report_filters, et.new_recid, et.old_recid FROM #event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25 et
LEFT JOIN #event_trigger_bkup etb ON etb.old_recid = et.old_recid 
WHERE etb.old_recid IS NULL
print('--==============================START workflow_event_message=============================')

	if object_id('tempdb..#workflow_event_message_7C8FADC9_8875_4FAC_852B_09331A760A25') is null 
	
	CREATE TABLE #workflow_event_message_7C8FADC9_8875_4FAC_852B_09331A760A25
	 (
	 [event_message_id] int ,[event_trigger_id] int ,[event_message_name] varchar(100) COLLATE DATABASE_DEFAULT ,[message_template_id] int ,[message] varchar(1000) COLLATE DATABASE_DEFAULT ,[mult_approval_required] char(1) COLLATE DATABASE_DEFAULT ,[comment_required] char(1) COLLATE DATABASE_DEFAULT ,[approval_action_required] char(1) COLLATE DATABASE_DEFAULT ,[self_notify] char(1) COLLATE DATABASE_DEFAULT ,[notify_trader] char(1) COLLATE DATABASE_DEFAULT ,[next_module_events_id] int ,[minimum_approval_required] int ,[optional_event_msg] char(1) COLLATE DATABASE_DEFAULT ,[counterparty_contact_type] int ,[automatic_proceed] char(1) COLLATE DATABASE_DEFAULT ,[notification_type] varchar(1000) COLLATE DATABASE_DEFAULT ,new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #workflow_event_message_7C8FADC9_8875_4FAC_852B_09331A760A25;
INSERT INTO #workflow_event_message_7C8FADC9_8875_4FAC_852B_09331A760A25(
	 [event_message_id],[event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type],old_recid
	 )
	 VALUES
	 
(1256,1358,'Collateral Expiring',0,'Collateral is expiring for few counterparty. <#ALERT_REPORT>','n','n','n','y','n',NULL,NULL,'n',NULL,'n','',1256),
(1254,1356,'Credit Limit Violated',0,'Credit Limit Violated for :  <#ALERT_REPORT>','n','n','n','y','n',NULL,NULL,'n',NULL,'n','757',1254),
(1255,1357,'Credit File Review',0,'Please Review Credit File of attached Counterparty. <#ALERT_REPORT>','n','n','n','y','n',NULL,NULL,'n',NULL,'n','757',1255),
(1257,1359,'Contract Expiration Alert',0,'Some Contracts are expiring soon. Please review Contracts. <#ALERT_REPORT>','n','n','n','y','n',NULL,NULL,'n',NULL,'n','0',1257),
(1258,1360,'Incomplete Deal Alert',0,'There are some incomplete deals.<#ALERT_REPORT><ALERT_REPORT#>','n','n','n','y','n',NULL,NULL,'n',NULL,'n',NULL,1258),
(1259,1361,'Counterparty Credit Info Change',0,'<#COUNTERPARTY><COUNTERPARTY><COUNTERPARTY#> Counterparty credit file has been updated.  <#ALERT_REPORT>','n','n','n','y','n',NULL,NULL,'n',NULL,'n','757',1259),
(1260,1362,'Credit Limi Update Alert',NULL,'<#COUNTERPARTY><COUNTERPARTY><COUNTERPARTY#> Counterparty credit limit has been updated.  <#ALERT_REPORT>','n','n','n','y','n',NULL,NULL,'n',NULL,'n','757',1260),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);
	delete #workflow_event_message_7C8FADC9_8875_4FAC_852B_09331A760A25 where event_message_id is null;
	update #workflow_event_message_7C8FADC9_8875_4FAC_852B_09331A760A25 set event_trigger_id='FARRMS1_ '+cast(event_message_id as varchar(30))  where isnull(event_trigger_id,'')='' ;
	update #workflow_event_message_7C8FADC9_8875_4FAC_852B_09331A760A25 set event_message_name='FARRMS2_ '+cast(event_message_id as varchar(30))  where isnull(event_message_name,'')='' ;
			
print('--==============================END workflow_event_message=============================')
	
UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_7C8FADC9_8875_4FAC_852B_09331A760A25 wem INNER JOIN #event_trigger_7C8FADC9_8875_4FAC_852B_09331A760A25 et ON et.old_recid = wem.event_trigger_id
UPDATE wem SET wem.event_trigger_id = et.new_recid FROM #workflow_event_message_7C8FADC9_8875_4FAC_852B_09331A760A25 wem INNER JOIN #event_trigger_bkup et ON et.old_recid = wem.event_trigger_id
UPDATE wem SET wem.next_module_events_id = meb.new_recid FROM #workflow_event_message_7C8FADC9_8875_4FAC_852B_09331A760A25 wem  INNER JOIN #module_events_bkup meb ON meb.old_recid = wem.next_module_events_id

print('--==============================START workflow_event_message=============================')
UPDATE dbo.workflow_event_message SET [message_template_id]=src.[message_template_id],[message]=src.[message],[mult_approval_required]=src.[mult_approval_required],[comment_required]=src.[comment_required],[approval_action_required]=src.[approval_action_required],[self_notify]=src.[self_notify],[notify_trader]=src.[notify_trader],[next_module_events_id]=src.[next_module_events_id],[minimum_approval_required]=src.[minimum_approval_required],[optional_event_msg]=src.[optional_event_msg],[counterparty_contact_type]=src.[counterparty_contact_type],[automatic_proceed]=src.[automatic_proceed],[notification_type]=src.[notification_type]
		   OUTPUT 'u','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	FROM #workflow_event_message_7C8FADC9_8875_4FAC_852B_09331A760A25 src INNER JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name;
insert into workflow_event_message
		([event_trigger_id],[event_message_name],[message_template_id],[message],[mult_approval_required],[comment_required],[approval_action_required],[self_notify],[notify_trader],[next_module_events_id],[minimum_approval_required],[optional_event_msg],[counterparty_contact_type],[automatic_proceed],[notification_type]
		)
		 OUTPUT 'i','workflow_event_message',inserted.event_message_id,inserted.event_trigger_id,inserted.event_message_name,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	
		SELECT 
		src.[event_trigger_id],src.[event_message_name],src.[message_template_id],src.[message],src.[mult_approval_required],src.[comment_required],src.[approval_action_required],src.[self_notify],src.[notify_trader],src.[next_module_events_id],src.[minimum_approval_required],src.[optional_event_msg],src.[counterparty_contact_type],src.[automatic_proceed],src.[notification_type]
		FROM #workflow_event_message_7C8FADC9_8875_4FAC_852B_09331A760A25 src LEFT JOIN workflow_event_message dst  ON src.event_trigger_id=dst.event_trigger_id AND src.event_message_name=dst.event_message_name
		WHERE dst.[event_message_id] IS NULL;
UPDATE #workflow_event_message_7C8FADC9_8875_4FAC_852B_09331A760A25 SET new_recid =dst.new_id 
		FROM #workflow_event_message_7C8FADC9_8875_4FAC_852B_09331A760A25 src INNER JOIN #old_new_id dst  ON src.event_trigger_id=dst.unique_key1 AND src.event_message_name=dst.unique_key2 AND dst.table_name='workflow_event_message'
		;
print('--==============================END workflow_event_message=============================')
	
INSERT INTO #workflow_event_message_bkup (event_message_id, event_trigger_id, event_message_name, message_template_id, message, mult_approval_required, comment_required, approval_action_required, self_notify, notify_trader, counterparty_contact_type, next_module_events_id, minimum_approval_required, optional_event_msg, automatic_proceed, notification_type, new_recid, old_recid)
SELECT wem.event_message_id, wem.event_trigger_id, wem.event_message_name, wem.message_template_id, wem.message, wem.mult_approval_required, wem.comment_required, wem.approval_action_required, wem.self_notify, wem.notify_trader, wem.counterparty_contact_type, wem.next_module_events_id, wem.minimum_approval_required, wem.optional_event_msg, wem.automatic_proceed, wem.notification_type, wem.new_recid, wem.old_recid FROM #workflow_event_message_7C8FADC9_8875_4FAC_852B_09331A760A25 wem
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
UPDATE wea SET wea.status_id = sdv.new_recid FROM #workflow_event_action wea INNER JOIN #static_data_value_7C8FADC9_8875_4FAC_852B_09331A760A25 sdv ON sdv.old_recid = wea.status_id	

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
	 
(5825,NULL,'Jan  9 2015 12:00AM',2,NULL,1,5824,1256,3,NULL,5825),
(5828,NULL,'Jan 11 2015 12:00AM',3,NULL,1,5827,1254,3,NULL,5828),
(5831,NULL,'Jan  7 2015 12:00AM',3,NULL,1,5830,1255,3,NULL,5831),
(5834,NULL,'Jan  8 2015 12:00AM',4,NULL,1,5833,1257,3,NULL,5834),
(5837,NULL,'Jan  8 2015 12:00AM',4,NULL,1,5836,1258,3,NULL,5837),
(5840,NULL,'Jan  7 2015 12:00AM',5,NULL,1,5839,1259,3,NULL,5840),
(5843,NULL,'Jan 10 2015 12:00AM',2,NULL,1,5842,1260,3,NULL,5843),
(5824,NULL,'Jan  2 2015 12:00AM',4,NULL,1,5823,1358,2,NULL,5824),
(5827,NULL,'Jan  3 2015 12:00AM',6,NULL,1,5826,1356,2,NULL,5827),
(5830,NULL,'Jan  2 2015 12:00AM',3,NULL,1,5829,1357,2,NULL,5830),
(5833,NULL,'Jan  2 2015 12:00AM',2,NULL,1,5832,1359,2,NULL,5833),
(5836,NULL,'Jan  2 2015 12:00AM',7,NULL,1,5835,1360,2,NULL,5836),
(5839,NULL,'Jan  2 2015 12:00AM',4,NULL,1,5838,1361,2,NULL,5839),
(5842,NULL,'Jan  2 2015 12:00AM',7,NULL,1,5841,1362,2,NULL,5842),
(5823,NULL,'Jan  2 2015 12:00AM',2,NULL,1,5822,1174,1,NULL,5823),
(5826,NULL,'Jan  3 2015 12:00AM',11,NULL,2,5822,1175,1,NULL,5826),
(5829,NULL,'Jan  2 2015 12:00AM',5,NULL,3,5822,1176,1,NULL,5829),
(5832,NULL,'Jan  2 2015 12:00AM',2,NULL,4,5822,1177,1,NULL,5832),
(5835,NULL,'Jan  2 2015 12:00AM',5,NULL,5,5822,1178,1,NULL,5835),
(5838,NULL,'Jan  2 2015 12:00AM',2,NULL,6,5822,1179,1,NULL,5838),
(5841,NULL,'Jan  2 2015 12:00AM',2,NULL,7,5822,1180,1,NULL,5841),
(5822,'Alerts','Jan  2 2015 12:00AM',2,NULL,NULL,NULL,NULL,0,0,5822),
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

UPDATE wwc SET wwc.table_id = atd.new_recid FROM #workflow_where_clause wwc INNER JOIN #alert_table_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 atd ON atd.old_recid = wwc.table_id
UPDATE wwc SET wwc.column_id = acd.new_recid FROM #workflow_where_clause wwc INNER JOIN #alert_columns_definition_7C8FADC9_8875_4FAC_852B_09331A760A25 acd ON acd.alert_columns_definition_id = wwc.column_id
UPDATE wwc SET wwc.module_events_id = me.new_recid FROM #workflow_where_clause wwc INNER JOIN #module_events_7C8FADC9_8875_4FAC_852B_09331A760A25 me ON me.old_recid = wwc.module_events_id
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
	 
(3554,5824,5825,0,NULL,3554),
(3555,5827,5828,0,NULL,3555),
(3556,5830,5831,0,NULL,3556),
(3557,5833,5834,0,NULL,3557),
(3558,5836,5837,0,NULL,3558),
(3559,5839,5840,0,NULL,3559),
(3560,5842,5843,0,NULL,3560),
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
