UPDATE ic
SET ic.is_required = 0
FROM ixp_columns ic
INNER JOIN ixp_tables it ON ic.ixp_table_id = it.ixp_tables_id
WHERE it.ixp_tables_name = 'ixp_rec_certified_volume'
	AND ixp_columns_name IN ('expiry_date', 'issue_date')