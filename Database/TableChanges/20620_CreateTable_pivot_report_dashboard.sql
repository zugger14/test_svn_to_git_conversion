SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[pivot_report_dashboard]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[pivot_report_dashboard](
    	[pivot_report_dashboard_id]     INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[user_name]                     VARCHAR(50) REFERENCES application_users(user_login_id) NOT NULL,
    	[dashboard_name]                VARCHAR(100) NULL,
    	[layout_format]                 VARCHAR(10) NOT NULL,
    	[create_user]                   VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                     DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                   VARCHAR(50) NULL,
    	[update_ts]                     DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table pivot_report_dashboard EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_pivot_report_dashboard]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_pivot_report_dashboard]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_pivot_report_dashboard]
ON [dbo].[pivot_report_dashboard]
FOR UPDATE
AS
    UPDATE pivot_report_dashboard
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM pivot_report_dashboard t
      INNER JOIN DELETED u ON t.[pivot_report_dashboard_id] = u.[pivot_report_dashboard_id]
GO