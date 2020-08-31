SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20616)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20616, 20600, 'Deal Match', 'Deal Match', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20616 - Deal Match.'
END
ELSE
BEGIN
    PRINT 'Static data value 20616 - Deal Match already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF