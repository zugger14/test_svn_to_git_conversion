IF COL_LENGTH('variable_charge', 'counterparty_id') IS NULL
BEGIN
    ALTER TABLE variable_charge
	/**
	Columns 
	counterparty_id : column that stores the counterparty reference
	*/
	ADD counterparty_id INT
END
GO

IF COL_LENGTH('variable_charge', 'contract_id') IS NULL
BEGIN
    ALTER TABLE variable_charge
	/**
	Columns 
	contract_id : column that stores the contract reference
	*/
	ADD contract_id INT
END
GO