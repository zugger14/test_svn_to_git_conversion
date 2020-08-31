 SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
--drop table match_group_header
 
IF OBJECT_ID(N'[dbo].[udf_data_source]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].udf_data_source
    (
		  [udf_data_source_id]  INT IDENTITY(1, 1) NOT NULL
		, [udf_data_source_name]	VARCHAR(50)
		, [sql_string]			VARCHAR(500)
		, [is_hidden]			BIT
		, [create_user]			VARCHAR(50) NULL DEFAULT dbo.FNADBUser()
		, [create_ts]			DATETIME NULL DEFAULT GETDATE()
		, [update_user]			VARCHAR(50) NULL
		, [update_ts]			DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table udf_data_source already EXISTS'
END
GO


