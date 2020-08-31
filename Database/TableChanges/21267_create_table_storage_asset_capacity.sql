IF OBJECT_ID('dbo.storage_asset_capacity') IS NULL
BEGIN
	CREATE TABLE dbo.storage_asset_capacity
	(
		storage_asset_capacity_id	INT IDENTITY(1,1) PRIMARY KEY,
		storage_asset_id			INT REFERENCES  dbo.storage_asset(storage_asset_id),
		effective_date				DATE,
		reservoir					VARCHAR(200),
		reservoir_type				VARCHAR(200),
		capacity					FLOAT,
		uom							INT,
		[create_user]				VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]					DATETIME DEFAULT GETDATE(),
		[update_user]				VARCHAR(100) NULL,
		[update_ts]					DATETIME NULL
	 )
END
ELSE
	PRINT 'Table storage_asset_capacity already Exists.'