--created date : 2015-04-23
--add internal static data type 'meter type'
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 38600)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (38600, 'Meter Type', 1, 'Meter Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 38600 - Meter Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 38600 - Meter Type already EXISTS.'
END

--insert static data values for sdt 'meter type'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 38600)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (38600, 38600, 'Injection', 'Injection', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 38600 - Injection.'
END
ELSE
BEGIN
	PRINT 'Static data value 38600 - Injection already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 38601)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (38601, 38600, 'Withdrawal', 'Withdrawal', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 38601 - Withdrawal.'
END
ELSE
BEGIN
	PRINT 'Static data value 38601 - Withdrawal already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 38602)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (38602, 38600, 'Receipt', 'Receipt', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 38602 - Receipt.'
END
ELSE
BEGIN
	PRINT 'Static data value 38602 - Receipt already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 38603)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (38603, 38600, 'Delivery', 'Delivery', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 38603 - Delivery.'
END
ELSE
BEGIN
	PRINT 'Static data value 38603 - Delivery already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF



