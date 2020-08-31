SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[report_manager_group]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[report_manager_group]
    (
    	[report_manager_group_id]  INT PRIMARY KEY IDENTITY(1, 1) NOT NULL,
    	[report_template_name_id]  INT FOREIGN KEY REFERENCES report_template_name(report_template_name_id),
    	[group_name]               VARCHAR(5000),
    	[user_login_id]            VARCHAR(50),
    	[tab_group]                INT,
    	[create_user]              VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                DATETIME NULL DEFAULT GETDATE(),
    	[update_user]              VARCHAR(50) NULL,
    	[update_ts]                DATETIME NULL,
    )
END
ELSE
BEGIN
    PRINT 'Table report_manager_group EXISTS'
END

GO
