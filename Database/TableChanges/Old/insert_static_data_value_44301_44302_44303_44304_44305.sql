SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44301)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44301, 44300, 'Price', ' Price', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44301 - Price.'
END
ELSE
BEGIN
    PRINT 'Static data value 44301 - Price already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44302)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44302, 44300, 'Packaging', ' Packaging', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44302 - Packaging.'
END
ELSE
BEGIN
    PRINT 'Static data value 44302 - Packaging already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44303)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44303, 44300, 'Quantity', ' Quantity', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44303 - Quantity.'
END
ELSE
BEGIN
    PRINT 'Static data value 44303 - Quantity already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44304)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44304, 44300, 'Weight', ' Weight', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44304 - Weight.'
END
ELSE
BEGIN
    PRINT 'Static data value 44304 - Weight already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF



SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44305)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44305, 44300, 'Density', ' Density', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44305 - Density.'
END
ELSE
BEGIN
    PRINT 'Static data value 44305 - Density already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF