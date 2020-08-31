IF OBJECT_ID(N'FNAReplaceSpecialChars', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAReplaceSpecialChars]
GO
 
--select dbo.FNAReplaceSpecialChars('sdf: dsfds- dfd', '_')

-- convert the following special chars with replace_with value
--":", "$", " ", "/", "\", "|", "*", "%", "&", "#", "@", "!", "(", ")", "-"
CREATE FUNCTION [dbo].[FNAReplaceSpecialChars]
(
	@clean_str     VARCHAR(100),
	@replace_with  CHAR
)
RETURNS Varchar(100)
AS
BEGIN

	DECLARE @FNAReplaceSpecialChars varchar(100)
	SET @clean_str = CASE 	WHEN (CHARINDEX(':',@clean_str)<>0) THEN REPLACE ( @clean_str , ':' , @replace_with ) ELSE @clean_str END
	SET @clean_str = CASE 	WHEN (CHARINDEX('$',@clean_str)<>0) THEN  REPLACE ( @clean_str , '$' , @replace_with ) ELSE @clean_str END
	SET @clean_str = CASE 	WHEN (CHARINDEX(' ',@clean_str)<>0) THEN REPLACE ( @clean_str , ' ' , @replace_with ) ELSE @clean_str END
	SET @clean_str = CASE 	WHEN (CHARINDEX('/',@clean_str)<>0) THEN REPLACE ( @clean_str , '/' , @replace_with ) ELSE @clean_str END		
	SET @clean_str = CASE 	WHEN (CHARINDEX('\',@clean_str)<>0) THEN REPLACE ( @clean_str , '\' , @replace_with ) ELSE @clean_str END		
	SET @clean_str = CASE 	WHEN (CHARINDEX('|',@clean_str)<>0) THEN REPLACE ( @clean_str , '|' , @replace_with ) ELSE @clean_str END
	SET @clean_str = CASE 	WHEN (CHARINDEX('*',@clean_str)<>0) THEN REPLACE ( @clean_str , '*' , @replace_with ) ELSE @clean_str END
	SET @clean_str = CASE 	WHEN (CHARINDEX('%',@clean_str)<>0) THEN REPLACE ( @clean_str , '%' , @replace_with ) ELSE @clean_str END						
	SET @clean_str = CASE 	WHEN (CHARINDEX('&',@clean_str)<>0) THEN REPLACE ( @clean_str , '&' , @replace_with ) ELSE @clean_str END			
	SET @clean_str = CASE 	WHEN (CHARINDEX('#',@clean_str)<>0) THEN REPLACE ( @clean_str , '#' , @replace_with ) ELSE @clean_str END						
	SET @clean_str = CASE 	WHEN (CHARINDEX('@',@clean_str)<>0) THEN REPLACE ( @clean_str , '@' , @replace_with ) ELSE @clean_str END						
	SET @clean_str = CASE 	WHEN (CHARINDEX('!',@clean_str)<>0) THEN REPLACE ( @clean_str , '!' , @replace_with ) ELSE @clean_str END						
	SET @clean_str = CASE 	WHEN (CHARINDEX('(',@clean_str)<>0) THEN REPLACE ( @clean_str , '(' , @replace_with ) ELSE @clean_str END						
	SET @clean_str = CASE 	WHEN (CHARINDEX(')',@clean_str)<>0) THEN REPLACE ( @clean_str , ')' , @replace_with ) ELSE @clean_str END						
	SET @clean_str = CASE 	WHEN (CHARINDEX('-',@clean_str)<>0) THEN REPLACE ( @clean_str , '-' , @replace_with ) ELSE @clean_str END			
	SET @clean_str = CASE 	WHEN (CHARINDEX('+',@clean_str)<>0) THEN REPLACE ( @clean_str , '+' , @replace_with ) ELSE @clean_str END			
			
	SET @FNAReplaceSpecialChars = @clean_str
	RETURN(@FNAReplaceSpecialChars)
END










