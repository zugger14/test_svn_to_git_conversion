/**
* alter table var_measurement_criteria_detail, add tenor_type, tenor_from, tenor_to for new enhancement of tenor attached with criteria.
* 26 nov 2013
**/
IF COL_LENGTH ('var_measurement_criteria_detail', 'tenor_type') IS NULL
BEGIN
	ALTER TABLE var_measurement_criteria_detail ADD tenor_type CHAR(1)
END
ELSE
	PRINT 'Column already exists.'
		
IF COL_LENGTH ('var_measurement_criteria_detail', 'tenor_from') IS NULL
BEGIN
	ALTER TABLE var_measurement_criteria_detail ADD tenor_from VARCHAR (10)
END
ELSE
	PRINT 'Column already exists.'

IF COL_LENGTH ('var_measurement_criteria_detail', 'tenor_to') IS NULL
BEGIN
	ALTER TABLE var_measurement_criteria_detail ADD tenor_to VARCHAR (10)
END
ELSE
	PRINT 'Column already exists.'
		