/****** Object:  UserDefinedFunction [dbo].[FNACharIndexCustom]    Script Date: 10/26/2009 14:06:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FNACharIndexMatchWholeWord]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNACharIndexMatchWholeWord]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================================
-- Create date: 2009-10-26 02:05PM
-- Description:	Returns the first position of the search string in the given string.
--				Search is similar to 'Match Whole Word Only'.
-- Params:
-- @searchString varchar(1000) - Search string
-- @fullString varchar(8000) - String to be search within
-- @startLocation int - Start location to being searching
-- ==========================================================================================
CREATE FUNCTION [dbo].[FNACharIndexMatchWholeWord]
(
	@searchString		VARCHAR(1000)
	, @fullString		VARCHAR(MAX)
	, @startLocation	INT = 0
)
RETURNS INT
AS

--DECLARE @searchString varchar(1000)
--DECLARE @fullString varchar(8000)
--DECLARE @startLocation int
--SET @fullString  = 'SELECT *                    
--                    FROm
--                    a where FROM can be define'
--SET @searchString = 'FROM'
--SET @startLocation = 0
BEGIN
	
	DECLARE @pos INT
	DECLARE @pos_min INT
	
	--CASE 1: <LineFeed> + @searchString + <CarriageReturn>
	SET @pos_min = CHARINDEX(CHAR(10) + @searchString + CHAR(13), @fullString, @startLocation)
	SET @pos = CHARINDEX(CHAR(10) + @searchString + ' ', @fullString, @startLocation)
	--PRINT cast(@pos AS VARCHAR) + ' - ' + cast(@pos_min AS VARCHAR)
	IF @pos > 0 AND ((@pos_min = 0) OR (@pos < @pos_min)) 
		SET @pos_min = @pos
		
	--CASE 2: <LineFeed> + @searchString + <Tab>
	SET @pos = CHARINDEX(CHAR(10) + @searchString + CHAR(9), @fullString, @startLocation)
	--PRINT cast(@pos AS VARCHAR) + ' - ' + cast(@pos_min AS VARCHAR)
	IF @pos > 0 AND ((@pos_min = 0) OR (@pos < @pos_min)) 
		SET @pos_min = @pos

	--CASE 3: <LineFeed> + @searchString + <Space>		
	SET @pos = CHARINDEX(CHAR(10) + @searchString + ' ', @fullString, @startLocation)
	--PRINT cast(@pos AS VARCHAR) + ' - ' + cast(@pos_min AS VARCHAR)
	IF @pos > 0 AND ((@pos_min = 0) OR (@pos < @pos_min)) 
		SET @pos_min = @pos
		
	--CASE 4: <Space> + @searchString + <CarriageReturn>
	SET @pos = CHARINDEX(' ' + @searchString + CHAR(13), @fullString, @startLocation)
	--PRINT cast(@pos AS VARCHAR) + ' - ' + cast(@pos_min AS VARCHAR)
	IF @pos > 0 AND ((@pos_min = 0) OR (@pos < @pos_min)) 
		SET @pos_min = @pos
	
	--CASE 5: <Space> + @searchString + <Tab>
	SET @pos = CHARINDEX(' ' + @searchString + CHAR(9), @fullString, @startLocation)
	--PRINT cast(@pos AS VARCHAR) + ' - ' + cast(@pos_min AS VARCHAR)
	IF @pos > 0 AND ((@pos_min = 0) OR (@pos < @pos_min)) 
		SET @pos_min = @pos
		
	--CASE 6: <Space> + @searchString + <Space>		
	SET @pos = CHARINDEX(' ' + @searchString + ' ', @fullString, @startLocation)
	--PRINT cast(@pos AS VARCHAR) + ' - ' + cast(@pos_min AS VARCHAR)
	IF @pos > 0 AND ((@pos_min = 0) OR (@pos < @pos_min)) 
		SET @pos_min = @pos
		
	--CASE 7: <Tab> + @searchString + <CarriageReturn>
	SET @pos = CHARINDEX(CHAR(9) + @searchString + CHAR(13), @fullString, @startLocation)
	--PRINT cast(@pos AS VARCHAR) + ' - ' + cast(@pos_min AS VARCHAR)
	IF @pos > 0 AND ((@pos_min = 0) OR (@pos < @pos_min)) 
		SET @pos_min = @pos
	
	--CASE 8: <Tab> + @searchString + <Tab>
	SET @pos = CHARINDEX(CHAR(9) + @searchString + CHAR(9), @fullString, @startLocation)
	--PRINT cast(@pos AS VARCHAR) + ' - ' + cast(@pos_min AS VARCHAR)
	IF @pos > 0 AND ((@pos_min = 0) OR (@pos < @pos_min)) 
		SET @pos_min = @pos
		
	--CASE 9: <Tab> + @searchString + <Space>
	SET @pos = CHARINDEX(CHAR(9) + @searchString + ' ', @fullString, @startLocation)
	--PRINT cast(@pos AS VARCHAR) + ' - ' + cast(@pos_min AS VARCHAR)
	IF @pos > 0 AND ((@pos_min = 0) OR (@pos < @pos_min)) 
		SET @pos_min = @pos
		
	--PRINT @pos_min
	--add +1 for the extra character we searched (<Tab>, <Space>, <CarriageReturn>, <LineFeed>)
	RETURN CASE WHEN @pos_min = 0 THEN 0 ELSE @pos_min + 1 END
END
