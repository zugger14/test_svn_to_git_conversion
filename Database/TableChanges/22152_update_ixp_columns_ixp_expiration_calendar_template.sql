DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_expiration_calendar_template'

-- Update Mandatory
UPDATE ic 
SET ic.is_required = 1 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id
       AND ic.ixp_columns_name IN (
	     'expiration_calendar'
		,'delivery_period'
		,'expiration_from'
		,'expiration_to'
	)

-- Update Repetition
UPDATE ic 
SET ic.is_major = 1 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id 
       AND ic.ixp_columns_name IN (
	     'expiration_calendar'
		,'delivery_period'
		,'expiration_from'
		,'expiration_to'
	)

-- Update Date
UPDATE ic 
SET ic.datatype = '[datetime]' 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id 
       AND ic.ixp_columns_name IN (
	     'delivery_period'
		,'expiration_from'
		,'expiration_to'
	)

-- Update sequence
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'expiration_calendar'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'description'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'holiday_calendar'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'delivery_period'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'expiration_from'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'expiration_to'




