

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44700)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44700, 44700, 'Acer', ' Acer', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44700 - Acer.'
END
ELSE
BEGIN
    PRINT 'Static data value 44700 - Acer already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44701)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44701, 44700, 'ICE Trade Vault', ' ICE Trade Vault', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44701 - ICE Trade Vault.'
END
ELSE
BEGIN
    PRINT 'Static data value 44701 - ICE Trade Vault already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

