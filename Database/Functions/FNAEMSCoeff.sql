/****** Object:  UserDefinedFunction [dbo].[FNAEMSCoeff]    Script Date: 08/20/2009 12:25:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMSCoeff]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSCoeff]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAEMSCoeff]    Script Date: 08/20/2009 12:25:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAEMSCoeff] (@source_input_id as int,@conversion_type as int,@conv_source as int)
RETURNS float AS  
BEGIN 
	
	RETURN 1
END



