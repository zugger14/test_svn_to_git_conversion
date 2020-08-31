--SELECT * FROM 
UPDATE application_ui_template 
SET template_type = 102801,
	remarks = NULL
WHERE application_function_id IN (
	SELECT function_id FROM application_functions WHERE function_name IN (	
	'Setup Meter'	
	)
)
--select * from static_data_value where type_id = 102800
--select * from application_ui_template where application_function_id = 10122500
--select * from application_functions where function_id = 10122500