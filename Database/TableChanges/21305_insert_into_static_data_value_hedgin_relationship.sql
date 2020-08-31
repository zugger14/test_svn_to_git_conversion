SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23507)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (23507, 23500, 'Hedging Relationship', 'Hedging Relationship', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 23507 - Hedging Relationship.'
END 
ELSE
BEGIN
    PRINT 'Static data value 23507 - Hedging Relationship already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF