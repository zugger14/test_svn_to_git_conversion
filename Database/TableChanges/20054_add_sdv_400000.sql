SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 400000)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (400000, 4000, 'meter_id', 'Meter', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 400000 - meter_id.'
END
ELSE
BEGIN
    PRINT 'Static data value 400000 - meter_id already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF