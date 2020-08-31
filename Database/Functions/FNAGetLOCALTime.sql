SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNAGetLOCALTime', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNAGetLOCALTime
GO

/**
	Converts UTC Time to given timezone.

	Parameters
	@Date	:	DateTime
	@Timezone	:	Time Zone to convert to
*/

CREATE FUNCTION [dbo].[FNAGetLOCALTime] 
	(@Date AS DATETIME, 
	 @Timezone AS INT)
RETURNS DATETIME
AS
BEGIN
-- DECLARE VARIABLES
	DECLARE @NEWDT AS DATETIME
	DECLARE @OFFSETHR AS INT
	DECLARE @OFFSETMI AS INT
	DECLARE @DSTOFFSETHR AS INT
	DECLARE @DSTOFFSETMI AS INT
	DECLARE @DSTDT AS VARCHAR(10)
	DECLARE @DSTEFFDT AS VARCHAR(10)
	DECLARE @DSTENDDT AS VARCHAR(10)

	DECLARE @DST_eff_wom AS VARCHAR(1)	--DST effective week of month
	
	--extra variables to resolve last nth day of month (e.g. European DST, where DST is applied on last Sunday on March)
	DECLARE @last_eff_day_of_month DATE
	--base date, which is Sunday; used to get last nth day of the month
	DECLARE @base_date DATE = CAST('19000107' AS DATE)	
	DECLARE @DST_eff_day VARCHAR(1)
	DECLARE @base_adjusted_date DATE
	
-- GET THE DST parameter from the provided datetime
	-- This gets the month of the datetime provided (2 char value)
	SELECT @DSTDT = CASE LEN(DATEPART(month, @Date)) WHEN 1 then '0' + CONVERT(VARCHAR(2),DATEPART(month, @Date)) ELSE CONVERT(VARCHAR(2),DATEPART(month, @Date)) END
	-- This gets the occurance of the day of the week within the month (i.e. first sunday, or second sunday...) (1 char value)
	SELECT @DSTDT = @DSTDT + CONVERT(VARCHAR(1), DATEPART(WEEK, @Date)
			- DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM,0,@Date), 0))+ 1)
	-- This gets the day of the week for the provided datetime (1 char value)
	SELECT @DSTDT = @DSTDT + CONVERT(VARCHAR(1),DATEPART(dw, @Date))
	-- This gets the hour for the provided datetime (2 char value)
	SELECT @DSTDT = @DSTDT + CASE LEN(DATEPART(hh, @Date)) WHEN 1 then '0' + CONVERT(VARCHAR(2),DATEPART(hh, @Date)) ELSE CONVERT(VARCHAR(2),DATEPART(hh, @Date)) END
	-- This gets the minutes for the provided datetime (2 char value)
	SELECT @DSTDT = @DSTDT + CASE LEN(DATEPART(mi, @Date)) WHEN 1 then '0' + CONVERT(VARCHAR(2),DATEPART(mi, @Date)) ELSE CONVERT(VARCHAR(2),DATEPART(mi, @Date)) END
	
	-- This query gets the timezone information from the TIME_ZONES table for the provided timezone
	SELECT
		@OFFSETHR=offset_hr,
		@OFFSETMI=offset_mi,
		@DSTOFFSETHR=dst_offset_hr,
		@DSTOFFSETMI=dst_offset_mi,
		@DSTEFFDT=dst_eff_dt,
		@DSTENDDT=dst_END_dt
	FROM time_zones
	WHERE timezone_id = @Timezone AND
		@Date BETWEEN eff_dt AND end_dt
	
	--Resolve if value is L (last week, which can be either 4 or 5)
	IF LEFT(RIGHT(@DSTEFFDT, 6), 1) = 'L'
	BEGIN		
		--get day (usually Sunday) where DST applies
		SET @DST_eff_day = LEFT(RIGHT(@DSTEFFDT, 5), 1)
					
		--adjust base date (for e.g. if DST applied date is Tuesday, the adjusted base date should be 19000109, which is also Tuesday)
		SET @base_adjusted_date = DATEADD(day, @DST_eff_day - 1, @base_date)	

		--get last nth day of the month, if n = 1, it will be last Sunday
		SET @last_eff_day_of_month = DATEADD(day, DATEDIFF(day, @base_adjusted_date, DATEADD(month,DATEDIFF(MONTH, 0, @Date), 30)) / 7 * 7, @base_adjusted_date	)

		--get the week of the month (either 4 or 5) of last nth day of the month
		SET @DST_eff_wom = DATEPART(WEEK, @last_eff_day_of_month)
			- DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM,0,@last_eff_day_of_month), 0))+ 1


		--replace L with the actual week of the month for that date
		SET @DSTEFFDT = REPLACE(@DSTEFFDT, 'L' , @DST_eff_wom)

		--SELECT @last_eff_day_of_month [@last_eff_day_of_month], @DST_eff_wom [@DST_eff_wom], @DSTEFFDT [@DSTEFFDT]
	END

	--Repeat the logic for DST end date
	IF LEFT(RIGHT(@DSTENDDT, 6), 1) = 'L'
	BEGIN		
		--get day (usually Sunday) where DST applies
		SET @DST_eff_day = LEFT(RIGHT(@DSTENDDT, 5), 1)
					
		--adjust base date (for e.g. if DST applied date is Tuesday, the adjusted base date should be 19000109, which is also Tuesday)
		SET @base_adjusted_date = DATEADD(day, @DST_eff_day - 1, @base_date)	

		--get last nth day of the month, if n = 1, it will be last Sunday
		SET @last_eff_day_of_month = DATEADD(day, DATEDIFF(day, @base_adjusted_date, DATEADD(month,DATEDIFF(MONTH, 0, @Date), 30)) / 7 * 7, @base_adjusted_date	)

		--get the week of the month (either 4 or 5) of last nth day of the month
		SET @DST_eff_wom = DATEPART(WEEK, @last_eff_day_of_month)
			- DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM,0,@last_eff_day_of_month), 0))+ 1

		--replace L with the actual week of the month for that date
		SET @DSTENDDT = REPLACE(@DSTENDDT, 'L' , @DST_eff_wom)

		--SELECT @last_eff_day_of_month [@last_eff_day_of_month], @DST_eff_wom [@DST_eff_wom], @DSTENDDT [@DSTENDDT]
	END
	
	-- Checks to see if the DST parameter for the datetime provided is within the DST parameter for the timezone
	IF @DSTDT BETWEEN @DSTEFFDT AND @DSTENDDT
	BEGIN
		-- Increase the datetime by the hours and minutes assigned to the timezone
		SET @NEWDT = DATEADD(hh,@DSTOFFSETHR,@Date)
		SET @NEWDT = DATEADD(mi,@DSTOFFSETMI,@NEWDT)
	END
	-- If the DST parameter for the provided datetime is not within the defined
	-- DST eff and end dates for the timezone then use the standard time offset
	ELSE
	BEGIN
		-- Increase the datetime by the hours and minutes assigned to the timezone
		SET @NEWDT = DATEADD(hh,@OFFSETHR,@Date)
		SET @NEWDT = DATEADD(mi,@OFFSETMI,@NEWDT)
	END

	-- Return the new date that has been converted from UTC time
	RETURN @NEWDT
END




GO
