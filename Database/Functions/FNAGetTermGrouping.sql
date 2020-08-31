IF OBJECT_ID(N'FNAGetTermGrouping', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAGetTermGrouping]
GO

-- This function converst a datatime to ADIHA format 'mm/dd/yyyy'
-- Inpute is SQL datatime...
-- Input is a SQl Date variable
--DROP FUNCTION FNAGetTermGrouping
-- grnaulirty type m (month), q(quarter), s(semi-annual), a(annual)
CREATE FUNCTION [dbo].[FNAGetTermGrouping]
(
	@DATE              DATETIME,
	@granularity_type  CHAR
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE  @FNAGetTermGrouping AS VARCHAR(50)
	SET  @FNAGetTermGrouping = CASE WHEN (@granularity_type = 'm') THEN
						(CAST(Month(@DATE) AS VARCHAR) +
						'-'+CAST(Year(@DATE) AS VARCHAR))
				       WHEN (@granularity_type = 'q') THEN
						CAST(datepart(qq, @DATE) AS VARCHAR) + 
						CASE WHEN (datepart(qq, @DATE) = 1) THEN 'st Q' 
						     WHEN (datepart(qq, @DATE) = 2) THEN 'nd Q'
						     WHEN (datepart(qq, @DATE) = 3) THEN 'rd Q'   
						     ELSE 'th Q' END + 
						'-' + CAST(Year(@DATE) As Varchar)
				       WHEN (@granularity_type = 's') THEN
						CASE WHEN (Month(@DATE) < 7) THEN '1st'  
						     ELSE '2nd' END + 
						'-' + CAST(Year(@DATE) As Varchar)
				       ELSE
						CAST(Year(@DATE) As Varchar)					
				       END			
	
	RETURN(@FNAGetTermGrouping)
END

-- select dbo.FNAGetTermGrouping('4/1/2004', 'm')
-- select dbo.FNAGetTermGrouping('4/1/2004', 'q')
-- select dbo.FNAGetTermGrouping('4/1/2004', 's')
-- select dbo.FNAGetTermGrouping('4/1/2004', 'a')