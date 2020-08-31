IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'IX_contract_charge_type_detail')
BEGIN
	ALTER TABLE TRMTracker_New_Framework.dbo.contract_charge_type_detail 
	DROP CONSTRAINT IX_contract_charge_type_detail
END

--create new constraint
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'IX_contract_charge_type_detail_template')
BEGIN
	ALTER TABLE TRMTracker_New_Framework.dbo.contract_charge_type_detail 
	ADD CONSTRAINT IX_contract_charge_type_detail_template UNIQUE (contract_charge_type_id, template_id); 
END