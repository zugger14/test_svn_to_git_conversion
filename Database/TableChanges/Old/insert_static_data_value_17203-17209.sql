SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17203)
BEGIN
	INSERT INTO static_data_value (value_id,[type_id],code,[description],create_user,create_ts)
	VALUES ( 17203,17200,'New','New','farrms_admin',GETDATE() )
	  
	PRINT 'Inserted static data value 17203 - New'
END
ELSE
BEGIN
	PRINT 'Static data value 17203 - New already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17204)
BEGIN
	INSERT INTO static_data_value (value_id,[type_id],code,[description],create_user,create_ts)
	VALUES ( 17204,17200,'New for CEM','New for CEM','farrms_admin',GETDATE() )
	  
	PRINT 'Inserted static data value 17204 - New for CEM'
END
ELSE
BEGIN
	PRINT 'Static data value 17204 - New for CEM already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17205)
BEGIN
	INSERT INTO static_data_value (value_id,[type_id],code,[description],create_user,create_ts)
	VALUES ( 17205,17200,'Counterparty Confirmed','Counterparty Confirmed','farrms_admin',GETDATE() )
	  
	PRINT 'Inserted static data value 17205 - Counterparty Confirmed'
END
ELSE
BEGIN
	PRINT 'Static data value 17205 - Counterparty Confirmed already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17206)
BEGIN
	INSERT INTO static_data_value (value_id,[type_id],code,[description],create_user,create_ts)
	VALUES ( 17206,17200,'Amended','Amended','farrms_admin',GETDATE() )
	  
	PRINT 'Inserted static data value 17206 - Amended'
END
ELSE
BEGIN
	PRINT 'Static data value 17206 - Amended already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17207)
BEGIN
	INSERT INTO static_data_value (value_id,[type_id],code,[description],create_user,create_ts)
	VALUES ( 17207,17200,'Amended New','Amended New','farrms_admin',GETDATE() )
	  
	PRINT 'Inserted static data value 17207 - Amended New'
END
ELSE
BEGIN
	PRINT 'Static data value 17207 - Amended New already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17208)
BEGIN
	INSERT INTO static_data_value (value_id,[type_id],code,[description],create_user,create_ts)
	VALUES ( 17208,17200,'Cancelled','Cancelled','farrms_admin',GETDATE() )
	  
	PRINT 'Inserted static data value 17208 - Cancelled'
END
ELSE
BEGIN
	PRINT 'Static data value 17208 - Cancelled already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17209)
BEGIN
	INSERT INTO static_data_value (value_id,[type_id],code,[description],create_user,create_ts)
	VALUES ( 17209,17200,'Cancelled New','Cancelled New','farrms_admin',GETDATE() )
	  
	PRINT 'Inserted static data value 17209 - Cancelled New'
END
ELSE
BEGIN
	PRINT 'Static data value 17209 - Cancelled New already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF


