IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'contract_charge_type_detail' AND COLUMN_NAME = 'contract_component_type')
BEGIN
	ALTER TABLE contract_charge_type_detail ADD contract_component_type CHAR(1)
	PRINT 'Column Added.'
END
ELSE
	PRINT 'Column already exists.'	