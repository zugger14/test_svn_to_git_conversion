IF COL_LENGTH('dbo.setup_menu', 'display_name') IS NOT NULL
BEGIN
	UPDATE setup_menu
		SET display_name = LTRIM(RTRIM(display_name))
END
GO