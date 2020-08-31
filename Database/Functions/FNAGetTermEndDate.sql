/*
SELECT dbo.FNAGetTermEndDate('m','2009-12-04',0)
SELECT dbo.FNAGetTermEndDate('q','2009-12-04',0)
SELECT dbo.FNAGetTermEndDate('s','2009-12-04',0)
SELECT dbo.FNAGetTermEndDate('a','2009-12-04',0)

SELECT dbo.FNAGetTermEndDate('m','2009-12-04',1)
SELECT dbo.FNAGetTermEndDate('q','2009-12-04',1)
SELECT dbo.FNAGetTermEndDate('s','2009-12-04',1)
SELECT dbo.FNAGetTermEndDate('a','2009-12-04',1)

SELECT dbo.FNAGetTermEndDate('h','2009-12-04 00:02:03.123',0)
SELECT dbo.FNAGetTermEndDate('h','2009-12-04',2)

SELECT dbo.FNAGetTermEndDate('d','2009-12-04 00:02:03.123',23)
SELECT dbo.FNAGetTermEndDate('d','2009-12-04',1)

SELECT dbo.FNAGetTermEndDate('h','2015-09-09',23)
SELECT dbo.FNAGetTermEndDate('w','2009-12-04',1)
SELECT dbo.FNAGetTermEndDate('f','2009-12-04',3)
*/
IF OBJECT_ID('[dbo].[FNAGetTermEndDate]','fn') IS NOT NULL 
DROP FUNCTION [dbo].[FNAGetTermEndDate]
GO

CREATE FUNCTION [dbo].[FNAGetTermEndDate](
	@term_frequency CHAR(1),
	@date DATETIME,
	@offset INT 
)
RETURNS DATETIME 
AS
BEGIN

--DECLARE @term_frequency CHAR(1),
--@date DATETIME,
--@offset INT


--SET @term_frequency = 'f'
	set @offset=ISNULL(@offset,1)
	DECLARE @term_end DATETIME 
	DECLARE @mult INT 

	
	
	IF	@term_frequency = 'h' 
	BEGIN
		SET @mult = 1
		
		
		SET @term_end = DATEADD(hh, DATEDIFF(hh,0,@date)+(1+@offset)*@mult-1,0)
	END
	ELSE IF @term_frequency = 'd'
	BEGIN
		SET @mult = 1
		SET @term_end = DATEADD(dd, DATEDIFF(dd,0,@date)+(1+@offset)*@mult-1,0)
	END
	ELSE IF @term_frequency = 'w'
	BEGIN
		SET @mult = 1
		SET @term_end = DATEADD(dd,-2,DATEADD(ww, DATEDIFF(ww,0,@date)+(1+@offset)*@mult,0))
	END
	ELSE IF @term_frequency = 'f'
	BEGIN 
		SET @term_end = DATEADD(mi,@offset*15,@date)
	END
	ELSE IF @term_frequency = 'r'
	BEGIN 
		SET @term_end = DATEADD(mi,@offset*10,@date)
	END
	ELSE IF @term_frequency = 't'
	BEGIN 
		SET @term_end = DATEADD(mi,@offset*30,@date)
	END
	ELSE IF @term_frequency = 'z'
	BEGIN 
		SET @term_end = DATEADD(mi,@offset*5,@date)
	END
	ELSE 
	BEGIN
		SET @mult = CASE @term_frequency 
						WHEN 'm' THEN 1
						WHEN 'q' THEN 3
						WHEN 's' THEN 6
						WHEN 'a' THEN 12
					END
					
		SET @date = dbo.FNAGetTermStartDate(@term_frequency,@date,0)
					
		SET @term_end = DATEADD(dd,-1,DATEADD(mm, DATEDIFF(m,0,@date)+(1+@offset)*@mult,0))
	END	
	
	RETURN @term_end
END
