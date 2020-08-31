IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 46500)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (46500, 'Platform', 1, 'Platform', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 46500 - Platform.'
END
ELSE
BEGIN
	PRINT 'Static data type 46500 - Platform already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46500)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46500, 46500, 'EMIR', 'EMIR', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46500 - EMIR.'
END
ELSE
BEGIN
    PRINT 'Static data value 46500 - EMIR already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46501)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46501, 46500, 'ICE', 'ICE', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46501 - ICE.'
END
ELSE
BEGIN
    PRINT 'Static data value 46501 - ICE already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF