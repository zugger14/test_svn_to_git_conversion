
IF COL_LENGTH('calcprocess_inventory_deals', 'term_date') IS  NULL
	ALTER TABLE calcprocess_inventory_deals ADD term_date DATETIME
GO

IF COL_LENGTH('calcprocess_inventory_deals', 'calc_type') IS  NULL
	ALTER TABLE calcprocess_inventory_deals ADD calc_type CHAR(1)
GO

