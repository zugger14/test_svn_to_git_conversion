IF NOT EXISTS(SELECT 1  FROM ixp_tables t inner join ixp_columns c on t.ixp_tables_id = c.ixp_table_id where ixp_tables_id = 4 and (ixp_columns_name = 'contract_id' or ixp_columns_name = 'contract_name'))
BEGIN 
	UPDATE c
	SET c.is_major = 1
	FROM ixp_tables t
	INNER JOIN ixp_columns c ON t.ixp_tables_id = c.ixp_table_id
	WHERE ixp_tables_id = 4
		AND (
			ixp_columns_name = 'contract_id'
			OR ixp_columns_name = 'contract_name'
			)
END

IF NOT EXISTS(SELECT 1 FROM ixp_tables t INNER JOIN ixp_columns c ON t.ixp_tables_id = c.ixp_table_id WHERE ixp_tables_id = 4
		AND ixp_columns_name LIKE '%date'
		AND NULLIF(datatype, '') IS NULL)
BEGIN
	UPDATE c
	SET c.datatype = '[datetime]'
	FROM ixp_tables t
	INNER JOIN ixp_columns c ON t.ixp_tables_id = c.ixp_table_id
	WHERE ixp_tables_id = 4
		AND ixp_columns_name LIKE '%date'
END
