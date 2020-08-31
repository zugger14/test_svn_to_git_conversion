SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[my_report]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[my_report]
    (
	[my_report_id]			INT IDENTITY(1, 1) NOT NULL,
	[my_report_name]		VARCHAR(200) NULL,
	[dashboard_report_flag] CHAR(1) NOT NULL,
	[paramset_hash]			VARCHAR(200) NULL,
	[dashboard_id]			INT NULL,
	[criteria_flag]			CHAR(1) NULL,
	[criteria]				VARCHAR(5000) NULL,
	[tooltip]				VARCHAR(5000) NULL,
	[my_report_owner]		VARCHAR(100),
	[role_id]				INT NULL,
	[column_order]			INT NULL,
	[create_name]			VARCHAR(100) DEFAULT dbo.FNADBUser(),
	[create_ts]				DATETIME NULL DEFAULT GETDATE(),
	[update_user]			VARCHAR(50) NULL,
	[update_ts]				DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table my_report EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_my_report]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_my_report]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_my_report]
ON [dbo].[my_report]
FOR UPDATE
AS
    UPDATE my_report
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM my_report t
    INNER JOIN DELETED u ON t.my_report_id = u.my_report_id
GO