 IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 23100)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (23100, 'Tenor Bucket', 1, 'Tenor Bucket', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 23100 - Tenor Bucket.'
END
ELSE
BEGIN
	PRINT 'Static data type 23100 - Tenor Bucket already EXISTS.'
END 


 SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23100)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (23100, 23100, 'DE', 'DE', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 23100 - DE.'
END
ELSE
BEGIN
	PRINT 'Static data value 23100 - DE already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF 
 SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23101)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (23101, 23100, 'UK', 'UK', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 23101 - UK.'
END
ELSE
BEGIN
	PRINT 'Static data value 23101 - UK already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF 
