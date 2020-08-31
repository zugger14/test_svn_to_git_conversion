IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 105200)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (105200, 'Collateral Status Type ', 0, 'Collateral Status Type', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 105200 - Collateral Status Type .'
END
ELSE
BEGIN
	PRINT 'Static data type 105200 - Collateral Status Type  already EXISTS.'
END