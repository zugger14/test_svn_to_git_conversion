/****** Object:  UserDefinedFunction [dbo].[FNAIntStopMnth]    Script Date: 05/02/2011 11:36:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAIntStopMnth]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAIntStopMnth]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAIntStopMnth]    Script Date: 05/02/2011 11:36:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[FNAIntStopMnth] ()
RETURNS float AS  
BEGIN 
	return 1
END









