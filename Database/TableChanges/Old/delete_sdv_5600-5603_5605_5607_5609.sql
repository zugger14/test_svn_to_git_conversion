UPDATE source_deal_header SET deal_status = 5604 WHERE deal_status IN (5609, 5600, 5601, 5602, 5603, 5605, 5607)

UPDATE status_rule_detail SET from_status_id = 5604 WHERE from_status_id IN (5609, 5600, 5601, 5602, 5603, 5605, 5607)

UPDATE status_rule_detail SET to_status_id = 5604 WHERE to_status_id IN (5609, 5600, 5601, 5602, 5603, 5605, 5607)

UPDATE status_rule_detail SET Change_to_status_id = 5604 WHERE Change_to_status_id IN (5609, 5600, 5601, 5602, 5603, 5605, 5607)

UPDATE source_deal_header_template SET deal_status = 5604 WHERE deal_status IN (5609, 5600, 5601, 5602, 5603, 5605, 5607)

DELETE FROM static_data_value WHERE value_id IN (5609, 5600, 5601, 5602, 5603, 5605, 5607)