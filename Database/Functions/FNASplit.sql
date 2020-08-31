SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNASplit', N'TF') IS NOT NULL 
	DROP FUNCTION [dbo].FNASplit
GO

/**
	Splits the expression into two parts by delimeter specified(, being default delimeter) and returns them as a table

	Parameters
	@input_list	:	List of delimited items
	@delimiter	:	Delimiter that separates items
*/

CREATE FUNCTION dbo.FNASplit(
    @input_list VARCHAR(max) -- List of delimited items
  , @delimiter VARCHAR(30) = ',' -- delimiter that separates items
) RETURNS @list TABLE (item VARCHAR(max))

BEGIN
	/* TEST DATA
	DECLARE @input_list VARCHAR(8000) -- List of delimited items
    DECLARE @delimiter VARCHAR(25)
    
    SET @input_list = 'test$-#tesf4df$-#fdgfg'
    --SET @input_list = '$-#test$-#tesf4df$-#fdgfg$-#'
    SET @delimiter = '$-#'
    
    --SET @input_list = 'a,b,c'
    --SET @input_list = ',a,b,c,'
    --SET @delimiter = ','
	*/
	
	DECLARE @delim_length INT, @str_length INT
	SET @str_length = DATALENGTH(@input_list)
	SET @delim_length = DATALENGTH(@delimiter)  --don't use LEN as it excludes leading/trailing blanks, delim shudn't be modified

	SET @input_list = @delimiter + @input_list + @delimiter
	INSERT INTO @list (item)
	SELECT RTRIM(LTRIM(SUBSTRING(@input_list, N + @delim_length, CHARINDEX(@delimiter, @input_list, N + 1) - N - @delim_length)))
	FROM dbo.seq_big
	WHERE N <= @str_length
	AND SUBSTRING(@input_list, N, @delim_length) = @delimiter 
	
	RETURN
END




GO
