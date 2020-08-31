IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 31800)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (31800, 'Nomination Group', 0, 'Nomination Group', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 31800 - Nomination Group.'
END
ELSE
BEGIN
	PRINT 'Static data type 31800 - Nomination Group already EXISTS.'
END
