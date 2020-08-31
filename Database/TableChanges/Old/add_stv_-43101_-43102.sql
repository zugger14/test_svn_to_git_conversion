SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -43102)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-43102, 43100, 'Shipment Instructions Requested', ' Shipment Instructions Requested', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -43102 - Shipment Instructions Requested.'
END
ELSE
BEGIN
    PRINT 'Static data value -43102 - Shipment Instructions Requested already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -43101)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-43101, 43100, 'Label Approved', ' Label Approved', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -43101 - Label Approved.'
END
ELSE
BEGIN
    PRINT 'Static data value -43101 - Label Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

