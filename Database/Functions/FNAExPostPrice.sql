/****** Object:  UserDefinedFunction [dbo].[FNAExPostPrice]    Script Date: 07/28/2009 18:09:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAExPostPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAExPostPrice]
/****** Object:  UserDefinedFunction [dbo].[FNAExPostPrice]    Script Date: 07/28/2009 18:09:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAExPostPrice](@product_type INT,@location_id INT)
RETURNS float AS  
BEGIN 
	return 1
END









