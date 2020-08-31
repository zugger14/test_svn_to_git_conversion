SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 997)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (978, 997, 'Monthly Hourly', 'Monthly Hourly', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 997 - Monthly Hourly.'
END
ELSE
BEGIN
    PRINT 'Static data value 997 - Monthly Hourly already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000289)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (978, 10000289, 'TOU Monthly', 'TOU Monthly', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000289 - TOU Monthly.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000289 - TOU Monthly already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO