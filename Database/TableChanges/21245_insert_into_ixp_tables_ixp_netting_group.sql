IF (SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_netting_group') IS NULL
BEGIN 
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
	VALUES ('ixp_netting_group', 'Setup Netting Group', 'i')
END

GO