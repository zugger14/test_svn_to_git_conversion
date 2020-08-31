IF OBJECT_ID(N'FNAResolveDate' ,N'FN') IS NOT NULL
    DROP FUNCTION FNAResolveDate
 GO
 
CREATE FUNCTION [dbo].[FNAResolveDate] (
	@date DATETIME, @date_rule INT
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @return_date DATETIME
	
	--Static data value 19307 - Today already EXISTS.
	--Static data value 19308 - Next Day already EXISTS.
	--Static data value 19309 - Next Business Day already EXISTS.
	--Static data value 19310 - Prior Day already EXISTS.
	--Static data value 19311 - Next Week already EXISTS.
	--Static data value 19312 - Next Month already EXISTS.
	--Static data value 19313 - Next Quarter already EXISTS.
	--Static data value 19314 - Next year already EXISTS.ay
	-- 19315 - Balance of the Week
	-- 19316 - Balance of the Month
	-- 19317 - Balance of the Quarter
	-- 19318 - Balance of the Year
	
	SET @return_date = CASE @date_rule 
							WHEN 19307 THEN CONVERT(DATE, GETDATE())
							WHEN 19308 THEN DATEADD(DAY, 1, @date)
							WHEN 19309 THEN dbo.FNAGetBusinessDay('n', @date, NULL)
							WHEN 19310 THEN DATEADD(DAY, -1, @date)
							WHEN 19311 THEN DATEADD(WEEK, DATEDIFF(WEEK, 0, @date) + 1, -1) -- use last param = 0, if week should start from Monday
							WHEN 19312 THEN DATEADD(m, DATEDIFF(m, -1, @date), 0)
							WHEN 19313 THEN DATEADD(qq, DATEDIFF(qq, 0, @date) + 1, 0)
							WHEN 19314 THEN DATEADD(YEAR, DATEDIFF(YEAR, 0, @date) + 1, 0)
							WHEN 19302 THEN DATEADD(MONTH, DATEDIFF(MONTH, 0, @date), 0)
							WHEN 19301 THEN DATEADD(YEAR, DATEDIFF(YEAR, 0, @date), 0)
							WHEN 19303 THEN EOMONTH(@date)
							WHEN 19304 THEN DATEADD (dd, -1, DATEADD(yy, DATEDIFF(yy, 0, @date) + 1, 0))
							WHEN 19315 THEN DATEADD(DAY, 1, @date)
							WHEN 19316 THEN DATEADD(DAY, 1, @date)
							WHEN 19317 THEN DATEADD(DAY, 1, @date)
							WHEN 19318 THEN DATEADD(DAY, 1, @date)
							ELSE @date
						END	
	RETURN @return_date
END