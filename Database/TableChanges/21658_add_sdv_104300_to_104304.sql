SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 104300)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (104300, 104300, 'CHAR', 'CHAR', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 104300 - CHAR.'
END
ELSE
BEGIN
    PRINT 'Static data value 104300 - CHAR already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 104301)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (104301, 104300, 'VARCHAR', 'VARCHAR', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 104301 - VARCHAR.'
END
ELSE
BEGIN
    PRINT 'Static data value 104301 - VARCHAR already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 104302)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (104302, 104300, 'INT', 'INT', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 104302 - INT.'
END
ELSE
BEGIN
    PRINT 'Static data value 104302 - INT already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 104303)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (104303, 104300, 'FLOAT', 'FLOAT', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 104303 - FLOAT.'
END
ELSE
BEGIN
    PRINT 'Static data value 104303 - FLOAT already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 104304)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (104304, 104300, 'DATETIME', 'DATETIME', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 104304 - DATETIME.'
END
ELSE
BEGIN
    PRINT 'Static data value 104304 - DATETIME already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF