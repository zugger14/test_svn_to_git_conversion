-- insert into ixp_tables
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_rec_rps_import_template')
BEGIN 
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag) 
	SELECT 'ixp_rec_rps_import_template', 'REC RPS Import', 'i'
END

DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_rec_rps_import_template'
 
-- insert into ixp_columns
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'compliance_period')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'compliance_period', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'retirement_types')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'retirement_types', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'vintage_year')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'vintage_year', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'vintage_month')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'vintage_month', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'generator')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'generator', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'volume')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'volume', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'jurisdiction')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'jurisdiction', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'tier')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'tier', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'certificate_from')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'certificate_from', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'certificate_to')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'certificate_to', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'sequence_from')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'sequence_from', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'sequence_to')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'sequence_to', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'transferor_counterparty')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'transferor_counterparty', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'transferee_counterparty')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'transferee_counterparty', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'delivery_date')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'delivery_date', 'VARCHAR(600)', 0)
END

UPDATE ixp_columns
SET is_required = 1 
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name in (
'compliance_period'
,'vintage_year'
,'vintage_month'
,'volume'
,'jurisdiction'
,'tier'
,'certificate_from'
,'certificate_to'
,'sequence_from'
,'sequence_to'
,'transferee_counterparty')

UPDATE ixp_columns SET seq = 10 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'compliance_period'
UPDATE ixp_columns SET seq = 20 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'retirement_types'
UPDATE ixp_columns SET seq = 30 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'vintage_year'
UPDATE ixp_columns SET seq = 40 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'vintage_month'
UPDATE ixp_columns SET seq = 50 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'generator'
UPDATE ixp_columns SET seq = 60 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'volume'
UPDATE ixp_columns SET seq = 70 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'jurisdiction'
UPDATE ixp_columns SET seq = 80 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'tier'
UPDATE ixp_columns SET seq = 90 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'certificate_from'
UPDATE ixp_columns SET seq = 100 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'certificate_to'
UPDATE ixp_columns SET seq = 110 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'sequence_from'
UPDATE ixp_columns SET seq = 120 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'sequence_to'
UPDATE ixp_columns SET seq = 130 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'transferor_counterparty'
UPDATE ixp_columns SET seq = 140 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'transferee_counterparty'
UPDATE ixp_columns SET seq = 150 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'delivery_date'

