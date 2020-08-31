IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 105900)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (105900, 'Change Type', 1, 'Change Type', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 105900 - Change Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 105900 - Change Type already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105900)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105900, 105900, 'Name Change', 'Name Change', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105900 - Name Change.'
END
ELSE
BEGIN
    PRINT 'Static data value 105900 - Name Change already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105901)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105901, 105900, 'Novation', 'Novation', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105901 - Novation.'
END
ELSE
BEGIN
    PRINT 'Static data value 105901 - Novation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105902)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105902, 105900, 'Merger', 'Merger', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105902 - Merger.'
END
ELSE
BEGIN
    PRINT 'Static data value 105902 - Merger already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


