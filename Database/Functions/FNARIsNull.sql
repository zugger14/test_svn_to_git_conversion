IF OBJECT_ID(N'FNARIsNull', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARIsNull]
 GO 

CREATE FUNCTION [dbo].[FNARIsNull] (
	@arg1  VARCHAR(5000),
	@arg2  VARCHAR(5000)
)
RETURNS VARCHAR(5000)
AS
BEGIN
	DECLARE @return_val AS VARCHAR(5000)
	
	IF NULLIF(NULLIF(LTRIM(RTRIM(@arg1)),''),'NULL') IS NULL
	    SET @return_val = @arg2
	ELSE
		SET @return_val = @arg1
	
	RETURN @return_val
END