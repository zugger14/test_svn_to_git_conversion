IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAAVGPrice]') AND [type] IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAAVGPrice]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAAVGPrice](
	@curve_id INT,
	@from_month FLOAT,
	@to_month FLOAT
)
RETURNS FLOAT AS  
BEGIN 
	RETURN 1.0
END
GO