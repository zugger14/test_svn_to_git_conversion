/****** Object:  UserDefinedFunction [dbo].[FNAIsHoliday]    Script Date: 07/23/2009 01:09:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAIsHoliday]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAIsHoliday]
/****** Object:  UserDefinedFunction [dbo].[FNAIsHoliday]    Script Date: 07/23/2009 01:09:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAIsHoliday]()
RETURNS float AS  
BEGIN 
	return 1
END








