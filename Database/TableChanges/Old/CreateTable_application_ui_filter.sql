SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[application_ui_filter]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[application_ui_filter] (
    	[application_ui_filter_id]		INT IDENTITY(1, 1)  PRIMARY KEY NOT NULL,
		[application_group_id]			INT REFERENCES application_ui_template_group(application_group_id) NULL,
    	[report_id]						INT REFERENCES report(report_id) NULL,
    	[user_login_id]					VARCHAR(50) REFERENCES application_users(user_login_id) NOT NULL,
    	[application_ui_filter_name]	VARCHAR(50) NOT NULL,
    	[create_user]					VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]						DATETIME NULL DEFAULT GETDATE(),
    	[update_user]					VARCHAR(50) NULL,
    	[update_ts]						DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table application_ui_filter EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_application_ui_filter]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_application_ui_filter]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_application_ui_filter]
ON [dbo].[application_ui_filter]
FOR UPDATE
AS
    UPDATE t
    SET    update_user     = dbo.FNADBUser(),
           update_ts       = GETDATE()
    FROM   application_ui_filter t
    INNER JOIN DELETED u ON  t.[application_ui_filter_id] = u.[application_ui_filter_id]
GO