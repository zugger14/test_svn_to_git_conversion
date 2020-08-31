IF OBJECT_ID('[dbo].[excel_sheet_snapshot]') IS NULL
BEGIN
    CREATE TABLE [dbo].[excel_sheet_snapshot]
    (
    	excel_sheet_snapshot INT IDENTITY (1,1) PRIMARY KEY,
    	excel_sheet_id                INT FOREIGN KEY REFERENCES excel_sheet(excel_sheet_id),
    	[snapshot_filename]           NVARCHAR(255),
    	[snapshot_applied_filter]     NVARCHAR(MAX),
    	[snapshot_refreshed_on]       DATETIME NULL DEFAULT GETDATE(),
    	[create_user]                 VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                   DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                 VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[update_ts]                   DATETIME NULL DEFAULT GETDATE()
    )
END
ELSE
    PRINT 'excel_sheet_snapshot Already Exists'

IF COL_LENGTH('excel_sheet_snapshot','excel_sheet_snapshot') IS NOT NULL
	EXEC sp_RENAME 'excel_sheet_snapshot.excel_sheet_snapshot' , 'excel_sheet_snapshot_id', 'COLUMN'
		