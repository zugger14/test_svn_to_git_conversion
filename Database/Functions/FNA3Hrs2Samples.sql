/****** Object:  UserDefinedFunction [dbo].[FNA3Hrs2Samples]    Script Date: 04/05/2010 17:20:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNA3Hrs2Samples]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNA3Hrs2Samples]
/****** Object:  UserDefinedFunction [dbo].[FNA3Hrs2Samples]    Script Date: 04/05/2010 17:20:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNA3Hrs2Samples](@curve_ID INT)
RETURNS float AS  
BEGIN 
	return 1
END









