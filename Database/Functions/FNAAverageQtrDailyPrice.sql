IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAAverageQtrDailyPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAAverageQtrDailyPrice]
GO
CREATE FUNCTION [dbo].[FNAAverageQtrDailyPrice](@curve_id VARCHAR(200), @month INT)
RETURNS FLOAT AS  
BEGIN 
	RETURN 1 
END

