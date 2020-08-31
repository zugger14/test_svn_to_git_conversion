--SELECT * FROM
UPDATE application_ui_template 
SET template_type = 102815,--save/delete/load complete
	remarks = NULL
WHERE application_function_id IN (
	SELECT function_id FROM application_functions WHERE function_name IN (
	'Setup Role'
	,'Setup User'
	)
)