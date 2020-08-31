DECLARE @value_name VARCHAR(1000) 
DECLARE @value_id INT 
DECLARE @udf_template_id INT
DECLARE @application_group_id INT 
DECLARE @application_ui_field_id INT 
DECLARE @maintain_udf_detail INT 
DECLARE @udf_field_id VARCHAR(50)
DECLARE @delete_application_ui_field_ui INT 
---------------------------------------------------Start RPG------------------------------------------------------------------------------------

SET @value_name = 'RPG'
SET @value_id = -5680
-- insert operator
--static data type
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = @value_id)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5680, 5500, 'RPG', 'RPG', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5680 - RPG.'
END
ELSE
BEGIN
	PRINT 'Static data value -5680 - RPG already EXISTS.'
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

-- select * from application_ui_template_definition where application_function_id = 10102500
IF EXISTS (SELECT 1 FROM application_ui_template_definition WHERE default_label = @value_name AND CHARINDEX('udf',field_id) > 0)
BEGIN
	SELECT @delete_application_ui_field_ui = application_ui_field_id FROM application_ui_template_definition WHERE default_label = @value_name
	DELETE FROM application_ui_template_fields WHERE application_ui_field_id = @delete_application_ui_field_ui
	DELETE FROM application_ui_template_definition WHERE application_ui_field_id = @delete_application_ui_field_ui
END 

IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition WHERE application_function_id = 10102500 AND field_id = @udf_field_id)
BEGIN
	INSERT INTO application_ui_template_definition(application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail
												, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag
												, update_required, has_round_option, create_user, create_ts, update_user, update_ts, blank_option, is_primary
												, is_udf, is_identity, text_row_num, hyperlink_function, char_length)
	SELECT 10102500, @udf_field_id, @udf_field_id, @value_name, 'input', 'varchar', 'h', 'n', ''
		, 150, 'n',	'n', NULL, 'n',	'n', 'n', 'n', NULL, NULL, NULL, NULL, 'n',	'n', 'y', 'n', NULL, NULL, NULL
		
	SELECT @application_ui_field_id = IDENT_CURRENT('application_ui_template_definition')

	SELECT @application_group_id = autg.application_group_id 
	FROM application_ui_template aui 
	INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id  = aui.application_ui_template_id 
	WHERE application_function_id = 10102500
		AND group_name = 'Additional'

	-- select * from application_ui_template_fields 
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_fields WHERE application_ui_field_id = @application_ui_field_id AND udf_template_id = @udf_template_id)
	BEGIN
		INSERT INTO application_ui_template_fields(application_group_id, application_ui_field_id, hidden, field_type, udf_template_id)
		SELECT @application_group_id, @application_ui_field_id, 'n', 'input', @udf_template_id	
	END
END

------------------------------------------------END REF----------------------------------------------------------------------------------

--SELECT autg.* ,group_name
--FROM application_ui_template aui 
--INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id  = aui.application_ui_template_id 
--WHERE application_function_id = 10102500 AND group_name = 'Additional'

--UPDATE application_ui_template_group  SET active_flag = 'y' WHERE application_group_id =3490

--SELECT * FROM application_ui_template_definition WHERE application_function_id= 10102500
--SELECT * FROM application_ui_template_fields

---------------------------------------------------Start DUNS REF------------------------------------------------------------------------------------
SET @value_name = 'DUNS REF'
SET @value_id = -5681
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = @value_id)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5681, 5500, 'DUNS REF', 'DUNS REF', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5681 - DUNS REF.'
END
ELSE
BEGIN
	PRINT 'Static data value -5681 - DUNS REF already EXISTS.'
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


IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition WHERE application_function_id = 10102500 AND field_id = @udf_field_id)
BEGIN
	INSERT INTO application_ui_template_definition(application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail
												, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag
												, update_required, has_round_option, create_user, create_ts, update_user, update_ts, blank_option, is_primary
												, is_udf, is_identity, text_row_num, hyperlink_function, char_length)
	SELECT 10102500, @udf_field_id, @udf_field_id, @value_name, 'input', 'varchar', 'h', 'n', ''
		, 150, 'n',	'n', NULL, 'n',	'n', 'n', 'n', NULL, NULL, NULL, NULL, 'n',	'n', 'y', 'n', NULL, NULL, NULL
		
	SELECT @application_ui_field_id = IDENT_CURRENT('application_ui_template_definition')

	SELECT @application_group_id = autg.application_group_id 
	FROM application_ui_template aui 
	INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id  = aui.application_ui_template_id 
	WHERE application_function_id = 10102500
		AND group_name = 'Additional'

	-- select * from application_ui_template_fields
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_fields WHERE application_ui_field_id = @application_ui_field_id AND udf_template_id = @udf_template_id)
	BEGIN
		INSERT INTO application_ui_template_fields(application_group_id, application_ui_field_id, hidden, field_type, udf_template_id)
		SELECT @application_group_id, @application_ui_field_id, 'n', 'input', @udf_template_id	
	END
END
---------------------------------------------------END DUNS REF------------------------------------------------------------------------------------

---------------------------------------------------Start TSP Location Name------------------------------------------------------------------------------------
SET @value_name = 'TSP Location Name'
SET @value_id = -5682

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5682)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5682, 5500, 'TSP Location Name', 'TSP Location Name', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5682 - TSP Location Name.'
END
ELSE
BEGIN
	PRINT 'Static data value -5682 - TSP Location Name already EXISTS.'
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


IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition WHERE application_function_id = 10102500 AND field_id = @udf_field_id)
BEGIN
	INSERT INTO application_ui_template_definition(application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail
												, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag
												, update_required, has_round_option, create_user, create_ts, update_user, update_ts, blank_option, is_primary
												, is_udf, is_identity, text_row_num, hyperlink_function, char_length)
	SELECT 10102500, @udf_field_id, @udf_field_id, @value_name, 'input', 'varchar', 'h', 'n', ''
		, 150, 'n',	'n', NULL, 'n',	'n', 'n', 'n', NULL, NULL, NULL, NULL, 'n',	'n', 'y', 'n', NULL, NULL, NULL
		
	SELECT @application_ui_field_id = IDENT_CURRENT('application_ui_template_definition')

	SELECT @application_group_id = autg.application_group_id 
	FROM application_ui_template aui 
	INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id  = aui.application_ui_template_id 
	WHERE application_function_id = 10102500
		AND group_name = 'Additional'

	-- select * from application_ui_template_fields
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_fields WHERE application_ui_field_id = @application_ui_field_id AND udf_template_id = @udf_template_id)
	BEGIN
		INSERT INTO application_ui_template_fields(application_group_id, application_ui_field_id, hidden, field_type, udf_template_id)
		SELECT @application_group_id, @application_ui_field_id, 'n', 'input', @udf_template_id	
	END
END

---------------------------------------------------END TSP Location Name------------------------------------------------------------------------------------

---------------------------------------------------Start TSP Location Name------------------------------------------------------------------------------------
SET @value_name = 'TSP Location Name'
SET @value_id = -5682

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5682)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5682, 5500, 'TSP Location Name', 'TSP Location Name', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5682 - TSP Location Name.'
END
ELSE
BEGIN
	PRINT 'Static data value -5682 - TSP Location Name already EXISTS.'
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


IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition WHERE application_function_id = 10102500 AND field_id =  @udf_field_id)
BEGIN
	INSERT INTO application_ui_template_definition(application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail
												, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag
												, update_required, has_round_option, create_user, create_ts, update_user, update_ts, blank_option, is_primary
												, is_udf, is_identity, text_row_num, hyperlink_function, char_length)
	SELECT 10102500, @udf_field_id, @udf_field_id, @value_name, 'input', 'varchar', 'h', 'n', ''
		, 150, 'n',	'n', NULL, 'n',	'n', 'n', 'n', NULL, NULL, NULL, NULL, 'n',	'n', 'y', 'n', NULL, NULL, NULL
		
	SELECT @application_ui_field_id = IDENT_CURRENT('application_ui_template_definition')

	SELECT @application_group_id = autg.application_group_id 
	FROM application_ui_template aui 
	INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id  = aui.application_ui_template_id 
	WHERE application_function_id = 10102500
		AND group_name = 'Additional'

	-- select * from application_ui_template_fields
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_fields WHERE application_ui_field_id = @application_ui_field_id AND udf_template_id = @udf_template_id)
	BEGIN
		INSERT INTO application_ui_template_fields(application_group_id, application_ui_field_id, hidden, field_type, udf_template_id)
		SELECT @application_group_id, @application_ui_field_id, 'n', 'input', @udf_template_id	
	END
END
---------------------------------------------------END TSP Location Name------------------------------------------------------------------------------------


---------------------------------------------------Start Tesoro Facility ID------------------------------------------------------------------------------------
SET @value_name = 'Tesoro Facility ID'
SET @value_id = -5683

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5683)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5683, 5500, 'Tesoro Facility ID', 'Tesoro Facility ID', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5683 - Tesoro Facility ID.'
END
ELSE
BEGIN
	PRINT 'Static data value -5683 - Tesoro Facility ID already EXISTS.'
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


IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition WHERE application_function_id = 10102500 AND field_id =  @udf_field_id)
BEGIN
	INSERT INTO application_ui_template_definition(application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail
												, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag
												, update_required, has_round_option, create_user, create_ts, update_user, update_ts, blank_option, is_primary
												, is_udf, is_identity, text_row_num, hyperlink_function, char_length)
	SELECT 10102500, @udf_field_id, @udf_field_id, @value_name, 'input', 'varchar', 'h', 'n', ''
		, 150, 'n',	'n', NULL, 'n',	'n', 'n', 'n', NULL, NULL, NULL, NULL, 'n',	'n', 'y', 'n', NULL, NULL, NULL
		
	SELECT @application_ui_field_id = IDENT_CURRENT('application_ui_template_definition')

	SELECT @application_group_id = autg.application_group_id 
	FROM application_ui_template aui 
	INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id  = aui.application_ui_template_id 
	WHERE application_function_id = 10102500
		AND group_name = 'Additional'

	-- select * from application_ui_template_fields
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_fields WHERE application_ui_field_id = @application_ui_field_id AND udf_template_id = @udf_template_id)
	BEGIN
		INSERT INTO application_ui_template_fields(application_group_id, application_ui_field_id, hidden, field_type, udf_template_id)
		SELECT @application_group_id, @application_ui_field_id, 'n', 'input', @udf_template_id	
	END 
END
---------------------------------------------------END Tesoro Facility ID------------------------------------------------------------------------------------

---------------------------------------------------Start Tesoro GSI Group------------------------------------------------------------------------------------
SET @value_name = 'Tesoro GSI Group'
SET @value_id = -5684

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5684)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5684, 5500, 'Tesoro GSI Group', 'Tesoro GSI Group', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5684 - Tesoro GSI Group.'
END
ELSE
BEGIN
	PRINT 'Static data value -5684 - Tesoro GSI Group already EXISTS.'
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


IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition WHERE application_function_id = 10102500 AND field_id =  @udf_field_id)
BEGIN
	INSERT INTO application_ui_template_definition(application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail
												, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag
												, update_required, has_round_option, create_user, create_ts, update_user, update_ts, blank_option, is_primary
												, is_udf, is_identity, text_row_num, hyperlink_function, char_length)
	SELECT 10102500, @udf_field_id, @udf_field_id, @value_name, 'input', 'varchar', 'h', 'n', ''
		, 150, 'n',	'n', NULL, 'n',	'n', 'n', 'n', NULL, NULL, NULL, NULL, 'n',	'n', 'y', 'n', NULL, NULL, NULL
		
	SELECT @application_ui_field_id = IDENT_CURRENT('application_ui_template_definition')

	SELECT @application_group_id = autg.application_group_id 
	FROM application_ui_template aui 
	INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id  = aui.application_ui_template_id 
	WHERE application_function_id = 10102500
		AND group_name = 'Additional'

	-- select * from application_ui_template_fields
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_fields WHERE application_ui_field_id = @application_ui_field_id AND udf_template_id = @udf_template_id)
	BEGIN
		INSERT INTO application_ui_template_fields(application_group_id, application_ui_field_id, hidden, field_type, udf_template_id)
		SELECT @application_group_id, @application_ui_field_id, 'n', 'input', @udf_template_id	
	END 
END
---------------------------------------------------END Tesoro GSI Group------------------------------------------------------------------------------------


---------------------------------------------------Start Facility------------------------------------------------------------------------------------
SET @value_name = 'Facility'
SET @value_id = -5689

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5689)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5689, 5500, 'Facility', 'Facility', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5689 - Facility.'
END
ELSE
BEGIN
	PRINT 'Static data value -5689 - Facility already EXISTS.'
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

IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition WHERE application_function_id = 10102500 AND field_id =  @udf_field_id)
BEGIN
	INSERT INTO application_ui_template_definition(application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail
												, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag
												, update_required, has_round_option, create_user, create_ts, update_user, update_ts, blank_option, is_primary
												, is_udf, is_identity, text_row_num, hyperlink_function, char_length)
	SELECT 10102500, @udf_field_id, @udf_field_id, @value_name, 'input', 'varchar', 'h', 'n', ''
		, 150, 'n',	'n', NULL, 'n',	'n', 'n', 'n', NULL, NULL, NULL, NULL, 'n',	'n', 'y', 'n', NULL, NULL, NULL
		
	SELECT @application_ui_field_id = IDENT_CURRENT('application_ui_template_definition')

	SELECT @application_group_id = autg.application_group_id 
	FROM application_ui_template aui 
	INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id  = aui.application_ui_template_id 
	WHERE application_function_id = 10102500
		AND group_name = 'Additional'

	-- select * from application_ui_template_fields
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_fields WHERE application_ui_field_id = @application_ui_field_id AND udf_template_id = @udf_template_id)
	BEGIN
		INSERT INTO application_ui_template_fields(application_group_id, application_ui_field_id, hidden, field_type, udf_template_id)
		SELECT @application_group_id, @application_ui_field_id, 'n', 'input', @udf_template_id	
	END
END
---------------------------------------------------END Facility------------------------------------------------------------------------------------




