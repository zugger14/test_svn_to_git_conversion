IF OBJECT_ID('FNARelativePeriod', 'FN') IS NOT NULL 
	DROP FUNCTION dbo.FNARelativePeriod 

/****** Object:  UserDefinedFunction [dbo].[FNARelativePeriod]    Script Date: 10/30/2009 10:23:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Function [dbo].[FNARelativePeriod] (
	@curve_Id INT,
	@period INT-- 0 Day, 1 Month, 2 year
)

RETURNS float
AS
BEGIN
 
	RETURN(1)
end
 

