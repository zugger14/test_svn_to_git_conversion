/****** Object:  UserDefinedFunction [dbo].[FNAAverageHourlyMnPrice]    Script Date: 06/15/2010 18:29:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAAverageHourlyMnPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAAverageHourlyMnPrice]
/****** Object:  UserDefinedFunction [dbo].[FNAAverageHourlyMnPrice]    Script Date: 06/15/2010 18:30:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAAverageHourlyMnPrice](@curve_id INT,@block_define_id INT)
RETURNS float AS  
BEGIN 
	return 1
END





