-- REC Certificate
DECLARE @ixp_table_id INT
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_rec_certified_volume'

-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'deal_id'
	,'production_start_date'
	,'production_end_date'
	,'leg'
	,'jurisdiction'
	,'tier'
	,'certification_entity'
	,'year'
	,'certificate_start_id'
	,'certificate_end_id'
	,'certificate_seq_from'
	,'certificate_seq_to'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'deal_id'
	,'production_start_date'
	,'production_end_date'
	,'jurisdiction'
	,'tier'
	,'certification_entity'
	,'leg'
)
-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'production_start_date'
	,'production_end_date'
	,'issue_date'
	,'expiry_date'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'production_start_date'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'production_end_date'
UPDATE ic SET seq = 31 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'leg'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'jurisdiction'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'tier'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certification_entity'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'issue_date'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'expiry_date'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'year'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certificate_start_id'
UPDATE ic SET seq = 110 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certificate_end_id'
UPDATE ic SET seq = 120 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certificate_seq_from'
UPDATE ic SET seq = 130 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certificate_seq_to'