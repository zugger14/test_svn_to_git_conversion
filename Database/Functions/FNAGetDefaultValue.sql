IF OBJECT_ID('FNAGetDefaultValue') IS NOT NULL
    DROP FUNCTION dbo.FNAGetDefaultValue
GO

CREATE FUNCTION dbo.FNAGetDefaultValue (
	@source_date   DATETIME,
	@default_value  INT
)
RETURNS VARCHAR(30)
AS
BEGIN
	--declare @source_date datetime='2011-03-03',@default_value int=19301	
	
	DECLARE @ret_val VARCHAR(30)
	
	IF ISDATE(@source_date) = 1
	BEGIN
	    SELECT @ret_val = CASE @default_value
	                           WHEN 19301 THEN --first day of year
	                                CONVERT(VARCHAR(5), @source_date, 120) + '01-01'
	                           WHEN 19302 THEN --first day of month
	                                CONVERT(VARCHAR(8), @source_date, 120) + '01'
	                           WHEN 19303 THEN --last day of month
	                                CONVERT( VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(8), DATEADD(MONTH, 1, @source_date), 120) + '01'), 120) 
							   WHEN 19304 THEN --last day of year
									CONVERT(VARCHAR(10), DATEADD(DAY, -1, CAST(YEAR(@source_date) + 1 AS VARCHAR) + '-01-01' ), 120)    
							   WHEN 19305 THEN --same as source date
							   		CONVERT(VARCHAR(10), @source_date, 120)
							   WHEN 19306 THEN --last day of month
							   		CONVERT( VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(8), DATEADD(MONTH, 1, @source_date), 120) + '01'), 120)
							   ELSE CONVERT(VARCHAR(10), @source_date, 120)
	                      END
	END
	ELSE
	    SET @ret_val = CONVERT(VARCHAR(10), @source_date, 120)
	
	RETURN @ret_val
END