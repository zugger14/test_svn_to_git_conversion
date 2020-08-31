-- insert into ixp_tables
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_deal_udf_import')
BEGIN 
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag) 
	SELECT 'ixp_deal_udf_import', 'Deal UDF Import', 'i'
END

DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_deal_udf_import'
 
-- insert into ixp_columns
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'deal_ref_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'deal_ref_id', 'VARCHAR(200)', 1)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'header_detail')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'header_detail', 'VARCHAR(50)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'term')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'term', 'VARCHAR(50)', 1)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'tab')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'tab', 'VARCHAR(100)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'name')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'name', 'VARCHAR(200)', 1)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'value')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'value', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'currency')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'currency', 'VARCHAR(50)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'uom')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'uom', 'VARCHAR(50)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'counterparty')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'counterparty', 'VARCHAR(100)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'contract')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'contract', 'VARCHAR(100)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'rec_pay')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'rec_pay', 'VARCHAR(50)', 0)
END

UPDATE ixp_columns
SET is_required = 1 
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name in (
'deal_ref_id'
,'header_detail'
,'tab'
,'name')

UPDATE ixp_columns SET seq = 10 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'deal_ref_id'
UPDATE ixp_columns SET seq = 20 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'header_detail'
UPDATE ixp_columns SET seq = 30 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'term'
UPDATE ixp_columns SET seq = 40 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'tab'
UPDATE ixp_columns SET seq = 50 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'name'
UPDATE ixp_columns SET seq = 60 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'value'
UPDATE ixp_columns SET seq = 70 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'currency'
UPDATE ixp_columns SET seq = 80 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'uom'
UPDATE ixp_columns SET seq = 90 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'counterparty'
UPDATE ixp_columns SET seq = 100 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'contract'
UPDATE ixp_columns SET seq = 110 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'rec_pay'
