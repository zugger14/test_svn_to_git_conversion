SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[excel_report_privilege]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].excel_report_privilege
    (
		[excel_report_privilege_id] INT IDENTITY(1, 1) NOT NULL,
		[type_id] INT  NULL,
		[value_id] INT  NULL,
		[user_id] VARCHAR(1000),
		[role_id] INT,
		[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME NULL DEFAULT GETDATE(),
		[update_user] VARCHAR(50) NULL,
		[update_ts] DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table excel_report_privilege EXISTS'
END

GO

