SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44702)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44702, 44700, 'REMIT', 'REMIT', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44702 - REMIT.'
END
ELSE
BEGIN
    PRINT 'Static data value 44702 - REMIT already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44703)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44703, 44700, 'EMIR', 'EMIR', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44703 - EMIR.'
END
ELSE
BEGIN
    PRINT 'Static data value 44703 - EMIR already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44704)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44704, 44700, 'MiFID', 'MiFID', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44704 - MiFID.'
END
ELSE
BEGIN
    PRINT 'Static data value 44704 - MiFID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO