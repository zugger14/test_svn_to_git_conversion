SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT * FROM static_data_value WHERE value_id = -309394)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-309394, 44800, 'Unused', 'Unused', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -309394 - Unused.'
	
	update [dbo].generator_characterstics set generator_config_value_id=-309394 where generator_config_value_id=309394
	update [dbo].[operation_unit_configuration] set generator_config_value_id=-309394 where generator_config_value_id=309394

	update [dbo].process_long_term_generation_unit_cost set generator_config_value_id=-309394 where generator_config_value_id=309394
	update [dbo].process_short_term_generation_unit_cost set generator_config_value_id=-309394 where generator_config_value_id=309394
	update [dbo].process_generation_unit_cost set generator_config_value_id=-309394 where generator_config_value_id=309394
	

	if not exists (select 1 from dbo.user_defined_fields_template where field_name='309394')
		delete static_data_value where value_id=309394
 
END
ELSE
BEGIN
    PRINT 'Static data value -309394 - Unuse already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
