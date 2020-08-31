
IF COL_LENGTH('counterparty_credit_block_trading', 'comodity_id') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_credit_block_trading
	ALTER COLUMN comodity_id INT NULL
END
ELSE 
BEGIN
	PRINT 'Column ''comodity_id'' doesn''t Exists '
END
GO

IF COL_LENGTH('counterparty_credit_block_trading', 'deal_type_id' ) IS NOT NULL
BEGIN
	ALTER TABLE counterparty_credit_block_trading
	ALTER COLUMN deal_type_id INT NULL
END
ELSE 
BEGIN
	PRINT 'Column ''comodity_id'' doesn''t Exists '
END
GO

