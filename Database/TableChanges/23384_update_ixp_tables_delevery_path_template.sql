DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_delivery_path_template'

-- Update Mandatory
UPDATE ic 
SET ic.is_required = 0 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id
       AND ic.ixp_columns_name IN (
	     'path_name'
		 ,'path_code'
		 ,'loss_factor'
	)

-- Update Repetition
UPDATE ic 
SET ic.is_major = 1 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id 
       AND ic.ixp_columns_name IN (
	    'from_location'
		,'to_location'
	)

