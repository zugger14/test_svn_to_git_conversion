IF COL_LENGTH('counterparty_contract_address', 'contract_category') IS NULL
BEGIN
	ALTER TABLE 
	/**
        Columns
        contract_category : Contract Category
    */
	dbo.[counterparty_contract_address]  ADD contract_category INT
END