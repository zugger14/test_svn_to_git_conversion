/*
* alter table counterparty_credit_info, add cols max_threshold, min_threshold, check_apply.
* sligal
* 11/22/2012
*/

IF COL_LENGTH('counterparty_credit_info', 'max_threshold') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_info ADD max_threshold FLOAT NULL
END
ELSE
	PRINT 'Column max_threshold already exists in table counterparty_credit_info'
GO

IF COL_LENGTH('counterparty_credit_info', 'min_threshold') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_info ADD min_threshold FLOAT NULL
END
ELSE
	PRINT 'Column min_threshold already exists in table counterparty_credit_info'
GO

IF COL_LENGTH('counterparty_credit_info', 'check_apply') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_info ADD check_apply CHAR(1) NULL
END
ELSE
	PRINT 'Column check_apply already exists in table counterparty_credit_info'
GO