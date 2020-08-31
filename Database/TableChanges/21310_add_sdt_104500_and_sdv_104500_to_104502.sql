IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 104500)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (104500, 'Fx Option Type', 1, '', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 104500 - Fx Option Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 104500 - Fx Option Type already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 104502)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (104502, 104500, 'Payment Date', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 104502 - Payment Date.'
END
ELSE
BEGIN
    PRINT 'Static data value 104502 - Payment Date already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 104501)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (104501, 104500, 'Invoice Date', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 104501 - Invoice Date.'
END
ELSE
BEGIN
    PRINT 'Static data value 104501 - Invoice Date already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 104500)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (104500, 104500, 'Average over delivery period', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 104500 - Average over delivery period.'
END
ELSE
BEGIN
    PRINT 'Static data value 104500 - Average over delivery period already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF