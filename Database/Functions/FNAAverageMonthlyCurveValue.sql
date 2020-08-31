IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAAverageMonthlyCurveValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAAverageMonthlyCurveValue]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAAverageMonthlyCurveValue](@price_multiplier float,@call_from int)
RETURNS FLOAT 
AS  
BEGIN 
	RETURN 1
END
