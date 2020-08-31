SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNADecodeXML', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNADecodeXML
GO

/**
	Decodes XML string back to original string

	Parameters
	@xml_string	:	XML string to decode
*/

CREATE FUNCTION dbo.FNADecodeXML 
(
	@xml_string NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @xml_string_modified NVARCHAR(MAX)
	
	SET @xml_string_modified = REPLACE(REPLACE(
									REPLACE(
										REPLACE(
											REPLACE(
												REPLACE(@xml_string, 
													'&amp;', '&'),
													'&apos;', ''''), 
													'&quot;', '"'), 
													'&gt;', '>'),
													'&lt;', '<'),
													'&#039;', '''')
	RETURN @xml_string_modified

END



GO
