IF COL_LENGTH('explain_delivered_mtm', 'pnl_conversion_factor') IS NOT NULL
BEGIN
	ALTER TABLE explain_delivered_mtm ALTER COLUMN pnl_conversion_factor FLOAT
END