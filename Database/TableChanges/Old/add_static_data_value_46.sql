SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (46, 25, 'Counterparty Certificate', 'Counterparty Certificate', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 46 - Counterparty Certificate.'
END
ELSE
BEGIN
	PRINT 'Static data value 46 - Counterparty Certificate already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF