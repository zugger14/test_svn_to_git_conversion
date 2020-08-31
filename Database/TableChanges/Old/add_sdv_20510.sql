SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20510)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20510, 20500, 'Contract Approval', 'Contract Approval', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20510 - Contract Approval.'
END
ELSE
BEGIN
	PRINT 'Static data value 20510 - Contract Approval already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
