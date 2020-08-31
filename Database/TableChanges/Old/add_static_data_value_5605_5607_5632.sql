SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5605)
BEGIN
	INSERT INTO static_data_value (value_id,[type_id],code,[description],create_user,create_ts)
	VALUES ( 5605,5600,'Validated','Validated','farrms_admin',GETDATE() )
	  
	PRINT 'Inserted static data value 5605 - Validated'
END
ELSE
BEGIN
	UPDATE static_data_value SET code = 'Validated' , [description] = 'Validated' WHERE value_id = 5605
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5632)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (5632, 5600, 'Matured', 'Matured', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 5632 - Matured.'
END
ELSE
BEGIN
	PRINT 'Static data value 5632 - Matured already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5607)
BEGIN
	INSERT INTO static_data_value (value_id,[type_id],code,[description],create_user,create_ts)
	VALUES ( 5607,5600,'Cancelled','Cancelled','farrms_admin',GETDATE() )
	  
	PRINT 'Inserted static data value 5607 - Cancelled'
END
ELSE
BEGIN
	PRINT 'Static data value 5607 - Cancelled already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF

