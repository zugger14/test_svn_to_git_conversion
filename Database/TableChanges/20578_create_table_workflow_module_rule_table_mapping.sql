SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[workflow_module_rule_table_mapping]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].workflow_module_rule_table_mapping (
		mapping_id		INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		module_id		INT,
		rule_table_id	INT,
		is_active		INT NULL,
		[create_user]	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]		DATETIME NULL DEFAULT GETDATE(),
		[update_user]	VARCHAR(50) NULL,
		[update_ts]		DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].workflow_module_rule_table_mapping EXISTS'
END

GO

IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_rule_table_id_workflow_module_rule_table_mapping]')
				 AND parent_object_id = OBJECT_ID(N'[dbo].[module_events]'))
BEGIN
	ALTER TABLE [module_events] DROP CONSTRAINT "FK_rule_table_id_workflow_module_rule_table_mapping"
END				
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_rule_table_id_workflow_module_rule_table_mapping]')
				 AND parent_object_id = OBJECT_ID(N'[dbo].[workflow_module_rule_table_mapping]'))
BEGIN
	ALTER TABLE [dbo].[workflow_module_rule_table_mapping] ADD CONSTRAINT [FK_rule_table_id_workflow_module_rule_table_mapping] 
	FOREIGN KEY([rule_table_id])
	REFERENCES [dbo].[alert_table_definition] ([alert_table_definition_id])
END
GO

IF OBJECT_ID('[dbo].[TRGUPD_workflow_module_rule_table_mapping]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_workflow_module_rule_table_mapping]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_workflow_module_rule_table_mapping]
ON [dbo].[workflow_module_rule_table_mapping]
FOR UPDATE
AS
    UPDATE workflow_module_rule_table_mapping
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM workflow_module_rule_table_mapping t
      INNER JOIN DELETED u ON t.mapping_id = u.mapping_id
GO