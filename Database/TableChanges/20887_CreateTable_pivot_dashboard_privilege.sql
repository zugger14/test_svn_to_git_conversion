SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[pivot_dashboard_privilege]', N'U') IS NULL
BEGIN
 CREATE TABLE [dbo].[pivot_dashboard_privilege] (
	[pivot_dashboard_privilege_id] INT IDENTITY(1, 1) NOT NULL,
	[dashboard_id]                 INT REFERENCES pivot_report_dashboard([pivot_report_dashboard_id]) NOT NULL,
	[user_login_id]                VARCHAR(50) REFERENCES application_users([user_login_id]),
	[role_id]                      INT REFERENCES application_security_role([role_id]),
	[create_user]                  VARCHAR(50) NULL DEFAULT [dbo].[FNADBUser](),
	[create_ts]                    DATETIME NULL DEFAULT GETDATE(),
	[update_user]                  VARCHAR(50) NULL,
	[update_ts]                    DATETIME NULL
)
END
ELSE
BEGIN
    PRINT 'Table pivot_dashboard_privilege EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_pivot_dashboard_privilege]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_pivot_dashboard_privilege]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_pivot_dashboard_privilege]
ON [dbo].[pivot_dashboard_privilege]
FOR UPDATE
AS
    UPDATE pivot_dashboard_privilege
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM pivot_dashboard_privilege t
      INNER JOIN DELETED u ON t.[pivot_dashboard_privilege_id] = u.[pivot_dashboard_privilege_id]
GO