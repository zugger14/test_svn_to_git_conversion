IF OBJECT_ID(N'FNASingleQuote', N'FN') IS NOT NULL
DROP FUNCTION dbo.FNASingleQuote
GO 

CREATE FUNCTION dbo.FNASingleQuote (@str as varchar(max))  
RETURNS varchar(max) AS  
BEGIN 
declare @ret_value as varchar(max)
if @str is null 
	set @ret_value='NULL'
else
	set @ret_value=''''+@str+''''

return @ret_value


END





