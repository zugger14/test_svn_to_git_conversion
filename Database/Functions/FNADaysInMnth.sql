/****** Object:  UserDefinedFunction [dbo].[FNADaysInMnth]    Script Date: 12/07/2010 16:46:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNADaysInMnth]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNADaysInMnth]
/****** Object:  UserDefinedFunction [dbo].[FNADaysInMnth]    Script Date: 12/07/2010 16:46:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNADaysInMnth] ()
RETURNS INT
AS
BEGIN

    RETURN 1

END

