IF OBJECT_ID(N'[dbo].[spa_setup_rule_workflow]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_setup_rule_workflow
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
 /**
	Operation for Workflow Setup

	Parameters :
	@flag : Flag
			'w' -- Get workflows
			'a' -- Get Workfow Messages
			'e' -- Get Alert Rules
			't' -- Get Email template setup for workflow messaging
			'm' -- Insert/Update operation for workflow message
			'r' -- Get Alert Rules for dropdown
			'u' -- Insert/Update operation for workflow events
			'd' -- Delete workflow events
			'b' -- Get Approvals in Manage Approval
			'c' -- Action for Approve/Unapprove/Complete
			'f' -- Get workflow activities
			'x' -- Check comments required
			'y' -- Delete workflow activities
			'n' -- Get the next event
			'p' -- Get control status for dropdown
			'q' -- Insert/Update Event action
			'v' -- Get actions for dropdown
			'z' -- Insert/Update Alert Rules
			'g' -- Get workflow message documents
			'h' -- Insert/Update workflow message documents
			'j' -- Insert/Update workflow message documents contacts
			'k' -- Delete workflow message documents
			'o' -- Get workflow where clause
			'i' -- Get workflow link
			'l' -- Get workflow link where clause
			'1' -- Delete Workflow
			's' -- Get Workflow for dropdown in calendar
			'2' -- For module dropdown in workflow/alert
			'3' -- For event dropdown in workflow/alert
			'4' -- FOR Rule Table dropdown in workflow/alert
			'5' -- For module dropdown in workflow/alert
			'6' -- Get Alert Tables
			'7' -- Get Workflow Links
			'8' -- Get Document Types
			'9' -- Get Report Type
			'11' -- for updateing comment on workflow_activity table
			'12' -- display or dont display the popup of comment on UI
			'email_group' -- Get Workfow Email groups
			'tag' -- Get Workflow Tags
	@workflow_id : Module Event Id (module_events_id FROM module_events)
	@xml : Xml Data
	@message_id : Event Message Id (event_message_id from workflow_event_message)
	@process_table : Process table that contains the data to be processed from workflow
	@user_login_id : User Login Id
	@activity_id : Workflow_activity_id from workflow_activities table
	@approved : 1-Approced, 0-Unapproved, 2-Completed,3-Threshold Exception
	@module_id : static_data_values - type_id = 20600
	@status_id : static_data_values - type_id = 725
	@source_id : Value of the primary column of the workflow module
	@comments : Comments Text
	@date_from : Date From Filter
	@date_to : Date To Fiter
	@user_role_xml : Xml data for user role
	@action_id : Id from workflow_event_action. Next event to be triggered
	@message_detail_id : Id of message detail (message_detail_id FROM workflow_event_message_details)
	@document_template_id :Id of the message document setup
	@effective_date : Effective Date for workflow document
	@document_category : Document Category (static_data_value - type_id = 25)
	@alert_rule_id : Id of the Alert Rule (alert_sql_id FROM alert_sql)
	@approved_by : Approved By User
	@call_from : 'simple alert' or 'workflow'
	@group_type : Email group type for workflow document contact email
 */

CREATE PROCEDURE [dbo].spa_setup_rule_workflow
	@flag NCHAR(20),
	@workflow_id INT = NULL,
	@xml NTEXT = NULL,
	@message_id INT = NULL,
	@process_table NVARCHAR(100)= NULL,
	@user_login_id NVARCHAR(100)= NULL,
	@activity_id NVARCHAR(1000) = NULL,
	@approved INT = NULL,
	@module_id INT = NULL,
	@status_id INT = NULL,
	@source_id NVARCHAR(500) = NULL,
	@comments NVARCHAR(MAX) = NULL,
	@date_from DATE = NULL,
	@date_to DATE = NULL,
	@user_role_xml NTEXT = NULL,
	@action_id INT = NULL,
	@message_detail_id INT = NULL,
	@document_template_id NVARCHAR(50) = NULL,
	@effective_date DATE = NULL,
	@document_category INT = NULL,
	@alert_rule_id NVARCHAR(1000) = NULL,
	@approved_by NVARCHAR(100) = null,
	@call_from NVARCHAR(50) = null,
	@group_type NCHAR(1) = NULL
AS
SET NOCOUNT ON
/** DEBUG **
declare @flag NCHAR(1),
	@workflow_id INT = NULL,
	@xml NVARCHAR(MAX) = NULL,
	@message_id INT = NULL,
	@process_table NVARCHAR(100)= NULL,
	@user_login_id NVARCHAR(100)= NULL,
	@activity_id NVARCHAR(1000) = NULL,
	@approved INT = NULL,
	@module_id INT = NULL,
	@status_id INT = NULL,
	@source_id NVARCHAR(500) = NULL,
	@comments NVARCHAR(MAX) = NULL,
	@date_from DATE = NULL,
	@date_to DATE = NULL,
	@user_role_xml NVARCHAR(MAX) = NULL,
	@action_id INT = NULL,
	@message_detail_id INT = NULL,
	@document_template_id NVARCHAR(50) = NULL,
	@effective_date DATE = NULL,
	@document_category INT = NULL,
	@alert_rule_id INT = NULL,
	@approved_by NVARCHAR(100) = null,
	@call_from NVARCHAR(50) = null,
	@group_type NCHAR(1) = NULL

select @flag='z',@xml = '<Root function_id="10122500" object_id="1954"><FormXML  alert_sql_id="1954" alert_sql_name="Test" notification_type="757" rule_category="20610" alert_type="r" workflow_only="n" is_active="y" system_rule="n" message=""></FormXML><GridGroup><GridDelete grid_id="alert_rule_table" grid_label="Rule Tables"><GridRow  alert_id="1954" alert_rule_table_id="952" table_id="9" table_alias="test" ></GridRow> <GridRow  alert_id="1954" alert_rule_table_id="953" table_id="8" table_alias="test2" ></GridRow> </GridDelete></GridGroup></Root>'
--*/

DECLARE @desc NVARCHAR(500)
DECLARE @err_no INT
DECLARE @idoc INT
DECLARE @sql NVARCHAR(MAX)
DECLARE @module_event_id NVARCHAR(MAX) = NULL
DECLARE @is_comment_required NCHAR(1)

SET @activity_id = NULLIF(@activity_id, '')
--set @status_id = isnull(nullif(@status_id,''), 725)

IF @flag = 'w' 
	BEGIN
		SELECT sdv.code [module_name], workflow_name [workflow_name], module_events_id [workflow_id], sdv1.code [event_name], au.user_f_name + ' ' + au.user_l_name [owner]
		FROM module_events AS me
		LEFT JOIN static_data_value AS sdv ON me.modules_id = sdv.value_id
		LEFT JOIN static_data_value AS sdv1 ON me.event_id = sdv1.value_id
		LEFT JOIN application_users AS au ON me.workflow_owner = au.user_login_id
	END
ELSE IF @flag = 'a' 
    BEGIN
		SELECT wem.event_message_name [message_name],
				wem.notification_type,
				wem.[message],
				wem.self_notify,
				wem.approval_action_required [approval_required],
				wem.mult_approval_required,
				wem.comment_required,
				STUFF((SELECT ',' + b.user_login_id
				   FROM workflow_event_user_role b 
				   WHERE b.event_message_id = wem.event_message_id AND b.user_login_id <> ''
				  FOR XML PATH('')), 1, 1, '') user_login_id,
				STUFF((SELECT ',' + CAST(c.role_id AS NVARCHAR(10))
				   FROM workflow_event_user_role c 
				   WHERE c.event_message_id = wem.event_message_id AND c.role_id <> 0
				  FOR XML PATH('')), 1, 1, '') role_id,
				wem.notify_trader,
				wem.next_module_events_id,
				wem.minimum_approval_required,
				wem.optional_event_msg,
				CASE WHEN wem.automatic_proceed = 'h' OR wem.automatic_proceed = 'y' THEN 'y' ELSE 'n' END [automatic_proceed],
				dbo.FNADateTimeFormat(ce.[start_date],1) [start_date],
				ce.reminder/1440 [reminder_days],
				CASE WHEN ce.include_holiday = 'y' THEN 1 ELSE 0 END [include_holiday]
		FROM workflow_event_message AS wem
		LEFT JOIN calendar_events ce ON wem.event_message_id = ce.event_message_id
		WHERE wem.event_message_id = @message_id
		GROUP BY wem.event_message_id, wem.event_message_name, wem.notification_type, wem.message, 
					wem.self_notify, wem.approval_action_required, wem.mult_approval_required, wem.comment_required, wem.notify_trader,wem.next_module_events_id,wem.minimum_approval_required,wem.optional_event_msg,wem.automatic_proceed,
					ce.[start_date], ce.reminder, ce.include_holiday
    END
ELSE IF @flag = 'e'
	BEGIN
		--SELECT as1.alert_sql_name [rule_name], 'Message' [type], wem.event_message_name [name], et.alert_id, et.event_trigger_id [rule_id], NULL [event_action_id], wem.event_message_id
		--FROM event_trigger AS et
		--LEFT JOIN alert_sql AS as1 ON et.alert_id = as1.alert_sql_id
		--LEFT JOIN workflow_event_message AS wem ON wem.event_trigger_id = et.event_trigger_id
		--WHERE et.modules_event_id = @workflow_id
		--UNION ALL
		SELECT as1.alert_sql_name [rule_name], ISNULL(wem.event_message_name, 'Message') [name], sdv.code [action_name], ass.alert_sql_name, et.alert_id, et.event_trigger_id [rule_id], wea.event_action_id, wem.event_message_id [event_message_id]
		FROM event_trigger AS et
		LEFT JOIN alert_sql AS as1 ON et.alert_id = as1.alert_sql_id
		LEFT JOIN workflow_event_message AS wem ON wem.event_trigger_id = et.event_trigger_id
		LEFT JOIN workflow_event_action AS wea ON wea.event_message_id = wem.event_message_id
		LEFT JOIN event_trigger ett on ett.event_trigger_id = wea.alert_id
		LEFT JOIN alert_sql ass on ass.alert_sql_id = ett.alert_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = wea.status_id
		WHERE et.modules_event_id = @workflow_id
	END
ELSE IF @flag = 't' 
    BEGIN
		SELECT aec.admin_email_configuration_id, aec.template_name FROM admin_email_configuration aec
		RIGHT JOIN static_data_value sdv ON sdv.value_id = aec.module_type
		WHERE sdv.type_id= 17800 AND sdv.code = 'Workflow'
		AND (aec.template_name IS NOT NULL	OR aec.admin_email_configuration_id IS NOT NULL)
    END
ELSE IF @flag = 'm' 
	BEGIN
		BEGIN TRY
			--SET @xml='<Root><FormXML event_message_id="" event_message_name="Message Number 2" event_trigger_id="11" message_template_id="-1" message="Message"></FormXML></Root>'
			--SET @user_role_xml='<Root><FormXML user_login_id="achewt" role_id="107"></FormXML><FormXML user_login_id="athapa" role_id="108"></FormXML></Root>'
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

			IF OBJECT_ID('tempdb..#workflow_event_message') IS NOT NULL
				DROP TABLE #workflow_event_message
		
			SELECT event_message_id		[event_message_id],
					event_message_name	[event_message_name],
					event_trigger_id	[event_trigger_id],
					notification_type   [notification_type],
					message				[message],
					self_notify			[self_notify],
					approval_req		[approval_req],
					comment_req			[comment_req],
					mult_app_req		[mult_app_req],
					notify_trader		[notify_trader],
					next_module_events_id	[next_module_events_id],
					minimum_approval_required [minimum_approval_required],
					optional_event_msg	[optional_event_msg],
					automatic_proceed	[automatic_proceed]
			INTO #workflow_event_message
			FROM OPENXML(@idoc, '/Root/FormXML', 1)
			WITH (
				event_message_id		NVARCHAR(20),
				event_message_name		NVARCHAR(100),
				event_trigger_id		NVARCHAR(20),
				notification_type		NVARCHAR(100),
				message					NVARCHAR(1000),
				self_notify				NCHAR(1),
				approval_req			NCHAR(1),
				comment_req				NCHAR(1),
				mult_app_req			NCHAR(1),
				notify_trader			NCHAR(1),
				next_module_events_id	INT,
				minimum_approval_required INT,
				optional_event_msg		NCHAR(1),
				automatic_proceed		NCHAR(1)
			)

			IF OBJECT_ID('tempdb..#tmp_msg_task') IS NOT NULL
				DROP TABLE #tmp_msg_task
		
			SELECT	[start_date]	[start_date],
					duration		[duration],
					workflow_id_type[workflow_id_type],
					parent_id		[parent_id]
			INTO #tmp_msg_task
			FROM OPENXML(@idoc, '/Root/TaskXML', 1)
			WITH (
				[start_date]		DATETIME,
				duration			INT,
				workflow_id_type	INT,
				parent_id			INT
			)

			IF OBJECT_ID('tempdb..#tmp_msg_reminder') IS NOT NULL
				DROP TABLE #tmp_msg_reminder
		
			SELECT	ISNULL(NULLIF([start_date],'1900-01-01 00:00:00.000'),GETDATE()) [start_date],
					reminder_days	[reminder_days],
					module_id		[module_id],
					source_id			[source_id],
					include_holiday		[include_holiday],
					NULLIF(event_message_id,0)	[event_message_id]
			INTO #tmp_msg_reminder
			FROM OPENXML(@idoc, '/Root/TaskReminder', 1)
			WITH (
				[start_date]	DATETIME,
				reminder_days	INT,
				module_id		INT,
				source_id		INT,
				include_holiday NCHAR(1),
				event_message_id	INT
			)
			

			IF OBJECT_ID('tempdb..#tmp_import_notification') IS NOT NULL
				DROP TABLE #tmp_import_notification
		
			SELECT	ixp_rules_id [ixp_rules_id],
					[action]	[action]
			INTO #tmp_import_notification
			FROM OPENXML(@idoc, '/Root/ImportNotification', 1)
			WITH (
				ixp_rules_id	INT,
				[action]		VARCHAR(100)
			)
			
			EXEC sp_xml_preparedocument @idoc OUTPUT, @user_role_xml

			IF OBJECT_ID('tempdb..#workflow_event_user_role') IS NOT NULL
				DROP TABLE #workflow_event_user_role
		
			SELECT 
					NULLIF(user_login_id, '')		[user_login_id],
					NULLIF(role_id, 0)				[role_id]
			INTO #workflow_event_user_role
			FROM OPENXML(@idoc, '/Root/FormXML', 1)
			WITH (
				user_login_id			NVARCHAR(100),
				role_id					NVARCHAR(100)
			)
			
			DECLARE @event_message_id NVARCHAR(10) = '', @m_events_id INT, @e_trigger_id INT
			SELECT @event_message_id = event_message_id FROM #workflow_event_message
			
			IF @event_message_id = ''
				BEGIN
					IF ((SELECT event_trigger_id FROM #workflow_event_message) = -9999)
					BEGIN
						SELECT @m_events_id = wst1.workflow_id FROM workflow_schedule_task wst1
						INNER JOIN workflow_schedule_task wst2 ON wst1.id =  wst2.parent
						INNER JOIN #tmp_msg_task tmp ON wst2.id = tmp.parent_id
						
						INSERT INTO event_trigger(modules_event_id, alert_id)
						SELECT @m_events_id, -2

						SET @e_trigger_id = SCOPE_IDENTITY()
					END

					INSERT INTO workflow_schedule_task ([start_date], duration, workflow_id_type, parent, sort_order)
					SELECT [start_date], duration, workflow_id_type, NULLIF(parent_id, '0'), s.new_sort_order FROM  #tmp_msg_task tmp
					CROSS APPLY (
						SELECT ISNULL(MAX(sort_order) + 1,1) [new_sort_order] FROM workflow_schedule_task wst
						WHERE wst.parent = tmp.parent_id
					) s

					DECLARE @task_new_id INT = SCOPE_IDENTITY()

					IF ((SELECT event_trigger_id FROM #workflow_event_message) <> -9999)
					BEGIN
						INSERT INTO workflow_schedule_link (source, [target], [type])
						SELECT parent, id, 0 FROM workflow_schedule_task WHERE id = @task_new_id
					END

					DECLARE @msg_event_trigger_id INT
					IF EXISTS (SELECT 1 FROM #workflow_event_message WHERE NULLIF(event_trigger_id,0) IS NULL)
					BEGIN
						INSERT INTO event_trigger (create_user)
						SELECT dbo.FNADBUser()
						SET @msg_event_trigger_id = IDENT_CURRENT('event_trigger')
					END

					INSERT INTO workflow_event_message
					(
						event_message_name,
						event_trigger_id,
						notification_type,
						[message],
						self_notify,
						mult_approval_required,
						comment_required,
						approval_action_required,
						notify_trader,
						next_module_events_id,
						minimum_approval_required,
						optional_event_msg,
						automatic_proceed
					)
					SELECT event_message_name,
						CASE WHEN event_trigger_id = -9999 THEN @e_trigger_id ELSE ISNULL(NULLIF(event_trigger_id,0),@msg_event_trigger_id) END,
						notification_type,
						[message],
						self_notify,
						mult_app_req,
						comment_req,
						approval_req,
						notify_trader,
						NULLIF(next_module_events_id,0),
						NULLIF(minimum_approval_required,0),
						optional_event_msg,
						automatic_proceed
					FROM #workflow_event_message AS wem
					
					SET @event_message_id = SCOPE_IDENTITY()

					UPDATE wem 
					SET wem.automatic_proceed = CASE WHEN me.modules_id = 20619 THEN 'y' ELSE 'n' END
					FROM workflow_event_message wem
					INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
					INNER JOIN module_events me ON me.module_events_id = et.modules_event_id
					WHERE wem.event_message_id = @event_message_id

					INSERT INTO workflow_event_user_role
					(
						event_message_id,
						user_login_id,
						role_id
					)
					SELECT @event_message_id,
						user_login_id,
						role_id 
					FROM #workflow_event_user_role AS weur

					UPDATE wst
					SET wst.workflow_id = @event_message_id
					FROM workflow_schedule_task wst
					WHERE id = @task_new_id

					INSERT INTO workflow_schedule_link(source, [target], [type])
					SELECT @task_new_id, wst.id, 2 FROM workflow_schedule_task wst
					LEFT JOIN workflow_event_message wem ON wst.workflow_id = wem.next_module_events_id  AND wst.workflow_id_type = 1
					WHERE wem.event_message_id = @event_message_id AND wem.next_module_events_id IS NOT NULL

					IF EXISTS (SELECT 1 FROM #tmp_msg_reminder)
					BEGIN
						INSERT INTO calendar_events (
									[name], 
									[description], 
									reminder, 
									[start_date], 
									[end_date], 
									include_holiday, 
									module_id, 
									event_message_id, 
									source_id,
									rec_type
						)
						SELECT	msg.event_message_name	[name], 
								msg.event_message_name	[description], 
								ISNULL(NULLIF(tmp.reminder_days*1440,0),1)		[reminder], 
								dbo.FNAConvertTimezone(tmp.[start_date],1)				[start_date],	
								dbo.FNAConvertTimezone(DATEADD(HOUR,1,tmp.[start_date]),1)	[end_date], 
								tmp.include_holiday		[include_holiday], 
								tmp.module_id		[module_id], 
								@event_message_id	[event_message_id], 
								tmp.source_id		[source_id] ,
								''					[rec_type]
						FROM #tmp_msg_reminder tmp 
						OUTER APPLY (SELECT * FROM #workflow_event_message) msg
					END

					IF EXISTS (SELECT 1 FROM #tmp_import_notification)
					BEGIN
											
						Update
						iids
						set iids.message_id = @event_message_id						
						from ixp_import_data_source iids
						INNER JOIN #tmp_import_notification tin 
						ON tin.ixp_rules_id = iids.rules_id AND tin.action = 1 
		
						Update
						iids
						set iids.error_message_id = @event_message_id						
						from ixp_import_data_source iids
						INNER JOIN #tmp_import_notification tin 
						ON tin.ixp_rules_id = iids.rules_id AND tin.action = 0 
					END

				END
			ELSE
				BEGIN
					DELETE wsl FROM workflow_schedule_link wsl 
					INNER JOIN workflow_schedule_task wst ON wsl.[target] = wst.id
					LEFT JOIN workflow_event_message wem ON wst.workflow_id = wem.next_module_events_id
					LEFT JOIN #workflow_event_message twem ON wem.event_message_id = twem.event_message_id
					WHERE wem.event_message_id = @event_message_id AND twem.next_module_events_id IS NOT NULL

					UPDATE wem2
						SET wem2.event_message_name = wem.event_message_name,
							wem2.notification_type = wem.notification_type,
							wem2.[message] = wem.message,
							wem2.self_notify = wem.self_notify,
							wem2.approval_action_required = wem.approval_req,
							wem2.comment_required = wem.comment_req,
							wem2.mult_approval_required = wem.mult_app_req,
							wem2.notify_trader = wem.notify_trader,
							wem2.next_module_events_id = NULLIF(wem.next_module_events_id,0),
							wem2.minimum_approval_required = NULLIF(wem.minimum_approval_required,0),
							wem2.optional_event_msg = wem.optional_event_msg,
							wem2.automatic_proceed = wem.automatic_proceed
					FROM #workflow_event_message AS wem
					LEFT JOIN workflow_event_message AS wem2 ON wem.event_message_id = wem2.event_message_id
					WHERE wem2.event_message_id = @event_message_id

					UPDATE wem 
					SET wem.automatic_proceed = CASE WHEN me.modules_id = 20619 THEN 'y' ELSE 'n' END
					FROM workflow_event_message wem
					INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
					INNER JOIN module_events me ON me.module_events_id = et.modules_event_id
					WHERE wem.event_message_id = @event_message_id

					DELETE 
					FROM workflow_event_user_role
					WHERE event_message_id = @event_message_id
					
					INSERT INTO workflow_event_user_role
					(
						event_message_id,
						user_login_id,
						role_id
					)
					SELECT @event_message_id,
						user_login_id,
						role_id 
					FROM #workflow_event_user_role AS weur

					INSERT INTO workflow_schedule_link(source, [target], [type])
					SELECT wst1.id, wst.id, 2 FROM workflow_schedule_task wst
					LEFT JOIN workflow_event_message wem ON wst.workflow_id = wem.next_module_events_id AND wst.workflow_id_type = 1
					INNER JOIN workflow_schedule_task wst1 ON wst1.workflow_id = wem.event_message_id AND wst1.workflow_id_type = 3
					WHERE wem.event_message_id = @event_message_id AND wem.next_module_events_id IS NOT NULL
					
					UPDATE #tmp_msg_reminder
					SET event_message_id = @event_message_id

					UPDATE ce
					SET ce.[name] = wem.event_message_name,
						ce.[description] = wem.event_message_name,
						ce.[start_date] = dbo.FNAConvertTimezone(tmp.[start_date],1),
						ce.[end_date] = dbo.FNAConvertTimezone(DATEADD(HOUR,1,tmp.[start_date]),1),
						ce.reminder = ISNULL(NULLIF(tmp.reminder_days*1440,0),1),
						ce.include_holiday = tmp.include_holiday
					FROM calendar_events ce
					INNER JOIN #tmp_msg_reminder tmp ON ce.event_message_id = tmp.event_message_id
					INNER JOIN #workflow_event_message wem ON wem.event_message_id = tmp.event_message_id

				END
			
			EXEC spa_ErrorHandler 0
				, 'workflow_event_message'
				, 'spa_setup_rule_workflow'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, @event_message_id
		
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			   ROLLBACK
	 
			SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
			SELECT @err_no = ERROR_NUMBER()
	 
			EXEC spa_ErrorHandler @err_no
			   , 'workflow_event_message'
			   , 'spa_setup_rule_workflow'
			   , 'Error'
			   , @desc
			   , ''
		END CATCH
	END
ELSE IF @flag = 'r' 
    BEGIN
		SELECT	alert_sql_id,
     			alert_sql_name
		FROM alert_sql 
		WHERE ISNULL(alert_category,'c') <> 'w' AND alert_sql_id > 0
     	ORDER BY alert_sql_name ASC
    END
ELSE IF @flag = 'u' 
	BEGIN
		BEGIN TRY
			--SET @xml='<Root><FormXML modules_event_id="3" alert_id="9" event_trigger_id=""></FormXML></Root>'
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

			IF OBJECT_ID('tempdb..#workflow_rules') IS NOT NULL
				DROP TABLE #workflow_rules
		
			SELECT modules_event_id		[modules_event_id],
					alert_id			[alert_id],
					event_trigger_id	[event_trigger_id]
			INTO #workflow_rules
			FROM OPENXML(@idoc, '/Root/FormXML', 1)
			WITH (
				modules_event_id		NVARCHAR(100),
				alert_id				NVARCHAR(100),
				event_trigger_id		NVARCHAR(100)
			)
			
			DECLARE @event_trigger_id NVARCHAR(100) = ''
			SELECT @event_trigger_id = event_trigger_id FROM #workflow_rules
			
			IF @event_trigger_id = ''
				BEGIN
					INSERT INTO event_trigger
					(
						modules_event_id,
						alert_id
					)
					SELECT modules_event_id,
						alert_id
					FROM #workflow_rules AS wr
					
					SET @event_trigger_id = SCOPE_IDENTITY()
				END
			ELSE
				BEGIN
					UPDATE et
						SET et.alert_id = wr.alert_id
					FROM #workflow_rules AS wr
					LEFT JOIN event_trigger AS et ON wr.event_trigger_id = et.event_trigger_id
					WHERE et.event_trigger_id = @event_trigger_id
				END
			
			EXEC spa_ErrorHandler 0
				, 'event_trigger'
				, 'spa_setup_rule_workflow'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, @event_trigger_id
		
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			   ROLLBACK
	 
			SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
			SELECT @err_no = ERROR_NUMBER()
	 
			EXEC spa_ErrorHandler @err_no
			   , 'event_trigger'
			   , 'spa_setup_rule_workflow'
			   , 'Error'
			   , @desc
			   , ''
		END CATCH
	END
ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRY
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

			IF OBJECT_ID('tempdb..#workflow_rules_delete') IS NOT NULL
				DROP TABLE #workflow_rules_delete
		
			SELECT event_trigger_id		[event_trigger_id],
					event_message_id	[event_message_id],
					event_action_id		[event_action_id]
			INTO #workflow_rules_delete
			FROM OPENXML(@idoc, '/GridGroup/GridRow', 1)
			WITH (
				event_trigger_id	NVARCHAR(100),
				event_message_id	NVARCHAR(100),
				event_action_id		NVARCHAR(100)
			)

			-- Delete From Actions
			DELETE wea
			FROM workflow_event_action wea
			LEFT JOIN #workflow_rules_delete wrd ON wrd.event_action_id = wea.event_action_id
			WHERE wrd.event_action_id IS NOT NULL
			
			--DELETE wea
			--FROM workflow_event_action wea
			--LEFT JOIN #workflow_rules_delete wrd ON wrd.event_message_id = wea.event_message_id
			--WHERE wrd.event_message_id IS NOT NULL
			
			-- Delete From User Role
			DELETE weur
			FROM workflow_event_user_role weur
			LEFT JOIN #workflow_rules_delete wrd ON wrd.event_message_id = weur.event_message_id
			WHERE wrd.event_message_id IS NOT NULL

			-- Delete From Messages
			DELETE wem
			FROM workflow_event_message wem
			LEFT JOIN #workflow_rules_delete wrd ON wrd.event_message_id = wem.event_message_id
			WHERE wrd.event_message_id IS NOT NULL
			
			--DELETE wem
			--FROM workflow_event_message wem
			--LEFT JOIN #workflow_rules_delete wrd ON wrd.event_trigger_id = wem.event_trigger_id
			--WHERE wrd.event_trigger_id IS NOT NULL

			-- Delete From Mapped Rules
			DELETE et
			FROM event_trigger et
			LEFT JOIN #workflow_rules_delete wrd ON wrd.event_trigger_id = et.event_trigger_id
			WHERE wrd.event_trigger_id IS NOT NULL

			EXEC spa_ErrorHandler 0
					, 'event_trigger'
					, 'spa_setup_rule_workflow'
					, 'Success' 
					, 'Changes have been saved successfully.'
					, ''

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			   ROLLBACK
	 
			SET @desc = dbo.FNAHandleDBError(NULL)
	 
			SELECT @err_no = ERROR_NUMBER()
	 
			EXEC spa_ErrorHandler @err_no
			   , 'event_trigger'
			   , 'spa_setup_rule_workflow'
			   , 'Error'
			   , @desc
			   , ''
		END CATCH
	END
	ELSE IF @flag = 'b'
	BEGIN
		IF OBJECT_ID('tempdb..#tmp_approval_permission') IS NOT NULL
				DROP TABLE #tmp_approval_permission
		CREATE TABLE #tmp_approval_permission(user_login_id NVARCHAR(100) COLLATE DATABASE_DEFAULT  , action_permission INT)

		INSERT INTO #tmp_approval_permission(user_login_id, action_permission)
		SELECT	user_login_id, 
				CASE WHEN dbo.FNADBUser() = user_login_id THEN 2 ELSE ISNULL(share_calendar,0) END [action_permission]
		FROM application_users au
		INNER JOIN dbo.SplitCommaSeperatedValues(@user_login_id) a ON au.user_login_id = a.item

		IF OBJECT_ID('tempdb..#tmp_approval_list') IS NOT NULL
				DROP TABLE #tmp_approval_list

				--select * from #tmp_approval_list

		CREATE TABLE #tmp_approval_list(module NVARCHAR(100) COLLATE DATABASE_DEFAULT , message NVARCHAR(1000) COLLATE DATABASE_DEFAULT , workflow_activity_id INT, source_id INT, [status] NVARCHAR(50) COLLATE DATABASE_DEFAULT , status_id int,
		created_date NVARCHAR(100) COLLATE DATABASE_DEFAULT , comments NVARCHAR(1000) COLLATE DATABASE_DEFAULT , document NVARCHAR(1000) COLLATE DATABASE_DEFAULT , event_message_id INT, action_permission INT, source_column NVARCHAR(1000) COLLATE DATABASE_DEFAULT, [message_name] NVARCHAR(500) COLLATE DATABASE_DEFAULT, comment_required NVARCHAR(1) COLLATE DATABASE_DEFAULT)

		SET @sql = 'INSERT INTO #tmp_approval_list (module, message, workflow_activity_id, source_id, [status], status_id, created_date, comments, document,event_message_id,action_permission,source_column,[message_name],comment_required)
					SELECT	sdv.code [module], 
							MAX(wa.message) [message],
							MAX(wa.workflow_activity_id) [activity_id], 
							wa.source_id [source_id], 
							ISNULL(sdv1.code, ''Outstanding'') [status],isnull(max(wa.control_status),725) [status_id],
							dbo.FNADateTimeFormat(MAX(wa.as_of_date), 0) [created_date],
							wa.comments [comment],
							''<span style="cursor:pointer" onClick="open_workflow_document(''+CAST(MAX(wa.workflow_activity_id) AS NVARCHAR(100))+'')"><font color=#0000ff><u><l>Open<l></u></font></span> (''+ CAST(COUNT(an.attachment_file_name) AS NVARCHAR(100)) +'')'' [Document],
							wa.event_message_id [event_message_id],
							tap.action_permission,
							wa.source_column,
							wem.event_message_name,
							MAX(wem.comment_required)
					FROM workflow_activities wa
					LEFT JOIN event_trigger et ON et.event_trigger_id = wa.workflow_trigger_id
					LEFT JOIN module_events me ON me.module_events_id = et.modules_event_id
					LEFT JOIN static_data_value sdv ON me.modules_id = sdv.value_id
					LEFT JOIN static_data_value sdv1 ON sdv1.value_id = wa.control_status 
					LEFT JOIN workflow_event_message wem ON et.event_trigger_id = wem.event_trigger_id
					LEFT JOIN workflow_event_user_role weur ON wa.event_message_id = CASE WHEN wa.user_login_id = '''' THEN weur.event_message_id ELSE 0 END 
					LEFT JOIN application_role_user aru ON aru.role_id = weur.role_id
					LEFT JOIN application_notes an ON wa.workflow_activity_id = an.notes_object_id --AND ISNULL(an.internal_type_value_id, 44) = 44
					OUTER APPLY(SELECT MAX(user_login_id) user_login_id FROM application_role_user WHERE role_id = weur.role_id AND user_login_id = ''' + CAST(dbo.FNADBUser() AS NVARCHAR(100)) + ''') ars
					LEFT JOIN delete_source_deal_header dsdh ON dsdh.source_deal_header_id = CASE WHEN wa.source_column =  ''primary_temp_id'' AND wa.source_id = 1 THEN -1 ELSE wa.source_id END AND me.modules_id = 20601
					LEFT JOIN #tmp_approval_permission tap ON tap.user_login_id = wa.user_login_id OR tap.user_login_id = weur.user_login_id OR tap.user_login_id =aru.user_login_id
					WHERE wa.workflow_activity_id IS NOT NULL AND tap.action_permission IS NOT NULL 
					AND dsdh.source_deal_header_id IS NULL
					'
		SET @sql = @sql + ' AND CASE WHEN wem.self_notify = ''y'' THEN ''x'' ELSE wa.create_user END <> dbo.FNADBUser()'
		IF @module_id IS NOT NULL
			SET @sql += ' AND me.modules_id = ' + CAST(@module_id AS NVARCHAR(100))

		IF @status_id = '725'
			SET @sql += ' AND ISNULL(wa.control_status, '''') = '''''
		ELSE IF @status_id IS NOT NULL
			SET @sql += ' AND wa.control_status = ' + CAST(@status_id AS NVARCHAR(100))
		
		IF @date_from IS NOT NULL
			SET @sql = @sql + ' AND CONVERT(NVARCHAR(10), dbo.FNAGetSQLStandardDate(wa.as_of_date), 120) >= ''' + CAST(dbo.FNAGetSQLStandardDate(@date_from) AS NVARCHAR(10)) + ''''
		IF @date_to IS NOT NULL
			SET @sql = @sql + ' AND CONVERT(NVARCHAR(10), dbo.FNAGetSQLStandardDate(wa.as_of_date), 120) >= ''' + CAST(dbo.FNAGetSQLStandardDate(@date_to) AS NVARCHAR(10)) + ''''

		IF @source_id IS NOT NULL
			SET @sql += ' AND wa.source_id = ' + CAST(@source_id AS NVARCHAR(100))
		IF @activity_id IS NOT NULL
			SET @sql += ' AND wa.workflow_activity_id = ' + CAST(@activity_id AS NVARCHAR(100))
		IF @user_login_id IS NULL
			SET @user_login_id = dbo.FNADBUser()

		IF dbo.FNAAppAdminRoleCheck(dbo.FNADBUser()) = 0 --dbo.FNADBUser() <> dbo.FNAAppAdminID()
			SET @sql += ' AND (ISNULL(ars.user_login_id,wa.user_login_id) IN(''' + REPLACE(@user_login_id, ',', ''',''') + ''') OR (weur.user_login_id IN(''' + REPLACE(@user_login_id, ',', ''',''') + ''') AND NULLIF(wa.user_login_id, '''') IS NULL))'

		SET @sql += ' GROUP BY sdv.code,me.modules_id,wa.source_id,sdv1.code,wa.comments,wa.event_message_id,wa.source_column,tap.action_permission, CASE WHEN wa.source_column = ''calendar_event_id'' THEN CAST(wa.as_of_date AS NVARCHAR(10)) ELSE wa.source_column END,wem.event_message_name'
		--PRINT(@sql)
		EXEC(@sql)

		SELECT	DISTINCT
				tml.module [module], 
				sdh_g.deal_id + ' - ' + tml.message_name [group],
				--REPLACE(REPLACE(REPLACE(tml.message ,'../../','../../../'),'<br/>','&nbsp;&nbsp;'),'./dev/spa_html.php','../../../adiha.php.scripts/dev/spa_html.php') [message],
				CASE WHEN (CHARINDEX('<a target', tml.[message]) > 0 AND CHARINDEX('click here', tml.[message]) = 0) THEN REPLACE(REPLACE(tml.[message], '<a target="_blank" href', '<a target="_blank" alt' ), '<a target="_blank"', '<a href="javascript: message_pop_up_drill(' + CAST(msb.[message_id] AS NVARCHAR(100)) + ', ''desc'')"')  ELSE tml.[message] END [message],
				tml.workflow_activity_id [activity_id], 
				tml.source_id [source_id], 
				tml.status [status],
				tml.[created_date] [created_date],
				tml.comments [comment],
				tml.[Document],
				CASE WHEN tml.action_permission = 2 THEN ln.actions ELSE '' END [action],
				CASE 
					WHEN tml.source_column = 'calendar_event_id' THEN '728'
					WHEN tml.action_permission = 2 THEN ln.action_id 
					ELSE '' 
				END [action_id]
				,tml.comment_required [Comment Required]
		FROM #tmp_approval_list tml
		outer apply (
			SELECT  event_message_id,
			  STUFF((
				SELECT '   ' + 
					CASE WHEN wea.status_id = 729 AND wea.status_id <> tml.status_id THEN '<span style="cursor:pointer" onClick="workflow_approval_comment(1)"><font color=#0000ff><u><l>Approve<l></u></font></span>'
						 WHEN wea.status_id = 726 AND wea.status_id <> tml.status_id THEN '<span style="cursor:pointer" onClick="workflow_approval_comment(0)"><font color=#0000ff><u><l>Unapprove<l></u></font></span>'
						 WHEN wea.status_id = 728 AND wea.status_id <> tml.status_id THEN '<span style="cursor:pointer" onClick="workflow_approval_comment(2)"><font color=#0000ff><u><l>Complete<l></u></font></span>'
					ELSE '' END
					FROM workflow_event_action wea
					WHERE (event_message_id = Results.event_message_id) 
					FOR XML PATH(''),TYPE 
				).value('.','NVARCHAR(MAX)') 
			  ,1,0,'') as actions,
			  STUFF((
				SELECT ',' + CAST(status_id AS NVARCHAR)
					FROM workflow_event_action wea
					WHERE (event_message_id = Results.event_message_id) 
					FOR XML PATH(''),TYPE 
				).value('.','NVARCHAR(MAX)') 
			  ,1,1,'') as action_id
			FROM    workflow_event_action Results
			where Results.event_message_id = tml.event_message_id
			GROUP BY event_message_id
		) ln --ON tml.event_message_id = ln.event_message_id
		LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = tml.source_id AND tml.module = 'Deal'
		LEFT JOIN source_deal_header sdh_g on sdh_g.source_deal_header_id = sdh.structured_deal_id
		OUTER APPLY (SELECT max(mb.message_id) [message_id] FROM message_board mb WHERE mb.workflow_activity_id = tml.workflow_activity_id AND mb.user_login_id = dbo.FNADBUser()) msb
			
	END
	ELSE IF @flag = 'c'
	BEGIN
		DECLARE @control_status INT
		IF @approved = 1 -- Approved
		BEGIN
			SET @control_status = 729
		END
		ELSE IF @approved = 0 -- Unapproved
		BEGIN
			SET @control_status = 726
		END
		ELSE IF @approved = 2 -- Completed
		BEGIN
			SET @control_status = 728
		END
		ELSE IF @approved = 3 -- Threshold Exception
		BEGIN
			SET @control_status = 733
		END

		IF @approved IS NOT NULL
		BEGIN
			DECLARE @msg_process_table NVARCHAR(400)
			DECLARE @n_process_id NVARCHAR(400) = dbo.FNAGetNewID()
			SET @user_login_id = dbo.FNADBUser()
			SET @msg_process_table = dbo.FNAProcessTableName('alert_message', @user_login_id, @n_process_id)
			
			SET @sql = 'CREATE TABLE ' + @msg_process_table + ' (user_login_id NVARCHAR(100) COLLATE DATABASE_DEFAULT, [source] NVARCHAR(50) COLLATE DATABASE_DEFAULT, [description] NVARCHAR(MAX) COLLATE DATABASE_DEFAULT, [TYPE] NCHAR(1) COLLATE DATABASE_DEFAULT, is_alert NCHAR(1) COLLATE DATABASE_DEFAULT, is_alert_processed NCHAR(1) COLLATE DATABASE_DEFAULT,process_id NVARCHAR(50) COLLATE DATABASE_DEFAULT,
			notes_subject NVARCHAR(250) COLLATE DATABASE_DEFAULT, notes_text NVARCHAR(MAX) COLLATE DATABASE_DEFAULT, send_from NVARCHAR(100) COLLATE DATABASE_DEFAULT, send_to NVARCHAR(MAX) COLLATE DATABASE_DEFAULT, send_status NCHAR(1) COLLATE DATABASE_DEFAULT, active_flag NCHAR(1) COLLATE DATABASE_DEFAULT, event_trigger_id INT, attachment_file_name NVARCHAR(500) COLLATE DATABASE_DEFAULT, email_type NCHAR(1) COLLATE DATABASE_DEFAULT NULL, workflow_activity_id int null, sys_users NVARCHAR(MAX) COLLATE DATABASE_DEFAULT)'
			EXEC(@sql)
			
			DECLARE @workflow_activity_id INT
			DECLARE activity_cursor CURSOR FOR
			SELECT DISTINCT s.item FROM dbo.SplitCommaSeperatedValues(@activity_id) s WHERE s.item <> ''
			OPEN activity_cursor
			FETCH NEXT FROM activity_cursor INTO @workflow_activity_id 
			WHILE @@FETCH_STATUS = 0
			BEGIN
				DECLARE @activity_event_trigger_id INT, @next_alert_id INT = NULL, @next_trigger_id INT, @current_status INT,@activity_message_id INT, @previous_status INT
				DECLARE @next_process_id NVARCHAR(200), @next_process_table NVARCHAR(200), @source_column NVARCHAR(100),@XML_Process_data XML, @workflow_process_id NVARCHAR(100)
				DECLARE @message_process_id NVARCHAR(200)
				DECLARE @workflow_group_id INT
				declare @next_notification_type NVARCHAR(1000) = null
				
				SELECT	@activity_event_trigger_id = wa.workflow_trigger_id,
						@next_process_id = @n_process_id,
						@next_process_table = process_table,
						@previous_status = waa.control_prior_status,
						@current_status = control_status,
						@activity_message_id = event_message_id,
						@source_column = source_column,
						@XML_Process_data = XML_process_data,
						@workflow_process_id = workflow_process_id,
						@message_process_id = process_id,
						@workflow_group_id = wa.workflow_group_id
				FROM workflow_activities wa
				LEFT JOIN workflow_activities_audit waa ON wa.workflow_activity_id = waa.workflow_activity_id AND waa.control_new_status = wa.control_status
				WHERE wa.workflow_activity_id = @workflow_activity_id

				IF OBJECT_ID(@next_process_table) IS NULL
				BEGIN
					IF @XML_Process_data IS NOT NULL
						BEGIN						
							SET @XML_Process_data = '<PSRecordset>'+CAST(@XML_Process_data AS NVARCHAR(MAX))+'</PSRecordset>'
							EXEC [spa_parse_xml_file] 'b',NULL,@XML_Process_data,@next_process_table

						END
				END

				IF @approved = 4 -- Recall
					SET @control_status = @previous_status
				
				-- Update Audit Log
				IF @approved <> 4 -- Only if action is not recall
				INSERT INTO [dbo].[workflow_activities_audit]
					   ([workflow_activity_id]
					   ,[workflow_trigger_id]
					   ,[as_of_date]
					   ,[control_prior_status]
					   ,[control_new_status]
					   ,[activity_desc])
				 VALUES
					   (@workflow_activity_id
					   ,@activity_event_trigger_id
					   ,GETDATE()
					   ,ISNULL(@current_status, 725)
					   ,ISNULL(@control_status, 728)
					   ,ISNULL(@comments, ''))

				---- Approve/Unapprove Activities
				UPDATE dbo.workflow_activities
					SET control_status = @control_status,
						approved_by = isnull(@approved_by, dbo.FNADBUser()), --approved by available when call from email parse
						approved_date = GETDATE()
					WHERE  workflow_activity_id = @workflow_activity_id

				---- Approve/Unapprove repeated previous activities
				DECLARE @c_workflow_trigger_id INT, @c_event_message_id INT, @c_souce_column NVARCHAR(100), @c_source_id INT, @c_user_login_id NVARCHAR(100)

				SELECT	@c_workflow_trigger_id = workflow_trigger_id, 
						@c_event_message_id = event_message_id, 
						@c_souce_column = source_column, 
						@c_source_id = source_id, 
						@c_user_login_id = user_login_id
				FROM workflow_activities WHERE workflow_activity_id = @workflow_activity_id

				UPDATE workflow_activities
				SET control_status = @control_status,
					approved_by = isnull(@approved_by, dbo.FNADBUser()), --approved by available when call from email parse
					approved_date = GETDATE()
				WHERE workflow_trigger_id = @c_workflow_trigger_id
				AND event_message_id = @c_event_message_id
				AND source_column = @c_souce_column
				AND source_id = @c_source_id
				AND CASE WHEN ISNULL(user_login_id,'') = '' THEN dbo.FNADBUser() ELSE user_login_id END = dbo.FNADBUser()
				AND control_status IS NULL

				
				
				--Check the Special Condition
				DECLARE @special_condition NCHAR(1) = 'n', @proceed_to_next_event NCHAR = 'y', @minimum_approval_required INT = 0, @event_count INT = 0
				DECLARE @optional_event_msg NCHAR(1) = 'n', @w_process_id NVARCHAR(100) = ''
				SELECT  @special_condition = mult_approval_required,
						@minimum_approval_required = minimum_approval_required,
						@optional_event_msg = optional_event_msg
				FROM workflow_event_message
				WHERE event_message_id = @activity_message_id
				
				IF @special_condition = 'y'
				BEGIN
					IF @control_status = 726
						SET @minimum_approval_required = 1

					IF (@minimum_approval_required = 0 OR @minimum_approval_required IS NULL)
					BEGIN
						IF EXISTS(
							SELECT 1 --workflow_activity_id, control_status, update_user
							FROM workflow_activities
							WHERE workflow_trigger_id = @activity_event_trigger_id 
							AND event_message_id = @activity_message_id
							AND workflow_activity_id <> @workflow_activity_id
							AND (control_status IS NULL OR control_status <> @control_status)
							AND workflow_process_id = @workflow_process_id
							AND process_id = @message_process_id
						)
						BEGIN
							SET @proceed_to_next_event = 'n'
						END
					END
					ELSE 
					BEGIN
					SELECT @w_process_id = workflow_process_id FROM workflow_activities WHERE workflow_activity_id = @workflow_activity_id

					SELECT @event_count = COUNT(workflow_activity_id) --workflow_activity_id, control_status, update_user
						FROM workflow_activities
						WHERE workflow_trigger_id = @activity_event_trigger_id 
						AND event_message_id = @activity_message_id
						AND (control_status IS NOT NULL OR control_status <> @control_status)
						AND workflow_process_id = @w_process_id
						AND process_id = @message_process_id

						IF (@event_count < @minimum_approval_required)
						BEGIN
							SET @proceed_to_next_event = 'n'
						END
					END
				END
				
				IF @proceed_to_next_event = 'y'
				BEGIN
					IF @special_condition = 'y'
					BEGIN
						UPDATE workflow_activities
						SET control_status = @control_status,
							approved_date = GETDATE()
							WHERE workflow_trigger_id = @activity_event_trigger_id 
							AND event_message_id = @activity_message_id
							AND workflow_activity_id <> @workflow_activity_id
							AND (control_status IS NULL OR control_status <> @control_status)
							AND workflow_process_id = @workflow_process_id
							AND process_id = @message_process_id
					END

					IF @optional_event_msg = 'y'
					BEGIN
						SELECT @w_process_id = workflow_process_id FROM workflow_activities WHERE workflow_activity_id = @workflow_activity_id

						IF OBJECT_ID('tempdb..#temp_optional_app_list') IS NOT NULL
							DROP TABLE #temp_optional_app_list

						SELECT workflow_trigger_id, source_column, source_id, user_login_id
						INTO #temp_optional_app_list
						FROM workflow_activities
						WHERE workflow_trigger_id = @activity_event_trigger_id 
							AND workflow_process_id = @w_process_id
							AND workflow_activity_id <> @workflow_activity_id
							AND (control_status IS NULL OR control_status <> @control_status)


						UPDATE workflow_activities
						SET control_status = @control_status,
							approved_date = GETDATE()
							WHERE workflow_trigger_id = @activity_event_trigger_id 
							AND workflow_process_id = @w_process_id
							AND workflow_activity_id <> @workflow_activity_id
							AND (control_status IS NULL OR control_status <> @control_status)


						UPDATE wa
						SET wa.control_status = @control_status,
							wa.approved_date = GETDATE()
						FROM workflow_activities wa
						INNER JOIN #temp_optional_app_list tmp ON wa.workflow_trigger_id = tmp.workflow_trigger_id
						AND wa.source_column = tmp.source_column 
						AND wa.source_id = tmp.source_id
						WHERE wa.workflow_process_id <> @w_process_id AND wa.control_status IS NULL
						
					END

					-- Triggering Next Rule ---
					SELECT top 1 @next_alert_id = et1.alert_id, @next_trigger_id = et1.event_trigger_id, @next_notification_type = wem_n.notification_type
					FROM event_trigger et
					LEFT JOIN workflow_event_message wem ON et.event_trigger_id = wem.event_trigger_id AND wem.event_message_id = @activity_message_id
					LEFT JOIN workflow_event_action wea ON wem.event_message_id = wea.event_message_id
					LEFT JOIN event_trigger et1 ON wea.alert_id = et1.event_trigger_id
					LEFT JOIN workflow_event_message wem_n ON wem_n.event_trigger_id = et1.event_trigger_id
					WHERE et.event_trigger_id = @activity_event_trigger_id AND wea.status_id = @control_status

					IF @next_alert_id IS NOT NULL
					BEGIN
						DECLARE @partial_value_process_table NVARCHAR(400)
						SET @user_login_id = dbo.FNADBUser()
						SET @partial_value_process_table = dbo.FNAProcessTableName('workflow_approval', @user_login_id, dbo.FNAGetNewID())
						
						IF @next_process_table <> ''
						BEGIN
							SET @sql = 'SELECT a.* INTO ' + @partial_value_process_table + ' FROM ' + @next_process_table + ' a 
										LEFT JOIN workflow_activities wa ON wa.source_id = a.' + @source_column + '
										AND wa.workflow_activity_id = ' + CAST(@workflow_activity_id AS NVARCHAR(100))
							EXEC(@sql)
							EXEC spa_run_alert_sql @next_alert_id, @next_process_id, @partial_value_process_table, NULL, NULL, @next_trigger_id, @msg_process_table, @workflow_process_id, NULL, @workflow_group_id, NULL, @control_status 
							EXEC('DROP TABLE ' + @partial_value_process_table)
						END
						ELSE 
						BEGIN
							DECLARE @job_name NVARCHAR(100)
							SET @sql = 'spa_run_alert_sql ' + CAST(@next_alert_id AS NVARCHAR) + ', NULL, NULL, NULL, NULL, ' + CAST(@next_trigger_id AS NVARCHAR) + ', NULL, ''' + @workflow_process_id + ''',NULL, ''' + @workflow_group_id + ''', NULL, ''' + @control_status + ''''
							SET @job_name = 'Alert_Job_AP_' + CAST(@next_alert_id AS NVARCHAR) + '_' +  CAST(@next_process_id AS NVARCHAR)

							EXEC spa_run_sp_as_job @job_name, @sql, @job_name, @user_login_id, NULL, NULL, NULL
						END
					END
				END

				FETCH NEXT FROM activity_cursor INTO @workflow_activity_id
			END
			CLOSE activity_cursor
			DEALLOCATE activity_cursor
			
			--PRINT @msg_process_table
			SET @sql = 'IF EXISTS(SELECT 1 FROM ' + @msg_process_table + ')
						BEGIN
							
							IF OBJECT_ID(''tempdb..#notification_type'') IS NOT NULL
								DROP TABLE #notification_type

							SELECT item INTO #notification_type FROM dbo.SplitCommaSeperatedValues(''' + CAST(@next_notification_type AS NVARCHAR(100)) + ''')

							IF EXISTS (SELECT 1 FROM #notification_type WHERE item IN (751, 752, 755, 756,757)) -- MESSAGE BOARD
							BEGIN
								INSERT INTO message_board (user_login_id, [source], [description], [TYPE], is_alert, is_alert_processed, process_id, workflow_activity_id)
								SELECT	DISTINCT
										a.user_login_id,
										a.source,
										wa.[description],
										a.[type],
										a.is_alert,
										a.[is_alert_processed],
										a.[process_id],
										a.[workflow_activity_id]
								FROM 
								(SELECT	user_login_id,
										MAX(source) [source],
										SUBSTRING(description,0,CHARINDEX(''EXEC spa_get_alert_report_output'',description)) + SUBSTRING(description,CHARINDEX(''EXEC spa_get_alert_report_output'',description) + 54, LEN(description)) [desc],
										MAX(type) [type],
										is_alert,
										MAX(is_alert_processed) [is_alert_processed],
										MAX(process_id) [process_id],
										MAX(workflow_activity_id) [workflow_activity_id]
								FROM ' + @msg_process_table + ' mpt
								
								GROUP BY user_login_id, is_alert, event_trigger_id, 
								SUBSTRING(description,0,CHARINDEX(''EXEC spa_get_alert_report_output'',description)) + SUBSTRING(description,CHARINDEX(''EXEC spa_get_alert_report_output'',description) + 54, LEN(description))
								) a
								INNER JOIN ' + @msg_process_table + ' wa ON wa.[workflow_activity_id] = a.[workflow_activity_id]
								where wa.is_alert in (''y'',''n'')
								

							END
							IF EXISTS (SELECT 1 FROM #notification_type WHERE item IN (750, 752, 754, 756)) -- EMAIL
							BEGIN
								INSERT INTO email_notes (notes_subject, notes_text, send_from, send_to, send_status, active_flag, email_type, workflow_activity_id, attachment_file_name, sys_users)
								SELECT MAX(notes_subject), MAX(notes_text), send_from, send_to, send_status, active_flag, max(email_type), max(workflow_activity_id),max(attachment_file_name), MAX(sys_users)
								FROM ' + @msg_process_table + '
								WHERE is_alert IS NULL
								GROUP BY send_from, send_to, send_status, active_flag, event_trigger_id
							END
						END'
			EXEC(@sql)
		END

		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR,
				 'Update Activity Status',
				 'spa_setup_rule_workflow',
				 'DB Error',
				 'Changes have not been saved.',
				 ''
		ELSE
			EXEC spa_ErrorHandler 0,
				 'Update Activity Status',
				 'spa_setup_rule_workflow',
				 'Success',
				 'Changes have been saved successfully.',
				 ''
	END
	ELSE IF @flag = 'f'
	BEGIN
		SELECT	
				--wa.workflow_activity_id [Activity ID], 
				wa.message [Message], 
				sdv.code [Prior Status], 
				sdv1.code [New Status],
				waa.activity_desc [Comment], 
				waa.as_of_date [As of Date], 
				au.user_f_name + ' ' + ISNULL(au.user_m_name, '') + ' ' + au.user_l_name [User]
		FROM workflow_activities wa
		LEFT JOIN workflow_activities_audit waa ON wa.workflow_activity_id = waa.workflow_activity_id
		LEFT JOIN dbo.SplitCommaSeperatedValues(@activity_id) s ON waa.workflow_activity_id = s.item
		LEFT JOIN application_users au ON waa.create_user = au.user_login_id
		LEFT JOIN static_data_value sdv ON waa.control_prior_status = sdv.value_id
		LEFT JOIN static_data_value sdv1 ON waa.control_new_status = sdv1.value_id
		WHERE s.item IS NOT NULL
	END
	ELSE IF @flag = 'x'
	BEGIN
		DECLARE @comment_required NCHAR(1) = 'n'
		
		IF @approved = 1
		BEGIN
			SET @control_status = 729
		END
		ELSE IF @approved = 0
		BEGIN
			SET @control_status = 726
		END

		SELECT @comment_required = ISNULL(wem2.comment_required, 'n')
		FROM event_trigger et
		LEFT JOIN workflow_event_message wem ON et.event_trigger_id = wem.event_trigger_id
		LEFT JOIN workflow_event_action wea ON wem.event_message_id = wea.event_message_id
		LEFT JOIN event_trigger et1 ON wea.alert_id = et1.event_trigger_id
		LEFT JOIN workflow_event_message wem2 ON wem2.event_trigger_id = et1.event_trigger_id
		LEFT JOIN workflow_activities wa ON wa.event_message_id = wem.event_message_id
		LEFT JOIN dbo.SplitCommaSeperatedValues(@activity_id) s ON wa.workflow_activity_id = s.item
		WHERE s.item IS NOT NULL AND wea.status_id = @control_status AND wem2.event_message_id IS NOT NULL

		SELECT @approved, @comment_required
	END
	ELSE IF @flag = 'y'
	BEGIN
		IF OBJECT_ID('tempdb..#workflow_event_action') IS NOT NULL
				DROP TABLE #workflow_event_action
	
		CREATE TABLE #temp_del_list (
			workflow_trigger_id INT,
			event_message_id INT,
			source_column NVARCHAR(100) COLLATE DATABASE_DEFAULT   ,
			source_id INT
		)
	
		
		INSERT INTO #temp_del_list (workflow_trigger_id, event_message_id, source_column, source_id)
		SELECT DISTINCT workflow_trigger_id, event_message_id, source_column, source_id
		FROM workflow_activities wa
		INNER JOIN dbo.SplitCommaSeperatedValues(@activity_id) s ON wa.workflow_activity_id = s.item
		
		DELETE wa FROM workflow_activities wa
		INNER JOIN #temp_del_list tmp ON wa.workflow_trigger_id = tmp.workflow_trigger_id
		AND wa.event_message_id = tmp.event_message_id
		AND wa.source_column = tmp.source_column
		AND wa.source_id = tmp.source_id
		AND CASE WHEN ISNULL(wa.user_login_id,'') = '' THEN dbo.FNADBUser() ELSE wa.user_login_id END = dbo.FNADBUser()
		AND wa.control_status IS NULL
	
		

		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR,
				 'Delete Activity',
				 'spa_setup_rule_workflow',
				 'DB Error',
				 'Changes have not been saved successfully.',
				 ''
		ELSE
			EXEC spa_ErrorHandler 0,
				 'Delete Activity',
				 'spa_setup_rule_workflow',
				 'Success',
				 'Changes have been saved successfully.',
				 ''
	END
	ELSE IF @flag = 'n'
	BEGIN
		IF EXISTS(SELECT * FROM workflow_event_message WHERE ISNULL(automatic_proceed,'n') = 'y' AND event_message_id = @message_id)
		BEGIN
			SELECT DISTINCT et.event_trigger_id, CASE WHEN alert_sql_id = -1 THEN wem.event_message_name ELSE alert_sql_name END
			FROM event_trigger et
			LEFT JOIN (
				SELECT me.module_events_id, et.event_trigger_id
				FROM event_trigger et
				LEFT JOIN module_events me ON me.module_events_id = et.modules_event_id
				LEFT JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
				WHERE CASE WHEN @message_id IS NULL THEN et.event_trigger_id ELSE wem.event_message_id END = CASE WHEN @message_id IS NULL THEN @alert_rule_id ELSE @message_id END
			) a on  a.module_events_id = et.modules_event_id
			LEFT JOIN alert_sql ass ON ass.alert_sql_id = et.alert_id
			LEFT JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id AND et.alert_id = -1
			WHERE a.module_events_id IS NOT NULL AND a.event_trigger_id <> et.event_trigger_id
			UNION ALL
			SELECT -7, 'End the process'
		END
		ELSE
		BEGIN
			SELECT DISTINCT et.event_trigger_id, CASE WHEN alert_sql_id = -1 THEN wem.event_message_name ELSE alert_sql_name END
			FROM event_trigger et
			LEFT JOIN (
				SELECT me.module_events_id, et.event_trigger_id
				FROM event_trigger et
				LEFT JOIN module_events me ON me.module_events_id = et.modules_event_id
				LEFT JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
				WHERE CASE WHEN @message_id IS NULL THEN et.event_trigger_id ELSE wem.event_message_id END = CASE WHEN @message_id IS NULL THEN @alert_rule_id ELSE @message_id END
			) a on  a.module_events_id = et.modules_event_id
			LEFT JOIN alert_sql ass ON ass.alert_sql_id = et.alert_id
			LEFT JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id AND et.alert_id = -1
			WHERE a.module_events_id IS NOT NULL AND a.event_trigger_id <> et.event_trigger_id
		END
		
	END
	ELSE IF @flag = 'p'
	BEGIN
		SELECT	value_id, code
		FROM static_data_value
		WHERE type_id = 725 AND value_id IN (726,729)
	END
	ELSE IF @flag = 'q'
	BEGIN
		BEGIN TRY
			--SET @xml='<Root><FormXML event_action_id="" event_message_id="1" approval_action="729" next_rule="12"></FormXML></Root>'
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

			IF OBJECT_ID('tempdb..#workflow_event_action') IS NOT NULL
				DROP TABLE #workflow_event_action
		
			SELECT event_message_id		[event_message_id],
					event_action_id		[event_action_id],
					approval_action		[approval_id],
					next_rule			[next_rule_id]
			INTO #workflow_event_action
			FROM OPENXML(@idoc, '/Root/FormXML', 1)
			WITH (
				event_message_id		INT,
				event_action_id			INT,
				approval_action			INT,
				next_rule				INT
			)
			
			DECLARE @event_action_id INT
			SELECT @event_action_id = event_action_id FROM #workflow_event_action
			
			IF @event_action_id = ''
				BEGIN
					INSERT INTO workflow_event_action
					(
						event_message_id,
						status_id,
						alert_id
					)
					SELECT event_message_id,
						approval_id,
						next_rule_id
					FROM #workflow_event_action AS wea
					
				END
			ELSE
				BEGIN
					UPDATE wea2
						SET wea2.event_message_id = wea.event_message_id,
							wea2.status_id = wea.approval_id,
							wea2.alert_id = wea.next_rule_id
					FROM #workflow_event_action AS wea
					LEFT JOIN workflow_event_action AS wea2 ON wea.event_action_id = wea2.event_action_id
					WHERE wea2.event_action_id = @event_action_id
				END
			
			EXEC spa_ErrorHandler 0
				, 'workflow_event_action'
				, 'spa_setup_rule_workflow'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, @event_message_id
		
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			   ROLLBACK
	 
			SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
			SELECT @err_no = ERROR_NUMBER()
	 
			EXEC spa_ErrorHandler @err_no
			   , 'workflow_event_action'
			   , 'spa_setup_rule_workflow'
			   , 'Error'
			   , @desc
			   , ''
		END CATCH
	END
	ELSE IF @flag = 'v'
	BEGIN
		SELECT
				status_id,
				alert_id
		FROM workflow_event_action AS wea
		WHERE wea.event_action_id = @action_id
	END
	ELSE IF @flag = 'z'
	BEGIN
		BEGIN TRY
			BEGIN TRAN
			--SET @xml = '<Root function_id="10122500" object_id="53">
			--<FormXML  alert_sql_name="Deal Confirmation Event" notification_type="751" rule_category="26000" alert_type="r" is_active="y" system_rule="n" alert_sql_id="53" workflow_only="n" message=""></FormXML>
			--<GridGroup><Grid grid_id="alert_rule_table"><GridRow  alert_id="" alert_rule_table_id="" table_id="9" table_alias="adfadf" ></GridRow> </Grid></GridGroup></Root>'
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

			IF OBJECT_ID('tempdb..#alert_form') IS NOT NULL
				DROP TABLE #alert_form
		
			SELECT NULLIF(alert_sql_id, 0)	[alert_id],
					alert_sql_name			[alert_name],
					notification_type		[notification_type],
					rule_category			[rule_category],
					is_active				[is_active],
					system_rule				[system_rule],
					workflow_only			[workflow_only],
					sql_statement			[sql_statement]
			INTO #alert_form
			FROM OPENXML(@idoc, '/Root/FormXML', 1)
			WITH (
				alert_sql_id				INT,
				alert_sql_name				NVARCHAR(1000),
				notification_type			INT,
				rule_category				INT,
				is_active					NCHAR,
				system_rule					NCHAR,
				workflow_only				NCHAR,
				sql_statement				NVARCHAR(MAX)
			)

			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

			IF OBJECT_ID('tempdb..#rule_table_grid') IS NOT NULL
				DROP TABLE #rule_table_grid
		
			SELECT NULLIF(alert_id, 0)					[alert_id],
					NULLIF(alert_rule_table_id, 0)		[alert_rule_table_id],
					table_id							[table_id],
					table_alias							[table_alias]
			INTO #rule_table_grid
			FROM OPENXML(@idoc, '/Root/GridGroup/Grid/GridRow', 1)
			WITH (
				alert_id					INT,
				alert_rule_table_id			INT,
				table_id					INT,
				table_alias					NVARCHAR(100)
			)
			
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

			IF OBJECT_ID('tempdb..#rule_table_grid_delete') IS NOT NULL
				DROP TABLE #rule_table_grid_delete
		
			SELECT NULLIF(alert_id, 0)					[alert_id],
					NULLIF(alert_rule_table_id, 0)		[alert_rule_table_id]
			INTO #rule_table_grid_delete
			FROM OPENXML(@idoc, '/Root/GridGroup/GridDelete/GridRow', 1)
			WITH (
				alert_id					INT,
				alert_rule_table_id			INT
			)

			DECLARE @alert_id INT = NULL, @root_table_id INT = NULL

			--Form
			IF EXISTS(SELECT 1 FROM #alert_form af WHERE af.alert_id IS NULL)
			BEGIN 
				INSERT INTO alert_sql(alert_sql_name, notification_type, rule_category, alert_type, is_active, system_rule, workflow_only, sql_statement)
				SELECT alert_name, notification_type, rule_category, 's', is_active, system_rule, workflow_only, sql_statement
				FROM #alert_form WHERE alert_id IS NULL
			
				SET @alert_id = SCOPE_IDENTITY()
			END
			ELSE
			BEGIN
				SELECT @alert_id = alert_id
				FROM #alert_form
				WHERE alert_id IS NOT NULL
				
				UPDATE ass
					SET ass.alert_sql_name = af.alert_name, 
						ass.notification_type = af.notification_type, 
						ass.rule_category = af.rule_category, 
						ass.is_active = af.is_active, 
						ass.system_rule = af.system_rule,
						ass.sql_statement = af.sql_statement
				FROM #alert_form af
				LEFT JOIN alert_sql ass ON af.alert_id = ass.alert_sql_id 
				WHERE af.alert_id IS NOT NULL AND af.alert_id = @alert_id
			END
			
			IF EXISTS(SELECT 1 FROM #rule_table_grid)
			BEGIN
				IF EXISTS(SELECT 1 FROM alert_rule_table WHERE alert_id = @alert_id)
			BEGIN
				SELECT @root_table_id = alert_rule_table_id FROM alert_rule_table WHERE alert_id = @alert_id
				
				INSERT INTO alert_rule_table(alert_id, root_table_id, table_id, table_alias)
				SELECT @alert_id, @root_table_id, table_id, table_alias 
				FROM #rule_table_grid
				WHERE alert_rule_table_id IS NULL
				
				UPDATE art
					SET art.table_id = rtg.table_id,
						art.table_alias = rtg.table_alias 
				FROM #rule_table_grid rtg
				LEFT JOIN alert_rule_table art ON art.alert_rule_table_id = rtg.alert_rule_table_id
				WHERE rtg.alert_rule_table_id IS NOT NULL
			END
			ELSE
			BEGIN
				INSERT INTO alert_rule_table(alert_id, table_id, table_alias)
				SELECT TOP 1 @alert_id, table_id, table_alias
				FROM #rule_table_grid

				SET @root_table_id = SCOPE_IDENTITY()

				DELETE TOP (1)
				FROM #rule_table_grid

				INSERT INTO alert_rule_table(alert_id, root_table_id, table_id, table_alias)
				SELECT @alert_id, @root_table_id, table_id, table_alias
					FROM #rule_table_grid
				END
			END
			
			--Grid
			DELETE art
			FROM #rule_table_grid_delete rtgd
			LEFT JOIN alert_rule_table art ON art.alert_rule_table_id = rtgd.alert_rule_table_id
			WHERE rtgd.alert_rule_table_id IS NOT NULL
				AND rtgd.alert_id IS NOT NULL

			EXEC spa_ErrorHandler 0
					, 'alert_rule_table'
					, 'spa_setup_rule_workflow'
					, 'Success' 
					, 'Changes have been saved successfully.'
					, @alert_id

			COMMIT TRAN
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			   ROLLBACK TRAN
	 
			SET @desc = dbo.FNAHandleDBError(10122500)
	 
			EXEC spa_ErrorHandler -1
			   , 'alert_rule_table'
			   , 'spa_setup_rule_workflow'
			   , 'Error'
			   , @desc
			   , ''
		END CATCH
	END

	ELSE IF @flag = 'g'
	BEGIN
		SELECT	sdv.code [document1],
				sdv1.code [document2], 
				wb.message_document_id [message_document_id], 
				wb.document_template_id [document_type],
				dbo.FNADateFormat(wb.effective_date) [effective_date],
				wb.document_category [document_category],
				wa.message_detail_id [id], 
				wa.counterparty_contact_type [contact_type],
				wa.delivery_method [delivery_method],
				CASE WHEN wa.as_defined_in_contact = 'y' THEN 'true' ELSE 'false' END [as_defined_in_contact],
				wa.message [message], 
				dbo.FNAEmailHyperlink(wa.email) [email],
				dbo.FNAEmailHyperlink(wa.email_cc) [email_cc],
				dbo.FNAEmailHyperlink(wa.email_bcc) [email_bcc],
				wa.internal_contact_type [internal_contact_type],
				wb.document_template [document_template],
				wa.[subject] [subject],
				IIF(tbl.email_group IS NULL OR tbl.email_group = '',tbl.email_group,left(tbl.email_group, len(tbl.email_group) - 1)) email_group,
				IIF(tbl1.email_group_cc IS NULL OR tbl1.email_group_cc = '',tbl1.email_group_cc,left(tbl1.email_group_cc, len(tbl1.email_group_cc) - 1)) email_group_cc,
				IIF(tbl2.email_group_bcc IS NULL OR tbl2.email_group_bcc = '',tbl2.email_group_bcc,left(tbl2.email_group_bcc, len(tbl2.email_group_bcc) - 1)) email_group_bcc,
				wa.message_template_id [message_template_id],
				ISNULL(wb.use_generated_document, 'n') [use_generated_document]
		FROM workflow_event_message_documents wb
		LEFT JOIN workflow_event_message_details wa ON wb.message_document_id = wa.event_message_document_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = wb.document_template_id
		LEFT JOIN static_data_value sdv1 ON sdv1.value_id = wb.document_category
		OUTER APPLY(
				SELECT COALESCE('1_' + CAST(workflow_contacts_id AS NVARCHAR(10)),'2_' + CAST(query_value AS NVARCHAR(10))) + ';'
				FROM workflow_event_message_email
				WHERE message_detail_id = wa.message_detail_id
				AND group_type = 'e'
				FOR XML PATH('')
			) tbl (email_group) 
		OUTER APPLY(
				SELECT COALESCE('1_' + CAST(workflow_contacts_id AS NVARCHAR(10)),'2_' + CAST(query_value AS NVARCHAR(10))) + ';'
				FROM workflow_event_message_email
				WHERE message_detail_id = wa.message_detail_id
				AND group_type = 'c'
				FOR XML PATH('')
			) tbl1 (email_group_cc)
		OUTER APPLY(
				SELECT COALESCE('1_' + CAST(workflow_contacts_id AS NVARCHAR(10)),'2_' + CAST(query_value AS NVARCHAR(10))) + ';'
				FROM workflow_event_message_email
				WHERE message_detail_id = wa.message_detail_id
				AND group_type = 'b'
				FOR XML PATH('')
			) tbl2 (email_group_bcc)
		WHERE wb.event_message_id = @message_id
	END

	ELSE IF @flag = 'h'
	BEGIN
		BEGIN TRY
			INSERT INTO workflow_event_message_documents(event_message_id, document_template_id, effective_date, document_category)
			SELECT @message_id, @document_template_id, @effective_date, @document_category

			EXEC spa_ErrorHandler 0
						, 'workflow_event_message_documents'
						, 'spa_setup_rule_workflow'
						, 'Success' 
						, 'Changes have been saved successfully.'
						, ''
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			   ROLLBACK
	 
			SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
			SELECT @err_no = ERROR_NUMBER()
	 
			EXEC spa_ErrorHandler @err_no
			   , 'workflow_event_message_documents'
			   , 'spa_setup_rule_workflow'
			   , 'Error'
			   , @desc
			   , ''
		END CATCH
	END

	ELSE IF @flag = 'j'
	BEGIN
		BEGIN TRY
			IF OBJECT_ID('tempdb..#tmp_document_contact') IS NOT NULL
				DROP TABLE #tmp_document_contact
		
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

			SELECT * INTO #tmp_document_contact 
		
			FROM OPENXML(@idoc, '/Root/FormData', 1)
			WITH (
				message_document_id	INT,
				event_message_id	INT,
				document_type		INT,
				effective_date		NVARCHAR(100),
				document_category	INT,
				document_template	INT,
				id					INT,
				contact_type		INT,
				delivery_method		INT,
				as_defined_in_contact	NCHAR(1),
				[message]			NVARCHAR(1000),
				email				NVARCHAR(300),
				email_cc			NVARCHAR(300),
				email_bcc			NVARCHAR(300),
				internal_contact_type	INT,
				[subject]			NVARCHAR(1000),
				message_template_id   INT,
				use_generated_document NCHAR(1)
			)

			SELECT * INTO #tmp_document_contact_email
		
			FROM OPENXML(@idoc, '/Root/EmailData/GridRow', 1)
			WITH (
				group_type	NCHAR(1),
				workflow_contacts_id		INT,
				query_value		NVARCHAR(100)
			)
		
			DECLARE @new_message_document_id INT
			IF EXISTS (SELECT 1 FROM #tmp_document_contact WHERE message_document_id = 0)
			BEGIN
				INSERT INTO workflow_event_message_documents(event_message_id, document_template_id, effective_date, document_category, document_template, use_generated_document)
				SELECT event_message_id, document_type, effective_date, document_category, NULLIF(document_template,0), use_generated_document
				FROM #tmp_document_contact

				SET @new_message_document_id = SCOPE_IDENTITY()
			END
			ELSE
			BEGIN
				UPDATE wemd
					SET wemd.document_template_id = tmp.document_type,
						wemd.effective_date =  tmp.effective_date,
						wemd.document_category = tmp.document_category,
						wemd.document_template = tmp.document_template,
						wemd.use_generated_document = tmp.use_generated_document
				FROM workflow_event_message_documents wemd
				INNER JOIN #tmp_document_contact tmp ON tmp.message_document_id = wemd.message_document_id

				SELECT @new_message_document_id = message_document_id FROM #tmp_document_contact
			END

			IF EXISTS(SELECT 1 FROM #tmp_document_contact WHERE id = 0)
			BEGIN
				INSERT INTO workflow_event_message_details (event_message_document_id, message, counterparty_contact_type, delivery_method, email, email_cc, email_bcc, internal_contact_type, as_defined_in_contact,[subject],message_template_id)
				SELECT @new_message_document_id, message, NULLIF(contact_type,''), NULLIF(delivery_method,''), email, email_cc, email_bcc, internal_contact_type, as_defined_in_contact, [subject],NULLIF(message_template_id,0)
				FROM #tmp_document_contact 
				WHERE id = 0
				SELECT @message_detail_id = SCOPE_IDENTITY()
			END
			ELSE
			BEGIN
				UPDATE w
				SET w.event_message_document_id = @new_message_document_id,
					w.message = tdc.message,
					w.counterparty_contact_type = NULLIF(tdc.contact_type,''),
					w.delivery_method = NULLIF(tdc.delivery_method,''),
					w.email = tdc.email,
					w.email_cc = tdc.email_cc,
					w.email_bcc = tdc.email_bcc,
					w.internal_contact_type = tdc.internal_contact_type,
					w.as_defined_in_contact = tdc.as_defined_in_contact,
					w.[subject] = tdc.[subject],
					w.message_template_id = NULLIF(tdc.message_template_id,0)
				FROM workflow_event_message_details w
				INNER JOIN #tmp_document_contact tdc ON tdc.id = w.message_detail_id

				SELECT @message_detail_id = id
				FROM #tmp_document_contact
			END

			DELETE FROM workflow_event_message_email
			WHERE message_detail_id = @message_detail_id

			INSERT INTO workflow_event_message_email(message_detail_id,group_type,workflow_contacts_id,query_value)
			SELECT @message_detail_id,group_type,workflow_contacts_id,query_value
			FROM #tmp_document_contact_email

		EXEC spa_ErrorHandler 0
						, 'workflow_event_message_documents'
						, 'spa_setup_rule_workflow'
						, 'Success' 
						, 'Changes have been saved successfully.'
						, ''
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			   ROLLBACK
	 
			SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
			SELECT @err_no = ERROR_NUMBER()
	 
			EXEC spa_ErrorHandler @err_no
			   , 'workflow_event_message_documents'
			   , 'spa_setup_rule_workflow'
			   , 'Error'
			   , @desc
			   , ''
		END CATCH
	END

	ELSE IF @flag = 'k'
	BEGIN
		BEGIN TRY
			IF @message_detail_id IS NOT NULL
			BEGIN
				DELETE FROM workflow_event_message_details
				WHERE message_detail_id = @message_detail_id
			END
			ELSE
			BEGIN
				DELETE w1 FROM workflow_event_message_documents w
				INNER JOIN workflow_event_message_details w1 ON w.message_document_id = w1.event_message_document_id
				WHERE w.document_template_id = @document_template_id AND w.event_message_id = @message_id

				DELETE w FROM workflow_event_message_documents w
				WHERE w.document_template_id = @document_template_id AND w.event_message_id = @message_id 
			END
			EXEC spa_ErrorHandler 0
						, 'workflow_event_message_documents'
						, 'spa_setup_rule_workflow'
						, 'Success' 
						, 'Changes have been saved successfully.'
						, ''
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			   ROLLBACK
	 
			SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
			SELECT @err_no = ERROR_NUMBER()
	 
			EXEC spa_ErrorHandler @err_no
			   , 'workflow_event_message_documents'
			   , 'spa_setup_rule_workflow'
			   , 'Error'
			   , @desc
			   , ''
		END CATCH
	END

	ELSE IF @flag = 'o'
	BEGIN
		SELECT * FROM (
			SELECT	workflow_where_clause_id,
					data_source_column_id,
					operator_id,
					column_value,
					clause_type,
					second_value,
					sequence_no
			 FROM workflow_where_clause
			 WHERE module_events_id = @module_id
			 UNION ALL 
			 SELECT	workflow_where_clause_id,
					data_source_column_id,
					operator_id,
					column_value,
					clause_type,
					second_value,
					sequence_no
			 FROM workflow_where_clause
			 WHERE workflow_schedule_task_id = @workflow_id) a
		 ORDER BY sequence_no
		 
	END

	ELSE IF @flag = 'i'
	BEGIN
		SELECT	workflow_link_id,
				[description],
				modules_event_id
		FROM workflow_link
		WHERE workflow_schedule_task_id = @workflow_id
	END

	ELSE IF @flag = '1'
	BEGIN
		SELECT	workflow_Link_where_clause_id,
				data_source_column_id,
				operator_id,
				column_value,
				clause_type,
				second_value,
				sequence_no,
				w.workflow_link_id
		FROM workflow_link_where_clause w
		INNER JOIN workflow_link wl ON w.workflow_Link_id = wl.workflow_link_id
		WHERE workflow_schedule_task_id = @workflow_id
		
	END

	ELSE IF @flag = 'l'
	BEGIN
		BEGIN TRY
			DELETE wa
			FROM 
			workflow_activities wa
			INNER JOIN workflow_event_message wem ON wa.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
				ON tbl.item = et.alert_id

			DELETE weur
			FROM
			workflow_event_user_role weur
			INNER JOIN workflow_event_message wem ON weur.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
				ON tbl.item = et.alert_id

			DELETE ar
			FROM 
			workflow_event_message wem 
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			INNER JOIN alert_reports ar 
				ON ar.event_message_id = wem.event_message_id
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
				ON tbl.item = et.alert_id
					
			DELETE weme 
			FROM workflow_event_message_email weme
			INNER JOIN workflow_event_message_details wemd
				ON wemd.message_detail_id = weme.message_detail_id
			INNER JOIN workflow_event_message_documents wemds
				ON wemds.message_document_id = wemd.event_message_document_id
			INNER JOIN workflow_event_message wem ON wemds.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON et.event_trigger_id = wem.event_trigger_id
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
				ON tbl.item = et.alert_id

			DELETE wemd 
			FROM workflow_event_message_details wemd
			INNER JOIN workflow_event_message_documents wemds
				ON wemds.message_document_id = wemd.event_message_document_id
			INNER JOIN workflow_event_message wem ON wemds.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON et.event_trigger_id = wem.event_trigger_id
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
				ON tbl.item = et.alert_id

			DELETE wemd 
			FROM workflow_event_message_documents wemd
			INNER JOIN workflow_event_message wem ON wemd.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON et.event_trigger_id = wem.event_trigger_id
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
				ON tbl.item = et.alert_id

			DELETE weur FROM workflow_event_user_role weur
			INNER JOIN workflow_event_message wem ON weur.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON et.event_trigger_id = wem.event_trigger_id
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
				ON tbl.item = et.alert_id

			DELETE wwc FROM	workflow_where_clause wwc
			INNER JOIN workflow_schedule_task wst ON wwc.workflow_schedule_task_id = wst.id
			INNER JOIN module_events me ON wst.workflow_id = me.module_events_id
			INNER JOIN event_trigger et ON et.modules_event_id = me.module_events_id 
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
				ON tbl.item = et.alert_id
			WHERE wst.workflow_id_type = 1

			DELETE  wst 
			FROM workflow_schedule_task wst 
			INNER JOIN module_events me ON wst.workflow_id = me.module_events_id
			INNER JOIN event_trigger et ON et.modules_event_id = me.module_events_id 
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
				ON tbl.item = et.alert_id
			WHERE wst.workflow_id_type = 1

			IF EXISTS(SELECT alert_category FROM alert_sql asql INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl ON tbl.item = asql.alert_sql_id WHERE alert_category = 'w')
			BEGIN
				SELECT @module_event_id = STUFF((
					SELECT ', ' + CAST(et.modules_event_id AS NVARCHAR(MAX))
					FROM module_events me
					INNER JOIN event_trigger et ON me.module_events_id = et.modules_event_id
					INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
						ON tbl.item = et.alert_id
					FOR XML PATH('')
				), 1, 2, '');			
			END

			DELETE wea 
			FROM workflow_event_action wea
			INNER JOIN event_trigger et ON et.event_trigger_id = wea.alert_id
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
					ON tbl.item = et.alert_id

			DELETE wem
			FROM 
				workflow_event_message wem 
				INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
				INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
					ON tbl.item = et.alert_id

			DELETE waa
			FROM workflow_activities_audit waa
			INNER JOIN event_trigger et ON et.event_trigger_id = waa.workflow_trigger_id
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
					ON tbl.item = et.alert_id

			DELETE et
			FROM event_trigger et
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
					ON tbl.item = et.alert_id
			

			IF @module_event_id IS NOT NULL
			BEGIN
				DELETE FROM module_events WHERE module_events_id IN(@module_event_id)			
			END



			DELETE atwc 
			FROM alert_table_where_clause atwc
			INNER JOIN alert_conditions ac ON atwc.condition_id = ac.alert_conditions_id
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
					ON tbl.item = ac.rules_id

			DELETE aa 
			FROM alert_actions aa
			INNER JOIN alert_conditions ac ON aa.condition_id = ac.alert_conditions_id
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
					ON tbl.item = ac.rules_id

			DELETE ac
			FROM alert_conditions ac
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
					ON tbl.item = ac.rules_id

			DELETE art
			FROM alert_rule_table art
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
					ON tbl.item = art.alert_id

			DELETE as1
			FROM alert_sql as1
			INNER JOIN dbo.FNASplit(@alert_rule_id,',') tbl
					ON tbl.item = as1.alert_sql_id

			EXEC spa_ErrorHandler 0,
				 'Setup Alert',
				 'spa_setup_rule_workflow',
				 'Success',
				 'Changes have been saved successfully.',
				 ''
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			   ROLLBACK
		   
			EXEC spa_ErrorHandler -1,
				 'Setup Alert',
				 'spa_setup_rule_workflow',
				 'DB Error',
				 'Failed to save data.',
				 ''
		END CATCH
	END
	ELSE IF @flag = 's'
	BEGIN
		SELECT DISTINCT me1.module_events_id, me1.workflow_name
		FROM workflow_event_message wem
		INNER JOIN event_trigger et ON et.event_trigger_id = wem.event_trigger_id
		INNER JOIN module_events me ON et.modules_event_id = me.module_events_id
		INNER JOIN workflow_schedule_task wst ON wst.workflow_id = me.module_events_id AND wst.workflow_id_type = 1
		INNER JOIN workflow_schedule_task wst1 ON wst.parent = wst1.parent AND ISNULL(wst1.system_defined,0) <> 2
		INNER JOIN module_events me1 ON wst1.workflow_id = me1.module_events_id
		WHERE wem.event_message_id = @message_id
		UNION ALL 
		SELECT '-1','Workflow Links'
	END

	-- For module dropdown in workflow/alert
	ELSE IF @flag = '2'
	BEGIN
		SELECT DISTINCT wmem.module_id [value_id], sdv.code FROM workflow_module_event_mapping wmem
		INNER JOIN static_data_value sdv ON wmem.module_id = sdv.value_id
		WHERE wmem.is_active = 1
		UNION ALL 
		SELECT DISTINCT module_id, 'UDT - ' + udt_name [code]
		FROM 
		workflow_module_event_mapping mp
		INNER JOIN user_defined_tables udt ON ABS(mp.module_id) = udt_id
		WHERE mp.module_id < -1 AND mp.is_active = 1
		ORDER BY sdv.code
	END

	-- For event dropdown in workflow/alert
	ELSE IF @flag = '3'
	BEGIN
		SET @sql = 'SELECT DISTINCT wmem.event_id [value_id], sdv.code FROM workflow_module_event_mapping wmem
					INNER JOIN static_data_value sdv ON wmem.event_id = sdv.value_id
					WHERE wmem.is_active = 1 AND (module_id = ' + CAST(@module_id AS NVARCHAR(10)) + ' OR module_id = -1)
		'
		+ CASE WHEN ISNULL(@call_from,-1) = 'simple_alert' THEN ' AND wmem.event_id NOT IN (20538,20548)' ELSE '' END
		+ ' ORDER BY sdv.code'
		EXEC(@sql)

		
	END

	-- FOR Rule Table dropdown in workflow/alert
	ELSE IF @flag = '4'
	BEGIN
		SELECT DISTINCT atd.alert_table_definition_id, atd.logical_table_name 
		FROM workflow_module_rule_table_mapping wwrtm
		INNER JOIN alert_table_definition atd ON wwrtm.rule_table_id = atd.alert_table_definition_id
		WHERE wwrtm.is_active = 1 AND is_action_view = 'y' AND (CASE WHEN @module_id IS NULL THEN '' ELSE wwrtm.module_id END = ISNULL(@module_id,'') OR module_id = -1)
	END

	-- For module dropdown in workflow/alert
	ELSE IF @flag = '5'
	BEGIN
		SELECT * FROM (
			SELECT DISTINCT wmem.module_id [value_id], sdv.code FROM workflow_module_event_mapping wmem
			INNER JOIN static_data_value sdv ON wmem.module_id = sdv.value_id
			WHERE wmem.is_active = 1 
			UNION ALL
			SELECT -1, 'General'
			UNION ALL 
			SELECT DISTINCT module_id, 'UDT - ' + udt_name [code]
			FROM 
			workflow_module_event_mapping mp
			INNER JOIN user_defined_tables udt ON ABS(mp.module_id) = udt_id
			WHERE mp.module_id < -1 AND mp.is_active = 1
			
		) a WHERE ISNULL(@module_id,a.[value_id]) = a.value_id
		ORDER BY a.code
	END
	
	ELSE IF @flag = '6'
	BEGIN
		SELECT DISTINCT atd.alert_table_definition_id, atd.logical_table_name 
		FROM workflow_module_rule_table_mapping wwrtm
		INNER JOIN alert_table_definition atd 
			ON wwrtm.rule_table_id = atd.alert_table_definition_id
		WHERE wwrtm.is_active = 1 
		AND is_action_view = 'n' 
		AND (CASE WHEN @module_id IS NULL THEN '' ELSE wwrtm.module_id END = ISNULL(IIF(@module_id = 20610,wwrtm.module_id,@module_id),'') OR module_id = -1)
	END

	ELSE IF @flag = '7'
	BEGIN
		DECLARE @n_module_id INT = -1
		IF NULLIF(@module_id,'') IS NOT NULL
		BEGIN
			SET @n_module_id = @module_id
		END
		ELSE
		BEGIN
			SELECT @n_module_id = me.modules_id FROM workflow_schedule_task wst
			INNER JOIN event_trigger et ON et.event_trigger_id = wst.workflow_id
			INNER JOIN module_events me ON me.module_events_id = et.modules_event_id
			WHERE id = @workflow_id
		END
		
		IF OBJECT_ID('tempdb..#temp_links') IS NOT NULL
			DROP TABLE #temp_links

		SELECT 'tag_' + CAST(workflow_message_tag_id AS NVARCHAR) [id], workflow_message_tag_name [name], IIF(is_hyperlink = 1,REPLACE(workflow_message_tag,'<','<#') + workflow_message_tag + REPLACE(workflow_message_tag,'>','#>'),workflow_message_tag) [hyperlink_tags] 
		INTO  #temp_links
		FROM workflow_message_tag w
		WHERE module_id = @n_module_id
		UNION
		SELECT 'tag_-11', 'Alert Report','<#ALERT_REPORT>'

		SELECT '{"message": [' + STUFF((
			SELECT ',' + '{"id": "' + [id] + '", "text": "' + [name] + '", "icon": null, "tag_structure": "' + [hyperlink_tags] + '"}' 
			FROM #temp_links
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') + ']}'
		AS [tag_options]
	END

	ELSE IF @flag = '8'
	BEGIN
		SELECT sdv.value_id [document_type] FROM workflow_event_message wem
		INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
		INNER JOIN module_events me ON me.module_events_id = et.modules_event_id
		LEFT JOIN static_data_value sdv ON sdv.category_id = me.modules_id
		WHERE wem.event_message_id = @message_id
	END
	ELSE IF @flag = '9'
	BEGIN
		SET @sql = 'SELECT ''n'' [value] , ''SQL Report'' [code] UNION
					SELECT ''y'' [value] , ''Report Manager Report'''
		+ CASE WHEN @call_from != 'workflow' OR @call_from IS NULL 
			THEN ' UNION SELECT ''a'' [value] , ''Data View Report''' ELSE ''
		  END
		EXEC(@sql)
	END
	ELSE IF @flag = '10'
	BEGIN
		SELECT 'f' [value], 'Report As File Attachment' [code] UNION ALL
		SELECT 'r' [value], 'Report' [code] UNION ALL
		SELECT 'b' [value], 'Both' [code]
	END
	ELSE IF @flag = 'email_group'
	BEGIN
		SELECT @module_id = me.modules_id FROM workflow_event_message wem
		INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
		INNER JOIN module_events me ON me.module_events_id = et.modules_event_id
		WHERE wem.event_message_id = @message_id

		IF OBJECT_ID('tempdb..#workflow_email_group') IS NOT NULL
				DROP TABLE #workflow_email_group
		CREATE TABLE #workflow_email_group(
			[value] NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
			code NVARCHAR(1000) COLLATE DATABASE_DEFAULT
		)
		DECLARE @email_group_query NVARCHAR(1000)
		SELECT @email_group_query = email_group_query 
		FROM workflow_contacts
		WHERE module_id = @module_id
		AND NULLIF(email_group,'') IS NULL
		AND group_type = @group_type

		INSERT INTO #workflow_email_group
		EXEC(@email_group_query)

		SELECT '1_' + CAST(workflow_contacts_id AS NVARCHAR(10)),email_group
		FROM workflow_contacts
		WHERE module_id = @module_id
		AND group_type = @group_type
		AND NULLIF(email_group,'') IS NOT NULL
		UNION
		SELECT '2_' + CAST([value] AS NVARCHAR(10)),code FROM #workflow_email_group
		ORDER BY email_group
	END
	ELSE IF @flag = '11'
	BEGIN
		BEGIN TRY
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

			IF OBJECT_ID('tempdb..#workflow_update_comment') IS NOT NULL
				DROP TABLE #workflow_update_comment
		
			SELECT workflow_activity_id	[workflow_activity_id],
					comment	[comment]
			INTO #workflow_update_comment
			FROM OPENXML(@idoc, '/Root/FormXML', 1)
			WITH (
				workflow_activity_id		NVARCHAR(20),
				comment						NVARCHAR(500)
			)

			SELECT @activity_id = workflow_activity_id, @comments = comment FROM #workflow_update_comment

			UPDATE wa SET wa.comments = @comments FROM workflow_activities wa INNER JOIN 
			dbo.SplitCommaSeperatedValues(@activity_id) scsv ON wa.workflow_activity_id = scsv.item
			
			EXEC spa_ErrorHandler 0,
				 'Setup Alert',
				 'spa_setup_rule_workflow',
				 'Success',
				 'Changes have been saved successfully.',
				 ''
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler -1,
				 'Setup Alert',
				 'spa_setup_rule_workflow',
				 'Success',
				 'Changes have been saved successfully.',
				 ''
		END CATCH
	END
	ELSE IF @flag = '12'
	BEGIN
		SELECT @is_comment_required = comment_required FROM workflow_activities wa INNER JOIN workflow_event_message wem ON wa.event_message_id = wem.event_message_id
		WHERE workflow_activity_id = @activity_id

		SELECT @is_comment_required [is_comment_required]
	END
	ELSE IF @flag = 'tag'
	BEGIN
		SELECT workflow_message_tag FROM  workflow_message_tag WHERE module_id = @module_id
	END