--SELECT * FROM 
UPDATE application_ui_template 
SET template_type = 102812, --save/load complete
	remarks = NULL
WHERE application_function_id IN (
	SELECT function_id FROM application_functions WHERE function_name IN (
	'Setup Price Curve',
	'Setup Alerts'
	)
)