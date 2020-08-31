SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNABuildNameValueXML', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNABuildNameValueXML
GO

/**
	Builds standard name:value collection in xml format. Wraps the collection with <Root> element if it is not already available

	Parameters
	@xml_string	:	XML string to append.
	@name	:	XML Node
	@value	:	XML Node value
*/

CREATE FUNCTION dbo.FNABuildNameValueXML 
(
	@xml_string NVARCHAR(MAX),
	@name NVARCHAR(MAX),
	@value NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	
	DECLARE @xml_string_modified NVARCHAR(MAX)
	DECLARE @contains_root bit
	
	IF CHARINDEX('<Root>', @xml_string) > 0
	BEGIN
		SET @xml_string_modified = STUFF(@xml_string, CHARINDEX('</Root>', @xml_string), 100, '')
		SET @contains_root = 1
	END
	ELSE
	BEGIN
		SET @xml_string_modified = @xml_string
		SET @contains_root = 0
	END
	
	SET @xml_string_modified = @xml_string_modified + '<PSRecordset name="' + dbo.FNAEncodeXML(@name) + '" value="' + + dbo.FNAEncodeXML(@value) + '" />'
	
	RETURN (CASE @contains_root WHEN 0 THEN '<Root>' + @xml_string_modified + '</Root>'
									ELSE @xml_string_modified + '</Root>' END)
		
END




GO
