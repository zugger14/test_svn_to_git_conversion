IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 27000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (27000, 'Contract Charge Type Group', 0, 'Contract Charge Type Group', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 27000 - Contract Charge Type Group.'
END
ELSE
BEGIN
	PRINT 'Static data type 27000 - Contract Charge Type Group already EXISTS.'
END
