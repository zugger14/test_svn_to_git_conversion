UPDATE ic 
SET ic.is_required = 0
--SELECT ic.is_required
FROM ixp_columns ic
INNER JOIN ixp_tables it
	ON ic.ixp_table_id = it.ixp_tables_id
WHERE it.ixp_tables_name = 'ixp_rec_generator'
	AND ic.ixp_columns_name = 'eligibility_mapping_template'