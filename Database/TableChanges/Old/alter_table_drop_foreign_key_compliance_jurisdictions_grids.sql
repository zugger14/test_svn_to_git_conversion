IF EXISTS ( SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'rec_gen_eligibility' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_rec_gen_eligibility_static_data_value' )
BEGIN
   ALTER TABLE dbo.rec_gen_eligibility DROP CONSTRAINT [FK_rec_gen_eligibility_static_data_value]
END

IF EXISTS ( SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'state_properties_bonus' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_state_properties_bonus_static_data_value' )
BEGIN
   ALTER TABLE dbo.state_properties_bonus DROP CONSTRAINT [FK_state_properties_bonus_static_data_value]
END

IF EXISTS ( SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'state_rec_requirement_data' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_state_rec_requirement Data_static_data_value' )
BEGIN
   ALTER TABLE dbo.state_rec_requirement_data DROP CONSTRAINT [FK_state_rec_requirement Data_static_data_value]
END

IF EXISTS ( SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'state_properties_duration' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_state_properties_duration_static_data_value' )
BEGIN
   ALTER TABLE dbo.state_properties_duration DROP CONSTRAINT [FK_state_properties_duration_static_data_value]
END
  