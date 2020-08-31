DECLARE @ixp_table_id VARCHAR(200)
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_location_template'

--SET Sequence
UPDATE ic 
SET seq = 10 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'location_id'

UPDATE ic 
SET seq = 20 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Location_Name'

UPDATE ic 
SET seq = 30 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Commodity_id'

UPDATE ic 
SET seq = 40 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Location_Description'

UPDATE ic 
SET seq = 50 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_major_location_ID'

UPDATE ic 
SET seq = 60 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term_pricing_index'

UPDATE ic 
SET seq = 70 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'profile_id'

UPDATE ic 
SET seq = 80 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'proxy_profile_id'

UPDATE ic 
SET seq = 90 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Meter_ID'

UPDATE ic 
SET seq = 100 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'meter_type'

UPDATE ic 
SET seq = 110 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'effective_date'

UPDATE ic 
SET seq = 120 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'country'

UPDATE ic 
SET seq = 130 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'region'

UPDATE ic 
SET seq = 140 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'province'

UPDATE ic 
SET seq = 150 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'grid_value_id'

UPDATE ic 
SET seq = 160 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'time_zone'


	 
-- SET Required  
UPDATE ixp_columns 
SET is_required = 1 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name IN ('location_id', 'Location_Name', 'Commodity_id')

--SET  Unique
UPDATE ixp_columns 
SET is_major = 1 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'location_id'

--SET datatype
UPDATE ixp_columns 
SET datatype = '[datetime]' 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'effective_date'
