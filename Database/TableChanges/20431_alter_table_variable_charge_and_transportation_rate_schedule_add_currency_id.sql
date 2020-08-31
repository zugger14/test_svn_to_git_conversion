IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'transportation_rate_schedule' AND COLUMN_NAME = 'currency_id')
	ALTER TABLE transportation_rate_schedule ADD currency_id INT

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'variable_charge' AND COLUMN_NAME = 'currency_id')
	ALTER TABLE variable_charge ADD currency_id INT