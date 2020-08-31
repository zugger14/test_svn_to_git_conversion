SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[ixp_import_filter]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[ixp_import_filter]
    (
		ixp_import_filter_id		INT IDENTITY(1, 1)	NOT NULL,
		ixp_rules_id				INT NOT NULL,
		filter_group				VARCHAR(200),
		filter_id					INT,
		filter_value				VARCHAR(MAX),
		ixp_import_data_source		INT,
		create_user					VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),		create_ts					DATETIME DEFAULT GETDATE(),		update_user					VARCHAR(128) NULL,
		update_ts					DATETIME NULL,		CONSTRAINT [PK_ixp_import_filter_idl] PRIMARY KEY CLUSTERED([ixp_import_filter_id] ASC)
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table ixp_import_filter EXISTS'
END
GO



/*
 * Update Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ixp_import_filter]'))
    DROP TRIGGER [dbo].[TRGUPD_ixp_import_filter]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_import_filter]
ON [dbo].[ixp_import_filter]
FOR UPDATE
AS
BEGIN
	DECLARE @update_user  VARCHAR(200)
	DECLARE @update_ts    DATETIME
	
	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.ixp_import_filter
	SET    update_user = @update_user,
	       update_ts = @update_ts
	FROM   dbo.ixp_import_filter sc
	       INNER JOIN DELETED u ON  sc.ixp_import_filter_id = u.ixp_import_filter_id  
END
GO