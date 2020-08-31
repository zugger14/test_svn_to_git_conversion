-- 1 Insert into ixp_tables
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_product_detail_template')

BEGIN
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
	SELECT 'ixp_product_detail_template' , 'Product Detail', 'i'
END

-- 2 Insert into ixp_columns logical_name, constraint_type, value, uom, effective_date, frequency
DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_product_detail_template'

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id AND ic.ixp_columns_name LIKE 'deal_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'deal_id', 0 )
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id AND ic.ixp_columns_name LIKE 'in_or_not')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'in_or_not', 0 )
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id AND ic.ixp_columns_name LIKE 'region')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'region', 0 )
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id AND ic.ixp_columns_name LIKE 'jurisdiction')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'jurisdiction', 0 )
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id AND ic.ixp_columns_name LIKE 'tier')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'tier', 0 )
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id AND ic.ixp_columns_name LIKE 'technology')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'technology', 0 )
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id AND ic.ixp_columns_name LIKE 'vintage')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'vintage', 0 )
END

