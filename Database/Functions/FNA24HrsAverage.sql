/****** Object:  UserDefinedFunction [dbo].[FNA24HrsAverage]    Script Date: 04/05/2010 17:21:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNA24HrsAverage]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNA24HrsAverage]
/****** Object:  UserDefinedFunction [dbo].[FNA24HrsAverage]    Script Date: 04/05/2010 17:21:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNA24HrsAverage](@curve_ID INT)
RETURNS float AS  
BEGIN 
	return 1
END









