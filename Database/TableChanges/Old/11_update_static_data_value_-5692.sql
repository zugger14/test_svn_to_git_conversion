IF EXISTS (SELECT 1 FROM static_data_value WHERE value_id = -5692 )
BEGIN
	UPDATE static_data_value SET code = 'EIC', description = 'EIC' WHERE value_id = -5692
END 

IF EXISTS (SELECT 1 FROM static_data_value WHERE value_id = -5694 )
BEGIN
	UPDATE static_data_value SET code = 'TSO Gas', description = 'TSO Gas' WHERE value_id = -5694
END 

