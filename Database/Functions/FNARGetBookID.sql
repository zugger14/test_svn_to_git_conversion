IF OBJECT_ID('FNARGetBookID') IS NOT NULL
    DROP FUNCTION dbo.FNARGetBookID
GO

CREATE FUNCTION [dbo].[FNARGetBookID] (@source_book_id INT)
RETURNS INT
AS
BEGIN
	/*	
	--	Returns the ID of given book. Note that this function has same input and output 
	--	(book id passed as input and same book id returned as output). This is required 
	--	to let user choose Book name and return its id. But passing book name gives issues 
	--	if when it collides with existing formula function (e.g. a book named power), so book id 
	--	is passed in the function, but is displayed as name in the frontend.
	*/
	RETURN @source_book_id
END