SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42003)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42003, 42000, 'Deal Required Documents', 'Deal Required Documents', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42003 - Deal Required Documents.'
END
ELSE
BEGIN
    PRINT 'Static data value 42003 - Deal Required Documents already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF

