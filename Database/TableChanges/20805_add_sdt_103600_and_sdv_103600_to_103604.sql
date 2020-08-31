IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 103600)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (103600, 'Complex Pricing Type', 1, 'Complex Pricing Type', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 103600 - Complex Pricing Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 103600 - Complex Pricing Type already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 103600)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (103600, 103600, 'Fixed Price', 'Fixed Price', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 103600 - Fixed Price.'
END
ELSE
BEGIN
    PRINT 'Static data value 103600 - Fixed Price already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 103601)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (103601, 103600, 'Indexed', 'Indexed', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 103601 - Indexed.'
END
ELSE
BEGIN
    PRINT 'Static data value 103601 - Indexed already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 103602)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (103602, 103600, 'Formula', 'Formula', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 103602 - Formula.'
END
ELSE
BEGIN
    PRINT 'Static data value 103602 - Formula already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 103603)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (103603, 103600, 'Event', 'Event', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 103603 - Event.'
END
ELSE
BEGIN
    PRINT 'Static data value 103603 - Event already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 103604)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (103604, 103600, 'Hybrid', 'Hybrid', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 103604 - Hybrid.'
END
ELSE
BEGIN
    PRINT 'Static data value 103604 - Hybrid already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF