DELETE FROM static_data_value WHERE  [type_id] = 20900
DELETE FROM static_data_type WHERE  [type_id] = 20900

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 22000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (22000, 'Udf Modules', 1, 'Udf Modules', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 22000 - Udf Modules.'
END
ELSE
BEGIN
	PRINT 'Static data type 22000 - Udf Modules already EXISTS.'
END
