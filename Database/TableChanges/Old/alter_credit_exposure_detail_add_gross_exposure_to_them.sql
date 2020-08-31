/**
* alter credit_exposure_detail, add gross_exposure_to_them int null
**/
IF COL_LENGTH('credit_exposure_detail', 'gross_exposure_to_them') IS NULL
BEGIN
	ALTER TABLE credit_exposure_detail ADD gross_exposure_to_them FLOAT NULL 
END
ELSE
	PRINT 'column already exists.'