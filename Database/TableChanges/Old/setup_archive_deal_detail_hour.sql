--Step1
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2157)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (2157, 2150, 'Nomination', 'Nomination', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 2157 - Nomination.'
END
ELSE
BEGIN
	PRINT 'Static data value 2157 - Nomination already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
