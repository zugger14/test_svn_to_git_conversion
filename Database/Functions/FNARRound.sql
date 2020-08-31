/****** Object:  UserDefinedFunction [dbo].[FNAActualVol]    Script Date: 01/11/2011 09:49:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARRound]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARRound]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAActualVol]    Script Date: 01/11/2011 09:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARRound](
		@value FLOAT,
		@round INT		
	
	)
	RETURNS float AS  
	BEGIN 
	
		RETURN ROUND(@value,@round)
	END









