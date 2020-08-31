IF OBJECT_ID(N'[dbo].[FNAConvertIntegerTo15minTime]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAConvertIntegerTo15minTime]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-01-18
-- Description: Function to convert integers to 15 minutes interval time

-- Params:
-- returns VARCHAR(10) - 15 mins time format. e.g. 00:15, 00:30
-- ===========================================================================================================
CREATE FUNCTION [dbo].[FNAConvertIntegerTo15minTime](@value INT)
    RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @time VARCHAR(10)
    SET @time = --prefix with 0 if the hr is single digit
				(CASE WHEN ((@value - 1)/ 4) < 10 THEN '0' ELSE '' END) + CAST((@value - 1)/ 4 AS VARCHAR(10)) 
				+ ':' 
				--suffix with 0 if the min is single digit (i.e. 0)
				+ CAST(((@value - 1) * 15) % 60 AS VARCHAR(2)) + CASE WHEN (((@value - 1) * 15) % 60) = 0 THEN '0' ELSE '' END
	RETURN @time					  
END
GO