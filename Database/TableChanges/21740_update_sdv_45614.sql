UPDATE static_data_value
    SET [code] = 'Last Day of the Quarter',
        [category_id] = NULL
    WHERE [value_id] = 45614
PRINT 'Updated Static value 45614 - Last Day of the Quarter.'