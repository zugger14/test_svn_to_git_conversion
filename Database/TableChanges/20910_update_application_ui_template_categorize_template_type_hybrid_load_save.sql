--SELECT * FROM 
UPDATE application_ui_template 
SET template_type = 102805
WHERE application_function_id IN (
	SELECT function_id FROM application_functions WHERE function_name IN (
	'Customize Menu'
	,'Form Builder' --not available
	,'Maintain Manual Journal Entries'
	,'Setup Forecast Model'
	,'Template Field Mapping'
	)
)
----select * from static_data_value where type_id = 102800
--select * from application_ui_template where application_function_id = 20004900
--select * from application_functions where function_id = 20004900