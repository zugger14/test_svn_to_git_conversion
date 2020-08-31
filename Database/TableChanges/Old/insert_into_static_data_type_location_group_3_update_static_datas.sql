IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 29500)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (29500, 'Location Group 3', 0, 'Location Group 3', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 29500 - Location Group 3.'
END
ELSE
BEGIN
	PRINT 'Static data type 29500 - Location Group 3 already EXISTS.'
END

UPDATE static_data_type SET internal = 0 WHERE type_id IN (14000, 11150, 18000)