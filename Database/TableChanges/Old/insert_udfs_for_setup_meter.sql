DECLARE @value_name VARCHAR(1000) 
DECLARE @value_id INT 
DECLARE @udf_template_id INT
DECLARE @application_group_id INT 
DECLARE @application_ui_field_id INT 
DECLARE @maintain_udf_detail INT 
DECLARE @udf_field_id VARCHAR(50)
DECLARE @delete_application_ui_field_ui INT 
---------------------------------------------------Start Reporting Code------------------------------------------------------------------------------------
SET @value_name = 'Reporting Code'
SET @value_id = -5685

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5685)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5685, 5500, 'Reporting Code', 'Reporting Code', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5685 - Reporting Code.'
END
ELSE
BEGIN
	PRINT 'Static data value -5685 - Reporting Code already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--user_defined_fields_template
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = @value_name)
BEGIN 
	INSERT INTO user_defined_fields_template(field_name
											, Field_label
											, Field_type
											, data_type
											, is_required
											, udf_type
											, field_size
											, field_id
											)
	SELECT @value_id, @value_name, 't', 'varchar(500)', 'n', 'h', 120, @value_id
END 

SELECT @udf_template_id = udf_template_id , @udf_field_id = REPLACE(LOWER(@value_name), ' ', '_') FROM user_defined_fields_template WHERE Field_label = @value_name
-- select * from maintain_udf_detail
IF NOT EXISTS (SELECT 1 FROM maintain_udf_detail WHERE udf_template_id = @udf_template_id)
BEGIN 
	INSERT INTO maintain_udf_detail(
									 udf_template_id
									, udf_label
									, is_update_required
									, is_insert_required
									, is_disable
									, is_hidden
									, sequence_number)
	SELECT @udf_template_id, @value_name,'y', 'y', 'n', 'n', 1 
	
	SELECT @maintain_udf_detail = IDENT_CURRENT('maintain_udf_detail')
	--SELECT IDENT_CURRENT('maintain_udf_detail')

	-- select * from maintain_udf_detail_values
	IF NOT EXISTS(SELECT 1 FROM maintain_udf_detail_values WHERE application_field_id = @maintain_udf_detail AND module_object_id = @value_id)
	BEGIN
		INSERT INTO maintain_udf_detail_values(application_field_id	,module_object_id,	udf_values)
		SELECT @maintain_udf_detail, @value_id,	NULL
	END 
END

IF EXISTS (SELECT 1 FROM application_ui_template_definition WHERE default_label = @value_name AND CHARINDEX('udf',field_id) > 0)
BEGIN
	SELECT @delete_application_ui_field_ui = application_ui_field_id FROM application_ui_template_definition WHERE default_label = @value_name
	DELETE FROM application_ui_template_fields WHERE application_ui_field_id = @delete_application_ui_field_ui
	DELETE FROM application_ui_template_definition WHERE application_ui_field_id = @delete_application_ui_field_ui
END 

IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition WHERE application_function_id = 10103000 AND field_id = @udf_field_id)
BEGIN
	INSERT INTO application_ui_template_definition(application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail
												, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag
												, update_required, has_round_option, create_user, create_ts, update_user, update_ts, blank_option, is_primary
												, is_udf, is_identity, text_row_num, hyperlink_function, char_length)
	SELECT 10103000, @udf_field_id, @udf_field_id, @value_name, 'input', 'varchar', 'h', 'n', ''
		, 200, 'n',	'n', NULL, 'n',	'n', 'n', 'n', NULL, NULL, NULL, NULL, 'n',	'n', 'y', 'n', NULL, NULL, NULL
		
	SELECT @application_ui_field_id = IDENT_CURRENT('application_ui_template_definition')

	SELECT @application_group_id = autg.application_group_id 
	FROM application_ui_template aui 
	INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id  = aui.application_ui_template_id 
	WHERE application_function_id = 10103000
		AND group_name = 'Metering Info'

	-- select * from application_ui_template_fields
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_fields WHERE application_ui_field_id = @application_ui_field_id AND udf_template_id = @udf_template_id)
	BEGIN
		INSERT INTO application_ui_template_fields(application_group_id, application_ui_field_id, hidden, field_type, udf_template_id)
		SELECT @application_group_id, @application_ui_field_id, 'n', 'input', @udf_template_id	
	END	
END
---------------------------------------------------END Reporting Code------------------------------------------------------------------------------------


---------------------------------------------------Start Wexpro Agreement------------------------------------------------------------------------------------
SET @value_name = 'Wexpro Agreement'
SET @value_id = -5686

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5686)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5686, 5500, 'Wexpro Agreement', 'Wexpro Agreement', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5686 - Wexpro Agreement.'
END
ELSE
BEGIN
	PRINT 'Static data value -5686 - Wexpro Agreement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--user_defined_fields_template
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = @value_name)
BEGIN 
	INSERT INTO user_defined_fields_template(field_name
											, Field_label
											, Field_type
											, data_type
											, is_required
											, udf_type
											, field_size
											, field_id
											)
	SELECT @value_id, @value_name, 't', 'varchar(500)', 'n', 'h', 120, @value_id
END 

SELECT @udf_template_id = udf_template_id , @udf_field_id = REPLACE(LOWER(@value_name), ' ', '_') FROM user_defined_fields_template WHERE Field_label = @value_name
-- select * from maintain_udf_detail
IF NOT EXISTS (SELECT 1 FROM maintain_udf_detail WHERE udf_template_id = @udf_template_id)
BEGIN 
	INSERT INTO maintain_udf_detail(
									 udf_template_id
									, udf_label
									, is_update_required
									, is_insert_required
									, is_disable
									, is_hidden
									, sequence_number)
	SELECT @udf_template_id, @value_name,'y', 'y', 'n', 'n', 1 
	
	SELECT @maintain_udf_detail = IDENT_CURRENT('maintain_udf_detail')
	--SELECT IDENT_CURRENT('maintain_udf_detail')

	-- select * from maintain_udf_detail_values
	IF NOT EXISTS(SELECT 1 FROM maintain_udf_detail_values WHERE application_field_id = @maintain_udf_detail AND module_object_id = @value_id)
	BEGIN
		INSERT INTO maintain_udf_detail_values(application_field_id	,module_object_id,	udf_values)
		SELECT @maintain_udf_detail, @value_id,	NULL
	END 
END

IF EXISTS (SELECT 1 FROM application_ui_template_definition WHERE default_label = @value_name AND CHARINDEX('udf',field_id) > 0)
BEGIN
	SELECT @delete_application_ui_field_ui = application_ui_field_id FROM application_ui_template_definition WHERE default_label = @value_name
	DELETE FROM application_ui_template_fields WHERE application_ui_field_id = @delete_application_ui_field_ui
	DELETE FROM application_ui_template_definition WHERE application_ui_field_id = @delete_application_ui_field_ui
END 

IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition WHERE application_function_id = 10103000 AND field_id = @udf_field_id)
BEGIN
	INSERT INTO application_ui_template_definition(application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail
												, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag
												, update_required, has_round_option, create_user, create_ts, update_user, update_ts, blank_option, is_primary
												, is_udf, is_identity, text_row_num, hyperlink_function, char_length)
	SELECT 10103000, @udf_field_id, @udf_field_id, @value_name, 'input', 'varchar', 'h', 'n', ''
		, 200, 'n',	'n', NULL, 'n',	'n', 'n', 'n', NULL, NULL, NULL, NULL, 'n',	'n', 'y', 'n', NULL, NULL, NULL
		
	SELECT @application_ui_field_id = IDENT_CURRENT('application_ui_template_definition')

	SELECT @application_group_id = autg.application_group_id 
	FROM application_ui_template aui 
	INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id  = aui.application_ui_template_id 
	WHERE application_function_id = 10103000
		AND group_name = 'Metering Info'

	-- select * from application_ui_template_fields
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_fields WHERE application_ui_field_id = @application_ui_field_id AND udf_template_id = @udf_template_id)
	BEGIN
		INSERT INTO application_ui_template_fields(application_group_id, application_ui_field_id, hidden, field_type, udf_template_id)
		SELECT @application_group_id, @application_ui_field_id, 'n', 'input', @udf_template_id	
	END
END
---------------------------------------------------END Wexpro Agreement------------------------------------------------------------------------------------

---------------------------------------------------Start Field------------------------------------------------------------------------------------
SET @value_name = 'Field'
SET @value_id = -5687

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5687)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5687, 5500, 'Field', 'Field', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5687 - Field.'
END
ELSE
BEGIN
	PRINT 'Static data value -5687 - Field already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--user_defined_fields_template
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = @value_name)
BEGIN 
	INSERT INTO user_defined_fields_template(field_name
											, Field_label
											, Field_type
											, data_type
											, is_required
											, udf_type
											, field_size
											, field_id
											)
	SELECT @value_id, @value_name, 't', 'varchar(500)', 'n', 'h', 120, @value_id
END 

SELECT @udf_template_id = udf_template_id , @udf_field_id = REPLACE(LOWER(@value_name), ' ', '_') FROM user_defined_fields_template WHERE Field_label = @value_name
-- select * from maintain_udf_detail
IF NOT EXISTS (SELECT 1 FROM maintain_udf_detail WHERE udf_template_id = @udf_template_id)
BEGIN 
	INSERT INTO maintain_udf_detail(
									 udf_template_id
									, udf_label
									, is_update_required
									, is_insert_required
									, is_disable
									, is_hidden
									, sequence_number)
	SELECT @udf_template_id, @value_name,'y', 'y', 'n', 'n', 1 
	
	SELECT @maintain_udf_detail = IDENT_CURRENT('maintain_udf_detail')
	--SELECT IDENT_CURRENT('maintain_udf_detail')

	-- select * from maintain_udf_detail_values
	IF NOT EXISTS(SELECT 1 FROM maintain_udf_detail_values WHERE application_field_id = @maintain_udf_detail AND module_object_id = @value_id)
	BEGIN
		INSERT INTO maintain_udf_detail_values(application_field_id	,module_object_id,	udf_values)
		SELECT @maintain_udf_detail, @value_id,	NULL
	END 
END

IF EXISTS (SELECT 1 FROM application_ui_template_definition WHERE default_label = @value_name AND CHARINDEX('udf',field_id) > 0)
BEGIN
	SELECT @delete_application_ui_field_ui = application_ui_field_id FROM application_ui_template_definition WHERE default_label = @value_name
	DELETE FROM application_ui_template_fields WHERE application_ui_field_id = @delete_application_ui_field_ui
	DELETE FROM application_ui_template_definition WHERE application_ui_field_id = @delete_application_ui_field_ui
END 

IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition WHERE application_function_id = 10103000 AND field_id = @udf_field_id)
BEGIN
	INSERT INTO application_ui_template_definition(application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail
												, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag
												, update_required, has_round_option, create_user, create_ts, update_user, update_ts, blank_option, is_primary
												, is_udf, is_identity, text_row_num, hyperlink_function, char_length)
	SELECT 10103000, @udf_field_id, @udf_field_id, @value_name, 'input', 'varchar', 'h', 'n', ''
		, 200, 'n',	'n', NULL, 'n',	'n', 'n', 'n', NULL, NULL, NULL, NULL, 'n',	'n', 'y', 'n', NULL, NULL, NULL
		
	SELECT @application_ui_field_id = IDENT_CURRENT('application_ui_template_definition')

	SELECT @application_group_id = autg.application_group_id 
	FROM application_ui_template aui 
	INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id  = aui.application_ui_template_id 
	WHERE application_function_id = 10103000
		AND group_name = 'Metering Info'

	-- select * from application_ui_template_fields
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_fields WHERE application_ui_field_id = @application_ui_field_id AND udf_template_id = @udf_template_id)
	BEGIN
		INSERT INTO application_ui_template_fields(application_group_id, application_ui_field_id, hidden, field_type, udf_template_id)
		SELECT @application_group_id, @application_ui_field_id, 'n', 'input', @udf_template_id	
	END
END
---------------------------------------------------END Field------------------------------------------------------------------------------------

---------------------------------------------------Start Status------------------------------------------------------------------------------------
SET @value_name = 'Status'
SET @value_id = -5688

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5688)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5688, 5500, 'Status', 'Status', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5688 - Status.'
END
ELSE
BEGIN
	PRINT 'Static data value -5688 - Status already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--user_defined_fields_template
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = @value_name)
BEGIN 
	INSERT INTO user_defined_fields_template(field_name
											, Field_label
											, Field_type
											, data_type
											, is_required
											, udf_type
											, field_size
											, field_id
											)
	SELECT @value_id, @value_name, 't', 'varchar(500)', 'n', 'h', 120, @value_id
END 

SELECT @udf_template_id = udf_template_id , @udf_field_id = REPLACE(LOWER(@value_name), ' ', '_') FROM user_defined_fields_template WHERE Field_label = @value_name
-- select * from maintain_udf_detail
IF NOT EXISTS (SELECT 1 FROM maintain_udf_detail WHERE udf_template_id = @udf_template_id)
BEGIN 
	INSERT INTO maintain_udf_detail(
									 udf_template_id
									, udf_label
									, is_update_required
									, is_insert_required
									, is_disable
									, is_hidden
									, sequence_number)
	SELECT @udf_template_id, @value_name,'y', 'y', 'n', 'n', 1 
	
	SELECT @maintain_udf_detail = IDENT_CURRENT('maintain_udf_detail')
	--SELECT IDENT_CURRENT('maintain_udf_detail')

	-- select * from maintain_udf_detail_values
	IF NOT EXISTS(SELECT 1 FROM maintain_udf_detail_values WHERE application_field_id = @maintain_udf_detail AND module_object_id = @value_id)
	BEGIN
		INSERT INTO maintain_udf_detail_values(application_field_id	,module_object_id,	udf_values)
		SELECT @maintain_udf_detail, @value_id,	NULL
	END 
END

IF EXISTS (SELECT 1 FROM application_ui_template_definition WHERE default_label = @value_name AND CHARINDEX('udf',field_id) > 0)
BEGIN
	SELECT @delete_application_ui_field_ui = application_ui_field_id FROM application_ui_template_definition WHERE default_label = @value_name
	DELETE FROM application_ui_template_fields WHERE application_ui_field_id = @delete_application_ui_field_ui
	DELETE FROM application_ui_template_definition WHERE application_ui_field_id = @delete_application_ui_field_ui
END 

IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition WHERE application_function_id = 10103000 AND field_id = @udf_field_id)
BEGIN
	INSERT INTO application_ui_template_definition(application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail
												, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag
												, update_required, has_round_option, create_user, create_ts, update_user, update_ts, blank_option, is_primary
												, is_udf, is_identity, text_row_num, hyperlink_function, char_length)
	SELECT 10103000, @udf_field_id, @udf_field_id, @value_name, 'input', 'varchar', 'h', 'n', ''
		, 200, 'n',	'n', NULL, 'n',	'n', 'n', 'n', NULL, NULL, NULL, NULL, 'n',	'n', 'y', 'n', NULL, NULL, NULL
		
	SELECT @application_ui_field_id = IDENT_CURRENT('application_ui_template_definition')

	SELECT @application_group_id = autg.application_group_id 
	FROM application_ui_template aui 
	INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id  = aui.application_ui_template_id 
	WHERE application_function_id = 10103000
		AND group_name = 'Metering Info'

	-- select * from application_ui_template_fields
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_fields WHERE application_ui_field_id = @application_ui_field_id AND udf_template_id = @udf_template_id)
	BEGIN
		INSERT INTO application_ui_template_fields(application_group_id, application_ui_field_id, hidden, field_type, udf_template_id)
		SELECT @application_group_id, @application_ui_field_id, 'n', 'input', @udf_template_id	
	END	
END
---------------------------------------------------END Status------------------------------------------------------------------------------------








