SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -926)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-926, 800, 'DeriveDayAhead', ' DeriveDayAhead', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -926 - DeriveDayAhead.'
END
ELSE
BEGIN
    PRINT 'Static data value -926 - DeriveDayAhead already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_value
    SET code = 'DeriveDayAhead'
    WHERE [value_id] = -926 
PRINT 'Updated Static value -926 - DeriveDayAhead.'

SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -927)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-927, 800, 'GetGMContractFee', ' ', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -927 - GetGMContractFee.'
END
ELSE
BEGIN
    PRINT 'Static data value -927 - GetGMContractFee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF