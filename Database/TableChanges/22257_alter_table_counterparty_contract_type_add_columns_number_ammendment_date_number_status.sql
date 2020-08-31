IF COL_LENGTH('counterparty_contract_type', 'ammendment_date') IS NULL
BEGIN
	ALTER TABLE
	/**
        Columns
        ammendment_date : ammendment_date 
    */
	 counterparty_contract_type ADD [ammendment_date] DATETIME NULL
END
ELSE 
	PRINT('Column ammendment_date already exists')	
GO

IF COL_LENGTH('counterparty_contract_type', 'number') IS NULL
BEGIN
	ALTER TABLE
	/**
        Columns
        number : 
    */
	counterparty_contract_type ADD [number] INT NULL
END
ELSE 
	PRINT('Column number already exists')	
GO

IF COL_LENGTH('counterparty_contract_type', 'contract_status') IS NULL
BEGIN
	ALTER TABLE
	/**
        Columns
        status : 
    */
	counterparty_contract_type ADD [contract_status] INT NULL
END
ELSE 
	PRINT('Column number already exists')	
GO

