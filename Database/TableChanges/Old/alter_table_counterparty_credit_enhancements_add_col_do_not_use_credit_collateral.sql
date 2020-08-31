/**
* alter table counterparty_credit_enhancements , add char(1) exclude_collateral
* 27 nov 2013
**/
IF COL_LENGTH(N'counterparty_credit_enhancements', N'exclude_collateral') IS NULL
BEGIN
	ALTER TABLE counterparty_credit_enhancements
	ADD exclude_collateral CHAR(1) NOT NULL DEFAULT 'n'
END
ELSE
	PRINT 'Column already exists.'
