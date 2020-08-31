IF OBJECT_ID('[dbo].[excel_sheet_parameter]') IS NULL
BEGIN
    CREATE TABLE [dbo].[excel_sheet_parameter]
    (
    	excel_sheet_parameter_id     INT IDENTITY(1, 1) PRIMARY KEY,
    	excel_file_id                INT FOREIGN KEY REFERENCES excel_file(excel_file_id),
    	[name]                       VARCHAR(255) NOT NULL,
    	[label]                      VARCHAR(255) NOT NULL,
    	[values]                     NVARCHAR(MAX),
    	[data_type]                  TINYINT,
    	[optional]                   BIT DEFAULT 0,
    	[override_type]              TINYINT,
    	[no_days]                    INT DEFAULT 0,
    	[create_user]                VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                  DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[update_ts]                  DATETIME NULL DEFAULT GETDATE()
    )
END
ELSE
    PRINT 'excel_sheet_parameter Already Exists'
    