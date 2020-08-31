/*
Product and Module 
WITH List (function_id,function_path,function_ref_id,Lvl, display_name)
AS
(
	SELECT a.function_id,CONVERT(VARCHAR(8000),a.function_name) ,func_ref_id,1 as Lvl, CONVERT(VARCHAR(8000),a.function_name)
	FROM application_functions a WHERE function_id = 10000000
	UNION all
	SELECT a.function_id,function_path + '=>'+ CONVERT(VARCHAR(8000),a.function_name) ,func_ref_id,Lvl + 1,  CONVERT(VARCHAR(8000),a.function_name)
	FROM application_functions a 
	INNER JOIN List l ON  a.func_ref_id = l.function_id 
)

SELECT function_id,function_path,Lvl 'Depth', display_name FROM List 
WHERE Lvl <3 
*/
--TRM
--SELECT * FROM application_functions where function_id IN (10000000,10100000,10110000,10120000,10130000,10140000,10150000,10160000,10170000,10180000,10190000,10200000,10210000,10220000,10230000,10240000,12100000,12110000,12120000,12130000)
DELETE FROM application_functions where function_id IN (10000000,10100000,10110000,10120000,10130000,10140000,10150000,10160000,10170000,10180000,10190000,10200000,10210000,10220000,10230000,10240000,12100000,12110000,12120000,12130000)

--FAS -- 13000000
--SELECT * FROM application_functions where function_id IN (13000000,13100000,13110000,13120000,13130000,13140000,13150000,13180000,13190000,13200000,13210000,13220000)
DELETE FROM application_functions where function_id IN (13000000,13100000,13110000,13120000,13130000,13140000,13150000,13180000,13190000,13200000,13210000,13220000)


--Delete menus and sub menus. Those function ids whose menu type is 1 in setup menu.
--Step 1 Remove those functions from application_functional_users
--select af.* 
DELETE afu
from setup_menu sm
INNER JOIN application_functions af ON af.function_id = sm.function_id
LEFT JOIN application_ui_template aut ON aut.application_function_id = af.function_id
inner join application_functional_users afu ON afu.function_id = af.function_id
WHERE sm.menu_type = 1 
	AND document_path IS NULL
	AND file_path IS NULL
	AND aut.application_function_id IS NULL
	
--Step 2:- Remove from application_functions	
--select af.* 
DELETE af
from setup_menu sm
INNER JOIN application_functions af ON af.function_id = sm.function_id
LEFT JOIN application_ui_template aut ON aut.application_function_id = af.function_id
WHERE sm.menu_type = 1 
	AND document_path IS NULL
	AND file_path IS NULL
	AND aut.application_function_id IS NULL
	


