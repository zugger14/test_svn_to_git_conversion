IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20700)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (20700, 'Invoice Status', 1, 'Invoice Status', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20700 - Invoice Status.'
END
ELSE
BEGIN
	PRINT 'Static data type 20700 - Invoice Status already EXISTS.'
END
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20700)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20700, 20700, 'Initial', 'Initial', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20700 - Initial.'
END
ELSE
BEGIN
	PRINT 'Static data value 20700 - Initial already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20701)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20701, 20700, 'Final', 'Final', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20701 - Final.'
END
ELSE
BEGIN
	PRINT 'Static data value 20701 - Final already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20704)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20704, 20700, 'Voided', 'Voided', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20704 - Voided.'
END
ELSE
BEGIN
	PRINT 'Static data value 20704 - Voided already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


GO


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20705)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20705, 20700, 'Dispute', 'Dispute', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20705 - Dispute.'
END
ELSE
BEGIN
	PRINT 'Static data value 20705 - Dispute already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

