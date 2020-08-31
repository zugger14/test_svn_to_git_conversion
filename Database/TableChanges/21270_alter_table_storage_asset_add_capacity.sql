IF COL_LENGTH('storage_asset','capacity') IS NULL
BEGIN
	ALTER TABLE storage_asset
	ADD capacity FLOAT
END