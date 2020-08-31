UPDATE agcd 
SET agcd.field_type = 'dhxCalendarA'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE grid_name = 'transportation_rate_schedule'
	AND column_name = 'effective_date' 

GO

UPDATE adiha_grid_definition
SET grid_label = 'Rates/Fees'
WHERE grid_name = 'transportation_rate_schedule'

GO

UPDATE autd 
SET autd.field_size = 200
FROM application_ui_template_definition autd
WHERE autd.application_function_id = '10162000' 
	AND autd.farrms_field_id in ('code', 'description')

GO