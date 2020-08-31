SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42001)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (42001, 42000, 'Counterparty Certificate', 'Counterparty Certificate', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 42001 - Counterparty Certificate.'
END
ELSE
BEGIN
	PRINT 'Static data value 42001 - Counterparty Certificate already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42002)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (42002, 42000, 'Counterparty Products', 'Counterparty Products', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 42002 - Counterparty Products.'
END
ELSE
BEGIN
	PRINT 'Static data value 42002 - Counterparty Products already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF