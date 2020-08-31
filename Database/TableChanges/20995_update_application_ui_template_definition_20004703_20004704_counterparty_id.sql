-- Temporarily created to avoid removal of application filters for form to ignore user data

declare @app_func_id int
SET @app_func_id = 20004703
update application_ui_template_fields 
	set field_type = 'browser', 
		grid_id = 'browse_counterparty' where application_ui_field_id = (select application_ui_field_id from application_ui_template_definition where field_id like 'counterparty_id%' and application_function_id = @app_func_id and field_type = 'combo') AND field_type = 'combo'


update application_ui_template_definition 
	set field_type = 'browser', 
		sql_string= NULL,
		data_type = 'varchar' where field_id like 'counterparty_id%' and application_function_id = @app_func_id and field_type = 'combo'


SET @app_func_id = 20004704
update application_ui_template_fields 
	set field_type = 'browser', 
		grid_id = 'browse_counterparty' where application_ui_field_id = (select application_ui_field_id from application_ui_template_definition where field_id like 'counterparty_id%' and application_function_id = @app_func_id and field_type = 'combo') AND field_type = 'combo'


update application_ui_template_definition 
	set field_type = 'browser', 
		sql_string= NULL,
		data_type = 'varchar' where field_id like 'counterparty_id%' and application_function_id = @app_func_id and field_type = 'combo'
GO