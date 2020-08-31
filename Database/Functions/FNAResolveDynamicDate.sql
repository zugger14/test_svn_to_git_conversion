SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNAResolveDynamicDate', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNAResolveDynamicDate
GO

/**
	Function to resolve date at runtime.

	Parameters
	@dyndate_source	:	Dynamic data parameter with pipe separated. Eg '45609|0|106400|n'.
*/

CREATE FUNCTION [dbo].[FNAResolveDynamicDate] (@dyndate_source AS VARCHAR(500))
RETURNS DATE
AS

/*
--SELECT [dbo].[FNAResolveDynamicDate]('2015-05-11')
--SELECT [dbo].[FNAResolveDynamicDate]('45609|0|106400|n')
DECLARE @dyndate_source AS VARCHAR(500)
 --SET @dyndate_source = '45606|2|106401|y' -- week 
 --SET @dyndate_source = '45606|2|106400|y' -- day
 --SET @dyndate_source = '45606|-2|106400|y' -- day
 --SET @dyndate_source = '45606|-2|106401|y' -- day
 --SET @dyndate_source = '45602|2|106400|y' -- 45602 first day of the month 
--*/
BEGIN
	IF(CHARINDEX ('|',@dyndate_source) = 0)
		RETURN(@dyndate_source)

	DECLARE 
		  @static_date DATE 
		, @date_type INT  
		, @adj_value INT 
		, @adj_type INT 
		, @is_bussiness_day char(1)
		, @date_adj_value DATE 
		, @holiday_group_id INT
		, @client_current_date DATETIME
		
	SELECT @client_current_date = [dbo].[FNAConvertTimezone](GETDATE(),0)

	SELECT TOP 1 @holiday_group_id = calendar_desc
		FROM default_holiday_calendar 
	
	SELECT
		  @date_type = clm1
		, @adj_value = clm2
		, @adj_type = clm3
		, @is_bussiness_day = clm4
	FROM [dbo].[FNASplitAndTranspose](@dyndate_source, '|')

	
	--IF NULLIF(@static_date, '') IS NOT NULL
	--BEGIN
	--	RETURN(@static_date)
	--END
	--List Date according to Override Type i.e type id(45600)
	SET @static_date = (
		SELECT CASE sdv.value_id
			WHEN 45600 --Current Day
				THEN CAST(dt.CurrentDate AS DATE)
			WHEN 45602 --First Day of the Month
				THEN CAST(dt.[FirstDayOfTheMonth] AS DATE)
			WHEN 45603 --Last Day of the Month
				THEN CAST(dt.[LastDayOfTheMonth] AS DATE)
			WHEN 45606 --First Day of the Week
				THEN CAST(dt.[FirstDayOfWeek] AS DATE)
			WHEN 45607 --Last Day of the Week
				THEN CAST(dt.[LastDayOfWeek] AS DATE)
			WHEN 45611 --First Day of the Current Year
				THEN CAST(dt.[FirstDayOfTheYear] AS DATE)
			WHEN 45612 --Last Day of Current Year)
				THEN CAST(dt.[LastDayOfTheYear] AS DATE)
			WHEN 45604 --First Business Day of the Month
				THEN CAST(dt1.[FirstBusinessDayOfTheMonth] AS DATE)
			WHEN 45605 --Last Business Day of the Month
				THEN CAST(dt1.[LastBusinessDayOfTheMonth] AS DATE)
			WHEN 45609 --Last Business Day of the Week
				THEN CAST(dt.[LastBusinessDayOfTheWeek] AS DATE)
			WHEN 45608 --First Business Day of the Week
				THEN CAST(dt.[FirstBusinessDayOfTheWeek] AS DATE)
			WHEN 45613 --First Day of the Current Quarter
				THEN CAST(dt.[FirstDayOfTheQuarter] AS DATE)
			WHEN 45614 --Last Day of the Current Quarter
				THEN CAST(dt.[LastDayOfTheQuarter] AS DATE)
			WHEN 45615 --First Business Day of the Current Quarter
				THEN CAST(dt3.[FirstBusinessDayOfTheQuarter] AS DATE)
			WHEN 45616 --Last Business Day of the Current Quarter
				THEN CAST(dt3.[LastBusinessDayOfTheQuarter] AS DATE)
			ELSE CAST(@client_current_date AS DATE)
			END [Value]
		FROM static_data_value  sdv
		OUTER APPLY (
			SELECT @client_current_date [CurrentDate]
				,DATEADD(MONTH, DATEDIFF(MONTH, 0, @client_current_date), 0) AS FirstDayOfTheMonth
				,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @client_current_date) + 1, 0)) AS LastDayOfTheMonth
				,DATEADD(ww, DATEDIFF(ww, 0, @client_current_date), 0) - 1 AS FirstDayOfWeek
				,DATEADD(ww, DATEDIFF(ww, 0, @client_current_date), 4) + 1 AS LastDayOfWeek
				,DATEADD(yy, DATEDIFF(yy, 0, @client_current_date), 0)  AS [FirstDayOfTheYear]
				,DATEADD (dd, -1, DATEADD(yy, DATEDIFF(yy, 0, @client_current_date) +1, 0)) [LastDayOfTheYear]
				,DATEADD(qq, DATEDIFF(qq, 0, @client_current_date), 0) [FirstDayOfTheQuarter]
				,DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @client_current_date) +1, 0)) [LastDayOfTheQuarter]
				,dbo.FNAGetBusinessDay ('p', DATEADD(ww, DATEDIFF(ww, 0, @client_current_date), 4) + 1, @holiday_group_id) [LastBusinessDayOfTheWeek]
				,dbo.FNAGetBusinessDay ('n', DATEADD(ww, DATEDIFF(ww, 0, @client_current_date), 0) - 1, @holiday_group_id) [FirstBusinessDayOfTheWeek]
			) dt
		OUTER APPLY (
			SELECT MIN(sql_date_value) AS FirstBusinessDayOfTheMonth, MAX(sql_date_value) LastBusinessDayOfTheMonth FROM [vw_date_details] vdd 
				LEFT JOIN holiday_group hg ON hg.hol_date = vdd.[sql_date_value]
					AND hg.hol_group_value_id = @holiday_group_id WHERE is_weekday <> 0 
					AND hg.hol_group_ID IS NULL
					AND MONTH(sql_date_value) = MONTH (@client_current_date) AND YEAR(sql_date_value) = YEAR (@client_current_date)
		) dt1
		OUTER APPLY(
			SELECT MIN(sql_date_value) AS FirstBusinessDayOfTheQuarter, MAX(sql_date_value) LastBusinessDayOfTheQuarter FROM [vw_date_details] vdd 
			LEFT JOIN holiday_group hg ON hg.hol_date = vdd.[sql_date_value]
					AND hg.hol_group_value_id = @holiday_group_id WHERE is_weekday <> 0 
					AND hg.hol_group_ID IS NULL
					--AND MONTH(sql_date_value) = MONTH (@client_current_date) 
					AND YEAR(sql_date_value) = YEAR (@client_current_date)
					AND DATEPART(qq,sql_date_value) = DATEPART(qq,@client_current_date)
		) dt3

		WHERE sdv.value_id = @date_type
		)

	--Adjust type to adjust value i.e Day, Month, Week and Quater.
	SET @date_adj_value = (
			SELECT CASE 
					WHEN sdv.value_id = 106400  AND @is_bussiness_day = 'n' --'Day'
						THEN DATEADD(day, @adj_value, @static_date)
					WHEN sdv.value_id = 106402 AND @date_type = 45603 --'Month' and EOF
                        THEN EOMONTH(DATEADD(month, @adj_value, @static_date))
					WHEN sdv.value_id = 106402 --'Month'
						THEN DATEADD(month, @adj_value, @static_date)
					WHEN sdv.value_id = 106403 --'Quarter'
						THEN DATEADD(quarter, @adj_value, @static_date)
					WHEN sdv.value_id = 106401 --'Week'
						THEN DATEADD(week, @adj_value, @static_date)
					WHEN sdv.value_id = 106404 --'Year'
						THEN DATEADD(year, @adj_value, @static_date)
					ELSE @static_date
					END
			FROM static_data_value sdv
			WHERE sdv.value_id = @adj_type
		)
		
	IF @is_bussiness_day = 'y' AND @adj_value > 0 --resolve date if bussiness day and positive adjust value.
	BEGIN

		SET @date_adj_value   = (
			SELECT TOP 1 p_dk.[sql_date_value]
			FROM (
				SELECT DENSE_RANK() OVER (ORDER BY [sql_date_value] ASC) AS row_id
					, [sql_date_value]
				FROM  [dbo].[vw_date_details] dd
				LEFT JOIN holiday_group hg ON hg.hol_date = dd.[sql_date_value]
					AND hg.hol_group_value_id = @holiday_group_id
				WHERE 1 = 1
					AND (
						hg.hol_group_ID IS NULL
						AND dd.is_weekday <> 0
						)
					AND dd.[sql_date_value] > CASE WHEN @adj_type <> 106400 THEN DATEADD(DAY, -1, @date_adj_value) ELSE @date_adj_value END
					) p_dk
		WHERE row_id = IIF(@adj_type <> 106400, 1, @adj_value)
		)
    END
	
	IF @is_bussiness_day = 'y' AND @adj_value < 0 --resolve date if bussiness day and negative adjust value.
	BEGIN

		SET @date_adj_value   = (
			SELECT TOP 1 n_dk.[sql_date_value]
			FROM (
				SELECT DENSE_RANK() OVER ( ORDER BY [sql_date_value] DESC) AS row_id
				, [sql_date_value]
				FROM [dbo].[vw_date_details] dd
				LEFT JOIN holiday_group hg ON hg.hol_date = dd.[sql_date_value]
					AND hg.hol_group_value_id = @holiday_group_id
				WHERE 1 = 1
					AND (
						hg.hol_group_ID IS NULL
						AND dd.is_weekday <> 0
						)
					AND dd.[sql_date_value] < 	
					CASE WHEN @adj_type <> 106400 THEN DATEADD(DAY, 1, @date_adj_value) ELSE @date_adj_value END
				) n_dk
			WHERE row_id = IIF(@adj_type <> 106400, 1, ABS(@adj_value)) )
    END

	--SELECT @date_adj_value
	RETURN(@date_adj_value)

END








GO
