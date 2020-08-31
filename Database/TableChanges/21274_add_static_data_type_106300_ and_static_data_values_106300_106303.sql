IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 106300)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (106300, 'Billing Frequency', 1, 'Billing Frequency', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 106300 - Billing Frequency.'
END
ELSE
BEGIN
	PRINT 'Static data type 106300 - Billing Frequency already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106300)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106300, 106300, 'One Time', 'One Time', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106300 - One Time.'
END
ELSE
BEGIN
    PRINT 'Static data value 106300 - One Time already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106301)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106301, 106300, 'Monthly', 'Monthly', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106301 - Monthly.'
END
ELSE
BEGIN
    PRINT 'Static data value 106301 - Monthly already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106302)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106302, 106300, 'Quarterly', 'Quarterly', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106302 - Quarterly.'
END
ELSE
BEGIN
    PRINT 'Static data value 106302 - Quarterly already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106303)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106303, 106300, 'Annually', 'Annually', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106303 - Annually.'
END
ELSE
BEGIN
    PRINT 'Static data value 106303 - Annually already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF