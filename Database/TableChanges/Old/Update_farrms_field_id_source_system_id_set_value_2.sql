--SELECT * FROM application_ui_template_definition WHERE farrms_field_id = 'source_system_id'
UPDATE application_ui_template_definition SET default_value = 2 WHERE farrms_field_id = 'source_system_id'

update application_ui_template_definition set sql_string = 'EXEC spa_source_system_description ''s''' WHERE farrms_field_id = 'source_system_id'