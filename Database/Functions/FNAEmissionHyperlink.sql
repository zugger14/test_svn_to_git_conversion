/****** Object:  UserDefinedFunction [dbo].[FNAEmissionHyperlink]   */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEmissionHyperlink]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEmissionHyperlink]
/****** Object:  UserDefinedFunction [dbo].[FNAEmissionHyperlink]    Script Date: 07/23/2009 01:11:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAEmissionHyperlink]
(
 @no_of_param INT,
 @func_id  VARCHAR(50),
 @label   VARCHAR(500) = NULL,
 @arg1   VARCHAR(50) = NULL,
 @arg2   VARCHAR(50) = NULL
)
RETURNS VARCHAR(500) AS
BEGIN 
 --Below are the flags against the previously used functions.
 -- 2 : FNAHyperLinkText  -- 2 parameters
 -- 3 : FNAHyperLinkText2 -- 3 parameters
 -- 31 : FNAHyperLinkText3 -- 3 parameters case 1
 
 DECLARE @hyper_text VARCHAR(500)
 
 SELECT @hyper_text = 
  CASE @no_of_param 
   WHEN 2 THEN '<span style=cursor:hand onClick=emissionHyperlink('+@func_id+','+@arg1+',null)><font color=#0000ff><u>'+ @label +'</u></font></span>'
   WHEN 3 THEN '<span style=cursor:hand onClick=emissionHyperlink('+@func_id+','+@arg1+','+@arg2+')><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
   WHEN 31 THEN '<span style=cursor:hand onClick=parent.openHyperlinktest('+@func_id+','+@arg1+','''+@arg2+''')><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
   ELSE ''
  END 
 
 RETURN @hyper_text
END