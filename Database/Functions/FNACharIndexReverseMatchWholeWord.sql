/****** Object:  UserDefinedFunction [dbo].[FNACharIndexCustom]    Script Date: 10/26/2009 14:06:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNACharIndexReverseMatchWholeWord]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNACharIndexReverseMatchWholeWord]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================
-- Create date: 2010-02-22 03:05PM
-- Description:	Returns the last occurance of the search string in the given string.
--				Search is similar to 'Match Whole Word Only In Reverse Direction'.
-- Params:
-- @searchString varchar(1000) - Search string
-- @fullString varchar(8000) - String to be search within
-- @startLocation int - Start location to being searching
-- ==========================================================================================
CREATE FUNCTION [dbo].[FNACharIndexReverseMatchWholeWord]
(
	@searchString		varchar(1000)
	, @fullString		varchar(8000)
	, @startLocation	int = 0
)
RETURNS int
AS

BEGIN
	
	DECLARE @match_pos INT
	DECLARE @index INT
	
	SET @match_pos = 0
	SET @index = -1
	
	IF @startLocation = 0
		SET @startLocation = DATALENGTH(@fullString)
	
	WHILE @index <> 0 AND @index < @startLocation
	BEGIN
		SET @index = dbo.FNACharIndexMatchWholeWord(@searchString, @fullString, @index)
		IF @index > 0 AND @index < @startLocation
			SET @match_pos = @index
	END
	
	RETURN @match_pos

END
