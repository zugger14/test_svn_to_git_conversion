IF OBJECT_ID(N'FNAGetAbbreviationDef', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAGetAbbreviationDef]
 GO 

--This function returns the abbreviation defination 
CREATE FUNCTION [dbo].[FNAGetAbbreviationDef]
(
	@abbr CHAR(10)
)
RETURNS VARCHAR(100)
AS
BEGIN
	RETURN	
	CASE @abbr
	     WHEN 'y' THEN 'Yes'
	     WHEN 'n' THEN 'No'
	     WHEN 'c' THEN 'Call'
	     WHEN 'e' THEN 'European'
	     WHEN 'a' THEN 'American'
	     WHEN 'p' THEN 'Put'
	     ELSE @abbr
	END
END
  