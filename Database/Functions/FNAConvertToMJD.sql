IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAConvertToMJD]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAConvertToMJD]
GO
CREATE FUNCTION [dbo].[FNAConvertToMJD] (
	@date DATETIME
	)
RETURNS float AS  
BEGIN 
	/*Convert date to MJD (Modified Julian Day) format*/
	DECLARE @month INT,
			@day INT,
			@year INT,
			@l INT,
			@p1 INT,
			@p2 INT,
			@p3 INT,
			@julian_day FLOAT

	SET @day = DAY(@date)
	SET @month = MONTH(@date)
	SET @year = YEAR(@date)

	 /*In leap years, -1 for Jan, Feb, else 0
		 Logic added from http://www.csgnetwork.com/julianmodifdateconv.html
	 */
	SET @l = CEILING((@month - 14) / 12);
	SET @p1 = @day - 32075 + FLOOR(1461 * (@year + 4800 + @l) / 4);
	SET @p2 = Floor(367 * (@month - 2 - @l * 12) / 12);
	SET @p3 = 3 *  Floor(Floor((@year + 4900 + @l) / 100) / 4);
	SET @julian_day = @p1 + @p2 - @p3      
	SET @julian_day = @julian_day + (0.0/24.0) - 0.5
	SET @julian_day = @julian_day - 2400000.5
	RETURN	@julian_day
END