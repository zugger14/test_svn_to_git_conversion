IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 104900)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (104900, 'Rating Outlook', 0, 'Rating Outlook', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 104900 - Rating Outlook.'
END
ELSE
BEGIN
	PRINT 'Static data type 104900 - Rating Outlook already EXISTS.'
END