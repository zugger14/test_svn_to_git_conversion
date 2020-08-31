IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'application_functions' AND COLUMN_NAME = 'book_required')
BEGIN	 
	UPDATE application_functions
	SET book_required = 1
	WHERE function_id = 10222300
END
ELSE
	PRINT 'Column does not exists.'