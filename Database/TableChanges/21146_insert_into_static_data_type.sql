IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 4075)
BEGIN 
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (4075, 'Msmt Eff Test Type', 1, 'Msmt Eff Test Type', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 4075 - Msmt Eff Test Type.'
END 
ELSE
BEGIN
	PRINT 'Static data type 4075 - Msmt Eff Test Type already EXISTS.'
END