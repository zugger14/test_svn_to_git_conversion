DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_rec_volumes'
 
-- insert into ixp_columns
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'leg')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, seq, datatype, is_required) 
	VALUES
	(@ixp_tables_id, 'leg', 1, 21, NULL, 1)
END
