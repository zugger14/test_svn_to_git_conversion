
 
IF NOT EXISTS (SELECT 1 FROM ixp_ssis_configurations it WHERE it.package_name = 'NymexPlattsTreasury') 
BEGIN
	 INSERT INTO ixp_ssis_configurations(package_name, package_description, config_filter_value)
	 SELECT 'NymexPlattsTreasury', 'Nymex Treasury Platts Import', 'PKG_NymexTreasuryPlattsPriceCurveImport' 
END

/*
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_Platts_template') 
BEGIN
	 INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)   
	 SELECT 'ixp_Platts_template'  , 'Platts', 'i' 
END

INSERT INTO ixp_table_meta_data (ixp_tables_id, table_name)
SELECT it.ixp_tables_id,
       it.ixp_tables_name
FROM   ixp_tables it
LEFT JOIN ixp_table_meta_data itmd ON itmd.ixp_tables_id = it.ixp_tables_id
WHERE itmd.ixp_table_meta_data_table_id IS NULL

DECLARE @ixp_platts_template_id INT	
SELECT @ixp_platts_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_Platts_template'

IF @ixp_platts_template_id IS NOT NULL
BEGIN

	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'as_of_date' AND ixp_table_id = @ixp_platts_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_platts_template_id, 'as_of_date', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'maturity_date' AND ixp_table_id = @ixp_platts_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_platts_template_id, 'maturity_date', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'open' AND ixp_table_id = @ixp_platts_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_platts_template_id, 'open', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'high' AND ixp_table_id = @ixp_platts_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_platts_template_id, 'high', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'low' AND ixp_table_id = @ixp_platts_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_platts_template_id, 'low', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'last' AND ixp_table_id = @ixp_platts_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_platts_template_id, 'last', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'change' AND ixp_table_id = @ixp_platts_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_platts_template_id, 'change', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'settle' AND ixp_table_id = @ixp_platts_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_platts_template_id, 'settle', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'Volume' AND ixp_table_id = @ixp_platts_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_platts_template_id, 'Volume', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'open_interest' AND ixp_table_id = @ixp_platts_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_platts_template_id, 'open_interest', 0, NULL END
 	
END
ELSE
BEGIN
	SELECT 'ixp_Platts_template not present in ixp_tables'
END

*/

