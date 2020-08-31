IF COL_LENGTH('contract_group', 'standard_contract') IS NULL
BEGIN
	ALTER TABLE contract_group ADD standard_contract CHAR(1) NULL 	
END
