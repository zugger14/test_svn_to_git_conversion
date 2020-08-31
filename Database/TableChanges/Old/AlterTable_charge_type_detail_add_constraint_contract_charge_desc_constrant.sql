IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'contract_charge_desc_constrant')
BEGIN
	ALTER TABLE TRMTracker_New_Framework.dbo.contract_charge_type 
	ADD CONSTRAINT contract_charge_desc_constrant UNIQUE (contract_charge_desc); 
END