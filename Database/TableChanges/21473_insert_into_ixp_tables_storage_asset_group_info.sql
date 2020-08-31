IF NOT EXISTS(SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_storage_asset_group_info')
BEGIN
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
	VALUES ('ixp_storage_asset_group_info', 'Storage Asset Group Info', 'i')

	PRINT 'ixp_storage_asset_group_info import rule added.'
END 

GO