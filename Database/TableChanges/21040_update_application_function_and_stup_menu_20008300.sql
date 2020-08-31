IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008300)
BEGIN
	UPDATE application_functions SET function_name = 'Setup UDF Template New', function_desc = 'Setup UDF Template New' where function_id = 20008300
END

GO 

IF EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 20008300)
BEGIN
	UPDATE setup_menu SET display_name = 'Setup UDF Template New' where function_id = 20008300
END
GO