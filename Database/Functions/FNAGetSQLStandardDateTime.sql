IF OBJECT_ID(N'FNAGetSQLStandardDateTime', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAGetSQLStandardDateTime]
GO 

--SELECT DBO.FNAGetSQLStandardDateTime('2004-2-28 01:00:00')
--SELECT DBO.FNAGetSQLStandardDateTime('2004-2-28')
--SELECT convert(datetime, '2004-2-28', 102)
-- This function converst a datatime to ADIHA format 'yyyy-mm-dd'
-- Inpute is SQL datatime...
-- Input is a SQl Date variable
CREATE FUNCTION [dbo].[FNAGetSQLStandardDateTime]
(
	@DATE DATETIME
)
RETURNS Varchar(50)
AS
BEGIN
	Declare @FNAGetSQLStandardDateTime As Varchar(50)


	DECLARE @monthI Int
	DECLARE @dayI Int
	DECLARE @hh Int
	DECLARE @mm Int
	DECLARE @ss Int	
	
	SET @monthI = MONTH(@DATE)
	SET @dayI = DAY(@DATE)

	SET @hh = datepart(hh, @DATE)
	SET @mm = datepart(mi, @DATE)
	SET @ss = datepart(ss, @DATE)

	Set @FNAGetSQLStandardDateTime = 	CAST(Year(@DATE) As Varchar)+
					'-'+ CASE WHEN (@monthI < 10) then '0' else '' end + 
						CAST(@monthI As Varchar) +
					'-'+ CASE WHEN (@dayI < 10) then '0' else '' end + 
						CAST(@dayI As Varchar) + 

					case WHEN (@hh > 0) then ' ' + 
						case when (@hh < 10) then '0' else '' end + cast(@hh as varchar) 
					else ' 00' end + 
			
					case WHEN (@mm > 0) then ':' + 
						case when (@mm < 10) then '0' else '' end + cast(@mm as varchar)  
					else ':00' end +
			
					case WHEN (@ss > 0) then ':' + 
						case when (@ss < 10) then '0' else '' end + cast(@ss as varchar) 
					else ':00' end 
	
	RETURN(@FNAGetSQLStandardDateTime)
END


















