SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5624)
BEGIN
	INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
	VALUES (5600, 5624, 'Draft', 'Draft', NULL, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 5624 - Draft.'
END
ELSE
BEGIN
    PRINT 'Static data value 5624 - Draft already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO