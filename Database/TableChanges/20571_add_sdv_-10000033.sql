SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000033)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000033, 5500, 'Clearing Obligation', 'Clearing Obligation', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000033 - Clearing Obligation.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000033 - Clearing Obligation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF