SET NOCOUNT ON
GO  
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -14000)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-14000, 14000, '- Not Specified -', '- Not Specified -', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -14000 - "- Not Specified -".'
END
ELSE
BEGIN
	UPDATE static_data_value
	SET code = '- Not Specified -',
	[description] = '- Not Specified -'
	WHERE value_id = -14000 AND [type_id] = 14000
	
    PRINT 'Static data value -14000 - "- Not Specified -" Updated.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -43200)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-43200, 43200, '- Not Specified -', '- Not Specified -', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -43200 - "- Not Specified -".'
END
ELSE
BEGIN
	UPDATE static_data_value
	SET code = '- Not Specified -',
	[description] = '- Not Specified -'
	WHERE value_id = -43200 AND [type_id] = 43200
	
    PRINT 'Static data value -43200 - "- Not Specified -" Updated.'
END
SET IDENTITY_INSERT static_data_value OFF


