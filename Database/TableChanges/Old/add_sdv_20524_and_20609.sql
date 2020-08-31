SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20524)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20524, 20500, 'Counterparty Credit Limit Update', 'Counterparty Credit Limit Update', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20524 - Counterparty Credit Limit Update.'
END
ELSE
BEGIN
	PRINT 'Static data value 20524 - Counterparty Credit Limit Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20609)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20609, 20600, 'Counterparty Credit Limit', 'Counterparty Credit Limit', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20609 - Counterparty Credit Limit.'
END
ELSE
BEGIN
	PRINT 'Static data value 20609 - Counterparty Credit Limit already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF