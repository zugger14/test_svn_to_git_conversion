/** inserting static data type 'Measure Filter' with static data values 
* sligal
* 9/21/2012(after risk merge)**/
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 17350)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (17350, 'Measure Filter', 1, 'VAR', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 17350 - Measure Filter.'
END
ELSE
BEGIN
	PRINT 'Static data type 17350 - Measure Filter already EXISTS.'
END

/** inserting static data values for type_id=17350[Measure Filter] **/
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17351)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17351, 17350, 'VaR', 'VaR', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17351 - VaR.'
END
ELSE
BEGIN
	PRINT 'Static data value 17351 - VaR already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17352)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17352, 17350, 'CFaR', 'CFaR', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17352 - CFaR.'
END
ELSE
BEGIN
	PRINT 'Static data value 17352 - CFaR already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17353)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17353, 17350, 'EaR', 'EaR', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17353 - EaR.'
END
ELSE
BEGIN
	PRINT 'Static data value 17353 - EaR already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17354)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17354, 17350, 'PaR', 'PaR', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17354 - PaR.'
END
ELSE
BEGIN
	PRINT 'Static data value 17354 - PaR already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17355)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17355, 17350, 'PFE', 'PFE', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17355 - PFE.'
END
ELSE
BEGIN
	PRINT 'Static data value 17355 - PFE already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17356)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17356, 17350, 'MTM', 'MTM', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17356 - MTM.'
END
ELSE
BEGIN
	PRINT 'Static data value 17356 - MTM already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
