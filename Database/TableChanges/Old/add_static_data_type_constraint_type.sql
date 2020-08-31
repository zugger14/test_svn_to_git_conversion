IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 18600)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (18600, 'Constraint Type', 1, 'Constraint Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 18600 - Constraint Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 18600 - Constraint Type already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18601)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18601, 18600, 'Maximum Injection Capacity', 'Maximum Injection Capacity', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18601 - Maximum Injection Capacity.'
END
ELSE
BEGIN
	PRINT 'Static data value 18601 - Maximum Injection Capacity already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18602)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18602, 18600, 'Maximum Withdrawal Capacity', 'Maximum Withdrawal Capacity', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18602 - Maximum Withdrawal Capacity.'
END
ELSE
BEGIN
	PRINT 'Static data value 18602 - Maximum Withdrawal Capacity already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18603)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18603, 18600, 'Maximum Working Gas Volume', 'Maximum Working Gas Volume', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18603 - Maximum Working Gas Volume.'
END
ELSE
BEGIN
	PRINT 'Static data value 18603 - Maximum Working Gas Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

