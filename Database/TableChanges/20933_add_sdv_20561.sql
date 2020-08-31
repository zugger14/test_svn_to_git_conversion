SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20561)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20561, 20500, 'EOD Process', 'EOD Process', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20561 - EOD Process.'
END
ELSE
BEGIN
    PRINT 'Static data value 20561 - EOD Process already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF