/****** Object:  UserDefinedFunction [dbo].[FNADealLeg]    Script Date: 04/07/2009 17:17:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARIsYrEnd]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARIsYrEnd]
/****** Object:  UserDefinedFunction [dbo].[FNARIsYrEnd]    Script Date: 04/07/2009 17:17:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARIsYrEnd](@as_of_date DATETIME)
RETURNS INT AS  
BEGIN 
	
	DECLARE @ret INT
	
	IF MONTH(@as_of_date) = 12 AND DAY(@as_of_date)=31
		SELECT @ret =  1
	ELSE
		SELECT @ret =  0
		
	RETURN @ret	
END
