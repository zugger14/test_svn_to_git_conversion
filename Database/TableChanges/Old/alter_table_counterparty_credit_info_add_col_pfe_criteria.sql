/**
* add col 'pfe_criteria' pn table 'counterparty_credit_info'
* sligal
* june 10 2013
**/
IF COL_LENGTH('counterparty_credit_info', 'pfe_criteria') IS NULL
BEGIN
	ALTER TABLE counterparty_credit_info ADD pfe_criteria INT
END
ELSE
	PRINT 'pfe_criteria column already exists.'