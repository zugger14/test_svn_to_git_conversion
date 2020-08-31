IF EXISTS(SELECT 1 FROM static_data_value where value_id = 46 AND [type_id] = 25)
BEGIN
	DELETE FROM application_notes where internal_type_value_id = 46
	DELETE FROM static_data_value where value_id = 46 AND [type_id] = 25
END