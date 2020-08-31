IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetVatAmount]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetVatAmount]
GO


/****** Object:  UserDefinedFunction [dbo].[FNAGetRates]    Script Date: 02/14/2011 15:43:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAGetVatAmount] 
(
)
RETURNS float AS  
BEGIN 

	RETURN 1
END

GO

