IF (SELECT distinct 1 FROM setup_menu WHERE function_id = 10104100) IS NOT NULL
BEGIN
	UPDATE setup_menu SET display_name =  'Setup UDF Template - Old' WHERE function_id = 10104100
	PRINT 'Display name ''Setup UDF Template - Old'' is successfully updated.'
END 
ELSE 
	PRINT 'Function ID - 10104100 doesnot exist.'

IF (SELECT 1 FROM setup_menu WHERE function_id = 20008300) IS NOT NULL
BEGIN
	UPDATE setup_menu SET display_name =  'Setup UDF Template' WHERE function_id = 20008300
	PRINT 'Display name ''Setup UDF Template'' is successfully updated.'
END 
ELSE 
	PRINT 'Function ID - 20008300 doesnot exist.'
