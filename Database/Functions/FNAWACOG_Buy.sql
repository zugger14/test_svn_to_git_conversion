IF OBJECT_ID('[dbo].[FNAWACOG_Buy]','fn') IS NOT NULL 
DROP FUNCTION [dbo].[FNAWACOG_Buy]
GO 

CREATE FUNCTION [dbo].[FNAWACOG_Buy](@book_id INT,@source_system_book_id1 INT,@source_system_book_id2 INT,@source_system_book_id3 INT,@source_system_book_id4 INT)
RETURNS float AS  
BEGIN 
	return 1
END

