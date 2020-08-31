IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_state_properties_pricing') 
BEGIN
	TRUNCATE TABLE state_properties_pricing
	ALTER TABLE state_properties_pricing ADD CONSTRAINT UC_state_properties_pricing UNIQUE (technology,pricing_type_id,curve_id)
END
ELSE 
	PRINT 'Unique Key UC_state_properties_pricing already exists.'
