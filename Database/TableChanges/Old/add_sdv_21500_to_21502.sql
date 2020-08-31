SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21500)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21500, 21500, 'Invoice', 'Invoice', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21500 - Invoice.'
END
ELSE
BEGIN
	PRINT 'Static data value 21500 - Invoice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21501)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21501, 21500, 'Remittance', 'Remittance', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21501 - Remittance.'
END
ELSE
BEGIN
	PRINT 'Static data value 21501 - Remittance already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21502)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21502, 21500, 'Netting Statement', 'Netting Statement', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21502 - Netting Statement.'
END
ELSE
BEGIN
	PRINT 'Static data value 21502 - Netting Statement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
