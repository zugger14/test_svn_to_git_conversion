UPDATE b 
SET is_primary = 'y' 
FROM alert_table_definition a
INNER JOIN alert_columns_definition b ON a.alert_table_definition_id = b.alert_table_id
WHERE a.physical_table_name = 'contract_group' AND b.column_name = 'contract_id'

UPDATE b 
SET is_primary = 'y' 
FROM alert_table_definition a
INNER JOIN alert_columns_definition b ON a.alert_table_definition_id = b.alert_table_id
WHERE a.physical_table_name = 'source_deal_header' AND b.column_name = 'source_deal_header_id'

UPDATE b 
SET is_primary = 'y' 
FROM alert_table_definition a
INNER JOIN alert_columns_definition b ON a.alert_table_definition_id = b.alert_table_id
WHERE a.physical_table_name = 'source_deal_pnl' AND b.column_name = 'source_deal_header_id'

UPDATE b 
SET is_primary = 'y' 
FROM alert_table_definition a
INNER JOIN alert_columns_definition b ON a.alert_table_definition_id = b.alert_table_id
WHERE a.physical_table_name = 'contract_group_audit_view' AND b.column_name = 'contract_id'