--Added new Historical source under volatility source
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10639)
BEGIN
 INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
 VALUES (10639, 10007, 'Historical', 'Historical', 'farrms_admin', GETDATE())
 PRINT 'Inserted static data value 10639 - Historical.'
END
ELSE
BEGIN
 PRINT 'Static data value 10639 - Historical already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF