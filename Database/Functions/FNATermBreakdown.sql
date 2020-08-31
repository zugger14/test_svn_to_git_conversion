IF OBJECT_ID('[dbo].[FNATermBreakdown]','tf') IS NOT NULL 
DROP FUNCTION [dbo].[FNATermBreakdown] 
GO 

--SELECT * FROM [FNATermBreakdown] ('w','2015-09-09','2015-10-10')

CREATE FUNCTION [dbo].[FNATermBreakdown] 
(
	@frequency CHAR(1),
	@term_start DATETIME,
	@term_end DATETIME
)
returns @tt table(term_start DATETIME, term_end DATETIME)
AS
BEGIN
--DECLARE @frequency CHAR(1),
--@term_start DATETIME,
--@term_end DATETIME
--DECLARE @tt table(term_start DATETIME, term_end DATETIME)

--SET @frequency = 'h'
--SET @term_start = '2015-01-01'
--SET @term_end = '2015-01-01'

--SELECT dbo.FNAGetTermEndDate('f','2015-01-09 23:30:00',0)
--SELECT dbo.FNAGetTermEndDate('f','2015-09-09',95)
	DECLARE 
			@volume FLOAT,
			@st VARCHAR(8000)

	DECLARE @term_end_frequency CHAR(1)
	DECLARE @offset INT
	--SET @offset =  CASE
	--					--WHEN @frequency = 'f' THEN 95	--96*15 = 1440(total minute in 24 hours)
	--					WHEN @frequency = 't' THEN 47		
	--					ELSE 0 END 
	SET @term_end_frequency = @frequency --CASE WHEN @frequency = 'h' THEN 'd' ELSE @frequency END 
	
	
	;WITH term_lag (term_start,term_end) AS 
		(
			SELECT	@term_start,dbo.FNAGetTermEndDate(@frequency,@term_start,0)	-- DATEADD(dd,-1,DATEADD(mm, DATEDIFF(m,0,@term_start)+1,0))
				
				UNION ALL
			
			SELECT	
					dbo.FNAGetTermStartDate(@frequency,term_start,1),			-- DATEADD(month,1 ,dbo.FNAGetContractMonth(term_start)), 
					 dbo.FNAGetTermEndDate(@frequency,term_start,1)			-- DATEADD(dd,-1,DATEADD(mm, DATEDIFF(m,0,term_start)+2,0)) 
			FROM term_lag 
			WHERE 	
					dbo.FNAGetTermEndDate(@frequency,term_start,1) < dbo.FNAGetTermEndDate(@term_end_frequency,@term_end,@offset)	
				
		)
		insert into @tt 
		SELECT 
			term_start,term_end
		FROM term_lag
		option (maxrecursion 0)
		
		
		UPDATE tt
		SET term_end = @term_end 
		FROM @tt tt
		INNER JOIN (SELECT MAX(term_start) term_start FROM @tt) [mx]
		ON mx.term_start = tt.term_start 

		
	--Select * FROM @tt
	
	
RETURN 

END 