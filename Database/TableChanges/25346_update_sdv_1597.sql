UPDATE static_data_value
    SET [code] = 'Price Corridor Limit',
        [category_id] = NULL,
        [description] = 'Price Corridor'
    WHERE [value_id] = 1597
PRINT 'Updated Static value 1597 - Price Corridor Limit.'