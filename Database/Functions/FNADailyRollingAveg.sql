/****** Object:  UserDefinedFunction [dbo].[FNADailyRollingAveg]    Script Date: 05/02/2011 11:38:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNADailyRollingAveg]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNADailyRollingAveg]
GO
/****** Object:  UserDefinedFunction [dbo].[FNADailyRollingAveg]    Script Date: 05/02/2011 11:38:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[FNADailyRollingAveg](@x int, @y int)
RETURNS float AS  
BEGIN 
	return 1
END













