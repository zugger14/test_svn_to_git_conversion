SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 735)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (735, 725, 'Success', ' Success', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 735 - Success.'
END
ELSE
BEGIN
    PRINT 'Static data value 735 - Success already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 736)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (736, 725, 'Failure', ' Failure', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 736 - Failure.'
END
ELSE
BEGIN
    PRINT 'Static data value 736 - Failure already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO