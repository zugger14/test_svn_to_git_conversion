IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.FNAisLeapYear') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION dbo.FNAisLeapYear
GO 

CREATE FUNCTION dbo.FNAisLeapYear(@year INT)
RETURNS BIT
AS
BEGIN
	RETURN(SELECT CASE DATEPART(mm,DATEADD(dd,1,CAST((CAST(@year AS VARCHAR(4)) + '0228') AS DATETIME))) WHEN 2 THEN 1 ELSE 0 END)
END
GO


--SELECT dbo.FNAisLeapYear(1900) AS 'IsLeapYear?'
--SELECT dbo.FNAisLeapYear(2000) AS 'IsLeapYear?'
--SELECT dbo.FNAisLeapYear(2007) AS 'IsLeapYear?'
--SELECT dbo.FNAisLeapYear(2008) AS 'IsLeapYear?'