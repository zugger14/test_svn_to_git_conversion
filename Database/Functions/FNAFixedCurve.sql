GO
/****** Object:  UserDefinedFunction [dbo].[FNAFixedCurve]    Script Date: 07/23/2009 01:09:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAFixedCurve]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAFixedCurve]
/****** Object:  UserDefinedFunction [dbo].[FNAFixedCurve]    Script Date: 07/23/2009 01:10:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Function [dbo].[FNAFixedCurve] (
	@curve_Id INT
	
)

RETURNS float
AS
BEGIN
 
	RETURN(1)
end
 

