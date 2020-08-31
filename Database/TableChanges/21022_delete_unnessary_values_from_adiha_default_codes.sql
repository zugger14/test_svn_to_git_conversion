IF EXISTS(SELECT 1 FROM adiha_default_codes WHERE default_code_id = 50)
BEGIN
	DELETE FROM adiha_default_codes_values_possible WHERE default_code_id = 50
	DELETE FROM adiha_default_codes_values WHERE default_code_id = 50
	DELETE FROM adiha_default_codes WHERE default_code_id = 50
	PRINT 'Deal Reference ID Prefix Removed.'
END

IF EXISTS(SELECT 1 FROM adiha_default_codes WHERE default_code_id = 52)
BEGIN 
	DELETE FROM adiha_default_codes_values_possible WHERE default_code_id = 52
	DELETE FROM adiha_default_codes_values WHERE default_code_id = 52
	DELETE FROM adiha_default_codes WHERE default_code_id = 52		
	PRINT 'Default Holiday Calendar Removed.'
END

IF EXISTS(SELECT 1 FROM adiha_default_codes WHERE default_code_id = 48)
BEGIN
	DELETE FROM adiha_default_codes_values_possible WHERE default_code_id = 48
	DELETE FROM adiha_default_codes_values WHERE default_code_id = 48
	DELETE FROM adiha_default_codes WHERE default_code_id = 48
	PRINT 'Report Manager Removed.'
END

IF EXISTS(SELECT 1 FROM adiha_default_codes WHERE default_code_id = 25)
BEGIN
	DELETE FROM adiha_default_codes_values_possible WHERE default_code_id = 25
	DELETE FROM adiha_default_codes_values WHERE default_code_id = 25
	DELETE FROM adiha_default_codes WHERE default_code_id = 25
	PRINT 'Report Writer Setup Removed.'
END

IF EXISTS(SELECT 1 FROM adiha_default_codes WHERE default_code_id = 51)
BEGIN
	DELETE FROM adiha_default_codes_values_possible WHERE default_code_id = 51
	DELETE FROM adiha_default_codes_values WHERE default_code_id = 51
	DELETE FROM adiha_default_codes WHERE default_code_id = 51
	PRINT 'Setup Menu Removed.'
END

IF EXISTS(SELECT 1 FROM adiha_default_codes WHERE default_code_id = 26)
BEGIN
	DELETE FROM adiha_default_codes_values_possible WHERE default_code_id = 26
	DELETE FROM adiha_default_codes_values WHERE default_code_id = 26
	DELETE FROM adiha_default_codes WHERE default_code_id = 26
	PRINT 'System Formula Removed.'
END

IF EXISTS(SELECT 1 FROM adiha_default_codes WHERE default_code_id = 30)
BEGIN
	DELETE FROM adiha_default_codes_values_possible WHERE default_code_id = 30
	DELETE FROM adiha_default_codes_values WHERE default_code_id = 30
	DELETE FROM adiha_default_codes WHERE default_code_id = 30
	PRINT 'TRM Functionality Removed.'
END

IF EXISTS(SELECT 1 FROM adiha_default_codes WHERE default_code_id = 57)
BEGIN
	DELETE FROM adiha_default_codes_values_possible WHERE default_code_id = 57
	DELETE FROM adiha_default_codes_values WHERE default_code_id = 57
	DELETE FROM adiha_default_codes WHERE default_code_id = 57
	PRINT 'What-If Hypothetical Deal Setup Removed.'
END

IF EXISTS(SELECT 1 FROM adiha_default_codes WHERE default_code_id = 60)
BEGIN
	DELETE FROM adiha_default_codes_values_possible WHERE default_code_id = 60
	DELETE FROM adiha_default_codes_values WHERE default_code_id = 60
	DELETE FROM adiha_default_codes WHERE default_code_id = 60
	PRINT 'Function Category Removed.'
END

IF EXISTS(SELECT 1 FROM adiha_default_codes_values_possible WHERE default_code_id = 44)
BEGIN
	DELETE FROM adiha_default_codes_values_possible WHERE default_code_id = 44
	PRINT 'Value Deleted.'
END

IF EXISTS(SELECT 1 FROM adiha_default_codes_values_possible WHERE default_code_id = 86)
BEGIN
	DELETE FROM adiha_default_codes_values_possible WHERE default_code_id = 86
	PRINT 'Value Deleted.'
END