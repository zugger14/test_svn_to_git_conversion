IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetBusinessDay]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetBusinessDay]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- modify date: 2017-08-09
-- Description: This Function Returns The Next or Previuos Business Days considering the Holiday. 
				--Modified because it could not return the correct previous business date for holidays in mondays (bmanandhar@pioneersolutionsglobal.com)

-- Params:
-- @pre_next CHAR(1) - Indicates whether to find the next ot previous day. 'p' - last business 'n' Next Business Day
-- @start_date SMALLDATE - Start Date
-- @hol_calendar INT - Holiday calendar to use 
-- Example : SELECT dbo.FNAGetBusinessDay ('p','2017-08-01',309259)
-- ===========================================================================================================

CREATE FUNCTION [dbo].[FNAGetBusinessDay] (@pre_next CHAR(1), @start_date DATE, @hol_calendar INT)
RETURNS DATE AS

BEGIN	
	DECLARE @next_bus_day DATE 
	DECLARE @is_business_day INT = 0

	DECLARE @prev_date DATE = DATEADD(DAY, -1, @start_date )
	DECLARE @next_date DATE = DATEADD(DAY, 1, @start_date )

	WHILE (@is_business_day = 0)
	BEGIN
		IF @pre_next = 'p'
		BEGIN			
			IF DATEPART(WEEKDAY,@prev_date) IN (1, 7) 	
				SET @is_business_day = 0
			ELSE IF EXISTS (SELECT hol_date FROM holiday_group WHERE hol_group_value_id =  @hol_calendar AND hol_date = @prev_date)
				 SET @is_business_day = 0
			ELSE
				SET @is_business_day = 1

			IF @is_business_day = 0
				 SET @prev_date = DATEADD(DAY, -1, @prev_date)		
		END
		ELSE IF @pre_next = 'n'
		BEGIN			
			IF DATEPART(WEEKDAY,@next_date) IN (1, 7) 	
				SET @is_business_day = 0
			ELSE IF EXISTS (SELECT hol_date FROM holiday_group WHERE hol_group_value_id =  @hol_calendar AND hol_date = @next_date)
				 SET @is_business_day = 0
			ELSE
				SET @is_business_day = 1

			IF @is_business_day = 0
				 SET @next_date = DATEADD(DAY, 1, @next_date)
		END
	END

	IF @pre_next = 'p'
		SET @next_bus_day = @prev_date
	ELSE IF @pre_next = 'n'
		SET @next_bus_day = @next_date

	RETURN @next_bus_day

END