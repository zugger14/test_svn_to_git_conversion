IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 29100)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (29100, 'Commodity Group 1', 0, 'Commodity Group 1', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 29100 - Commodity Group 1.'
END
ELSE
BEGIN
	PRINT 'Static data type 29100 - Commodity Group 1 already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 29200)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (29200, 'Commodity Group 2', 0, 'Commodity Group 2', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 29200 - Commodity Group 2.'
END
ELSE
BEGIN
	PRINT 'Static data type 29200 - Commodity Group 2 already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 29300)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (29300, 'Commodity Group 3', 0, 'Commodity Group 3', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 29300 - Commodity Group 3.'
END
ELSE
BEGIN
	PRINT 'Static data type 29300 - Commodity Group 3 already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 29400)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (29400, 'Commodity Group 4', 0, 'Commodity Group 4', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 29400 - Commodity Group 4.'
END
ELSE
BEGIN
	PRINT 'Static data type 29400 - Commodity Group 4 already EXISTS. '
END
