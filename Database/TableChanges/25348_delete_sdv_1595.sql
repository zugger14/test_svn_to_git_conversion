IF EXISTS(SELECT 1 FROM static_data_value WHERE type_id = 1580 AND value_id = 1595)
BEGIN
	DELETE FROM static_data_value where type_id = 1580 AND value_id = 1595
END
GO