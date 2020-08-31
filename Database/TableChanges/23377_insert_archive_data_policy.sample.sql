DECLARE @archive_linked_server VARCHAR(100) = ''  --todo: If archiveDB in same server set as, '' else change to linkserver name (e.g FARRMSARCH)
DECLARE @archive_db VARCHAR(250) = ''  --todo: change to archive DB name

------------------------------------

SET @archive_db = CASE WHEN @archive_linked_server <> '' THEN @archive_linked_server + '.' ELSE '' END  + @archive_db 

DELETE FROM archive_data_policy_detail
DELETE FROM archive_data_policy

INSERT INTO archive_data_policy(archive_type_value_id, main_table_name, staging_table_name, [sequence], where_field, archive_frequency, existence_check_fields, tran_status)
SELECT 2155, 'source_price_curve', NULL, 1, 'as_of_date', 'm', 'source_curve_def_id, as_of_date, assessment_curve_type_value_id, curve_source_value_id, maturity_date, is_dst', 'F'

INSERT INTO archive_data_policy(archive_type_value_id, main_table_name, staging_table_name, [sequence], where_field, archive_frequency, existence_check_fields, tran_status)
SELECT 2172, 'deal_detail_hour', NULL, 1, 'term_date', 'm', 'term_date, profile_id, period', 'F'

--archive_data_policy_detail
INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
SELECT adp.archive_data_policy_id, 'source_price_curve', 0, 1, NULL, '*', 12 FROM archive_data_policy adp
LEFT JOIN archive_data_policy_detail adpd ON adpd.archive_data_policy_id = adp.archive_data_policy_id AND adpd.table_name = 'source_price_curve'
WHERE adp.archive_type_value_id = 2155 AND adpd.archive_data_policy_detail_id IS NULL	
UNION ALL
SELECT adp.archive_data_policy_id, 'source_price_curve_arch1', 1, 2, @archive_db, '*', -1 FROM archive_data_policy adp
LEFT JOIN archive_data_policy_detail adpd ON adpd.archive_data_policy_id = adp.archive_data_policy_id AND adpd.table_name = 'source_price_curve_arch1'
WHERE adp.archive_type_value_id = 2155 AND adpd.archive_data_policy_detail_id IS NULL	

--forecast data (not Nomination data)
UNION ALL
SELECT adp.archive_data_policy_id, 'deal_detail_hour', 0, 1, NULL, '*', 12 FROM archive_data_policy adp
LEFT JOIN archive_data_policy_detail adpd ON adpd.archive_data_policy_id = adp.archive_data_policy_id AND adpd.table_name = 'deal_detail_hour'
WHERE adp.archive_type_value_id = 2172 AND adpd.archive_data_policy_detail_id IS NULL	
UNION ALL
SELECT adp.archive_data_policy_id, 'deal_detail_hour_arch1', 1, 2, @archive_db, '*', -1 FROM archive_data_policy adp
LEFT JOIN archive_data_policy_detail adpd ON adpd.archive_data_policy_id = adp.archive_data_policy_id AND adpd.table_name = 'deal_detail_hour_arch1'
WHERE adp.archive_type_value_id = 2172 AND adpd.archive_data_policy_detail_id IS NULL	




 
