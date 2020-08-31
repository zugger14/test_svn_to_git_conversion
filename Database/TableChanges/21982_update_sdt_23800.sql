UPDATE static_data_type
SET [type_name] = 'Regression Group',
    [description] = 'Regression Group',
    [internal] = 0, 
    [is_active] = 1
WHERE [type_id] = 23800
PRINT 'Updated static data type 23800 - Regression Group.'