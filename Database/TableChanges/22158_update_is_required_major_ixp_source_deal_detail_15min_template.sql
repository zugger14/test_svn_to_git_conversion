DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_deal_detail_15min_template'

UPDATE ixp_columns
SET is_required = 0, is_major = 0
WHERE ixp_table_id = @ixp_table_id

UPDATE ixp_columns
SET is_required = 1, is_major = 1
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name IN ('deal_id', 'term_date', 'is_dst', 'leg')

UPDATE ixp_columns
SET is_required = 1
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'volume'

UPDATE ixp_columns
SET is_major = 1
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name IN ('hr', 'minute')

UPDATE ixp_columns
SET datatype = '[datetime]'
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term_date'

GO