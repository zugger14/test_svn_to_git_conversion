SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17604)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17604, 17600, 'TOU Allocation with Expiration Calendar', 'TOU Allocation with Expiration Calendar', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17604 -TOU Allocation with Expiration Calendar.'
END
ELSE
BEGIN
	PRINT 'Static data value 17604 - TOU Allocation with Expiration Calendar already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF



