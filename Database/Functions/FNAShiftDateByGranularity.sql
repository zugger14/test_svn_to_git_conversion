IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNAShiftDateByGranularity]') AND [type] IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].FNAShiftDateByGranularity

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ===========================================================================================================
-- Author: Runaj Khatiwada
-- Create date: 2018-06-01
-- Description: Function to shift the date value by given interval of time, interval of time is in the basis of granularity.
-- Params:
--	Granularity --> It is static data values of type id 978 which gives the granularity whether it is daily or weekly or many more.
--  Shift By --> It is the constant value by which the date field is shifted on the basis of granularity.
--  Input Dat --> This is the input date which has to be shifted.
-- RETURNS DATETIME (Shifted Date value)

-- Sample Data: SELECT dbo.FNAShiftDateByGranularity(980, 5, GETDATE()) --Shifts the input date by 5 months.
-- ===========================================================================================================

CREATE FUNCTION [dbo].[FNAShiftDateByGranularity] (
	@granularity INT,
	@shift_by INT,
	@input_date DATETIME
)
	RETURNS DATETIME 
AS  
BEGIN 
	DECLARE @return_value DATETIME

	SET @return_value = CASE 
							WHEN @granularity = 980 THEN DATEADD(MONTH, @shift_by, @input_date) --Monthly
							WHEN @granularity = 981 THEN DATEADD(DAY, @shift_by, @input_date) --Daily
							WHEN @granularity = 982 THEN DATEADD(HOUR, @shift_by, @input_date) --Hourly
							WHEN @granularity = 987 THEN DATEADD(MINUTE, @shift_by * 15, @input_date) --15Mins
							WHEN @granularity = 989 THEN DATEADD(MINUTE, @shift_by * 30, @input_date) --30Mins
							WHEN @granularity = 990 THEN DATEADD(DAY, @shift_by * 7, @input_date) --Weekly
							WHEN @granularity = 991 THEN DATEADD(YEAR, @shift_by / 4, @input_date) --Quarterly
							WHEN @granularity = 992 THEN DATEADD(YEAR, @shift_by / 2, @input_date) --Semi-Annually
							WHEN @granularity = 993 THEN DATEADD(YEAR, @shift_by, @input_date) --Annually
							WHEN @granularity = 994 THEN DATEADD(MINUTE, @shift_by * 10, @input_date) --10Min
							WHEN @granularity = 995 THEN DATEADD(MINUTE, @shift_by * 5, @input_date) --5Min
							ELSE @input_date
						END

	RETURN @return_value
END
GO