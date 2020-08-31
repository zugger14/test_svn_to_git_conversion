-- 1 Insert into ixp_tables
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_eligibility_mapping_template')

BEGIN
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
	SELECT 'ixp_eligibility_mapping_template' , 'Eligibility Mapping', 'i'
END

-- 2 Insert into ixp_columns logical_name, constraint_type, value, uom, effective_date, frequency
DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_eligibility_mapping_template'

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id AND ic.ixp_columns_name LIKE 'template_name')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'template_name', 0 )
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id AND ic.ixp_columns_name LIKE 'jurisdiction_market')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'jurisdiction_market', 0 )
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id AND ic.ixp_columns_name LIKE 'tier')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'tier', 0 )
END
