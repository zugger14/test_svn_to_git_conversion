SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -27)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-27, 25, 'Credit Exposure', 'Credit Exposure', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -27 - Credit Exposure.'
END
ELSE
BEGIN
    PRINT 'Static data value -27 - Credit Exposure already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF