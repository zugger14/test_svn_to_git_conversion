SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000032)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000032, 5500, 'Confirmation Timestamp', 'Confirmation Timestamp', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000032 - Confirmation Timestamp.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000032 - Confirmation Timestamp already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF