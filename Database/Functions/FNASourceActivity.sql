/****** Object:  UserDefinedFunction [dbo].[FNASourceActivity]    Script Date: 06/11/2009 09:10:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNASourceActivity]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNASourceActivity]
/****** Object:  UserDefinedFunction [dbo].[FNASourceActivity]    Script Date: 06/11/2009 09:10:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNASourceActivity](@generator_id INT,@input_id INT,@no_of_months INT)
RETURNS float AS  
BEGIN 
	return 1
END




