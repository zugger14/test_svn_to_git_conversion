
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1600)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (1600, 1600, 'Average Contract', 'Average Contract', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 1600 - Average Contract.'
END
ELSE
BEGIN
	UPDATE static_data_value SET code='Average Contract', [description]='Average Contract' WHERE value_id=1600
	PRINT 'Static data value 1600 - Average Contract already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1606)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (1606, 1600, 'Average Market', 'Average Market', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 1606 - Average Market.'
END
ELSE
BEGIN
	PRINT 'Static data value 1606 - Average Market already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1607)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (1607, 1600, 'Average Both', 'Average Both', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 1607 - Average Both.'
END
ELSE
BEGIN
	PRINT 'Static data value 1607 - Average Both already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SELECT * FROM static_data_value sdv WHERE sdv.type_id=1600