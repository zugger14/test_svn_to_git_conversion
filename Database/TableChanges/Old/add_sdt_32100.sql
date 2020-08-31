IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 32100)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (32100, 'Rank', 0, 'Rank', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 32100 - Rank.'
END
ELSE
BEGIN
	PRINT 'Static data type 32100 - Rank already EXISTS.'
END

