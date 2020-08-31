IF OBJECT_ID(N'FNALastDayInMonth', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNALastDayInMonth]
GO

-- This function returns the last day of the month a given date
CREATE FUNCTION [dbo].[FNALastDayInMonth](@a_date DateTime)
RETURNS Int
AS
BEGIN
	Declare @FNALastDayInMonth As Int
	select	@FNALastDayInMonth = CASE DATEPART(mm,  @a_date )
				WHEN 1 Then 31
			  WHEN 2 Then 	
				CASE ISDATE('2/29/' + CAST(DATEPART(yy,  @a_date ) As varchar))
					WHEN 1 Then 29
					ELSE 28
				END
			  WHEN 3 Then 31
			  WHEN 4 Then 30
			  WHEN 5 Then 31
			  WHEN 6 Then 30
			  WHEN 7 Then 31
			  WHEN 8 Then 31
			  WHEN 9 Then 30
			  WHEN 10 Then 31
			  WHEN 11 Then 30
			  ELSE 31
			END
	
	RETURN(@FNALastDayInMonth)
END