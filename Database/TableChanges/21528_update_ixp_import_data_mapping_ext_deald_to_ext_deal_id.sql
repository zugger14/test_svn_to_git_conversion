UPDATE ixp_import_data_mapping 
SET source_column_name = 'd.[ext deal id]'
WHERE ixp_rules_id IN (SELECT ixp_rules_id FROM ixp_rules WHERE ixp_rules_name = 'Deals')
AND source_column_name = 'd.[ext deald]'