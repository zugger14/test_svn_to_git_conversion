--SELECT * FROM 
UPDATE application_ui_template 
SET template_type = 102804, --hybrid load
	remarks = NULL
WHERE application_function_id IN (
	SELECT function_id FROM application_functions WHERE function_name IN (
	'Setup Plant Derate/Outage'
	)
)
--'FIX API Interface' it does not have ui_template
--select * from static_data_value where type_id = 102800
--select * from application_functions where function_id = 20001100