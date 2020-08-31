DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_contract_template'

IF EXISTS (SELECT * FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'storage_asset_id')
BEGIN
    UPDATE ixp_columns  
	SET is_required = 0 
	WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'storage_asset_id'
END

GO