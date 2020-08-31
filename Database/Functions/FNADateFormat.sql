/****** Object:  UserDefinedFunction [dbo].[FNADateFormat]    Script Date: 11/07/2009 16:37:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNADateFormat]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNADateFormat]
/****** Object:  UserDefinedFunction [dbo].[FNADateFormat]    Script Date: 11/07/2009 16:35:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 



-- This function converst a datatime to ADIHA format BASED on users region defintion. 
-- Inpute is SQL datatime...
-- Input is a SQl Date variable
-- select dbo.FNADateFormat('2003-1-31 12:10:09') 
CREATE FUNCTION [dbo].[FNADateFormat](@DATE datetime)
RETURNS Varchar(50)
AS
BEGIN
	Declare @FNADateFormat As Varchar(50)

	IF  @DATE=''
		SET @FNADateFormat=''
	ELSE
		Set @FNADateFormat = dbo.FNAGetGenericDate(@DATE, dbo.FNADBUser())
	
	RETURN(@FNADateFormat)
END



