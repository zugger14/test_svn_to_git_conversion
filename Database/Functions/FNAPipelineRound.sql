IF OBJECT_ID(N'dbo.FNAPipelineRound') IS NOT NULL
    DROP FUNCTION dbo.FNAPipelineRound
GO

-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2015-09-22
-- Description: Perform Bankers rounding.
 
-- Params:
-- @x - Number to round
-- @decimal_places - round to decimal points
-- Usage: dbo.FNAPipelineRound(7.5, 0) - 8
-- ===============================================================================================================

CREATE FUNCTION dbo.FNAPipelineRound (
	@round_type 		INT, 
	@value              MONEY,
	@decimal_places     TINYINT
)
RETURNS MONEY
AS
BEGIN
	IF @round_type = 1
	BEGIN
	    SET @value = @value * POWER(10, @decimal_places)
	    
	    SET @value = CASE 
	                      WHEN @value = FLOOR(@value) THEN @value
	                      ELSE CASE SIGN(CEILING(@value) - 2 * @value + FLOOR(@value))
	                                WHEN 1 THEN FLOOR(@value)
	                                WHEN -1 THEN CEILING(@value)
	                                ELSE 2 * ROUND(@value / 2, 0)
	                           END
	                 END / POWER(10, @decimal_places)
	END
	ELSE
	    SET @value = ROUND(@value, @decimal_places)
	
	RETURN @value
END