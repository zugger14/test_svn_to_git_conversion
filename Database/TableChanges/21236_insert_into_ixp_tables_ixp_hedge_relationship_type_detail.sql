IF (SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_hedge_relationship_type_detail') IS NULL
BEGIN 
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
	VALUES ('ixp_hedge_relationship_type_detail', 'Hedging Relationship Type', 'i')
END
GO