/****** Object:  UserDefinedFunction [dbo].[FNACVD]    Script Date: 05/02/2011 11:15:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAPeakHours]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAPeakHours]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAPeakHours]    Script Date: 05/02/2011 11:15:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAPeakHours] (@block_definition INT,@block_type INT)
RETURNS float AS  
BEGIN 
	return 1
END


