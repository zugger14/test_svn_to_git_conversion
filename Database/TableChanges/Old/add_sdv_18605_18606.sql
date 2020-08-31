SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18605)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18605, 18600, 'Minimum Injection Capacity', 'Minimum Injection Capacity', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18605 - Minimum Injection Capacity.'
END
ELSE
BEGIN
	PRINT 'Static data value 18605 - Minimum Injection Capacity already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18606)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18606, 18600, 'Minimum Withdrawal Capacity', 'Minimum Withdrawal Capacity', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18606 - Minimum Withdrawal Capacity.'
END
ELSE
BEGIN
	PRINT 'Static data value 18606 - Minimum Withdrawal Capacity already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
