SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17804)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17804, 17800, 'Invoice Mail', 'Invoice Mail', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17804 - Invoice Mail.'
END
ELSE
BEGIN
	PRINT 'Static data value 17804 - Invoice Mail already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
