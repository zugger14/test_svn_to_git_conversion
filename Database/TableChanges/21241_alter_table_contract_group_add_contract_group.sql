IF COL_LENGTH('contract_group', 'grouping_contract') IS NULL
BEGIN
    ALTER TABLE contract_group ADD grouping_contract Varchar(100)
END
ELSE
	PRINT 'Column contract_group Exists'
GO
