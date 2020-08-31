IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 29700)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (29700, 'Market', 0, 'Market', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 29700 - Market.'
END
ELSE
BEGIN
	PRINT 'Static data type 29700 - Market already EXISTS.'
END
