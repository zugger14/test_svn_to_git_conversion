IF COL_LENGTH('var_measurement_criteria_detail', 'hold_to_maturity') IS NULL
BEGIN
	ALTER TABLE var_measurement_criteria_detail 
	ADD hold_to_maturity CHAR(1)
	PRINT 'Column var_measurement_criteria_detail.hold_to_maturity added.'
END
GO 

ALTER TABLE var_measurement_criteria_detail
ALTER COLUMN hold_to_maturity CHAR(1)