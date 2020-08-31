IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 45500)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (45500, 'Options Calculate Method', 1, 'Options Calculate Method', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 45500 - Options Calculate Method.'
END
ELSE
BEGIN
	PRINT 'Static data type 45500 - Options Calculate Method already EXISTS.'
END


UPDATE static_data_type
SET [type_name] = 'Options Calculate Method',
	[description] = 'Options Calculate Method',
	internal = 1
	WHERE [type_id] = 45500
PRINT 'Updated static data type 45500 - Options Calculate Method.'