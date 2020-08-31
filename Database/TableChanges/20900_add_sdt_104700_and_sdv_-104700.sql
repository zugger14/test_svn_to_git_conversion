IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 104700)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (104700, 'Dashboard Category', 0, 'Dashboard Category', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 104700 - Dashboard Category.'
END
ELSE
BEGIN
	PRINT 'Static data type 104700 - Dashboard Category already EXISTS.'
END


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -104700)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-104700, 104700, 'Deal', 'Deal', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -104700 - Deal.'
END
ELSE
BEGIN
    PRINT 'Static data value -104700 - Deal already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF