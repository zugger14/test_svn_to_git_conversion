/* 
Added by sbantawa@pioneerglobalsolution.com (25th May, 2012) 
Inserts static data type Type For
*/

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20200)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (20200, 'Limit For', 1, 'Limit For', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20200 - Limit For.'
END
ELSE
BEGIN
	PRINT 'Static data type 20200 - Limit For already EXISTS.'
END