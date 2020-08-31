/* Script to update menu_order for the first time in reference to current menu structure, Since menu_order is not being used properly, this will set menu_order for each module, menu group and menu so that they are loaded in exact order next time. */

SET NOCOUNT ON

DECLARE @product_category INT

DECLARE db_cursor CURSOR FOR 
SELECT product_category 
FROM setup_menu
WHERE parent_menu_id IS NULL

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @product_category  

WHILE @@FETCH_STATUS = 0  
BEGIN  
	IF OBJECT_ID('tempdb..#trmtracker_menu') IS NOT NULL DROP TABLE #trmtracker_menu
	
	CREATE TABLE #trmtracker_menu (
		function_id INT
		, setup_menu_id INT
		, parent_menu_id INT
		, display_name VARCHAR(1000)
		, default_parameter VARCHAR(1000)
		, hide_show BIT
		, menu_type BIT
		, [level] INT
		, sort_order VARCHAR(1000)
		, menu_order INT
		, product_category INT
		, file_path VARCHAR(1000)
		, window_name VARCHAR(1000)
	)

	INSERT INTO #trmtracker_menu
	EXEC spa_setup_menu @flag='k', @pre_flag='s', @product_category=@product_category

	UPDATE sm
	SET sm.menu_order = t.menu_order
	FROM setup_menu sm
	INNER JOIN #trmtracker_menu t
		ON t.setup_menu_id = sm.setup_menu_id

	FETCH NEXT FROM db_cursor INTO @product_category 
END 

CLOSE db_cursor  
DEALLOCATE db_cursor 




