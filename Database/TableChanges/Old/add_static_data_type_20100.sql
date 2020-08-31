/* 
Added by sbantawa@pioneerglobalsolution.com (24th May, 2012) 
Inserts static data type Model Type
*/

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20100)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (20100, 'Model Type', 1, 'Model Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20100 - Model Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 20100 - Model Type already EXISTS.'
END