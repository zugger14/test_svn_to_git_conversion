IF OBJECT_ID(N'dbo.FNAFlattenedJSON') IS NOT NULL
    DROP FUNCTION dbo.FNAFlattenedJSON
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2014-12-31
-- Description: Parse xml to json.
 
-- Params:
-- @xml_result CHAR(1)        - XML resultset
-- 
-- ===============================================================================================================

CREATE FUNCTION dbo.FNAFlattenedJSON (
	@xml_result XML
)

RETURNS NVARCHAR(MAX)
WITH 

 EXECUTE AS CALLER
AS
BEGIN

	DECLARE @json_version     NVARCHAR(MAX),
	        @row_count        INT
	
	SELECT @json_version = '',
	       @row_count = COUNT(*)
	FROM   @xml_result.nodes('/root/*') x(a)
	
	SELECT @json_version = @json_version +
	       STUFF(
	           (
	               SELECT json_string
	               FROM   (
	                          SELECT ', {' +
	                                 STUFF(
	                                     (
	                                         SELECT ',"' + COALESCE(b.c.value('local-name(.)', 'NVARCHAR(255)'), '')
	                                                + '":'+ CASE WHEN COALESCE(b.c.value('local-name(.)', 'NVARCHAR(255)'), '') IN ('list','options','userdata', 'connector', 'serverFiltering') THEN '' ELSE '"' END + 
													REPLACE(
															--escape single quote
														REPLACE(
															--escape tab properly within a value
															REPLACE(
																--escape return properly
																REPLACE(
																	--linefeed must be escaped
																	REPLACE(
																		--backslash too
																		REPLACE(
																			COALESCE(b.c.value('text()[1]', 'NVARCHAR(MAX)'), ''),	--forwardslash
																			'\',
																			'\\'
																		),
																		'/',
																		'\/'
																	),
																	CHAR(10),
																	'\n'
																),
																CHAR(13),
																'\r'
															),
															CHAR(09),
															'\t'
														),
														'\\"',
														'\"'
													)  

	                                                +  CASE WHEN COALESCE(b.c.value('local-name(.)', 'NVARCHAR(255)'), '') IN ('list','options','userdata', 'connector', 'serverFiltering') THEN '' ELSE '"' END
	                                         FROM   x.a.nodes('*') b(c) 
	                                                FOR XML PATH(''),
	                                                TYPE
	                                     ).value('(./text())[1]', 'NVARCHAR(MAX)'),
	                                     1,
	                                     1,
	                                     ''
	                                 ) + '}'
	                          FROM   @xml_result.nodes('/root/*') x(a)
	                      ) JSON(json_string)
	                      FOR XML PATH(''),
	                      TYPE
	           ).value('.', 'NVARCHAR(MAX)'),
	           1,
	           1,
	           ''
	       )
	
	IF @row_count > 1
	    RETURN '[' + RTRIM(LTRIM(@json_version)) + ' ]'
	
	RETURN RTRIM(LTRIM(@json_version))
END