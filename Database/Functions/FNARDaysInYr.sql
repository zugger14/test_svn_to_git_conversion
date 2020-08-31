IF OBJECT_ID(N'FNARDaysInYr', N'FN') IS NOT NULL
DROP FUNCTION FNARDaysInYr
 GO 

-- select dbo.FNARDaysInYr('2015-05-01')
-- This function returns the number of days in a year
CREATE FUNCTION FNARDaysInYr(@a_date DateTime)
RETURNS Int
AS
BEGIN
	DECLARE @FNARDaysInYr INT, @start_date DATETIME, @end_date DATETIME
	
	SET @start_date = CAST(CAST(YEAR(@a_date) AS VARCHAR)+'-01-01' AS DATETIME)
	SET @end_date = CAST(CAST(YEAR(@a_date) AS VARCHAR)+'-12-31' AS DATETIME)
	
	select	@FNARDaysInYr = DATEDIFF(dd,@start_date,@end_date)+1

	RETURN(@FNARDaysInYr)
END






