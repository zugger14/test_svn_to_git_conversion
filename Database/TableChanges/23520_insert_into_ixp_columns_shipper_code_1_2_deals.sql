DECLARE @ixp_table_id INT

SELECT @ixp_table_id = ixp_tables_id
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_source_deal_template'

IF NOT EXISTS(
	SELECT 1
	FROM ixp_columns
	WHERE ixp_table_id = @ixp_table_id
		AND ixp_columns_name = 'shipper_code1'
)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail, seq, datatype, is_required)
	SELECT @ixp_table_id, 'shipper_code1', 'NVARCHAR(600)', 0, 'd', 808, NULL, 0
END

IF NOT EXISTS(
	SELECT 1
	FROM ixp_columns
	WHERE ixp_table_id = @ixp_table_id
		AND ixp_columns_name = 'shipper_code2'
)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail, seq, datatype, is_required)
	SELECT @ixp_table_id, 'shipper_code2', 'NVARCHAR(600)', 0, 'd', 809, NULL, 0
END

UPDATE ic
SET seq = 808
-- SELECT *
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
	AND ixp_columns_name = 'shipper_code1'

UPDATE ic
SET seq = 809
-- SELECT *
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
	AND ixp_columns_name = 'shipper_code2'

UPDATE ic
SET seq = 801
-- SELECT *
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
	AND ixp_columns_name = 'close_reference_id'

UPDATE ic
SET seq = 802
-- SELECT *
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
	AND ixp_columns_name = 'product_id'

UPDATE ic
SET seq = 101
-- SELECT *
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
	AND ixp_columns_name = 'deal_sub_type_type_id'

GO