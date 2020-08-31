IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE main_table_name = 'source_deal_pnl')
BEGIN
	INSERT INTO archive_data_policy(archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields, tran_status)
	SELECT 2163, 'source_deal_pnl', 'stage_source_deal_pnl', 1, 'pnl_as_of_date', 'd', 'source_deal_header_id, term_start, term_end, Leg, pnl_as_of_date, pnl_source_value_id', 'C'

	PRINT 'Value inserted successfully for ''source_deal_pnl''.'
END
GO
DECLARE @archive_data_policy_id INT

SELECT @archive_data_policy_id = archive_data_policy_id FROM archive_data_policy WHERE main_table_name = 'source_deal_pnl'

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE table_name = 'source_deal_pnl' and archive_data_policy_id = @archive_data_policy_id)
BEGIN
	INSERT INTO archive_data_policy_detail(archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @archive_data_policy_id, 'source_deal_pnl', 0, 1,	NULL, '*', 1	
END

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE table_name = 'source_deal_pnl_arch1' and archive_data_policy_id = @archive_data_policy_id)
BEGIN
	INSERT INTO archive_data_policy_detail(archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @archive_data_policy_id, 'source_deal_pnl_arch1', 1, 2, NULL, '*',	-1 
END

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE table_name = 'source_deal_pnl_arch2' and archive_data_policy_id = @archive_data_policy_id)
BEGIN
	INSERT INTO archive_data_policy_detail(archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @archive_data_policy_id, 'source_deal_pnl_arch2', 1,	3, NULL, '*',	-1
END
