SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[regression_module_dependencies]', N'U') IS NULL
BEGIN
	CREATE TABLE regression_module_dependencies (
		regression_module_dependencies_id	INT IDENTITY(1, 1) PRIMARY KEY
		, regression_module_header_id		INT REFERENCES [dbo].[regression_module_header] (regression_module_header_id) 
		, [object_name]						VARCHAR(1000)
		, create_user						VARCHAR(200) DEFAULT dbo.FNADBUser()
		, create_ts							DATETIME DEFAULT GETDATE()
		, update_user						VARCHAR(200)
		, update_ts							DATETIME
	)
END
ELSE
BEGIN
    PRINT 'Table regression_module_dependencies EXISTS'
END
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_regression_module_dependencies]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_regression_module_dependencies]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_regression_module_dependencies]
ON [dbo].[regression_module_dependencies]
FOR UPDATE
AS
    UPDATE [dbo].[regression_module_dependencies]
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM [dbo].[regression_module_dependencies] t
    INNER JOIN DELETED u ON t.[regression_module_dependencies_id] = u.[regression_module_dependencies_id]
GO
