DECLARE @ixp_tables_id INT = NULL

SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_meter_id_template'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'channel' AND ixp_table_id = @ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id,'channel','VARCHAR(600)',0)
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'channel_description' AND ixp_table_id = @ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id,'channel_description','VARCHAR(600)',0)
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'mult_factor' AND ixp_table_id = @ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id,'mult_factor','VARCHAR(600)',0)
END

GO