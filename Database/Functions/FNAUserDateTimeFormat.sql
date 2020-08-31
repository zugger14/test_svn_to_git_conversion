IF OBJECT_ID(N'FNAUserDateTimeFormat', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAUserDateTimeFormat]
GO 


-- select dbo.FNAUserDateTimeFormat('1/30/2003 23:1:31', 1)
-- This function converst a datatime to ADIHA DateTime format 
-- Inpute is SQL datatime...
-- Input is a SQL Date variable
-- type = 1    Jan 2, 1967 hh:mm:ss
-- type = 2    1/2/1967 hh:mm:ss
CREATE FUNCTION [dbo].[FNAUserDateTimeFormat]
(
	@DATE           DATETIME,
	@type           INT,
	@user_login_id  VARCHAR(50)
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @FNAUserDateTimeFormat AS VARCHAR(50)
	
	SET @FNAUserDateTimeFormat = dbo.FNAGetGenericDate(@DATE, @user_login_id) + 
	    ' ' +
	    RIGHT('0' + CAST(DATEPART(hh, @DATE) AS VARCHAR), 2) + ':' +
	    RIGHT('0' + CAST(DATEPART(mi, @DATE) AS VARCHAR), 2) + ':' +
	    RIGHT('0' + CAST(DATEPART(ss, @DATE) AS VARCHAR), 2)
	
	RETURN(@FNAUserDateTimeFormat)
END