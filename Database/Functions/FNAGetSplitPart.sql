/*
	 @Description - FUNCTION to get a split string with delimiter of given position
	 @param - @input_list: delimeter seperated string
			- @delimeter: seperator string
			- @position: index position of split string to return 
	 @returns - Selected position's split string, NULL if index position is out of bound	
	 @e.g. - 	SELECT  dbo.FNAGetSplitPart('str1 - str2 - str3 - str4',' - ', 3) -- returns str3
	
*/
IF OBJECT_ID(N'FNAGetSplitPart', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAGetSplitPart]
 GO 

CREATE FUNCTION [dbo].[FNAGetSplitPart]
(
	@input_list  VARCHAR(8000),
	@delimiter   VARCHAR(8000) = ',',
	@position    INT = 1
)
RETURNS VARCHAR(8000)  
AS  
BEGIN
	DECLARE @ret_string VARCHAR(8000)
	SET @ret_string = NULL
	DECLARE @split_list AS TABLE(idx INT, item VARCHAR(8000))

	INSERT INTO @split_list(idx, item)
	SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) idx, * FROM dbo.FNASplit(@input_list, @delimiter)
	SELECT @ret_string = item FROM @split_list s WHERE s.idx = @position

	RETURN @ret_string
END 