UPDATE data_source_column
SET param_data_source = 'EXEC spa_counterparty_products @flag = ''x'''
WHERE param_data_source = 'SELECT DISTINCT commodity_form_name [value], commodity_form_name [label]
FROM commodity_attribute_form'