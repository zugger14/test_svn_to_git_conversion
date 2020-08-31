IF OBJECT_ID('[dbo].[excel_file]') IS NULL
BEGIN
    CREATE TABLE [dbo].[excel_file]
    (
    	excel_file_id     INT IDENTITY(1, 1) PRIMARY KEY,
    	[file_name]       VARCHAR(255) NOT NULL,
    	[create_user]     VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]       DATETIME NULL DEFAULT GETDATE(),
    	[update_user]     VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[update_ts]       DATETIME NULL DEFAULT GETDATE()
    )
END
ELSE
    PRINT 'Excel File Already Exists'
    