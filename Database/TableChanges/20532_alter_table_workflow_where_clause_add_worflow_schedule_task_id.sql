IF COL_LENGTH('workflow_where_clause', 'workflow_schedule_task_id') IS NULL
BEGIN
	ALTER TABLE workflow_where_clause ADD workflow_schedule_task_id INT NULL
END

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_workflow_schedule_task_workflow_where_clause]')
				 AND parent_object_id = OBJECT_ID(N'[dbo].[workflow_where_clause]'))
BEGIN
	ALTER TABLE [dbo].[workflow_where_clause] ADD CONSTRAINT [FK_workflow_schedule_task_workflow_where_clause] 
	FOREIGN KEY([workflow_schedule_task_id])
	REFERENCES [dbo].[workflow_schedule_task] ([id])
END
