IF OBJECT_ID('tempdb..#temp') IS NOT NULL
    DROP TABLE #temp

SELECT MIN(setup_menu_id) setup_menu_id,
	   sm.display_name,
       sm.function_id,
       COUNT(sm.function_id) [count]
INTO #temp
FROM setup_menu sm
       INNER JOIN application_functions af
            ON  af.function_id = sm.function_id
WHERE  sm.product_category = 10000000       
GROUP BY sm.display_name, sm.function_id  HAVING COUNT(sm.function_id) = 2
ORDER BY sm.display_name, sm.function_id

DELETE 
FROM setup_menu
WHERE setup_menu_id IN (SELECT setup_menu_id FROM #temp)

IF OBJECT_ID('tempdb..#temp') IS NOT NULL
    DROP TABLE #temp
