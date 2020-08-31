UPDATE static_data_value SET code = 'Pkg ID', [description] = 'Pkg ID' WHERE [value_id] = -5630
PRINT 'Updated Static value -5630 - Pkg ID.'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5631)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5631, 5500, 'Svc Req K', 'Svc Req K', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5631 - Svc Req K.'
END
ELSE
BEGIN
	PRINT 'Static data value -5631 - Svc Req K already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
