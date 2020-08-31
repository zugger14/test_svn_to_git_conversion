IF OBJECT_ID(N'setup_menu', N'U') IS NOT NULL AND COL_LENGTH('setup_menu', 'display_name') IS NOT NULL
BEGIN
	UPDATE setup_menu
		SET display_name = 'Setup Payment Terms' 
	WHERE function_id = 20017000
END



