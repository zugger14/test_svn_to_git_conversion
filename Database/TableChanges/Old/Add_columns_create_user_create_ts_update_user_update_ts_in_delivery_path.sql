IF COL_LENGTH('delivery_status', 'create_user') IS NULL
BEGIN
	ALTER TABLE delivery_status ADD create_user VARCHAR(50) NULL DEFAULT dbo.FNADBUser()	
END


IF COL_LENGTH('delivery_status', 'create_ts') IS NULL
BEGIN
	ALTER TABLE delivery_status ADD create_ts DATETIME NULL DEFAULT GETDATE()
END

IF COL_LENGTH('delivery_status', 'update_user') IS NULL
BEGIN
	ALTER TABLE delivery_status ADD update_user VARCHAR(50) NULL
END


IF COL_LENGTH('delivery_status', 'update_ts') IS NULL
BEGIN
	ALTER TABLE delivery_status ADD update_ts DATETIME NULL
END