SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20023)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20023, 20000, 'Calendar Day + Finalized date', 'Calendar Day + Finalized date', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20023 - Calendar Day + Finalized date.'
END
ELSE
BEGIN
	PRINT 'Static data value 20023 - Calendar Day + Finalized date already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20024)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20024, 20000, 'Working Day + Finalized date', 'Working Day + Finalized date', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20024 - Working Day + Finalized date.'
END
ELSE
BEGIN
	PRINT 'Static data value 20024 - Working Day + Finalized date already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
