IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 10006)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (10006, 'GL Account Balance For Estimate', 0, 'GL Account Balance For Estimate', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 10006 - GL Account Balance For Estimate.'
END
ELSE
BEGIN
	PRINT 'Static data type 10006 - GL Account Balance For Estimate already EXISTS.'
END


UPDATE static_data_type
SET [type_name] = 'GL Account Balance For Estimate',
	[description] = 'GL Account Balance For Estimate',
	internal = 0
	WHERE [type_id] = 10006
PRINT 'Updated static data type 10006 - GL Account Balance For Estimate.'