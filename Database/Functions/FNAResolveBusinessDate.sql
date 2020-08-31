 IF OBJECT_ID('dbo.FNAResolveBusinessDate') IS NOT NULL
     DROP FUNCTION dbo.FNAResolveBusinessDate
GO

/*
 * FNAResolveBusinessDate - Resolve date for the static data Type - 45600
 * Param :
 * @value_id - static data value id
 */
CREATE FUNCTION dbo.FNAResolveBusinessDate (
	@value_id       INT
)
RETURNS VARCHAR(10)
AS
BEGIN	
	DECLARE @return_value VARCHAR(10)
	DECLARE @dates TABLE (
	            current_day VARCHAR(10) COLLATE DATABASE_DEFAULT,
	            current_business_day VARCHAR(10) COLLATE DATABASE_DEFAULT,
	            fisrt_day_month VARCHAR(10) COLLATE DATABASE_DEFAULT,
	            last_day_month VARCHAR(10) COLLATE DATABASE_DEFAULT,
	            first_day_week VARCHAR(10) COLLATE DATABASE_DEFAULT,
	            last_day_week VARCHAR(10) COLLATE DATABASE_DEFAULT,
	            first_business_day_month VARCHAR(10) COLLATE DATABASE_DEFAULT,
	            last_business_day_month VARCHAR(10) COLLATE DATABASE_DEFAULT,
	            first_business_day_week VARCHAR(10) COLLATE DATABASE_DEFAULT,
	            last_business_day_week VARCHAR(10) COLLATE DATABASE_DEFAULT
	)
	-- SELECT dbo.FNAResolveBusinessDate(45603)
	--select * FROM static_data_value where type_id = 45600
	INSERT INTO @dates (
	    current_day,
	    current_business_day,
	    fisrt_day_month,
	    last_day_month,
	    first_day_week,
	    last_day_week,
	    first_business_day_month,
	    last_business_day_month,
	    first_business_day_week,
	    last_business_day_week
	  )
	SELECT  CAST(dt.CurrentDate AS DATE) CurrentDate,
			CAST(dt.CurrentBusinessDay AS DATE) CurrentBusinessDay,
			CAST(dt.FirstDayOfTheMonth AS DATE) FirstDayOfTheMonth,
			CAST(dt.LastDayOfTheMonth AS DATE) LastDayOfTheMonth,
			CAST(dt.FirstDayOfWeek AS DATE) FirstDayOfWeek,
			CAST(dt.LastDayOfWeek AS DATE) LastDayOfWeek,
			dt.FirstBusinessDayOfMonth,
			dt.LastBusinessDayOfMonth,
			dt.FirstBusinessDayOfWeek,
			dt.LastBusinessDayOfWeek
	FROM default_holiday_calendar dhc
	OUTER APPLY (
		SELECT GETDATE() [CurrentDate],
				dbo.FNAGetBusinessDay('p',dbo.FNAGetBusinessDay('n', GETDATE(), dhc.calendar_desc), dhc.calendar_desc )[CurrentBusinessDay],
				DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0) AS 
				FirstDayOfTheMonth,
				DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, GETDATE()) + 1, 0)) AS 
				LastDayOfTheMonth,
				DATEADD(ww, DATEDIFF(ww, 0, GETDATE()), 0) - 1 AS FirstDayOfWeek,
				DATEADD(ww, DATEDIFF(ww, 0, GETDATE()), 4) + 1 AS LastDayOfWeek,
				dbo.FNAGetBusinessDay('n',dbo.FNAGetFirstLastDayOfMonth(DATEADD(MONTH, -1, GETDATE()), 'l'),dhc.calendar_desc)     FirstBusinessDayOfMonth,
				dbo.FNAGetBusinessDay('p',dbo.FNAGetFirstLastDayOfMonth(DATEADD(MONTH, 1, GETDATE()), 'f'),dhc.calendar_desc)     LastBusinessDayOfMonth,
				dbo.FNAGetBusinessDay('n',(DATEADD(wk, 0, DATEADD(DAY, 0-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE())))),dhc.calendar_desc)     FirstBusinessDayOfWeek,
				dbo.FNAGetBusinessDay('p',(DATEADD(wk, 1, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE())))),dhc.calendar_desc) LastBusinessDayOfWeek
	) dt
	
	IF @value_id = 45600
		SELECT @return_value = current_day FROM @dates
	IF @value_id = 45601
		SELECT @return_value = current_business_day FROM @dates
	IF @value_id = 45602
		SELECT @return_value = fisrt_day_month FROM @dates
	IF @value_id = 45603
		SELECT @return_value = last_day_month FROM @dates
	IF @value_id = 45604
		SELECT @return_value = first_business_day_month FROM @dates
	IF @value_id = 45605
		SELECT @return_value = last_business_day_month FROM @dates
	IF @value_id = 45606
		SELECT @return_value = first_day_week FROM @dates
	IF @value_id = 45607
		SELECT @return_value = last_day_week FROM @dates
	IF @value_id = 45608
		SELECT @return_value = first_business_day_week FROM @dates
	IF @value_id = 45609
		SELECT @return_value = last_business_day_week FROM @dates
	
	RETURN @return_value
END