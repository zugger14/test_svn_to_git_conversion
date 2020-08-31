SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5603)
BEGIN
	INSERT INTO static_data_value (value_id,[type_id],code,[description],create_user,create_ts)
	VALUES ( 5603,5600,'Pending','Pending','farrms_admin',GETDATE() )
	  
	PRINT 'Inserted static data value 5603 - Pending'
END
ELSE
BEGIN
	PRINT 'Static data value 5603 - Pending already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5604)
BEGIN
	INSERT INTO static_data_value (value_id,[type_id],code,[description],create_user,create_ts)
	VALUES ( 5604,5600,'New','New','farrms_admin',GETDATE() )
	  
	PRINT 'Inserted static data value 5604 - New'
END
ELSE
BEGIN
	PRINT 'Static data value 5604 - New already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5605)
BEGIN
	INSERT INTO static_data_value (value_id,[type_id],code,[description],create_user,create_ts)
	VALUES ( 5605,5600,'Validated','Validated','farrms_admin',GETDATE() )
	  
	PRINT 'Inserted static data value 5605 - Validated'
END
ELSE
BEGIN
	PRINT 'Static data value 5605 - Validated already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5606)
BEGIN
	INSERT INTO static_data_value (value_id,[type_id],code,[description],create_user,create_ts)
	VALUES ( 5606,5600,'Amended New','Amended New','farrms_admin',GETDATE() )
	  
	PRINT 'Inserted static data value 5606 - Amended New'
END
ELSE
BEGIN
	PRINT 'Static data value 5606 - Amended New already EXISTS.'
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


