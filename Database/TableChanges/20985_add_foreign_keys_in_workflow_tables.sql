-- Start Deleting junk data---
BEGIN TRY
	BEGIN TRAN
	DELETE wsl from workflow_schedule_link wsl LEFT JOIN workflow_schedule_task wsb ON wsl.source = wsb.id WHERE wsb.id IS NULL

	DELETE wsl from workflow_schedule_link wsl LEFT JOIN workflow_schedule_task wsb ON wsl.[target] = wsb.id WHERE wsb.id IS NULL

	DELETE wemd FROM workflow_event_message_details wemd LEFT JOIN workflow_event_message_documents wedoc ON wedoc.message_document_id = wemd.event_message_document_id
	WHERE wedoc.message_document_id IS NULL

	DELETE atr FROM alert_table_relation atr WHERE to_table_id IN (
	SELECT art.alert_rule_table_id FROM alert_rule_table art LEFT JOIN alert_sql aq ON aq.alert_sql_id = art.alert_id
	WHERE aq.alert_sql_id IS NULL
	) 

	DELETE art FROM alert_rule_table art LEFT JOIN alert_sql aq ON aq.alert_sql_id = art.alert_id
	WHERE aq.alert_sql_id IS NULL

	DELETE FROM atwc
	FROM alert_table_where_clause atwc LEFT JOIN alert_rule_table art ON art.alert_rule_table_id = atwc.table_id 
	WHERE art.alert_rule_table_id IS NULL

	-- END Deleting junk data---

	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_module_events_workflow_where_clause]')
					 AND parent_object_id = OBJECT_ID(N'[dbo].[workflow_where_clause]'))
	BEGIN
		ALTER TABLE [dbo].[workflow_where_clause] ADD CONSTRAINT [FK_module_events_workflow_where_clause] 
		FOREIGN KEY([module_events_id])
		REFERENCES [dbo].[module_events] ([module_events_id])
	END

	IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_module_events_workflow_schedule_task]')
					 AND parent_object_id = OBJECT_ID(N'[dbo].[workflow_schedule_task]'))
	BEGIN
		ALTER TABLE [dbo].[workflow_schedule_task] DROP CONSTRAINT [FK_module_events_workflow_schedule_task] 
	END

	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_workflow_schedule_task_workflow_schedule_link_source]')
					 AND parent_object_id = OBJECT_ID(N'[dbo].[workflow_schedule_link]'))
	BEGIN
		ALTER TABLE [dbo].[workflow_schedule_link] ADD CONSTRAINT [FK_workflow_schedule_task_workflow_schedule_link_source] 
		FOREIGN KEY([source])
		REFERENCES [dbo].[workflow_schedule_task] ([id])
	END

	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_workflow_schedule_task_workflow_schedule_link_target]')
					 AND parent_object_id = OBJECT_ID(N'[dbo].[workflow_schedule_link]'))
	BEGIN
		ALTER TABLE [dbo].[workflow_schedule_link] ADD CONSTRAINT [FK_workflow_schedule_task_workflow_schedule_link_target] 
		FOREIGN KEY([target])
		REFERENCES [dbo].[workflow_schedule_task] ([id])
	END

	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_workflow_event_message_documents_workflow_event_message_details]')
					 AND parent_object_id = OBJECT_ID(N'[dbo].[workflow_event_message_details]'))
	BEGIN
		ALTER TABLE [dbo].[workflow_event_message_details] ADD CONSTRAINT [FK_workflow_event_message_documents_workflow_event_message_details] 
		FOREIGN KEY([event_message_document_id])
		REFERENCES [dbo].[workflow_event_message_documents] ([message_document_id])
	END

	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_alert_sql_alert_rule_table]')
					 AND parent_object_id = OBJECT_ID(N'[dbo].[alert_rule_table]'))
	BEGIN
		ALTER TABLE [dbo].[alert_rule_table] ADD CONSTRAINT [FK_alert_sql_alert_rule_table] 
		FOREIGN KEY([alert_id])
		REFERENCES [dbo].[alert_sql] ([alert_sql_id])
	END

	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_alert_rule_table_alert_table_where_clause]')
					 AND parent_object_id = OBJECT_ID(N'[dbo].[alert_table_where_clause]'))
	BEGIN
		ALTER TABLE [dbo].[alert_table_where_clause] ADD CONSTRAINT [FK_alert_rule_table_alert_table_where_clause] 
		FOREIGN KEY([table_id])
		REFERENCES [dbo].[alert_rule_table] ([alert_rule_table_id])
	END

	IF @@TRANCOUNT>0
		COMMIT
	SELECT 'SUCCESS'
END TRY
BEGIN CATCH
	if @@TRANCOUNT>0
		ROLLBACK

	SELECT ERROR_MESSAGE() ERROR

END CATCH

