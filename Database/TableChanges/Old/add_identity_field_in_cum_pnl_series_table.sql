
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'cum_pnl_series' AND COLUMN_NAME = 'cum_pnl_series_id')
BEGIN
	ALTER TABLE cum_pnl_series ADD cum_pnl_series_id INT IDENTITY(1,1)
END