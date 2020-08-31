SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21601)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21601, 21600, 'BRKF', 'Broker Fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21601 - Broker Fee.'
END
ELSE
BEGIN
	PRINT 'Static data value 21601 - Broker Fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21602)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21602, 21600, 'COM', 'Commissions', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21602 - Commissions.'
END
ELSE
BEGIN
	PRINT 'Static data value 21602 - Commissions already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

