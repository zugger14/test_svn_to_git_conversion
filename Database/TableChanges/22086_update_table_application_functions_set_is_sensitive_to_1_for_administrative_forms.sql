IF COL_LENGTH('application_functions', 'is_sensitive') IS NOT NULL
BEGIN
	UPDATE application_functions
	SET is_sensitive = 1
	WHERE function_id IN (10105000, 20010400, 20011300, 20012400)
END