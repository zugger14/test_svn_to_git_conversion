SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17823)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (17800, 17823, 'EPEX Password Renew Notification', 'EPEX Password Renew Notification', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 17823 - EPEX Password Renew Notification.'
END
ELSE
BEGIN
    PRINT 'Static data value 17823 - EPEX Password Renew Notification already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17824)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (17800, 17824, 'EPEX Password Fail Notification', 'EPEX Password Fail Notification', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 17824 - EPEX Password Fail Notification.'
END
ELSE
BEGIN
    PRINT 'Static data value 17824 - EPEX Password Fail Notification already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            