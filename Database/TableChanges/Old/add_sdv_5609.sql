SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5609)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (5609, 5600, 'Request for Cancellation', 'Request for Cancellation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 5609 - Request for Cancellation.'
END
ELSE
BEGIN
	PRINT 'Static data value 5609 - Request for Cancellation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
