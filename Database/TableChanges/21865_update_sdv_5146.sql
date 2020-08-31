UPDATE static_data_value
    SET [code] = 'RPS',
        [category_id] = NULL
    WHERE [value_id] = 5146
PRINT 'Updated Static value 5146 - RPS.'