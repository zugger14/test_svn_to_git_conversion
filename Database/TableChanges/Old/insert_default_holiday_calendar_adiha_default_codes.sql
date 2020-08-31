IF NOT EXISTS(SELECT 1 FROM adiha_default_codes WHERE code_def = 'Default Holiday Calendar')
BEGIN
	INSERT INTO adiha_default_codes(default_code_id
								, default_code
								, code_description
								, code_def
								, instances)	
	VALUES(52, 'Default Holiday Calendar', 'Default Holiday Calendar', 'Default Holiday Calendar', 1)						
END
ELSE
	PRINT 'Default Holiday Calendar already exist.'
GO