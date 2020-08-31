SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -106000)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-106000, 106000, 'High Risk', 'High Risk', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -106000 - High Risk.'
END
ELSE
BEGIN
    PRINT 'Static data value -106000 - High Risk already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -106001)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-106001, 106000, 'Medium Risk', 'Medium Risk', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -106001 - Medium Risk.'
END
ELSE
BEGIN
    PRINT 'Static data value -106001 - Medium Risk already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -106002)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-106002, 106000, 'Low Risk', 'Low Risk', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -106002 - Low Risk.'
END
ELSE
BEGIN
    PRINT 'Static data value -106002 - Low Risk already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -106003)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-106003, 106000, 'No Risk', 'No Risk', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -106003 - No Risk.'
END
ELSE
BEGIN
    PRINT 'Static data value -106003 - No Risk already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF