IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 105800)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (105800, 'counterparty contract type', 1, 'counterparty contract type', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 105800 - counterparty contract type.'
END
ELSE
BEGIN
	PRINT 'Static data type 105800 - counterparty contract type already EXISTS.'
END