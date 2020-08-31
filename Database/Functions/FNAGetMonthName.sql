IF OBJECT_ID(N'FNAGetMonthName', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAGetMonthName]
GO 

-- This function returns the varchar month as in integer value
CREATE FUNCTION [dbo].[FNAGetMonthName]
(
	@no_month INT
)
RETURNS Varchar(3)
AS
BEGIN
	Declare @FNAGetMonthAsName As varchar(3)
	select	@FNAGetMonthAsName = CASE 	WHEN @no_month = 1 THEN 'Jan'
					 	WHEN @no_month = 2 THEN 'Feb'
						WHEN @no_month = 3 THEN 'Mar'
						WHEN @no_month = 4 THEN 'Apr'
					 	WHEN @no_month = 5 THEN 'May'
						WHEN @no_month = 6 THEN 'Jun'
						WHEN @no_month = 7 THEN 'Jul'
					 	WHEN @no_month = 8 THEN 'Aug'
						WHEN @no_month = 9 THEN 'Sep'
						WHEN @no_month = 10 THEN 'Oct'
					 	WHEN @no_month = 11 THEN 'Nov'
						WHEN @no_month = 12 THEN 'Dec'
						ELSE '' 
					END
	
	RETURN(@FNAGetMonthAsName)
END