IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_contract_id_effective_date')
BEGIN
	ALTER TABLE transportation_contract_mdq
	ADD CONSTRAINT UC_contract_id_effective_date UNIQUE (contract_id,effective_date)
END