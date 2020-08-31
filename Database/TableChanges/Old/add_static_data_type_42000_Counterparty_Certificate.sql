IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 42000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (42000, 'Counterparty Certificate', 0, 'Counterparty Certificate', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 42000 - Counterparty Certificate.'
END
ELSE
BEGIN
	PRINT 'Static data type 42000 - Counterparty Certificate already EXISTS.'
END