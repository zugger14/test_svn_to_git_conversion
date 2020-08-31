IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 23900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (23900, 'Send Deal Confirmation Status', 1, 'Send Deal Confirmation Status', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 23900 - Send Deal Confirmation Status.'
END
ELSE
BEGIN
	PRINT 'Static data type 23900 - Send Deal Confirmation Status already EXISTS.'
END
