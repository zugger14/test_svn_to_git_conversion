SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[regression_module_header]', N'U') IS NULL
BEGIN
	CREATE TABLE regression_module_header (
		regression_module_header_id INT IDENTITY(1, 1) PRIMARY KEY
		, module_value_id INT NOT NULL
		, module_name VARCHAR(100)
		, [description] VARCHAR(1000)
		, report_paramset_hash VARCHAR(100)
		, create_user VARCHAR(200) DEFAULT dbo.FNADBUser()
		, create_ts DATETIME DEFAULT GETDATE()
		, update_user VARCHAR(200)
		, update_ts DATETIME
	)
END
ELSE
BEGIN
    PRINT 'Table regression_module_header EXISTS'
END
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_regression_module_header]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_regression_module_header]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_regression_module_header]
ON [dbo].[regression_module_header]
FOR UPDATE
AS
    UPDATE [dbo].[regression_module_header]
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM [dbo].[regression_module_header] t
    INNER JOIN DELETED u ON t.[regression_module_header_id] = u.[regression_module_header_id]
GO