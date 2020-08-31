IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 102800)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (102800, 'Application UI Template Type', 1, 'Application UI Template Usage Type', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 102800 - Application UI Template Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 102800 - Application UI Template Type already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 102800)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (102800, 102800, 'Full Standard', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 102800 - Full Standard.'
END
ELSE
BEGIN
    PRINT 'Static data value 102800 - Full Standard already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 102801)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (102801, 102800, 'Hybrid Save', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 102801 - Hybrid Save.'
END
ELSE
BEGIN
    PRINT 'Static data value 102801 - Hybrid Save already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 102802)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (102802, 102800, 'Hybrid Delete', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 102802 - Hybrid Delete.'
END
ELSE
BEGIN
    PRINT 'Static data value 102802 - Hybrid Delete already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 102803)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (102803, 102800, 'Hybrid Save/Delete', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 102803 - Hybrid Save/Delete.'
END
ELSE
BEGIN
    PRINT 'Static data value 102803 - Hybrid Save/Delete already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 102804)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (102804, 102800, 'Hybrid Load', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 102804 - Hybrid Load.'
END
ELSE
BEGIN
    PRINT 'Static data value 102804 - Hybrid Load already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 102805)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (102805, 102800, 'Hybrid Load/Save', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 102805 - Hybrid Load/Save.'
END
ELSE
BEGIN
    PRINT 'Static data value 102805 - Hybrid Load/Save already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 102806)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (102806, 102800, 'Hybrid Load/Delete', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 102806 - Hybrid Load/Delete.'
END
ELSE
BEGIN
    PRINT 'Static data value 102806 - Hybrid Load/Delete already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 102807)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (102807, 102800, 'Full Custom', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 102807 - Full Custom.'
END
ELSE
BEGIN
    PRINT 'Static data value 102807 - Full Custom already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF