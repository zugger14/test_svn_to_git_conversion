UPDATE static_data_value
    SET code = 'Standard Node Type',
    [category_id] = ''
    WHERE [value_id] = -100000
PRINT 'Updated Static value -100000 - Standard Node Type.'