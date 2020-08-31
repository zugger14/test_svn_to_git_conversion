SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20511)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20511, 20500, 'Contract - Post Settlement Calculation', 'Contract - Post Settlement Calculation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20511 - Contract - Post Settlement Calculation.'
END
ELSE
BEGIN
	PRINT 'Static data value 20511 - Contract - Post Settlement Calculation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF