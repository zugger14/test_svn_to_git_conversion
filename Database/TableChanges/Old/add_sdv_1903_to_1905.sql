SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1903)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (1903, 1900, 'Initiation', 'Initiation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 1903 - Initiation.'
END
ELSE
BEGIN
	PRINT 'Static data value 1903 - Initiation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1904)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (1904, 1900, 'Ready for Review', 'Ready for Review', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 1904 - Ready for Review.'
END
ELSE
BEGIN
	PRINT 'Static data value 1904 - Ready for Review already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1905)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (1905, 1900, 'Final Review', 'Final Review', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 1905 - Final Review.'
END
ELSE
BEGIN
	PRINT 'Static data value 1905 - Final Review already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF