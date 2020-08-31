SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39505)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (39505, 39500, 'EMIR Verified', 'EMIR Verified', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 39505 - EMIR Verified.'
END
ELSE
BEGIN
    PRINT 'Static data value 39505 - EMIR Verified already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39504)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (39504, 39500, 'EMIR Submitted', 'EMIR Submitted', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 39504 - EMIR Submitted.'
END
ELSE
BEGIN
    PRINT 'Static data value 39504 - EMIR Submitted already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39503)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (39503, 39500, 'EMIR Outstanding', 'EMIR Outstanding', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 39503 - EMIR Outstanding.'
END
ELSE
BEGIN
    PRINT 'Static data value 39503 - EMIR Outstanding already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO