SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18717)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18717, 18700, 'Capacity based Term fee', 'Capacity based Term fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 5608 - Capacity based Term fee.'
END
ELSE
BEGIN
	PRINT 'Static data value 18717 - Capacity based Term fee EXISTS.'
	
END
SET IDENTITY_INSERT static_data_value OFF
