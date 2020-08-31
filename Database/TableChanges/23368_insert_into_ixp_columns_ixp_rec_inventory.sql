DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_rec_inventory'
 
-- insert into ixp_columns
IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'certification_entity')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, is_required, seq)
	VALUES
	(@ixp_tables_id,'certification_entity',  0, 1, 88)
END

IF EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'certificate_serial_numbers_from')
BEGIN	
	UPDATE ixp_columns SET is_major = 1 WHERE ixp_table_id = @ixp_tables_id and ixp_columns_name = 'certificate_serial_numbers_from'
END


IF EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'certificate_serial_numbers_to')
BEGIN	
	UPDATE ixp_columns SET is_major = 1 WHERE ixp_table_id = @ixp_tables_id and ixp_columns_name = 'certificate_serial_numbers_to'
END