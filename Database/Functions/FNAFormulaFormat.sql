/****** Object:  UserDefinedFunction [dbo].[FNAFormulaFormat]    Script Date: 09/15/2011 11:42:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FNAFormulaFormat]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAFormulaFormat]
GO

/****** Object:  UserDefinedFunction [dbo].[FNAFormulaFormat]    Script Date: 09/15/2011 11:42:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAFormulaFormat] (@formula VARCHAR(MAX),@type CHAR(1))
RETURNS VARCHAR(8000) AS  
BEGIN 
	DECLARE @test_formula VARCHAR(8000)
		
	SET @test_formula = CAST([dbo].FNAFormulaFormatMaxString(@formula, @type) AS VARCHAR(8000))
		
	RETURN @test_formula
END



GO


