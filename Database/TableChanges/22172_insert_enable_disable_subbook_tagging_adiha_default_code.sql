IF NOT EXISTS (SELECT 1 FROM adiha_default_codes WHERE default_code_id = 104)
BEGIN
	INSERT INTO adiha_default_codes (default_code_id, default_code, code_def, code_description, instances)
	VALUES (104, 'disable_tag_in_sub_book', 'Tagging Fields in Sub Book', 'Tagging Fields in Sub Book.', '1')
END
ELSE
BEGIN
	UPDATE adiha_default_codes 
	SET [default_code] = 'tagging_in_sub_book',
		[code_def] = 'Tagging Fields in Sub Book',
		[code_description] = 'Tagging Fields in Sub Book' 
	WHERE default_code_id = 104
END

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_values_possible WHERE default_code_id = 104 AND var_value = '0')
BEGIN
	INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, description) 
	VALUES (104, '0', 'Disable tagging fields in Sub Book')
END
ELSE
BEGIN
	UPDATE adiha_default_codes_values_possible 
	SET [var_value] = '0',
		[description] = 'Disable tagging fields in Sub Book'
	WHERE default_code_id = 104 
	AND var_value = '0'
END


IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_values_possible WHERE default_code_id = 104 AND var_value = '1')
BEGIN
	INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, description) 
	VALUES (104, '1', 'Enable tagging fields in Sub Book')
END
ELSE
BEGIN
	UPDATE adiha_default_codes_values_possible
	SET description = 'Enable tagging fields in Sub Book'
	WHERE default_code_id = 104 AND var_value = '1'
END

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_values WHERE default_code_id = 104)
BEGIN
	INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
	VALUES (1, 104, 1, 0, 'Tagging Fields in Sub Book')
END
GO