SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNAAverageMnthlyPrice]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAAverageMnthlyPrice]
GO

CREATE FUNCTION [dbo].[FNAAverageMnthlyPrice](@curve_id INT,@param INT)
	RETURNS FLOAT
AS
BEGIN
	RETURN 1.0
END
GO
