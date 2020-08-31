SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25008)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25008, 25000, 'Contractual/Forecast', 'Contractual/Forecast', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25008 - Contractual/Forecast.'
END
ELSE
BEGIN
    UPDATE static_data_value
    SET code = 'Contractual/Forecast',
			  category_id = ''
    WHERE [value_id] = 25008
		PRINT 'Updated Static value 25008 - Contractual/Forecast.'
END
SET IDENTITY_INSERT static_data_value OFF