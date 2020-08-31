
IF COL_LENGTH('inventory_account_type', 'location_id') IS  NULL
	ALTER TABLE inventory_account_type ADD location_id INT
GO
