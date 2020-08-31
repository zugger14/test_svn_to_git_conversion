IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 90000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (90000, 'Fxing Type', 1, 'Fxing Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 90000 - Fxing Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 90000 - Fxing Type already EXISTS.'
END
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 90000)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (90000, 90000, 'Original', 'Original', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 90000 - Original.'
END
ELSE
BEGIN
	PRINT 'Static data value 90000 - Original already  EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_type SET [type_name] = 'Fxing Type', [description] = 'Fxing Type' WHERE [type_id] = 90000
PRINT 'Updated Static data type 90000 - Fxing Type.'
UPDATE static_data_value SET [type_id]= 90000, [code] = 'Original', [description] = 'Original' WHERE [value_id] = 90000 
PRINT 'Updated static data value 90000 - Original.'
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 90000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (90000, 'Fxing Type', 1, 'Fxing Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 90000 - Fxing Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 90000 - Fxing Type already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 90001)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (90001, 90000, 'Fixing', 'Fixing', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 90001 - Fixing.'
END
ELSE
BEGIN
	PRINT 'Static data value 90001 - Fixing already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_type SET [type_name] = 'Fxing Type', [description] = 'Fxing Type' WHERE [type_id] = 90000
PRINT 'Updated Static data type 90000 - Fxing Type.'
UPDATE static_data_value SET [type_id]= 90000, [code] = 'Fixing', [description] = 'Fixing' WHERE [value_id] = 90001 
PRINT 'Updated static data value 90001 - Fixing.'

IF EXISTS(SELECT 1 FROM static_data_type sdt WHERE sdt.[type_id] = 90000)
BEGIN
	DELETE FROM static_data_value WHERE [type_id] = 90000
	DELETE FROM static_data_type WHERE [type_id] = 90000	
END

UPDATE source_deal_header SET product_id = 4100 WHERE product_id = 90000
UPDATE source_deal_header SET product_id = 4101 WHERE product_id = 90001
