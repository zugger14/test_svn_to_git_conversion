IF COL_LENGTH(N'storage_ratchet', 'inventory_level_from') IS NULL
BEGIN
	ALTER TABLE storage_ratchet 
		ADD inventory_level_from FLOAT NULL
	
END
ELSE 
	PRINT 'Columns inventory_level_from already exists.'
	
	
IF COL_LENGTH(N'storage_ratchet', 'inventory_level_to') IS NULL
BEGIN
	ALTER TABLE storage_ratchet 
		ADD inventory_level_to FLOAT NULL
	
END
ELSE 
	PRINT 'Columns inventory_level_to already exists.'	 