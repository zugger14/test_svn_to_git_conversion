-- Shipper Code Mapping
DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_shipper_code_mapping'

-- required
UPDATE ic
SET is_required = 0
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	  'external_id'
)