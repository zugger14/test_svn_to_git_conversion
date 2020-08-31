UPDATE fep
SET default_value = '0'
FROM formula_editor_parameter fep
	INNER JOIN static_data_value sdv
		ON  sdv.value_id = fep.formula_id
WHERE sdv.code = 'row'
	AND fep.field_label = 'Offset'
       
UPDATE fep
SET sql_string = 'EXEC spa_GetAllPriceCurveDefinitions ''s'',NULL,NULL,NULL',
	blank_option = 0
FROM formula_editor_parameter fep
	INNER JOIN static_data_value sdv
		ON  sdv.value_id = fep.formula_id
WHERE sdv.code = 'ContractPriceValue'
	AND fep.field_label = 'Curve ID'
       
UPDATE fep
SET blank_option = 1
FROM formula_editor_parameter fep
	INNER JOIN static_data_value sdv
		ON  sdv.value_id = fep.formula_id
WHERE sdv.code = 'ContractPriceValue'
	AND fep.field_label = 'Granularity'
	
UPDATE fep
SET blank_option = 1
FROM formula_editor_parameter fep
	INNER JOIN static_data_value sdv
		ON  sdv.value_id = fep.formula_id
WHERE sdv.code = 'ContractPriceValue'
	AND fep.field_label = 'Index Group'	