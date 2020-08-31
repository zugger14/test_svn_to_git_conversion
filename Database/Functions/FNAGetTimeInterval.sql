IF OBJECT_ID(N'FNAGetTimeInterval', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[FNAGetTimeInterval]
GO

/**
	To return Elapsed duration of a datetime from start time and end time provided

	Parameters :
	@start_date : Start Date
	@end_date : End Date
	@mode : 1: returns elapsed time in “hh:mm:ss” format
			2: returns elapsed time in “X hrs Y mins Z secs” forma

	Returns Elapsed Time
*/

CREATE FUNCTION [dbo].[FNAGetTimeInterval]
(
	@start_date DATETIME,
	@end_date DATETIME,
	@mode TINYINT
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @FNAGetTimeInterval AS VARCHAR(50)
		, @current_date AS DATETIME
		, @weeks AS VARCHAR(10)
		, @days AS VARCHAR(10)
		, @hours AS VARCHAR(10)
		, @minutes AS VARCHAR(10)
		, @seconds AS VARCHAR(10)

	SET @FNAGetTimeInterval = '00:00:00'
	SET @current_date = @end_date

	SET @weeks = CAST(DATEDIFF(second, @start_date, @current_date) / 60 / 60 / 24 / 7 AS VARCHAR(10))
	SET @days = CAST(DATEDIFF(second, @start_date, @current_date) / 60 / 60 / 24 % 7 AS VARCHAR(10))
	SET @hours = CAST(DATEDIFF(second, @start_date, @current_date) / 60 / 60 % 24  AS VARCHAR(10))
	SET @minutes = CAST(DATEDIFF(second, @start_date, @current_date) / 60 % 60 AS VARCHAR(10))
	SET @seconds = CAST(DATEDIFF(second, @start_date, @current_date) % 60 AS VARCHAR(10))		

	-- convert weeks in to hours
	IF @weeks <> 0
	BEGIN
		SET @hours = @weeks * 7 * 24
	END

	-- convert days into hours
	IF @days <> 0
	BEGIN
		SET @hours = @hours + (@days * 24)
	END

	IF @mode = 2
		BEGIN
			SET @FNAGetTimeInterval = IIF(@hours <> 0, @hours + ' hrs ', '')
				+ IIF(@minutes <> 0, @minutes + ' mins ', '')
				+ IIF(@seconds <> 0, @seconds + ' secs ', '' )
		END
	ELSE
		BEGIN
			SET @FNAGetTimeInterval =  CASE 
				WHEN @hours <> 0 THEN 
					CASE
						WHEN (@hours < 10) THEN '0' 
						ELSE '' 
					END + @hours + ':'
				ELSE '00:'
			END
			+ IIF(@minutes <> 0, RIGHT('0' + @minutes, 2) + ':', '00:')
			+ IIF(@seconds <> 0, RIGHT('0' + @seconds, 2), '00')
	END
	
	RETURN @FNAGetTimeInterval
END

GO