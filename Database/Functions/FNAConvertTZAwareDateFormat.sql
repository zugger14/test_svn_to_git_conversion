IF OBJECT_ID('[dbo].[FNAConvertTZAwareDateFormat]','fn') IS NOT NULL 
DROP FUNCTION [dbo].[FNAConvertTZAwareDateFormat]
GO 

 /*
SELECT dbo.FNAConvertTZAwareDateFormat(GETDATE(),1)
SELECT dbo.FNAConvertTZAwareDateFormat(GETDATE(),2)
SELECT dbo.FNAConvertTZAwareDateFormat(GETDATE(),3)
SELECT dbo.FNAConvertTZAwareDateFormat(GETDATE(),4)
*/


/*
	@type : 1 => SQL Starndard Date format
		  : 2 => Client's Date format
		  : 3 => SQL Starndard DateTime format
		  : 4 => Client's DateTime format
		
*/

CREATE FUNCTION [dbo].[FNAConvertTZAwareDateFormat]
	(@aDate DATETIME,@type INT = 1 )
RETURNS VARCHAR(20)
AS
BEGIN	
	DECLARE 
		@new_date VARCHAR(50)
		,@time_part VARCHAR(10)
		
		
	SET @new_date = dbo.FNADateTimeFormat(@aDate,1)
	
	IF @type IN (3,4)
		SET @time_part = ' ' + LTRIM(RTRIM(SUBSTRING(@new_date, CHARINDEX(' ',@new_date) + 1, 10)))
	ELSE
		SET @time_part = ''
	
	IF @type IN  (1,3)
		SET @new_date  = dbo.FNACovertToSTDDate(@new_date)
	ELSE
		SET @new_date = dbo.FNADateFormat(dbo.FNACovertToSTDDate(@new_date))
		
	RETURN @new_date +  @time_part
END
