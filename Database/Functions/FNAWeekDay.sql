/****** Object:  UserDefinedFunction [dbo].[FNAWeekDay]    Script Date: 07/23/2009 01:07:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAWeekDay]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAWeekDay]
/****** Object:  UserDefinedFunction [dbo].[FNAWeekDay]    Script Date: 07/23/2009 01:07:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAWeekDay]()

RETURNS INT AS
BEGIN

	return 1
END



