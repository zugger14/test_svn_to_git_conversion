IF COL_LENGTH('counterparty_credit_info', 'exclude_exposure_after') IS NULL
BEGIN
 ALTER TABLE counterparty_credit_info ADD exclude_exposure_after INT
END
ELSE
 PRINT 'exclude_exposure_after column already exists.'