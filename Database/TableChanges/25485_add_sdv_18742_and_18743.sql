SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18742)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (18700, 18742, 'Positive Price Commodity', 'Positive Price Commodity', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 18742 - Positive Price Commodity.'
END
ELSE
BEGIN
    PRINT 'Static data value 18742 - Positive Price Commodity already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18743)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (18700, 18743, 'Negative Price Commodity', 'Negative Price Commodity', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 18743 - Negative Price Commodity.'
END
ELSE
BEGIN
    PRINT 'Static data value 18743 - Negative Price Commodity already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   

     