DECLARE @count_check INT 

SELECT @count_check = COUNT(setup_menu_id) FROM setup_menu WHERE display_name = 'Setup Time Series' GROUP BY display_name HAVING COUNT(1) > 1

IF @count_check > 1 
BEGIN
	DELETE FROM setup_menu WHERE setup_menu_id = (SELECT MAX(setup_menu_id) FROM setup_menu WHERE display_name = 'Setup Time Series')
END

SELECT @count_check = COUNT(setup_menu_id) FROM setup_menu WHERE display_name = 'Setup Weather Data' GROUP BY display_name HAVING COUNT(1) > 1

IF @count_check > 1 
BEGIN
	DELETE FROM setup_menu WHERE setup_menu_id = (SELECT MAX(setup_menu_id) FROM setup_menu WHERE display_name = 'Setup Weather Data')
END
GO