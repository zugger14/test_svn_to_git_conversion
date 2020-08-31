/*
* alter table whatif_criteria_book, alter length of column book_parameter.
* sligal
* 05/02/2013
*/

IF COL_LENGTH('whatif_criteria_book', 'book_parameter') IS NOT NULL
BEGIN
    ALTER TABLE whatif_criteria_book ALTER COLUMN book_parameter VARCHAR(8000)
END
ELSE
	PRINT 'Column book_parameter does not exist in table whatif_criteria_book'
GO
