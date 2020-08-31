/*
* ---------------------------------------------------------------
* | Created Date	:	28th june, 2010							|
* | Purpose		:	resolve as of date							|
* | Description	:	give custom as of date as parameter passed	|
* |					eg. DATE.F : First Day of the month			|
* |					DATE.L : Last Day of the month				|
* |					DATE.X where X is an integer: (Today - X)	|
* ---------------------------------------------------------------
*/
IF OBJECT_ID(N'FNAResolveCustomAsOfDate' ,N'FN') IS NOT NULL
    DROP FUNCTION FNAResolveCustomAsOfDate
 GO
 
CREATE FUNCTION [dbo].[FNAResolveCustomAsOfDate]
(
	@param VARCHAR(20), @date DATETIME
)
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @user_today  DATETIME
	       ,@return_val  VARCHAR(20)
	
	IF @date IS NOT NULL
		SET @user_today = dbo.FNAConvertTimezone(@date ,0)
	ELSE
		SET @user_today = dbo.FNAConvertTimezone(GETDATE() ,0)
	IF CHARINDEX('-', @param) > 0
	BEGIN
		SET @return_val = @param 
	END
	ELSE
	IF @param = 'DATE.F' -- DATE.F: First Day of the month
	BEGIN
	    SET @return_val = dbo.FNAGetContractMonth(@user_today)
	END
	ELSE -- DATE.L: Last Day of the month
	IF @param = 'DATE.L'
	BEGIN
	    SET @return_val = CAST(YEAR(@user_today) AS VARCHAR) + '-' + CAST( FORMAT(@user_today,'MM') AS VARCHAR)
	        + '-' + CAST(dbo.FNALastDayInMonth(@user_today) AS VARCHAR)
	END
	ELSE -- DATE.X where X is an integer: (Today - X)
	BEGIN
	    SET @return_val = CONVERT(
	            VARCHAR(10)
	           ,DATEADD(
	                dd
	               ,-1 * CAST(SUBSTRING(@param ,6 ,LEN(@param)) AS INT)
	               ,@user_today
	            )
	           ,120
	        )
	END
	
	RETURN @return_val
END