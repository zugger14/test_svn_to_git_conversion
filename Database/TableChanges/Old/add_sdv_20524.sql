SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20524)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20524, 20500, 'Deal - Post Actualize Schdule', 'Deal - Post Actualize Schdule', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20524 - Deal - Post Actualize Schdule.'
END
ELSE
BEGIN
	PRINT 'Static data value 20524 - Deal - Post Actualize Schdule already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
