IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_deal_fields_mapping_contracts')
BEGIN
	ALTER TABLE deal_fields_mapping_contracts
	ADD CONSTRAINT UC_deal_fields_mapping_contracts UNIQUE (deal_fields_mapping_id,contract_id)
END