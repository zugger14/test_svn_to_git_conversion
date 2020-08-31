SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105800)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105800, 105800, 'Netting', 'Netting', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105800 - Netting.'
END
ELSE
BEGIN
    PRINT 'Static data value 105800 - Netting already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105801)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105801, 105800, 'Master', 'Master', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105801 - Master.'
END
ELSE
BEGIN
    PRINT 'Static data value 105801 - Master already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105802)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105802, 105800, 'CSA', 'CSA', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105802 - CSA.'
END
ELSE
BEGIN
    PRINT 'Static data value 105802 - CSA already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105803)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105803, 105800, 'Other ', 'Other ', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105803 - Other .'
END
ELSE
BEGIN
    PRINT 'Static data value 105803 - Other  already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105804)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105804, 105800, 'Agreements ', 'Agreements ', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105804 - Agreements .'
END
ELSE
BEGIN
    PRINT 'Static data value 105804 - Agreements  already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

