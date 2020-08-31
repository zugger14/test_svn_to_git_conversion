UPDATE static_data_value
    SET [code] = 'Module Events',
        [category_id] = NULL,
        [description] = 'Event Trigger'
    WHERE [value_id] = 42101
PRINT 'Updated Static value 42101 - Event Trigger.'