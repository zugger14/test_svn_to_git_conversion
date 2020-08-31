SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46700)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46700, 46700, 'Fixed Priced', 'Fixed Priced', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46700 - Fixed Priced.'
END
ELSE
BEGIN
    PRINT 'Static data value 46700 - Fixed Priced already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46701)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46701, 46700, 'Indexed', 'Indexed', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46701 - Indexed.'
END
ELSE
BEGIN
    PRINT 'Static data value 46701 - Indexed already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46702)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46702, 46700, 'Formula', 'Formula', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46702 - Formula.'
END
ELSE
BEGIN
    PRINT 'Static data value 46702 - Formula already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46703)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46703, 46700, 'Hybrid(all)', 'Hybrid(all)', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46703 - Hybrid(all).'
END
ELSE
BEGIN
    PRINT 'Static data value 46703 - Hybrid(all) already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46704)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46704, 46700, 'Fixed Float', 'Fixed Float', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46704 - Fixed Float.'
END
ELSE
BEGIN
    PRINT 'Static data value 46704 - Fixed Float already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46705)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46705, 46700, 'Float Float', 'Float Float', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46705 - Float Float.'
END
ELSE
BEGIN
    PRINT 'Static data value 46705 - Float Float already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46706)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46706, 46700, 'Tiered', 'Tiered', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46706 - Tiered.'
END
ELSE
BEGIN
    PRINT 'Static data value 46706 - Tiered already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF