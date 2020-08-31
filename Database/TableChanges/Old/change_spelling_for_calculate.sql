
UPDATE adiha_default_codes_values_possible
SET
DESCRIPTION = 'Do not Calculate MTM on deal insert/update' WHERE default_code_id = '41' AND var_value = '0'

UPDATE adiha_default_codes_values_possible
SET
DESCRIPTION = 'Calculate MTM on deal insert/update' WHERE default_code_id = '41' AND var_value = '1'