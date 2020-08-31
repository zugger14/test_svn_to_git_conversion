IF COL_LENGTH('netting_group_detail_contract','contract_description') IS NULL
	ALTER TABLE netting_group_detail_contract ADD contract_description VARCHAR(1000)
GO
