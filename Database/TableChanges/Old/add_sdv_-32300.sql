SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -32300)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-32300, 32200, 'Scheduler', ' Scheduler', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -32300 - Scheduler.'
END
ELSE
BEGIN
    PRINT 'Static data value -32300 - Scheduler already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF