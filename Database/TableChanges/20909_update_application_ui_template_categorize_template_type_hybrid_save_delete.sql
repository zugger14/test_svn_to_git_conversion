--SELECT * FROM
UPDATE application_ui_template 
SET template_type = 102803,--save/delete
	remarks = NULL
WHERE application_function_id IN (
	SELECT function_id FROM application_functions WHERE function_name IN (
	'Setup Location'
	)
)
--select * from static_data_value where type_id = 102800