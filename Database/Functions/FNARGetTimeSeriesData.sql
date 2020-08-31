IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARGetTimeSeriesData]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNARGetTimeSeriesData]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==================================================================================
-- Created date: 2015-10-16
-- Description:	Returns Time Series data based on the as of date
-- Param: 
--	@@time_series_id int - Time Series ID
-- Returns: 1
-- ==================================================================================
CREATE FUNCTION dbo.FNARGetTimeSeriesData(@time_series_id int,@as_of_date DATETIME)
RETURNS FLOAT
AS
BEGIN
	DECLARE @value FLOAT

	SELECT 
		@value = tsd.value
	FROM	
		time_series_data tsd
		CROSS APPLY(SELECT MAX(effective_date) effective_date 
			FROM time_series_data 
		WHERE time_series_definition_id=tsd.time_series_definition_id
			  AND effective_date <= @as_of_date ) tsd1
	WHERE
		tsd.time_series_definition_id = @time_series_id
		AND tsd.effective_date = tsd1.effective_date

	RETURN @value
END
