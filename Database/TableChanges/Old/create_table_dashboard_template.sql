SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
 
IF OBJECT_ID(N'[dbo].[dashboard_template]', N'U') IS NULL
BEGIN
    CREATE TABLE [dashboard_template]
    (
		[dashboard_template_id]		INT IDENTITY(1,1) PRIMARY KEY NOT NULL ,
		[dashboard_template_name]	NVARCHAR(100) NOT NULL,
		[dashboard_template_desc]	NVARCHAR(100) NOT NULL,
		[dashboard_template_owner]	NVARCHAR(100) NOT NULL,
		[system_defined]			NCHAR(1) NOT NULL,
		[create_user]				NVARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]					DATETIME NULL DEFAULT GETDATE(),
		[update_user]				NVARCHAR(50) NULL,
		[update_ts]					DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table dashboard_template EXISTS'
END
GO

--Update Trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_dashboard_template]'))
    DROP TRIGGER [dbo].[TRGUPD_dashboard_template]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_dashboard_template]
ON [dbo].[dashboard_template]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE dashboard_template
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM dashboard_template dt
        INNER JOIN DELETED d ON d.dashboard_template_id = dt.dashboard_template_id
    END
END
GO



