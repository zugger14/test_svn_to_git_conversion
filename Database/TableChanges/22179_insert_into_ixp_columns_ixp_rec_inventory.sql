DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_rec_inventory'
 
-- insert into ixp_columns
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'counterparty')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, is_required, seq)
	VALUES
	(@ixp_tables_id,'counterparty',  1, 0, 16)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'price')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, is_required, seq)
	VALUES
	(@ixp_tables_id,'price',  0, 0, 85)
END


IF EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'expiry_date')
BEGIN
	UPDATE ixp_columns
	SET is_required = 0
	WHERE ixp_columns_name = 'expiry_date'
		AND ixp_table_id = @ixp_tables_id
END