SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[regression_module_detail]', N'U') IS NULL
BEGIN
	CREATE TABLE regression_module_detail (
		regression_module_detail_id			INT IDENTITY(1, 1) PRIMARY KEY
		, regression_module_header_id		INT REFERENCES [dbo].[regression_module_header] (regression_module_header_id)
		, table_name						VARCHAR(100)
		, unique_columns					VARCHAR(800)
		, compare_columns					VARCHAR(800)
		, display_name						VARCHAR(800)
		, sequence_order					VARCHAR(100)
		, create_user						VARCHAR(200) DEFAULT dbo.FNADBUser()
		, create_ts							DATETIME DEFAULT GETDATE()
		, update_user						VARCHAR(200)
		, update_ts							DATETIME
	)
END
ELSE
BEGIN
    PRINT 'Table regression_module_detail EXISTS'
END
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
--IF OBJECT_ID('[dbo].[TRGUPD_regression_module_detail]', 'TR') IS NOT NULL
--    DROP TRIGGER [dbo].[TRGUPD_regression_module_detail]
--GO
 
--CREATE TRIGGER [dbo].[TRGUPD_regression_module_detail]
--ON [dbo].[regression_module_detail]
--FOR UPDATE
--AS
--    UPDATE [dbo].[regression_module_detail]
--       SET update_user = dbo.FNADBUser(),
--           update_ts = GETDATE()
--    FROM [dbo].[regression_module_detail] t
--    INNER JOIN DELETED u ON t.[regression_module_detail_id] = u.[regression_module_detail_id]
--GO
