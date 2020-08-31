IF COL_LENGTH('setup_menu', 'default_parameter') IS NOT NULL
BEGIN
	EXEC sp_rename 'setup_menu.default_parameter', 'menu_image', 'COLUMN'; 
END