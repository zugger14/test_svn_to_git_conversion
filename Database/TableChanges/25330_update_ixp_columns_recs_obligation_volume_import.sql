DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_recs_obligation_volumes_import_template'
 
-- Update min_target
UPDATE ixp_columns 
set is_required = 0
WHERE ixp_columns_name = 'min_target'
	AND ixp_table_id = @ixp_table_id

--update min_absolute_target
UPDATE ixp_columns 
set is_required = 0
WHERE ixp_columns_name = 'min_absolute_target'
	AND ixp_table_id = @ixp_table_id
