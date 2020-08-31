UPDATE static_data_type
SET [type_name] = 'Submission Status',
	[description] = 'Submission Status',
	[internal] = 1, 
	[is_active] = 1
	WHERE [type_id] = 39500
PRINT 'Updated static data type 39500 - Submission Status.'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39502)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (39502, 39500, 'Verified', 'Verified', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 39502 - Verified.'
END
ELSE
BEGIN
    UPDATE static_data_value
    SET code = 'Verified',
	[description] = 'Verified',
    [category_id] = ''
    WHERE [value_id] = 39502
	
	PRINT 'Updated Static value 39502 - Verified.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT * FROM static_data_value WHERE value_id = 39501)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (39501, 39500, 'Submitted', 'Submitted', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 39501 - Submitted.'
END
ELSE
BEGIN
    UPDATE static_data_value
    SET code = 'Submitted',
	[description] = 'Submitted',
    [category_id] = '',
	[type_id] = 39500
    WHERE [value_id] = 39501
PRINT 'Updated Static value 39501 - Submitted.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39500)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (39500, 39500, 'Outstanding', 'Outstanding', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 39500 - Outstanding.'
END
ELSE
BEGIN
    UPDATE static_data_value
    SET code = 'Outstanding',
	[description] = 'Outstanding',
    [category_id] = ''
    WHERE [value_id] = 39500
PRINT 'Updated Static value 39500 - Outstanding.'
END
SET IDENTITY_INSERT static_data_value OFF

DELETE FROM static_data_value WHERE value_id IN (39503, 39504, 39505)