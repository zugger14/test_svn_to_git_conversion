SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -894)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-894, 800, 'IsInternalPortfolio', 'IsInternalPortfolio', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -894 - IsInternalPortfolio.'
END
ELSE
BEGIN
	PRINT 'Static data value -894 - IsInternalPortfolio already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
