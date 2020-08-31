--index
UPDATE maintain_field_deal
SET sql_string = 'SELECT source_curve_def_id, curve_name FROM source_price_curve_def WHERE is_active= ''y'' ORDER BY curve_name'
WHERE field_id = 88

--udf "Pricing Index"
UPDATE user_defined_fields_template 
SET sql_string = 'select source_curve_def_id, curve_name from source_price_curve_def WHERE is_active= ''y'' ORDER BY curve_name' 
WHERE field_label = 'Pricing Index'

--formula curve id
UPDATE maintain_field_deal
SET sql_string = 'SELECT source_curve_def_id,curve_name FROM source_price_curve_def WHERE is_active= ''y'' ORDER BY curve_name'
WHERE field_id = 127

--location
UPDATE maintain_field_deal 
SET sql_string = 'EXEC spa_source_minor_location ''s'', @is_active = ''y'''
WHERE field_id = 109

--counterparty
UPDATE maintain_field_deal 
SET sql_string = 'SELECT source_counterparty_id, counterparty_name FROM dbo.source_counterparty WHERE int_ext_flag <> ''b'' and is_active = ''y'' ORDER BY counterparty_name'
WHERE field_id = 11 

--contract
UPDATE maintain_field_deal 
SET sql_string = 'EXEC spa_source_contract_detail ''r'', @is_active= ''y'''
WHERE field_id = 47
