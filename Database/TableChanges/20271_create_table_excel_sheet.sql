IF OBJECT_ID('[dbo].[excel_sheet]') IS NULL
BEGIN
    CREATE TABLE [dbo].[excel_sheet]
    (
    	excel_sheet_id             INT IDENTITY(1, 1) PRIMARY KEY,
    	[excel_file_id]            INT FOREIGN KEY REFERENCES excel_file(excel_file_id),
    	[sheet_name]               VARCHAR(255) NOT NULL,
    	[snapshot]                 BIT DEFAULT 0,
    	[sheet_type]               TINYINT DEFAULT 0,
    	[category_id]              INT,
    	[parameter_sheet_name]     VARCHAR(255),
    	[alias]                    NVARCHAR(512),
    	[description]              NVARCHAR(1024),
    	[maintain_history]         BIT DEFAULT 0,
    	[create_user]              VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                DATETIME NULL DEFAULT GETDATE(),
    	[update_user]              VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[update_ts]                DATETIME NULL DEFAULT GETDATE()
    )
END
ELSE
    PRINT 'excel_sheet Already Exists'
	