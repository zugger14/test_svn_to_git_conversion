UPDATE source_deal_header SET deal_status = NULL WHERE deal_status = 5608

UPDATE status_rule_detail SET change_to_status_id = NULL WHERE change_to_status_id = 5608

IF EXISTS(SELECT 'x' FROM static_data_value WHERE value_id = 5608)
DELETE FROM STATIC_data_value WHERE value_id = 5608

