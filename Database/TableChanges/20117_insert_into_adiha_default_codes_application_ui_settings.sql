INSERT INTO adiha_default_codes_params(seq_no, default_code_id, var_name, type_id, var_length, value_type)
SELECT 7, adc.default_code_id, 'Filter Field Size', 3, NULL, 'h'  
FROM adiha_default_codes  adc
left JOIN adiha_default_codes_params adcp ON adc.default_code_id = adcp.default_code_id AND adcp.var_name = 'Filter Field Size'
WHERE adc.default_code_id = 86 AND adcp.type_id IS NULL



INSERT INTO adiha_default_codes_values(instance_no, default_code_id, seq_no, var_value, [description])
SELECT 1, 86, adcp.seq_no, 210, adcp.var_name
FROM adiha_default_codes  adc
INNER JOIN adiha_default_codes_params adcp ON adc.default_code_id = adcp.default_code_id AND adcp.var_name = 'Filter Field Size'
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adcp.default_code_id AND adcp.seq_no = adcv.seq_no 
WHERE adc.default_code_id = 86 AND adcv.instance_no IS NULL


INSERT INTO adiha_default_codes_params(seq_no, default_code_id, var_name, type_id, var_length, value_type)
SELECT 8, adc.default_code_id, 'Fieldset Width', 3, NULL, 'h'  
FROM adiha_default_codes  adc
left JOIN adiha_default_codes_params adcp ON adc.default_code_id = adcp.default_code_id AND adcp.var_name = 'Fieldset Width'
WHERE adc.default_code_id = 86 AND adcp.type_id IS NULL



INSERT INTO adiha_default_codes_values(instance_no, default_code_id, seq_no, var_value, [description])
SELECT 1, 86, adcp.seq_no, 1000, adcp.var_name
FROM adiha_default_codes  adc
INNER JOIN adiha_default_codes_params adcp ON adc.default_code_id = adcp.default_code_id AND adcp.var_name = 'Fieldset Width'
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adcp.default_code_id AND adcp.seq_no = adcv.seq_no 
WHERE adc.default_code_id = 86 AND adcv.instance_no IS NULL


--Browse Clear Offset Top Start
INSERT INTO adiha_default_codes_params(seq_no, default_code_id, var_name, type_id, var_length, value_type)
SELECT 9, adc.default_code_id, 'Browse Clear Offset Top', 3, NULL, 'h'  
FROM adiha_default_codes  adc
left JOIN adiha_default_codes_params adcp ON adc.default_code_id = adcp.default_code_id AND adcp.var_name = 'Browse Clear Offset Top'
WHERE adc.default_code_id = 86 AND adcp.type_id IS NULL



INSERT INTO adiha_default_codes_values(instance_no, default_code_id, seq_no, var_value, [description])
SELECT 1, 86, adcp.seq_no, 20, adcp.var_name
FROM adiha_default_codes  adc
INNER JOIN adiha_default_codes_params adcp ON adc.default_code_id = adcp.default_code_id AND adcp.var_name = 'Browse Clear Offset Top'
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adcp.default_code_id AND adcp.seq_no = adcv.seq_no 
WHERE adc.default_code_id = 86 AND adcv.instance_no IS NULL
--Browse Clear Offset Top End

--Browse Clear Offset Left Start
INSERT INTO adiha_default_codes_params(seq_no, default_code_id, var_name, type_id, var_length, value_type)
SELECT 10, adc.default_code_id, 'Browse Clear Offset Left', 3, NULL, 'h'  
FROM adiha_default_codes  adc
left JOIN adiha_default_codes_params adcp ON adc.default_code_id = adcp.default_code_id AND adcp.var_name = 'Browse Clear Offset Left'
WHERE adc.default_code_id = 86 AND adcp.type_id IS NULL



INSERT INTO adiha_default_codes_values(instance_no, default_code_id, seq_no, var_value, [description])
SELECT 1, 86, adcp.seq_no, -25, adcp.var_name
FROM adiha_default_codes  adc
INNER JOIN adiha_default_codes_params adcp ON adc.default_code_id = adcp.default_code_id AND adcp.var_name = 'Browse Clear Offset Left'
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adcp.default_code_id AND adcp.seq_no = adcv.seq_no 
WHERE adc.default_code_id = 86 AND adcv.instance_no IS NULL
--Browse Clear Offset Left End