--Moodys

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000222)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000222, 'Aaa', 'Aaa', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000222 - Aaa.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000222 - Aaa already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000223)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000223, 'Aa', 'Aa', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000223 - Aa.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000223 - Aa already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000224)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000224, 'A', 'A', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000224 - A.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000224 - A already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000225)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000225, 'Baa', 'Baa', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000225 - Baa.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000225 - Baa already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000226)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000226, 'Ba', 'Ba', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000226 - Ba.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000226 - Ba already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000227)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000227, 'B', 'B', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000227 - B.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000227 - B already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000228)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000228, 'Caa', 'Caa', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000228 - Caa.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000228 - Caa already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000229)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000229, 'Ca', 'Ca', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000229 - Ca.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000229 - Ca already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000230)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000230, 'C', 'C', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000230 - C.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000230 - C already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

