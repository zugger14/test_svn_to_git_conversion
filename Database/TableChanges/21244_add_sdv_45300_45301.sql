SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45300)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (45300, 45300, 'Owner', 'Owner', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45300 - Owner.'
END
ELSE
BEGIN
    PRINT 'Static data value 45300 - Owner already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45301)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (45301, 45300, 'Leaser', 'Leaser', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45301 - Leaser.'
END
ELSE
BEGIN
    PRINT 'Static data value 45301 - Leaser already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF