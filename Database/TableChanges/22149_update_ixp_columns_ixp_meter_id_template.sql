--SET Sequence
DECLARE @ixp_table_id VARCHAR(200)

SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_meter_id_template'

-- SET Required  

UPDATE ixp_columns 
SET is_required = 1 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name IN ('channel','channel_description','mult_factor')










