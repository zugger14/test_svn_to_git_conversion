IF OBJECT_ID(N'FNALastDayInDate', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNALastDayInDate]
GO 

-- This function returns the a date with the month being the last day
-- 11/28/03 will be returned as 11/30/03
-- drop function FNALastDayInDate
CREATE FUNCTION [dbo].[FNALastDayInDate]
(
	@a_date DATETIME
)
RETURNS Datetime
AS
BEGIN
	DECLARE  @FNALastDayInDate AS Datetime
	SELECT 	@FNALastDayInDate = CAST(year(@a_date) AS VARCHAR) + '-' 
			+ CAST(month(@a_date) AS VARCHAR)
				+ '-' + CAST(dbo.FNALastDayInMonth(@a_date) AS VARCHAR) 

--Changed to use std sql date format
-- 	select	@FNALastDayInDate = cast(month(@a_date) as varchar) + '/' 
-- 			+ cast(dbo.FNALastDayInMonth(@a_date) as varchar) 
-- 				+ '/' + cast(year(@a_date) as varchar)
	
	RETURN(@FNALastDayInDate)
END