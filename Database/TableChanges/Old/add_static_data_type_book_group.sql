IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 31000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (31000, 'Source Book Group1', 0, 'Source Book Group1', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 31000 - Source Book Group1.'
END
ELSE
BEGIN
	PRINT 'Static data type 31000 - Source Book Group1 already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 31100)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (31100, 'Source Book Group2', 0, 'Source Book Group2', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 31100 - Source Book Group2.'
END
ELSE
BEGIN
	PRINT 'Static data type 31100 - Source Book Group2 already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 31200)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (31200, 'Source Book Group3', 0, 'Source Book Group3', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 31200 - Source Book Group3.'
END
ELSE
BEGIN
	PRINT 'Static data type 31200 - Source Book Group3 already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 31300)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (31300, 'Source Book Group4', 0, 'Source Book Group4', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 31300 - Source Book Group4.'
END
ELSE
BEGIN
	PRINT 'Static data type 31300 - Source Book Group4 already EXISTS.'
END

