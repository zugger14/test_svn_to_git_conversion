--SELECT * FROM
UPDATE application_ui_template 
SET template_type = 102808,
	remarks = NULL
WHERE application_function_id IN (
	SELECT function_id FROM application_functions WHERE function_name IN (
	'Compose Email'
	,'Forecast Parameters Mapping'
	,'Setup Settlement Netting Group'
	,'Map Rate Schedules'
	,'Deal Confirmation Rule'
	,'Setup Contract Component Template'
	,'Setup Counterparty'
	,'Setup GL Codes'
	,'Setup Non-Standard Contract'
	,'Setup Standard Contract'
	,'Setup Static Data'
	,'Setup Storage Asset'
	,'Setup Transportation Contract'
	)
)
--select * from static_data_value where type_id = 102800
--select * from application_ui_template where application_function_id = 10101161
--select * from application_functions where function_id = 10101161