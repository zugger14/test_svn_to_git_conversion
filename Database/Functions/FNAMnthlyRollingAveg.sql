/****** Object:  UserDefinedFunction [dbo].[FNAMnthlyRollingAveg]    Script Date: 05/02/2011 10:44:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAMnthlyRollingAveg]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAMnthlyRollingAveg]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAMnthlyRollingAveg]    Script Date: 05/02/2011 10:44:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAMnthlyRollingAveg](@x int, @y int)
RETURNS float AS  
BEGIN 
	return 1
END










