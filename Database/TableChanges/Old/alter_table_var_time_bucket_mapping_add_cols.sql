/*
* alter table var_time_bucket_mapping, add cols: risk_bucket, shift_by, shift_value
* sligal
* 11/27/2012
*/
IF COL_LENGTH('var_time_bucket_mapping', 'risk_bucket') IS NULL
BEGIN
	ALTER TABLE var_time_bucket_mapping ADD risk_bucket INT NULL
END
ELSE
	PRINT 'Column risk_bucket already exists in table var_time_bucket_mapping'
GO

IF COL_LENGTH('var_time_bucket_mapping', 'shift_by') IS NULL
BEGIN
	ALTER TABLE var_time_bucket_mapping ADD shift_by CHAR(1) NOT NULL DEFAULT 'v'
END
ELSE
	PRINT 'Column shift_by already exists in table var_time_bucket_mapping'
GO

IF COL_LENGTH('var_time_bucket_mapping', 'shift_value') IS NULL
BEGIN
	ALTER TABLE var_time_bucket_mapping ADD shift_value FLOAT NULL
END
ELSE
	PRINT 'Column shift_value already exists in table var_time_bucket_mapping'
GO