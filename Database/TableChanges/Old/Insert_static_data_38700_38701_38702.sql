SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 38700)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (38700, 38700, 'Holiday', 'Holiday', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 38700 - Holiday.'
END
ELSE
BEGIN
	PRINT 'Static data value 38700 - Holiday.'
END
SET IDENTITY_INSERT static_data_value OFF

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 38701)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (38701, 38700, 'Expiration', 'Expiration', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 38701 - Expiration.'
END
ELSE
BEGIN
	PRINT 'Static data value 38701 - Expiration.'
END
SET IDENTITY_INSERT static_data_value OFF

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 38702)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (38702, 38700, 'Settlement', 'Settlement', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 38702 - Settlement.'
END
ELSE
BEGIN
	PRINT 'Static data value 38702 - Settlement.'
END
SET IDENTITY_INSERT static_data_value OFF

GO


