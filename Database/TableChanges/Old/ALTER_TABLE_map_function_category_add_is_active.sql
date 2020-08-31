

IF COL_LENGTH('map_function_category', 'is_active') IS NULL
BEGIN

	ALTER TABLE map_function_category ADD is_active BIT
		PRINT 'Column map_function_category.is_active added.'
END
ELSE
BEGIN
	PRINT 'Column map_function_category.is_active already exists.'
END
GO

-- select * from static_data_value sdv INNER JOIN map_function_category mfc ON sdv.value_id=mfc.function_id where type_id=800 ORDER BY code


Update map_function_category SET is_active=1 
Update map_function_category SET is_active=0 WHERE function_id IN(-874,-820,-821,-819,-818,896,894,-872,-898,-873,-854,-857)


--EXEC spa_formula_editor @flag='r'
