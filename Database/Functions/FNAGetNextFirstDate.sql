IF OBJECT_ID('dbo.FNAGetNextFirstDate') IS NOT NULL
DROP FUNCTION dbo.FNAGetNextFirstDate
go
CREATE FUNCTION dbo.FNAGetNextFirstDate(@maturity_date datetime,@granularity INT)
RETURNS datetime AS  
BEGIN 
--alter proc dbo.FNAGetNextFirstDate_s
--@maturity_date datetime,
--@granularity INT
--as	

		--DECLARE @maturity_date datetime,@granularity INT
		--SELECT @maturity_date='2007-04-01',@granularity=991
		DECLARE @ret_value  DATETIME
		DECLARE @day INT,@year INT,@month INT
		IF @granularity = 980 --Monthly
		BEGIN			
			SELECT @ret_value=CAST(CONVERT(VARCHAR(7),dateadd(m,CASE WHEN DAY(@maturity_date)=1 THEN 0 ELSE 1 end,@maturity_date),120)+'-01' AS DATETIME)
		END
		ELSE IF @granularity IN (981,982,987,989) --Daily, 15min, 30min, hourly
		BEGIN
			SELECT 	@ret_value = @maturity_date --DATEADD(dd,1,@maturity_date)
		END
		ELSE IF @granularity = 993 --Yearly
		BEGIN
			SET @ret_value=CAST(CONVERT(VARCHAR(4),DATEADD(YEAR,CASE WHEN DAY(@maturity_date)=1 AND MONTH(@maturity_date)=1 THEN 0 ELSE 1 end,@maturity_date),120)+'-01-01' AS DATETIME)
		END
		ELSE IF @granularity = 991 --Quaterly
		BEGIN
			SELECT 	@maturity_date = DATEADD(mm,CASE WHEN day(@maturity_date)=1 AND month(@maturity_date) IN (1,4,7,10) THEN 0 ELSE 3 end,@maturity_date)	
			SELECT  @year  = DATEPART(yy,@maturity_date)
			SELECT  @month = DATEPART(mm,@maturity_date)
			SELECT  @month = CASE WHEN @month <4 THEN 1 
								  WHEN @month  between 4 and 6 THEN 4 
								  WHEN @month  between 7 and 9 THEN 7 
								  ELSE 10 
							 END
			SELECT  @ret_value = CAST(CAST(@year AS VARCHAR)+'-'+CAST(@month AS varchar)+'-01' AS DATETIME)
		END
		ELSE IF @granularity = 992 --Semi-Annually
		BEGIN
			SELECT 	@maturity_date = DATEADD(mm,CASE WHEN day(@maturity_date)=1 AND MONTH(@maturity_date) IN (1,7) THEN 0 ELSE 6 END,@maturity_date)			
			SELECT  @month = DATEPART(mm,@maturity_date)
			SELECT  @year  = DATEPART(yy,@maturity_date)
			SELECT  @month = CASE WHEN @month <7 THEN 1   ELSE 7 END
			SELECT  @ret_value = CAST(CAST(@year AS VARCHAR)+'-0'+CAST(@month AS varchar)+'-01' AS DATETIME)
		END
		ELSE IF @granularity = 990 -- Weekly
		BEGIN								
			SELECT  @ret_value = DATEADD(dd,8-DATEPART(dw,@maturity_date),@maturity_date)
			--SELECT  @ret_value = DATEADD(dd,8-CASE DATEPART(dw,@maturity_date) WHEN 1 THEN 8 ELSE DATEPART(dw,@maturity_date) END,@maturity_date)			
		END
	RETURN @ret_value
--	SELECT 	 @ret_value

END
