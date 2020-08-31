
IF EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNAStripSpecificHTML]') AND TYPE IN(N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAStripSpecificHTML]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAStripSpecificHTML]
(
	@HTMLText VARCHAR(MAX),
	@exlude_start_tag VARCHAR(MAX),
	@exlude_end_tag VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @Start   INT
	DECLARE @End     INT
	DECLARE @Length  INT
	SET @Start = CHARINDEX(@exlude_start_tag, @HTMLText)
	SET @End = CHARINDEX(@exlude_end_tag, @HTMLText, CHARINDEX(@exlude_start_tag, @HTMLText))
	SET @Length = (@End - @Start) + 1
	WHILE @Start > 0
	      AND @End > 0
	      AND @Length > 0
	BEGIN
	    SET @HTMLText = STUFF(@HTMLText, @Start, @Length, '')
	    SET @Start = CHARINDEX(@exlude_start_tag, @HTMLText)
	    SET @End = CHARINDEX(@exlude_end_tag, @HTMLText, CHARINDEX(@exlude_start_tag, @HTMLText))
	    SET @Length = (@End - @Start) + 1
	END
	RETURN LTRIM(RTRIM(@HTMLText))
END