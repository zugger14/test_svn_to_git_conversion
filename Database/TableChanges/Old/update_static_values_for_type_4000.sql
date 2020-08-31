--Update description of all 4000 values to good format

UPDATE static_data_value SET [type_id]= 4000, [code] = 'expected_return', [description] = 'Expected Return' WHERE [value_id] = 4032 
PRINT 'Updated static data value 4032 - expected_return.'
