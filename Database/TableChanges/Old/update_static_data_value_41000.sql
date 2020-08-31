UPDATE static_data_value
SET code = REPLACE(code, ' ', ''),
	description = REPLACE(description, ' ', '')
WHERE [type_id] = 41000 AND [value_id] <> 41000