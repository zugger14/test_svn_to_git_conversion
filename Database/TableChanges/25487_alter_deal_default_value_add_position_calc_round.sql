IF COL_LENGTH(N'deal_default_value', N'position_calc_round') IS NULL
BEGIN
	ALTER TABLE deal_default_value ADD position_calc_round INT
	PRINT 'Added position_calc_round column.'
END
ELSE
BEGIN
	PRINT 'Column already exists.'
END
GO