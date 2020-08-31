IF COL_LENGTH(N'deal_default_value', N'round_volume') IS NULL
BEGIN
	ALTER TABLE deal_default_value ADD round_volume INT
	PRINT 'Added round_volume column.'
END
ELSE
BEGIN
	PRINT 'Column already exists.'
END
GO

IF COL_LENGTH(N'deal_default_value', N'round_price') IS NULL
BEGIN
	ALTER TABLE deal_default_value ADD round_price INT
	PRINT 'Added round_price column.'
END
ELSE
BEGIN
	PRINT 'Column already exists.'
END
GO