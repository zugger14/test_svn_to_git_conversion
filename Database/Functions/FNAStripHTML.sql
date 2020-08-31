IF OBJECT_ID('[dbo].[FNAStripHTML]') IS NOT NULL
	DROP FUNCTION  [dbo].[FNAStripHTML]
GO
CREATE FUNCTION [dbo].[FNAStripHTML]
(
	@HTMLText VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @Start   INT
	DECLARE @End     INT
	DECLARE @Length  INT
	SET @Start = CHARINDEX('<', @HTMLText)
	SET @End = CHARINDEX('>', @HTMLText, CHARINDEX('<', @HTMLText))
	SET @Length = (@End - @Start) + 1
	WHILE @Start > 0
	      AND @End > 0
	      AND @Length > 0
	BEGIN
	    SET @HTMLText = STUFF(@HTMLText, @Start, @Length, '')
	    SET @Start = CHARINDEX('<', @HTMLText)
	    SET @End = CHARINDEX('>', @HTMLText, CHARINDEX('<', @HTMLText))
	    SET @Length = (@End - @Start) + 1
	END
	RETURN LTRIM(RTRIM(@HTMLText))
END
GO

--Test above FUNCTION LIKE this :
--SELECT dbo.FNAStripHTML('<b>UDF at someurl.com </b><br><br><a href="http://www.someurl.com">someurl.com</a>')