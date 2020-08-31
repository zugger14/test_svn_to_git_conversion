/*
* Insert and set server timezone to GMT+1 for TRMTracker_Essent.
*/

IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible WHERE default_code_id = 36 AND var_value = 15)
	INSERT INTO adiha_default_codes_values_possible(default_code_id, var_value, [description])
	VALUES(36, 15, 'Europe/Madrid')
            
UPDATE adiha_default_codes_values
SET var_value = 15, [description] = 'Europe/Madrid'
WHERE default_code_id = 36 AND instance_no = 1 AND seq_no = 1