IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 23400)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (23400, 'Requirement Type', 1, 'Requirement Type', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 23400 - Requirement Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 23400 - Requirement Type already EXISTS.'
END


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23400)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (23400, 23400, 'Assignment', ' Assignment', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 23400 - Assignment.'
END
ELSE
BEGIN
    PRINT 'Static data value 23400 - Assignment already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF