DECLARE @_ixp_tables_id INT

SELECT @_ixp_tables_id = ixp_tables_id From ixp_tables where ixp_tables_name = 'ixp_source_deal_detail_15min_template'

IF EXISTS (SELECT 1 From ixp_columns WHERE ixp_table_id = @_ixp_tables_id AND ixp_columns_name = 'volume' AND is_required <> 0)
BEGIN
	UPDATE ixp_columns SET is_required = 0 WHERE ixp_table_id = @_ixp_tables_id AND ixp_columns_name = 'volume'
	PRINT 'Column volume updated successfully.'
END

IF EXISTS (SELECT 1 From ixp_columns WHERE ixp_table_id = @_ixp_tables_id AND ixp_columns_name = 'schedule_volume' AND is_required <> 0)
BEGIN
	UPDATE ixp_columns SET is_required = 0 WHERE ixp_table_id = @_ixp_tables_id AND ixp_columns_name = 'schedule_volume'
	PRINT 'Column schedule_volume updated successfully.'
END

IF EXISTS (SELECT 1 From ixp_columns WHERE ixp_table_id = @_ixp_tables_id AND ixp_columns_name = 'actual_volume' AND is_required <> 0)
BEGIN
	UPDATE ixp_columns SET is_required = 0 WHERE ixp_table_id = @_ixp_tables_id AND ixp_columns_name = 'actual_volume'
	PRINT 'Column actual_volume updated successfully.'
END