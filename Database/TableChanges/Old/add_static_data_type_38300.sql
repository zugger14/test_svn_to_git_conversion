IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 38300)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (38300, 'Optimization Objective', 1, 'Optimization Objective', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 38300 - Optimization Objective.'
END
ELSE
BEGIN
	PRINT 'Static data type 38300 - Optimization Objective already EXISTS.'
END