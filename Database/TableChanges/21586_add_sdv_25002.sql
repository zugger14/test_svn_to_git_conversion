SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25002)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25002, 25000, 'Expired', 'Expired', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25002 - Expired.'
END
ELSE
BEGIN
    UPDATE static_data_value
    SET code = 'Expired',
			  [description] = 'Expired',
			  category_id = ''
    WHERE [value_id] = 25002
		PRINT 'Updated Static value 25002 - Expired.'
END
SET IDENTITY_INSERT static_data_value OFF