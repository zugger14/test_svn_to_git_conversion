DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_recovery_rate'

-- Update Mandatory
UPDATE ic 
SET ic.is_required = 1 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id
       AND ic.ixp_columns_name IN (
	     'effective_date'
		,'debt_rating'
		,'rate'
		,'months'
		,'rating_type'
	)

-- Update Repetition
UPDATE ic 
SET ic.is_major = 1 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id 
       AND ic.ixp_columns_name IN (
	    'effective_date'
		,'debt_rating'
		,'rating_type'
	)

-- Update Date
UPDATE ic 
SET ic.datatype = '[datetime]' 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id 
       AND ic.ixp_columns_name IN (
	     'effective_date'
	)

-- Update sequence
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'effective_date'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'debt_rating'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'months'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'rate'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'rating_type'





