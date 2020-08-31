/****** Object:  UserDefinedFunction [dbo].[FNAGetProxy_term]    Script Date: 05/01/2011 14:41:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetProxy_term]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetProxy_term]
GO

CREATE FUNCTION [dbo].[FNAGetProxy_term] 
(
	@contract_id INT,
	@granularity INT,
	@term_start DATETIME,
	@term_end DATETIME
)
returns @tt table(commodity_id INT,term_start DATETIME,[hour] INT,proxy_term_start DATETIME,proxy_hour INT)
AS
----/*
--	DECLARE @contract_id INT
--	DECLARE @granularity INT
--	DECLARE @term_start DATETIME
--	DECLARE @term_end DATETIME

--	SET @granularity=982
--	SET @term_start='2011-01-01'
--	SET @term_end='2011-01-31'

--*/
BEGIN


	DECLARE @frequency CHAR(1)
	DECLARE 
			@volume FLOAT,
			@st VARCHAR(8000),
			@commodity_id INT
			
	SET @frequency=CASE @granularity WHEN 980 THEN 'm' WHEN 981 THEN 'd' WHEN 982 THEN 'h' END		
	DECLARE @term_end_frequency CHAR(1)

	SET @commodity_id=-1
	SET @term_end_frequency = CASE WHEN @frequency = 'h' THEN 'd' ELSE @frequency END 
	DECLARE @start_hour INT,@end_hour INT,@c_start_day INT,@c_end_day INT
	
	SET @c_start_day=0
	SET @c_end_day=0
	SET @start_hour=6
	SET @end_hour=6
	
	IF @contract_id IS NOT NULL
		SELECT 
			@c_start_day=ISNULL(billing_from_date,0),
			@c_end_day=ISNULL(billing_to_date,0),
			@start_hour=ISNULL(billing_from_hour,0),
			@end_hour=ISNULL(billing_to_hour,24) 
			
		FROM 
			dbo.contract_group WHERE contract_id=@contract_id 
	
	IF @c_start_day>0
		SET  @term_start=CAST(YEAR(@term_start) AS VARCHAR)+'-'+CAST(MONTH(@term_start) AS VARCHAR)+'-'+RIGHT(CAST(@c_start_day AS VARCHAR),2)
		
	IF @c_end_day>0
		SET  @term_end=CAST(CASE WHEN MONTH(@term_start)=12 THEN 1 ELSE 0 END+YEAR(@term_start) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(MONTH,1,@term_start)) AS VARCHAR)+'-'+RIGHT(CAST(@c_end_day-1 AS VARCHAR),2)
	
	;WITH term_lag (term_start,term_end) AS 
		(
			SELECT	@term_start,dbo.FNAGetTermEndDate(@frequency,DATEADD(hour,@start_hour,@term_start),0)	
				
				UNION ALL
			
			SELECT	
					dbo.FNAGetTermStartDate(@frequency,term_start,1),			
					dbo.FNAGetTermEndDate(@frequency,DATEADD(hour,@start_hour,term_start),1)			
			FROM term_lag 
			WHERE 	
					dbo.FNAGetTermEndDate('h',term_start,@start_hour)	 < dbo.FNAGetTermEndDate('h',DATEADD(DAY,1,@term_end),@end_hour-1)	
		)
		
		
		INSERT INTO @tt 
		SELECT 
			@commodity_id,
			CONVERT(VARCHAR(10),term_start,120),
			DATEPART(hour,term_start)+1,
			CONVERT(VARCHAR(10),term_end,120),
			DATEPART(hour,term_end)+1
		FROM 
			term_lag			
		option (maxrecursion 0)
	

RETURN 

END 