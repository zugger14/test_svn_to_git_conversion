IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 38800)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (38800, 'Margin Provisions', 0, 'Margin Provisions', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 38800 - Margin Provisions.'
END
ELSE
BEGIN
	PRINT 'Static data type 38800 - Margin Provisions already EXISTS.'
END
