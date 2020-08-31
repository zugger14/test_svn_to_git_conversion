SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.[ice_interface_data]', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.[ice_interface_data]
    (	[ID] [INT]				IDENTITY(1, 1) NOT NULL,
    	ice_interface_data_id	INT, 
		data_type				VARCHAR(500), 
		[description]			VARCHAR(500), 
		[import_rule_id]		INT,
    	[create_user]			[VARCHAR](50) NULL DEFAULT dbo.FNAdbuser(),
    	[create_ts]				[DATETIME] NULL DEFAULT GETDATE(),
		[update_user]			VARCHAR(200),
		[update_time]			DATETIME 
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table ice_interface_data EXISTS'
END

Go


--Update Trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ice_interface_data]'))
    DROP TRIGGER [dbo].[TRGUPD_ice_interface_data]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ice_interface_data]
ON [dbo].[ice_interface_data]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE [dbo].[ice_interface_data]
        SET update_user = dbo.FNADBUser(), update_time = GETDATE()
        FROM [dbo].[ice_interface_data] fr
        INNER JOIN DELETED d ON d.id = fr.id
    END
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ixp_rules_import_rule_id]')
				 AND parent_object_id = OBJECT_ID(N'[dbo].[ice_interface_data]'))
BEGIN
	ALTER TABLE [dbo].[ice_interface_data] ADD CONSTRAINT [FK_ixp_rules_import_rule_id] 
	FOREIGN KEY([import_rule_id])
	REFERENCES [dbo].[ixp_rules] ([ixp_rules_id])
END
