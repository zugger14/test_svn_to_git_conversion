IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19000, 'Contract calculation type', 1, 'Contract calculation type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19000 - Contract calculation type.'
END
ELSE
BEGIN
	PRINT 'Static data type 19000 - Contract calculation type already EXISTS.'
END



SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19000)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19000, 19000, 'Deal Level Calculation', 'Deal Level Calculation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19000 - Deal Level Calculation.'
END
ELSE
BEGIN
	PRINT 'Static data value 19000 - Deal Level Calculation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19001)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19001, 19000, 'Contract Level calculation', 'Contract Level calculation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19001 - Contract Level calculation.'
END
ELSE
BEGIN
	PRINT 'Static data value 19001 - Contract Level calculation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19002)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19002, 19000, 'Deal-Term level Calculation', 'Deal-Term level Calculation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19002 - Deal-Term level Calculation.'
END
ELSE
BEGIN
	PRINT 'Static data value 19002 - Deal-Term level Calculation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

