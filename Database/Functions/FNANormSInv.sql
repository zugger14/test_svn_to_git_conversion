IF OBJECT_ID('dbo.FNANormSInv') IS NOT null
	DROP FUNCTION dbo.FNANormSInv 
go
	---SELECT dbo.FNANormSInv(0.2)
	---SELECT RAND() FROM dbo.source_deal_header
	
	
-- This function is a replacement for the Microsoft Excel Worksheet function NORMSINV.
-- It uses the algorithm of Peter J. Acklam to compute the inverse normal cumulative
-- distribution. Refer to http://home.online.no/~pjacklam/notes/invnorm/index.html for
-- a description of the algorithm.
-- Adapted to VB by Christian d'Heureuse, http://www.source-code.biz.

create Function dbo.FNANormSInv(@p As float) 
RETURNS float AS  
BEGIN 
	DECLARE @a1 AS float, @a2 AS float, @a3 AS FLOAT
	,@a4 AS float, @a5 AS float, @a6 AS float
	,@b1 AS float, @b2  AS float, @b3 AS float
	,@b4  AS float, @b5  AS float, @c1 AS float
	,@c2  AS float, @c3 AS float, @c4  AS float
	,@c5  AS float, @c6 AS float, @d1 AS float
	,@d2  AS float, @d3 AS float, @d4 AS float
	,@p_low  AS float, @p_high  AS float,@q  AS float, @r  AS FLOAT,@NormSInv_r float


	SET @p_high = 1 - @p_low

	select @a1 = -39.6968302866538, @a2 = 220.946098424521, @a3 = -275.928510446969
		,@a4 = 138.357751867269, @a5 = -30.6647980661472, @a6 = 2.50662827745924
		,@b1 = -54.4760987982241, @b2 = 161.585836858041, @b3 = -155.698979859887
		,@b4 = 66.8013118877197, @b5 = -13.2806815528857, @c1 = -7.78489400243029E-03
		,@c2 = -0.322396458041136, @c3 = -2.40075827716184, @c4 = -2.54973253934373
		,@c5 = 4.37466414146497, @c6 = 2.93816398269878, @d1 = 7.78469570904146E-03
		,@d2 = 0.32246712907004, @d3 = 2.445134137143, @d4 = 3.75440866190742
		,@p_low = 0.02425, @p_high = 1 - @p_low

	If @p <= 0 Or @p >= 1
		SET @NormSInv_r = 0 --Err.Raise vbObjectError, , "NormSInv: Argument out of range."
	ELSE If @p < @p_low
	begin
		SET @q = Sqrt(-2 * Log(@p))
		SET @NormSInv_r = (((((@c1 * @q + @c2) * @q + @c3) * @q + @c4) * @q + @c5) * @q + @c6) / ((((@d1 * @q + @d2) * @q + @d3) * @q + @d4) * @q + 1)
	end
	ELSE If @p <= @p_high
	begin
		SET @q = @p - 0.5
		SET  @r = @q * @q
		SET @NormSInv_r = (((((@a1 * @r + @a2) * @r + @a3) * @r + @a4) * @r + @a5) * @r + @a6) * @q / (((((@b1 * @r + @b2) * @r + @b3) * @r + @b4) * @r + @b5) * @r + 1)
	end
	ELSE
	begin
	   SET @q = Sqrt(-2 * Log(1 - @p))
	   SET @NormSInv_r = -(((((@c1 * @q + @c2) * @q + @c3) * @q + @c4) * @q + @c5) * @q + @c6) / ((((@d1 * @q + @d2) * @q + @d3) * @q + @d4) * @q + 1)
	end

RETURN @NormSInv_r
END
