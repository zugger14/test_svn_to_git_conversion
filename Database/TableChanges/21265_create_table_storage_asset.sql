IF OBJECT_ID('dbo.storage_asset') IS NULL
BEGIN
	CREATE TABLE dbo.storage_asset
	(
		storage_asset_id		INT IDENTITY(1,1) PRIMARY KEY,
		asset_name				VARCHAR(200),
		asset_description		VARCHAR(200),
		commodity_id			INT,
		location_id				INT,
		effective_date			DATETIME,
		[create_user]			VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]				DATETIME DEFAULT GETDATE(),
		[update_user]			VARCHAR(100) NULL,
		[update_ts]				DATETIME NULL
	 )
END
ELSE
	PRINT 'Table storage_asset already Exists.'