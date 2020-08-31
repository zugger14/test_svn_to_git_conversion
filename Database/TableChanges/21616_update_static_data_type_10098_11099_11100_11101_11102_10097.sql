UPDATE static_data_type
SET [type_name] = 'S&P',
    [description] = 'Debt Rating',
    [internal] = 1, 
    [is_active] = 1
WHERE [type_id] = 10098
PRINT 'Updated static data type 10098 - S&P.'

UPDATE static_data_type
SET [type_name] = 'Moodys',
    [description] = 'Debt Rating2',
    [internal] = 1, 
    [is_active] = 1
WHERE [type_id] = 11099
PRINT 'Updated static data type 11099 - Moodys.'

UPDATE static_data_type
SET [type_name] = 'Fitch',
    [description] = 'Debt Rating3',
    [internal] = 1, 
    [is_active] = 1
WHERE [type_id] = 11100
PRINT 'Updated static data type 11100 - Fitch.'

UPDATE static_data_type
SET [type_name] = 'D&B',
    [description] = 'Debt Rating4',
    [internal] = 1, 
    [is_active] = 1
WHERE [type_id] = 11101
PRINT 'Updated static data type 11101 - D&B.'

UPDATE static_data_type
SET [type_name] = 'Debt Rating5',
    [description] = 'Debt Rating5',
    [internal] = 1, 
    [is_active] = 1
WHERE [type_id] = 11102
PRINT 'Updated static data type 11102 - Debt Rating5.'   

UPDATE static_data_type
SET [type_name] = 'Risk Rating',
    [description] = 'Risk Rating',
    [internal] = 0, 
    [is_active] = 1
WHERE [type_id] = 10097
PRINT 'Updated static data type 10097 - Risk Rating.'    