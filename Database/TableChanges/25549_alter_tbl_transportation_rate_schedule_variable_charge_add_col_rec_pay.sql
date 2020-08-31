 IF COL_LENGTH('transportation_rate_schedule','rec_pay') IS NULL
BEGIN
	ALTER TABLE dbo.transportation_rate_schedule
	/**
	rec_pay : receipt pay colum
	*/
	ADD rec_pay NCHAR(1)
END
ELSE
BEGIN
	PRINT 'Column rec_pay Already Exist'
END

GO 


 IF COL_LENGTH('variable_charge','rec_pay') IS NULL
BEGIN
	ALTER TABLE dbo.variable_charge
	/**
	rec_pay : receipt pay colum
	*/
	ADD rec_pay NCHAR(1)
END
ELSE
BEGIN
	PRINT 'Column rec_pay Already Exist'
END

GO 





