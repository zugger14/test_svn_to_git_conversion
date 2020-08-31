-- is_major
UPDATE ic
SET is_major = 0
-- SELECT * 
FROM ixp_columns ic
INNER JOIN ixp_tables it 
	ON ic.ixp_table_id = it.ixp_tables_id
	AND it.ixp_tables_name = 'ixp_source_book_template'
	AND ixp_columns_name = 'source_book_name'

-- is_required
UPDATE ic
SET is_required = 1
-- SELECT *
FROM ixp_columns ic
INNER JOIN ixp_tables it 
	ON ic.ixp_table_id = it.ixp_tables_id
	AND it.ixp_tables_name = 'ixp_source_book_template'
	AND ixp_columns_name IN (
		 'source_book_name'
		,'source_system_book_id'
		,'source_system_book_type_value_id'
	)