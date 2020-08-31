IF OBJECT_ID(N'[dbo].[FNAStripAnchor]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAStripAnchor]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAStripAnchor]
(
	@anchor VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @Start   INT
	DECLARE @End     INT
	DECLARE @Length  INT
	SET @Start = CHARINDEX('<a', @anchor)
	SET @End = CHARINDEX('>', @anchor, @Start)
	
	SET @Length = (@End - @Start) + 1
	
	WHILE @Start > 0
	      AND @End > 0
	      AND @Length > 0
	BEGIN
	    SET @anchor = STUFF(@anchor, @Start, @Length, '')
	    SET @Start = CHARINDEX('<a', @anchor)
	    SET @End = CHARINDEX('>', @anchor, @Start)
	    SET @Length = (@End - @Start) + 1
	END
	
	SET @Start = CHARINDEX('</a', @anchor)
	SET @End = CHARINDEX('>', @anchor, @Start)
	
	SET @Length = (@End - @Start) + 1
	
	WHILE @Start > 0
	      AND @End > 0
	      AND @Length > 0
	BEGIN
	    SET @anchor = STUFF(@anchor, @Start, @Length, '')
	    SET @Start = CHARINDEX('</a', @anchor)
	    SET @End = CHARINDEX('>', @anchor, @Start)
	    SET @Length = (@End - @Start) + 1
	END
	
	RETURN LTRIM(RTRIM(@anchor))
END
GO