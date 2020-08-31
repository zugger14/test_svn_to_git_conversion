	--delete from mapping
DELETE idm FROM ixp_import_data_mapping idm 
	INNER JOIN ixp_rules ir ON ir.ixp_rules_id = idm.ixp_rules_id 
	INNER JOIN ixp_columns ic ON ic.ixp_columns_id = idm.dest_column
WHERE ir.ixp_rules_name = 'Transportation Contract'
AND ic.ixp_columns_name IN ('block_definition','time_zone') 

DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_transportation_contract'

-- Update to non  Mandatory
UPDATE ic 
SET ic.is_required = 0
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id
       AND ic.ixp_columns_name IN (
	     'flow_start_date'
		,'flow_end_date'
	)
--update to non unique
UPDATE ic 
SET ic.is_major = 0
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id
       AND ic.ixp_columns_name IN (
	     'contract_name'
	)
	--UPDATE to mandatory and unique
UPDATE ic 
	SET ic.is_major = 1,
		ic.is_required = 1
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id
AND ic.ixp_columns_name IN (
'contract_id'
)
--update seq 
UPDATE ic SET seq = 190 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_id'







