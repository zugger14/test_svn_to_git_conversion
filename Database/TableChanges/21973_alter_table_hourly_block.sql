IF COL_LENGTH('hourly_block','from_month') IS NULL
BEGIN
	ALTER TABLE hourly_block
	ADD from_month INT
END

IF COL_LENGTH('hourly_block','to_month') IS NULL
BEGIN
	ALTER TABLE hourly_block
	ADD to_month INT
END


