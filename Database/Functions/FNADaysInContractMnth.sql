/****** Object:  UserDefinedFunction [dbo].[FNADaysInContractMnth]    Script Date: 12/07/2010 16:46:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNADaysInContractMnth]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNADaysInContractMnth]
/****** Object:  UserDefinedFunction [dbo].[FNADaysInContractMnth]    Script Date: 12/07/2010 16:46:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNADaysInContractMnth] ()
RETURNS INT
AS
BEGIN

    RETURN 1

END

