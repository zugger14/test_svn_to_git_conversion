/****** Object:  UserDefinedFunction [dbo].[FNASourceEmissionsValue]    Script Date: 06/14/2009 22:56:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNASourceEmissionsValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNASourceEmissionsValue]
/****** Object:  UserDefinedFunction [dbo].[FNASourceEmissionsValue]    Script Date: 06/14/2009 22:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNASourceEmissionsValue](@generator_id INT,@series_type INT,@year INT,@no_of_months INT)
RETURNS float AS  
BEGIN 
	return 1
END

