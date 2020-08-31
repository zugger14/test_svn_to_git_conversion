/*
default codes for whatif configuration.
29 oct 2013
modified: 9 jan 2014
modified reason: default_code_id 55 was already reserved in ladwp for email_notification_derive_price_curve
*/

--delete for default_code_id 55
DELETE FROM adiha_default_codes_values WHERE default_code_id = 55 AND [description] = 'What-If Hypothetical Deal Setup'
DELETE FROM adiha_default_codes_params WHERE default_code_id = 55 AND var_name = 'spa_whatif_configuration'
DELETE FROM adiha_default_codes WHERE default_code_id = 55 AND default_code = 'whatif_configuration'
GO


IF NOT EXISTS(SELECT 1 FROM adiha_default_codes adc WHERE adc.default_code_id = 57)
BEGIN
	INSERT INTO adiha_default_codes (default_code_id, default_code, code_description, code_def, instances)
	VALUES (57, 'whatif_configuration', 'What-If Hypothetical Deal Setup', 'What-If Hypothetical Deal Setup', 1)
	
	DELETE FROM adiha_default_codes_values WHERE default_code_id = 57 
	DELETE FROM adiha_default_codes_params WHERE default_code_id = 57	

	INSERT INTO adiha_default_codes_params VALUES(1, 57, 'spa_whatif_configuration', 3, NULL, 'h')
	INSERT INTO adiha_default_codes_values VALUES(1, 57, 1, 1, 'What-If Hypothetical Deal Setup')

END
GO
