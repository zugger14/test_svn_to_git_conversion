/****** Object:  UserDefinedFunction [dbo].[FNADealType]    Script Date: 04/07/2009 17:15:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNADealType]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNADealType]
/****** Object:  UserDefinedFunction [dbo].[FNADealType]    Script Date: 04/07/2009 17:15:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNADealType](@deal_type_id INT,@deal_subtype_id INT)
RETURNS FLOAT AS  
BEGIN 
	return 1
END
