DECLARE @menu_id INT
DECLARE @count INT

SELECT  @count = COUNT(1) from  setup_menu WHERE function_id = 10234300 AND product_category = 13000000

IF (@count > 1 )
BEGIN
	SELECT TOP 1  @menu_id = setup_menu_id from  setup_menu WHERE function_id = 10234300 AND product_category = 13000000 ORDER BY setup_menu_id DESC

	DELETE FROM setup_menu WHERE setup_menu_id = @menu_id
END