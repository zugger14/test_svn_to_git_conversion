/*
default codes for whatif configuration.
29 oct 2013
*/
IF NOT EXISTS(SELECT 1 FROM adiha_default_codes adc WHERE adc.default_code_id = 55)
BEGIN
	INSERT INTO adiha_default_codes (default_code_id, default_code, code_description, code_def, instances)
	VALUES (55, 'whatif_configuration', 'What-If Hypothetical Deal Setup', 'What-If Hypothetical Deal Setup', 1)	
END
GO

DELETE FROM adiha_default_codes_values WHERE default_code_id = 55
DELETE FROM adiha_default_codes_params WHERE default_code_id = 55
GO

INSERT INTO adiha_default_codes_params VALUES(1, 55, 'spa_whatif_configuration', 3, NULL, 'h')
INSERT INTO adiha_default_codes_values VALUES(1, 55, 1, 1, 'What-If Hypothetical Deal Setup')

GO