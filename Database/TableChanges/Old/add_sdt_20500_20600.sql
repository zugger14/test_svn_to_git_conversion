IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20500)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (20500, 'Alert Events', 1, 'Alert Events', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20500 - Alert Events.'
END
ELSE
BEGIN
	PRINT 'Static data type 20500 - Alert Events already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20600)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (20600, 'Alert Modules', 1, 'Alert Modules', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20600 - Alert Modules.'
END
ELSE
BEGIN
	PRINT 'Static data type 20600 - Alert Modules already EXISTS.'
END

