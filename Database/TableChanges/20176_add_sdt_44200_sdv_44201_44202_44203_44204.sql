IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 44200)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (44200, 'Neural Network Data Type', 1, 'Neural Network Data Type', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 44200 - Neural Network Data Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 44200 - Neural Network Data Type already EXISTS.'
END


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44201)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44201, 44200, 'Input Range', ' Input Range', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44201 - Input Range.'
END
ELSE
BEGIN
    PRINT 'Static data value 44201 - Input Range already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44202)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44202, 44200, 'Output Range', ' Output Range', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44202 - Output Range.'
END
ELSE
BEGIN
    PRINT 'Static data value 44202 - Output Range already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44203)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44203, 44200, 'Train Data Range', ' Train Data Range
', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44203 - Train Data Range.'
END
ELSE
BEGIN
    PRINT 'Static data value 44203 - Train Data Range already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44204)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44204, 44200, 'Test Data Range', ' Test Data Range
', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44204 - Test Data Range.'
END
ELSE
BEGIN
    PRINT 'Static data value 44204 - Test Data Range already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF