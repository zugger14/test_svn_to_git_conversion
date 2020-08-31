IF OBJECT_ID(N'FNAGetMonthAsInt', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAGetMonthAsInt]
GO

-- This function returns the varchar month as in integer value
CREATE FUNCTION [dbo].[FNAGetMonthAsInt]
(
	@term_month VARCHAR(10)
)
RETURNS Int
AS
BEGIN
	Declare @FNAGetMonthAsInt As Int
	select	@FNAGetMonthAsInt = CASE 	WHEN @term_month = 'jan' OR @term_month='January' THEN 1
					 	WHEN @term_month = 'feb' OR @term_month='February' THEN 2
						WHEN @term_month = 'mar' OR @term_month='March' THEN 3
						WHEN @term_month = 'apr' OR @term_month='April' THEN 4
						WHEN @term_month = 'may' OR @term_month='May' THEN 5
						WHEN @term_month = 'jun' OR @term_month='June' THEN 6
						WHEN @term_month = 'jul' OR @term_month='July' THEN 7	
						WHEN @term_month = 'aug' OR @term_month='August' THEN 8
						WHEN @term_month = 'sep' OR @term_month='September' THEN 9
						WHEN @term_month = 'oct' OR @term_month='October' THEN 10
						WHEN @term_month = 'nov' OR @term_month='November' THEN 11
						WHEN @term_month = 'dec' OR @term_month='December' THEN 12
						ELSE 0 
					END
	
	RETURN(@FNAGetMonthAsInt)
END




