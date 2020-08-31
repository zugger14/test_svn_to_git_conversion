IF COL_LENGTH('counterparty_credit_block_trading', 'template_id') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_block_trading ADD template_id INT NULL
END
ELSE
	PRINT('Column template_id already exists.')
GO

IF COL_LENGTH('counterparty_credit_block_trading', 'counterparty_id') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_block_trading ADD counterparty_id INT NULL
END
ELSE
	PRINT('Column counterparty_id already exists.')
GO

IF COL_LENGTH('counterparty_credit_block_trading', 'internal_counterparty_id') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_block_trading ADD internal_counterparty_id INT NULL
END
ELSE
	PRINT('Column internal_counterparty_id already exists.')
GO

IF COL_LENGTH('counterparty_credit_block_trading', 'buy_sell') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_block_trading ADD buy_sell CHAR(1) NULL
END
ELSE
	PRINT('Column buy_sell already exists.')
GO