SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106502)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106502, 106500, 'Workflow', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106502 - Workflow.'
END
ELSE
BEGIN
    PRINT 'Static data value 106502 - Workflow already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106501)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106501, 106500, 'Functions', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106501 - Functions.'
END
ELSE
BEGIN
    PRINT 'Static data value 106501 - Functions already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106500)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106500, 106500, 'Report', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106500 - Report.'
END
ELSE
BEGIN
    PRINT 'Static data value 106500 - Report already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF