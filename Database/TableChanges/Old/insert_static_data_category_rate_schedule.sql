IF NOT EXISTS(SELECT 1 FROM static_data_category WHERE category_name = 'Rate Schedule Code')
BEGIN
 	INSERT INTO static_data_category(category_name, category_desc,type_id)
	VALUES ('Rate Schedule Code','Rate Schedule Code',5500)
 	PRINT ' Inserted Rate Schedule Code'
END
ELSE
BEGIN
	PRINT 'Rate Schedule Code already EXISTS.'
END
