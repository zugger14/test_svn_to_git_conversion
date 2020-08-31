DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_deal_volume_update_template'

-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'term_start'
)

-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'source_deal_header_id'
	,'deal_id'
	,'term_start'
)
-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'term_start'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_deal_header_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_id'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term_start'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_volume'
