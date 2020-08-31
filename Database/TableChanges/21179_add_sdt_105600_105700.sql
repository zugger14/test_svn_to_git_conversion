IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 105600)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (105600, 'Interest Method', 1, 'Interest Method', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 105600 - Interest Method.'
END
ELSE
BEGIN
	PRINT 'Static data type 105600 - Interest Method already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 105700)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (105700, 'Negative Interest', 1, 'Negative Interest', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 105700 - Negative Interest.'
END
ELSE
BEGIN
	PRINT 'Static data type 105700 - Negative Interest already EXISTS.'
END