SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5728)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (5728, 5500, 'No of Days', ' no of days text field ', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 5728 - No of Days.'
END
ELSE
BEGIN
    PRINT 'Static data value 5728 - No of Days already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF