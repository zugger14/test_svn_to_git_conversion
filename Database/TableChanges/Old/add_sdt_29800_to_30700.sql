IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 29800)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (29800, 'GL Code 1', 0, 'GL Code 1', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 29800 - GL Code 1.'
END
ELSE
BEGIN
	PRINT 'Static data type 29800 - GL Code 1 already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 29900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (29900, 'GL Code 2', 0, 'GL Code 2', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 29900 - GL Code 2.'
END
ELSE
BEGIN
	PRINT 'Static data type 29900 - GL Code 2 already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 30000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (30000, 'GL Code 3', 0, 'GL Code 3', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 30000 - GL Code 3.'
END
ELSE
BEGIN
	PRINT 'Static data type 30000 - GL Code 3 already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 30100)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (30100, 'GL Code 4', 0, 'GL Code 4', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 30100 - GL Code 4.'
END
ELSE
BEGIN
	PRINT 'Static data type 30100 - GL Code 4 already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 30200)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (30200, 'GL Code 5', 0, 'GL Code 5', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 30200 - GL Code 5.'
END
ELSE
BEGIN
	PRINT 'Static data type 30200 - GL Code 5 already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 30300)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (30300, 'GL Code 6', 0, 'GL Code 6', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 30300 - GL Code 6.'
END
ELSE
BEGIN
	PRINT 'Static data type 30300 - GL Code 6 already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 30400)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (30400, 'GL Code 7', 0, 'GL Code 7', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 30400 - GL Code 7.'
END
ELSE
BEGIN
	PRINT 'Static data type 30400 - GL Code 7 already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 30500)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (30500, 'GL Code 8', 0, 'GL Code 8', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 30500 - GL Code 8.'
END
ELSE
BEGIN
	PRINT 'Static data type 30500 - GL Code 8 already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 30600)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (30600, 'GL Code 9', 0, 'GL Code 9', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 30600 - GL Code 9.'
END
ELSE
BEGIN
	PRINT 'Static data type 30600 - GL Code 9 already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 30700)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (30700, 'GL Code 10', 0, 'GL Code 10', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 30700 - GL Code 10.'
END
ELSE
BEGIN
	PRINT 'Static data type 30700 - GL Code 10 already EXISTS.'
END
