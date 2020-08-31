SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNAEncodeXML', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNAEncodeXML
GO

/**
	Encodes XML string escaping special characters so that it can be parsed

	Parameters
	@xml_string	:	XML string to encode
*/

CREATE FUNCTION [dbo].[FNAEncodeXML] 
(
	@xml_string NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @xml_string_modified NVARCHAR(MAX)
	
	SET @xml_string_modified = REPLACE(
									REPLACE(
										REPLACE(
											REPLACE(
												REPLACE(@xml_string, 
													'&', '&amp;'),
													'''', '&apos;'), 
													'"', '&quot;'), 
													'>', '&gt;'),
													'<', '&lt;')
	RETURN @xml_string_modified

END



GO
