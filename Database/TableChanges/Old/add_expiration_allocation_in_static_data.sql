SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17603)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17603, 17600, 'Allocation by Expiration Calendar', 'Allocation by Expiration Calendar', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17603 - Allocation by Expiration Calendar.'
END
ELSE
BEGIN
	PRINT 'Static data value 17603 - Allocation by Expiration Calendar already EXISTS.'
END
