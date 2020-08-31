/****** Object:  UserDefinedFunction [dbo].[FNAGetNewID]    Script Date: 03/19/2009 14:39:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetNewID]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetNewID]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetNewID]    Script Date: 03/19/2009 14:39:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Create date: 2008-09-11 10:50AM
-- Description:	Returns unique identifier (so nondeterministic function) with hypen(-)
--				replaced with underscore(_)
-- =============================================
CREATE FUNCTION [dbo].[FNAGetNewID]()
RETURNS varchar(50)
AS
BEGIN
	
	RETURN(REPLACE((SELECT new_id FROM vwNewID), '-', '_'))

END
