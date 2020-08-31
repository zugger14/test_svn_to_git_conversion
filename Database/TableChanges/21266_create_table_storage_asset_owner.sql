IF OBJECT_ID('dbo.storage_asset_owner') IS NULL
BEGIN
	CREATE TABLE dbo.storage_asset_owner
	(
		storage_asset_owner_id		INT IDENTITY(1,1) PRIMARY KEY,
		storage_asset_id			INT REFERENCES  dbo.storage_asset(storage_asset_id),
		effective_date				DATE,
		counterparty_id				INT,
		[percentage]				FLOAT,
		[create_user]				VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]					DATETIME DEFAULT GETDATE(),
		[update_user]				VARCHAR(100) NULL,
		[update_ts]					DATETIME NULL
	 )
END
ELSE
	PRINT 'Table storage_asset_owner already Exists.'