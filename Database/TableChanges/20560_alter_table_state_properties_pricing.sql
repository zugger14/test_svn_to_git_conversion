IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_state_properties_pricing') 
BEGIN
	ALTER TABLE state_properties_pricing
	DROP CONSTRAINT UC_state_properties_pricing
END

TRUNCATE TABLE state_properties_pricing
ALTER TABLE state_properties_pricing 
ADD CONSTRAINT UC_state_properties_pricing 
UNIQUE (state_value_id,technology,pricing_type_id,curve_id)

 
