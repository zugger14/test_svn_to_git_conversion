--## Static Data Type
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 106400)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], create_user, create_ts)
	VALUES (106400, 'Date Adjustment Type', 1, 'Date Adjustment Type', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 106400 - Date Adjustment Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 106400 - Date Adjustment Type already EXISTS.'
END

--## Static Data Values
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106400)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106400, 106400, 'Day', 'Day', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106400 - Day.'
END
ELSE
BEGIN
    PRINT 'Static data value 106400 - Day already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106401)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106401, 106400, 'Week', 'Week', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106401 - Week.'
END
ELSE
BEGIN
    PRINT 'Static data value 106401 - Week already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106402)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106402, 106400, 'Month', 'Month', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106402 - Month.'
END
ELSE
BEGIN
    PRINT 'Static data value 106402 - Month already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106403)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106403, 106400, 'Quarter', 'Quarter', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106403 - Quarter.'
END
ELSE
BEGIN
    PRINT 'Static data value 106403 - Quarter already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106404)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106404, 106400, 'Year', 'Year', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106404 - Year.'
END
ELSE
BEGIN
    PRINT 'Static data value 106404 - Year already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF