IF OBJECT_ID(N'FNARYearCount', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARYearCount]
 GO
 
CREATE FUNCTION [dbo].[FNARYearCount]
(
	@term_reporting  VARCHAR(20),
	@term_start      VARCHAR(20)
)
RETURNS INT
AS
BEGIN
	IF @term_reporting IS NULL
	   OR @term_start IS NULL
	    RETURN 0
	
	RETURN YEAR(@term_reporting) - YEAR(@term_start) + 1
END








