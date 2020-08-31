IF EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106700)
BEGIN
	UPDATE setup_menu SET menu_type = 0 WHERE function_id = 10106700
	PRINT 'Function ID 10106700 updated successfully.'
END
ELSE
BEGIN
	PRINT 'Function ID 10106700 doesnot exists.'
END