SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNAAverageYrlyPrice]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAAverageYrlyPrice]
GO

CREATE FUNCTION [dbo].[FNAAverageYrlyPrice](@curve_id INT,@param INT)
	RETURNS FLOAT
AS
BEGIN
	RETURN 1.0
END
GO
