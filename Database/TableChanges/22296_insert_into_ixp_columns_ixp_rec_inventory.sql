DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_rec_inventory'
 
-- insert into ixp_columns
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'facility_name')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, is_required, seq)
	VALUES
	(@ixp_tables_id,'facility_name',  0, 0, 12)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'technology')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, is_required, seq)
	VALUES
	(@ixp_tables_id,'technology',  0, 0, 14)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'generation_state')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, is_required, seq)
	VALUES
	(@ixp_tables_id,'generation_state',  0, 0, 16)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'source_certificate_number')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, is_required, seq)
	VALUES
	(@ixp_tables_id,'source_certificate_number',  0, 0, 130)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'action')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, is_required, seq)
	VALUES
	(@ixp_tables_id,'action',  0, 0, 140)
END

IF EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'expiry_date')
BEGIN
	UPDATE ixp_columns
	SET is_required = 0
	WHERE ixp_columns_name IN ('generator', 'issue_date')
		AND ixp_table_id = @ixp_tables_id
END