

IF COL_LENGTH('dbo.counterparty_credit_enhancements', 'transferred') IS NULL
BEGIN
	ALTER TABLE counterparty_credit_enhancements
	ADD transferred char(1) NULL;
	PRINT( 'Column transfer successfully added.' );
END;
ELSE
BEGIN
	PRINT( 'Column transfer already exist.' );
END;