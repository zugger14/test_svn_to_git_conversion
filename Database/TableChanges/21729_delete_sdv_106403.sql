IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106403 AND type_id = 106400)
BEGIN
	DELETE FROM static_data_value WHERE value_id = 106403 AND type_id = 106400
	PRINT 'Static Data Value 106403 - Quarterly deleted.'
END