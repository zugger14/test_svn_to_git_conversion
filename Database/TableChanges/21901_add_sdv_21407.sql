SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21407)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (21407, 21400, 'CLR Functions', 'CLR Functions', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 21407 - CLR Functions.'
END
ELSE
BEGIN
    PRINT 'Static data value 21407 - CLR Functions already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF