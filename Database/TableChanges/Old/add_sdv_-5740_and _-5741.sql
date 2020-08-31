SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5740)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-5740, 5500, 'Trader3', ' Trader3', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -5740 - Trader3.'
END
ELSE
BEGIN
    PRINT 'Static data value -5740 - Trader3 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5741)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-5741, 5500, 'Trader4', ' Trader4', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -5741 - Trader4.'
END
ELSE
BEGIN
    PRINT 'Static data value -5741 - Trader4 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

