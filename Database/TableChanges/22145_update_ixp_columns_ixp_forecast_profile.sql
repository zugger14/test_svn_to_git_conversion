--SET Sequence
DECLARE @ixp_table_id VARCHAR(200)

SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_forecast_profile'

UPDATE ic 
SET seq = 10 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'profile_name'

UPDATE ic 
SET seq = 20 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'profile_type'

UPDATE ic 
SET seq = 30 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'profile_code'

UPDATE ic 
SET seq = 40 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'uom_id'

UPDATE ic 
SET seq = 50 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'granularity'
	 
-- SET Required  

UPDATE ixp_columns 
SET is_required = 1 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name IN ('profile_name','profile_type','profile_code','uom_id','granularity')

--SET  Unique

UPDATE ixp_columns 
SET is_major = 1 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'profile_code'









