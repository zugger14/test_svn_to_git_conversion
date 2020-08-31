IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'deal_calc_cashflow_earnings_detail' AND COLUMN_NAME = 'value')
BEGIN
	ALTER TABLE deal_calc_cashflow_earnings_detail ALTER COLUMN [value] NUMERIC(38, 20)
END