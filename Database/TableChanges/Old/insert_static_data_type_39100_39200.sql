IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 39100)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (39100, 'Rate Schedule Type', 1, 'Rate Schedule Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 39100 - Rate Schedule Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 39100 - Rate Schedule Type already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 39200)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (39200, 'Zone', 0, 'Zone', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 39200 - Zone.'
END
ELSE
BEGIN
	PRINT 'Static data type 39200 - Zone already EXISTS.'
END


