IF OBJECT_ID('FNAGetDayWiseDate') IS NOT NULL
DROP FUNCTION [dbo].[FNAGetDayWiseDate]
go

create FUNCTION [dbo].[FNAGetDayWiseDate](
    @from_date DATETIME
  , @to_date DATETIME = null 
) RETURNS @List TABLE (day_date DATETIME,weekdays TINYINT,no_of_days_in_month TINYINT)

BEGIN
--SELECT * FROM [FNAGetDayWiseDate]('2010-01-01','2010-02-28')

--declare    @from_date DATETIME  , @to_date DATETIME 
-- select @from_date ='2010-01-01'  , @to_date=NULL
-- SELECT dateadd(month,1,convert(datetime,convert(varchar(8),@from_date,120)+'01',120)-1)
	 set @to_date =ISNULL(@to_date, dateadd(month,1,convert(datetime,convert(varchar(8),@from_date,120)+'01',120))-1)
	
	;WITH ct_day_date (day_date,weekdays,no_of_days_in_month) AS 
	(
	SELECT @from_date, DATEPART(dw,@from_date) ,day(dateadd(month,1,convert(datetime,convert(varchar(8),@from_date,120)+'01',120)-1))
		UNION ALL 
	SELECT DATEADD(day,1,day_date),DATEPART(dw,DATEADD(day,1,day_date)) ,day(dateadd(month,1,convert(datetime,convert(varchar(8),DATEADD(day,1,day_date),120)+'01',120)-1)) FROM ct_day_date WHERE day_date<@to_date

	)

	INSERT INTO @List 
	SELECT * FROM ct_day_date
	OPTION(MAXRECURSION 0)
RETURN
END


