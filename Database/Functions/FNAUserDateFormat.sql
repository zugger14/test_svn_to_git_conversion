IF OBJECT_ID(N'FNAUserDateFormat', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAUserDateFormat]
GO 

-- This function converst a datatime to ADIHA format BASED on users region defintion. 
-- Inpute is SQL datatime...
-- Input is a SQl Date variable
-- select dbo.FNAUserDateFormat('2003-1-31 12:10:09') 
CREATE FUNCTION [dbo].[FNAUserDateFormat]
(
	@DATE           DATETIME,
	@user_login_id  VARCHAR(50)
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @FNAUserDateFormat AS VARCHAR(50)
	
	SET @FNAUserDateFormat = dbo.FNAGetGenericDate(@DATE, @user_login_id)
	
	RETURN(@FNAUserDateFormat)
END