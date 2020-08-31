IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetTimeSeriesData]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAGetTimeSeriesData]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==================================================================================
-- Created date: 2015-10-16
-- Description:	Validates syntax of FNARGetTimeSeriesData function
-- Param: 
--	@@time_series_id int - Time Series ID
-- Returns: 1
-- ==================================================================================
CREATE FUNCTION dbo.FNAGetTimeSeriesData(@time_series_id int)
RETURNS int
AS
BEGIN
	
	RETURN 1

END
