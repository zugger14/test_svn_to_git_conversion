IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 46600)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts, is_active)
	VALUES (46600, 'Confirmation Type', 1, 'Confirmation Type', 'farrms_admin', GETDATE(), 1)
	PRINT 'Inserted static data type 46600 - Confirmation Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 46600 - Confirmation Type already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46602)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46602, 46600, 'SDR', 'SDR', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46602 - SDR.'
END
ELSE
BEGIN
    PRINT 'Static data value 46602 - SDR already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46601)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46601, 46600, 'Paper confirm', 'Paper confirm', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46601 - Paper confirm.'
END
ELSE
BEGIN
    PRINT 'Static data value 46601 - Paper confirm already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46600)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46600, 46600, 'Econfirm', 'Econfirm', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46600 - Econfirm.'
END
ELSE
BEGIN
    PRINT 'Static data value 46600 - Econfirm already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF