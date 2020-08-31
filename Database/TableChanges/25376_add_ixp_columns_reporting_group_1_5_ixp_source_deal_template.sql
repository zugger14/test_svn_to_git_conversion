DECLARE @_ixp_tables_id INT

SELECT @_ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_deal_template'
 
IF NOT EXISTS( SELECT 1 FROM ixp_columns WHERE ixp_table_id = @_ixp_tables_id AND ixp_columns_name = 'reporting_group1')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail, seq, datatype, is_required)
	SELECT @_ixp_tables_id, 'reporting_group1', 'NVARCHAR(600)', 0, 'h', 1020, NULL, 0
END

IF NOT EXISTS( SELECT 1 FROM ixp_columns WHERE ixp_table_id = @_ixp_tables_id AND ixp_columns_name = 'reporting_group2')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail, seq, datatype, is_required)
	SELECT @_ixp_tables_id, 'reporting_group2', 'NVARCHAR(600)', 0, 'h', 1030, NULL, 0
END

IF NOT EXISTS( SELECT 1 FROM ixp_columns WHERE ixp_table_id = @_ixp_tables_id AND ixp_columns_name = 'reporting_group3')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail, seq, datatype, is_required)
	SELECT @_ixp_tables_id, 'reporting_group3', 'NVARCHAR(600)', 0, 'h', 1040, NULL, 0
END

IF NOT EXISTS( SELECT 1 FROM ixp_columns WHERE ixp_table_id = @_ixp_tables_id AND ixp_columns_name = 'reporting_group4')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail, seq, datatype, is_required)
	SELECT @_ixp_tables_id, 'reporting_group4', 'NVARCHAR(600)', 0, 'h', 1050, NULL, 0
END

IF NOT EXISTS( SELECT 1 FROM ixp_columns WHERE ixp_table_id = @_ixp_tables_id AND ixp_columns_name = 'reporting_group5')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail, seq, datatype, is_required)
	SELECT @_ixp_tables_id, 'reporting_group5', 'NVARCHAR(600)', 0, 'h', 1060, NULL, 0
END

GO

