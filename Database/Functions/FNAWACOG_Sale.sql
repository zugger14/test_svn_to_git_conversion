IF OBJECT_ID('[dbo].[FNAWACOG_Sale]','fn') IS NOT NULL 
DROP FUNCTION [dbo].[FNAWACOG_Sale]
GO 

CREATE FUNCTION [dbo].[FNAWACOG_Sale](@book_id INT)
RETURNS float AS  
BEGIN 
	return 1
END

