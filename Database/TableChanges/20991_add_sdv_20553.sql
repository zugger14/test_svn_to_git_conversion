SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20553)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20553, 20500, 'Post Deal Match', 'Post Deal Match', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20553 - Post Deal Match.'
END
ELSE
BEGIN
    PRINT 'Static data value 20553 - Post Deal Match already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF