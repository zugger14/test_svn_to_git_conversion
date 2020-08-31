IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'general_assest_info_virtual_storage' AND  COLUMN_NAME = 'storage_asset_id')
BEGIN
	PRINT 'Column storage_asset_id Already exists'
END
ELSE
BEGIN
	ALTER TABLE general_assest_info_virtual_storage ADD storage_asset_id INT
	PRINT 'Column storage_asset_id Added'
END