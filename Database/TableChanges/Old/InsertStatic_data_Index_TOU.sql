IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 18900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (18900, 'Index TOU', 1, 'Index TOU', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 18900 - Index TOU.'
END
ELSE
BEGIN
	PRINT 'Static data type 18900 - Index TOU already EXISTS.'
END

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18900)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18900, 18900, 'Onpeak', 'OnPeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18900 - Onpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value 18900 - Onpeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18901)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18901, 18900, 'Offpeak', 'Offpeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18901 - Offpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value 18901 - Offpeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


