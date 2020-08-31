IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 10002)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (10002, 'Compliance Jurisdictions', 0, 'Compliance Jurisdictions', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 10002 - Compliance Jurisdictions.'
END
ELSE
BEGIN
	UPDATE static_data_type SET [internal] = 0 WHERE [type_id] = 10002
	PRINT 'Compliance Jurisdictions updated to external'
END
