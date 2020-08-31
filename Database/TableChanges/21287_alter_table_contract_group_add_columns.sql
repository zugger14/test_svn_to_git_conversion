IF COL_LENGTH('contract_group','service_type') IS NULL
BEGIN
	ALTER TABLE contract_group 
	ADD service_type CHAR(1)
	PRINT 'Added column ''service_type'''
END
ELSE
PRINT 'column ''service_type'' already exists'


IF COL_LENGTH('contract_group','storage_asset_id') IS NULL
BEGIN
	ALTER TABLE contract_group 
	ADD storage_asset_id INT
	PRINT 'Added column ''storage_asset_id'''
END
ELSE
PRINT 'column ''storage_asset_id'' already exists'