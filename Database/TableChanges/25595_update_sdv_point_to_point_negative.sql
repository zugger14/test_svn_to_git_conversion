UPDATE static_data_value 
	SET code = code + ' old'
WHERE type_id = 31400 
	AND [code] = 'Point-Point' 
	AND value_id > 0
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -31400)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (31400, -31400, 'Point-Point', 'Point-Point', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -31400 - Point-Point.'
END
ELSE
BEGIN
    PRINT 'Static data value -31400 - Point-Point already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      

GO

DECLARE @value_id INT, @new_value_id INT

SELECT @value_id = value_id
FROM static_data_value 
WHERE type_id = 31400 
	AND [code] = 'Point-Point old' 
	AND value_id > 0

SELECT @new_value_id = value_id 
FROM static_data_value 
WHERE type_id = 31400 
	AND [code] = 'Point-Point' 
	AND value_id < 0

UPDATE dbo.delivery_path SET priority = @new_value_id  WHERE priority = @value_id 

DELETE FROM static_data_value 
WHERE type_id = 31400 
	AND [code] = 'Point-Point old' 
	AND value_id > 0



