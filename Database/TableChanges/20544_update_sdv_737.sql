UPDATE static_data_value
    SET code = 'Ignored',
    [category_id] = ''
    WHERE [value_id] = 737
PRINT 'Updated Static value 737 - Ignored.'