/****** Object:  UserDefinedFunction [dbo].[FNA6MsBlockAverage]    Script Date: 04/05/2010 17:20:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNA6MsBlockAverage]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNA6MsBlockAverage]
/****** Object:  UserDefinedFunction [dbo].[FNA6MsBlockAverage]    Script Date: 04/05/2010 17:20:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNA6MsBlockAverage](@curve_ID INT)
RETURNS float AS  
BEGIN 
	return 1
END









