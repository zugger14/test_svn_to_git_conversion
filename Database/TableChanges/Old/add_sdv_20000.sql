IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (20000, 'Payment Cashflow Calendar', 1, 'Payment Cashflow Calendar', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20000 - Payment Cashflow Calendar.'
END
ELSE
BEGIN
	PRINT 'Static data type 20000 - Payment Cashflow Calendar already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20000)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20000, 20000, 'Month +1: Calendar day 20th', 'Month +1: Calendar day 20th', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20000 - Month +1: Calendar day 20th.'
END
ELSE
BEGIN
	PRINT 'Static data value 20000 - Month +1: Calendar day 20th already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_type SET [type_name] = 'Payment Cashflow Calendar', [description] = 'Payment Cashflow Calendar' WHERE [type_id] = 20000
PRINT 'Updated Static data type 20000 - Payment Cashflow Calendar.'


IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (20000, 'Payment Cashflow Calendar', 1, 'Payment Cashflow Calendar', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20000 - Payment Cashflow Calendar.'
END
ELSE
BEGIN
	PRINT 'Static data type 20000 - Payment Cashflow Calendar already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20001)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20001, 20000, 'Month +1: Working day 5', 'Month +1: Working day 5', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20001 - Month +1: Working day 5.'
END
ELSE
BEGIN
	PRINT 'Static data value 20001 - Month +1: Working day 5 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_type SET [type_name] = 'Payment Cashflow Calendar', [description] = 'Payment Cashflow Calendar' WHERE [type_id] = 20000
PRINT 'Updated Static data type 20000 - Payment Cashflow Calendar.'
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (20000, 'Payment Cashflow Calendar', 1, 'Payment Cashflow Calendar', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20000 - Payment Cashflow Calendar.'
END
ELSE
BEGIN
	PRINT 'Static data type 20000 - Payment Cashflow Calendar already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20002)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20002, 20000, 'Month +0: Working day 1', 'Month +0: Working day 1', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20002 - Month +0: Working day 1.'
END
ELSE
BEGIN
	PRINT 'Static data value 20002 - Month +0: Working day 1 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_type SET [type_name] = 'Payment Cashflow Calendar', [description] = 'Payment Cashflow Calendar' WHERE [type_id] = 20000
PRINT 'Updated Static data type 20000 - Payment Cashflow Calendar.'

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (20000, 'Payment Cashflow Calendar', 1, 'Payment Cashflow Calendar', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20000 - Payment Cashflow Calendar.'
END
ELSE
BEGIN
	PRINT 'Static data type 20000 - Payment Cashflow Calendar already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20003)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20003, 20000, 'Month +0: Working day -5', 'Month +0: Working day -5', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20003 - Month +0: Working day -5.'
END
ELSE
BEGIN
	PRINT 'Static data value 20003 - Month +0: Working day -5 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_type SET [type_name] = 'Payment Cashflow Calendar', [description] = 'Payment Cashflow Calendar' WHERE [type_id] = 20000
PRINT 'Updated Static data type 20000 - Payment Cashflow Calendar.'


IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (20000, 'Payment Cashflow Calendar', 1, 'Payment Cashflow Calendar', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20000 - Payment Cashflow Calendar.'
END
ELSE
BEGIN
	PRINT 'Static data type 20000 - Payment Cashflow Calendar already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20004)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20004, 20000, 'Month +1: Working day -12', 'Month +1: Working day -12', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20004 - Month +1: Working day -12.'
END
ELSE
BEGIN
	PRINT 'Static data value 20004 - Month +1: Working day -12 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_type SET [type_name] = 'Payment Cashflow Calendar', [description] = 'Payment Cashflow Calendar' WHERE [type_id] = 20000
PRINT 'Updated Static data type 20000 - Payment Cashflow Calendar.'
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (20000, 'Payment Cashflow Calendar', 1, 'Payment Cashflow Calendar', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20000 - Payment Cashflow Calendar.'
END
ELSE
BEGIN
	PRINT 'Static data type 20000 - Payment Cashflow Calendar already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20005)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20005, 20000, 'Month +1: Working day -6', 'Month +1: Working day -6', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20005 - Month +1: Working day -6.'
END
ELSE
BEGIN
	PRINT 'Static data value 20005 - Month +1: Working day -6 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_type SET [type_name] = 'Payment Cashflow Calendar', [description] = 'Payment Cashflow Calendar' WHERE [type_id] = 20000
PRINT 'Updated Static data type 20000 - Payment Cashflow Calendar.'
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (20000, 'Payment Cashflow Calendar', 1, 'Payment Cashflow Calendar', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20000 - Payment Cashflow Calendar.'
END
ELSE
BEGIN
	PRINT 'Static data type 20000 - Payment Cashflow Calendar already EXISTS.'
END



SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20006)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20006, 20000, 'No Payment', 'No Payment', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20005 No Payment.'
END
ELSE
BEGIN
	PRINT 'Static data value 20006 No Payment already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

