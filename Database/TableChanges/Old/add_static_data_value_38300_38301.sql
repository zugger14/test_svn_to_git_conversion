SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 38300)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (38300, 38300, 'Maximum Flow based on Cost Ranking', 'Maximum Flow based on Cost Ranking', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 38300 - Maximum Flow based on Cost Ranking.'
END
ELSE
BEGIN
	PRINT 'Static data value 38300 - Maximum Flow based on Cost Ranking already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 38301)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (38301, 38300, 'Maximum Flow based on Location Ranking', 'Maximum Flow based on Location Ranking', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 38301 - Maximum Flow based on Location Ranking.'
END
ELSE
BEGIN
	PRINT 'Static data value 38301 - Maximum Flow based on Location Ranking already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO
