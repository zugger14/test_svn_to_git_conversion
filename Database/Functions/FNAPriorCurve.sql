/****** Object:  UserDefinedFunction [dbo].[FNAPriorCurve]    Script Date: 11/30/2009 20:49:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAPriorCurve]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAPriorCurve]
/****** Object:  UserDefinedFunction [dbo].[FNAPriorCurve]    Script Date: 11/30/2009 20:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Function [dbo].[FNAPriorCurve] (
	@curve_Id INT,
	@Relative_Year int, --( could be 0 or negative values. Negative value will use the prior year values)
	@Relative_month int,
	@Relative_day int,
	@same_as_of_date TINYINT,
	@use_same_as_of_date INT
)

RETURNS float
AS
BEGIN
 
	RETURN(1)
end
 

