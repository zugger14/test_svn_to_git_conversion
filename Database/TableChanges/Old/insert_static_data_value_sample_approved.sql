SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5634)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (5634, 5600, 'Sample Approved', ' Sample Approved', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 5634 - Sample Approved.'
END
ELSE
BEGIN
    PRINT 'Static data value 5634 - Sample Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF