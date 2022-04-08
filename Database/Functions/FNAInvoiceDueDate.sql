/****** Object:  UserDefinedFunction [dbo].[FNAInvoiceDueDate]    Script Date: 12/02/2009 21:29:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAInvoiceDueDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAInvoiceDueDate]
/****** Object:  UserDefinedFunction [dbo].[FNAInvoiceDueDate]    Script Date: 12/02/2009 21:29:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select dbo.FNAInvoiceDueDate('2013-01-01',20001,NULL,12)
CREATE FUNCTION [dbo].[FNAInvoiceDueDate](@start_date DATETIME,@due_date_type INT, @holiday_calendar_id INT = NULL,@no_of_days INT)
RETURNS DATETIME
AS
BEGIN
	
	--DECLARE @start_date DATETIME,@due_date_type INT, @holiday_calendar_id INT,@no_of_days INT
	--SET @start_date = '2013-01-01'
	--SET @due_date_type =20002
	--SET @no_of_days =20
	
	DECLARE @hol_calendar INT,@end_date DATETIME, @business_day INT,@ret_date DATETIME,@system_default_hol_calendar INT,@month_incr INT,@week_incr INT, @finaldate DATETIME
	SELECT @system_default_hol_calendar= calendar_desc FROM [default_holiday_calendar]
	SET @hol_calendar = COALESCE(@holiday_calendar_id,@system_default_hol_calendar,291898)


	--IF ISNULL(@no_of_days,0) = 0
	--	SET @no_of_days =1
		
	SET @month_incr = NULL
	SET @week_incr = NULL
	
	IF @due_date_type IN(20025)
	BEGIN
		SET @ret_date = dbo.FNAGetFirstLastDayOfMonth(@start_date, 'l')
	END	
	IF @due_date_type IN(20018,20019,20020,20023,20024)  
	BEGIN
		IF 	@due_date_type=20018 OR @due_date_type=20023
			SET @ret_date = DATEADD(d,@no_of_days,@start_date)  
		ELSE
			IF @due_date_type = 20019 OR @due_date_type=20024
				SET @ret_date = dbo.FNAGetBusinessDay ('n',DATEADD(d,@no_of_days-1,@start_date),@hol_calendar) 	
			ELSE
				SET @ret_date = dbo.FNAGetBusinessDay ('p',DATEADD(d,@no_of_days,@start_date),@hol_calendar) 		
	END
	IF @due_date_type IN(20001,20003,20005,20007,20009,20011,20013,20015,20017,20021,20022)  --Calendar day 20th
		BEGIN
			IF ISNULL(@no_of_days,0) = 0
				SET @no_of_days =1
	
			IF @due_date_type=20001
				SET @month_incr = 0
			ELSE IF @due_date_type=20003 OR @due_date_type = 20021
				SET @month_incr = 1
			ELSE IF @due_date_type=20005
				SET @month_incr = 2
			ELSE IF @due_date_type=20007
				SET @month_incr = 3
			ELSE IF @due_date_type=20009
				SET @month_incr = 4
			ELSE IF @due_date_type=20011
				SET @month_incr = 5
			ELSE IF @due_date_type=20013
				SET @week_incr = 0
			ELSE IF @due_date_type=20015 OR @due_date_type = 20022
				SET @week_incr = 1
			ELSE IF @due_date_type=20017
				SET @week_incr = 2
			
			SET @business_day = @no_of_days
			IF @month_incr IS NOT NULL
				SET @start_date = DATEADD(d,@no_of_days-1,DATEADD(m,@month_incr,dbo.FNAGetContractMonth(@start_date)))
			ELSE IF @week_incr IS NOT NULL	
				SET @start_date = DATEADD(d,@no_of_days-1,DATEADD(wk,@week_incr, DATEADD(WEEK, DATEDIFF(WEEK, '19050101', @start_date), '19050101')))			
			
			IF @due_date_type IN(20021,20022)
				SET @ret_date = dbo.FNAGetBusinessDay ('p',@start_date+1,@hol_calendar)
			ELSE
				SET @ret_date = dbo.FNAGetBusinessDay ('n',@start_date-1,@hol_calendar)
			
		END

	ELSE IF @due_date_type IN(20000,20002,20004,20006,20008,20010,20012,20014,20016)  -- working day 20th
		BEGIN
			IF @due_date_type=20000
				SET @month_incr = 0
			ELSE IF @due_date_type=20002
				SET @month_incr = 1
			ELSE IF @due_date_type=20004
				SET @month_incr = 2
			ELSE IF @due_date_type=20006
				SET @month_incr = 3
			ELSE IF @due_date_type=20008
				SET @month_incr = 4
			ELSE IF @due_date_type=20010
				SET @month_incr = 5
			ELSE IF @due_date_type=20012
				SET @week_incr = 0
			ELSE IF @due_date_type=20014
				SET @week_incr = 1
			ELSE IF @due_date_type=20016
				SET @week_incr = 2
			
			SET @business_day = @no_of_days

			IF @month_incr IS NOT NULL
			BEGIN
				SET @start_date = DATEADD(m,@month_incr,dbo.FNAGetContractMonth(@start_date))
				SET @end_date = DATEADD(m,2,dbo.FNAGetContractMonth(@start_date))-1
	
				;WITH cte (dtDate) AS
				(
					SELECT @start_date
					UNION ALL
					SELECT DATEADD(DD,1,dtDate) FROM CTE 
					WHERE dtDate < @end_date 
				)


		SELECT @ret_date=dtDate 
				FROM 
				(
					SELECT 	ROW_NUMBER() OVER 
							(ORDER BY dtDate) AS businessday,
							 ROW_NUMBER() OVER 
							(ORDER BY dtDate DESC) AS businessday_rev
						   ,dtDate
					FROM CTE 
					WHERE DATEPART(W,dtDate) NOT IN (7,1)
					AND NOT EXISTS (SELECT hol_date FROM holiday_group 
									WHERE hol_date = dtDate AND hol_group_value_id = @hol_calendar
								   )
				) AS X
				WHERE  ABS(@business_day) = CASE WHEN @business_day >0 THEN businessday WHEN @business_day=0 THEN businessday-1 ELSE businessday_rev END
				OPTION (MAXRECURSION 0)
			END	
			ELSE IF @week_incr IS NOT NULL	
			BEGIN
				SET @end_date = DATEADD(wk,@week_incr,DATEADD(WEEK, DATEDIFF(WEEK, '19050101', @start_date), '19050101'))
				SET @end_date = dbo.FNAGetBusinessDay ('n',@end_date,@hol_calendar)
				SET @ret_date = @end_date
			END	
			


	
		END
		ELSE IF @due_date_type IN (20018) 
			BEGIN
				IF(@no_of_days < 0)
				BEGIN
					SELECT @finaldate = dbo.FNAGetBusinessDayN('p',@start_date,@hol_calendar, ABS(@no_of_days))
				END
				ELSE
				BEGIN
					SELECT @finaldate = dbo.FNAGetBusinessDayN('n',@start_date,@hol_calendar, @no_of_days)
				END
				SET @ret_date = @finaldate
		   END

	
	RETURN(@ret_date)
	

END

