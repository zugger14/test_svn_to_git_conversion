IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAProvisionalCurveValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAProvisionalCurveValue]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAProvisionalCurveValue](@price_multiplier float)
RETURNS FLOAT 
AS  
BEGIN 
	RETURN 1
END
