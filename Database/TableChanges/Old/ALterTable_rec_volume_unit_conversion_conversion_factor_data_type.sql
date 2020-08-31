

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'rec_volume_unit_conversion' AND COLUMN_NAME = 'conversion_factor' AND DATA_TYPE = 'float')
BEGIN
	ALTER TABLE rec_volume_unit_conversion 
	ALTER COLUMN conversion_factor numeric(38,20) NULL
END
ELSE 
PRINT  'Data type float does not exists'