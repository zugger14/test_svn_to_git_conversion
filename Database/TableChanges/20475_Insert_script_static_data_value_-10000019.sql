SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000019)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000019, 5500, 'Financial/Non-Financial', 'Financial/Non-Financial', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000019 - Financial/Non-Financial.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000019 - Financial/Non-Financial already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


UPDATE static_data_value
    SET code = 'Financial/Non-Financial',
    [category_id] = ''
    WHERE [value_id] = -10000019
PRINT 'Updated Static value -10000019 - Financial/Non-Financial.'