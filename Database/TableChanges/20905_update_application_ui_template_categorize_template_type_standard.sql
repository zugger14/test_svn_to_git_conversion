--SELECT * FROM
UPDATE application_ui_template 
SET template_type = 102800,
	remarks = NULL
WHERE application_function_id IN (
	SELECT function_id FROM application_functions WHERE function_name IN (
		'Assign Priority to Nomination Group'
		,'Deal Default Value Mapping'
		,'Deal Type Pricing Mapping'
		,'Setup Contract Component Mapping'
		,'Setup Default GL Code for Contract Components'
		,'Setup Profile'
		,'Setup UOM Conversion'
	)
)
--select * from static_data_value where type_id = 102800
--select * from application_ui_template where application_function_id = 10103400
--select * from application_functions where function_id = 10103400
