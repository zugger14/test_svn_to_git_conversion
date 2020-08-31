IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'FK__maintain___maint__136ED61C' AND TYPE = 'F') --remove Foreign key
BEGIN
	ALTER TABLE maintain_udf_detail DROP CONSTRAINT FK__maintain___maint__136ED61C
END

DECLARE @value_name VARCHAR(1000) = 'Pigridcode'
DECLARE @value_id INT = 303415
-- insert operator
--static data type
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = @value_id)
BEGIN 
	SET IDENTITY_INSERT static_data_value ON 
	INSERT INTO static_data_value(value_id
								, type_id
								, code
								, description)
	SELECT @value_id, 5500, @value_name, @value_name
	SET IDENTITY_INSERT static_data_value OFF
END

--user_defined_fields_template
IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = @value_name)
BEGIN 
	INSERT INTO user_defined_fields_template(field_name
											, Field_label
											, Field_type
											, data_type
											, is_required
											, udf_type
											, field_size
											, field_id
											, sql_string)
	SELECT @value_id, @value_name, 't', 'varchar(MAX)', 'n', 'h', 120, @value_id, ''
END 


DECLARE @udf_template_id INT
DECLARE @udf_field_id VARCHAR(1000)
--SELECT @udf_template_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = @value_name
SELECT @udf_template_id = udf_template_id , @udf_field_id = 'udf_' + CAST(ABS(field_name) AS VARCHAR(20)) FROM user_defined_fields_template WHERE Field_label = @value_name


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
END

DECLARE @maintain_udf_detail INT 
SELECT @maintain_udf_detail = IDENT_CURRENT('maintain_udf_detail')
--SELECT IDENT_CURRENT('maintain_udf_detail')

-- select * from maintain_udf_detail_values
IF NOT EXISTS(SELECT 1 FROM maintain_udf_detail_values WHERE application_field_id = @maintain_udf_detail AND module_object_id = @value_id)
BEGIN
	INSERT INTO maintain_udf_detail_values(application_field_id	,module_object_id,	udf_values)
	SELECT @maintain_udf_detail, @value_id,	NULL
END 


DECLARE @application_ui_field_id INT 
SELECT @application_ui_field_id = application_ui_field_id FROM application_ui_template_definition WHERE field_id = 'Pigridcode' AND farrms_field_id = 'Pigridcode' AND default_label = 'Pigridcode'
DELETE FROM application_ui_template_fields WHERE application_ui_field_id = @application_ui_field_id
DELETE FROM application_ui_template_definition WHERE application_ui_field_id = @application_ui_field_id

-- select * from application_ui_template_definition
IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition WHERE application_function_id = 10103000 AND field_id = @udf_field_id)
BEGIN
	INSERT INTO application_ui_template_definition(application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail
												, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag
												, update_required, has_round_option, create_user, create_ts, update_user, update_ts, blank_option, is_primary
												, is_udf, is_identity, text_row_num, hyperlink_function, char_length)
	SELECT 10103000, @udf_field_id, @udf_field_id, @value_name, 'input', 'int', 'h', 'n', ''
		, 200, 'n',	'n', NULL, 'n',	'n', 'n', 'n', NULL, NULL, NULL, NULL, 'n',	'n', 'y', 'n', NULL, NULL, NULL


	DECLARE @application_group_id INT 
	SELECT @application_ui_field_id = IDENT_CURRENT('application_ui_template_definition')

	SELECT @application_group_id = autg.application_group_id 
	FROM application_ui_template aui 
	INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id  = aui.application_ui_template_id 
	WHERE application_function_id = 10103000
		AND group_name = 'General'

	-- select * from application_ui_template_fields
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_fields WHERE application_ui_field_id = @application_ui_field_id AND udf_template_id = @udf_template_id)
	BEGIN
		INSERT INTO application_ui_template_fields(application_group_id, application_ui_field_id, hidden, field_type, udf_template_id, sequence)
		SELECT @application_group_id, @application_ui_field_id, 'n', 'input', @udf_template_id,5
	END
END


UPDATE application_ui_template_definition
SET field_id = @udf_field_id, 
	farrms_field_id = @udf_field_id
WHERE field_id = 'Pigridcode'
	AND application_function_id = 10103000

GO

