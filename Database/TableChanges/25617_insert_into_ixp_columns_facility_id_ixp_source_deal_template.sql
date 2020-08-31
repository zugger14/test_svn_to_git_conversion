DECLARE @ixp_table_id INT

SELECT @ixp_table_id = ixp_tables_id
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_source_deal_template'

IF NOT EXISTS(
	SELECT 1
	FROM ixp_columns
	WHERE ixp_table_id = @ixp_table_id
		AND ixp_columns_name = 'facility_id'
)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail, seq, datatype, is_required)
	SELECT @ixp_table_id, 'facility_id', 'NVARCHAR(600)', 0, NULL, NULL, NULL, 0
END