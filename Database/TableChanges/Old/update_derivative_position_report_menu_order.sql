--SELECT * FROM setup_menu sm WHERE sm.display_name LIKE '%derivative pos%'

DECLARE @menu_order INT
/*get lasy menu order*/
SELECT @menu_order = MAX(sm.menu_order) + 1 
FROM setup_menu sm WHERE sm.parent_menu_id = 10230093

--update data Derivative Position Report
UPDATE setup_menu
SET parent_menu_id = 10230093,
	menu_order = @menu_order
WHERE display_name = 'Derivative Position Report'

GO