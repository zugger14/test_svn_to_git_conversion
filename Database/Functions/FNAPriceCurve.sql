SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNAPriceCurve]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAPriceCurve]
GO

CREATE FUNCTION [dbo].[FNAPriceCurve](@curve_id INT, @adder FLOAT, @multiplier FLOAT)
	RETURNS FLOAT
AS
BEGIN
	RETURN 1.0
END
GO
