IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 45900)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (45900, 'Attribute Type', 1, 'Attribute Type', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 45900 - Attribute Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 45900 - Attribute Type already EXISTS.'
END


UPDATE static_data_type
SET [type_name] = 'Option Calculation Method',
	[description] = 'Option Calculation Method',
	internal = 1
	WHERE [type_id] = 45900
PRINT 'Updated static data type 45900 - Option Calculation Method. Renamed.'




SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45901)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (45901, 45900, 'f', 'Full Evaluation', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45901 - f.'
END
ELSE
BEGIN
    PRINT 'Static data value 45901 - f already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


UPDATE static_data_value
    SET code = 'f',
    [category_id] = ''
    WHERE [value_id] = 45901
PRINT 'Updated Static value 45901 - f.'