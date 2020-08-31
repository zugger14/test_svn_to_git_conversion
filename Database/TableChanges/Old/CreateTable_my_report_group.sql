SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[my_report_group]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[my_report_group] (
    	[my_report_group_id]    INT IDENTITY(1, 1) NOT NULL,
    	[my_report_group_name]  VARCHAR(200) NULL,
    	[report_dashboard_flag]	CHAR(1) NULL,
    	[role_id]				INT NULL,
    	[group_owner]			VARCHAR(200),
    	[group_order]			INT,
    	[create_user]           VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]             DATETIME NULL DEFAULT GETDATE(),
    	[update_user]           VARCHAR(50) NULL,
    	[update_ts]             DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table my_report_group EXISTS'
END
 
GO
