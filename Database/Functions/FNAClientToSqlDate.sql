/*
Author : Vishwas Khanal
Desc   : This will convert the user dateformat to sql dateformat
Dated  : 12.May.2010
*/

--SELECT dbo.FNAClientToSqlDate('31-12-2010','essent')
IF OBJECT_ID('dbo.FNAClientToSqlDate','FN') IS NOT NULL
DROP FUNCTION dbo.FNAClientToSqlDate
GO
CREATE FUNCTION dbo.FNAClientToSqlDate(
    @userDate VARCHAR(10)	
) RETURNS DATETIME
BEGIN 
	DECLARE @userDateFormat VARCHAR(10),
			@param1			VARCHAR(4),
			@param2			VARCHAR(4),
			@param3			VARCHAR(4),		
			@splitCharacter CHAR(1),
			@final_date  DATETIME

	DECLARE  @tmp TABLE(sno INT IDENTITY(1,1),item VARCHAR(4))
		
	SELECT @splitCharacter = CASE WHEN CHARINDEX('-',@userDate)>0 THEN '-' 
								  WHEN CHARINDEX('/',@userDate)>0 THEN '/'
								  ELSE '.' END
			
	SELECT @userDateFormat = date_format from APPLICATION_USERS AU INNER JOIN 
		REGION r ON r.region_id = AU.region_id AND AU.user_login_id = dbo.FNADBUser()

	INSERT INTO @tmp(item) SELECT item FROM dbo.FNASplit(@userDate,@splitCharacter)

	SELECT @param1 = item FROM @tmp WHERE sno=1
	SELECT @param2 = item FROM @tmp WHERE sno=2
	SELECT @param3 = item FROM @tmp WHERE sno=3
			
	--RETURN CAST(CASE WHEN @userDateFormat IN ('mm/dd/yyyy','mm-dd-yyyy') THEN @param3+'-'+@param1+'-'+@param2
	--				ELSE @param3+'-' + @param2 + '-' + @param1
	--			END AS DATETIME)
				
	
	IF LEN(@param1)= 4
	BEGIN
			SET  @final_date = cast(@param1 + '-' + @param2 + '-' + @param3 AS DATETIME)
	END
	ELSE 
	BEGIN 
		SET @final_date =TRY_CAST(CASE WHEN @userDateFormat IN ('mm/dd/yyyy','mm-dd-yyyy') THEN @param3+'-'+@param1+'-'+@param2
					ELSE @param3+'-' + @param2 + '-' + @param1
				END AS DATETIME)
	END 
	
	RETURN 	@final_date

END
