 IF COL_LENGTH('source_fee_volume','rec_pay') IS NULL
BEGIN
	ALTER TABLE dbo.source_fee_volume
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


