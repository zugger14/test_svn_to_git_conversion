DECLARE @ixp_table_id INT

SELECT @ixp_table_id = ixp_tables_id from ixp_tables where ixp_tables_name = 'ixp_delivery_path_template'

IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'effective_date' AND ixp_table_id = @ixp_table_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required, datatype)
	VALUES (@ixp_table_id, 'effective_date','VARCHAR(600)',0, 120, 0, '[datetime]')
END
