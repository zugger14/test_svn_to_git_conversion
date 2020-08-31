IF COL_LENGTH('var_measurement_criteria_detail', 'end_date') IS NULL
BEGIN
    ALTER TABLE var_measurement_criteria_detail ADD end_date DATETIME NULL
END
ELSE
BEGIN
	PRINT 'Column end_date already exist' 
END	
GO

IF COL_LENGTH('var_measurement_criteria_detail', 'mc_model') IS NULL
BEGIN
    ALTER TABLE var_measurement_criteria_detail ADD mc_model INT NULL
END
ELSE
BEGIN
	PRINT 'Column mc_model already exist' 
END	
GO