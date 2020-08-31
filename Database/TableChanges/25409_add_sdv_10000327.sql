SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000327)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (20500, 10000327, 'Contract Amendment - Post Update', 'Contract Amendment - Post Update', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000327 - Contract Amendment - Post Update.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000327 - Contract Amendment - Post Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF