SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44005)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44005, 44000, 'User defined tables', 'User defined tables', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44005 - User defined tables.'
END
ELSE
BEGIN
    PRINT 'Static data value 44005 - User defined tables already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_value
    SET code = 'User defined tables',
    [category_id] = ''
    WHERE [value_id] = 44005
PRINT 'Updated Static value 44005 - Userpp defined tables.'