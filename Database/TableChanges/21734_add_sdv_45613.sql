SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45613)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (45600, 45613, 'First Day Of The Quarter', 'First Day Of The Quarter', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45613 - First Day Of The Quarter.'
END
ELSE
BEGIN
    PRINT 'Static data value 45613 - First Day Of The Quarter already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF