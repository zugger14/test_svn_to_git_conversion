SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNAURLDecode', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNAURLDecode
GO

/**
	Decodes special characters. Works similar to javascript unescape function

	Parameters
	@url	:	String value which contains special characters to decode
*/

CREATE FUNCTION [dbo].[FNAURLDecode](@url NVARCHAR(MAX))
	RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @decoded_url NVARCHAR(MAX)
    SET @decoded_url =
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(	
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(	
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(
						REPLACE(
    					REPLACE(
						REPLACE(@url, '%20', ' '),
										'%21', '!'),
										'%23', '#'),
										'%24', '$'),
										'%25', '%'),
										'%5E', '^'),
										'%26', '&'),
										'%28', '('),
										'%29', ')'),
										'%3D', '='),
										'%3A', ':'),
										'%3B', ';'),
										'%22', '"'),
										'%27', ''''),
										'%5C', '\'),
										'%3F', '?'),
										'%3C', '<'),
										'%3E', '>'),
										'%7E', '~'),
										'%5B', '['),
										'%5D', ']'),
										'%7B', '{'),
										'%7D', '}'),
										'%60', '`'),
										'%2C', ','),
										'%7C', '|'),
										'%2F', '/'),
										'%0A', '')
    RETURN @decoded_url  
END



GO
