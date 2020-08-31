IF COL_LENGTH('state_rec_requirement_data', 'per_profit_give_back') IS NOT NULL
BEGIN
	ALTER TABLE state_rec_requirement_data ALTER COLUMN per_profit_give_back NUMERIC(38, 20)
	PRINT 'Data type of column state_rec_requirement_data.per_profit_give_back changed to numeric from float.'
END
ELSE
BEGIN
	PRINT 'Column state_rec_requirement_data.per_profit_give_back does not exist.'
END
GO

IF COL_LENGTH('state_rec_requirement_detail', 'min_target') IS NOT NULL
BEGIN
	ALTER TABLE state_rec_requirement_detail ALTER COLUMN min_target NUMERIC(38, 20)
	PRINT 'Data type of column state_rec_requirement_detail.min_target changed to numeric from float.'
END
ELSE
BEGIN
	PRINT 'Column state_rec_requirement_detail.min_target does not exist.'
END
GO

IF COL_LENGTH('state_rec_requirement_detail', 'min_absolute_target') IS NOT NULL
BEGIN
	ALTER TABLE state_rec_requirement_detail ALTER COLUMN min_absolute_target NUMERIC(38, 20)
	PRINT 'Data type of column state_rec_requirement_detail.min_absolute_target changed to numeric from float.'
END
ELSE
BEGIN
	PRINT 'Column state_rec_requirement_detail.min_absolute_target does not exist.'
END
GO

IF COL_LENGTH('state_rec_requirement_detail', 'max_target') IS NOT NULL
BEGIN
	ALTER TABLE state_rec_requirement_detail ALTER COLUMN max_target NUMERIC(38, 20)
	PRINT 'Data type of column state_rec_requirement_detail.max_target changed to numeric from float.'
END
ELSE
BEGIN
	PRINT 'Column state_rec_requirement_detail.max_target does not exist.'
END
GO

IF COL_LENGTH('state_rec_requirement_detail', 'max_absolute_target') IS NOT NULL
BEGIN
	ALTER TABLE state_rec_requirement_detail ALTER COLUMN max_absolute_target NUMERIC(38, 20)
	PRINT 'Data type of column state_rec_requirement_detail.max_absolute_target changed to numeric from float.'
END
ELSE
BEGIN
	PRINT 'Column state_rec_requirement_detail.max_absolute_target does not exist.'
END
GO





