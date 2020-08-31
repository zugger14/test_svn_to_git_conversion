UPDATE static_data_type
SET [type_name] = 'Function Category',
    [description] = 'Function Category',
    [internal] = 1, 
    [is_active] = 1
WHERE [type_id] = 27400
PRINT 'Updated static data type 27400 - Function Category.'   