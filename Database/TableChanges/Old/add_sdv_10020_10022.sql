SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10020)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (10020, 10020, 'Agent', 'Agent', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 10020 - Agent.'
END
ELSE
BEGIN
	PRINT 'Static data value 10020 - Agent already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10021)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (10021, 10020, 'Accounting Party', 'Accounting Party', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 10021 - Accounting Party.'
END
ELSE
BEGIN
	PRINT 'Static data value 10021 - Accounting Party already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10022)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (10022, 10020, 'Confirming Party', 'Confirming Party', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 10022 - Confirming Party.'
END
ELSE
BEGIN
	PRINT 'Static data value 10022 - Confirming Party already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF