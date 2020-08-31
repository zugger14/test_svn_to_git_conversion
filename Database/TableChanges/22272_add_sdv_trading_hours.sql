SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110162)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110162, 'TRADING_HOURS_UTC [Eg. 10-17]', 'TRADING_HOURS_UTC [Eg. 10-17]', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110162 - TRADING_HOURS_UTC [Eg. 10-17].'
END
ELSE
BEGIN
    PRINT 'Static data value 110162 - TRADING_HOURS_UTC [Eg. 10-17] already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF 