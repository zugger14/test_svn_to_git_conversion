IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 37900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (37900, 'Operator', 1, 'Operator', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 37900 - Operator.'
END
ELSE
BEGIN
	PRINT 'Static data type 37900 - Operator already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 37901)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (37901, 37900, 'Between', 'Between', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 37901 - Between.'
END
ELSE
BEGIN
	PRINT 'Static data value 37901 - Between already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 37902)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (37902, 37900, 'Less than', 'Less than', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 37902 - Less than.'
END
ELSE
BEGIN
	PRINT 'Static data value 37902 - Less than already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 37903)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (37903, 37900, 'Greater than', 'Greater than', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 37903 - Greater than.'
END
ELSE
BEGIN
	PRINT 'Static data value 37903 - Greater than already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 38000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (38000, 'Reference', 1, 'Reference', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 38000 - Reference.'
END
ELSE
BEGIN
	PRINT 'Static data type 38000 - Reference already EXISTS.'
END	

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 38100)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (38100, 38000, 'Upper', 'Upper', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 38100 - Upper.'
END
ELSE
BEGIN
	PRINT 'Static data value 38100 - Upper already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 38101)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (38101, 38000, 'Lower', 'Lower', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 38101 - Lower.'
END
ELSE
BEGIN
	PRINT 'Static data value 38101 - Lower already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
