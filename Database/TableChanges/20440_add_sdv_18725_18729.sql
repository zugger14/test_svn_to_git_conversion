SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18725)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18725, 18700, 'Fuel based variable charge', 'Fuel based variable charge', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18726 - Fuel based variable charge.'
END
ELSE
BEGIN
	PRINT 'Static data value 18725 - Fuel based variable charge already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18726)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18726, 18700, 'Variable Charges', 'Variable Charges', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18726 - Variable Charges.'
END
ELSE
BEGIN
	PRINT 'Static data value 18726 - Variable Charges already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18727)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18727, 18700, 'Reservation Rate Monthly', 'Fixed Charges - Reservation Rate Monthly', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18727 - Fixed Rate Monthly.'
END
ELSE
BEGIN
	PRINT 'Static data value 18727 - Fixed Rate Monthly already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF




SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18728)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18728, 18700, 'Fixed Charges', 'Fixed Charges', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18728 - Fixed Charges.'
END
ELSE
BEGIN
	PRINT 'Static data value 18728 - Fixed Charges already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF




SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18729)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18729, 18700, 'Reservation Rate Monthly MDQ', 'Reservation Rate Monthly MDQ', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18729 - Reservation Rate Monthly MDQ.'
END
ELSE
BEGIN
	PRINT 'Static data value 18729 - Reservation Rate Monthly MDQ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF