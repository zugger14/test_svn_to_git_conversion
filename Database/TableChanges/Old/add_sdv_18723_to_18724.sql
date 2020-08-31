SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18723)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18723, 18700, 'Broker Fees', 'Broker Fees', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18723 - Broker Fees.'
END
ELSE
BEGIN
	PRINT 'Static data value 18723 - Broker Fees already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18724)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18724, 18700, 'Pre Pay', 'Pre Pay', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18724 - Pre Pay.'
END
ELSE
BEGIN
	PRINT 'Static data value 18724 - Pre Pay already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF
