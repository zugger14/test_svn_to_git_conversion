IF OBJECT_id('[FNANormDist]') IS NOT NULL
DROP FUNCTION [dbo].[FNANormDist]
GO

CREATE FUNCTION [dbo].[FNANormDist](@value FLOAT, @mean FLOAT, @sigma FLOAT, @cummulative BIT)
RETURNS NUMERIC(28,8)
AS
/****************************************************************************************
NAME: FNANormDist
WRITTEN BY: Shushil Bohara
DATE: 2012/10/12
Usage: SELECT dbo.FNANormDist(.48321740,0,1,0)
OUTPUT: 0.35498205
*****************************************************************************************/
BEGIN

DECLARE @x FLOAT
DECLARE @z FLOAT
DECLARE @t FLOAT
DECLARE @ans FLOAT
DECLARE @returnvalue FLOAT

IF (@mean = 0 AND @sigma = 0)
	SET @returnvalue = 0
ELSE
BEGIN
	IF @sigma = 0
		SET @sigma = 1
	SELECT @x = (@value-@mean)/@sigma
	IF (@cummulative = 1)
	BEGIN
		SELECT @z = abs(@x)/sqrt(2.0)
		SELECT @t = 1.0/(1.0+0.5*@z)
		SELECT @ans = @t*exp(-@z*@z-1.26551223+@t*(1.00002368+@t*(0.37409196+@t*(0.09678418+@t*(-0.18628806+@t*(0.27886807+@t*(-1.13520398+@t*(1.48851587+@t*(-0.82215223+@t*0.17087277)))))))))/2.0
		IF (@x <= 0)
			SELECT @returnvalue = @ans
		ELSE
			SELECT @returnvalue = 1-@ans
	END
	ELSE
	BEGIN
		SELECT @returnvalue = exp(-@x*@x/2.0)/sqrt(2.0*3.14159265358979)
	END
END
RETURN CAST(@returnvalue AS NUMERIC(28,8))

END

