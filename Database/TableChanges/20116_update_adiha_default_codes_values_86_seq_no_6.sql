IF EXISTS(SELECT 1 FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 6 AND instance_no = 1)
BEGIN
	UPDATE adiha_default_codes_values SET var_value = 32 WHERE default_code_id = 86 AND seq_no = 6 AND instance_no = 1
END