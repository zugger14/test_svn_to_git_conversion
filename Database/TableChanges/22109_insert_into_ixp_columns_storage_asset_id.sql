DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_contract_template'

IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'storage_asset_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, is_required)
	VALUES (@ixp_table_id, 'storage_asset_id', 'VARCHAR(600)', 0, 0)
END

GO