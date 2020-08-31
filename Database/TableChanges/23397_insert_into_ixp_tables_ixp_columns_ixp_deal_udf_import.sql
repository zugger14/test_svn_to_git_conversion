/*

DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_deal_udf_import'

delete from ixp_columns where ixp_table_id=@ixp_tables_id
delete from ixp_tables where ixp_tables_id=@ixp_tables_id

*/

-- insert into ixp_tables
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_deal_udf_import')
BEGIN 
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag) 
	SELECT 'ixp_deal_udf_import', 'Deal UDF', 'i'
END

DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_deal_udf_import'
 
-- insert into ixp_columns
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'deal_ref_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'deal_ref_id', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'header_detail')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'header_detail', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'term')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'term', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'leg')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'leg', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'name')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'name', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'value')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'value', 'VARCHAR(600)', 0)
END

UPDATE ixp_columns
SET is_major = 1 
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name in (
	 'deal_ref_id'
	,'term'
	,'leg'
	,'name'
)

UPDATE ixp_columns
SET is_required = 1 
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name in (
'deal_ref_id'
,'header_detail'
,'name')

UPDATE ixp_columns SET seq = 10 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'deal_ref_id'
UPDATE ixp_columns SET seq = 20 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'header_detail'
UPDATE ixp_columns SET seq = 30 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'term'
UPDATE ixp_columns SET seq = 40 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'leg'
UPDATE ixp_columns SET seq = 50 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'name'
UPDATE ixp_columns SET seq = 60 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'value'