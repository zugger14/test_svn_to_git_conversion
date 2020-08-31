IF EXISTS (SELECT 1 FROM static_data_value WHERE value_id = -11135)
BEGIN
	UPDATE static_data_value SET code = ' 2A' WHERE value_id = -11135
	PRINT 'Static Data Value is updated successfully.'
END
ELSE 
	PRINT 'Static Data Value ''2A'' is not found in the system.'