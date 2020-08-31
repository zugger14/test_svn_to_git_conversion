IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 106200)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (106200, 'Rate Granularity', 1, 'Rate Granularity', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 106200 - Rate Granularity.'
END
ELSE
BEGIN
	PRINT 'Static data type 106200 - Rate Granularity already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106200)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106200, 106200, 'Annual', 'Annual', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106200 - Annual.'
END
ELSE
BEGIN
    PRINT 'Static data value 106200 - Annual already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106201)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106201, 106200, 'Monthly', 'Monthly', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106201 - Monthly.'
END
ELSE
BEGIN
    PRINT 'Static data value 106201 - Monthly already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106202)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106202, 106200, 'Term', 'Term', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106202 - Term.'
END
ELSE
BEGIN
    PRINT 'Static data value 106202 - Term already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106203)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106203, 106200, 'Daily', 'Daily', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106203 - Daily.'
END
ELSE
BEGIN
    PRINT 'Static data value 106203 - Daily already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF