SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5612)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (5612, 5600, 'Initial Risk Review', 'Initial Risk Review', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 5612 - Initial Risk Review.'
END
ELSE
BEGIN
	PRINT 'Static data value 5612 - Initial Risk Review already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5613)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (5613, 5600, 'Final Risk Review', 'Final Risk Review', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 5613 - Final Risk Review.'
END
ELSE
BEGIN
	PRINT 'Static data value 5613 - Final Risk Review already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF