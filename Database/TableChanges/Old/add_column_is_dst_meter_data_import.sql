IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic INNER JOIN ixp_tables AS it ON it.ixp_tables_id = ic.ixp_table_id WHERE it.ixp_tables_name LIKE 'ixp_15mins_allocation_data_template' and ic.ixp_columns_name LIKE 'is_dst')
 BEGIN
 	DECLARE @ixp_tables_id INT
 	SELECT @ixp_tables_id  = it.ixp_tables_id
 	FROM ixp_tables AS it
 	WHERE it.ixp_tables_name LIKE 'ixp_15mins_allocation_data_template'
 	
 	INSERT INTO ixp_columns
 	(
 		ixp_table_id,
 		ixp_columns_name,
 		column_datatype,
 		is_major
 	)
 	VALUES
 	(
 		@ixp_tables_id,
 		'is_dst',
 		'VARCHAR(600)',
 		0
 	)
 END