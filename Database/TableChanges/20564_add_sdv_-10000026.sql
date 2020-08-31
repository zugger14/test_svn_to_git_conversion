SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000026)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000026, 5500, 'Asset Class', 'Asset Class', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000026 - Asset Class.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000026 - Asset Class already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF