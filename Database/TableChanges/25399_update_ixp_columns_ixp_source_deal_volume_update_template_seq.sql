DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_deal_volume_update_template'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'schedule_volume' AND ixp_table_id = @ixp_table_id) 
BEGIN 
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, is_required, seq, datatype) 
	SELECT @ixp_table_id, 'schedule_volume', 0, 0, 50, NULL 
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'actual_volume' AND ixp_table_id = @ixp_table_id) 
BEGIN 
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, is_required, seq, datatype)
	SELECT @ixp_table_id, 'actual_volume', 0, 0, 60, NULL
END
	
-- seq
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'schedule_volume'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'actual_volume'
