--For 'decaying_factor' table
IF COL_LENGTH('decaying_factor', 'code_value') IS NOT NULL AND COL_LENGTH('decaying_factor', 'state_value_id') IS NOT NULL
BEGIN
       ALTER TABLE decaying_factor 
			DROP COLUMN code_value;
END
ELSE IF COL_LENGTH('decaying_factor', 'code_value') IS NOT NULL AND COL_LENGTH('decaying_factor', 'state_value_id') IS NULL
BEGIN
       EXEC sp_RENAME 'decaying_factor.code_value', 'state_value_id', 'COLUMN'
END

--For 'state_properties' table
IF COL_LENGTH('state_properties', 'code_value') IS NOT NULL AND COL_LENGTH('state_properties', 'state_value_id') IS NOT NULL
BEGIN
       ALTER TABLE state_properties 
			DROP COLUMN code_value;
END
ELSE IF COL_LENGTH('state_properties', 'code_value') IS NOT NULL AND COL_LENGTH('state_properties', 'state_value_id') IS NULL
BEGIN
       EXEC sp_RENAME 'state_properties.code_value', 'state_value_id', 'COLUMN'
END

--For 'state_properties_duration' table
IF COL_LENGTH('state_properties_duration', 'code_value') IS NOT NULL AND COL_LENGTH('state_properties_duration', 'state_value_id') IS NOT NULL
BEGIN
       ALTER TABLE state_properties_duration 
			DROP COLUMN code_value;
END
ELSE IF COL_LENGTH('state_properties_duration', 'code_value') IS NOT NULL AND COL_LENGTH('state_properties_duration', 'state_value_id') IS NULL
BEGIN
       EXEC sp_RENAME 'state_properties_duration.code_value', 'state_value_id', 'COLUMN'
END

--For 'state_properties_bonus' table
IF COL_LENGTH('state_properties_bonus', 'code_value') IS NOT NULL AND COL_LENGTH('state_properties_bonus', 'state_value_id') IS NOT NULL
BEGIN
       ALTER TABLE state_properties_bonus 
			DROP COLUMN code_value;
END
ELSE IF COL_LENGTH('state_properties_bonus', 'code_value') IS NOT NULL AND COL_LENGTH('state_properties_bonus', 'state_value_id') IS NULL
BEGIN
       EXEC sp_RENAME 'state_properties_bonus.code_value', 'state_value_id', 'COLUMN'
END




		








		



