IF EXISTS(SELECT 1 FROM process_table_archive_policy WHERE tbl_name IN ('deal_detail_hour', 'source_price_curve'))
BEGIN
	DELETE FROM process_table_archive_policy
	WHERE tbl_name IN ('deal_detail_hour', 'source_price_curve')
	
	PRINT 'Value successfully deleted for ''deal_detail_hour'' and  ''source_price_curve''.'
END