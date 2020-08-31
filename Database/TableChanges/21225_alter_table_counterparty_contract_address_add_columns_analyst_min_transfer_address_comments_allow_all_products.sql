IF COL_LENGTH('counterparty_contract_address', 'analyst') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD analyst VARCHAR(200) NULL
END
ELSE
	PRINT('Column analyst already exists.')
GO


IF COL_LENGTH('counterparty_contract_address', 'min_transfer_amount') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD min_transfer_amount FLOAT NULL
END
ELSE
	PRINT('Column min_transfer_amount exists.')
GO


IF COL_LENGTH('counterparty_contract_address', 'comments') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD comments VARCHAR(200) NULL
END
ELSE
	PRINT('Column comments exists.')
GO

IF COL_LENGTH('counterparty_contract_address', 'allow_all_products') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD allow_all_products CHAR(1) NULL
END
ELSE
	PRINT('Column allow_all_products already exists.')
GO
