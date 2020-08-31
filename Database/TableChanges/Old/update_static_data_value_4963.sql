
UPDATE static_data_type
SET    internal = 1
WHERE  [type_id] = 17300
PRINT 'Updated Static data type 17300 - Deal Profile.'

GO

DELETE 
FROM   static_data_value
WHERE  [type_id] = 17300
       AND value_id = 292057

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17300)
BEGIN	
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)	
	VALUES (17300, 17300, 'Deal Volume', 'Deal Volume', 'farrms_admin', GETDATE())	
	PRINT 'Inserted static data value 17300 - Deal Volume.'END
ELSE
BEGIN	
	PRINT 'Static data value 17300 - Deal Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO

--SELECT * FROM static_data_value WHERE value_id = 17000