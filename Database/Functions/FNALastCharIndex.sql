IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNALastCharIndex]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNALastCharIndex]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ===========================================================================================
-- Create date: 2011-04-11
-- Description:	Returns the last occurance of the search string in the given string.
-- Params:
-- @searchString varchar(1000) - Search string
-- @fullString varchar(8000) - String to be search within
-- ==========================================================================================
CREATE FUNCTION [dbo].[FNALastCharIndex]
(
	@searchString		varchar(1000)
	, @fullString		varchar(8000)
)
RETURNS int
AS

BEGIN
	
	DECLARE @match_pos INT
--	DECLARE @index INT
--	
--	SET @match_pos = 0
--	SET @index = -1
--	
--	IF @startLocation = 0
--		SET @startLocation = DATALENGTH(@fullString)
--	
--	WHILE @index <> 0 AND @index < @startLocation
--	BEGIN
--		SET @index = CHARINDEX(@searchString, @fullString, @index)
--		IF @index > 0 AND @index < @startLocation
--			SET @match_pos = @index
--	END
	
	SET @match_pos = CHARINDEX(REVERSE(@searchString), REVERSE(@fullString))
	
	RETURN CASE WHEN @match_pos > 0 THEN DATALENGTH(@fullString) - @match_pos + 1
		ELSE 0 END
END
