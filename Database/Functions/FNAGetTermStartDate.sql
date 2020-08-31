/*
SELECT dbo.FNAGetTermStartDate('m','2009-12-04',1)
SELECT dbo.FNAGetTermStartDate('q','2009-12-04',1)
SELECT dbo.FNAGetTermStartDate('s','2009-12-04',1)
SELECT dbo.FNAGetTermStartDate('a','2009-12-04',1)

SELECT dbo.FNAGetTermStartDate('h','2009-12-04 1:2:3.456',0)


SELECT dbo.FNAGetTermStartDate('d','2009-12-04',1)
SELECT dbo.FNAGetTermStartDate('f','2009-12-04',1)
SELECT dbo.FNAGetTermStartDate('w','2009-12-04',1)

*/
IF OBJECT_ID('[dbo].[FNAGetTermStartDate]','fn') IS NOT NULL 
DROP FUNCTION [dbo].[FNAGetTermStartDate]
GO

CREATE FUNCTION [dbo].[FNAGetTermStartDate](
	@term_frequency CHAR(1),
	@date DATETIME,
	@offset INT 
)
RETURNS DATETIME 
AS
BEGIN
	SET @offset=ISNULL(@offset,1)
	DECLARE @term_start DATETIME 
	DECLARE @mult INT 
	
	IF	@term_frequency = 'h' 
	BEGIN
		SET @mult = 1
		SET @term_start = DATEADD(hh, DATEDIFF(hh,0,@date)+(1+@offset)*@mult-1,0)
	END
	
	ELSE IF @term_frequency = 'd'
	BEGIN
		SET @mult = 1
		SET @term_start = DATEADD(dd, DATEDIFF(dd,0,@date)+(1+@offset)*@mult-1,0)
	END
	ELSE IF @term_frequency = 'w'
	BEGIN
		SET @mult = 1
		SET @term_start = DATEADD(dd,-1,DATEADD(ww, DATEDIFF(ww,0,@date)+(1+@offset)*@mult-1,0))
	END
	ELSE IF @term_frequency = 'f'
	BEGIN

		SET @term_start = DATEADD(mi,@offset*15,@date)
	END
		ELSE IF @term_frequency = 'r'
	BEGIN
		SET @term_start = DATEADD(mi,@offset*10,@date)
	END

	ELSE IF @term_frequency = 't'
	BEGIN

		SET @term_start = DATEADD(mi,@offset*30,@date)
	END
	ELSE IF @term_frequency = 'z'
	BEGIN 
		SET @term_start = DATEADD(mi,@offset*5,@date)
	END
	ELSE
	BEGIN 
		SET @mult = CASE @term_frequency 
						WHEN 'm' THEN 1
						WHEN 'q' THEN 3
						WHEN 's' THEN 6
						WHEN 'a' THEN 12
					END
		
--		SET @term_end = DATEADD(month,@offset*@mult,CAST(FLOOR(CAST(@date AS DECIMAL(12, 5))) - 
--				   (DAY(@date) - 1) AS DATETIME))

		DECLARE @yy CHAR(4), @mm int
		SET @yy = CAST(DATEPART(yy,@date) AS CHAR(4))
		SET @mm = DATEPART(mm,@date)
					
		SET @term_start = CASE @term_frequency 
						WHEN 'm' THEN DATEADD(mm, DATEDIFF(mm,0,@date), 0)
						WHEN 'q' THEN DATEADD(qq, DATEDIFF(qq,0,@date), 0)
						WHEN 's' THEN 
							CASE WHEN 
								@mm < 7 THEN CAST(@yy + '-01-01' AS DATETIME)
								ELSE CAST(@yy + '-07-01' AS DATETIME)
							END 
						WHEN 'a' THEN DATEADD(yy, DATEDIFF(yy,0,@date), 0)
					END 

		SET @term_start = DATEADD(month,@offset*@mult,CAST(FLOOR(CAST(@term_start AS DECIMAL(12, 5))) - 
				   (DAY(@term_start) - 1) AS DATETIME))					
    END 
    
	RETURN @term_start 
               
END