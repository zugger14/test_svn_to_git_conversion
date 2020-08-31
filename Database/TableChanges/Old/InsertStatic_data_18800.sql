IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 18800)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (18800, 'Curve Ration Options', 1, 'Curve Ration Options', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 18800 - Curve Ration Options.'
END
ELSE
BEGIN
	PRINT 'Static data type 18800 - Curve Ration Options already EXISTS.'
END

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18800)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18800, 18800, 'current month remaining days ratio', 'current month remaining days ratio', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18800 - current month remaining days ratio.'
END
ELSE
BEGIN
	PRINT 'Static data value 18800 - current month remaining days ratio already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
