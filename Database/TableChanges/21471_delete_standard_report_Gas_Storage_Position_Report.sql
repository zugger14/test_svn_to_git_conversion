----------Delete Standard Report Query--------

DECLARE @function_id INT
SET @function_id = (select function_id from application_functions where function_name = 'Gas Storage Position Report')
	
DELETE aufd FROM  application_ui_template_fields AS autf
INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
INNER JOIN application_ui_filter_details aufd on aufd.application_field_id = autf.application_field_id
WHERE aut.application_function_id = @function_id
	
DELETE FROM application_ui_filter WHERE application_function_id = @function_id
DELETE FROM application_functional_users WHERE function_id = @function_id
DELETE FROM setup_menu WHERE  function_id = @function_id
EXEC spa_application_ui_template 'd', @function_id
DELETE FROM application_functions WHERE function_id = @function_id 