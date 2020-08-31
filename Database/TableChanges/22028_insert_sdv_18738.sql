SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18738)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (18700, 18738, 'Commodity Based Fee', 'Commodity Based Fee', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 18738 - Commodity Based Fee.'
END
ELSE
BEGIN
    PRINT 'Static data value 18738 - Commodity Based Fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            