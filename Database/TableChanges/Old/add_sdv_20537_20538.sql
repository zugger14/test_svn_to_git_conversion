SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20537)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20537, 20500, 'Deal - Post Insert and Update', ' Deal - Post Insert And Update', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20537 - Deal - Post Insert and Update.'
END
ELSE
BEGIN
    PRINT 'Static data value 20537 - Deal - Post Insert and Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20538)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20538, 20500, 'Not Required', ' Not Required', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20538 - Not Required.'
END
ELSE
BEGIN
    PRINT 'Static data value 20538 - Not Required already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO