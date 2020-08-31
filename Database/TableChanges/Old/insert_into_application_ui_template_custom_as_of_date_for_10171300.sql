IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition WHERE field_id = 'custom_as_of_date_field' AND application_function_id = 10171300) 
BEGIN
	INSERT INTO application_ui_template_definition(application_function_id, field_id, farrms_field_id, default_label, field_type, is_hidden, default_value, data_flag)
	VALUES(10171300, 'custom_as_of_date_field', 'custom_as_of_date_field', 'Custom As Of Date', 'input','y', 1, 'n')
END

DECLARE @application_ui_field_id INT
DECLARE @application_group_id INT

SELECT @application_ui_field_id = application_ui_field_id 
FROM application_ui_template_definition 
WHERE field_id = 'custom_as_of_date_field' 
	AND application_function_id = 10171300

SELECT @application_group_id = application_group_id
FROM application_ui_template_group
WHERE application_ui_template_id = (
	SELECT application_ui_template_id
	FROM application_ui_template
	WHERE application_function_id = 10171300
)

IF NOT EXISTS(SELECT 1 FROM application_ui_template_fields WHERE application_ui_field_id = @application_ui_field_id) 
BEGIN
	INSERT INTO application_ui_template_fields (application_group_id, application_ui_field_id, field_alias, Default_value, default_format, validation_flag, hidden, field_type)
	VALUES(@application_group_id, @application_ui_field_id, '', 'deal_date_to', '', '', 'y', 'input')	
END
