UPDATE static_data_value
    SET [code] = 'Point-Point',
        [category_id] = NULL,
        [description] = '1'
    WHERE [value_id] = -31400
PRINT 'Updated Static value -31400 - Point-Point.' 