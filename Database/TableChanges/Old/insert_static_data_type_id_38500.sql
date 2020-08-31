IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 38500)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (38500, 'Contract Group', 0, 'Contract Group', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 38500 - Contract Group.'
END
ELSE
BEGIN
	PRINT 'Static data type 38500 - Contract Group already EXISTS.'
END

