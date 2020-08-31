IF EXISTS (SELECT 1 FROM static_data_value sdv WHERE sdv.code = 'VaR limit' AND sdv.[type_id] = 1580)
BEGIN 
	UPDATE static_data_value SET code = 'At Risk' WHERE value_id = 1584
	PRINT 'updated successfully'
END
ELSE 
	PRINT 'static value does not exist.'
	
IF EXISTS (SELECT 1 FROM static_data_value sdv WHERE sdv.code = 'Position and Tenor' AND sdv.[type_id] = 1580)
BEGIN 
	UPDATE static_data_value SET code = 'Position and Tenor limit' WHERE value_id = 1581
	PRINT 'updated successfully'
END
ELSE 
	PRINT 'static value does not exist.'