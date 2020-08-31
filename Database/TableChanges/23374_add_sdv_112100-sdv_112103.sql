
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112100)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112100, 112100, 'Outstanding', 'Outstanding', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112100 - Outstanding.'
END
ELSE
BEGIN
    PRINT 'Static data value 112100 - Outstanding already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112101)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112100, 112101, 'Error', 'Error', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112101 - Error.'
END
ELSE
BEGIN
    PRINT 'Static data value 112101 - Error already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112102)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112100, 112102, 'Delivered', 'Delivered', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112102 - Delivered.'
END
ELSE
BEGIN
    PRINT 'Static data value 112102 - Delivered already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112103)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112100, 112103, 'Transferred', 'Transferred', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112103 - Transferred.'
END
ELSE
BEGIN
    PRINT 'Static data value 112103 - Transferred already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF