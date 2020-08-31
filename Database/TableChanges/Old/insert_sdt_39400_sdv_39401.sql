IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 39500)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (39500, 'Generation Category', 1, 'Generation Category', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 39500 - Generation Category.'
END
ELSE
BEGIN
	PRINT 'Static data type 39500 - Generation Category already EXISTS.'
END


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39501)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39501, 39500, 'Gas Generation', 'Gas Generation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39401 - Gas Generation.'
END
ELSE
BEGIN
	PRINT 'Static data value 39501 - Gas Generation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

