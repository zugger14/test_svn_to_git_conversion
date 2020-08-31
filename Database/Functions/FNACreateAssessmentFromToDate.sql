IF OBJECT_ID(N'FNACreateAssessmentFromToDate', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNACreateAssessmentFromToDate]
 GO 



-- select dbo.FNACreateAssessmentFromToDate ('jan', 'may', 0, 0,'1/31/2003', 1)
-- select dbo.FNACreateAssessmentFromToDate ('jan', 'may', 0, 0,'1/31/2003', 2)  
CREATE FUNCTION [dbo].[FNACreateAssessmentFromToDate]
(
	@stripFromMonth          VARCHAR(10),
	@stripToMonth            VARCHAR(10),
	@rollForwardYearOverlap  INT,
	@stripYearOverlap        INT,
	@runDate                 DATETIME,
	@type                    INT
)
RETURNS VARCHAR(50)
AS
	
BEGIN

-- DECLARE @stripFromMonth varchar(10)
-- DECLARE @stripToMonth varchar(10)
-- DECLARE @rollForwardYearOverlap int
-- DECLARE @stripYearOverlap int
-- DECLARE @runDate DATETIME
-- DECLARE @type int   
--@type 1 means get from  date, 2 means get  to date

Declare @FNACreateAssessmentFromToDate As Varchar(50)
DECLARE @fromMonth int
DECLARE @toMonth int
DECLARE @startYear int
-- 
-- SET @runDate  = '1/31/2003'
-- SET @type = 0
-- SET @rollForwardYearOverlap = 0
-- SET @stripYearOverlap = 0

-- SET @stripFromMonth = lower('jan')
-- SET @stripToMonth = lower('apr')

SET @fromMonth = dbo.FNAGetMonthAsInt(@stripFromMonth)
SET @toMonth = dbo.FNAGetMonthAsInt(@stripToMonth)

--select @fromMonth, @toMonth

SET @startYear = datepart(yy, @runDate) + @rollForwardYearOverlap


If @fromMonth <= datepart(mm, @runDate) 
	set @startYear = @startYear + 1

If @type = 1
	SET @FNACreateAssessmentFromToDate =  CAST(@startYear AS varchar) + '-' + CAST(@fromMonth AS VARCHAR) + '-01'
Else	
	SET @FNACreateAssessmentFromToDate = CAST((@startYear + @stripYearOverlap) as varchar) + '-' + CAST(@toMonth AS VARCHAR) + '-01' 

	RETURN (@FNACreateAssessmentFromToDate)
END 



