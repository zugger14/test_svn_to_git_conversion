/****** Object:  UserDefinedFunction [dbo].[FNAExAntePrice]    Script Date: 06/05/2009 17:29:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAExAntePrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAExAntePrice]
/****** Object:  UserDefinedFunction [dbo].[FNAExAntePrice]    Script Date: 06/05/2009 17:29:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAExAntePrice](@product_type INT)
RETURNS float AS  
BEGIN 
	return 1
END









