SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 410)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (410, 400, 'Own use', 'Own use', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 410 - Own use.'
END
ELSE
BEGIN
	PRINT 'Static data value 410 - Own use already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


UPDATE static_data_value
SET    [type_id] = 400,
       [code] = 'Own Use',
       [description] = 'Own Use'
WHERE  [value_id] = 410

PRINT 'Updated static data value 410 - Own Use.'


