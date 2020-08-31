SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[workflow_link]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[workflow_link]
    (
    	[workflow_link_id]			INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[workflow_schedule_task_id] INT NULL,
    	[modules_event_id]			INT NULL,
    	[description]				VARCHAR(500) NULL,
    	[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]					DATETIME NULL DEFAULT GETDATE(),
    	[update_user]				VARCHAR(50) NULL,
    	[update_ts]					DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table workflow_link EXISTS'
END
 
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_workflow_schedule_task_workflow_link]')
				 AND parent_object_id = OBJECT_ID(N'[dbo].[workflow_link]'))
BEGIN
	ALTER TABLE [dbo].[workflow_link] ADD CONSTRAINT [FK_workflow_schedule_task_workflow_link] 
	FOREIGN KEY([workflow_schedule_task_id])
	REFERENCES [dbo].[workflow_schedule_task] ([id])
END

GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_module_events_workflow_link]')
				 AND parent_object_id = OBJECT_ID(N'[dbo].[workflow_link]'))
BEGIN
	ALTER TABLE [dbo].[workflow_link] ADD CONSTRAINT [FK_module_events_workflow_link] 
	FOREIGN KEY([modules_event_id])
	REFERENCES [dbo].[module_events] ([module_events_id])
END

GO
