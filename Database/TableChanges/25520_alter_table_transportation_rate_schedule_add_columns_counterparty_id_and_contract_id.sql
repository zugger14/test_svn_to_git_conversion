IF COL_LENGTH('transportation_rate_schedule', 'counterparty_id') IS NULL
BEGIN
    ALTER TABLE transportation_rate_schedule
	/**
	Columns 
	counterparty_id : column that stores the counterparty reference
	*/
	ADD counterparty_id INT
END
GO

IF COL_LENGTH('transportation_rate_schedule', 'contract_id') IS NULL
BEGIN
    ALTER TABLE transportation_rate_schedule
	/**
	Columns 
	contract_id : column that stores the contract reference
	*/
	ADD contract_id INT
END
GO