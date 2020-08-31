DECLARE @value_id INT 
SELECT @value_id = value_id FROM static_data_value sdv  WHERE sdv.code = 'MTM Reporting' AND sdv.type_id = 2150

IF NOT EXISTS (SELECT 1 FROM archive_data_policy WHERE main_table_name = 'source_deal_pnl')
BEGIN
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, [sequence], where_field, archive_frequency, existence_check_fields, tran_status)
	SELECT @value_id, 'source_deal_pnl', 'stage_source_deal_pnl', 1, 'pnl_as_of_date', 'd', 'source_deal_header_id, term_start, term_end, Leg, pnl_as_of_date, pnl_source_value_id','C'

	DECLARE @archive_data_policy_id INT
	SELECT @archive_data_policy_id = archive_data_policy_id FROM archive_data_policy WHERE main_table_name = 'source_deal_pnl'

	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, [sequence], archive_db, field_list, retention_period)
	SELECT @archive_data_policy_id, 'source_deal_pnl', 0, 1 , NULL, '*', 1 UNION ALL
	SELECT @archive_data_policy_id, 'source_deal_pnl_arch1', 1, 2 , NULL, '*', -1 UNION ALL 
	SELECT @archive_data_policy_id, 'source_deal_pnl_arch2', 1, 3 , NULL, '*', -1 
END
