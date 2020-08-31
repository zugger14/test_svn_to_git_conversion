IF OBJECT_ID(N'FNAGetSQLStandardDate', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAGetSQLStandardDate]
GO 

--SELECT DBO.FNAGetSQLStandardDate('2004-2-28')
--SELECT convert(datetime, '2004-2-28', 102)
-- This function converst a datatime to ADIHA format 'yyyy-mm-dd'
-- Inpute is SQL datatime...
-- Input is a SQl Date variable
CREATE FUNCTION [dbo].[FNAGetSQLStandardDate]
(
	@DATE DATETIME
)
RETURNS Varchar(50)
AS
BEGIN
	Declare @FNAGetSQLStandardDate As Varchar(50)


	DECLARE @monthI Int
	DECLARE @dayI Int
	
	
	SET @monthI = MONTH(@DATE)
	SET @dayI = DAY(@DATE)

	Set @FNAGetSQLStandardDate = 	CAST(Year(@DATE) As Varchar)+
					'-'+ CASE WHEN (@monthI < 10) then '0' else '' end + 
						CAST(@monthI As Varchar) +
					'-'+ CASE WHEN (@dayI < 10) then '0' else '' end + 
						CAST(@dayI As Varchar)
	
	RETURN(@FNAGetSQLStandardDate)
END














