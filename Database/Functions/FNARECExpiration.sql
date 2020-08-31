/****** Object:  UserDefinedFunction [dbo].[FNARECExpiration]    Script Date: 08/20/2009 12:31:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARECExpiration]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARECExpiration]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARECExpiration]    Script Date: 08/20/2009 12:31:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--SELECT DBO.FNARECExpiration('2004-2-28')

-- This function returns expiration date for REC deals based on duration in  years
-- Inpute is duration in years and REC generation date

CREATE FUNCTION [dbo].[FNARECExpiration](@years int, @term datetime)
RETURNS Varchar(50)
AS
BEGIN
	Declare @FNARECExpiration As Varchar(50)


	Set @FNARECExpiration = cast ((year(@term) + @years - 1) as varchar) + '-12-31'

	
	RETURN(@FNARECExpiration)
END















