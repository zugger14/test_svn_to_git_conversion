UPDATE static_data_value
    SET [code] = 'Name',
        [category_id] = NULL,
        [description] = 'Rule'
    WHERE [value_id] = 42102
PRINT 'Updated Static value 42102 - Rule.'