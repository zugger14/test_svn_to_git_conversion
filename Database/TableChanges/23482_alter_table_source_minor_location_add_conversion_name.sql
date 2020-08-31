
IF COL_LENGTH('source_minor_location', 'conversion_value_id') IS NULL
BEGIN
	ALTER TABLE source_minor_location ADD conversion_value_id INT NULL
END
ELSE 
	PRINT('Column conversion_value_id already exists')	
GO


