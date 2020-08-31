SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5658)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5658, 5500, 'Clearing Counterparty', 'Clearing Counterparty', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5658 - Clearing Counterparty.'
END
ELSE
BEGIN
	PRINT 'Static data value -5658 - Clearing Counterparty already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF