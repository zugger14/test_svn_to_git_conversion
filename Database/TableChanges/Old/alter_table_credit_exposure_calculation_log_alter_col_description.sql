IF COL_LENGTH('credit_exposure_calculation_log', 'description') IS NOT NULL
BEGIN
	ALTER TABLE credit_exposure_calculation_log ALTER COLUMN DESCRIPTION VARCHAR(8000)  
END
ELSE
	PRINT 'Column description not exists in table credit_exposure_calculation_log'
GO