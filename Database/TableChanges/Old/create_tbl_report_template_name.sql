SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[report_template_name]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[report_template_name]
    (
    	[report_template_name_id]  INT PRIMARY KEY IDENTITY(1, 1) NOT NULL,
    	[user_login_id]            VARCHAR(50),
    	[report_name]              VARCHAR(100),
    	[ispublic]                 CHAR(1),
    	[create_user]              VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                DATETIME NULL DEFAULT GETDATE(),
    	[update_user]              VARCHAR(50) NULL,
    	[update_ts]                DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table report_template_name EXISTS'
END
 
GO

