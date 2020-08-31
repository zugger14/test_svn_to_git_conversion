-- insert into ixp_tables

IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_rec_sales_transfer_import_template')
BEGIN 
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag) 
	SELECT 'ixp_rec_sales_transfer_import_template', 'REC Sales/Transfer Import', 'i'
END

DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_rec_sales_transfer_import_template'
 
-- insert into ixp_columns
IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'wregis_gu_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'wregis_gu_id', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'month')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'month', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'year')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'year', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'date_transfer')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'date_transfer', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'transferee')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'transferee', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'state')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'state', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'tier')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'tier', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'quantity')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'quantity', 0 )
END

