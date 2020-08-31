IF OBJECT_ID(N'FNAGetNthWeekDayofMonth', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAGetNthWeekDayofMonth]
GO 

CREATE FUNCTION FNAGetNthWeekDayofMonth ( 
   @dt DATETIME, 
   @dow VARCHAR(10), 
   @num INT 
) 
RETURNS DATETIME 
AS 
BEGIN

DECLARE @RetDate DATETIME;

WITH MonthDays AS 
( 
   SELECT DATEADD(DAY,number-1,DATEADD(MONTH,DATEDIFF(MONTH,0,@dt),0)) AS MonthDate 
   FROM MASTER..spt_values 
   WHERE number > 0 
       AND TYPE = 'P' 
) 
, WeekDays AS 
( 
   SELECT *, ROW_NUMBER() OVER(ORDER BY MonthDate) DayIndex 
   FROM MonthDays 
   WHERE YEAR(@dt) = YEAR(MonthDate) 
       AND MONTH(@dt) = MONTH(MonthDate) 
       AND DATEPART(dw,MonthDate) = @dow
) 
SELECT @RetDate = MonthDate 
FROM WeekDays 
WHERE DayIndex = @num RETURN (@RetDate) END 
GO