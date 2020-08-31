TRUNCATE TABLE setup_as_of_date

INSERT INTO setup_as_of_date
(
	module_id
	, screen_id
	, as_of_date
	, no_of_days
)
SELECT '10235499' module_id, '10237500' screen_id, '8' as_of_date, '' no_of_days  UNION ALL 
SELECT '13200000' module_id, '10151000' screen_id, '5' as_of_date, '30' no_of_days  UNION ALL 
SELECT '13210000' module_id, '10233400' screen_id, '8' as_of_date, ''	no_of_days  UNION ALL 
SELECT '13190000' module_id, '10234400' screen_id, '5' as_of_date, '30'	no_of_days  UNION ALL 
SELECT '13190000' module_id, '10234500' screen_id, '5' as_of_date, '30'	no_of_days  UNION ALL 
SELECT '13121295' module_id, '10235200' screen_id, '8' as_of_date, ''	no_of_days  UNION ALL 
SELECT '13121295' module_id, '10235400' screen_id, '8' as_of_date, ''	no_of_days  UNION ALL 
SELECT '13121295' module_id, '10234900' screen_id, '8' as_of_date, ''	no_of_days  
