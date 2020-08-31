/*
* alter table counterparty_credit_block_trading, add cols contract, active, buysell_allow.
* sligal
* 11/22/2012
*/

IF COL_LENGTH('counterparty_credit_block_trading', 'contract') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_block_trading ADD [contract] INT NULL
END
ELSE
	PRINT 'Column contract already exists in table counterparty_credit_block_trading'
GO

IF COL_LENGTH('counterparty_credit_block_trading', 'active') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_block_trading ADD active CHAR(1) NULL
END
ELSE
	PRINT 'Column active already exists in table counterparty_credit_block_trading'
GO

IF COL_LENGTH('counterparty_credit_block_trading', 'buysell_allow') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_block_trading ADD buysell_allow CHAR(1) NULL
END
ELSE
	PRINT 'Column buysell_allow already exists in table counterparty_credit_block_trading'
GO