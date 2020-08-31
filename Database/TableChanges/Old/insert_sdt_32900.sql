IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 32900)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (32900, 'Company Trigger', 0, 'Company Trigger', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 32900 - Company Trigger.'
END
ELSE
BEGIN
	PRINT 'Static data type 32900 - Company Trigger already EXISTS.'
END