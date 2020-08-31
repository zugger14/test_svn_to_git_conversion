UPDATE static_data_value
    SET [code] = 'Standard Workflow Data View',
        [category_id] = NULL,
        [description] = 'Workflow'
    WHERE [value_id] = 106502
PRINT 'Updated Static value 106502 - Standard Workflow Data View.'