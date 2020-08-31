UPDATE static_data_value
    SET [code] = 'First Day of the Quarter',
        [category_id] = NULL
    WHERE [value_id] = 45613
PRINT 'Updated Static value 45613 - First Day of the Quarter.'