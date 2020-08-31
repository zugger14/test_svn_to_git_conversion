SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000139)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000139, 5500, 'Begining Balance', 'Begining Balance', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000139 - Begining Balance.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000139 - Begining Balance already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000140)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000140, 5500, 'Ending Balance', 'Ending Balance', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000140 - Ending Balance.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000140 - Ending Balance already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF