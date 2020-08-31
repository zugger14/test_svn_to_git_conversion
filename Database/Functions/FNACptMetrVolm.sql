/****** Object:  UserDefinedFunction [dbo].[FNADealLeg]    Script Date: 04/07/2009 17:17:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNACptMetrVolm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNACptMetrVolm]
/****** Object:  UserDefinedFunction [dbo].[FNACptMetrVolm]    Script Date: 04/07/2009 17:17:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNACptMetrVolm](@block_define_id INT,@country_id INT)
RETURNS FLOAT AS  
BEGIN 
	return 1
END
