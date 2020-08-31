IF EXISTS (SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_trader_template')
BEGIN
	DECLARE @ixp_tables_id INT
	SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_trader_template'

	UPDATE ixp_columns
	SET is_required = 1
	WHERE ixp_columns_name IN ('trader_id','trader_name')
		AND ixp_table_id = @ixp_tables_id
END