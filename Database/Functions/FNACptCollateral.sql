/****** Object:  UserDefinedFunction [dbo].[FNACptCollateral]    Script Date: 12/07/2010 16:46:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNACptCollateral]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNACptCollateral]
/****** Object:  UserDefinedFunction [dbo].[FNACptCollateral]    Script Date: 12/07/2010 16:47:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SELECT [dbo].[FNACptCollateral]('2012-01-01',42)
CREATE FUNCTION [dbo].[FNACptCollateral]()
RETURNS FLOAT AS  
BEGIN 
	RETURN 1		
END
