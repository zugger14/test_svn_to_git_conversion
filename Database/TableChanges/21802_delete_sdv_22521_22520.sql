IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22521 AND type_id = 22500)
BEGIN
	DELETE FROM static_data_value WHERE value_id = 22521 AND type_id = 22500
	PRINT 'Static Data Value 22521 - Regression Type Calculation deleted.'
END

IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22520 AND type_id = 22500)
BEGIN
	DELETE FROM static_data_value WHERE value_id = 22520 AND type_id = 22500
	PRINT 'Static Data Value 22520 -Report Manager Report deleted.'
END