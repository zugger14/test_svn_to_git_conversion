IF COL_LENGTH('source_ice_trade_vault','file_name') IS NULL
	ALTER TABLE source_ice_trade_vault ADD file_name VARCHAR(200)