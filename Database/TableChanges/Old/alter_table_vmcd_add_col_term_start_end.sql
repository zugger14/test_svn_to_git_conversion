/**
* alter table var_measurement_criteria_detail, add  term_start, term_end for new enhancement of tenor attached with criteria.
* 3 jan 2014
**/
	
IF COL_LENGTH ('var_measurement_criteria_detail', 'term_start') IS NULL
BEGIN
	ALTER TABLE var_measurement_criteria_detail ADD term_start DATETIME NULL
	
END
ELSE
	PRINT 'Column already exists.'

IF COL_LENGTH ('var_measurement_criteria_detail', 'term_end') IS NULL
BEGIN
	ALTER TABLE var_measurement_criteria_detail ADD term_end DATETIME NULL
END
ELSE
	PRINT 'Column already exists.'

--update previous values for tenor_from, tenor_to, tenor_type to NULL
IF COL_LENGTH ('var_measurement_criteria_detail', 'tenor_from') IS NOT NULL
BEGIN
	UPDATE var_measurement_criteria_detail SET tenor_from = NULL
END
IF COL_LENGTH ('var_measurement_criteria_detail', 'tenor_to') IS NOT NULL
BEGIN
	UPDATE var_measurement_criteria_detail SET tenor_to = NULL
END
IF COL_LENGTH ('var_measurement_criteria_detail', 'tenor_type') IS NOT NULL
BEGIN
	UPDATE var_measurement_criteria_detail SET tenor_type = NULL
END
			