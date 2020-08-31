IF OBJECT_ID(N'contract_group', N'U') IS NOT NULL AND COL_LENGTH('contract_group', 'pre_pay') IS NULL
BEGIN
    ALTER TABLE
	/**
		Column
		pre_pay : if the contract is pre pay or not 'n' No, 'y' yes.
	*/
	contract_group ADD pre_pay CHAR(1)
END
GO